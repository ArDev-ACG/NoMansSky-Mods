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
    # LOS DOS DE LA SEGUNDA HORNADA, Y LO QUE LOS DEFINE ES LO QUE NO LLEVAN.
    #
    # Ni `regiones`, ni `agarre`, ni `giros`, ni `objetivo`, ni `alfas_fijos`.
    # Toda esa maquinaria -ocho pruebas del necromorfo y diez del zombie- se
    # monto para UNA sola cosa: sostener un BIPEDO sobre un esqueleto de
    # arana. La piel del vanilla cabia entera en la mitad de abajo de la
    # malla, asi que nuestros brazos y nuestra cabeza no tenian cerca mas que
    # cuerpo, y por eso el vecino mas cercano daba un solo hueso con el 79,5%.
    #
    # Estos dos son del MISMO TIPO DE ANIMAL que su vanilla -un insecto de
    # cuatro patas sobre un artropodo de seis, y un cuadrupedo de cuello
    # largo sobre un cuadrupedo bajo-, que es la condicion exacta que la
    # receta pone para que copiar del vecino mas cercano valga. Es lo mismo
    # que hizo el SkrullCrawler, que es una arana puesta sobre una arana y
    # salio a la primera.
    #
    # `sin_claves` SI se queda: es una propiedad del esqueleto vanilla, no
    # del bicho que le pongas encima, y ya esta medida en los `.ANIM`.
    "warriorbug": dict(
        blend=RAIZ / "BLENDER" / "proyectos" / "warriorbug_nms.blend",
        vanilla=(RAIZ / "work" / "models" / "vanilla_bugfiend" / "models"
                 / "planets" / "creatures" / "arthropod"
                 / "bugfiend.scene.mbin"),
        salida=RAIZ / "work" / "models" / "warriorbugmesh" / "pesos.json",
        objeto="ArthropodThorax",
        giro_z=180,
        puntas=("_end_jnt",),
        cabeza=("head_",),
        pies=("_end_jnt",),
        tronco=("root_", "spine_", "tail_"),
        espejo=("_L", "_R"),
        # 1.0 y no "altura", por el acuerdo B3: los JointBindings se copian
        # del vanilla TAL CUAL en Patch-NMSGraft.py, asi que en partida el
        # juego lee nuestros vertices en el espacio del vanilla sin reescalar
        # nada. Casar contra un rig hinchado es casar contra huesos que en
        # partida estan en otro sitio. Y aqui hinchar seria x2,9: nuestra
        # malla mide 2,430 y el ArthropodThorax vanilla 0,84.
        escala_piel=1.0,
        # Absoluto, como el zombie y el necromorfo, y por una razon distinta
        # de la suya: no es que sea un bipedo, es que el ARTHROPOD reparte su
        # masa entre SEIS patas y una cabeza -su maximo es head_C0_0_jnt con
        # el 31,4%- y el warrior bug tiene CUATRO patas y un torax gordo. El
        # relativo mide una anatomia que este bicho no tiene.
        tope_reparto=0.85,
        # EL MAPA A MANO, y hace falta aunque los dos sean artropodos.
        #
        # Se probo primero sin el, que era la apuesta: mismo tipo de animal,
        # luego vale el vecino mas cercano. No valio, y la causa esta medida:
        # el ARTHROPOD ocupa DENTRO DE NUESTRA CAJA de w -0,05 a 0,84 y de
        # v 0,08 a 0,70, o sea que su cabeza cae por delante de la nuestra y
        # el torax se come el resto. Sin mapa, `spine_C0_0_jnt` se llevaba el
        # 43,0% con la altura vieja y el 53,1% con la nueva.
        #
        # Los cortes salen del histograma de NUESTRA malla, no de suponer.
        # Con v < 0,45 -la parte baja, 23% de los vertices- el eje w tiene
        # DOS jorobas, que son los dos pares de patas:
        #     w 0,2-0,4  1353 vertices   patas traseras
        #     w 0,5-0,7  2107 vertices   patas delanteras
        # y la parte alta -v > 0,75, 13%- cae en w 0,62, que son las
        # mandibulas y las antenas.
        #
        # El ARTHROPOD tiene TRES pares de patas y el bug DOS: se usan el par
        # 0 -delantero, w 0,74- y el par 2 -trasero, w 0,43-, y el par 1 se
        # queda sin usar. El eslabon es `leg_*_0_jnt`, el primero CON CLAVES;
        # `legbase_*` esta en la paleta y no tiene ni una, que fue la
        # PRUEBA05 del zombie.
        #
        # Gana la PRIMERA fila que case, asi que van de arriba abajo.
        #
        # ESPEJADOS PARA LA PRUEBA02, y no es un retoque: es la MISMA linea
        # de arriba con `u -> 1-u` y `w -> 1-w`. El giro de la malla paso de
        # 0 a 180 en Export-NMSMesh.py, y 180 en Y espeja justo esos dos ejes
        # de la caja; los cortes de abajo estan en coordenadas de la caja, no
        # del bicho, asi que sin espejarlos senalan al reves. Medido: con los
        # cortes viejos sobre la malla girada, `spine_C0_0_jnt` pasaba a
        # mandar el 92,2% -tope 85- porque la region de la cabeza cazaba la
        # punta del abdomen, 759 vertices en vez de los 2400 de la cabeza.
        regiones=(
            ("head_C0_0_jnt",  lambda u, v, w: v > 0.70 and w < 0.45),
            ("leg_L0_0_jnt",   lambda u, v, w: v < 0.45 and w < 0.55 and u < 0.45),
            ("leg_R0_0_jnt",   lambda u, v, w: v < 0.45 and w < 0.55 and u > 0.55),
            ("leg_L2_0_jnt",   lambda u, v, w: v < 0.45 and u < 0.45),
            ("leg_R2_0_jnt",   lambda u, v, w: v < 0.45 and u > 0.55),
            ("spine_C0_0_jnt", lambda u, v, w: w < 0.55),
            ("tail_C0_0_jnt",  lambda u, v, w: True),
        ),
        # EL AGARRE, Y HACE FALTA AUNQUE LA ANATOMIA CASE.
        #
        # Se entrego primero sin el -mapa duro, alfa 1,0- y `Pose-NMSMesh.py`
        # lo midio antes de construir, que es justo para lo que esta:
        #     walk    tension 55,1   abre 25 cm
        #     run     tension 81,9   abre 39 cm
        #     attack  tension 117,4  abre 62 cm
        # contra los 11,5 / 17,0 / 13,0 del zombie ya aceptado. El mapa duro
        # es la PRUEBA06, la de las cuchillas, y lo sigue siendo aqui.
        #
        # Las patas se agarran al abdomen y a el torax segun de cual cuelgan,
        # y la cabeza al torax.
        agarre={
            "leg_L0_0_jnt":   "spine_C0_0_jnt",
            "leg_R0_0_jnt":   "spine_C0_0_jnt",
            "head_C0_0_jnt":  "spine_C0_0_jnt",
            "leg_L2_0_jnt":   "tail_C0_0_jnt",
            "leg_R2_0_jnt":   "tail_C0_0_jnt",
            "tail_C0_0_jnt":  "spine_C0_0_jnt",
        },
        giros=RAIZ / "work" / "models" / "warriorbugmesh" / "giros.json",
        clips=("arthropodwalk.anim", "arthropodrun.anim"),
        clips_tope=("arthropodwalk.anim", "arthropodrun.anim",
                    "arthropodidle.anim", "arthropodattack01.anim"),
        # El ARTHROPOD es simetrico -al andar sus dos patas giran 17,9 y
        # 17,8- y nuestro reparto tambien lo es -asimetria 0,000-, asi que
        # aqui no hay diferencia entre lados que igualar. Lo que sobra es el
        # vaiven ABSOLUTO, y eso lo corta el tope.
        espejo_vaiven=False,
        # 300 Y NO 120, Y NO ES UN NUMERO NUEVO: ES EL MISMO. El vaiven es
        # giro x PALANCA, y la palanca es la distancia de la region al pivote
        # del hueso PARTIDA POR el tamano de la region; el esqueleto no
        # escala con nosotros, asi que subir la malla de 1,80 a 2,70 sube la
        # palanca MAS de lo que sube el bicho -la cabeza pasa de 4,4x a 5,4x-.
        #
        # ESTE NUMERO SE VUELVE A MEDIR CADA VEZ QUE CAMBIA `alto`, y sale de
        # la columna `todos` de la propia corrida: es una VENTANA, no un
        # numero. A 2,70 la cabeza conserva su hueso por encima de 195 -su
        # vaiven peor es 391- y las patas delanteras se sueltan del torax por
        # encima de 316 -633-. 300 cae dentro y devuelve el reparto de la
        # PRUEBA01, que es el criterio: el tope bueno es el que reproduce el
        # reparto de la entrega que ya se vio bien.
        #
        # Con el tope quieto en 120 y la malla a 3,60 -la PRUEBA02- el agarre
        # de la cabeza subia a 76% y `spine_C0_0_jnt` mandaba el 90,1% contra
        # un tope de 85: agrandar el bicho sin tocar esto lo deja TIESO y
        # ademas rompe el assert.
        objetivo=300.0,
        # EL TOPE NO LLEGA AL ABDOMEN, Y ES QUIEN MANDA LA COSTURA.
        #
        # Con solo el agarre y el tope de 120, `Pose-NMSMesh.py` bajo el bug
        # de 55,1/81,9/117,4 a 47,6/54,4/74,7, pero el hueso que manda paso a
        # ser `tail_C0_0_jnt`: 5154 vertices, el 28,5% de la malla, con
        # vaiven 8 -o sea MUY por debajo del tope, que no lo ve-. Lo que abre
        # no es su giro sino el SALTO contra `spine_C0_0_jnt` en la frontera
        # w 0,45, que parte el cuerpo del bicho en dos.
        #
        # Es el mismo caso que las piernas del zombie en la PRUEBA10: el tope
        # por vaiven no las trataba, y se arreglo con alfa fijo. Aqui el
        # abdomen y las patas traseras van al mismo 0,4.
        alfas_fijos={
            "tail_C0_0_jnt": 0.4,
            "leg_L2_0_jnt": 0.4,
            "leg_R2_0_jnt": 0.4,
        },
        sin_claves=("legbase_L0_0_jnt", "legbase_L1_0_jnt", "legbase_L2_0_jnt",
                    "legbase_R0_0_jnt", "legbase_R1_0_jnt", "legbase_R2_0_jnt"),
    ),
    "crywolf": dict(
        blend=RAIZ / "BLENDER" / "proyectos" / "crywolf_nms.blend",
        vanilla=(RAIZ / "work" / "models" / "vanilla_fiend" / "models"
                 / "planets" / "creatures" / "spiderrig" / "fiend.scene.mbin"),
        salida=RAIZ / "work" / "models" / "crywolfmesh" / "pesos.json",
        objeto="_Fiend_Body",
        giro_z=180,
        puntas=("Leg3", "Leg4", "END"),
        cabeza=("Head", "Jaw", "Skull"),
        pies=("Leg4END", "Leg3END"),
        tronco=("Root", "Back"),
        espejo=("L", "R"),
        escala_piel=1.0,
        tope_reparto=0.85,
        # EL MAPA A MANO, y la razon aqui es la PROPORCION, no la anatomia.
        #
        # El FIEND y el cry wolf son los dos cuadrupedos, que era la apuesta.
        # Lo que no casa es la forma: medido en el volcado, el FIEND ocupa
        # DENTRO DE NUESTRA CAJA de w -0,47 a 1,64, o sea 4,4 m de largo por
        # 1,2 de alto -3,5 a 1-, y el cry wolf es 1,1 a 1. Sus patas
        # delanteras -w 1,08- y su cabeza -w 1,51- caen POR DELANTE de
        # nuestra malla, asi que el vecino mas cercano solo alcanza el
        # tronco: `RootJNT` se llevaba el 62,8%.
        #
        # Los cortes salen del histograma de NUESTRA malla. El eje w es
        # bimodal y las dos jorobas son el cuerpo y el cuello:
        #     w 0,2-0,5   4650 vertices   cuerpo, con las cuatro patas
        #     w 0,9-1,0   3174 vertices   cuello y cabeza, el 34% de la malla
        # y en la parte baja -v < 0,45, 29%- las patas delanteras salen en
        # w 0,3-0,5 y las traseras en w 0,0-0,25.
        #
        # El eslabon es `*Leg1JNT`, el primero de la cadena Y el primero con
        # claves: los cuatro `*Leg1JNT` del SPIDERRIG tienen claves en todos
        # los `.ANIM`, medido el 29/08.
        #
        # ESPEJADOS PARA LA PRUEBA02, por lo mismo que el bug: `u -> 1-u` y
        # `w -> 1-w`, que es lo que el giro de 180 le hace a la caja.
        # LOS CORTES SE RE-MIDEN EN LA PRUEBA05, porque el cuello se re-poso y
        # el mapa va en coordenadas NORMALIZADAS: no cambia con la escala,
        # pero si con la FORMA. Doblado el cuello 30 grados, la caja pasa de
        # 1,356 x 2,85 x 3,102 a 1,199 x 2,85 x 2,292 y el bicho se hace mas
        # compacto. Secciones nuevas a lo largo de w, medidas el 04/09:
        #     w 0,00-0,15  3094 vert  y 0,81..0,98  ancho 0,31-0,44  CABEZA
        #     w 0,15-0,35   645 vert  y 0,90 -> 0,47  ancho 0,28-0,36  CUELLO
        #     w 0,35-0,40   655 vert  el ancho salta a 0,64 y 0,99     HOMBROS
        #     w 0,40-0,70  4056 vert  ancho ~0,96                      TRONCO
        #     w 0,75-1,00   925 vert  ancho 0,54-0,78              GRUPA Y COLA
        # o sea que el arranque del cuello baja de w 0,45 a w 0,35, que es
        # donde el ancho en x salta de 0,36 a 0,64.
        regiones=(
            ("NewHeadJNT",     lambda u, v, w: v > 0.72 and w < 0.35),
            ("NewBack1JNT",    lambda u, v, w: w < 0.35),
            ("LFirstLeg1JNT",  lambda u, v, w: v < 0.45 and w < 0.62 and u < 0.45),
            ("RFirstLeg1JNT",  lambda u, v, w: v < 0.45 and w < 0.62 and u > 0.55),
            ("LFourthLeg1JNT", lambda u, v, w: v < 0.45 and u < 0.45),
            ("RFourthLeg1JNT", lambda u, v, w: v < 0.45 and u > 0.55),
            ("RootJNT",        lambda u, v, w: True),
        ),
        # EL AGARRE. Medido igual que en el bug, con el mapa duro puesto:
        #     walk    tension 71,8   abre 61 cm
        #     run     tension 55,6   abre 67 cm
        #     attack  tension 64,9   abre 57 cm
        # y las tres las manda `*FirstLeg1JNT`, o sea las patas delanteras,
        # que es de donde cuelga el pecho justo debajo del cuello largo.
        #
        # Las delanteras y la cabeza se agarran al pecho; las traseras, a la
        # cadera.
        agarre={
            "LFirstLeg1JNT":  "NewBack1JNT",
            "RFirstLeg1JNT":  "NewBack1JNT",
            "NewHeadJNT":     "NewBack1JNT",
            "LFourthLeg1JNT": "RootJNT",
            "RFourthLeg1JNT": "RootJNT",
            # EL ANCLA TAMBIEN NECESITA AGARRE, igual que `tail_C0_0_jnt`
            # en el zombie desde la PRUEBA09: `alfas_de` SOLO recorre las
            # regiones que lo tienen, asi que sin esta linea `NewBack1JNT`
            # -que es el CUELLO- no lo topa nadie. Medido el 03/09 con el
            # tope leyendo los seis clips: se quedaba en vaiven 279 contra
            # el objetivo de 170, y es el hueso que `Pose-NMSMesh.py` culpa
            # en los NUEVE clips. Era el "partir NewBack1JNT" que la firma
            # de la PRUEBA03 dejo escrito, y sale mas barato: no hace falta
            # partir la region, hace falta que la region tenga ancla.
            "NewBack1JNT":    "RootJNT",
        },
        giros=RAIZ / "work" / "models" / "crywolfmesh" / "giros.json",
        clips=("fiendwalk.anim", "fiendrun.anim"),
        # EL TOPE LEE TAMBIEN `roar` Y `pounce` DESDE LA PRUEBA04, y no es
        # un clip mas: `roar` es el PEOR de los nueve. Medido el 03/09 con
        # Pose-NMSMesh sobre la PRUEBA03 ya desplegada -tension por clip-:
        #     roar 36,4   run 28,2   pounce 26,8   attack 26,2   walk 25,8
        #     idle 15,7   trot 8,2   attack2 8,9   attack3 7,6
        # y en `roar` el giro de mundo de `RootJNT` pasa de 6,3 -que es lo
        # que veia el tope- a 44,2, o sea SIETE VECES. `NewBack1JNT` va de
        # 6,3 a 49,4 y `NewHeadJNT` de 2,9 a 72,2. Con esos tres fuera de
        # la lista el tope de 170 se eligio sobre un vaiven que en el clip
        # que mas duele estaba infravalorado ocho veces.
        #
        # Y `roar` NO es un clip raro en este mod: `SpawnBroodAnim = ROAR`
        # en el `FIEND`, o sea que el Horror rie CADA `SpawnBroodTimer`
        # segundos mientras pelea. Es de los que mas se ven.
        clips_tope=("fiendwalk.anim", "fiendrun.anim",
                    "fiendidle.anim", "fiendattack.anim",
                    "fiendroar.anim", "fiendpounce.anim"),
        # El FIEND NO es simetrico -sus patas traseras giran 69,5 contra 26,2
        # al andar- y eso no lo arregla ningun tope, porque es una diferencia
        # ENTRE regiones. El espejo se queda puesto, como en el necromorfo.
        espejo_vaiven=True,
        # 110 DESDE LA PRUEBA05, Y BAJA DESDE 140 PORQUE LA MALLA ES OTRA.
        # Doblar el cuello 30 grados hace el bicho mas compacto -la caja pasa
        # de 3,102 de fondo a 2,292- y la escala uniforme cae de 5,834 a
        # 5,158, o sea que TODAS las aristas miden un 12% menos. Por eso la
        # `tension`, que es una RAZON entre vecinos, sube aunque el estiron
        # baje: la referencia se ha encogido. El numero que se mira aqui es
        # `abre`, el estiron EN METROS, que es lo que se ve en pantalla.
        #
        # Barrido del 04/09 sobre los NUEVE clips, `abre` en cm:
        #                    walk  run  attack  idle  roar  pounce
        #   PRUEBA04 obj140    33   36      41    23    19      33
        #   PRUEBA05 obj170    36   35      35    28    28      50
        #   PRUEBA05 obj140    30   28      31    23    23      42
        #   PRUEBA05 obj110    23   25      26    18    20      33
        # o sea que 110 gana o empata en los SEIS contra la PRUEBA04, y el
        # flex de locomocion se queda en 3,02 y 3,33 -MAS suelto que el 2,78
        # y 3,40 de la PRUEBA04-, asi que no es la estatua contra la que
        # avisa `alfas_de`. La pata delantera izquierda se queda en 0,9x,
        # o sea un 10% menos que la propia piel del vanilla, y se acepta:
        # es el 8,8% de la malla contra la costura, que es lo que se mira.
        objetivo=110.0,
        # El unico hueso sin claves de esta paleta, y es el TORSO: hereda a
        # RootJNT y un torso no necesita giro propio, asi que el assert lo
        # deja pasar por caer en `tronco`.
        sin_claves=("NewBack1JNT",),
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
        #
        # EL ESLABON ES EL PRIMERO DE LA PATA, NO EL TERCERO. Desde el
        # 28/08: hasta la PRUEBA04 los brazos colgaban de *FirstLeg3JNT y
        # las piernas de *FourthLeg3JNT, y en partida salian cuchillas de
        # varios metros. La cadena mide
        #     RootJNT -> Leg1 0,34 -> Leg2 +0,29 -> Leg3 +0,61 -> Leg4END
        # asi que Leg3 esta a 0,90 m pata afuera Y acumula el giro de sus
        # dos padres. Y nuestros brazos estan POR ENCIMA de todo el bicho
        # vanilla -su piel cabe en y 0,05..0,37 de nuestros 3,62 m-, o sea
        # que el brazo de palanca son metros. Giro acumulado por palanca
        # larga es exactamente el estiron. Leg1 lleva solo su propio giro
        # y su origen apenas se mueve.
        #
        # MEDIDO EL 29/08 y CONFIRMADO: aqui Leg1 SI vale, al reves que en
        # el ARTHROPOD. Los cuatro `*Leg1JNT` tienen claves en todos los
        # `.ANIM`, y de los siete huesos de esta paleta el UNICO quieto es
        # `NewBack1JNT`, que es el TORSO y esta bien quieto -hereda a
        # RootJNT y un torso no necesita giro propio-. Desplazamiento
        # -giro de mundo x palanca, promediado sobre walk y run-:
        #     brazo   Leg1 1,12/0,86   Leg2 1,03/0,99   Leg3 1,11/1,11 m
        #     pierna  Leg1 0,84/0,35   Leg2 1,25/0,39   Leg3 1,43/0,29 m
        # Leg1 gana claro en las piernas y empata en los brazos, asi que el
        # mapa de la PRUEBA05 se queda como esta.
        regiones=(
            ("NewHeadJNT",     lambda u, v, w: v > 0.86),
            ("LFirstLeg1JNT",  lambda u, v, w: v > 0.45 and u > 0.70),
            ("RFirstLeg1JNT",  lambda u, v, w: v > 0.45 and u < 0.30),
            ("NewBack1JNT",    lambda u, v, w: v > 0.55),
            ("LFourthLeg1JNT", lambda u, v, w: v <= 0.40 and u >= 0.50),
            ("RFourthLeg1JNT", lambda u, v, w: v <= 0.40 and u < 0.50),
            ("RootJNT",        lambda u, v, w: True),
        ),
        # EL AGARRE: region -> la region VECINA que la sujeta. Ver
        # `mapa_a_mano`. Cada miembro se queda `alfa` de su propio giro y el
        # resto lo sigue al cuerpo, que es lo unico que baja la palanca de
        # 18,4x de los brazos. Los brazos y la cabeza se agarran al torso;
        # las piernas, a la cadera.
        agarre={
            "LFirstLeg1JNT":  "NewBack1JNT",
            "RFirstLeg1JNT":  "NewBack1JNT",
            "NewHeadJNT":     "NewBack1JNT",
            "LFourthLeg1JNT": "RootJNT",
            "RFourthLeg1JNT": "RootJNT",
        },
        # EL GIRO DE CADA HUESO, que es la mitad que le faltaba a la
        # palanca. Lo escribe `Sway-NMSJoint.py --json`. Ver `vaiven_de`.
        giros=RAIZ / "work" / "models" / "fiendmesh" / "giros.json",
        # SOLO LOCOMOCION, y a proposito. La asimetria de las patas
        # traseras -2,7 veces entre izquierda y derecha- vive en `walk` y
        # `run`; en `attack` las dos giran parecido -60,4 y 67,4- y en
        # partida el ataque se ve BIEN. Meter `attack` aqui taparia la
        # asimetria justo en los dos clips donde se ve.
        clips=("fiendwalk.anim", "fiendrun.anim"),
        # El espejo se queda puesto: la asimetria de las patas traseras
        # del FIEND -69,5 grados contra 26,2 al andar- es real y no la
        # arregla ningun tope, porque es una diferencia ENTRE regiones.
        espejo_vaiven=True,
        # LA UNICA COSA QUE CAMBIA EN LA PRUEBA09, y es el tope global.
        # 113 no es un numero redondo: es el vaiven en el que el espejo
        # dejo las piernas en la PRUEBA08, y las piernas son lo unico que
        # en partida se ve bien. Medido el 31/08 en las tres capturas del
        # necromorfo: los brazos, CONGELADOS en el alfa de la 07, siguen
        # sacando cuchillas -se quedaban en vaiven 207 y 154, casi el
        # doble de las piernas-. Descongelarlos hasta 113 es peticion
        # expresa del 31/08, sabiendo que van a salir MAS tiesos.
        objetivo=113.0,
        # Solo la cabeza sigue congelada, y por lo de siempre: en
        # locomocion mide 18 -el tope ni la veria- pero en `idle` gira
        # 35,2 grados, asi que soltarla seria un estreno sin medir.
        alfas_fijos={
            "NewHeadJNT": 0.65,
        },
        # El unico hueso sin claves de esta paleta. Cae en `tronco`, asi que
        # el assert lo deja pasar: un torso quieto hereda a RootJNT y basta.
        sin_claves=("NewBack1JNT",),
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
        #
        # Y EL ESLABON ES `leg_*_0_jnt`: EL PRIMERO CON CLAVES, NO EL
        # PRIMERO DE LA CADENA. La PRUEBA05 colgo los miembros de
        # `legbase_*`, que es el primero de la cadena, y el zombie entro al
        # juego RIGIDO. La causa, medida en los cuatro `.ANIM` del ARTHROPOD
        # -walk, run, idle y attack01-: `legbase_*` NO TIENE NI UNA CLAVE en
        # ninguno de los cuatro. De los 29 huesos a los que el vanilla pega
        # piel, los SEIS `legbase_*` son los UNICOS quietos, y la PRUEBA05
        # metio cuatro de ellos bajo los brazos y las piernas, o sea bajo el
        # 52,2% de la malla. Un `legbase_*` solo hereda a `spine_C0_0_jnt`:
        # gira los mismos 4,0 grados de mundo que el torso, nada propio.
        #
        # La cadena y su giro de MUNDO, promediado sobre walk y run:
        #   spine 4,0deg -> legbase 4,0deg -> leg_0 18-35deg -> leg_1 28-36deg
        # `leg_*_0_jnt` es el primero que se mueve por su cuenta y lleva un
        # solo giro propio. `leg_*_1_jnt` -la PRUEBA04- arrastra dos, y eso
        # con la palanca de metros hasta nuestras manos es el estiron.
        regiones=(
            ("head_C0_0_jnt", lambda u, v, w: v > 0.86),
            ("leg_L0_0_jnt", lambda u, v, w: v > 0.55 and u > 0.74),
            ("leg_R0_0_jnt", lambda u, v, w: v > 0.55 and u < 0.26),
            ("spine_C0_0_jnt", lambda u, v, w: v > 0.55),
            ("leg_L2_0_jnt", lambda u, v, w: v <= 0.40 and u >= 0.50),
            ("leg_R2_0_jnt", lambda u, v, w: v <= 0.40 and u < 0.50),
            ("tail_C0_0_jnt", lambda u, v, w: True),
        ),
        # Lo mismo aqui. Los brazos van a 6,8x y 7,7x y la cabeza a 4,1x,
        # contra las piernas a 3,6x y 2,1x, que son las que se ven bien.
        agarre={
            "leg_L0_0_jnt":  "spine_C0_0_jnt",
            "leg_R0_0_jnt":  "spine_C0_0_jnt",
            "head_C0_0_jnt": "spine_C0_0_jnt",
            "leg_L2_0_jnt":  "tail_C0_0_jnt",
            "leg_R2_0_jnt":  "tail_C0_0_jnt",
            # EL ANCLA TAMBIEN NECESITA AGARRE, desde la PRUEBA09. De
            # `tail_C0_0_jnt` cuelga la cintura -la franja que no casa con
            # ninguna otra region- y gira 119 grados en `attack01`, pero
            # sin `agarre` no habia forma de toparlo: `alfas_de` solo
            # recorre las regiones que lo tienen. Se agarra al torso, que
            # en el mismo clip gira 38.
            "tail_C0_0_jnt": "spine_C0_0_jnt",
        },
        giros=RAIZ / "work" / "models" / "zombiemesh" / "giros.json",
        clips=("arthropodwalk.anim", "arthropodrun.anim"),
        # EL TOPE LEE LOS CUATRO CLIPS desde la PRUEBA09, y el espejo se
        # queda en locomocion. Con el tope leyendo solo `walk` y `run` la
        # cabeza mide 21 y se queda en alfa 1,0; en `attack01` mide 299.
        # Eso es la cuchilla de cuello medida el 31/08 en partida.
        clips_tope=("arthropodwalk.anim", "arthropodrun.anim",
                    "arthropodidle.anim", "arthropodattack01.anim"),
        # AQUI EL ESPEJO NO VALE, y por una vez el ARTHROPOD es simetrico:
        # los dos huesos de brazo giran 52,1 y 53,2 en `run`, asi que
        # igualarlos no baja nada. Lo que sobra aqui es el vaiven ABSOLUTO
        # de los brazos, no la diferencia entre lados, y eso lo corta el
        # tope. Medido el 31/08 en partida: cuello, hombros y brazos
        # estiran; las piernas no se mueven.
        espejo_vaiven=False,
        # Tope de VAIVEN, no de palanca. La 07 puso 4,0 de palanca y con
        # eso los brazos se quedaron en vaiven 202 y 209 -y siguen sacando
        # cuchillas-, mientras las piernas se quedaban en 59 y 65, que es
        # el -las piernas no parecen moverse-. Se lee de la tabla que
        # imprime este script.
        objetivo=120.0,
        # LAS DOS PIERNAS AL MISMO NUMERO, Y ESO ES LA PRUEBA10.
        #
        # El tope por `objetivo` NO LAS TRATA IGUAL, y ahi estaba la
        # asimetria. Medido el 01/09 con Pose-NMSMesh.py sobre los cuatro
        # .ANIM: en `attack01` los dos huesos giran casi lo mismo -46,8 y
        # 41,6 grados- pero nuestras palancas son 3,6x y 2,1x, asi que el
        # vaiven sale 168 y 87. Con el tope en 120 eso AGARRA LA IZQUIERDA
        # -alfa 0,71- Y DEJA SUELTA LA DERECHA -alfa 1,0-. La asimetria no
        # la pone el ARTHROPOD, que es simetrico: la fabrica el tope al
        # leer una palanca que sale de nuestro propio reparto.
        #
        # Y en locomocion el tope NO LLEGA A NINGUNA DE LAS DOS: valen 65 y
        # 59, muy por debajo de 120. Ahi la costura de la cadera abre 22 cm
        # -`tail_C0_0_jnt` gira 3,2 grados y `leg_R2_0_jnt` 28,3, y entre
        # los dos hay saltos de peso de 0,42 sobre aristas de 2,8 cm-.
        #
        # 0,4 fijo en las dos, medido ANTES de construir:
        #     walk   tension 27,7 -> 11,5   abre 16 -> 7 cm
        #     run    tension 41,2 -> 17,0   abre 22 -> 13 cm
        #     attack tension 33,9 -> 13,0   abre 21 -> 21 cm  (es el hombro)
        #     idle   sin cambio                              (es el hombro)
        # `flex` -la deformacion normal, p99- se queda entre 1,84 y 2,36, o
        # sea que la piel sigue deformando y esto NO es una estatua.
        #
        # LOS BRAZOS NO SE TOCAN, y se probo: agarrarlos a 0,75 lleva
        # `attack` de 21 a 74 cm. El ancla es `spine_C0_0_jnt` y el torso
        # tiene MAS alcance hasta los vertices del brazo que el propio
        # hueso del brazo, asi que el agarre alarga la palanca en vez de
        # acortarla.
        alfas_fijos={
            "leg_L2_0_jnt": 0.4,
            "leg_R2_0_jnt": 0.4,
        },
        # Los huesos de la paleta del ARTHROPOD sin ni una clave en ningun
        # `.ANIM`. Colgar un miembro de uno de ellos es la PRUEBA05.
        sin_claves=("legbase_L0_0_jnt", "legbase_L1_0_jnt", "legbase_L2_0_jnt",
                    "legbase_R0_0_jnt", "legbase_R1_0_jnt", "legbase_R2_0_jnt"),
    ),
}

