RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\MODS\NMS_MOD_ZOMBIES\work\models\fiendmesh]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\MODS\NMS_MOD_ZOMBIES\work\textures]]

DESTINO_MALLA    = [[MODELS\PLANETS\CREATURES\SPIDERRIG]]
DESTINO_MATERIAL = [[MODELS\PLANETS\CREATURES\SPIDERRIG\FIEND]]
DESTINO_TEXTURA  = [[TEXTURES\PLANETS\CREATURES\SPIDERRIG]]

ENTREGA =
{
  {
    ["COMMENT"]              = "El .SCENE vanilla injertado: 44 JOINT, colisiones, luz y ATTACHMENT intactos; el nodo _Fiend_Body reapuntado a nuestra malla y borrados SUB1_Fiend_Body y EyeGlow",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.SCENE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.SCENE.MBIN]],
  },
  {
    ["COMMENT"]              = "Nuestra geometria con los cuatro arrays por hueso del vanilla devueltos y MeshBaseSkinMat de una malla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.GEOMETRY.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.GEOMETRY.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "El buffer: 14233 vertices a stride 8 y 17997 indices, del necromorfo decimado a 5999 triangulos",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.GEOMETRY.DATA.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.GEOMETRY.DATA.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "FIEND_MAT SIN _F02_SKINNED: la malla va rigida a proposito, porque todavia no trae los canales 5 y 6",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND_MAT.MATERIAL.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MATERIAL .. [[\FIEND_MAT.MATERIAL.MBIN]],
  },
  {
    ["COMMENT"]              = "Color base propio: atlas 2048 BC7 con 12 mips, las siete texturas del asset en una rejilla de 4x4",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\NECROMORPH.BASE.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\FIEND.BASE.DDS]],
  },
  {
    ["COMMENT"]              = "Normal propio, ATI2 2048 con 12 mips, fabricado desde la luminancia del atlas",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\NECROMORPH.BASE.NORMAL.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\FIEND.BASE.NORMAL.DDS]],
  },
}

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_FiendMesh_PRUEBA01",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.1.0] Segunda malla propia dentro de una criatura, y la primera en el Horror de superficie. Sustituye el cuerpo del FIEND -que es tambien el del MINIFIEND, porque CREATUREFILENAMETABLE manda los dos al mismo modelo- por un necromorfo de Tripo. El .SCENE es el vanilla injertado, asi que se conservan los 44 nodos JOINT con sus animaciones, las seis colisiones, la luz, el ATTACHMENT con la _FIEND_BODY.ENTITY y el material: el bicho sigue apareciendo, andando, atacando y sonando igual, y lo unico que cambia es de que vertices esta hecho. Del nodo de malla se reescriben diecisiete atributos, y la regla resulto ser que son los arrays POR MALLA del .GEOMETRY dichos otra vez: BATCHCOUNT de 109770 a 17997, VERTRENDGRAPHIC y VERTRENDPHYSICS de 20508 y 22212 a 14232, BOUNDHULLST y BOUNDHULLED de 288 y 331 a 0 y 94, y el AABB entero. Se borran los otros dos nodos MESH, SUB1_Fiend_Body y EyeGlow, porque nuestro .GEOMETRY trae un solo stream y esos dos se quedarian indexando uno que no existe, que es exactamente como se cierra el juego. Los cuatro arrays por hueso -JointBindings, JointExtents, JointMirrorAxes y JointMirrorPairs, 45 entradas para 44 huesos- se devuelven del vanilla con tools/Patch-NMSGraft.py, porque NMSDK los deja vacios y el ragdoll sigue leyendolos. Comprobado con tools/Check-NMSGraft.py antes de construir: salida 0, todos los indices del .SCENE caen dentro del .GEOMETRY. LA MALLA VA RIGIDA A PROPOSITO. FIEND_MAT se entrega SIN _F02_SKINNED, que es el paso equivalente a la PRUEBA02 del SCUTTLER: con el flag puesto y sin los canales 5 y 6 en el buffer el juego aplica el esqueleto a unos vertices que no dicen de que hueso cuelgan, y el bicho se estira sin forma. Pesar contra el SPIDERRIG es el paso siguiente y va en su propia prueba. La geometria son 5999 triangulos y 14233 vertices exportados, contra los 36590 y 20508 del vanilla. La orientacion no se adivino: el AABB del FIEND va de -1.405 a +3.573 en Z, y al importarlo con NMSDK la caja sale de -3.572 a +1.405 en Y de Blender con la cabeza en +Y, o sea que la cabeza vanilla mira a -Z; el necromorfo tras girar -90 en X miraba a +Z, asi que lleva ademas 180 en Y. La escala es UNIFORME y sale de la altura, 1.8105, que deja el bicho en los 1.809819 exactos del AABB vanilla, y la malla se asienta con los pies en Y 0 y centrada en X y en Z, porque salia centrada en el origen con los pies en -0.94. Queda mas estrecha y mas corta que el vanilla -1.29 por 1.11 contra 2.65 por 4.98- porque es un humanoide de pie donde habia una araña despatarrada, y la colision sigue siendo la del vanilla. LA SEGUNDA COSA QUE MIDE ESTA PRUEBA son las texturas. El asset viene en 22 piezas con SIETE colores base distintos y NMSDK solo exporta el primer slot de material de cada objeto, asi que las siete se funden en un atlas de 2048x2048 con tools/Atlas-NMSMesh.py -rejilla de 4x4 celdas de 512, las dos texturas de 1024 en bloques de 2x2 a resolucion nativa, 13 de las 16 celdas usadas- y las UV de cada pieza se mueven a su celda. El atlas se comprobo contra las fuentes desde fuera de Blender: identico byte a byte, sin desvio de gamma y sin volteo. El normal sale de la luminancia del atlas, porque el asset no trae ninguno. Las mascaras se quedan las del vanilla, que estan pintadas para otras UV: el asset tampoco trae rugosidad y esa decision va aparte. Si sale mal se sabe cual fallo sin volver a entrar: el bicho estirado sin forma es la malla, el bicho bien plantado con los colores en el sitio equivocado es el atlas, y el relieve hundido donde deberia sobresalir es la convencion del canal verde, que se arregla regenerando con --invertir-y. CHOCA con HorribleTerror_NecroSkin, que escribe la misma FIEND.BASE.DDS.",
["ADD_FILES"]       = ENTREGA,
}
