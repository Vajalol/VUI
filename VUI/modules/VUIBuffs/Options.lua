---@class VUIBuffs: AceModule
local VUIBuffs = LibStub("AceAddon-3.0"):GetAddon("VUIBuffs")
local L = VUIBuffs.L
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceRegistry = LibStub("AceConfigRegistry-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")

-- Options table
local options

-- Setup the options panel
function VUIBuffs:SetupOptions()
    options = {
        name = "VUI Buffs",
        handler = VUIBuffs,
        type = "group",
        args = {
            general = {
                order = 1,
                type = "group",
                name = L["General"],
                args = {
                    header1 = {
                        order = 1,
                        type = "header",
                        name = L["General Settings"],
                    },
                    enabled = {
                        order = 2,
                        type = "toggle",
                        name = L["Enable"],
                        desc = L["Enable/disable VUI Buffs"],
                        get = function() return VUIBuffs.db.profile.general.enabled end,
                        set = function(_, value)
                            VUIBuffs.db.profile.general.enabled = value
                            VUIBuffs:UpdateAllDisplays()
                        end,
                        width = "full",
                    },
                    lockFrames = {
                        order = 3,
                        type = "toggle",
                        name = L["Lock Frames"],
                        desc = L["Lock/unlock frames"],
                        get = function() return VUIBuffs.db.profile.general.lockFrames end,
                        set = function(_, value)
                            VUIBuffs.db.profile.general.lockFrames = value
                            VUIBuffs:UpdateAllDisplays()
                        end,
                        width = "full",
                    },
                    resetPositions = {
                        order = 4,
                        type = "execute",
                        name = L["Reset Positions"],
                        desc = L["Reset all frame positions"],
                        func = function() VUIBuffs:ResetPositions() end,
                    },
                    testMode = {
                        order = 5,
                        type = "execute",
                        name = L["Test Mode"],
                        desc = L["Toggle test mode"],
                        func = function() VUIBuffs:ToggleTestMode() end,
                    },
                    spacer1 = {
                        order = 10,
                        type = "description",
                        name = " ",
                    },
                    header2 = {
                        order = 11,
                        type = "header",
                        name = L["Display Settings"],
                    },
                    enabledInWorld = {
                        order = 12,
                        type = "toggle",
                        name = L["Enable in World"],
                        desc = L["Enable/disable in open world"],
                        get = function() return VUIBuffs.db.profile.general.enabledInWorld end,
                        set = function(_, value)
                            VUIBuffs.db.profile.general.enabledInWorld = value
                            VUIBuffs:UpdateAllDisplays()
                        end,
                    },
                    enabledInDungeons = {
                        order = 13,
                        type = "toggle",
                        name = L["Enable in Dungeons"],
                        desc = L["Enable/disable in dungeons"],
                        get = function() return VUIBuffs.db.profile.general.enabledInDungeons end,
                        set = function(_, value)
                            VUIBuffs.db.profile.general.enabledInDungeons = value
                            VUIBuffs:UpdateAllDisplays()
                        end,
                    },
                    enabledInRaids = {
                        order = 14,
                        type = "toggle",
                        name = L["Enable in Raids"],
                        desc = L["Enable/disable in raids"],
                        get = function() return VUIBuffs.db.profile.general.enabledInRaids end,
                        set = function(_, value)
                            VUIBuffs.db.profile.general.enabledInRaids = value
                            VUIBuffs:UpdateAllDisplays()
                        end,
                    },
                    enabledInArenas = {
                        order = 15,
                        type = "toggle",
                        name = L["Enable in Arenas"],
                        desc = L["Enable/disable in arenas"],
                        get = function() return VUIBuffs.db.profile.general.enabledInArenas end,
                        set = function(_, value)
                            VUIBuffs.db.profile.general.enabledInArenas = value
                            VUIBuffs:UpdateAllDisplays()
                        end,
                    },
                    enabledInBattlegrounds = {
                        order = 16,
                        type = "toggle",
                        name = L["Enable in Battlegrounds"],
                        desc = L["Enable/disable in battlegrounds"],
                        get = function() return VUIBuffs.db.profile.general.enabledInBattlegrounds end,
                        set = function(_, value)
                            VUIBuffs.db.profile.general.enabledInBattlegrounds = value
                            VUIBuffs:UpdateAllDisplays()
                        end,
                    },
                    spacer2 = {
                        order = 20,
                        type = "description",
                        name = " ",
                    },
                    header3 = {
                        order = 21,
                        type = "header",
                        name = L["Appearance"],
                    },
                    hideIconBorder = {
                        order = 22,
                        type = "toggle",
                        name = L["Hide Icon Border"],
                        desc = L["Hide/show icon borders"],
                        get = function() return VUIBuffs.db.profile.general.hideIconBorder end,
                        set = function(_, value)
                            VUIBuffs.db.profile.general.hideIconBorder = value
                            VUIBuffs:UpdateAllDisplays()
                        end,
                    },
                    showEmptyBuffs = {
                        order = 23,
                        type = "toggle",
                        name = L["Show Empty Buffs"],
                        desc = L["Show/hide empty buffs"],
                        get = function() return VUIBuffs.db.profile.general.showEmptyBuffs end,
                        set = function(_, value)
                            VUIBuffs.db.profile.general.showEmptyBuffs = value
                            VUIBuffs:UpdateAllDisplays()
                        end,
                    },
                    borderStyle = {
                        order = 24,
                        type = "select",
                        name = L["Border Style"],
                        desc = L["Select border style"],
                        values = {
                            [1] = L["Thin"],
                            [2] = L["Classic"],
                        },
                        get = function() return VUIBuffs.db.profile.general.borderStyle end,
                        set = function(_, value)
                            VUIBuffs.db.profile.general.borderStyle = value
                            VUIBuffs:UpdateAllDisplays()
                        end,
                    },
                },
            },
            
            barDisplay = {
                order = 2,
                type = "group",
                name = L["Bar Display"],
                args = {
                    header1 = {
                        order = 1,
                        type = "header",
                        name = L["Bar Display Settings"],
                    },
                    enabled = {
                        order = 2,
                        type = "toggle",
                        name = L["Enable Bar Display"],
                        desc = L["Enable/disable bar display"],
                        get = function() return VUIBuffs.db.profile.barDisplays.global.enabled end,
                        set = function(_, value)
                            VUIBuffs.db.profile.barDisplays.global.enabled = value
                            VUIBuffs:UpdateAllDisplays()
                        end,
                        width = "full",
                    },
                    barHeight = {
                        order = 3,
                        type = "range",
                        name = L["Bar Height"],
                        desc = L["Set bar height"],
                        min = 1,
                        max = 50,
                        step = 1,
                        get = function() return VUIBuffs.db.profile.barDisplays.global.barHeight end,
                        set = function(_, value)
                            VUIBuffs.db.profile.barDisplays.global.barHeight = value
                            VUIBuffs:UpdateAllDisplays()
                        end,
                    },
                    barWidth = {
                        order = 4,
                        type = "range",
                        name = L["Bar Width"],
                        desc = L["Set bar width"],
                        min = 50,
                        max = 300,
                        step = 1,
                        get = function() return VUIBuffs.db.profile.barDisplays.global.barWidth end,
                        set = function(_, value)
                            VUIBuffs.db.profile.barDisplays.global.barWidth = value
                            VUIBuffs:UpdateAllDisplays()
                        end,
                    },
                    barPadding = {
                        order = 5,
                        type = "range",
                        name = L["Bar Padding"],
                        desc = L["Set padding between bars"],
                        min = 0,
                        max = 20,
                        step = 1,
                        get = function() return VUIBuffs.db.profile.barDisplays.global.barPadding end,
                        set = function(_, value)
                            VUIBuffs.db.profile.barDisplays.global.barPadding = value
                            VUIBuffs:UpdateAllDisplays()
                        end,
                    },
                    growthDirection = {
                        order = 6,
                        type = "select",
                        name = L["Growth Direction"],
                        desc = L["Set direction for bars to grow"],
                        values = {
                            ["UP"] = L["Up"],
                            ["DOWN"] = L["Down"],
                        },
                        get = function() return VUIBuffs.db.profile.barDisplays.global.growthDirection end,
                        set = function(_, value)
                            VUIBuffs.db.profile.barDisplays.global.growthDirection = value
                            VUIBuffs:UpdateAllDisplays()
                        end,
                    },
                    spacer1 = {
                        order = 10,
                        type = "description",
                        name = " ",
                    },
                    header2 = {
                        order = 11,
                        type = "header",
                        name = L["Text Settings"],
                    },
                    showTimer = {
                        order = 12,
                        type = "toggle",
                        name = L["Show Timer"],
                        desc = L["Show/hide timer text"],
                        get = function() return VUIBuffs.db.profile.barDisplays.global.showTimer end,
                        set = function(_, value)
                            VUIBuffs.db.profile.barDisplays.global.showTimer = value
                            VUIBuffs:UpdateAllDisplays()
                        end,
                    },
                    timerPosition = {
                        order = 13,
                        type = "select",
                        name = L["Timer Position"],
                        desc = L["Set timer text position"],
                        values = {
                            ["LEFT"] = L["Left"],
                            ["RIGHT"] = L["Right"],
                        },
                        get = function() return VUIBuffs.db.profile.barDisplays.global.timerPosition end,
                        set = function(_, value)
                            VUIBuffs.db.profile.barDisplays.global.timerPosition = value
                            VUIBuffs:UpdateAllDisplays()
                        end,
                        disabled = function() return not VUIBuffs.db.profile.barDisplays.global.showTimer end,
                    },
                    timerTextSize = {
                        order = 14,
                        type = "range",
                        name = L["Timer Text Size"],
                        desc = L["Set timer text size"],
                        min = 6,
                        max = 20,
                        step = 1,
                        get = function() return VUIBuffs.db.profile.barDisplays.global.timerTextSize end,
                        set = function(_, value)
                            VUIBuffs.db.profile.barDisplays.global.timerTextSize = value
                            VUIBuffs:UpdateAllDisplays()
                        end,
                        disabled = function() return not VUIBuffs.db.profile.barDisplays.global.showTimer end,
                    },
                    showName = {
                        order = 15,
                        type = "toggle",
                        name = L["Show Name"],
                        desc = L["Show/hide name text"],
                        get = function() return VUIBuffs.db.profile.barDisplays.global.showName end,
                        set = function(_, value)
                            VUIBuffs.db.profile.barDisplays.global.showName = value
                            VUIBuffs:UpdateAllDisplays()
                        end,
                    },
                    namePosition = {
                        order = 16,
                        type = "select",
                        name = L["Name Position"],
                        desc = L["Set name text position"],
                        values = {
                            ["LEFT"] = L["Left"],
                            ["RIGHT"] = L["Right"],
                        },
                        get = function() return VUIBuffs.db.profile.barDisplays.global.namePosition end,
                        set = function(_, value)
                            VUIBuffs.db.profile.barDisplays.global.namePosition = value
                            VUIBuffs:UpdateAllDisplays()
                        end,
                        disabled = function() return not VUIBuffs.db.profile.barDisplays.global.showName end,
                    },
                    nameTextSize = {
                        order = 17,
                        type = "range",
                        name = L["Name Text Size"],
                        desc = L["Set name text size"],
                        min = 6,
                        max = 20,
                        step = 1,
                        get = function() return VUIBuffs.db.profile.barDisplays.global.nameTextSize end,
                        set = function(_, value)
                            VUIBuffs.db.profile.barDisplays.global.nameTextSize = value
                            VUIBuffs:UpdateAllDisplays()
                        end,
                        disabled = function() return not VUIBuffs.db.profile.barDisplays.global.showName end,
                    },
                },
            },
            
            customSpells = {
                order = 3,
                type = "group",
                name = L["Custom Spells"],
                args = {
                    header = {
                        order = 1,
                        type = "header",
                        name = L["Custom Spells"],
                    },
                    info = {
                        order = 2,
                        type = "description",
                        name = L["Add custom spells to track with VUI Buffs"],
                        fontSize = "medium",
                    },
                    -- This will be populated dynamically
                },
            },
            
            profiles = {
                order = 100,
                type = "group",
                name = L["Profiles"],
                args = {},
            },
        },
    }
    
    -- Add profile options
    options.args.profiles = AceDBOptions:GetOptionsTable(self.db)
    
    AceRegistry:RegisterOptionsTable("VUIBuffs", options)
    self.optionsFrame = AceConfigDialog:AddToBlizOptions("VUIBuffs", "VUI Buffs")
    
    -- Register additional panels
    AceConfigDialog:AddToBlizOptions("VUIBuffs", L["General"], "VUI Buffs", "general")
    AceConfigDialog:AddToBlizOptions("VUIBuffs", L["Bar Display"], "VUI Buffs", "barDisplay")
    AceConfigDialog:AddToBlizOptions("VUIBuffs", L["Custom Spells"], "VUI Buffs", "customSpells")
    AceConfigDialog:AddToBlizOptions("VUIBuffs", L["Profiles"], "VUI Buffs", "profiles")
end