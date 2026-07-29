--[[
  HORRIBLE TERROR - Fase 1/2: prueba de paletas (SANGRE)
  ------------------------------------------------------------------
  Objetivo: pintar TODA la fauna de rojo carne. No es el look final del
  mod; es una senal de validacion imposible de confundir. Si al aterrizar
  los bichos salen rojos, la ruta de paletas funciona y la Fase 2 esta
  desbloqueada sin tocar Blender ni un solo DDS.

  ------------------------------------------------------------------
  COMO COLOREA NMS A LAS CRIATURAS - cadena verificada en 6.45.0.1
  ------------------------------------------------------------------
  No existe "la textura del bicho X". El color se resuelve en 3 saltos:

    1. TEXTURES\PLANETS\CREATURES\<RIG>\<parte>.TEXTURE.MBIN
       Cada capa de textura procedural declara un TkPaletteTexture:
           <Property name="Palette"   value="Scale" />
           <Property name="ColourAlt" value="Primary" />
           <Property name="Index"     value="-1" />
       O sea: la parte no guarda un color, guarda el NOMBRE de una paleta.

    2. El nombre se resuelve contra el archivo de paletas del BIOMA del
       planeta: METADATA\SIMULATION\SOLARSYSTEM\BIOMES\<X>\<X>COLOURPALETTES.MBIN
       Cada uno es un cGcPaletteList con 64 paletas de 64 colores RGBA.

    3. Index -1 = el juego elige color por semilla dentro de esa paleta.

  Consecuencia: cambiando los colores de la paleta se repinta la fauna
  entera del universo. Es global por diseno. Para "planeta infestado" es
  justo lo que queremos; para "solo este bicho" no sirve.

  ------------------------------------------------------------------
  QUE PALETAS TOCAR - medido, no adivinado
  ------------------------------------------------------------------
  Se decompilaron los 432 .TEXTURE.MBIN de TEXTURES\PLANETS\CREATURES\
  y se conto que paleta pide cada capa:

      Scale       1318   <- se toca
      Underbelly   512   <- se toca
      Fur          470   <- se toca
      Rock         402   <- NO: compartida con el terreno del planeta
      Feather      128   <- se toca
      Paint        113   <- NO: compartida con naves y edificios
      Undercoat      1   <- se toca (por completar el set de piel)
      ...resto marginal

  Se dejan fuera Rock y Paint a proposito. Pintarlas de rojo tenirian las
  rocas y las naves, y entonces no se sabria si el cambio afecto a la
  fauna o al mundo entero. La prueba tiene que ser inequivoca.

  Cobertura: ~2429 de ~2900 capas de criatura = 84%.

  ------------------------------------------------------------------
  POR QUE 47 ARCHIVOS
  ------------------------------------------------------------------
  Cada bioma trae su propia lista de paletas. Verificado: los 47 archivos
  de abajo contienen las 5 paletas de fauna. Si se parchea solo uno, la
  fauna sale roja solo en ese bioma.

  Se excluye METADATA\GAMESTATE\PLAYERDATA\CUSTOMISATIONCOLOURPALETTES.MBIN
  a proposito: es la personalizacion del jugador, no fauna.

  ------------------------------------------------------------------
  TRAMPA CONOCIDA: Underbelly
  ------------------------------------------------------------------
  Existe tambien una paleta "BioShip_Underbelly" (naves vivientes). Si el
  match de PRECEDING_KEY_WORDS es por subcadena, "Underbelly" cazara las
  dos y las naves vivientes tambien saldran rojas por debajo.
  --> COMPROBAR EN REPORT.lua cuantas secciones "Underbelly" se tocaron.
      Si son 2 por archivo en vez de 1, hay que acotar el match.
  Ninguna otra de las 5 tiene colisiones de subcadena (verificado contra
  la lista completa de 64 nombres de paleta).

  Archivo objetivo: los 47 *COLOURPALETTES.MBIN / *COLOURPALETTE.MBIN
  Viven todos en NMSARC.Precache.pak
--]]

-- Rojo carne, saturado. Rango 0..1. Alpha no se toca (se queda en 1).
RED_R = "0.750000"
RED_G = "0.030000"
RED_B = "0.030000"

