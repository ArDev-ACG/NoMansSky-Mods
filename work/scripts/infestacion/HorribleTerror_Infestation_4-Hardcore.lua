--[[
  HORRIBLE TERROR - Infestacion :: HARDCORE
  ==================================================================
  MOD 2, version 0.2.0. Los Horrores Biologicos (FIEND en los archivos)
  dejan de ser una rareza y pasan a ser parte del paisaje. Los huevos se
  siembran por el terreno, y cuando uno eclosiona vienen mas, mas rapido,
  pegan mas seguido y no te sueltan.

  >>> CONFIGURACION 4 de 4: HARDCORE <<<

  ------------------------------------------------------------------
  NOVEDADES DE 0.2.0
  ------------------------------------------------------------------
  0.1.0 subia CANTIDAD de Fiends. 0.2.0 cambia su CONDUCTA:

    1  FiendOnscreenMarkers  true -> false   sin marcador de UI
    2  FiendPerceptionDistance  60 -> 80     te ven tan lejos como
                                             los depredadores
    3  FiendMin/MaxSpawnTime 0.25/3 -> 0.1/0.5    eclosion en oleada
    4  AvoidCreaturesWeight  6 -> 10         menos amontonamiento
    4b GroundWormSpawnerActivateRadius 100 -> 10  el gusano salta
                                             cuando ya lo tienes encima
    5  MinFlurryHits/Max  2/4 -> 3/6         mas golpes por racha
    6  DelayBetweenPounceAttacks 2.0 -> 1.2  salta mas seguido
    7  AnimSpeedModifier 1.0 -> 1.2          ataca mas rapido
    8  AllowSpawnBrood false -> true         SE MULTIPLICAN mientras
                                             luchas (solo Hardcore)

  Los puntos 5-8 estrenan un archivo nuevo: CREATUREDATATABLE.MBIN.

  El zigzag estaba en esta lista y se ha QUITADO sin llegar a probarlo:
  los Fiend ya zigzaguean con el campo a 0. Ver la seccion de la sesion
  del 2026-08-04 mas abajo.

  ------------------------------------------------------------------
  RELACION CON EL MOD 1 (Predators)
  ------------------------------------------------------------------
  Este mod INCLUYE los cambios del mod 1 en el tier equivalente. No se
  instalan los dos: escriben los mismos archivos y uno pisaria al otro
  en silencio.

      Mod 1 "Predators"    -> solo dificultad de depredadores
      Mod 2 "Infestation"  -> lo del mod 1 + los Fiends   <-- este

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

  Facil no escribe ningun global de Fiend ni toca CREATUREDATATABLE a
  proposito: sus valores coinciden con vanilla y escribirlos ensuciaria
  el EXML delta sin cambiar nada.

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
  La unica disputada es GCCREATUREGLOBALS, y solo contra nuestro mod 1.

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
    Coverage 0.2 / FlatDensity 0.5 identico en los cinco objetos: es un
    struct por defecto, no un dato real.
    --> Por eso se usa VALUE_MATCH: solo se multiplican las ocurrencias
        cuyo valor actual es el de vanilla del bloque bueno.

  * NO se toca Coverage. Los valores reales son 0.1, 1.0 y 2.0 y no
    sabemos el rango valido del campo; x20 sobre 2.0 podria salirse.

  * TRAMPA DE ORDEN (2026-08-01): las reglas de un mismo archivo se
    aplican EN SECUENCIA, asi que un valor ya escrito puede encajar en el
    VALUE_MATCH de una regla posterior. Con EGG_MULT = 5 los huevos
    pasaban a 0.025 y la regla del gusano (VALUE_MATCH 0.025) los volvia
    a multiplicar. Por eso en INFESTATION el gusano va PRIMERO y los
    huevos ULTIMOS.

  * ENTEROS, sin decimales: FiendMaxAttackers, FiendMaxEngaged,
    MaxFiendsToSpawn, MaxEcosystemCreaturesNormal, MinFlurryHits y
    MaxFlurryHits. Todo lo demas es float con 6 decimales.

  * BOOLEANOS: FiendOnscreenMarkers y AllowSpawnBrood se escriben
    "false"/"true" en minusculas, sin comillas en el MXML.

  * "Weight " lleva un ESPACIO AL FINAL. Typo de Hello Games.

  * NO usar WHERE_IN_SECTION para el peso de DANGEROUS. WIS filtra
    secciones enteras: una version anterior puso a 1000 los 22 pesos de
    Generic. La via correcta es SPECIAL_KEY_WORDS encadenado.

  ------------------------------------------------------------------
  SESION DEL 2026-08-04: LA PRUEBA MIDIO 0.1.0, NO 0.2.0
  ------------------------------------------------------------------
  0.2.0 se construyo el 04/08 y NUNCA se copio a GAMEDATA\MODS. Lo que
  estaba instalado al probar era 0.1.0: 9 cambios en GCCREATUREGLOBALS
  y ningun CREATUREDATATABLE.EXML. Comprobado leyendo el EXML desplegado.

  --> REGLA: construir NO es desplegar. Antes de cualquier prueba
      in-game, leer el EXML de GAMEDATA\MODS y confirmar que contiene
      los campos de la version que se cree estar probando. El conteo del
      REPORT solo dice que la build salio; no dice que este en el juego.

  Lo que la prueba SI demuestra, aun midiendo 0.1.0:

  * Los Fiend se acercan zigzagueando CON FiendZigZagSpeed = 0. O sea
    que ese campo NO es la causa del zigzag que se ve en pantalla.
    Subirlo a 1.5 solo habria empeorado lo que molesta.
    --> Por eso se retira de 0.2.0: el objetivo es que vengan DERECHOS,
        y este campo empuja justo al reves. Nunca llego a probarse.
    --> La causa real esta sin identificar. Sospechosos, por orden:
        MaxTurnRadius = 5.0 (no pueden girar cerrado hacia ti, sobrepasan
        y corrigen), el empuje entre bichos de las manadas 5/7 que
        introdujo el mod 1 (SpherePusher*), y AvoidCreaturesStrength = 0
        en el arbol MELEE. Ver COMPORTAMIENTO.md 5.

  * AllowSpawnBrood: veredicto NULO. El archivo no estaba en el juego,
    asi que "no se multiplicaban" no dice nada del campo. Sigue
    [SIN PROBAR] igual que antes de la sesion.

  * FiendOnscreenMarkers: veredicto NULO por el mismo motivo. El
    marcador que se vio es el vanilla, porque el cambio no estaba puesto.

  Nota para la primera prueba real del brood: con FiendMaxEngaged = 12 y
  los huevos x20, una cria de brood es indistinguible de un Fiend salido
  de un huevo. Hace falta un sitio con Fiends pero SIN huevos cerca, o la
  prueba no medira nada.

  ------------------------------------------------------------------
  VERIFICACION ESPERADA
  ------------------------------------------------------------------
  REPORT: 54 CHANGE(s) en total.
     5 en CREATUREGENERATIONDATA (4 de densidad + 1 de peso)
     2 en cada tabla PLAYERPREDATOR (x2 archivos = 4)
    26 en GCCREATUREGLOBALS (5 depredador + 4 Fiend 0.1.0 + 6 de 0.2.0
                             + 11 de 0.3.0: 4 acecho + 2 rumbo + 5 horda)
     7 en CREATUREDATATABLE (2 racha + 1 salto + 1 anim + 3 de brood)
     4 en FIENDEGGS    (2 FlatDensity + 2 SlopeDensity)
     6 en INFESTATION  (4 del grupo 0.005 + 1 de 0.025 + 1 de 0.030)
     2 en CREATUREBEHAVIOURTREES (MoveSpeed + Slowdown, solo MELEE)
--]]

