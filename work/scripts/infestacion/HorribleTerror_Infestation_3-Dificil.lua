--[[
  HORRIBLE TERROR - Infestacion :: DIFICIL
  ==================================================================
  MOD 2, version 0.2.0. Los Horrores Biologicos (FIEND en los archivos)
  dejan de ser una rareza y pasan a ser parte del paisaje. Los huevos se
  siembran por el terreno, y cuando uno eclosiona vienen mas y mas rapido.

  >>> CONFIGURACION 3 de 4: DIFICIL <<<

  ------------------------------------------------------------------
  NOVEDADES DE 0.2.0
  ------------------------------------------------------------------
  0.1.0 subia CANTIDAD de Fiends. 0.2.0 cambia su CONDUCTA:

    1  FiendOnscreenMarkers  true -> false   sin marcador de UI
    2  FiendPerceptionDistance  60 -> 70     te ven de mas lejos
    3  FiendMin/MaxSpawnTime 0.25/3 -> 0.15/1.0   eclosion en oleada
    4  AvoidCreaturesWeight  6 -> 10         menos amontonamiento
    4b GroundWormSpawnerActivateRadius 100 -> 20  el gusano salta cerca
    5  MinFlurryHits/Max  2/4 -> 3/5         mas golpes por racha
    6  DelayBetweenPounceAttacks 2.0 -> 1.5  salta mas seguido
    7  AnimSpeedModifier 1.0 -> 1.1          ataca mas rapido

  El zigzag estaba en esta lista y se ha QUITADO sin llegar a probarlo:
  los Fiend ya zigzaguean con el campo a 0. Ver la seccion de la sesion
  del 2026-08-04 mas abajo.

  AllowSpawnBrood (que se multipliquen) es exclusivo de Hardcore.

  Los puntos 6-8 estrenan un archivo nuevo: CREATUREDATATABLE.MBIN.

  ------------------------------------------------------------------
  RELACION CON EL MOD 1 (Predators)
  ------------------------------------------------------------------
  Este mod INCLUYE los cambios del mod 1 en el tier equivalente. No se
  instalan los dos: escriben los mismos archivos y uno pisaria al otro
  en silencio.

  ------------------------------------------------------------------
  LAS CUATRO CONFIGURACIONES
  ------------------------------------------------------------------
  Instala UNA sola.

  Parametro                Vanilla  1Facil  2Normal 3Dificil 4Hardcore
  --------------------------------------------------------------------
  -- Parte heredada del mod 1 --
  Densidad terrestre          x1      x2       x5      x20      x20
  Peso arquetipo DANGEROUS     1       3       10     1000     1000
  Manada min/max             1/1     1/2      2/3      3/5      5/7
  Percepcion depredador (m)   40      45       50       60       80
  Huye al % de vida           40      30       15        0        0
  % depredadores hostiles    0.5     0.6     0.75      1.0      1.0
  Tope criaturas a la vez     40      45       50       60       70
  Distancia de aburrimiento   80      80       80       80      150
  -- Fiends: cantidad (0.1.0) --
  Densidad de huevos          x1      x2       x5      x20      x20
  FiendMaxAttackers            2       2        3        4        6
  FiendMaxEngaged              6       6        8       10       12
  MaxFiendsToSpawn             6       6        8       10       12
  FiendAggroTime (s)          45      45       60       90      120
  -- Fiends: conducta (0.2.0) --
  Marcador de UI              si      si       si       NO       NO
  Percepcion Fiend (m)        60      60       65       70       80
  Eclosion min/max (s)   0.25/3.0  0.25/3  0.2/2.0  0.15/1.0  0.1/0.5
  AvoidCreaturesWeight         6       6        8       10       10
  Radio activacion gusano    100     100       50       20       10
  Golpes por racha           2/4     2/4      2/4      3/5      3/6
  Cadencia del salto (s)     2.0     2.0      1.8      1.5      1.2
  Velocidad de ataque        1.0     1.0      1.0      1.1      1.2
  Se multiplican              no      no       no       no       SI

  ------------------------------------------------------------------
  ARCHIVOS QUE TOCA - 7 rutas (una mas que en 0.1.0)
  ------------------------------------------------------------------
    METADATA\SIMULATION\ECOSYSTEM\CREATUREGENERATIONDATA.MBIN
    METADATA\SIMULATION\ECOSYSTEM\GROUND\GROUNDTABLEPLAYERPREDATORMED.MBIN
    METADATA\SIMULATION\ECOSYSTEM\GROUND\GROUNDTABLEPLAYERPREDATORLARGE.MBIN
    METADATA\SIMULATION\ECOSYSTEM\CREATUREDATATABLE.MBIN          <-- NUEVO
    GLOBALS\GCCREATUREGLOBALS.MBIN
    METADATA\SIMULATION\SOLARSYSTEM\BIOMES\OBJECTS\RARE\FIENDEGGS.MBIN
    METADATA\SIMULATION\SOLARSYSTEM\BIOMES\OBJECTS\RARE\INFESTATION.MBIN

  Escaneo del 2026-08-03: las 7 rutas siguen libres de mods de terceros.

  ------------------------------------------------------------------
  TRAMPAS VERIFICADAS - no tocar sin leer esto
  ------------------------------------------------------------------
  * TRAMPA NUEVA DE 0.2.0: CREATUREDATATABLE tiene DIEZ bloques de
    GcCreatureFiendAttackData, no solo el del FIEND. Los duenos son
    FIEND, BUGFIEND, BUGQUEEN, SCUTTLER, SCUTTLER_PET, SLUG, MINIFIEND
    y MINIDRONE, mas 2 de GcCreatureSpookFiendAttackData.
    --> SCUTTLER_PET es LA MASCOTA DEL JUGADOR y BUGQUEEN es un jefe
        calibrado aparte. Un REPLACE_TYPE = "ALL" los tocaria.
        Por eso cada regla lleva SPECIAL_KEY_WORDS anclado a
        {"Id", "FIEND"} y REPLACE_TYPE = "ONCE".

  * Cada objeto de FIENDEGGS/INFESTATION lleva DOS bloques de densidad.
    El bueno es QualityVariants. Debajo hay un QualityVariantData con
    Coverage 0.2 / FlatDensity 0.5 identico en los cinco objetos.
    --> Por eso se usa VALUE_MATCH.

  * NO se toca Coverage. Rango valido desconocido.

  * TRAMPA DE ORDEN (2026-08-01): las reglas de un mismo archivo se
    aplican EN SECUENCIA. Por eso en INFESTATION el gusano va PRIMERO y
    los huevos ULTIMOS.

  * ENTEROS, sin decimales: FiendMaxAttackers, FiendMaxEngaged,
    MaxFiendsToSpawn, MaxEcosystemCreaturesNormal, MinFlurryHits y
    MaxFlurryHits. Todo lo demas es float con 6 decimales.

  * BOOLEANOS: FiendOnscreenMarkers se escribe "false" en minusculas.

  * "Weight " lleva un ESPACIO AL FINAL. Typo de Hello Games.

  * NO usar WHERE_IN_SECTION para el peso de DANGEROUS.

  ------------------------------------------------------------------
  SESION DEL 2026-08-04: LA PRUEBA MIDIO 0.1.0, NO 0.2.0
  ------------------------------------------------------------------
  0.2.0 se construyo el 04/08 y NUNCA se copio a GAMEDATA\MODS. Lo que
  estaba instalado al probar era 0.1.0. Comprobado leyendo el EXML
  desplegado: 9 cambios en GCCREATUREGLOBALS, sin CREATUREDATATABLE.

  --> REGLA: construir NO es desplegar. Antes de cualquier prueba
      in-game, leer el EXML de GAMEDATA\MODS y confirmar que contiene los
      campos de la version que se cree estar probando.

  ZigZag RETIRADO igualmente, y por una razon que la prueba si respalda:
  los Fiend se acercan zigzagueando CON el campo a 0, o sea que
  FiendZigZagSpeed no es la causa de lo que se ve. Subirlo solo habria
  empeorado lo que molesta -- el objetivo es que vengan DERECHOS.
  Se quita la regla entera en vez de escribir 0: escribir el propio valor
  vanilla ensucia el EXML delta sin cambiar nada.

  FiendOnscreenMarkers sigue [SIN PROBAR]: tampoco estaba desplegado.

  La causa real del zigzag sigue sin identificar. Ver COMPORTAMIENTO.md.

  ------------------------------------------------------------------
  VERIFICACION ESPERADA
  ------------------------------------------------------------------
  REPORT: 50 CHANGE(s) en total.
     5 en CREATUREGENERATIONDATA (4 de densidad + 1 de peso)
     2 en cada tabla PLAYERPREDATOR (x2 archivos = 4)
    25 en GCCREATUREGLOBALS (4 depredador + 4 Fiend 0.1.0 + 6 de 0.2.0
                             + 11 de 0.3.0: 4 acecho + 2 rumbo + 5 horda)
     4 en CREATUREDATATABLE (2 racha + 1 salto + 1 anim)
     2 en CREATUREBEHAVIOURTREES (MoveSpeed + Slowdown, solo MELEE)
     4 en FIENDEGGS    (2 FlatDensity + 2 SlopeDensity)
     6 en INFESTATION  (4 del grupo 0.005 + 1 de 0.025 + 1 de 0.030)
--]]

