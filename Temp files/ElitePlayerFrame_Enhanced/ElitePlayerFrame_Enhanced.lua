-- [ Namespace ]
local addon = (select(2,...))
-- [ Constants ]
addon.NAME = (select(1,...))
addon.SHORT_NAME = "EPF"
addon.TITLE, addon.DESCRIPTION = select(2,C_AddOns.GetAddOnInfo(addon.NAME))
addon.VERSION_AND_REVISION = C_AddOns.GetAddOnMetadata(addon.NAME,"Version")
addon.VERSION, addon.REVISION = addon.VERSION_AND_REVISION:match("(%d+%.%d+)%.(%d+)")
addon.BRANCH = C_AddOns.GetAddOnMetadata(addon.NAME,"X-Branch")
addon.SUPPORTED_GAME_TYPES_STRING = C_AddOns.GetAddOnMetadata(addon.NAME,"AllowLoadGameType") or "all"
addon.SUPPORTED_GAME_TYPES = {}
addon.ICON = C_AddOns.GetAddOnMetadata(addon.NAME,"IconTexture")
addon.ICON_TEXTURE_STRING_FORMAT = "|T%s:%s:%s|t"
addon.ICON_ATLAS_STRING_FORMAT = "|A:%s:%s:%s|a"
addon.ICON_STRING_FORMAT = addon.ICON and addon.ICON_TEXTURE_STRING_FORMAT
if not addon.ICON then
	addon.ICON = C_AddOns.GetAddOnMetadata(addon.NAME,"IconAtlas")
	addon.ICON_STRING_FORMAT = addon.ICON and addon.ICON_ATLAS_STRING_FORMAT or ""
