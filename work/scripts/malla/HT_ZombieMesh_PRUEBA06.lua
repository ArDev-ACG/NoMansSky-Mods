RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\MODS\NMS_MOD_ZOMBIES\work\models\zombiemesh_anim]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\MODS\NMS_MOD_ZOMBIES\work\textures]]

DESTINO_MALLA    = [[MODELS\PLANETS\CREATURES\ARTHROPOD]]
DESTINO_MATERIAL = [[MODELS\PLANETS\CREATURES\ARTHROPOD\BUGFIEND]]
DESTINO_TEXTURA  = [[TEXTURES\PLANETS\CREATURES\ARTHROPOD\THORAX]]

ENTREGA =
{
  {
    ["COMMENT"]              = "M4-PIEL - el .SCENE vanilla injertado, con FIRSTSKINMAT 0 y LASTSKINMAT 7",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.SCENE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.SCENE.MBIN]],
  },
  {
    ["COMMENT"]              = "M4-PIEL - VertexLayout a stride 20 con los canales 5 y 6, SkinMatrixLayout de 7 huesos y los cuatro arrays por hueso del vanilla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.GEOMETRY.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.GEOMETRY.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "M4-PIEL - el buffer con el MAPA A MANO al primer eslabon CON CLAVES, leg_*_0_jnt, 22982 vertices, 1043488 bytes",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.GEOMETRY.DATA.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.GEOMETRY.DATA.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA02 - el descriptor recortado a UNA entrada, _Arthropod_1 sin hijos",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.DESCRIPTOR.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.DESCRIPTOR.MBIN]],
  },
  {
    ["COMMENT"]              = "M4-FLAG - ARTHROPODTHORAX01MAT con _F02_SKINNED de vuelta Y el gMasksMap reapuntado a ZOMBIE.BASE.MASKS.DDS. md5 identico al de la PRUEBA04. La PRUEBA05 lo entrego sin el flag y con el gMasksMap devuelto al del ARTHROPOD vanilla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\ARTHROPODTHORAX01MAT.MATERIAL.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MATERIAL .. [[\ARTHROPODTHORAX01MAT.MATERIAL.MBIN]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA04 y la PRUEBA05, byte a byte - color base BC7 1024 con 11 mips",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\ZOMBIE.BASE.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\ZOMBIE.BASE.DDS]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA04 y la PRUEBA05, byte a byte - normal ATI2 1024 con 11 mips, esculpido en el asset",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\ZOMBIE.BASE.NORMAL.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\ZOMBIE.BASE.NORMAL.DDS]],
  },
  {
    ["COMMENT"]              = "M-BABA - mascaras PROPIAS, planas a 87 con el 3.2% de hueco de UV retenido a 0. Va a ruta PROPIA, ZOMBIE.BASE.MASKS.DDS: ARTHROPODTHORAX01.BASE.MASKS.DDS la comparte toda la fauna artropodo del juego",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\ZOMBIE.BASE.MASKS.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\ZOMBIE.BASE.MASKS.DDS]],
  },
}

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_ZombieMesh_PRUEBA06",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.6.0] M4-FLAG: LA PRUEBA05 ENTREGO EL MATERIAL SIN _F02_SKINNED Y CON LAS MASCARAS DEL VANILLA. LO QUE MIDIO LA PRUEBA05 EN PARTIDA: el zombie y el necromorfo salen los dos SIN estirarse y los dos SIN animacion de movimiento, y el zombie ademas se ve PEOR que en la PRUEBA04. LA CAUSA, ENCONTRADA COMPARANDO MD5 CONTRA LA PRUEBA04 DESPLEGADA, y son DOS cosas en el MISMO archivo, el ARTHROPODTHORAX01MAT.MATERIAL.MBIN. UNA: no declara _F02_SKINNED, y sin ese flag el juego NO aplica el esqueleto, o sea que la malla se dibuja SIN PESAR, rigida. Y como no se deforma nada, TAMPOCO SE ESTIRA, que es por lo que parecia que el pesado habia mejorado cuando lo que pasaba es que ya no se pesaba. DOS: el gMasksMap habia vuelto a TEXTURES/.../ARTHROPODTHORAX01.BASE.MASKS.DDS, la mascara que comparte TODA la fauna artropodo del juego, asi que el zombie volvia a salir mojado y nuestro ZOMBIE.BASE.MASKS.DDS se entregaba sin que lo leyera nadie. Eso es M-BABA otra vez, y es exactamente el -se ve peor que la PRUEBA04-. EL PORQUE, que es lo que hay que recordar: Skin-NMSGeometry.py COPIA LA CARPETA DE ORIGEN ENTERA, y en la de origen el .MATERIAL no lleva ni el flag ni el sampler reapuntado, porque los dos son el paso 5 de la receta y se ponen al final, sobre la copia. CADA VEZ QUE SE REHACE LA PIEL SE PIERDEN LOS DOS EN SILENCIO. La PRUEBA04 los llevaba; al recoser para la PRUEBA05 se cayeron, y el COMMENT del .lua seguia diciendo -CON _F02_SKINNED- porque el comentario no se rehace con el archivo. EL ARREGLO: Flag-NMSMaterial.py --poner _F02_SKINNED y Set-NMSSampler.py gMasksMap ZOMBIE.BASE.MASKS.DDS. El material queda md5 IDENTICO al de la PRUEBA04, y las tres texturas ya lo eran. Y APARTE, EL ESLABON, que es un fallo REAL aunque no fuera el que se veia: la PRUEBA05 colgo brazos y piernas de legbase_*, y legbase_* NO TIENE NI UNA CLAVE en ninguno de los cuatro .ANIM del ARTHROPOD -WALK, RUN, IDLE y ATTACK01-. De los 29 huesos a los que el vanilla pega piel, los SEIS legbase_* son los UNICOS quietos, y la PRUEBA05 metio cuatro debajo del 52,2% de la malla. Solo heredan a spine_C0_0_jnt: 4,0 grados de mundo, los mismos que el torso. Con el flag puesto eso habria salido rigido de miembros igual, asi que se arregla ahora y no en otra vuelta: leg_L/R0_0_jnt para los brazos y leg_L/R2_0_jnt para las piernas, el primero CON CLAVES. Giro de mundo promediado sobre walk y run: spine 4,0 -> legbase 4,0 -> leg_0 18-35 -> leg_1 28-36 grados. O sea el movimiento de la PRUEBA04 con menos giro acumulado, que es lo que estiraba. LAS CUATRO RANURAS SE QUEDAN: entre guardar dos y guardar cuatro el reparto cambia 0,1 puntos, medido, asi que nunca fueron ellas. Y las tres texturas van byte a byte como en la PRUEBA04. LO QUE SALE: 2,04 influencias por vertice. tail_C0_0_jnt 24,0%, leg_R2_0_jnt 19,8%, spine_C0_0_jnt 17,6%, leg_L2_0_jnt 15,8%, leg_R0_0_jnt 8,7%, leg_L0_0_jnt 7,5%, head_C0_0_jnt 6,6%. Asimetria 0,052 contra 0,018 del vanilla, igual que la 04 y la 05: lo que queda es que el zombie esta MODELADO en postura. Vertice medio a 0,872 sobre una diagonal de 3,05. 22982 vertices casados sobre los 17983 de Blender, buffer de 459640 bytes a stride 20, paleta 2-3-7-19-25-37-42, FIRSTSKINMAT 0 -> LASTSKINMAT 7. Y QUEDAN DOS GUARDAS NUEVAS, que son lo que habria cortado esto antes de entrar al juego. En Check-NMSGraft.py: lee el .MATERIAL y da salida 1 si falta _F02_SKINNED o si un sampler ha vuelto a la textura compartida del vanilla -comprobado contra la PRUEBA05 desplegada: la caza-. Y en Weight-NMSMesh.py: revienta si el mapa cuelga un MIEMBRO de un hueso sin claves; el tronco si puede, porque hereda al padre. LA FIRMA, ESCRITA ANTES DE ENTRAR. Si el zombie mueve brazos y piernas, sale seco y la piel no se estira, M4-PIEL cierra. Si se mueve y sale seco pero vuelve el estiron, el eslabon se paso y hay que subir SUAVIZADOS, que sigue en 12. Si sigue rigido con el flag puesto, el fallo no esta en el material. SUSTITUYE a la PRUEBA01, 02, 03, 04 y 05.",
["ADD_FILES"]       = ENTREGA,
}
