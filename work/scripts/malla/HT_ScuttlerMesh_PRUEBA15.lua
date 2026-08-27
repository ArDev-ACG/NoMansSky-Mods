RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\models\scuttlermesh_anim]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\textures]]

DESTINO_MALLA    = [[MODELS\PLANETS\CREATURES\SPIDERRIG]]
DESTINO_MATERIAL = [[MODELS\PLANETS\CREATURES\SPIDERRIG\FREIGHTERFIEND]]
DESTINO_TEXTURA  = [[TEXTURES\PLANETS\CREATURES\SPIDERRIG]]
DESTINO_PROC     = [[TEXTURES\COMMON\PLAYER\PLAYERCHARACTER]]

ENTREGA =
{
  {
    ["COMMENT"]              = "Igual que la PRUEBA14, byte a byte - el nodo de malla reinjertado sobre el .SCENE vanilla, con FIRSTSKINMAT 0 y LASTSKINMAT 42",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FREIGHTERFIEND.SCENE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FREIGHTERFIEND.SCENE.MBIN]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA14, byte a byte - VertexLayout a stride 20 con los canales 5 y 6, SkinMatrixLayout de 42 huesos y los cuatro arrays por hueso del vanilla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FREIGHTERFIEND.GEOMETRY.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FREIGHTERFIEND.GEOMETRY.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA14, byte a byte - el buffer con el index arreglado: 7627 vertices, todos apuntados, y las UV en su isla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FREIGHTERFIEND.GEOMETRY.DATA.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FREIGHTERFIEND.GEOMETRY.DATA.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA14, byte a byte - FFIENDMAT con _F02_SKINNED y el gNormalMap al normal propio",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FFIENDMAT.MATERIAL.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MATERIAL .. [[\FFIENDMAT.MATERIAL.MBIN]],
  },
  {
    ["COMMENT"]              = "M-ESTRELLA - el mismo color base con el hueco de UV derramado desde la isla vecina, para que el negro no sangre por los mips",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\SKRULLCRAWLER.BASE.RELLENA.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\SKRULLCRAWLER.BASE.DDS]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA14, byte a byte - las mascaras invertidas, con el fondo de UV retenido a 0",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\SKRULLCRAWLER.BASE.MASKS.INV.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\SKRULLCRAWLER.BASE.MASKS.DDS]],
  },
  {
    ["COMMENT"]              = "M-ESTRELLA - el normal con el relieve apagado en los 4 primeros pixeles de cada isla: ahi la arruga era del corte del atlas, no del bicho",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\SKRULLCRAWLER.BASE.NORMAL.SC.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\SKRULLCRAWLER.BASE.NORMAL.DDS]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA14, byte a byte - lista procedural sin capas, que mande el gDiffuseMap",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FREIGHTERFIEND.TEXTURE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_PROC .. [[\FREIGHTERFIEND.TEXTURE.MBIN]],
  },
}

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_ScuttlerMesh_PRUEBA15",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.15.0] M-ESTRELLA: la nuca. La PRUEBA14 arreglo el index y la textura dejo de ir a remolinos, pero en la nuca seguian dibujandose estrellas. NO ERA LA UV NI EL INDEX: ERA EL NORMAL, Y LA ESTRELLA ES EL CONTORNO DE LAS ISLAS DEL ATLAS. La altura del normal sale de la LUMINANCIA del color, y el hueco de UV del asset de Meshy es NEGRO PURO -el 12,34% de la textura-, asi que en el borde de cada isla la pendiente se dispara y Make-NMSNormal grababa una arruga siguiendo el corte del atlas. Medido decodificando el ATI2 QUE ESTABA EN PARTIDA: inclinacion 0.4905 en el borde de isla contra 0.0850 en el interior, una mentira de x5,8 pintada exactamente por donde Meshy corto. Y se reprodujo la receta para estar seguros: con fuerza 10 sobre el PNG crudo salen 0.4891 y 0.0829, que son esos mismos numeros. EL ARREGLO SON DOS COSAS Y LAS DOS ENTRAN AQUI, las dos contra el mismo fondo negro. UNA, el color base va con el hueco DERRAMADO desde la isla mas cercana -tools/Make-NMSTexture.py --rellenar-: NMS hace 12 mips hasta 1x1 y cada reduccion promediaba el borde con el negro; en el mip 1 el 3,5% de la textura es borde util y ahi el negro robaba 2,2 niveles de media y 38 en el peor 1%. DOS, el normal se genera sobre ese mismo relleno y ademas se APAGA el relieve en los 4 primeros pixeles de cada isla -tools/Make-NMSNormal.py --sin-costuras 4-: ahi la arruga es del corte y no del bicho, y llevando las dos orillas de una costura a plano las dos coinciden y la costura deja de verse. Resultado medido: el borde baja de 0.4905 a 0.1529 y el interior se queda en 0.0870 contra 0.0850, o sea que se quita la costura y NO se toca el relieve bueno. Se aplana el 15,9% de la textura, que es borde de isla y hueco. LOS TRES ARCHIVOS DE GEOMETRIA VAN BYTE A BYTE LOS DE LA PRUEBA14, y tambien el material y el gMasksMap, que ese ya esta cerrado -M-BABA medido y correcto el 24/08, el bicho ya no se ve de baba-. Solo cambian dos DDS. LA FIRMA, ESCRITA ANTES DE ENTRAR: si la nuca sale lisa y el resto igual de bien que en la PRUEBA14, M-ESTRELLA esta cerrado. Si la nuca mejora pero se queda una linea suave por donde iban las estrellas, es que 4 pixeles se quedan cortos y se sube --sin-costuras a 8; no hay que rediagnosticar nada. Si el bicho pierde relieve y sale liso de mas, --sin-costuras se paso y se baja a 2. Si la nuca sigue igual con las mismas estrellas duras, entonces no era el normal y hay que mirar el gMasksMap, que es el unico mapa que no se ha tocado. Sustituye a las PRUEBA01 a 14 y choca con HT_FiendMarkers_PRUEBA04 y con HorribleTerror_NecroSkin.",
["ADD_FILES"]       = ENTREGA,
}
