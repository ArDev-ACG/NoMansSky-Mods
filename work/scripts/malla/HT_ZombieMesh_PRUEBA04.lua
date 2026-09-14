RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\MODS\NMS_MOD_ZOMBIES\work\models\zombiemesh_anim]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\MODS\NMS_MOD_ZOMBIES\work\textures]]

DESTINO_MALLA    = [[MODELS\PLANETS\CREATURES\ARTHROPOD]]
DESTINO_MATERIAL = [[MODELS\PLANETS\CREATURES\ARTHROPOD\BUGFIEND]]
DESTINO_TEXTURA  = [[TEXTURES\PLANETS\CREATURES\ARTHROPOD\THORAX]]

ENTREGA =
{
  {
    ["COMMENT"]              = "M4-PIEL - el .SCENE vanilla injertado, con FIRSTSKINMAT 0 y LASTSKINMAT 7",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.SCENE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.SCENE.MBIN]],
  },
  {
    ["COMMENT"]              = "M4-PIEL - VertexLayout a stride 20 con los canales 5 y 6, SkinMatrixLayout de 7 huesos y los cuatro arrays por hueso del vanilla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.GEOMETRY.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.GEOMETRY.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "M4-PIEL - el buffer con el MAPA A MANO, de 22982 vertices con indice de hueso y peso, 1043488 bytes",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.GEOMETRY.DATA.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.GEOMETRY.DATA.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA02 - el descriptor recortado a UNA entrada, _Arthropod_1 sin hijos",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.DESCRIPTOR.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.DESCRIPTOR.MBIN]],
  },
  {
    ["COMMENT"]              = "M4-PIEL - ARTHROPODTHORAX01MAT CON _F02_SKINNED, y el difuso, el normal y las mascaras en rutas propias",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\ARTHROPODTHORAX01MAT.MATERIAL.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MATERIAL .. [[\ARTHROPODTHORAX01MAT.MATERIAL.MBIN]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA02, byte a byte - color base BC7 1024 con 11 mips",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\ZOMBIE.BASE.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\ZOMBIE.BASE.DDS]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA02, byte a byte - normal ATI2 1024 con 11 mips, esculpido en el asset",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\ZOMBIE.BASE.NORMAL.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\ZOMBIE.BASE.NORMAL.DDS]],
  },
  {
    ["COMMENT"]              = "M-BABA - mascaras PROPIAS, planas a 87 con el 3.2% de hueco de UV retenido a 0. Antes caian las del ARTHROPOD vanilla y el zombie salia mojado. Va a ruta PROPIA, ZOMBIE.BASE.MASKS.DDS: ARTHROPODTHORAX01.BASE.MASKS.DDS la comparte toda la fauna artropodo del juego",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\ZOMBIE.BASE.MASKS.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\ZOMBIE.BASE.MASKS.DDS]],
  },
}

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_ZombieMesh_PRUEBA04",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.4.0] M4-PIEL con MAPA A MANO. Es la PRUEBA03 con el buffer de pesos rehecho y nada mas: las tres texturas y el material van igual. LO QUE MEDIA LA PRUEBA03: spine_C0_0_jnt se llevaba el 80,1%, o sea el zombie moviendose de BLOQUE. La causa, medida con el volcado nuevo -tools/Weight-NMSMesh.py --volcar-huesos-: LA PIEL DEL ARTHROPOD CABE EN LA MITAD DE ABAJO DE NUESTRA MALLA, y de 0,08 a 0,51 sobre 2,43 m. Nuestros brazos y nuestra cabeza no tienen cerca mas que cuerpo de arana. Copiar del vecino mas cercano vale entre dos bichos del mismo tipo y esto es un BIPEDO montado en una arana de ocho patas. EL MAPA, leido del mismo volcado, donde las tres parejas de patas se ordenan por z -leg_*0_* delante en z 1,07-1,33, leg_*1_* en medio en 0,69 y leg_*2_* detras en 0,00-0,33- y los L caen en x>0,5: cabeza por encima de 0,86 -> head_C0_0_jnt; por encima de 0,55 y a los lados -> leg_L/R0_1_jnt, o sea las patas DELANTERAS de brazos; el resto por encima de 0,55 -> spine_C0_0_jnt; por debajo de 0,40 -> leg_L/R2_1_jnt, las patas TRASERAS de piernas; y lo que quede -> tail_C0_0_jnt, que es el abdomen y va en el eje, x 0,50. LO QUE SALE: 7 huesos con peso y el mayor baja del 80,1% al 23,7%. tail_C0_0_jnt 23,7%, leg_R2_1_jnt 20,2%, spine_C0_0_jnt 17,5%, leg_L2_1_jnt 15,7%, leg_R0_1_jnt 8,8%, leg_L0_1_jnt 7,5%, head_C0_0_jnt 6,6%. Asimetria 0,052 contra 0,018 del vanilla -era 0,092 con las bandas de brazo anchas; estrecharlas a 0,74 la baja a la mitad, y lo que queda es que el zombie esta MODELADO en postura, no simetrico-. 1,81 influencias por vertice, vertice medio a 0,860 de su hueso sobre una diagonal de 3,05. 22982 vertices casados sobre los 17983 de Blender, buffer de 459640 bytes a stride 20, FIRSTSKINMAT 0 -> LASTSKINMAT 7. Check-NMSGraft da salida 0. Y UNA COSA MAS QUE SE CORRIGE: tail_C0_* cuenta como TRONCO y no como punta de miembro. Es el abdomen del artropodo y el volcado lo pone en el eje; contarlo como punta dejaba el tronco en el 15,1% y saltaba el assert por una razon falsa. Con el abdomen dentro, el tronco son 41,2%. LA FIRMA, ESCRITA ANTES DE ENTRAR. Si el zombie mueve brazos y piernas por separado y ya no se ve mojado, M4-PIEL cierra y con el M-BABA entero. Si los brazos van con las piernas, el mapa tiene los lados cruzados y se cambian L por R en las dos filas de leg_*0_1. Si un trozo sale disparado, hay que subir SUAVIZADOS. Si el juego cierra al parir el Horror, es el descriptor. SUSTITUYE a la PRUEBA01, 02 y 03.",
["ADD_FILES"]       = ENTREGA,
}
