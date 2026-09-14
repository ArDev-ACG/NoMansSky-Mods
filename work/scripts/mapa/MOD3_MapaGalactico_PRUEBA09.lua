function EMOTE(id, title, model, scale, icon)
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
    '\t\t\t\t<Property name="Filename" value="'..icon..'" />\n'..
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
ESCALA_NORMAL         = "0.100000"

ICONO_1 = "TEXTURES/UI/FRONTEND/ICONS/QUICKMENU/EMOTES/MOD3_MAPA_01.DDS"
DDS_1   = os.getenv("USERPROFILE") .. [[\MODS\NMS_MOD_ZOMBIES\work\textures\MOD3_MAPA_01.DDS]]

ENTIDAD_MAPA = [[MODELS\COMMON\SPACECRAFT\COMMONPARTS\HANGARINTERIORPARTS\BRIDGETERMINAL\ENTITIES\GALAXYMAPTERMINAL.ENTITY.MBIN]]

EMOTES_MOD3 =
  EMOTE("MOD3_GALMAP", "MOD3 Mapa Galactico", SCENE_TERMINAL_PUENTE, ESCALA_NORMAL, ICONO_1)

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "MOD3_MapaGalactico_PRUEBA09",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "PRUEBA 09 del mod 3 (ruta F): el emote invoca el terminal del puente y ademas despierta el nodo GalaxyMapTerminal, que en vanilla nace con TriggerAction INACTIVE y sin etiqueta. Los otros dos terminales del mismo prop quedan intactos como control. Experimento, no es un mod publicable.",
["ADD_FILES"] =
  {
    {
      ["COMMENT"]              = "Icono elegido en la PRUEBA 08: galaxia espiral, BC7 256x256 2 mips",
      ["EXTERNAL_FILE_SOURCE"] = DDS_1,
      ["FILE_DESTINATION"]     = [[TEXTURES\UI\FRONTEND\ICONS\QUICKMENU\EMOTES\MOD3_MAPA_01.DDS]],
    },
  },
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
              ["COMMENT"]            = "PRUEBA 09: un solo emote, el terminal del puente a escala 0.10",
              ["SPECIAL_KEY_WORDS"]  = {"EmoteID", "EMOTE_WAVE"},
              ["ADD_OPTION"]         = "ADDbeforeSECTION",
              ["VALUE_CHANGE_TABLE"] = {{"IGNORE", "IGNORE"}},
              ["ADD"]                = EMOTES_MOD3
            },
          }
        },
        {
          ["MBIN_FILE_SOURCE"] = ENTIDAD_MAPA,
          ["MXML_CHANGE_TABLE"] =
          {
            {
              ["COMMENT"]            = "PRUEBA 09: TriggerAction INACTIVE -> INTERACT, como los dos terminales hermanos que si dan cartel",
              ["REPLACE_TYPE"]       = "ALL",
              ["VALUE_MATCH"]        = "INACTIVE",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"TriggerAction", "INTERACT"},
              }
            },
            {
              ["COMMENT"]             = "PRUEBA 09: etiqueta del cartel, vacia en vanilla",
              ["PRECEDING_KEY_WORDS"] = {"StoryUtilityOverrideData"},
              ["VALUE_CHANGE_TABLE"]  =
              {
                {"Name", "SHIP_GALACTICMAP"},
              }
            },
          }
        },
      }
    }
  }
}
