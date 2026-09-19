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

import math
import os
import sys

import bmesh
import bpy
import mathutils
import numpy as np

RAIZ = os.path.expanduser(r"~\MODS\NMS_MOD_ZOMBIES")

# Lo que cambia de un modelo a otro, y nada mas.
#
# GIRO son los grados que hay que aplicar en X y en Y ANTES de exportar:
#
#   X -90   pasa de Z arriba -lo que deja el importador de FBX- a Y arriba,
#           que es el "arriba" de NMS. El marker ya venia asi y no lo necesita.
#   Y 180   pone la cara mirando a -Z, que es hacia donde mira el bicho
#           vanilla. Medido, no supuesto: el AABB del FIEND va de -1.405 a
#           +3.573 en Z, y al importarlo con NMSDK la caja sale de -3.572 a
#           +1.405 en Y de Blender -o sea Y_blender = -Z_nms- con la cabeza
#           en +Y. La cabeza vanilla esta en -Z de NMS.
#
# ALTO es la altura del bicho vanilla al que sustituye (AABBMAXY - AABBMINY
# de su nodo de malla). La escala es UNIFORME y sale de la altura, no del
# encaje de los tres ejes: el vanilla arrastra cola o patas largas y cuadrar
# los tres deforma. None deja la malla como esta.
MODELOS = {
    "marker": dict(
        fbx=RAIZ + r"\asset\Modelos Descomprimidos\marker-1\source\marker_1.fbx",
        blend=RAIZ + r"\BLENDER\proyectos\marker.blend",
        salida=RAIZ + r"\BLENDER\FIENDEGG",
        nodo="FiendEgg",
        escena="FIENDEGG",
        material=(r"MODELS\PLANETS\BIOMES\COMMON\RARERESOURCE\GROUND\FIENDEGG"
                  r"\EGGSHELL_MAT.MATERIAL.MBIN"),
        giro=(0, 0),
        alto=None,
    ),
    # EL QUE RELEVA AL MARKER en el FIENDEGG. Estatico: ni piel, ni pesos, ni
    # Weight-/Skin-/Check-NMSGraft. Solo los pasos 0a, 0c y 0d.
    #
    # NO entra por `fbx` como el marker, sino por `origen`: el marker importa
    # el FBX directo porque ya venia con el eje alto en Y, y este NO -sale de
    # Decimate-NMSMesh.py, que importa con el eje alto en Z de Blender-. De
    # ahi el giro en X.
    #
    # EL GIRO EN Y SE DEJA EN 0 Y ESTA SIN COMPROBAR EN PARTIDA. El huevo es
    # casi de revolucion, asi que el volcado no distingue el frente; lo unico
    # que lo distingue es por donde abre. Si en partida abre hacia el lado
    # equivocado, esto es lo que se toca.
    #
    # ALTO = 0.761688, medido en el AABB del nodo FiendEgg vanilla
    # (work/models/eggmesh/FIENDEGG.SCENE.MXML: AABBMAXY 0.708496 menos
    # AABBMINY -0.053192). No se elige: es el tamano del huevo del juego.
    "facehuggeregg": dict(
        origen=RAIZ + r"\BLENDER\proyectos\facehuggeregg.blend",
        objeto="facehuggeregg",
        blend=RAIZ + r"\BLENDER\proyectos\facehuggeregg_nms.blend",
        salida=RAIZ + r"\BLENDER\FIENDEGG",
        nodo="FiendEgg",
        escena="FIENDEGG",
        material=(r"MODELS\PLANETS\BIOMES\COMMON\RARERESOURCE\GROUND\FIENDEGG"
                  r"\EGGSHELL_MAT.MATERIAL.MBIN"),
        giro=(-90, 0),
        # 1,11% contra el 0,1% por defecto, y el assert es el que esta mal
        # calibrado, no la malla: son 102 aristas de costura sobre 9192, la
        # mas larga mide 0,174 -cabe en una celda del atlas de 0,25- y
        # correlacionan 0,825 con la arista en 3D. La malla NO se decimo
        # (3064 -> 3064), asi que tampoco es el colapso. Ver el porque
        # completo en _medir_uv.
        tope_uv=1.5,
        alto=0.761688,
    ),
    "necromorph": dict(
        origen=RAIZ + r"\BLENDER\proyectos\necromorph_atlas.blend",
        objeto="necromorph",
        blend=RAIZ + r"\BLENDER\proyectos\necromorph_nms.blend",
        salida=RAIZ + r"\BLENDER\FIEND",
        nodo="_Fiend_Body",
        escena="FIEND",
        material=(r"MODELS\PLANETS\CREATURES\SPIDERRIG\FIEND"
                  r"\FIEND_MAT.MATERIAL.MBIN"),
        giro=(-90, 180),
        alto=3.619638,
    ),
    "skrullcrawler": dict(
        origen=RAIZ + r"\BLENDER\proyectos\skrullcrawler.blend",
        objeto="skrullcrawler",
        blend=RAIZ + r"\BLENDER\proyectos\scuttler30k.blend",
        salida=RAIZ + r"\BLENDER\FREIGHTERFIEND",
        nodo="polySurface6",
        escena="FREIGHTERFIEND",
        material=(r"MODELS\PLANETS\CREATURES\SPIDERRIG\FREIGHTERFIEND"
                  r"\FFIENDMAT.MATERIAL.MBIN"),
        giro=(-90, 180),
        alto=1.85069,
    ),
    # LOS DOS DE LA SEGUNDA HORNADA, y sustituyen a los dos bipedos.
    #
    # EL GIRO VUELVE A 180, Y LO DECIDE LA PARTIDA, NO EL VOLCADO. La
    # PRUEBA01 salio con `giro=(-90, 0)` porque el decimo superior de la malla
    # caia en w 0,38 contra la cabeza vanilla en w 0,84, o sea el volcado
    # decia que con 180 el bicho iba montado del reves. En partida los dos
    # salieron DE ESPALDA con el 0, asi que el volcado media otra cosa -el
    # decimo superior de un insecto son las patas levantadas, no la cabeza- y
    # el 180 de las otras tres entradas era el bueno.
    #
    # EL ALTO NO ES EL DE LOS ACUERDOS B1 Y B2, Y ESO ES LA DECISION DEL
    # 2026-09-02. Medido, no elegido a gusto.
    #
    # B1 y B2 subieron el necromorfo a 3,62 m y el zombie a 2,43 m porque a
    # la altura del vanilla "se veian enanos". El precio no se vio entonces y
    # se midio ahora: el esqueleto del juego mide ~1,34 m -FIEND- y ~1,05 m
    # -ARTHROPOD-, asi que a esas alturas MAS DE LA MITAD DE LA MALLA QUEDA
    # POR ENCIMA DEL ULTIMO HUESO. Con la primera pasada de estos dos:
    #
    #     warrior bug a 2,43 m   60,7% de la malla sin hueso encima
    #                            spine_C0_0_jnt se lleva el 43,0%   (tope 39,3)
    #     cry wolf a 3,62 m      59,5% de la malla sin hueso encima
    #                            RootJNT se lleva el 64,6%          (tope 25,5)
    #
    # Ahi arriba el vecino mas cercano no encuentra mas que tronco, y de ahi
    # salen los dos asserts. Es la MISMA causa que se llevo ocho pruebas del
    # necromorfo y diez del zombie, y que se leia como "es que son bipedos":
    # el bipedismo lo agravaba, pero lo que rompe es la escala.
    #
    # 1,80 y 1,90 dejaban al bicho en 1,7x y 1,4x su vanilla con el esqueleto
    # cubriendo el 70-75% de la malla en vez del 40%, y asi salio la PRUEBA01.
    #
    # LA PRUEBA02 LOS DOBLO -3,60 y 3,80- a peticion del usuario, y EN PARTIDA
    # SALIERON DEMASIADO GRANDES. La PRUEBA03 se queda en x1,5 de la PRUEBA01
    # -2,70 y 2,85-, tambien elegido en partida y no en la mesa.
    #
    # Lo que sobrevive de la 02 es el METODO, y son dos cosas que no se ven
    # hasta que se toca la escala: el mapa a mano de Weight-NMSMesh.py va en
    # coordenadas NORMALIZADAS y por tanto NO cambia con el tamano, pero el
    # TOPE DE VAIVEN si, porque el vaiven es giro x palanca y el esqueleto del
    # juego no crece con nosotros. Cada cambio de `alto` obliga a volver a
    # medir la ventana del `objetivo`. Ver RECETA-PIEL.md §3.
    "warriorbug": dict(
        origen=RAIZ + r"\BLENDER\proyectos\warriorbug_atlas.blend",
        objeto="warriorbug",
        blend=RAIZ + r"\BLENDER\proyectos\warriorbug_nms.blend",
        salida=RAIZ + r"\BLENDER\BUGFIEND",
        nodo="ArthropodThorax",
        escena="BUGFIEND",
        material=(r"MODELS\PLANETS\CREATURES\ARTHROPOD\BUGFIEND"
                  r"\ARTHROPODTHORAX01MAT.MATERIAL.MBIN"),
        giro=(-90, 180),
        alto=2.700,
    ),
    "crywolf": dict(
        origen=RAIZ + r"\BLENDER\proyectos\crywolf_atlas.blend",
        objeto="crywolf",
        blend=RAIZ + r"\BLENDER\proyectos\crywolf_nms.blend",
        salida=RAIZ + r"\BLENDER\FIEND",
        nodo="_Fiend_Body",
        escena="FIEND",
        material=(r"MODELS\PLANETS\CREATURES\SPIDERRIG\FIEND"
                  r"\FIEND_MAT.MATERIAL.MBIN"),
        giro=(-90, 180),
        # EL DOBLEZ DEL CUELLO, y es lo unico que separa la PRUEBA05 de la 04.
        #
        # Medido el 04/09 sobre la malla ya girada: el cuello arranca en
        # z 0,45 -donde el ancho en x salta de 0,08 a 0,15, o sea donde
        # empieza el pecho- y la cabeza vive en z 0,00..0,10. Del arranque a
        # la cabeza sube 0,151 y avanza 0,213, o sea que el cuello va a
        # 35 GRADOS SOBRE LA HORIZONTAL. Eso es lo que en partida se lee como
        # "la cabeza va por delante" y "le pesa la cabeza", y NO es el pesado:
        # el 04/09 se deformo la misma malla con los pesos de la PRUEBA03 y
        # los de la PRUEBA04 y los dos renders salen iguales. Es la postura
        # del asset.
        #
        # Se dobla 30 grados en X con rampa suave: `desde` no se mueve nada y
        # `hasta` va entero, asi que el doblez se reparte por el cuello y la
        # cabeza gira rigida. Con 30 el cuello pasa de 35 a 65 grados y la
        # cabeza pasa de 0,213 a 0,109 por delante del arranque.
        pose=dict(grados=30.0, desde=0.45, hasta=0.15),
        alto=2.850,
    ),
    # ALTERNATIVA al cry wolf en el mismo hueco, no relevo: los dos se publican
    # y el jugador elige. Mismo rig, mismo nodo, mismo material.
    #
    # Entra por `origen` y no por `fbx`, como el facehuggerEgg: sale de
    # Decimate-NMSMesh.py, que importa con el eje alto en Z de Blender. De ahi
    # el giro en X.
    #
    # LOS TRES VALORES SON DE ARRANQUE Y SE RE-MIDEN CON EL VOLCADO. El 2,850
    # es el del cry wolf, que es el unico numero de este hueco elegido EN
    # PARTIDA y no en la mesa: el esqueleto FIEND mide 1,34 m y a 3,62 m el
    # 59,5% de la malla quedaba por encima del ultimo hueso.
    #
    # `pose` NO se pone. El doblez de cuello del cry wolf arregla un defecto de
    # postura de AQUEL asset; a este no se le inventa uno sin medirlo.
    "xenodog": dict(
        origen=RAIZ + r"\BLENDER\proyectos\xenodog.blend",
        objeto="xenodog",
        blend=RAIZ + r"\BLENDER\proyectos\xenodog_nms.blend",
        salida=RAIZ + r"\BLENDER\FIEND",
        nodo="_Fiend_Body",
        escena="FIEND",
        material=(r"MODELS\PLANETS\CREATURES\SPIDERRIG\FIEND"
                  r"\FIEND_MAT.MATERIAL.MBIN"),
        # EL 180 ESTABA MAL Y SE MIDIO, no se adivino. Con giro=(-90,180) el
        # volcado de Weight-NMSMesh.py ponia NUESTRA cabeza en z' 0 y la del
        # esqueleto FIEND en z' 1,41, o sea el bicho mirando hacia atras: la
        # cola del FIEND caia sobre nuestra cabeza y el pesado habria colgado
        # la cabeza de los NewTail*JNT.
        #
        # Que extremo es cual se decidio MIRANDO la malla, no por el numero de
        # vertices: en z' 0,92..1,00 hay 786 vertices en una varilla centrada
        # de x' 0,45..0,55 -el 10% del ancho-, que es la cola; y en z' 0,00..0,08
        # hay 5045 que ocupan el ancho entero, que son el domo, las mandibulas,
        # los hombros y los tubos dorsales.
        #
        # OJO: esto NO lo arregla `giro_z` de Weight-NMSMesh.py. Se probo: con
        # giro_z 0 y con 180 las z' salen IDENTICAS y lo unico que cambia es la
        # altura -con 0 los pies quedan en y' 0,60 y la cabeza en 0,17, boca
        # abajo-. giro_z 180 es el correcto y el desajuste es de ESTE giro.
        giro=(-90, 0),
        alto=2.850,
    ),
    "zombie": dict(
        origen=RAIZ + r"\BLENDER\proyectos\zombie.blend",
        objeto="zombie",
        blend=RAIZ + r"\BLENDER\proyectos\zombie_nms.blend",
        salida=RAIZ + r"\BLENDER\BUGFIEND",
        nodo="ArthropodThorax",
        escena="BUGFIEND",
        material=(r"MODELS\PLANETS\CREATURES\ARTHROPOD\BUGFIEND"
                  r"\ARTHROPODTHORAX01MAT.MATERIAL.MBIN"),
        giro=(-90, 180),
        alto=2.430,
    ),
}

