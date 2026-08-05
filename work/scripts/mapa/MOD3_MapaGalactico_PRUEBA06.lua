NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "MOD3_MapaGalactico_PRUEBA06",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "PRUEBA 06 del mod 3: control puro. No toca el mapa galactico. Pone dos opciones de GCDEBUGOPTIONS cuyo efecto es imposible de confundir con vanilla (RenderHud = false, InfiniteStamina = true) para responder una sola pregunta: si el ejecutable de release lee GCDEBUGOPTIONS. Experimento de dos campos, no es un mod publicable.",
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
              ["COMMENT"]            = "PRUEBA 06: control ruidoso, sin HUD no hay duda posible",
              ["REPLACE_TYPE"]       = "ALL",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"RenderHud", "false"},
              }
            },
            {
              ["COMMENT"]            = "PRUEBA 06: segundo control independiente",
              ["REPLACE_TYPE"]       = "ALL",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"InfiniteStamina", "true"},
              }
            },
          }
        },
      }
    }
  }
}
