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
import sys

import bpy

RAIZ = os.path.expanduser(r"~\NMS_MOD_ZOMBIES")
MODS3D = RAIZ + r"\asset\Modelos Descomprimidos"

# Lo que cambia de un modelo a otro.
#
#   texturas   SOLO si el FBX no trae las imagenes metidas en los materiales.
#              Es el caso del warrior bug: sus doce slots vienen VACIOS -el
#              .fbx no declara ni una ruta, comprobado buscando cadenas .png
#              en el binario- y los PNG llegan sueltos al lado del .fbx, asi
#              que la unica forma de casarlos es por nombre. Los nombres son
#              rusos y describen la parte -telo cuerpo, noga pata, rot boca,
#              usi antena, glaz ojo-, y se comprobaron contra el volcado por
#              material: `telo` ocupa el torso -X +-0,40, Z 3,52..4,66-, los
#              `noga` las cuatro patas -X +-1,71- y los `usi` lo mas alto
#              -Z hasta 5,38-. None = ese material va a color plano; el
#              `glaz` del bug es un ojo negro de 1024 caras.
#   bloques    Cuantas celdas de lado se lleva cada slot. Sin esto se calcula
#              del tamano del PNG, que es lo que hace falta en el necromorfo
#              -mezcla 1024 con 512 y 256- y lo que NO puede valer aqui: los
#              PNG de estos dos son de 2048 y 4096, o sea mas grandes que el
#              atlas entero, y el calculo pediria el atlas completo para el
#              primer slot. Con doce slots el reparto lo decide el hueco.
MODELOS = {
    "necromorph": dict(
        blend=RAIZ + r"\BLENDER\proyectos\necromorph.blend",
        objeto="necromorph",
        salida_blend=RAIZ + r"\BLENDER\proyectos\necromorph_atlas.blend",
        salida_png=RAIZ + r"\work\textures\NECROMORPH.BASE.PNG",
        atlas=2048,
        celda=512,
    ),
    "warriorbug": dict(
        blend=RAIZ + r"\BLENDER\proyectos\warriorbug.blend",
        objeto="warriorbug",
        salida_blend=RAIZ + r"\BLENDER\proyectos\warriorbug_atlas.blend",
        salida_png=RAIZ + r"\work\textures\WARRIORBUG.BASE.PNG",
        atlas=2048,
        celda=512,
        texturas={
            "telo":         "telo.png",
            "telo niz":     "telo niz.png",
            "telo niz.001": "telo niz.png",
            "noga1":        "noga 1.png",
            "noga1.001":    "noga 1.png",
            "noga konec":   "noga2.png",
            "rot":          "rot.png",
            "rot niz":      "rot niz.png",
            "usi":          "usi.png",
            "usi.001":      "usi001.png",
            "usi.002":      "usi002.png",
            "glaz":         None,
        },
        texturas_en=MODS3D + r"\warriorbug\source",
        # Doce slots en dieciseis celdas: uno cada uno y sobran cuatro. No se
        # le da bloque doble a nadie porque el techo real no es el atlas sino
        # el .DDS: doce trozos en 2048 son 512 por trozo, y eso ya es el
        # doble de lo que tenia el zombie, cuyo .DDS iba a 1024.
        bloques={},
    ),
    "crywolf": dict(
        blend=RAIZ + r"\BLENDER\proyectos\crywolf.blend",
        objeto="crywolf",
        salida_blend=RAIZ + r"\BLENDER\proyectos\crywolf_atlas.blend",
        salida_png=RAIZ + r"\work\textures\CRYWOLF.BASE.PNG",
        atlas=2048,
        celda=512,
        # Aqui los materiales SI traen nodos de imagen, pero apuntan a unos
        # `.tga` que no vienen en el zip -lo que hay son `.jpeg` en
        # `textures/`-, asi que Blender los carga a 0x0 y el atlas divide por
        # cero. Se dicen a mano, como en el bug. Los nombres casan uno a uno
        # y no hay nada que adivinar.
        texturas={
            "Cry Wolf Main": "BODY_PAINT_Cry_Wolf_Main_BaseColor.jpeg",
            "Cry Wolf SEC":  "BODY_PAINT_Cry_Wolf_SEC_BaseColor.jpeg",
        },
        texturas_en=MODS3D + r"\crywolf\textures",
        # Y este trae normal Y rugosidad DE VERDAD, que ni el necromorfo ni
        # el zombie tenian: sus normales se inventaron de la luminancia con
        # Make-NMSNormal.py y sus mascaras iban planas a 87. Aqui se atlasean
        # los tres canales con el MISMO reparto de celdas -`bloques` es
        # explicito y `colocar` es determinista-, asi que el normal y la
        # rugosidad caen exactamente encima del color.
        texturas_normal={
            "Cry Wolf Main": "BODY_PAINT_Cry_Wolf_Main_Normal.jpeg",
            "Cry Wolf SEC":  "BODY_PAINT_Cry_Wolf_SEC_Normal.jpeg",
        },
        texturas_masks={
            "Cry Wolf Main": "BODY_PAINT_Cry_Wolf_Main_Roughness.jpeg",
            "Cry Wolf SEC":  "BODY_PAINT_Cry_Wolf_SEC_Roughness.jpeg",
        },
        # Solo dos slots, asi que cada uno se lleva 2x2 celdas -1024 px- y
        # sobra media rejilla. Main es el cuerpo entero y SEC las costillas,
        # el ojo y los bigotes: los dos se miran de cerca.
        bloques={"Cry Wolf Main": 2, "Cry Wolf SEC": 2},
    ),
}

