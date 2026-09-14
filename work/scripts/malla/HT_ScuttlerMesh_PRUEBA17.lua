RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\MODS\NMS_MOD_ZOMBIES\work\models\scuttlermesh_anim]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\MODS\NMS_MOD_ZOMBIES\work\textures]]

DESTINO_MALLA    = [[MODELS\PLANETS\CREATURES\SPIDERRIG]]
DESTINO_MATERIAL = [[MODELS\PLANETS\CREATURES\SPIDERRIG\FREIGHTERFIEND]]
DESTINO_TEXTURA  = [[TEXTURES\PLANETS\CREATURES\SPIDERRIG]]
DESTINO_PROC     = [[TEXTURES\COMMON\PLAYER\PLAYERCHARACTER]]

ENTREGA =
{
  {
    ["COMMENT"]              = "M-OJO - el .SCENE de la PRUEBA16 con el AttackLight apagado otra vez: FALLOFF 0, INTENSITY 0, RADIUS 0.0001 y COL 0,0,0",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FREIGHTERFIEND.SCENE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FREIGHTERFIEND.SCENE.MBIN]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA16, byte a byte, verificado con cmp - SkinMatrixLayout de 14 huesos y los cuatro arrays por hueso del vanilla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FREIGHTERFIEND.GEOMETRY.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FREIGHTERFIEND.GEOMETRY.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA16, byte a byte, verificado con cmp - el buffer de 7627 vertices con los canales 5 y 6",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FREIGHTERFIEND.GEOMETRY.DATA.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FREIGHTERFIEND.GEOMETRY.DATA.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA16, byte a byte, verificado con cmp - FFIENDMAT con _F02_SKINNED y el gNormalMap al normal propio",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FFIENDMAT.MATERIAL.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MATERIAL .. [[\FFIENDMAT.MATERIAL.MBIN]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA14, byte a byte, verificado con cmp - color base propio, BC7 2048 con 12 mips",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\SKRULLCRAWLER.BASE.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\SKRULLCRAWLER.BASE.DDS]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA14, byte a byte, verificado con cmp - las mascaras invertidas, con el fondo de UV retenido a 0",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\SKRULLCRAWLER.BASE.MASKS.INV.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\SKRULLCRAWLER.BASE.MASKS.DDS]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA14, byte a byte, verificado con cmp - normal propio, ATI2 2048 con 12 mips",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\SKRULLCRAWLER.BASE.NORMAL.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\SKRULLCRAWLER.BASE.NORMAL.DDS]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA14, byte a byte, verificado con cmp - lista procedural sin capas, que mande el gDiffuseMap",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FREIGHTERFIEND.TEXTURE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_PROC .. [[\FREIGHTERFIEND.TEXTURE.MBIN]],
  },
}

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_ScuttlerMesh_PRUEBA17",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.17.0] M-OJO: devolver el AttackLight a cero. LA MALLA NO SE TOCA. Los dos archivos de geometria salen byte a byte como en la PRUEBA16, verificado con cmp, y las cinco texturas y el material tampoco cambian: LO UNICO QUE CAMBIA SON SEIS FLOTANTES DEL .SCENE. LO QUE PASO, medido el 27/08 sobre los .MBIN de ModBackups: el AttackLight es un punto de luz de 360 grados colgado de la mandibula, amarillo verdoso puro -COL 0.861, 1.0, 0.0- con RADIUS 4.472136 e INTENSITY 1.0. Se apago en la PRUEBA10 y se aprobo apagado en la PRUEBA13, cuyo .MBIN no trae ni la cadena 0.861 ni la 4.472136 y si trae DOS veces el 0.0001 de las dos luces inertes. LA PRUEBA14 LO RESUCITO: reinjerto el nodo de malla SOBRE EL .SCENE VANILLA -eso es literalmente lo que dice su propio COMMENT- y el injerto conserva las luces del vanilla, asi que la neutralizacion, que era un paso a mano, se perdio sin que nadie lo viera. La PRUEBA16 la heredo: su .MBIN trae 0.861 una vez, 4.472136 una vez y el 0.0001 una sola vez. Por eso el Horror vuelve a salir con el ojo encendido. EL ARREGLO NO ES ESTE ARCHIVO, ES QUE NO PUEDA VOLVER A PASAR: tools/Graft-NMSScene.py apaga ahora el AttackLight dentro del propio injerto, con los valores de Light_pointLight1 -la luz inerte que el vanilla ya trae en esa misma escena-, y tools/Check-NMSGraft.py trae un bloque nuevo, ACUERDOS PERDIDOS, que sale con codigo 1 si el AttackLight aparece encendido. Comprobado en los dos sentidos: contra el .SCENE de la PRUEBA16 da 1 y lo nombra, contra este da 0. LOS NUMEROS DE ESTA ENTREGA: .SCENE de 21897 bytes, los mismos que la PRUEBA16; 114 nodos JOINT y 1 nodo MESH; stride 20 con los canales 2,3,5,6; FIRSTSKINMAT 0 -> LASTSKINMAT 14. LA FIRMA, ESCRITA ANTES DE ENTRAR. Si el Horror sale con el ojo apagado y la espalda sigue limpia, M-OJO cierra y la PRUEBA16 queda confirmada entera. Si el ojo sigue brillando, entonces no es el AttackLight y el sospechoso pasa a ser el emisivo horneado en el color base del atlas -Q-GLOW-, que se mide en la textura y no en el .SCENE. Si ademas vuelve la lona de la espalda, el mod no se ha desplegado: mirar la fecha del .MBIN. Sustituye a las PRUEBA01 a 16 y choca con HT_FiendMarkers_PRUEBA04 y con HorribleTerror_NecroSkin.",
["ADD_FILES"]       = ENTREGA,
}
