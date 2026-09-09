"""Reescribe los .ANIM del vanilla para NUESTRA malla, y con ellos el bind.

    python tools/Retarget-NMSRig.py crywolf

Existe porque el 04/09 se midio POR QUE ninguna de las cinco pruebas del cry
wolf cambiaba nada en pantalla, y la respuesta no estaba en los pesos:

  1. `JointBindings` es del VANILLA -lo copia Patch-NMSGraft- y NO es la
     inversa del reposo de nuestra escena. Medido: con la pose de reposo
     puesta, `World_reposo * InvBind` deberia ser la identidad y desplaza la
     region de la cabeza 3,21 m, el cuello 1,47 y las patas de 0,46 a 1,21.
     Solo `RootJNT` sale a cero. O sea que en cuanto una region se agarra a
     su propio hueso, sale disparada: ESAS eran las "cuchillas".
  2. Por eso el agarre habia ido bajando prueba tras prueba hasta 0,04 en la
     pata delantera izquierda y 0,22 en la cabeza. Con esos numeros NADA
     sigue a su hueso: los 9672 vertices los mandan `RootJNT` y `NewBack1JNT`,
     o sea el bicho va RIGIDO, y por eso daba igual lo que se tocara.
  3. Y aunque el bind se arregle, pegar nuestra malla a las rotaciones del
     clip TAL CUAL le pone la POSTURA DE LA ARANA: el clip no guarda un
     movimiento, guarda una pose absoluta por fotograma. Renderizado el
     04/09: el lobo sale tumbado y descuartizado.

La solucion es un retarget de verdad, y hace falta escribir los clips porque
el juego no sabe restar poses: lo que se guarda es el DELTA contra una pose
de referencia comun -el fotograma 0 de `idle`- aplicado sobre NUESTRO reposo.

    W_hueso(t) = [ W_vanilla(t) * W_ref^-1 ] * W_nuestro_reposo

Puesto en local -que es lo que lleva el archivo- toda la parte vanilla se va
a dos constantes por hueso, una por delante y otra por detras:

    q_local_nuevo(t) = A * q_local_vanilla(t) * B
    A = conj(q_reposo_padre) * q_ref_padre        B = conj(q_ref) * q_reposo

o sea que un canal QUIETO sigue quieto y uno ANIMADO sigue animado: se
reescriben los mismos huecos del archivo y no se toca ni la estructura ni el
numero de fotogramas. La traslacion es aun mas simple: es el hueso puesto
donde le toca en NUESTRA malla, constante, salvo `RootJNT`, que lleva el
avance del clip y solo se le suma el desplazamiento del pivote.

LOS CLIPS NO SE PISAN: se escriben en `SPIDERRIG\ANIM_CRYWOLF\` y quien los
nombra es NUESTRO `_FIEND_BODY.ENTITY`, que es el archivo donde el juego
lleva las 22 rutas. El FREIGHTERFIEND -o sea el SkrullCrawler- sigue leyendo
los del vanilla y no se entera.

Va DESPUES de `Skin-NMSGeometry.py` y de `Patch-NMSGraft.py`, porque los dos
copian la carpeta o el bind del vanilla y borrarian esto, y ANTES del
`Check-NMSGraft.py` que autoriza a construir.
"""

import importlib.util
import shutil
import subprocess
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

import numpy as np

RAIZ = Path(__file__).resolve().parent.parent
MBINCOMPILER = RAIZ / "tools" / "AMUMSS" / "MODBUILDER" / "MBINCompiler.exe"


def _modulo(nombre, ruta):
    """Un guion en el nombre impide el import normal."""
    spec = importlib.util.spec_from_file_location(nombre, ruta)
    modulo = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(modulo)
    return modulo


P = _modulo("pose", Path(__file__).with_name("Pose-NMSMesh.py"))
sway = P.sway

