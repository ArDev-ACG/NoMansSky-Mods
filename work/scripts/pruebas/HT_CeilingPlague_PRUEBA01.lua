NIDO_CARGUERO = "MODELS\PLANETS\BIOMES\COMMON\BUILDINGS\PARTS\BUILDABLEPARTS\SPACEBASE\INFESTATION\MEDIUMHANGSLIME.SCENE.MBIN"

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HT_CeilingPlague_PRUEBA01",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.1.0] La plaga del carguero colgada del techo de los edificios abandonados. No toca ningun .LSYSTEM: el locator TENTACLE_ sigue colgando INTERIOR_TENTACLEPLANT al 30% como en vanilla. Lo que cambia es lo que hay dentro de esa escena, que resulta no tener malla propia: es un envoltorio con un LOCATOR ObjectSpawner y dentro un nodo REFERENCE que apunta por SCENEGRAPH a TENTACLEPLANT.SCENE.MBIN, girado 180 grados en Z para colgar boca abajo. Se cambia ese SCENEGRAPH por MEDIUMHANGSLIME.SCENE.MBIN, el nido colgante del carguero, y el giro de 180 se conserva porque vive en el envoltorio, no en la escena apuntada. El nido trae su ENTITY entera: GcDestructableComponentData (Health 600, explosion INFESTPILLAREXP, recompensa DE_FATSLIME, modelo destruido), GcShootableComponentData, GcScannableComponentData y GcAlienPodComponentData, que es la mecanica de que el nido te huele. Y esa ENTITY ya la retoca HorribleTerror_Infestation, asi que hereda gratis AgroTorch y GunfireAgro. Escribe un solo archivo. Incompatible con HT_LocatorTest_PRUEBA01, que secuestra el mismo locator desde el .LSYSTEM.",
["MODIFICATIONS"]   =
  {
    {
      ["MBIN_CHANGE_TABLE"] =
      {
        {
          ["MBIN_FILE_SOURCE"] = "MODELS\PLANETS\BIOMES\COMMON\BUILDINGS\PROPS\ABANDONED\INTERIOR_TENTACLEPLANT.SCENE.MBIN",
          ["MXML_CHANGE_TABLE"] =
          {
            {
              ["COMMENT"]            = "SCENEGRAPH del nodo TentacleRef: de la planta del techo al nido colgante del carguero",
              ["SPECIAL_KEY_WORDS"]  = {"Name", "SCENEGRAPH"},
              ["REPLACE_TYPE"]       = "ONCE",
              ["VALUE_CHANGE_TABLE"] = { {"Value", NIDO_CARGUERO} }
            },
          }
        },
      }
    },
  },
}
