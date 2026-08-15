"""El par .GEOMETRY / .GEOMETRY.DATA de NMS, abierto y vuelto a cerrar.

Biblioteca, no comando: la usan tools/Skin-NMSGeometry.py y
tools/Check-NMSGraft.py. Vive aparte porque un archivo con guion en el
nombre no se puede importar, y lo que no se puede importar no se puede
testear.

Lo que hay que saber del .DATA, medido y no supuesto:

  - es cTkGeometryStreamData -> TkMeshData, con los buffers en base64 y
    SIN offsets: MBINCompiler los recalcula al recompilar.
  - MeshDataStream lleva los vertices y los indices PEGADOS, en ese
    orden. MeshPositionDataStream lleva las posiciones, aparte.
  - la ida y vuelta cambia 19 bytes de cabecera -el magic pasa de CCCC a
    DDDD, cambian los rellenos de las listas- y NADA de la carga util.
    El magic DD ya esta en partida: lo lleva el .GEOMETRY de la PRUEBA11.

Los offsets del .GEOMETRY siguen la convencion del vanilla, que no es la
que parece: VertexDataOffset y VertexPositionDataOffset son ABSOLUTOS en
el archivo, e IndexDataOffset es RELATIVO al principio de los vertices
-o sea, vale lo mismo que VertexDataSize-.
"""

import base64
import subprocess
import xml.etree.ElementTree as ET
from dataclasses import dataclass
from pathlib import Path

MBINCOMPILER = (Path(__file__).resolve().parent / "AMUMSS" / "MODBUILDER"
                / "MBINCompiler.exe")

# El contrato del vanilla, de freighterfiend.geometry.MXML: ElementCount 4,
# Stride 20. El indice de hueso es UNSIGNED_BYTE x4 y el peso HALF_FLOAT x4.
CANALES_PIEL = [
    {"Type": "5121", "SemanticID": "5", "Normalise": "0", "Size": "4",
     "Offset": "8", "Instancing": "PerVertex"},
    {"Type": "5131", "SemanticID": "6", "Normalise": "0", "Size": "4",
     "Offset": "12", "Instancing": "PerVertex"},
]


@dataclass
class Streams:
    id_string: str
    hash: int
    vertices: bytes
    indices: bytes
    posiciones: bytes


def _correr(ruta: Path, salida: Path) -> Path:
    if salida.exists():
        salida.unlink()
    r = subprocess.run([str(MBINCOMPILER), ruta.name], cwd=str(ruta.parent),
                       capture_output=True, text=True)
    if not salida.exists():
        raise RuntimeError(f"MBINCompiler no escribio {salida}:\n"
                           f"{r.stdout}\n{r.returncode}")
    return salida


def descompilar(mbin: Path) -> Path:
    """FREIGHTERFIEND.GEOMETRY.DATA.MBIN.PC -> ...DATA.MXML"""
    mbin = Path(mbin)
    nombre = mbin.name
    for sufijo in (".MBIN.PC", ".MBIN"):
        if nombre.upper().endswith(sufijo):
            nombre = nombre[: -len(sufijo)]
            break
    return _correr(mbin, mbin.with_name(nombre + ".MXML"))


def compilar(mxml: Path) -> Path:
    """...DATA.MXML -> ...DATA.MBIN.PC, o .SCENE.MXML -> .SCENE.MBIN"""
    mxml = Path(mxml)
    tallo = mxml.name[: -len(".MXML")]
    sufijo = ".MBIN.PC" if ".GEOMETRY" in tallo.upper() else ".MBIN"
    return _correr(mxml, mxml.with_name(tallo + sufijo))


def _malla(mxml: Path):
    arbol = ET.parse(mxml)
    nodo = arbol.getroot().find(".//Property[@value='TkMeshData']")
    if nodo is None:
        raise KeyError(f"{mxml} no lleva ningun TkMeshData")
    return arbol, nodo


def _campo(nodo, nombre):
    p = nodo.find(f"Property[@name='{nombre}']")
    if p is None:
        raise KeyError(nombre)
    return p


def leer_streams(data_mxml: Path) -> Streams:
    _, malla = _malla(Path(data_mxml))
    tam_v = int(_campo(malla, "VertexDataSize").get("value"))
    mezcla = base64.b64decode(_campo(malla, "MeshDataStream").get("value"))
    return Streams(
        id_string=_campo(malla, "IdString").get("value"),
        hash=int(_campo(malla, "Hash").get("value")),
        vertices=mezcla[:tam_v],
        indices=mezcla[tam_v:],
        posiciones=base64.b64decode(
            _campo(malla, "MeshPositionDataStream").get("value")),
    )


def escribir_streams(data_mxml: Path, s: Streams) -> None:
    data_mxml = Path(data_mxml)
    arbol, malla = _malla(data_mxml)
    _campo(malla, "VertexDataSize").set("value", str(len(s.vertices)))
    _campo(malla, "IndexDataSize").set("value", str(len(s.indices)))
    _campo(malla, "VertexPositionDataSize").set(
        "value", str(len(s.posiciones)))
    _campo(malla, "MeshDataStream").set(
        "value", base64.b64encode(s.vertices + s.indices).decode("ascii"))
    _campo(malla, "MeshPositionDataStream").set(
        "value", base64.b64encode(s.posiciones).decode("ascii"))
    arbol.write(data_mxml, encoding="utf-8", xml_declaration=True)


def cabecera(data_mbin: Path, s: Streams) -> int:
    """Los bytes de cabecera del .DATA: lo que hay antes de los streams."""
    return (Path(data_mbin).stat().st_size
            - len(s.vertices) - len(s.indices) - len(s.posiciones))
