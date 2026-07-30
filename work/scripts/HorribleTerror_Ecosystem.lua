--[[
  HORRIBLE TERROR - Ecosistema (script unificado)
  ==================================================================
  Reemplaza a HorribleTerror_GroundDensity.lua y
  HorribleTerror_PredatorWorlds.lua, que quedan retirados.

  ------------------------------------------------------------------
  POR QUE SE UNIFICO - no fue una mejora estetica, fue un BUG
  ------------------------------------------------------------------
  Los dos scripts anteriores generaban dos mods distintos que escribian
  EXACTAMENTE la misma ruta:

      METADATA/SIMULATION/ECOSYSTEM/CREATUREGENERATIONDATA.EXML

  Resultado in-game: planetas sin fauna. AMUMSS avisa de esto en el
  prompt de COMBINED/INDIVIDUAL, textualmente:

      "If they modify the same original EXML files, the last one loaded
       will win and the other changes will be lost"

  REGLA: dos mods nuestros NUNCA deben escribir el mismo archivo. Todo lo
  que toque CREATUREGENERATIONDATA vive en ESTE script. Si mas adelante
  hay que tocar rareza, RoleFrequencyModifiers o densidad de agua/aire,
  se anaden aqui, no en un script nuevo.

  ==================================================================
  CAMBIO 1 - Densidad de fauna terrestre
  ==================================================================
  GroundGroupsPerKm es la densidad TOTAL de grupos terrestres por km2.
  No distingue rol: multiplica herbivoros, pasivos y depredadores por
  igual. El reparto de roles se controla en el cambio 2.

  Vanilla:   Sparse 25   Normal 50   Dense 100   VeryDense 200
  Con x20:   Sparse 500  Normal 1000 Dense 2000  VeryDense 4000

  Probado in-game: x20 se ve claramente y no da problemas de
  rendimiento en los planetas donde se ha probado.

  IMPORTANTE - PRECEDING_KEY_WORDS es obligatorio aqui: las claves
  Sparse/Normal/Dense/VeryDense se repiten identicas en
  WaterGroupsPerKm, AirGroupsPerKm, CaveGroupsPerKm y DensityModifiers.

  ==================================================================
  CAMBIO 2 - Peso del arquetipo DANGEROUS
  ==================================================================
  'Generic -> Ground' es la lista ponderada que decide que arquetipo de
  fauna recibe cada planeta normal. Verificado: las listas Ground de
  BiomeSpecific estan vacias para todos los biomas corrientes, asi que
  los planetas normales caen todos aqui.

  Pesos vanilla (suman 11):
      DEFAULT 0 | BUTTERFLY 1 | ALIEN 1.5 | DANGEROUS 1 | HERD 1
      HUNTEDHERD 1 | PARADISE 1.5 | EMPTY 1 | GIANT 1 | SPARSE 1 | BUSY 1

  DANGEROUS trae GROUNDTABLEPLAYERPREDATORMED y ...LARGE, que son los
  que cazan AL JUGADOR. PREDATOR a secas caza otras criaturas y te
  ignora, por eso HUNTEDHERD y GIANT no sirven para un mod de terror.

  Con peso 1000: 1000/1010 = 99.0% de planetas normales.

  Se sube un peso en vez de bajar los otros diez. Mismo efecto con un
  solo cambio: menos que romper si NMS reordena la lista en un update, y
  menos choque con otros mods.

  TRAMPA: la propiedad se llama "Weight " CON ESPACIO AL FINAL. Es un
  typo de Hello Games en los datos del juego, igual que "BiomeSpecific ".

  TRAMPA 2: no usar WHERE_IN_SECTION para esto. WIS filtra secciones
  enteras, no localiza sub-secciones -- una version anterior puso a 1000
  los 22 pesos de Generic (Ground, Air, Cave y Water) en vez de uno.
  La via correcta es SKW con dos pares encadenados.

  ==================================================================
  VERIFICACION ESPERADA
  ==================================================================
  REPORT debe decir 5 CHANGE(s): 4 de densidad + 1 de peso.
  El EXML delta debe contener SOLO GroundGroupsPerKm y un unico
  Weight bajo Generic/Ground _index="3".
--]]

DENSITY_MULT     = 20
DANGEROUS_WEIGHT = "1000.000000"

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HorribleTerror_Ecosystem",
["MOD_AUTHOR"]      = "ArDev-ACG",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "Densidad de fauna terrestre x"..DENSITY_MULT.." y arquetipo DANGEROUS dominante: casi todos los planetas generan depredadores que cazan al jugador.",
["MODIFICATIONS"]   =
  {
    {
      ["MBIN_CHANGE_TABLE"] =
      {
        {
          ["MBIN_FILE_SOURCE"] = "METADATA\SIMULATION\ECOSYSTEM\CREATUREGENERATIONDATA.MBIN",
          ["MXML_CHANGE_TABLE"] =
          {
            -- Cambio 1: densidad terrestre
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
            -- Cambio 2: dominancia de DANGEROUS
            {
              ["COMMENT"]            = "Generic/Ground: DANGEROUS 1.0 -> "..DANGEROUS_WEIGHT,
              ["SPECIAL_KEY_WORDS"]  =
              {
                "Generic",   "GcCreatureGenerationWeightedList",
                "Archetype", "DANGEROUS",
              },
              ["REPLACE_TYPE"]       = "ONCE",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"Weight ", DANGEROUS_WEIGHT},
              }
            },
          }
        },
      }
    },
  },
}