cual = sys.argv[sys.argv.index("--") + 1] if "--" in sys.argv else "marker"
M = MODELOS[cual]
print(f"modelo: {cual}")

BLEND = M["blend"]
SALIDA = M["salida"]
NOMBRE_NODO = M["nodo"]
MATERIAL = M["material"]

if "fbx" in M:
    bpy.ops.wm.read_homefile(use_empty=True)
    bpy.ops.import_scene.fbx(filepath=M["fbx"])
    ob = next(o for o in bpy.data.objects if o.type == "MESH")
else:
    bpy.ops.wm.open_mainfile(filepath=M["origen"])
    ob = bpy.data.objects[M["objeto"]]

ob.name = NOMBRE_NODO
ob.data.name = NOMBRE_NODO

bpy.context.view_layer.objects.active = ob
ob.select_set(True)

giro_x, giro_y = M["giro"]
if giro_x or giro_y:
    ob.rotation_euler = (math.radians(giro_x), 0, 0)
    bpy.ops.object.transform_apply(rotation=True)
    ob.rotation_euler = (0, math.radians(giro_y), 0)
    bpy.ops.object.transform_apply(rotation=True)

POSE = M.get("pose")
if POSE:
    # DOBLAR UNA PARTE DE LA MALLA, con rampa. Va DESPUES del giro -para poder
    # razonar en el marco de NMS, con Y arriba y Z el fondo- y ANTES de la
    # escala, para que el alto de 2,85 m se mida sobre la malla ya doblada.
    #
    # La rampa es un smoothstep para que la tangente sea cero en los dos
    # extremos: sin eso queda un pliegue justo en la frontera, que es lo que
    # el suavizado de los pesos NO puede deshacer porque es geometria.
    co = np.array([tuple(v.co) for v in ob.data.vertices])
    lo_p, hi_p = co.min(axis=0), co.max(axis=0)
    tam_p = np.maximum(hi_p - lo_p, 1e-9)
    z = (co[:, 2] - lo_p[2]) / tam_p[2]
    u = np.clip((POSE["desde"] - z) / (POSE["desde"] - POSE["hasta"]), 0.0, 1.0)
    t = u * u * (3.0 - 2.0 * u)
    # El pivote: el centro de la seccion que hay JUSTO en `desde`, que es
    # donde el cuello se mete en el pecho. Se coge una banda estrecha y no un
    # solo vertice para que no lo mande el ruido del decimador.
    banda = np.abs(z - POSE["desde"]) < 0.02
    assert banda.sum() >= 20, f"la banda del pivote solo tiene {banda.sum()} vertices"
    pivote = co[banda].mean(axis=0)
    ang = math.radians(POSE["grados"]) * t
    dy, dz = co[:, 1] - pivote[1], co[:, 2] - pivote[2]
    ca, sa = np.cos(ang), np.sin(ang)
    co[:, 1] = pivote[1] + dy * ca - dz * sa
    co[:, 2] = pivote[2] + dy * sa + dz * ca
    for v, nuevo in zip(ob.data.vertices, co):
        v.co = mathutils.Vector(nuevo)
    ob.data.update()
    movidos = int((t > 1e-6).sum())
    lo_d, hi_d = co.min(axis=0), co.max(axis=0)
    print(f"doblez {POSE['grados']:.0f} grados en X sobre {movidos} vertices "
          f"({100 * movidos / len(co):.1f}%), pivote "
          f"{tuple(round(float(v), 4) for v in pivote)}")
    print(f"  caja {tuple(round(float(v), 4) for v in (hi_p - lo_p))}"
          f" -> {tuple(round(float(v), 4) for v in (hi_d - lo_d))}")

