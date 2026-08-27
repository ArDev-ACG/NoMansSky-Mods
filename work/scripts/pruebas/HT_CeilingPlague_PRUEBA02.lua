NIDO_CARGUERO = "MODELS\PLANETS\BIOMES\COMMON\BUILDINGS\PARTS\BUILDABLEPARTS\SPACEBASE\INFESTATION\MEDIUMHANGSLIME.SCENE.MBIN"
GIRO_Z        = "0.000000"
BAJADA_Y      = "-4.000000"

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_CeilingPlague_PRUEBA02",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.2.0] La plaga del carguero colgada del techo de los edificios abandonados, corregida de sitio. La PRUEBA01 puso el nido pero salio flotando: el MEDIUMHANGSLIME esta modelado con el ORIGEN en la vaina y la carne abierta 4,11 m POR ENCIMA, al reves que la planta vanilla, asi que el giro de 180 grados que el envoltorio traia para la planta dejaba la vaina metida en el techo y la carne colgando en el aire. Se quitan los 180 grados y se baja el nodo 4 m: la carne queda a ras del techo, en el locator Tentacle_ que esta a 6,45 m, y la vaina cuelga de cabeza a 2,45 m del suelo. Sigue sin tocar ningun .LSYSTEM. Escribe un solo archivo. Sustituye a HT_CeilingPlague_PRUEBA01 e incompatible con HT_LocatorTest_PRUEBA01, que secuestra el mismo locator.",
["MODIFICATIONS"]   =
  {
    {
      ["MBIN_CHANGE_TABLE"] =
      {
        {
          ["MBIN_FILE_SOURCE"] = "MODELS\PLANETS\BIOMES\COMMON\BUILDINGS\PROPS\ABANDONED\INTERIOR_TENTACLEPLANT.SCENE.MBIN",
          ["MXML_CHANGE_TABLE"] =
          {
            {
              ["COMMENT"]            = "SCENEGRAPH del nodo TentacleRef: de la planta del techo al nido colgante del carguero",
              ["SPECIAL_KEY_WORDS"]  = {"Name", "SCENEGRAPH"},
              ["REPLACE_TYPE"]       = "ONCE",
              ["VALUE_CHANGE_TABLE"] = { {"Value", NIDO_CARGUERO} }
            },
            {
              ["COMMENT"]            = "TentacleRef: sin el giro de la planta y bajado 4 m para que la carne pegue en el techo",
              ["SPECIAL_KEY_WORDS"]  = {"Name", "TentacleRef"},
              ["REPLACE_TYPE"]       = "ONCE",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"RotZ",   GIRO_Z},
                {"TransY", BAJADA_Y},
              }
            },
          }
        },
      }
    },
  },
}
