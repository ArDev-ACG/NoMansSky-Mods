RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\models\scuttlermesh]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\textures]]

DESTINO_MALLA    = [[MODELS\PLANETS\CREATURES\SPIDERRIG]]
DESTINO_MATERIAL = [[MODELS\PLANETS\CREATURES\SPIDERRIG\FREIGHTERFIEND]]
DESTINO_TEXTURA  = [[TEXTURES\PLANETS\CREATURES\SPIDERRIG]]

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
    ["COMMENT"]              = "FFIENDMAT sin _F02_SKINNED y con gDiffuseMap en la textura propia",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FFIENDMAT.MATERIAL.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MATERIAL .. [[\FFIENDMAT.MATERIAL.MBIN]],
  },
  {
    ["COMMENT"]              = "Etapa 3b - color base propio, BC7 2048 con 12 mips",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\SKRULLCRAWLER.BASE.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\SKRULLCRAWLER.BASE.DDS]],
  },
}

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_ScuttlerMesh_PRUEBA07",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.7.0] Etapa 3b: el SCUTTLER deja de llevar la textura vanilla estirada y pasa a la suya. Anade SKRULLCRAWLER.BASE.DDS, BC7 2048x2048 con 12 mips, generada con tools/Make-NMSTexture.py desde el PNG de color base del asset Meshy_AI_Skullcrawler, que ya venia a 2048 y no hubo que reescalar. La cabecera DDS se copia byte a byte de freighterfiend.base.dds, asi que la salida pesa los mismos 5592580 bytes que el donante. El gDiffuseMap del FFIENDMAT apunta a la textura nueva en vez de a FREIGHTERFIEND.BASE.DDS. Se entrega como archivo nuevo y no sobrescribiendo la vanilla a proposito: las tres texturas del FreighterFiend las comparte MINIFIEND_PET, que es la mascota domesticada del jugador, y el mod la protege en todas partes. gNormalMap y gMasksMap se quedan en las vanilla: una variable por prueba, y el normal es el que dira si hace falta fabricar uno. El tinte gMaterialColourVec4 sigue neutro en 1,1,1 hasta ver el bicho texturado. Lo demas no cambia respecto a la PRUEBA06: misma malla de 11357 vertices y 9592 triangulos, mismo .SCENE vanilla injertado, los cuatro arrays por hueso a 115 y el MeshBaseSkinMat. Sustituye a las PRUEBA01 a 06 y choca con HT_FiendMarkers_PRUEBA04 y con HorribleTerror_NecroSkin, que escribe el mismo FFIENDMAT con _F02_SKINNED puesto.",
["ADD_FILES"]       = ENTREGA,
}
