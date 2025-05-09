local L = LibStub("AceLocale-3.0"):NewLocale("VUIKeystones", "enUS", true)

if not L then return end

-- General strings
L["Enable"] = true
L["Enable/disable VUI Keystones"] = true
L["General"] = true
L["Options"] = true

-- Config options
L["config_characterConfig"] = "Per-character configuration"
L["config_progressTooltip"] = "Show progress each enemy gives on their tooltip"
L["config_progressTooltipMDT"] = "Use Mythic Dungeon Tools' data for the tooltip"
L["config_progressFormat"] = "Enemy Forces Format"
L["config_progressFormat_1"] = "24.19%"
L["config_progressFormat_2"] = "90/372"
L["config_progressFormat_3"] = "24.19% - 90/372"
L["config_progressFormat_4"] = "24.19% (75.81%)"
L["config_progressFormat_5"] = "90/372 (282)"
L["config_progressFormat_6"] = "24.19% (75.81%) - 90/372 (282)"
L["config_splitsFormat"] = "Objective Splits Display"
L["config_splitsFormat_1"] = "Disabled"
L["config_splitsFormat_2"] = "Time from start"
L["config_splitsFormat_3"] = "Relative to previous"
L["config_autoGossip"] = "Automatically select gossip entries during Mythic Keystone dungeons (ex: Odyn)"
L["config_cosRumors"] = "Output to party chat clues from \"Chatty Rumormonger\" during Court of Stars"
L["config_silverGoldTimer"] = "Show timer for both 2 and 3 bonus chests at same time"
L["config_completionMessage"] = "Show message with final times on completion of a Mythic Keystone dungeon"
L["config_showSplits"] = "Show split time for each objective in objective tracker"
L["config_smallAffixes"] = "Show smaller affix icons on the keystone and objectives tracker"
L["config_deathTracker"] = "Show death counter under objective tracker"
L["config_recordSplits"] = "Record and save your best splits for each dungeon"
L["config_resetPopup"] = "Show popup for keystone reset"
L["config_announceKeystones"] = "Announce your keystone to party chat when inspected"
L["config_schedule"] = "Show the schedule of affixes for future weeks"
L["config_showLevelModifier"] = "Show level modifier for trash count below objectives"
L["config_hideTalkingHead"] = "Hide talking head frame for dungeon bosses"

-- Keystone related
L["keystoneFormat"] = "[Keystone: %s - Level %d]"
L["completion0"] = "Timer expired for %s with %s, you were %s over the time limit."
L["completion1"] = "Beat the timer for %s in %s. You were %s ahead of the timer, and missed +2 by %s."
L["completion2"] = "Beat the timer for %s with +2 in %s. You were %s ahead of the timer, and missed +3 by %s."
L["completion3"] = "Beat the timer for %s with +3 in %s. You were %s ahead of the timer!"