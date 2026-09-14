RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\MODS\NMS_MOD_ZOMBIES\work\models\markermesh]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\MODS\NMS_MOD_ZOMBIES\work\textures]]

DESTINO_MALLA   = [[MODELS\PLANETS\BIOMES\COMMON\RARERESOURCE\GROUND]]
DESTINO_TEXTURA = [[TEXTURES\PLANETS\BIOMES\COMMON\RARERESOURCE\GROUND]]

MAT_MARKER_BASE   = "TEXTURES/PLANETS/BIOMES/COMMON/RARERESOURCE/GROUND/MARKER.BASE.DDS"
MAT_MARKER_NORMAL = "TEXTURES/PLANETS/BIOMES/COMMON/RARERESOURCE/GROUND/MARKER.BASE.NORMAL.DDS"

ARCHIVOS_MALLA =
{
  "FIENDEGG.SCENE.MBIN",
  "FIENDEGG.GEOMETRY.MBIN.PC",
  "FIENDEGG.GEOMETRY.DATA.MBIN.PC",
}

ARCHIVOS_TEXTURA =
{
  "MARKER.BASE.DDS",
  "MARKER.BASE.NORMAL.DDS",
}

ENTREGA = {}

for i = 1, #ARCHIVOS_MALLA do
  ENTREGA[#ENTREGA + 1] =
  {
    ["COMMENT"]              = "Etapa 2 - malla propia triangulada: el marker-1 entero en el sitio del huevo",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\]] .. ARCHIVOS_MALLA[i],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\]] .. ARCHIVOS_MALLA[i],
  }
end

for i = 1, #ARCHIVOS_TEXTURA do
  ENTREGA[#ENTREGA + 1] =
  {
    ["COMMENT"]              = "Etapa 2b - textura propia del marker, generada con tools/Make-NMSTexture.py",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\]] .. ARCHIVOS_TEXTURA[i],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\]] .. ARCHIVOS_TEXTURA[i],
  }
end

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_EggMesh_PRUEBA04",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.4.0] Etapa 2c de la via Blender. Arregla la malla de HT_EggMesh_PRUEBA03, a la que le faltaba un tercio de las caras: el .GEOMETRY solo traia 1098 de los 1636 triangulos porque el exportador de NMSDK toma otro camino cuando la malla tiene quads, y el marker tenia 806. Triangulada antes de exportar, el IndexDataSize pasa de 6592 a 9816 bytes, que es lo que exigen 4908 indices de 16 bits. El .SCENE es el mismo de siempre: el vanilla del huevo, que conserva el material EGGSHELL_MAT, la entidad FIENDEGG.ENTITY con FIENDHATCH y Health 125, y la esfera de colision de radio 0.395. Entrega tambien MARKER.BASE.DDS y MARKER.BASE.NORMAL.DDS y apunta a las dos el EGGSHELL_MAT del huevo de superficie. Sustituye a HT_EggMesh_PRUEBA02 y PRUEBA03: los tres escriben los mismos archivos de malla y no pueden estar puestos a la vez.",
["ADD_FILES"]       = ENTREGA,
["MODIFICATIONS"]   =
  {
    {
      ["MBIN_CHANGE_TABLE"] =
      {
        {
          ["MBIN_FILE_SOURCE"] = "MODELS\PLANETS\BIOMES\COMMON\RARERESOURCE\GROUND\FIENDEGG\EGGSHELL_MAT.MATERIAL.MBIN",
          ["MXML_CHANGE_TABLE"] =
          {
            {
              ["COMMENT"]            = "gDiffuseMap: del atlas de la cueva a la textura del marker",
              ["SPECIAL_KEY_WORDS"]  = {"Name", "gDiffuseMap"},
              ["REPLACE_TYPE"]       = "ONCE",
              ["VALUE_CHANGE_TABLE"] = { {"Map", MAT_MARKER_BASE} }
            },
            {
              ["COMMENT"]            = "gNormalMap: normales del marker, no las del huevo",
              ["SPECIAL_KEY_WORDS"]  = {"Name", "gNormalMap"},
              ["REPLACE_TYPE"]       = "ONCE",
              ["VALUE_CHANGE_TABLE"] = { {"Map", MAT_MARKER_NORMAL} }
            },
          }
        },
      }
    },
  },
}
