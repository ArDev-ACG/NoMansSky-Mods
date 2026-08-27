BUG_R = "0.120000"
BUG_G = "1.000000"
BUG_B = "0.150000"

MINI_R = "0.150000"
MINI_G = "0.350000"
MINI_B = "1.000000"

FF_R = "1.000000"
FF_G = "0.150000"
FF_B = "0.120000"

BUGFIEND_MATS =
{
  "MODELS\PLANETS\CREATURES\ARTHROPOD\BUGFIEND\ARTHROPODABDOMENFIEND.MATERIAL.MBIN",
  "MODELS\PLANETS\CREATURES\ARTHROPOD\BUGFIEND\ARTHROPODANTENNASMAT2.MATERIAL.MBIN",
  "MODELS\PLANETS\CREATURES\ARTHROPOD\BUGFIEND\ARTHROPODFANGSMAT.MATERIAL.MBIN",
  "MODELS\PLANETS\CREATURES\ARTHROPOD\BUGFIEND\ARTHROPODHEAD01MAT2.MATERIAL.MBIN",
  "MODELS\PLANETS\CREATURES\ARTHROPOD\BUGFIEND\ARTHROPODHEAD05LOWERMAT1.MATERIAL.MBIN",
  "MODELS\PLANETS\CREATURES\ARTHROPOD\BUGFIEND\ARTHROPODLEGS01MAT1.MATERIAL.MBIN",
  "MODELS\PLANETS\CREATURES\ARTHROPOD\BUGFIEND\ARTHROPODSHELL01MAT1.MATERIAL.MBIN",
  "MODELS\PLANETS\CREATURES\ARTHROPOD\BUGFIEND\ARTHROPODTHORAX01MAT.MATERIAL.MBIN",
  "MODELS\PLANETS\CREATURES\ARTHROPOD\BUGFIEND\LAMBERT1.MATERIAL.MBIN",
}

MINIFIEND_MATS =
{
  "MODELS\PLANETS\CREATURES\SPIDERRIG\MINIFIEND_PET\FFIENDMAT.MATERIAL.MBIN",
  "MODELS\PLANETS\CREATURES\SPIDERRIG\MINIFIEND_PET\FFIENDEYEMAT.MATERIAL.MBIN",
  "MODELS\PLANETS\CREATURES\SPIDERRIG\MINIFIEND_PET\LAMBERT1.MATERIAL.MBIN",
}

FREIGHTERFIEND_MATS =
{
  "MODELS\PLANETS\CREATURES\SPIDERRIG\FREIGHTERFIEND\FFIENDMAT.MATERIAL.MBIN",
  "MODELS\PLANETS\CREATURES\SPIDERRIG\FREIGHTERFIEND\LAMBERT1.MATERIAL.MBIN",
}

FREIGHTERFIEND_EYE_MATS =
{
  "MODELS\PLANETS\CREATURES\SPIDERRIG\FREIGHTERFIEND\FFIENDEYEMAT.MATERIAL.MBIN",
}

MINIFIEND_SCENE      = "MODELS\PLANETS\CREATURES\SPIDERRIG\MINIFIEND_PET.SCENE.MBIN"
FREIGHTERFIEND_SCENE = "MODELS\PLANETS\CREATURES\SPIDERRIG\FREIGHTERFIEND.SCENE.MBIN"

function Tinte(rutas, etiqueta, r, g, b)
  local bloques = {}
  for i = 1, #rutas do
    bloques[i] =
    {
      ["MBIN_FILE_SOURCE"] = rutas[i],
      ["MXML_CHANGE_TABLE"] =
      {
        {
          ["COMMENT"]            = etiqueta,
          ["SPECIAL_KEY_WORDS"]  = {"Name", "gMaterialColourVec4"},
          ["REPLACE_TYPE"]       = "ONCE",
          ["VALUE_CHANGE_TABLE"] =
          {
            {"X", r},
            {"Y", g},
            {"Z", b},
          }
        },
      }
    }
  end
  return bloques
end

function LuzAtaque(escena, etiqueta, r, g, b)
  local canales = {{"COL_R", r}, {"COL_G", g}, {"COL_B", b}}
  local subtablas = {}
  for i = 1, #canales do
    subtablas[i] =
    {
      ["COMMENT"]            = etiqueta .. " " .. canales[i][1],
      ["SPECIAL_KEY_WORDS"]  = {"Name", "AttackLight", "Name", canales[i][1]},
      ["REPLACE_TYPE"]       = "ONCE",
      ["VALUE_CHANGE_TABLE"] =
      {
        {"Value", canales[i][2]},
      }
    }
  end
  return
  {
    {
      ["MBIN_FILE_SOURCE"]  = escena,
      ["MXML_CHANGE_TABLE"] = subtablas,
    },
  }
end

TABLA = {}

function Anadir(bloques)
  for i = 1, #bloques do TABLA[#TABLA + 1] = bloques[i] end
end

Anadir(Tinte(BUGFIEND_MATS,           "BUGFIEND -> verde",                   BUG_R,  BUG_G,  BUG_B))
Anadir(Tinte(MINIFIEND_MATS,          "MINIFIEND -> azul",                   MINI_R, MINI_G, MINI_B))
Anadir(Tinte(FREIGHTERFIEND_MATS,     "FREIGHTERFIEND cuerpo -> rojo carne", FF_R,   FF_G,   FF_B))
Anadir(Tinte(FREIGHTERFIEND_EYE_MATS, "FREIGHTERFIEND ojo -> rojo carne",    FF_R,   FF_G,   FF_B))

Anadir(LuzAtaque(MINIFIEND_SCENE,      "MINIFIEND AttackLight -> azul",      MINI_R, MINI_G, MINI_B))
Anadir(LuzAtaque(FREIGHTERFIEND_SCENE, "FREIGHTERFIEND AttackLight -> rojo", FF_R,   FF_G,   FF_B))

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_FiendMarkers_PRUEBA04",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.4.0] Marca por la luz, no por la piel. Cada Horror lleva un nodo LIGHT propio llamado AttackLight, amarillo en vanilla e identico en los dos bichos del carguero: es lo unico que se ve de ellos en penumbra. Pasa a azul en el MiniFiend y a rojo carne en el Horror de carguero, y se mantiene el tinte de piel de la PRUEBA02.",
["MODIFICATIONS"]   =
  {
    {
      ["MBIN_CHANGE_TABLE"] = TABLA
    },
  },
}
