--[[
  HORRIBLE TERROR - Infestacion :: NORMAL
  ==================================================================
  MOD 2, version 0.2.0. Los Horrores Biologicos (FIEND en los archivos)
  dejan de ser una rareza y pasan a ser parte del paisaje. Los huevos se
  siembran por el terreno y la eclosion viene mas seguida.

  >>> CONFIGURACION 2 de 4: NORMAL <<<

  ------------------------------------------------------------------
  NOVEDADES DE 0.2.0
  ------------------------------------------------------------------
  0.1.0 subia CANTIDAD de Fiends. 0.2.0 cambia su CONDUCTA. Este tier
  coge solo la mitad suave de los cambios:

    2  FiendPerceptionDistance  60 -> 65     te ven algo antes
    3  FiendMin/MaxSpawnTime 0.25/3 -> 0.2/2.0   eclosion mas junta
    4  AvoidCreaturesWeight  6 -> 8          menos amontonamiento
    4b GroundWormSpawnerActivateRadius 100 -> 50  el gusano salta antes
    6  DelayBetweenPounceAttacks 2.0 -> 1.8  salta algo mas seguido

  NO entran en este tier, son de Dificil/Hardcore:
    1  FiendOnscreenMarkers  -> el marcador de UI se mantiene
    5  MinFlurryHits/Max     -> racha vanilla 2/4
    7  AnimSpeedModifier     -> velocidad de ataque vanilla
    8  AllowSpawnBrood       -> no se multiplican

  El punto 6 estrena un archivo nuevo: CREATUREDATATABLE.MBIN.

  El zigzag (FiendZigZagSpeed/Strength) estuvo en la lista de 0.2.0 y se
  ha QUITADO de todos los tiers SIN llegar a probarlo. Motivo: se vio
  in-game que los Fiend ya se acercan zigzagueando con el campo a 0, o
  sea que no es la palanca que lo causa -- y subirlo iria en contra de lo
  que se busca, que vengan DERECHOS a por ti. Todos los tiers se quedan
  en el vanilla 0.

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
        Por eso la regla lleva SPECIAL_KEY_WORDS anclado a
        {"Id", "FIEND"} y REPLACE_TYPE = "ONCE".

  * TRAMPA DE ORDEN (encontrada al construir 0.1.0, y este tier es donde
    se manifestaba): las reglas de un mismo archivo se aplican EN
    SECUENCIA, asi que un valor ya escrito puede encajar en el
    VALUE_MATCH de una regla posterior. Con EGG_MULT = 5 los huevos
    pasaban a 0.025 y la regla del gusano (VALUE_MATCH 0.025) los volvia
    a multiplicar: FlatDensity 0.125 = x25 en vez de x5, y 29 cambios en
    vez de 27. Por eso en INFESTATION el gusano va PRIMERO y los huevos
    ULTIMOS. Con x2 y x20 la colision no se daba: SOLO fallaba aqui.

  * Cada objeto de FIENDEGGS/INFESTATION lleva DOS bloques de densidad.
    El bueno es QualityVariants. Debajo hay un QualityVariantData con
    Coverage 0.2 / FlatDensity 0.5 identico en los cinco objetos.
    --> Por eso se usa VALUE_MATCH.

  * NO se toca Coverage. Rango valido desconocido.

  * ENTEROS, sin decimales: FiendMaxAttackers, FiendMaxEngaged,
    MaxFiendsToSpawn y MaxEcosystemCreaturesNormal. Lo demas es float.

  * "Weight " lleva un ESPACIO AL FINAL. Typo de Hello Games.

  * NO usar WHERE_IN_SECTION para el peso de DANGEROUS.

  ------------------------------------------------------------------
  VERIFICACION ESPERADA
  ------------------------------------------------------------------
  REPORT: 45 CHANGE(s) en total.
     5 en CREATUREGENERATIONDATA (4 de densidad + 1 de peso)
     2 en cada tabla PLAYERPREDATOR (x2 archivos = 4)
    24 en GCCREATUREGLOBALS (4 depredador + 4 Fiend 0.1.0 + 5 de 0.2.0
                             + 11 de 0.3.0: 4 acecho + 2 rumbo + 5 horda)
     1 en CREATUREDATATABLE (cadencia del salto)
     1 en CREATUREBEHAVIOURTREES (Slowdown, solo MELEE)
     4 en FIENDEGGS    (2 FlatDensity + 2 SlopeDensity)
     6 en INFESTATION  (4 del grupo 0.005 + 1 de 0.025 + 1 de 0.030)
--]]

-- ---------- Heredado del mod 1 ----------
DENSITY_MULT     = 5
DANGEROUS_WEIGHT = "10.000000"
PACK_MIN         = "2"
PACK_MAX         = "3"
PERCEPTION       = "50.000000"
RUNAWAY_HP       = "15.000000"
PCT_HOSTILE      = "0.750000"
MAX_CREATURE     = "50"   -- ENTERO, sin decimales

