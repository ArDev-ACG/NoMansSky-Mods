RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\models\markermesh]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\textures]]

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
    ["COMMENT"]              = "Etapa 2 - malla propia triangulada y a escala: el marker-1 en el sitio del huevo",
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
["MOD_FILENAME"]    = "HT_EggMesh_PRUEBA05",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.5.0] Etapa 2d de la via Blender. Arregla el tamano de HT_EggMesh_PRUEBA04, que salia del tamano de una montana. El exportador de NMSDK escribe las coordenadas locales de los vertices e ignora la escala del objeto: el FBX del marker importa con scale 0.01, asi que en Blender se veia de 1,63 m y al juego iba de 163. Aplicada la escala antes de exportar, la malla mide 1,6335 en local, que es justo el AABB que ya declaraba el .SCENE (0.008757 a 1.642224) y algo mas del doble del huevo vanilla, que mide 0.7615. Conserva lo de la PRUEBA04: 1636 triangulos completos e IndexDataSize 9816. El .SCENE sigue siendo el vanilla del huevo, con EGGSHELL_MAT, la FIENDEGG.ENTITY con FIENDHATCH y Health 125, y la colision de radio 0.395. Entrega tambien MARKER.BASE.DDS y MARKER.BASE.NORMAL.DDS. Sustituye a las PRUEBA02, 03 y 04: todas escriben los mismos archivos de malla y no pueden estar puestas a la vez.",
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