CUAL = sys.argv[sys.argv.index("--") + 1] if "--" in sys.argv else "necromorph"
M = MODELOS[CUAL]
# `--canal normal` o `--canal masks` atlasea el OTRO mapa del mismo modelo con
# el MISMO reparto de celdas, y no toca ni las UV ni el .blend: los dos ya
# quedaron bien en la pasada de `base`. Solo escribe el PNG.
CANAL = (sys.argv[sys.argv.index("--canal") + 1]
         if "--canal" in sys.argv else "base")
assert CANAL in ("base", "normal", "masks"), CANAL
print(f"modelo: {CUAL}  canal: {CANAL}")

BLEND = M["blend"]
OBJETO = M["objeto"]
SALIDA_BLEND = M["salida_blend"]
SALIDA_PNG = M["salida_png"]
if CANAL != "base":
    sufijo = {"normal": ".BASE.NORMAL.PNG", "masks": ".BASE.MASKS.PNG"}[CANAL]
    SALIDA_PNG = SALIDA_PNG.replace(".BASE.PNG", sufijo)
    assert SALIDA_PNG.endswith(sufijo), M["salida_png"]
TEXTURAS = M.get(f"texturas_{CANAL}") if CANAL != "base" else M.get("texturas")
assert TEXTURAS is not None or CANAL == "base", (
    f"{CUAL} no declara `texturas_{CANAL}`")
TEXTURAS_EN = M.get("texturas_en")
BLOQUES = M.get("bloques")

ATLAS = M["atlas"]
CELDA = M["celda"]
LADO = ATLAS // CELDA


def imagen_del_material(mat):
    """La imagen del material, o la que diga `texturas` si el FBX no trae
    ninguna. None cuando el material va a color plano."""
    if TEXTURAS is not None:
        assert mat.name in TEXTURAS, (
            f"{mat.name!r} no esta en `texturas` de {CUAL}. Los slots son "
            f"{[m.name for m in bpy.data.materials]}")
        archivo = TEXTURAS[mat.name]
        if archivo is None:
            return None
        ruta = os.path.join(TEXTURAS_EN, archivo)
        assert os.path.exists(ruta), f"no esta el PNG: {ruta}"
        return bpy.data.images.load(ruta, check_existing=True)
    nodos = [n for n in mat.node_tree.nodes
             if n.type == "TEX_IMAGE" and n.image is not None]
    if len(nodos) == 1:
        return nodos[0].image
    # Varias imagenes: aqui solo se atlasea el COLOR BASE. El cry wolf trae
    # tres por material -BaseColor, Normal y Roughness- y coger la primera
    # seria una moneda al aire. Se sigue el enlace de `Base Color` del BSDF,
    # que es el unico sitio donde el dato esta dicho y no supuesto. El normal
    # y la rugosidad salen aparte, con Make-NMSTexture.py.
    assert nodos, f"{mat.name}: 0 imagenes"
    bsdf = next((n for n in mat.node_tree.nodes if "Base Color" in n.inputs),
                None)
    assert bsdf is not None, f"{mat.name}: {len(nodos)} imagenes y ningun BSDF"
    enlaces = bsdf.inputs["Base Color"].links
    assert enlaces, (f"{mat.name}: {len(nodos)} imagenes y `Base Color` "
                     f"sin enlazar, no hay forma de saber cual es el color")
    nodo = enlaces[0].from_node
    assert nodo.type == "TEX_IMAGE" and nodo.image is not None, (
        f"{mat.name}: `Base Color` viene de {nodo.type}, no de una imagen")
    return nodo.image


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