-- ---------- Heredado del mod 1 ----------
DENSITY_MULT     = 20
DANGEROUS_WEIGHT = "1000.000000"
PACK_MIN         = "5"
PACK_MAX         = "7"
PERCEPTION       = "80.000000"
RUNAWAY_HP       = "0.000000"
PCT_HOSTILE      = "1.000000"
MAX_CREATURE     = "70"   -- ENTERO, sin decimales
BOREDOM          = "150.000000"

-- ---------- Fiends: cantidad (0.1.0) ----------
EGG_MULT         = "20"
FIEND_ATTACKERS  = "6"    -- ENTERO
FIEND_ENGAGED    = "12"   -- ENTERO
FIEND_SPAWN      = "12"   -- ENTERO
FIEND_AGGRO      = "120.000000"

-- ---------- Fiends: conducta (0.2.0) ----------
FIEND_MARKERS    = "false"        -- 1  [SIN PROBAR] nunca se desplego
FIEND_PERCEPTION = "80.000000"    -- 2
HATCH_MIN        = "0.100000"     -- 3
HATCH_MAX        = "0.500000"     -- 3
AVOID_WEIGHT     = "10.000000"    -- 4
WORM_RADIUS      = "10.000000"    -- 4b
FLURRY_MIN       = "3"            -- 5  ENTERO
FLURRY_MAX       = "6"            -- 5  ENTERO
POUNCE_DELAY     = "1.200000"     -- 6
ANIM_SPEED       = "1.200000"     -- 7
BROOD_ALLOW      = "true"         -- 8  [SIN PROBAR]
BROOD_ID         = "BUGFIENDS"    -- 8  copiado de BUGQUEEN vanilla
BROOD_TIMER      = "10.000000"    -- 8  BUGQUEEN usa 30; bajado a 10
                                  --    para que llegue a saltar dentro
                                  --    de un combate y se pueda VER