CUAL = sys.argv[sys.argv.index("--") + 1] if "--" in sys.argv else "skrullcrawler"
M = MODELOS[CUAL]
print(f"modelo: {CUAL}")

BLEND = M["blend"]
VANILLA = M["vanilla"]
SALIDA = M["salida"]
# `--salida <ruta>` escribe el pesado en otro sitio Y NO GUARDA EL .blend.
# Es para probar un agarre y puntuarlo con Pose-NMSMesh.py sin pisar ni el
# pesos.json que esta en el juego ni los grupos del .blend.
PRUEBA = "--salida" in sys.argv
if PRUEBA:
    SALIDA = Path(sys.argv[sys.argv.index("--salida") + 1])
NUESTRA = M["objeto"]
# `--giro-z N` prueba otro giro sin tocar la tabla. Existe porque el giro NO
# se adivina y el unico assert que habia lo mide en ALTURA -RootJNT por encima
# de las puntas-, o sea que no dice nada de si el bicho mira adelante o atras.
# Con el cry wolf eso importo: nuestra parte alta cae en w 0,05 y la cabeza
# del FIEND en w 1,51, y si van enfrentadas todo se va a RootJNT.
GIRO_Z = (int(sys.argv[sys.argv.index("--giro-z") + 1])
          if "--giro-z" in sys.argv else M["giro_z"])
