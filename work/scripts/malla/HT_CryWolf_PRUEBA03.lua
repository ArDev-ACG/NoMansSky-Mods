RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\MODS\NMS_MOD_ZOMBIES\work\models\crywolfmesh_anim]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\MODS\NMS_MOD_ZOMBIES\work\textures]]

DESTINO_MALLA    = [[MODELS\PLANETS\CREATURES\SPIDERRIG]]
DESTINO_MATERIAL = [[MODELS\PLANETS\CREATURES\SPIDERRIG\FIEND]]
DESTINO_TEXTURA  = [[TEXTURES\PLANETS\CREATURES\SPIDERRIG]]

ENTREGA =
{
  {
    ["COMMENT"]              = "El .SCENE vanilla del FIEND injertado con nuestra malla, con FIRSTSKINMAT 0 y LASTSKINMAT 7. Los 44 nodos JOINT, la colision, el ATTACHMENT y el .ENTITY siguen siendo los del juego, y el AttackLight va apagado por el acuerdo A1",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.SCENE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.SCENE.MBIN]],
  },
  {
    ["COMMENT"]              = "VertexLayout a stride 20 con los canales 2, 3, 5 y 6, SkinMatrixLayout de 7 huesos, y los cuatro arrays por hueso devueltos del vanilla por Patch-NMSGraft",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.GEOMETRY.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.GEOMETRY.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "El buffer de vertices: 11100 vertices exportados sobre 9672 de Blender, 513252 bytes, con el indice y el peso de hueso ya cosidos",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.GEOMETRY.DATA.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.GEOMETRY.DATA.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "FIEND_MAT con _F02_SKINNED y los TRES samplers apuntando a rutas propias CRYWOLF",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND_MAT.MATERIAL.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MATERIAL .. [[\FIEND_MAT.MATERIAL.MBIN]],
  },
  {
    ["COMMENT"]              = "Color base BC7 2048 con 12 mips. Atlas de los dos materiales del modelo -Main el cuerpo y SEC las costillas, el ojo y los bigotes- a 1024 cada uno, en 8 de 16 celdas",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\CRYWOLF.BASE.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\CRYWOLF.BASE.DDS]],
  },
  {
    ["COMMENT"]              = "Normal ATI2 2048 con 12 mips, ESCULPIDO EN EL ASSET y no inventado de la luminancia: este modelo si trae normal propio, y se atlasea con el mismo reparto de celdas que el color",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\CRYWOLF.BASE.NORMAL.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\CRYWOLF.BASE.NORMAL.DDS]],
  },
  {
    ["COMMENT"]              = "Mascaras ATI1 2048 sacadas de la RUGOSIDAD REAL del asset e invertidas por el acuerdo B5, porque el asset entrega rugosidad y el shader lee ese canal como brillo. Ni el zombie ni el necromorfo tenian esto: sus mascaras iban planas",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\CRYWOLF.BASE.MASKS.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\CRYWOLF.BASE.MASKS.DDS]],
  },
}

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_CryWolf_PRUEBA03",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.3.0] EL CRY WOLF A 2,85 m, QUE ES x1,5 DE LA PRUEBA01. Mismo caso que HT_WarriorBug_PRUEBA03: la PRUEBA02 lo doblo a 3,80 y en partida salio demasiado grande. El giro de 180 se queda. Texturas, atlas, material e injerto byte a byte los de la PRUEBA01. EL TOPE DE VAIVEN PASA A 170, con la ventana medida a 2,85 m: por debajo de 129 la cabeza -vaiven peor 258- pierde su hueso y la manda NewBack1JNT, que es lo que la PRUEBA01 NO hacia; por encima de 214 las patas delanteras -428- se sueltan del pecho. Y AQUI EL CENTRO DE LA VENTANA NO SE COGE A CIEGAS, SE MIDE: con 200 salia tension 30,3 / 33,2 / 30,8 y costura 45, 49 y 52 cm; con 170 baja a 25,8 / 28,2 / 26,2 y 39, 42 y 46 con el MISMO reparto -RootJNT 42,6% / NewHeadJNT 35,5% / NewBack1JNT 18,3% contra el 45,1 / 35,8 / 19,1 de la PRUEBA01-, 7 huesos y ASIMETRIA 0,000 CONTRA 0,005 DEL VANILLA. ESTE BICHO ABRE MAS COSTURA QUE EL BUG Y NO ES LA ESCALA, Y VA ESCRITO ANTES DE ENTRAR: a 3,80 m abria 45/49/56 y a 2,85 abre 39/42/46, o sea que bajarle un cuarto de tamano casi no lo movio. La PRUEBA01 abria 10/12/13. El sospechoso es el CUELLO LARGO colgando de NewBack1JNT, que es donde el medidor pone la costura en los cuatro clips. El flex se queda entre 3,11 y 5,25, o sea que la piel deforma de sobra. Check-NMSGraft en salida 0 con _F02_SKINNED y los tres samplers verificados. LA FIRMA, ESCRITA ANTES DE ENTRAR. Si sale al tamano bueno y mirando hacia donde anda, entra. Si al andar se le ve ABRIR EL PECHO O LA BASE DEL CUELLO, es la costura de 39-46 cm que esta medida aqui y el arreglo NO es el tope -ya esta en el centro de su ventana- sino partir NewBack1JNT en dos regiones, cuello y pecho. Si se hunde o atraviesa cosas, es la COLISION del vanilla, que no se toca. SUSTITUYE a HT_CryWolf_PRUEBA02, a la 01 y a toda la serie HT_FiendMesh, que escriben los mismos archivos y NO PUEDEN CONVIVIR con esta.",
["ADD_FILES"]       = ENTREGA,
}
