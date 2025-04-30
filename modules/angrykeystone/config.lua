-------------------------------------------------------------------------------
-- Title: AngryKeystones Config
-- Author: VortexQ8
-- Configuration options for the AngryKeystones module
-------------------------------------------------------------------------------

local _, VUI = ...
local AngryKeystones = VUI.angrykeystone
if not AngryKeystones then return end

-- Setup localization (would use proper localization in a real addon)
local L = {
    ["AngryKeystones"] = "Angry Keystones",
    ["Enable AngryKeystones"] = "Enable Angry Keystones",
    ["Enable or disable the AngryKeystones module"] = "Enable or disable the Angry Keystones module",
    ["Show Objective Tracker"] = "Show Objective Tracker",
    ["Show enhanced objective tracker during Mythic+ dungeons"] = "Show enhanced objective tracker during Mythic+ dungeons",
    ["Show Enemy Forces"] = "Show Enemy Forces",
    ["Show enemy forces percentage and count"] = "Show enemy forces percentage and count",
    ["Show Chest Timer"] = "Show Chest Timer",
    ["Show time remaining for each chest/medal tier"] = "Show time remaining for each chest/medal tier",
    ["Show Keystone Info"] = "Show Keystone Info",
    ["Show detailed information about the active keystone"] = "Show detailed information about the active keystone",
    ["Show Death Counter"] = "Show Death Counter",
    ["Show the death counter and time penalty"] = "Show the death counter and time penalty",
    ["Timer Format"] = "Timer Format",
    ["Format for displaying the timer"] = "Format for displaying the timer",
    ["Progress Format"] = "Progress Format",
    ["Format for displaying enemy forces progress"] = "Format for displaying enemy forces progress",
    ["Announce Progress"] = "Announce Progress",
    ["Announce progress percentage in chat"] = "Announce progress percentage in chat",
    ["Use VUI Theme"] = "Use VUI Theme",
    ["Apply the current VUI theme to AngryKeystones interface"] = "Apply the current VUI theme to Angry Keystones interface",
    ["Custom Style"] = "Custom Style",
    ["Choose a custom style if not using VUI theme"] = "Choose a custom style if not using VUI theme",
    ["Thunder Storm"] = "Thunder Storm",
    ["Phoenix Flame"] = "Phoenix Flame",
    ["Arcane Mystic"] = "Arcane Mystic",
    ["Fel Energy"] = "Fel Energy",
    ["MM:SS"] = "MM:SS",
    ["MMSS"] = "MMSS",
    ["Full Time"] = "Full Time",
    ["Percent"] = "Percent",
    ["Count"] = "Count",
    ["Both"] = "Both",
    ["Display Options"] = "Display Options",
    ["Appearance Options"] = "Appearance Options",
    ["Timer Options"] = "Timer Options",
    ["Sound Options"] = "Sound Options",
    ["Play Completion Sound"] = "Play Completion Sound",
    ["Play a sound when the dungeon is completed"] = "Play a sound when the dungeon is completed",
}

