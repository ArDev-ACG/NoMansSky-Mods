"""Comprueba que un .SCENE vanilla injertado no indexa fuera de NUESTRO .GEOMETRY.

    python tools/Check-NMSGraft.py <carpeta con los .MXML>

Existe por el crash del SCUTTLER. NMSDK exporta la malla, pero NO escribe los
arrays por hueso ni los de piel: los deja vacios. Cuando el .SCENE que se
entrega es el vanilla injertado, todo lo que el vanilla conservaba -el ragdoll,
los 114 nodos JOINT, el nodo de malla- sigue indexando esos arrays, y la lectura
se sale. El juego no avisa: cierra.

Esto lo caza sin entrar al juego. Cada comprobacion es un indice que el .SCENE
usa, contra la longitud del array que lo recibe en el .GEOMETRY.

Los .MXML se sacan con MBINCompiler:

    MBINCompiler.exe FREIGHTERFIEND.SCENE.MBIN
    MBINCompiler.exe FREIGHTERFIEND.GEOMETRY.MBIN.PC
"""

import shutil
import sys
import tempfile
import xml.etree.ElementTree as ET
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))

import nmsgeom
import nmsskin

# Un array por hueso tiene una entrada por cada nodo JOINT del .SCENE, mas una:
# el vanilla del SCUTTLER trae 115 para 114 nodos.
POR_HUESO = ["JointBindings", "JointExtents", "JointMirrorAxes",
             "JointMirrorPairs"]

# Un array por malla tiene una entrada por cada nodo MESH.
POR_MALLA = ["MeshAABBMin", "MeshAABBMax", "MeshVertRStart", "MeshVertREnd",
             "BoundHullVertSt", "BoundHullVertEd", "MeshBaseSkinMat"]

# Cada atributo del nodo de malla cierra un rango dentro de un array del
# .GEOMETRY, y el fin es EXCLUSIVO en los dos, pese al nombre de `LASTSKINMAT`:
# el vanilla va de 96 a 144 sobre 192 vertices de casco, y el nodo del ojo dice
# `LASTSKINMAT` 23 sobre 23 entradas. Un rango que empieza y acaba en el mismo
# sitio no lee nada, y por eso no basta con este bloque: los arrays que nadie
# indexa por rango se comprueban aparte, por longitud.
INDICES = [
    ("BOUNDHULLED", "BoundHullVerts"),
    ("LASTSKINMAT", "SkinMatrixLayout"),
]


def campos(raiz):
    """Los hijos del nodo raiz, por nombre: valor suelto o lista de hijos."""
    top = raiz[0] if raiz.tag == "Data" and len(raiz) == 1 else raiz
    salida = {}
    for hijo in top:
        nombre = hijo.get("name")
        if nombre is not None:
            salida[nombre] = hijo.get("value") or list(hijo)
    return salida


def nodos(raiz, tipo):
    encontrados = []
    for n in raiz.iter():
        if n.get("value") != "TkSceneNodeData":
            continue
        for p in n:
            if p.get("name") == "Type" and p.get("value") == tipo:
                encontrados.append(n)
    return encontrados


def atributos(nodo):
    cont = next(p for p in nodo if p.get("name") == "Attributes")
    salida = {}
    for attr in cont:
        clave = valor = None
        for p in attr:
            if p.get("name") == "Name":
                clave = p.get("value")
            elif p.get("name") == "Value":
                valor = p.get("value")
        if clave:
            salida[clave] = valor
    return salida


def nombre_de(nodo):
    for p in nodo:
        if p.get("name") == "Name":
            return p.get("value")
    return "?"


def _data_mxml(carpeta, temporal):
    """El .GEOMETRY.DATA.MXML, descompilandolo si hace falta.

    No estar descompilado NO es un fallo del injerto: la carpeta congelada
    solo guarda el .MBIN.PC. Antes esto se contaba como fallo y el check
    daba salida 1 por no encontrar un archivo intermedio, que es criar
    lobos. Si esta el .MBIN.PC, se saca; si no esta ninguno, se avisa y las
    comprobaciones de piel se saltan.

    Y se saca en un TEMPORAL, no al lado del original: este comando solo
    lee. work/models/scuttlermesh/ es la PRUEBA11, dada por buena en
    partida, y un revisor que escribe en lo que revisa no vale.
    """
    hecho = next(carpeta.glob("*.GEOMETRY.DATA.MXML"), None)
    if hecho is not None:
        return hecho
    mbin = next(carpeta.glob("*.GEOMETRY.DATA.MBIN.PC"), None)
    if mbin is None:
        return None
    copia = Path(temporal) / mbin.name
    shutil.copy(mbin, copia)
    return nmsgeom.descompilar(copia)


