RAIZ = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\models\markermesh]]

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
    ["COMMENT"]              = "Etapa 2 - malla propia: el marker-1 en el sitio del huevo",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ .. [[\]] .. ARCHIVOS[i],
    ["FILE_DESTINATION"]     = DESTINO .. [[\]] .. ARCHIVOS[i],
  }
end

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_EggMesh_PRUEBA02",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.2.0] Etapa 2 de la via Blender. Sustituye la geometria del huevo de Fiend por el modelo marker-1 (822 vertices, 1636 triangulos), importado en FBX y exportado con NMSDK 0.10.0-alpha13 sobre la escena vanilla. Conserva del huevo las tres cosas que no son geometria: el material EGGSHELL_MAT, la entidad FIENDEGG.ENTITY (que es donde vive el comportamiento: FIENDHATCH, IncreaseFiendWanted, Health 125) y la esfera de colision de radio 0.395. Mide si el conducto acepta geometria nuestra y no solo la ida y vuelta de la vanilla. Sustituye a HT_EggMesh_PRUEBA01: los dos escriben los mismos tres archivos y no pueden estar puestos a la vez.",
["ADD_FILES"]       = ENTREGA,
}
