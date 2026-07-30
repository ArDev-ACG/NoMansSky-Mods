--[[
  HORRIBLE TERROR - Sentidos y tenacidad del depredador
  ==================================================================
  Archivo objetivo: GLOBALS\GCCREATUREGLOBALS.MBIN

  Un solo archivo, un solo mod. Todo lo que toque GCCREATUREGLOBALS va
  aqui: si mas adelante hay que ajustar velocidades, vida o los limites
  de Fiend, se anaden a este script, NO a uno nuevo (ver §10i del doc de
  proyecto: dos mods escribiendo el mismo EXML dejaron los planetas sin
  fauna).

  ------------------------------------------------------------------
  CAMBIOS
  ------------------------------------------------------------------

  1) PredatorPerceptionDistance   40 -> 60
     Radio al que el depredador detecta al jugador. +50% de alcance.
     Te ven desde mucho mas lejos, asi que los encuentros empiezan antes
     y hay menos margen para rodear una zona sin ser visto.

  2) PredatorRunAwayHealthPercent  40 -> 0
     Vanilla: al bajar del 40% de vida el depredador huye. A 0 no huye
     nunca: pelea hasta morir. Es EL cambio que separa "animal salvaje"
     de "cosa que no deberia estar viva". Un zombie no se retira.

  3) PercentagePlayerPredators    0.5 -> 1.0
     Que proporcion de los depredadores generados son PlayerPredator
     (te cazan a TI) en vez de Predator normal (cazan otras criaturas y
     te ignoran). A 1.0, TODOS van a por ti.

     Nota: esta palanca rinde mas que la densidad. Con el tope de
     criaturas simultaneas ya tocado, convertir los depredadores
     existentes en hostiles cuesta 0 rendimiento -- no anade bichos,
     cambia lo que hacen los que ya hay.

  4) MaxEcosystemCreaturesNormal   40 -> 60
     Tope duro de criaturas cargadas a la vez. +50%.
     Es el unico cambio de este script con coste de rendimiento real.

  ------------------------------------------------------------------
  LO QUE NO SE TOCA, Y POR QUE
  ------------------------------------------------------------------

  PlayerPredatorBoredomDistance -- ya es 80 en vanilla. Pedido "subir a
  80" = sin cambio. Se deja fuera del script en vez de escribir 80 sobre
  80: un cambio nulo ensucia el EXML delta y hace mas dificil leer que
  toco el mod de verdad.

  Interaccion a vigilar: con percepcion 60 y aburrimiento 80, el margen
  para escapar se estrecha de 40 m a 20 m. Sigues libre al pasar de 80 m,
  pero te vuelven a detectar a 60 en vez de a 40, asi que reenganchan
  mucho mas facil. Si escapar resulta imposible, la palanca es subir
  BoredomDistance, no bajar la percepcion.

  SpawnsAvoidBaseMultiplier (3) -- APLAZADO A PROPOSITO.
  Es el parametro que mantiene la fauna lejos de bases y asentamientos.
  Bajarlo pondria bichos rondando tu base. Queda anotado como feature
  futura de tipo evento/horda, no como comportamiento permanente:
  tener depredadores permanentemente encima de la base propia cansa
  rapido y es justo el tipo de cosa que genera quejas en Nexus.
  Ver docs/IDEAS.md.

  ------------------------------------------------------------------
  TRAMPA: MaxEcosystemCreaturesNormal es ENTERO
  ------------------------------------------------------------------
  En el MXML es <Property name="MaxEcosystemCreaturesNormal" value="40" />
  sin decimales, a diferencia del resto que son floats. Hay que escribir
  "60" y no "60.000000" o MBINCompiler puede rechazar la compilacion.
  Verificado uno por uno: los otros cuatro SI son floats.

  ------------------------------------------------------------------
  AVISO DE ACUMULACION
  ------------------------------------------------------------------
  Estos cambios se multiplican con los otros dos mods:

      Ecosystem      99% de planetas con arquetipo DANGEROUS
      PredatorPacks  manadas de 3-5 en vez de 1
      Senses         100% hostiles, detectan a 60 m, no huyen nunca

  El resultado combinado es MUY superior a la suma de las partes. Si
  queda injugable, el orden para aflojar es: primero
  PercentagePlayerPredators, luego el tamano de manada, y la densidad la
  ultima (ya esta topada por MaxEcosystemCreatures y bajarla no hara
  tanto como parece).

  ------------------------------------------------------------------
  VERIFICACION ESPERADA
  ------------------------------------------------------------------
  REPORT: 4 CHANGE(s). El EXML delta debe contener exactamente esas
  cuatro propiedades y ninguna mas.
--]]

PERCEPTION   = "60.000000"   -- vanilla 40
RUNAWAY_HP   = "0.000000"    -- vanilla 40 (% de vida al que huye)
PCT_HOSTILE  = "1.000000"    -- vanilla 0.5
MAX_CREATURE = "60"          -- vanilla 40  -- ENTERO, sin decimales

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HorribleTerror_PredatorSenses",
["MOD_AUTHOR"]      = "ArDev-ACG",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "Los depredadores detectan al jugador a 60m, todos son hostiles y pelean hasta morir. Sube el tope de criaturas simultaneas a 60.",
["MODIFICATIONS"]   =
  {
    {
      ["MBIN_CHANGE_TABLE"] =
      {
        {
          ["MBIN_FILE_SOURCE"] = "GLOBALS\GCCREATUREGLOBALS.MBIN",
          ["MXML_CHANGE_TABLE"] =
          {
            {
              ["COMMENT"]            = "Sentidos y tenacidad del depredador",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"PredatorPerceptionDistance",  PERCEPTION},
                {"PredatorRunAwayHealthPercent", RUNAWAY_HP},
                {"PercentagePlayerPredators",   PCT_HOSTILE},
                {"MaxEcosystemCreaturesNormal", MAX_CREATURE},
              }
            },
          }
        },
      }
    },
  },
}
