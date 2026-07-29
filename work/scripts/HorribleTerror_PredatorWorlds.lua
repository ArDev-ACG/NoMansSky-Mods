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
  Cada entrada de la lista es un bloque con dos hijos:

      <Property name="Ground" value="GcCreature...DomainEntry" _index="3">
          <Property name="Weight " value="1.000000" />
          <Property name="Archetype" value="DANGEROUS" />
      </Property>

  Hay que cambiar el hermano ANTERIOR del Archetype que nos interesa. Se
  usa SPECIAL_KEY_WORDS con dos pares:

      par 1: ("Generic","GcCreatureGenerationWeightedList")  -> fija la seccion
      par 2: ("Archetype","DANGEROUS")                       -> la linea exacta

  El primer par es imprescindible: DANGEROUS aparece dos veces en el
  archivo, en 'Generic' y en 'PurpleSystemSpecific'. Sin el, se tocarian
  las dos.

  Localizar por Archetype y no por _index es a proposito: si NMS reordena
  la lista en un update, el script sigue apuntando al sitio correcto.

  ------------------------------------------------------------------
  INTENTO FALLIDO - NO VOLVER A ESTA VIA
  ------------------------------------------------------------------
  Primera version uso PKW = {"Generic"} + WHERE_IN_SECTION con el par
  ("Archetype","DANGEROUS"). Resultado: 22 cambios en vez de 1. Puso a
  1000 TODOS los pesos de Generic -- Ground(11) + Air(7) + Cave(2) +
  Water(2).

  Motivo: WHERE_IN_SECTION es un FILTRO de secciones, no un localizador
  de sub-seccion. PKW selecciono el bloque 'Generic' entero, WIS comprobo
  "¿contiene Archetype=DANGEROUS?" -> si -> y el VCT reescribio todos los
  "Weight " de dentro.

  Efecto real de aquel bug: todos los pesos iguales = reparto plano.
  DANGEROUS se quedaba en 9.1%, igual que vanilla, y encima aplastaba Air
  (DEFAULT del 52% al 14%). Peor que no tocar nada.

  --> COMPROBAR EN REPORT.lua que se hace 1 cambio, no 22 ni 2.
      Si son 2, se colo el de PurpleSystemSpecific.
      Construir con [N] (no copiar) hasta que el conteo sea 1.

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