# EL MAPA DE REGIONES ESTA COPIADO de tools/Weight-NMSMesh.py A PROPOSITO: ese
# guion solo corre dentro de Blender -importa bpy en la primera linea- y esto
# tiene que correr fuera. Si el mapa cambia alli, cambia aqui; el assert de
# `regiones()` avisa si los nombres dejan de casar con el .SCENE.
MODELOS = {
    "crywolf": dict(
        pose="crywolf",
        anim=RAIZ / "work" / "models" / "crywolfmesh_anim",
        entidad=("models/planets/creatures/spiderrig/fiend/entities",
                 "_fiend_body.entity"),
        carpeta_vanilla="MODELS/PLANETS/CREATURES/SPIDERRIG/ANIM/",
        carpeta_nuestra="MODELS/PLANETS/CREATURES/SPIDERRIG/ANIM_CRYWOLF/",
        geometria="FIEND.GEOMETRY.MXML",
        escena="FIEND.SCENE.MXML",
        entidad_salida="_FIEND_BODY.ENTITY.MXML",
        referencia="fiendidle.anim",
        regiones=(
            ("NewHeadJNT",     lambda u, v, w: v > 0.72 and w < 0.35),
            ("NewBack1JNT",    lambda u, v, w: w < 0.35),
            ("LFirstLeg1JNT",  lambda u, v, w: v < 0.45 and w < 0.62 and u < 0.45),
            ("RFirstLeg1JNT",  lambda u, v, w: v < 0.45 and w < 0.62 and u > 0.55),
            ("LFourthLeg1JNT", lambda u, v, w: v < 0.45 and u < 0.45),
            ("RFourthLeg1JNT", lambda u, v, w: v < 0.45 and u > 0.55),
            ("RootJNT",        lambda u, v, w: True),
        ),
        # DONDE VA CADA HUESO EN NUESTRA MALLA, y el percentil no es un gusto:
        # una pata cuelga de su HOMBRO o de su CADERA, o sea del techo de su
        # region -95, y no 100, para no coger el vertice suelto-; la cabeza y
        # el cuello giran desde su BASE -5-; y el tronco pivota por su medio.
        # La X se centra en 0 en lo que va por el eje, para no heredar la
        # asimetria de la malla; en las patas se coge la mediana.
        destinos={
            "RootJNT":        (50, True),
            "NewBack1JNT":    (5,  True),
            "NewHeadJNT":     (5,  True),
            "LFirstLeg1JNT":  (95, False),
            "RFirstLeg1JNT":  (95, False),
            "LFourthLeg1JNT": (95, False),
            "RFourthLeg1JNT": (95, False),
        },
    ),
}


def conj(q):
    c = np.array(q, dtype=np.float64).copy()
    c[..., :3] *= -1
    return c


def _campos(nodo):
    return {p.get("name"): p for p in nodo}


def regiones(M, V):
    """Un nombre de hueso por vertice, con el mapa duro y sin agarre."""
    lo, tam = V.min(axis=0), np.ptp(V, axis=0)
    salida = []
    for punto in V:
        u, v, w = (punto - lo) / tam
        for hueso, dentro in M["regiones"]:
            if dentro(u, v, w):
                salida.append(hueso)
                break
    return np.array(salida)


def destinos(M, V, REG):
    """Hueso -> donde tiene que estar su pivote en NUESTRA malla."""
    salida = {}
    for hueso, (percentil, centrado) in M["destinos"].items():
        dentro = V[REG == hueso]
        assert len(dentro), f"la region {hueso} no recibe ni un vertice"
        x = 0.0 if centrado else float(np.median(dentro[:, 0]))
        salida[hueso] = np.array([x,
                                  float(np.percentile(dentro[:, 1], percentil)),
                                  float(np.median(dentro[:, 2]))])
    return salida


def esqueleto(huesos, DESTINO):
    """El reposo NUESTRO: mismas rotaciones que el vanilla, otros pivotes.

    Las rotaciones NO se tocan y eso es deliberado. El delta ya lleva el
    movimiento; cambiar tambien el eje de reposo obligaria a decidir a mano
    hacia donde mira cada hueso nuestro, que es justo lo que no hay forma de
    medir. Con el pivote bien puesto la pata gira alrededor de su cadera, que
    es lo que se ve.
    """
    orden = list(huesos)
    q, p = P.apilar(huesos, orden, {}, {}, 1)
    q_reposo = {n: q[i, 0] for i, n in enumerate(orden)}
    p_vanilla = {n: p[i, 0] for i, n in enumerate(orden)}
    R = {n: P._a_matriz(q_reposo[n][None, :], np.zeros((1, 3)))[0, :3, :3]
         for n in orden}

    p_nuestro, local = {}, {}
    for n in orden:                      # leer_scene ya devuelve orden de arbol
        padre = huesos[n][0]
        base = p_nuestro[padre] if padre else np.zeros(3)
        giro = R[padre] if padre else np.eye(3)
        if n in DESTINO:
            local[n] = giro.T @ (DESTINO[n] - base)
            p_nuestro[n] = DESTINO[n]
        else:
            t = huesos[n][1]
            local[n] = np.array([t["TransX"], t["TransY"], t["TransZ"]])
            p_nuestro[n] = base + giro @ local[n]
    return orden, q_reposo, R, p_vanilla, p_nuestro, local


