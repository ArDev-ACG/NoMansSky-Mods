"""Funde las texturas de un modelo de varias partes en un solo atlas.

    blender.exe --background --python tools/Atlas-NMSMesh.py

Por que existe: NMSDK exporta UN material por objeto -usa el primer slot y
tira el resto-, y el necromorfo de Tripo viene en 22 piezas con SIETE colores
base distintos. Unirlas en una malla (tools/Decimate-NMSMesh.py) deja los
siete slots ahi, asi que al exportar seis septimas partes del bicho saldrian
con la textura de la septima. Hay que juntar las siete imagenes en una sola y
mover las UV de cada pieza al trozo que le toca.

El atlas es de 2048x2048 porque es lo que mide FIEND.BASE.DDS del juego, y
tools/Make-NMSTexture.py copia la cabecera del vanilla byte a byte: si el PNG
no mide lo mismo, el .DDS sale con dimensiones que no cuadran con su cabecera.

La rejilla es de 512, o sea 4x4 = 16 celdas. Las texturas de 1024 ocupan un
bloque de 2x2 y se quedan a su resolucion nativa; las de 512 y la de 256, una
celda. Con las siete piezas del necromorfo salen 13 de las 16 celdas usadas.
Repartir todo a 512 por igual habria sido mas corto, pero baja a la mitad las
dos texturas grandes, que son las que se miran de cerca.

El escalado solo se usa para la de 256 y es un np.repeat exacto: todas las
medidas son potencias de dos y el destino siempre es multiplo del origen, asi
que no hay interpolacion que pueda emborronar nada.

Y una cosa que no se ve y muerde: en Blender el origen de las UV y la fila 0
del buffer de pixeles son los DOS la esquina de abajo a la izquierda. Por eso
la fila de la rejilla se cuenta desde abajo en los dos sitios y el atlas no
sale del reves.

Deja dos cosas:

    BLENDER/proyectos/<modelo>_atlas.blend   la malla con un solo material
    work/textures/<MODELO>.BASE.PNG          el atlas, listo para el .DDS

No pisa el .blend de origen: el de partes sueltas sigue siendo la fuente.
Despues, el .DDS que come el juego:

    python tools/Make-NMSTexture.py work/textures/NECROMORPH.BASE.PNG \\
           work/textures/FIEND.BASE.DDS work/textures/NECROMORPH.BASE.DDS
"""

import numpy as np
import os

import bpy

RAIZ = os.path.expanduser(r"~\NMS_MOD_ZOMBIES")
BLEND = RAIZ + r"\BLENDER\proyectos\necromorph.blend"
OBJETO = "necromorph"
SALIDA_BLEND = RAIZ + r"\BLENDER\proyectos\necromorph_atlas.blend"
SALIDA_PNG = RAIZ + r"\work\textures\NECROMORPH.BASE.PNG"

ATLAS = 2048
CELDA = 512
LADO = ATLAS // CELDA


def imagen_del_material(mat):
    nodos = [n for n in mat.node_tree.nodes
             if n.type == "TEX_IMAGE" and n.image is not None]
    assert len(nodos) == 1, f"{mat.name}: {len(nodos)} imagenes, se espera 1"
    return nodos[0].image


def pixeles(img):
    ancho, alto = img.size
    buf = np.empty(ancho * alto * img.channels, dtype=np.float32)
    img.pixels.foreach_get(buf)
    return buf.reshape(alto, ancho, img.channels)


def a_rgba(a):
    if a.shape[2] == 4:
        return a
    relleno = np.ones(a.shape[:2] + (4 - a.shape[2],), dtype=np.float32)
    return np.concatenate([a, relleno], axis=2)


def escalar(a, destino):
    """Solo amplia por multiplo entero. Todo aqui es potencia de dos."""
    origen = a.shape[0]
    assert a.shape[0] == a.shape[1], f"textura no cuadrada: {a.shape}"
    if origen == destino:
        return a
    assert destino % origen == 0, f"{origen} -> {destino} no es multiplo"
    k = destino // origen
    return np.repeat(np.repeat(a, k, axis=0), k, axis=1)