def _revisar_piel(carpeta, geo, mallas, temporal):
    """Lo que vive en el binario y el XML solo no ve.

    Existe porque con el flag _F02_SKINNED puesto y los indices de hueso
    fuera de rango el juego CIERRA SIN AVISAR. Eso paso en la PRUEBA05 y
    costo una sesion de juego entera.
    """
    fallos = []
    data_mxml = _data_mxml(carpeta, temporal)
    if data_mxml is None:
        print("  aviso: no hay .GEOMETRY.DATA, la piel no se revisa\n")
        return fallos

    geo_mxml = next(carpeta.glob("*.GEOMETRY.MXML"))
    s = nmsgeom.leer_streams(data_mxml)
    d = nmsgeom.layout(geo_mxml)
    stride = d["stride"]
    vertices = int(geo.get("VertexCount", 0))
    print(f"  stride {stride} con los canales {sorted(d['elementos'])}\n")

    if stride * vertices != len(s.vertices):
        fallos.append(f"stride {stride} x {vertices} vertices = "
                      f"{stride * vertices}, pero el buffer trae "
                      f"{len(s.vertices)} bytes")

    data_mbin = next(carpeta.glob("*.GEOMETRY.DATA.MBIN.PC"), None)
    if data_mbin is not None:
        inicio = nmsgeom.cabecera(data_mbin, s)
        meta = ET.parse(geo_mxml).getroot().find(
            ".//Property[@value='TkMeshMetaData']")
        espera = {"VertexDataSize": len(s.vertices),
                  "VertexDataOffset": inicio,
                  "IndexDataSize": len(s.indices),
                  "IndexDataOffset": len(s.vertices),
                  "VertexPositionDataSize": len(s.posiciones),
                  "VertexPositionDataOffset":
                      inicio + len(s.vertices) + len(s.indices)}
        for clave, valor in espera.items():
            dice = int(meta.find(f"Property[@name='{clave}']").get("value"))
            if dice != valor:
                fallos.append(f"{clave} dice {dice}, pero el .DATA da {valor}")

    crudo = geo.get("SkinMatrixLayout")
    palet = ([int(p.get("value")) for p in crudo]
             if isinstance(crudo, list) else [])
    joints = nmsskin.leer_joints(next(carpeta.glob("*.SCENE.MXML")))
    fuera = [v for v in palet if v not in set(joints.values())]
    if fuera:
        fallos.append(f"SkinMatrixLayout apunta a JOINTINDEX que no existen: "
                      f"{fuera[:8]} (los del .SCENE van de 1 a {len(joints)})")

    for nodo in mallas:
        attr = atributos(nodo)
        primero = int(attr.get("FIRSTSKINMAT", 0))
        ultimo = int(attr.get("LASTSKINMAT", 0))
        if ultimo == primero:
            continue  # malla rigida a proposito: no hay piel que revisar

        if 5 not in d["elementos"] or 6 not in d["elementos"]:
            fallos.append(f"{nombre_de(nodo)} pide piel, pero el VertexLayout "
                          f"no declara los canales 5 y 6")
            continue

        v = np.frombuffer(s.vertices, dtype=np.uint8).reshape(-1, stride)
        idx = v[:, d["elementos"][5]: d["elementos"][5] + 4]
        w = v[:, d["elementos"][6]: d["elementos"][6] + 8].copy().view("<f2")

        tope = ultimo - primero
        peor = int(idx.max())
        if peor >= tope:
            culpables = int((idx.max(axis=1) >= tope).sum())
            fallos.append(f"{nombre_de(nodo)}: indice de hueso {peor} con un "
                          f"rango de {tope} ({culpables} vertices). "
                          f"EL JUEGO CIERRA SIN AVISAR")

        suma = w.astype("float32").sum(axis=1)
        malos = int((abs(suma - 1.0) > 0.01).sum())
        if malos:
            i = int(abs(suma - 1.0).argmax())
            fallos.append(f"{nombre_de(nodo)}: {malos} vertices con pesos que "
                          f"no suman 1 (el peor, el {i}, suma {suma[i]:.3f})")

    return fallos


