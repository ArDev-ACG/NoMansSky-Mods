RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\models\crywolfmesh_anim6]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\textures]]

DESTINO_MALLA    = [[MODELS\PLANETS\CREATURES\SPIDERRIG]]
DESTINO_MATERIAL = [[MODELS\PLANETS\CREATURES\SPIDERRIG\FIEND]]
DESTINO_ENTIDAD  = [[MODELS\PLANETS\CREATURES\SPIDERRIG\FIEND\ENTITIES]]
DESTINO_ANIM     = [[MODELS\PLANETS\CREATURES\SPIDERRIG\ANIM_CRYWOLF]]
DESTINO_TEXTURA  = [[TEXTURES\PLANETS\CREATURES\SPIDERRIG]]

ENTREGA =
{
  {
    ["COMMENT"]              = "El .SCENE del FIEND con los 44 nodos JOINT MOVIDOS a nuestra malla. La colision, el ATTACHMENT y el resto siguen siendo los del juego; lo unico que cambia son los TransX/Y/Z de los JOINT, para que el reposo de la escena diga lo mismo que el bind y que los clips",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.SCENE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.SCENE.MBIN]],
  },
  {
    ["COMMENT"]              = "VertexLayout a stride 20 y, LO NUEVO, los JointBindings recalculados: la inversa de NUESTRO reposo en vez de la copia del vanilla que dejaba la cabeza 3,21 m fuera de sitio",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.GEOMETRY.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.GEOMETRY.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "El buffer de vertices, con los pesos a agarre 1,0: cada region manda en su propio hueso, que es lo que el bind nuevo permite por primera vez",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND.GEOMETRY.DATA.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FIEND.GEOMETRY.DATA.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "FIEND_MAT con _F02_SKINNED y los TRES samplers a rutas CRYWOLF, BYTE A BYTE el de la PRUEBA05",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FIEND_MAT.MATERIAL.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MATERIAL .. [[\FIEND_MAT.MATERIAL.MBIN]],
  },
  {
    ["COMMENT"]              = "El .ENTITY del cuerpo, con las 22 rutas de clip apuntando a ANIM_CRYWOLF en vez de a ANIM. Es lo que deja intacto al FREIGHTERFIEND, o sea al SkrullCrawler, que sigue leyendo los clips del vanilla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\_FIEND_BODY.ENTITY.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_ENTIDAD .. [[\_FIEND_BODY.ENTITY.MBIN]],
  },
  {
    ["COMMENT"]              = "Color base BC7 2048 con 12 mips, sin tocar desde la PRUEBA01",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\CRYWOLF.BASE.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\CRYWOLF.BASE.DDS]],
  },
  {
    ["COMMENT"]              = "Normal ATI2 2048 con 12 mips, esculpido en el asset, sin tocar desde la PRUEBA01",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\CRYWOLF.BASE.NORMAL.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\CRYWOLF.BASE.NORMAL.DDS]],
  },
  {
    ["COMMENT"]              = "Mascaras ATI1 2048 de la rugosidad real del asset, invertidas por el acuerdo B5, sin tocar desde la PRUEBA01",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\CRYWOLF.BASE.MASKS.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\CRYWOLF.BASE.MASKS.DDS]],
  },
  {
    ["COMMENT"]              = "Clip FIENDATTACK retargeteado: las rotaciones del vanilla contadas como delta contra el fotograma 0 de idle, y los siete pivotes puestos en nuestra malla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\ANIM_CRYWOLF\FIENDATTACK.ANIM.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_ANIM .. [[\FIENDATTACK.ANIM.MBIN]],
  },
  {
    ["COMMENT"]              = "Clip FIENDATTACK2 retargeteado: las rotaciones del vanilla contadas como delta contra el fotograma 0 de idle, y los siete pivotes puestos en nuestra malla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\ANIM_CRYWOLF\FIENDATTACK2.ANIM.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_ANIM .. [[\FIENDATTACK2.ANIM.MBIN]],
  },
  {
    ["COMMENT"]              = "Clip FIENDATTACK3 retargeteado: las rotaciones del vanilla contadas como delta contra el fotograma 0 de idle, y los siete pivotes puestos en nuestra malla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\ANIM_CRYWOLF\FIENDATTACK3.ANIM.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_ANIM .. [[\FIENDATTACK3.ANIM.MBIN]],
  },
  {
    ["COMMENT"]              = "Clip FIENDBURY retargeteado: las rotaciones del vanilla contadas como delta contra el fotograma 0 de idle, y los siete pivotes puestos en nuestra malla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\ANIM_CRYWOLF\FIENDBURY.ANIM.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_ANIM .. [[\FIENDBURY.ANIM.MBIN]],
  },
  {
    ["COMMENT"]              = "Clip FIENDDEATH01 retargeteado: las rotaciones del vanilla contadas como delta contra el fotograma 0 de idle, y los siete pivotes puestos en nuestra malla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\ANIM_CRYWOLF\FIENDDEATH01.ANIM.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_ANIM .. [[\FIENDDEATH01.ANIM.MBIN]],
  },
  {
    ["COMMENT"]              = "Clip FIENDEAT retargeteado: las rotaciones del vanilla contadas como delta contra el fotograma 0 de idle, y los siete pivotes puestos en nuestra malla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\ANIM_CRYWOLF\FIENDEAT.ANIM.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_ANIM .. [[\FIENDEAT.ANIM.MBIN]],
  },
  {
    ["COMMENT"]              = "Clip FIENDFASTWALK retargeteado: las rotaciones del vanilla contadas como delta contra el fotograma 0 de idle, y los siete pivotes puestos en nuestra malla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\ANIM_CRYWOLF\FIENDFASTWALK.ANIM.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_ANIM .. [[\FIENDFASTWALK.ANIM.MBIN]],
  },
  {
    ["COMMENT"]              = "Clip FIENDGROUNDAPPEAR retargeteado: las rotaciones del vanilla contadas como delta contra el fotograma 0 de idle, y los siete pivotes puestos en nuestra malla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\ANIM_CRYWOLF\FIENDGROUNDAPPEAR.ANIM.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_ANIM .. [[\FIENDGROUNDAPPEAR.ANIM.MBIN]],
  },
  {
    ["COMMENT"]              = "Clip FIENDIDLE retargeteado: las rotaciones del vanilla contadas como delta contra el fotograma 0 de idle, y los siete pivotes puestos en nuestra malla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\ANIM_CRYWOLF\FIENDIDLE.ANIM.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_ANIM .. [[\FIENDIDLE.ANIM.MBIN]],
  },
  {
    ["COMMENT"]              = "Clip FIENDPAIN retargeteado: las rotaciones del vanilla contadas como delta contra el fotograma 0 de idle, y los siete pivotes puestos en nuestra malla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\ANIM_CRYWOLF\FIENDPAIN.ANIM.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_ANIM .. [[\FIENDPAIN.ANIM.MBIN]],
  },
  {
    ["COMMENT"]              = "Clip FIENDPAIN2 retargeteado: las rotaciones del vanilla contadas como delta contra el fotograma 0 de idle, y los siete pivotes puestos en nuestra malla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\ANIM_CRYWOLF\FIENDPAIN2.ANIM.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_ANIM .. [[\FIENDPAIN2.ANIM.MBIN]],
  },
  {
    ["COMMENT"]              = "Clip FIENDPAIN3 retargeteado: las rotaciones del vanilla contadas como delta contra el fotograma 0 de idle, y los siete pivotes puestos en nuestra malla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\ANIM_CRYWOLF\FIENDPAIN3.ANIM.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_ANIM .. [[\FIENDPAIN3.ANIM.MBIN]],
  },
  {
    ["COMMENT"]              = "Clip FIENDPERFORM01 retargeteado: las rotaciones del vanilla contadas como delta contra el fotograma 0 de idle, y los siete pivotes puestos en nuestra malla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\ANIM_CRYWOLF\FIENDPERFORM01.ANIM.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_ANIM .. [[\FIENDPERFORM01.ANIM.MBIN]],
  },
  {
    ["COMMENT"]              = "Clip FIENDPERFORM02 retargeteado: las rotaciones del vanilla contadas como delta contra el fotograma 0 de idle, y los siete pivotes puestos en nuestra malla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\ANIM_CRYWOLF\FIENDPERFORM02.ANIM.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_ANIM .. [[\FIENDPERFORM02.ANIM.MBIN]],
  },
  {
    ["COMMENT"]              = "Clip FIENDPERFORM03 retargeteado: las rotaciones del vanilla contadas como delta contra el fotograma 0 de idle, y los siete pivotes puestos en nuestra malla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\ANIM_CRYWOLF\FIENDPERFORM03.ANIM.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_ANIM .. [[\FIENDPERFORM03.ANIM.MBIN]],
  },
  {
    ["COMMENT"]              = "Clip FIENDPOUNCE retargeteado: las rotaciones del vanilla contadas como delta contra el fotograma 0 de idle, y los siete pivotes puestos en nuestra malla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\ANIM_CRYWOLF\FIENDPOUNCE.ANIM.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_ANIM .. [[\FIENDPOUNCE.ANIM.MBIN]],
  },
  {
    ["COMMENT"]              = "Clip FIENDROAR retargeteado: las rotaciones del vanilla contadas como delta contra el fotograma 0 de idle, y los siete pivotes puestos en nuestra malla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\ANIM_CRYWOLF\FIENDROAR.ANIM.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_ANIM .. [[\FIENDROAR.ANIM.MBIN]],
  },
  {
    ["COMMENT"]              = "Clip FIENDRUN retargeteado: las rotaciones del vanilla contadas como delta contra el fotograma 0 de idle, y los siete pivotes puestos en nuestra malla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\ANIM_CRYWOLF\FIENDRUN.ANIM.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_ANIM .. [[\FIENDRUN.ANIM.MBIN]],
  },
  {
    ["COMMENT"]              = "Clip FIENDSLOWWALK retargeteado: las rotaciones del vanilla contadas como delta contra el fotograma 0 de idle, y los siete pivotes puestos en nuestra malla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\ANIM_CRYWOLF\FIENDSLOWWALK.ANIM.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_ANIM .. [[\FIENDSLOWWALK.ANIM.MBIN]],
  },
  {
    ["COMMENT"]              = "Clip FIENDSPIT retargeteado: las rotaciones del vanilla contadas como delta contra el fotograma 0 de idle, y los siete pivotes puestos en nuestra malla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\ANIM_CRYWOLF\FIENDSPIT.ANIM.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_ANIM .. [[\FIENDSPIT.ANIM.MBIN]],
  },
  {
    ["COMMENT"]              = "Clip FIENDTROT retargeteado: las rotaciones del vanilla contadas como delta contra el fotograma 0 de idle, y los siete pivotes puestos en nuestra malla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\ANIM_CRYWOLF\FIENDTROT.ANIM.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_ANIM .. [[\FIENDTROT.ANIM.MBIN]],
  },
  {
    ["COMMENT"]              = "Clip FIENDWALK retargeteado: las rotaciones del vanilla contadas como delta contra el fotograma 0 de idle, y los siete pivotes puestos en nuestra malla",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\ANIM_CRYWOLF\FIENDWALK.ANIM.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_ANIM .. [[\FIENDWALK.ANIM.MBIN]],
  },
}

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_CryWolf_PRUEBA06",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.6.0] EL CRY WOLF CON SU PROPIO ESQUELETO. ESTA ES LA PRIMERA QUE ENTREGA .ANIM, Y HAY 22. POR QUE, Y ESTA MEDIDO. La queja del 04/09 era que el lobo se sigue viendo como la captura de asset/Errores aunque la PRUEBA05 doblara el cuello 30 grados. Se reprodujo la captura FUERA del juego -fiendpounce fotograma 57, con la malla de la 05- y es la misma pose, o sea que el despliegue estaba bien y lo que fallaba era otra cosa. Y se midio: PRIMERO, EL BIND ESTABA MAL. Patch-NMSGraft copia JointBindings del vanilla tal cual, y esa matriz NO es la inversa del reposo de nuestra escena: con la pose de reposo puesta, World_reposo * InvBind tendria que dar la identidad y desplaza la region de la cabeza 3,21 m, el cuello 1,47 y las patas de 0,46 a 1,21; solo RootJNT sale a cero. O sea que en cuanto una region se agarraba a su hueso salia disparada, y ESAS eran las cuchillas contra las que se fue bajando el agarre prueba tras prueba. SEGUNDO, POR ESO EL BICHO IBA RIGIDO. Con el agarre en 0,04 en la pata delantera izquierda y 0,22 en la cabeza, los 9672 vertices los mandaban RootJNT y NewBack1JNT: NI UN VERTICE seguia a su propio hueso, y por eso daba igual lo que se tocara. TERCERO, EL ESQUELETO NO CABE. El SPIDERRIG mide 1,74 x 1,22 x 4,24 -3,5 a 1 de largo a alto- y nuestra malla 1,20 x 2,85 x 2,29 -1,1 a 1-: no hay escala uniforme que case eso, y los pivotes le quedaban entre 0,6 y 1,3 m a la carne que mueven. Y CUARTO, MOVER LOS JOINT DEL .SCENE NO VALE: los .ANIM traen traslacion en los 115 nodos y en 112 es constante, o sea que el clip repone el offset cada fotograma y se come el cambio. De ahi que haya que escribir los clips. LO QUE SE ENTREGA. Los pivotes de los siete huesos con peso se ponen donde toca en NUESTRA malla -la cabeza sube 2,27 m, las cuatro patas 0,81, RootJNT 0,74 y el cuello 0,31-, el bind pasa a ser la inversa de ESE reposo, el .SCENE escribe los mismos pivotes para no contradecirlo, y los 22 clips se reescriben con el movimiento contado como DELTA contra una pose de referencia comun, el fotograma 0 de idle: W(t) = [W_vanilla(t) * W_ref^-1] * W_nuestro_reposo. Puesto en local eso es una constante por delante y otra por detras de cada valor, asi que un canal quieto sigue quieto y uno animado sigue animado, y ni la estructura ni el numero de fotogramas cambian. Sin el delta la malla se pega a la POSE de la arana y sale tumbada y descuartizada, renderizado el 04/09. LOS CLIPS VAN EN ANIM_CRYWOLF Y NO PISAN LOS DEL JUEGO: quien los nombra es nuestro _FIEND_BODY.ENTITY, que es donde viven las 22 rutas, asi que el FREIGHTERFIEND -o sea el SkrullCrawler de la HT_ScuttlerMesh- sigue leyendo los del vanilla. LO QUE SALE MEDIDO, y sobre los ARCHIVOS QUE SE ENTREGAN, no sobre el vanilla: el bind casa con el reposo en 7 de 7 huesos contra 1 de 7 de la PRUEBA05, el error de la identidad es 8,3e-16, el agarre sube a 1,0 en las seis regiones y ahora manda cada una en la suya -cabeza 3429, tronco 2490, patas 916/916/793/791, cuello 337-, asimetria 0,000 contra 0,005 del vanilla y el reparto no se separa mas de 5 puntos del mapa. Pose-NMSMesh sobre lo entregado, walk-roar-pounce-attack: tension 30-43 y ABRE 38, 52, 35 y 41 cm. ABRE MAS QUE LA PRUEBA05 -23, 20, 33 y 26- Y SE ACEPTA A PROPOSITO: la 05 no se estiraba porque no se movia, que es literalmente la queja; lo que se mira ahora es si el bicho anda, no si esta quieto. LA FIRMA, ESCRITA ANTES DE ENTRAR. Si el lobo pisa con las cuatro patas y mantiene la cabeza en su sitio al andar y al saltar, cierra. Si se ve la costura en el hombro o en la cadera, faltan pasadas de suavizado: SUAVIZADOS de 12 a 24 en Weight-NMSMesh. Si el RUGIDO dobla el cuerpo en dos -es el peor de los cuatro renders, 52 cm-, la palanca es la pose de referencia o recortar el delta solo en ese clip. Si el bicho aparece descolocado el primer fotograma, es el .SCENE contra el clip y se mira ahi. Y si CRASHEA, lo nuevo son el .ENTITY y los 22 clips: se quitan los clips uno a uno empezando por los PERFORM. SUSTITUYE a HT_CryWolf_PRUEBA05 y a toda la serie anterior, que escriben los mismos archivos y NO PUEDEN CONVIVIR con esta.",
["ADD_FILES"]       = ENTREGA,
}