def invbind(orden, R, p_nuestro):
    """La inversa del reposo NUESTRO, que es lo que el bind tiene que ser."""
    salida = {}
    for n in orden:
        m = np.eye(4)
        m[:3, :3] = R[n]
        m[:3, 3] = p_nuestro[n]
        salida[n] = np.linalg.inv(m)
    return salida


def escribir_bind(geo_mxml: Path, scene_mxml: Path, INVBIND):
    """`JointBindings` del .GEOMETRY, por JOINTINDEX y transpuesta.

    El indice es el JOINTINDEX del nodo del .SCENE y no el orden del arbol, y
    la matriz se guarda TRANSPUESTA. Las dos cosas salen de `leer_bind`, que
    es quien las midio contra el vanilla.
    """
    indice = {}

    def recorrer(nodo):
        c = _campos(nodo)
        if c.get("Type") is not None and c["Type"].get("value") == "JOINT":
            atributos = c.get("Attributes")
            for a in (atributos if atributos is not None else ()):
                ca = _campos(a)
                if (ca.get("Name") is not None
                        and ca["Name"].get("value") == "JOINTINDEX"):
                    indice[c["Name"].get("value")] = int(ca["Value"].get("value"))
        hijos = c.get("Children")
        for h in (hijos if hijos is not None else ()):
            recorrer(h)

    recorrer(ET.parse(scene_mxml).getroot())
    arbol = ET.parse(geo_mxml)
    guardados = list(_campos(arbol.getroot())["JointBindings"])
    puestos = 0
    for nombre, i in indice.items():
        if i >= len(guardados) or nombre not in INVBIND:
            continue
        valores = INVBIND[nombre].T.reshape(-1)
        for prop, x in zip(_campos(guardados[i])["InvBindMatrix"], valores):
            prop.set("value", f"{x:.10f}")
        puestos += 1
    arbol.write(geo_mxml, encoding="utf-8", xml_declaration=True)
    return puestos, len(guardados)


def escribir_scene(scene_mxml: Path, local):
    """Los mismos pivotes en el .SCENE, para que el reposo case con el bind.

    En partida manda el clip -sus canales de traslacion pisan lo que diga la
    escena, medido: los 115 nodos traen traslacion y la de 112 de ellos es
    constante-, asi que esto no cambia lo que se ve. Se escribe porque si no
    la escena diria una cosa y el bind otra, y el primer guion que las cruce
    -`Pose-NMSMesh.py`, sin ir mas lejos- mediria ruido.
    """
    arbol = ET.parse(scene_mxml)
    puestos = 0

    def recorrer(nodo):
        nonlocal puestos
        c = _campos(nodo)
        if (c.get("Type") is not None and c["Type"].get("value") == "JOINT"
                and c["Name"].get("value") in local):
            t = local[c["Name"].get("value")]
            for prop in c["Transform"]:
                for eje, x in zip("XYZ", t):
                    if prop.get("name") == f"Trans{eje}":
                        prop.set("value", f"{x:.10f}")
            puestos += 1
        hijos = c.get("Children")
        for h in (hijos if hijos is not None else ()):
            recorrer(h)

    recorrer(arbol.getroot())
    arbol.write(scene_mxml, encoding="utf-8", xml_declaration=True)
    return puestos


