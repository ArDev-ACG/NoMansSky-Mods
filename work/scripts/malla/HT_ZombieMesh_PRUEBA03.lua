RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\models\zombiemesh_anim]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\textures]]

DESTINO_MALLA    = [[MODELS\PLANETS\CREATURES\ARTHROPOD]]
DESTINO_MATERIAL = [[MODELS\PLANETS\CREATURES\ARTHROPOD\BUGFIEND]]
DESTINO_TEXTURA  = [[TEXTURES\PLANETS\CREATURES\ARTHROPOD\THORAX]]

ENTREGA =
{
  {
    ["COMMENT"]              = "M4-PIEL - el .SCENE vanilla injertado, con FIRSTSKINMAT 0 y LASTSKINMAT 12",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.SCENE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.SCENE.MBIN]],
  },
  {
    ["COMMENT"]              = "M4-PIEL - VertexLayout a stride 20 con los canales 5 y 6, SkinMatrixLayout de 12 huesos y los cuatro arrays por hueso del vanilla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.GEOMETRY.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.GEOMETRY.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "M4-PIEL - el buffer de 22982 vertices con indice de hueso y peso, 1043488 bytes",
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
["MOD_FILENAME"]    = "HT_ZombieMesh_PRUEBA03",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.3.0] M4-PIEL: el zombie deja de ir rigido. Es la PRUEBA02 con la piel puesta y con mascaras propias. LO QUE LO DESBLOQUEA, y era el paso 1 de la receta: del BUGFIEND vanilla solo estaban los .MXML y el .SCENE, y NMSDK abre por su cuenta el .GEOMETRY.MBIN.PC y el .GEOMETRY.DATA.MBIN.PC. Sacados el 27/08 con hgpaktool -U -f *BUGFIEND* sobre los 97 .pak. DESPUES APARECIERON DOS FALLOS MAS, los dos del importador y los dos medidos: tools/Weight-NMSMesh.py cogia la PRIMERA malla del vanilla con grupos de vertices, y el BUGFIEND trae ONCE -la primera es FiendButt, 746 vertices de 26299 pegados a tail_C0_0 y tail_C0_1 y a nada mas-, asi que el zombie se pesaba contra el culo del bicho: el 86,0% colgaba de la cola y hasta la caja envolvente salia mal, escala 1,7486. Y el importador de NMSDK ABORTABA la escena en el primer material roto -realize_path devuelve None y create_material_node hace op.join con ese None-, que es exactamente por lo que solo entraba FiendButt. Con las dos cosas arregladas entran las once mallas y los 26299 vertices, y la distancia del vertice medio a su hueso baja de 2,479 a 0,578 sobre una diagonal de 3,05. Y LA ESCALA VA A 1.0, no a la que llena nuestra malla: los JointBindings se copian del vanilla en Patch-NMSGraft.py, asi que en partida nuestros vertices se leen en el espacio del vanilla SIN reescalar, y casar contra un rig hinchado es casar contra huesos que en partida estan en otro sitio. LO QUE SALE: 22982 vertices casados sobre los 17983 de Blender, paleta de 12 huesos de 53, buffer de 1043488 bytes a stride 20, FIRSTSKINMAT 0 -> LASTSKINMAT 12, 2,00 influencias por vertice. Reparto: spine_C0_0_jnt 80,1%, legbase_R2_0_jnt 4,8%, legbase_L0_0_jnt 4,7%, leg_R2_0_jnt 4,1%, tail_C0_0_jnt 3,3%. Asimetria 0,091 contra 0,018 del vanilla. Check-NMSGraft da salida 0: 53 nodos JOINT, 1 nodo MESH, stride 20 con los canales 2,3,5,6. EL 80,1% ESTA ACEPTADO Y NO ES EL FALLO DEL 15/08: aquel dejaba el TRONCO al 0,4% con una punta de pata al 43,2%; aqui el tronco se lo lleva todo y ninguna punta pasa del 5%. Un bipedo cuelga de la columna y una arana no -el ARTHROPOD pone su maximo en head_C0_0_jnt con el 31,4%-, asi que el tope relativo contra el vanilla no lo puede pasar ni un pesado bueno y este modelo lleva tope ABSOLUTO del 85%; los otros tres asserts siguen midiendo contra el vanilla. LAS MASCARAS, que es la segunda mitad de M-BABA: en las capturas del 22/08 el zombie salia MOJADO porque llevaba el gMasksMap del ARTHROPOD vanilla cayendo en NUESTRAS UV. Ahora lleva uno PROPIO y PLANO a 87, que es la media util del gMasksMap vanilla medida el 22/08, con el 3,2% de hueco de UV retenido a 0, y va a ruta propia -ZOMBIE.BASE.MASKS.DDS- porque ARTHROPODTHORAX01.BASE.MASKS.DDS la comparte toda la fauna artropodo del juego. Plano y no del roughness porque el asset de Meshy no trae roughness. El color base y el normal van byte a byte como en la PRUEBA02. LA FIRMA, ESCRITA ANTES DE ENTRAR. Si el zombie se mueve y ya no se ve mojado, M4-PIEL cierra y con el M-BABA entero. Si se estira sin forma o el juego se cierra al parir el Horror, son los pesos o el descriptor. Si se mueve solo de bloque, sin que los miembros hagan nada, el 80,1% de spine_C0_0_jnt es demasiado y lo que falta es un mapa a mano de region nuestra -> hueso vanilla. Si sigue mojado, el canal no era brillo y hay que ir al material. SUSTITUYE a la PRUEBA01 y la PRUEBA02.",
["ADD_FILES"]       = ENTREGA,
}
