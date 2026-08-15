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

import sys
import xml.etree.ElementTree as ET
from pathlib import Path

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


def revisar(carpeta):
    escena = next(carpeta.glob("*.SCENE.MXML"))
    geometria = next(carpeta.glob("*.GEOMETRY.MXML"))
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
