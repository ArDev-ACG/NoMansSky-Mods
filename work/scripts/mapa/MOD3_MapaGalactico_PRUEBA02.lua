VERSION_MAX = 37

FINAL_STAGE_VERSIONS = ""
STAGE_VERSIONS       = ""

for v = 1, VERSION_MAX do
  local i = v - 1
  FINAL_STAGE_VERSIONS = FINAL_STAGE_VERSIONS ..
    '\t\t\t\t<Property name="FinalStageVersions" value="GcGenericMissionVersionProgress" _index="'..i..'">\n'..
    '\t\t\t\t\t<Property name="Version" value="'..v..'" />\n'..
    '\t\t\t\t\t<Property name="Progress" value="1" />\n'..
    '\t\t\t\t</Property>\n'
  STAGE_VERSIONS = STAGE_VERSIONS ..
    '\t\t\t\t\t\t<Property name="Versions" value="GcGenericMissionVersionProgress" _index="'..i..'">\n'..
    '\t\t\t\t\t\t\t<Property name="Version" value="'..v..'" />\n'..
    '\t\t\t\t\t\t\t<Property name="Progress" value="0" />\n'..
    '\t\t\t\t\t\t</Property>\n'
end

MISSION_HEAD =
[[
		<Property name="Missions" value="GcGenericMissionSequence" _id="MOD3_GALMAP">
			<Property name="MissionID" value="MOD3_GALMAP" />
			<Property name="MissionClass" value="Secondary" />
			<Property name="MissionIsCritical" value="false" />
			<Property name="MissionObjective" value="" />
			<Property name="MissionTitles" value="GcNumberedTextList">
				<Property name="Format" value="" />
				<Property name="Count" value="1" />
			</Property>
			<Property name="MissionSubtitles" value="GcNumberedTextList">
				<Property name="Format" value="" />
				<Property name="Count" value="1" />
			</Property>
			<Property name="MissionDescriptions" value="GcNumberedTextList">
				<Property name="Format" value="" />
				<Property name="Count" value="1" />
			</Property>
			<Property name="SeasonalLogTextOverrides" value="GcSeasonalLogOverrides">
				<Property name="ApplicableSeasonNumbers" />
				<Property name="MissionTitle" value="" />
				<Property name="MissionSubtitle" value="" />
				<Property name="MissionDescription" value="" />
			</Property>
			<Property name="MissionDescSwitchOverride" value="" />
			<Property name="MissionProcDescriptionHeader" value="GcNumberedTextList">
				<Property name="Format" value="" />
				<Property name="Count" value="1" />
			</Property>
			<Property name="MissionProcDescriptionA" value="GcNumberedTextList">
				<Property name="Format" value="" />
				<Property name="Count" value="1" />
			</Property>
			<Property name="MissionProcDescriptionB" value="GcNumberedTextList">
				<Property name="Format" value="" />
				<Property name="Count" value="1" />
			</Property>
			<Property name="MissionProcDescriptionC" value="GcNumberedTextList">
				<Property name="Format" value="" />
				<Property name="Count" value="1" />
			</Property>
			<Property name="UseScanEventDetailsInLogInfo" value="false" />
			<Property name="UseFirstPurpleSystemDetailsInLogInfo" value="false" />
			<Property name="MissionIcon" value="TkTextureResource">
				<Property name="Filename" value="" />
			</Property>
			<Property name="MissionIconSelected" value="TkTextureResource">
				<Property name="Filename" value="" />
			</Property>
			<Property name="MissionIconNotSelected" value="TkTextureResource">
				<Property name="Filename" value="" />
			</Property>
			<Property name="MissionPriority" value="-1" />
			<Property name="MissionCategory" value="GcMissionCategory">
				<Property name="MissionCategory" value="Mission" />
			</Property>
			<Property name="MissionPageHint" value="GcMissionPageHint">
				<Property name="MissionPageHint" value="None" />
			</Property>
			<Property name="MissionPageLocID" value="" />
			<Property name="MissionBuildMenuHint" value="" />
			<Property name="MissionHasColourOverride" value="false" />
			<Property name="MissionColourOverride">
				<Property name="R" value="1.000000" />
				<Property name="G" value="1.000000" />
				<Property name="B" value="1.000000" />
				<Property name="A" value="1.000000" />
			</Property>
			<Property name="BeginCheckFrequency" value="1" />
			<Property name="WikiMissionBlockedBySeasons" />
			<Property name="DefaultItems" value="GcDefaultMissionItemsTable">
				<Property name="PrimarySubstances" />
				<Property name="SecondarySubstances" />
				<Property name="PrimaryProducts" />
				<Property name="SecondaryProducts" />
				<Property name="AmountMin" value="0" />
				<Property name="AmountMax" value="0" />
				<Property name="AmountShouldBeRoundNumber" value="false" />
			</Property>
			<Property name="PrefixTitle" value="true" />
			<Property name="NextMissionHint" value="" />
			<Property name="MessageComplete" value="Never" />
			<Property name="MessageStart" value="Never" />
			<Property name="MissionBoardOptions" value="GcMissionBoardOptions">
				<Property name="Type" value="GcMissionType">
					<Property name="MissionType" value="SpaceCombat" />
				</Property>
				<Property name="Difficulty" value="GcMissionDifficulty">
					<Property name="MissionDifficulty" value="Normal" />
				</Property>
				<Property name="MinRank" value="0" />
				<Property name="CloseMissionGiver" value="false" />
				<Property name="IsGuildShopMission" value="false" />
				<Property name="IsPlanetProcMission" value="false" />
				<Property name="IsMultiplayerEventMission" value="false" />
				<Property name="RewardPenaltyOnAbandon" value="" />
				<Property name="Faction" />
				<Property name="Weighting" value="100" />
				<Property name="IgnoreCalculatedObjective" value="false" />
				<Property name="MultiplayerMissionInitialWarpScanEvent" value="" />
				<Property name="DefaultItemInitialWarpScanEvents" />
				<Property name="DefaultItemTypeForInitialWarp" value="None" />
				<Property name="BasePartBlueprints" />
			</Property>
			<Property name="AutoStart" value="None" />
			<Property name="RestartOnCompletion" value="false" />
			<Property name="CancelSetsComplete" value="false" />
			<Property name="Dialog" value="GcAlienPuzzleTable">
				<Property name="Table" />
			</Property>
			<Property name="ScanEvents" />
			<Property name="Rewards">
				<Property name="Rewards" value="GcGenericRewardTableEntry" _id="R_MOD3_GALMAP">
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
						</Property>
					</Property>
				</Property>
			</Property>
			<Property name="Costs" />
			<Property name="TradingDataOverride" value="GcTradeData">
				<Property name="AlwaysPresentProducts" />
				<Property name="AlwaysPresentSubstances" />
				<Property name="OptionalProducts" />
				<Property name="OptionalSubstances" />
				<Property name="AlwaysConsideredBarterProducts" />
				<Property name="BarterAcceptanceCurve" value="TkCurveType">
					<Property name="Curve" value="Linear" />
				</Property>
				<Property name="BarterPriceMultiplier" value="1.000000" />
				<Property name="BarterItemPreferenceFloor" value="0.500000" />
				<Property name="MinItemsForSale" value="5" />
				<Property name="MaxItemsForSale" value="15" />
				<Property name="PercentageOfItemsAreProducts" value="0.300000" />
				<Property name="BuyPriceIncreaseRedThreshold" value="20.000000" />
				<Property name="BuyPriceDecreaseGreenThreshold" value="-10.000000" />
				<Property name="SellPriceIncreaseGreenThreshold" value="10.000000" />
				<Property name="SellPriceDecreaseRedThreshold" value="-20.000000" />
				<Property name="ShowSeasonRewards" value="false" />
				<Property name="UseBarterForBuy" value="false" />
				<Property name="MinAmountOfProductAvailable">
					<Property name="Poor" value="10" />
					<Property name="Average" value="10" />
					<Property name="Wealthy" value="10" />
					<Property name="Pirate" value="10" />
				</Property>
				<Property name="MaxAmountOfProductAvailable">
					<Property name="Poor" value="100" />
					<Property name="Average" value="100" />
					<Property name="Wealthy" value="100" />
					<Property name="Pirate" value="100" />
				</Property>
				<Property name="MinAmountOfSubstanceAvailable">
					<Property name="Poor" value="100" />
					<Property name="Average" value="100" />
					<Property name="Wealthy" value="100" />
					<Property name="Pirate" value="100" />
				</Property>
				<Property name="MaxAmountOfSubstanceAvailable">
					<Property name="Poor" value="1000" />
					<Property name="Average" value="1000" />
					<Property name="Wealthy" value="1000" />
					<Property name="Pirate" value="1000" />
				</Property>
				<Property name="MinExtraSystemProducts">
					<Property name="Poor" value="2" />
					<Property name="Average" value="2" />
					<Property name="Wealthy" value="2" />
					<Property name="Pirate" value="2" />
				</Property>
				<Property name="MaxExtraSystemProducts">
					<Property name="Poor" value="4" />
					<Property name="Average" value="4" />
					<Property name="Wealthy" value="4" />
					<Property name="Pirate" value="4" />
				</Property>
				<Property name="TradeProductsPriceImprovements">
					<Property name="Poor" value="0.000000" />
					<Property name="Average" value="0.000000" />
					<Property name="Wealthy" value="0.000000" />
					<Property name="Pirate" value="0.000000" />
				</Property>
			</Property>
			<Property name="StartConditionTest" value="GcMissionConditionTest">
				<Property name="ConditionTest" value="AnyFalse" />
			</Property>
			<Property name="CancelConditionTest" value="GcMissionConditionTest">
				<Property name="ConditionTest" value="AnyFalse" />
			</Property>
			<Property name="StartIsCancel" value="false" />
			<Property name="StartingConditions" />
			<Property name="CancelingConditions" />
			<Property name="FinalStageVersions">
]]

