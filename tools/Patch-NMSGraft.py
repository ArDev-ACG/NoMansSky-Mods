"""Devuelve al .GEOMETRY exportado todo lo que el .SCENE vanilla sigue indexando.

    python tools/Patch-NMSGraft.py <carpeta> <vanilla .GEOMETRY.MXML>
    python tools/Patch-NMSGraft.py <carpeta> <vanilla .GEOMETRY.MXML>            --bind <vanilla .ANIM.MXML>#<fotograma>

La carpeta lleva NUESTRO par .SCENE.MXML + .GEOMETRY.MXML; el .GEOMETRY se
reescribe en sitio. Despues hay que pasar tools/Check-NMSGraft.py, que es quien
dice si quedo algo fuera de rango.

NMSDK exporta la malla y nada mas: deja vacios los arrays por hueso y el de
piel por malla. Cuando lo que se entrega es el .SCENE vanilla injertado, el
esqueleto y el ragdoll siguen ahi y siguen leyendo esos arrays, asi que la
lectura se sale y el juego cierra sin avisar.

La regla, y no la lista de nombres, es lo que importa:

  - lo que va POR HUESO se copia del vanilla tal cual. Nuestros huesos son los
    suyos, sin tocar: se corresponden uno a uno.
  - CON UNA EXCEPCION, `JointBindings`, y es `--bind`. Ver abajo.
  - lo que va POR MALLA se calcula de NUESTRA escena. Ahi el vanilla no sirve:
    describe sus mallas, no la nuestra.

Rellenar los arrays de uno en uno, segun iba crasheando, costo dos sesiones de
juego. Por eso se rellenan los cuatro de hueso siempre, aunque alguno ya venga
puesto, y por eso existe el Check.

EL BIND NO ES UNA CONSTANTE DEL HUESO, ES DE LA POSE EN QUE SE PESO LA MALLA.

`JointBindings` guarda, por hueso, la inversa de la pose de mundo en la que
estaba el esqueleto CUANDO SE PESO la malla, porque el juego hace

    v' = suma de  peso * mundo(t) * inversa_de_bind * v

y la inversa de bind es lo unico que lleva a `v` desde donde el artista lo
dejo hasta el espacio del hueso. Copiar la del vanilla vale mientras nuestra
malla este modelada EN LA MISMA POSTURA que la suya. Si no lo esta, cada
region sale disparada en cuanto se agarra a su propio hueso.

Medido el 04/09 en el cry wolf: con la pose de reposo puesta, `mundo * bind`
tendria que dar la identidad y desplaza la cabeza 1,69 m, el cuello 1,45 y las
patas de 0,45 a 1,27. Solo `RootJNT` sale a cero. Y no vale usar el reposo del
`.SCENE` en su lugar: se midio, y sale PEOR -tension 87 contra 35-, porque la
malla del vanilla tampoco esta pesada en su reposo.

`--bind <ANIM.MXML>#<fotograma>` pone en su sitio la inversa de la pose de
mundo del VANILLA en ese fotograma. Entonces `mundo(t) * bind` es el
movimiento del hueso DESDE ese fotograma, y eso se le puede aplicar a nuestra
malla tal como esta modelada: es un retarget, y no hace falta reescribir ni un
`.ANIM` ni el `.SCENE`. El fotograma se elige midiendo con
`tools/Pose-NMSMesh.py`, no a ojo: es el que deja la malla mas quieta y mas
cerca del suelo en los nueve clips a la vez.

`SkinMatrixLayout` se queda vacio a proposito: es la paleta de huesos sobre la
que se reparte una malla concreta, y la nuestra no se reparte -va rigida, con
el FFIENDMAT sin _F02_SKINNED-. El nodo la pide con FIRSTSKINMAT y LASTSKINMAT
a 0, que es un rango vacio y no lee nada.
"""

import importlib.util
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

POR_HUESO = ["JointBindings", "JointExtents", "JointMirrorAxes",
             "JointMirrorPairs"]


def contenedor(raiz, nombre):
    for p in raiz.iter():
        if p.get("name") == nombre and p.get("value") is None:
            return p
    raise KeyError(nombre)


def nodos_malla(raiz):
    encontrados = []
    for n in raiz.iter():
        if n.get("value") != "TkSceneNodeData":
            continue
        for p in n:
            if p.get("name") == "Type" and p.get("value") == "MESH":
                encontrados.append(n)
    return encontrados


def atributo(nodo, clave):
    cont = next(p for p in nodo if p.get("name") == "Attributes")
    for attr in cont:
        nombre = valor = None
        for p in attr:
            if p.get("name") == "Name":
                nombre = p.get("value")
            elif p.get("name") == "Value":
                valor = p.get("value")
        if nombre == clave:
            return valor
    return None


def _pose(nombre):
    """tools/Pose-NMSMesh.py como modulo: lleva un guion y no se importa.

    De ahi salen `sway` -el lector de .SCENE y de .ANIM- y `_a_matriz`. Es el
    mismo codigo que mide, asi que el bind que se escribe aqui y el que se
    mide alli no pueden discrepar.
    """
    ruta = Path(__file__).with_name(nombre)
    spec = importlib.util.spec_from_file_location("pose", ruta)
    modulo = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(modulo)
    return modulo


