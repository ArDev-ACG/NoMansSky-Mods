LOMOS =
{
  "_RATBACK_25", "_RATBACK_2XRARE", "_RATBACK_4XRARE", "_RATBACK_3A",
  "_RATBACK_1N", "_RATBACK_2N", "_RATBACK_3N", "_RATBACK_4N",
  "_RATBACK_5N", "_RATBACK_6N", "_RATBACK_12OK", "_RATBACK_11OK", "_RATBACK_24OK",
  "_REXBACK_0", "_REXBACK_2XRARE", "_REXBACK_4XRARE", "_REXBACK_3A",
  "_REXBACK_1N", "_REXBACK_2N", "_REXBACK_3N", "_REXBACK_4N",
  "_REXBACK_5N", "_REXBACK_6N", "_REXBACK_12OK", "_REXBACK_11OK", "_REXBACK_24OK",
}

CABEZAS =
{
  "_HEAD_BIRDREX", "_HEAD_LIZ", "_HEAD_RHINO",
  "_HEAD_CROC", "_HEAD_RAT", "_HEAD_TOUCANA",
}

CT = {}

function Borrar(ids, etiqueta)
  for _, id in ipairs(ids) do
    CT[#CT+1] =
    {
      ["COMMENT"]           = etiqueta.." "..id,
      ["SPECIAL_KEY_WORDS"] = {"Id", id},
      ["REPLACE_TYPE"]      = "ONCE",
      ["REMOVE"]            = "SECTION",
    }
  end
end

Borrar(LOMOS,   "quita el lomo")
Borrar(CABEZAS, "quita la rama de cabeza")

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_PredatorParts_PRUEBA03",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.3.0] Identica a la PRUEBA02 salvo una variable: se quita CREATE_HOES. Con el flag puesto AMUMSS conserva la cabecera de la seccion borrada, asi que la lista no encoge y quedan ranuras huecas: _HEAD_ seguia teniendo 8 entradas con 6 vacias. Sin el flag deben desaparecer los elementos enteros y quedar _HEAD_ con 2, _RATBACK_ con 1 y _REXBACK_ con 1. Si MBINCompiler no recompila, la respuesta es que el aviso del manual aplica aqui. Experimento, no es un mod publicable.",
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