ESCALA_PIEL = M.get("escala_piel", "altura")
TOPE_REPARTO = M.get("tope_reparto")

# Cuantos vertices de la piel vanilla promedia cada vertice nuestro.
# Con 1 estariamos en el metodo que fallo -un ganador unico y una costura
# donde cambia-. Con 8 la frontera es un degradado de varios centimetros,
# que es lo que hace falta para que no se tense. Se guardan las
# nmsskin.RANURAS = 4 mayores, que son las que el buffer trae: el canal 5
# son 4 bytes de indice y el 6 son 4 half de peso, y nmsskin.canales() ya
# escribia los cuatro. Hasta el 28/08 esto truncaba a DOS y renormalizaba,
# o sea que deshacia el suavizado justo donde hacia falta -en la frontera,
# que es el unico sitio donde se juntan 3 o mas huesos-.
VECINOS = 8
BLOQUE_VECINOS = 256  # 256 x 7635 x 3 float64 son 47 MB; de una vez, 880

# Pasadas de promedio por las aristas de NUESTRA malla, despues de copiar.
# Es lo unico que puede devolver al torso la trasera que las patas del
# vanilla se llevan, porque ahi no hay nada del vanilla que copiar salvo
# pata. El numero se sube hasta que el assert de punta deja de saltar.
SUAVIZADOS = 12