MISSION_MID =
[[			</Property>
			<Property name="Stages">
				<Property name="Stages" value="GcGenericMissionStage" _index="0">
					<Property name="Versions">
]]

MISSION_TAIL =
[[					</Property>
					<Property name="Stage" value="GcMissionSequenceReward">
						<Property name="GcMissionSequenceReward">
							<Property name="Message" value="" />
							<Property name="Reward" value="R_MOD3_GALMAP" />
							<Property name="DoMissionBoardOverride" value="false" />
							<Property name="Silent" value="true" />
							<Property name="RewardInventoryOverride" value="None" />
							<Property name="DebugText" value="MOD3 abre mapa galactico" />
						</Property>
					</Property>
				</Property>
			</Property>
			<Property name="ForcesBuildMenuHint" value="false" />
			<Property name="IsProceduralAllowed" value="false" />
			<Property name="IsRecurring" value="false" />
			<Property name="IsLegacy" value="false" />
			<Property name="BlocksPinning" value="false" />
			<Property name="CanRenounce" value="false" />
			<Property name="UseCommunityMissionForLog" value="" />
			<Property name="TakeCommunityMissionIDFromSeasonData" value="false" />
			<Property name="TelemetryUpload" value="false" />
			<Property name="UseSeasonTitleOverride" value="false" />
			<Property name="RequiresSettlement" value="false" />
			<Property name="SettlementAbandonOSD" value="" />
		</Property>
]]

