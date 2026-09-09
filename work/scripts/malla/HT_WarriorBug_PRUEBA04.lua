RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\models\warriorbugmesh_anim]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\textures]]

DESTINO_MALLA    = [[MODELS\PLANETS\CREATURES\ARTHROPOD]]
DESTINO_MATERIAL = [[MODELS\PLANETS\CREATURES\ARTHROPOD\BUGFIEND]]
DESTINO_TEXTURA  = [[TEXTURES\PLANETS\CREATURES\ARTHROPOD\THORAX]]

ENTREGA =
{
  {
    ["COMMENT"]              = "El .SCENE vanilla del BUGFIEND injertado con nuestra malla, con FIRSTSKINMAT 0 y LASTSKINMAT 7. Los 53 nodos JOINT, la colision, el ATTACHMENT y el .ENTITY siguen siendo los del juego: lo unico que cambia es de que vertices esta hecho el bicho",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.SCENE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.SCENE.MBIN]],
  },
  {
    ["COMMENT"]              = "VertexLayout a stride 20 con los canales 2, 3, 5 y 6, SkinMatrixLayout de 7 huesos, y los cuatro arrays por hueso devueltos del vanilla por Patch-NMSGraft",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.GEOMETRY.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.GEOMETRY.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "El buffer de vertices: 20257 vertices exportados sobre 18063 de Blender, 945388 bytes, con el indice y el peso de hueso ya cosidos",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.GEOMETRY.DATA.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.GEOMETRY.DATA.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "El descriptor recortado a UNA entrada, _Arthropod_1 sin hijos, igual que en la serie del zombie. Con los nodos MESH borrados por el injerto, el descriptor completo cierra el juego al parir el Horror",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.DESCRIPTOR.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.DESCRIPTOR.MBIN]],
  },
  {
    ["COMMENT"]              = "ARTHROPODTHORAX01MAT con _F02_SKINNED y los TRES samplers apuntando a rutas propias WARRIORBUG. Las ARTHROPODTHORAX01.BASE*.DDS las comparte toda la fauna artropodo del juego",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\ARTHROPODTHORAX01MAT.MATERIAL.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MATERIAL .. [[\ARTHROPODTHORAX01MAT.MATERIAL.MBIN]],
  },
  {
    ["COMMENT"]              = "Color base BC7 2048 con 12 mips. Atlas de las DOCE texturas del modelo en 12 de 16 celdas de 512. Va a 2048 y no a los 1024 del ARTHROPOD vanilla porque doce trozos en 1024 dejarian 256 pixeles por pieza",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\WARRIORBUG.BASE.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\WARRIORBUG.BASE.DDS]],
  },
  {
    ["COMMENT"]              = "Normal ATI2 2048 con 12 mips, HORNEADO DE LA MALLA ALTA de 133108 triangulos sobre las UV de la nuestra de 36000, con Bake-NMSNormal.py. Desviacion 20,1 y 20,2 contra los 17,2 y 18,3 del FIEND vanilla; el generado de la luminancia que llevaba la PRUEBA03 daba 2,3 y 3,6, o sea un mapa casi en blanco",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\WARRIORBUG.BASE.NORMAL.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\WARRIORBUG.BASE.NORMAL.DDS]],
  },
  {
    ["COMMENT"]              = "Mascaras ATI1 2048 sacadas de la luminancia del atlas con Make-NMSMasks.py y centradas en la media del ARTHROPOD vanilla. Zona util media 146,1 con desviacion 30,6 contra los 146,6 y 30,6 del vanilla; la PRUEBA03 iba a 87 PLANO, desviacion 0,0, que es lo que se ve como plastico. El modelo no trae rugosidad propia",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\WARRIORBUG.BASE.MASKS.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\WARRIORBUG.BASE.MASKS.DDS]],
  },
}

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_WarriorBug_PRUEBA04",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.4.0] EL WARRIOR BUG, MISMA MALLA Y OTRA PIEL. LA GEOMETRIA NO SE TOCA: el .SCENE, los dos .GEOMETRY, el .DESCRIPTOR, el .MATERIAL y el color base van BYTE A BYTE los de la PRUEBA03, que quedo cerrada el 03/09. Cambian DOS archivos, el normal y las mascaras, y los dos por el mismo sintoma: el bicho se veia PLANO Y DE PLASTICO. LAS DOS CAUSAS ESTAN MEDIDAS Y SON DISTINTAS. El normal daba desviacion 2,3 y 3,6 contra los 17,2 y 18,3 del FIEND vanilla, o sea SIETE VECES MAS LISO: estaba sacado de la luminancia del atlas de color con Make-NMSNormal.py, y las doce texturas de este asset vienen pintadas muy planas, asi que no habia de donde sacar relieve. Y las mascaras tenian DESVIACION 0,0: eran el numero 87 repetido en los cuatro millones de pixeles. Un brillo identico en todo el cuerpo es exactamente lo que el ojo lee como plastico; el ARTHROPOD vanilla mide 146,6 con desviacion 30,6. Encima el 87 se habia copiado del FIEND, que es el vanilla del OTRO bicho. EL NORMAL YA NO SE INVENTA, SE HORNEA DE LA GEOMETRIA QUE SE TIRO AL DECIMAR. El asset entra con 133108 triangulos y el juego se lleva 36000, o sea que tres cuartas partes de la forma estaban esperando en el .fbx. Bake-NMSNormal.py -guion nuevo- las hornea sobre las UV de nuestra malla: sale desviacion 20,1 y 20,2 con la media en 128,6 y 128,5, que es donde tiene que estar el plano. NO se sube --fuerza al mapa viejo a proposito: multiplicar por siete un relieve sacado de la pintura convierte cada linea pintada en un bulto, y eso es el efecto baba que ya costo la PRUEBA12 del SkrullCrawler. DOS TRAMPAS NUEVAS, LAS DOS MEDIDAS Y LAS DOS DENTRO DEL GUION. La malla alta importa del .fbx en OTRO SITIO que la baja -mismas medidas hasta el milimetro, separadas 4,556-, porque Decimate-NMSMesh.py asienta la malla y el .fbx sigue en su origen: se alinean por el centro de la caja antes de hornear. Y el PNG horneado sale con la media en 187,6 en vez de 128 si la imagen se queda en sRGB, porque un normal NO es color y guardarlo con la curva mueve el plano fuera del centro: la imagen se marca Non-Color. LAS MASCARAS SE SACAN DE LA LUMINANCIA DEL COLOR, y es una aproximacion elegida a sabiendas: en un modelo pintado las grietas van oscuras y son mates y los bultos van claros y brillan. Zona util media 146,1 y desviacion 30,6 contra los 146,6 y 30,6 del vanilla. Y el 81,3% del atlas que es fondo sin usar SE QUEDA A 0 y se derrama despues con --rellenar, que es la trampa que el --invertir del conversor le hizo al cry wolf: le dejo el 50,1% de su atlas a 255, o sea a brillo maximo sangrando por los mips. LA FIRMA, ESCRITA ANTES DE ENTRAR. Si el bicho deja de verse de plastico y se le ven grietas y placas, entran los dos archivos y la piel del bug cierra. Si sigue plano pero ya no plastico, el que falta es el normal y hay que mirar si el atlas tiene resolucion para enseñarlo -ver Q-TEXBUG: sus once PNG de origen son de 2048 y el atlas los guarda a 512-. Si sale con bultos que siguen el dibujo, es que el horneado no cogio la malla alta. Si sale brillante a manchas, es el reparto de la mascara y se baja la desviacion. SUSTITUYE a HT_WarriorBug_PRUEBA03 y a toda la serie HT_ZombieMesh, que escriben los mismos archivos y NO PUEDEN CONVIVIR con esta.",
["ADD_FILES"]       = ENTREGA,
}