-- ---------- Heredado del mod 1 ----------
DENSITY_MULT     = 20
DANGEROUS_WEIGHT = "1000.000000"
PACK_MIN         = "3"
PACK_MAX         = "5"
PERCEPTION       = "60.000000"
RUNAWAY_HP       = "0.000000"
PCT_HOSTILE      = "1.000000"
MAX_CREATURE     = "60"   -- ENTERO, sin decimales

-- ---------- Fiends: cantidad (0.1.0) ----------
EGG_MULT         = "20"
FIEND_ATTACKERS  = "4"    -- ENTERO
FIEND_ENGAGED    = "10"   -- ENTERO
FIEND_SPAWN      = "10"   -- ENTERO
FIEND_AGGRO      = "90.000000"

-- ---------- Fiends: conducta (0.2.0) ----------
FIEND_MARKERS    = "false"        -- 1  [SIN PROBAR] nunca se desplego
FIEND_PERCEPTION = "70.000000"    -- 2
HATCH_MIN        = "0.150000"     -- 3
HATCH_MAX        = "1.000000"     -- 3
AVOID_WEIGHT     = "10.000000"    -- 4
WORM_RADIUS      = "20.000000"    -- 4b
FLURRY_MIN       = "3"            -- 5  ENTERO
FLURRY_MAX       = "5"            -- 5  ENTERO
POUNCE_DELAY     = "1.500000"     -- 6
ANIM_SPEED       = "1.100000"     -- 7
-- ZigZag retirado: con el campo a 0 los Fiend ya zigzaguean, asi que no
-- es la palanca, y subirlo iria en contra de que vengan derechos.

