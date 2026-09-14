RAIZ_MALLA = os.getenv("USERPROFILE") .. [[\MODS\NMS_MOD_ZOMBIES\work\models\scuttlermesh]]

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
    ["COMMENT"]              = "GEOMETRY con los JointExtents y JointMirrorPairs del vanilla devueltos",
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
["MOD_FILENAME"]    = "HT_ScuttlerMesh_PRUEBA05",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.5.0] Etapa 3 de la via Blender: arregla el crash al matar un SCUTTLER. Con la PRUEBA04 el bicho salia entero, rigido y bien orientado, pero el juego se caia al destruir uno. La FREIGHTERFIEND.ENTITY trae GcRagdollComponentData y GcEasyRagdollSetUpData: al morir hace ragdoll y recorre los 114 nodos JOINT que el .SCENE conserva, leyendo para cada hueso su entrada en JointExtents. El .GEOMETRY que exporta NMSDK trae ese array VACIO, y tambien JointMirrorPairs, asi que la lectura se salia del array. Esta version devuelve los dos arrays del vanilla, 115 entradas cada uno: son datos por HUESO, no por malla, y los huesos son los del vanilla sin tocar, asi que se corresponden uno a uno. No se copian SkinMatrixLayout ni MeshBaseSkinMat, que si describen como se reparte una malla concreta sobre los huesos y la nuestra no es la de ellos. El .GEOMETRY pasa de 4214 a 10188 bytes. Lo demas no cambia: 9592 triangulos, 11357 vertices, giro -90 en X mas 180 en Y, altura del vanilla, y FFIENDMAT sin _F02_SKINNED. Sustituye a las PRUEBA01 a 04 y choca con HT_FiendMarkers_PRUEBA04.",
["ADD_FILES"]       = ENTREGA,
}
