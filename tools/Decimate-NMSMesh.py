"""Prepara un modelo de terceros para el conducto de NMSDK.

    blender.exe --background --python tools/Decimate-NMSMesh.py

Por cada modelo: importa el FBX, une las partes sueltas en una sola malla,
triangula, decima al presupuesto de triangulos, aplica la escala y guarda un
.blend en BLENDER/proyectos/. NO exporta: eso lo hace Export-NMSMesh.py una vez
decidido el destino.

Se unen las partes porque NMS espera un nodo de malla por objeto y NMSDK solo
usa el primer material slot de cada uno. Un modelo de 7 partes con 7 texturas
distintas necesita ademas que esas texturas se junten en un atlas: eso NO lo
hace este guion.

El orden importa: triangular ANTES de decimar deja el conteo final exacto, y
aplicar la escala AL FINAL evita que el decimador trabaje sobre coordenadas de
otra magnitud. El porque de cada paso esta en BLENDER/README.md §2b.
"""

import bmesh
import os
import bpy

RAIZ = os.path.expanduser(r"~\NMS_MOD_ZOMBIES\asset\Modelos Descomprimidos")
PROYECTOS = os.path.expanduser(r"~\NMS_MOD_ZOMBIES\BLENDER\proyectos")

PRESUPUESTO = 6000

MODELOS = {
    "necromorph": (
        RAIZ + r"\Necromorph_texturizado"
             + r"\tripo_convert_28ab8120-1277-41b2-8218-23d1979b09c5.fbx"),
    "zombie": (
        RAIZ + r"\Zombie_Texturizado"
             + r"\tripo_convert_9de8be52-92c5-4b12-92da-9d20d801f678.fbx"),
    "skrullcrawler": (
        RAIZ + r"\ScrullCrawler_max_hd"
             + r"\Meshy_AI_Skullcrawler_0813180805_texture_fbx"
             + r"\Meshy_AI_Skullcrawler_0813180805_texture.fbx"),
}


def triangular(ob):
    bm = bmesh.new()
    bm.from_mesh(ob.data)
    bmesh.ops.triangulate(bm, faces=bm.faces, ngon_method="EAR_CLIP")
    bm.to_mesh(ob.data)
    bm.free()
    ob.data.update()


for nombre, ruta in MODELOS.items():
    print("\n" + "=" * 70)
    print(nombre)
    bpy.ops.wm.read_homefile(use_empty=True)
    bpy.ops.import_scene.fbx(filepath=ruta)

    mallas = [o for o in bpy.data.objects if o.type == "MESH"]
    for o in list(bpy.data.objects):
        if o.type != "MESH":
            bpy.data.objects.remove(o, do_unlink=True)

    bpy.context.view_layer.objects.active = mallas[0]
    for o in mallas:
        o.select_set(True)
    if len(mallas) > 1:
        bpy.ops.object.join()
        print(f"  unidas {len(mallas)} partes en una malla")

    ob = bpy.context.view_layer.objects.active
    ob.name = nombre
    ob.data.name = nombre

    triangular(ob)
    antes = len(ob.data.polygons)

    if antes > PRESUPUESTO:
        mod = ob.modifiers.new("decimar", "DECIMATE")
        mod.decimate_type = "COLLAPSE"
        mod.ratio = PRESUPUESTO / antes
        bpy.ops.object.modifier_apply(modifier=mod.name)
        triangular(ob)

    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)

    despues = len(ob.data.polygons)
    lados = {len(p.vertices) for p in ob.data.polygons}
    co = [v.co for v in ob.data.vertices]
    alto = max(c.z for c in co) - min(c.z for c in co)
    print(f"  {antes} -> {despues} tris  ({despues / antes:.1%})"
          f"  lados={lados}  verts={len(ob.data.vertices)}")
    print(f"  alto en local: {alto:.4f}   uv={len(ob.data.uv_layers)}")

    destino = f"{PROYECTOS}\\{nombre}.blend"
    bpy.ops.wm.save_as_mainfile(filepath=destino)
    print(f"  guardado en {destino}")
