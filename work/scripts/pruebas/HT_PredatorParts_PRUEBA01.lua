QUITAR =
{
  "_RATBACK_25", "_RATBACK_2XRARE", "_RATBACK_4XRARE", "_RATBACK_3A",
  "_RATBACK_1N", "_RATBACK_2N", "_RATBACK_3N", "_RATBACK_4N",
  "_RATBACK_5N", "_RATBACK_6N", "_RATBACK_12OK", "_RATBACK_11OK", "_RATBACK_24OK",
  "_REXBACK_0", "_REXBACK_2XRARE", "_REXBACK_4XRARE", "_REXBACK_3A",
  "_REXBACK_1N", "_REXBACK_2N", "_REXBACK_3N", "_REXBACK_4N",
  "_REXBACK_5N", "_REXBACK_6N", "_REXBACK_12OK", "_REXBACK_11OK", "_REXBACK_24OK",
}

CT = {}
for _, id in ipairs(QUITAR) do
  CT[#CT+1] =
  {
    ["COMMENT"]           = "quita la opcion "..id,
    ["SPECIAL_KEY_WORDS"] = {"Id", id},
    ["REPLACE_TYPE"]      = "ONCE",
    ["CREATE_HOES"]       = "TRUE",
    ["REMOVE"]            = "SECTION",
  }
end

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_PredatorParts_PRUEBA01",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.1.0] Pregunta unica: si se borran opciones de una categoria del descriptor, la fauna procedural pierde esa variacion sin romperse? Solo TREXRIG, solo las dos categorias de lomo, de 15 opciones se dejan 2. _BODY_TREX y _BODY_HOLESXRARE NO se tocan: son otra rama de cuerpo, no un lomo.",
["MODIFICATIONS"]   =
  {
    {
      ["MBIN_CHANGE_TABLE"] =
      {
        {
          ["MBIN_FILE_SOURCE"]  = "MODELS\PLANETS\CREATURES\TREXRIG\TREX.DESCRIPTOR.MBIN",
          ["MXML_CHANGE_TABLE"] = CT,
        },
      }
    },
  },
}
