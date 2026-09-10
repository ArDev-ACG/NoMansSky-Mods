DENSITY_MULT     = 20
DANGEROUS_WEIGHT = "1000.000000"
PACK_MIN         = "5"
PACK_MAX         = "7"
PERCEPTION       = "80.000000"
RUNAWAY_HP       = "0.000000"
PCT_HOSTILE      = "1.000000"
MAX_CREATURE     = "70"
BOREDOM          = "150.000000"
REGAIN_INTEREST  = "2.000000"

FIEND_ATTACKERS  = "24"
FIEND_ENGAGED    = "24"
FIEND_SPAWN      = "24"
FIEND_AGGRO      = "600.000000"
FIEND_MARKERS    = "false"
FIEND_PERCEPTION = "120.000000"

PREDATOR_MARKERS  = "false"
FIEND_AGGRO_DECAY = "0.020000"
FIEND_AGGRO_EGG   = "3.000000"
FIEND_SHOT_MEMORY = "60.000000"
FIEND_DESPAWN     = "300.000000"
HATCH_MIN        = "0.100000"
HATCH_MAX        = "0.500000"
AVOID_WEIGHT     = "10.000000"
WORM_RADIUS      = "10.000000"
FLURRY_MIN       = "4"
FLURRY_MAX       = "8"
POUNCE_DELAY     = "0.700000"
POUNCE_REACH     = "3.000000"
POUNCE_VERTICAL  = "1.000000"
SPIT_ALWAYS      = "true"
SPIT_DELAY       = "0.600000"
TURN_TO_FACE     = "0.150000"
ANIM_SPEED       = "1.200000"
BROOD_ALLOW      = "true"
BROOD_ID         = "BUGFIENDS"
BROOD_TIMER      = "5.000000"

NOTICE_PAUSE     = "0.000000"
APPROACH_TIME    = "0.000000"
CHARGE_DIST      = "40.000000"
ENERGY_CHASING   = "0.000000"
STEER_RATE       = "0.100000"
TURN_RADIUS      = "2.000000"
COHERE_WEIGHT    = "1.200000"
ALIGN_WEIGHT     = "3.500000"
PUSH_SMALL       = "5.000000"
PUSH_MEDIUM      = "5.000000"
PUSH_LARGE       = "3.000000"
MELEE_SPEED      = "Fast"
MELEE_SLOWDOWN   = "1.000000"

FREIGHTER_SPAWN   = "30.000000"
FREIGHTER_DESPAWN = "50.000000"
FIEND_SPAWN_DIST  = "120.000000"

