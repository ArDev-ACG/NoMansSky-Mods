"""Cambia a que .DDS apunta un sampler de un .MATERIAL, y lo recompila.

    python tools/Set-NMSSampler.py <archivo .MATERIAL.MBIN> gNormalMap RUTA/X.DDS
    python tools/Set-NMSSampler.py <archivo .MATERIAL.MBIN> --ver

Existe porque poner la textura propia en la carpeta no basta: mientras el
sampler siga apuntando a la del bicho vanilla, el juego carga la vanilla y
no se entera de la nuestra. Paso a paso es lo mismo que se hizo a mano con
el gDiffuseMap y el gMasksMap, y hay que repetirlo en cada modelo nuevo.

Las rutas van con BARRA NORMAL y en mayusculas, como las trae el vanilla:

    TEXTURES/PLANETS/CREATURES/SPIDERRIG/SKRULLCRAWLER.BASE.NORMAL.DDS

No comprueba que el .DDS exista, porque el .MATERIAL se edita aqui y el
.DDS lo reparte el .lua a otra carpeta distinta: no hay forma fiable de
resolver una contra la otra desde este comando.
"""

import sys
import xml.etree.ElementTree as ET
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import nmsgeom


def samplers(material_mxml) -> dict:
    """Nombre del sampler -> ruta del .DDS."""
    raiz = ET.parse(Path(material_mxml)).getroot()
    salida = {}
    for s in raiz.iter():
        if s.get("value") != "TkMaterialSampler":
            continue
        campos = {p.get("name"): p for p in s}
        if "Name" in campos and "Map" in campos:
            salida[campos["Name"].get("value")] = campos["Map"].get("value")
    return salida


def poner(material_mxml, nombre, ruta) -> None:
    material_mxml = Path(material_mxml)
    arbol = ET.parse(material_mxml)
    for s in arbol.getroot().iter():
        if s.get("value") != "TkMaterialSampler":
            continue
        campos = {p.get("name"): p for p in s}
        if campos.get("Name") is not None and \
                campos["Name"].get("value") == nombre:
            campos["Map"].set("value", ruta)
            arbol.write(material_mxml, encoding="utf-8", xml_declaration=True)
            return
    raise KeyError(f"{material_mxml.name} no tiene ningun sampler {nombre}")


if __name__ == "__main__":
    if len(sys.argv) < 3:
        sys.exit(__doc__)

    mbin = Path(sys.argv[1])
    mxml = nmsgeom.descompilar(mbin)

    if sys.argv[2] == "--ver":
        print()
        for k, v in samplers(mxml).items():
            print(f"  {k:16} {v}")
        print()
        sys.exit(0)

    if len(sys.argv) != 4:
        sys.exit(__doc__)
    nombre, ruta = sys.argv[2], sys.argv[3]

    antes = samplers(mxml).get(nombre)
    if antes == ruta:
        print(f"\n  {nombre} ya apuntaba a {ruta}\n")
        sys.exit(0)

    poner(mxml, nombre, ruta)
    nmsgeom.compilar(mxml)
    print(f"\n  antes    {nombre} -> {antes}")
    print(f"  despues  {nombre} -> "
          f"{samplers(nmsgeom.descompilar(mbin))[nombre]}\n")