# Las paradas de `--barrer`: mide la costura con cada numero de pasadas sin
# escribir nada, para elegir SUAVIZADOS sin entrar a la partida. El ancho de
# la transicion crece como la RAIZ de las pasadas, asi que van al doble.
BARRIDO = (12, 24, 48, 96)

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


def suaviza(crudo, vecinas):
    """Una pasada de promedio por las aristas de NUESTRA malla."""
    siguiente = []
    for i, propio in enumerate(crudo):
        mezcla = dict(propio)
        for j in vecinas[i]:
            for n, w in crudo[j].items():
                mezcla[n] = mezcla.get(n, 0.0) + w
        total = sum(mezcla.values())
        siguiente.append({n: w / total for n, w in mezcla.items()})
    return siguiente


def costura(crudo, vecinas):
    """Cuanto salta el peso entre dos vertices UNIDOS POR UNA ARISTA.

    Una lamina tensada ES ese salto: dos vertices pegados que cuelgan de
    huesos que giran distinto se van a sitios distintos, y en partida eso
    son las cuchillas de varios metros. Se mide sobre NUESTRAS aristas, que
    es donde se ve, y sobre los pesos YA RECORTADOS a las cuatro ranuras,
    que es lo que de verdad viaja en el buffer.

    Devuelve el salto en 0..1 -0 es el mismo peso a los dos lados, 1 es
    hueso puro contra hueso puro- mas la fraccion de vertices que cuelgan
    de UN solo hueso, que es la materia prima de la costura.
    """
    corto = []
    for p in crudo:
        pares = sorted(p.items(), key=lambda t: -t[1])[:nmsskin.RANURAS]
        total = sum(w for _, w in pares)
        corto.append({n: w / total for n, w in pares})
    saltos = []
    for i, propio in enumerate(corto):
        for j in vecinas[i]:
            if j <= i:
                continue
            otro = corto[j]
            saltos.append(sum(abs(propio.get(n, 0.0) - otro.get(n, 0.0))
                              for n in set(propio) | set(otro)) / 2)
    s = np.array(saltos)
    puros = float(np.mean([max(p.values()) > 0.99 for p in corto]))
    infl = float(np.mean([len(p) for p in corto]))
    return s.mean(), float(np.percentile(s, 99)), s.max(), puros, infl