def compilar(mxml: Path) -> Path:
    """MBINCompiler sobre el .MXML, dejando el binario al lado.

    La extension la pone MBINCompiler y no siempre es la misma: el .GEOMETRY
    sale `.MBIN.PC` y todo lo demas `.MBIN`, asi que se miran las dos.
    """
    base = mxml.parent / mxml.name[:-len(".MXML")]
    posibles = [base.with_name(base.name + ".MBIN"),
                base.with_name(base.name + ".MBIN.PC")]
    for p in posibles:
        if p.exists():
            p.unlink()
    r = subprocess.run([str(MBINCOMPILER), mxml.name], cwd=str(mxml.parent),
                       capture_output=True, text=True)
    hecho = [p for p in posibles if p.exists()]
    if not hecho:
        raise RuntimeError(f"MBINCompiler no escribio {base.name}.MBIN[.PC] "
                           f"({r.returncode}):\n{r.stdout}\n{r.stderr}")
    return hecho[0]


def clips_de(entidad_mxml: Path, carpeta: str):
    """Los clips que el .ENTITY nombra, sin repetir y en su orden."""
    fuera = []
    for linea in entidad_mxml.read_text(encoding="utf-8").splitlines():
        if carpeta in linea:
            archivo = linea.split(carpeta, 1)[1].split('"', 1)[0]
            if archivo not in fuera:
                fuera.append(archivo)
    return fuera


def escribir_clip(origen: Path, destino: Path, huesos, q_reposo, q_ref,
                  local, p_vanilla, p_nuestro):
    """Un clip con el delta ya horneado. Devuelve cuantos canales cambio."""
    arbol = ET.parse(origen)
    arriba = _campos(arbol.getroot())
    fotogramas = list(arriba["AnimFrameData"])
    quietos = _campos(arriba["StillFrameData"])

    giros_vivos = [list(_campos(f)["Rotations"]) for f in fotogramas]
    trasl_vivas = [list(_campos(f)["Translations"]) for f in fotogramas]
    giros_quietos = list(quietos["Rotations"])
    trasl_quietas = list(quietos["Translations"])
    n_giro, n_trasl = len(giros_vivos[0]), len(trasl_vivas[0])

    def ranura(vivos, n, parados, i):
        """Los nodos XML de un canal: uno por fotograma, o el unico quieto."""
        return [v[i] for v in vivos] if i < n else [parados[i - n]]

    tocados = 0
    for nodo in arriba["NodeData"]:
        d = {p.get("name"): p.get("value") for p in nodo}
        nombre = d["Node"]
        if nombre not in huesos:
            continue                      # del rig comun, pero no de este bicho
        padre = huesos[nombre][0]
        A = (sway._multiplicar(conj(q_reposo[padre]), q_ref[padre])
             if padre else np.array([0.0, 0.0, 0.0, 1.0]))
        B = sway._multiplicar(conj(q_ref[nombre]), q_reposo[nombre])

        for prop in ranura(giros_vivos, n_giro, giros_quietos,
                           int(d["RotIndex"])):
            c = {x.get("name"): x for x in prop}
            q = np.array([float(c[k].get("value")) for k in "XYZW"])
            for k, x in zip("XYZW", sway._multiplicar(A, sway._multiplicar(q, B))):
                c[k].set("value", f"{x:.10f}")
            tocados += 1

        # LA TRASLACION ES EL HUESO PUESTO EN SU SITIO, y es constante: el
        # unico que lleva movimiento propio es `RootJNT`, que es el avance
        # del clip, y a ese solo se le suma el salto del pivote.
        desplaza = (p_nuestro["RootJNT"] - p_vanilla["RootJNT"]
                    if nombre == "RootJNT" else None)
        for prop in ranura(trasl_vivas, n_trasl, trasl_quietas,
                           int(d["TransIndex"])):
            c = {x.get("name"): x for x in prop}
            if desplaza is not None:
                t = np.array([float(c[k].get("value")) for k in "XYZ"]) + desplaza
            else:
                t = local[nombre]
            for k, x in zip("XYZ", t):
                c[k].set("value", f"{x:.10f}")
            tocados += 1

    destino.parent.mkdir(parents=True, exist_ok=True)
    arbol.write(destino, encoding="utf-8", xml_declaration=True)
    return tocados