if M["alto"]:
    co = [v.co for v in ob.data.vertices]
    propio = max(c.y for c in co) - min(c.y for c in co)
    ob.scale = (M["alto"] / propio,) * 3
    print(f"escala uniforme {M['alto'] / propio:.4f}: "
          f"alto {propio:.3f} -> {M['alto']:.3f}")
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)

    # Y DE PIE sobre el origen, no centrado en el. El bicho vanilla se apoya
    # en el suelo -el FIEND tiene AABBMINY -0.036- y el nuestro salia con los
    # pies en -0.94 y la caja entera corrida en Z, porque el FBX trae su
    # propio origen. Sin esto la criatura flota o se hunde, y ademas queda
    # descolocada respecto a la colision, que es la del vanilla y no se toca.
    # Se mueve la MALLA, no el objeto: transform_apply(location=True) en
    # segundo plano no llegaba a los vertices y el .GEOMETRY salia con el
    # AABB de antes, identico hasta el sexto decimal.
    co = [v.co for v in ob.data.vertices]
    lo = [min(c[i] for c in co) for i in range(3)]
    hi = [max(c[i] for c in co) for i in range(3)]
    mueve = mathutils.Vector((-(lo[0] + hi[0]) / 2, -lo[1],
                              -(lo[2] + hi[2]) / 2))
    ob.data.transform(mathutils.Matrix.Translation(mueve))
    ob.data.update()
    print(f"asentado: {tuple(round(v, 4) for v in mueve)}")

