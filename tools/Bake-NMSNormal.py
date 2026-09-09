"""Hornea el normal de la malla ALTA sobre las UV de la nuestra.

    blender.exe --background --python tools/Bake-NMSNormal.py -- \\
        <blend> <objeto> <fbx alto> <salida.png> [--tam 2048] [--extrusion X]

QUE LO DISTINGUE DE Make-NMSNormal.py, QUE ES LA RAZON DE QUE EXISTA. Aquel
saca el relieve de la LUMINANCIA del color: donde el pintor puso oscuro, pone
hueco. Es un apaño para cuando el asset no trae normal, y tiene dos precios
medidos: cada linea pintada sale como un bulto -el efecto "baba" de la
PRUEBA12 del SkrullCrawler- y si el atlas viene plano no hay relieve que
sacar. El warrior bug daba desviacion 2,3 y 3,6 contra los 17,2 y 18,3 del
vanilla, o sea un mapa practicamente en blanco.

Esto otro es lo de verdad: el relieve sale de la GEOMETRIA que se tiro al
decimar. El bug entra con 133 108 triangulos y se entrega con 36 000, asi que
hay tres cuartas partes de la forma esperando en el .fbx. Hornearlas las
devuelve al pixel.

COMO SE COMPRUEBA QUE SALIO BIEN, y va dentro: la desviacion de los canales R
y G contra el vanilla. El FIEND mide 17,2 y 18,3, el SkrullCrawler 17,8. Por
debajo de ~8 el mapa esta liso y no ha horneado nada -casi siempre porque las
dos mallas no estan alineadas o la extrusion se queda corta-, y el guion
aborta en vez de dejar un PNG que parece bueno.

LAS DOS MALLAS TIENEN QUE ESTAR EN EL MISMO SITIO. El .blend de atlas sale de
Decimate-NMSMesh.py, que importa ese mismo .fbx y no lo mueve, asi que casan
por construccion; se comprueba igual comparando las cajas, porque si no casan
el horneado sale liso y no dice por que.
"""

import sys
from pathlib import Path

import bpy
import numpy as np


def opcion(nombre, defecto):
    if f"--{nombre}" in sys.argv:
        return float(sys.argv[sys.argv.index(f"--{nombre}") + 1])
    return defecto


def caja(obs):
    ptos = np.array([tuple(o.matrix_world @ v.co)
                     for o in obs for v in o.data.vertices])
    return ptos.min(axis=0), ptos.max(axis=0)


def main():
    args = sys.argv[sys.argv.index("--") + 1:]
    blend, objeto, fbx, salida = args[0], args[1], args[2], Path(args[3])
    tam = int(opcion("tam", 2048))

    bpy.ops.wm.open_mainfile(filepath=blend)
    baja = bpy.data.objects[objeto]
    antes = set(bpy.data.objects)

    bpy.ops.import_scene.fbx(filepath=fbx)
    altas = [o for o in set(bpy.data.objects) - antes if o.type == "MESH"]
    if not altas:
        raise SystemExit(f"{fbx}: no trajo ninguna malla")

    tris_alta = sum(len(o.data.polygons) for o in altas)
    print(f"baja  {objeto}: {len(baja.data.polygons)} caras")
    print(f"alta  {len(altas)} objetos, {tris_alta} caras")

    lo_b, hi_b = caja([baja])
    lo_a, hi_a = caja(altas)
    tam_b, tam_a = hi_b - lo_b, hi_a - lo_a
    print(f"caja baja {tam_b.round(3)}  alta {tam_a.round(3)}")

    # LO QUE TIENE QUE CASAR ES EL TAMANO, NO LA POSICION. El .blend de atlas
    # sale de Decimate-NMSMesh.py, que ademas de decimar ASIENTA la malla; el
    # .fbx recien importado sigue en el origen que traia. Medido en el warrior
    # bug: las dos cajas miden lo mismo hasta el milimetro y estan separadas
    # 4,556. Se mueve la ALTA a la baja, que es la que manda las UV.
    tope = 0.05 * float(np.linalg.norm(tam_b))
    assert float(np.abs(tam_a - tam_b).max()) < tope, (
        f"las dos mallas no miden lo mismo: {tam_a.round(3)} contra "
        f"{tam_b.round(3)}. El .blend y el .fbx no son del mismo paso")

    salto = (lo_b + hi_b) / 2 - (lo_a + hi_a) / 2
    if float(np.abs(salto).max()) > 1e-4:
        print(f"alineando la alta: {salto.round(4)}")
        for o in altas:
            o.location = [o.location[i] + salto[i] for i in range(3)]
        bpy.context.view_layer.update()
        lo_a, hi_a = caja(altas)
        resto = float(np.abs(np.concatenate([lo_a - lo_b, hi_a - hi_b])).max())
        assert resto < tope, f"tras alinear siguen separadas {resto:.3f}"

    # La extrusion de la jaula: cuanto se aleja la baja de la alta. El
    # decimado no mueve un vertice mas que un poco, asi que un 2% de la
    # diagonal sobra y no pilla la pata de al lado.
    extrusion = opcion("extrusion", 0.02 * float(np.linalg.norm(tam_b)))
    print(f"extrusion {extrusion:.4f}")

    img = bpy.data.images.new("BAKE", width=tam, height=tam, float_buffer=True,
                              is_data=True)
    # NON-COLOR O EL PNG SALE CON LA MEDIA EN 187 EN VEZ DE 128, y el mapa
    # entero se lee torcido. Un normal NO es color: sus canales son las dos
    # componentes de un vector. Si la imagen se queda en sRGB, `img.save()`
    # aplica la curva al guardar -0,502 lineal pasa a 0,735- y el plano deja
    # de estar en el centro. Medido: 187,6 contra los 128,1 del buffer.
    img.colorspace_settings.name = "Non-Color"
    mat = baja.data.materials[0]
    mat.use_nodes = True
    nodo = mat.node_tree.nodes.new("ShaderNodeTexImage")
    nodo.image = img
    mat.node_tree.nodes.active = nodo

    bpy.context.scene.render.engine = "CYCLES"
    bpy.context.scene.cycles.samples = 1
    bpy.context.scene.render.bake.use_selected_to_active = True
    bpy.context.scene.render.bake.cage_extrusion = extrusion
    bpy.context.scene.render.bake.margin = 16
    bpy.context.scene.render.bake.use_clear = True

    bpy.ops.object.select_all(action="DESELECT")
    for o in altas:
        o.select_set(True)
    baja.select_set(True)
    bpy.context.view_layer.objects.active = baja

    print("horneando...")
    bpy.ops.object.bake(type="NORMAL")

    px = np.array(img.pixels[:]).reshape(tam, tam, 4)[:, :, :3]
    b = np.clip(px * 255.0, 0, 255)
    r_d, g_d = float(b[:, :, 0].std()), float(b[:, :, 1].std())
    print(f"desviacion R {r_d:.1f}  G {g_d:.1f}   (vanilla FIEND 17,2 / 18,3)")
    print(f"medias     R {b[:, :, 0].mean():.1f}  G {b[:, :, 1].mean():.1f}  "
          f"B {b[:, :, 2].mean():.1f}   (plano = 128 / 128 / 255)")

    img.filepath_raw = str(salida)
    img.file_format = "PNG"
    img.save()
    print(f"escrito {salida}")

    assert max(r_d, g_d) > 8.0, (
        f"el mapa sale liso -desviacion {r_d:.1f} y {g_d:.1f}-: no ha "
        f"horneado nada. Mira la alineacion de las dos mallas o sube "
        f"--extrusion")


main()
