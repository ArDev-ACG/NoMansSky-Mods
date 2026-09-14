RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\MODS\NMS_MOD_ZOMBIES\work\models\warriorbugmesh_anim]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\MODS\NMS_MOD_ZOMBIES\work\textures]]

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
["MOD_FILENAME"]    = "HT_WarriorBug_PRUEBA03",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.3.0] EL WARRIOR BUG A 2,70 m, QUE ES x1,5 DE LA PRUEBA01. La PRUEBA02 lo doblo a 3,60 a peticion del usuario y EN PARTIDA SALIO DEMASIADO GRANDE; esta se queda a medio camino, tambien elegido en partida y no en la mesa. El giro de 180 de la PRUEBA02 SE QUEDA, que ese si acerto: la PRUEBA01 entraba de espalda. Texturas, atlas, material e injerto van byte a byte los de la PRUEBA01. LO QUE ESTA ENTREGA ANADE AL CONDUCTO ES QUE CAMBIAR `alto` OBLIGA A VOLVER A MEDIR EL TOPE DE VAIVEN, y no es evidente. El mapa a mano de regiones trabaja en coordenadas NORMALIZADAS de nuestra caja, asi que la escala no lo toca; pero el vaiven es giro por PALANCA, y la palanca es la distancia de la region al pivote partida por el tamano de la region. El esqueleto del juego NO crece con nosotros, asi que subir la malla sube la palanca MAS de lo que sube el bicho: la cabeza va 4,4x a 1,80 m, 5,4x a 2,70 y 7,0x a 3,60. Con el tope quieto en 120 y la malla a 3,60 el agarre de la cabeza subia al 76% y spine_C0_0_jnt mandaba el 90,1% contra un tope de 85, o sea que agrandar el bicho sin tocar esto LO DEJA TIESO y ademas rompe el assert. EL TOPE NUEVO ES 300 Y NO SALE A OJO: es una VENTANA que se lee en la columna todos de la propia corrida. A 2,70 la cabeza conserva su hueso por encima de 195 -su vaiven peor es 391- y las patas delanteras se sueltan del torax por encima de 316 -633-. El criterio para elegir dentro de la ventana es reproducir el reparto de la entrega que ya se vio bien: sale spine 76,5% / head 13,6% / tail 9,9% contra el 76,9 / 13,2 / 9,9 de la PRUEBA01, con 7 huesos y ASIMETRIA 0,000 CONTRA 0,018 DEL VANILLA. MEDIDO ANTES DE CONSTRUIR con Pose-NMSMesh.py, que deforma la malla con los .ANIM del juego fuera de la partida: tension 14,4 andando, 26,0 corriendo y 30,9 atacando, contra los 25,9 / 38,7 / 55,3 de la PRUEBA01. La costura abre 9, 18 y 26 cm contra 11, 17 y 28, o sea que el bicho es UNA VEZ Y MEDIA MAS GRANDE Y ABRE LO MISMO O MENOS. El flex se queda entre 1,13 y 2,77: la piel SIGUE DEFORMANDO. Check-NMSGraft en salida 0 con _F02_SKINNED y los tres samplers verificados. LA FIRMA, ESCRITA ANTES DE ENTRAR. Si sale al tamano bueno y mirando hacia donde anda, la serie cierra y solo queda afinar textura. Si a 2,70 se sigue viendo grande, el siguiente paso es 2,20 y NO hace falta tocar nada mas que `alto` y volver a medir la ventana del tope. Si se hunde en el suelo o atraviesa cosas, es la COLISION, que es la del vanilla de 1,05 m y no se toca. SUSTITUYE a HT_WarriorBug_PRUEBA02, a la 01 y a toda la serie HT_ZombieMesh, que escriben los mismos archivos y NO PUEDEN CONVIVIR con esta.",
["ADD_FILES"]       = ENTREGA,
}
