--[[
  HORRIBLE TERROR - Manadas de depredadores
  ==================================================================
  Los depredadores que cazan al jugador salen DE UNO EN UNO en vanilla.
  Este script los convierte en jaurias de 3 a 5.

  ------------------------------------------------------------------
  EL PROBLEMA QUE RESUELVE
  ------------------------------------------------------------------
  Con densidad x20 hay muchisima fauna, pero los encuentros hostiles se
  sienten flojos. La razon esta aqui:

      GROUNDTABLEPLAYERPREDATORMED    MinGroupSize 1 / MaxGroupSize 1
      GROUNDTABLEPLAYERPREDATORLARGE  MinGroupSize 1 / MaxGroupSize 1

  Es diseno de Hello Games: subir la densidad multiplica los herbivoros,
  pero los que te atacan siguen apareciendo solos. Por eso el x20 se nota
  visualmente y no se nota en la amenaza.

  ------------------------------------------------------------------
  POR QUE 3-5 ES SEGURO
  ------------------------------------------------------------------
  Tres cosas verificadas antes de tocar nada:

  1) NO hay fuego amigo. El nodo de dano del arbol MELEE es
     GcBehaviourApplyDamageData con PlayerDamageType = FIEND_DMG y
     Radius 1.0. Es dano AL JUGADOR, no un area que pille a otros
     bichos. Cinco depredadores no se matan entre ellos.

  2) HAY TOPE GLOBAL. GCCREATUREGLOBALS trae
     MaxEcosystemCreaturesNormal = 40 (y Low = 20). El motor no va a
     cargar mas de 40 criaturas a la vez pase lo que pase. Manadas
     grandes no revientan nada: consumen presupuesto, asi que se veran
     menos grupos distintos pero mas numerosos.

  3) LAS DOS TABLAS SON EQUIVALENTES en estructura. Una sola entrada
     RoleDescription cada una, un solo MinGroupSize y un solo
     MaxGroupSize. No hace falta acotar con keywords.

  ------------------------------------------------------------------
  RIESGO CONOCIDO: amontonamiento
  ------------------------------------------------------------------
  El global AvoidCreaturesWeight = 6 hace que las criaturas se esquiven
  entre si... pero el nodo MOVE_CLOSE del arbol MELEE lo pisa con
  AvoidCreaturesStrength = 0 mientras cargan contra el objetivo.

  Traduccion: mientras te persiguen NO se esquivan. Con 5 bichos podrian
  amontonarse o solaparse visualmente.

  NO se toca todavia a proposito. Los arboles de comportamiento son la
  capa mas fragil del ecosistema y el sintoma puede no aparecer siquiera.
  Si in-game se ve mal, la correccion es subir AvoidCreaturesStrength de
  0 a ~0.3-0.5 en el nodo MOVE_CLOSE de CREATUREBEHAVIOURTREES.

  ------------------------------------------------------------------
  POR QUE ES UN SCRIPT APARTE Y NO VA EN Ecosystem.lua
  ------------------------------------------------------------------
  Toca archivos DISTINTOS (GROUND/GROUNDTABLE*), no
  CREATUREGENERATIONDATA. Sin solape = sin riesgo de la colision que
  dejo los planetas sin fauna. Ver §10i del doc de proyecto.

  Antes de cada build con varios scripts, comprobar que ningun par de
  mods escribe la misma ruta EXML.

  ------------------------------------------------------------------
  VERIFICACION ESPERADA
  ------------------------------------------------------------------
  REPORT: 4 CHANGE(s) -- 2 por archivo, en 2 archivos.
  El EXML delta de cada uno debe contener SOLO MinGroupSize y
  MaxGroupSize. Si aparece algo mas, parar.
--]]

-- Vanilla: 1 / 1. El juego elige un numero al azar en este rango.
PACK_MIN = "3"
PACK_MAX = "5"

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HorribleTerror_PredatorPacks",
["MOD_AUTHOR"]      = "ArDev-ACG",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "Los depredadores que cazan al jugador aparecen en manadas de "..PACK_MIN.." a "..PACK_MAX.." en vez de solos.",
["MODIFICATIONS"]   =
  {
    {
      ["MBIN_CHANGE_TABLE"] =
      {
        {
          ["MBIN_FILE_SOURCE"] =
          {
            "METADATA\SIMULATION\ECOSYSTEM\GROUND\GROUNDTABLEPLAYERPREDATORMED.MBIN",
            "METADATA\SIMULATION\ECOSYSTEM\GROUND\GROUNDTABLEPLAYERPREDATORLARGE.MBIN",
          },
          ["MXML_CHANGE_TABLE"] =
          {
            {
              ["COMMENT"]            = "Tamano de manada 1/1 -> "..PACK_MIN.."/"..PACK_MAX,
              ["VALUE_CHANGE_TABLE"] =
              {
                {"MinGroupSize", PACK_MIN},
                {"MaxGroupSize", PACK_MAX},
              }
            },
          }
        },
      }
    },
  },
}
