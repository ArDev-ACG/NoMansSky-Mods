"""Pesa nuestra malla contra el esqueleto vanilla, sin tocar el interfaz.

    blender.exe --background --python tools/Weight-NMSMesh.py

Deja dos cosas, y las dos se versionan: el .blend y
work/models/scuttlermesh/pesos.json, que es lo que consume el splice.

SE COPIA LA PIEL DEL VANILLA Y DESPUES SE SUAVIZA POR NUESTRAS ARISTAS.

Han fallado dos metodos antes que este, y los dos con EL MISMO sintoma en
partida —"laminas planas tensadas"—, escrito las dos veces con esas
palabras:

    PRUEBA12  Data Transfer POLYINTERP_NEAREST, o sea copiar del punto mas
              cercano de la SUPERFICIE del vanilla. Las dos puntas de las
              patas delanteras se llevaron el 82% de la malla y RootJNT se
              quedo con el 0,4%.
    PRUEBA14  distancia al SEGMENTO de cada hueso. LFirstLeg3JNT se llevo
              el 12,1% y RFirstLeg3JNT el 0,0%, y ademas se pesaba contra
              los 113 huesos del .SCENE: 30 de los 42 grupos que salieron
              eran parpados, ojos, boca, mandibula y cola, huesos a los que
              la piel del vanilla NO se pega. Esos son las tiras negras.

La causa comun no es la alineacion: es adjudicar a UN ganador entre huesos
que estan casi a la misma distancia. El FreighterFiend es una araña de
patas largas y cuerpo pequeño y el nuestro es compacto, asi que sus patas
atraviesan nuestro volumen; una franja del torso se va con una pata y la de
al lado se queda con la espalda, y al andar la costura entre las dos se
estira. Eso es la lamina.

Lo que hace ahora, y por que cada paso:

    1. los candidatos salen del SkinMatrixLayout del .GEOMETRY vanilla, o
       sea de los huesos a los que el propio juego pega esa piel: 19 de 113
       en el SPIDERRIG, 29 de 53 en el ARTHROPOD. Los parpados dejan de
       poder ganar porque dejan de estar en la lista.
    2. cada vertice nuestro promedia los VECINOS de la piel vanilla, no uno
       solo, con peso inverso a la distancia. Sin ganador unico no hay
       costura, hay degradado.
    3. y se promedia otra vez por las aristas de NUESTRA malla. Es lo unico
       que devuelve al torso la trasera que las patas del vanilla se llevan,
       porque ahi, en el espacio, no hay nada del vanilla que copiar salvo
       pata. Ataca el fallo de frente: una lamina tensada ES un salto de
       peso entre dos vertices unidos por una arista.

Y los topes no son numeros a ojo: se comparan contra lo que el vanilla hace
con su propia piel, medido en la misma corrida. El que de verdad separa es
la SIMETRIA -el vanilla da 0,000, la PRUEBA14 daba 0,253-; se probo y se
descarto la distancia del vertice a su hueso, porque el vanilla mismo da
1,039 sobre una diagonal de 4,22 y los dos metodos malos daban 0,903 y
1,092.

Otras dos cosas que costaron una sesion cada una y siguen aplicando:

  1. NMSDK IMPORTA pesos pero NO los EXPORTA: escribe JointBindings,
     MeshBaseSkinMat y SkinMatrixLayout vacios. El muro es solo de salida.
  2. El importador exige que la carpeta repita la ruta interna de la
     escena (import_scene.py:220, base_path). Por eso el vanilla esta
     extraido en work/models/vanilla_freighterfiend/models/planets/...

Y el giro de 180 en Z no se decide contando grupos con vertices -eso da
GIRO_Z 0, que pone nuestro craneo mirando hacia atras-. Se decide por
donde cae la cabeza: la del vanilla esta en +Y.
"""

import json
import os
import re
import sys
import math
from pathlib import Path

import bpy
import numpy as np
from mathutils import Matrix

sys.path.insert(0, str(Path(__file__).resolve().parent))
import nmsskin