def costura_vanilla(vanillas, paleta):
    """El mismo medidor, sobre la piel del VANILLA y sus propias aristas.

    Es la referencia, como en el resto del guion: no hay un numero bueno de
    salto en abstracto, hay el que el juego ya se traga con esa animacion y
    ese esqueleto. Solo cuentan los vertices con peso de la paleta y las
    aristas cuyos DOS extremos lo tienen; los demas son ojos y brillos, que
    no son piel.
    """
    crudo, vecinas, mapa, n = [], [], {}, 0
    for o in vanillas:
        nombre = {g.index: g.name for g in o.vertex_groups}
        vivos = {}
        for v in o.data.vertices:
            pares = [(nombre[e.group], e.weight) for e in v.groups
                     if nombre[e.group] in paleta and e.weight > 0]
            if not pares:
                continue
            total = sum(w for _, w in pares)
            vivos[v.index] = n
            crudo.append({g: w / total for g, w in pares})
            vecinas.append([])
            n += 1
        for a in o.data.edges:
            i, j = a.vertices
            if i in vivos and j in vivos:
                vecinas[vivos[i]].append(vivos[j])
                vecinas[vivos[j]].append(vivos[i])
        mapa[o.name] = len(vivos)
    return costura(crudo, vecinas)


def mide_palanca(dominantes, puntos, vv_nuestro, pesos_vanilla):
    """Cuanto AMPLIFICA cada hueso, contra la piel a la que iba destinado.

    Un grado de giro se convierte en metros segun lo lejos que este el
    vertice del hueso que lo mueve. El sitio del hueso se toma de la PIEL
    del vanilla -el centroide de los vertices que domina-, NO del armature:
    NMSDK no deja alineadas las dos matrices y por ahi ya se colo un
    diagnostico falso una vez.

    Devuelve hueso -> (nuestra distancia, la del vanilla, las veces). Ese
    ultimo numero es todo: con 18,4x el mismo giro que mueve su piel 5 cm
    nos mueve el brazo casi un metro, y eso es la cuchilla.
    """
    centro = {}
    for punto, pares in zip(vv_nuestro, pesos_vanilla):
        centro.setdefault(max(pares, key=lambda t: t[1])[0], []).append(punto)
    dom = np.array(dominantes)
    salida = {}
    for hueso, suyos in centro.items():
        c = np.mean(suyos, axis=0)
        mios = puntos[dom == hueso]
        if not len(mios):
            continue
        nd = float(np.linalg.norm(mios - c, axis=1).mean())
        sd = float(np.linalg.norm(np.array(suyos) - c, axis=1).mean())
        salida[hueso] = (nd, sd, nd / sd)
    return salida


