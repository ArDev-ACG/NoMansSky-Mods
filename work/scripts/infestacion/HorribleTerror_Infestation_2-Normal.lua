DENSITY_MULT     = 3
DANGEROUS_WEIGHT = "4.000000"
PACK_MIN         = "1"
PACK_MAX         = "2"
PERCEPTION       = "50.000000"
RUNAWAY_HP       = "25.000000"
PCT_HOSTILE      = "0.600000"
MAX_CREATURE     = "50"
BOREDOM          = "100.000000"
REGAIN_INTEREST  = "15.000000"

FIEND_ATTACKERS  = "8"
FIEND_ENGAGED    = "8"
FIEND_SPAWN      = "8"
FIEND_AGGRO      = "60.000000"
FIEND_AGGRO_DECAY = "0.080000"
FIEND_AGGRO_EGG   = "1.500000"
FIEND_SHOT_MEMORY = "20.000000"
FIEND_DESPAWN     = "180.000000"
FIEND_PERCEPTION = "65.000000"
HATCH_MIN        = "0.200000"
HATCH_MAX        = "2.000000"
AVOID_WEIGHT     = "8.000000"
WORM_RADIUS      = "50.000000"
POUNCE_DELAY     = "1.800000"
POUNCE_REACH     = "2.000000"
POUNCE_VERTICAL  = "0.500000"
SPIT_DELAY       = "0.900000"
TURN_TO_FACE     = "0.250000"

