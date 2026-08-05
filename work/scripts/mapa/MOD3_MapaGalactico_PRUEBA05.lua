NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "MOD3_MapaGalactico_PRUEBA05",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "PRUEBA 05 del mod 3 (ruta E, el menu rapido si es dato): DebugGalaxyMapInQuickMenu = true para que el mapa galactico salga en el menu rapido a pie. ForceNexusInQuickMenu = true como control, para saber si el juego lee GCDEBUGOPTIONS. Experimento de dos campos, no es un mod publicable.",
["MODIFICATIONS"]   =
  {
    {
      ["MBIN_CHANGE_TABLE"] =
      {
        {
          ["MBIN_FILE_SOURCE"] = "GLOBALS\GCDEBUGOPTIONS.GLOBAL.MBIN",
          ["MXML_CHANGE_TABLE"] =
          {
            {
              ["COMMENT"]            = "PRUEBA 05: mapa galactico en el menu rapido",
              ["REPLACE_TYPE"]       = "ALL",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"DebugGalaxyMapInQuickMenu", "true"},
              }
            },
            {
              ["COMMENT"]            = "PRUEBA 05: control, dice si el juego lee este archivo",
              ["REPLACE_TYPE"]       = "ALL",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"ForceNexusInQuickMenu", "true"},
              }
            },
          }
        },
      }
    }
  }
}
