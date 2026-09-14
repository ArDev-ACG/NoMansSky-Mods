RAIZ = os.getenv("USERPROFILE") .. [[\MODS\NMS_MOD_ZOMBIES\work\models\eggmesh]]

DESTINO = [[MODELS\PLANETS\BIOMES\COMMON\RARERESOURCE\GROUND]]

ARCHIVOS =
{
  "FIENDEGG.SCENE.MBIN",
  "FIENDEGG.GEOMETRY.MBIN.PC",
  "FIENDEGG.GEOMETRY.DATA.MBIN.PC",
}

ENTREGA = {}

for i = 1, #ARCHIVOS do
  ENTREGA[i] =
  {
    ["COMMENT"]              = "Etapa 1 - ida y vuelta por NMSDK, sin tocar la geometria",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ .. [[\]] .. ARCHIVOS[i],
    ["FILE_DESTINATION"]     = DESTINO .. [[\]] .. ARCHIVOS[i],
  }
end

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_EggMesh_PRUEBA01",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.1.0] Etapa 1 de la via Blender. El huevo de Fiend vanilla se importo a Blender con NMSDK 0.10.0-alpha13, se volvio a exportar sin tocar un solo vertice, y se le devolvieron las dos rutas internas que el exportador prefija con CUSTOMMODELS/MODELGROUP. Mide dos cosas de una: si el formato que produce NMSDK carga en NMS 6.45, y si la ida y vuelta conserva la malla. No cambia nada del juego a proposito: si el huevo sale igual que siempre, la prueba ha pasado.",
["ADD_FILES"]       = ENTREGA,
}