NOTICE_PAUSE     = "0.800000"
APPROACH_TIME    = "2.000000"
CHARGE_DIST      = "12.000000"
ENERGY_CHASING   = "-0.050000"
STEER_RATE       = "0.200000"
TURN_RADIUS      = "4.000000"
COHERE_WEIGHT    = "0.400000"
ALIGN_WEIGHT     = "1.500000"
PUSH_SMALL       = "9.000000"
PUSH_MEDIUM      = "9.000000"
PUSH_LARGE       = "4.500000"
MELEE_SLOWDOWN   = "3.000000"
EGG_MULT = "5"

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HorribleTerror_Infestation_2-Normal",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "7.00",
["MOD_DESCRIPTION"] = "[NORMAL] Terror 0.9.2: contiene el mod de conducta (27% de planetas hostiles, manadas de 1-2, Horrores que te ven a 65 m, eclosionan mas juntos y vienen derechos y en grupo) y ademas siembra el mundo con huevos x5 y gusanos x5. NUEVO EN 0.9.2: el nivel se pone al dia con las palancas que las versiones 0.7.0, 0.8.0 y 0.9.0 solo le habian dado al Hardcore, escaladas para este nivel. EL INTERES: la distancia de aburrimiento sube de 80 a 100 m en los DOS temperamentos y el tiempo que te ignoran baja de 30 a 15 segundos, la mitad del camino al 2 del Hardcore. LA OLEADA YA NO SE APAGA SOLA: el aggro que gasta cada Horror al nacer baja de 0.1 a 0.08, romper un huevo suma 1.5 en vez de 1.0, recuerda tus disparos 20 segundos en vez de 10 y no se evapora hasta los 180 m. Y LOS OCHO QUE CABEN EN COMBATE AHORA PEGAN LOS OCHO: hasta aqui solo pegaban tres y los otros cinco daban vueltas alrededor, que es la leccion de la 0.7.0. EL SALTO llega a 2.0x y salva medio metro de desnivel. ESCUPEN cada 0.9 s y tardan 0.25 s en encararte. LO QUE NO ENTRA A PROPOSITO: que se multipliquen al rugir y que escupan sin condicion previa siguen siendo exclusivos del Hardcore. No instalar junto al mod Horrible Terror - Predators: este ya lo incluye.",
["MODIFICATIONS"]   =
  {
    {
      ["MBIN_CHANGE_TABLE"] =
      {
        {
          ["MBIN_FILE_SOURCE"] = "METADATA\SIMULATION\ECOSYSTEM\CREATUREGENERATIONDATA.MBIN",
          ["MXML_CHANGE_TABLE"] =
          {
            {
              ["COMMENT"]             = "GroundGroupsPerKm x"..DENSITY_MULT,
              ["PRECEDING_KEY_WORDS"] = {"GroundGroupsPerKm"},
              ["VALUE_CHANGE_TABLE"]  =
              {
                {"Sparse",    "@*"..DENSITY_MULT},
                {"Normal",    "@*"..DENSITY_MULT},
                {"Dense",     "@*"..DENSITY_MULT},
                {"VeryDense", "@*"..DENSITY_MULT},
              }
            },
            {
              ["COMMENT"]            = "Generic/Ground: DANGEROUS -> "..DANGEROUS_WEIGHT,
              ["SPECIAL_KEY_WORDS"]  =
              {
                "Generic",   "GcCreatureGenerationWeightedList",
                "Archetype", "DANGEROUS",
              },
              ["REPLACE_TYPE"]       = "ONCE",
              ["VALUE_CHANGE_TABLE"] = { {"Weight ", DANGEROUS_WEIGHT} }
            },
          }
        },
        {
          ["MBIN_FILE_SOURCE"] =
          {
            "METADATA\SIMULATION\ECOSYSTEM\GROUND\GROUNDTABLEPLAYERPREDATORMED.MBIN",
            "METADATA\SIMULATION\ECOSYSTEM\GROUND\GROUNDTABLEPLAYERPREDATORLARGE.MBIN",
          },
          ["MXML_CHANGE_TABLE"] =
          {
            {
              ["COMMENT"]            = "Manada "..PACK_MIN.."/"..PACK_MAX,
              ["VALUE_CHANGE_TABLE"] =
              {
                {"MinGroupSize", PACK_MIN},
                {"MaxGroupSize", PACK_MAX},
              }
            },
          }
        },
        {
          ["MBIN_FILE_SOURCE"] = "GLOBALS\GCCREATUREGLOBALS.MBIN",
          ["MXML_CHANGE_TABLE"] =
          {
            {
              ["COMMENT"]            = "Sentidos y tenacidad del depredador",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"PredatorPerceptionDistance",   PERCEPTION},
                {"PredatorRunAwayHealthPercent", RUNAWAY_HP},
                {"PercentagePlayerPredators",    PCT_HOSTILE},
                {"MaxEcosystemCreaturesNormal",  MAX_CREATURE},
                {"PlayerPredatorBoredomDistance", BOREDOM},
                {"PredatorBoredomDistance",       BOREDOM},
                {"PlayerPredatorRegainInterestTime", REGAIN_INTEREST},
                {"PredatorRegainInterestTime",       REGAIN_INTEREST},
              }
            },
            {
              ["COMMENT"]            = "Presion de los Horrores Biologicos",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"FiendMaxAttackers", FIEND_ATTACKERS},
                {"FiendMaxEngaged",   FIEND_ENGAGED},
                {"MaxFiendsToSpawn",  FIEND_SPAWN},
                {"FiendAggroTime",    FIEND_AGGRO},
              }
            },
            {
              ["COMMENT"]            = "El salto llega a "..POUNCE_REACH.."x y salva "..POUNCE_VERTICAL.." m de desnivel",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"FiendPounceDistanceModifier", POUNCE_REACH},
                {"FiendMaxVerticalForPounce",   POUNCE_VERTICAL},
              }
            },
            {
              ["COMMENT"]            = "El aggro sube con los huevos y se drena mas despacio que en vanilla",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"FiendAggroDecreasePerSpawn",   FIEND_AGGRO_DECAY},
                {"FiendAggroIncreaseDamageEgg",  FIEND_AGGRO_EGG},
                {"FiendAggroIncreaseDestroyEgg", FIEND_AGGRO_EGG},
              }
            },
            {
              ["COMMENT"]            = "Memoria y correa: tardan mas en soltarte",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"FiendBeingShotMemoryTime", FIEND_SHOT_MEMORY},
                {"FiendDespawnDistance",     FIEND_DESPAWN},
              }
            },
            {
              ["COMMENT"]            = "Percepcion de Fiend a "..FIEND_PERCEPTION,
              ["VALUE_CHANGE_TABLE"] = { {"FiendPerceptionDistance", FIEND_PERCEPTION} }
            },
            {
              ["COMMENT"]            = "Eclosion mas junta",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"FiendMinSpawnTime", HATCH_MIN},
                {"FiendMaxSpawnTime", HATCH_MAX},
              }
            },
            {
              ["COMMENT"]            = "Separacion entre criaturas y gusano por cercania",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"AvoidCreaturesWeight",            AVOID_WEIGHT},
                {"GroundWormSpawnerActivateRadius", WORM_RADIUS},
              }
            },
            {
              ["COMMENT"]            = "Menos acecho",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"PredatorNoticePauseTime",  NOTICE_PAUSE},
                {"PredatorApproachTime",     APPROACH_TIME},
                {"PredatorChargeDist",       CHARGE_DIST},
                {"PredatorEnergyUseChasing", ENERGY_CHASING},
              }
            },
            {
              ["COMMENT"]            = "Rumbo directo: mas refresco de steering y giro mas cerrado",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"SteeringUpdateRate", STEER_RATE},
                {"MaxTurnRadius",      TURN_RADIUS},
              }
            },
            {
              ["COMMENT"]            = "Horda: la manada se mantiene mas junta",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"FollowLeaderCohereWeight", COHERE_WEIGHT},
                {"FollowLeaderAlignWeight",  ALIGN_WEIGHT},
              }
            },
            {
              ["COMMENT"]             = "Horda: menos empujon mutuo (struct por tamano)",
              ["PRECEDING_KEY_WORDS"] = {"SpherePusherWeight"},
              ["VALUE_CHANGE_TABLE"]  =
              {
                {"Small",  PUSH_SMALL},
                {"Medium", PUSH_MEDIUM},
                {"Large",  PUSH_LARGE},
              }
            },
          }
        },
        {
          ["MBIN_FILE_SOURCE"] = "METADATA\SIMULATION\ECOSYSTEM\CREATUREBEHAVIOURTREES.MBIN",
          ["MXML_CHANGE_TABLE"] =
          {
            {
              ["COMMENT"]            = "MELEE: frenan menos al acercarse",
              ["SPECIAL_KEY_WORDS"]  = {"Id", "MELEE"},
              ["REPLACE_TYPE"]       = "ONCE",
              ["VALUE_CHANGE_TABLE"] = { {"DynamicMoveSlowdownDistMul", MELEE_SLOWDOWN} }
            },
          }
        },
        {
          ["MBIN_FILE_SOURCE"] = "METADATA\SIMULATION\ECOSYSTEM\CREATUREDATATABLE.MBIN",
          ["MXML_CHANGE_TABLE"] =
          {
            {
              ["COMMENT"]            = "FIEND: cadencia del salto -> "..POUNCE_DELAY,
              ["SPECIAL_KEY_WORDS"]  = {"Id", "FIEND"},
              ["REPLACE_TYPE"]       = "ONCE",
              ["VALUE_CHANGE_TABLE"] = { {"DelayBetweenPounceAttacks", POUNCE_DELAY} }
            },
            {
              ["COMMENT"]            = "FIEND: escupe mas rapido y tarda menos en encararte",
              ["SPECIAL_KEY_WORDS"]  = {"Id", "FIEND"},
              ["REPLACE_TYPE"]       = "ONCE",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"DelayBetweenSpitAttacks", SPIT_DELAY},
                {"TurnToFaceTime",          TURN_TO_FACE},
              }
            },
          }
        },
        {
          ["MBIN_FILE_SOURCE"] = "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\OBJECTS\RARE\FIENDEGGS.MBIN",
          ["MXML_CHANGE_TABLE"] =
          {
            {
              ["COMMENT"]            = "Huevos de Fiend x"..EGG_MULT,
              ["MATH_OPERATION"]     = "*",
              ["REPLACE_TYPE"]       = "ALL",
              ["VALUE_MATCH"]        = "0.005000",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"FlatDensity",  EGG_MULT},
                {"SlopeDensity", EGG_MULT},
              }
            },
          }
        },
        {
          ["MBIN_FILE_SOURCE"] = "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\OBJECTS\RARE\INFESTATION.MBIN",
          ["MXML_CHANGE_TABLE"] =
          {
            {
              ["COMMENT"]            = "Gusano de arena (WORMSPAWNER) x"..EGG_MULT.." - llano",
              ["MATH_OPERATION"]     = "*",
              ["REPLACE_TYPE"]       = "ALL",
              ["VALUE_MATCH"]        = "0.025000",
              ["VALUE_CHANGE_TABLE"] = { {"FlatDensity", EGG_MULT} }
            },
            {
              ["COMMENT"]            = "Gusano de arena (WORMSPAWNER) x"..EGG_MULT.." - pendiente",
              ["MATH_OPERATION"]     = "*",
              ["REPLACE_TYPE"]       = "ALL",
              ["VALUE_MATCH"]        = "0.030000",
              ["VALUE_CHANGE_TABLE"] = { {"SlopeDensity", EGG_MULT} }
            },
            {
              ["COMMENT"]            = "Huevos de Fiend x"..EGG_MULT,
              ["MATH_OPERATION"]     = "*",
              ["REPLACE_TYPE"]       = "ALL",
              ["VALUE_MATCH"]        = "0.005000",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"FlatDensity",  EGG_MULT},
                {"SlopeDensity", EGG_MULT},
              }
            },
          }
        },
      }
    },
  },
}
