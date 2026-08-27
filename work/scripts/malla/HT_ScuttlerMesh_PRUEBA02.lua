RAIZ_MALLA = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\models\scuttlermesh]]

DESTINO_MALLA    = [[MODELS\PLANETS\CREATURES\SPIDERRIG]]
DESTINO_MATERIAL = [[MODELS\PLANETS\CREATURES\SPIDERRIG\FREIGHTERFIEND]]

ENTREGA =
{
  {
    ["COMMENT"]              = "Etapa 3 - el SkrullCrawler en el sitio del cuerpo del SCUTTLER",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FREIGHTERFIEND.SCENE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FREIGHTERFIEND.SCENE.MBIN]],
  },
  {
    ["COMMENT"]              = "Etapa 3 - el SkrullCrawler en el sitio del cuerpo del SCUTTLER",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FREIGHTERFIEND.GEOMETRY.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FREIGHTERFIEND.GEOMETRY.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "Etapa 3 - el SkrullCrawler en el sitio del cuerpo del SCUTTLER",
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
["MOD_FILENAME"]    = "HT_ScuttlerMesh_PRUEBA02",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.2.0] Etapa 3 de la via Blender, segundo intento. La PRUEBA01 contesto la pregunta que se le puso: el juego SI aplica el skinning, y como nuestra malla no trae los canales SemanticID 5 y 6 -indices y pesos de hueso- cada vertice recibe una matriz que no le corresponde y la malla se estira sin forma. Lo importante es que renderiza y que el bicho sigue atacando: la geometria entra y la entidad funciona. Esta prueba apaga el camino que la deforma. Entrega el mismo trio de archivos que la PRUEBA01 mas una copia de FFIENDMAT.MATERIAL.MBIN sin la bandera _F02_SKINNED, que es la que enciende el skinning en el shader. Se conservan _F01_DIFFUSEMAP, _F03_NORMALMAP y _F25_MASKS_MAP. Si funciona, el SkrullCrawler saldra entero y rigido, moviendose por el mundo con la animacion de la raiz pero sin deformarse. Sigue con la textura vanilla estirada sobre nuestras UV, a proposito. Sustituye a HT_ScuttlerMesh_PRUEBA01 y choca con HT_FiendMarkers_PRUEBA04, que escribe el mismo FREIGHTERFIEND.SCENE.MBIN.",
["ADD_FILES"]       = ENTREGA,
}