RAIZ = Path(os.path.expanduser(r"~\NMS_MOD_ZOMBIES"))
# Lo que cambia de un modelo a otro, y nada mas. Se elige con `-- <modelo>`,
# los mismos nombres que en tools/Export-NMSMesh.py.
#
#   blend    el .blend que DEJA Export-NMSMesh.py, NO el de antes. El guion
#            asienta los pies en Y 0 y el conducto manual los tenia en
#            -0.020806: son 2,08 cm, siete veces la tolerancia de 0,003 con la
#            que casa Skin-NMSGeometry, o sea que pesar contra el blend
#            equivocado no casa NI UN VERTICE.
#   giro_z   §3 de RECETA-PIEL.md. No se adivina: lo decide el assert de la
#            cabeza por encima de los pies, que va al final de este guion.
#   cabeza / pies / puntas / tronco
#            trozos del NOMBRE de los huesos del vanilla, y cambian con el
#            esqueleto. El SPIDERRIG los tiene en estilo Maya viejo
#            -NewHeadJNT, RootJNT, RFirstLeg4END- y el ARTHROPOD en estilo
#            Maya nuevo -head_C0_0_jnt, root_C0_0_jnt, leg_R0_end_jnt-.
MODELOS = {
    "skrullcrawler": dict(
        blend=RAIZ / "BLENDER" / "proyectos" / "scuttler30k.blend",
        vanilla=(RAIZ / "work" / "models" / "vanilla_freighterfiend" / "models"
                 / "planets" / "creatures" / "spiderrig"
                 / "freighterfiend.scene.mbin"),
        salida=RAIZ / "work" / "models" / "scuttlermesh" / "pesos.json",
        objeto="polySurface6",
        giro_z=180,
        puntas=("Leg3", "Leg4", "END"),
        cabeza=("Head", "Jaw", "Skull"),
        pies=("Leg4END", "Leg3END"),
        tronco=("Root", "Back"),
        espejo=("L", "R"),
        escala_piel="altura",
        tope_reparto=None,
    ),
    "necromorph": dict(
        blend=RAIZ / "BLENDER" / "proyectos" / "necromorph_nms.blend",
        vanilla=(RAIZ / "work" / "models" / "vanilla_fiend" / "models"
                 / "planets" / "creatures" / "spiderrig" / "fiend.scene.mbin"),
        salida=RAIZ / "work" / "models" / "fiendmesh" / "pesos.json",
        objeto="_Fiend_Body",
        giro_z=180,
        puntas=("Leg3", "Leg4", "END"),
        cabeza=("Head", "Jaw", "Skull"),
        pies=("Leg4END", "Leg3END"),
        tronco=("Root", "Back"),
        espejo=("L", "R"),
        escala_piel=1.0,
        tope_reparto=0.85,
        # Un BIPEDO montado en una arana: el vecino mas cercano no puede
        # encontrarle brazos porque el FIEND no los tiene donde nosotros. El
        # mapa sale del volcado de --volcar-huesos, no de suponer: la piel del
        # FIEND cabe entera en la MITAD DE ABAJO de nuestra malla -y de 0,05 a
        # 0,37 sobre 3,62 m- y se sale por delante y por detras -z de 0,00 a
        # 1,56 sobre 2,22 m-. Los L* caen en x > 0,5 y los R* en x < 0,5.
        # Gana la PRIMERA fila que case, asi que van de arriba abajo.
        regiones=(
            ("NewHeadJNT",     lambda u, v, w: v > 0.86),
            ("LFirstLeg3JNT",  lambda u, v, w: v > 0.45 and u > 0.70),
            ("RFirstLeg3JNT",  lambda u, v, w: v > 0.45 and u < 0.30),
            ("NewBack1JNT",    lambda u, v, w: v > 0.55),
            ("LFourthLeg3JNT", lambda u, v, w: v <= 0.40 and u >= 0.50),
            ("RFourthLeg3JNT", lambda u, v, w: v <= 0.40 and u < 0.50),
            ("RootJNT",        lambda u, v, w: True),
        ),
    ),
    "zombie": dict(
        blend=RAIZ / "BLENDER" / "proyectos" / "zombie_nms.blend",
        vanilla=(RAIZ / "work" / "models" / "vanilla_bugfiend" / "models"
                 / "planets" / "creatures" / "arthropod"
                 / "bugfiend.scene.mbin"),
        salida=RAIZ / "work" / "models" / "zombiemesh" / "pesos.json",
        objeto="ArthropodThorax",
        giro_z=180,
        puntas=("_end_jnt",),
        cabeza=("head_",),
        pies=("_end_jnt",),
        # `tail_C0_*` es el ABDOMEN del artropodo, o sea cuerpo, no punta de
        # miembro: el volcado lo pone en x 0,50, en el eje. Cuenta como tronco.
        tronco=("root_", "spine_", "tail_"),
        espejo=("_L", "_R"),
        escala_piel=1.0,
        tope_reparto=0.85,
        # Lo mismo, con el ARTHROPOD. Del volcado: la piel del bicho cabe en
        # la mitad de abajo -y de 0,08 a 0,51 sobre 2,43 m-, `head_C0_0_jnt`
        # se lleva 8264 vertices y esta delante, `spine_C0_0_jnt` es el hueso
        # de cuerpo mas alto, y las tres parejas de patas se ordenan por z:
        # `leg_*0_*` delante (z 1,07-1,33), `leg_*1_*` en medio (0,69) y
        # `leg_*2_*` detras (0,00-0,33). Los L* caen en x > 0,5.
        regiones=(
            ("head_C0_0_jnt", lambda u, v, w: v > 0.86),
            ("leg_L0_1_jnt",  lambda u, v, w: v > 0.55 and u > 0.74),
            ("leg_R0_1_jnt",  lambda u, v, w: v > 0.55 and u < 0.26),
            ("spine_C0_0_jnt", lambda u, v, w: v > 0.55),
            ("leg_L2_1_jnt",  lambda u, v, w: v <= 0.40 and u >= 0.50),
            ("leg_R2_1_jnt",  lambda u, v, w: v <= 0.40 and u < 0.50),
            ("tail_C0_0_jnt", lambda u, v, w: True),
        ),
    ),
}

CUAL = sys.argv[sys.argv.index("--") + 1] if "--" in sys.argv else "skrullcrawler"
M = MODELOS[CUAL]
print(f"modelo: {CUAL}")

BLEND = M["blend"]
VANILLA = M["vanilla"]
SALIDA = M["salida"]
NUESTRA = M["objeto"]
GIRO_Z = M["giro_z"]
ESCALA_PIEL = M.get("escala_piel", "altura")
TOPE_REPARTO = M.get("tope_reparto")

# Cuantos vertices de la piel vanilla promedia cada vertice nuestro.
# Con 1 estariamos en el metodo que fallo -un ganador unico y una costura
# donde cambia-. Con 8 la frontera es un degradado de varios centimetros,
# que es lo que hace falta para que no se tense. Se queda en 2 influencias
# por vertice, que es lo que cabe comodo en el buffer.
VECINOS = 8
BLOQUE_VECINOS = 256  # 256 x 7635 x 3 float64 son 47 MB; de una vez, 880

