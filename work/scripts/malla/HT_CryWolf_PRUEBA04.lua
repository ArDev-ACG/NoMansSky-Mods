RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\MODS\NMS_MOD_ZOMBIES\work\models\crywolfmesh_anim]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\MODS\NMS_MOD_ZOMBIES\work\textures]]

DESTINO_MALLA    = [[MODELS\PLANETS\CREATURES\SPIDERRIG]]
DESTINO_MATERIAL = [[MODELS\PLANETS\CREATURES\SPIDERRIG\FIEND]]
DESTINO_TEXTURA  = [[TEXTURES\PLANETS\CREATURES\SPIDERRIG]]

ENTREGA =
{
  {
    ["COMMENT"]              = "El .SCENE vanilla del FIEND injertado con nuestra malla, BYTE A BYTE el de la PRUEBA03: los 44 nodos JOINT, la colision, el ATTACHMENT y el .ENTITY siguen siendo los del juego",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.SCENE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.SCENE.MBIN]],
  },
  {
    ["COMMENT"]              = "VertexLayout a stride 20 con los canales 2, 3, 5 y 6 y los cuatro arrays por hueso del vanilla, BYTE A BYTE el de la PRUEBA03",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.GEOMETRY.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.GEOMETRY.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "EL UNICO ARCHIVO QUE CAMBIA. Mismos 11100 vertices y mismos 513252 bytes que la PRUEBA03; lo que cambia es el PESO DE HUESO de cada uno, o sea a que se agarra la piel. Ni un vertice se mueve de sitio",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.GEOMETRY.DATA.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.GEOMETRY.DATA.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "FIEND_MAT con _F02_SKINNED y los TRES samplers a rutas CRYWOLF, BYTE A BYTE el de la PRUEBA03",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND_MAT.MATERIAL.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MATERIAL .. [[\FIEND_MAT.MATERIAL.MBIN]],
  },
  {
    ["COMMENT"]              = "Color base BC7 2048 con 12 mips, sin tocar desde la PRUEBA01",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\CRYWOLF.BASE.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\CRYWOLF.BASE.DDS]],
  },
  {
    ["COMMENT"]              = "Normal ATI2 2048 con 12 mips, esculpido en el asset, sin tocar desde la PRUEBA01",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\CRYWOLF.BASE.NORMAL.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\CRYWOLF.BASE.NORMAL.DDS]],
  },
  {
    ["COMMENT"]              = "Mascaras ATI1 2048 de la rugosidad real del asset e invertidas por el acuerdo B5, sin tocar desde la PRUEBA01",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\CRYWOLF.BASE.MASKS.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\CRYWOLF.BASE.MASKS.DDS]],
  },
}

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_CryWolf_PRUEBA04",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.4.0] EL CRY WOLF CON EL MISMO CUERPO Y OTRA PIEL DE HUESOS. LA GEOMETRIA NO SE TOCA: seis de los siete archivos van BYTE A BYTE los de la PRUEBA03 y el septimo -el buffer de vertices- mide los mismos 513252 bytes con los mismos 11100 vertices en el mismo sitio; lo unico que cambia es EL PESO DE HUESO. Sale de la partida del 03/09: las dos patas traseras se deforman al RUGIR y al ATACAR, y el bicho camina como si le pesara la cabeza. LAS DOS CAUSAS ESTAN MEDIDAS Y SON UNA SOLA COSA VISTA DOS VECES, Y NINGUNA ES LA MALLA. CAUSA 1, EL TOPE NO VEIA EL PEOR CLIP. El tope de vaiven de la PRUEBA03 se eligio leyendo cuatro animaciones -walk, run, idle y attack- y el FIEND tiene NUEVE. Medidas las nueve con Pose-NMSMesh.py sobre la PRUEBA03 ya desplegada, la que mas tensa NO es ninguna de las cuatro: es ROAR con 36,4 contra los 28,2 de run. Y no es un clip raro en este mod, es el que mas se ve: SpawnBroodAnim del FIEND vale ROAR, o sea que el Horror ruge cada 10 segundos mientras pelea, que es justo cuando la partida dice que se deforma. En roar el giro de mundo de RootJNT pasa de los 6,3 que veia el tope a 44,2 -SIETE VECES-, NewBack1JNT de 6,3 a 49,4 y NewHeadJNT de 2,9 a 72,2. El tope de 170 se habia elegido sobre un vaiven infravalorado ocho veces. Ahora giros.json trae los nueve clips y el tope lee seis, roar y pounce incluidos. CAUSA 2, EL CUELLO NO LO TOPABA NADIE. NewBack1JNT es el hueso del que cuelga el cuello largo, y es el que Pose-NMSMesh culpa en los NUEVE clips, uno por uno. No tenia AGARRE, y alfas_de SOLO recorre las regiones que lo tienen: se quedaba en vaiven 279 contra un objetivo de 170, sin que ningun tope lo mirase. Es exactamente el mismo fallo que el zombie tuvo con tail_C0_0_jnt hasta su PRUEBA09. Se le pone ancla a RootJNT y baja de 5,7x a 2,8x. LA FIRMA DE LA PRUEBA03 PEDIA PARTIR NewBack1JNT EN CUELLO Y PECHO Y NO HACE FALTA: no le faltaba una region, le faltaba un ancla. EL NUMERO NUEVO SE MIDE, NO SE COGE. Barrido de objetivo puntuado con los nueve clips -tension del peor clip / costura walk-run-attack / flex de locomocion-: la PRUEBA03 daba 36,4 con 39-42-46 cm y flex 3,74 y 5,25; obj 200 da 27,8 con 45-49-52; obj 170 da 23,7 con 39-42-46; obj 140 da 19,6 con 33-36-41 y flex 2,78 y 3,40; obj 110 da 15,5 pero deja la pata delantera izquierda en 0,9x, o sea MENOS que la propia piel del vanilla, que es la estatua contra la que avisa el guion. SE ENTREGA 140. Contra la PRUEBA03: roar 36,4 -> 15,2, run 28,2 -> 16,9, attack 26,2 -> 15,5, walk 25,8 -> 19,0, y la pata trasera derecha, que era el hueso con mas tension propia despues de los dos del tronco, baja de 6,09 a 1,77. Reparto 7 huesos, 2,56 asignaciones por vertice, ASIMETRIA 0,000 CONTRA 0,005 DEL VANILLA y el reparto no se separa mas de 5 puntos del mapa a mano. Check-NMSGraft en salida 0 con _F02_SKINNED y los tres samplers. LO QUE ESTA MEDIDO Y NO SE ARREGLA, Y VA ESCRITO ANTES DE ENTRAR: EL DESPEGUE DEL SUELO. En roar el pivote de RootJNT sube 58 cm y en pounce el bicho entero sube 1,39 m. Eso es TRASLACION del propio .ANIM del juego, no giro, y la traslacion no se multiplica por la palanca ni la corrige ningun peso: mueve 1:1 todo lo que cuelgue del hueso. Si el lobo sigue pareciendo que vuela AL SALTAR, es esto y la malla no tiene la culpa; el vanilla hace el mismo salto con un bicho de 1,2 m y por eso no canta. LA FIRMA, ESCRITA ANTES DE ENTRAR. Si las patas traseras dejan de deformarse al rugir y al atacar, la causa era el tope ciego y cierra. Si dejan de deformarse pero el bicho sale TIESO de cuello, 140 se paso y el siguiente es 170, que ya esta medido. Si siguen deformandose igual, no era el vaiven de giro sino el reparto entre las dos traseras -la izquierda va a 1,6x y la derecha a 2,1x porque el espejo iguala solo la locomocion- y hay que igualarlas tambien en el tope. Si lo que se ve es que FLOTA al saltar, es la traslacion de arriba y no se toca. SUSTITUYE a HT_CryWolf_PRUEBA03, a la 02, a la 01 y a toda la serie HT_FiendMesh, que escriben los mismos archivos y NO PUEDEN CONVIVIR con esta.",
["ADD_FILES"]       = ENTREGA,
}