end
addon.ICON_WIDTH = 97
addon.ICON_HEIGHT = 93
addon.ICON_STRING = format(addon.ICON_STRING_FORMAT,addon.ICON,0,addon.ICON_WIDTH/addon.ICON_HEIGHT)
addon.CHILDREN = {}
addon.MIXINS = {}
addon.HOOKS = {}
--- [ Localisation ]
addon.LOCALE = GetLocale()
addon.LOCALISATION = setmetatable({},{
	__index = function (t,k)
		local v = tostring(k)
		rawset(t,k,v)
		return v
	end,
	__newindex = function(t,k,v)
		if v == true then rawset(t,k,k) else rawset(t,k,v) end
	end
})
local L = addon.LOCALISATION
--- [ Customisation ]
addon.CUSTOM_FRAME_MODES = {}
--- [ Output levels ]
addon.CRITICAL_ERROR_LEVEL = 0
addon.ERROR_LEVEL = 1
addon.WARNING_LEVEL = 2
addon.NOTICE_LEVEL = 3
addon.DEBUG_LEVEL = 4
addon.DEFAULT_OUTPUT_LEVEL = addon.NOTICE_LEVEL
--- [ Resolution ]
addon.BASE_RESOLUTION = 768	-- Hardcoded base resolution height value for textures
--- [ Observed frames ]
addon.PLAYER_FRAME = "PlayerFrame"
addon.PLAYER_CONTAINER_FRAME = addon.PLAYER_FRAME.."Container"
addon.PLAYER_TEXTURE_FRAME = "FrameTexture"
addon.PLAYER_CONTENT_FRAME = addon.PLAYER_FRAME.."Content"
addon.PLAYER_CONTEXTUAL_CONTENT_FRAME = addon.PLAYER_CONTENT_FRAME.."Contextual"
addon.PLAYER_REST_ICON_FRAME = "PlayerRestLoop"
--- [ Colors ]
addon.COLOR = CreateColor(0.8,0.667,0.2)	-- CCAA33
local DISABLED_FONT_COLOR = CreateColor(1,0.2,0.2)	-- FF3333
local ENABLED_FONT_COLOR = CreateColor(0.2,1,0.2)	-- 33FF33
--- [ Game types ]
addon.GAME_TYPE_TAG_MAPS = {
	["all"] = {
		["tags"] = {"standard","plunderstorm"},
		["is"] = {
			["all"] = true
		}
	},
	["standard"] = {
		["tags"] = {"mainline","classic"},
		["is"] = {
			["standard"] = true,
			["all"] = true
		}
	},
	["mainline"] = {
		["is"] = {
			["mainline"] = true,
			["all"] = true,
			["standard"] = true
		}
	},
	["classic"] = {
		["tags"] = {"vanilla","tbc","wrath","cata","mists"},
		["is"] = {
			["classic"] = true,
			["all"] = true,
			["standard"] = true
		}
	},
	["vanilla"] = {
		["is"] = {
			["all"] = true,
			["standard"] = true,
			["classic"] = true
		}
	},
	["tbc"] = {
		["is"] = {
			["tbc"] = true,
			["all"] = true,
			["standard"] = true,
			["classic"] = true
		}
	},
	["wrath"] = {
		["is"] = {
			["wrath"] = true,
			["all"] = true,
			["standard"] = true,
			["classic"] = true
		}
	},
	["cata"] = {
		["is"] = {
			["cata"] = true,
			["all"] = true,
			["standard"] = true,
			["classic"] = true
		}
	},
	["mists"] = {
		["is"] = {
			["mists"] = true,
			["all"] = true,
			["standard"] = true,
			["classic"] = true
		}
	},
	["plunderstorm"] = {
		["is"] = {
			["plunderstorm"] = true,
			["all"] = true,
			["mainline"] = true
		}
	}
}
--- [ Expansions ]
addon.EXPANSION_COLORS = {	-- Hardcoded colours for known expansions
	[LE_EXPANSION_CLASSIC] = CreateColor(1,0.8,0.2),	-- FFCC33
	[LE_EXPANSION_BURNING_CRUSADE] = CreateColor(0.6,0.8,0.2),	-- 99CC33
	[LE_EXPANSION_WRATH_OF_THE_LICH_KING] = CreateColor(0.2,0.6,1),	-- 3399FF
	[LE_EXPANSION_CATACLYSM] = CreateColor(1,0.4,0.2),	-- FF6633
	[LE_EXPANSION_MISTS_OF_PANDARIA] = CreateColor(0.2,0.6,0.467),	-- 339977
	[LE_EXPANSION_WARLORDS_OF_DRAENOR] = CreateColor(0.8,0.4,0.2),	-- CC6633
	[LE_EXPANSION_LEGION] = CreateColor(0.933,1,0.4),	-- EEFF66
	[LE_EXPANSION_BATTLE_FOR_AZEROTH] = CreateColor(0.2,0.467,0.733),	-- 3377BB
	[LE_EXPANSION_SHADOWLANDS] = CreateColor(0.933,0.867,0.733),	-- EEDDBB
	[LE_EXPANSION_DRAGONFLIGHT] = CreateColor(0.8,0.8,0.8),	-- CCCCCC
	[LE_EXPANSION_WAR_WITHIN] = CreateColor(1,0.6,0.2),	-- FF9933
	[LE_EXPANSION_MIDNIGHT or LE_EXPANSION_WAR_WITHIN+1] = CreateColor(0.6,0.4,1),	-- 9966FF
	[LE_EXPANSION_LAST_TITAN or LE_EXPANSION_WAR_WITHIN+2] = CreateColor(1,0.933,0.6),	-- FFEE99
}
addon.INTRO_MAX_LEVEL = 10	-- Hardcoded level cap for starting experience
--- [ Settings ]
addon.SETTINGS_NAME = addon.NAME.."_Settings"
---- [ Characters ]
addon.CHAR_SETTINGS_STRUCTURE = {
	["version"] = "string",
	["outputLevel"] = "number",
	["display"] = "boolean",
	["frameMode"] = "number",
	["classSelection"] = "boolean",
	["factionSelection"] = "boolean",
}
addon.CHAR_SETTINGS_DEFAULTS = {
	["version"] = addon.VERSION.."."..addon.REVISION.."-"..addon.BRANCH,
	["outputLevel"] = addon.DEFAULT_OUTPUT_LEVEL,
	["display"] = true,
	["frameMode"] = 1,
	["classSelection"] = true,
	["factionSelection"] = true,
}
addon.CHAR_SETTINGS_CONVERSIONS = {
	["outputLevel"] = function(settings,structure)
		local k = "debug"
		if settings[k] then
			return settings[k], k
		end
	end,
	["frameMode"] = function(settings,structure)
		local k = "mode"
		if settings[k] then
			return settings[k], k
		end
	end,
	["classSelection"] = function(settings,structure)
		local k = "classMode"
		if settings[k] then
			return settings[k] ~= 0, k
		end
	end,
	["factionSelection"] = function(settings,structure)
		local k = "factionMode"
		if settings[k] then
			return settings[k] == 0, k
		end
	end,
}
-- [ Initialisation ]
--- [ Stages ]
addon.isInitialised = false
addon.initialisationStages = {{["state"] = false},{["state"] = false},{["state"] = false}}
function addon:InitialiseStage(stage,value)
	if not stage then return end
	if value == nil then
		value = true
	end
	local tailcalls = {}
	if value and not self.initialisationStages[stage].state then	-- Initialising an uninitialised stage
		if stage == 1 then
			-- [ Localisation ]
			self.RunOnce("InitialiseStage1Localisation",function ()
				--- [ Constants ]
				self.DESCRIPTION = L[self.DESCRIPTION]
				---- [ Output levels ]
				self.OUTPUT_LEVELS = {}
				self:AddOutputLevel(self.CRITICAL_ERROR_LEVEL,L["Critical Errors"],L["Critical Error"],DISABLED_FONT_COLOR)
				self:AddOutputLevel(self.ERROR_LEVEL,L["Errors"],L["Error"],DISABLED_FONT_COLOR)
				self:AddOutputLevel(self.WARNING_LEVEL,L["Warnings"],L["Warning"],CreateColor(1,0.8,0.2))	-- FFCC33
				self:AddOutputLevel(self.NOTICE_LEVEL,L["Notices"],L["Notice"],CreateColor(0.4,0.4,1))	-- 6666FF
				self:AddOutputLevel(self.DEBUG_LEVEL,L["Debug messages"],L["Debug"],LIGHTGRAY_FONT_COLOR)
				---- [ Slash commands ]
				for i,v in ipairs(self.SLASHCMD_INDEX) do
					self.SLASHCMDS[L[v]] = {
						["id"] = i,
						["name"] = v,
						["localisedName"] = L[v],
						["handler"] = self.SLASHCMD_HANDLERS[v],
						["helpHandler"] = self.SLASHCMD_HELP_HANDLERS[v],
					}
					self.L_SLASHCMD_INDEX[i] = L[v]
					----- [ Arguments ]
					if self.SLASHCMD_ARG_INDEX[v] then
						self.SLASHCMDS[L[v]].arguments = {}
						self.L_SLASHCMD_ARG_INDEX[L[v]] = {}
						for ii,vv in ipairs(self.SLASHCMD_ARG_INDEX[v]) do
							self.SLASHCMDS[L[v]].arguments[L[vv]] = {
								["id"] = ii,
								["name"] = vv,
								["localisedName"] = L[vv],
							}
							self.L_SLASHCMD_ARG_INDEX[L[v]][ii] = L[vv]
						end
					end
				end
				---- [ Game types ]
				self.GAME_TYPES = {}
				if WOW_PROJECT_MAINLINE then self:AddGameType(WOW_PROJECT_MAINLINE,WOWLABS_MAINLINE,"mainline") end
				if WOW_PROJECT_CLASSIC then self:AddGameType(WOW_PROJECT_CLASSIC,EXPANSION_NAME0,"vanilla") end
				if WOW_PROJECT_BURNING_CRUSADE_CLASSIC then self:AddGameType(WOW_PROJECT_BURNING_CRUSADE_CLASSIC,EXPANSION_NAME1.." "..EXPANSION_NAME0,"tbc") end
				if WOW_PROJECT_WRATH_CLASSIC then self:AddGameType(WOW_PROJECT_WRATH_CLASSIC,EXPANSION_NAME2.." "..EXPANSION_NAME0,"wrath") end
				if WOW_PROJECT_CATACLYSM_CLASSIC then self:AddGameType(WOW_PROJECT_CATACLYSM_CLASSIC,EXPANSION_NAME3.." "..EXPANSION_NAME0,"cata") end
				if WOW_PROJECT_MISTS_CLASSIC then self:AddGameType(WOW_PROJECT_MISTS_CLASSIC,EXPANSION_NAME4.." "..EXPANSION_NAME0,"mists") end
				if WOW_PROJECT_WOWLABS then self:AddGameType(WOW_PROJECT_WOWLABS,WOWLABS_GAMEMODE_HEADER,"plunderstorm") end
				---- [ Genders ]
				self.GENDERS = {}
				self:AddGender(UNKNOWN,LIGHTGRAY_FONT_COLOR)
				self:AddGender(MALE,CreateColor(0.4,0.6,1))	-- 6699FF
				self:AddGender(FEMALE,CreateColor(1,0.4,0.6))	-- FF6699
				---- [ Classes ]
				self.CLASSES = {}
				local maleClasses, femaleClasses = LocalizedClassList(false), LocalizedClassList(true)
				for k in pairs(maleClasses) do
					self:AddClass(k,{k,maleClasses[k],femaleClasses[k]},C_ClassColor.GetClassColor(k))
				end
				---- [ Expansions ]
				self.EXPANSIONS = {}
				for i = 0, GetNumExpansions()-1 do
					self:AddExpansion(i)
				end
				---- [ Factions ]
				self.FACTIONS = {}
				self:AddFaction("Other",FACTION_OTHER,LIGHTGRAY_FONT_COLOR)
				self:AddFaction("Alliance",FACTION_ALLIANCE,PLAYER_FACTION_COLOR_ALLIANCE)
				self:AddFaction("Horde",FACTION_HORDE,PLAYER_FACTION_COLOR_HORDE)
				self:AddFaction("Neutral",FACTION_NEUTRAL,CENTAUR_MAJOR_FACTION_COLOR)
				---- [ Display ]
				self.DISPLAY_STATES = {}
				self:AddDisplayState(false,L["Disabled"],DISABLED_FONT_COLOR)
				self:AddDisplayState(true,L["Enabled"],ENABLED_FONT_COLOR)
				---- [ Frame modes ]
				self.FRAME_MODES = {}
				self:AddFrameMode(L["Normal"],WHITE_FONT_COLOR)
				self:AddFrameMode(L["Auto"],ENABLED_FONT_COLOR)
				self:AddFrameMode(L["Silver"],CreateColor(0.667,0.667,0.667))	-- AAAAAA
				self:AddFrameMode(L["Silver - Winged"],CreateColor(0.933,0.933,0.933))	-- EEEEEE
				self:AddFrameMode(L["Gold"],CreateColor(0.8,0.667,0.2))	-- CCAA33
				self:AddFrameMode(L["Gold - Winged"],CreateColor(1,0.867,0.4))	-- FFDD66
				---- [ Textures ]
				self.TEXTURES = {}
				self:AddTexture(L["Standard (Disabled)"])
				self:AddTexture(L["Standard"])
				local o, rio = self.SetPointOffset(9,0), self.SetPointOffset(20,13)
				self:AddTexture(nil,self.SetTexture({
					["name"] = "UI-HUD-UnitFrame-Target-PortraitOn-Boss-Rare-Silver",
					["flipHorizontally"] = true
				},o),"Portrait",rio)
				self:AddTexture(nil,self.SetTexture({
					["file"] = "Interface\\AddOns\\ElitePlayerFrame_Enhanced\\CustomTextures.blp",
					["file-2x"] = "Interface\\AddOns\\ElitePlayerFrame_Enhanced\\CustomTextures-2x.blp",
					["width"] = 99,
					["height"] = 81,
					["leftTexCoord"] = 238/1024,
					["rightTexCoord"] = 436/1024,
					["topTexCoord"] = 232/512,
					["bottomTexCoord"] = 394/512,
				},o),"Portrait",rio)
				self:AddTexture(nil,self.SetTexture({
					["name"] = "UI-HUD-UnitFrame-Target-PortraitOn-Boss-Gold",
					["flipHorizontally"] = true
				},o),"Portrait",rio)
				self:AddTexture(nil,self.SetTexture({
					["name"] = "UI-HUD-UnitFrame-Target-PortraitOn-Boss-Gold-Winged",
					["flipHorizontally"] = true
				},o),"Portrait",rio)
				---- [ Custom frame modes ]
				for i,v in ipairs(self.CUSTOM_FRAME_MODES) do self:AddCustomFrameMode(v) end
				---- [ Class selection ]
				self.CLASS_SELECTION_STATES = {}
				self:AddClassSelectionState(false,L["Disabled"],DISABLED_FONT_COLOR)
				self:AddClassSelectionState(true,L["Enabled"],ENABLED_FONT_COLOR)
				---- [ Faction selection ]
				self.FACTION_SELECTION_STATES = {}
				self:AddFactionSelectionState(false,L["Disabled"],DISABLED_FONT_COLOR)
				self:AddFactionSelectionState(true,L["Enabled"],ENABLED_FONT_COLOR)
				--- [ Variables ]
				---- [ States ]
				self.initialisationStages[1].name = format(L["%s - Frame"],1)
				self.initialisationStages[2].name = format(L["%s - Addon"],2)
				self.initialisationStages[3].name = format(L["%s - Player"],3)
			end)
			-- [ Game type support assertion ]
			local gameType = self.GAME_TYPES[WOW_PROJECT_ID]
			if not (gameType and self.SUPPORTED_GAME_TYPES[gameType.tag]) then
				self:Msg(format(L["You are attempting to use the %s branch of this addon in %s game type, which is unsupported and won't work."],self.BRANCH,gameType and gameType.name and format(L["the %s"],gameType.name) or L["an unknown"]),self.CRITICAL_ERROR_LEVEL)
				return
			end
			-- [ Hooks ]
			self.FRAME:RegisterEvent("ADDON_LOADED")
			-- [ Manage state ]
			self.initialisationStages[stage].state = true
		elseif stage == 2 and self.initialisationStages[1].state then
			-- [ Settings ]
			local fixed = 0
			--- [ Database ]
			---- [ Get/Set ]
			local newDatabase = false
			local newVersion = false
			if not _G[self.SETTINGS_NAME] then
				newDatabase = true
				_G[self.SETTINGS_NAME] = self.SetSettings({},self.CHAR_SETTINGS_STRUCTURE,self.CHAR_SETTINGS_DEFAULTS)
				self:Msg(format(L["Used default settings for new %s."],L["character"]),self.NOTICE_LEVEL)
			end
			self.database = _G[self.SETTINGS_NAME]
			---- [ Fix ]
			if not newDatabase then
				if self.database.version == nil or self.database.version ~= self.CHAR_SETTINGS_DEFAULTS.version then
					newVersion = true
				end
				fixed = fixed + self.FixSettings(self.database,self.CHAR_SETTINGS_STRUCTURE,self.CHAR_SETTINGS_DEFAULTS,self.CHAR_SETTINGS_CONVERSIONS)
			end
			--- [ Output ]
			self.settings = self.database
			if not newDatabase and not newVersion and fixed > 0 then
				self:Msg(format(L["Fixed %s settings."],fixed),self.WARNING_LEVEL)
			elseif newVersion then
				self:Msg(format(L["Updated settings for version %s.%s (%s)."],tostring(self.VERSION),tostring(self.REVISION),tostring(self.BRANCH)),self.NOTICE_LEVEL)
			end
			-- [ Information ]
			self:SetInfo()
			-- [ Hooks ]
			self.RunOnce("InitialiseStage2Hooks",function ()
				self.FRAME:RegisterEvent("PLAYER_ENTERING_WORLD")
			end)
			-- [ Manage state ]
			self.initialisationStages[stage].state = true
		elseif stage == 3 and self.initialisationStages[1].state and self.initialisationStages[2].state then
			-- [ Information ]
			if not self.info.character then
				self:SetCharacterInfo()
			end
			-- [ Manage state ]
			self.initialisationStages[stage].state = true
		end
		if self.initialisationStages[stage].state then
			value = #self.initialisationStages
			for k,v in pairs(self.initialisationStages) do
				if not v.state then value = value - 1 end
			end
			self:Msg(format(L["Initialised stage %s (%s/%s)."],tostring(self.initialisationStages[stage].name),tostring(value),tostring(#self.initialisationStages)),self.DEBUG_LEVEL)
			-- [ Manage proceeding initialisation ]
			--- [ Stage 2 ]
			local s = 2
			if stage == 1 then
				if self.initialisationStages[s].state then
					self:InitialiseStage(s,false)
				end
				if self.hasLoaded then
					self:InitialiseStage(s)
				end
			end
			--- [ Stage 3 ]
			s = 3
			if stage == 1 or stage == 2 then
				if self.initialisationStages[s].state then
					self:InitialiseStage(s,false)
				end
				if self.hasPlayerLoaded then
					self:InitialiseStage(s)
				end
			end
			-- [ Manage overall state ]
			if not self.isInitialised then
				if value == #self.initialisationStages then
					-- [ Hooks ]
					self.RunOnce("InitialisedHooks",function ()
						self.FRAME:RegisterEvent("PLAYER_LEVEL_UP")
						self.FRAME:RegisterEvent("UPDATE_EXPANSION_LEVEL")
						self.FRAME:RegisterEvent("MIN_EXPANSION_LEVEL_UPDATED")
						self.FRAME:RegisterEvent("MAX_EXPANSION_LEVEL_UPDATED")
						self.FRAME:RegisterEvent("NEUTRAL_FACTION_SELECT_RESULT")
						self.FRAME:RegisterEvent("BARBER_SHOP_APPEARANCE_APPLIED")
						self.FRAME:RegisterEvent("DISPLAY_SIZE_CHANGED")
						hooksecurefunc(self.PLAYER_FRAME.."_Update",self.HOOKS.PlayerFrame_Updated)
					end)
					-- [ GUI ]
					self:Update(true)
					-- [ Addon Compartment ]
					_G[self.NAME.."_AddonCompartment_Clicked"] = self.HOOKS.AddonCompartment_Clicked
					_G[self.NAME.."_AddonCompartment_Entered"] = self.HOOKS.AddonCompartment_Entered
					_G[self.NAME.."_AddonCompartment_Left"] = self.HOOKS.AddonCompartment_Left
					-- [ Slash commands ]
					_G["SLASH_"..self.NAME.."1"] = self.SLASHCMD
					_G["SLASH_"..self.NAME.."2"] = self.SLASHCMD2
					SlashCmdList[self.NAME] = self.HOOKS.SlashCmd_Received
					-- [ Manage state ]
					self.isInitialised = true
					self:Msg(L["Initialised."],self.DEBUG_LEVEL)
					self.FRAME:Initialised()
				end
			end
		end
	elseif not value and self.initialisationStages[stage].state then	-- Uninitialising an initialised stage
		self.initialisationStages[stage].state = false
		value = #self.initialisationStages
		for k,v in pairs(self.initialisationStages) do
			if not v.state then value = value - 1 end
		end
		self:Msg(format(L["Uninitialised stage %s (%s/%s)."],tostring(self.initialisationStages[stage].name),tostring(value),tostring(#self.initialisationStages)),self.DEBUG_LEVEL)
		-- [ Manage proceeding initialisation ]
		--- [ Stage 2 ]
		local s = 2
		if stage == 1 then
			if self.initialisationStages[s].state then
				self:InitialiseStage(s,false)
			end
		end
		--- [ Stage 3 ]
		s = 3
		if stage == 1 or stage == 2 then
			if self.initialisationStages[s].state then
				self:InitialiseStage(s,false)
			end
		end
		-- [ Manage overall state ]
		if self.isInitialised then
			self.isInitialised = false
			self:Msg(L["Uninitialised."],self.DEBUG_LEVEL)
		end
	end
	-- [ Process tail calls ]
	for i,c in pairs(tailcalls) do
		c()
	end
	return self.isInitialised,self.initialisationStages
end
-- [ Frame mixin ]
_G[addon.NAME.."Mixin"] = {}
addon.MIXINS.FRAME = _G[addon.NAME.."Mixin"]
function addon.MIXINS.FRAME:Initialised()
	return addon.isInitialised
end
addon.MIXINS.FRAME.VERSION = addon.VERSION
addon.MIXINS.FRAME.REVISION = addon.REVISION
addon.MIXINS.FRAME.BRANCH = addon.BRANCH
--- [ Custom frames ]
function addon.MIXINS.FRAME:AddCustomFrameMode(definition)
	if not addon.isInitialised then return end
	local i, n = addon:AddCustomFrameMode(definition)
	if i then addon:Msg(format(L["Added custom frame mode (%s: %s)"],i,n),addon.DEBUG_LEVEL) end
	return i, n
end
-- [ RunOnce ]
local ran = {}
function addon.RunOnce(id,f,t)
	if not t then t = ran end
	if not t[id] then
		t[id] = true
		return f()
	end
end
-- [ Add get last line to tooltips ]
function addon.AddGetLastLineToTooltip(tooltip)
	if type(tooltip.GetLastLine) ~= "function" then
		function tooltip:GetLastLine(side)
			return _G[self:GetName().."Text"..tostring(side == "right" and "Right" or "Left")..self:NumLines()]
		end
	end
end
-- [ State handlers ]
--- [ Frame loaded ]
addon.hasFrameLoaded = false
function addon.MIXINS.FRAME:Loaded()
	addon.hasFrameLoaded = true
	local stage = 1
	if not addon.initialisationStages[stage].state then
		addon.FRAME = self
		addon.FRAMELAYERS = {
			["Frame"] = self.Frame,
			["Portrait"] = self.Portrait
		}
		addon.ADDONCOMPARTMENT_TOOLTIP = _G[addon.NAME.."_AddonCompartment_Tooltip"]
		addon.AddGetLastLineToTooltip(addon.ADDONCOMPARTMENT_TOOLTIP)
		addon:InitialiseStage(stage)
	end
end
--- [ Event received ]
function addon.MIXINS.FRAME:Event_Received(event,...)
	addon:Msg(event,addon.DEBUG_LEVEL)
	if event == "ADDON_LOADED" then
		if (select(1,...)) == addon.NAME then
			self:UnregisterEvent("ADDON_LOADED")
			addon:Loaded()
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		addon:Player_Loaded()
	elseif addon.isInitialised then
		if event == "UPDATE_EXPANSION_LEVEL" or event == "MIN_EXPANSION_LEVEL_UPDATED" or event == "MAX_EXPANSION_LEVEL_UPDATED"	-- The expansion info may have changed
		or event == "PLAYER_LEVEL_UP" or event == "NEUTRAL_FACTION_SELECT_RESULT" or event == "BARBER_SHOP_APPEARANCE_APPLIED"	-- The character level, faction, or gender may have changed
		or event == "DISPLAY_SIZE_CHANGED" then	-- The texture resolution may have changed
			addon:Update()
		end
	end
end
--- [ Addon loaded ]
addon.hasLoaded = false
function addon:Loaded(reload)
	self.hasLoaded = true
	local stage = 2
	if self.initialisationStages[stage].state and reload then
		self:InitialiseStage(stage,false)
	end
	self:InitialiseStage(stage)
end
--- [ Player loaded ]
addon.hasPlayerLoaded = false
function addon:Player_Loaded(reload)
	self.hasPlayerLoaded = true
	local stage = 3
	if self.initialisationStages[stage].state and reload then
		self:InitialiseStage(stage,false)
	end
	self:InitialiseStage(stage)
end
-- [ Reset ]
function addon:Reset()
	local stage = 2
	-- [ Manage initialisation ]
	self:InitialiseStage(stage,false)
	-- [ Settings ]
	_G[addon.SETTINGS_NAME] = nil
	self.settings = nil
	-- [ Manage initialisation ]
	self:InitialiseStage(stage)
	self:Msg(format(L["%s settings were reset."],L["Character"]))
end
-- [ Settings ]
--- [ Set ]
function addon.SetSettings(settings,structure,defaults)
	local set = 0
	for k,v in pairs(structure) do
		settings[k] = type(v) == "table" and {} or defaults[k]
		addon:Msg(format(L["Setting %s set to default."],tostring(k)),addon.DEBUG_LEVEL)
		set = set + 1
		if type(settings[k]) == "table" and type(defaults[k]) == "table" and #defaults[k] > 0 then
			set = set + addon.SetSettings(settings[k],structure[k],defaults[k])
		end
	end
	return settings, set
end
--- [ Fix ]
function addon.FixSettings(settings,structure,defaults,conversions)
	local fixed = 0
	for k,v in pairs(structure) do
		if settings[k] == nil then
			if conversions and conversions[k] then
				local ck
				settings[k],ck = conversions[k](settings,v)
				if settings[k] ~= nil and ck then
					addon:Msg(format(L["Missing setting %s updated from %s."],tostring(k),tostring(ck)),addon.DEBUG_LEVEL)
					fixed = fixed + 1
				end
			end
			if settings[k] == nil and defaults and defaults[k] then
				settings[k] = defaults[k]
				addon:Msg(format(L["Missing setting %s set to default."],tostring(k)),addon.DEBUG_LEVEL)
				fixed = fixed + 1
			end
		end
	end
	for k,v in pairs(settings) do
		if structure[k] == nil then
			settings[k] = nil
			addon:Msg(format(L["Unused setting %s removed."],tostring(k)),addon.DEBUG_LEVEL)
			fixed = fixed + 1
		else
			local multiValid = false
			if type(structure[k]) == "string" and structure[k]:find(",") then
				for i,t in ipairs({strsplit(",",structure[k])}) do
					if type(v) == t then
						multiValid = true
						break
					end
				end
			end
			if not multiValid and (type(v) ~= "table" and type(v) ~= structure[k]) or (type(v) == "table" and type(structure[k]) ~= "table") then
				settings[k] = type(structure[k]) == "table" and {} or defaults and defaults[k]
				if settings[k] == nil then
					addon:Msg(format(L["Invalid setting %s removed."],tostring(k)),addon.DEBUG_LEVEL)
				else
					addon:Msg(format(L["Invalid setting %s set to default."],tostring(k)),addon.DEBUG_LEVEL)
				end
				fixed = fixed + 1
			end
		end
		if type(settings[k]) == "table" and type(structure[k]) == "table" and next(structure[k]) ~= nil then
			fixed = fixed + addon.FixSettings(settings[k],structure[k],defaults and defaults[k],conversions and conversions[k])
		end
	end
	if defaults and defaults.version then
		settings.version = defaults.version
	end
	return fixed
end
-- [ Support iterating 0 indexed arrays ]
local ipairs1 = ipairs
local function ipairs(a)
	if a[0] == nil then return ipairs1(a) end
	local i, l = -1, #a
	return function()
		i = i + 1
		if i <= l then return i,a[i] end
	end
end
-- [ Table building ]
function addon.SetTableData(d,i,n,c)
	d.id = i
	d.name = n
	d.color = c
	return d
end
function addon.AddDataToTable(t,n,c)
	local i = t[0] and #t + 1 or 0	-- Index from 0
	t[i] = {}
	return addon.SetTableData(t[i],i,n,c)
end
function addon:AddOutputLevel(i,n,p,c)
	self.OUTPUT_LEVELS[i] = {}
	self.OUTPUT_LEVELS[i].prefix = p
	return self.SetTableData(self.OUTPUT_LEVELS[i],i,n,c)
end
function addon:AddGameType(i,n,t)
	self.GAME_TYPES[i] = {}
	self.GAME_TYPES[i].tag = t
	self.GAME_TYPES[i].isTag = self.GAME_TYPE_TAG_MAPS[t] and self.GAME_TYPE_TAG_MAPS[t].is or {}
	return self.SetTableData(self.GAME_TYPES[i],i,n,WHITE_FONT_COLOR)
end
function addon:AddSupportedGameType(t)
	local map = self.GAME_TYPE_TAG_MAPS[t] and self.GAME_TYPE_TAG_MAPS[t].tags
	if map then
		for i,mt in ipairs(map) do
			self:AddSupportedGameType(mt)
		end
	else
		self.SUPPORTED_GAME_TYPES[t] = true
	end
	return true
end
for m in addon.SUPPORTED_GAME_TYPES_STRING:gmatch("([^,^%s]+)") do
	addon:AddSupportedGameType(m)
end
function addon:AddGender(n,c)
	local i = #self.GENDERS + 1
	self.GENDERS[i] = {}
	return self.SetTableData(self.GENDERS[i],i,n,c)
end
function addon:AddClass(i,n,c)
	self.CLASSES[i] = {}
	return self.SetTableData(self.CLASSES[i],i,n,c)
end
function addon:AddExpansion(i)
	self.EXPANSIONS[i] = {}
	self.EXPANSIONS[i].maxLevel = GetMaxLevelForExpansionLevel(i)
	self.EXPANSIONS[i].minLevel = i > 0 and GetMaxLevelForExpansionLevel(i - 1) or self.INTRO_MAX_LEVEL
	return self.SetTableData(self.EXPANSIONS[i],i,_G["EXPANSION_NAME"..tostring(i)] or UNKNOWN,self.EXPANSION_COLORS[i] or LIGHTGRAY_FONT_COLOR)
end
function addon:AddFaction(i,n,c)
	self.FACTIONS[i] = {}
	return self.SetTableData(self.FACTIONS[i],i,n,c)
end
function addon:AddDisplayState(v,n,c)
	self.DISPLAY_STATES[v] = {}
	return self.SetTableData(self.DISPLAY_STATES[v],v,n,c)
end
--- [ Frame modes ]
function addon:AddFrameMode(n,c)
	return self.AddDataToTable(self.FRAME_MODES,n,c)
end
function addon.SetPointOffset(x,y)
	return {
		["x"] = x or 0,
		["y"] = y or 0
	}
end
function addon.SetTexture(a,o)
	return {
		["atlas"] = a,
		["offsets"] = o or addon.SetPointOffset(0,0)
	}
end
function addon.SetLayeredTextures(ft,pt)
	return {
		["Frame"] = ft,
		["Portrait"] = pt
	}
end
---- [ Layered textures ]
function addon:AddLayeredTextures(n,ts,rio,ac)
	local i = self.TEXTURES[0] and #self.TEXTURES + 1 or 0	-- Index from 0
	self.TEXTURES[i] = {}
	if type(ts) == "table" then
		if not ts["Frame"] and not ts["Portrait"] then ts = {["Frame"] = ts} end
		for k,v in pairs(ts) do
			if type(v) == "table" then
				self.TEXTURES[i][k] = {}
				local a = type(v.atlas) == "string" and {["name"]=v.atlas} or v.atlas
				if a.name and not a.width ~= not a.height then
					local ai = C_Texture.GetAtlasInfo(a.name)
					a.width = a.width or ai.width
					a.height = a.height or ai.height
				end
				self.TEXTURES[i][k].atlas = a
				self.TEXTURES[i][k].offsets = v.offsets or self.SetPointOffset(0,0)
			end
		end
	end
	self.TEXTURES[i].restIconOffsets = rio or self.SetPointOffset(0,0)
	self.TEXTURES[i].autoCondition = ac or false
	return self.SetTableData(self.TEXTURES[i],i,n or self.FRAME_MODES[i].name,self.FRAME_MODES[i].color)
end
---- [ Textures ]
function addon:AddTexture(n,t,l,rio,ac)
	if t and type(t) ~= "table" then
		t = {["atlas"] = t}
	end
	return self:AddLayeredTextures(n,t and {[l or "Frame"] = t} or nil,rio,ac)
end
---- [ Custom frame modes ]
function addon:AddCustomFrameMode(definition)
	if type(definition) == "function" then
		local i, f = #self.FRAME_MODES, definition(self)
		if f then
			local i, n = i+1, f[1]
			self:AddFrameMode(n,f[2])
			self:AddLayeredTextures(nil,f[3],f[4],f[5])
			return i, n
		end
	end
end
--- [ Selection states ]
function addon:AddClassSelectionState(v,n,c)
	self.CLASS_SELECTION_STATES[v] = {}
	return self.SetTableData(self.CLASS_SELECTION_STATES[v],v,n,c)
end
function addon:AddFactionSelectionState(v,n,c)
	self.FACTION_SELECTION_STATES[v] = {}
	return self.SetTableData(self.FACTION_SELECTION_STATES[v],v,n,c)
end
-- [ Message output ]
function addon:Msg(msg,dbg,custom)
	local prefix = self.PREFIX
	if custom and custom.prefix then
		prefix = custom.prefix
	end
	local colon = ":"
	if self.initialisationStages[1].state then
		colon = L[":"]
	end
	if custom and custom.type and custom.lang and custom.to then
		SendChatMessage(tostring(prefix)..colon.." "..tostring(msg),custom.type,custom.lang,custom.to)
	else
		if DEFAULT_CHAT_FRAME and (dbg == nil or (self.initialisationStages[2].state and self.settings.outputLevel >= dbg) or (not self.initialisationStages[2].state and self.DEFAULT_OUTPUT_LEVEL >= dbg)) then
			if self.initialisationStages[1].state and dbg ~= nil then
				msg = self.SetTextColor(tostring(self.OUTPUT_LEVELS[dbg].prefix),self.OUTPUT_LEVELS[dbg].color)..colon.." "..msg
			end
			DEFAULT_CHAT_FRAME:AddMessage(tostring(prefix)..colon.." "..tostring(msg))
		end
	end
end
--- [ Color ]
function addon.SetTextColor(s,c)
	if s and c and type(c.WrapTextInColorCode) == "function" then
		s = c:WrapTextInColorCode(tostring(s))
	else
		s = LIGHTGRAY_FONT_COLOR:WrapTextInColorCode(tostring(s))
	end
	return s
end
addon.PREFIX = (addon.ICON and addon.ICON_STRING.." " or "")..addon.COLOR:WrapTextInColorCode(format("[%s]",addon.SHORT_NAME))
-- [ Information ]
function addon:SetInfo()
	self.info = {}
	self:SetExpansionInfo()
	if self.hasPlayerLoaded then
		self:SetCharacterInfo()
	end
	return self.info
end
--- [ Expansions ]
function addon:SetExpansionInfo()
	local ol, oll, l, ll = self.info.expansion and self.info.expansion.id, self.info.latestExpansion and self.info.latestExpansion.id, GetExpansionLevel(), GetMaximumExpansionLevel()
	if not self.EXPANSIONS[l] then
		self:AddExpansion(l)
	end
	if not self.EXPANSIONS[ll] then
		self:AddExpansion(ll)
	end
	self.info.expansion = self.EXPANSIONS[l]
	self.info.latestExpansion = self.EXPANSIONS[ll]
	if not ol or ol ~= l then
		self:Msg(format(L["Expansion information updated to %s (#%s)."],addon.SetTextColor(tostring(self.info.expansion.name),self.info.expansion.color),tostring(l)),self.DEBUG_LEVEL)
	end
	if l ~= ll and (not oll or oll ~= ll) then
		self:Msg(format(L["Latest expansion information updated to %s (#%s)."],addon.SetTextColor(tostring(self.info.latestExpansion.name),self.info.latestExpansion.color),tostring(ll)),self.DEBUG_LEVEL)
	end
	return self.info.expansion
end
--- [ Character ]
function addon:SetCharacterInfo()
	if UnitExists("player") then
		self.info.character = {}
		self.info.character.name = UnitName("player")
		self.info.character.level = UnitLevel("player")
		self.info.character.gender = UnitSex("player")
		self.info.character.race = UnitRace("player")
		self.info.character.class = UnitClassBase("player")
		self.info.character.faction = UnitFactionGroup("player")
		self:Msg(L["Character information updated."],self.DEBUG_LEVEL)
	else
		self:Msg(L["Unable to update character information; player not loaded yet."],self.WARNING_LEVEL)
	end
	return self.info.character
end
-- [ GUI ]
--- [ Get frame points ]
function addon.GetFramePoints(frame,name)
	local points = {}
	for i = 1,frame:GetNumPoints() do
		local anchor,relativeFrame,relativeAnchor,x,y = frame:GetPoint(i)
		addon:Msg(format(L["%s point %s/%s is %s, %s, %s, %s, %s."],tostring(name or frame:GetName() or frame),tostring(i),tostring(frame:GetNumPoints()),tostring(anchor),tostring(relativeFrame:GetName() or relativeFrame),tostring(relativeAnchor),tostring(x),tostring(y)),addon.DEBUG_LEVEL)
		tinsert(points,{
			["anchor"] = anchor,
			["relativeFrame"] = relativeFrame,
			["relativeAnchor"] = relativeAnchor,
			["offsetX"] = x,
			["offsetY"] = y
		})
		i = i + 1
	end
	return points
end
--- [ Set default frame points ]
addon.defaultFramePoints = {}
function addon:SetDefaultFramePoints(frame,name,reset)
	name = name or (frame and frame:GetName())
	if reset or (name and not self.defaultFramePoints[name]) then
		if name then
			if frame then
				self.defaultFramePoints[name] = self.GetFramePoints(frame,name)
				self:Msg(format(L["Set default points for %s."],tostring(name)),self.DEBUG_LEVEL)
			else
				self:Msg(format(L["Unable to set default points for %s; frame does not exist yet."],tostring(name)),self.WARNING_LEVEL)
			end
		else
			self:Msg(format(L["Unable to set default points for unknown frame."],tostring(name)),self.ERROR_LEVEL)
		end
	end
end
function addon:SetTextureDefaultFramePoints(reset)
	for l in pairs(self.FRAMELAYERS) do
		self:SetDefaultFramePoints(self.FRAME[l],l,reset)
	end
end
function addon:SetRestIconDefaultFramePoints(reset)
	self:SetDefaultFramePoints(_G[self.PLAYER_FRAME][self.PLAYER_CONTENT_FRAME][self.PLAYER_CONTEXTUAL_CONTENT_FRAME][self.PLAYER_REST_ICON_FRAME],self.PLAYER_REST_ICON_FRAME,reset)
end
--- [ Update display ]
function addon:Update(force)
	local changed = false
	if not self.info.character or self.info.character.level ~= UnitLevel("player") or self.info.character.faction ~= UnitFactionGroup("player") or self.info.character.gender ~= UnitSex("player") or self.info.character.class ~= UnitClassBase("player") then
		self:SetCharacterInfo()
		changed = true
	else
		self:Msg(L["Character info has not changed since the last display update."],self.DEBUG_LEVEL)
	end
	if not self.info.expansion or self.info.expansion.id ~= GetExpansionLevel() or not self.info.latestExpansion or self.info.latestExpansion.id ~= GetMaximumExpansionLevel() then
		self:SetExpansionInfo()
		changed = true
	else
		self:Msg(L["Expansion info has not changed since the last display update."],self.DEBUG_LEVEL)
	end
	if self:UpdateTextureResolution() then
		changed = true
	end
	if _G[self.PLAYER_FRAME]:IsClampedToScreen() == false then
		_G[self.PLAYER_FRAME]:SetClampedToScreen(true)
		changed = true
	end
	if force then
		self:Msg(L["Forced display update."],self.DEBUG_LEVEL)
	end
	if force or changed then
		changed = self:UpdateTexture() or false
		changed = self:UpdateRestIcon() or changed
		if changed then
			-- [ Hooks ]
			self.FRAME:Updated()
		end
	end
end
function addon.MIXINS.FRAME:Updated()
	return
end
function addon.HOOKS.PlayerFrame_Updated(...)
	return addon:Update(...)	-- If an argument is provided, it forces an update
end
--- [ Texture ]
---- [ Update ]
function addon:UpdateTexture(reset)
	local r, t = true, self.GetTexture()
	for l,f in pairs(self.FRAMELAYERS) do
		if f then
			self:SetDefaultFramePoints(self.FRAME[l],l,reset)
			if #self.defaultFramePoints[l] == 1 then
				local d = self.defaultFramePoints[l][1]
				local lt = t[l]
				local o = lt and lt.offsets
				local a = lt and lt.atlas
				local h = a and a.hideFrame
				f:ClearAllPoints()
				f:SetPoint(d.anchor, d.relativeFrame, d.relativeAnchor, d.offsetX+(o and o.x or 0), d.offsetY+(o and o.y or 0))
				local tf = l and _G[self.PLAYER_FRAME][self.PLAYER_CONTAINER_FRAME][self.PLAYER_TEXTURE_FRAME]
				if type(a) == "table" then
					if a.name then
						local an = self.GetTextureResolutionValue(a,"name")
						f:SetAtlas(an,not (a.width and a.height),a.filterMode)
						if a.flipHorizontally or a.flipVertically then
							f:SetTexCoord(a.flipHorizontally and 1 or 0,a.flipHorizontally and 0 or 1,a.flipVertically and 1 or 0,a.flipVertically and 0 or 1)
						end
					else
						if a.file then
							local af = self.GetTextureResolutionValue(a,"file")
							f:SetTexture(af,a.tilesHorizontally,a.tilesVertically,a.filterMode)
						end
						local ltc, rtc, ttc, btc = self.GetTextureResolutionValue(a,"leftTexCoord"), self.GetTextureResolutionValue(a,"rightTexCoord"), self.GetTextureResolutionValue(a,"topTexCoord"), self.GetTextureResolutionValue(a,"bottomTexCoord")
						f:SetTexCoord(ltc or 0,rtc or 1,ttc or 0,btc or 1)
					end
					if a.width or a.height then
						f:SetSize(a.width or 0,a.height or 0)
					end
					f:Show()
					if l == "Frame" and h and tf then
						tf:Hide()
					end
				else
					if l == "Frame" and not h and tf then
						tf:Show()
					end
					f:Hide()
				end
				self:Msg(format(L["Updated to %s %s texture."],self.SetTextColor(tostring(t.name),t.color),l),self.DEBUG_LEVEL)
				if self.settings.outputLevel >= self.DEBUG_LEVEL then
					self.GetFramePoints(f,l)
				end
			else
				self:Msg(format(L["Unable to update %s texture position; default points not set yet."],l),self.WARNING_LEVEL)
				r = false
			end
		else
			self:Msg(format(L["Unable to update %s texture position; frame not loaded yet."],l),self.DEBUG_LEVEL)
			r = false
		end
	end
	return r
end
function addon.HOOKS.Texture_Updated(...)	-- Unused hook
	return addon:UpdateTexture(...)	-- If an argument is provided, it causes a default points reset
end
---- [ Get ]
function addon.GetTexture()
	if not addon.settings.display then return addon.TEXTURES[0]
	elseif addon.settings.frameMode == 0 then return addon.TEXTURES[1]
	elseif addon.info.character and addon.settings.frameMode == 1 then
		for i,v in ipairs(addon.TEXTURES) do
			if type(v.autoCondition) == "function" and v.autoCondition(addon) then
				return addon.TEXTURES[i]
			end
		end
		if addon.info.character.level == addon.info.expansion.maxLevel then
			return addon.TEXTURES[5]
		elseif addon.info.character.level >= addon.INTRO_MAX_LEVEL then
			if addon.info.character.level >= addon.info.expansion.minLevel then
				return addon.TEXTURES[3]
			else
				return addon.TEXTURES[2]
			end
		else
			return addon.TEXTURES[1]
		end
	end
	return addon.TEXTURES[addon.settings.frameMode] or addon.TEXTURES[1]
end
---- [ Update Texture Resolution ]
addon.TextureResolution = 1
function addon:UpdateTextureResolution()
	local w, h = GetPhysicalScreenSize()
	local otr, tr = self.TextureResolution, math.ceil(h/addon.BASE_RESOLUTION)
	if tr == otr then return false end
	self.TextureResolution = tr
	self:Msg(format(L["Updated texture resolution to %sx."],tostring(tr)),self.DEBUG_LEVEL)
	return tr
end
---- [ Get Texture Resolution Value ]
function addon.GetTextureResolutionValue(atlas,value)
	if atlas and value then
		local tr = addon.TextureResolution
		local ov = atlas[tr == 1 and value or format("%s-%sx",value,tr)]
		if ov then return ov end
		local w, h = GetPhysicalScreenSize()
		for i = addon.TextureResolution-1, 2, -1 do
			if h/(i*addon.BASE_RESOLUTION) > 0.5 then
				local v = atlas[format("%s-%sx",value,i)]
				if v then return v end
			end
		end
		return atlas[value]
	end
end
--- [ Update rest icon ]
function addon:UpdateRestIcon(reset)
	local f = _G[self.PLAYER_FRAME][self.PLAYER_CONTENT_FRAME][self.PLAYER_CONTEXTUAL_CONTENT_FRAME][self.PLAYER_REST_ICON_FRAME]
	if f then
		self:SetRestIconDefaultFramePoints(reset)
		local t = self.GetTexture()
		if #self.defaultFramePoints[self.PLAYER_REST_ICON_FRAME] == 1 then
			local d = self.defaultFramePoints[self.PLAYER_REST_ICON_FRAME][1]
			local o = t.restIconOffsets
			f:ClearAllPoints()
			f:SetPoint(d.anchor, d.relativeFrame, d.relativeAnchor, d.offsetX+(o and o.x or 0), d.offsetY+(o and o.y or 0))
			if self.settings.outputLevel >= self.DEBUG_LEVEL then
				self.GetFramePoints(f,self.PLAYER_REST_ICON_FRAME)
			end
			self:Msg(L["Updated rest icon position."],self.DEBUG_LEVEL)
			return true
		else
			self:Msg(L["Unable to update rest icon position; default points not set yet."],self.WARNING_LEVEL)
		end
	else
		self:Msg(L["Unable to update rest icon position; frame not loaded yet."],self.DEBUG_LEVEL)
	end
	return false
end
function addon.HOOKS.RestIcon_Updated(...)	-- Unused hook
	return addon:UpdateRestIcon(...)	-- If an argument is provided, it causes a default points reset
end
-- [ Addon Compartment handlers ]
function addon.HOOKS.AddonCompartment_Clicked(addonName,mouseButtonName,button)
	if mouseButtonName == "LeftButton" then
		addon:ToggleDisplay()
	elseif mouseButtonName == "RightButton" then
		addon:CycleFrameMode(IsShiftKeyDown())
	elseif mouseButtonName == "MouseButton4" then
		addon:ToggleClassSelection()
	elseif mouseButtonName == "MouseButton5" then
		addon:ToggleFactionSelection()
	elseif mouseButtonName == "MiddleButton" then
		addon:CycleOutputLevel(IsShiftKeyDown())
	end
end
function addon.HOOKS.AddonCompartment_Entered(addonName,button)
	local t = addon.ADDONCOMPARTMENT_TOOLTIP
	local wc, dyc, bc, ic = WHITE_FONT_COLOR, DARKYELLOW_FONT_COLOR, TUTORIAL_FONT_COLOR, LIGHTGRAY_FONT_COLOR
	local gi, ci, fi, si, ti
	t:SetOwner(button,"ANCHOR_NONE")
	t:ClearAllPoints()
	t:SetPoint("TOPRIGHT",button,"TOPLEFT")
	-- [ Addon ]
	t:AddDoubleLine((addon.ICON and addon.ICON_STRING.." " or "")..addon.COLOR:WrapTextInColorCode(addon.TITLE),format(L["v%s (%s)"],addon.VERSION_AND_REVISION,addon.BRANCH),wc.r,wc.g,wc.b,wc.r,wc.g,wc.b)
	t:AddLine(addon.DESCRIPTION,wc.r,wc.g,wc.b,true)
	-- [ Expansion ]
	t:AddLine(" ")
	if addon.info.expansion.id == addon.info.latestExpansion.id then
		t:AddLine(L["Expansion"]..L[":"],wc.r,wc.g,wc.b)
		t:GetLastLine():SetFontObject(GameTooltipTextSmall)
		t:AddLine(addon.info.expansion.color:WrapTextInColorCode(tostring(addon.info.expansion.name)),wc.r,wc.g,wc.b,true)
		t:AddLine(format(L["Level %s-%s"],addon.info.expansion.minLevel,addon.info.expansion.maxLevel),wc.r,wc.g,wc.b,true)
	else
		t:AddDoubleLine(L["Your expansion"]..L[":"],L["Latest expansion"]..L[":"],wc.r,wc.g,wc.b,wc.r,wc.g,wc.b)
		t:GetLastLine("left"):SetFontObject(GameTooltipTextSmall)
		t:GetLastLine("right"):SetFontObject(GameTooltipTextSmall)
		t:AddDoubleLine(addon.info.expansion.color:WrapTextInColorCode(tostring(addon.info.expansion.name)),addon.info.latestExpansion.color:WrapTextInColorCode(tostring(addon.info.latestExpansion.name)),wc.r,wc.g,wc.b,wc.r,wc.g,wc.b)
		t:AddDoubleLine(format(L["Level %s-%s"],addon.info.expansion.minLevel,addon.info.expansion.maxLevel),format(L["Level %s-%s"],addon.info.expansion.minLevel,addon.info.latestExpansion.maxLevel),wc.r,wc.g,wc.b,wc.r,wc.g,wc.b)
	end
	-- [ Character ]
	t:AddLine(" ")
	t:AddLine(L["Character"]..L[":"],wc.r,wc.g,wc.b)
	t:GetLastLine():SetFontObject(GameTooltipTextSmall)
	gi = addon.GENDERS[addon.info.character.gender]
	ci = addon.CLASSES[addon.info.character.class]
	fi = addon.FACTIONS[addon.info.character.faction]
	ti = addon.GetTexture()
	t:AddDoubleLine(tostring(addon.info.character.name),format(L["Level %s"],tostring(addon.info.character.level)),wc.r,wc.g,wc.b,wc.r,wc.g,wc.b)
	t:AddDoubleLine(tostring(addon.info.character.race),ci.color:WrapTextInColorCode(tostring(ci.name[addon.info.character.gender])),wc.r,wc.g,wc.b,wc.r,wc.g,wc.b)
	t:AddDoubleLine(gi.color:WrapTextInColorCode(tostring(gi.name)),fi.color:WrapTextInColorCode(tostring(fi.name)),wc.r,wc.g,wc.b,wc.r,wc.g,wc.b)
	-- [ Settings ]
	--- [ Display ]
	si = addon.DISPLAY_STATES[addon.settings.display]
	t:AddLine(" ")
	t:AddLine(L["Display"]..L[":"].." "..si.color:WrapTextInColorCode(si.name),wc.r,wc.g,wc.b,true)
	t:AddLine(L["Display of the player frame modifications."],nil,nil,nil,true)
	t:GetLastLine():SetFontObject(GameTooltipTextSmall)
	t:GetLastLine():SetTextColor(dyc.r,dyc.g,dyc.b)
	t:AddLine(format(L["%s to toggle this setting."],bc:WrapTextInColorCode(L["Left-Click"])),ic.r,ic.g,ic.b,true)
	t:GetLastLine():SetFontObject(GameTooltipTextSmall)
	t:GetLastLine():SetTextColor(ic.r,ic.g,ic.b)
	if addon.settings.display then
		--- [ Frame mode ]
		si = addon.FRAME_MODES[addon.settings.frameMode]
		t:AddLine(" ")
		if addon.settings.frameMode ~= 1 then
			t:AddLine(L["Frame mode"]..L[":"].." "..si.color:WrapTextInColorCode(si.name),wc.r,wc.g,wc.b)
		else
			t:AddDoubleLine(L["Frame mode"]..L[":"].." "..si.color:WrapTextInColorCode(si.name),L["Selected frame"]..L[":"].." "..ti.color:WrapTextInColorCode(ti.name),wc.r,wc.g,wc.b,wc.r,wc.g,wc.b)
		end
		t:AddLine(L["A specific frame, or auto (selects the most appropriate frame based on your character and expansion)."],nil,nil,nil,true)
		t:GetLastLine():SetFontObject(GameTooltipTextSmall)
		t:GetLastLine():SetTextColor(dyc.r,dyc.g,dyc.b)
		t:AddLine(format(L["%s to cycle this setting forwards."],bc:WrapTextInColorCode(L["Right-Click"])),ic.r,ic.g,ic.b,true)
		t:GetLastLine():SetFontObject(GameTooltipTextSmall)
		t:GetLastLine():SetTextColor(ic.r,ic.g,ic.b)
		t:AddLine(format(L["%s to cycle this setting backwards."],bc:WrapTextInColorCode(format(L["%s+%s"],L["Shift"],L["Right-Click"]))),ic.r,ic.g,ic.b,true)
		t:GetLastLine():SetFontObject(GameTooltipTextSmall)
		t:GetLastLine():SetTextColor(ic.r,ic.g,ic.b)
		if addon.settings.frameMode == 1 then
			--- [ Class selection ]
			si = addon.CLASS_SELECTION_STATES[addon.settings.classSelection]
			t:AddLine(" ")
			t:AddLine(L["Class selection"]..L[":"].." "..si.color:WrapTextInColorCode(si.name),wc.r,wc.g,wc.b)
			t:AddLine(L["Class based frame selection in auto frame mode."],nil,nil,nil,true)
			t:GetLastLine():SetFontObject(GameTooltipTextSmall)
			t:GetLastLine():SetTextColor(dyc.r,dyc.g,dyc.b)
			t:AddLine(format(L["%s to toggle this setting."],bc:WrapTextInColorCode(L["Button4-Click"])),ic.r,ic.g,ic.b,true)
			t:GetLastLine():SetFontObject(GameTooltipTextSmall)
			t:GetLastLine():SetTextColor(ic.r,ic.g,ic.b)
			--- [ Faction selection ]
			si = addon.FACTION_SELECTION_STATES[addon.settings.factionSelection]
			t:AddLine(" ")
			t:AddLine(L["Faction selection"]..L[":"].." "..si.color:WrapTextInColorCode(si.name),wc.r,wc.g,wc.b,true)
			t:AddLine(L["Faction based frame selection in auto frame mode."],nil,nil,nil,true)
			t:GetLastLine():SetFontObject(GameTooltipTextSmall)
			t:GetLastLine():SetTextColor(dyc.r,dyc.g,dyc.b)
			t:AddLine(format(L["%s to toggle this setting."],bc:WrapTextInColorCode(L["Button5-Click"])),ic.r,ic.g,ic.b,true)
			t:GetLastLine():SetFontObject(GameTooltipTextSmall)
			t:GetLastLine():SetTextColor(ic.r,ic.g,ic.b)
		end
	end
	--- [ Output level ]
	si = addon.OUTPUT_LEVELS[addon.settings.outputLevel]
	t:AddLine(" ")
	t:AddLine(L["Output level"]..L[":"].." "..si.color:WrapTextInColorCode(si.name),wc.r,wc.g,wc.b,true)
	t:AddLine(L["Limits output to messages of the specified level and lower."],dyc.r,dyc.g,dyc.b,true)
	t:GetLastLine():SetFontObject(GameTooltipTextSmall)
	t:GetLastLine():SetTextColor(dyc.r,dyc.g,dyc.b)
	t:AddLine(format(L["%s to cycle this setting forwards."],bc:WrapTextInColorCode(L["Middle-Click"])),ic.r,ic.g,ic.b,true)
	t:GetLastLine():SetFontObject(GameTooltipTextSmall)
	t:GetLastLine():SetTextColor(ic.r,ic.g,ic.b)
	t:AddLine(format(L["%s to cycle this setting backwards."],bc:WrapTextInColorCode(format(L["%s+%s"],L["Shift"],L["Middle-Click"]))),ic.r,ic.g,ic.b,true)
	t:GetLastLine():SetFontObject(GameTooltipTextSmall)
	t:GetLastLine():SetTextColor(ic.r,ic.g,ic.b)
	t:Show()
end
function addon.HOOKS.AddonCompartment_Left(addonName,button)
	addon.ADDONCOMPARTMENT_TOOLTIP:Hide()
end
--- [ Cycle output level ]
function addon:CycleOutputLevel(backwards)
	if backwards then
		self.settings.outputLevel = self.settings.outputLevel > 0 and self.settings.outputLevel-1 or #addon.OUTPUT_LEVELS
	else
		self.settings.outputLevel = self.settings.outputLevel < #addon.OUTPUT_LEVELS and self.settings.outputLevel+1 or 0
	end
end
--- [ Cycle frame mode ]
function addon:CycleFrameMode(backwards)
	if backwards then
		self.settings.frameMode = self.settings.frameMode > 0 and self.settings.frameMode-1 or #addon.FRAME_MODES
	else
		self.settings.frameMode = self.settings.frameMode < #addon.FRAME_MODES and self.settings.frameMode+1 or 0
	end
	self:Update(true)
end
-- [ Setting toggles ]
--- [ Toggle display ]
function addon:ToggleDisplay()
	self.settings.display = not self.settings.display
	self:Update(true)
end
--- [ Toggle class selection ]
function addon:ToggleClassSelection(backwards)
	self.settings.classSelection = not self.settings.classSelection
	self:Update(true)
end
--- [ Toggle faction selection ]
function addon:ToggleFactionSelection(backwards)
	self.settings.factionSelection = not self.settings.factionSelection
	self:Update(true)
end
-- [ Slash command handlers ]
addon.SLASHCMD = "/"..tostring(addon.SHORT_NAME):lower()
addon.SLASHCMD2 = "/"..tostring(addon.NAME):lower()
addon.SLASHCMDS = {}
addon.SLASHCMD_INDEX = {}	-- Index of slash commands by name
addon.SLASHCMD_ARG_INDEX = {}	-- Index of slash command arguments by command name and argument name
addon.L_SLASHCMD_INDEX = {}	-- Index of slash commands by localised name
addon.L_SLASHCMD_ARG_INDEX = {}	-- Index of slash command arguments by localised command name and localised argument name
addon.SLASHCMD_HANDLERS = {}
addon.SLASHCMD_HELP_HANDLERS = {}
--- [ Command received ]
function addon.HOOKS.SlashCmd_Received(s,...)
	local cmd = {}
	local c
	cmd.string = s
	if s and s ~= "" then
		cmd.args = addon.ExplodeArguments(cmd.string)
		cmd.cmd = tostring(cmd.args[1])
		if not addon.SLASHCMDS[cmd.cmd] or type(addon.SLASHCMDS[cmd.cmd].handler) ~= "function" then
			cmd.cmd = L["help"]
			c = addon.SLASHCMDS[L["help"]].handler
			addon:Msg(format(L["%s is an invalid command."],tostring(cmd.string)),addon.ERROR_LEVEL)
		else
			c = addon.SLASHCMDS[cmd.cmd].handler
		end
	else
		cmd.cmd = L["help"]
		c = addon.SLASHCMDS[L["help"]].handler
	end
	c(cmd)
	cmd = nil	-- GC
end
---- [ Argument parsing ]
function addon.ExplodeArguments(s)
	local t = {}
	local i = 0
	while (type(s) == "string") do
		local _, ri, ra = string.find(s,"^ *'([^']*)' *",i+1)	-- Find single quote enclosed arguments
		if not ra then
			_, ri, ra = string.find(s,'^ *"([^"]*)" *',i+1)	-- Find double quote enclosed arguments
			if not ra then
				_, ri, ra = string.find(s,"^ *([^%s]+) *",i+1)	-- Find space delimited arguments
				if not ra then return t end
			end
		end
		i = ri
		tinsert(t,ra)
	end
end
--- [ Help ]
tinsert(addon.SLASHCMD_INDEX,"help")
function addon.SLASHCMD_HANDLERS.help(cmd)
	local c
	if cmd.args and cmd.args[2] ~= nil then
		cmd.cmd = tostring(cmd.args[2])
		if addon.SLASHCMDS[cmd.cmd] and type(addon.SLASHCMDS[cmd.cmd].handler) == "function" then
			addon.SLASHCMDS[cmd.cmd].handler(cmd)
			return
		else
			addon:Msg(format(L["%s is an invalid argument for %s."],addon.SetTextColor(tostring(cmd.args[2]),DARKYELLOW_FONT_COLOR),addon.SetTextColor(L["help"],DARKYELLOW_FONT_COLOR)),addon.ERROR_LEVEL)
		end
	else
		addon:Msg(L["Help"]..L[":"].." "..addon.SetTextColor(addon.SLASHCMD,DARKYELLOW_FONT_COLOR)..L[","].." "..addon.SetTextColor(addon.SLASHCMD2,DARKYELLOW_FONT_COLOR))
	end
	for i,v in ipairs(addon.L_SLASHCMD_INDEX) do
		if v ~= L["help"] then
			c = addon.SLASHCMDS[v].helpHandler
			if v ~= L["update"] or addon.settings.outputLevel >= addon.DEBUG_LEVEL then
				if type(c) == "function" then
					cmd.cmd = v
					c(cmd)
				end
			end
		end
	end
end
--- [ Info ]
tinsert(addon.SLASHCMD_INDEX,"info")
addon.SLASHCMD_ARG_INDEX.info = {}
tinsert(addon.SLASHCMD_ARG_INDEX.info,"addon")
tinsert(addon.SLASHCMD_ARG_INDEX.info,"expansion")
tinsert(addon.SLASHCMD_ARG_INDEX.info,"character")
function addon.SLASHCMD_HANDLERS.info(cmd)
	if cmd.args and cmd.args[2] ~= nil then
		if cmd.args[2] == L["help"] or cmd.args[1] == L["help"] then
			addon.SLASHCMDS[cmd.cmd].helpHandler(cmd)
		elseif cmd.args[2] == L["addon"] then
			addon:Msg(L["Addon"]..L[":"].." "..format(L["%s, v%s (%s)."],tostring(addon.TITLE),tostring(addon.VERSION_AND_REVISION),tostring(addon.BRANCH))..strchar(13)..tostring(addon.DESCRIPTION))
		elseif cmd.args[2] == L["expansion"] then
			addon:Msg(L["Expansion"]..L[":"].." "..format(L["%s (#%s), level %s-%s."],addon.SetTextColor(tostring(addon.info.expansion.name),addon.info.expansion.color),tostring(addon.info.expansion.id),tostring(addon.info.expansion.minLevel),tostring(addon.info.expansion.maxLevel)))
			if addon.info.expansion.id ~= addon.info.latestExpansion.id then
				addon:Msg(L["Latest expansion"]..L[":"].." "..format(L["%s (#%s), level %s-%s."],addon.SetTextColor(tostring(addon.info.latestExpansion.name),addon.info.latestExpansion.color),tostring(addon.info.latestExpansion.id),tostring(addon.info.latestExpansion.minLevel),tostring(addon.info.latestExpansion.maxLevel)))
			end
		elseif cmd.args[2] == L["character"] then
			addon:Msg(L["Character"]..L[":"].." "..format(L["%s, a level %s %s %s %s %s."],tostring(addon.info.character.name),tostring(addon.info.character.level),addon.SetTextColor(tostring(addon.FACTIONS[addon.info.character.faction].name),addon.FACTIONS[addon.info.character.faction].color),addon.SetTextColor(tostring(addon.GENDERS[addon.info.character.gender].name),addon.GENDERS[addon.info.character.gender].color),tostring(addon.info.character.race),addon.SetTextColor(tostring(addon.CLASSES[addon.info.character.class].name[addon.info.character.gender]),addon.CLASSES[addon.info.character.class].color)))
		else
			addon:Msg(format(L["%s is an invalid argument for %s."],addon.SetTextColor(tostring(cmd.args[2]),DARKYELLOW_FONT_COLOR),addon.SetTextColor(L["info"],DARKYELLOW_FONT_COLOR)),addon.ERROR_LEVEL)
			addon.SLASHCMDS[cmd.cmd].helpHandler(cmd)
		end
	else
		-- [ Call cmd with each argument ]
		for i,v in ipairs(addon.L_SLASHCMD_ARG_INDEX[cmd.cmd]) do
			cmd.args[2] = addon.SLASHCMDS[cmd.cmd].arguments[v].localisedName
			addon.SLASHCMDS[cmd.cmd].handler(cmd)
		end
	end
end
---- [ Help ]
function addon.SLASHCMD_HELP_HANDLERS.info(cmd)
	local args = ""
	for i,v in ipairs(addon.L_SLASHCMD_ARG_INDEX[L["info"]]) do
		if args ~= "" then
			args = args..L["|"]:gsub("|","||")	-- Escape pipe character if used
		end
		args = args..addon.SetTextColor(v,DARKYELLOW_FONT_COLOR)
	end
	addon:Msg(L["Help"]..L[":"].." "..format(L["%s [%s]"],addon.SetTextColor(L["info"],DARKYELLOW_FONT_COLOR),args).." "..L["-"].." "..L["Reports information about the optional subject."])
end
--- [ Display ]
tinsert(addon.SLASHCMD_INDEX,"display")
function addon.SLASHCMD_HANDLERS.display(cmd)
	if cmd.args and cmd.args[2] ~= nil then
		if cmd.args[2] == L["help"] or cmd.args[1] == L["help"] then
			addon.SLASHCMDS[cmd.cmd].helpHandler(cmd)
			return
		else
			addon:Msg(format(L["%s is an invalid argument for %s."],addon.SetTextColor(tostring(cmd.args[2]),DARKYELLOW_FONT_COLOR),addon.SetTextColor(L["display"],DARKYELLOW_FONT_COLOR)),addon.ERROR_LEVEL)
			addon.SLASHCMDS[cmd.cmd].helpHandler(cmd)
			return
		end
	else
		addon:ToggleDisplay()
	end
	local s = addon.DISPLAY_STATES[addon.settings.display]
	addon:Msg(L["Display"]..L[":"].." "..format(L["%s."],addon.SetTextColor(tostring(s and s.name or UNKNOWN),s and s.color)))
end
---- [ Help ]
function addon.SLASHCMD_HELP_HANDLERS.display(cmd)
	addon:Msg(L["Help"]..L[":"].." "..addon.SetTextColor(L["display"],DARKYELLOW_FONT_COLOR).." "..L["-"].." "..L["Toggles the display of the player frame modifications."])
end
--- [ Frame mode ]
tinsert(addon.SLASHCMD_INDEX,"frame")
function addon.SLASHCMD_HANDLERS.frame(cmd)
	if cmd.args and cmd.args[2] ~= nil then
		if cmd.args[2] == L["help"] or cmd.args[1] == L["help"] then
			addon.SLASHCMDS[cmd.cmd].helpHandler(cmd)
			return
		elseif tonumber(cmd.args[2]) == nil or (tonumber(cmd.args[2]) > #addon.FRAME_MODES or tonumber(cmd.args[2]) < 0) then
			addon:Msg(format(L["%s is an invalid argument for %s."],addon.SetTextColor(tostring(cmd.args[2]),DARKYELLOW_FONT_COLOR),addon.SetTextColor(L["frame"],DARKYELLOW_FONT_COLOR)),addon.ERROR_LEVEL)
			addon.SLASHCMDS[cmd.cmd].helpHandler(cmd)
			return
		else
			addon.settings.frameMode = tonumber(cmd.args[2])
			addon:Update(true)
		end
	end
	local m = addon.FRAME_MODES[addon.settings.frameMode]
	addon:Msg(L["Frame mode"]..L[":"].." "..format(L["%s (%s)."],addon.SetTextColor(tostring(addon.settings.frameMode),m and m.color),addon.SetTextColor(tostring(m and m.name or UNKNOWN),m and m.color)))
end
---- [ Help ]
function addon.SLASHCMD_HELP_HANDLERS.frame(cmd)
	local modes = ""
	for i,v in ipairs(addon.FRAME_MODES) do
		modes = modes ~= "" and modes..L[","].." " or modes
		modes = modes..format(L["%s = %s"],addon.SetTextColor(i,v.color),addon.SetTextColor(tostring(v.name),v.color))
	end
	addon:Msg(L["Help"]..L[":"].." "..format(L["%s [%s-%s]"],addon.SetTextColor(L["frame"],DARKYELLOW_FONT_COLOR),addon.SetTextColor(0,DARKYELLOW_FONT_COLOR),addon.SetTextColor(tostring(#addon.FRAME_MODES),DARKYELLOW_FONT_COLOR)).." "..L["-"].." "..format(L["Reports or sets the frame mode (%s)."],modes))
end
--- [ Class selection ]
tinsert(addon.SLASHCMD_INDEX,"class")
function addon.SLASHCMD_HANDLERS.class(cmd)
	if cmd.args and cmd.args[2] ~= nil then
		if cmd.args[2] == L["help"] or cmd.args[1] == L["help"] then
			addon.SLASHCMDS[cmd.cmd].helpHandler(cmd)
			return
		else
			addon:Msg(format(L["%s is an invalid argument for %s."],addon.SetTextColor(tostring(cmd.args[2]),DARKYELLOW_FONT_COLOR),addon.SetTextColor(L["class"],DARKYELLOW_FONT_COLOR)),addon.ERROR_LEVEL)
			addon.SLASHCMDS[cmd.cmd].helpHandler(cmd)
			return
		end
	else
		addon:ToggleClassSelection()
	end
	local s = addon.CLASS_SELECTION_STATES[addon.settings.classSelection]
	addon:Msg(L["Class selection"]..L[":"].." "..format(L["%s."],addon.SetTextColor(tostring(s and s.name or UNKNOWN),s and s.color)))
end
---- [ Help ]
function addon.SLASHCMD_HELP_HANDLERS.class(cmd)
	addon:Msg(L["Help"]..L[":"].." "..addon.SetTextColor(L["class"],DARKYELLOW_FONT_COLOR).." "..L["-"].." "..L["Toggles class based frame selection in auto frame mode."])
end
--- [ Faction selection ]
tinsert(addon.SLASHCMD_INDEX,"faction")
function addon.SLASHCMD_HANDLERS.faction(cmd)
	if cmd.args and cmd.args[2] ~= nil then
		if cmd.args[2] == L["help"] or cmd.args[1] == L["help"] then
			addon.SLASHCMDS[cmd.cmd].helpHandler(cmd)
			return
		else
			addon:Msg(format(L["%s is an invalid argument for %s."],addon.SetTextColor(tostring(cmd.args[2]),DARKYELLOW_FONT_COLOR),addon.SetTextColor(L["faction"],DARKYELLOW_FONT_COLOR)),addon.ERROR_LEVEL)
			addon.SLASHCMDS[cmd.cmd].helpHandler(cmd)
			return
		end
	else
		addon:ToggleFactionSelection()
	end
	local s = addon.FACTION_SELECTION_STATES[addon.settings.factionSelection]
	addon:Msg(L["Faction selection"]..L[":"].." "..format(L["%s."],addon.SetTextColor(tostring(s and s.name or UNKNOWN),s and s.color)))
end
---- [ Help ]
function addon.SLASHCMD_HELP_HANDLERS.faction(cmd)
	addon:Msg(L["Help"]..L[":"].." "..addon.SetTextColor(L["faction"],DARKYELLOW_FONT_COLOR).." "..L["-"].." "..L["Toggles faction based frame selection in auto frame mode."])
end
--- [ Output ]
tinsert(addon.SLASHCMD_INDEX,"output")
function addon.SLASHCMD_HANDLERS.output(cmd)
	if cmd.args and cmd.args[2] ~= nil then
		if cmd.args[2] == L["help"] or cmd.args[1] == L["help"] then
			addon.SLASHCMDS[cmd.cmd].helpHandler(cmd)
			return
		elseif tonumber(cmd.args[2]) == nil or (tonumber(cmd.args[2]) > #addon.OUTPUT_LEVELS or tonumber(cmd.args[2]) < 0) then
			addon:Msg(format(L["%s is an invalid argument for %s."],addon.SetTextColor(tostring(cmd.args[2]),DARKYELLOW_FONT_COLOR),addon.SetTextColor(L["output"],DARKYELLOW_FONT_COLOR)),addon.ERROR_LEVEL)
			addon.SLASHCMDS[cmd.cmd].helpHandler(cmd)
			return
		else
			addon.settings.outputLevel = tonumber(cmd.args[2])
		end
	end
	local l = addon.OUTPUT_LEVELS[addon.settings.outputLevel]
	addon:Msg(L["Output level"]..L[":"].." "..format(L["%s (%s)."],addon.SetTextColor(tostring(addon.settings.outputLevel),l and l.color),addon.SetTextColor(tostring(l and l.name or UNKNOWN),l and l.color)))
end
---- [ Help ]
function addon.SLASHCMD_HELP_HANDLERS.output(cmd)
	local outputLevels = ""
	for i,v in ipairs(addon.OUTPUT_LEVELS) do
		outputLevels = outputLevels ~= "" and outputLevels..L[","].." " or outputLevels
		outputLevels = outputLevels..format(L["%s = %s"],addon.SetTextColor(i,v.color),addon.SetTextColor(tostring(v.name),v.color))
	end
	addon:Msg(L["Help"]..L[":"].." "..format(L["%s [%s-%s]"],addon.SetTextColor(L["output"],DARKYELLOW_FONT_COLOR),addon.SetTextColor(0,DARKYELLOW_FONT_COLOR),addon.SetTextColor(tostring(#addon.OUTPUT_LEVELS),DARKYELLOW_FONT_COLOR)).." "..L["-"].." "..format(L["Reports or sets the output level setting (%s)."],outputLevels))
end
--- [ Update ]
tinsert(addon.SLASHCMD_INDEX,"update")
function addon.SLASHCMD_HANDLERS.update(cmd)
	if cmd.args and cmd.args[2] ~= nil then
		if cmd.args[2] == L["help"] or cmd.args[1] == L["help"] then
			addon.SLASHCMDS[cmd.cmd].helpHandler(cmd)
			return
		else
			addon:Msg(format(L["%s is an invalid argument for %s."],addon.SetTextColor(tostring(cmd.args[2]),DARKYELLOW_FONT_COLOR),addon.SetTextColor(L["update"],DARKYELLOW_FONT_COLOR)),addon.ERROR_LEVEL)
			addon.SLASHCMDS[cmd.cmd].helpHandler(cmd)
			return
		end
	else
		addon:Update(true)
	end
end
---- [ Help ]
function addon.SLASHCMD_HELP_HANDLERS.update(cmd)
	addon:Msg(L["Help"]..L[":"].." "..addon.SetTextColor(L["update"],DARKYELLOW_FONT_COLOR).." "..L["-"].." "..L["Forces an update of the player frame modifications."])
end
--- [ Reset ]
tinsert(addon.SLASHCMD_INDEX,"reset")
function addon.SLASHCMD_HANDLERS.reset(cmd)
	if cmd.args and cmd.args[2] ~= nil then
		if cmd.args[2] == L["help"] or cmd.args[1] == L["help"] then
			addon.SLASHCMDS[cmd.cmd].helpHandler(cmd)
			return
		else
			addon:Msg(format(L["%s is an invalid argument for %s."],addon.SetTextColor(tostring(cmd.args[2]),DARKYELLOW_FONT_COLOR),addon.SetTextColor(L["reset"],DARKYELLOW_FONT_COLOR)),addon.ERROR_LEVEL)
			addon.SLASHCMDS[cmd.cmd].helpHandler(cmd)
			return
		end
	else
		addon:Reset()
	end
end
---- [ Help ]
function addon.SLASHCMD_HELP_HANDLERS.reset(cmd)
	addon:Msg(L["Help"]..L[":"].." "..addon.SetTextColor(L["reset"],DARKYELLOW_FONT_COLOR).." "..L["-"].." "..L["Resets your character's settings to default."])
end