# Pasadas de promedio por las aristas de NUESTRA malla, despues de copiar.
# Es lo unico que puede devolver al torso la trasera que las patas del
# vanilla se llevan, porque ahi no hay nada del vanilla que copiar salvo
# pata. El numero se sube hasta que el assert de punta deja de saltar.
SUAVIZADOS = 12

# Lo que NO puede pasar. Los topes NO son numeros a ojo: los tres primeros
# se comparan contra lo que hace el VANILLA con su propia piel, medido en
# la misma corrida. Asi valen igual para el SPIDERRIG y para el ARTHROPOD.
#
#   HOLGURA_REPARTO  el vanilla pone el 45,9% de su malla en RootJNT: un
#                    hueso dueno de medio bicho es anatomia normal aqui, y
#                    el tope fijo de 0,35 rechazaba pesados buenos. Lo que
#                    no vale es pasarse MUCHO de lo que hace el vanilla.
#   TOPE_ASIMETRIA   el que de verdad separa. El reparto del vanilla esta
#                    pareado al vertice -RFirstLeg3JNT 260, LFirstLeg3JNT
#                    260- y los dos fallos lo rompen de par en par:
#                    PRUEBA12 con el 82% en dos puntas, PRUEBA14 con
#                    LFirstLeg3JNT al 12,1% y RFirstLeg3JNT al 0,0%.
#   MINIMO_TRONCO    que el cuerpo cuelgue de la COLUMNA. El 15/08 colgaba
#                    de las puntas de las patas y RootJNT tenia 17 vertices.
#   TOPE_PUNTA       ninguna punta de miembro con un trozo grande, y se
#                    mide CONTRA EL TRONCO, no contra la malla entera. La
#                    fraccion de vertices no es comparable entre las dos
#                    mallas: el vanilla amontona el 73% de los suyos en el
#                    cuerpo -Root 45,9% mas Head 27,5%- y la nuestra, que
#                    sale de decimar, los reparte parejos. Contra la malla
#                    entera, el 15% de nuestras patas traseras y el 3,4%
#                    de las suyas no dicen lo mismo. Contra el tronco si:
#                    el fallo del 15/08 era 43,2% de punta con el tronco
#                    al 0,4%, o sea la punta CIEN VECES el tronco.
#
# Se probo y se DESCARTO, ahora con la referencia delante, la distancia del
# vertice a su hueso: el vanilla contra su propio esqueleto da 1,039 de
# media sobre una diagonal de 4,22, y los dos metodos malos dieron 0,903 y
# 1,092. No separa nada, y por eso se imprime pero no corta.
HOLGURA_REPARTO = 1.25
TOPE_ASIMETRIA = 0.10
MINIMO_TRONCO = 0.30
TOPE_PUNTA = 0.50  # una punta, como mucho, la mitad de lo que lleve el tronco


def caja_mundo(ob):
    co = [ob.matrix_world @ v.co for v in ob.data.vertices]
    lo = np.array([min(c[i] for c in co) for i in range(3)])
    hi = np.array([max(c[i] for c in co) for i in range(3)])
    return lo, hi


def paleta_vanilla():
    """Los huesos a los que se pega la piel del VANILLA, y SOLO esos.

    El .SCENE del FreighterFiend trae 114 huesos y su piel usa 19. Los
    otros 95 son parpados, ojos, boca, mandibula, cola y las patas
    segunda y tercera: trozos que el bicho mueve por su cuenta y muy
    lejos del cuerpo. Un vertice nuestro pegado a uno de ellos sale
    disparado en cuanto el bicho parpadea.

    Ese fue el fallo de la PRUEBA14, medido el 26/08: pesando contra los
    114 salian 42 grupos y 30 caian fuera de esta lista -NewJawJNT con
    425 vertices, NewTail2/3/4 con 882, y luego REyelidLowerJNT,
    LEyeParentJNT o LowerLMouthJNT con uno cada uno-. De ahi las tiras
    negras de la nuca. La PRUEBA12, que se movia bien, usaba 14 grupos y
    los 14 estaban aqui dentro.
    """
    joints = nmsskin.leer_joints(VANILLA.with_suffix(".MXML"))
    por_indice = {i: n for n, i in joints.items()}
    geo = VANILLA.with_name(
        VANILLA.name.replace(".scene.mbin", ".geometry.MXML"))
    bloque = re.search(r'name="SkinMatrixLayout".*?</Property>',
                       geo.read_text(encoding="utf-8", errors="replace"),
                       re.S)
    assert bloque, f"no hay SkinMatrixLayout en {geo}"
    return {por_indice[int(v)]
            for v in re.findall(r'value="(-?\d+)"', bloque.group(0))}


def asimetria(frac, espejo, paleta):
    """Cuanto se desparejan los huesos izquierdo y derecho, en fraccion.

    Solo cuenta los que TIENEN pareja EN LA PALETA. Sin esa condicion,
    RootJNT se puntuaba contra un "LootJNT" que no existe y el vanilla
    -que esta pareado al vertice, RFirstLeg3JNT 260 y LFirstLeg3JNT 260-
    salia con 0,459 de asimetria, o sea con la suya propia entera.
    NewBack1JNT ni siquiera lleva L ni R, y tambien se salta.
    """
    izq, der = espejo
    total = 0.0
    for g in frac:
        if der not in g:
            continue
        pareja = g.replace(der, izq, 1)
        if pareja == g or pareja not in paleta:
            continue
        total += abs(frac.get(pareja, 0.0) - frac[g])
    return total


def reparto_de(dominantes):
    """Nombre de hueso -> fraccion de la malla que le toca."""
    cuenta = {}
    for g in dominantes:
        cuenta[g] = cuenta.get(g, 0) + 1
    return {g: n / len(dominantes) for g, n in cuenta.items()}


