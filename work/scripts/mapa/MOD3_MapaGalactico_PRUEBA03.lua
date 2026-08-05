RECOMPENSA_MOD3_GALMAP =
[[
		<Property name="InteractionTable" value="GcGenericRewardTableEntry" _id="R_MOD3_GALMAP">
			<Property name="Id" value="R_MOD3_GALMAP" />
			<Property name="List" value="GcRewardTableItemList">
				<Property name="RewardChoice" value="GiveAll" />
				<Property name="OverrideZeroSeed" value="false" />
				<Property name="UseInventoryChoiceOverride" value="false" />
				<Property name="IncrementStat" value="" />
				<Property name="List">
					<Property name="List" value="GcRewardTableItem" _index="0">
						<Property name="PercentageChance" value="100.000000" />
						<Property name="LabelID" value="" />
						<Property name="Reward" value="GcRewardForceOpenGalaxyMap">
							<Property name="GcRewardForceOpenGalaxyMap">
								<Property name="BlockWarp" value="true" />
							</Property>
						</Property>
					</Property>
					<Property name="List" value="GcRewardTableItem" _index="1">
						<Property name="PercentageChance" value="100.000000" />
						<Property name="LabelID" value="" />
						<Property name="Reward" value="GcRewardMoney">
							<Property name="GcRewardMoney">
								<Property name="AmountMin" value="1234" />
								<Property name="AmountMax" value="1234" />
								<Property name="RoundNumber" value="false" />
								<Property name="Currency" value="GcCurrency">
									<Property name="Currency" value="Units" />
								</Property>
							</Property>
						</Property>
					</Property>
				</Property>
			</Property>
		</Property>
]]

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "MOD3_MapaGalactico_PRUEBA03",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "PRUEBA 03 del mod 3 (ruta D): el Analizador de Planos entrega GcRewardForceOpenGalaxyMap directamente, sin mision, con 1234 unidades de testigo. Experimento, no es un mod publicable.",
["MODIFICATIONS"]   =
  {
    {
      ["MBIN_CHANGE_TABLE"] =
      {
        {
          ["MBIN_FILE_SOURCE"] = "METADATA\REALITY\TABLES\REWARDTABLE.MBIN",
          ["MXML_CHANGE_TABLE"] =
          {
            {
              ["COMMENT"]            = "PRUEBA 03: R_MOD3_GALMAP = abre mapa + 1234 unidades de testigo",
              ["SPECIAL_KEY_WORDS"]  = {"Id", "JUNK"},
              ["ADD_OPTION"]         = "ADDbeforeSECTION",
              ["VALUE_CHANGE_TABLE"] = {{"IGNORE", "IGNORE"}},
              ["ADD"]                = RECOMPENSA_MOD3_GALMAP
            },
          }
        },
        {
          ["MBIN_FILE_SOURCE"] = "MODELS\PLANETS\BIOMES\COMMON\BUILDINGS\PARTS\BUILDABLEPARTS\TECH\BLUEPRINTANALYSER\ENTITIES\BLUEPRINTANALYSER.ENTITY.MBIN",
          ["MXML_CHANGE_TABLE"] =
          {
            {
              ["COMMENT"]              = "PRUEBA 03: el analizador entrega R_MOD3_GALMAP",
              ["PRECEDING_KEY_WORDS"]  = {"StoryUtilityOverrideData"},
              ["VALUE_CHANGE_TABLE"]   =
              {
                {"Reward", "R_MOD3_GALMAP"},
              }
            },
          }
        },
      }
    }
  }
}
