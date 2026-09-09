RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\models\fiendmesh_anim]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\textures]]

DESTINO_MALLA    = [[MODELS\PLANETS\CREATURES\SPIDERRIG]]
DESTINO_MATERIAL = [[MODELS\PLANETS\CREATURES\SPIDERRIG\FIEND]]
DESTINO_TEXTURA  = [[TEXTURES\PLANETS\CREATURES\SPIDERRIG]]

ENTREGA =
{
  {
    ["COMMENT"]              = "M3-PIEL - el .SCENE vanilla injertado, con FIRSTSKINMAT 0 y LASTSKINMAT 7. md5 identico al de la PRUEBA07",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.SCENE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.SCENE.MBIN]],
  },
  {
    ["COMMENT"]              = "M3-PIEL - VertexLayout a stride 20 con los canales 5 y 6, SkinMatrixLayout de 7 huesos. md5 identico al de la PRUEBA07",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.GEOMETRY.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.GEOMETRY.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "M3-ESPEJO - EL UNICO ARCHIVO QUE CAMBIA. Mismo mapa y los mismos 42742 vertices y 1718844 bytes que la PRUEBA07; lo que cambia son los PESOS DE LAS PIERNAS: la izquierda baja de vaiven 271 a 113 para igualar a la derecha, que ya estaba en 113. Brazos y cabeza SIN TOCAR",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.GEOMETRY.DATA.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.GEOMETRY.DATA.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "M3-FLAG - FIEND_MAT con _F02_SKINNED. md5 identico al de la PRUEBA07, la PRUEBA06 y la PRUEBA04",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND_MAT.MATERIAL.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MATERIAL .. [[\FIEND_MAT.MATERIAL.MBIN]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA02, byte a byte - el atlas de color del asset",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\NECROMORPH.BASE.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\FIEND.BASE.DDS]],
  },
  {
    ["COMMENT"]              = "M-TEX - normal rehecho a fuerza 9 y con --sin-costuras: desvio X 17.1 e Y 15.8, contra el 17.2 del FIEND vanilla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\NECROMORPH.BASE.NORMAL.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\FIEND.BASE.NORMAL.DDS]],
  },
  {
    ["COMMENT"]              = "M-BABA - mascaras PROPIAS, planas a 87 con el 35.4% de hueco de UV retenido a 0",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\NECROMORPH.BASE.MASKS.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\FIEND.BASE.MASKS.DDS]],
  },
}

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_FiendMesh_PRUEBA08",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.8.0] M3-ESPEJO: LAS DOS PATAS TRASERAS DEL FIEND NO GIRAN LO MISMO, Y NUESTRAS DOS PIERNAS CUELGAN UNA DE CADA UNA. LO QUE MIDIO LA PRUEBA07 EN PARTIDA, el 31/08: los brazos y el ataque salen LIMPIOS -el agarre funciono ahi-, pero al ANDAR se estira la mitad del cuerpo, como un cuarto de su tamano, y al CORRER el cuerpo entero se despega del suelo. LA CAUSA, Y NO ES LA QUE DECIA LA FIRMA DE LA 07. La 07 elegia el agarre con la PALANCA sola -lo lejos que le queda el pivote a nuestra piel, o sea cuantas VECES amplifica-, y la palanca NO SABE CUANTO GIRA EL HUESO. Por eso le salio del reves: apreto la CABEZA al 61% -palanca 6,2x pero 2,9 grados al andar, o sea inofensiva- y dejo ENTERAS las dos patas traseras -palanca solo 3,9x y 3,8x, pero son las que MAS GIRAN de toda la paleta y llevan el 41,7% de la malla-. Lo que estira es PALANCA POR GIRO, y eso hasta ahora no se habia medido nunca. LOS NUMEROS, sacados el 31/08 de los .ANIM del SPIDERRIG con Sway-NMSJoint.py, que es la herramienta que faltaba. Giro de mundo al andar y al correr: LFourthLeg1JNT 69,5 y 67,3 grados; RFourthLeg1JNT 26,2 y 29,4. O sea que la pata trasera IZQUIERDA del FIEND gira 2,7 VECES lo que la derecha al andar y 2,3 al correr. No es desfase de paso, es AMPLITUD: el FIEND es una arana de ocho patas y su animador nunca necesito simetria izquierda-derecha. Y nuestro mapa parte la mitad de abajo de la malla por un plano DURO en u 0,50 y cuelga cada mitad de una de las dos. Las dos mitades se mueven distinto y cizallan por la linea media: ESO es -al andar se estira la mitad del cuerpo-, y no lo arregla ningun tope global porque es una diferencia ENTRE regiones, no un exceso de una sola. Y ES TAMBIEN EL FLOTAR AL CORRER, medido y descartado lo otro: se leyeron las ALTURAS DE MUNDO de los pivotes y en fiendrun suben solo 0,19 m sobre fiendidle, asi que NO es traslacion; es que al correr los brazos se paran -3,2 y 4,0 grados- y las piernas se van a 67,3 mientras el torso se queda en 3,3, o sea que la mitad de abajo se columpia sola y el bicho parece levantarse. EL ARREGLO, Y ES UNA REGLA, NO UN NUMERO A OJO: EL ESPEJO. Cada region se iguala con la del otro lado por el lado MAS QUIETO, que es el que en partida se ve bien. La pierna izquierda baja de vaiven 271 a 113 -agarre del 58% a RootJNT- y la derecha se queda como estaba, en 113. Un bipedo anda con las dos piernas igual; el rig no lo hace, y esto lo compensa en el peso. LOS BRAZOS Y LA CABEZA NO SE TOCAN, congelados en el alfa de la PRUEBA07 -0,22, 0,25 y 0,65- porque en partida ya no estiran. Los brazos salen TIESOS y eso se sabe y se deja para otra prueba: soltarlos es cambiar dos cosas a la vez. ASI QUE ESTA ENTREGA MUEVE UNA SOLA COSA: las piernas. LO QUE SALE: 2,42 influencias por vertice, 16048 de 16048 vertices con peso, 42742 casados, buffer de 854840 bytes a stride 20, FIRSTSKINMAT 0 a LASTSKINMAT 7. Asimetria 0,017 contra 0,005 del vanilla, y la costura no empeora: p99 0,160 contra 0,169 de la PRUEBA07. El reparto no se separa mas de 5 puntos del mapa. LOS OTROS SEIS ARCHIVOS VAN BYTE A BYTE COMO LA PRUEBA07, comprobado por md5 uno a uno: SOLO CAMBIA EL BUFFER DE VERTICES. Y QUEDAN DOS ARREGLOS EN LAS HERRAMIENTAS. UNO: Sway-NMSJoint.py lee ahora tambien las Translations del .ANIM y saca la altura de mundo de cada pivote por clip, que es lo que permitio descartar la traslacion como causa del flotar; y con --json vuelca los giros para que Weight-NMSMesh elija el agarre por palanca POR giro. DOS: el guard de asimetria media HUESOS DOMINANTES, y eso deja de querer decir nada en cuanto el agarre baja de 0,5 -con alfa 0,42 la pierna izquierda no manda en NINGUNO de sus vertices, manda RootJNT, y el guard leia 0,208 de desparejo cuando el mapa habia repartido las dos mitades igual-. Ahora mide MASA de peso y descuenta el alfa, asi que sigue cazando lo que se escribio para cazar: que el suavizado o el vecino mas cercano se coman un lado. LA FIRMA, ESCRITA ANTES DE ENTRAR. Si al andar ya no se estira ninguna mitad y al correr el cuerpo se queda en el suelo, el espejo es la respuesta y M3-PIEL cierra por el lado de las piernas. Si las dos mitades van ya iguales pero LAS DOS estiran, entonces 113 de vaiven sigue siendo mucho y toca poner objetivo, que va en None a proposito. Si sigue estirando solo una mitad, el lado que estira no era el izquierdo y hay que mirar el signo. Si las piernas salen TIESAS como los brazos, el espejo se paso y hay que igualar por la media y no por el minimo. SUSTITUYE a la PRUEBA01, 02, 03, 04, 05, 06 y 07.",
["ADD_FILES"]       = ENTREGA,
}
