--[[
  HORRIBLE TERROR - Infestacion :: FACIL
  ==================================================================
  MOD 2. Los Horrores Biologicos (FIEND en los archivos) dejan de ser
  una rareza y pasan a ser parte del paisaje. Los huevos se siembran
  por el terreno, y cuando uno eclosiona vienen mas y aguantan mas.

  >>> CONFIGURACION 1 de 4: FACIL <<<

  ------------------------------------------------------------------
  RELACION CON EL MOD 1 (Predators)
  ------------------------------------------------------------------
  Este mod INCLUYE los cambios del mod 1 en el tier equivalente. No se
  instalan los dos: escriben los mismos archivos y uno pisaria al otro
  en silencio.

      Mod 1 "Predators"    -> solo dificultad de depredadores
      Mod 2 "Infestation"  -> lo del mod 1 + los Fiends   <-- este

  Se versiona aparte y empieza en 0.1.0. No es una actualizacion del
  mod 1; es otro mod que reutiliza su calibracion.

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
  -- Parte nueva: Fiends --
  Densidad de huevos          x1      x2       x5      x20      x20
  FiendMaxAttackers            2       2        3        4        6
  FiendMaxEngaged              6       6        8       10       12
  MaxFiendsToSpawn             6       6        8       10       12
  FiendAggroTime (s)          45      45       60       90      120

  ESTE TIER no escribe ningun global de Fiend a proposito: los cuatro
  valores coinciden con vanilla y escribirlos ensuciaria el EXML delta
  sin cambiar nada. Facil solo multiplica los huevos por 2.

  ------------------------------------------------------------------
  QUE SIGNIFICA CADA PARAMETRO NUEVO
  ------------------------------------------------------------------
  Densidad de huevos     FlatDensity y SlopeDensity de FIENDEGG.SCENE en
                         FIENDEGGS.MBIN e INFESTATION.MBIN. Los huevos se
                         colocan como si fueran plantas: el bicho no sale
                         del ecosistema de fauna, sale del huevo. Tambien
                         multiplica el GROUNDWORMSPAWNER de INFESTATION,
                         que es el gusano de arena pequeno.

  FiendMaxAttackers      Cuantos Fiends pueden estar golpeandote a la vez.
                         Vanilla 2: los demas rodean y esperan turno.

  FiendMaxEngaged        Cuantos te tienen fichado a la vez, atacando o no.

  MaxFiendsToSpawn       Tope de Fiends que genera una eclosion.

  FiendAggroTime         Segundos que dura el estado de agresion. Vanilla
                         45. Subirlo alarga la persecucion tras romper un
                         huevo.

  ------------------------------------------------------------------
  ARCHIVOS QUE TOCA - 6 rutas
  ------------------------------------------------------------------
    METADATA\SIMULATION\ECOSYSTEM\CREATUREGENERATIONDATA.MBIN
    METADATA\SIMULATION\ECOSYSTEM\GROUND\GROUNDTABLEPLAYERPREDATORMED.MBIN
    METADATA\SIMULATION\ECOSYSTEM\GROUND\GROUNDTABLEPLAYERPREDATORLARGE.MBIN
    GLOBALS\GCCREATUREGLOBALS.MBIN
    METADATA\SIMULATION\SOLARSYSTEM\BIOMES\OBJECTS\RARE\FIENDEGGS.MBIN
    METADATA\SIMULATION\SOLARSYSTEM\BIOMES\OBJECTS\RARE\INFESTATION.MBIN

  Escaneo del 2026-07-30 sobre los 87 mods de terceros instalados:
  FIENDEGGS, INFESTATION y CREATUREDATATABLE estan libres. La unica ruta
  disputada es GCCREATUREGLOBALS, y solo contra nuestro propio mod 1.

  ------------------------------------------------------------------
  TRAMPAS VERIFICADAS - no tocar sin leer esto
  ------------------------------------------------------------------
  * TRAMPA NUEVA Y GRANDE: cada objeto de FIENDEGGS/INFESTATION lleva
    DOS bloques de densidad. El bueno es QualityVariants (los valores
    reales, distintos por objeto). Debajo hay otro llamado
    QualityVariantData con Coverage 0.2 / FlatDensity 0.5 IDENTICO en
    los cinco objetos de los dos archivos: tiene pinta de struct por
    defecto, no de dato real.
    --> Multiplicar "FlatDensity" a secas tocaria los dos. Por eso aqui
        se usa VALUE_MATCH: solo se multiplican las ocurrencias cuyo
        valor actual es el de vanilla del bloque bueno.

  * NO se toca Coverage. Los valores reales son 0.1, 1.0 y 2.0 y no
    sabemos el rango valido del campo; x20 sobre 2.0 podria salirse.
    FlatDensity/SlopeDensity son la palanca de densidad de verdad.

  * FiendMaxAttackers, FiendMaxEngaged y MaxFiendsToSpawn son ENTEROS
    en el MXML (value="2"), como MaxEcosystemCreaturesNormal. Escribir
    "4", no "4.000000". FiendAggroTime si es float.

  * "Weight " lleva un ESPACIO AL FINAL. Typo de Hello Games.

  * NO usar WHERE_IN_SECTION para el peso de DANGEROUS. WIS filtra
    secciones enteras: una version anterior puso a 1000 los 22 pesos de
    Generic. La via correcta es SPECIAL_KEY_WORDS encadenado.

  ------------------------------------------------------------------
  VALORES VANILLA VERIFICADOS (NMS 170671, MBINCompiler 6.45.0.1)
  ------------------------------------------------------------------
  FIENDEGGS.MBIN    2 objetos, los dos FIENDEGG.SCENE
                      Objects[0]       FLORACLUMP  Flat 0.005  Slope 0.005
                      DetailObjects[0] RAREX       Flat 0.005  Slope 0.005
  INFESTATION.MBIN  3 objetos
                      WORMSPAWNER  GROUNDWORMSPAWNER  Flat 0.025 Slope 0.030
                      FIENDEGGS    FIENDEGG           Flat 0.005 Slope 0.005
                      (sin nombre) FIENDEGG           Flat 0.005 Slope 0.005

  ------------------------------------------------------------------
  VERIFICACION ESPERADA
  ------------------------------------------------------------------
  REPORT: 23 CHANGE(s) en total.
    5 en CREATUREGENERATIONDATA (4 de densidad + 1 de peso)
    2 en cada tabla PLAYERPREDATOR (x2 archivos = 4)
    4 en GCCREATUREGLOBALS (solo depredador; este tier no toca Fiend)
    4 en FIENDEGGS    (2 FlatDensity + 2 SlopeDensity)
    6 en INFESTATION  (4 del grupo 0.005 + 1 de 0.025 + 1 de 0.030)
--]]

-- ---------- Heredado del mod 1 ----------
DENSITY_MULT     = 2
DANGEROUS_WEIGHT = "3.000000"
PACK_MIN         = "1"
PACK_MAX         = "2"
PERCEPTION       = "45.000000"
RUNAWAY_HP       = "30.000000"
PCT_HOSTILE      = "0.600000"
MAX_CREATURE     = "45"   -- ENTERO, sin decimales

-- ---------- Nuevo: Fiends ----------
EGG_MULT         = "2"
-- Sin globales de Fiend en este tier: coinciden con vanilla.

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HorribleTerror_Infestation_1-Facil",
["MOD_AUTHOR"]      = "ArDev-ACG",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[FACIL] Infestacion: huevos de Horror Biologico x2, mas los depredadores del mod de dificultad.",
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
        -- ---------- Sentidos del depredador ----------
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
          }
        },
        -- ---------- Densidad de huevos: FIENDEGGS ----------
        -- VALUE_MATCH acota al bloque QualityVariants. Sin el, los
        -- bloques QualityVariantData (0.5) tambien se multiplicarian.
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
        {
          ["MBIN_FILE_SOURCE"] = "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\OBJECTS\RARE\INFESTATION.MBIN",
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
          }
        },
      }
    },
  },
}
