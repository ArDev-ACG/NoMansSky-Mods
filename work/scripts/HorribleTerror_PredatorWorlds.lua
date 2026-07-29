--[[
  HORRIBLE TERROR - Fase 1: infestacion (arquetipo DANGEROUS)
  ------------------------------------------------------------------
  Objetivo: que la mayoria de planetas normales generen depredadores que
  cazan AL JUGADOR, en vez de herbivoros pastando.

  No se inventa comportamiento hostil. El juego ya lo trae. Solo se sube
  el peso del arquetipo que ya existe.

  ------------------------------------------------------------------
  COMO ELIGE NMS QUE FAUNA PONE EN UN PLANETA
  ------------------------------------------------------------------
  CREATUREGENERATIONDATA tiene una lista ponderada por dominio:

      Generic -> Ground   (planetas normales)   <- ESTA es la palanca
      Generic -> Air / Cave / Water
      BiomeSpecific -> <bioma> -> Ground        (casi todas vacias)
      PurpleSystemSpecific -> ...               (sistemas purpura)

  Verificado: las listas Ground de BiomeSpecific estan VACIAS para Lush,
  Toxic, Scorched, Frozen, Barren, Dead, etc. O sea que los planetas
  normales caen todos en 'Generic'. Las unicas con contenido son las del
  bioma Weird (Beam, Hexagon, Shards...) y los sistemas purpura.

  Pesos vanilla de Generic -> Ground (suman 11):

      DEFAULT      0.00    0.0%   <- desactivado por Hello Games
      BUTTERFLY    1.00    9.1%
      ALIEN        1.50   13.6%
      DANGEROUS    1.00    9.1%   <- el que nos interesa
      HERD         1.00    9.1%
      HUNTEDHERD   1.00    9.1%
      PARADISE     1.50   13.6%
      EMPTY        1.00    9.1%
      GIANT        1.00    9.1%
      SPARSE       1.00    9.1%
      BUSY         1.00    9.1%

  Con DANGEROUS_WEIGHT = 1000 la cuenta queda 1000/1010 = 99.0% de los
  planetas normales.

  ------------------------------------------------------------------
  POR QUE SUBIR UNO Y NO BAJAR LOS DIEZ RESTANTES
  ------------------------------------------------------------------
  Da practicamente el mismo resultado (99.0% vs 100%) con 1 cambio en vez
  de 11. Menos superficie de fallo, menos que romper si NMS reordena la
  lista en un update, y menos choque con cualquier otro mod que toque
  esta tabla. Ademas ese 1% que sobrevive es sano: deja algun planeta
  raro sin infestar, que da contraste al mod en vez de aplanar todo.

  ------------------------------------------------------------------
  QUE TRAE DANGEROUS
  ------------------------------------------------------------------
  Del arquetipo, verificado en CREATUREGENERATIONARCHETYPES:

      GROUNDTABLEPLAYERPREDATORMED.MBIN     <- ataca al jugador
      GROUNDTABLEPLAYERPREDATORLARGE.MBIN   <- ataca al jugador
      GROUNDTABLEHERBIVOREMED.MBIN          <- presas, para que cace algo
      GROUNDTABLEPLANTCATPRED.MBIN
      GROUNDTABLEARTHROPODPRED.MBIN

  Ojo con la distincion: PLAYERPREDATOR te caza a TI. PREDATOR a secas
  caza otras criaturas y te ignora. HUNTEDHERD y GIANT solo traen
  PREDATOR, por eso no sirven para un mod de terror.

  ------------------------------------------------------------------
  TRAMPA: la propiedad se llama "Weight " CON ESPACIO AL FINAL
  ------------------------------------------------------------------
  En el MXML es literalmente:

      <Property name="Weight " value="1.000000" />

  Es un typo de Hello Games en los datos del juego, no un error de
  decompilacion. El mismo caso que "BiomeSpecific ". Si se busca "Weight"
  a secas el match puede fallar. Se usa el nombre exacto, con espacio.

  ------------------------------------------------------------------
  COMO SE ACOTA EL CAMBIO
  ------------------------------------------------------------------
  DANGEROUS aparece dos veces en el archivo: en 'Generic' y en
  'PurpleSystemSpecific'. Se usa PKW = {"Generic"} para quedarse solo con
  la primera. WHERE_IN_SECTION localiza la entrada por su Archetype, asi
  no hace falta LINE_OFFSET ni depender del _index -- si NMS reordena la
  lista en un update, el script sigue funcionando.

  --> COMPROBAR EN REPORT.lua que se hizo 1 cambio, no 2.
      Si son 2, se colo el de PurpleSystemSpecific.

  Archivo objetivo: METADATA\SIMULATION\ECOSYSTEM\CREATUREGENERATIONDATA.MBIN
--]]

-- 1000 sobre una suma vanilla de 11 => 99.0% de planetas infestados.
-- Valor de PRUEBA, igual que DENSITY_MULT = 20. Para release conviene algo
-- entre 5 y 20 (33% - 65%), que deja planetas seguros y hace que encontrar
-- uno infestado signifique algo.
DANGEROUS_WEIGHT = "1000.000000"

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HorribleTerror_PredatorWorlds",
["MOD_AUTHOR"]      = "ArDev-ACG",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "Sube el peso del arquetipo DANGEROUS para que casi todos los planetas normales generen depredadores que cazan al jugador.",
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
              ["COMMENT"]             = "Generic/Ground: DANGEROUS 1.0 -> "..DANGEROUS_WEIGHT,
              ["PRECEDING_KEY_WORDS"] = {"Generic"},
              ["WHERE_IN_SECTION"]    = {{"Archetype", "DANGEROUS"}},
              ["VALUE_CHANGE_TABLE"]  =
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