MISSION_MOD3_GALMAP = MISSION_HEAD .. FINAL_STAGE_VERSIONS ..
                      MISSION_MID  .. STAGE_VERSIONS ..
                      MISSION_TAIL

NMS_MOD_DEFINITION_CONTAINER =
{
["MOD_FILENAME"]    = "MOD3_MapaGalactico_PRUEBA02",
["MOD_AUTHOR"]      = "AldrichDDD",
["NMS_VERSION"]     = "6.45",
["MOD_DESCRIPTION"] = "PRUEBA 02 del mod 3 (ruta C): el Modulo de Mensajes lanza una mision que entrega GcRewardForceOpenGalaxyMap. Experimento, no es un mod publicable.",
["MODIFICATIONS"]   =
  {
    {
      ["MBIN_CHANGE_TABLE"] =
      {
        {
          ["MBIN_FILE_SOURCE"] = "MODELS\PLANETS\BIOMES\COMMON\BUILDINGS\PARTS\BUILDABLEPARTS\TECH\MESSAGEMODULE\ENTITIES\MESSAGEMODULE.ENTITY.MBIN",
          ["MXML_CHANGE_TABLE"] =
          {
            {
              ["COMMENT"]              = "PRUEBA 02: al usar el modulo, arranca MOD3_GALMAP",
              ["PRECEDING_KEY_WORDS"]  = {"GcInteractionComponentData"},
              ["VALUE_CHANGE_TABLE"]   =
              {
                {"StartMissionOnUse", "MOD3_GALMAP"},
              }
            },
          }
        },
        {
          ["MBIN_FILE_SOURCE"] = "METADATA\SIMULATION\MISSIONS\TABLES\STARTEDONUSEMISSIONTABLE.MBIN",
          ["MXML_CHANGE_TABLE"] =
          {
            {
              ["COMMENT"]            = "PRUEBA 02: mision MOD3_GALMAP con GcRewardForceOpenGalaxyMap",
              ["SPECIAL_KEY_WORDS"]  = {"MissionID", "SENTINEL_CRASH"},
              ["ADD_OPTION"]         = "ADDbeforeSECTION",
              ["VALUE_CHANGE_TABLE"] = {{"IGNORE", "IGNORE"}},
              ["ADD"]                = MISSION_MOD3_GALMAP
            },
          }
        },
      }
    }
  }
}
