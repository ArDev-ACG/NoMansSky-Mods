RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\models\scuttlermesh_anim]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\textures]]

DESTINO_MALLA    = [[MODELS\PLANETS\CREATURES\SPIDERRIG]]
DESTINO_MATERIAL = [[MODELS\PLANETS\CREATURES\SPIDERRIG\FREIGHTERFIEND]]
DESTINO_TEXTURA  = [[TEXTURES\PLANETS\CREATURES\SPIDERRIG]]
DESTINO_PROC     = [[TEXTURES\COMMON\PLAYER\PLAYERCHARACTER]]

ENTREGA =
{
  {
    ["COMMENT"]              = "Etapa 4 - el nodo de malla con FIRSTSKINMAT 0 y LASTSKINMAT 14, y el AttackLight neutralizado entero",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FREIGHTERFIEND.SCENE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FREIGHTERFIEND.SCENE.MBIN]],
  },
  {
    ["COMMENT"]              = "Etapa 4 - VertexLayout a stride 20 con los canales 5 y 6, SkinMatrixLayout de 14 huesos y MeshBaseSkinMat [0]",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FREIGHTERFIEND.GEOMETRY.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FREIGHTERFIEND.GEOMETRY.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "Etapa 4 - el buffer de 90856 a 227140 bytes: los 11357 vertices con su indice de hueso y su peso",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FREIGHTERFIEND.GEOMETRY.DATA.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FREIGHTERFIEND.GEOMETRY.DATA.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "Etapa 4 - FFIENDMAT CON _F02_SKINNED, mas el color y las mascaras propias",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FFIENDMAT.MATERIAL.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MATERIAL .. [[\FFIENDMAT.MATERIAL.MBIN]],
  },
  {
    ["COMMENT"]              = "Etapa 3b - color base propio, BC7 2048 con 12 mips",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\SKRULLCRAWLER.BASE.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\SKRULLCRAWLER.BASE.DDS]],
  },
  {
    ["COMMENT"]              = "Etapa 3f - mascaras propias, ATI1 de un canal desde el roughness del asset",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\SKRULLCRAWLER.BASE.MASKS.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\SKRULLCRAWLER.BASE.MASKS.DDS]],
  },
  {
    ["COMMENT"]              = "Etapa 3c - lista procedural sin capas: que no componga y mande el gDiffuseMap",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FREIGHTERFIEND.TEXTURE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_PROC .. [[\FREIGHTERFIEND.TEXTURE.MBIN]],
  },
}

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_ScuttlerMesh_PRUEBA12",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.12.0] Etapa 4: que el SkrullCrawler deje de ir rigido. Hasta ahora la malla no estaba pegada a ningun hueso: el esqueleto SPIDERRIG se movia debajo y el bicho se deslizaba entero. No se anima nada, porque el esqueleto y sus animaciones ya son del juego; lo que faltaba era pesar nuestra malla contra sus huesos. Cada vertice ocupaba 8 bytes -normal y tangente- y no habia sitio para decir de que hueso cuelga y cuanto; ahora ocupa 20, con el indice de hueso en el canal 5 (UNSIGNED_BYTE x4, offset 8) y el peso en el 6 (HALF_FLOAT x4, offset 12), que es el contrato exacto del bicho vanilla. El buffer pasa de 90856 a 227140 bytes para los 11357 vertices exportados. Los pesos salen de transferir los del FreighterFiend vanilla a nuestra malla en Blender: 4820 de 4820 vertices con peso, 4895 asignaciones -1.02 huesos por vertice, contra 1.05 del vanilla, o sea igual de rigido que el original- y maximo 2 influencias, que caben de sobra en los 4 huecos. De los 113 huesos del esqueleto solo 14 reciben peso: la cabeza y las ocho patas. La espalda no doblara y el cuerpo se movera en bloque con RootJNT, y las pinzas no aplican porque nuestro bicho no tiene. El detalle que decide si el juego cierra o no es que el byte del canal 5 NO es el numero de hueso sino la posicion dentro de SkinMatrixLayout entre FIRSTSKINMAT y LASTSKINMAT: con una paleta de 14 los valores van de 0 a 13, y meter ahi el JOINTINDEX es lo que cerro el juego en la PRUEBA05. Se comprobo con tools/Check-NMSGraft.py antes de construir, que ahora mira el binario y no solo el XML, y que rompiendolo a proposito caza las tres maneras de fallar. Y el ultimo paso es devolver _F02_SKINNED a FFIENDMAT, que es lo que hace que el juego aplique el esqueleto. Del resto no cambia nada respecto a la PRUEBA11: normal y tangente salen iguales byte a byte, y los indices y las posiciones intactos. Queda pendiente el gNormalMap, que sigue siendo el vanilla y esta pintado para las UV del SCUTTLER original. Sustituye a las PRUEBA01 a 11 y choca con HT_FiendMarkers_PRUEBA04 y con HorribleTerror_NecroSkin.",
["ADD_FILES"]       = ENTREGA,
}