def encoger(a, destino):
    """Amplia como `escalar`, y ademas REDUCE por multiplo entero promediando
    el bloque. Hace falta desde el warrior bug y el cry wolf, que traen PNG de
    2048 y 4096 para un atlas de 2048 repartido entre doce slots: ahi la celda
    es MAS PEQUENA que el origen y `escalar` solo sabia ir hacia arriba.

    Se promedia y no se muestrea uno de cada k porque muestrear se come el
    detalle fino -las escamas del bug son de pocos pixeles- y deja aliasing
    que los mips ya no arreglan."""
    origen = a.shape[0]
    assert a.shape[0] == a.shape[1], f"textura no cuadrada: {a.shape}"
    if origen <= destino:
        return escalar(a, destino)
    assert origen % destino == 0, f"{origen} -> {destino} no es multiplo"
    k = origen // destino
    return a.reshape(destino, k, destino, k, a.shape[2]).mean(axis=(1, 3))


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
planos = {}
for i, slot in enumerate(ob.material_slots):
    img = imagen_del_material(slot.material)
    fuentes[i] = img
    if img is None:
        c = list(slot.material.diffuse_color)
        planos[i] = np.array(c[:3] + [1.0], dtype=np.float32)
        print(f"  slot {i}  {slot.material.name:32s} COLOR PLANO {c[:3]}")
    else:
        print(f"  slot {i}  {slot.material.name:32s} "
              f"{img.size[0]}x{img.size[1]}")

if BLOQUES is not None:
    bloques = {i: BLOQUES.get(ob.material_slots[i].material.name, 1)
               for i in fuentes}
else:
    bloques = {i: max(1, min(LADO, img.size[0] // CELDA))
               for i, img in fuentes.items()}
sitio = colocar(bloques)

lienzo = np.zeros((ATLAS, ATLAS, 4), dtype=np.float32)
lienzo[:, :, 3] = 1.0
rect = {}
for i, img in fuentes.items():
    fila, col = sitio[i]
    lado = bloques[i] * CELDA
    if img is None:
        trozo = np.tile(planos[i], (lado, lado, 1))
    else:
        trozo = encoger(a_rgba(pixeles(img)), lado)
    y, x = fila * CELDA, col * CELDA
    lienzo[y:y + lado, x:x + lado] = trozo
    rect[i] = (x / ATLAS, y / ATLAS, lado / ATLAS, lado / ATLAS)
    print(f"  slot {i} -> celda ({fila},{col})  {lado}px  "
          f"uv u {rect[i][0]:.3f}+{rect[i][2]:.3f}  "
          f"v {rect[i][1]:.3f}+{rect[i][3]:.3f}")


def guardar_atlas(lienzo, ruta):
    img = bpy.data.images.new(os.path.basename(ruta), ATLAS, ATLAS, alpha=True)
    img.pixels.foreach_set(lienzo.ravel())
    img.filepath_raw = ruta
    img.file_format = "PNG"
    img.save()


if CANAL != "base":
    # Las UV ya se movieron en la pasada de `base` y el .blend ya lleva el
    # material del atlas. Aqui solo hace falta el PNG, con el mismo reparto.
    guardar_atlas(lienzo, SALIDA_PNG)
    print(f"\n  {len(fuentes)} texturas -> {ATLAS}x{ATLAS} ({CANAL})")
    print(f"  {SALIDA_PNG}")
    sys.exit(0)

uvs = malla.uv_layers.active.data
crudo = np.empty(len(uvs) * 2, dtype=np.float32)
uvs.foreach_get("uv", crudo)
crudo = crudo.reshape(-1, 2)
# Dos cosas distintas se salen de [0,1] y NO se tratan igual.
#
# El TILING de verdad -una pieza que repite su textura, UV de 0 a 4- pisaria
# la celda vecina y no hay atlas que lo arregle: revienta.
#
# El RUIDO del decimador es otra cosa. El warrior bug sale del colapso 3,7:1
# con diez loops de 108000 pasados por 1,7e-3, que en una celda de 512 px son
# 0,4 pixeles. Eso se recorta y ya, porque recortarlo mueve el vertice menos
# de lo que mide un texel y reventar por ahi seria tirar el modelo entero.
HOLGURA = 0.01
fuera = int(((crudo < -HOLGURA) | (crudo > 1 + HOLGURA)).any(axis=1).sum())
assert fuera == 0, (f"{fuera} UV fuera de [0,1] por mas de {HOLGURA}: la "
                    f"pieza se repetiria y pisaria la celda vecina. Rango "
                    f"{crudo.min(axis=0)} a {crudo.max(axis=0)}")
recortados = int(((crudo < 0) | (crudo > 1)).any(axis=1).sum())
if recortados:
    # Y SE ESCRIBE DE VUELTA, que es lo que hace que sirva de algo: el bucle
    # de abajo lee de `uvs`, no de esta copia.
    np.clip(crudo, 0.0, 1.0, out=crudo)
    uvs.foreach_set("uv", crudo.ravel())
    print(f"  {recortados} UV recortadas a [0,1] (ruido del decimador, "
          f"por debajo de {HOLGURA})")

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