def colocar(bloques):
    """Rejilla LADOxLADO. Los bloques grandes primero, que son los que no caben
    en cualquier hueco. Devuelve {indice de material: (fila, columna)}."""
    libre = np.ones((LADO, LADO), dtype=bool)
    sitio = {}
    for idx, lado in sorted(bloques.items(), key=lambda kv: -kv[1]):
        for fila in range(LADO - lado + 1):
            for col in range(LADO - lado + 1):
                if libre[fila:fila + lado, col:col + lado].all():
                    libre[fila:fila + lado, col:col + lado] = False
                    sitio[idx] = (fila, col)
                    break
            if idx in sitio:
                break
        else:
            raise RuntimeError(f"no cabe el bloque de {lado}x{lado} celdas")
    return sitio


bpy.ops.wm.open_mainfile(filepath=BLEND)
ob = bpy.data.objects[OBJETO]
malla = ob.data

fuentes = {}
for i, slot in enumerate(ob.material_slots):
    img = imagen_del_material(slot.material)
    fuentes[i] = img
    print(f"  slot {i}  {slot.material.name:32s} {img.size[0]}x{img.size[1]}")

bloques = {i: max(1, min(LADO, img.size[0] // CELDA))
           for i, img in fuentes.items()}
sitio = colocar(bloques)

lienzo = np.zeros((ATLAS, ATLAS, 4), dtype=np.float32)
lienzo[:, :, 3] = 1.0
rect = {}
for i, img in fuentes.items():
    fila, col = sitio[i]
    lado = bloques[i] * CELDA
    trozo = escalar(a_rgba(pixeles(img)), lado)
    y, x = fila * CELDA, col * CELDA
    lienzo[y:y + lado, x:x + lado] = trozo
    rect[i] = (x / ATLAS, y / ATLAS, lado / ATLAS, lado / ATLAS)
    print(f"  slot {i} -> celda ({fila},{col})  {lado}px  "
          f"uv u {rect[i][0]:.3f}+{rect[i][2]:.3f}  "
          f"v {rect[i][1]:.3f}+{rect[i][3]:.3f}")

uvs = malla.uv_layers.active.data
crudo = np.empty(len(uvs) * 2, dtype=np.float32)
uvs.foreach_get("uv", crudo)
crudo = crudo.reshape(-1, 2)
fuera = ((crudo < -1e-4) | (crudo > 1 + 1e-4)).any(axis=1).sum()
assert fuera == 0, (f"{fuera} UV fuera de [0,1]: la pieza se repetiria y "
                    f"pisaria la celda vecina. Rango "
                    f"{crudo.min(axis=0)} a {crudo.max(axis=0)}")

for poly in malla.polygons:
    u0, v0, du, dv = rect[poly.material_index]
    for li in poly.loop_indices:
        u, v = uvs[li].uv
        uvs[li].uv = (u0 + u * du, v0 + v * dv)

nuevo = np.empty(len(uvs) * 2, dtype=np.float32)
uvs.foreach_get("uv", nuevo)
nuevo = nuevo.reshape(-1, 2)
for poly in malla.polygons:
    u0, v0, du, dv = rect[poly.material_index]
    for li in poly.loop_indices:
        u, v = nuevo[li]
        assert u0 - 1e-4 <= u <= u0 + du + 1e-4, f"U {u} fuera de su celda"
        assert v0 - 1e-4 <= v <= v0 + dv + 1e-4, f"V {v} fuera de su celda"

atlas = bpy.data.images.new("atlas", ATLAS, ATLAS, alpha=True)
atlas.pixels.foreach_set(lienzo.ravel())
atlas.filepath_raw = SALIDA_PNG
atlas.file_format = "PNG"
atlas.save()

mat = bpy.data.materials.new(f"{OBJETO}_atlas")
mat.use_nodes = True
tex = mat.node_tree.nodes.new("ShaderNodeTexImage")
tex.image = bpy.data.images.load(SALIDA_PNG)
bsdf = next(n for n in mat.node_tree.nodes if "Base Color" in n.inputs)
mat.node_tree.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])

malla.materials.clear()
malla.materials.append(mat)
for poly in malla.polygons:
    poly.material_index = 0

bpy.ops.wm.save_as_mainfile(filepath=SALIDA_BLEND)
print(f"\n  {len(fuentes)} texturas -> {ATLAS}x{ATLAS}, "
      f"{sum(b * b for b in bloques.values())} de {LADO * LADO} celdas")
print(f"  {SALIDA_PNG}")
print(f"  {SALIDA_BLEND}")
