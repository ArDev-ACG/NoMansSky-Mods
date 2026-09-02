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
    ["COMMENT"]              = "Normal ATI2 2048 con 12 mips, sacado de la luminancia del atlas con Make-NMSNormal y con el relieve apagado en el borde de cada isla de UV. El modelo no trae normal propio",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\WARRIORBUG.BASE.NORMAL.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\WARRIORBUG.BASE.NORMAL.DDS]],
  },
  {
    ["COMMENT"]              = "Mascaras ATI1 2048 propias, planas a 87, que es el mismo valor del zombie y del necromorfo y lo que mide el vanilla. El modelo no trae rugosidad propia",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\WARRIORBUG.BASE.MASKS.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\WARRIORBUG.BASE.MASKS.DDS]],
  },
}

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_WarriorBug_PRUEBA01",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.1.0] EL WARRIOR BUG DE STARSHIP TROOPERS SUSTITUYE AL ZOMBIE EN EL BUGFIEND, Y ES UN MOD NUEVO QUE ARRANCA EN 0.1.0 AUNQUE REUTILICE TODO EL CONDUCTO. SE RETIRA EL ZOMBIE: era un bipedo montado en un artropodo y esa era la causa de fondo de sus diez pruebas. El warrior bug es un insecto de cuatro patas con el cuerpo bajo, o sea EL MISMO TIPO DE ANIMAL que el ARTHROPOD de seis patas al que sustituye. LA MALLA: 133108 triangulos decimados a 36000, 18063 vertices en Blender que salen 20257 exportados, las DOCE texturas del modelo fundidas en un atlas de 2048 en 12 de 16 celdas de 512. El .fbx no declara ni una ruta de textura -comprobado buscando cadenas .png en el binario- asi que los doce slots se casaron por nombre, que en ruso describe la parte -telo cuerpo, noga pata, rot boca, usi antena, glaz ojo-, y se comprobo contra el volcado por material y con un render texturizado antes de exportar. LA ALTURA ES 1,80 m Y NO LOS 2,43 DEL ZOMBIE, Y ESE ES EL HALLAZGO DE ESTA ENTREGA. Los acuerdos B1 y B2 subieron las dos mallas viejas al doble o el triple del bicho vanilla porque a su tamano se veian enanas, y el precio no se midio hasta ahora: el esqueleto del ARTHROPOD mide 1,05 m, asi que a 2,43 el 60,7% DE LA MALLA QUEDA POR ENCIMA DEL ULTIMO HUESO y ahi el pesado no encuentra mas que tronco. Con 2,43 spine_C0_0_jnt se llevaba el 43,0% contra un tope de 39,3; a 1,80 el bicho sigue siendo 1,7 VECES el vanilla -grande y bien visible, que era lo que B1 y B2 querian- y el esqueleto cubre el 70% de la malla. LA ORIENTACION SE CORRIGIO Y EL ASSERT DEL PROYECTO NO LA VEIA: el giro en Y pasa de 180 a 0 porque nuestra parte alta caia en w 0,38 y la cabeza del vanilla en w 0,84, o sea el bicho montado mirando hacia atras. El assert de orientacion mide ALTURA -RootJNT por encima de las puntas- y por eso no podia cazarlo. EL PESADO lleva mapa a mano de siete regiones con los cortes sacados del histograma de nuestra propia malla, no supuestos: en la mitad de abajo el eje w tiene dos jorobas, 1353 vertices en w 0,2-0,4 que son las patas traseras y 2107 en w 0,5-0,7 que son las delanteras. Del ARTHROPOD se usan el par de patas 0 y el 2, y el eslabon es leg_*_0_jnt, el primero CON CLAVES: legbase_* esta en la paleta y no tiene ni una, que fue la PRUEBA05 del zombie. SALE CON 7 HUESOS, 2,17 influencias por vertice y ASIMETRIA 0,000 CONTRA 0,018 DEL VANILLA, o sea mejor pareado que el propio bicho del juego. MEDIDO ANTES DE CONSTRUIR con Pose-NMSMesh.py, que deforma la malla con los .ANIM del juego fuera de la partida: el mapa duro sin agarre daba tension 55,1 andando, 81,9 corriendo y 117,4 atacando; con el agarre, el tope de vaiven en 120 y alfa fijo 0,4 en el abdomen y las dos patas traseras queda en 25,9 / 38,7 / 55,3 y la costura abre 11, 17 y 28 cm. El flex se queda entre 1,12 y 3,06, o sea que la piel SIGUE DEFORMANDO y esto no es una estatua. Check-NMSGraft en salida 0 las dos veces, antes y despues del flag, con _F02_SKINNED puesto y los tres samplers verificados. LA FIRMA, ESCRITA ANTES DE ENTRAR. Si el bicho entra bien plantado y se mueve con las patas sin sacar cuchillas, el conducto cierra y solo queda afinar. Si sale estirado, el flag esta y los pesos estan mal y hay que mirar el mapa. Si sale rigido y de una pieza, es el flag y no el mapa. Si sale a remolinos de textura, es el atlas y el casado de los doce slots. SUSTITUYE a toda la serie HT_ZombieMesh, que escribe los mismos archivos y NO PUEDE CONVIVIR con esta.",
["ADD_FILES"]       = ENTREGA,
}
