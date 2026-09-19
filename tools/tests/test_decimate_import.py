"""El conducto entra por FBX desde agosto y el xenodog llega en .glb.

Existe porque `bpy.ops.import_scene.fbx` estaba escrito a pelo en el bucle:
un modelo .glb se importaba como FBX y Blender abria una escena vacia sin
decir nada, que es el peor fallo posible -no revienta, decima cero
triangulos y guarda un .blend valido y vacio-.
"""

import importlib.util
import sys
from pathlib import Path

import pytest

RAIZ = Path(__file__).resolve().parents[2]


def _cargar():
    """Importa el modulo. El bucle NO corre: vive tras `if __name__`.

    Sin ese guardia habria que envolver esto en un try/except que se tragase
    el error de Blender, y entonces el test no distinguiria "la funcion no
    existe" de "el modulo no importa": los dos darian AttributeError.
    """
    ruta = RAIZ / "tools" / "Decimate-NMSMesh.py"
    sys.modules.setdefault("bpy", type(sys)("bpy"))
    sys.modules.setdefault("bmesh", type(sys)("bmesh"))
    spec = importlib.util.spec_from_file_location("decimate_nmsmesh", ruta)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


@pytest.mark.parametrize(
    "ruta,esperado",
    [
        (r"C:\x\crywolf\source\Cry Wolf SETS.fbx", "fbx"),
        (r"C:\x\facehugger-egg\source\xenoEgg.FBX", "fbx"),
        (r"C:\x\alien-xenodog\source\model.glb", "gltf"),
        (r"C:\x\alien-xenodog\source\model.gltf", "gltf"),
    ],
)
def test_importador_por_extension(ruta, esperado):
    mod = _cargar()
    assert mod.importador_para(ruta) == esperado


def test_extension_desconocida_revienta_y_dice_cuales_valen():
    mod = _cargar()
    with pytest.raises(ValueError) as e:
        mod.importador_para(r"C:\x\modelo.obj")
    assert ".glb" in str(e.value) and ".fbx" in str(e.value)
