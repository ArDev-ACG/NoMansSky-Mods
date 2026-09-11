DENSITY_MULT     = 20
DANGEROUS_WEIGHT = "1000.000000"
PACK_MIN         = "3"
PACK_MAX         = "5"
PERCEPTION       = "60.000000"
RUNAWAY_HP       = "0.000000"
PCT_HOSTILE      = "1.000000"
MAX_CREATURE     = "60"
BOREDOM          = "120.000000"
REGAIN_INTEREST  = "8.000000"

FIEND_ATTACKERS  = "12"
FIEND_ENGAGED    = "12"
FIEND_SPAWN      = "12"
FIEND_AGGRO      = "90.000000"
FIEND_AGGRO_DECAY = "0.050000"
FIEND_AGGRO_EGG   = "2.000000"
FIEND_SHOT_MEMORY = "35.000000"
FIEND_DESPAWN     = "220.000000"
FIEND_MARKERS    = "false"
FIEND_PERCEPTION = "70.000000"
HATCH_MIN        = "0.150000"
HATCH_MAX        = "1.000000"
AVOID_WEIGHT     = "10.000000"
WORM_RADIUS      = "20.000000"
FLURRY_MIN       = "3"
FLURRY_MAX       = "5"
POUNCE_DELAY     = "1.500000"
POUNCE_REACH     = "2.400000"
POUNCE_VERTICAL  = "0.700000"
SPIT_ALWAYS      = "true"
SPIT_DELAY       = "0.750000"
TURN_TO_FACE     = "0.200000"
ANIM_SPEED       = "1.100000"

NOTICE_PAUSE     = "0.300000"
APPROACH_TIME    = "0.500000"
CHARGE_DIST      = "25.000000"
ENERGY_CHASING   = "0.000000"
STEER_RATE       = "0.150000"
TURN_RADIUS      = "3.000000"
COHERE_WEIGHT    = "0.800000"
ALIGN_WEIGHT     = "2.500000"
PUSH_SMALL       = "7.000000"
PUSH_MEDIUM      = "7.000000"
PUSH_LARGE       = "4.000000"
MELEE_SPEED      = "Fast"
MELEE_SLOWDOWN   = "2.000000"
EGG_MULT = "20"

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HorribleTerror_Infestation_3-Dificil",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "7.00",
["MOD_DESCRIPTION"] = "[DIFICIL] Terror 0.9.2: contiene el mod de conducta (99% de planetas hostiles, manadas de 3-5, nunca huyen, Horrores sin marcador que eclosionan en oleada y pegan 3-5 golpes por racha) y ademas siembra el mundo con huevos x20 y gusanos x20. NUEVO EN 0.9.2: el nivel se pone al dia con las palancas que las versiones 0.7.0, 0.8.0 y 0.9.0 solo le habian dado al Hardcore, escaladas para este nivel y siempre por debajo de el. EL INTERES: la distancia de aburrimiento sube de 80 a 120 m en los DOS temperamentos -el Hardcore va a 150- y el tiempo que te ignoran baja de 30 a 8 segundos. LA OLEADA YA NO SE APAGA SOLA: el aggro que gasta cada Horror al nacer baja de 0.1 a 0.05, romper un huevo suma 2.0 en vez de 1.0, recuerda tus disparos 35 segundos y no se evapora hasta los 220 m. DOCE ENCIMA Y LOS DOCE PEGANDO: los tres contadores van a la par en 12 -el Hardcore usa 24-, porque si caben doce comprometidos y solo pegan cuatro, los otros ocho dan vueltas alrededor. EL SALTO llega a 2.4x y salva 0.7 m de desnivel: subirte a una roca deja de ser refugio. ESCUPEN SIN CONDICION PREVIA, cada 0.75 s, y tardan 0.2 s en encararte. LO QUE NO ENTRA A PROPOSITO: que se multipliquen al rugir sigue siendo exclusivo del Hardcore, y con el las crias, el marcador de depredador apagado y los nidos del carguero. No instalar junto al mod Horrible Terror - Predators: este ya lo incluye.",
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
              ["COMMENT"]            = "El aggro sube el doble con los huevos y se drena a la mitad de vanilla",
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
              ["COMMENT"]            = "Sin marcador de UI y percepcion de Fiend a "..FIEND_PERCEPTION,
              ["VALUE_CHANGE_TABLE"] =
              {
                {"FiendOnscreenMarkers",    FIEND_MARKERS},
                {"FiendPerceptionDistance", FIEND_PERCEPTION},
              }
            },
            {
              ["COMMENT"]            = "Eclosion en oleada",
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
              ["COMMENT"]            = "Sin acecho: te ve y arranca",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"PredatorNoticePauseTime",  NOTICE_PAUSE},
                {"PredatorApproachTime",     APPROACH_TIME},
                {"PredatorChargeDist",       CHARGE_DIST},
                {"PredatorEnergyUseChasing", ENERGY_CHASING},
              }
            },
            {
              ["COMMENT"]            = "Rumbo directo: mas refresco de steering y giro cerrado",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"SteeringUpdateRate", STEER_RATE},
                {"MaxTurnRadius",      TURN_RADIUS},
              }
            },
            {
              ["COMMENT"]            = "Horda: la manada se mueve como un bloque",
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
              ["COMMENT"]            = "MELEE: cierran distancia rapido y sin frenar",
              ["SPECIAL_KEY_WORDS"]  = {"Id", "MELEE"},
              ["REPLACE_TYPE"]       = "ONCE",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"BehaviourMoveSpeed",         MELEE_SPEED},
                {"DynamicMoveSlowdownDistMul", MELEE_SLOWDOWN},
              }
            },
          }
        },
        {
          ["MBIN_FILE_SOURCE"] = "METADATA\SIMULATION\ECOSYSTEM\CREATUREDATATABLE.MBIN",
          ["MXML_CHANGE_TABLE"] =
          {
            {
              ["COMMENT"]            = "FIEND: golpes por racha "..FLURRY_MIN.."/"..FLURRY_MAX,
              ["SPECIAL_KEY_WORDS"]  = {"Id", "FIEND"},
              ["REPLACE_TYPE"]       = "ONCE",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"MinFlurryHits", FLURRY_MIN},
                {"MaxFlurryHits", FLURRY_MAX},
              }
            },
            {
              ["COMMENT"]            = "FIEND: cadencia del salto -> "..POUNCE_DELAY,
              ["SPECIAL_KEY_WORDS"]  = {"Id", "FIEND"},
              ["REPLACE_TYPE"]       = "ONCE",
              ["VALUE_CHANGE_TABLE"] = { {"DelayBetweenPounceAttacks", POUNCE_DELAY} }
            },
            {
              ["COMMENT"]            = "FIEND: velocidad de animacion de ataque -> "..ANIM_SPEED,
              ["SPECIAL_KEY_WORDS"]  = {"Id", "FIEND"},
              ["REPLACE_TYPE"]       = "ONCE",
              ["VALUE_CHANGE_TABLE"] = { {"AnimSpeedModifier", ANIM_SPEED} }
            },
            {
              ["COMMENT"]            = "FIEND: escupe siempre, mas rapido, y tarda menos en encararte",
              ["SPECIAL_KEY_WORDS"]  = {"Id", "FIEND"},
              ["REPLACE_TYPE"]       = "ONCE",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"AllowSpitAlways",         SPIT_ALWAYS},
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
