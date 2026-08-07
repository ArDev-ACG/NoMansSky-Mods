NECRO_DDS = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\textures\FIEND.BASE.DDS]]

FFIEND_TINT_R = "1.000000"
FFIEND_TINT_G = "0.150000"
FFIEND_TINT_B = "0.120000"

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HorribleTerror_NecroSkin",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.1.0] Dos vias de aspecto a la vez y en bichos distintos: el Horror Biologico lleva textura propia, el Horror de carguero lleva tinte de material.",
["ADD_FILES"] =
  {
    {
      ["COMMENT"]              = "Textura del Horror Biologico: BC7 2048x2048 12 mips, generada con tools/Make-NMSTexture.py",
      ["EXTERNAL_FILE_SOURCE"] = NECRO_DDS,
      ["FILE_DESTINATION"]     = [[TEXTURES\PLANETS\CREATURES\SPIDERRIG\FIEND.BASE.DDS]],
    },
  },
["MODIFICATIONS"]   =
  {
    {
      ["MBIN_CHANGE_TABLE"] =
      {
        {
          ["MBIN_FILE_SOURCE"] = "MODELS\PLANETS\CREATURES\SPIDERRIG\FREIGHTERFIEND\FFIENDMAT.MATERIAL.MBIN",
          ["MXML_CHANGE_TABLE"] =
          {
            {
              ["COMMENT"]            = "gMaterialColourVec4 -> rojo carne. No toca la textura, multiplica el color",
              ["SPECIAL_KEY_WORDS"]  = {"Name", "gMaterialColourVec4"},
              ["REPLACE_TYPE"]       = "ONCE",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"X", FFIEND_TINT_R},
                {"Y", FFIEND_TINT_G},
                {"Z", FFIEND_TINT_B},
              }
            },
          }
        },
      }
    },
  },
}
