NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "MOD3_MapaGalactico_PRUEBA01",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "PRUEBA 01 del mod 3: el Modulo de Mensajes abre el mapa galactico. Experimento de un campo, no es un mod publicable.",
["MODIFICATIONS"]   =
  {
    {
      ["MBIN_CHANGE_TABLE"] =
      {
        {
          ["MBIN_FILE_SOURCE"] = "MODELS\PLANETS\BIOMES\COMMON\BUILDINGS\PARTS\BUILDABLEPARTS\TECH\MESSAGEMODULE\ENTITIES\MESSAGEMODULE.ENTITY.MBIN",
          ["MXML_CHANGE_TABLE"] =
          {
            {
              ["COMMENT"]            = "PRUEBA: MessageModule -> FreighterGalacticMap",
              ["REPLACE_TYPE"]       = "ALL",
              ["VALUE_MATCH"]        = "MessageModule",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"InteractionType", "FreighterGalacticMap"},
              }
            },
          }
        },
      }
    }
  }
}
