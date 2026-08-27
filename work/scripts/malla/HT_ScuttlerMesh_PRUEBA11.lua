RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\models\scuttlermesh]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\textures]]

DESTINO_MALLA    = [[MODELS\PLANETS\CREATURES\SPIDERRIG]]
DESTINO_MATERIAL = [[MODELS\PLANETS\CREATURES\SPIDERRIG\FREIGHTERFIEND]]
DESTINO_TEXTURA  = [[TEXTURES\PLANETS\CREATURES\SPIDERRIG]]
DESTINO_PROC     = [[TEXTURES\COMMON\PLAYER\PLAYERCHARACTER]]

ENTREGA =
{
  {
    ["COMMENT"]              = "Etapa 3e - .SCENE injertado con el AttackLight neutralizado entero",
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
    ["COMMENT"]              = "FFIENDMAT sin _F02_SKINNED, con el color y las mascaras propias",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FFIENDMAT.MATERIAL.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MATERIAL .. [[\FFIENDMAT.MATERIAL.MBIN]],
  },
  {
    ["COMMENT"]              = "Etapa 3b - color base propio, BC7 2048 con 12 mips",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\SKRULLCRAWLER.BASE.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\SKRULLCRAWLER.BASE.DDS]],
  },
  {
    ["COMMENT"]              = "Etapa 3f - mascaras propias, ATI1 de un canal desde el roughness del asset",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\SKRULLCRAWLER.BASE.MASKS.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\SKRULLCRAWLER.BASE.MASKS.DDS]],
  },
  {
    ["COMMENT"]              = "Etapa 3c - lista procedural sin capas: que no componga y mande el gDiffuseMap",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FREIGHTERFIEND.TEXTURE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_PROC .. [[\FREIGHTERFIEND.TEXTURE.MBIN]],
  },
}

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_ScuttlerMesh_PRUEBA11",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.11.0] Etapa 3f: las mascaras dejan de ser las del bicho vanilla. Hasta ahora el gMasksMap apuntaba a FREIGHTERFIEND.BASE.MASKS.DDS, que esta pintado para las UV del SCUTTLER original y no para las nuestras, asi que el brillo y lo mate caian donde no tocaba. Anade SKRULLCRAWLER.BASE.MASKS.DDS, ATI1 de 2048x2048 con 12 mips, sacada del mapa de roughness del asset. El formato del slot es ATI1, o sea un solo canal, y ese canal se comporta como rugosidad: la vanilla da media 189.3 y mediana 196, y el roughness del asset da media 173.7 y mediana 199, asi que el nivel general de sombreado no salta y lo unico que cambia es donde cae cada cosa. Para generarla hubo que ampliar tools/Make-NMSTexture.py a BC4, que ya tenia escrito el bloque porque el BC5 son dos seguidos; se le anaden las opciones --canal y --invertir. El codificador se verifico descodificando la salida: error medio 0.47 sobre 255 y maximo 18, que es compresion BC4 normal. El .DDS pesa 2796344 bytes, los mismos que su donante. Lo demas no cambia respecto a la PRUEBA10. Queda pendiente el gNormalMap, que sigue siendo el vanilla, y recuperar el nodo de malla del ojo. Sustituye a las PRUEBA01 a 10 y choca con HT_FiendMarkers_PRUEBA04 y con HorribleTerror_NecroSkin.",
["ADD_FILES"]       = ENTREGA,
}
