"""Soldar, decimar y hornear: el xenodog sin islas sueltas (2026-09-21).

    blender -b --python tools/Weld-Bake-NMSMesh.py -- <baja.npz> <color.png> <rugosidad.png> 36000 2048

El .glb de Sketchfab viene partido en 2677 islas de UV (glTF duplica
vertices en cada costura); soldado es UNA pieza. Decimar sin soldar encoge
cada isla por su lado: 2270 trozos con rendijas de 3-19 mm, que en partida
eran las esquirlas y los huecos al rugir. Soldar mezcla las UV del atlas
(camuflaje), asi que se hacen UV nuevas y se hornea color y rugosidad de la
malla alta. Despues: tools/Inject-NMSMesh.py y Reorient-NMSGeometry.py.

El presupuesto es 36000, el del FIEND vanilla, y lo topa el formato y no el
gusto: Indices16Bit=1 son 65535 vertices y las UV nuevas parten 1,40 por
triangulo -50414 vertices con 36000 triangulos-. Con 30000 salian 43576.
"""
import bpy, bmesh, sys, numpy as np
import os
a = sys.argv[sys.argv.index("--") + 1:]
out, png, png_r, META, TAM = a[0], a[1], a[2], int(a[3]), int(a[4])
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=os.path.expanduser(r"~\MODS\NMS_MOD_ZOMBIES\ASSETS\Modelos Descomprimidos\alien-xenodog\source\model.glb"))
alta = [o for o in bpy.context.scene.objects if o.type == "MESH"][0]
baja = alta.copy(); baja.data = alta.data.copy(); baja.name = "baja"
bpy.context.scene.collection.objects.link(baja)
me = baja.data
bm = bmesh.new(); bm.from_mesh(me)
bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-5)
bmesh.ops.triangulate(bm, faces=bm.faces)
bm.to_mesh(me); bm.free()
mod = baja.modifiers.new("d", "DECIMATE"); mod.decimate_type = "COLLAPSE"; mod.ratio = META / len(me.polygons)
mod.use_collapse_triangulate = True
bpy.context.view_layer.objects.active = baja
bpy.ops.object.modifier_apply(modifier=mod.name)
bm = bmesh.new(); bm.from_mesh(me)
bmesh.ops.dissolve_degenerate(bm, dist=1e-6, edges=bm.edges)
bmesh.ops.triangulate(bm, faces=bm.faces)
bmesh.ops.delete(bm, geom=[v for v in bm.verts if not v.link_faces], context="VERTS")
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
bm.to_mesh(me); bm.free(); me.update()
while me.uv_layers:
    me.uv_layers.remove(me.uv_layers[0])
me.uv_layers.new(name="UVMap")
for o in bpy.context.scene.objects:
    o.select_set(False)
baja.select_set(True); bpy.context.view_layer.objects.active = baja
bpy.ops.object.mode_set(mode="EDIT"); bpy.ops.mesh.select_all(action="SELECT")
bpy.ops.uv.smart_project(angle_limit=1.15, island_margin=0.004)
bpy.ops.uv.pack_islands(margin=0.004)
bpy.ops.object.mode_set(mode="OBJECT")
for p in me.polygons:
    p.use_smooth = True
print("BAJA tris", len(me.polygons), "verts", len(me.vertices))

sc = bpy.context.scene
sc.render.engine = "CYCLES"; sc.cycles.samples = 4; sc.cycles.device = "CPU"
mat = bpy.data.materials.new("bake"); mat.use_nodes = True
baja.data.materials.clear(); baja.data.materials.append(mat)
nt = mat.node_tree
tex = nt.nodes.new("ShaderNodeTexImage")


def hornear(tipo, ruta, cs):
    img = bpy.data.images.new(tipo, TAM, TAM, alpha=False)
    img.colorspace_settings.name = cs
    tex.image = img; nt.nodes.active = tex
    for o in sc.objects:
        o.select_set(False)
    alta.select_set(True); baja.select_set(True); bpy.context.view_layer.objects.active = baja
    kw = dict(type=tipo, use_selected_to_active=True, cage_extrusion=0.01, max_ray_distance=0.03, margin=16)
    if tipo == "DIFFUSE":
        kw["pass_filter"] = {"COLOR"}
    bpy.ops.object.bake(**kw)
    img.filepath_raw = ruta; img.file_format = "PNG"; img.save()
    print("HORNEADO", tipo, ruta)


hornear("DIFFUSE", png, "sRGB")
hornear("ROUGHNESS", png_r, "Non-Color")

v = np.zeros(len(me.vertices) * 3); me.vertices.foreach_get("co", v); v = v.reshape(-1, 3)
me.calc_loop_triangles()
lt = np.zeros(len(me.loop_triangles) * 3, dtype=np.int64); me.loop_triangles.foreach_get("loops", lt)
lv = np.zeros(len(me.loops), dtype=np.int64); me.loops.foreach_get("vertex_index", lv)
uv = np.zeros(len(me.loops) * 2); me.uv_layers[0].data.foreach_get("uv", uv)
vn = np.zeros(len(me.vertices) * 3); me.vertices.foreach_get("normal", vn)
np.savez(out, v=v, lt=lt.reshape(-1, 3), lv=lv, uv=uv.reshape(-1, 2), vn=vn.reshape(-1, 3))
