RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\models\fiendmesh_anim]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\textures]]

DESTINO_MALLA    = [[MODELS\PLANETS\CREATURES\SPIDERRIG]]
DESTINO_MATERIAL = [[MODELS\PLANETS\CREATURES\SPIDERRIG\FIEND]]
DESTINO_TEXTURA  = [[TEXTURES\PLANETS\CREATURES\SPIDERRIG]]

ENTREGA =
{
  {
    ["COMMENT"]              = "M3-PIEL - el .SCENE vanilla injertado, con FIRSTSKINMAT 0 y LASTSKINMAT 7",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.SCENE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.SCENE.MBIN]],
  },
  {
    ["COMMENT"]              = "M3-PIEL - VertexLayout a stride 20 con los canales 5 y 6, SkinMatrixLayout de 7 huesos y los cuatro arrays por hueso del vanilla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.GEOMETRY.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.GEOMETRY.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "M3-PIEL - el buffer con el MAPA A MANO, de 42742 vertices con indice de hueso y peso, 1718844 bytes",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.GEOMETRY.DATA.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.GEOMETRY.DATA.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "M3-PIEL - FIEND_MAT CON _F02_SKINNED, el ultimo paso de la receta",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND_MAT.MATERIAL.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MATERIAL .. [[\FIEND_MAT.MATERIAL.MBIN]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA02, byte a byte - el atlas de color del asset",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\NECROMORPH.BASE.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\FIEND.BASE.DDS]],
  },
  {
    ["COMMENT"]              = "M-TEX - normal rehecho a fuerza 9 y con --sin-costuras: desvio X 17.1 e Y 15.8, contra el 4.7 de la PRUEBA02 y el 17.2 del FIEND vanilla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\NECROMORPH.BASE.NORMAL.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\FIEND.BASE.NORMAL.DDS]],
  },
  {
    ["COMMENT"]              = "M-BABA - mascaras PROPIAS, planas a 87 con el 35.4% de hueco de UV retenido a 0. Antes caian las del vanilla, pintadas para otras UV",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\NECROMORPH.BASE.MASKS.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\FIEND.BASE.MASKS.DDS]],
  },
}

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_FiendMesh_PRUEBA04",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.4.0] M3-PIEL con MAPA A MANO. Es la PRUEBA03 con un solo archivo distinto de verdad -el buffer de pesos- y el resto igual: las tres texturas y el material van como en la PRUEBA03. LO QUE MEDIA LA PRUEBA03 Y NO HACIA FALTA ESPERAR: RootJNT se llevaba el 79,5% de la malla, o sea que el necromorfo se movia de BLOQUE. La causa esta medida, no supuesta, y sale de un volcado nuevo -tools/Weight-NMSMesh.py --volcar-huesos- que dice donde vive la piel de cada hueso vanilla DENTRO de nuestra caja: LA PIEL DEL FIEND CABE ENTERA EN LA MITAD DE ABAJO DE NUESTRA MALLA, de 0,05 a 0,37 sobre 3,62 m, y se sale por delante y por detras, z de 0,00 a 1,56 sobre 2,22 m. O sea que nuestros brazos y nuestra cabeza NO TIENEN NADA CERCA salvo cuerpo, y el vecino mas cercano no podia hacer otra cosa. No es un bug del pesado: es que copiar del vecino vale entre dos bichos del mismo tipo de animal y esto es un BIPEDO montado en una arana. EL ARREGLO: se dice a mano que region de nuestra malla cuelga de que hueso, y las fronteras duras las deshace el suavizado de 12 pasadas que ya estaba. El mapa, en fracciones de nuestra caja: cabeza por encima de 0,86 -> NewHeadJNT; por encima de 0,45 y a los lados -> L/RFirstLeg3JNT, que son las patas DELANTERAS; el resto por encima de 0,55 -> NewBack1JNT; por debajo de 0,40 -> L/RFourthLeg3JNT, las patas TRASERAS; y lo que quede -> RootJNT. Los L caen en x>0,5 y los R en x<0,5, leido del volcado. LO QUE SALE: 7 huesos con peso en vez de 1 dominante, y el mayor baja del 79,5% al 21,0%. LFourthLeg3JNT 21,0%, RFourthLeg3JNT 20,5%, RootJNT 18,8%, NewBack1JNT 18,8%, RFirstLeg3JNT 9,9%, LFirstLeg3JNT 9,0%, NewHeadJNT 2,0%. Asimetria 0,014 contra 0,005 del vanilla. 1,71 influencias por vertice. 42742 vertices casados sobre los 16048 de Blender, buffer de 854840 bytes a stride 20, FIRSTSKINMAT 0 -> LASTSKINMAT 7. Check-NMSGraft da salida 0. Y LA GUARDA CAMBIA CON EL METODO, que si no no guarda nada: con mapa a mano el tope de punta NO aplica -mide una anatomia que el mapa dice al reves a proposito, porque nuestras piernas SI cuelgan de las patas traseras- y se sustituye por otra mas fuerte: que el reparto que sale no se separe mas de 5 puntos del que pedia el mapa. El fallo del 15/08 eran 40 puntos de desviacion. Los otros tres asserts siguen midiendo contra el vanilla. LA FIRMA, ESCRITA ANTES DE ENTRAR. Si el necromorfo mueve brazos y piernas por separado, M3-PIEL cierra. Si se mueve mejor que la PRUEBA03 pero los brazos van con las piernas, el mapa tiene los lados cruzados y se cambian L por R en las dos filas de FirstLeg. Si un trozo sale disparado, la frontera de esa region es demasiado dura y hay que subir SUAVIZADOS. Si se estira sin forma o el juego cierra, son los indices y no el mapa. SUSTITUYE a la PRUEBA01, 02 y 03. Choca con HorribleTerror_NecroSkin.",
["ADD_FILES"]       = ENTREGA,
}