# FUERA EL COLOR DE VERTICE, Y NO ES COSMETICO.
#
# NMSDK exporta la capa de color como el canal 4 -UNSIGNED_BYTE x4- y eso son
# CUATRO BYTES MAS por vertice. El FBX del cry wolf trae una capa `Col` y con
# ella el .GEOMETRY salio a stride 12 con los canales [2, 3, 4] en vez de a
# stride 8 con [2, 3].
#
# Rompe dos cosas: Skin-NMSGeometry.py aborta si la malla no viene a stride 8
# -y hace bien, porque los offsets de los canales 5 y 6 los cuenta desde ahi-
# y el vanilla al que sustituimos declara [2, 3, 5, 6] y ni lee ni espera un
# canal 4. O sea que son cuatro bytes por vertice que nadie mira y que ademas
# impiden coser la piel.
for capa in list(ob.data.color_attributes):
    nombre = capa.name
    ob.data.color_attributes.remove(capa)
    print(f"quitada la capa de color {nombre!r} (canal 4, stride +4)")

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
lo = [min(c[i] for c in co) for i in range(3)]
hi = [max(c[i] for c in co) for i in range(3)]
caja = [hi[i] - lo[i] for i in range(3)]
alto = caja[1]
print(f"caja en coordenadas locales: "
      f"{caja[0]:.4f} / {alto:.4f} / {caja[2]:.4f}"
      f"  (el huevo vanilla mide 0.7615 de alto)")
