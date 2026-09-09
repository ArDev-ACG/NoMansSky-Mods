RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\models\warriorbugmesh_anim]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\textures]]

DESTINO_MALLA    = [[MODELS\PLANETS\CREATURES\ARTHROPOD]]
DESTINO_MATERIAL = [[MODELS\PLANETS\CREATURES\ARTHROPOD\BUGFIEND]]
DESTINO_TEXTURA  = [[TEXTURES\PLANETS\CREATURES\ARTHROPOD\THORAX]]

ENTREGA =
{
  {
    ["COMMENT"]              = "El .SCENE vanilla del BUGFIEND injertado, BYTE A BYTE el de la PRUEBA03 y la PRUEBA04",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.SCENE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.SCENE.MBIN]],
  },
  {
    ["COMMENT"]              = "VertexLayout a stride 20, BYTE A BYTE el de la PRUEBA03 y la PRUEBA04",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.GEOMETRY.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.GEOMETRY.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "El buffer de 20257 vertices con sus UV, BYTE A BYTE el de la PRUEBA03 y la PRUEBA04. AQUI SE VE QUE EL ATLAS NUEVO NO MUEVE UNA UV: si las hubiera movido, este archivo cambiaria",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.GEOMETRY.DATA.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.GEOMETRY.DATA.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "El descriptor recortado a UNA entrada, BYTE A BYTE el de la PRUEBA03 y la PRUEBA04",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.DESCRIPTOR.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.DESCRIPTOR.MBIN]],
  },
  {
    ["COMMENT"]              = "ARTHROPODTHORAX01MAT con _F02_SKINNED y los TRES samplers a rutas WARRIORBUG, BYTE A BYTE el de la PRUEBA03 y la PRUEBA04. Las rutas no cambian: cambia lo que hay en ellas",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\ARTHROPODTHORAX01MAT.MATERIAL.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MATERIAL .. [[\ARTHROPODTHORAX01MAT.MATERIAL.MBIN]],
  },
  {
    ["COMMENT"]              = "Color base BC7 4096 con 13 mips, 22,4 MB. Mismas doce celdas y mismas UV que la PRUEBA04; lo que cambia es que cada celda mide 1024 y no 512",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\WARRIORBUG.BASE.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\WARRIORBUG.BASE.DDS]],
  },
  {
    ["COMMENT"]              = "Normal ATI2 4096 con 13 mips, horneado OTRA VEZ del alto poly sobre las mismas UV pero a 4096. Desviacion 17,2 y 17,3 contra los 17,2 y 18,3 del FIEND vanilla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\WARRIORBUG.BASE.NORMAL.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\WARRIORBUG.BASE.NORMAL.DDS]],
  },
  {
    ["COMMENT"]              = "Mascaras ATI1 4096 con 13 mips, sacadas del atlas nuevo. Zona util media 146,1 desviacion 30,6 contra los 146,6 y 30,6 del ARTHROPOD vanilla, igual que en la PRUEBA04",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\WARRIORBUG.BASE.MASKS.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\WARRIORBUG.BASE.MASKS.DDS]],
  },
}

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_WarriorBug_PRUEBA05",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.5.0] EL WARRIOR BUG A x4 DE PIXELES, Y ES LA OTRA MITAD DE Q-TEXBUG. La PRUEBA04 arreglo lo que NO era resolucion -el normal dejo de inventarse de la luminancia y paso a horneado del alto poly, y las mascaras dejaron de ser el numero 87 repetido- y en partida el 03/09 el bicho SE SIGUE VIENDO IGUAL. Queda la causa que la propia firma de la PRUEBA04 dejo apuntada: los pixeles. LA MALLA NO SE TOCA Y LAS UV TAMPOCO. Cinco de los ocho archivos van BYTE A BYTE los de la PRUEBA03 y la PRUEBA04, y entre ellos el BUFFER DE VERTICES, que es donde viven las UV: si el atlas hubiera movido una sola coordenada, ese archivo cambiaria y no cambia. La rejilla del atlas es 4x4 en las dos, las celdas se reparten igual y las coordenadas se calculan en FRACCION del atlas -u 0,00 0,25 0,50 0,75-, asi que subir el atlas no las mueve. EL AGUJERO, MEDIDO Y NO SUPUESTO. El atlas de la PRUEBA04 va a 2048 con celdas de 512 y sus once PNG de origen son de 2048 cada uno, o sea que se tiraban QUINCE DE CADA DIECISEIS PIXELES. Y medido sobre el atlas entregado: 73,4% negro puro, 81,9% por debajo de 6, LA FILA DE ARRIBA -cuatro celdas- COMPLETAMENTE VACIA y la mejor celda al 64,7%. Lo pintado ocupa el 18% de los cuatro millones de pixeles, o sea unos 760 mil texeles para un bicho de 2,70 m: MENOS de los que tiene el ARTHROPOD vanilla en su atlas de 1024, que es al que sustituye. ASI QUE EL BICHO IBA CON MENOS RESOLUCION QUE EL VANILLA, no con mas. QUE CAMBIA: el atlas pasa a 4096 con celdas de 1024, o sea CUATRO VECES los pixeles por trozo y de tirar 15 de cada 16 a tirar 3 de cada 4. Los tres .DDS pasan de 14 MB a 56, que es el precio y va escrito. El normal se vuelve a hornear a 4096 sobre las mismas UV y da desviacion 17,2 y 17,3 con medias 127,9 y 128,0, o sea el mismo relieve que la PRUEBA04 -que daba 20,1 y 20,2 a 2048- pero muestreado fino: no baja porque se aplane, baja porque la misma pendiente repartida entre cuatro veces mas texeles cambia menos de un texel al siguiente. Las mascaras salen del atlas nuevo y miden lo mismo que antes, util 146,1 con desviacion 30,6 contra los 146,6 y 30,6 del vanilla. Make-NMSTexture.py estrena --tamano, que parchea ancho, alto, mips y linearSize de la cabecera copiada del vanilla: formato, flags y bloque DX10 siguen siendo los del juego, y los tres archivos se validan bloque a bloque contra el tamano que exige su cabecera. LO QUE ESTA DESCARTADO Y POR QUE. La otra via de Q-TEXBUG era repacar las islas apretando el 81% vacio, y sale mas cara sin ser mejor: el hueco NO lo crea el atlas, viene dentro de cada PNG de origen, asi que apretarlo exige UV nuevas, y UV nuevas son buffer de vertices nuevo, o sea reabrir la malla que quedo congelada el 03/09. Esto no reabre nada. LA FIRMA, ESCRITA ANTES DE ENTRAR. Si ahora se le leen las escamas y las placas, la resolucion era el techo y Q-TEXBUG cierra en la via (b). Si se ve exactamente igual que la PRUEBA04, LA RESOLUCION NUNCA FUE EL TECHO y la pregunta se cierra al reves: lo que falta no esta en la textura y hay que mirar el material -que sigue siendo el del ARTHROPOD- o la luz. Si mejora solo de cerca y de lejos sigue igual, son los mips y hay que mirar el derrame del fondo. Si el juego tarda mas en cargar o parpadea la textura, son los 56 MB y se vuelve a 2048, que es un solo numero en Atlas-NMSMesh.py. SUSTITUYE a HT_WarriorBug_PRUEBA04, a la 03 y a toda la serie HT_ZombieMesh, que escriben los mismos archivos y NO PUEDEN CONVIVIR con esta.",
["ADD_FILES"]       = ENTREGA,
}
