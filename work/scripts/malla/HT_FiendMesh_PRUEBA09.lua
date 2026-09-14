RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\MODS\NMS_MOD_ZOMBIES\work\models\fiendmesh_anim]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\MODS\NMS_MOD_ZOMBIES\work\textures]]

DESTINO_MALLA    = [[MODELS\PLANETS\CREATURES\SPIDERRIG]]
DESTINO_MATERIAL = [[MODELS\PLANETS\CREATURES\SPIDERRIG\FIEND]]
DESTINO_TEXTURA  = [[TEXTURES\PLANETS\CREATURES\SPIDERRIG]]

ENTREGA =
{
  {
    ["COMMENT"]              = "M3-PIEL - el .SCENE vanilla injertado, con FIRSTSKINMAT 0 y LASTSKINMAT 7. md5 identico al de la PRUEBA08",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.SCENE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.SCENE.MBIN]],
  },
  {
    ["COMMENT"]              = "M3-PIEL - VertexLayout a stride 20 con los canales 5 y 6, SkinMatrixLayout de 7 huesos. md5 identico al de la PRUEBA08",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.GEOMETRY.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.GEOMETRY.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "M3-TOPE - EL UNICO ARCHIVO QUE CAMBIA. Mismo mapa y los mismos 42742 vertices y 1718844 bytes que la PRUEBA08; lo que cambia son los PESOS DE LOS BRAZOS: descongelados y topados al vaiven 113 de las piernas, agarre 88% y 82% a NewBack1JNT. Piernas y cabeza como en la PRUEBA08",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.GEOMETRY.DATA.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.GEOMETRY.DATA.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "M3-FLAG - FIEND_MAT con _F02_SKINNED. md5 identico al de la PRUEBA08, la PRUEBA06 y la PRUEBA04",
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
["MOD_FILENAME"]    = "HT_FiendMesh_PRUEBA09",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.9.0] M3-TOPE: LOS BRAZOS DEL NECROMORFO BAJAN AL MISMO VAIVEN QUE LAS PIERNAS. LO QUE MIDIO LA PRUEBA08 EN PARTIDA, el 31/08, en tres capturas: la medida que pedia -si el espejo quita el cizallado de la mitad de abajo- NO SE PUEDE LEER, porque lo que domina las tres imagenes son LOS BRAZOS EN CUCHILLAS y el cuerpo despegado del suelo, que es justo lo que la 08 no tocaba. LA CAUSA, MEDIDA Y NO SUPUESTA: los brazos iban CONGELADOS en el alfa de la PRUEBA07 -0,22 y 0,25-, y ese alfa los dejaba en vaiven 207 y 154, casi el DOBLE de los 113 en los que el espejo dejo las piernas, que son lo unico que en partida se ve bien. El alfa de la 07 se eligio con la PALANCA sola -objetivo 4,0 de palanca-, y la palanca no sabe cuanto gira el hueso: LFirstLeg1JNT amplifica 18,4 veces y gira 51,0 grados al andar, asi que 0,22 de 939 sigue siendo 207. EL ARREGLO, Y ES EL MISMO NUMERO, NO UNO NUEVO: entra el tope global de VAIVEN a 113, que es el valor al que el espejo ya habia bajado las piernas. Con el, el brazo izquierdo pasa de 207 a 113 -agarre del 88% a NewBack1JNT- y el derecho de 154 a 113 -agarre del 82%-. Las piernas se quedan donde estaban, en 113 y 113. LA CABEZA SIGUE CONGELADA en 0,65 y a proposito: en locomocion mide 18 y el tope ni la veria, pero en idle gira 35,2 grados, asi que soltarla seria un estreno sin medir. LOS BRAZOS VAN A SALIR MAS TIESOS QUE EN LA 08, y se entrega sabiendolo: es peticion expresa del 31/08 despues de ver que tiesos-pero-quietos no era lo que pasaba, porque seguian estirando. LO QUE SALE: 2,42 influencias por vertice, 16048 de 16048 vertices con peso, 42742 casados, buffer de 854840 bytes a stride 20, FIRSTSKINMAT 0 a LASTSKINMAT 7. Asimetria 0,017 contra 0,005 del vanilla; costura p99 0,160; el reparto no se separa mas de 5 puntos del mapa; Check-NMSGraft en salida 0 con el flag y los tres samplers verificados. LOS OTROS TRES MBIN VAN BYTE A BYTE COMO LA PRUEBA08, comprobado por md5 uno a uno: SOLO CAMBIA EL BUFFER DE VERTICES. LA FIRMA, ESCRITA ANTES DE ENTRAR. Si los brazos dejan de sacar cuchillas y solo salen tiesos, el tope es la respuesta y lo que quede de estiron es de las piernas o de la cabeza, que se miden ya sin ruido. Si los brazos siguen estirando con vaiven 113, entonces 113 no es el numero y el estiron no es de giro: toca mirar las Translations con Sway-NMSJoint.py. Si sale todo tieso y el bicho se mueve en bloque, el tope se paso y hay que subirlo, no bajarlo. Y si el cuerpo sigue despegandose del suelo con los brazos ya quietos, eso es lo que queda por atacar y es TRASLACION, no giro. SUSTITUYE a la PRUEBA01, 02, 03, 04, 05, 06, 07 y 08.",
["ADD_FILES"]       = ENTREGA,
}
