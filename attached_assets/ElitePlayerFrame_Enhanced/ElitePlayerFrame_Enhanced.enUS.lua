local addon = (select(2,...))
local L = addon.LOCALISATION
if (addon.LOCALE == "enUS") then
	L[addon.DESCRIPTION] = true	-- Addon description
	-- [ Loading/initialisation/resetting ]
	L["Initialised stage %s (%s/%s)."] = true	-- Formatted with stage name, number of initialised stages, and number of total stages
	L["Uninitialised stage %s (%s/%s)."] = true	-- Formatted with stage name, number of initialised stages, and number of total stages
	L["%s - Frame"] = true	-- Formatted with stage number
	L["%s - Addon"] = true	-- Formatted with stage number
	L["%s - Player"] = true	-- Formatted with stage number
	L["Initialised."] = true
	L["Uninitialised."] = true
	L["an unknown"] = true	-- Unknown game type string
	L["the %s"] = true	-- Known game type string, formatted with game type name
	L["You are attempting to use the %s branch of this addon in %s game type, which is unsupported and won't work."] = true	-- Formatted with branch name, and game type string
	--- [ Settings ]
	L["Used default settings for new %s."] = true	-- Formatted with settings type
	L["Fixed %s settings."] = true	-- Formatted with number of settings fixed
	L["Updated settings for version %s.%s (%s)."] = true	-- Formatted with version and revision number, and branch name
	L["%s settings were reset."] = true	-- Formatted with settings type
	L["Setting %s set to default."] = true	-- Formatted with setting identifier
	L["Missing setting %s updated from %s."] = true	-- Formatted with setting identifiers
	L["Missing setting %s set to default."] = true	-- Formatted with setting identifier
	L["Unused setting %s removed."] = true	-- Formatted with setting identifier
	L["Invalid setting %s removed."] = true	-- Formatted with setting identifier
	L["Invalid setting %s set to default."] = true	-- Formatted with setting identifier
	-- [ Information ]
	--- [ Addon ]
	L["Addon"] = true
	L["Addon information updated."] = true
	L["v%s (%s)"] = true	-- Formatted with version string and branch
	L["addon"] = true	-- Command argument
	L["%s, v%s (%s)."] = true	-- Formatted with addon title, version string, and branch
	--- [ Expansion ]
	L["Expansion"] = true
	L["Current expansion"] = true
	L["Expansion information updated to %s (#%s)."] = true	-- Formatted with expansion name and identifier
	L["Latest expansion"] = true
	L["Latest expansion information updated to %s (#%s)."] = true	-- Formatted with expansion name and identifier
	L["Level %s-%s"] = true	-- Formatted with expansion min and max levels
	L["expansion"] = true	-- Command argument
	L["%s (#%s), level %s-%s."] = true	-- Formatted with expansion name, identifier, and min and max level
	--- [ Character ]
	L["Character"] = true
	L["Character information updated."] = true
	L["Unable to update character information; player not loaded yet."] = true
	L["Level %s"] = true	-- Formatted with character level
	L["character"] = true	-- Command argument
	L["%s, a level %s %s %s %s %s."] = true	-- Formatted with character name, level, faction name, gender name, race name, and class name
	-- [ Settings ]
	L["Disabled"] = true	-- Label
	L["Enabled"] = true	-- Label
	L["%s."] = true	-- Formatted with setting label
	L["%s (%s)."] = true	-- Formatted with setting value and label
	L["%s = %s"] = true	-- Formatted with setting value and label
	--- [ Display ]
	L["Display"] = true
	L["Display of the player frame modifications."] = true	-- Description
	L["display"] = true	-- Command
	L["Toggles the display of the player frame modifications."] = true	-- Command description
	--- [ Frame mode ]
	L["Frame mode"] = true
	L["Selected frame"] = true
	L["A specific frame, or auto (selects the most appropriate frame based on your character and expansion)."] = true	-- Description
	L["frame"] = true	-- Command
	L["Reports or sets the frame mode (%s)."] = true	-- Command description, formatted with a delimited frame mode list
	L["Normal"] = true	-- Label
	L["Auto"] = true	-- Label
	L["Silver"] = true	-- Label
	L["Silver - Winged"] = true	-- Label
	L["Gold"] = true	-- Label
	L["Gold - Winged"] = true	-- Label
	---- [ Textures ]
	L["Standard (Disabled)"] = true	-- Label
	L["Standard"] = true	-- Label
	---- [ Custom ]
	L["%s - %s"] = true	-- Formatted with class name and faction name
	L["Death Knight"] = true
	L["Demon Hunter"] = true
	L["Added custom frame mode (%s: %s)"] = true	-- Formatted with custom frame mode ID and name
	--- [ Class selection ]
	L["Class selection"] = true
	L["Class based frame selection in auto frame mode."] = true	-- Description
	L["class"] = true	-- Command
	L["Toggles class based frame selection in auto frame mode."] = true	-- Command description
	--- [ Faction selection ]
	L["Faction selection"] = true
	L["Faction based frame selection in auto frame mode."] = true	-- Description
	L["faction"] = true	-- Command
	L["Toggles faction based frame selection in auto frame mode."] = true	-- Command description
	--- [ Output levels ]
	L["Output level"] = true
	L["Limits output to messages of the specified level and lower."] = true	-- Description
	L["output"] = true	-- Command
	L["Reports or sets the output level setting (%s)."] = true	-- Command description, formatted with delimited output level list
	L["Critical Errors"] = true	-- Label
	L["Critical Error"] = true	-- Prefix
	L["Errors"] = true	-- Label
	L["Error"] = true	-- Prefix
	L["Notices"] = true	-- Label
	L["Notice"] = true	-- Prefix
	L["Warnings"] = true	-- Label
	L["Warning"] = true	-- Prefix
	L["Debug messages"] = true	-- Label
	L["Debug"] = true	-- Prefix
	-- [ GUI ]
	--- [ Frame points ]
	L["%s point %s/%s is %s, %s, %s, %s, %s."] = true	-- Formatted with frame name, point index, total points, anchor, relative frame name, relative anchor, x offset, and y offset
	L["Set default points for %s."] = true	-- Formatted with frame name
	L["Unable to set default points for %; frame does not exist yet."] = true	-- Formatted with frame name
	L["Unable to set default points for unknown frame."] = true
	--- [ Display updates ]
	L["Expansion info has not changed since the last display update."] = true
	L["Character info has not changed since the last display update."] = true
	L["Forced display update."] = true
	--- [ Texture updates ]
	L["Updated to %s %s texture."] = true	-- Formatted with texture name and layer
	L["Unable to update %s texture position; default points not set yet."] = true	-- Formatted with texture layer
	L["Unable to update %s texture position; frame not loaded yet."] = true	-- Formatted with texture layer
	L["Updated texture resolution to %sx."] = true	-- Formatted with texture resolution factor
	--- [ Rest icon updates ]
	L["Updated rest icon position."] = true
	L["Unable to update rest icon position; default points not set yet."] = true
	L["Unable to update rest icon position; frame not loaded yet."] = true
	-- [ Slash command handlers ]
	L["%s is an invalid command."] = true	-- Formatted with input command
	L["%s is an invalid argument for %s."] = true	-- Formatted with input argument and command
	L["%s [%s]"] = true	-- Formatted with input command and argument(s)
	L["%s [%s-%s]"] = true	-- Formatted with input command, min argument, and max argument
	--- [ Help ]
	L["Help"] = true	-- Prefix
	L["help"] = true	-- Command
	--- [ Information ]
	L["Info"] = true	-- Prefix
	L["info"] = true	-- Command
	L["Reports information about the optional subject."] = true	-- Command description
	--- [ Update ]
	L["update"] = true	-- Command
	L["Forces an update of the player frame modifications."] = true	-- Command description
	--- [ Reset ]
	L["reset"] = true	-- Command
	L["Resets your character's settings to default."] = true	-- Command description
	-- [ Actions ]
	L["Left-Click"] = true	-- Action
	L["Right-Click"] = true	-- Action
	L["Middle-Click"] = true	-- Action
	L["Button4-Click"] = true	-- Action
	L["Button5-Click"] = true	-- Action
	L["Shift"] = true	-- Modifier
	L["Ctrl"] = true	-- Modifier
	L["Alt"] = true	-- Modifier
	L["%s+%s"] = true	-- Formatted with modifier and action
	L["%s to toggle this setting."] = true	-- Formatted with action
	L["%s to cycle this setting forwards."] = true	-- Formatted with action
	L["%s to cycle this setting backwards."] = true	-- Formatted with action
	-- [ Miscellaneous ]
	L[":"] = true	-- Colon for output and label prefixes
	L["|"] = true	-- Pipe for command optional argument delimitation (will be escaped in output)
	L["-"] = true	-- Hyphen for command syntax and description separation
	L[","] = true	-- Comma for list delimitation
end