BUG_R = "0.120000"
BUG_G = "1.000000"
BUG_B = "0.150000"

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

SCUTTLER_MATS =
{
  "MODELS\PLANETS\CREATURES\SPIDERRIG\FREIGHTERFIEND\FFIENDMAT.MATERIAL.MBIN",
  "MODELS\PLANETS\CREATURES\SPIDERRIG\FREIGHTERFIEND\LAMBERT1.MATERIAL.MBIN",
}

SCUTTLER_EYE_MAT = "MODELS\PLANETS\CREATURES\SPIDERRIG\FREIGHTERFIEND\FFIENDEYEMAT.MATERIAL.MBIN"

SCUTTLER_SCENE = "MODELS\PLANETS\CREATURES\SPIDERRIG\FREIGHTERFIEND.SCENE.MBIN"

FLAG_UNLIT =
  '\t\t<Property name="Flags" value="TkMaterialFlags">\n'..
  '\t\t\t<Property name="MaterialFlag" value="_F07_UNLIT" />\n'..
  '\t\t</Property>\n'

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

function OjoPintado(ruta, etiqueta, r, g, b)
  return
  {
    {
      ["MBIN_FILE_SOURCE"]  = ruta,
      ["MXML_CHANGE_TABLE"] =
      {
        {
          ["COMMENT"]            = etiqueta .. " tinte",
          ["SPECIAL_KEY_WORDS"]  = {"Name", "gMaterialColourVec4"},
          ["REPLACE_TYPE"]       = "ONCE",
          ["VALUE_CHANGE_TABLE"] =
          {
            {"X", r},
            {"Y", g},
            {"Z", b},
          }
        },
        {
          ["COMMENT"]            = etiqueta .. " _F07_UNLIT",
          ["SPECIAL_KEY_WORDS"]  = {"MaterialFlag", "_F25_MASKS_MAP"},
          ["ADD_OPTION"]         = "ADDafterSECTION",
          ["VALUE_CHANGE_TABLE"] = {{"IGNORE", "IGNORE"}},
          ["ADD"]                = FLAG_UNLIT
        },
      }
    },
  }
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

Anadir(Tinte(BUGFIEND_MATS, "BUGFIEND -> verde acido", BUG_R, BUG_G, BUG_B))
Anadir(Tinte(SCUTTLER_MATS, "SCUTTLER cuerpo -> rojo carne", FF_R, FF_G, FF_B))
Anadir(OjoPintado(SCUTTLER_EYE_MAT, "SCUTTLER emisivo -> rojo carne", FF_R, FF_G, FF_B))
Anadir(LuzAtaque(SCUTTLER_SCENE, "SCUTTLER AttackLight -> rojo carne", FF_R, FF_G, FF_B))

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_FiendMarkers_PRUEBA05",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.5.0] Corrige la identidad de los bichos y ataca la parte que si se ve. CREATUREFILENAMETABLE dice que FREIGHTERFIEND.SCENE es la criatura SCUTTLER, la del nido del carguero, y que MINIFIEND_PET.SCENE es SCUTTLER_PET, la mascota domesticada: por eso el azul nunca se vio, se pintaba un bicho que no aparece. Aqui se deja de escribir MINIFIEND_PET y se anade _F07_UNLIT al FFIENDEYEMAT del SCUTTLER, para que el uniform pinte el emisivo en vez de multiplicarlo y la boca deje de salir amarilla en penumbra.",
["MODIFICATIONS"]   =
  {
    {
      ["MBIN_CHANGE_TABLE"] = TABLA
    },
  },
}