print(f"  min {tuple(round(v, 4) for v in lo)}"
      f"  max {tuple(round(v, 4) for v in hi)}")
assert alto < 10, f"la malla mide {alto:.1f} en local: falta aplicar la escala"

# ---------------------------------------------------------------------------
# El exportador de NMSDK escribe el index buffer EQUIVOCADO, y por eso la
# textura sale estirada. Medido el 24/08 sobre el SkrullCrawler:
#
#   mesh_parser() parte bien los vertices de costura -4820 pasan a 11357, uno
#   por cada combinacion de vertice y UV- y devuelve DOS listas de indices:
#
#     indexes      los indices ya remapeados a los vertices partidos
#     np_indexes   data.loops.foreach_get("vertex_index"), o sea los de ANTES
#                  de partir, del 0 al 4819
#
#   y export.py:296 serializa `self.np_indexes[i]`, la de antes de partir. Los
#   6537 vertices partidos entran al buffer y NO LOS APUNTA NADIE: cada vertice
#   de costura se queda con la PRIMERA UV que le tocara, que en un atlas como
#   el de Meshy -cientos de islas diminutas- es de otra isla cualquiera.
#
#   La malla en 3D sale perfecta -los indices 0..4819 apuntan a las posiciones
#   buenas- y solo la textura se rompe, que es justo lo que se veia en partida:
#   el bicho bien plantado y la piel a remolinos. El 30,89% de las aristas de
#   la malla desplegada cruzaban mas del 10% del atlas; el FBX original no pasa
#   de 5,8%.
#
# Y de paso, normales: NMSDK escribe `poly.normal` -la normal de CARA de la
# primera cara que toco el vertice-, ignorando las que Blender ya tiene
# calculadas. Error mediano de 21,6 grados y un 2,7% de vertices apuntando al
# reves. Aqui se usan las de Blender, que son las buenas.
#
# Se parchea desde fuera y no se toca el addon: vive en AppData y se pierde al
# reinstalarlo.
# ---------------------------------------------------------------------------

