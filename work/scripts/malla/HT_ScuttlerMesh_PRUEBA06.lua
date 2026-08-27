RAIZ_MALLA = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\models\scuttlermesh]]

DESTINO_MALLA    = [[MODELS\PLANETS\CREATURES\SPIDERRIG]]
DESTINO_MATERIAL = [[MODELS\PLANETS\CREATURES\SPIDERRIG\FREIGHTERFIEND]]

ENTREGA =
{
  {
    ["COMMENT"]              = "Etapa 3 - el SkrullCrawler en el sitio del SCUTTLER",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FREIGHTERFIEND.SCENE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FREIGHTERFIEND.SCENE.MBIN]],
  },
  {
    ["COMMENT"]              = "GEOMETRY con los cuatro arrays por hueso y el MeshBaseSkinMat",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FREIGHTERFIEND.GEOMETRY.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FREIGHTERFIEND.GEOMETRY.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "Etapa 3 - el SkrullCrawler en el sitio del SCUTTLER",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FREIGHTERFIEND.GEOMETRY.DATA.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FREIGHTERFIEND.GEOMETRY.DATA.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "FFIENDMAT sin _F02_SKINNED: que el shader no deforme por huesos",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FFIENDMAT.MATERIAL.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MATERIAL .. [[\FFIENDMAT.MATERIAL.MBIN]],
  },
}

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_ScuttlerMesh_PRUEBA06",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.6.0] Etapa 3 de la via Blender: segundo intento contra el crash al matar un SCUTTLER. La PRUEBA05 devolvio JointExtents y JointMirrorPairs del vanilla y el juego seguia cerrando, porque los arrays que el .SCENE vanilla indexa no eran dos sino cinco, y NMSDK no escribe ninguno. Faltaban JointBindings, JointMirrorAxes -115 entradas cada uno, una por hueso mas una- y MeshBaseSkinMat, que iba vacio para una malla. Ahora se rellenan los cuatro arrays por hueso desde el vanilla, porque nuestros huesos son los suyos sin tocar, y el MeshBaseSkinMat se calcula del FIRSTSKINMAT de nuestra escena, que vale 0. SkinMatrixLayout se queda vacio a proposito: el nodo lo pide de 0 a 0, que es un rango vacio y no lee nada. Se comprueba antes de entrar al juego con tools/Check-NMSGraft.py, que cruza cada indice del .SCENE contra la longitud del array que lo recibe: pasa con el vanilla y fallaba con la PRUEBA05. Lo demas no cambia: 9592 triangulos, 11357 vertices, giro -90 en X mas 180 en Y, altura del vanilla, y FFIENDMAT sin _F02_SKINNED. El .GEOMETRY pasa de 10188 a 27212 bytes. Sustituye a las PRUEBA01 a 05 y choca con HT_FiendMarkers_PRUEBA04.",
["ADD_FILES"]       = ENTREGA,
}
