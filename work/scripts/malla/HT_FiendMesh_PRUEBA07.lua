RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\models\fiendmesh_anim]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\textures]]

DESTINO_MALLA    = [[MODELS\PLANETS\CREATURES\SPIDERRIG]]
DESTINO_MATERIAL = [[MODELS\PLANETS\CREATURES\SPIDERRIG\FIEND]]
DESTINO_TEXTURA  = [[TEXTURES\PLANETS\CREATURES\SPIDERRIG]]

ENTREGA =
{
  {
    ["COMMENT"]              = "M3-PIEL - el .SCENE vanilla injertado, con FIRSTSKINMAT 0 y LASTSKINMAT 7. Byte a byte como la PRUEBA06",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.SCENE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.SCENE.MBIN]],
  },
  {
    ["COMMENT"]              = "M3-PIEL - VertexLayout a stride 20 con los canales 5 y 6, SkinMatrixLayout de 7 huesos y los cuatro arrays por hueso del vanilla. Byte a byte como la PRUEBA06",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.GEOMETRY.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.GEOMETRY.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "M3-AGARRE - EL UNICO ARCHIVO QUE CAMBIA. Mismo mapa a mano al primer eslabon de pata y los mismos 42742 vertices y 1718844 bytes que la PRUEBA06; lo que cambia son los PESOS: brazos y cabeza agarrados al torso para bajar la palanca de 18,4x a 4,0x",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.GEOMETRY.DATA.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.GEOMETRY.DATA.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "M3-FLAG - FIEND_MAT con _F02_SKINNED. md5 identico al de la PRUEBA06 y al de la PRUEBA04",
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
["MOD_FILENAME"]    = "HT_FiendMesh_PRUEBA07",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.7.0] M3-AGARRE: LA PALANCA, QUE ES LO QUE NUNCA SE HABIA MEDIDO. LO QUE MIDIO LA PRUEBA06 EN PARTIDA: la textura correcta en los dos bichos, los dos se mueven, y VUELVEN LAS CUCHILLAS - deformaciones en las extremidades cada vez que se mueven o atacan. La firma de la PRUEBA06 decia que si pasaba eso habia que subir SUAVIZADOS, que sigue en 12. SE MIDIO Y NO ES ESO: con 12 pasadas nuestra piel ya es MAS SUAVE que la del propio vanilla -salto de peso entre vertices unidos por una arista, p99 0,180 el nuestro contra 0,500 el del FIEND con su propia piel, y el FIEND no saca cuchillas-, y subir a 96 pasadas solo baja el p99 a 0,079 sin tocar la causa. LA COSTURA NUNCA FUE EL FALLO. LO QUE SI LO ES, MEDIDO EL 30/08 CON --barrer: LA PALANCA. Cada hueso mueve nuestros vertices tantas veces mas lejos que a la piel a la que iba destinado como lejos le quede el pivote, y se mide contra el centroide de la piel vanilla que ese hueso domina, no contra el armature, que NMSDK no deja alineado. LFirstLeg1JNT, que es el que lleva nuestro BRAZO IZQUIERDO, tiene nuestra piel a 2,77 m y la suya propia a 0,15 m: 18,4 VECES. El derecho 16,2x. La cabeza 6,2x. Y LAS PIERNAS 3,9x y 3,8x, que son justo las que en partida se ven BIEN. Ahi esta todo: el mismo giro que mueve la pata del FIEND cinco centimetros nos mueve el brazo casi un metro. Y explica por que cambiar de eslabon no lo arreglo nunca: Leg1, Leg2 y Leg3 tienen los tres la misma palanca de metros y solo cambia el giro, asi que la PRUEBA04 y la PRUEBA06 median lo mismo. EL ARREGLO, Y ES EN LOS PESOS: EL AGARRE. Cada region del mapa a mano se queda solo una parte alfa de su giro propio y el resto lo sigue a la region VECINA, que va con el cuerpo: los brazos y la cabeza al torso NewBack1JNT, las piernas a la cadera RootJNT. El desplazamiento es lineal en el peso, asi que alfa multiplica la palanca. Y NO SE ELIGE UN ALFA A OJO: se elige UN objetivo por modelo, 4,0x, y cada region coge el alfa que la deja justo ahi. 4,0 no es un numero redondo, es la amplificacion QUE YA TIENEN LAS PIERNAS, o sea la que la partida ya dice que se ve bien. LO QUE SALE: brazo izquierdo 18,4x a 4,0x con el 78% agarrado al torso, brazo derecho 16,2x a 4,0x con el 75%, cabeza 6,2x a 4,0x, Y LAS PIERNAS SIN TOCAR, porque ya estaban por debajo del objetivo. No es la PRUEBA05: al brazo le queda el 22% de su giro propio, o sea que sigue moviendose, cuatro veces lo que el vanilla mueve esa piel en vez de dieciocho. 2,27 influencias por vertice, 16048 de 16048 vertices con peso, 42742 casados, buffer de 854840 bytes a stride 20, paleta 2-15-19-23-27-39-42, FIRSTSKINMAT 0 a LASTSKINMAT 7. Asimetria 0,005 contra 0,005 del vanilla, que es lo mejor que ha salido nunca. El reparto no se separa mas de 0,5 puntos del que pide el mapa, con el tope en 5. Y la costura no empeora: p99 0,169 contra 0,180. LOS OTROS SEIS ARCHIVOS VAN BYTE A BYTE COMO LA PRUEBA06 -el .SCENE, el .GEOMETRY, el .MATERIAL con su flag y las tres texturas-, comprobado por md5: SOLO CAMBIA EL BUFFER DE VERTICES, asi que esta entrega mide UNA sola cosa. Y QUEDA UN MEDIDOR NUEVO en Weight-NMSMesh.py, que es lo que hay que usar antes de volver a entrar: --barrer mide la costura por arista y la palanca de cada region SIN ENTRAR A LA PARTIDA, con la piel del vanilla al lado como referencia. LA FIRMA, ESCRITA ANTES DE ENTRAR. Si el necromorfo mueve brazos y piernas y ya NO salen cuchillas, M3-PIEL cierra y el agarre es la respuesta. Si los brazos salen tiesos, el objetivo 4,0 se paso de bajo y hay que subirlo a 6,0, que deja el brazo en 6,0x. Si siguen saliendo cuchillas IGUALES que en la PRUEBA06, entonces no es la palanca del hueso sino el bind: los JointBindings se copian del FIEND tal cual y nuestra malla mide el doble que su esqueleto. SUSTITUYE a la PRUEBA01, 02, 03, 04, 05 y 06.",
["ADD_FILES"]       = ENTREGA,
}
