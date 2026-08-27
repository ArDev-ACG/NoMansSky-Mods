TENTACLE_MODEL = "MODELS/PLANETS/BIOMES/COMMON/BUILDINGS/PROPS/ABANDONED/INTERIOR_TENTACLEPLANT.SCENE.MBIN"
CONTROL_MODEL  = "MODELS/PLANETS/BIOMES/COMMON/BUILDINGS/DEBRIS/DEBRISLARGE_COMMON.SCENE.MBIN"
CONTROL_PROB   = "100.000000"

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_LocatorTest_PRUEBA01",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.1.0] Control del locator TENTACLE_ de los tres edificios abandonados. Pregunta unica: cuelga el locator una escena que no sea la suya? La planta del techo pasa a ser DEBRISLARGE_COMMON, la misma escena que el locator TECHBOX_ ya usa en ese mismo archivo, o sea una que el juego sabe instanciar ahi. Si sale el escombro, el conducto funciona y lo que fallo en 0.3.2 era la escena del huevo. Si no sale nada, el fallo es el locator. Experimento, no es un mod publicable.",
["MODIFICATIONS"]   =
  {
    {
      ["MBIN_CHANGE_TABLE"] =
      {
        {
          ["MBIN_FILE_SOURCE"] =
          {
            "MODELS\PLANETS\BIOMES\COMMON\BUILDINGS\ABANDONED\ABANDONDEDSCIENTIFIC.LSYSTEM.MBIN",
            "MODELS\PLANETS\BIOMES\COMMON\BUILDINGS\ABANDONED\ABANDONDEDTRADER.LSYSTEM.MBIN",
            "MODELS\PLANETS\BIOMES\COMMON\BUILDINGS\ABANDONED\ABANDONDEDWARRIOR.LSYSTEM.MBIN",
          },
          ["MXML_CHANGE_TABLE"] =
          {
            {
              ["COMMENT"]            = "Locator TENTACLE_: la planta pasa a ser el escombro que ya usa TECHBOX_",
              ["REPLACE_TYPE"]       = "ALL",
              ["VALUE_MATCH"]        = TENTACLE_MODEL,
              ["VALUE_CHANGE_TABLE"] = { {"Model", CONTROL_MODEL} }
            },
            {
              ["COMMENT"]            = "Ese locator sale siempre, no al 30%",
              ["SPECIAL_KEY_WORDS"]  = {"LocatorType", "TENTACLE_"},
              ["REPLACE_TYPE"]       = "ALL",
              ["VALUE_CHANGE_TABLE"] = { {"Probability", CONTROL_PROB} }
            },
          }
        },
      }
    },
  },
}
