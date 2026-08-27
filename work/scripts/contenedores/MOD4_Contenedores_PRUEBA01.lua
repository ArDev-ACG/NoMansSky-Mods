CASILLAS = "100"

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "MOD4_Contenedores_PRUEBA01",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "[PRUEBA 0.1.0] El contenedor 1 de 50 casillas a "..CASILLAS..". UN SOLO CAMPO CAMBIADO, para que lo que se mida sea una cosa y no dos. LO QUE SE SABE ANTES DE ENTRAR, medido el 27/08 sobre los .pak: el tamano de los cofres NO esta en la tabla de construccion ni en DIFFICULTYCONFIG -ahi los campos Chest son limites de PILA, 9999 y 20, no casillas-. Esta en METADATA/GAMESTATE/DEFAULTSAVEDATA.MBIN, en Chest1Layout hasta Chest10Layout, con Slots 50 los diez. Y hay dos cosas mas que salieron del mismo volcado y cambian como se lee el resultado. UNA: los contenedores NO son una caja cada uno. El campo StorageContainerIndex de BASEBUILDINGOBJECTSTABLE va de 0 a 9, y CUATRO familias de pieza construible apuntan a los MISMOS diez indices -CONTAINER0-9 en base planetaria, S_CONTAINER0-9 en carguero legado, FRE_ROOM_STORE0-9 en sala industrial y B_WALL_CARG0-9 en corveta-. O sea que la partida tiene DIEZ inventarios y cada contenedor construido es una PUERTA a uno de ellos: dos contenedores del mismo indice comparten los mismos 50, y uno en el planeta y otro en el carguero tambien, sin importar la distancia. Por eso este mod toca el COFRE 1 y no un contenedor concreto. DOS: DEFAULTSAVEDATA es la plantilla de PARTIDA NUEVA, y si el cambio alcanza a una partida ya empezada no se sabe. Es la misma duda que la de los extractores, y se contesta sin volver a tocar ningun archivo. LA FIRMA, ESCRITA ANTES DE ENTRAR. Se abre el contenedor 1 QUE YA EXISTE. Si sale con "..CASILLAS.." casillas, la plantilla alcanza a las partidas viejas y el mod sirve tal cual: se sube el resto de cofres y se decide el numero final. Si sigue con 50, el layout viene horneado en la partida y hay dos salidas, ninguna adivinada: probarlo en una partida nueva para confirmar que ahi si entra, o editar el save, que es otra cosa y no un mod. Si el juego se cierra al abrirlo o las casillas salen vacias y no dejan meter nada, el numero no puede subir por encima de lo que la interfaz dibuja y hay que bajar de "..CASILLAS..". LO QUE ESTE MOD NO HACE Y NO PUEDE HACER: sumar dos contenedores pegados, ni impedir romper uno lleno. No hay campo donde escribirlo -los unicos de vecindad de toda la tabla son de encaje y de red electrica- y los mods de NMS no ejecutan codigo. Ver docs/MOD4-CONTENEDORES.md.",
["MODIFICATIONS"]   =
  {
    {
      ["MBIN_CHANGE_TABLE"] =
      {
        {
          ["MBIN_FILE_SOURCE"] = "METADATA\GAMESTATE\DEFAULTSAVEDATA.MBIN",
          ["MXML_CHANGE_TABLE"] =
          {
            {
              ["COMMENT"]              = "Cofre 1: Slots "..CASILLAS,
              ["PRECEDING_KEY_WORDS"]  = {"Chest1Layout"},
              ["VALUE_CHANGE_TABLE"]   = { {"Slots", CASILLAS} }
            },
          }
        },
      }
    }
  }
}
