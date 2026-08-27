RAIZ_MALLA   = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\models\scuttlermesh]]
RAIZ_TEXTURA = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\textures]]

DESTINO_MALLA    = [[MODELS\PLANETS\CREATURES\SPIDERRIG]]
DESTINO_MATERIAL = [[MODELS\PLANETS\CREATURES\SPIDERRIG\FREIGHTERFIEND]]
DESTINO_TEXTURA  = [[TEXTURES\PLANETS\CREATURES\SPIDERRIG]]
DESTINO_PROC     = [[TEXTURES\COMMON\PLAYER\PLAYERCHARACTER]]

ENTREGA =
{
  {
    ["COMMENT"]              = "Etapa 3d - mismo .SCENE injertado, con el AttackLight apagado",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FREIGHTERFIEND.SCENE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FREIGHTERFIEND.SCENE.MBIN]],
  },
  {
    ["COMMENT"]              = "GEOMETRY con los cuatro arrays por hueso y el MeshBaseSkinMat",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FREIGHTERFIEND.GEOMETRY.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FREIGHTERFIEND.GEOMETRY.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "Etapa 3 - el SkrullCrawler en el sitio del SCUTTLER",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FREIGHTERFIEND.GEOMETRY.DATA.MBIN.PC]],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\FREIGHTERFIEND.GEOMETRY.DATA.MBIN.PC]],
  },
  {
    ["COMMENT"]              = "FFIENDMAT sin _F02_SKINNED y con gDiffuseMap en la textura propia",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FFIENDMAT.MATERIAL.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_MATERIAL .. [[\FFIENDMAT.MATERIAL.MBIN]],
  },
  {
    ["COMMENT"]              = "Etapa 3b - color base propio, BC7 2048 con 12 mips",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_TEXTURA .. [[\SKRULLCRAWLER.BASE.DDS]],
    ["FILE_DESTINATION"]     = DESTINO_TEXTURA .. [[\SKRULLCRAWLER.BASE.DDS]],
  },
  {
    ["COMMENT"]              = "Etapa 3c - lista procedural sin capas: que no componga y mande el gDiffuseMap",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\FREIGHTERFIEND.TEXTURE.MBIN]],
    ["FILE_DESTINATION"]     = DESTINO_PROC .. [[\FREIGHTERFIEND.TEXTURE.MBIN]],
  },
}

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_ScuttlerMesh_PRUEBA09",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.9.0] Etapa 3d: apaga la luz que el bicho lleva puesta. Con la PRUEBA08 la textura propia ya se ve, pero salia dorada. La causa es el nodo AttackLight del .SCENE vanilla injertado, un punto de luz de 360 grados colgado del hueso NewJawEND con RADIUS 4.472136, INTENSITY 1.0 y color 0.861, 1.0, 0.0, que es amarillo verdoso puro. Ilumina al bicho entero desde dentro y tambien pinta de verde el suelo a su alrededor. No es nueva: es la vanilla de siempre. Lo que cambio es la piel, porque el SCUTTLER original es rojo oscuro y se traga ese amarillo, mientras que nuestro atlas tiene blancos y rojos claros que lo devuelven. Encima nuestra malla mide 1.83 de alto por 2.66 de ancho y cabe mucho mas cuerpo dentro de esos 4.47 metros de radio. Esta prueba pone su INTENSITY a 0, como ya la tiene la otra luz de la escena, Light_pointLight1. Solo cambia ese flotante: ningun indice se mueve, el .SCENE sigue pesando 21889 bytes y Check-NMSGraft.py lo revalida con sus 114 nodos JOINT. Lo demas no cambia respecto a la PRUEBA08. Sustituye a las PRUEBA01 a 08 y choca con HT_FiendMarkers_PRUEBA04 y con HorribleTerror_NecroSkin.",
["ADD_FILES"]       = ENTREGA,
}
