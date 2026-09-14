RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\MODS\NMS_MOD_ZOMBIES\work\models\fiendmesh]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\MODS\NMS_MOD_ZOMBIES\work\textures]]

DESTINO_MALLA    = [[MODELS\PLANETS\CREATURES\SPIDERRIG]]
DESTINO_MATERIAL = [[MODELS\PLANETS\CREATURES\SPIDERRIG\FIEND]]
DESTINO_TEXTURA  = [[TEXTURES\PLANETS\CREATURES\SPIDERRIG]]

ENTREGA =
{
  {
    ["COMMENT"]              = "El .SCENE vanilla injertado otra vez sobre la malla de 30000 triangulos: 44 JOINT, colisiones, luz y ATTACHMENT intactos",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.SCENE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.SCENE.MBIN]],
  },
  {
    ["COMMENT"]              = "Nuestra geometria con los cuatro arrays por hueso del vanilla devueltos, 45 entradas para 44 huesos",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.GEOMETRY.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.GEOMETRY.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "El buffer: 59384 vertices a stride 8 y 90000 indices, del necromorfo decimado a 30000 triangulos",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.GEOMETRY.DATA.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.GEOMETRY.DATA.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "FIEND_MAT SIN _F02_SKINNED: la malla sigue rigida a proposito, porque todavia no trae los canales 5 y 6",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND_MAT.MATERIAL.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MATERIAL .. [[\FIEND_MAT.MATERIAL.MBIN]],
  },
  {
    ["COMMENT"]              = "El MISMO atlas de la PRUEBA01, identico byte a byte: lo que cambia son las UV, que viven en el .GEOMETRY",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\NECROMORPH.BASE.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\FIEND.BASE.DDS]],
  },
  {
    ["COMMENT"]              = "El mismo normal de la PRUEBA01, ATI2 2048 con 12 mips, fabricado desde la luminancia del atlas",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\NECROMORPH.BASE.NORMAL.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\FIEND.BASE.NORMAL.DDS]],
  },
}

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_FiendMesh_PRUEBA02",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.2.0] La misma malla y la misma textura que la PRUEBA01: lo unico que cambia es CUANTOS TRIANGULOS se conservan, de 5999 a 30000. SUSTITUYE a la PRUEBA01, escriben los mismos archivos. LO QUE MIDE: si el color deja de salir a confeti. En partida el 21/08 la PRUEBA01 entro bien plantada y del tamano correcto, pero con la textura rara, y la causa se midio fuera del juego: el FBX de Tripo son 278381 triangulos y se entregaban 5999, o sea el 2,2 por ciento. Eso normalmente solo baja la silueta, pero estas texturas vienen HORNEADAS POR TRIANGULO -una isla de UV por cara, por eso el atlas se ve a confeti cuando se mira suelto- asi que al colapsar 46 a 1 cada cara superviviente muestrea a caballo entre islas que ya no son la suya. La textura no estaba mal elegida ni mal montada: estaba bien puesta sobre una malla que ya no era la suya. Ahora se conserva el 10,8 por ciento, 30000 triangulos, que ademas es MENOS que los 36590 del FIEND vanilla al que sustituye, asi que no hay ningun argumento de coste. EL NUMERO NO SALE DE UN GUSTO Y TAMPOCO DEL VANILLA: sale del formato. El .GEOMETRY se escribe con Indices16Bit=1, o sea indices de dos bytes y 65536 vertices como techo, y NMSDK NO LO COMPRUEBA. Al probar 36000 triangulos el exportador escupio 69261 vertices con la bandera de 16 bits puesta y sin una sola queja: eso son indices que dan la vuelta, y se habria llevado al juego una malla rota sin que nada avisara. El exportador ademas parte vertices -en este modelo 1,92 exportados por triangulo, porque el horneado por triangulo obliga a partir casi cada esquina- asi que el techo hay que medirlo DESPUES de exportar y no antes. Con 30000 salen 59384 vertices, un 9 por ciento por debajo del techo. Ese fallo ya no puede repetirse en silencio: tools/Check-NMSGraft.py comprueba ahora VertexCount contra el techo de 16 bits y da salida 1, y esta comprobado que salta con el export de 69261. Del resto no se toca nada. El atlas es el MISMO archivo que la PRUEBA01, verificado por md5: el atlas depende de las siete imagenes del asset y de la rejilla, no de la malla, y lo unico que se movio son las UV, que viajan en el .GEOMETRY. El giro sigue siendo -90 en X y 180 en Y, la escala sigue siendo uniforme y sale de la altura del AABB vanilla -3.619638-, y la malla se asienta con los pies en Y 0 y centrada en X y en Z. Del injerto salen BATCHCOUNT 90000, VERTRENDGRAPHIC y VERTRENDPHYSICS 59383 y BOUNDHULLED 211, y se borra el nodo MESH EyeGlow porque nuestro .GEOMETRY trae un solo stream. Check-NMSGraft da salida 0: 44 nodos JOINT, 1 nodo MESH, todos los indices del .SCENE dentro del .GEOMETRY. LA MALLA SIGUE RIGIDA A PROPOSITO, FIEND_MAT va sin _F02_SKINNED: pesarla contra el SPIDERRIG es M3-PIEL y va en su propia prueba, y se hace DESPUES de esta porque el pesos.json sale de la geometria y rehacer la malla obliga a repetir el pesado entero. Si sale mal se sabe cual fallo sin volver a entrar: si el color sigue a confeti no era el decimado y hay que hornear la textura sobre un desenvuelto nuevo; si el bicho sale con brillo de baba es el gMasksMap, que sigue siendo el vanilla y esta pintado para otras UV -es el M-BABA abierto-; y si el relieve sale hundido donde deberia sobresalir es la convencion del canal verde del normal. CHOCA con HorribleTerror_NecroSkin y con HT_FiendMesh_PRUEBA01, que escriben la misma FIEND.BASE.DDS.",
["ADD_FILES"]       = ENTREGA,
}
