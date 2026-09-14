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
    ["COMMENT"]              = "Etapa 2 - malla propia: el marker-1 en el sitio del huevo",
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
["MOD_FILENAME"]    = "HT_EggMesh_PRUEBA03",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.3.0] Etapa 2b de la via Blender. Igual que HT_EggMesh_PRUEBA02 - el marker-1 en el sitio del huevo de Fiend - y ademas le pone su propia textura. Entrega MARKER.BASE.DDS (BC7 2048x2048 12 mips, color base del marker con el mapa de emision horneado encima, porque el glow real no esta resuelto) y MARKER.BASE.NORMAL.DDS (ATI2/BC5 2048x2048 12 mips, canales R=X G=Y como el vanilla), y apunta a las dos el EGGSHELL_MAT del huevo de superficie, que es un archivo exclusivo suyo: el huevo de cueva y el de carguero tienen su propia copia y no se tocan. El mapa de mascaras se deja vanilla a proposito, porque no se sabe que canal es que cosa. Sustituye a HT_EggMesh_PRUEBA02: los dos escriben los mismos tres archivos de malla y no pueden estar puestos a la vez.",
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