-- Get the full configuration options for AngryKeystones
function AngryKeystones:GetFullConfig()
    local config = {
        name = L["AngryKeystones"],
        type = "group",
        childGroups = "tab",
        args = {
            general = {
                type = "group",
                name = L["Display Options"],
                order = 1,
                args = {
                    enabled = {
                        type = "toggle",
                        name = L["Enable AngryKeystones"],
                        desc = L["Enable or disable the AngryKeystones module"],
                        get = function() return VUI.db.profile.modules.angrykeystone.enabled end,
                        set = function(_, value) 
                            VUI.db.profile.modules.angrykeystone.enabled = value
                            if value then
                                self:Enable()
                            else
                                self:Disable()
                            end
                        end,
                        order = 1
                    },
                    displayHeader = {
                        type = "header",
                        name = L["Display Options"],
                        order = 2
                    },
                    showObjectiveTracker = {
                        type = "toggle",
                        name = L["Show Objective Tracker"],
                        desc = L["Show enhanced objective tracker during Mythic+ dungeons"],
                        get = function() return VUI.db.profile.modules.angrykeystone.showObjectiveTracker end,
                        set = function(_, value) 
                            VUI.db.profile.modules.angrykeystone.showObjectiveTracker = value
                            self:RefreshSettings()
                        end,
                        order = 3
                    },
                    showEnemyCounter = {
                        type = "toggle",
                        name = L["Show Enemy Forces"],
                        desc = L["Show enemy forces percentage and count"],
                        get = function() return VUI.db.profile.modules.angrykeystone.showEnemyCounter end,
                        set = function(_, value) 
                            VUI.db.profile.modules.angrykeystone.showEnemyCounter = value
                            self:RefreshSettings()
                        end,
                        order = 4
                    },
                    showForces = {
                        type = "toggle",
                        name = L["Show Forces"],
                        desc = L["Show enemy forces total amount"],
                        get = function() return VUI.db.profile.modules.angrykeystone.showForces end,
                        set = function(_, value) 
                            VUI.db.profile.modules.angrykeystone.showForces = value
                            self:RefreshSettings()
                        end,
                        order = 5,
                        disabled = function() return not VUI.db.profile.modules.angrykeystone.showEnemyCounter end
                    },
                    showPercentage = {
                        type = "toggle",
                        name = L["Show Percentage"],
                        desc = L["Show enemy forces percentage"],
                        get = function() return VUI.db.profile.modules.angrykeystone.showPercentage end,
                        set = function(_, value) 
                            VUI.db.profile.modules.angrykeystone.showPercentage = value
                            self:RefreshSettings()
                        end,
                        order = 6,
                        disabled = function() return not VUI.db.profile.modules.angrykeystone.showEnemyCounter end
                    },
                    showChestTimer = {
                        type = "toggle",
                        name = L["Show Chest Timer"],
                        desc = L["Show time remaining for each chest/medal tier"],
                        get = function() return VUI.db.profile.modules.angrykeystone.showChestTimer end,
                        set = function(_, value) 
                            VUI.db.profile.modules.angrykeystone.showChestTimer = value
                            self:RefreshSettings()
                        end,
                        order = 7
                    },
                    showDeathCounter = {
                        type = "toggle",
                        name = L["Show Death Counter"],
                        desc = L["Show the death counter and time penalty"],
                        get = function() return VUI.db.profile.modules.angrykeystone.showDeathCounter end,
                        set = function(_, value) 
                            VUI.db.profile.modules.angrykeystone.showDeathCounter = value
                            self:RefreshSettings()
                        end,
                        order = 8
                    },
                    showKeystoneInfo = {
                        type = "toggle",
                        name = L["Show Keystone Info"],
                        desc = L["Show detailed information about the active keystone"],
                        get = function() return VUI.db.profile.modules.angrykeystone.showKeystoneInfo end,
                        set = function(_, value) 
                            VUI.db.profile.modules.angrykeystone.showKeystoneInfo = value
                            self:RefreshSettings()
                        end,
                        order = 9
                    }
                }
            },
            appearance = {
                type = "group",
                name = L["Appearance Options"],
                order = 2,
                args = {
                    appearanceHeader = {
                        type = "header",
                        name = L["Appearance Options"],
                        order = 1
                    },
                    useVUITheme = {
                        type = "toggle",
                        name = L["Use VUI Theme"],
                        desc = L["Apply the current VUI theme to AngryKeystones interface"],
                        get = function() return VUI.db.profile.modules.angrykeystone.useVUITheme end,
                        set = function(_, value) 
                            VUI.db.profile.modules.angrykeystone.useVUITheme = value
                            
                            -- Apply theme changes immediately if possible
                            if self.ThemeIntegration and self.ThemeIntegration.ApplyTheme then
                                self.ThemeIntegration:ApplyTheme()
                            end
                            
                            self:RefreshSettings()
                        end,
                        order = 2
                    },
                    customStyle = {
                        type = "select",
                        name = L["Custom Style"],
                        desc = L["Choose a custom style if not using VUI theme"],
                        disabled = function() return VUI.db.profile.modules.angrykeystone.useVUITheme end,
                        values = {
                            ["thunderstorm"] = L["Thunder Storm"],
                            ["phoenixflame"] = L["Phoenix Flame"],
                            ["arcanemystic"] = L["Arcane Mystic"],
                            ["felenergy"] = L["Fel Energy"]
                        },
                        get = function() return VUI.db.profile.modules.angrykeystone.customStyle end,
                        set = function(_, value) 
                            VUI.db.profile.modules.angrykeystone.customStyle = value
                            self:RefreshSettings()
                        end,
                        order = 3
                    }
                }
            },
            timer = {
                type = "group",
                name = L["Timer Options"],
                order = 3,
                args = {
                    timerHeader = {
                        type = "header",
                        name = L["Timer Options"],
                        order = 1
                    },
                    timerFormat = {
                        type = "select",
                        name = L["Timer Format"],
                        desc = L["Format for displaying the timer"],
                        values = {
                            ["mm:ss"] = L["MM:SS"],
                            ["mmss"] = L["MMSS"],
                            ["full"] = L["Full Time"]
                        },
                        get = function() return VUI.db.profile.modules.angrykeystone.timerFormat end,
                        set = function(_, value) 
                            VUI.db.profile.modules.angrykeystone.timerFormat = value
                            self:RefreshSettings()
                        end,
                        order = 2
                    },
                    progressFormat = {
                        type = "select",
                        name = L["Progress Format"],
                        desc = L["Format for displaying enemy forces progress"],
                        values = {
                            ["percent"] = L["Percent"],
                            ["count"] = L["Count"],
                            ["both"] = L["Both"]
                        },
                        get = function() return VUI.db.profile.modules.angrykeystone.progressFormat end,
                        set = function(_, value) 
                            VUI.db.profile.modules.angrykeystone.progressFormat = value
                            self:RefreshSettings()
                        end,
                        order = 3
                    },
                    announceProgress = {
                        type = "toggle",
                        name = L["Announce Progress"],
                        desc = L["Announce progress percentage in chat"],
                        get = function() return VUI.db.profile.modules.angrykeystone.announceProgress end,
                        set = function(_, value) 
                            VUI.db.profile.modules.angrykeystone.announceProgress = value
                            self:RefreshSettings()
                        end,
                        order = 4
                    }
                }
            },
            sound = {
                type = "group",
                name = L["Sound Options"],
                order = 4,
                args = {
                    soundHeader = {
                        type = "header",
                        name = L["Sound Options"],
                        order = 1
                    },
                    playCompletionSound = {
                        type = "toggle",
                        name = L["Play Completion Sound"],
                        desc = L["Play a sound when the dungeon is completed"],
                        get = function() return VUI.db.profile.modules.angrykeystone.playCompletionSound end,
                        set = function(_, value) 
                            VUI.db.profile.modules.angrykeystone.playCompletionSound = value
                            self:RefreshSettings()
                        end,
                        order = 2
                    }
                }
            }
        }
    }
    
    return config
end

-- Initialize the config module
function AngryKeystones:InitializeConfig()
    -- Register module config with the VUI ModuleAPI
    local config = self:GetFullConfig()
    VUI.ModuleAPI:RegisterModuleConfig("angrykeystone", config)
    
    -- Set up default values not already in the defaults table
    if VUI.db.profile.modules.angrykeystone.playCompletionSound == nil then
        VUI.db.profile.modules.angrykeystone.playCompletionSound = true
    end
    
    if VUI.db.profile.modules.angrykeystone.progressFormat == nil then
        VUI.db.profile.modules.angrykeystone.progressFormat = "both"
    end
    
    -- Debug message
    VUI:Debug("AngryKeystones config initialized")
end

-- Initialization
AngryKeystones:InitializeConfig()