def main(argv):
    cual = next((a for a in argv[1:] if not a.startswith("-")), "crywolf")
    M = dict(MODELOS[cual])
    # `--anim` porque cada prueba cose en su propia carpeta: la anterior se
    # queda entera como estaba, que es lo que permite volver atras sin borrar.
    if "--anim" in argv:
        M["anim"] = Path(argv[argv.index("--anim") + 1])
    Mp = P.MODELOS[M["pose"]]
    huesos = sway.leer_scene(Mp["raiz"] / Mp["scene"])

    V = P.cargar_pesos(Mp["pesos"])[0]
    REG = regiones(M, V)
    faltan = [n for n in set(REG) if n not in huesos]
    assert not faltan, f"el mapa nombra huesos que no estan en el .SCENE: {faltan}"
    DESTINO = destinos(M, V, REG)

    orden, q_reposo, R, p_vanilla, p_nuestro, local = esqueleto(huesos, DESTINO)
    INVBIND = invbind(orden, R, p_nuestro)

    print(f"{cual}: {len(V)} vertices, {len(huesos)} huesos en el esqueleto")
    print(f"{'hueso':16} {'vert':>6}  {'pivote vanilla':>22}  "
          f"{'pivote nuestro':>22}  salto")
    for n in sorted(DESTINO):
        print(f"{n:16} {int((REG == n).sum()):6}  "
              f"{str(np.round(p_vanilla[n], 2)):>22}  "
              f"{str(np.round(p_nuestro[n], 2)):>22}  "
              f"{np.linalg.norm(p_nuestro[n] - p_vanilla[n]):5.2f} m")

    # COMPROBACION 1, Y ABORTA: con el bind nuevo, la pose de reposo tiene que
    # devolver la malla EXACTAMENTE donde esta. Es la que no pasaba antes.
    peor = max(float(np.abs(P._a_matriz(q_reposo[n][None, :],
                                        p_nuestro[n][None, :])[0] @ INVBIND[n]
                            - np.eye(4)).max()) for n in orden)
    assert peor < 1e-6, f"el bind nuevo no es la inversa del reposo: {peor}"
    print(f"\nbind nuevo: reposo * inversa = identidad, error {peor:.1e}")

    # La pose de referencia. Todos los clips se cuentan contra la MISMA, o
    # cambiar de clip daria un salto.
    ref = P.asegurar_anim(Mp["raiz"], Mp["anims"], M["referencia"])
    g, t, _ = sway.leer_anim(ref)
    q = P.apilar(huesos, orden, g, t, len(next(iter(g.values()))))[0]
    q_ref = {n: q[i, 0] for i, n in enumerate(orden)}

    # El .ENTITY: la copia del vanilla con las 22 rutas reapuntadas.
    ent_van = P.asegurar_anim(Mp["raiz"], *M["entidad"])
    lista = clips_de(ent_van, M["carpeta_vanilla"])
    print(f"el .ENTITY nombra {len(lista)} clips")

    destino_ent = M["anim"] / M["entidad_salida"]
    destino_ent.write_text(
        ent_van.read_text(encoding="utf-8").replace(M["carpeta_vanilla"],
                                                    M["carpeta_nuestra"]),
        encoding="utf-8")
    compilar(destino_ent)
    # Los .MXML se quedan al lado del .MBIN A PROPOSITO: son los que lee
    # `Pose-NMSMesh.py crywolf06`, que es quien comprueba lo que se entrega
    # -nuestra escena, nuestro bind y nuestros clips- sin entrar al juego.

    salida = M["anim"] / M["carpeta_nuestra"].rstrip("/").rsplit("/", 1)[1]
    if salida.exists():
        shutil.rmtree(salida)
    for archivo in lista:
        origen = P.asegurar_anim(Mp["raiz"], Mp["anims"],
                                 archivo.lower().replace(".mbin", ""))
        mxml = salida / archivo.replace(".MBIN", ".MXML")
        tocados = escribir_clip(origen, mxml, huesos, q_reposo, q_ref, local,
                                p_vanilla, p_nuestro)
        compilar(mxml)
        print(f"  {archivo:28} {tocados:5} canales reescritos")

    geo = M["anim"] / M["geometria"]
    puestos, total = escribir_bind(geo, Mp["raiz"] / Mp["scene"], INVBIND)
    compilar(geo)
    print(f"\nbind escrito en {puestos} de {total} huesos de {geo.name}")

    escena = M["anim"] / M["escena"]
    print(f"pivotes escritos en {escribir_scene(escena, local)} JOINT "
          f"de {escena.name}")
    compilar(escena)
    print(f"clips en {salida}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
