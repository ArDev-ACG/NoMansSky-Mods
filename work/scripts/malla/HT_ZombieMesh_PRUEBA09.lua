RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\MODS\NMS_MOD_ZOMBIES\work\models\zombiemesh_anim]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\MODS\NMS_MOD_ZOMBIES\work\textures]]

DESTINO_MALLA    = [[MODELS\PLANETS\CREATURES\ARTHROPOD]]
DESTINO_MATERIAL = [[MODELS\PLANETS\CREATURES\ARTHROPOD\BUGFIEND]]
DESTINO_TEXTURA  = [[TEXTURES\PLANETS\CREATURES\ARTHROPOD\THORAX]]

ENTREGA =
{
  {
    ["COMMENT"]              = "M4-PIEL - el .SCENE vanilla injertado, con FIRSTSKINMAT 0 y LASTSKINMAT 7. md5 identico al de la PRUEBA08",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.SCENE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.SCENE.MBIN]],
  },
  {
    ["COMMENT"]              = "M4-PIEL - VertexLayout a stride 20 con los canales 5 y 6, SkinMatrixLayout de 7 huesos. md5 identico al de la PRUEBA08",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.GEOMETRY.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.GEOMETRY.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "M4-ATAQUE - EL UNICO ARCHIVO QUE CAMBIA. Mismo mapa y los mismos 22982 vertices y 1043488 bytes que la PRUEBA08; lo que cambia es que el tope de 120 se mide sobre LOS CUATRO CLIPS y no solo sobre walk y run: la cabeza entra por primera vez -de 300 a 120, agarre 60% al torso- y con ella la pierna izquierda -de 169 a 120-",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.GEOMETRY.DATA.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.GEOMETRY.DATA.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA02 - el descriptor recortado a UNA entrada, _Arthropod_1 sin hijos",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.DESCRIPTOR.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.DESCRIPTOR.MBIN]],
  },
  {
    ["COMMENT"]              = "M4-FLAG - ARTHROPODTHORAX01MAT con _F02_SKINNED y el gMasksMap apuntando a ZOMBIE.BASE.MASKS.DDS. md5 identico al de la PRUEBA08",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\ARTHROPODTHORAX01MAT.MATERIAL.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MATERIAL .. [[\ARTHROPODTHORAX01MAT.MATERIAL.MBIN]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA04, 05, 06 y 07, byte a byte - color base BC7 1024 con 11 mips",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\ZOMBIE.BASE.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\ZOMBIE.BASE.DDS]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA04, 05, 06 y 07, byte a byte - normal ATI2 1024 con 11 mips, esculpido en el asset",
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
["MOD_FILENAME"]    = "HT_ZombieMesh_PRUEBA09",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.9.0] M4-ATAQUE: EL TOPE PASA A LEER LOS CUATRO CLIPS, NO SOLO ANDAR Y CORRER. LO QUE MIDIO LA PRUEBA08 EN PARTIDA, el 31/08, en cinco capturas: PASA LA MITAD. Los brazos ya NO hacen cuchillas en ninguna de las cinco, en una anda entero y correcto y la textura sigue sana y seca, asi que el tope de vaiven en 120 es el mecanismo bueno. PERO AHORA ESTIRA LA CABEZA -craneo y cuello disparados en dos capturas- Y LA MITAD DE ABAJO, en cono hacia el suelo. LA CAUSA, MEDIDA EN LOS .ANIM Y NO SUPUESTA: el vaiven se estaba midiendo SOLO sobre arthropodwalk y arthropodrun, y ahi la cabeza vale 21, asi que el tope ni la veia y se quedaba en alfa 1,0. En arthropodattack01 la misma cabeza vale 300. El bicho ataca de frente, que es donde se le mira, y ahi el tope no llegaba. Lo mismo por debajo: la pierna izquierda vale 65 andando y 169 atacando. EL ARREGLO, Y ES UNA REGLA, NO UN NUMERO: cada regla lee sus propios clips. El TOPE mide sobre los CUATRO -walk, run, idle y attack01-, porque un exceso es un exceso en cualquier clip. El ESPEJO se queda en locomocion, porque la asimetria izquierda-derecha de una arana vive ahi y meter attack la taparia; aqui ademas el espejo va apagado, que el ARTHROPOD es simetrico -52,1 y 53,2 grados al correr-. Con eso la cabeza baja de 300 a 120 con un agarre del 60% a spine_C0_0_jnt, la pierna izquierda de 169 a 120 con un 29% a tail_C0_0_jnt, y los brazos aprietan un poco mas -de 428 y 497 a 120, agarre del 72% y 76%-. Y UNA COSA MAS EN LAS HERRAMIENTAS: tail_C0_0_jnt, que es el ancla de la que cuelga la cintura, ESTRENA AGARRE al torso. Sin el no habia forma de toparlo, porque alfas_de solo recorre las regiones que lo tienen; esta vez no le hace falta -mide 106 y el tope esta en 120- pero deja de ser un punto ciego. LO QUE SALE: 2,32 influencias por vertice, 17983 de 17983 vertices con peso, 22982 casados, buffer de 459640 bytes a stride 20, FIRSTSKINMAT 0 a LASTSKINMAT 7, SkinMatrixLayout 2, 3, 7, 19, 25, 37 y 42. Check-NMSGraft en salida 0 con el flag y los tres samplers verificados. Y UN NUMERO QUE EMPEORA Y SE DICE: la asimetria sube a 0,058 contra 0,018 del vanilla -la 08 daba 0,040-, y es el precio de topar la pierna izquierda a 120 mientras la derecha se queda en 86 sin tocar. Si en partida la mitad de abajo sale descuadrada de un lado, el siguiente paso es encender el espejo tambien aqui. LOS OTROS CUATRO MBIN VAN BYTE A BYTE COMO LA PRUEBA08, comprobado por md5 uno a uno: SOLO CAMBIA EL BUFFER DE VERTICES. LA FIRMA, ESCRITA ANTES DE ENTRAR. Si la cabeza deja de dispararse y la mitad de abajo se queda entera, M4-PIEL cierra y el zombie se congela. Si la cabeza se arregla pero abajo sigue el cono, lo que estira no es la pierna sino el ancla y hay que bajar el tope de 120 a los 86 de la pierna derecha. Si el zombie sale tieso de cuello y andar, el tope se paso en la cabeza y hay que subirlo. SUSTITUYE a la PRUEBA01, 02, 03, 04, 05, 06, 07 y 08.",
["ADD_FILES"]       = ENTREGA,
}
