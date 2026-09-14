RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\MODS\NMS_MOD_ZOMBIES\work\models\zombiemesh_anim]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\MODS\NMS_MOD_ZOMBIES\work\textures]]

DESTINO_MALLA    = [[MODELS\PLANETS\CREATURES\ARTHROPOD]]
DESTINO_MATERIAL = [[MODELS\PLANETS\CREATURES\ARTHROPOD\BUGFIEND]]
DESTINO_TEXTURA  = [[TEXTURES\PLANETS\CREATURES\ARTHROPOD\THORAX]]

ENTREGA =
{
  {
    ["COMMENT"]              = "M4-PIEL - el .SCENE vanilla injertado, con FIRSTSKINMAT 0 y LASTSKINMAT 7. md5 identico al de la PRUEBA07",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.SCENE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.SCENE.MBIN]],
  },
  {
    ["COMMENT"]              = "M4-PIEL - VertexLayout a stride 20 con los canales 5 y 6, SkinMatrixLayout de 7 huesos. md5 identico al de la PRUEBA07",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.GEOMETRY.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.GEOMETRY.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "M4-TOPE - EL UNICO ARCHIVO QUE CAMBIA. Mismo mapa y los mismos 22982 vertices y 1043488 bytes que la PRUEBA07; lo que cambia son los PESOS DE LOS BRAZOS: de vaiven 355 y 411 a 120 los dos. Piernas y cabeza SIN TOCAR",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.GEOMETRY.DATA.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.GEOMETRY.DATA.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA02 - el descriptor recortado a UNA entrada, _Arthropod_1 sin hijos",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\BUGFIEND.DESCRIPTOR.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\BUGFIEND.DESCRIPTOR.MBIN]],
  },
  {
    ["COMMENT"]              = "M4-FLAG - ARTHROPODTHORAX01MAT con _F02_SKINNED y el gMasksMap apuntando a ZOMBIE.BASE.MASKS.DDS. md5 identico al de la PRUEBA07",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\ARTHROPODTHORAX01MAT.MATERIAL.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MATERIAL .. [[\ARTHROPODTHORAX01MAT.MATERIAL.MBIN]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA04, 05, 06 y 07, byte a byte - color base BC7 1024 con 11 mips",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\ZOMBIE.BASE.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\ZOMBIE.BASE.DDS]],
  },
  {
    ["COMMENT"]              = "Igual que la PRUEBA04, 05, 06 y 07, byte a byte - normal ATI2 1024 con 11 mips, esculpido en el asset",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\ZOMBIE.BASE.NORMAL.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\ZOMBIE.BASE.NORMAL.DDS]],
  },
  {
    ["COMMENT"]              = "M-BABA - mascaras PROPIAS, planas a 87 con el 3.2% de hueco de UV retenido a 0. Va a ruta PROPIA: ARTHROPODTHORAX01.BASE.MASKS.DDS la comparte toda la fauna artropodo del juego",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\ZOMBIE.BASE.MASKS.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\ZOMBIE.BASE.MASKS.DDS]],
  },
}

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_ZombieMesh_PRUEBA08",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.8.0] M4-TOPE: LOS BRAZOS CUELGAN DEL PAR DE PATAS QUE MAS GIRA Y LAS PIERNAS DEL QUE MENOS. LO QUE MIDIO LA PRUEBA07 EN PARTIDA, el 31/08: las piernas NO PARECEN MOVERSE, y lo unico que se estira y saca cuchillas es el CUELLO, los HOMBROS y los BRAZOS, al andar y al atacar. LA CAUSA, Y ES LA MISMA DEL NECROMORFO: la 07 elegia el agarre con la PALANCA sola, y la palanca no sabe cuanto gira el hueso. Lo que estira es PALANCA POR GIRO. LOS NUMEROS, sacados el 31/08 de los .ANIM del ARTHROPOD con Sway-NMSJoint.py. Giro de mundo al andar y al correr, por PAR de patas: par DELANTERO leg_L0/R0_0_jnt 18,1-52,1 y 16,7-53,2 grados; par de EN MEDIO leg_L1/R1_0_jnt 76,3-69,8 y 25,2-83,0; par TRASERO leg_L2/R2_0_jnt 17,9-18,1 y 17,8-28,3. Y nuestro mapa cuelga los BRAZOS del par delantero -de los que mas giran- y las PIERNAS del par TRASERO, que es el MAS QUIETO de los tres. De ahi salen las dos cosas que se ven a la vez: los brazos quedaban en vaiven 202 y 209 despues del agarre de la 07 y siguen sacando cuchillas, y las piernas en 65 y 58, que es el -no parecen moverse-. Y EL CUELLO NO ES EL CUELLO: head_C0_0_jnt gira 5,1 grados al andar y 1,6 al correr, o sea nada. Lo que se ve en el cuello y en los hombros es la COSTURA de la region del brazo, que llega hasta v 0,55 por arriba y corta en u 0,74 y 0,26, o sea justo por el hombro, y por arriba topa con la cabeza en v 0,86, o sea justo por el cuello. A un lado de la costura la piel seguia al brazo a 205 de vaiven y al otro al torso a 7. Bajar el brazo baja la costura: es el mismo arreglo para las tres cosas. EL ARREGLO: EL TOPE, en vaiven y ya no en palanca. objetivo 120, y los dos brazos bajan de 355 y 411 a 120 -agarre del 66% y del 71% a spine_C0_0_jnt-. El salto en el hombro pasa de unos 198 a unos 113, casi la mitad. AQUI NO SE USA EL ESPEJO, al reves que en el necromorfo, y por una vez el ARTHROPOD es simetrico donde importa: los dos huesos de brazo giran 52,1 y 53,2 al correr, asi que igualarlos no baja nada. Lo que sobra aqui es el vaiven ABSOLUTO, y eso lo corta el tope. LAS PIERNAS Y LA CABEZA NO SE TOCAN, y hay que decirlo claro: LAS PIERNAS VAN A SEGUIR MOVIENDOSE POCO. Estan colgadas del par mas quieto del rig y eso no lo arregla ningun peso, solo cambiarlas al par de EN MEDIO, que gira de 3 a 4 veces mas. Eso es la PRUEBA09 y NO se mete aqui a proposito: cambiar de hueso y cambiar el tope a la vez es medir dos cosas de una, que es como se perdio la PRUEBA05. LO QUE SALE: 2,18 influencias por vertice, 17983 de 17983 vertices con peso, 22982 casados, buffer de 459640 bytes a stride 20, paleta 2-3-7-19-25-37-42, FIRSTSKINMAT 0 a LASTSKINMAT 7. Asimetria 0,058 contra 0,018 del vanilla; lo que queda es que el zombie esta MODELADO en postura. La costura no empeora: p99 0,168. El reparto no se separa mas de 5 puntos del mapa. LOS OTROS SIETE ARCHIVOS VAN BYTE A BYTE COMO LA PRUEBA07, comprobado por md5 uno a uno: SOLO CAMBIA EL BUFFER DE VERTICES. Y EL FLAG Y EL SAMPLER SE VOLVIERON A CAER al rehacer la piel, como estaba escrito que pasaria: Check-NMSGraft.py los caza los dos antes de entrar y se repusieron con Flag-NMSMaterial.py y Set-NMSSampler.py, con lo que el .MATERIAL sale md5 identico al de la PRUEBA07. LA FIRMA, ESCRITA ANTES DE ENTRAR. Si el cuello, los hombros y los brazos dejan de estirarse y el zombie sigue seco, el tope de vaiven es la respuesta y solo queda el par de patas de las piernas. Si los brazos salen TIESOS como los del necromorfo, 120 se paso de bajo y hay que subirlo a 200. Si el cuello sigue estirando con los brazos ya quietos, entonces no era la costura del hombro y hay que mirar la frontera de la cabeza en v 0,86. Si sigue saliendo cuchilla en el mismo sitio y del mismo tamano, no es el peso sino el bind: los JointBindings se copian del ARTHROPOD tal cual. SUSTITUYE a la PRUEBA01, 02, 03, 04, 05, 06 y 07.",
["ADD_FILES"]       = ENTREGA,
}
