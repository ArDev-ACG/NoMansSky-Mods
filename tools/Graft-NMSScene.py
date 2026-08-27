"""Injerta NUESTRA malla en el .SCENE vanilla de una criatura.

    python tools/Graft-NMSScene.py <vanilla .SCENE.MBIN> <carpeta del export>
                                   <carpeta destino>

Del bicho vanilla se conserva TODO menos la geometria: los nodos JOINT con su
esqueleto y sus animaciones, las colisiones, las luces, el material y el
ATTACHMENT con su .ENTITY, que es donde vive el comportamiento. Por eso la
criatura sigue andando, atacando y sonando igual: lo unico que cambia es de
que vertices esta hecha.

En el SCUTTLER esto se hizo a mano, atributo por atributo. Existe este guion
porque la regla resulto ser corta y mecanica:

    los atributos del nodo de malla son los arrays POR MALLA del .GEOMETRY,
    dichos otra vez.

    BATCHSTARTGRAPH / BATCHSTARTPHYSI   0
    BATCHCOUNT                          IndexCount
    VERTRSTARTGRAPH / VERTRSTARTPHYSI   MeshVertRStart
    VERTRENDGRAPHIC / VERTRENDPHYSICS   MeshVertREnd
    BOUNDHULLST / BOUNDHULLED           BoundHullVertSt / BoundHullVertEd
    FIRSTSKINMAT / LASTSKINMAT          0 / len(SkinMatrixLayout)
    AABBMIN* / AABBMAX*                 MeshAABBMin / MeshAABBMax

No se lee nada del .SCENE que exporta NMSDK, y no por gusto: su AABB sale
RANCIO -escribe el de antes de mover la malla, porque ob.bound_box esta
cacheado y en segundo plano nadie reevalua el depsgraph-. El .GEOMETRY del
mismo export si lo trae bien. Se cree al .GEOMETRY.

Y EL AttackLight SE APAGA. Es la luz que pone dorado al bicho con una piel
clara; se aprobo apagada en la PRUEBA13 y la PRUEBA14 la resucito al
reinjertar. Vive aqui para que no se pueda volver a perder.

LAS DEMAS MALLAS SE BORRAN. Nuestro .GEOMETRY trae un solo stream, asi que
cualquier otro nodo MESH del vanilla -el ojo, el brillo del ojo- se quedaria
indexando un stream que no existe. En el SCUTTLER se borro `SUB1polySurface6`
por esto mismo; en el FIEND caen `SUB1_Fiend_Body` y `EyeGlow`.

Lo que este guion NO hace, y hay que hacer despues:

    python tools/Patch-NMSGraft.py <destino> <vanilla .GEOMETRY.MXML>
    python tools/Check-NMSGraft.py <destino>

El primero devuelve los cuatro arrays por hueso, que NMSDK deja vacios y el
ragdoll sigue leyendo. El segundo dice si algo quedo fuera de rango, y NO SE
CONSTRUYE SIN QUE DE SALIDA 0: con los indices pasados el juego cierra sin
avisar, y ya paso en la PRUEBA05.
"""

import shutil
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import nmsgeom


def campos(raiz):
    top = raiz[0] if raiz.tag == "Data" and len(raiz) == 1 else raiz
    return {h.get("name"): h for h in top if h.get("name")}


def nodos_malla(raiz):
    salida = []
    for n in raiz.iter():
        if n.get("value") != "TkSceneNodeData":
            continue
        if any(p.get("name") == "Type" and p.get("value") == "MESH" for p in n):
            salida.append(n)
    return salida


def nombre_de(nodo):
    return next((p.get("value") for p in nodo if p.get("name") == "Name"), "?")


def poner(nodo, clave, valor):
    cont = next(p for p in nodo if p.get("name") == "Attributes")
    for attr in cont:
        pares = {p.get("name"): p for p in attr}
        if pares.get("Name") is not None and pares["Name"].get("value") == clave:
            antes = pares["Value"].get("value")
            pares["Value"].set("value", str(valor))
            return antes
    raise KeyError(f"{nombre_de(nodo)} no tiene el atributo {clave}")


# El AttackLight es un punto de luz de 360 grados colgado de la mandibula,
# amarillo verdoso puro -0.861, 1.0, 0.0- con RADIUS 4.47 e INTENSITY 1.0.
# El bicho vanilla es rojo oscuro y se lo traga; nuestras pieles tienen
# blancos y rojos claros y lo devuelven, asi que el Horror sale dorado y con
# el ojo encendido. Se apago en la PRUEBA10, se aprobo en la PRUEBA13 y la
# PRUEBA14 lo resucito al reinjertar sobre el .SCENE vanilla: por eso vive
# AQUI y no en un paso a mano. Los valores son los de Light_pointLight1, la
# luz inerte que el propio vanilla ya trae en esa misma escena.
LUZ_MUERTA = {"FALLOFF": "0.000000", "INTENSITY": "0.000000",
              "RADIUS": "0.000100", "COL_R": "0.000000",
              "COL_G": "0.000000", "COL_B": "0.000000"}


def apagar_luces(raiz, nombres=("AttackLight",)):
    """Deja a cero las luces que encienden al bicho desde dentro."""
    apagadas = []
    for n in raiz.iter():
        if n.get("value") != "TkSceneNodeData":
            continue
        if not any(p.get("name") == "Type" and p.get("value") == "LIGHT"
                   for p in n):
            continue
        if nombre_de(n) not in nombres:
            continue
        for clave, valor in LUZ_MUERTA.items():
            poner(n, clave, valor)
        apagadas.append(nombre_de(n))
    return apagadas