def deriva_del_mapa(crudo, cuenta, n):
    """Lo que mas se separa el reparto del MAPA A MANO, en fraccion.

    Es el assert DERIVA de abajo, adelantado: suavizar de mas se come una
    region entera, y esto dice cuanto antes de que corte.
    """
    dom = {}
    for p in crudo:
        g = max(p, key=p.get)
        dom[g] = dom.get(g, 0) + 1
    return max(abs(dom.get(h, 0) / n - c / n) for h, c in cuenta.items())


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


def asimetria(frac, espejo, paleta, alfas=None):
    """Cuanto se desparejan los huesos izquierdo y derecho, en fraccion.

    Solo cuenta los que TIENEN pareja EN LA PALETA. Sin esa condicion,
    RootJNT se puntuaba contra un "LootJNT" que no existe y el vanilla
    -que esta pareado al vertice, RFirstLeg3JNT 260 y LFirstLeg3JNT 260-
    salia con 0,459 de asimetria, o sea con la suya propia entera.
    NewBack1JNT ni siquiera lleva L ni R, y tambien se salta.

    Y SE DESCUENTA EL ALFA, desde la PRUEBA08. El agarre desparea el peso
    A PROPOSITO: si la pata izquierda del FIEND gira 2,7 veces mas que la
    derecha, `espeja` le quita peso a la nuestra para que las dos se
    MUEVAN igual, y el reparto sale con 0,208 de asimetria siendo justo lo
    que se queria. Deshacer el alfa devuelve el reparto que pidio el mapa
    -que si es simetrico, porque son dos mitades de un plano en u 0,50- y
    deja este guard cazando lo que se escribio para cazar: que el vecino
    mas cercano o el suavizado se hayan comido un lado, que es la PRUEBA12
    y la PRUEBA14.
    """
    izq, der = espejo
    alfas = alfas or {}
    total = 0.0
    for g in frac:
        if der not in g:
            continue
        pareja = g.replace(der, izq, 1)
        if pareja == g or pareja not in paleta:
            continue
        a = max(alfas.get(g, 1.0), 1e-3)
        b = max(alfas.get(pareja, 1.0), 1e-3)
        total += abs(frac.get(pareja, 0.0) / b - frac[g] / a)
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

    # Y QUE EL HUESO SE MUEVA. Estar en la paleta dice que el vanilla le
    # pega piel; NO dice que tenga una sola clave de animacion. El ARTHROPOD
    # tiene seis `legbase_*` en la paleta y quietos en los cuatro `.ANIM`, y
    # la PRUEBA05 colgo de ellos el 52,2% del zombie: entro al juego rigido.
    # Un miembro cuelga de un hueso que gire; el tronco puede colgar de uno
    # quieto, porque hereda al padre y no necesita giro propio.
    quietos = [h for h, _ in M["regiones"]
               if h in M.get("sin_claves", ())
               and not any(t in h for t in M["tronco"])]
    assert not quietos, (
        f"el mapa cuelga un MIEMBRO de huesos sin ni una clave de "
        f"animacion: {quietos}. En partida sale rigido, que es la PRUEBA05. "
        f"Coge el primer eslabon de la cadena que SI tenga claves")
    AGARRE = M.get("agarre", {})

    def mapa_a_mano(alfa):
        """Los pesos que pide el mapa, con el AGARRE ya aplicado.

        EL AGARRE ES LA PALANCA, y es lo unico que quedaba por tocar.
        Medido el 30/08 con `--barrer`: el mismo hueso que mueve su propia
        piel vanilla 0,15 m mueve nuestro brazo 2,77 m, o sea 18,4 VECES,
        porque el pivote le queda a metros. Por eso salian cuchillas en las
        extremidades, y por eso cambiar de eslabon no las quitaba: Leg1,
        Leg2 y Leg3 tienen todos la misma palanca y solo cambia el giro.

        `alfa` es cuanto del giro PROPIO del hueso se queda la region; el
        resto se lo lleva su ancla, que es la region vecina y va con el
        cuerpo. El desplazamiento es lineal en el peso, asi que alfa
        multiplica la palanca: con 0,20 el brazo se mueve una quinta parte.
        Y la mezcla es la MISMA en toda la region, asi que no abre costura
        por dentro; solo baja la que ya habia en el hombro.

        alfa 1,0 es el mapa duro de siempre -la PRUEBA06, con cuchillas- y
        alfa 0,0 es colgar el miembro del tronco, o sea rigido, que es la
        PRUEBA05. El numero se elige con `--barrer --alfa`.

        Devuelve DOS repartos: el que pide el mapa por region y el
        DOMINANTE, que con mezcla ya no es el nombre de la region.
        """
        crudo, region, manda = [], {}, {}
        for p in puntos:
            u, v, w = (p - lo_p) / tam_p
            for hueso, dentro in M["regiones"]:
                if dentro(u, v, w):
                    ancla = AGARRE.get(hueso)
                    a = alfa.get(hueso, 1.0)
                    pesos = ({hueso: a, ancla: 1.0 - a}
                             if ancla and a < 1.0 else {hueso: 1.0})
                    crudo.append(pesos)
                    region[hueso] = region.get(hueso, 0) + 1
                    g = max(pesos, key=pesos.get)
                    manda[g] = manda.get(g, 0) + 1
                    break
        return crudo, region, manda

    def vaiven_de(palanca, clips):
        """Cuanto mueve cada hueso NUESTRA piel: palanca POR giro de mundo.

        LA PALANCA SOLA NO BASTA, y eso lo ensena la PRUEBA07 en partida.
        La palanca dice lo lejos que le queda el pivote a nuestra region,
        o sea cuantas VECES amplifica; no dice si el hueso se mueve. La 07
        eligio los alfas con la palanca sola y le salio del reves: apreto
        la CABEZA del necromorfo al 61% -palanca 6,2x pero 2,9 grados al
        andar, o sea inofensiva- y dejo enteras las dos patas traseras
        -palanca 3,9x, pero 69,5 y 26,2 grados, las que mas giran de toda
        la paleta, y el 41,7% de la malla-. En partida se vio exactamente
        eso el 31/08: brazos y ataque limpios, y al andar se estira la
        mitad de abajo.

        El vaiven se mide sobre los clips de LOCOMOCION, que es donde se
        ve, y se coge el PEOR. Sale en grados-por-veces y solo sirve para
        comparar regiones entre si, nunca como medida absoluta.
        """
        if not clips:
            return {h: x[2] for h, x in palanca.items()}
        giros = json.loads(Path(M["giros"]).read_text(encoding="utf-8"))
        return {h: x[2] * max(giros[h][c] for c in clips)
                for h, x in palanca.items() if h in giros}

    def espeja(vaiven):
        """Iguala cada region con su espejo, por el lado MAS QUIETO.

        Un bipedo anda con las dos piernas igual. El FIEND no: es una
        arana, su animador nunca necesito simetria, y `LFourthLeg1JNT`
        gira 69,5 grados al andar contra los 26,2 de `RFourthLeg1JNT`,
        2,7 VECES mas. Nuestro mapa parte la mitad de abajo por un plano
        duro en u 0,50 y cuelga cada mitad de una de las dos, asi que las
        dos mitades cizallan por la linea media. Eso es el -al andar se
        estira la mitad del cuerpo- de la PRUEBA07, y NO lo arregla ningun
        tope global: es una diferencia ENTRE regiones, no un exceso de
        una sola.

        Se iguala por abajo porque el lado quieto es el que en partida se
        ve bien.
        """
        izq, der = M["espejo"]
        salida = dict(vaiven)
        for h in vaiven:
            for a, b in ((izq, der), (der, izq)):
                if a not in h:
                    continue
                pareja = (b + h[len(a):] if h.startswith(a)
                          else h.replace(a, b, 1))
                if pareja != h and pareja in vaiven:
                    salida[h] = min(vaiven[h], vaiven[pareja])
                    break
        return salida

    def alfas_de(objetivo):
        """Cuanto giro propio se le deja a cada region.

        Dos reglas, y CADA UNA LEE SUS PROPIOS CLIPS. El ESPEJO iguala
        cada miembro con el del otro lado y se mide sobre LOCOMOCION, que
        es donde vive la asimetria de la arana: meter `attack` ahi la
        taparia, porque atacando las dos patas giran parecido. El TOPE no
        deja a nadie pasar del objetivo y se mide sobre `clips_tope`, que
        por defecto son los mismos pero puede ser la lista entera.

        LA PRUEBA08 ENSENA POR QUE HACEN FALTA DOS LISTAS. Con el tope
        leyendo solo `walk` y `run`, la cabeza del zombie mide 21 -alfa
        1,0, el tope ni la ve- y en `attack01` mide 299. En partida el
        31/08 salio exactamente eso: brazos limpios y la cabeza en
        cuchilla.

        El desplazamiento es lineal en el peso, asi que el alfa es la
        razon directa entre el vaiven que se quiere y el que hay, y de las
        dos reglas manda la mas apretada.

        `alfas_fijos` gana sobre las dos. Es para congelar una region que
        ya se ha medido EN PARTIDA y que no se quiere volver a mover.
        """
        espejo = espeja(VAIVEN) if M.get("espejo_vaiven") else VAIVEN
        alfas = {}
        for h in AGARRE:
            if not VAIVEN.get(h):
                continue
            a = espejo[h] / VAIVEN[h]
            if objetivo and VAIVEN_TOPE.get(h):
                a = min(a, objetivo / VAIVEN_TOPE[h])
            alfas[h] = min(1.0, a)
        alfas.update(M.get("alfas_fijos") or {})
        # `--alfa hueso=valor,hueso=valor` para probar un agarre sin tocar
        # este archivo. Existe desde el 01/09, y por una medida concreta:
        # `Pose-NMSMesh.py` dice que la costura de la cadera abre 22 cm
        # porque el muslo cuelga de un hueso que gira 28 grados y la
        # cintura de uno que gira 3, y el tope por `objetivo` NO LLEGA AHI
        # -pide 120 y las piernas miden 28-. Lo que hay que topar ahi no es
        # el giro absoluto: es la DIFERENCIA a un lado y otro de la costura.
        if "--alfa" in sys.argv:
            for par in sys.argv[sys.argv.index("--alfa") + 1].split(","):
                hueso, valor = par.split("=")
                alfas[hueso] = float(valor)
        return alfas

    palanca = mide_palanca([max(p, key=p.get) for p in mapa_a_mano({})[0]],
                           puntos, vv_nuestro, pesos_vanilla)
    VAIVEN = vaiven_de(palanca, M.get("clips") or ())
    VAIVEN_TOPE = vaiven_de(palanca, M.get("clips_tope") or M.get("clips") or ())
    ALFAS = alfas_de(M.get("objetivo"))
    crudo, cuenta, cuenta_manda = mapa_a_mano(ALFAS)
    print()
    print(f"mapa a mano region -> hueso (objetivo {M.get('objetivo') or '-'}):")
    for hueso, _ in M["regiones"]:
        n = cuenta.get(hueso, 0)
        x = palanca.get(hueso, (0, 0, 0))[2]
        vai = VAIVEN.get(hueso, 0.0)
        top = VAIVEN_TOPE.get(hueso, vai)
        a = ALFAS.get(hueso, 1.0)
        peor = f"  vaiven {vai:6.0f}" + (f" (todos {top:6.0f})" if top > vai else "")
        cola = (f"{peor} -> {max(vai, top) * a:6.0f}, agarre "
                f"{1 - a:.0%} a {AGARRE[hueso]}" if a < 1.0 else peor)
        print(f"  {hueso:<20} {n:6d}  {n / len(puntos) * 100:5.1f}%"
              f"   {x:4.1f}x{cola}")
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

