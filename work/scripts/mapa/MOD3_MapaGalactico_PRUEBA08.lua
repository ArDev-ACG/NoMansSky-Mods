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

DIR_ICONOS = "TEXTURES/UI/FRONTEND/ICONS/QUICKMENU/EMOTES/"
ICONO_1    = DIR_ICONOS.."MOD3_MAPA_01.DDS"
ICONO_2    = DIR_ICONOS.."MOD3_MAPA_02.DDS"
ICONO_3    = DIR_ICONOS.."MOD3_MAPA_03.DDS"

DDS_1 = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\textures\MOD3_MAPA_01.DDS]]
DDS_2 = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\textures\MOD3_MAPA_02.DDS]]
DDS_3 = os.getenv("USERPROFILE") .. [[\NMS_MOD_ZOMBIES\work\textures\MOD3_MAPA_03.DDS]]

EMOTES_MOD3 =
  EMOTE("MOD3_GALMAP_A", "MOD3 Mapa Galactico 1", SCENE_TERMINAL_PUENTE, ESCALA_NORMAL, ICONO_1) ..
  EMOTE("MOD3_GALMAP_B", "MOD3 Mapa Galactico 2", SCENE_TERMINAL_PUENTE, ESCALA_NORMAL, ICONO_2) ..
  EMOTE("MOD3_GALMAP_C", "MOD3 Mapa Galactico 3", SCENE_TERMINAL_PUENTE, ESCALA_NORMAL, ICONO_3)

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "MOD3_MapaGalactico_PRUEBA08",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "PRUEBA 08 del mod 3 (ruta F): tres emotes identicos que invocan el terminal del puente (BRIDGETERMINAL) a escala normal y solo se diferencian en el icono, para elegir el arte del menu de emotes. Experimento, no es un mod publicable.",
["ADD_FILES"] =
  {
    {
      ["COMMENT"]              = "Icono 1: galaxia espiral, BC7 256x256 2 mips, generado con tools/Make-NMSTexture.py",
      ["EXTERNAL_FILE_SOURCE"] = DDS_1,
      ["FILE_DESTINATION"]     = [[TEXTURES\UI\FRONTEND\ICONS\QUICKMENU\EMOTES\MOD3_MAPA_01.DDS]],
    },
    {
      ["COMMENT"]              = "Icono 2: sistema con planetas y orbitas, BC7 256x256 2 mips",
      ["EXTERNAL_FILE_SOURCE"] = DDS_2,
      ["FILE_DESTINATION"]     = [[TEXTURES\UI\FRONTEND\ICONS\QUICKMENU\EMOTES\MOD3_MAPA_02.DDS]],
    },
    {
      ["COMMENT"]              = "Icono 3: trazo lineal turquesa, BC7 256x256 2 mips",
      ["EXTERNAL_FILE_SOURCE"] = DDS_3,
      ["FILE_DESTINATION"]     = [[TEXTURES\UI\FRONTEND\ICONS\QUICKMENU\EMOTES\MOD3_MAPA_03.DDS]],
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
              ["COMMENT"]            = "PRUEBA 08: tres emotes con el mismo prop y distinto icono",
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
