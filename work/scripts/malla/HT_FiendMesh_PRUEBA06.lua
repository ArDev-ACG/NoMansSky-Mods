RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\models\fiendmesh_anim]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\textures]]

DESTINO_MALLA    = [[MODELS\PLANETS\CREATURES\SPIDERRIG]]
DESTINO_MATERIAL = [[MODELS\PLANETS\CREATURES\SPIDERRIG\FIEND]]
DESTINO_TEXTURA  = [[TEXTURES\PLANETS\CREATURES\SPIDERRIG]]

ENTREGA =
{
  {
    ["COMMENT"]              = "M3-PIEL - el .SCENE vanilla injertado, con FIRSTSKINMAT 0 y LASTSKINMAT 7. Byte a byte como la PRUEBA05",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.SCENE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.SCENE.MBIN]],
  },
  {
    ["COMMENT"]              = "M3-PIEL - VertexLayout a stride 20 con los canales 5 y 6, SkinMatrixLayout de 7 huesos y los cuatro arrays por hueso del vanilla. Byte a byte como la PRUEBA05",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.GEOMETRY.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.GEOMETRY.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "M3-PIEL - el buffer con el MAPA A MANO al PRIMER eslabon de pata y las cuatro ranuras llenas, 42742 vertices, 1718844 bytes. Byte a byte como la PRUEBA05: el pesado NO se toca",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.GEOMETRY.DATA.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.GEOMETRY.DATA.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "M3-FLAG - EL UNICO ARCHIVO QUE CAMBIA. FIEND_MAT con _F02_SKINNED de vuelta, md5 identico al de la PRUEBA04. La PRUEBA05 lo entrego SIN el flag",
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
["MOD_FILENAME"]    = "HT_FiendMesh_PRUEBA06",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.6.0] M3-FLAG: LA PRUEBA05 ENTREGO EL MATERIAL SIN _F02_SKINNED. LO QUE MIDIO LA PRUEBA05 EN PARTIDA: el necromorfo y el zombie salen los dos SIN estirarse y los dos SIN animacion de movimiento, y el zombie ademas con la textura peor que en la PRUEBA04. LA CAUSA, ENCONTRADA COMPARANDO MD5 CONTRA LA PRUEBA04 DESPLEGADA: el FIEND_MAT.MATERIAL.MBIN de la PRUEBA05 NO DECLARA _F02_SKINNED. Sin ese flag el juego NO aplica el esqueleto: la malla se dibuja sin pesar, o sea RIGIDA. Y como no se deforma nada, TAMPOCO SE ESTIRA, que es por lo que parecia que el pesado habia mejorado cuando lo que pasaba es que ya no se pesaba. Las tres cosas medidas en partida salen de este UNICO archivo. EL PORQUE, que es lo que hay que recordar: Skin-NMSGeometry.py COPIA LA CARPETA DE ORIGEN ENTERA, y en la de origen el .MATERIAL no lleva el flag, porque el flag es el paso 5 de la receta y se pone al final, sobre la copia. Asi que CADA VEZ QUE SE REHACE LA PIEL EL FLAG SE PIERDE EN SILENCIO. La PRUEBA04 lo llevaba; al recoser para la PRUEBA05 se cayo, y el COMMENT del .lua seguia diciendo -CON _F02_SKINNED- porque el comentario no se rehace con el archivo. EL ARREGLO: Flag-NMSMaterial.py --poner _F02_SKINNED, y el FIEND_MAT queda md5 IDENTICO al de la PRUEBA04. LOS OTROS SEIS ARCHIVOS VAN BYTE A BYTE COMO LA PRUEBA05 -el .SCENE, los dos de geometria y las tres texturas-, asi que esta entrega mide UNA sola cosa. EL PESADO NO SE TOCA, y ademas queda confirmado por medida: el 29/08 se midieron los tres eslabones de pata contra los .ANIM del SPIDERRIG -FIENDWALK, FIENDRUN, FIENDIDLE y FIENDATTACK- y Leg1 gana o empata en los cuatro miembros: brazo 1,12/0,86 m de desplazamiento contra 1,03/0,99 de Leg2 y 1,11/1,11 de Leg3; pierna 0,84/0,35 contra 1,25/0,39 y 1,43/0,29. Y de los siete huesos de su paleta el UNICO sin claves de animacion es NewBack1JNT, que es el TORSO y esta bien quieto: hereda a RootJNT y un torso no necesita giro propio. Y QUEDA UNA GUARDA NUEVA en Check-NMSGraft.py, que es lo que habria cortado esto antes de entrar al juego: ahora lee el .MATERIAL y da salida 1 si falta _F02_SKINNED o si un sampler ha vuelto a la textura compartida del vanilla. Comprobado contra la PRUEBA05 desplegada: la caza. LA FIRMA, ESCRITA ANTES DE ENTRAR. Si el necromorfo mueve brazos y piernas por su cuenta y la textura sigue sana, M3-PIEL cierra. Si se mueve pero vuelven las cuchillas de varios metros, entonces el estiron de la PRUEBA04 nunca fue el eslabon y hay que subir SUAVIZADOS, que sigue en 12. Si sigue rigido con el flag puesto, el fallo no esta en el material y hay que mirar el buffer desplegado byte a byte. SUSTITUYE a la PRUEBA01, 02, 03, 04 y 05.",
["ADD_FILES"]       = ENTREGA,
}
