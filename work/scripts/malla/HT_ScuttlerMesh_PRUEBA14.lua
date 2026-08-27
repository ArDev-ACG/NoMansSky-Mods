RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\models\scuttlermesh_anim]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\textures]]

DESTINO_MALLA    = [[MODELS\PLANETS\CREATURES\SPIDERRIG]]
DESTINO_MATERIAL = [[MODELS\PLANETS\CREATURES\SPIDERRIG\FREIGHTERFIEND]]
DESTINO_TEXTURA  = [[TEXTURES\PLANETS\CREATURES\SPIDERRIG]]
DESTINO_PROC     = [[TEXTURES\COMMON\PLAYER\PLAYERCHARACTER]]

ENTREGA =
{
  {
    ["COMMENT"]              = "M-UVIDX - el nodo de malla reinjertado sobre el .SCENE vanilla, con FIRSTSKINMAT 0 y LASTSKINMAT 42",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FREIGHTERFIEND.SCENE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FREIGHTERFIEND.SCENE.MBIN]],
  },
  {
    ["COMMENT"]              = "M-UVIDX - VertexLayout a stride 20 con los canales 5 y 6, SkinMatrixLayout de 42 huesos y los cuatro arrays por hueso del vanilla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FREIGHTERFIEND.GEOMETRY.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FREIGHTERFIEND.GEOMETRY.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "M-UVIDX - el buffer con el index arreglado: 7627 vertices, todos apuntados, y las UV en su isla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FREIGHTERFIEND.GEOMETRY.DATA.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FREIGHTERFIEND.GEOMETRY.DATA.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA13, byte a byte - FFIENDMAT con _F02_SKINNED y el gNormalMap al normal propio",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FFIENDMAT.MATERIAL.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MATERIAL .. [[\FFIENDMAT.MATERIAL.MBIN]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA13, byte a byte - color base propio, BC7 2048 con 12 mips",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\SKRULLCRAWLER.BASE.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\SKRULLCRAWLER.BASE.DDS]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA13, byte a byte - las mascaras invertidas, con el fondo de UV retenido a 0",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\SKRULLCRAWLER.BASE.MASKS.INV.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\SKRULLCRAWLER.BASE.MASKS.DDS]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA13, byte a byte - normal propio, ATI2 2048 con 12 mips",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\SKRULLCRAWLER.BASE.NORMAL.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\SKRULLCRAWLER.BASE.NORMAL.DDS]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA13, byte a byte - lista procedural sin capas, que mande el gDiffuseMap",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FREIGHTERFIEND.TEXTURE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_PROC .. [[\FREIGHTERFIEND.TEXTURE.MBIN]],
  },
}

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_ScuttlerMesh_PRUEBA14",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.14.0] M-UVIDX: la textura no estaba mal, estaba puesta en el vertice equivocado. LAS CINCO TEXTURAS Y EL MATERIAL VAN BYTE A BYTE COMO EN LA PRUEBA13; lo unico que cambia son los tres archivos de geometria, asi que lo que se mide es la malla y no la piel. LA CAUSA, LEIDA EN EL CODIGO DE NMSDK Y MEDIDA EN EL ARCHIVO DESPLEGADO: mesh_parser parte bien los vertices de costura -4820 pasan a 11357, uno por cada combinacion de vertice y UV- y devuelve DOS listas de indices, `indexes` ya remapeada a los vertices partidos y `np_indexes` que es data.loops.foreach_get('vertex_index'), o sea la de ANTES de partir. Y export.py serializa la segunda. Medido sobre el .GEOMETRY.DATA que esta en el juego: 11357 vertices en el buffer, indice maximo usado 4819, o sea 6537 VERTICES QUE NO APUNTA NADIE. Cada vertice de costura se queda con la PRIMERA UV que le tocara, y en el atlas de Meshy -cientos de islas diminutas, el 12,34% de la textura es hueco negro- esa primera UV es de otra isla cualquiera. LOS NUMEROS QUE LO ATAN: el 30,89% de las aristas de la malla desplegada cruzaban mas del 10% del atlas, con un maximo de 1,2574 sobre 1; el FBX original de Meshy no pasa de 0,0582 y no tiene NI UNA por encima de 0,10. Y la correlacion entre lo que mide una arista en 3D y lo que mide en UV, que en una malla sana es fuerte, daba 0,044: cero. La malla en 3D salia PERFECTA -aristas de 6 cm de mediana, ninguna larga- porque los indices 0..4819 si apuntan a las posiciones buenas, y por eso el bicho se veia bien plantado y solo la piel salia a remolinos. Eso explica las tres capturas de la PRUEBA13: los dibujos de estrella con anillos en el craneo son bordes de isla de UV, no relieve. AHORA: 7627 vertices y los 7627 apuntados, arista UV maxima 0,0583 -la del FBX es 0,0582-, ninguna por encima de 0,10, correlacion 0,804. DE PASO, LAS NORMALES: NMSDK escribia poly.normal, la normal de CARA de la primera cara que tocaba el vertice, ignorando las que Blender ya tiene. Error mediano de 21,6 grados y un 2,7% de vertices apuntando al reves; ahora se usan las de Blender y quedan en 8,1 grados y 0,52%. Se parchea desde tools/Export-NMSMesh.py y no se toca el addon, que vive en AppData y se pierde al reinstalarlo. LO SEGUNDO QUE CAMBIA, Y HAY QUE SABERLO PARA LEER EL RESULTADO: al rehacer el export con el guion, la malla se asienta con los pies en Y 0 en vez de en -0,020806, que son 2,08 cm, siete veces la tolerancia con la que Skin-NMSGeometry casa los pesos. Asi que pesos.json se ha rehecho contra el .blend nuevo y con el pesado por hueso mas cercano de d3bfd2d, y la paleta pasa de 14 huesos a 42. Check-NMSGraft da salida 0: 114 nodos JOINT, stride 20 con los canales 2,3,5,6 y todos los indices del .SCENE dentro del .GEOMETRY. LA FIRMA, ESCRITA ANTES DE ENTRAR: si la piel sale continua y sin dibujos de estrella, M-UVIDX esta cerrado y con el M-NUCA, que nunca fue UV ni presupuesto de triangulos sino esto mismo. Si la piel sale bien pero el bicho se deforma raro al andar o al morir, entonces lo que fallo es la paleta nueva de 42 huesos, no el index, y se vuelve al pesado. Si sigue viendose a remolinos igual que antes, el mod no se ha desplegado: comprobar la fecha del .MBIN en GAMEDATA\MODS antes de volver a diagnosticar nada. QUEDA MEDIDO Y NO ENTRA AQUI: el borde de cada isla se come algo de negro al hacer los mips -en el mip 1 el 3,5% de la textura es borde util y ahi el negro roba 2,2 niveles de media y 38 en el peor 1%-. Es un halo fino, no lo que se veia, y el arreglo ya esta hecho en tools/Make-NMSTexture.py --rellenar por si al verlo de cerca molesta. Sustituye a las PRUEBA01 a 13 y choca con HT_FiendMarkers_PRUEBA04 y con HorribleTerror_NecroSkin.",
["ADD_FILES"]       = ENTREGA,
}
