RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\models\facehuggereggmesh]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\textures]]

DESTINO_MALLA   = [[MODELS\PLANETS\BIOMES\COMMON\RARERESOURCE\GROUND]]
DESTINO_TEXTURA = [[TEXTURES\PLANETS\BIOMES\COMMON\RARERESOURCE\GROUND]]

MAT_BASE   = "TEXTURES/PLANETS/BIOMES/COMMON/RARERESOURCE/GROUND/FACEHUGGEREGG.BASE.DDS"
MAT_NORMAL = "TEXTURES/PLANETS/BIOMES/COMMON/RARERESOURCE/GROUND/FACEHUGGEREGG.BASE.NORMAL.DDS"

ARCHIVOS_MALLA =
{
  "FIENDEGG.SCENE.MBIN",
  "FIENDEGG.GEOMETRY.MBIN.PC",
  "FIENDEGG.GEOMETRY.DATA.MBIN.PC",
}

ARCHIVOS_TEXTURA =
{
  "FACEHUGGEREGG.BASE.DDS",
  "FACEHUGGEREGG.BASE.NORMAL.DDS",
}

ENTREGA = {}

for i = 1, #ARCHIVOS_MALLA do
  ENTREGA[#ENTREGA + 1] =
  {
    ["COMMENT"]              = "Malla propia injertada en el .SCENE vanilla de 7.0: el xenoEgg en el sitio del huevo",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\]] .. ARCHIVOS_MALLA[i],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\]] .. ARCHIVOS_MALLA[i],
  }
end

for i = 1, #ARCHIVOS_TEXTURA do
  ENTREGA[#ENTREGA + 1] =
  {
    ["COMMENT"]              = "Textura propia del huevo, generada con tools/Make-NMSTexture.py",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\]] .. ARCHIVOS_TEXTURA[i],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\]] .. ARCHIVOS_TEXTURA[i],
  }
end

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_FacehuggerEgg_PRUEBA01",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "7.00",
["MOD_DESCRIPTION"] = "[PRUEBA 0.1.0] Releva al marker en el FIENDEGG. Malla xenoEgg de 3064 triangulos y 1881 vertices, sin decimar, injertada en el .SCENE vanilla de 7.0 Cosmos, no en el de 6.45: el FIENDEGG.SCENE.MBIN cambio con Cosmos de 1711 a 1859 bytes y el .GEOMETRY.MBIN.PC de 5266 a 2129, asi que la base vieja ya no descompila. Escala uniforme 0.8267 para dejarlo en 0.7617 de alto, que es el AABB del nodo FiendEgg vanilla (0.708496 menos -0.053192). Ancho 1.1133 contra 0.6431 del vanilla: el huevo es 1.7 veces mas ancho a la misma altura y esto esta SIN COMPROBAR en partida, igual que el giro en Y, que se dejo en 0. La base se apoya en Y=0 y el vanilla se hunde 5 cm, asi que puede quedar flotando. Conserva el .SCENE vanilla entero: EGGSHELL_MAT, la FIENDEGG.ENTITY con FIENDHATCH y la colision. Sustituye a HT_EggMesh_PRUEBA05: los dos escriben los mismos archivos de malla y no pueden estar puestos a la vez.",
["ADD_FILES"]       = ENTREGA,
["MODIFICATIONS"]   =
  {
    {
      ["MBIN_CHANGE_TABLE"] =
      {
        {
          ["MBIN_FILE_SOURCE"] = "MODELS\PLANETS\BIOMES\COMMON\RARERESOURCE\GROUND\FIENDEGG\EGGSHELL_MAT.MATERIAL.MBIN",
          ["MXML_CHANGE_TABLE"] =
          {
            {
              ["COMMENT"]            = "gDiffuseMap: del atlas de la cueva a la textura del huevo",
              ["SPECIAL_KEY_WORDS"]  = {"Name", "gDiffuseMap"},
              ["REPLACE_TYPE"]       = "ONCE",
              ["VALUE_CHANGE_TABLE"] = { {"Map", MAT_BASE} }
            },
            {
              ["COMMENT"]            = "gNormalMap: normales del huevo, no las del atlas de la cueva",
              ["SPECIAL_KEY_WORDS"]  = {"Name", "gNormalMap"},
              ["REPLACE_TYPE"]       = "ONCE",
              ["VALUE_CHANGE_TABLE"] = { {"Map", MAT_NORMAL} }
            },
          }
        },
      }
    },
  },
}
