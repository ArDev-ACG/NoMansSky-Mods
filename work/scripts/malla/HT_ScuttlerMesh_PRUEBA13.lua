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
    ["COMMENT"]              = "Etapa 4 - FFIENDMAT CON _F02_SKINNED y con el gNormalMap apuntando ya al normal propio",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FFIENDMAT.MATERIAL.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MATERIAL .. [[\FFIENDMAT.MATERIAL.MBIN]],
  },
  {
    ["COMMENT"]              = "Etapa 3b - color base propio, BC7 2048 con 12 mips",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\SKRULLCRAWLER.BASE.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\SKRULLCRAWLER.BASE.DDS]],
  },
  {
    ["COMMENT"]              = "M-BABA - las mismas mascaras con el canal invertido, y el fondo de UV sin usar retenido a 0",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\SKRULLCRAWLER.BASE.MASKS.INV.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\SKRULLCRAWLER.BASE.MASKS.DDS]],
  },
  {
    ["COMMENT"]              = "M-TEX - normal propio, ATI2 2048 con 12 mips, fabricado desde la luminancia del color del asset",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\SKRULLCRAWLER.BASE.NORMAL.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\SKRULLCRAWLER.BASE.NORMAL.DDS]],
  },
  {
    ["COMMENT"]              = "Etapa 3c - lista procedural sin capas: que no componga y mande el gDiffuseMap",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FREIGHTERFIEND.TEXTURE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_PROC .. [[\FREIGHTERFIEND.TEXTURE.MBIN]],
  },
}

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_ScuttlerMesh_PRUEBA13",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.13.0] M-BABA: que el SkrullCrawler deje de verse de baba. ES LA PRUEBA12 CON UN SOLO ARCHIVO CAMBIADO, el gMasksMap; los otros siete van byte a byte iguales, asi que lo que se mide es una cosa y no dos. El sospechoso estaba medido desde el 20/08 y se ha vuelto a medir antes de tocar nada: nuestro SKRULLCRAWLER.BASE.MASKS.DDS es un ATI1 de un canal con media 173.6 y el del FIEND vanilla -mismo formato, misma familia de bicho- da 85.4. El doble de brillo en el unico canal que hay. Y la causa no es que el mapa este mal pintado sino que viene AL REVES: el asset de Meshy entrega ROUGHNESS, donde el valor alto significa aspero y por tanto mate, y el shader lee ese canal como brillo, donde el valor alto significa mojado. Con un mapa casi todo alto -util media 199.5- el bicho salia entero de baba, que es exactamente lo que se vio en partida. La prueba que lo ata: 255 menos 173.6 da 81, y el vanilla mide 85. El arreglo es dar la vuelta al canal, y no bajarle el brillo: bajarlo dejaria las grietas brillantes y los bultos mates, o sea el mismo mapa del reves pero mas flojo. UNA COSA MAS QUE NO HACE EL --invertir DEL CONVERSOR, y por eso el PNG se prepara aparte: el 13.3% de la textura es UV sin usar y esta a 0, e invertirla la pondria a 255, o sea brillo maximo pegado al borde de cada isla, que a partir del cuarto mip sangra dentro. Se comprobo que ese 13.3% es hueco de verdad y no superficie del bicho: donde la rugosidad vale 0 el color base tambien es negro -RGB 2.8/1.8/1.7 con desviacion 15, contra 106.7/68.3/65.3 en la parte util-. Asi que se invierte solo lo util y el fondo se queda a 0, que es mate y es lo que hace el vanilla. Sale util media 54.0, p1 17 y p99 105, contra los 199.5 / 69 / 236 de la PRUEBA12; el vanilla mide 86.9 / 5 / 156. LA FIRMA, ESCRITA ANTES DE ENTRAR: si el bicho sale de hueso y piel seca, M-BABA esta cerrado. Si sale CALIZO, plano y sin ningun reflejo, la inversion se paso de mate y el arreglo es mezclar, no volver a diagnosticar. Si sigue viendose mojado igual que antes, entonces el canal no era el brillo y hay que ir al material, no a la textura. LO QUE ESTA PRUEBA NO TOCA Y SIGUE PENDIENTE: la nuca con la textura estirada, que es M-NUCA y es UV. Y NO ES EL PRESUPUESTO DE TRIANGULOS: medido el 22/08, el FBX del SkrullCrawler trae 9592 triangulos y la malla del juego trae los mismos 9592. Este bicho NUNCA se decimo, asi que el colapso de UV que puso a confeti al necromorfo y al zombie no le aplica y subirlo a 30000 no es posible ni haria nada. Sustituye a las PRUEBA01 a 12 y choca con HT_FiendMarkers_PRUEBA04 y con HorribleTerror_NecroSkin.",
["ADD_FILES"]       = ENTREGA,
}
