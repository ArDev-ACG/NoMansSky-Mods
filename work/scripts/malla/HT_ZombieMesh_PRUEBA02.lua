RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\models\zombiemesh]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\textures]]

DESTINO_MALLA    = [[MODELS\PLANETS\CREATURES\ARTHROPOD]]
DESTINO_MATERIAL = [[MODELS\PLANETS\CREATURES\ARTHROPOD\BUGFIEND]]
DESTINO_TEXTURA  = [[TEXTURES\PLANETS\CREATURES\ARTHROPOD\THORAX]]

ENTREGA =
{
  {
    ["COMMENT"]              = "El .SCENE vanilla injertado otra vez sobre la malla de 36000 triangulos: 53 JOINT y las colisiones intactos, borrados los otros diez nodos MESH",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.SCENE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.SCENE.MBIN]],
  },
  {
    ["COMMENT"]              = "Nuestra geometria con los cuatro arrays por hueso del vanilla devueltos, 54 entradas para 53 huesos",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.GEOMETRY.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.GEOMETRY.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "El buffer: 31475 vertices a stride 8 y 108000 indices, del zombie decimado a 36000 triangulos",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.GEOMETRY.DATA.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.GEOMETRY.DATA.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "El descriptor recortado a UNA entrada, _Arthropod_1 sin hijos: el mismo de la PRUEBA01, no depende de la malla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.DESCRIPTOR.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.DESCRIPTOR.MBIN]],
  },
  {
    ["COMMENT"]              = "ARTHROPODTHORAX01MAT SIN _F02_SKINNED y con el difuso y el normal en rutas nuevas, para no repintar al resto de la fauna artropodo",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\ARTHROPODTHORAX01MAT.MATERIAL.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MATERIAL .. [[\ARTHROPODTHORAX01MAT.MATERIAL.MBIN]],
  },
  {
    ["COMMENT"]              = "El mismo color base de la PRUEBA01, BC7 1024 con 11 mips: la textura no cambia, cambian las UV",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\ZOMBIE.BASE.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\ZOMBIE.BASE.DDS]],
  },
  {
    ["COMMENT"]              = "El mismo normal de la PRUEBA01, ATI2 1024 con 11 mips, y este SI viene esculpido en el asset",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\ZOMBIE.BASE.NORMAL.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\ZOMBIE.BASE.NORMAL.DDS]],
  },
}

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_ZombieMesh_PRUEBA02",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.2.0] El mismo zombie en la cria, el BUGFIEND, con la misma textura: lo unico que cambia es que se conservan 36000 triangulos en vez de 5999. SUSTITUYE a la PRUEBA01, escriben los mismos archivos. Va a la vez que HT_FiendMesh_PRUEBA02, que son ranuras distintas y conviven, para poder mirar los dos de una sola entrada. LO QUE MIDE es lo mismo que en el necromorfo: si el color deja de salir a confeti. El FBX de Meshy son 349911 triangulos y se entregaban 5999, el 1,7 por ciento; ahora se entrega el 10,3 por ciento. La causa esta medida y es de UV, no de eleccion de textura: estos assets vienen horneados POR TRIANGULO, una isla de UV por cara, asi que decimar 58 a 1 deja cada cara superviviente muestreando entre islas que no son la suya. El zombie parte MUCHO menos que el necromorfo -0,87 vertices exportados por triangulo contra 1,92- porque su asset trae UN solo material y un desenvuelto continuo, sin las siete piezas y sin atlas. Por eso aqui caben los 36000 completos: salen 31475 vertices, menos de la mitad del techo. Y hay techo, que es el hallazgo de esta tanda: el .GEOMETRY va con Indices16Bit=1, o sea 65536 vertices como maximo, y NMSDK no lo comprueba -al necromorfo le saco 69261 con la bandera puesta y sin quejarse-. Ahora lo caza tools/Check-NMSGraft.py antes de construir. Del resto no se toca nada: el color base y el normal son los MISMOS archivos de la PRUEBA01 y siguen en rutas nuevas que no pisan ninguna vanilla, porque ARTHROPODTHORAX01.BASE.DDS lo comparte toda la fauna artropodo del juego y lo que se reapunta es el material, que si es exclusivo del BUGFIEND. Las mascaras se quedan las del vanilla. El descriptor recortado a una unica entrada _Arthropod_1 sin hijos es tambien el mismo, porque depende de cuantos nodos MESH sobreviven al injerto y no de cuantos triangulos tienen, y siguen siendo uno: ArthropodThorax. El giro sigue siendo -90 en X y 180 en Y y la escala uniforme de 2.43 de alto. Del injerto salen BATCHCOUNT 108000, VERTRENDGRAPHIC y VERTRENDPHYSICS 31474 y BOUNDHULLED 274, y se borran los otros diez nodos MESH. Check-NMSGraft da salida 0: 53 nodos JOINT, 1 nodo MESH, todos los indices del .SCENE dentro del .GEOMETRY. LA MALLA SIGUE RIGIDA A PROPOSITO, sin _F02_SKINNED: pesarla contra el ARTHROPOD de 53 huesos es M4-PIEL y va despues de esta, porque el pesos.json sale de la geometria. Si sale mal se sabe cual fallo sin volver a entrar: color todavia a confeti = no era el decimado y toca hornear la textura; brillo de baba = el gMasksMap vanilla, que es el M-BABA abierto; y si el juego se cierra al parir el Horror es el descriptor y hay que volver a mirar los diez nodos borrados. CHOCA con HT_ZombieMesh_PRUEBA01.",
["ADD_FILES"]       = ENTREGA,
}
