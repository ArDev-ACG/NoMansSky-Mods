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
    ["COMMENT"]              = "M3-PIEL - el buffer con el MAPA A MANO al PRIMER eslabon de pata y las cuatro ranuras llenas, 42742 vertices, 1718844 bytes",
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
["MOD_FILENAME"]    = "HT_FiendMesh_PRUEBA05",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.5.0] M3-PIEL: EL ESLABON DE LA PATA, Y LAS CUATRO RANURAS DEL BUFFER. LO QUE MEDIA LA PRUEBA04 EN PARTIDA: la textura sana y sin baba -M-TEX y M-BABA cierran- pero los brazos y las piernas salen estirados en cuchillas de varios metros. LA CAUSA, MEDIDA EN EL .SCENE DEL VANILLA Y NO SUPUESTA. La cadena de pata del SPIDERRIG mide RootJNT -> LFirstLeg1JNT a 0,34 -> Leg2 +0,29 -> Leg3 +0,61 -> Leg4END +0,59. El mapa de la PRUEBA04 colgaba los brazos de *FirstLeg3JNT y las piernas de *FourthLeg3JNT, o sea el TERCER eslabon: esta a 0,90 m pata afuera Y acumula el giro de sus dos padres. Y nuestros brazos estan POR ENCIMA DE TODO EL BICHO VANILLA -su piel cabe en y 0,05 a 0,37 de nuestros 3,62 m-, asi que el brazo de palanca son metros. Giro acumulado por palanca larga es exactamente el estiron, y por eso el cuerpo salia bien y solo se iban las puntas. EL ARREGLO 1: el PRIMER eslabon. L/RFirstLeg1JNT para los brazos y L/RFourthLeg1JNT para las piernas. Leg1 lleva solo su propio giro y su origen apenas se mueve, asi que el miembro entero va RIGIDO con la pata en vez de estirarse detras de ella. Los cuatro estan en el SkinMatrixLayout. EL ARREGLO 2, independiente y gratis: el buffer trae CUATRO huecos de hueso -el canal 5 son 4 bytes de indice y el 6 son 4 half de peso- y nmsskin.canales() ya escribia los cuatro, pero Weight-NMSMesh truncaba a DOS y renormalizaba. O sea que deshacia el suavizado justo donde hacia falta: en la frontera entre regiones, que es el unico sitio donde se juntan 3 o mas huesos. Ahora se guardan las cuatro mayores. LO QUE SALE: 2,10 influencias por vertice contra 1,71 de la PRUEBA04. LFourthLeg1JNT 21,0%, RFourthLeg1JNT 20,5%, RootJNT 18,8%, NewBack1JNT 18,8%, RFirstLeg1JNT 9,9%, LFirstLeg1JNT 9,0%, NewHeadJNT 2,0%. Asimetria 0,014 contra 0,005 del vanilla. El reparto no se separa mas de 5 puntos del que pedia el mapa. 42742 vertices casados sobre los 16048 de Blender, buffer de 854840 bytes a stride 20, FIRSTSKINMAT 0 -> LASTSKINMAT 7. Check-NMSGraft da salida 0. LA FIRMA, ESCRITA ANTES DE ENTRAR. Si los brazos y las piernas ya no se estiran y siguen moviendose, M3-PIEL cierra. Si dejan de estirarse pero el necromorfo va TIESO, el eslabon se ha quedado corto y hay que probar Leg2 -que es el intermedio- en vez de Leg1. Si sigue estirando solo la mano y el pie, lo que falta es SUAVIZADOS, que sigue en 12. Si aparece un estiron NUEVO en el torso, es la frontera de region y no el eslabon. SUSTITUYE a la PRUEBA01, 02, 03 y 04. Choca con HorribleTerror_NecroSkin.",
["ADD_FILES"]       = ENTREGA,
}
