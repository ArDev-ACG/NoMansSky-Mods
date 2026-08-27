RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\models\scuttlermesh_anim]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\textures]]

DESTINO_MALLA    = [[MODELS\PLANETS\CREATURES\SPIDERRIG]]
DESTINO_MATERIAL = [[MODELS\PLANETS\CREATURES\SPIDERRIG\FREIGHTERFIEND]]
DESTINO_TEXTURA  = [[TEXTURES\PLANETS\CREATURES\SPIDERRIG]]
DESTINO_PROC     = [[TEXTURES\COMMON\PLAYER\PLAYERCHARACTER]]

ENTREGA =
{
  {
    ["COMMENT"]              = "M-PALETA - el mismo nodo de malla, con FIRSTSKINMAT 0 y LASTSKINMAT 14: la paleta vuelve a ser un subconjunto de la del vanilla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FREIGHTERFIEND.SCENE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FREIGHTERFIEND.SCENE.MBIN]],
  },
  {
    ["COMMENT"]              = "M-PALETA - VertexLayout a stride 20 con los canales 5 y 6, SkinMatrixLayout de 14 huesos -los 42 de la PRUEBA14 metian parpados, ojos, boca, mandibula y cola- y los cuatro arrays por hueso del vanilla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FREIGHTERFIEND.GEOMETRY.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FREIGHTERFIEND.GEOMETRY.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "M-PALETA - el mismo buffer de 7627 vertices con los canales 5 y 6 rehechos: copiados de la piel del vanilla y suavizados por nuestras aristas",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FREIGHTERFIEND.GEOMETRY.DATA.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FREIGHTERFIEND.GEOMETRY.DATA.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA14, byte a byte, verificado con cmp - FFIENDMAT con _F02_SKINNED y el gNormalMap al normal propio",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FFIENDMAT.MATERIAL.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MATERIAL .. [[\FFIENDMAT.MATERIAL.MBIN]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA14, byte a byte, verificado con cmp - color base propio, BC7 2048 con 12 mips",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\SKRULLCRAWLER.BASE.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\SKRULLCRAWLER.BASE.DDS]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA14, byte a byte, verificado con cmp - las mascaras invertidas, con el fondo de UV retenido a 0",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\SKRULLCRAWLER.BASE.MASKS.INV.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\SKRULLCRAWLER.BASE.MASKS.DDS]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA14, byte a byte, verificado con cmp - normal propio, ATI2 2048 con 12 mips",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\SKRULLCRAWLER.BASE.NORMAL.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\SKRULLCRAWLER.BASE.NORMAL.DDS]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA14, byte a byte, verificado con cmp - lista procedural sin capas, que mande el gDiffuseMap",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FREIGHTERFIEND.TEXTURE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_PROC .. [[\FREIGHTERFIEND.TEXTURE.MBIN]],
  },
}

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_ScuttlerMesh_PRUEBA16",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.16.0] M-PALETA: la nuca estirada no era la textura, era el pesado. SOLO CAMBIAN LOS TRES ARCHIVOS DE GEOMETRIA; el material y las cinco texturas van byte a byte como en la PRUEBA14, verificado con cmp, asi que lo que se mide es la piel y no el color. LO QUE DEJO LA PRUEBA14, medido en las cuatro capturas del 25/08: de frente el bicho sale PERFECTO -craneo, ojos y pinzas se leen, la textura es continua y no hay dibujos de estrella-, asi que M-BABA y M-UVIDX quedan cerrados. Por detras no: la espalda sale como una lona negra enorme y de ella cuelgan tiras planas y astillas rectas. Es la firma que la propia PRUEBA14 dejo escrita -piel bien pero el bicho deformado- y apunta a la paleta de 42 huesos. PRIMERA CAUSA, PROBADA: el .SCENE del FreighterFiend trae 114 huesos pero SU PIEL SOLO SE PEGA A 19, y esos 19 estan escritos en el SkinMatrixLayout del .GEOMETRY vanilla. La PRUEBA14 pesaba contra los 113 del esqueleto, asi que de los 42 grupos que salieron 30 CAIAN FUERA de esa lista: NewJawJNT y NewJawEND con 425 vertices, NewTail2/3/4 con 882, LThirdLeg3/4END con 626, y luego REyelidLowerJNT, LEyeParentJNT, LowerLMouthJNT o LPincer4JNT con UN vertice cada uno. Un vertice nuestro colgado de un parpado sale disparado en cuanto el bicho parpadea: esas son las astillas. SEGUNDA CAUSA, LA MISMA QUE MATO A LA PRUEBA12: adjudicar a UN ganador entre huesos que estan casi a la misma distancia. La PRUEBA12 copiaba del punto mas cercano de la SUPERFICIE vanilla y las dos puntas delanteras se llevaron el 82% de la malla; la PRUEBA14 media al SEGMENTO de cada hueso y dejo LFirstLeg3JNT en el 12,1% con RFirstLeg3JNT en el 0,0%. El FreighterFiend es una arana de patas largas y cuerpo pequeno y el nuestro es compacto, asi que sus patas atraviesan nuestro volumen: una franja del torso se va con una pata, la de al lado se queda con la espalda, y al andar la costura entre las dos se tensa. Eso es la lona. LO QUE SE DESCARTO CON NUMEROS, PARA NO VOLVER A MIRARLO: el GIRO_Z no es -los cuatro giros, 0, 90, 180 y 270, fallan igual y ninguno pasa del 4,8% en NewHeadJNT contra el 27,5% que le da el vanilla-, y la distancia del vertice a su hueso tampoco -el vanilla contra su propio esqueleto da 1,039 de media sobre una diagonal de 4,22, peor que los 0,903 del metodo que fallaba-. LO QUE SI SEPARA ES LA SIMETRIA: el reparto del vanilla esta pareado al vertice -RFirstLeg3JNT 260 y LFirstLeg3JNT 260- y da asimetria 0,000; la PRUEBA14 daba 0,253. EL ARREGLO, TRES PASOS: los candidatos salen del SkinMatrixLayout del vanilla, o sea 19 de 113, y los parpados dejan de poder ganar porque dejan de estar en la lista; cada vertice nuestro promedia los OCHO vertices mas cercanos de la piel vanilla con peso inverso a la distancia, que quita el ganador unico; y se suaviza doce pasadas por las aristas de NUESTRA malla, que es lo unico que devuelve al torso la trasera que las patas se llevan, porque ahi no hay nada del vanilla que copiar salvo pata. Ataca el fallo de frente: una lamina tensada ES un salto de peso entre dos vertices unidos por una arista. LOS NUMEROS DE ESTA ENTREGA: 14 huesos con peso y los 14 son subconjunto de los 19 del vanilla; RootJNT se lleva el 43,5% contra el 45,9% que el vanilla pone en el suyo; asimetria 0,026 contra 0,000 del vanilla; 1,96 influencias por vertice contra 1,23 antes de suavizar, que es la costura convertida en degradado; 7627 vertices casados sobre los 4820 de Blender; buffer de 152540 bytes a stride 20; FIRSTSKINMAT 0 -> LASTSKINMAT 14. Check-NMSGraft da salida 0 y los 31 tests de tools/tests pasan salvo cinco que traen constantes de la malla de antes del 24/08 y ya fallaban. LA FIRMA, ESCRITA ANTES DE ENTRAR. Si la espalda sale limpia y sin lonas ni astillas, M-PALETA cierra y con el toda la Etapa 4, y lo siguiente es repetir la receta en el necromorfo -M3-PIEL- y en el zombie -M4-PIEL-. Si las astillas se acaban pero queda una lona en la trasera, lo que falta es lo unico que quedo por encima del vanilla: LFourthLeg3JNT se lleva el 15,5% y RFourthLeg3JNT el 14,3% cuando el vanilla da 3,4% a las suyas, y entonces hay que subir SUAVIZADOS en tools/Weight-NMSMesh.py, no rediagnosticar. Si sale exactamente igual que la PRUEBA14, el mod no se ha desplegado: mirar la fecha del .MBIN desplegado antes de tocar nada. Sustituye a las PRUEBA01 a 15 y choca con HT_FiendMarkers_PRUEBA04 y con HorribleTerror_NecroSkin.",
["ADD_FILES"]       = ENTREGA,
}