def dist_a_segmento(p, a, b):
    """Distancia de cada punto p (n,3) al segmento a->b."""
    ab = b - a
    largo = float(ab @ ab)
    if largo < 1e-12:
        return np.linalg.norm(p - a, axis=1)
    t = np.clip(((p - a) @ ab) / largo, 0.0, 1.0)[:, None]
    return np.linalg.norm(p - (a + t * ab), axis=1)


def _callar_materiales():
    """El importador de NMSDK ABORTA la escena en el primer material roto.

    `realize_path` devuelve None cuando la textura no esta en disco y
    `create_material_node` hace un op.join con ese None: TypeError. La
    excepcion sube hasta `render_scene`, que la caza y para -"An exception
    ocurred while rendering"-, asi que las mallas que faltaban por anadir NO
    entran. Con el FreighterFiend no se noto, porque solo hay una y el fallo
    llega despues; con el BUGFIEND entraba SOLO FiendButt, 746 vertices de
    26583, y el zombie se pesaba contra el culo del bicho.

    Aqui no se usan los materiales para nada: se pesan vertices, grupos y
    huesos. Se anula la funcion y ya. Se parchea desde fuera, como en
    tools/Export-NMSMesh.py: el addon vive en AppData y se pierde al
    reinstalarlo.
    """
    import importlib
    modulo = importlib.import_module(
        "bl_ext.user_default.nmsdk.ModelImporter.import_scene")
    modulo.create_material_node = lambda *a, **k: None
    # Y las luces por lo mismo: en el FIEND, _add_light_to_scene busca un
    # nodo "Emission" que Blender 5.2 ya no crea y suelta un KeyError, que
    # es OTRA excepcion que aborta la escena entera. El nodo LIGHT va
    # despues de las mallas en el .SCENE del FIEND, asi que ahi no se
    # perdio ninguna, pero el orden depende del bicho y no se puede
    # confiar en el.
    modulo.ImportScene._add_light_to_scene = lambda self, *a, **k: None


bpy.ops.wm.open_mainfile(filepath=str(BLEND))
nuestra = bpy.data.objects[NUESTRA]

_callar_materiales()
bpy.ops.nmsdk.import_scene(path=str(VANILLA), clear_scene=False,
                           import_bones=True, import_collisions=False,
                           import_recursively=False)

# TODAS las mallas con piel del vanilla, no la primera. El FreighterFiend
# trae UNA -polySurface6- y por eso un next() basto para el SkrullCrawler.
# El BUGFIEND trae ocho y la primera es FiendButt: 746 vertices pegados a
# tail_C0_0 y tail_C0_1 y nada mas. Pesando contra ese trozo, el 86% de
# nuestro zombie colgaba de la cola y la caja del vanilla era la del culo,
# asi que hasta la escala salia mal -1,7486-. Al FIEND le pasa lo mismo con
# _Fiend_Body y SUB1_Fiend_Body, y ahi salia RootJNT con el 63,7%.
vanillas = [o for o in bpy.data.objects
            if o.type == "MESH" and o.vertex_groups and o is not nuestra]
assert vanillas, "el vanilla no trae ninguna malla con grupos de vertices"
armature = next(o for o in bpy.data.objects if o.type == "ARMATURE")
print(f"vanilla: {len(vanillas)} mallas con piel, "
      f"{sum(len(o.data.vertices) for o in vanillas)} vertices, "
      f"{len(armature.data.bones)} huesos")
for o in vanillas:
    print(f"    {o.name:<28} {len(o.data.vertices):>6} vertices")

# 1. La transformacion que lleva el espacio del vanilla al nuestro. Se
#    calcula con la MALLA del vanilla y despues se aplica a los HUESOS, que
#    es lo unico que se usa para pesar.
giro = (Matrix.Rotation(math.radians(GIRO_Z), 4, "Z")
        @ Matrix.Rotation(math.radians(90), 4, "X"))

# El orden de `vanillas` es el mismo aqui y donde se leen los pesos, que es
# lo que mantiene alineados `vv` y `pesos_vanilla` vertice a vertice.
vv = np.array([list(giro @ (o.matrix_world @ v.co))
               for o in vanillas for v in o.data.vertices])
lo_n, hi_n = caja_mundo(nuestra)
lo_v, hi_v = vv.min(axis=0), vv.max(axis=0)

# La escala sale de la ALTURA, no del eje mas apretado. Los dos bichos
# ocupan la misma plaza en el juego y de hecho ya miden casi lo mismo de
# alto -1.851 el nuestro contra 1.850 el vanilla-; lo que descuadra es el
# fondo, porque el vanilla arrastra una cola larga. Escalar por min() de
# las tres razones daba 0.847 y ENCOGIA el esqueleto: la distancia media de
# un vertice a su hueso se iba a 0.858 sobre una diagonal de 4.25, o sea que
# el rig se quedaba fuera de nuestra piel.
# Y con "altura" solo vale cuando los dos bichos MIDEN LO MISMO, que es el
# caso del SkrullCrawler -1.851 el nuestro contra 1.850 el vanilla, o sea
# escala 1.0005- y no el de los otros dos. El necromorfo se subio a proposito
# a 3,62 m porque a la altura del FIEND -1,81- "se veia enano" al lado de un
# bicho de 5 m de largo, y esa decision esta aprobada y no se toca.
#
# PERO EL PESADO NO PUEDE ESCALAR EL ESQUELETO PARA QUE QUEPA. Los JointBindings
# -las matrices de bind inversas- se copian del vanilla tal cual en
# Patch-NMSGraft.py, asi que EN EJECUCION nuestros vertices se leen en el
# espacio del vanilla, sin reescalar. Si aqui se hincha el rig x2 para que
# llene nuestra malla, cada vertice se casa con un hueso que en partida esta
# en otro sitio, y sale disparado. Medido el 27/08 con el necromorfo: con
# escala 2.0008 el rig hinchado mide 5,3 x 3,6 x 9,96, nuestra malla entera
# le cabe dentro del cuerpo y RootJNT se lleva el 63,7% contra el 20,4% del
# vanilla, con el vertice medio a 2,170 de su hueso sobre una diagonal de 4,97.
# Por eso escala_piel 1.0 en los dos modelos que no miden lo que el vanilla.
escala = (float((hi_n[1] - lo_n[1]) / (hi_v[1] - lo_v[1]))
          if ESCALA_PIEL == "altura" else float(ESCALA_PIEL))

