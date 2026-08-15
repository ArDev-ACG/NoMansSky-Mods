"""Pone o quita un MaterialFlag en un .MATERIAL, y lo recompila.

    python tools/Flag-NMSMaterial.py <archivo .MATERIAL.MBIN> --poner _F02_SKINNED
    python tools/Flag-NMSMaterial.py <archivo .MATERIAL.MBIN> --quitar _F02_SKINNED

Existe por el ultimo paso de la receta de piel: el buffer puede estar
perfecto, pero si el material no declara _F02_SKINNED el juego no aplica el
esqueleto y el bicho sigue yendo rigido. Y al reves, con el flag puesto y
los pesos mal el bicho se estira sin forma. Por eso el flag va SIEMPRE el
ultimo, despues de que tools/Check-NMSGraft.py de salida 0.

Los flags se guardan EN ORDEN NUMERICO, que es como los trae el vanilla
-_F01_DIFFUSEMAP, _F02_SKINNED, _F03_NORMALMAP, _F25_MASKS_MAP- y el
_index se reescribe entero. Poner uno que ya esta no hace nada.
"""

import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import nmsgeom


def _orden(flag):
    """_F02_SKINNED -> 2. Lo que no case va al final, por nombre."""
    m = re.match(r"_F(\d+)_", flag)
    return (int(m.group(1)), flag) if m else (999, flag)


def flags(material_mxml) -> list:
    raiz = ET.parse(Path(material_mxml)).getroot()
    cont = next(p for p in raiz.iter()
                if p.get("name") == "Flags" and p.get("value") is None)
    return [list(f)[0].get("value") for f in cont]


def escribir(material_mxml, valores) -> None:
    material_mxml = Path(material_mxml)
    arbol = ET.parse(material_mxml)
    cont = next(p for p in arbol.getroot().iter()
                if p.get("name") == "Flags" and p.get("value") is None)
    for hijo in list(cont):
        cont.remove(hijo)
    for i, v in enumerate(sorted(valores, key=_orden)):
        f = ET.SubElement(cont, "Property",
                          {"name": "Flags", "value": "TkMaterialFlags",
                           "_index": str(i)})
        ET.SubElement(f, "Property", {"name": "MaterialFlag", "value": v})
    arbol.write(material_mxml, encoding="utf-8", xml_declaration=True)


if __name__ == "__main__":
    if len(sys.argv) != 4 or sys.argv[2] not in ("--poner", "--quitar"):
        sys.exit(__doc__)

    mbin = Path(sys.argv[1])
    accion, flag = sys.argv[2], sys.argv[3]

    mxml = nmsgeom.descompilar(mbin)
    antes = flags(mxml)
    despues = ([f for f in antes if f != flag] if accion == "--quitar"
               else sorted(set(antes) | {flag}, key=_orden))

    if antes == despues:
        print(f"\n  {mbin.name} ya estaba como se pide: {antes}\n")
        sys.exit(0)

    escribir(mxml, despues)
    nmsgeom.compilar(mxml)
    print(f"\n  antes    {antes}")
    print(f"  despues  {flags(nmsgeom.descompilar(mbin))}\n")
