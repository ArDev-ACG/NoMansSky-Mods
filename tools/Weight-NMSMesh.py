"""Pesa nuestra malla contra el esqueleto vanilla, sin tocar el interfaz.

    blender.exe --background --python tools/Weight-NMSMesh.py

Deja dos cosas, y las dos se versionan: el .blend con los grupos puestos
y work/models/scuttlermesh/pesos.json, que es lo que consume el splice.

Existe porque los pesos de la primera sesion NO se guardaron: scuttler.blend
tenia polySurface6 con 4820 vertices y cero grupos de vertices. Los numeros
estaban anotados y los datos no estaban en ninguna parte.

Tres cosas que costaron la sesion anterior:

  1. NMSDK IMPORTA pesos -crea un grupo por hueso y reparte blendWeight-
     pero NO los EXPORTA: escribe JointBindings, MeshBaseSkinMat y
     SkinMatrixLayout vacios. El muro es solo de salida.
  2. El importador exige que la carpeta repita la ruta interna de la
     escena (import_scene.py:220, base_path). Por eso el vanilla esta
     extraido en work/models/vanilla_freighterfiend/models/planets/...
  3. Las dos mallas no estan en el mismo espacio: el vanilla viene Z
     arriba y la nuestra Y arriba. Sin girar, RFourthLeg* y LFourthLeg*
     se quedan con 0 vertices y RFirstLeg3JNT se traga 1630.

Y el giro de 180 en Z no se decide contando grupos con vertices -eso da
GIRO_Z 0, que pone nuestro craneo mirando hacia atras-. Se decide por
donde cae la cabeza: la del vanilla esta en +Y.
"""

import json
import os
import math
from pathlib import Path

import bpy

RAIZ = Path(os.path.expanduser(r"~\NMS_MOD_ZOMBIES"))
BLEND = RAIZ / "BLENDER" / "proyectos" / "scuttler.blend"
VANILLA = (RAIZ / "work" / "models" / "vanilla_freighterfiend" / "models" /
           "planets" / "creatures" / "spiderrig" / "freighterfiend.scene.mbin")
SALIDA = RAIZ / "work" / "models" / "scuttlermesh" / "pesos.json"

NUESTRA = "polySurface6"
GIRO_Z = 180
VACIOS_ESPERADOS = {"NewBack1JNT", "NewBack2JNT", "NewBack3JNT",
                    "LPincer1JNT", "RPincer1JNT"}


def caja(ob):
    co = [ob.matrix_world @ v.co for v in ob.data.vertices]
    lo = [min(c[i] for c in co) for i in range(3)]
    hi = [max(c[i] for c in co) for i in range(3)]
    return lo, hi


bpy.ops.wm.open_mainfile(filepath=str(BLEND))
nuestra = bpy.data.objects[NUESTRA]

bpy.ops.nmsdk.import_scene(path=str(VANILLA), clear_scene=False,
                           import_bones=True, import_collisions=False,
                           import_recursively=False)

vanilla = next(o for o in bpy.data.objects
               if o.type == "MESH" and o.vertex_groups and o is not nuestra)
armature = next(o for o in bpy.data.objects if o.type == "ARMATURE")
print(f"vanilla {vanilla.name}: {len(vanilla.data.vertices)} vertices, "
      f"{len(vanilla.vertex_groups)} grupos, {len(armature.data.bones)} huesos")

# 1. Alinear: el vanilla viene Z arriba, el nuestro Y arriba.
bpy.ops.object.select_all(action="DESELECT")
vanilla.select_set(True)
bpy.context.view_layer.objects.active = vanilla
vanilla.rotation_euler[0] += math.radians(90)
vanilla.rotation_euler[2] += math.radians(GIRO_Z)
bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)

# 2. Encajar la caja envolvente del vanilla en la nuestra.
lo_v, hi_v = caja(vanilla)
lo_n, hi_n = caja(nuestra)
escala = min((hi_n[i] - lo_n[i]) / (hi_v[i] - lo_v[i]) for i in range(3))
vanilla.scale = (escala, escala, escala)
bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
lo_v, hi_v = caja(vanilla)
vanilla.location = [(lo_n[i] + hi_n[i]) / 2 - (lo_v[i] + hi_v[i]) / 2
                    for i in range(3)]