-- ZigZag retirado: con el campo a 0 los Fiend ya zigzaguean, asi que no
-- es la palanca, y subirlo iria en contra de que vengan derechos.

-- ---------- 0.3.0: que vengan DERECHOS, SIN ACECHAR y EN HORDA ----------
-- Valores vanilla extraidos de NMSARC.globals.pak el 2026-08-04, no de
-- los backups de AMUMSS (que traen el archivo ya modificado).
--
-- A) SIN ACECHAR. La secuencia vanilla es: te ve -> pausa 1.5 s ->
--    se acerca -> acecha 4 s -> carga a 7 m. Se elimina entera.
NOTICE_PAUSE     = "0.000000"     -- A1  vanilla 1.5  pausa dramatica al verte
APPROACH_TIME    = "0.000000"     -- A2  vanilla 4.0  fase de acecho
CHARGE_DIST      = "40.000000"    -- A3  vanilla 7.0  carga desde lejos
ENERGY_CHASING   = "0.000000"     -- A4  vanilla -0.1 perseguir gastaba energia
--
-- B) DERECHOS. Sospechosos reales del zigzag, ninguno es FiendZigZag*.
STEER_RATE       = "0.100000"     -- B1  vanilla 0.25 recalculaba rumbo 4 veces/s
TURN_RADIUS      = "2.000000"     -- B2  vanilla 5.0  no podian virar cerrado
--
-- C) EN HORDA. Manada que se mueve como un bloque, no como 7 sueltos.
COHERE_WEIGHT    = "1.200000"     -- C1  vanilla 0.1  cohesion de la manada
ALIGN_WEIGHT     = "3.500000"     -- C2  vanilla 1.0  van en la misma direccion
PUSH_SMALL       = "5.000000"     -- C3  vanilla 10   menos empujones entre
PUSH_MEDIUM      = "5.000000"     --     vanilla 10   ellos = no se sacan unos
PUSH_LARGE       = "3.000000"     --     vanilla 5    a otros de su linea
--
-- D) ARBOL MELEE. Primera vez que tocamos CREATUREBEHAVIOURTREES.
MELEE_SPEED      = "Fast"         -- D1  vanilla Normal. RANGED_FIRE ya usa Fast
MELEE_SLOWDOWN   = "1.000000"     -- D2  vanilla 4.0  frenaban al acercarse
--
-- NO se toca AvoidCreaturesStrength del arbol MELEE (0.0). COMPORTAMIENTO.md
-- lo proponia para separar la manada; va justo en contra de "en horda".

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HorribleTerror_Infestation_4-Hardcore",
["MOD_AUTHOR"]      = "ArDev-ACG",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[HARDCORE] Infestacion 0.2.0: huevos x20, sin marcador de UI, eclosion en oleada, se multiplican mientras luchas, mas los depredadores del mod de dificultad.",
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
                {"PlayerPredatorBoredomDistance", BOREDOM},
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
                {"PredatorNoticePauseTime", NOTICE_PAUSE},
                {"PredatorApproachTime",    APPROACH_TIME},
                {"PredatorChargeDist",      CHARGE_DIST},
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
        -- ARCHIVO NUEVO, 8a ruta. Las dos reglas van ancladas a {"Id","MELEE"}
        -- con REPLACE_TYPE "ONCE": DynamicMoveSlowdownDistMul 4.0 y
        -- BehaviourMoveSpeed "Normal" aparecen tambien en RANGED_SPIT y
        -- RANGED_FIRE. MELEE es ademas el primer arbol del archivo.
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
            {
              ["COMMENT"]            = "FIEND: se multiplica mientras luchas [SIN PROBAR]",
              ["SPECIAL_KEY_WORDS"]  = {"Id", "FIEND"},
              ["REPLACE_TYPE"]       = "ONCE",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"AllowSpawnBrood",  BROOD_ALLOW},
                {"SpawnBroodID",     BROOD_ID},
                {"SpawnBroodTimer",  BROOD_TIMER},
              }
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