POD_TORCH        = "12.000000"
POD_GUNFIRE      = "8.000000"
POD_BROTAN       = "true"
EGG_MULT         = "20"

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HorribleTerror_Infestation_4-Hardcore",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "7.00",
["MOD_DESCRIPTION"] = "[HARDCORE] Terror 0.9.0: NUEVO EN 0.9.0, Y ES LA PRIMERA VUELTA QUE TOCA EL INTERES EN VEZ DE LA PRESION. La queja del 05/09 es que los bichos siguen yendose sin hacer caso, y eso ya no lo arregla apretar mas: diez vueltas subiendo cuantos caben, cuanto pegan y cuanto ven, y el interes no se habia tocado NUNCA. LO QUE SE DESCARTO PRIMERO, Y CON MEDIDA. Uno, el despliegue: descompilado GCCREATUREGLOBALS.MBIN de GAMEDATA/MODS, la 0.8.0 estaba viva y las TREINTA Y SEIS palancas llegaban exactas, o sea que no se perdia nada entre construir y jugar. Dos, el arbol de comportamiento: sus nodos -GetTarget, MoveToTarget, MaintainRange- no llevan ni temporizador de rendicion ni correa, solo TargetKey, ArriveDist y velocidades, asi que la decision de soltarte esta en codigo. Y tres, se comprobo que GCCREATUREGLOBALS es el UNICO fichero de IA de criaturas del juego: los otros seis GLOBALS son robot, asentamiento, UI, colocacion, tabla de juego y depuracion. LO QUE APARECIO. En ese fichero hay EXACTAMENTE SEIS campos que gobiernan perder y recuperar el interes, y el mod habia subido dos -FiendBeingShotMemoryTime 10 a 60 y PlayerPredatorBoredomDistance 80 a 150- y dejado CUATRO en vanilla. ENTRAN TRES DE ESOS CUATRO. PredatorBoredomDistance de 80 a 150, que es el GEMELO del que ya se subio: el juego trae dos temperamentos, TEMPERAMENT_PREDATOR y TEMPERAMENT_PLAYERPREDATOR, y solo se le habia subido la distancia de aburrimiento a uno. Y los dos tiempos de recuperar interes, PlayerPredatorRegainInterestTime y PredatorRegainInterestTime, de 30 segundos a 2: treinta segundos ignorandote es lo que en partida se lee como que se van y no vuelven. NO SE PONEN A CERO A PROPOSITO, y la leccion es de esta misma casa: en la 0.6.1 el drenaje de aggro se puso a cero y dejo la primera puerta del carguero abandonado sin abrirse nunca. Un temporizador se encoge, no se anula. EL CUARTO SE QUEDA FUERA A PROPOSITO, y es FiendDistToConsiderTargetSwtich -el typo es del juego-, que sigue en 10. Es el sospechoso mas gordo: con 24 Horrores enganchados y manadas de 5-7 encima, un Fiend se replantea a quien ataca cada vez que hay un candidato a menos de 10 m, o sea permanentemente, y eso es literalmente dejar de mirarte a ti; ademas encaja con que empeorara segun subian los contadores de 8 a 24, porque eso multiplica las ocasiones de replantearse. Se queda fuera porque su SIGNO NO ESTA CLARO: 10 puede querer decir cambia si hay algo a menos de 10 m -y entonces hay que BAJARLO- o cambia solo si el nuevo esta 10 m mas cerca -y entonces hay que SUBIRLO-, y son direcciones opuestas. Va solo en la 0.10.0, que es como se separa una palanca cuya semantica no se sabe. LO QUE NO CAMBIA: ni un contador, ni el salto, ni la cadencia, ni el drenaje, ni la malla, ni el arbol de comportamiento. Solo tres numeros. LA FIRMA, ESCRITA ANTES DE ENTRAR. Si te persiguen y vuelven cuando los pierdes de vista, cierra Q-INTERES y el interes era la via. Si siguen yendose IGUAL, entonces el interes no era y el que queda es FiendDistToConsiderTargetSwtich, que entra solo en la siguiente. Si ahora NO TE SUELTAN NUNCA y no se puede ni recoger recursos, el 2 se paso y el siguiente es 10, que sigue siendo un tercio de vanilla. Y si caen los FPS, esto no gasta nada -son tres constantes, ningun cuerpo nuevo- y el orden de reversion de la 0.8.0 no cambia. DE LA 0.8.0: contiene el mod de conducta (manadas de 5-7, deteccion a 80 m, Horrores que te ven a 120 m, se multiplican al rugir, crias que pegan igual que sus padres y no pierden el interes) y ademas siembra el mundo con huevos x20 y gusanos x20. NUEVO EN 0.8.0, Y ES SUBIR LA AGRESIVIDAD OTRA VUELTA, POR PETICION EXPRESA DEL 04/09. La 0.7.0 arreglo que el combate se apagara solo; esto es que ademas apriete. Seis palancas, todas numeros sueltos, ninguna toca el arbol de comportamiento ni la malla. MAS CUERPOS ENCIMA: FiendMaxAttackers, FiendMaxEngaged y MaxFiendsToSpawn de 16 a 24 -vanilla 2, 6 y 6-, y los tres van a la par a proposito, porque si caben 24 comprometidos pero solo nacen 16 el cupo extra no lo llena nadie. MAS CRIAS: SpawnBroodTimer de 10 a 5 segundos, o sea el doble de partos; se puede permitir justo porque la 0.7.0 dejo el drenaje de aggro en 0,02 y ya no se apaga la oleada al parir. EL SALTO LLEGA MAS LEJOS Y MAS ALTO: FiendPounceDistanceModifier de 1,7 a 3,0 y FiendMaxVerticalForPounce de 0,3 a 1,0. Esta es la que mas cambia la sensacion y no cuesta un solo frame: subirte a una roca deja de ser refugio. MAS CADENCIA: DelayBetweenPounceAttacks de 1,2 a 0,7 -vanilla 2,0- y los golpes por racha de 3-6 a 4-8 -vanilla 2-4-, en los dos bichos. ESCUPEN SIEMPRE: AllowSpitAlways a true en el FIEND y DelayBetweenSpitAttacks de 1,0 a 0,6 en los dos. Y NO ES UN INVENTO: el BUGFIEND YA LO TIENE EN TRUE DE VANILLA, verificado en el CREATUREDATATABLE descompilado del juego, asi que esto es copiarle al hijo lo que el juego ya le da. El padre lo tenia en false y era el unico de los dos que no disparaba de lejos. Y TARDAN MENOS EN ENCARARTE: TurnToFaceTime de 0,3 a 0,15, que es el tiempo muerto entre que te tienen delante y te pegan. LO QUE SE DEJA QUIETO A PROPOSITO: RoarChanceOnHit y RoarChanceOnMiss se quedan en 0,0 aunque los globales de depredador valgan 0,6 y 0,7, porque SpawnBroodAnim vale ROAR y subirlos es parir por cada golpe sin saber cuanto; y AllowSpawnBrood del BUGFIEND se queda en false, que es el techo de la oleada: encenderlo es crecimiento exponencial. LO QUE HAY QUE VIGILAR, Y VA ESCRITO: LOS FPS. Con MaxEcosystemCreaturesNormal en 70 -vanilla 40-, SteeringUpdateRate en 0,10 y ahora 24 enganchados pariendo cada 5 s, si el juego se atasca el orden de reversion es este y no otro: primero SpawnBroodTimer vuelve a 10, luego los tres contadores vuelven a 16, y solo despues SteeringUpdateRate vuelve a 0,25. NUEVO EN 0.7.0, Y SON DOS NUMEROS PARA UN SOLO SINTOMA: EL COMBATE SE APAGABA SOLO. En partida el 03/09 se vio que el Horror se va despues de rugir, que el medidor de enemigos va bajando mientras peleas y que las crias se van separando en vez de seguir atacando. Las tres cosas son la misma: FiendAggroDecreasePerSpawn. Cada Horror que NACE resta aggro, y con AllowSpawnBrood encendido y SpawnBroodTimer en 10 segundos los propios partos vacian el medidor. Con ocho atacantes pariendo cada 10 s son 0,8 de aggro cada 10 s contra los 3,0 que da romper un huevo: la oleada se desactiva sola en menos de un minuto, y cuando el medidor llega a cero se desengancha TODA la oleada de golpe, padre y crias. Baja de 0,1 a 0,02, o sea un quinto de vanilla, y no a cero: a cero se quedo en la 0.6.1 y dejo la primera puerta del carguero abandonado pidiendo seguridad adicional sin abrir nunca, porque esa puerta necesita que el medidor se vacie. Con 0,02 se sigue vaciando, solo que tarda cinco veces mas, que es lo que dura la pelea y no lo que dura la partida. Y FiendMaxAttackers pasa de 8 a 16, que es lo mismo que FiendMaxEngaged: hasta ahora solo ocho de los dieciseis enganchados podian pegar y los otros ocho se quedaban esperando alrededor, que es exactamente el -se van separando- de las crias. Nada de esto toca la malla ni el arbol de comportamiento. En 0.6.5: romper el nido colgante del carguero -el MEDIUMHANGSLIME- llama Horrores, porque su entidad ya traia IncreaseFiendCrime = EggDestroyed e IncreaseFiendWantedChance 1.0 y solo tenia IncreaseFiendWanted en false. Se pone en true. Va aqui y no solo en la prueba HT_CeilingPlague_PRUEBA03 porque los dos mods escriben ese mismo MBIN y el segundo que cargue gana entero: con los dos diciendo lo mismo, el orden de carga deja de importar. En 0.6.3: la banda de ataque del Horror vuelve a vanilla (6/10). En 0.6.1 se habia estrechado a 1/3 para que el padre no retrocediera al rugir, y el efecto secundario fue peor que el problema: con el limite lejano en 3 m el Horror no se comprometia con nada que estuviera mas lejos y te ignoraba por completo, el y sus crias. Retirados los huevos dentro de los edificios abandonados, que borraban la planta del techo sin poner nada en su sitio. Arreglada la primera puerta del carguero abandonado, que pedia seguridad adicional sin abrir nunca: el medidor de alerta se vacia cuando nacen Horrores, y estaba con el drenaje a cero. Vuelve al valor de vanilla. Las dos distancias del interior de carguero se quedan en vanilla tambien mientras se comprueba. No instalar junto al mod Horrible Terror - Predators: este ya lo incluye.",
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
              ["COMMENT"]            = "Sentidos, tenacidad E INTERES del depredador",
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
                {"PredatorNoticePauseTime", NOTICE_PAUSE},
                {"PredatorApproachTime",    APPROACH_TIME},
                {"PredatorChargeDist",      CHARGE_DIST},
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
            {
              ["COMMENT"]            = "El aggro sube el triple con los huevos y se drena a un quinto de vanilla",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"FiendAggroDecreasePerSpawn",   FIEND_AGGRO_DECAY},
                {"FiendAggroIncreaseDamageEgg",  FIEND_AGGRO_EGG},
                {"FiendAggroIncreaseDestroyEgg", FIEND_AGGRO_EGG},
              }
            },
            {
              ["COMMENT"]            = "Memoria y correa: no te sueltan ni te pierden",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"FiendBeingShotMemoryTime", FIEND_SHOT_MEMORY},
                {"FiendDespawnDistance",     FIEND_DESPAWN},
              }
            },
            {
              ["COMMENT"]            = "Interiores: distancias de carguero en vanilla, sospechosas de la puerta atascada",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"FreighterSpawnDist",   FREIGHTER_SPAWN},
                {"FreighterDespawnDist", FREIGHTER_DESPAWN},
                {"FiendSpawnDistance",   FIEND_SPAWN_DIST},
              }
            },
          }
        },
        {
          ["MBIN_FILE_SOURCE"] =
          {
            "MODELS\PLANETS\BIOMES\COMMON\BUILDINGS\PARTS\BUILDABLEPARTS\SPACEBASE\INFESTATION\LARGEPILLARSLIME\ENTITIES\LARGEPILLARSLIME.ENTITY.MBIN",
            "MODELS\PLANETS\BIOMES\COMMON\BUILDINGS\PARTS\BUILDABLEPARTS\SPACEBASE\INFESTATION\MEDIUMHANGSLIME\ENTITIES\MEDIUMHANGSLIME.ENTITY.MBIN",
          },
          ["MXML_CHANGE_TABLE"] =
          {
            {
              ["COMMENT"]            = "El nido despierta con la linterna y con los disparos",
              ["SPECIAL_KEY_WORDS"]  = {"Components", "GcAlienPodComponentData"},
              ["REPLACE_TYPE"]       = "ONCE",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"AgroTorch",   POD_TORCH},
                {"GunfireAgro", POD_GUNFIRE},
              }
            },
          }
        },
        {
          ["MBIN_FILE_SOURCE"] = "MODELS\PLANETS\BIOMES\COMMON\BUILDINGS\PARTS\BUILDABLEPARTS\SPACEBASE\INFESTATION\MEDIUMHANGSLIME\ENTITIES\MEDIUMHANGSLIME.ENTITY.MBIN",
          ["MXML_CHANGE_TABLE"] =
          {
            {
              ["COMMENT"]            = "Romper el nido colgante llama Horrores, igual que romper un huevo de suelo",
              ["SPECIAL_KEY_WORDS"]  = {"Components", "GcDestructableComponentData"},
              ["REPLACE_TYPE"]       = "ONCE",
              ["VALUE_CHANGE_TABLE"] = { {"IncreaseFiendWanted", POD_BROTAN} }
            },
          }
        },
        {
          ["MBIN_FILE_SOURCE"] = "GLOBALS\GCUIGLOBALS.GLOBAL.MBIN",
          ["MXML_CHANGE_TABLE"] =
          {
            {
              ["COMMENT"]            = "Sin marcador de UI en los depredadores",
              ["VALUE_CHANGE_TABLE"] = { {"ShowOnscreenPredatorMarkers", PREDATOR_MARKERS} }
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
                {"BehaviourMoveSpeed",          MELEE_SPEED},
                {"DynamicMoveSlowdownDistMul",  MELEE_SLOWDOWN},
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
            {
              ["COMMENT"]            = "FIEND: se multiplica mientras luchas",
              ["SPECIAL_KEY_WORDS"]  = {"Id", "FIEND"},
              ["REPLACE_TYPE"]       = "ONCE",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"AllowSpawnBrood",  BROOD_ALLOW},
                {"SpawnBroodID",     BROOD_ID},
                {"SpawnBroodTimer",  BROOD_TIMER},
              }
            },
            {
              ["COMMENT"]            = "BUGFIEND: golpes por racha "..FLURRY_MIN.."/"..FLURRY_MAX,
              ["SPECIAL_KEY_WORDS"]  = {"Id", "BUGFIEND"},
              ["REPLACE_TYPE"]       = "ONCE",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"MinFlurryHits", FLURRY_MIN},
                {"MaxFlurryHits", FLURRY_MAX},
              }
            },
            {
              ["COMMENT"]            = "BUGFIEND: cadencia del salto -> "..POUNCE_DELAY,
              ["SPECIAL_KEY_WORDS"]  = {"Id", "BUGFIEND"},
              ["REPLACE_TYPE"]       = "ONCE",
              ["VALUE_CHANGE_TABLE"] = { {"DelayBetweenPounceAttacks", POUNCE_DELAY} }
            },
            {
              ["COMMENT"]            = "BUGFIEND: velocidad de animacion de ataque -> "..ANIM_SPEED,
              ["SPECIAL_KEY_WORDS"]  = {"Id", "BUGFIEND"},
              ["REPLACE_TYPE"]       = "ONCE",
              ["VALUE_CHANGE_TABLE"] = { {"AnimSpeedModifier", ANIM_SPEED} }
            },
            {
              ["COMMENT"]            = "BUGFIEND: escupe siempre, mas rapido, y tarda menos en encararte",
              ["SPECIAL_KEY_WORDS"]  = {"Id", "BUGFIEND"},
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