def a_salida(crudo):
    """Los pesos crudos en el formato de pesos.json.

    Se saco a funcion el 01/09 porque el barrido de `--objetivo` tiene que
    DEJAR EN DISCO cada candidato para que `Pose-NMSMesh.py` lo puntue
    contra las animaciones de verdad. Escribirlo dos veces era el camino
    corto a que el barrido midiera un formato y la entrega otro.
    """
    salida = []
    for i, pesos in enumerate(crudo):
        pares = sorted(pesos.items(), key=lambda t: -t[1])[:nmsskin.RANURAS]
        total = sum(w for _, w in pares)
        pares = [(n, round(float(w / total), 6)) for n, w in pares]
        # Redondear a seis decimales puede dejar la suma en 0.999999, y el
        # assert de mas abajo pide 1 con 1e-4. Se cuadra en el mayor.
        pares[0] = (pares[0][0],
                    round(pares[0][1] + 1.0 - sum(w for _, w in pares), 6))
        co = nuestra.data.vertices[i].co
        salida.append([round(co.x, 6), round(co.y, 6), round(co.z, 6),
                       [list(t) for t in pares]])
    return salida


if "--barrer" in sys.argv:
    # Decidir SIN ENTRAR A LA PARTIDA. Dos barridos, y no miden lo mismo:
    #
    #   --barrer              pasadas de SUAVIZADOS. Medido el 30/08 y
    #                         DESCARTADO: con 12 pasadas nuestra piel ya es
    #                         MAS SUAVE que la del propio vanilla -p99 0,180
    #                         contra 0,500- y el vanilla no saca cuchillas.
    #                         La costura no era el fallo.
    #   --barrer --objetivo   el AGARRE, que si lo es. Ver `mapa_a_mano`.
    #
    # El objetivo se lee contra la partida, no contra un numero redondo: las
    # PIERNAS ya salen bien y estan a 3,9x en el necro y a 3,6x en el
    # zombie. Bajar los brazos y la cabeza a eso es toda la medida.
    if M.get("regiones"):
        print()
        print(f"{'hueso':<22} {'palanca':>8} {'vanilla':>8} {'x':>6}")
        for _h, _ in M["regiones"]:
            if _h in palanca:
                nd, sd, x = palanca[_h]
                print(f"{_h:<22} {nd:8.2f} {sd:8.2f} {x:5.1f}x")

    v_med, v_p99, v_mx, v_puros, v_infl = costura_vanilla(vanillas, paleta)

    if "--objetivo" in sys.argv:
        metas = [float(x) for x in
                 sys.argv[sys.argv.index("--objetivo") + 1].split(",")]
        print()
        print("x EFECTIVA por region:")
        print(f"{'hueso':<22} {'hoy':>7}"
              + "".join(f"{'obj ' + f'{m:g}':>9}" for m in metas))
        for _h, _ in M["regiones"]:
            if _h not in palanca:
                continue
            x = palanca[_h][2]
            print(f"{_h:<22} {x:6.1f}x"
                  + "".join(f"{x * alfas_de(m).get(_h, 1.0):8.1f}x"
                            for m in metas))
        print()
        print(f"{'objetivo':>8} {'medio':>7} {'p99':>7} {'max':>7} "
              f"{'1 hueso':>8} {'infl':>6} {'deriva':>7}")
        for m in metas:
            c_m, _, manda_m = mapa_a_mano(alfas_de(m))
            for _ in range(SUAVIZADOS):
                c_m = suaviza(c_m, vecinas)
            med, p99, mx, puros, infl = costura(c_m, vecinas)
            # Cada candidato se deja en disco. La costura es un PROXY -mide
            # saltos de peso entre vecinos, sin animacion ninguna-; quien
            # dice si sale cuchilla es Pose-NMSMesh.py, que lo mueve con los
            # .ANIM del juego.
            ruta = SALIDA.parent / f"pesos_obj{m:g}.json"
            ruta.write_text(json.dumps(a_salida(c_m)), encoding="utf-8")
            print(f"{m:8.1f} {med:7.3f} {p99:7.3f} {mx:7.3f} "
                  f"{puros * 100:7.1f}% {infl:6.2f} "
                  f"{deriva_del_mapa(c_m, manda_m, len(puntos)) * 100:6.1f}p")
    else:
        print()
        print(f"{'pasadas':>7} {'medio':>7} {'p99':>7} {'max':>7} "
              f"{'1 hueso':>8} {'infl':>6} {'deriva':>7}")
        hecho = 0
        for meta in (0,) + BARRIDO:
            while hecho < meta:
                crudo = suaviza(crudo, vecinas)
                hecho += 1
            med, p99, mx, puros, infl = costura(crudo, vecinas)
            d = (f"{deriva_del_mapa(crudo, cuenta_manda, len(puntos)) * 100:6.1f}p"
                 if M.get("regiones") else "     --")
            print(f"{hecho:7d} {med:7.3f} {p99:7.3f} {mx:7.3f} "
                  f"{puros * 100:7.1f}% {infl:6.2f} {d}")
    print(f"{'VANILLA':>8} {v_med:7.3f} {v_p99:7.3f} {v_mx:7.3f} "
          f"{v_puros * 100:7.1f}% {v_infl:6.2f}       - "
          f" <- la piel del vanilla con sus propias aristas")
    sys.exit(0)

