RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\MODS\NMS_MOD_ZOMBIES\work\models\scuttlermesh]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\MODS\NMS_MOD_ZOMBIES\work\textures]]

DESTINO_MALLA    = [[MODELS\PLANETS\CREATURES\SPIDERRIG]]
DESTINO_MATERIAL = [[MODELS\PLANETS\CREATURES\SPIDERRIG\FREIGHTERFIEND]]
DESTINO_TEXTURA  = [[TEXTURES\PLANETS\CREATURES\SPIDERRIG]]
DESTINO_PROC     = [[TEXTURES\COMMON\PLAYER\PLAYERCHARACTER]]

ENTREGA =
{
  {
    ["COMMENT"]              = "Etapa 3e - mismo .SCENE injertado, con el AttackLight neutralizado entero",
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
    ["COMMENT"]              = "FFIENDMAT sin _F02_SKINNED y con gDiffuseMap en la textura propia",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FFIENDMAT.MATERIAL.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MATERIAL .. [[\FFIENDMAT.MATERIAL.MBIN]],
  },
  {
    ["COMMENT"]              = "Etapa 3b - color base propio, BC7 2048 con 12 mips",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\SKRULLCRAWLER.BASE.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\SKRULLCRAWLER.BASE.DDS]],
  },
  {
    ["COMMENT"]              = "Etapa 3c - lista procedural sin capas: que no componga y mande el gDiffuseMap",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FREIGHTERFIEND.TEXTURE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_PROC .. [[\FREIGHTERFIEND.TEXTURE.MBIN]],
  },
}

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_ScuttlerMesh_PRUEBA10",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.10.0] Etapa 3e: descarta la luz del bicho de una vez. La PRUEBA09 puso el INTENSITY del AttackLight a 0 y el brillo dorado siguio igual, asi que probar un solo campo no bastaba: ese nodo lleva ademas un MATERIAL, MATERIALS/LIGHT.MATERIAL.MBIN, que en NMS dibuja un destello y no depende del INTENSITY. Aqui se neutraliza el nodo entero, dejandolo clavado a Light_pointLight1, que es la luz inerte que ya vive en ese mismo .SCENE: RADIUS 0.0001, FALLOFF 0, COL 0,0,0 e INTENSITY 0. Si el bicho sigue dorado despues de esto, la luz queda descartada y el sospechoso pasa a ser el material, en concreto el gMasksMap, que es un ATI1 de un solo canal y deja sin datos los que el shader espera para rugosidad. Comprobado contra el vanilla: el .SCENE original trae ese mismo AttackLight encendido a INTENSITY 1.0 y con el mismo amarillo verdoso, y el SCUTTLER vanilla no es dorado, asi que la luz nunca fue una explicacion completa. Anotado tambien lo que falta: el injerto perdio el segundo nodo de malla, SUB1polySurface6 con FFIENDEYEMAT, que es el ojo. Solo cambia el .SCENE respecto a la PRUEBA09; sigue en 21889 bytes y Check-NMSGraft.py lo revalida. Sustituye a las PRUEBA01 a 09 y choca con HT_FiendMarkers_PRUEBA04 y con HorribleTerror_NecroSkin.",
["ADD_FILES"]       = ENTREGA,
}
