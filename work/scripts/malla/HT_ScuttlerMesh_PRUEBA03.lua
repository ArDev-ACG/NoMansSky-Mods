RAIZ_MALLA = os.getenv("USERPROFILE") .. [[\MODS\NMS_MOD_ZOMBIES\work\models\scuttlermesh]]

DESTINO_MALLA    = [[MODELS\PLANETS\CREATURES\SPIDERRIG]]
DESTINO_MATERIAL = [[MODELS\PLANETS\CREATURES\SPIDERRIG\FREIGHTERFIEND]]

ENTREGA =
{
  {
    ["COMMENT"]              = "Etapa 3 - el SkrullCrawler en el sitio del cuerpo del SCUTTLER, del derecho",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FREIGHTERFIEND.SCENE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FREIGHTERFIEND.SCENE.MBIN]],
  },
  {
    ["COMMENT"]              = "Etapa 3 - el SkrullCrawler en el sitio del cuerpo del SCUTTLER, del derecho",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FREIGHTERFIEND.GEOMETRY.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FREIGHTERFIEND.GEOMETRY.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "Etapa 3 - el SkrullCrawler en el sitio del cuerpo del SCUTTLER, del derecho",
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
["MOD_FILENAME"]    = "HT_ScuttlerMesh_PRUEBA03",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.3.0] Etapa 3 de la via Blender. La PRUEBA02 cerro la pregunta grande: quitando la bandera _F02_SKINNED del material, el SkrullCrawler sale ENTERO Y RIGIDO en el sitio del SCUTTLER. Hay criaturas propias en el mod, sin deformacion por huesos pero con su volumen y moviendose por el mundo. Lo unico que quedaba mal era la orientacion: el bicho salia boca abajo. Esta version le da los 180 grados en X que faltaban. La conversion completa desde el FBX es girar +90 en X, no -90: Blender es Z-arriba y NMS es Y-arriba, pero ademas el modelo venia del reves. La malla son 9592 triangulos y 11357 vertices, escalada para igualar el alto del vanilla (1.8507) y apoyada en su mismo suelo (AABBMINY -0.020806). El .SCENE es el vanilla injertado: conserva los 114 nodos JOINT, las dos colisiones, las dos luces y el ATTACHMENT con la FREIGHTERFIEND.ENTITY, y solo cambian los 17 atributos que describen la malla mas el borrado del nodo del ojo. Sigue con la textura vanilla estirada sobre nuestras UV: la textura propia es el paso siguiente. Sustituye a HT_ScuttlerMesh_PRUEBA01 y PRUEBA02, y choca con HT_FiendMarkers_PRUEBA04.",
["ADD_FILES"]       = ENTREGA,
}
