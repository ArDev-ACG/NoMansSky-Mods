--[[
  HORRIBLE TERROR - Fase 1: prueba de pipeline
  ------------------------------------------------------------------
  Objetivo de este script: NO es contenido final del mod. Es el cambio
  minimo y verificable que demuestra que la cadena completa funciona:

      .lua -> AMUMSS -> MBINCompiler -> .pak -> GAMEDATA\MODS -> juego

  Multiplica la densidad de fauna TERRESTRE por km. Se eligio este
  parametro porque el efecto es imposible de no ver: al aterrizar en
  un planeta con vida deberia haber notoriamente mas bichos.

  Valores vanilla de GroundGroupsPerKm (verificados en 6.45.0.1):
      Sparse    25
      Normal    50
      Dense    100
      VeryDense 200

  Con DENSITY_MULT = 20 quedan en 500 / 1000 / 2000 / 4000.

  AVISO: 20 es un valor de PRUEBA, deliberadamente exagerado. El objetivo
  es que sea imposible confundirlo con la variacion normal del juego. NO es
  el valor de release: a x20 el rendimiento puede caer bastante en planetas
  con vida Full. Para el mod final la idea es bajarlo a algo entre 2 y 4.

  IMPORTANTE - por que PRECEDING_KEY_WORDS es obligatorio aqui:
  las claves Sparse/Normal/Dense/VeryDense se repiten identicas en
  WaterGroupsPerKm, AirGroupsPerKm, CaveGroupsPerKm y DensityModifiers.
  Sin acotar por "GroundGroupsPerKm" el cambio se aplicaria a todas y
  el resultado seria incontrolable.

  Archivo objetivo: METADATA\SIMULATION\ECOSYSTEM\CREATUREGENERATIONDATA.MBIN
  Vive en NMSARC.Precache.pak
--]]

DENSITY_MULT = 20

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HorribleTerror_GroundDensity",
["MOD_AUTHOR"]      = "ArDev-ACG",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "Fase 1 - multiplica x"..DENSITY_MULT.." la densidad de fauna terrestre. Prueba de pipeline.",
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
              ["PRECEDING_KEY_WORDS"] =
              {
                {"GroundGroupsPerKm"},
              },
              ["VALUE_CHANGE_TABLE"] =
              {
                {"Sparse",    "@*"..DENSITY_MULT},
                {"Normal",    "@*"..DENSITY_MULT},
                {"Dense",     "@*"..DENSITY_MULT},
                {"VeryDense", "@*"..DENSITY_MULT},
              }
            },
          }
        },
      }
    },
  },
}
