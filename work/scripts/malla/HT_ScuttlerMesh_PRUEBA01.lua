RAIZ_MALLA = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\models\scuttlermesh]]

DESTINO_MALLA = [[MODELS\PLANETS\CREATURES\SPIDERRIG]]

ARCHIVOS_MALLA =
{
  "FREIGHTERFIEND.SCENE.MBIN",
  "FREIGHTERFIEND.GEOMETRY.MBIN.PC",
  "FREIGHTERFIEND.GEOMETRY.DATA.MBIN.PC",
}

ENTREGA = {}

for i = 1, #ARCHIVOS_MALLA do
  ENTREGA[#ENTREGA + 1] =
  {
    ["COMMENT"]              = "Etapa 3 - el SkrullCrawler en el sitio del cuerpo del SCUTTLER",
    ["EXTERNAL_FILE_SOURCE"] = RAIZ_MALLA .. [[\]] .. ARCHIVOS_MALLA[i],
    ["FILE_DESTINATION"]     = DESTINO_MALLA .. [[\]] .. ARCHIVOS_MALLA[i],
  }
end

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_ScuttlerMesh_PRUEBA01",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.1.0] Etapa 3 de la via Blender: la primera malla propia en una CRIATURA, no en un prop. Mete el SkrullCrawler (9592 triangulos, 11357 vertices) en el sitio del cuerpo del SCUTTLER, el bicho que sale de los nidos del carguero. La pregunta que contesta es una sola: que hace el juego con una malla que NO trae los canales de skinning. El VertexLayout del vanilla declara SemanticID 5 y 6 -indices y pesos de hueso- y NMSDK no sabe escribirlos: exporta MeshBaseSkinMat y SkinMatrixLayout vacios. Si el bicho aparece rigido pero se mueve, tenemos modelos propios sin deformacion; si no aparece, la via de criaturas queda cerrada hasta escribir los pesos a mano. El .SCENE es el vanilla con dos cambios: los atributos del nodo polySurface6 pasan a describir nuestra malla, y se borra el nodo SUB1polySurface6 -el ojo- porque nuestro .GEOMETRY solo trae un stream. Se conservan los 114 nodos JOINT, las dos colisiones, las dos luces, el material FFIENDMAT y el ATTACHMENT que cuelga la FREIGHTERFIEND.ENTITY, que es donde vive el comportamiento. La malla va con la textura vanilla del Fiend estirada sobre nuestras UV: se vera raro a proposito, la textura propia es el paso siguiente.",
["ADD_FILES"]       = ENTREGA,
}
