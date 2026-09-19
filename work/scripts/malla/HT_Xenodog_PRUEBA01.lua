RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\MODS\NMS_MOD_ZOMBIES\work\models\xenodogmesh_anim]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\MODS\NMS_MOD_ZOMBIES\work\textures]]

DESTINO_MALLA    = [[MODELS\PLANETS\CREATURES\SPIDERRIG]]
DESTINO_MATERIAL = [[MODELS\PLANETS\CREATURES\SPIDERRIG\FIEND]]
DESTINO_TEXTURA  = [[TEXTURES\PLANETS\CREATURES\SPIDERRIG]]

ENTREGA =
{
  {
    ["COMMENT"]              = "El .SCENE vanilla del FIEND de 7.0 injertado: el esqueleto de 44 huesos, la colision y los pivotes son los del juego, y lo unico nuestro es el nodo de malla. Plantilla ad96a863591f02d8 sello 07 02, o sea la de la version instalada",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.SCENE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.SCENE.MBIN]],
  },
  {
    ["COMMENT"]              = "Los cuatro arrays por hueso que NMSDK deja vacios, y los 44 JointBindings como la inversa de la pose de mundo del vanilla en fiendattack fotograma 4. Barridos los 277 fotogramas de los cuatro clips: copiar el bind del vanilla tal cual da tension 1 529 y un estiron de 1,91 m; este da 105 y 0,20 m. Comprobado: mundo(f4) * bind da la identidad en los 10 huesos con peso, error 6,3e-11",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.GEOMETRY.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.GEOMETRY.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "El buffer de vertices: 37 355 vertices a stride 16 con sem11, que es el formato de NMS 7.x -con el 20 de 6.45 la malla sale traslucida sin un solo error-. Canales 5 y 6 pesados contra diez huesos, con la cola en NewTail1/3/5JNT",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.GEOMETRY.DATA.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.GEOMETRY.DATA.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "FIEND_MAT del vanilla de 7.0 con _F02_SKINNED y los TRES samplers a rutas XENODOG. Sin el flag el juego no aplica el esqueleto y el bicho sale rigido",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND_MAT.MATERIAL.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MATERIAL .. [[\FIEND_MAT.MATERIAL.MBIN]],
  },
  {
    ["COMMENT"]              = "Color base BC7 2048 con 12 mips, del JPEG del asset",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\XENODOG.BASE.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\XENODOG.BASE.DDS]],
  },
  {
    ["COMMENT"]              = "Normal ATI2 2048 con 12 mips, el del asset. Las UV son las del .glb decimado",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\XENODOG.BASE.NORMAL.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\XENODOG.BASE.NORMAL.DDS]],
  },
  {
    ["COMMENT"]              = "Mascaras ATI1 2048 de la rugosidad del asset, invertidas por el acuerdo B5",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\XENODOG.BASE.MASKS.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\XENODOG.BASE.MASKS.DDS]],
  },
}

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_Xenodog_PRUEBA01",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "7.00",
["MOD_DESCRIPTION"] = "[PRUEBA 0.1.0] EL XENODOG RELEVA AL CRY WOLF EN EL HUECO FIEND, Y LO QUE LO JUSTIFICA ES LA COLA. El FIEND vanilla tiene seis huesos de cola y LOS MUEVE: medido con Sway-NMSJoint sobre los 27 clips, NewTail5JNT da 38,7 grados de giro de mundo en fiendfastwalk y 45,4 en fiendattack, con latigazo creciente hacia la punta. Y EL CRY WOLF NO LO APROVECHA: su mapa de regiones no nombra ni un NewTail JNT, asi que su grupa y su cola caen en el RootJNT del final, que gira 2,4 / 4,1 / 18,9. Por eso va con la cola muerta. Aqui se nombran tres -NewTail1, NewTail3 y NewTail5- y esa es la diferencia visible entre los dos modelos del mismo hueco. LOS CORTES DEL MAPA SE LEYERON, NO SE ELIGIERON. Nuestra caja mide 1,556 x 2,850 x 2,302 m y sus ejes no son los del FIEND: la orientacion se midio por islas de malla -el slab de abajo da cuatro islas, que son los cuatro pies; el de delante una sola, que es el craneo; el de detras otra, que es la punta de la cola-. Los dos cortes duros salen de HUECOS VACIOS: por debajo de w 0,40 la franja central esta vacia, que es donde se separan las patas del vientre, y entre las patas delanteras y las traseras hay una banda con 37 vertices de 12 343. El esqueleto vanilla, metido en esa misma caja, va al reves y de canto, y para eso existe el mapa a mano: lo cruza a proposito. EL BIND, QUE ES LO QUE SE APRENDIO CON EL CRY WOLF. JointBindings es la inversa de la pose de mundo EN QUE SE PESO LA MALLA, no una constante del hueso, y esta malla no esta modelada en la postura del FIEND. Barridos los 277 fotogramas de walk, run, attack e idle: con el bind del vanilla tal cual salen tension 1 529, flex 43,0 y un estiron de 1,91 metros; con --bind fiendattack#4 salen 105, 3,9 y 0,20 m. LO QUE SALE MEDIDO, deformando la malla con los clips del vanilla y sin entrar al juego: abre 0,11 a 0,20 m por clip -el cry wolf congelado va en 0,20- y la punta de la cola, los 1 693 vertices de la region NewTail5JNT, recorre 1,07 m en attack y 0,80 en fastwalk RESPECTO AL CUERPO, o sea descontado el paso. La tension sale en 60..108 y NO es comparable con la del cry wolf: es una razon entre vecinos y esta malla viene decimada 54:1. TODO ESTA CONSTRUIDO CONTRA 7.0. Los cuatro .MBIN llevan el sello 07 02 y el hash de plantilla de la version instalada, y el buffer va a stride 16 con sem11: con el formato de 6.45 la malla se ve traslucida sin que el juego se queje una sola vez. LA FIRMA, ESCRITA ANTES DE ENTRAR. Si el juego cierra poco despues de la pantalla de estrellas, es una plantilla caducada. Si el bicho se ve traslucido, es el stride. Si va RIGIDO, falta _F02_SKINNED. Si va estirado con cuchillas, el flag esta y los pesos estan mal: se baja el objetivo del pesado, hoy en 110. Si se clava en el decorado o queda flotando, es el alto del exportador, que es el fallo abierto que tiene el cry wolf. SUSTITUYE a HT_CryWolf_PRUEBA07 y a toda su serie: escriben los mismos cuatro archivos y NO PUEDEN CONVIVIR.",
["ADD_FILES"]       = ENTREGA,
}
