NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HorribleTerror_DerelictBugs",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.1.0] Los cargueros abandonados salen infestados: las salas limpias de los interiores TURRETS y MAZE pasan a su version con Horrores. FLOATERS y SLIME se quedan como estan.",
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
              ["COMMENT"]            = "Barracones -> barracones infestados",
              ["REPLACE_TYPE"]       = "ALL",
              ["VALUE_MATCH"]        = "R_BARR",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"RoomID",       "R_BUG_BARR"},
                {"RoomId",       "R_BUG_BARR"},
                {"ValidRoomIDs", "R_BUG_BARR"},
                {"BranchRoomTypes", "R_BUG_BARR"},
              }
            },
            {
              ["COMMENT"]            = "Barracones pequenos -> infestados",
              ["REPLACE_TYPE"]       = "ALL",
              ["VALUE_MATCH"]        = "R_S_BARR",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"RoomID",       "R_S_BUG_BARR"},
                {"RoomId",       "R_S_BUG_BARR"},
                {"ValidRoomIDs", "R_S_BUG_BARR"},
                {"BranchRoomTypes", "R_S_BUG_BARR"},
              }
            },
            {
              ["COMMENT"]            = "Carga -> carga infestada",
              ["REPLACE_TYPE"]       = "ALL",
              ["VALUE_MATCH"]        = "R_CARG",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"RoomID",       "R_BUG_CARG"},
                {"RoomId",       "R_BUG_CARG"},
                {"ValidRoomIDs", "R_BUG_CARG"},
                {"BranchRoomTypes", "R_BUG_CARG"},
              }
            },
            {
              ["COMMENT"]            = "Carga pequena -> infestada",
              ["REPLACE_TYPE"]       = "ALL",
              ["VALUE_MATCH"]        = "R_S_CARG",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"RoomID",       "R_S_BUG_CARG"},
                {"RoomId",       "R_S_BUG_CARG"},
                {"ValidRoomIDs", "R_S_BUG_CARG"},
                {"BranchRoomTypes", "R_S_BUG_CARG"},
              }
            },
            {
              ["COMMENT"]            = "Enfermeria -> enfermeria infestada",
              ["REPLACE_TYPE"]       = "ALL",
              ["VALUE_MATCH"]        = "R_MEDI",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"RoomID",       "R_BUG_MEDI"},
                {"RoomId",       "R_BUG_MEDI"},
                {"ValidRoomIDs", "R_BUG_MEDI"},
                {"BranchRoomTypes", "R_BUG_MEDI"},
              }
            },
            {
              ["COMMENT"]            = "Enfermeria pequena -> infestada",
              ["REPLACE_TYPE"]       = "ALL",
              ["VALUE_MATCH"]        = "R_S_MEDI",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"RoomID",       "R_S_BUG_MEDI"},
                {"RoomId",       "R_S_BUG_MEDI"},
                {"ValidRoomIDs", "R_S_BUG_MEDI"},
                {"BranchRoomTypes", "R_S_BUG_MEDI"},
              }
            },
            {
              ["COMMENT"]            = "Ramas: las tres limpias pasan a su version con bichos",
              ["REPLACE_TYPE"]       = "ALL",
              ["VALUE_MATCH"]        = "B_BARR",
              ["VALUE_CHANGE_TABLE"] = { {"BranchRoomTypes", "B_BUG_BARR"} }
            },
            {
              ["COMMENT"]            = "Ramas de carga",
              ["REPLACE_TYPE"]       = "ALL",
              ["VALUE_MATCH"]        = "B_CARG",
              ["VALUE_CHANGE_TABLE"] = { {"BranchRoomTypes", "B_BUG_CARG"} }
            },
            {
              ["COMMENT"]            = "Ramas de enfermeria",
              ["REPLACE_TYPE"]       = "ALL",
              ["VALUE_MATCH"]        = "B_MEDI",
              ["VALUE_CHANGE_TABLE"] = { {"BranchRoomTypes", "B_BUG_MED"} }
            },
          }
        },
      }
    },
  },
}