# Y se apoyan los PIES en el suelo, no los centros de las cajas: los dos
# bichos andan por el suelo, y la cola del vanilla desplaza su centro.
desplaza = np.array([
    (lo_n[0] + hi_n[0]) / 2 - escala * (lo_v[0] + hi_v[0]) / 2,
    lo_n[1] - escala * lo_v[1],
    (lo_n[2] + hi_n[2]) / 2 - escala * (lo_v[2] + hi_v[2]) / 2,
])

a_local = np.array(nuestra.matrix_world.inverted().to_4x4())


def al_espacio_nuestro(punto):
    p = np.array(list(giro @ (armature.matrix_world @ punto)))
    p = escala * p + desplaza
    return (a_local @ np.append(p, 1.0))[:3]


huesos = [(h.name, al_espacio_nuestro(h.head_local),
           al_espacio_nuestro(h.tail_local)) for h in armature.data.bones]
print(f"escala {escala:.4f} ({ESCALA_PIEL}), {len(huesos)} huesos "
      f"llevados a nuestro espacio")

# 2. Cada vertice copia los pesos de los VECINOS de la piel vanilla.
#
#    Los dos metodos anteriores fallaron IGUAL, y el sintoma se escribio
#    las dos veces con las mismas palabras: "laminas planas tensadas".
#
#      PRUEBA12  transferencia por superficie (POLYINTERP_NEAREST): las
#                dos puntas de las patas delanteras se llevaron el 82%.
#      PRUEBA14  hueso mas cercano al SEGMENTO: LFirstLeg3JNT se llevo el
#                12,1% y RFirstLeg3JNT el 0,0%.
#
#    Y la causa es la misma: adjudicar a UN ganador entre huesos que
#    estan casi a la misma distancia. El FreighterFiend es una arana de
#    patas largas y cuerpo pequeno, las suyas barren el volumen de
#    nuestro cuerpo, y una franja entera del torso se va con una pata
#    mientras la de al lado se queda con la espalda. Al andar, la costura
#    entre las dos se estira: eso es la lamina.
#
#    Se descarto medir la DISTANCIA del vertice a su hueso, y ahora con
#    numero: el vanilla contra su propio esqueleto da media 1,039 sobre
#    una diagonal de 4,22, y los dos metodos malos dan 0,903 y 1,092. No
#    separa nada.
#
#    Lo que si separa es la SIMETRIA, y sale gratis: el reparto del
#    vanilla esta pareado al vertice -RFirstLeg3JNT y LFirstLeg3JNT
#    tienen 260 cada uno- y los dos fallos lo rompen de par en par. Se
#    mide abajo, contra el propio vanilla y no contra un numero a ojo.
#
#    Promediar VECINOS en vez de coger uno quita el ganador unico: la
#    frontera pasa a ser un degradado y no una costura.
paleta = paleta_vanilla()
candidatos = [h for h in huesos if h[0] in paleta]
assert candidatos, f"ninguno de los {len(huesos)} huesos esta en la paleta"
print(f"la piel del vanilla se pega a {len(paleta)} huesos; "
      f"de los {len(huesos)} del esqueleto casan {len(candidatos)}")

puntos = np.array([list(v.co) for v in nuestra.data.vertices],
                  dtype=np.float64)

# Los pesos que NMSDK ya importo en la malla vanilla, filtrados a la
# paleta y llevados a nuestro espacio. NMSDK importa pesos aunque no los
# exporte: el muro es solo de salida.
pesos_vanilla = []
for o in vanillas:
    nombre_grupo = {g.index: g.name for g in o.vertex_groups}
    for v in o.data.vertices:
        pares = [(nombre_grupo[e.group], e.weight) for e in v.groups
                 if nombre_grupo[e.group] in paleta and e.weight > 0]
        pesos_vanilla.append(pares)
vv_nuestro = np.array([(a_local @ np.append(escala * p + desplaza, 1.0))[:3]
                       for p in vv])
util = np.array([bool(p) for p in pesos_vanilla])
assert util.any(), "la malla vanilla no trae pesos de la paleta"
vv_nuestro, pesos_vanilla = vv_nuestro[util], [p for p, u
                                               in zip(pesos_vanilla, util) if u]
print(f"piel vanilla util: {len(pesos_vanilla)} vertices con peso")

