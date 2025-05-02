-- VUI InfoFrame Module Initialization
local _, VUI = ...

-- Create the module
local InfoFrame = {
    name = "infoframe",
    title = "VUI Info Frame",
    desc = "Enhanced information display with player stats, spec, and important cooldowns",
    version = "1.0",
    author = "VortexQ8",
}

-- Initialize function for the module
function InfoFrame:Initialize()
    -- Initialize settings with defaults
    self.settings = VUI.ModuleAPI:InitializeModuleSettings(self.name, defaults)
    
    -- Set enabled state based on settings
    self:SetEnabledState(self.settings.enabled)
    
    -- Register for events
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    
    -- Initialize ThemeIntegration if available
    if self.ThemeIntegration and self.ThemeIntegration.Initialize then
        self.ThemeIntegration:Initialize()
    end
    
    -- Print debug message
    if VUI.debug then
        VUI:Print("InfoFrame module initialized")
    end
end

-- Get configuration options for main UI integration
function InfoFrame:GetConfig()
    local config = {
        name = "Info Frame",
        type = "group",
        args = {
            enabled = {
                type = "toggle",
                name = "Enable Info Frame",
                desc = "Enable or disable the Info Frame module",
                get = function() return self.db.enabled end,
                set = function(_, value) 
                    self.db.enabled = value
                    if value then
                        self:Enable()
                    else
                        self:Disable()
                    end
                end,
                order = 1
            },
            locked = {
                type = "toggle",
                name = "Lock Frame",
                desc = "Lock or unlock the Info Frame position",
                get = function() return self.db.general.locked end,
                set = function(_, value) 
                    self.db.general.locked = value
                    self:ToggleLock()
                end,
                order = 2
            },
            scale = {
                type = "range",
                name = "Frame Scale",
                desc = "Adjust the size of the Info Frame",
                min = 0.5,
                max = 2.0,
                step = 0.05,
                get = function() return self.db.general.scale end,
                set = function(_, value) 
                    self.db.general.scale = value
                    self:UpdateFrameSize()
                end,
                order = 3
            },
            alpha = {
                type = "range",
                name = "Frame Opacity",
                desc = "Adjust the transparency of the Info Frame",
                min = 0.1,
                max = 1.0,
                step = 0.05,
                get = function() return self.db.general.alpha end,
                set = function(_, value) 
                    self.db.general.alpha = value
                    self:UpdateFrameAppearance()
                end,
                order = 4
            },
            sections = {
                type = "multiselect",
                name = "Display Sections",
                desc = "Choose which sections to display in the Info Frame",
                values = {
                    ["character"] = "Character Info",
                    ["gear"] = "Gear Status",
                    ["resources"] = "Resources",
                    ["performance"] = "Performance",
                    ["cooldowns"] = "Important Cooldowns"
                },
                get = function(_, key) return self.db.sections[key] end,
                set = function(_, key, value) 
                    self.db.sections[key] = value
                    self:UpdateContent()
                end,
                order = 5
            }
        }
    }
    
    return config
end

-- Register module config with the VUI ModuleAPI
VUI.ModuleAPI:RegisterModuleConfig("infoframe", InfoFrame:GetConfig())

-- Default settings
local defaults = {
    enabled = true,
    
    -- General settings
    general = {
        locked = false,
        scale = 1.0,
        width = 240,
        height = 150,
        alpha = 0.7,
        strata = "MEDIUM",
        position = {"CENTER", "UIParent", "CENTER", 0, 0},
        fontFamily = "Friz Quadrata TT",
        fontSize = 11,
        fontOutline = "OUTLINE",
        backdropColor = {r = 0, g = 0, b = 0, a = 0.7},
        borderColor = {r = 0.3, g = 0.3, b = 0.3, a = 1},
        classColored = true,
        displayTitle = true,
        showBorder = true,
    },
    
    -- Stats Frame settings
    statsFrame = {
        locked = false,
        scale = 1.0,
        alpha = 0.8,
        strata = "MEDIUM",
        position = {"CENTER", "UIParent", "CENTER", 300, 0},
    },
    
    -- Feature settings
    features = {
        showSpecAndLootSpec = true,
        showStats = true,
        showPlayerStatsFrame = true,
        showBattleRezCooldown = true,
        showBloodlustCooldown = true,
        showItemLevel = true,
        statsFormat = "percentage", -- "percentage" or "rating"
        showLatency = true,
        showFPS = true,
        showDurability = true,
        showGold = true,
        updateInterval = 0.5,
    },
    
    -- Stats to display
    stats = {
        crit = true,
        haste = true,
        mastery = true,
        versatility = true,
        intellect = false,
        strength = false,
        agility = false,
        stamina = false,
        armor = false,
        leech = true,
        avoidance = true,
        dodge = false,
        parry = false,
        block = false,
        movementSpeed = true,
    },
    
    -- Tooltips settings
    tooltips = {
        enhanced = true,
        showTargeting = true,
        showMountInfo = true,
        itemLevel = true,
        spellID = true,
        itemID = true,
        classColors = true,
    },
}