def jointindex(scene_mxml):
    """nombre de hueso -> su JOINTINDEX, que es el orden del array del bind.

    No es el orden del arbol: se comprobo contra el vanilla en `leer_bind`.
    """
    salida = {}

    def campos(nodo):
        return {q.get("name"): q for q in nodo}

    def recorrer(nodo):
        c = campos(nodo)
        if c.get("Type") is not None and c["Type"].get("value") == "JOINT":
            for a in (c.get("Attributes") if c.get("Attributes") is not None else ()):
                ca = campos(a)
                if (ca.get("Name") is not None
                        and ca["Name"].get("value") == "JOINTINDEX"):
                    salida[c["Name"].get("value")] = int(ca["Value"].get("value"))
        for h in (c.get("Children") if c.get("Children") is not None else ()):
            recorrer(h)

    recorrer(ET.parse(scene_mxml).getroot())
    return salida


def bind_de_referencia(nuestra, scene_mxml, anim_mxml, fotograma):
    """`JointBindings` = inversa de la pose de mundo del vanilla en un frame.

    Se escribe TRANSPUESTA, que es como el juego la guarda, y por JOINTINDEX.
    Aborta si la comprobacion no da la identidad: si eso falla, el bind esta
    mal y todo lo que se mida despues es ruido.
    """
    import numpy as np

    pose = _pose("Pose-NMSMesh.py")
    huesos = pose.sway.leer_scene(scene_mxml)
    giros, trasl, _ = pose.sway.leer_anim(anim_mxml)
    n = len(next(iter(giros.values())))
    if not 0 <= fotograma < n:
        raise SystemExit(f"el clip tiene {n} fotogramas y se pidio el {fotograma}")
    poses = pose.sway.pose_de_mundo(huesos, giros, trasl, n)

    orden = jointindex(scene_mxml)
    guardados = list(contenedor(nuestra, "JointBindings"))
    puestos = peor = 0
    for nombre, i in orden.items():
        if i >= len(guardados) or nombre not in poses:
            continue
        mundo = pose._a_matriz(poses[nombre][0][fotograma],
                               poses[nombre][1][fotograma])
        inversa = np.linalg.inv(mundo)
        peor = max(peor, float(np.abs(mundo @ inversa - np.eye(4)).max()))
        campos = {q.get("name"): q for q in guardados[i]}
        for prop, x in zip(campos["InvBindMatrix"], inversa.T.reshape(-1)):
            prop.set("value", f"{x:.10f}")
        puestos += 1
    assert peor < 1e-6, f"la inversa del bind no es inversa: {peor}"
    return puestos, len(guardados), n


def parchear(carpeta, ruta_vanilla, bind=None):
    escena = ET.parse(next(carpeta.glob("*.SCENE.MXML"))).getroot()
    ruta_nuestra = next(carpeta.glob("*.GEOMETRY.MXML"))
    arbol = ET.parse(ruta_nuestra)
    nuestra = arbol.getroot()
    vanilla = ET.parse(ruta_vanilla).getroot()

    for nombre in POR_HUESO:
        origen = contenedor(vanilla, nombre)
        destino = contenedor(nuestra, nombre)
        antes = len(destino)
        for hijo in list(destino):
            destino.remove(hijo)
        for hijo in list(origen):
            destino.append(hijo)
        print(f"  {nombre:18} {antes:>4} -> {len(destino):>4}   del vanilla")

    # El indice base de piel de cada malla es donde empieza su rango en la
    # paleta, que es justo lo que el nodo declara en FIRSTSKINMAT.
    mallas = nodos_malla(escena)
    destino = contenedor(nuestra, "MeshBaseSkinMat")
    antes = len(destino)
    for hijo in list(destino):
        destino.remove(hijo)
    for i, nodo in enumerate(mallas):
        base = atributo(nodo, "FIRSTSKINMAT") or "0"
        ET.SubElement(destino, "Property", {
            "name": "MeshBaseSkinMat", "value": base, "_index": str(i)})
    print(f"  {'MeshBaseSkinMat':18} {antes:>4} -> {len(destino):>4}   "
          f"de FIRSTSKINMAT de nuestras {len(mallas)} mallas")

    # Y AQUI, LO ULTIMO, EL BIND: pisa lo que se acaba de copiar del vanilla.
    # Va detras a proposito, para que el array ya tenga su forma y su tamano
    # y esto solo tenga que rellenar numeros.
    if bind is not None:
        anim, fotograma = bind
        ruta_escena = next(carpeta.glob("*.SCENE.MXML"))
        puestos, total, n = bind_de_referencia(nuestra, ruta_escena, anim,
                                               fotograma)
        print(f"  {'JointBindings':18} {puestos:>4} de {total:>4}   "
              f"inversa de {anim.name} fotograma {fotograma} de {n}")

    arbol.write(ruta_nuestra, encoding="utf-8", xml_declaration=True)
    print(f"\n  escrito {ruta_nuestra}")


if __name__ == "__main__":
    argumentos = [a for a in sys.argv[1:] if a != "--bind"]
    if len(argumentos) not in (2, 3):
        sys.exit(__doc__)
    referencia = None
    if len(argumentos) == 3:
        ruta, _, fotograma = argumentos[2].rpartition("#")
        referencia = (Path(ruta), int(fotograma))
    print()
    parchear(Path(argumentos[0]), Path(argumentos[1]), referencia)
    print()
