RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\models\zombiemesh_anim]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\textures]]

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
    ["COMMENT"]              = "M4-PIEL - el buffer con el MAPA A MANO al PRIMER eslabon de pata y las cuatro ranuras llenas, 22982 vertices, 1043488 bytes",
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
["MOD_FILENAME"]    = "HT_ZombieMesh_PRUEBA05",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.5.0] M4-PIEL: EL ESLABON DE LA PATA, Y LAS CUATRO RANURAS DEL BUFFER. LO QUE MEDIA LA PRUEBA04 EN PARTIDA: se fue la baba y el zombie sale SECO y se mueve natural -M-BABA cierra- pero la textura se estira: manos y pies en cuchillas y una lamina de torso tirada a un lado. LA CAUSA, MEDIDA EN EL .SCENE DEL VANILLA. La cadena de pata del ARTHROPOD mide spine_C0_0_jnt -> legbase_L0_0_jnt a 0,69 -> leg_0 +0,35 -> leg_1 +0,48 -> leg_2 +0,49. El mapa de la PRUEBA04 colgaba los brazos de leg_*0_1_jnt y las piernas de leg_*2_1_jnt, que es el TERCER eslabon: 0,83 m pata afuera arrastrando el giro de dos padres. Y nuestros brazos estan por encima de todo el bicho vanilla -su piel cabe en y 0,08 a 0,51 de nuestros 2,43 m-. Palanca larga por giro acumulado es el estiron. Es el mismo fallo que el necromorfo, con el otro esqueleto. EL ARREGLO 1: legbase_*, el PRIMER eslabon colgando del cuerpo, que es aqui lo que Leg1JNT es en el SPIDERRIG. legbase_L/R0_0_jnt para los brazos y legbase_L/R2_0_jnt para las piernas. Los cuatro estan en el SkinMatrixLayout. EL ARREGLO 2, independiente y gratis: el buffer trae CUATRO huecos de hueso y nmsskin.canales() ya escribia los cuatro, pero Weight-NMSMesh truncaba a DOS y renormalizaba, deshaciendo el suavizado justo en la frontera entre regiones, que es donde se juntan 3 o mas huesos. Es lo que dejaba la lamina de torso. Ahora se guardan las cuatro mayores. LO QUE SALE: 2,04 influencias por vertice contra 1,81 de la PRUEBA04. tail_C0_0_jnt 24,0%, legbase_R2_0_jnt 19,8%, spine_C0_0_jnt 17,6%, legbase_L2_0_jnt 15,8%, legbase_R0_0_jnt 8,7%, legbase_L0_0_jnt 7,5%, head_C0_0_jnt 6,6%. Asimetria 0,052 contra 0,018 del vanilla, igual que la PRUEBA04: lo que queda es que el zombie esta MODELADO en postura, no simetrico. Vertice medio a 0,577 de su hueso sobre una diagonal de 3,05, contra 0,860 de la PRUEBA04. 22982 vertices casados sobre los 17983 de Blender, buffer de 459640 bytes a stride 20, FIRSTSKINMAT 0 -> LASTSKINMAT 7. Check-NMSGraft da salida 0. LA FIRMA, ESCRITA ANTES DE ENTRAR. Si la textura ya no se estira y el movimiento sigue siendo el de la PRUEBA04, M4-PIEL cierra. Si deja de estirarse pero el zombie va TIESO, el eslabon se ha quedado corto y se prueba leg_*_0_jnt, el siguiente. Si sigue estirando solo la mano y el pie, falta SUAVIZADOS, que sigue en 12. Si la lamina del torso sigue ahi, no eran las ranuras sino la frontera de la region en u 0,74. SUSTITUYE a la PRUEBA01, 02, 03 y 04.",
["ADD_FILES"]       = ENTREGA,
}
