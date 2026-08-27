NIDO_CARGUERO = "MODELS\PLANETS\BIOMES\COMMON\BUILDINGS\PARTS\BUILDABLEPARTS\SPACEBASE\INFESTATION\MEDIUMHANGSLIME.SCENE.MBIN"
GIRO_Z        = "0.000000"
BAJADA_Y      = "-4.000000"
BROTAN        = "true"
AGRO_LINTERNA = "12.000000"
AGRO_DISPARO  = "8.000000"

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_CeilingPlague_PRUEBA03",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.3.0] La plaga del carguero colgada del techo de los edificios abandonados, y ahora VIVA. Contiene entera a la PRUEBA02, que ya paso en partida el 2026-08-20 y de la que no se retrocede: el nido queda pegado al techo y la vaina cuelga de cabeza a 2,45 m del suelo, y de posicion no se toca nada. Lo unico que anade es UN campo, y el campo estaba ya cableado en el vanilla: MEDIUMHANGSLIME.ENTITY.MBIN trae un GcDestructableComponentData con IncreaseFiendCrime = EggDestroyed y IncreaseFiendWantedChance 1.0 exactamente igual que el huevo de suelo FIENDEGG, y la unica diferencia entre los dos es que el huevo tiene IncreaseFiendWanted en true y el nido lo tiene en false. Se pone en true. Los Horrores no salen del prop: los suelta el sistema de fiend wanted cuando se comete el crimen EggDestroyed, que es como funcionan los huevos del suelo, asi que romper el nido del techo pasa a llamar a los Horrores igual que romper un huevo. El nido no necesita nada mas para que funcione: el .SCENE ya trae un locator SPAWNPOS_, un GcShootableComponentData, una escena MEDIUMHANGSLIME_DESTROYED propia y un GcAlienPodComponentData que le da agro por movimiento a 8,5 m, por linterna a 10 m y por disparo a 20 m, o sea que el nido ya reaccionaba al jugador y solo le faltaba la consecuencia. La explosion se queda en INFESTPILLAREXP, la del nido, y no se cambia por la FIENDHATCH del huevo: lo que se mide es si brotan, no como se ve el reventon. OJO CON EL ALCANCE: MEDIUMHANGSLIME.ENTITY.MBIN lo comparte la infestacion de cargueros abandonados, asi que encenderlo aqui lo enciende tambien alli, y romper baba en un carguero derrelicto tambien llamara Horrores. Es deliberado. Si el juego se cierra o los Horrores salen a manadas donde no toca, se vuelve a la PRUEBA02, que solo escribe el primero de los dos archivos. OJO CON EL EMPATE: HorribleTerror_Infestation_4-Hardcore escribe ESTE MISMO .ENTITY, y cuando dos mods escriben un MBIN el que cargue el segundo gana entero y en silencio. Las dos versiones se diferenciaban en tres campos y solo en tres: el Infestation pone AgroTorch 12 y GunfireAgro 8 y deja IncreaseFiendWanted en false, y esta prueba hacia lo contrario. Por eso esta prueba escribe LOS TRES, y asi es un superconjunto del Infestation: si gana esta, no se pierde nada de la conducta del nido. El unico escenario malo que queda es que gane el Infestation, y entonces no brotara nada; si en partida el nido despierta con la linterna pero romperlo no llama Horrores, es exactamente eso, y se arregla subiendo la prioridad de esta prueba por encima del Infestation en el menu de mods del juego. Sustituye a HT_CeilingPlague_PRUEBA02 e incompatible con HT_LocatorTest_PRUEBA01, que secuestra el mismo locator.",
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
        {
          ["MBIN_FILE_SOURCE"] = "MODELS\PLANETS\BIOMES\COMMON\BUILDINGS\PARTS\BUILDABLEPARTS\SPACEBASE\INFESTATION\MEDIUMHANGSLIME\ENTITIES\MEDIUMHANGSLIME.ENTITY.MBIN",
          ["MXML_CHANGE_TABLE"] =
          {
            {
              ["COMMENT"]            = "El unico campo que separa el nido del techo de un huevo de Horror: romperlo pasa a cometer el crimen EggDestroyed",
              ["REPLACE_TYPE"]       = "ONCE",
              ["VALUE_CHANGE_TABLE"] = { {"IncreaseFiendWanted", BROTAN} }
            },
            {
              ["COMMENT"]            = "Del HorribleTerror_Infestation, que escribe este mismo archivo: aggro por apuntar con la linterna",
              ["REPLACE_TYPE"]       = "ONCE",
              ["VALUE_CHANGE_TABLE"] = { {"AgroTorch", AGRO_LINTERNA} }
            },
            {
              ["COMMENT"]            = "Del HorribleTerror_Infestation: aggro por disparar cerca",
              ["REPLACE_TYPE"]       = "ONCE",
              ["VALUE_CHANGE_TABLE"] = { {"GunfireAgro", AGRO_DISPARO} }
            },
          }
        },
      }
    },
  },
}
