NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "MOD3_MapaGalactico_PRUEBA04",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "PRUEBA 04 del mod 3 (ruta B, repeticion de la 01 desplegada como MBIN): el Modulo de Mensajes usa la interaccion FreighterGalacticMap del terminal del puente. Experimento de un campo, no es un mod publicable.",
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
              ["COMMENT"]            = "PRUEBA 04: MessageModule -> FreighterGalacticMap",
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