def injertar(vanilla_scene, export, destino):
    destino.mkdir(parents=True, exist_ok=True)
    base = vanilla_scene.name.upper().replace(".SCENE.MBIN", "")

    escena_mbin = destino / f"{base}.SCENE.MBIN"
    shutil.copy(vanilla_scene, escena_mbin)
    # Por nombre exacto, no por *: el buzon de NMSDK guarda TODAS las
    # exportaciones -FIEND, FIENDEGG, SCUTTLER, SCENE- y un glob con comodin
    # se trae la primera que encuentre. Paso: el injerto salio con el .DATA
    # de otro bicho y el Check canto offsets imposibles.
    for sufijo in (".GEOMETRY.MBIN.PC", ".GEOMETRY.DATA.MBIN.PC"):
        origen = export / f"{base}{sufijo}"
        assert origen.is_file(), (
            f"no encuentro {origen}. El export tiene que llamarse como el "
            f"bicho vanilla; hay {sorted(p.name for p in export.glob('*' + sufijo))}")
        shutil.copy(origen, destino / f"{base}{sufijo}")

    for viejo in destino.glob("*.MXML"):
        viejo.unlink()
    escena_mxml = nmsgeom.descompilar(escena_mbin)
    geo_mxml = nmsgeom.descompilar(destino / f"{base}.GEOMETRY.MBIN.PC")

    geo = ET.parse(geo_mxml).getroot()
    c = campos(geo)

    def uno(nombre):
        hijos = list(c[nombre])
        assert len(hijos) == 1, (
            f"{nombre} trae {len(hijos)} entradas y nuestro .GEOMETRY tiene "
            f"que traer UNA malla")
        return hijos[0]

    def xyz(nombre):
        e = uno(nombre)
        return {p.get("name"): p.get("value") for p in e if p.get("value")}

    indices = c["IndexCount"].get("value")
    vert_ini = uno("MeshVertRStart").get("value")
    vert_fin = uno("MeshVertREnd").get("value")
    casco_ini = uno("BoundHullVertSt").get("value")
    casco_fin = uno("BoundHullVertEd").get("value")
    piel = len(list(c["SkinMatrixLayout"]))
    lo, hi = xyz("MeshAABBMin"), xyz("MeshAABBMax")
    id_stream = None
    for n in geo.iter():
        if n.get("value") == "TkMeshMetaData":
            id_stream = next(p.get("value") for p in n
                             if p.get("name") == "IdString")
            break

    print(f"\nnuestro .GEOMETRY: stream {id_stream}, "
          f"vertices {vert_ini}..{vert_fin}, {indices} indices, "
          f"casco {casco_ini}..{casco_fin}, {piel} matrices de piel")

    arbol = ET.parse(escena_mxml)
    raiz = arbol.getroot()
    padres = {h: p for p in raiz.iter() for h in p}
    mallas = nodos_malla(raiz)
    nuestra = next((n for n in mallas
                    if nombre_de(n).upper() == (id_stream or "").upper()), None)
    assert nuestra is not None, (
        f"el .SCENE no tiene ningun nodo MESH llamado {id_stream}. Los que "
        f"hay: {[nombre_de(n) for n in mallas]}. El nombre del objeto en "
        f"Blender tiene que ser el del nodo de malla vanilla")

    for n in mallas:
        if n is nuestra:
            continue
        print(f"  borrado el nodo MESH {nombre_de(n)}: nuestro .GEOMETRY no "
              f"trae su stream")
        padres[n].remove(n)

    for luz in apagar_luces(raiz):
        print(f"  apagada la luz {luz}: nuestra piel devuelve su amarillo")

    nuevos = {
        "BATCHSTARTGRAPH": 0, "BATCHSTARTPHYSI": 0,
        "BATCHCOUNT": indices,
        "VERTRSTARTGRAPH": vert_ini, "VERTRSTARTPHYSI": vert_ini,
        "VERTRENDGRAPHIC": vert_fin, "VERTRENDPHYSICS": vert_fin,
        "BOUNDHULLST": casco_ini, "BOUNDHULLED": casco_fin,
        "FIRSTSKINMAT": 0, "LASTSKINMAT": piel,
        "AABBMINX": lo["X"], "AABBMINY": lo["Y"], "AABBMINZ": lo["Z"],
        "AABBMAXX": hi["X"], "AABBMAXY": hi["Y"], "AABBMAXZ": hi["Z"],
    }
    print(f"\n{nombre_de(nuestra)}:")
    for clave, valor in nuevos.items():
        antes = poner(nuestra, clave, valor)
        marca = "  " if str(antes) == str(valor) else "<-"
        print(f"  {clave:16} {str(antes):>14} {marca} {valor}")

    arbol.write(escena_mxml, encoding="utf-8", xml_declaration=True)
    nmsgeom.compilar(escena_mxml)
    print(f"\n  escrito {escena_mbin}")
    print("\n  ahora: Patch-NMSGraft.py y despues Check-NMSGraft.py\n")


if __name__ == "__main__":
    if len(sys.argv) != 4:
        sys.exit(__doc__)
    injertar(Path(sys.argv[1]), Path(sys.argv[2]), Path(sys.argv[3]))
