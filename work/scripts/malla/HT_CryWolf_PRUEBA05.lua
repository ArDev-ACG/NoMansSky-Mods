RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\models\crywolfmesh_anim]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\textures]]

DESTINO_MALLA    = [[MODELS\PLANETS\CREATURES\SPIDERRIG]]
DESTINO_MATERIAL = [[MODELS\PLANETS\CREATURES\SPIDERRIG\FIEND]]
DESTINO_TEXTURA  = [[TEXTURES\PLANETS\CREATURES\SPIDERRIG]]

ENTREGA =
{
  {
    ["COMMENT"]              = "El .SCENE vanilla del FIEND injertado. Cambia respecto a la PRUEBA04 SOLO en el AABB, porque la malla es otra: los 44 nodos JOINT, la colision, el ATTACHMENT y el .ENTITY siguen siendo los del juego",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.SCENE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.SCENE.MBIN]],
  },
  {
    ["COMMENT"]              = "VertexLayout a stride 20 con los canales 2, 3, 5 y 6, y los cuatro arrays por hueso devueltos del vanilla por Patch-NMSGraft",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.GEOMETRY.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.GEOMETRY.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "El buffer de vertices: 11100 sobre 9672 de Blender. AQUI SI SE MUEVEN VERTICES, y es lo unico que hace esta prueba: el cuello va doblado 30 grados",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.GEOMETRY.DATA.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.GEOMETRY.DATA.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "FIEND_MAT con _F02_SKINNED y los TRES samplers a rutas CRYWOLF, BYTE A BYTE el de la PRUEBA01",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND_MAT.MATERIAL.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MATERIAL .. [[\FIEND_MAT.MATERIAL.MBIN]],
  },
  {
    ["COMMENT"]              = "Color base BC7 2048 con 12 mips, sin tocar desde la PRUEBA01",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\CRYWOLF.BASE.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\CRYWOLF.BASE.DDS]],
  },
  {
    ["COMMENT"]              = "Normal ATI2 2048 con 12 mips, esculpido en el asset, sin tocar desde la PRUEBA01. Las UV no se han movido, asi que sigue cayendo donde tiene que caer",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\CRYWOLF.BASE.NORMAL.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\CRYWOLF.BASE.NORMAL.DDS]],
  },
  {
    ["COMMENT"]              = "Mascaras ATI1 2048 de la rugosidad real del asset, invertidas por el acuerdo B5, sin tocar desde la PRUEBA01",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\CRYWOLF.BASE.MASKS.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\CRYWOLF.BASE.MASKS.DDS]],
  },
}

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_CryWolf_PRUEBA05",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.5.0] EL CRY WOLF CON LA CABEZA LEVANTADA. ESTA PRUEBA SI MUEVE VERTICES, Y REABRE EL MODELO A PETICION EXPRESA DEL 04/09. Las cuatro anteriores tocaron escala, giro, textura y peso de hueso; ninguna toco la forma. Esta dobla el cuello. POR QUE, Y ESTA MEDIDO. La queja era que la cabeza va por delante y parece que le pesa. El 04/09 se descarto que fuera el pesado: se deformo la MISMA malla con los pesos de la PRUEBA03 y con los de la PRUEBA04 usando fiendwalk, mismo fotograma, y los dos renders salen casi iguales. Y el render de la malla SIN ANIMAR ya trae el cuello saliendo hacia delante. O sea que estaba antes del pesado y seguia despues, porque es la POSTURA DE REPOSO DEL ASSET, y ningun reparto de peso la cambia: en la pose de bind la piel devuelve cada vertice a su sitio por construccion, es matematica y no ajuste. LA MEDIDA DEL CUELLO. Sobre la malla ya girada: el cuello arranca en w 0,45 -donde el ancho en x salta de 0,08 a 0,15, o sea donde empieza el pecho- y la cabeza vive en w 0,00 a 0,10. Del arranque a la cabeza SUBE 0,151 y AVANZA 0,213, o sea que el cuello iba a 35 GRADOS SOBRE LA HORIZONTAL. Se dobla 30 grados en X y pasa a 65: la cabeza pasa de 0,213 a 0,109 por delante del arranque, y de 0,151 a 0,238 por encima. EL DOBLEZ NO ES UN GIRO RIGIDO, ES UNA RAMPA. Va en Export-NMSMesh.py, entre el giro y la escala, con un smoothstep que vale 0 en el arranque del cuello y 1 en la cabeza: asi el cuello CURVA y la cabeza gira entera, y la tangente es cero en los dos extremos. Un giro rigido habria dejado un pliegue en la frontera, y un pliegue es geometria: el suavizado de los pesos no lo puede deshacer. Toca 3719 vertices, el 38,5%. DOS EFECTOS SECUNDARIOS, MEDIDOS Y ACEPTADOS. Primero: la caja pasa de 1,356 x 2,85 x 3,102 a 1,199 x 2,85 x 2,292, o sea que el bicho se hace mas compacto, y como el alto sigue clavado en 2,85 m la escala uniforme cae de 5,834 a 5,158: EL CUERPO SALE UN 12% MAS PEQUENO aunque la silueta mida lo mismo de alto. Se acepta porque 2,85 es la altura que ya se acepto en partida; si el bicho se ve pequeno, el arreglo es UN NUMERO -alto 3,22 devuelve el cuerpo a su tamano- y se sabe que 3,80 salio demasiado grande. Segundo: los cortes del mapa de regiones SE RE-MIDEN, porque van en coordenadas normalizadas y esas no cambian con la escala pero SI con la forma. El arranque del cuello baja de w 0,45 a w 0,35. Y EL TOPE SE VUELVE A LEER, Y BAJA DE 140 A 110. Con las aristas un 12% mas cortas la TENSION sube aunque el estiron baje, porque es una razon entre vecinos y la referencia se encogio; el numero que se mira aqui es ABRE, el estiron EN METROS, que es lo que se ve en pantalla. Barrido sobre los NUEVE clips, abre en cm, walk-run-attack-idle-roar-pounce: la PRUEBA04 daba 33-36-41-23-19-33; esta con 170 da 36-35-35-28-28-50; con 140 da 30-28-31-23-23-42; y CON 110 DA 23-25-26-18-20-33, o sea que gana o empata en los seis contra la PRUEBA04. El flex de locomocion se queda en 3,02 y 3,33, MAS SUELTO que el 2,78 y 3,40 de la PRUEBA04, asi que no es la estatua contra la que avisa el guion. La pata delantera izquierda se queda en 0,9x, un 10% menos que la propia piel del vanilla, y se acepta: es el 8,8% de la malla contra la costura, que es lo que se mira. Reparto 7 huesos, 2,71 asignaciones por vertice, ASIMETRIA 0,000 CONTRA 0,005 DEL VANILLA, el reparto no se separa mas de 5 puntos del mapa y Check-NMSGraft en salida 0 con _F02_SKINNED y los tres samplers. LAS TEXTURAS NO SE TOCAN Y NO HACE FALTA: el doblez mueve vertices, no UV. LA FIRMA, ESCRITA ANTES DE ENTRAR. Si el lobo levanta la cabeza y deja de leerse como que le pesa, cierra y el modelo se vuelve a congelar. Si ahora sale DEMASIADO ERGUIDO, tipo llama, el doblez se pasa y el siguiente es 20 grados: es un numero en Export-NMSMesh.py. Si se ve PEQUENO de cuerpo, es el 12% de arriba y se sube alto a 3,22. Si aparece un pliegue en la base del cuello, la rampa se queda corta y hay que abrirla de w 0,15-0,45 a w 0,10-0,55. Y si sigue flotando AL SALTAR, eso no ha cambiado ni podia: pounce sube el bicho 1,40 m y es traslacion del .ANIM del juego. SUSTITUYE a HT_CryWolf_PRUEBA04, a la 03, a la 02, a la 01 y a toda la serie HT_FiendMesh, que escriben los mismos archivos y NO PUEDEN CONVIVIR con esta.",
["ADD_FILES"]       = ENTREGA,
}