def _parchear_nmsdk():
    import importlib

    addon = importlib.import_module(
        "bl_ext.user_default.nmsdk.ModelExporter.addon_script")
    original = addon.Exporter.mesh_parser

    def mesh_parser(self, ob, is_coll_mesh=False):
        if is_coll_mesh:
            return original(self, ob, is_coll_mesh)

        me = ob.data
        assert me.uv_layers, f"{ob.name} no tiene UV"
        assert all(len(p.vertices) == 3 for p in me.polygons), "hay caras sin triangular"

        me.calc_tangents()
        uv_data = me.uv_layers.active.data
        normales_de_esquina = me.corner_normals

        exporta_color = bool(len(me.color_attributes)) and not self.settings.get(
            "no_vert_colours", False)
        color_data = me.color_attributes.active_color.data if exporta_color else None

        verts, uvs, normals, tangents = [], [], [], []
        colours = [] if exporta_color else None
        visto = {}
        indexes = []

        for lp in me.loops:
            vi = lp.vertex_index
            u, v = uv_data[lp.index].uv
            n = normales_de_esquina[lp.index].vector
            t = lp.tangent
            clave = (vi, round(u, 6), round(v, 6),
                     round(n[0], 5), round(n[1], 5), round(n[2], 5))
            idx = visto.get(clave)
            if idx is None:
                idx = visto[clave] = len(verts)
                co = me.vertices[vi].co
                verts.append((co[0], co[1], co[2], 1))
                # NMS guarda la V dada la vuelta, igual que hacia NMSDK.
                uvs.append((u, 1 - v, 0, 1))
                normals.append((n[0], n[1], n[2], 1))
                tangents.append((t[0], t[1], t[2], 1))
                if exporta_color:
                    c = color_data[lp.index].color
                    colours.append((int(255 * c[0]), int(255 * c[1]), int(255 * c[2])))
            indexes.append(idx)

        me.free_tangents()

        chverts = addon.generate_hull(me)
        np_indexes = np.array(indexes, dtype=np.uint32)

        print(f"parseado {ob.name}: {len(me.vertices)} vertices de Blender -> "
              f"{len(verts)} exportados, {len(indexes)} indices")
        _medir_uv(verts, uvs, np_indexes)
        return verts, normals, tangents, uvs, indexes, chverts, colours, np_indexes

    addon.Exporter.mesh_parser = mesh_parser


