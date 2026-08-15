"""Pone la piel en el .GEOMETRY: sube el stride de 8 a 20 y llena los
canales 5 y 6 con los pesos de pesos.json.

    python tools/Skin-NMSGeometry.py <carpeta origen> <carpeta destino>

Copia la carpeta entera y trabaja solo sobre la copia: la de origen no
se toca nunca, y asi no hay un paso manual que se pueda olvidar. El
sidecar sale de <origen>/pesos.json. Si el destino ya existe, aborta.

Reescribe tres archivos y recompila los tres, porque lo que reparte el
.lua son los .MBIN:

    .GEOMETRY.DATA.MBIN.PC   el bloque de vertices, de stride 8 a 20
    .GEOMETRY.MBIN.PC        VertexLayout, StreamMetaDataArray,
                             SkinMatrixLayout y MeshBaseSkinMat
    .SCENE.MBIN              FIRSTSKINMAT / LASTSKINMAT del nodo de malla

NO toca el .MATERIAL: el flag _F02_SKINNED va el ultimo y va en el .lua.
Con el flag puesto y los pesos mal, el bicho se estira sin forma; con los
indices fuera de rango, el juego cierra sin avisar. Por eso detras de esto
va tools/Check-NMSGraft.py, antes de construir nada.

SIRVE PARA CUALQUIER MALLA, no solo para el SkrullCrawler: no hay ni un
nombre de archivo ni una cifra de esa malla escritos aqui. Todo sale de la
carpeta que se le pasa. Lo unico que da por supuesto son dos cosas, y las
dos las comprueba y las dice en voz alta en vez de corromper el buffer:

    - que la malla venga a stride 8 -normal y tangente y nada mas-, que es
      lo que deja el exportador de NMSDK.
    - que el .SCENE traiga UN solo nodo MESH.
"""

import shutil
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import nmsgeom
import nmsskin

STRIDE_VIEJO = 8
STRIDE_NUEVO = 20


def _lista(raiz, nombre, valores):
    cont = next(p for p in raiz.iter()
                if p.get("name") == nombre and p.get("value") is None)
    for hijo in list(cont):
        cont.remove(hijo)
    for i, v in enumerate(valores):
        ET.SubElement(cont, "Property",
                      {"name": nombre, "value": str(v), "_index": str(i)})


def _nodos_malla(raiz):
    salida = []
    for n in raiz.iter():
        if n.get("value") != "TkSceneNodeData":
            continue
        if any(p.get("name") == "Type" and p.get("value") == "MESH" for p in n):
            salida.append(n)
    return salida


def _poner_attr(nodo, clave, valor):
    cont = next(p for p in nodo if p.get("name") == "Attributes")
    for attr in cont:
        campos = {p.get("name"): p for p in attr}
        if campos["Name"].get("value") == clave:
            campos["Value"].set("value", str(valor))
            return
    raise KeyError(clave)


def coser(origen: Path, destino: Path) -> None:
    if destino.exists():
        sys.exit(f"{destino} ya existe: borra o elige otra")
    shutil.copytree(origen, destino)
    print(f"  copiado    {origen} -> {destino}")

    pesos = nmsskin.leer_pesos(origen / "pesos.json")
    data = next(destino.glob("*.GEOMETRY.DATA.MBIN.PC"))
    geo = next(destino.glob("*.GEOMETRY.MBIN.PC"))
    escena = next(destino.glob("*.SCENE.MBIN"))

    data_mxml = nmsgeom.descompilar(data)
    geo_mxml = nmsgeom.descompilar(geo)
    escena_mxml = nmsgeom.descompilar(escena)

    # El stride NO se da por supuesto: se lee. Si esta malla no viene como
    # las del exportador de NMSDK, mas vale saberlo aqui que descubrirlo con
    # el buffer ya reescrito.
    d = nmsgeom.layout(geo_mxml)
    if 5 in d["elementos"] or 6 in d["elementos"]:
        sys.exit(f"  {geo.name} ya declara canales de piel "
                 f"{sorted(d['elementos'])}: esta malla ya esta cosida")
    if d["stride"] != STRIDE_VIEJO:
        sys.exit(f"  {geo.name} viene a stride {d['stride']} con los canales "
                 f"{sorted(d['elementos'])}, y este comando solo sabe subir de "
                 f"{STRIDE_VIEJO} a {STRIDE_NUEVO} -normal y tangente-. Para "
                 f"otra combinacion hay que recalcular los Offset de "
                 f"nmsgeom.CANALES_PIEL, hoy fijos en 8 y 12.")
    print(f"  stride     {d['stride']} con los canales "
          f"{sorted(d['elementos'])}")

    joints = nmsskin.leer_joints(escena_mxml)
    palet = nmsskin.paleta(pesos, joints)
    print(f"  paleta     {len(palet)} huesos de {len(joints)}: {palet}")

    s = nmsgeom.leer_streams(data_mxml)
    mapa = nmsskin.casar(nmsskin.posiciones(s), pesos)
    print(f"  casado     {len(mapa)} vertices exportados sobre "
          f"{len(pesos)} de Blender")

    idx, w = nmsskin.canales(pesos, palet, joints, mapa)
    ancho = nmsgeom.ampliar_stride(s.vertices, STRIDE_VIEJO, STRIDE_NUEVO)
    s.vertices = bytes(nmsskin.tejer(ancho, idx, w, STRIDE_NUEVO))
    print(f"  vertices   {len(s.vertices)} bytes a stride {STRIDE_NUEVO}")

    nmsgeom.escribir_streams(data_mxml, s)
    data = nmsgeom.compilar(data_mxml)

    nmsgeom.parchear_layout(geo_mxml)
    nmsgeom.parchear_metadata(geo_mxml, data, s)

    arbol = ET.parse(geo_mxml)
    raiz = arbol.getroot()
    _lista(raiz, "SkinMatrixLayout", palet)
    _lista(raiz, "MeshBaseSkinMat", [0])
    arbol.write(geo_mxml, encoding="utf-8", xml_declaration=True)
    nmsgeom.compilar(geo_mxml)

    arbol = ET.parse(escena_mxml)
    mallas = _nodos_malla(arbol.getroot())
    if len(mallas) != 1:
        sys.exit(f"{len(mallas)} nodos MESH: este tool asume uno")
    _poner_attr(mallas[0], "FIRSTSKINMAT", 0)
    _poner_attr(mallas[0], "LASTSKINMAT", len(palet))
    arbol.write(escena_mxml, encoding="utf-8", xml_declaration=True)
    nmsgeom.compilar(escena_mxml)

    print(f"  .SCENE     FIRSTSKINMAT 0 -> LASTSKINMAT {len(palet)}")
    print(f"\n  Ahora: python tools/Check-NMSGraft.py {destino}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    print()
    coser(Path(sys.argv[1]), Path(sys.argv[2]))
    print()