if "--volcar-huesos" in sys.argv:
    # DONDE VIVE LA PIEL DE CADA HUESO dentro de NUESTRA caja, en 0..1. Es lo
    # unico que hace falta para escribir a mano el mapa region -> hueso.
    #
    # Se mide sobre la PIEL y no sobre el esqueleto a proposito: `huesos` sale
    # de `armature.matrix_world` y `vv` de `vanilla.matrix_world`, y NMSDK NO
    # las deja alineadas —volcando los huesos del FIEND sale una lamina plana
    # pegada al suelo y a la cara de delante, y no puede ser—. La de la malla
    # es la que esta verificada: es la que casa el pesado, y da 0,578 sobre
    # una diagonal de 3,05 en el zombie. El pesado nunca uso la posicion de
    # los huesos, asi que ese desajuste no lo rompio; rompia el diagnostico.
    _co = np.array([list(v.co) for v in nuestra.data.vertices])
    _lo, _hi = _co.min(axis=0), _co.max(axis=0)
    _tam = np.maximum(_hi - _lo, 1e-9)
    _por_hueso = {}
    for _p, _pares in zip(vv_nuestro, pesos_vanilla):
        _por_hueso.setdefault(max(_pares, key=lambda t: t[1])[0], []).append(_p)
    print(f"\ncaja local de nuestra malla: {_lo.round(3)} .. {_hi.round(3)}")
    print(f"{'hueso':<24} {'vert':>6} {'x':>6} {'y':>6} {'z':>6}"
          f"   0 = izquierda / abajo / atras")
    for _n, _ps in sorted(_por_hueso.items(),
                          key=lambda t: -np.mean(t[1], axis=0)[1]):
        _u = (np.mean(_ps, axis=0) - _lo) / _tam
        print(f"{_n:<24} {len(_ps):6d} {_u[0]:6.2f} {_u[1]:6.2f} {_u[2]:6.2f}")
    sys.exit(0)

crudo = []
if M.get("regiones"):
    # EL MAPA A MANO. Copiar del vecino mas cercano vale cuando los dos
    # bichos son el mismo tipo de animal; con un BIPEDO montado en una arana
    # no, y el volcado de --volcar-huesos dice por que: la piel del vanilla
    # cabe entera en la mitad de abajo de nuestra malla, asi que nuestros
    # brazos y nuestra cabeza no tienen NADA cerca salvo cuerpo. Por eso el
    # 79,5% y el 80,1% en un solo hueso.
    #
    # Aqui se dice a mano que region nuestra cuelga de que hueso. Las
    # fronteras salen duras y las deshace el suavizado de 2b, que es
    # exactamente para lo que estaba: un salto de peso entre dos vertices
    # unidos por una arista es lo que tensa una lamina.
    lo_p, hi_p = puntos.min(axis=0), puntos.max(axis=0)
    tam_p = np.maximum(hi_p - lo_p, 1e-9)
    fuera = [h for h, _ in M["regiones"] if h not in paleta]
    assert not fuera, (
        f"el mapa de regiones nombra huesos a los que el vanilla NO pega "
        f"piel: {fuera}. Tienen que estar en el SkinMatrixLayout, o son "
        f"astillas: es el fallo de la PRUEBA14")
    cuenta = {}
    for p in puntos:
        u, v, w = (p - lo_p) / tam_p
        for hueso, dentro in M["regiones"]:
            if dentro(u, v, w):
                crudo.append({hueso: 1.0})
                cuenta[hueso] = cuenta.get(hueso, 0) + 1
                break
    print("\nmapa a mano region -> hueso:")
    for hueso, _ in M["regiones"]:
        n = cuenta.get(hueso, 0)
        print(f"  {hueso:<20} {n:6d}  {n / len(puntos) * 100:5.1f}%")
else:
    for i in range(0, len(puntos), BLOQUE_VECINOS):
        trozo = puntos[i:i + BLOQUE_VECINOS]
        d = np.linalg.norm(trozo[:, None, :] - vv_nuestro[None, :, :], axis=2)
        cerca = np.argsort(d, axis=1)[:, :VECINOS]
        for fila, vecinos in enumerate(cerca):
            # Peso inverso a la distancia: el vecino pegado manda, el de
            # lejos solo suaviza. El epsilon evita dividir por cero cuando
            # un vertice nuestro cae encima de uno del vanilla.
            acumulado = {}
            for k in vecinos:
                factor = 1.0 / (d[fila, k] + 1e-6)
                for nombre, w in pesos_vanilla[k]:
                    acumulado[nombre] = acumulado.get(nombre, 0.0) + w * factor
            total = sum(acumulado.values())
            crudo.append({n: w / total for n, w in acumulado.items()})

# 2b. Suavizar sobre NUESTRAS aristas, que es donde se ve el fallo.
#
#     Copiar del vanilla deja la trasera de nuestro cuerpo colgando de
#     las patas traseras del vanilla -LFourthLeg3JNT se llevaba el 14,9%
#     y RFourthLeg3JNT el 14,0%, contra el 3,4% que les da el vanilla a
#     las suyas-, porque ahi, en el espacio, no hay otra cosa del vanilla
#     que copiar: sus patas atraviesan nuestro volumen.
#
#     Ninguna medida espacial puede deshacer eso. Lo que si lo deshace es
#     la TOPOLOGIA nuestra: esa trasera es cuerpo, esta cosida al torso,
#     y sus vecinas cuelgan de RootJNT. Promediar por aristas la arrastra
#     de vuelta. Y ataca el fallo de frente, porque una lamina tensada ES
#     un salto de peso entre dos vertices unidos por una arista.
vecinas = [[] for _ in range(len(puntos))]
for a in nuestra.data.edges:
    i, j = a.vertices
    vecinas[i].append(j)
    vecinas[j].append(i)

for _ in range(SUAVIZADOS):
    siguiente = []
    for i, propio in enumerate(crudo):
        mezcla = dict(propio)
        for j in vecinas[i]:
            for n, w in crudo[j].items():
                mezcla[n] = mezcla.get(n, 0.0) + w
        total = sum(mezcla.values())
        siguiente.append({n: w / total for n, w in mezcla.items()})
    crudo = siguiente