-- ---------- Fiends: cantidad (0.1.0) ----------
EGG_MULT         = "5"
FIEND_ATTACKERS  = "3"    -- ENTERO
FIEND_ENGAGED    = "8"    -- ENTERO
FIEND_SPAWN      = "8"    -- ENTERO
FIEND_AGGRO      = "60.000000"

-- ---------- Fiends: conducta (0.2.0) ----------
-- Este tier NO toca marcadores, racha, velocidad de ataque ni
-- brood: coinciden con vanilla y escribirlos ensuciaria el EXML delta.
FIEND_PERCEPTION = "65.000000"    -- 2
HATCH_MIN        = "0.200000"     -- 4
HATCH_MAX        = "2.000000"     -- 4
AVOID_WEIGHT     = "8.000000"     -- 5
WORM_RADIUS      = "50.000000"    -- 5b
POUNCE_DELAY     = "1.800000"     -- 7

-- ---------- 0.3.0: que vengan DERECHOS, SIN ACECHAR y EN HORDA ----------
-- Valores vanilla extraidos de NMSARC.globals.pak el 2026-08-04.
-- Normal se queda a medio camino: acorta el acecho pero no lo elimina.
-- A) SIN ACECHAR
NOTICE_PAUSE     = "0.800000"     -- A1  vanilla 1.5
APPROACH_TIME    = "2.000000"     -- A2  vanilla 4.0
CHARGE_DIST      = "12.000000"    -- A3  vanilla 7.0
ENERGY_CHASING   = "-0.050000"    -- A4  vanilla -0.1
-- B) DERECHOS
STEER_RATE       = "0.200000"     -- B1  vanilla 0.25
TURN_RADIUS      = "4.000000"     -- B2  vanilla 5.0
-- C) EN HORDA
COHERE_WEIGHT    = "0.400000"     -- C1  vanilla 0.1
ALIGN_WEIGHT     = "1.500000"     -- C2  vanilla 1.0
PUSH_SMALL       = "9.000000"     -- C3  vanilla 10
PUSH_MEDIUM      = "9.000000"     --     vanilla 10
PUSH_LARGE       = "4.500000"     --     vanilla 5
-- D) ARBOL MELEE
-- BehaviourMoveSpeed NO se escribe: Normal ya es el valor vanilla.
MELEE_SLOWDOWN   = "3.000000"     -- D2  vanilla 4.0

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HorribleTerror_Infestation_2-Normal",
["MOD_AUTHOR"]      = "ArDev-ACG",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[NORMAL] Infestacion 0.2.0: huevos de Horror Biologico x5, eclosion mas junta, mas los depredadores del mod de dificultad.",
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
            -- 0.2.0: conducta (mitad suave)
            {
              ["COMMENT"]            = "0.2.0 - percepcion de Fiend a "..FIEND_PERCEPTION,
              ["VALUE_CHANGE_TABLE"] = { {"FiendPerceptionDistance", FIEND_PERCEPTION} }
            },
            {
              ["COMMENT"]            = "0.2.0 - eclosion mas junta",
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
            -- 0.3.0 A: acecho acortado, no eliminado.
            {
              ["COMMENT"]            = "0.3.0 - menos acecho",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"PredatorNoticePauseTime",  NOTICE_PAUSE},
                {"PredatorApproachTime",     APPROACH_TIME},
                {"PredatorChargeDist",       CHARGE_DIST},
                {"PredatorEnergyUseChasing", ENERGY_CHASING},
              }
            },
            -- 0.3.0 B: rumbo mas directo.
            {
              ["COMMENT"]            = "0.3.0 - rumbo directo: mas refresco de steering y giro mas cerrado",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"SteeringUpdateRate", STEER_RATE},
                {"MaxTurnRadius",      TURN_RADIUS},
              }
            },
            -- 0.3.0 C: horda suave.
            {
              ["COMMENT"]            = "0.3.0 - horda: la manada se mantiene mas junta",
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
        -- DynamicMoveSlowdownDistMul 4.0 aparece tambien en RANGED_SPIT y
        -- RANGED_FIRE. Normal NO toca BehaviourMoveSpeed: ya es "Normal".
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
        -- ---------- 0.2.0: conducta de ataque del FIEND ----------
        -- ANCLADA A {"Id", "FIEND"} CON REPLACE_TYPE "ONCE". Sin el ancla,
        -- un "ALL" tocaria los diez bloques de GcCreatureFiendAttackData,
        -- incluidos SCUTTLER_PET (la mascota del jugador) y BUGQUEEN.
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
        -- EL ORDEN DE ESTAS TRES REGLAS IMPORTA, Y EN ESTE TIER
        -- ESPECIALMENTE. Ver TRAMPA DE ORDEN arriba: con x5 es donde la
        -- cascada se manifestaba. Gusano PRIMERO, huevos ULTIMOS.
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
