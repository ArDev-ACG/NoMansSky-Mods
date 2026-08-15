"""Exporta una malla a formato NMS con NMSDK, sin tocar el interfaz de Blender.

    blender.exe --background --python tools/Export-NMSMesh.py

Existe porque el export a mano falla de tres formas que NMSDK no reporta:

  1. Los paneles del addon llevan `bl_context = 'objectmode'`. Si te quedas en
     modo edicion tras triangular, la pestaña NMSDK desaparece del panel `N`.
  2. `nmsdk.create_root_scene` no lo dibuja ningun panel: solo sale por `F3`.
     Sin esa raiz el export escribe `Children` vacio y `VertexCount 0` y no se
     queja.
  3. El explorador de archivos pide un *nombre*, no una carpeta: el operador
     hace `op.split(filepath)` y la segunda mitad es el nombre de la escena.

Y de dos que si reporta, pero tarde:

  4. Con quads en la malla, el exportador saca los indices del `face_map` de
     `bmesh.ops.triangulate` (`addon_script.py:633`) y salen incompletos. Hay
     que triangular ANTES. Se comprueba en el `.GEOMETRY`: `IndexDataSize`
     tiene que ser `IndexCount * 2`.
  5. Sin nodos de textura etiquetados, `parse_material` lanza una excepcion.
     `NMSMesh_props.material_path` se salta el parseo y apunta a un material
     que ya existe en el juego.

Y de una que no reporta nadie, ni Blender ni el juego:

  6. El exportador escribe `data.vertices[vi].co`, que son coordenadas LOCALES:
     ignora la escala del objeto. El FBX del marker importa con `scale = 0.01`,
     asi que en Blender se ve de 1,63 m y al juego iba de 163. Hay que APLICAR
     la escala. Solo la escala: la rotacion se deja, porque deja el eje alto en
     Y, que es el "arriba" de NMS.

El `IdString` del `.GEOMETRY` sale del nombre del objeto en Blender, y el juego
ata el nodo de malla a su stream por el hash de ese nombre. Si entregas un
`.SCENE` vanilla, el objeto tiene que llamarse como su nodo de malla.
"""

import bmesh
import os
import bpy

FBX = (os.path.expanduser(r"~\NMS_MOD_ZOMBIES\asset\Modelos Descomprimidos")
       r"\marker-1\source\marker_1.fbx")
BLEND = os.path.expanduser(r"~\NMS_MOD_ZOMBIES\BLENDER\proyectos\marker.blend")
SALIDA = os.path.expanduser(r"~\NMS_MOD_ZOMBIES\BLENDER\FIENDEGG")

NOMBRE_NODO = "FiendEgg"
MATERIAL = (r"MODELS\PLANETS\BIOMES\COMMON\RARERESOURCE\GROUND\FIENDEGG"
            r"\EGGSHELL_MAT.MATERIAL.MBIN")

bpy.ops.wm.read_homefile(use_empty=True)
bpy.ops.import_scene.fbx(filepath=FBX)

ob = next(o for o in bpy.data.objects if o.type == "MESH")
ob.name = NOMBRE_NODO
ob.data.name = NOMBRE_NODO

bpy.context.view_layer.objects.active = ob
ob.select_set(True)
bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
assert tuple(round(v, 6) for v in ob.scale) == (1.0, 1.0, 1.0), ob.scale

bm = bmesh.new()
bm.from_mesh(ob.data)
bmesh.ops.triangulate(bm, faces=bm.faces, ngon_method="EAR_CLIP")
bm.to_mesh(ob.data)
bm.free()
ob.data.update()

lados = {len(p.vertices) for p in ob.data.polygons}
assert lados == {3}, f"quedan caras sin triangular: {lados}"
print(f"{len(ob.data.polygons)} caras, todas de 3 lados")

co = [v.co for v in ob.data.vertices]
alto = max(c.y for c in co) - min(c.y for c in co)
print(f"alto de la malla en coordenadas locales: {alto:.4f}"
      f"  (el huevo vanilla mide 0.7615)")
assert alto < 10, f"la malla mide {alto:.1f} en local: falta aplicar la escala"

bpy.ops.nmsdk.create_root_scene()
raiz = bpy.data.objects["NMS_Scene"]
raiz.NMSReference_props.scene_name = "FIENDEGG"

ob.parent = raiz
ob.matrix_parent_inverse = raiz.matrix_world.inverted()
ob.NMSNode_props.node_types = "Mesh"
ob.NMSMesh_props.material_path = MATERIAL

bpy.context.view_layer.objects.active = ob
ob.select_set(True)

bpy.ops.wm.save_as_mainfile(filepath=BLEND)

print("EXPORT:", bpy.ops.export_mesh.nms(
    filepath=SALIDA,
    export_directory="CUSTOMMODELS",
    group_name="MODELGROUP",
))