-- ---------- 0.3.0: que vengan DERECHOS, SIN ACECHAR y EN HORDA ----------
-- Valores vanilla extraidos de NMSARC.globals.pak el 2026-08-04.
-- A) SIN ACECHAR
NOTICE_PAUSE     = "0.300000"     -- A1  vanilla 1.5
APPROACH_TIME    = "0.500000"     -- A2  vanilla 4.0
CHARGE_DIST      = "25.000000"    -- A3  vanilla 7.0
ENERGY_CHASING   = "0.000000"     -- A4  vanilla -0.1
-- B) DERECHOS
STEER_RATE       = "0.150000"     -- B1  vanilla 0.25
TURN_RADIUS      = "3.000000"     -- B2  vanilla 5.0
-- C) EN HORDA
COHERE_WEIGHT    = "0.800000"     -- C1  vanilla 0.1
ALIGN_WEIGHT     = "2.500000"     -- C2  vanilla 1.0
PUSH_SMALL       = "7.000000"     -- C3  vanilla 10
PUSH_MEDIUM      = "7.000000"     --     vanilla 10
PUSH_LARGE       = "4.000000"     --     vanilla 5
-- D) ARBOL MELEE
MELEE_SPEED      = "Fast"         -- D1  vanilla Normal
MELEE_SLOWDOWN   = "2.000000"     -- D2  vanilla 4.0
--
-- NO se toca AvoidCreaturesStrength del arbol MELEE (0.0): separaria la
-- manada, que es justo lo contrario de "en horda".

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HorribleTerror_Infestation_3-Dificil",
["MOD_AUTHOR"]      = "ArDev-ACG",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[DIFICIL] Infestacion 0.2.0: huevos de Horror Biologico x20, sin marcador de UI, eclosion en oleada, mas los depredadores del mod de dificultad.",
["MODIFICATIONS"]   =
  {
    {
      ["MBIN_CHANGE_TABLE"] =
      {
        -- ---------- Densidad y reparto de arquetipos ----------
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
        -- ---------- Tamano de manada ----------
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
        -- ---------- Sentidos del depredador + globales de Fiend ----------
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
            -- 0.2.0: conducta
            {
              ["COMMENT"]            = "0.2.0 - sin marcador de UI y percepcion de Fiend a "..FIEND_PERCEPTION,
              ["VALUE_CHANGE_TABLE"] =
              {
                {"FiendOnscreenMarkers",    FIEND_MARKERS},
                {"FiendPerceptionDistance", FIEND_PERCEPTION},
              }
            },
            {
              ["COMMENT"]            = "0.2.0 - eclosion en oleada",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"FiendMinSpawnTime", HATCH_MIN},
                {"FiendMaxSpawnTime", HATCH_MAX},
              }
            },
            {
              ["COMMENT"]            = "0.2.0 - separacion entre criaturas y gusano por cercania",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"AvoidCreaturesWeight",            AVOID_WEIGHT},
                {"GroundWormSpawnerActivateRadius", WORM_RADIUS},
              }
            },
            -- 0.3.0 A: te ven y vienen. Sin pausa, sin acecho, sin cansarse.
            {
              ["COMMENT"]            = "0.3.0 - sin acecho: te ve y arranca",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"PredatorNoticePauseTime",  NOTICE_PAUSE},
                {"PredatorApproachTime",     APPROACH_TIME},
                {"PredatorChargeDist",       CHARGE_DIST},
                {"PredatorEnergyUseChasing", ENERGY_CHASING},
              }
            },
            -- 0.3.0 B: que vengan derechos.
            {
              ["COMMENT"]            = "0.3.0 - rumbo directo: mas refresco de steering y giro cerrado",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"SteeringUpdateRate", STEER_RATE},
                {"MaxTurnRadius",      TURN_RADIUS},
              }
            },
            -- 0.3.0 C: horda. Cohesion y alineacion arriba, empuje mutuo abajo.
            {
              ["COMMENT"]            = "0.3.0 - horda: la manada se mueve como un bloque",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"FollowLeaderCohereWeight", COHERE_WEIGHT},
                {"FollowLeaderAlignWeight",  ALIGN_WEIGHT},
              }
            },
            {
              ["COMMENT"]             = "0.3.0 - horda: menos empujon mutuo (struct por tamano)",
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
        -- ---------- 0.3.0: arbol de comportamiento MELEE ----------
        -- ARCHIVO NUEVO, 8a ruta. Anclada a {"Id","MELEE"} con "ONCE":
        -- DynamicMoveSlowdownDistMul 4.0 y BehaviourMoveSpeed "Normal"
        -- aparecen tambien en RANGED_SPIT y RANGED_FIRE.
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
        -- ---------- 0.2.0: conducta de ataque del FIEND ----------
        -- CADA REGLA VA ANCLADA A {"Id", "FIEND"} CON REPLACE_TYPE "ONCE".
        -- Sin el ancla, un "ALL" tocaria los diez bloques de
        -- GcCreatureFiendAttackData, incluidos SCUTTLER_PET (la mascota
        -- del jugador) y BUGQUEEN (un jefe).
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
          }
        },
        -- ---------- Densidad de huevos: FIENDEGGS ----------
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
        -- ---------- Densidad de huevos y gusanos: INFESTATION ----------
        -- EL ORDEN DE ESTAS TRES REGLAS IMPORTA. Ver TRAMPA DE ORDEN arriba.
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