bpy.ops.object.transform_apply(location=True, rotation=False, scale=False)

# 3. Transferir los grupos, por superficie mas cercana.
#
# El operador va "del activo a los seleccionados", asi que el ACTIVO es el
# vanilla: es de donde salen los pesos. NO se usa use_reverse_transfer: con
# ese flag puesto, Blender INTERCAMBIA los valores validos de los dos enums
# -layers_select_src pasa a aceptar ('ACTIVE','NAME','INDEX') y "ALL" deja
# de existir- y el script se cae con un TypeError.
bpy.ops.object.select_all(action="DESELECT")
nuestra.select_set(True)
vanilla.select_set(True)
bpy.context.view_layer.objects.active = vanilla
bpy.ops.object.data_transfer(
    data_type="VGROUP_WEIGHTS", vert_mapping="POLYINTERP_NEAREST",
    layers_select_src="ALL", layers_select_dst="NAME")

# 4. Limitar a 4 influencias y normalizar. Solo sobre NUESTRA malla: el
# activo lo dejo el paso 3 en el vanilla, y estos dos operadores van sobre
# lo seleccionado.
bpy.ops.object.select_all(action="DESELECT")
nuestra.select_set(True)
bpy.context.view_layer.objects.active = nuestra
bpy.ops.object.vertex_group_limit_total(group_select_mode="ALL", limit=4)
bpy.ops.object.vertex_group_normalize_all(group_select_mode="ALL",
                                          lock_active=False)

grupos = {g.index: g.name for g in nuestra.vertex_groups}
salida = []
for v in nuestra.data.vertices:
    pares = sorted(((grupos[g.group], round(g.weight, 6))
                    for g in v.groups if g.weight > 0),
                   key=lambda p: -p[1])
    salida.append([round(v.co.x, 6), round(v.co.y, 6), round(v.co.z, 6),
                   pares])

# --- lo que puede fallar, y falla aqui y no en el juego ---
sin_peso = [i for i, e in enumerate(salida) if not e[3]]
assert not sin_peso, f"{len(sin_peso)} vertices sin peso: {sin_peso[:10]}"

asignaciones = sum(len(e[3]) for e in salida)
maximo = max(len(e[3]) for e in salida)
usados = {g for e in salida for g, _ in e[3]}
vacios = {g.name for g in nuestra.vertex_groups} - usados

print(f"vertices con peso: {len(salida)} de {len(nuestra.data.vertices)}")
print(f"asignaciones: {asignaciones}  "
      f"({asignaciones / len(salida):.2f} por vertice)")
print(f"maximo de huesos por vertice: {maximo}")
print(f"grupos creados: {len(nuestra.vertex_groups)}, con peso: {len(usados)}")
print(f"grupos a cero: {sorted(vacios)}")

assert len(salida) == 4820, len(salida)
assert maximo <= 2, f"algun vertice cuelga de {maximo} huesos"
assert vacios == VACIOS_ESPERADOS, f"grupos a cero inesperados: {vacios}"
for i, e in enumerate(salida):
    total = sum(p for _, p in e[3])
    assert abs(total - 1.0) < 1e-4, f"vertice {i} suma {total}"

cabezas = [e[1] for e in salida
           if any(g == "NewHeadJNT" and p > 0.5 for g, p in e[3])]
assert cabezas, "ningun vertice cuelga de NewHeadJNT"
centro = sum(cabezas) / len(cabezas)
print(f"centroide de la cabeza en Y: {centro:+.3f}")
assert centro > 0, (f"la cabeza cae en {centro:+.3f}: con GIRO_Z {GIRO_Z} el "
                    f"craneo mira hacia atras")

SALIDA.write_text(json.dumps(salida), encoding="utf-8")
print(f"escrito {SALIDA}")

bpy.data.objects.remove(vanilla, do_unlink=True)
bpy.data.objects.remove(armature, do_unlink=True)
bpy.ops.wm.save_as_mainfile(filepath=str(BLEND))
print(f"guardado {BLEND}")
