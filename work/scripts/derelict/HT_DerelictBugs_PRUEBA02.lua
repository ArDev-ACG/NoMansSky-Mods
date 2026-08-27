NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_DerelictBugs_PRUEBA02",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.2.0] Media conversion: solo los barracones de los cargueros abandonados pasan a su version infestada. Carga, enfermeria y las ramas se quedan vanilla.",
["MODIFICATIONS"]   =
  {
    {
      ["MBIN_CHANGE_TABLE"] =
      {
        {
          ["MBIN_FILE_SOURCE"] = "METADATA\REALITY\TABLES\FREIGHTERDUNGEONSTABLE.MBIN",
          ["MXML_CHANGE_TABLE"] =
          {
            {
              ["COMMENT"]            = "Barracones: sala principal y regla de conteo -> version infestada (8 cambios)",
              ["REPLACE_TYPE"]       = "ALL",
              ["VALUE_MATCH"]        = "R_BARR",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"RoomID", "R_BUG_BARR"},
              }
            },
            {
              ["COMMENT"]            = "Barracones: objetos de mision -> version infestada (8 cambios)",
              ["REPLACE_TYPE"]       = "ALL",
              ["VALUE_MATCH"]        = "R_BARR",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"ValidRoomIDs", "R_BUG_BARR"},
              }
            },
            {
              ["COMMENT"]            = "Barracones pequenos: sala principal y regla de conteo -> version infestada (8 cambios)",
              ["REPLACE_TYPE"]       = "ALL",
              ["VALUE_MATCH"]        = "R_S_BARR",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"RoomID", "R_S_BUG_BARR"},
              }
            },
          }
        },
      }
    },
  },
}
