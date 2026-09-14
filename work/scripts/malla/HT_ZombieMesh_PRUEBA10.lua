RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\MODS\NMS_MOD_ZOMBIES\work\models\zombiemesh_anim]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\MODS\NMS_MOD_ZOMBIES\work\textures]]

DESTINO_MALLA    = [[MODELS\PLANETS\CREATURES\ARTHROPOD]]
DESTINO_MATERIAL = [[MODELS\PLANETS\CREATURES\ARTHROPOD\BUGFIEND]]
DESTINO_TEXTURA  = [[TEXTURES\PLANETS\CREATURES\ARTHROPOD\THORAX]]

ENTREGA =
{
  {
    ["COMMENT"]              = "M4-PIEL - el .SCENE vanilla injertado, con FIRSTSKINMAT 0 y LASTSKINMAT 7. md5 identico al de la PRUEBA09",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.SCENE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.SCENE.MBIN]],
  },
  {
    ["COMMENT"]              = "M4-PIEL - VertexLayout a stride 20 con los canales 5 y 6, SkinMatrixLayout de 7 huesos. md5 identico al de la PRUEBA09",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.GEOMETRY.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.GEOMETRY.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "M4-SIMETRIA - EL UNICO ARCHIVO QUE CAMBIA. Mismos 22982 vertices y los mismos 1043488 bytes que la PRUEBA09; lo que cambia es que las DOS piernas van al MISMO alfa fijo de 0,4 en vez de dejar que el tope de 120 le ponga una a cada una",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.GEOMETRY.DATA.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.GEOMETRY.DATA.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA02 - el descriptor recortado a UNA entrada, _Arthropod_1 sin hijos. md5 identico al de la PRUEBA09",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.DESCRIPTOR.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.DESCRIPTOR.MBIN]],
  },
  {
    ["COMMENT"]              = "M4-FLAG - ARTHROPODTHORAX01MAT con _F02_SKINNED y el gMasksMap apuntando a ZOMBIE.BASE.MASKS.DDS. md5 identico al de la PRUEBA09",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\ARTHROPODTHORAX01MAT.MATERIAL.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MATERIAL .. [[\ARTHROPODTHORAX01MAT.MATERIAL.MBIN]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA04, 05, 06, 07, 08 y 09, byte a byte - color base BC7 1024 con 11 mips",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\ZOMBIE.BASE.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\ZOMBIE.BASE.DDS]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA04, 05, 06, 07, 08 y 09, byte a byte - normal ATI2 1024 con 11 mips, esculpido en el asset",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\ZOMBIE.BASE.NORMAL.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\ZOMBIE.BASE.NORMAL.DDS]],
  },
  {
    ["COMMENT"]              = "M-BABA - mascaras PROPIAS, planas a 87 con el 3.2% de hueco de UV retenido a 0. Va a ruta PROPIA: ARTHROPODTHORAX01.BASE.MASKS.DDS la comparte toda la fauna artropodo del juego",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\ZOMBIE.BASE.MASKS.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\ZOMBIE.BASE.MASKS.DDS]],
  },
}

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_ZombieMesh_PRUEBA10",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.10.0] M4-SIMETRIA: LAS DOS PIERNAS AL MISMO NUMERO. Y ES LA PRIMERA PRUEBA DE LA SERIE MEDIDA ANTES DE CONSTRUIRLA. La herramienta nueva es tools/Pose-NMSMesh.py: deforma NUESTRA malla con los .ANIM del juego fuera de la partida, haciendo exactamente lo que hace el juego -v prima = suma de peso por pose_de_mundo(t) por inversa_de_bind por v- porque las tres piezas estan en disco y Patch-NMSGraft.py copia los JointBindings del vanilla TAL CUAL. Lleva dos comprobaciones que abortan: que el JOINTINDEX y la transpuesta del bind sean los buenos, y que con toda la malla colgando de UN hueso el skinning no deforme nada, que da 8,3e-14. LO QUE ENCONTRO, Y ES LA CAUSA DE LA ASIMETRIA QUE LA PRUEBA09 ANOTO COMO PRECIO A PAGAR: el tope de vaiven NO TRATA IGUAL A LAS DOS PIERNAS. En arthropodattack01 los dos huesos giran casi lo mismo -leg_L2_0_jnt 46,8 grados y leg_R2_0_jnt 41,6- pero nuestras palancas son 3,6x y 2,1x, asi que el vaiven sale 168 y 87, y el tope de 120 AGARRA LA IZQUIERDA a alfa 0,71 Y DEJA SUELTA LA DERECHA a alfa 1,0. La asimetria no la pone el ARTHROPOD, que es simetrico -al andar las dos patas giran 17,9 y 17,8 grados, y paradas 2,7 y 2,7-: la fabrica el tope al leer una palanca que sale de nuestro propio reparto, que si es asimetrico -2746 vertices contra 3610, palanca real de 0,75 m contra 1,17 m, pureza de peso 0,69 contra 0,94-. Y EN LOCOMOCION EL TOPE NO LLEGA A NINGUNA DE LAS DOS, que valen 65 y 59 contra un tope de 120: ahi la costura de la cadera se abre porque el muslo cuelga de un hueso que gira 28,3 grados y la cintura de uno que gira 3,2, con saltos de peso de 0,42 sobre aristas de 2,8 cm. EL ARREGLO ES NO DEJAR QUE EL TOPE DECIDA POR PALANCAS DISTINTAS: alfas_fijos pone las dos piernas en 0,4, el mismo numero, y el tope de 120 se queda como estaba para brazos y cabeza. LO QUE MIDE, ANTES DE ENTRAR AL JUEGO, la PRUEBA09 contra esta, donde tension es cuantas veces se estira la distancia entre dos vertices vecinos y abre es lo mismo en centimetros: andando 27,7 a 11,5 y 16 cm a 7 cm; corriendo 41,2 a 17,0 y 22 cm a 13 cm; atacando 33,9 a 13,0 y 21 cm sin cambio; parado sin cambio. Y flex, que es la deformacion normal en el p99, se queda entre 1,84 y 2,36: la piel SIGUE DEFORMANDO y esto NO es una estatua. LOS BRAZOS NO SE TOCAN, Y SE PROBO: agarrarlos a 0,75 lleva el ataque de 21 a 74 cm, porque el ancla es spine_C0_0_jnt y el torso tiene MAS alcance hasta los vertices del brazo que el propio hueso del brazo. LO QUE ESTA PRUEBA NO ARREGLA, Y SE DICE ANTES DE ENTRAR: el hombro derecho. Atacando abre 21 cm, y parado da un pico de 14,8 cm en el fotograma 15 de 121; los dos en altura 0,86-0,87, que es justo donde el mapa corta la region de la cabeza. Los 12 suavizados sangran peso de cabeza al otro lado de esa costura y el pivote de head_C0_0_jnt esta a y 0,867 mientras esos vertices estan a y 2,09, o sea 1,22 m de palanca. La cuenta cierra: 30 grados por 1,22 m por 0,257 de salto son 16 cm, y se miden 14,8. Y LA CABEZA YA ESTA EN SU TOPE, en alfa 0,40 por el vaiven 299 del ataque, asi que por esa via no queda recorrido. LA RAZON DE FONDO, MEDIDA: nuestra malla va de y 0 a y 2,430 y el hueso mas alto del ARTHROPOD esta a y 1,175. Por encima de y 1,2 hay CERO huesos y el 49,5% de nuestra malla. La mitad del zombie cuelga por encima del final del esqueleto, y ningun reparto de pesos arregla eso porque la palanca no la ponen los pesos. La via que queda sin probar es cambiar el ancla del torso alto a tail_C0_2_jnt, que esta a y 1,175 -21 cm mas arriba que spine_C0_0_jnt- y ademas gira menos atacando -53,9 contra 118,7-, y eso es otra prueba. LOS OTROS CUATRO MBIN VAN BYTE A BYTE COMO LA PRUEBA09, comprobado por md5 uno a uno: SOLO CAMBIA EL BUFFER DE VERTICES, y mide los mismos 1043488 bytes. Check-NMSGraft en salida 0, con _F02_SKINNED puesto y los tres samplers verificados. LA FIRMA, ESCRITA ANTES DE ENTRAR. Si la mitad de abajo deja de salir descuadrada de un lado y el cono hacia el suelo se va, M4-SIMETRIA cierra y del zombie solo queda el hombro. Si abajo mejora pero sigue habiendo cuchilla en un lado y no en el otro, lo que descuadra no es el alfa sino el reparto -2746 vertices contra 3610- y hay que igualar las regiones, no los alfas. Si el zombie sale tieso de piernas al andar, 0,4 se paso y hay que subirlo a 0,6, que medido deja la carrera en 25,0 en vez de 17,0. SUSTITUYE a la PRUEBA01, 02, 03, 04, 05, 06, 07, 08 y 09.",
["ADD_FILES"]       = ENTREGA,
}
