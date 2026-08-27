function EMOTE(id, title, model, scale)
  return
    '\t\t<Property name="Emotes" value="GcPlayerEmote" _id="'..id..'">\n'..
    '\t\t\t<Property name="Title" value="'..title..'" />\n'..
    '\t\t\t<Property name="ChatText" value="UI_EMOTE_CHAT_HOLO_SYSTEM" />\n'..
    '\t\t\t<Property name="ChatUsesPrefix" value="false" />\n'..
    '\t\t\t<Property name="EmoteID" value="'..id..'" />\n'..
    '\t\t\t<Property name="AnimationName" value="1H_IDLE_HOLO_01" />\n'..
    '\t\t\t<Property name="PropData" value="GcPlayerEmotePropData">\n'..
    '\t\t\t\t<Property name="Model" value="'..model..'" />\n'..
    '\t\t\t\t<Property name="Scale" value="'..scale..'" />\n'..
    '\t\t\t\t<Property name="Hand" value="GcHand">\n'..
    '\t\t\t\t\t<Property name="Hand" value="Left" />\n'..
    '\t\t\t\t</Property>\n'..
    '\t\t\t\t<Property name="IsHologram" value="false" />\n'..
    '\t\t\t\t<Property name="ScanEffectNodeName" value="HoloSystem" />\n'..
    '\t\t\t\t<Property name="ScanEffect" value="GcScanEffectData">\n'..
    '\t\t\t\t\t<Property name="Id" value="" />\n'..
    '\t\t\t\t\t<Property name="ScanEffectType" value="Objects" />\n'..
    '\t\t\t\t\t<Property name="Colour">\n'..
    '\t\t\t\t\t\t<Property name="R" value="0.949020" />\n'..
    '\t\t\t\t\t\t<Property name="G" value="0.470588" />\n'..
    '\t\t\t\t\t\t<Property name="B" value="0.027451" />\n'..
    '\t\t\t\t\t\t<Property name="A" value="1.000000" />\n'..
    '\t\t\t\t\t</Property>\n'..
    '\t\t\t\t\t<Property name="BasecolourIntensity" value="0.350000" />\n'..
    '\t\t\t\t\t<Property name="ScanlinesSeparation" value="0.350000" />\n'..
    '\t\t\t\t\t<Property name="FresnelIntensity" value="3.000000" />\n'..
    '\t\t\t\t\t<Property name="GlowIntensity" value="0.000000" />\n'..
    '\t\t\t\t\t<Property name="WaveOffset" value="0.000000" />\n'..
    '\t\t\t\t\t<Property name="WaveActive" value="true" />\n'..
    '\t\t\t\t\t<Property name="FixedUpAxis" value="false" />\n'..
    '\t\t\t\t\t<Property name="Transparent" value="false" />\n'..
    '\t\t\t\t\t<Property name="Additive" value="false" />\n'..
    '\t\t\t\t\t<Property name="ModelFade" value="false" />\n'..
    '\t\t\t\t\t<Property name="FadeInTime" value="0.000000" />\n'..
    '\t\t\t\t\t<Property name="FadeOutTime" value="0.000000" />\n'..
    '\t\t\t\t\t<Property name="UseBaseColourForAll" value="false" />\n'..
    '\t\t\t\t</Property>\n'..
    '\t\t\t\t<Property name="DelayTime" value="0.300000" />\n'..
    '\t\t\t</Property>\n'..
    '\t\t\t<Property name="Icon" value="TkTextureResource">\n'..
    '\t\t\t\t<Property name="Filename" value="TEXTURES/UI/FRONTEND/ICONS/QUICKMENU/EMOTES/HOLOSYSTEM.DDS" />\n'..
    '\t\t\t</Property>\n'..
    '\t\t\t<Property name="LinkedSpecialID" value="" />\n'..
    '\t\t\t<Property name="NeverShowInMenu" value="false" />\n'..
    '\t\t\t<Property name="LoopAnimUntilMove" value="EMOTE_HOLO" />\n'..
    '\t\t\t<Property name="CloseMenuOnSelect" value="false" />\n'..
    '\t\t\t<Property name="MoveToCancel" value="false" />\n'..
    '\t\t\t<Property name="GekAnimationName" value="" />\n'..
    '\t\t\t<Property name="GekLoopAnimUntilMove" value="" />\n'..
    '\t\t\t<Property name="AvailableUnderwater" value="false" />\n'..
    '\t\t\t<Property name="RidingAnimationName" value="" />\n'..
    '\t\t\t<Property name="IsPetCommand" value="false" />\n'..
    '\t\t\t<Property name="PetCommandTitle" value="" />\n'..
    '\t\t\t<Property name="PetCommandIcon" value="TkTextureResource">\n'..
    '\t\t\t\t<Property name="Filename" value="" />\n'..
    '\t\t\t</Property>\n'..
    '\t\t</Property>\n'
end

SCENE_TERMINAL_PUENTE = "MODELS/COMMON/SPACECRAFT/COMMONPARTS/HANGARINTERIORPARTS/BRIDGETERMINAL.SCENE.MBIN"
SCENE_TELEPORTADOR    = "MODELS/PLANETS/BIOMES/COMMON/BUILDINGS/PARTS/COMMONPARTS/TELEPORTER_STATION.SCENE.MBIN"

EMOTES_MOD3 =
  EMOTE("MOD3_GALMAP",   "MOD3 Mapa Galactico",   SCENE_TERMINAL_PUENTE, "0.100000") ..
  EMOTE("MOD3_GALMAP_S", "MOD3 Mapa Galactico S", SCENE_TERMINAL_PUENTE, "0.010000") ..
  EMOTE("MOD3_TELEPORT", "MOD3 Teleportador",     SCENE_TELEPORTADOR,    "0.010000")

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "MOD3_MapaGalactico_PRUEBA07",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "PRUEBA 07 del mod 3 (ruta F, emote que invoca una SCENE con interaccion): tres emotes nuevos en EMOTEMENU. Dos invocan el terminal del puente (BRIDGETERMINAL) a dos escalas y uno el teleportador de estacion como control. Experimento, no es un mod publicable.",
["MODIFICATIONS"]   =
  {
    {
      ["MBIN_CHANGE_TABLE"] =
      {
        {
          ["MBIN_FILE_SOURCE"] = "METADATA\UI\EMOTEMENU.MBIN",
          ["MXML_CHANGE_TABLE"] =
          {
            {
              ["COMMENT"]            = "PRUEBA 07: tres emotes que invocan SCENEs con componente de interaccion",
              ["SPECIAL_KEY_WORDS"]  = {"EmoteID", "EMOTE_WAVE"},
              ["ADD_OPTION"]         = "ADDbeforeSECTION",
              ["VALUE_CHANGE_TABLE"] = {{"IGNORE", "IGNORE"}},
              ["ADD"]                = EMOTES_MOD3
            },
          }
        },
      }
    }
  }
}