for _ in range(SUAVIZADOS):
    crudo = suaviza(crudo, vecinas)

salida = a_salida(crudo)

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
_med, _p99, _mx, _puros, _ = costura(crudo, vecinas)
print(f"costura por arista: salto medio {_med:.3f}, p99 {_p99:.3f}, "
      f"maximo {_mx:.3f}; {_puros * 100:.1f}% de vertices a UN solo hueso")
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
assert max(len(e[3]) for e in salida) <= nmsskin.RANURAS, (
    f"algun vertice cuelga de mas de {nmsskin.RANURAS} huesos")
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

# CON MAPA A MANO LA ASIMETRIA SE MIDE EN MASA, NO EN DOMINANTES.
# `reparto_de` cuenta el hueso que MANDA en cada vertice, y eso deja de
# querer decir nada en cuanto el agarre baja de 0,5: con alfa 0,42 la pierna
# izquierda no manda en NINGUNO de sus vertices -manda RootJNT- y el guard
# leia 0,208 de desparejo cuando el mapa habia repartido las dos mitades
# igual. La masa de peso si es continua en el alfa, y descontandolo vuelve a
# salir el reparto que pidio el mapa.
masa = {}
for _fila in salida:
    for _g, _w in _fila[3]:
        masa[_g] = masa.get(_g, 0.0) + _w
masa = {_g: _m / len(salida) for _g, _m in masa.items()}

asim = asimetria(masa if M.get("regiones") else nuestro, M["espejo"], paleta,
                 ALFAS if M.get("regiones") else None)
print(f"nuestra asimetria {asim:.3f} contra {ref_asim:.3f} del vanilla")
assert asim - ref_asim < TOPE_ASIMETRIA, (
    f"el reparto sale desparejado: asimetria {asim:.3f} contra {ref_asim:.3f} "
    f"del vanilla. Los dos bichos son simetricos, asi que un lado que se "
    f"lleva lo del otro es la firma de PRUEBA12 y PRUEBA14, y en el juego "
    f"son las laminas planas tensadas")
tronco = sum(n for g, n in reparto.items()
             if any(t in g for t in M["tronco"])) / len(salida)
# CON MAPA A MANO ESTE TOPE TAMPOCO APLICA, por lo mismo que el de punta: lo
# que se lleva cada hueso lo decide el mapa y no el copiado, y ahi el 30% deja
# de ser una anatomia y pasa a ser un numero heredado del caso en que TODO
# colgaba del torso. El cry wolf con agarre 1,0 da 29,2% -Root 25,7 mas el
# cuello 3,5- porque su cabeza, que es el 35,5% de la malla, ya cuelga de
# `NewHeadJNT`, que es justo lo que se le pidio al mapa. Quien lo comprueba en
# los modelos con regiones es la guarda de abajo, que es mas fuerte: mide el
# resultado CONTRA EL MAPA, region por region.
assert tronco >= MINIMO_TRONCO or M.get("regiones"), (
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
    for hueso in cuenta_manda:
        pedido = cuenta_manda.get(hueso, 0) / len(puntos)
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
if PRUEBA:
    print(f"prueba: NO se guarda {BLEND}")
else:
    bpy.ops.wm.save_as_mainfile(filepath=str(BLEND))
    print(f"guardado {BLEND}")