-- Las 5 paletas que usa la piel de las criaturas.
FAUNA_PALETTES = { "Fur", "Scale", "Feather", "Underbelly", "Undercoat" }

-- Los 47 archivos de paletas que contienen esas 5.
PALETTE_FILES =
{
  "METADATA\SIMULATION\SOLARSYSTEM\COLOURS\BASECOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\COLOURS\LEGACYBASECOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\BARREN\BARRENCOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\BARREN\BARRENHQCOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\BARREN\BARRENPEACOCKCOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\BARREN\BARRENRUINSCOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\BURNT\BURNTCOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\BURNT\BURNTREMIX\BURNTREMIXCOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\DEAD\DEADCOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\DESOLATE\DESOLATECOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\FROZEN\FROZENCOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\FROZEN\FROZENHQCOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\GASGIANTS\GASCOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\IRRADIATED\IRRADIATEDCOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\IRRADIATED\IRRADREMIX\IRRADREMIXCOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\JUNGLE\JUNGLECOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\LAVA\LAVACOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\LUSH\LUSHCOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\LUSH\LUSHBUBBLESCOLOURPALETTE.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\LUSH\LUSHHQCOLOURPALETTE.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\LUSH\LUSHROOMACOLOURPALETTE.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\LUSH\LUSHROOMBCOLOURPALETTE.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\LUSH\LUSHRUINSCOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\LUSH\LUSHULTRACOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\NOXIOUS\NOXIOUSCOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\NOXIOUS\NOXREMIX\NOXREMIXCOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\RADIOACTIVE\RADIOCOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\SCORCHED\SCORCHCOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\SUBZERO\SUBZEROCOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\SUBZERO\SUBZREMIX\SUBZREMIXCOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\SWAMP\SWAMPCOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\TOXIC\TOXICCOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\TOXIC\TOXICEGGSCOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\TOXIC\TOXICSPORESCOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\TOXIC\TOXICTENTACLESCOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\WEIRD\BEAMSTONE\BEAMSCOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\WEIRD\BONESPIRE\BONESPIRECOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\WEIRD\CONTOUR\CONTOURCOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\WEIRD\ELBUBBLE\ELBUBBLECOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\WEIRD\FRACTALCUBE\FRACTCUBECOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\WEIRD\HEXAGON\HEXAGONCOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\WEIRD\HOUDINIPROPS\HOUDINIPROPSCOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\WEIRD\HYDROGARDEN\HYDROGARDENCOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\WEIRD\IRRISHELLS\IRRISHELLSCOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\WEIRD\MSTRUCTURES\MSTRUCTCOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\WEIRD\SHARDS\SHARDSCOLOURPALETTES.MBIN",
  "METADATA\SIMULATION\SOLARSYSTEM\BIOMES\WEIRD\WIRECELLS\WIRECELLSCOLOURPALETTES.MBIN",
}

-- Una entrada por paleta. ALLINSIDESECTION recorre los 64 colores de la
-- seccion y reescribe R/G/B en cada uno, sin salirse de esa paleta.
PALETTE_CHANGES = {}
for _, palette in ipairs(FAUNA_PALETTES) do
  PALETTE_CHANGES[#PALETTE_CHANGES + 1] =
  {
    ["COMMENT"]             = "Paleta "..palette.." -> rojo carne",
    ["PRECEDING_KEY_WORDS"] = { palette },
    ["REPLACE_TYPE"]        = "ALLINSIDESECTION",
    ["VALUE_CHANGE_TABLE"]  =
    {
      {"R", RED_R},
      {"G", RED_G},
      {"B", RED_B},
    }
  }
end

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "HorribleTerror_RedFauna",
["MOD_AUTHOR"]      = "ArDev-ACG",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "Prueba de validacion - pinta de rojo carne las paletas de piel de la fauna (Fur/Scale/Feather/Underbelly/Undercoat) en todos los biomas.",
["MODIFICATIONS"]   =
  {
    {
      ["MBIN_CHANGE_TABLE"] =
      {
        {
          ["MBIN_FILE_SOURCE"]  = PALETTE_FILES,
          ["MXML_CHANGE_TABLE"] = PALETTE_CHANGES,
        },
      }
    },
  },
}