salida = []
for i, pesos in enumerate(crudo):
    pares = sorted(pesos.items(), key=lambda t: -t[1])[:2]
    total = sum(w for _, w in pares)
    pares = [(n, round(float(w / total), 6)) for n, w in pares]
    # Redondear a seis decimales puede dejar la suma en 0.999999, y el
    # assert de mas abajo pide 1 con 1e-4. Se cuadra en el mayor.
    pares[0] = (pares[0][0],
                round(pares[0][1] + 1.0 - sum(w for _, w in pares), 6))
    co = nuestra.data.vertices[i].co
    salida.append([round(co.x, 6), round(co.y, 6), round(co.z, 6),
                   [list(t) for t in pares]])

# 3. Dejar los grupos puestos en el .blend, para poder mirarlo a mano.
for g in list(nuestra.vertex_groups):
    nuestra.vertex_groups.remove(g)
grupos = {}
for i, e in enumerate(salida):
    for nombre, w in e[3]:
        if nombre not in grupos:
            grupos[nombre] = nuestra.vertex_groups.new(name=nombre)
        grupos[nombre].add([i], w, "REPLACE")

# --- lo que puede fallar, y falla aqui y no en el juego ---
dominante = [max(e[3], key=lambda t: t[1])[0] for e in salida]
reparto = {}
for g in dominante:
    reparto[g] = reparto.get(g, 0) + 1

tam = puntos.max(axis=0) - puntos.min(axis=0)
asignaciones = sum(len(e[3]) for e in salida)
print(f"\nvertices con peso: {len(salida)} de {len(nuestra.data.vertices)}")
print(f"asignaciones: {asignaciones}  "
      f"({asignaciones / len(salida):.2f} por vertice)")
print(f"huesos con peso: {len(set(g for e in salida for g, _ in e[3]))}")
print(f"la malla mide {tam[0]:.2f} / {tam[1]:.2f} / {tam[2]:.2f}\n")
print(f"{'hueso':22} {'vert':>5} {'%':>6}   caja")
for g, n in sorted(reparto.items(), key=lambda t: -t[1])[:12]:
    c = puntos[np.array(dominante) == g]
    d = c.max(axis=0) - c.min(axis=0)
    print(f"{g:22} {n:5} {n / len(salida) * 100:5.1f}%   "
          f"{d[0]:.2f} / {d[1]:.2f} / {d[2]:.2f}")

# Informativo, no assert: se midio y NO sirve para decidir. Ver la nota de
# arriba. Se imprime porque un salto grande entre corridas si querria decir
# que la alineacion se ha movido.
segmento = {n: (a, b) for n, a, b in candidatos}
lejos = np.array([dist_a_segmento(puntos[i:i + 1], *segmento[dominante[i]])[0]
                  for i in range(len(puntos))])
print(f"\ndistancia de cada vertice a SU hueso: media {lejos.mean():.3f}, "
      f"maxima {lejos.max():.3f}, diagonal del bicho "
      f"{float(np.linalg.norm(tam)):.2f}")

assert len(salida) == len(nuestra.data.vertices), (
    f"{len(salida)} pesos para {len(nuestra.data.vertices)} vertices")
assert all(e[3] for e in salida), "hay vertices sin peso"
assert max(len(e[3]) for e in salida) <= 2, "algun vertice cuelga de 3+"
for i, e in enumerate(salida):
    total = sum(p for _, p in e[3])
    assert abs(total - 1.0) < 1e-4, f"vertice {i} suma {total}"

# La referencia: lo que el vanilla hace con su PROPIA piel, medido aqui
# mismo para no dejar constantes a ojo en el guion.
ref = reparto_de([max(p, key=lambda t: t[1])[0] for p in pesos_vanilla])
nuestro = {g: n / len(salida) for g, n in reparto.items()}
ref_peor = max(ref.values())
ref_asim = asimetria(ref, M["espejo"], paleta)
print(f"\nel vanilla con su propia piel: mayor {ref_peor * 100:.1f}% "
      f"({max(ref, key=ref.get)}), asimetria {ref_asim:.3f}")

# El tope del hueso mas cargado. Contra el vanilla SOLO vale cuando los dos
# bichos son la misma clase de animal: el SkrullCrawler y el FreighterFiend
# son los dos aranas y ahi 43,5% contra 45,9% se leen igual. El necromorfo y
# el zombie son BIPEDOS montados en una arana, y un bipedo cuelga casi entero
# de la columna mientras que a una arana la masa se le va a la cabeza y a las
# ocho patas: el FIEND pone su maximo en RootJNT con el 20,4% y el ARTHROPOD
# en head_C0_0_jnt con el 31,4%, o sea que el tope relativo no lo puede pasar
# NINGUN pesado de un bipedo, ni el bueno.
#
# Por eso esos dos llevan tope ABSOLUTO. Y no queda sin guarda: los tres
# asserts que de verdad cazaron los fallos del 15/08 -tronco minimo, tope de
# punta y simetria- siguen midiendo contra el vanilla y siguen abajo.
peor, cuantos = max(reparto.items(), key=lambda t: t[1])
fraccion = cuantos / len(salida)
limite = TOPE_REPARTO if TOPE_REPARTO else ref_peor * HOLGURA_REPARTO
assert fraccion < limite, (
    f"{peor} se lleva {fraccion * 100:.1f}% de la malla y el tope es "
    f"{limite * 100:.1f}% (el vanilla no pasa del {ref_peor * 100:.1f}%). "
    f"Es el fallo del 15/08: un hueso dueño de medio bicho")

asim = asimetria(nuestro, M["espejo"], paleta)
print(f"nuestra asimetria {asim:.3f} contra {ref_asim:.3f} del vanilla")
assert asim - ref_asim < TOPE_ASIMETRIA, (
    f"el reparto sale desparejado: asimetria {asim:.3f} contra {ref_asim:.3f} "
    f"del vanilla. Los dos bichos son simetricos, asi que un lado que se "
    f"lleva lo del otro es la firma de PRUEBA12 y PRUEBA14, y en el juego "
    f"son las laminas planas tensadas")