def _medir_uv(verts, uvs, indexes):
    """Salta si una arista cruza medio atlas: es la firma del index malo.

    El limite es 0,10 en UV. Medido: el FBX del SkrullCrawler no pasa de
    0,0582 y el del necromorfo anda por ahi; la malla rota daba 1,2574 en el
    30,89% de las aristas. Cualquier cosa entre medias tampoco es sana.
    """
    P = np.array(verts, dtype=np.float64)[:, :3]
    U = np.array(uvs, dtype=np.float64)[:, :2]
    I = np.asarray(indexes, dtype=np.int64).reshape(-1, 3)
    largo = lambda A: np.concatenate(
        [np.linalg.norm(A[I[:, i]] - A[I[:, (i + 1) % 3]], axis=1) for i in range(3)])
    eu, e3 = largo(U), largo(P)
    cuantas = int((eu > 0.10).sum())
    rotas = cuantas / len(eu) * 100
    print(f"  aristas UV: mediana {np.median(eu):.5f}  max {eu.max():.5f}  "
          f"por encima de 0.10: {cuantas} de {len(eu)} ({rotas:.4f}%)")
    print(f"  correlacion con la arista en 3D: {np.corrcoef(e3, eu)[0, 1]:.3f}")
    # EL LIMITE NO ES CERO, Y LA DIFERENCIA IMPORTA.
    #
    # Lo que este assert caza es el index buffer de antes de partir los
    # vertices, y esa firma es MASIVA: 30,89% de las aristas en el
    # SkrullCrawler, 30,30% en el necromorfo, 13,67% en el zombie. No es un
    # puñado, es un tercio de la malla.
    #
    # Un puñado es otra cosa: el decimador, al colapsar, deja algun triangulo
    # con dos esquinas en islas distintas del atlas. El warrior bug sale del
    # 3,7:1 con unas pocas de 108000. Con doce celdas de 0,25 esas aristas
    # miden hasta 0,196 -menos de una celda- y son triangulos sueltos, no una
    # malla mal indexada.
    #
    # 0,1% deja 137 veces de margen contra el caso malo mas suave medido.
    #
    # PERO EL TOPE ES UN PORCENTAJE Y ESO LO HACE DEPENDER DEL TAMANO DE LA
    # MALLA, que es un fallo del propio assert y se vio con el huevo el
    # 2026-09-13. El 0,1% se calibro contra el warrior bug, 108000 triangulos:
    #
    #     warriorbug      108000 tris   324000 aristas   0,1% = 324 aristas
    #     necromorph       59384 tris   178152 aristas   0,1% = 178 aristas
    #     skrullcrawler     9592 tris    28776 aristas   0,1% =  29 aristas
    #     facehuggeregg     3064 tris     9192 aristas   0,1% =   9 aristas
    #
    # O sea: el mismo punado de aristas de costura que en el warrior bug se
    # perdona -324 de margen- en una malla treinta y cinco veces mas pequena
    # no cabe. El huevo trae 102, que en el warrior bug serian el 0,0315% y
    # pasarian sin mirarlas.
    #
    # Lo que SI distingue los dos casos y no depende del tamano son las otras
    # dos senales que ya estan medidas arriba:
    #   - la arista UV mas larga cabe en UNA celda del atlas (< 0,25). El
    #     index buffer mal indexado cruza el atlas entero.
    #   - la correlacion con la arista en 3D es alta -0,825 en el huevo-, o
    #     sea que las aristas UV largas son aristas largas de verdad. En una
    #     malla mal indexada no hay correlacion, el emparejamiento es azar.
    #
    # Mientras esas dos aguanten, el tope por modelo es legitimo. `tope_uv`
    # en MODELOS lo sube solo para el modelo que lo declare; el resto sigue
    # en 0,1 y el assert sigue cazando lo que caza.
    TOPE = M.get("tope_uv", 0.1)
    assert rotas <= TOPE, (
        f"{rotas:.4f}% de las aristas cruzan mas del 10% del atlas, por "
        f"encima del {TOPE}%: eso ya no es el decimador, es el index buffer "
        f"de antes de partir los vertices. La textura saldria a remolinos")


_parchear_nmsdk()

bpy.ops.nmsdk.create_root_scene()
raiz = bpy.data.objects["NMS_Scene"]
raiz.NMSReference_props.scene_name = M["escena"]

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
