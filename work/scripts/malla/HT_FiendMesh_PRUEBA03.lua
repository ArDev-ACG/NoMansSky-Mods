RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\models\fiendmesh_anim]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\textures]]

DESTINO_MALLA    = [[MODELS\PLANETS\CREATURES\SPIDERRIG]]
DESTINO_MATERIAL = [[MODELS\PLANETS\CREATURES\SPIDERRIG\FIEND]]
DESTINO_TEXTURA  = [[TEXTURES\PLANETS\CREATURES\SPIDERRIG]]

ENTREGA =
{
  {
    ["COMMENT"]              = "M3-PIEL - el .SCENE vanilla injertado, con FIRSTSKINMAT 0 y LASTSKINMAT 15",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.SCENE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.SCENE.MBIN]],
  },
  {
    ["COMMENT"]              = "M3-PIEL - VertexLayout a stride 20 con los canales 5 y 6, SkinMatrixLayout de 15 huesos y los cuatro arrays por hueso del vanilla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.GEOMETRY.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.GEOMETRY.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "M3-PIEL - el buffer de 42742 vertices con indice de hueso y peso, 1718844 bytes",
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
["MOD_FILENAME"]    = "HT_FiendMesh_PRUEBA03",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.3.0] M3-PIEL: el necromorfo deja de ir rigido. Es la PRUEBA02 con la piel puesta, el normal rehecho y mascaras propias. LO QUE BLOQUEABA, medido el 27/08 y eran DOS cosas, ninguna del pesado. UNA: tools/Weight-NMSMesh.py cogia la PRIMERA malla del vanilla con grupos de vertices, un next() que basto para el SkrullCrawler porque el FreighterFiend trae UNA sola -polySurface6- y no basta aqui, que el FIEND trae tres. DOS, y es la gorda: el importador de NMSDK ABORTA la escena entera en el primer material roto -realize_path devuelve None y create_material_node hace un op.join con ese None- y en el FIEND ademas revienta en _add_light_to_scene, buscando un nodo Emission que Blender 5.2 ya no crea. La receta llamaba a ese error ruidoso pero inofensivo y no lo es: se lleva por delante las mallas que quedaban por anadir. Las dos se parchean desde fuera, como ya se hacia con mesh_parser, y el addon no se toca. TERCERA CAUSA, LA QUE EXPLICA EL 63,7% DE RootJNT: la escala. El guion hinchaba el esqueleto vanilla hasta llenar nuestra malla -x2.0008, porque el necromorfo se subio A PROPOSITO a 3,62 m cuando a la altura del FIEND se veia enano, y esa decision no se toca- y eso ES INCOMPATIBLE con como se lee la piel en partida: los JointBindings, o sea las matrices de bind inversas, se copian del vanilla tal cual en Patch-NMSGraft.py, asi que el juego lee nuestros vertices en el espacio del vanilla SIN reescalar. Casar contra un rig hinchado es casar contra huesos que en partida estan en otro sitio. Con escala 1.0 el vertice medio baja de 2,170 a 1,558 de su hueso sobre una diagonal de 4,97, aparecen 15 huesos con peso en vez de 12 y NewHeadJNT empieza a recibir. LO QUE SALE: 42742 vertices casados sobre los 16048 de Blender, paleta de 15 huesos de 44, buffer de 1718844 bytes a stride 20, FIRSTSKINMAT 0 -> LASTSKINMAT 15, 1,68 influencias por vertice. Reparto: RootJNT 79,5%, LFourthLeg3JNT 5,0%, RFourthLeg3JNT 4,3%, NewHeadJNT 2,7%. Asimetria 0,012 contra 0,005 del vanilla, o sea PAREADA, que es el numero que de verdad separo los dos pesados malos del SkrullCrawler. Check-NMSGraft da salida 0. EL 79,5% ESTA ACEPTADO Y NO ES EL FALLO DEL 15/08, y la diferencia esta medida: aquel tenia RootJNT al 0,4% con una punta de pata al 43,2%, o sea el tronco vacio; aqui el tronco se lo lleva TODO y las puntas no pasan del 5%. El tope relativo contra el vanilla no lo puede pasar ningun bipedo montado en una arana -el FIEND pone su maximo en RootJNT con el 20,4% porque a una arana la masa se le va a la cabeza y a las ocho patas-, asi que estos dos modelos llevan tope ABSOLUTO del 85% y los otros tres asserts, tronco minimo, tope de punta y simetria, siguen midiendo contra el vanilla. LA TEXTURA, que iba en el mismo paquete: el normal estaba a desviacion 4,7 contra los 17,2 del FIEND vanilla -se genero con --fuerza 2- y se rehace con --fuerza 9 y --sin-costuras, que aplana el 21,0% de la textura -borde de isla y hueco- y deja desvio X 17,1 e Y 15,8. Y el gMasksMap deja de ser el del vanilla, pintado para otras UV: se entrega uno PROPIO y PLANO a 87, que es la media util del gMasksMap del FIEND vanilla medida el 22/08, con el 35,4% de hueco de UV retenido a 0. Plano y no del roughness porque el asset de Tripo no trae roughness, solo color; es el arreglo minimo que quita el brillo de baba sin inventar relieve. LA FIRMA, ESCRITA ANTES DE ENTRAR. Si el necromorfo se mueve -distinta postura en capturas distintas- M3-PIEL cierra. Si se estira sin forma o el juego se cierra, son los pesos o los indices y se vuelve al paso 2 de la receta. Si se mueve pero SOLO de bloque, sin que las patas hagan nada, entonces el 79,5% de RootJNT es demasiado y lo que falta es un mapa a mano de region nuestra -> hueso vanilla, que es trabajo nuevo y no un arreglo. Si sigue de plastico, el normal no era y hay que mirar la convencion del canal verde. SUSTITUYE a la PRUEBA01 y la PRUEBA02. Choca con HorribleTerror_NecroSkin.",
["ADD_FILES"]       = ENTREGA,
}
