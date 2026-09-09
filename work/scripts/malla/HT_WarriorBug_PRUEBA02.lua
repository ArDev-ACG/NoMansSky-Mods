RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\models\warriorbugmesh_anim]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\textures]]

DESTINO_MALLA    = [[MODELS\PLANETS\CREATURES\ARTHROPOD]]
DESTINO_MATERIAL = [[MODELS\PLANETS\CREATURES\ARTHROPOD\BUGFIEND]]
DESTINO_TEXTURA  = [[TEXTURES\PLANETS\CREATURES\ARTHROPOD\THORAX]]

ENTREGA =
{
  {
    ["COMMENT"]              = "El .SCENE vanilla del BUGFIEND injertado con nuestra malla, con FIRSTSKINMAT 0 y LASTSKINMAT 7. Los 53 nodos JOINT, la colision, el ATTACHMENT y el .ENTITY siguen siendo los del juego: lo unico que cambia es de que vertices esta hecho el bicho",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.SCENE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.SCENE.MBIN]],
  },
  {
    ["COMMENT"]              = "VertexLayout a stride 20 con los canales 2, 3, 5 y 6, SkinMatrixLayout de 7 huesos, y los cuatro arrays por hueso devueltos del vanilla por Patch-NMSGraft",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.GEOMETRY.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.GEOMETRY.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "El buffer de vertices: 20257 vertices exportados sobre 18063 de Blender, 945388 bytes, con el indice y el peso de hueso ya cosidos",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.GEOMETRY.DATA.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.GEOMETRY.DATA.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "El descriptor recortado a UNA entrada, _Arthropod_1 sin hijos, igual que en la serie del zombie. Con los nodos MESH borrados por el injerto, el descriptor completo cierra el juego al parir el Horror",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.DESCRIPTOR.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.DESCRIPTOR.MBIN]],
  },
  {
    ["COMMENT"]              = "ARTHROPODTHORAX01MAT con _F02_SKINNED y los TRES samplers apuntando a rutas propias WARRIORBUG. Las ARTHROPODTHORAX01.BASE*.DDS las comparte toda la fauna artropodo del juego",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\ARTHROPODTHORAX01MAT.MATERIAL.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MATERIAL .. [[\ARTHROPODTHORAX01MAT.MATERIAL.MBIN]],
  },
  {
    ["COMMENT"]              = "Color base BC7 2048 con 12 mips. Atlas de las DOCE texturas del modelo en 12 de 16 celdas de 512. Va a 2048 y no a los 1024 del ARTHROPOD vanilla porque doce trozos en 1024 dejarian 256 pixeles por pieza",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\WARRIORBUG.BASE.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\WARRIORBUG.BASE.DDS]],
  },
  {
    ["COMMENT"]              = "Normal ATI2 2048 con 12 mips, sacado de la luminancia del atlas con Make-NMSNormal y con el relieve apagado en el borde de cada isla de UV. El modelo no trae normal propio",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\WARRIORBUG.BASE.NORMAL.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\WARRIORBUG.BASE.NORMAL.DDS]],
  },
  {
    ["COMMENT"]              = "Mascaras ATI1 2048 propias, planas a 87, que es el mismo valor del zombie y del necromorfo y lo que mide el vanilla. El modelo no trae rugosidad propia",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\WARRIORBUG.BASE.MASKS.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\WARRIORBUG.BASE.MASKS.DDS]],
  },
}

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_WarriorBug_PRUEBA02",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.2.0] EL WARRIOR BUG, DADO LA VUELTA Y AL DOBLE DE TAMANO. Dos cambios pedidos por el usuario el 02/09 despues de ver la PRUEBA01 en partida -se ve bien, pero dale la vuelta, esta de espalda, y hazla el doble-, y NADA MAS: las texturas, el atlas, el material y el injerto van byte a byte los de la PRUEBA01. EL GIRO VUELVE A 180 Y LO DECIDE LA PARTIDA, NO EL VOLCADO. La PRUEBA01 salio con giro (-90, 0) porque el decimo superior de la malla caia en w 0,38 contra la cabeza vanilla en w 0,84; en partida salio DE ESPALDA, o sea que ese volcado media otra cosa -el decimo superior de un insecto son las patas levantadas, no la cabeza- y el 180 que ya usaban las otras tres entradas del conducto era el bueno. LA ALTURA PASA DE 1,80 A 3,60 m, o sea 3,4 veces el esqueleto ARTHROPOD de 1,05. Es MAS de lo que la receta recomienda -1,4 a 1,7 veces- y se entrega sabiendolo: es peticion expresa y esta medido antes de construir. Y DOBLAR LA MALLA NO ES SOLO ESCALARLA, QUE ES EL HALLAZGO DE ESTA ENTREGA. El mapa a mano de regiones trabaja en coordenadas NORMALIZADAS de nuestra caja, asi que la escala no lo toca; pero el GIRO DE 180 EN Y ESPEJA DOS DE SUS TRES EJES, u y w, y con los cortes viejos la region de la cabeza cazaba la punta del abdomen -759 vertices en vez de 2665- y spine_C0_0_jnt pasaba a mandar el 92,2% contra un tope de 85. Los siete cortes van espejados: es la misma linea con u -> 1-u y w -> 1-w. Y EL TOPE DE VAIVEN NO ES ESCALA-INVARIANTE. El vaiven es giro por PALANCA, y la palanca es la distancia de la region al pivote partida por el tamano de la region: el esqueleto NO escala con nosotros, asi que doblar la malla sube la palanca MAS del doble -la cabeza pasa de 4,4x a 7,0x-. Con el tope quieto en 120 el agarre de la cabeza subia al 76% y spine se llevaba el 90,1%, o sea que doblar el bicho lo dejaba TIESO. El tope nuevo es 300 y no sale a ojo: es una ventana medida, por debajo de 255 la cabeza pierde su hueso y por encima de 375 las patas delanteras se sueltan del torax. Con 300 el reparto sale spine 78,3% / head 11,8% / tail 9,9%, que es el mismo que la PRUEBA01 -76,9 / 13,2 / 9,9-, con 7 huesos, 2,42 influencias por vertice y ASIMETRIA 0,000 CONTRA 0,018 DEL VANILLA. MEDIDO ANTES DE CONSTRUIR con Pose-NMSMesh.py, que deforma la malla con los .ANIM del juego fuera de la partida: tension 13,6 andando, 24,2 corriendo y 28,6 atacando, contra los 25,9 / 38,7 / 55,3 de la PRUEBA01, o sea que EL BICHO DOBLE SE TENSA MENOS QUE EL PEQUENO. La costura abre 12, 22 y 32 cm contra 11, 17 y 28, o sea que crece mucho menos que la malla. El flex se queda entre 1,14 y 2,63: la piel SIGUE DEFORMANDO y esto no es una estatua. Check-NMSGraft en salida 0 con _F02_SKINNED puesto y los tres samplers verificados. LA FIRMA, ESCRITA ANTES DE ENTRAR. Si el bicho sale MIRANDO HACIA DONDE ANDA y al doble, los dos cambios entran y solo queda afinar. Si sigue de espalda, el giro no esta en Export-NMSMesh.py sino en el injerto y hay que mirar el nodo del .SCENE. Si sale bien orientado pero las patas van a destiempo, es el espejo del mapa: nuestras patas delanteras cuelgan del par 0 del vanilla y ahora caen donde esta el par 2. Si se hunde en el suelo o atraviesa cosas, es la COLISION, que es la del vanilla de 1,05 m y no se toca. SUSTITUYE a HT_WarriorBug_PRUEBA02 y a toda la serie HT_ZombieMesh, que escriben los mismos archivos y NO PUEDEN CONVIVIR con esta.",
["ADD_FILES"]       = ENTREGA,
}