def _hace_falta(carpeta, patron, de):
    """El .MXML, sacandolo del .MBIN si solo esta el binario.

    Antes esto era un next() pelado y reventaba con un StopIteration sin
    decir que faltaba. Pasa siempre que se revisa lo DESPLEGADO, porque en
    GAMEDATA\\MODS solo estan los .MBIN.
    """
    hecho = next(carpeta.glob(patron), None)
    if hecho is not None:
        return hecho
    binario = next(carpeta.glob(de), None)
    if binario is None:
        sys.exit(f"\n  en {carpeta} no hay ni {patron} ni {de}\n")
    return nmsgeom.descompilar(binario)


def revisar(carpeta):
    escena = _hace_falta(carpeta, "*.SCENE.MXML", "*.SCENE.MBIN")
    geometria = _hace_falta(carpeta, "*.GEOMETRY.MXML", "*.GEOMETRY.MBIN.PC")
    print(f"  .SCENE     {escena.name}")
    print(f"  .GEOMETRY  {geometria.name}\n")

    raiz_escena = ET.parse(escena).getroot()
    geo = campos(ET.parse(geometria).getroot())

    def largo(nombre):
        valor = geo.get(nombre)
        return len(valor) if isinstance(valor, list) else 0

    fallos = []
    huesos = nodos(raiz_escena, "JOINT")
    mallas = nodos(raiz_escena, "MESH")
    print(f"  {len(huesos)} nodos JOINT, {len(mallas)} nodos MESH\n")

    for nombre in POR_HUESO:
        if largo(nombre) < len(huesos):
            fallos.append(f"{nombre}: {largo(nombre)} entradas para "
                          f"{len(huesos)} huesos")

    for nombre in POR_MALLA:
        if largo(nombre) < len(mallas):
            fallos.append(f"{nombre}: {largo(nombre)} entradas para "
                          f"{len(mallas)} mallas")

    vertices = int(geo.get("VertexCount", 0))
    indices = int(geo.get("IndexCount", 0))

    for nodo in mallas:
        attr = atributos(nodo)
        etiqueta = nombre_de(nodo)

        for clave, array in INDICES:
            if clave not in attr:
                continue
            indice = int(attr[clave])
            if indice > largo(array):
                fallos.append(f"{etiqueta}.{clave} = {indice}, pero "
                              f"{array} tiene {largo(array)} entradas")

        for clave in ("VERTRENDGRAPHIC", "VERTRENDPHYSICS"):
            if clave in attr and int(attr[clave]) > vertices - 1:
                fallos.append(f"{etiqueta}.{clave} = {attr[clave]}, pero "
                              f"VertexCount es {vertices}")

        if "BATCHSTARTGRAPH" in attr and "BATCHCOUNT" in attr:
            fin = int(attr["BATCHSTARTGRAPH"]) + int(attr["BATCHCOUNT"])
            if fin > indices:
                fallos.append(f"{etiqueta}: el lote llega a {fin}, pero "
                              f"IndexCount es {indices}")

    with tempfile.TemporaryDirectory(prefix="check-nmsgraft-") as temporal:
        fallos += _revisar_piel(carpeta, geo, mallas, temporal)
    return fallos


if __name__ == "__main__":
    carpeta = Path(sys.argv[1] if len(sys.argv) > 1 else ".")
    print(f"\nInjerto en {carpeta}\n")
    fallos = revisar(carpeta)

    if fallos:
        print("  FUERA DE RANGO -- el juego cierra al usarlo:\n")
        for f in fallos:
            print(f"    {f}")
        print()
        sys.exit(1)

    print("  todos los indices del .SCENE caen dentro del .GEOMETRY\n")
