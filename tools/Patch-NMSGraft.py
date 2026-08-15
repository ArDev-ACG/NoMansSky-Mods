"""Devuelve al .GEOMETRY exportado todo lo que el .SCENE vanilla sigue indexando.

    python tools/Patch-NMSGraft.py <carpeta> <vanilla .GEOMETRY.MXML>

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
  - lo que va POR MALLA se calcula de NUESTRA escena. Ahi el vanilla no sirve:
    describe sus mallas, no la nuestra.

Rellenar los arrays de uno en uno, segun iba crasheando, costo dos sesiones de
juego. Por eso se rellenan los cuatro de hueso siempre, aunque alguno ya venga
puesto, y por eso existe el Check.

`SkinMatrixLayout` se queda vacio a proposito: es la paleta de huesos sobre la
que se reparte una malla concreta, y la nuestra no se reparte -va rigida, con
el FFIENDMAT sin _F02_SKINNED-. El nodo la pide con FIRSTSKINMAT y LASTSKINMAT
a 0, que es un rango vacio y no lee nada.
"""

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


def parchear(carpeta, ruta_vanilla):
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

    arbol.write(ruta_nuestra, encoding="utf-8", xml_declaration=True)
    print(f"\n  escrito {ruta_nuestra}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    print()
    parchear(Path(sys.argv[1]), Path(sys.argv[2]))
    print()