tronco = sum(n for g, n in reparto.items()
             if any(t in g for t in M["tronco"])) / len(salida)
assert tronco >= MINIMO_TRONCO, (
    f"la raiz y la espalda solo se llevan {tronco * 100:.1f}% de la malla. "
    f"El cuerpo tiene que colgar de la columna; el 15/08 colgaba de las "
    f"puntas de las patas y RootJNT tenia 17 vertices")

if M.get("regiones"):
    # Con mapa a mano, EL TOPE DE PUNTA NO APLICA y se sustituye por una
    # guarda mas fuerte. El tope de punta mide una anatomia -"el cuerpo no
    # cuelga de la punta de una pata"- que el mapa ya dice al reves a
    # proposito: nuestras piernas SI cuelgan de las patas traseras del
    # vanilla, que es justo lo que se queria. Lo que hay que comprobar
    # entonces es otra cosa: que el resultado se PAREZCA al mapa, o sea que
    # el suavizado no se haya comido una region entera.
    #
    # No queda mas flojo. El fallo del 15/08 era una punta con el 43,2% y el
    # tronco al 0,4%; una desviacion asi contra el mapa son 40 puntos y esto
    # corta en 5.
    DERIVA = 0.05
    for hueso, _ in M["regiones"]:
        pedido = cuenta.get(hueso, 0) / len(puntos)
        salido = reparto.get(hueso, 0) / len(salida)
        assert abs(salido - pedido) < DERIVA, (
            f"{hueso}: el mapa le daba {pedido * 100:.1f}% y sale con "
            f"{salido * 100:.1f}%. El suavizado se ha comido la region, o el "
            f"mapa nombra un hueso que no esta donde dice el volcado de "
            f"--volcar-huesos")
    print(f"el reparto no se separa mas de {DERIVA * 100:.0f} puntos del mapa")
else:
    for g, n in reparto.items():
        if not any(t in g for t in M["puntas"]):
            continue
        assert n / len(salida) < tronco * TOPE_PUNTA, (
            f"{g} es una punta de miembro y se lleva "
            f"{n / len(salida) * 100:.1f}% de la malla, contra el "
            f"{tronco * 100:.1f}% del tronco. Asi empezo el fallo del 15/08: "
            f"RFirstLeg3JNT con 43.2% y RootJNT con 0.4%")

# La orientacion. El GIRO_Z no es solo delante/detras: giro = Rz @ Rx, y el
# Rx(90) deja al bicho boca abajo -la Z de arriba del vanilla va a -Y-, asi
# que es el Rz(180) el que lo pone de pie. Con GIRO_Z 0 el esqueleto queda
# invertido y los huesos de la cabeza caen a la altura de nuestros pies.
#
# El assert de antes comparaba contra 0 y NO PODIA FALLAR: nuestra malla va
# de -0.02 a +1.83, asi que la media de cualquier trozo sale positiva. Ahora
# se compara contra la altura del bicho, que es lo que de verdad distingue
# la cabeza arriba de la cabeza abajo.
# Se mide sobre los HUESOS ya transformados, no sobre nuestros vertices: lo
# que puede estar del reves es el esqueleto, y nuestra malla no cambia con
# el GIRO_Z. Medirlo en la malla era ademas un assert que no podia fallar.
# Y se mide con el TRONCO, no con la cabeza. Medido el 27/08 sobre el
# SPIDERRIG, que es el mismo esqueleto en el FIEND y en el FreighterFiend:
# NewHeadJNT cae a la MISMA altura que la media de las puntas de las patas
# -0,000 contra 0,000- porque estos bichos llevan la cabeza a ras de suelo.
# El assert pasaba por centesimas en el SkrullCrawler y fallaba por 3 cm en
# el necromorfo, o sea que era una moneda al aire y no una comprobacion.
# RootJNT si separa: esta a +0,341 sobre las puntas, once veces mas margen,
# y boca abajo se iria a -0,341. La cabeza se sigue imprimiendo, para leerla.
altura = {n: (a[1] + b[1]) / 2 for n, a, b in huesos}
cabeza = [y for n, y in altura.items() if any(t in n for t in M["cabeza"])]
arriba = [y for n, y in altura.items() if any(t in n for t in M["tronco"])]
abajo = [y for n, y in altura.items() if any(t in n for t in M["pies"])]
assert arriba and abajo, f'no encuentro huesos de {M["tronco"]} y {M["pies"]}'
media_cabeza = sum(cabeza) / len(cabeza) if cabeza else float("nan")
print(f"esqueleto: tronco a Y {sum(arriba) / len(arriba):+.3f}, "
      f"pies a Y {sum(abajo) / len(abajo):+.3f}, "
      f"cabeza a Y {media_cabeza:+.3f}")
assert sum(arriba) / len(arriba) > sum(abajo) / len(abajo), (
    f"el tronco del esqueleto queda POR DEBAJO de las puntas de las patas: "
    f"con GIRO_Z {GIRO_Z} esta boca abajo. El giro no es solo "
    f"delante/detras, es el que lo pone de pie")

SALIDA.write_text(json.dumps(salida), encoding="utf-8")
print(f"escrito {SALIDA}")

for o in vanillas:
    bpy.data.objects.remove(o, do_unlink=True)
bpy.data.objects.remove(armature, do_unlink=True)
bpy.ops.wm.save_as_mainfile(filepath=str(BLEND))
print(f"guardado {BLEND}")