-- Module configuration
local config = {
    type = "group",
    name = "Info Frame",
    desc = "Configure the info frame module functionality",
    get = function(info) return InfoFrame.settings[info[#info]] end,
    set = function(info, value) 
        InfoFrame.settings[info[#info]] = value 
        InfoFrame:UpdateSettings()
    end,
    args = {
        header = {
            type = "header",
            name = "Info Frame Module Configuration",
            order = 0,
        },
        enabled = {
            type = "toggle",
            name = "Enable Module",
            desc = "Enable or disable the info frame module and all its features",
            order = 1,
            get = function() return InfoFrame.enabled end,
            set = function(_, value)
                InfoFrame.enabled = value
                if value then
                    VUI:EnableModule("infoframe")
                else
                    VUI:DisableModule("infoframe")
                end
            end,
        },
        generalHeader = {
            type = "header",
            name = "General Settings",
            order = 10,
        },
        locked = {
            type = "toggle",
            name = "Lock Frame",
            desc = "Lock or unlock the info frame position",
            order = 11,
            get = function() return InfoFrame.settings.general.locked end,
            set = function(_, value) 
                InfoFrame.settings.general.locked = value 
                InfoFrame:UpdateLock()
            end,
            disabled = function() return not InfoFrame.enabled end,
        },
        scale = {
            type = "range",
            name = "Scale",
            desc = "Set the scale of the info frame",
            order = 12,
            min = 0.5,
            max = 2.0,
            step = 0.1,
            get = function() return InfoFrame.settings.general.scale end,
            set = function(_, value) 
                InfoFrame.settings.general.scale = value 
                InfoFrame:UpdateSettings()
            end,
            disabled = function() return not InfoFrame.enabled end,
        },
        alpha = {
            type = "range",
            name = "Alpha",
            desc = "Set the transparency of the info frame",
            order = 13,
            min = 0.1,
            max = 1.0,
            step = 0.1,
            get = function() return InfoFrame.settings.general.alpha end,
            set = function(_, value) 
                InfoFrame.settings.general.alpha = value 
                InfoFrame:UpdateSettings()
            end,
            disabled = function() return not InfoFrame.enabled end,
        },
        classColored = {
            type = "toggle",
            name = "Class Colored",
            desc = "Use class color for the frame border",
            order = 14,
            get = function() return InfoFrame.settings.general.classColored end,
            set = function(_, value) 
                InfoFrame.settings.general.classColored = value 
                InfoFrame:UpdateSettings()
            end,
            disabled = function() return not InfoFrame.enabled end,
        },
        displayTitle = {
            type = "toggle",
            name = "Display Title",
            desc = "Show or hide the title of the info frame",
            order = 15,
            get = function() return InfoFrame.settings.general.displayTitle end,
            set = function(_, value) 
                InfoFrame.settings.general.displayTitle = value 
                InfoFrame:UpdateSettings()
            end,
            disabled = function() return not InfoFrame.enabled end,
        },
        showBorder = {
            type = "toggle",
            name = "Show Border",
            desc = "Show or hide the border of the info frame",
            order = 16,
            get = function() return InfoFrame.settings.general.showBorder end,
            set = function(_, value) 
                InfoFrame.settings.general.showBorder = value 
                InfoFrame:UpdateSettings()
            end,
            disabled = function() return not InfoFrame.enabled end,
        },
        featuresHeader = {
            type = "header",
            name = "Feature Settings",
            order = 20,
        },
        showSpecAndLootSpec = {
            type = "toggle",
            name = "Show Spec and Loot Spec",
            desc = "Show current specialization and loot specialization",
            order = 21,
            get = function() return InfoFrame.settings.features.showSpecAndLootSpec end,
            set = function(_, value) 
                InfoFrame.settings.features.showSpecAndLootSpec = value 
                InfoFrame:UpdateSettings()
            end,
            disabled = function() return not InfoFrame.enabled end,
        },
        showStats = {
            type = "toggle",
            name = "Show Stats",
            desc = "Show player statistics",
            order = 22,
            get = function() return InfoFrame.settings.features.showStats end,
            set = function(_, value) 
                InfoFrame.settings.features.showStats = value 
                InfoFrame:UpdateSettings()
            end,
            disabled = function() return not InfoFrame.enabled end,
        },
        showPlayerStatsFrame = {
            type = "toggle",
            name = "Show Player Stats Frame",
            desc = "Show the advanced player stats frame with colored values and cooldown tracking",
            order = 23,
            get = function() return InfoFrame.settings.features.showPlayerStatsFrame end,
            set = function(_, value) 
                InfoFrame.settings.features.showPlayerStatsFrame = value 
                InfoFrame:UpdateSettings()
            end,
            disabled = function() return not InfoFrame.enabled end,
        },
        statsFormat = {
            type = "select",
            name = "Stats Format",
            desc = "Choose how to display stats",
            order = 24,
            values = {
                ["percentage"] = "Percentage",
                ["rating"] = "Rating",
            },
            get = function() return InfoFrame.settings.features.statsFormat end,
            set = function(_, value) 
                InfoFrame.settings.features.statsFormat = value 
                InfoFrame:UpdateSettings()
            end,
            disabled = function() return not (InfoFrame.enabled and InfoFrame.settings.features.showStats) end,
        },
        showBattleRezCooldown = {
            type = "toggle",
            name = "Show Battle Rez Cooldown",
            desc = "Show battle resurrection cooldown",
            order = 25,
            get = function() return InfoFrame.settings.features.showBattleRezCooldown end,
            set = function(_, value) 
                InfoFrame.settings.features.showBattleRezCooldown = value 
                InfoFrame:UpdateSettings()
            end,
            disabled = function() return not InfoFrame.enabled end,
        },
        showBloodlustCooldown = {
            type = "toggle",
            name = "Show Bloodlust Cooldown",
            desc = "Show bloodlust/heroism cooldown",
            order = 26,
            get = function() return InfoFrame.settings.features.showBloodlustCooldown end,
            set = function(_, value) 
                InfoFrame.settings.features.showBloodlustCooldown = value 
                InfoFrame:UpdateSettings()
            end,
            disabled = function() return not InfoFrame.enabled end,
        },
        showItemLevel = {
            type = "toggle",
            name = "Show Item Level",
            desc = "Show player item level",
            order = 27,
            get = function() return InfoFrame.settings.features.showItemLevel end,
            set = function(_, value) 
                InfoFrame.settings.features.showItemLevel = value 
                InfoFrame:UpdateSettings()
            end,
            disabled = function() return not InfoFrame.enabled end,
        },
        showLatency = {
            type = "toggle",
            name = "Show Latency",
            desc = "Show network latency",
            order = 28,
            get = function() return InfoFrame.settings.features.showLatency end,
            set = function(_, value) 
                InfoFrame.settings.features.showLatency = value 
                InfoFrame:UpdateSettings()
            end,
            disabled = function() return not InfoFrame.enabled end,
        },
        showFPS = {
            type = "toggle",
            name = "Show FPS",
            desc = "Show frames per second",
            order = 29,
            get = function() return InfoFrame.settings.features.showFPS end,
            set = function(_, value) 
                InfoFrame.settings.features.showFPS = value 
                InfoFrame:UpdateSettings()
            end,
            disabled = function() return not InfoFrame.enabled end,
        },
        showDurability = {
            type = "toggle",
            name = "Show Durability",
            desc = "Show equipment durability",
            order = 30,
            get = function() return InfoFrame.settings.features.showDurability end,
            set = function(_, value) 
                InfoFrame.settings.features.showDurability = value 
                InfoFrame:UpdateSettings()
            end,
            disabled = function() return not InfoFrame.enabled end,
        },
        updateInterval = {
            type = "range",
            name = "Update Interval",
            desc = "Set how often the info frame updates (in seconds)",
            order = 31,
            min = 0.1,
            max = 5.0,
            step = 0.1,
            get = function() return InfoFrame.settings.features.updateInterval end,
            set = function(_, value) 
                InfoFrame.settings.features.updateInterval = value 
                InfoFrame:UpdateSettings()
            end,
            disabled = function() return not InfoFrame.enabled end,
        },
        statsFrameHeader = {
            type = "header",
            name = "Player Stats Frame Settings",
            order = 35,
        },
        statsFrameLocked = {
            type = "toggle",
            name = "Lock Player Stats Frame",
            desc = "Lock or unlock the player stats frame position",
            order = 36,
            get = function() return InfoFrame.settings.statsFrame.locked end,
            set = function(_, value) 
                InfoFrame.settings.statsFrame.locked = value 
                InfoFrame:UpdateSettings()
            end,
            disabled = function() return not (InfoFrame.enabled and InfoFrame.settings.features.showPlayerStatsFrame) end,
        },
        statsFrameScale = {
            type = "range",
            name = "Player Stats Frame Scale",
            desc = "Set the scale of the player stats frame",
            order = 37,
            min = 0.5,
            max = 2.0,
            step = 0.1,
            get = function() return InfoFrame.settings.statsFrame.scale end,
            set = function(_, value) 
                InfoFrame.settings.statsFrame.scale = value 
                InfoFrame:UpdateSettings()
            end,
            disabled = function() return not (InfoFrame.enabled and InfoFrame.settings.features.showPlayerStatsFrame) end,
        },
        statsFrameAlpha = {
            type = "range",
            name = "Player Stats Frame Alpha",
            desc = "Set the transparency of the player stats frame",
            order = 38,
            min = 0.1,
            max = 1.0,
            step = 0.1,
            get = function() return InfoFrame.settings.statsFrame.alpha end,
            set = function(_, value) 
                InfoFrame.settings.statsFrame.alpha = value 
                InfoFrame:UpdateSettings()
            end,
            disabled = function() return not (InfoFrame.enabled and InfoFrame.settings.features.showPlayerStatsFrame) end,
        },
        statsHeader = {
            type = "header",
            name = "Stats Settings",
            order = 40,
        },
        critStat = {
            type = "toggle",
            name = "Critical Strike",
            desc = "Show critical strike chance",
            order = 41,
            get = function() return InfoFrame.settings.stats.crit end,
            set = function(_, value) 
                InfoFrame.settings.stats.crit = value 
                InfoFrame:UpdateSettings()
            end,
            disabled = function() return not (InfoFrame.enabled and InfoFrame.settings.features.showStats) end,
        },
        hasteStat = {
            type = "toggle",
            name = "Haste",
            desc = "Show haste percentage",
            order = 42,
            get = function() return InfoFrame.settings.stats.haste end,
            set = function(_, value) 
                InfoFrame.settings.stats.haste = value 
                InfoFrame:UpdateSettings()
            end,
            disabled = function() return not (InfoFrame.enabled and InfoFrame.settings.features.showStats) end,
        },
        masteryStat = {
            type = "toggle",
            name = "Mastery",
            desc = "Show mastery percentage",
            order = 43,
            get = function() return InfoFrame.settings.stats.mastery end,
            set = function(_, value) 
                InfoFrame.settings.stats.mastery = value 
                InfoFrame:UpdateSettings()
            end,
            disabled = function() return not (InfoFrame.enabled and InfoFrame.settings.features.showStats) end,
        },
        versatilityStat = {
            type = "toggle",
            name = "Versatility",
            desc = "Show versatility percentage",
            order = 44,
            get = function() return InfoFrame.settings.stats.versatility end,
            set = function(_, value) 
                InfoFrame.settings.stats.versatility = value 
                InfoFrame:UpdateSettings()
            end,
            disabled = function() return not (InfoFrame.enabled and InfoFrame.settings.features.showStats) end,
        },
        leechStat = {
            type = "toggle",
            name = "Leech",
            desc = "Show leech percentage",
            order = 45,
            get = function() return InfoFrame.settings.stats.leech end,
            set = function(_, value) 
                InfoFrame.settings.stats.leech = value 
                InfoFrame:UpdateSettings()
            end,
            disabled = function() return not (InfoFrame.enabled and InfoFrame.settings.features.showStats) end,
        },
        avoidanceStat = {
            type = "toggle",
            name = "Avoidance",
            desc = "Show avoidance percentage",
            order = 46,
            get = function() return InfoFrame.settings.stats.avoidance end,
            set = function(_, value) 
                InfoFrame.settings.stats.avoidance = value 
                InfoFrame:UpdateSettings()
            end,
            disabled = function() return not (InfoFrame.enabled and InfoFrame.settings.features.showStats) end,
        },
        movementSpeedStat = {
            type = "toggle",
            name = "Movement Speed",
            desc = "Show movement speed percentage",
            order = 47,
            get = function() return InfoFrame.settings.stats.movementSpeed end,
            set = function(_, value) 
                InfoFrame.settings.stats.movementSpeed = value 
                InfoFrame:UpdateSettings()
            end,
            disabled = function() return not (InfoFrame.enabled and InfoFrame.settings.features.showStats) end,
        },
        tooltipHeader = {
            type = "header",
            name = "Tooltip Settings",
            order = 50,
        },
        enhancedTooltips = {
            type = "toggle",
            name = "Enhanced Tooltips",
            desc = "Enable enhanced tooltips with additional information",
            order = 51,
            get = function() return InfoFrame.settings.tooltips.enhanced end,
            set = function(_, value) 
                InfoFrame.settings.tooltips.enhanced = value 
                InfoFrame:UpdateTooltips()
            end,
            disabled = function() return not InfoFrame.enabled end,
        },
        showTargeting = {
            type = "toggle",
            name = "Show Targeting Info",
            desc = "Show who is targeting the player you hover over",
            order = 52,
            get = function() return InfoFrame.settings.tooltips.showTargeting end,
            set = function(_, value) 
                InfoFrame.settings.tooltips.showTargeting = value 
                InfoFrame:UpdateTooltips()
            end,
            disabled = function() return not (InfoFrame.enabled and InfoFrame.settings.tooltips.enhanced) end,
        },
        showMountInfo = {
            type = "toggle",
            name = "Show Mount Info",
            desc = "Show mount information for mounted players",
            order = 53,
            get = function() return InfoFrame.settings.tooltips.showMountInfo end,
            set = function(_, value) 
                InfoFrame.settings.tooltips.showMountInfo = value 
                InfoFrame:UpdateTooltips()
            end,
            disabled = function() return not (InfoFrame.enabled and InfoFrame.settings.tooltips.enhanced) end,
        },
        itemLevel = {
            type = "toggle",
            name = "Show Item Level",
            desc = "Show item level in tooltips",
            order = 54,
            get = function() return InfoFrame.settings.tooltips.itemLevel end,
            set = function(_, value) 
                InfoFrame.settings.tooltips.itemLevel = value 
                InfoFrame:UpdateTooltips()
            end,
            disabled = function() return not (InfoFrame.enabled and InfoFrame.settings.tooltips.enhanced) end,
        },
        spellID = {
            type = "toggle",
            name = "Show Spell ID",
            desc = "Show spell ID in tooltips",
            order = 55,
            get = function() return InfoFrame.settings.tooltips.spellID end,
            set = function(_, value) 
                InfoFrame.settings.tooltips.spellID = value 
                InfoFrame:UpdateTooltips()
            end,
            disabled = function() return not (InfoFrame.enabled and InfoFrame.settings.tooltips.enhanced) end,
        },
        itemID = {
            type = "toggle",
            name = "Show Item ID",
            desc = "Show item ID in tooltips",
            order = 56,
            get = function() return InfoFrame.settings.tooltips.itemID end,
            set = function(_, value) 
                InfoFrame.settings.tooltips.itemID = value 
                InfoFrame:UpdateTooltips()
            end,
            disabled = function() return not (InfoFrame.enabled and InfoFrame.settings.tooltips.enhanced) end,
        },
        classColors = {
            type = "toggle",
            name = "Use Class Colors",
            desc = "Use class colors in tooltips",
            order = 57,
            get = function() return InfoFrame.settings.tooltips.classColors end,
            set = function(_, value) 
                InfoFrame.settings.tooltips.classColors = value 
                InfoFrame:UpdateTooltips()
            end,
            disabled = function() return not (InfoFrame.enabled and InfoFrame.settings.tooltips.enhanced) end,
        },
    }
}

-- Register module with VUI
VUI:RegisterModule("infoframe", InfoFrame)

-- Return the module to make it accessible to other files
VUI.modules.infoframe = InfoFrame