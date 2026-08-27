RAIZ_MALLA = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\models\scuttlermesh]]

DESTINO_MALLA    = [[MODELS\PLANETS\CREATURES\SPIDERRIG]]
DESTINO_MATERIAL = [[MODELS\PLANETS\CREATURES\SPIDERRIG\FREIGHTERFIEND]]

ENTREGA =
{
  {
    ["COMMENT"]              = "Etapa 3 - el SkrullCrawler de pie y mirando al derecho",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FREIGHTERFIEND.SCENE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FREIGHTERFIEND.SCENE.MBIN]],
  },
  {
    ["COMMENT"]              = "Etapa 3 - el SkrullCrawler de pie y mirando al derecho",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FREIGHTERFIEND.GEOMETRY.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FREIGHTERFIEND.GEOMETRY.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "Etapa 3 - el SkrullCrawler de pie y mirando al derecho",
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
["MOD_FILENAME"]    = "HT_ScuttlerMesh_PRUEBA04",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.4.0] Etapa 3 de la via Blender: la orientacion, tercer intento y esta vez comprobada fuera del juego. La PRUEBA02 lo saco de pie pero mirando al lado contrario; la PRUEBA03 le dio 180 en X y lo puso patas arriba, porque en X el giro lo tumba en vez de girarlo. La conversion buena es -90 en X, que pasa de Z-arriba a Y-arriba, mas 180 en Y para la media vuelta. Las tres candidatas se renderizaron antes de construir, en vez de averiguarlo yendo al carguero. Lo demas no cambia respecto a la PRUEBA02, que es la que cerro la pregunta grande: sin la bandera _F02_SKINNED en FFIENDMAT el juego no deforma la malla y el bicho sale entero y rigido. Son 9592 triangulos y 11357 vertices, a la altura del vanilla (1.8507) y sobre su mismo suelo. El .SCENE sigue siendo el vanilla injertado, con sus 114 nodos JOINT, las colisiones, las luces y el ATTACHMENT de la FREIGHTERFIEND.ENTITY. Sigue con la textura vanilla estirada sobre nuestras UV. Sustituye a las PRUEBA01, 02 y 03, y choca con HT_FiendMarkers_PRUEBA04.",
["ADD_FILES"]       = ENTREGA,
}
