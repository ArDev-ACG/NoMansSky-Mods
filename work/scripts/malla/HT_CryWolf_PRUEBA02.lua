RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\models\crywolfmesh_anim]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\textures]]

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
["MOD_FILENAME"]    = "HT_CryWolf_PRUEBA02",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.2.0] EL CRY WOLF, DADO LA VUELTA Y AL DOBLE DE TAMANO. Los mismos dos cambios que HT_WarriorBug_PRUEBA02 y por la misma peticion del usuario del 02/09 despues de ver la PRUEBA01 en partida. Las texturas, el atlas, el material y el injerto van byte a byte los de la PRUEBA01. EL GIRO VUELVE A 180 Y LO DECIDE LA PARTIDA, NO EL VOLCADO: la PRUEBA01 salio con giro (-90, 0) por el mismo volcado que al bug -nuestra parte alta en w 0,05 contra NewHeadJNT en w 1,51- y en partida salio DE ESPALDA igual. LA ALTURA PASA DE 1,90 A 3,80 m, o sea 2,8 veces el esqueleto FIEND de 1,34. Es MAS de lo que la receta recomienda y se entrega sabiendolo. EL MAPA DE REGIONES VA ESPEJADO, por lo mismo que el bug: el giro de 180 en Y espeja u y w de la caja, que es donde viven los cortes. Y EL TOPE DE VAIVEN PASA DE 120 A 200, con la ventana medida: por debajo de 155 la cabeza -vaiven peor 309- pierde su hueso y la manda NewBack1JNT, que es lo que la PRUEBA01 NO hacia; por encima de 250 las patas delanteras -506- se sueltan del pecho y la costura se va a 52-62 cm, o sea como si no hubiera agarre. Con 200 el reparto sale RootJNT 46,2% / NewHeadJNT 35,5% / NewBack1JNT 18,3%, que es el mismo que la PRUEBA01 -45,1 / 35,8 / 19,1-, con 7 huesos, 2,54 influencias por vertice y ASIMETRIA 0,000 CONTRA 0,005 DEL VANILLA. MEDIDO ANTES DE CONSTRUIR con Pose-NMSMesh.py: tension 27,3 andando, 30,0 corriendo y 28,5 atacando, contra los 16,2 / 12,6 / 15,0 de la PRUEBA01. La costura abre 45, 49 y 56 cm contra 10, 12 y 13, y ESE ES EL PRECIO DE DOBLARLO y va escrito aqui antes de entrar: sobre 3,80 m son el 12-15% del bicho, contra el 5-7% de la PRUEBA01. La causa esta medida y no es el mapa: la distancia media de un vertice a SU hueso pasa a 2,36 sobre una diagonal de 5,90, porque el esqueleto del juego no crece con nosotros. El flex se queda entre 3,20 y 5,39, o sea que la piel deforma de sobra. Check-NMSGraft en salida 0 con _F02_SKINNED y los tres samplers verificados. LA FIRMA, ESCRITA ANTES DE ENTRAR. Si sale mirando hacia donde anda y al doble, los dos cambios entran. Si sigue de espalda, el giro no esta en Export-NMSMesh.py. Si sale bien orientado pero el CUELLO o el PECHO abren al andar, es la costura de 45-56 cm que ya avisa esta medida, y se baja el tope de vaiven a 160 a cambio de tiesar la cabeza. Si se hunde o atraviesa cosas, es la COLISION del vanilla, que no se toca. SUSTITUYE a HT_CryWolf_PRUEBA02 y a toda la serie HT_FiendMesh, que escriben los mismos archivos y NO PUEDEN CONVIVIR con esta.",
["ADD_FILES"]       = ENTREGA,
}
