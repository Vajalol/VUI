-------------------------------------------------------------------------------
-- Title: AngryKeystones Config
-- Author: VortexQ8
-- Configuration options for the AngryKeystones module
-------------------------------------------------------------------------------

local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end
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
    
    -- Enhanced features
    ["Enhanced Features"] = "Enhanced Features",
    ["Enhanced Timer Display"] = "Enhanced Timer Display",
    ["Show enhanced timer display with key upgrade prediction"] = "Show enhanced timer display with key upgrade prediction",
    ["Show Key Level Upgrade"] = "Show Key Level Upgrade",
    ["Show key level upgrade prediction based on timer"] = "Show key level upgrade prediction based on timer",
    ["Show Chest Icons"] = "Show Chest Icons",
    ["Show themed chest icons for timer thresholds"] = "Show themed chest icons for timer thresholds",
    ["Enable Timer Pulse"] = "Enable Timer Pulse",
    ["Enable pulsing animation when timer is low"] = "Enable pulsing animation when timer is low",
    ["Enhanced Progress Tracker"] = "Enhanced Progress Tracker",
    ["Show enhanced enemy forces progress tracker"] = "Show enhanced enemy forces progress tracker",
    ["Show Pull Suggestions"] = "Show Pull Suggestions",
    ["Show suggested enemy pulls to reach 100%"] = "Show suggested enemy pulls to reach 100%",
    ["Show Enemy Details"] = "Show Enemy Details",
    ["Show detailed information about important enemies"] = "Show detailed information about important enemies",
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
            },
            enhanced = {
                type = "group",
                name = L["Enhanced Features"],
                order = 5,
                args = {
                    enhancedHeader = {
                        type = "header",
                        name = L["Enhanced Features"],
                        order = 1
                    },
                    -- Timer enhancements
                    timerEnhancementsHeader = {
                        type = "header",
                        name = L["Enhanced Timer Display"],
                        order = 2
                    },
                    enableEnhancedTimer = {
                        type = "toggle",
                        name = L["Enhanced Timer Display"],
                        desc = L["Show enhanced timer display with key upgrade prediction"],
                        get = function() return VUI.db.profile.modules.angrykeystone.enableEnhancedTimer end,
                        set = function(_, value) 
                            VUI.db.profile.modules.angrykeystone.enableEnhancedTimer = value
                            self:RefreshSettings()
                        end,
                        order = 3
                    },
                    showKeyLevelUpgrade = {
                        type = "toggle",
                        name = L["Show Key Level Upgrade"],
                        desc = L["Show key level upgrade prediction based on timer"],
                        get = function() return VUI.db.profile.modules.angrykeystone.showKeyLevelUpgrade end,
                        set = function(_, value) 
                            VUI.db.profile.modules.angrykeystone.showKeyLevelUpgrade = value
                            self:RefreshSettings()
                        end,
                        order = 4,
                        disabled = function() return not VUI.db.profile.modules.angrykeystone.enableEnhancedTimer end
                    },
                    showChestIcons = {
                        type = "toggle",
                        name = L["Show Chest Icons"],
                        desc = L["Show themed chest icons for timer thresholds"],
                        get = function() return VUI.db.profile.modules.angrykeystone.showChestIcons end,
                        set = function(_, value) 
                            VUI.db.profile.modules.angrykeystone.showChestIcons = value
                            self:RefreshSettings()
                        end,
                        order = 5,
                        disabled = function() return not VUI.db.profile.modules.angrykeystone.enableEnhancedTimer end
                    },
                    enableTimerPulse = {
                        type = "toggle",
                        name = L["Enable Timer Pulse"],
                        desc = L["Enable pulsing animation when timer is low"],
                        get = function() return VUI.db.profile.modules.angrykeystone.enableTimerPulse end,
                        set = function(_, value) 
                            VUI.db.profile.modules.angrykeystone.enableTimerPulse = value
                            self:RefreshSettings()
                        end,
                        order = 6,
                        disabled = function() return not VUI.db.profile.modules.angrykeystone.enableEnhancedTimer end
                    },
                    -- Progress tracker enhancements
                    progressEnhancementsHeader = {
                        type = "header",
                        name = L["Enhanced Progress Tracker"],
                        order = 7
                    },
                    enableEnhancedProgress = {
                        type = "toggle",
                        name = L["Enhanced Progress Tracker"],
                        desc = L["Show enhanced enemy forces progress tracker"],
                        get = function() return VUI.db.profile.modules.angrykeystone.enableEnhancedProgress end,
                        set = function(_, value) 
                            VUI.db.profile.modules.angrykeystone.enableEnhancedProgress = value
                            self:RefreshSettings()
                        end,
                        order = 8
                    },
                    showPullSuggestions = {
                        type = "toggle",
                        name = L["Show Pull Suggestions"],
                        desc = L["Show suggested enemy pulls to reach 100%"],
                        get = function() return VUI.db.profile.modules.angrykeystone.showPullSuggestions end,
                        set = function(_, value) 
                            VUI.db.profile.modules.angrykeystone.showPullSuggestions = value
                            self:RefreshSettings()
                        end,
                        order = 9,
                        disabled = function() return not VUI.db.profile.modules.angrykeystone.enableEnhancedProgress end
                    },
                    showEnemyDetails = {
                        type = "toggle",
                        name = L["Show Enemy Details"],
                        desc = L["Show detailed information about important enemies"],
                        get = function() return VUI.db.profile.modules.angrykeystone.showEnemyDetails end,
                        set = function(_, value) 
                            VUI.db.profile.modules.angrykeystone.showEnemyDetails = value
                            self:RefreshSettings()
                        end,
                        order = 10,
                        disabled = function() return not VUI.db.profile.modules.angrykeystone.enableEnhancedProgress end
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
    
    -- Set default values for enhanced features
    if VUI.db.profile.modules.angrykeystone.enableEnhancedTimer == nil then
        VUI.db.profile.modules.angrykeystone.enableEnhancedTimer = true
    end
    
    if VUI.db.profile.modules.angrykeystone.showKeyLevelUpgrade == nil then
        VUI.db.profile.modules.angrykeystone.showKeyLevelUpgrade = true
    end
    
    if VUI.db.profile.modules.angrykeystone.showChestIcons == nil then
        VUI.db.profile.modules.angrykeystone.showChestIcons = true
    end
    
    if VUI.db.profile.modules.angrykeystone.enableTimerPulse == nil then
        VUI.db.profile.modules.angrykeystone.enableTimerPulse = true
    end
    
    if VUI.db.profile.modules.angrykeystone.enableEnhancedProgress == nil then
        VUI.db.profile.modules.angrykeystone.enableEnhancedProgress = true
    end
    
    if VUI.db.profile.modules.angrykeystone.showPullSuggestions == nil then
        VUI.db.profile.modules.angrykeystone.showPullSuggestions = true
    end
    
    if VUI.db.profile.modules.angrykeystone.showEnemyDetails == nil then
        VUI.db.profile.modules.angrykeystone.showEnemyDetails = true
    end
    

end

-- Initialization
AngryKeystones:InitializeConfig()