RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\MODS\NMS_MOD_ZOMBIES\work\models\crywolfmesh_anim7]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\MODS\NMS_MOD_ZOMBIES\work\textures]]

DESTINO_MALLA    = [[MODELS\PLANETS\CREATURES\SPIDERRIG]]
DESTINO_MATERIAL = [[MODELS\PLANETS\CREATURES\SPIDERRIG\FIEND]]
DESTINO_TEXTURA  = [[TEXTURES\PLANETS\CREATURES\SPIDERRIG]]

ENTREGA =
{
  {
    ["COMMENT"]              = "El .SCENE vanilla del FIEND injertado, BYTE A BYTE el de la PRUEBA05: esta prueba no mueve un pivote ni toca la colision",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.SCENE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.SCENE.MBIN]],
  },
  {
    ["COMMENT"]              = "LO UNICO QUE CAMBIA DE VERDAD: los 44 JointBindings pasan de ser copia del vanilla a ser la inversa de la pose de mundo del vanilla en fiendwalk fotograma 24. Comprobado: mundo(f24) * bind da la identidad en los 7 huesos con peso, error 6,3e-11",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.GEOMETRY.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.GEOMETRY.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "El buffer de vertices. Los MISMOS 11100 vertices en el MISMO sitio que la PRUEBA05 -el cuello sigue doblado 30 grados-: lo que cambia son los canales 5 y 6, el pesado, que pasa del objetivo 110 al 200",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.GEOMETRY.DATA.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.GEOMETRY.DATA.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "FIEND_MAT con _F02_SKINNED y los TRES samplers a rutas CRYWOLF, BYTE A BYTE el de la PRUEBA05",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND_MAT.MATERIAL.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MATERIAL .. [[\FIEND_MAT.MATERIAL.MBIN]],
  },
  {
    ["COMMENT"]              = "Color base BC7 2048 con 12 mips, sin tocar desde la PRUEBA01",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\CRYWOLF.BASE.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\CRYWOLF.BASE.DDS]],
  },
  {
    ["COMMENT"]              = "Normal ATI2 2048 con 12 mips, esculpido en el asset, sin tocar desde la PRUEBA01. Las UV no se han movido",
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
["MOD_FILENAME"]    = "HT_CryWolf_PRUEBA07",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.7.0] EL CRY WOLF DEJA DE FLOTAR Y DE IR TIESO, Y ES UNA SOLA CAUSA. La queja del 04/09 era doble -sigue flotando, y las patas van todas tiesas- y las dos salen del MISMO fallo, medido el 05/09. EL BIND ESTABA MAL. Patch-NMSGraft copiaba JointBindings del vanilla tal cual, y esa matriz no es una constante del hueso: es la inversa de la pose de mundo EN QUE SE PESO LA MALLA. Copiarla vale mientras nuestra malla este modelada en la misma postura que la del vanilla, y la del cry wolf no lo esta. Medido sobre la PRUEBA05 desplegada -descompilando el .MBIN de GAMEDATA/MODS, 45 de 45 binds iguales al vanilla-: con la pose de reposo puesta, mundo * bind tendria que dar la identidad y desplaza la cabeza 1,69 m, el cuello 1,45 y las patas de 0,45 a 1,27. Solo RootJNT sale a cero. Y NO VALE PONER EL REPOSO DEL .SCENE EN SU LUGAR: se probo y sale PEOR -tension 87 contra 35-, porque la malla del vanilla tampoco esta pesada en su reposo. DE AHI SALIAN LAS DOS QUEJAS. Como cada region que se agarraba a su hueso salia disparada, el tope de vaiven se fue apretando prueba tras prueba hasta dejar el agarre en 0,10 y 0,20 en las patas delanteras: los 9672 vertices los mandaban RootJNT y NewBack1JNT y NINGUNA pata mandaba en un solo vertice. Medido: los pies de nuestra malla colgaban un 70,6% del TORSO y solo un 29,4% de las patas. Por eso no se abrian -tiesas- y por eso subian y bajaban con el cuerpo en vez de quedarse en el suelo -flotando-. Una causa, dos sintomas. LO QUE SE ENTREGA, Y LO QUE NO. Patch-NMSGraft gana --bind <ANIM>#<fotograma>: el bind pasa a ser la inversa de la pose de mundo del VANILLA en ese fotograma, asi que mundo(t) * bind es el movimiento del hueso DESDE ese fotograma y eso si se le puede aplicar a nuestra malla tal como esta modelada. Es un retarget, y NO hace falta reescribir ni un .ANIM ni el .SCENE: esta prueba no entrega clips, ni .ENTITY, ni pivotes nuevos. El .SCENE va BYTE A BYTE el de la PRUEBA05 y los clips son los del juego. EL FOTOGRAMA NO SE ELIGE A OJO. Se barrieron los frames de idle, walk y trot juzgando con los NUEVE clips a la vez, por tension y por distancia al suelo, y gana fiendwalk fotograma 24. El reposo del .SCENE quedo el peor de todos. Y CON EL BIND BUENO SE SUELTA EL AGARRE: el pesado pasa del objetivo 110 al 200, que ya estaba barrido en disco desde el 04/09 y hasta hoy no se podia usar. Las patas suben del 29,4% al 46,4% del peso de los pies. LO QUE SALE MEDIDO, sobre los archivos que se entregan y con los nueve clips: tension 34,85 -> 18,22, flex 3,33 -> 2,46, ABRE 33 -> 20 cm, y el alto medio de la malla 2,42 -> 2,85 m, o sea que deja de ir aplastada. Las patas al andar recorren 0,45 -> 0,87 m contra los 1,06 de los pies del propio vanilla. EL SUELO, POR CLIP, antes -> ahora: walk 0,44..0,67 -> -0,02..0,22 · idle 0,49..0,60 -> 0,01..0,11 · run 0,60..0,75 -> 0,17..0,30 · roar 0,26..0,62 -> -0,27..0,38 · pounce 0,22..1,17 -> -0,25..0,74. Y EL PRECIO, QUE SE ENTREGA SABIENDOLO: trot, attack2 y attack3 pasan de 0,00..0,09 a HUNDIRSE entre 24 y 47 cm. El vaiven vertical del esqueleto del FIEND son 0,83 m y el bind solo puede CORRER esa ventana, no estrecharla; antes estaba entera por encima del suelo -flotaba siempre y no se hundia nunca- y ahora esta centrada. LA FIRMA, ESCRITA ANTES DE ENTRAR. Si el lobo pisa el suelo al andar, al correr y parado, y las patas se abren al andar, cierra las dos quejas. Si ahora SE HUNDE al trotar o en los ataques cortos, es la ventana centrada y el arreglo es UN NUMERO: se sube el fotograma de referencia a uno mas bajo del vanilla, --bind, sin tocar nada mas. Si las patas se mueven pero se ve COSTURA en hombro o cadera, el objetivo 200 se paso y el siguiente es 170, que tambien esta barrido en disco. Si las patas siguen sin abrirse del todo, lo que queda es que colgamos de *Leg1JNT, que es la CADERA y sube y baja con el cuerpo: el paso siguiente es partir cada pata y colgar la parte baja de Leg3, y eso si es re-pesar en Blender. Si CRASHEA, lo unico nuevo son 44 matrices del .GEOMETRY: se vuelve a la PRUEBA05, que sigue en ModBackups. SUSTITUYE a HT_CryWolf_PRUEBA05 y a toda la serie anterior, que escriben los mismos archivos y NO PUEDEN CONVIVIR con esta.",
["ADD_FILES"]       = ENTREGA,
}
