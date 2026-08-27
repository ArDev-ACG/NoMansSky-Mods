RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\models\zombiemesh]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\textures]]

DESTINO_MALLA    = [[MODELS\PLANETS\CREATURES\ARTHROPOD]]
DESTINO_MATERIAL = [[MODELS\PLANETS\CREATURES\ARTHROPOD\BUGFIEND]]
DESTINO_TEXTURA  = [[TEXTURES\PLANETS\CREATURES\ARTHROPOD\THORAX]]

ENTREGA =
{
  {
    ["COMMENT"]              = "El .SCENE vanilla injertado: 53 JOINT y las colisiones intactos, el nodo ArthropodThorax reapuntado a nuestra malla y borrados los otros diez nodos MESH",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.SCENE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.SCENE.MBIN]],
  },
  {
    ["COMMENT"]              = "Nuestra geometria con los cuatro arrays por hueso del vanilla devueltos, 54 entradas para 53 huesos",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.GEOMETRY.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.GEOMETRY.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "El buffer: 8172 vertices a stride 8 y 17997 indices, del zombie de 5999 triangulos",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.GEOMETRY.DATA.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.GEOMETRY.DATA.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "El descriptor recortado a UNA entrada, _Arthropod_1 sin hijos: las otras siete nombraban nodos MESH que el injerto borra",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.DESCRIPTOR.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.DESCRIPTOR.MBIN]],
  },
  {
    ["COMMENT"]              = "ARTHROPODTHORAX01MAT SIN _F02_SKINNED y con el difuso y el normal apuntando a rutas nuevas, para no repintar al resto de la fauna artropodo",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\ARTHROPODTHORAX01MAT.MATERIAL.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MATERIAL .. [[\ARTHROPODTHORAX01MAT.MATERIAL.MBIN]],
  },
  {
    ["COMMENT"]              = "Color base propio del zombie, BC7 1024 con 11 mips, ruta nueva que no pisa ninguna vanilla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\ZOMBIE.BASE.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\ZOMBIE.BASE.DDS]],
  },
  {
    ["COMMENT"]              = "Normal propio del zombie, ATI2 1024 con 11 mips. Este SI viene esculpido en el asset: desviacion 51.8 contra los 17.2 del vanilla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\ZOMBIE.BASE.NORMAL.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\ZOMBIE.BASE.NORMAL.DDS]],
  },
}

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_ZombieMesh_PRUEBA01",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.1.0] Tercera malla propia dentro de una criatura, y la primera fuera del rig SPIDERRIG: un zombie en el cuerpo del BUGFIEND, que es la cria que el Horror pare al rugir en Hardcore. Se pone a la vez que el necromorfo del FIEND para poder mirar los dos al mismo tiempo, y son ranuras distintas asi que conviven. La malla son 5999 triangulos y 8172 vertices exportados, un solo material y sin atlas, porque el asset trae UNA sola textura de color. LA GRAN DIFERENCIA CON LAS DOS RANURAS ANTERIORES es que el BUGFIEND es PROCEDURAL: tiene .DESCRIPTOR propio, once nodos MESH y 53 huesos del rig ARTHROPOD, contra el nodo unico del FIEND. El descriptor resulto ser DETERMINISTA -ocho grupos con una sola opcion cada uno y Chance 0.0- asi que la cria vanilla siempre sale igual, y ademas sus ReferencePaths NO estan vacios: apuntan a ARTHROPOD.SCENE.MBIN, al contrario de los 172 del TREX que si lo estaban. De los ocho, siete nombran nodos MESH que el injerto tiene que borrar, porque nuestro .GEOMETRY trae un solo stream y cualquier nodo de mas se queda indexando uno que no existe, que es como se cierra el juego. Por eso ESTA PRUEBA ENTREGA TAMBIEN EL .DESCRIPTOR, recortado a una unica entrada _Arthropod_1 sin hijos, que es exactamente la forma del descriptor del FIEND: un grupo, una entrada, el nodo que sobrevive. Sin ese recorte el descriptor quedaria nombrando siete nodos que ya no estan. El nodo que se conserva es ArthropodThorax, que NO figura en el descriptor y por tanto siempre esta. Comprobado con tools/Check-NMSGraft.py antes de construir: salida 0, 53 nodos JOINT y 1 nodo MESH, y todos los indices del .SCENE caen dentro del .GEOMETRY. LA MALLA VA RIGIDA A PROPOSITO: ARTHROPODTHORAX01MAT se entrega SIN _F02_SKINNED, igual que la PRUEBA02 del SCUTTLER y la PRUEBA01 del FIEND. Pesar contra el ARTHROPOD es el paso siguiente y va en su propia prueba. La orientacion sale medida del vanilla y no se adivina: las piezas de cabeza del BUGFIEND caen en Z negativa igual que las del FIEND, asi que vale el mismo giro de -90 en X y 180 en Y. La escala es UNIFORME, 2.43 de alto, y sale de una regla y no de un gusto: el necromorfo quedo a 0.727 de la dimension mayor del FIEND vanilla -3.62 sobre 4.98- y la dimension mayor del BUGFIEND es 3.34 de largo, asi que 3.34 por 0.727 da 2.43. Queda claramente mas bajo que el necromorfo de 3.62, que es lo que toca para una cria. La malla se asienta con los pies en Y 0 y centrada en X y en Z. La colision sigue siendo la del vanilla y no se toca, asi que el bicho es mas alto que su caja. LAS TEXTURAS NO PISAN NINGUNA VANILLA: el difuso del torax, ARTHROPODTHORAX01.BASE.DDS, lo comparte toda la fauna artropodo del juego, asi que en vez de sobrescribirlo se apunta el material -que si es exclusivo del BUGFIEND, vive en su propia carpeta- a dos rutas nuevas, ZOMBIE.BASE.DDS y ZOMBIE.BASE.NORMAL.DDS. Las mascaras se quedan las del vanilla. El normal de este asset SI viene esculpido y no hay que fabricarlo desde la luminancia: mide desviacion 51.8 contra los 17.2 del FIEND vanilla. Si sale mal se sabe cual fallo sin volver a entrar: el bicho estirado sin forma es la malla, el bicho bien plantado con el color en el sitio equivocado son las UV, y si el juego se cierra al aparecer la cria es el descriptor y hay que volver a mirar los siete nodos borrados.",
["ADD_FILES"]       = ENTREGA,
}
