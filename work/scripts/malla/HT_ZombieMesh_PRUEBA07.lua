RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\MODS\NMS_MOD_ZOMBIES\work\models\zombiemesh_anim]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\MODS\NMS_MOD_ZOMBIES\work\textures]]

DESTINO_MALLA    = [[MODELS\PLANETS\CREATURES\ARTHROPOD]]
DESTINO_MATERIAL = [[MODELS\PLANETS\CREATURES\ARTHROPOD\BUGFIEND]]
DESTINO_TEXTURA  = [[TEXTURES\PLANETS\CREATURES\ARTHROPOD\THORAX]]

ENTREGA =
{
  {
    ["COMMENT"]              = "M4-PIEL - el .SCENE vanilla injertado, con FIRSTSKINMAT 0 y LASTSKINMAT 7. Byte a byte como la PRUEBA06",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.SCENE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.SCENE.MBIN]],
  },
  {
    ["COMMENT"]              = "M4-PIEL - VertexLayout a stride 20 con los canales 5 y 6, SkinMatrixLayout de 7 huesos y los cuatro arrays por hueso del vanilla. Byte a byte como la PRUEBA06",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.GEOMETRY.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.GEOMETRY.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "M4-AGARRE - EL UNICO ARCHIVO QUE CAMBIA. Mismo mapa a mano al primer eslabon CON CLAVES, leg_*_0_jnt, y los mismos 22982 vertices y 1043488 bytes que la PRUEBA06; lo que cambia son los PESOS: brazos y cabeza agarrados a la columna para bajar la palanca de 7,7x a 4,0x",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.GEOMETRY.DATA.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.GEOMETRY.DATA.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA02 - el descriptor recortado a UNA entrada, _Arthropod_1 sin hijos",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.DESCRIPTOR.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.DESCRIPTOR.MBIN]],
  },
  {
    ["COMMENT"]              = "M4-FLAG - ARTHROPODTHORAX01MAT con _F02_SKINNED y el gMasksMap apuntando a ZOMBIE.BASE.MASKS.DDS. md5 identico al de la PRUEBA06",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\ARTHROPODTHORAX01MAT.MATERIAL.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MATERIAL .. [[\ARTHROPODTHORAX01MAT.MATERIAL.MBIN]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA04, la 05 y la 06, byte a byte - color base BC7 1024 con 11 mips",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\ZOMBIE.BASE.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\ZOMBIE.BASE.DDS]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA04, la 05 y la 06, byte a byte - normal ATI2 1024 con 11 mips, esculpido en el asset",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\ZOMBIE.BASE.NORMAL.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\ZOMBIE.BASE.NORMAL.DDS]],
  },
  {
    ["COMMENT"]              = "M-BABA - mascaras PROPIAS, planas a 87 con el 3.2% de hueco de UV retenido a 0. Va a ruta PROPIA, ZOMBIE.BASE.MASKS.DDS: ARTHROPODTHORAX01.BASE.MASKS.DDS la comparte toda la fauna artropodo del juego",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\ZOMBIE.BASE.MASKS.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\ZOMBIE.BASE.MASKS.DDS]],
  },
}

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_ZombieMesh_PRUEBA07",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.7.0] M4-AGARRE: LA PALANCA, QUE ES LO QUE NUNCA SE HABIA MEDIDO. LO QUE MIDIO LA PRUEBA06 EN PARTIDA: la textura correcta en los dos bichos, los dos se mueven, y VUELVEN LAS CUCHILLAS - deformaciones en las extremidades cada vez que se mueven o atacan. La firma de la PRUEBA06 decia que si pasaba eso habia que subir SUAVIZADOS, que sigue en 12. SE MIDIO Y NO ES ESO: con 12 pasadas nuestra piel ya es MAS SUAVE que la del propio vanilla -salto de peso entre vertices unidos por una arista, p99 0,175 el nuestro contra 0,306 el del ARTHROPOD con su propia piel-, y subir a 96 pasadas solo baja el p99 a 0,076 y ademas empieza a comerse las regiones del mapa: 2,6 puntos de deriva con el tope en 5. LA COSTURA NUNCA FUE EL FALLO. LO QUE SI LO ES, MEDIDO EL 30/08 CON --barrer: LA PALANCA. Cada hueso mueve nuestros vertices tantas veces mas lejos que a la piel a la que iba destinado como lejos le quede el pivote, y se mide contra el centroide de la piel vanilla que ese hueso domina, no contra el armature, que NMSDK no deja alineado. leg_R0_0_jnt, que lleva nuestro BRAZO DERECHO, tiene nuestra piel a 1,30 m y la suya propia a 0,17 m: 7,7 VECES. El izquierdo 6,8x. La cabeza 4,1x. Y LAS PIERNAS 3,6x y 2,1x, que son justo las que en partida se ven BIEN. El mismo giro que mueve la pata del ARTHROPOD unos centimetros nos mueve el brazo casi un metro. Y explica por que cambiar de eslabon no lo arreglo nunca: legbase, leg_0 y leg_1 tienen los tres la misma palanca y solo cambia el giro, asi que la PRUEBA04 y la PRUEBA06 median lo mismo. EL ARREGLO, Y ES EN LOS PESOS: EL AGARRE. Cada region del mapa a mano se queda solo una parte alfa de su giro propio y el resto lo sigue a la region VECINA, que va con el cuerpo: los brazos y la cabeza a la columna spine_C0_0_jnt, las piernas al abdomen tail_C0_0_jnt. El desplazamiento es lineal en el peso, asi que alfa multiplica la palanca. Y NO SE ELIGE UN ALFA A OJO: se elige UN objetivo por modelo, 4,0x, y cada region coge el alfa que la deja justo ahi. 4,0 no es un numero redondo, es la amplificacion QUE YA TIENEN LAS PIERNAS, o sea la que la partida ya dice que se ve bien. LO QUE SALE: brazo derecho 7,7x a 4,0x, brazo izquierdo 6,8x a 4,0x, cabeza 4,1x a 4,0x, Y LAS PIERNAS SIN TOCAR, porque ya estaban por debajo del objetivo. No es la PRUEBA05, donde los miembros colgaban de legbase_* y no se movian NADA: aqui al brazo le queda mas de la mitad de su giro propio. 2,19 influencias por vertice, 17983 de 17983 vertices con peso, 22982 casados, buffer de 459640 bytes a stride 20, paleta 2-3-7-19-25-37-42, FIRSTSKINMAT 0 a LASTSKINMAT 7. Asimetria 0,040 contra 0,018 del vanilla -la PRUEBA06 daba 0,052-; lo que queda es que el zombie esta MODELADO en postura. El reparto no se separa mas de 2,2 puntos del que pide el mapa, con el tope en 5. Y la costura no empeora: p99 0,167 contra 0,175. LOS OTROS SIETE ARCHIVOS VAN BYTE A BYTE COMO LA PRUEBA06 -el .SCENE, el .GEOMETRY, el descriptor, el .MATERIAL con su flag y su gMasksMap, y las tres texturas-, comprobado por md5: SOLO CAMBIA EL BUFFER DE VERTICES, asi que esta entrega mide UNA sola cosa. Y QUEDA UN MEDIDOR NUEVO en Weight-NMSMesh.py, que es lo que hay que usar antes de volver a entrar: --barrer mide la costura por arista y la palanca de cada region SIN ENTRAR A LA PARTIDA, con la piel del vanilla al lado como referencia. LA FIRMA, ESCRITA ANTES DE ENTRAR. Si el zombie mueve brazos y piernas, sale seco y ya NO salen cuchillas, M4-PIEL cierra y el agarre es la respuesta. Si los brazos salen tiesos, el objetivo 4,0 se paso de bajo y hay que subirlo a 6,0. Si siguen saliendo cuchillas IGUALES que en la PRUEBA06, entonces no es la palanca del hueso sino el bind: los JointBindings se copian del ARTHROPOD tal cual. SUSTITUYE a la PRUEBA01, 02, 03, 04, 05 y 06.",
["ADD_FILES"]       = ENTREGA,
}
