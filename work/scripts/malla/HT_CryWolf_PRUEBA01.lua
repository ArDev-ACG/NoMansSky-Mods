RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\MODS\NMS_MOD_ZOMBIES\work\models\crywolfmesh_anim]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\MODS\NMS_MOD_ZOMBIES\work\textures]]

DESTINO_MALLA    = [[MODELS\PLANETS\CREATURES\SPIDERRIG]]
DESTINO_MATERIAL = [[MODELS\PLANETS\CREATURES\SPIDERRIG\FIEND]]
DESTINO_TEXTURA  = [[TEXTURES\PLANETS\CREATURES\SPIDERRIG]]

ENTREGA =
{
  {
    ["COMMENT"]              = "El .SCENE vanilla del FIEND injertado con nuestra malla, con FIRSTSKINMAT 0 y LASTSKINMAT 7. Los 44 nodos JOINT, la colision, el ATTACHMENT y el .ENTITY siguen siendo los del juego, y el AttackLight va apagado por el acuerdo A1",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.SCENE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.SCENE.MBIN]],
  },
  {
    ["COMMENT"]              = "VertexLayout a stride 20 con los canales 2, 3, 5 y 6, SkinMatrixLayout de 7 huesos, y los cuatro arrays por hueso devueltos del vanilla por Patch-NMSGraft",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.GEOMETRY.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.GEOMETRY.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "El buffer de vertices: 11100 vertices exportados sobre 9672 de Blender, 513252 bytes, con el indice y el peso de hueso ya cosidos",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.GEOMETRY.DATA.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.GEOMETRY.DATA.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "FIEND_MAT con _F02_SKINNED y los TRES samplers apuntando a rutas propias CRYWOLF",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND_MAT.MATERIAL.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MATERIAL .. [[\FIEND_MAT.MATERIAL.MBIN]],
  },
  {
    ["COMMENT"]              = "Color base BC7 2048 con 12 mips. Atlas de los dos materiales del modelo -Main el cuerpo y SEC las costillas, el ojo y los bigotes- a 1024 cada uno, en 8 de 16 celdas",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\CRYWOLF.BASE.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\CRYWOLF.BASE.DDS]],
  },
  {
    ["COMMENT"]              = "Normal ATI2 2048 con 12 mips, ESCULPIDO EN EL ASSET y no inventado de la luminancia: este modelo si trae normal propio, y se atlasea con el mismo reparto de celdas que el color",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\CRYWOLF.BASE.NORMAL.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\CRYWOLF.BASE.NORMAL.DDS]],
  },
  {
    ["COMMENT"]              = "Mascaras ATI1 2048 sacadas de la RUGOSIDAD REAL del asset e invertidas por el acuerdo B5, porque el asset entrega rugosidad y el shader lee ese canal como brillo. Ni el zombie ni el necromorfo tenian esto: sus mascaras iban planas",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\CRYWOLF.BASE.MASKS.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\CRYWOLF.BASE.MASKS.DDS]],
  },
}

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_CryWolf_PRUEBA01",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.1.0] EL CRY WOLF SUSTITUYE AL NECROMORFO EN EL FIEND, Y ES UN MOD NUEVO QUE ARRANCA EN 0.1.0. SE ELIGIO CONTRA EL CRYING-HEAD Y CON UN MOTIVO MEDIDO: el crying-head es una esfera con veinte brazos radiales y su masa vive ARRIBA, o sea que repetiria por otra via el fallo del necromorfo; el cry wolf es un cuadrupedo con las cuatro manos apoyadas en el suelo -Z 0,01 a 0,06- cuello largo y cabeza, que es la anatomia del FIEND punto por punto. LA MALLA: dos mallas del .fbx unidas -el cuerpo y las costillas expuestas con el ojo y los bigotes-, 18920 triangulos que NO se decimaron porque ya caben, 9672 vertices que salen 11100 exportados, y CERO aristas de UV rotas de 56760. Los dos materiales van a un atlas de 2048 con 1024 por pieza. TRAE NORMAL Y RUGOSIDAD DE VERDAD, que es lo que ni el zombie ni el necromorfo tuvieron: sus normales se inventaban de la luminancia y sus mascaras iban planas a 87. Aqui los tres canales se atlasean con el MISMO reparto de celdas, asi que el relieve y el brillo caen exactamente encima del color, y la rugosidad va invertida por el acuerdo B5. SE QUITO EL COLOR DE VERTICE, y no es cosmetico: el .fbx trae una capa Col que NMSDK exporta como canal 4, cuatro bytes por vertice que dejaban el .GEOMETRY a stride 12 en vez de 8; con eso Skin-NMSGeometry aborta y el vanilla ni lo lee. LA ALTURA ES 1,90 m Y NO LOS 3,62 DEL NECROMORFO. El esqueleto del FIEND mide 1,34 m, asi que a 3,62 el 59,5% de la malla quedaba por encima del ultimo hueso y RootJNT se llevaba el 62,8% contra un tope de 25,5. A 1,90 el bicho sigue siendo 1,4 VECES el vanilla y el esqueleto cubre el 71% de la malla. LA ORIENTACION SE CORRIGIO: el giro en Y pasa de 180 a 0 porque nuestra cabeza caia en w 0,05 y la del vanilla en w 1,51, o sea montado mirando hacia atras, y el assert de orientacion del proyecto mide ALTURA y no podia cazarlo. LO QUE NO CASA ES LA PROPORCION, Y ESTA MEDIDO: el FIEND ocupa dentro de nuestra caja de w -0,47 a 1,64 y de v 0,08 a 0,70, o sea 4,4 m de largo por 1,2 de alto -3,5 a 1- contra el 1,1 a 1 del lobo, asi que sus patas delanteras y su cabeza caen POR DELANTE de nuestra malla. Por eso lleva mapa a mano de siete regiones, con los cortes sacados del histograma de nuestra malla: el eje w es bimodal, 4650 vertices en w 0,2-0,5 que son el cuerpo con las cuatro patas y 3174 en w 0,9-1,0 que son el cuello y la cabeza, el 34% del bicho. El eslabon es *Leg1JNT, el primero de la cadena y el primero con claves. SALE CON 7 HUESOS, 2,22 influencias por vertice y ASIMETRIA 0,000 CONTRA 0,005 DEL VANILLA. MEDIDO ANTES DE CONSTRUIR con Pose-NMSMesh.py: el mapa duro sin agarre daba tension 71,8 andando, 55,6 corriendo y 64,9 atacando, con la costura abriendo 61, 67 y 57 cm; con el agarre -las patas delanteras y la cabeza al pecho, las traseras a la cadera- y el tope de vaiven en 120 queda en 16,2 / 12,6 / 15,0 y abre 10, 12 y 13 cm. ESO ES MEJOR QUE EL ZOMBIE YA ACEPTADO, que iba en 11,5 / 17,0 / 13,0 y abria 7, 13 y 21 cm. El flex se queda entre 1,77 y 2,27, o sea que la piel SIGUE DEFORMANDO. Check-NMSGraft en salida 0 las dos veces, con _F02_SKINNED y los tres samplers verificados. LA FIRMA, ESCRITA ANTES DE ENTRAR. Si entra bien plantado, anda con las cuatro patas y el cuello no saca cuchilla, el conducto cierra. Si el cuello se estira, es la palanca de NewHeadJNT y hay que bajarle el alfa. Si sale rigido y de una pieza, es el flag y no el mapa. SUSTITUYE a toda la serie HT_FiendMesh, que escribe los mismos archivos y NO PUEDE CONVIVIR con esta.",
["ADD_FILES"]       = ENTREGA,
}
