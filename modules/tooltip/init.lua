-- VUI Tooltip Module Initialization
local _, VUI = ...

-- Create the module
local Tooltip = {
    name = "tooltip",
    title = "VUI Tooltip",
    desc = "Enhanced tooltips with targeting information, mount details, and item/spell identifiers",
    version = "1.0",
    author = "VortexQ8",
}

-- Initialize the module
function Tooltip:Initialize()
    -- Initialize settings with defaults
    self.settings = VUI.ModuleAPI:InitializeModuleSettings(self.name, defaults)
    
    -- Set enabled state based on settings
    self:SetEnabledState(self.settings.enabled)
    
    -- Hook tooltip functions
    self:HookTooltipFunctions()
    
    -- Initialize theme integration if available
    if self.ThemeIntegration and self.ThemeIntegration.Initialize then
        self.ThemeIntegration:Initialize()
    end
    
    -- Register for combat events
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    
    -- Print debug message
    if VUI.debug then
        VUI:Print("Tooltip module initialized")
    end
end

-- Hook tooltip functions to add our custom information
function Tooltip:HookTooltipFunctions()
    -- This is a placeholder function that will be implemented in core.lua
end

-- Get configuration options for main UI integration
function Tooltip:GetConfig()
    local config = {
        name = "Tooltip",
        type = "group",
        args = {
            enabled = {
                type = "toggle",
                name = "Enable Tooltip",
                desc = "Enable or disable the Tooltip module",
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
            classColoredBorder = {
                type = "toggle",
                name = "Class Colored Border",
                desc = "Color tooltip border by class when displaying player information",
                get = function() return self.db.general.classColoredBorder end,
                set = function(_, value) 
                    self.db.general.classColoredBorder = value
                    self:UpdateTooltipSettings()
                end,
                order = 2
            },
            scale = {
                type = "range",
                name = "Tooltip Scale",
                desc = "Size of tooltips",
                min = 0.5,
                max = 2.0,
                step = 0.05,
                get = function() return self.db.general.scale end,
                set = function(_, value) 
                    self.db.general.scale = value
                    self:UpdateTooltipSettings()
                end,
                order = 3
            },
            alpha = {
                type = "range",
                name = "Tooltip Opacity",
                desc = "Opacity of tooltips",
                min = 0.1,
                max = 1.0,
                step = 0.05,
                get = function() return self.db.general.alpha end,
                set = function(_, value) 
                    self.db.general.alpha = value
                    self:UpdateTooltipSettings()
                end,
                order = 4
            },
            anchorToCursor = {
                type = "toggle",
                name = "Anchor to Cursor",
                desc = "Attach tooltips to the cursor",
                get = function() return self.db.general.anchorToCursor end,
                set = function(_, value) 
                    self.db.general.anchorToCursor = value
                    self:UpdateTooltipSettings()
                end,
                order = 5
            }
        }
    }
    
    return config
end

-- Register module config with the VUI ModuleAPI
VUI.ModuleAPI:RegisterModuleConfig("tooltip", Tooltip:GetConfig())

-- Default settings
local defaults = {
    enabled = true,
    useThemeColors = true,
    
    -- General settings
    general = {
        scale = 1.0,
        alpha = 1.0,
        backdropColor = {r = 0, g = 0, b = 0, a = 0.8},
        borderColor = {r = 0.3, g = 0.3, b = 0.3, a = 1},
        classColoredBorder = true,
        showBorder = true,
        fontFamily = "Friz Quadrata TT",
        fontSize = 11,
        fontOutline = "OUTLINE",
        anchorToCursor = false,
        anchorPoint = "BOTTOMRIGHT",
        offsetX = 0,
        offsetY = 0,
    },
    
    -- Feature settings
    features = {
        showTargetingInfo = true,
        showMountInfo = true,
        showItemLevelInfo = true,
        showSpellID = true,
        showItemID = true,
        showAuraSource = true,
        showUnitRole = true,
        showGuildRank = true,
        showPvPInfo = true,
        classColoredNames = true,
        showHealthValues = true,
        showPowerValues = true,
        showItemCount = true,
    },
    
    -- Combat settings
    combat = {
        hideInCombat = false,
        opacityInCombat = 0.6,
        scaleInCombat = 0.8,
    },
}

-- Module configuration
local config = {
    type = "group",
    name = "Tooltip",
    desc = "Configure the tooltip module functionality",
    get = function(info) return Tooltip.settings[info[#info]] end,
    set = function(info, value) 
        Tooltip.settings[info[#info]] = value 
        Tooltip:UpdateSettings()
    end,
    args = {
        header = {
            type = "header",
            name = "Tooltip Module Configuration",
            order = 0,
        },
        enabled = {
            type = "toggle",
            name = "Enable Module",
            desc = "Enable or disable the tooltip module and all its features",
            order = 1,
            get = function() return Tooltip.enabled end,
            set = function(_, value)
                Tooltip.enabled = value
                if value then
                    VUI:EnableModule("tooltip")
                else
                    VUI:DisableModule("tooltip")
                end
            end,
        },
        useThemeColors = {
            type = "toggle",
            name = "Use Theme Colors",
            desc = "Use colors from the active VUI theme for tooltip appearance",
            order = 2,
            get = function() return Tooltip.settings.useThemeColors end,
            set = function(_, value) 
                Tooltip.settings.useThemeColors = value
                -- Apply theme if enabled
                if value and Tooltip.ThemeIntegration and Tooltip.ThemeIntegration.ApplyTheme then
                    Tooltip.ThemeIntegration:ApplyTheme(VUI.activeTheme)
                end
                Tooltip:UpdateSettings()
            end,
            disabled = function() return not Tooltip.enabled end,
        },
        generalHeader = {
            type = "header",
            name = "General Settings",
            order = 10,
        },
        scale = {
            type = "range",
            name = "Scale",
            desc = "Set the scale of tooltips",
            order = 11,
            min = 0.5,
            max = 2.0,
            step = 0.1,
            get = function() return Tooltip.settings.general.scale end,
            set = function(_, value) 
                Tooltip.settings.general.scale = value 
                Tooltip:UpdateSettings()
            end,
            disabled = function() return not Tooltip.enabled end,
        },
        alpha = {
            type = "range",
            name = "Alpha",
            desc = "Set the transparency of tooltips",
            order = 12,
            min = 0.1,
            max = 1.0,
            step = 0.1,
            get = function() return Tooltip.settings.general.alpha end,
            set = function(_, value) 
                Tooltip.settings.general.alpha = value 
                Tooltip:UpdateSettings()
            end,
            disabled = function() return not Tooltip.enabled end,
        },
        classColoredBorder = {
            type = "toggle",
            name = "Class Colored Border",
            desc = "Use class color for tooltip borders when showing player information",
            order = 13,
            get = function() return Tooltip.settings.general.classColoredBorder end,
            set = function(_, value) 
                Tooltip.settings.general.classColoredBorder = value 
                Tooltip:UpdateSettings()
            end,
            disabled = function() return not Tooltip.enabled end,
        },
        showBorder = {
            type = "toggle",
            name = "Show Border",
            desc = "Show or hide tooltip borders",
            order = 14,
            get = function() return Tooltip.settings.general.showBorder end,
            set = function(_, value) 
                Tooltip.settings.general.showBorder = value 
                Tooltip:UpdateSettings()
            end,
            disabled = function() return not Tooltip.enabled end,
        },
        anchorToCursor = {
            type = "toggle",
            name = "Anchor to Cursor",
            desc = "Anchor tooltips to the cursor position",
            order = 15,
            get = function() return Tooltip.settings.general.anchorToCursor end,
            set = function(_, value) 
                Tooltip.settings.general.anchorToCursor = value 
                Tooltip:UpdateSettings()
            end,
            disabled = function() return not Tooltip.enabled end,
        },
        featureHeader = {
            type = "header",
            name = "Feature Settings",
            order = 20,
        },
        showTargetingInfo = {
            type = "toggle",
            name = "Show Targeting Info",
            desc = "Show who is targeting the unit in the tooltip",
            order = 21,
            get = function() return Tooltip.settings.features.showTargetingInfo end,
            set = function(_, value) 
                Tooltip.settings.features.showTargetingInfo = value 
                Tooltip:UpdateSettings()
            end,
            disabled = function() return not Tooltip.enabled end,
        },
        showMountInfo = {
            type = "toggle",
            name = "Show Mount Info",
            desc = "Show mount information for mounted units",
            order = 22,
            get = function() return Tooltip.settings.features.showMountInfo end,
            set = function(_, value) 
                Tooltip.settings.features.showMountInfo = value 
                Tooltip:UpdateSettings()
            end,
            disabled = function() return not Tooltip.enabled end,
        },
        showItemLevelInfo = {
            type = "toggle",
            name = "Show Item Level",
            desc = "Show item level information in tooltips",
            order = 23,
            get = function() return Tooltip.settings.features.showItemLevelInfo end,
            set = function(_, value) 
                Tooltip.settings.features.showItemLevelInfo = value 
                Tooltip:UpdateSettings()
            end,
            disabled = function() return not Tooltip.enabled end,
        },
        showSpellID = {
            type = "toggle",
            name = "Show Spell ID",
            desc = "Show spell ID in tooltips",
            order = 24,
            get = function() return Tooltip.settings.features.showSpellID end,
            set = function(_, value) 
                Tooltip.settings.features.showSpellID = value 
                Tooltip:UpdateSettings()
            end,
            disabled = function() return not Tooltip.enabled end,
        },
        showItemID = {
            type = "toggle",
            name = "Show Item ID",
            desc = "Show item ID in tooltips",
            order = 25,
            get = function() return Tooltip.settings.features.showItemID end,
            set = function(_, value) 
                Tooltip.settings.features.showItemID = value 
                Tooltip:UpdateSettings()
            end,
            disabled = function() return not Tooltip.enabled end,
        },
        showAuraSource = {
            type = "toggle",
            name = "Show Aura Source",
            desc = "Show source of auras in tooltips",
            order = 26,
            get = function() return Tooltip.settings.features.showAuraSource end,
            set = function(_, value) 
                Tooltip.settings.features.showAuraSource = value 
                Tooltip:UpdateSettings()
            end,
            disabled = function() return not Tooltip.enabled end,
        },
        classColoredNames = {
            type = "toggle",
            name = "Class Colored Names",
            desc = "Use class colors for player names in tooltips",
            order = 27,
            get = function() return Tooltip.settings.features.classColoredNames end,
            set = function(_, value) 
                Tooltip.settings.features.classColoredNames = value 
                Tooltip:UpdateSettings()
            end,
            disabled = function() return not Tooltip.enabled end,
        },
        showHealthValues = {
            type = "toggle",
            name = "Show Health Values",
            desc = "Show health values in tooltips",
            order = 28,
            get = function() return Tooltip.settings.features.showHealthValues end,
            set = function(_, value) 
                Tooltip.settings.features.showHealthValues = value 
                Tooltip:UpdateSettings()
            end,
            disabled = function() return not Tooltip.enabled end,
        },
        combatHeader = {
            type = "header",
            name = "Combat Settings",
            order = 30,
        },
        hideInCombat = {
            type = "toggle",
            name = "Hide In Combat",
            desc = "Hide tooltips during combat",
            order = 31,
            get = function() return Tooltip.settings.combat.hideInCombat end,
            set = function(_, value) 
                Tooltip.settings.combat.hideInCombat = value 
                Tooltip:UpdateSettings()
            end,
            disabled = function() return not Tooltip.enabled end,
        },
        opacityInCombat = {
            type = "range",
            name = "Opacity In Combat",
            desc = "Set the transparency of tooltips during combat",
            order = 32,
            min = 0.1,
            max = 1.0,
            step = 0.1,
            get = function() return Tooltip.settings.combat.opacityInCombat end,
            set = function(_, value) 
                Tooltip.settings.combat.opacityInCombat = value 
                Tooltip:UpdateSettings()
            end,
            disabled = function() return not Tooltip.enabled or Tooltip.settings.combat.hideInCombat end,
        },
        scaleInCombat = {
            type = "range",
            name = "Scale In Combat",
            desc = "Set the scale of tooltips during combat",
            order = 33,
            min = 0.5,
            max = 1.0,
            step = 0.1,
            get = function() return Tooltip.settings.combat.scaleInCombat end,
            set = function(_, value) 
                Tooltip.settings.combat.scaleInCombat = value 
                Tooltip:UpdateSettings()
            end,
            disabled = function() return not Tooltip.enabled or Tooltip.settings.combat.hideInCombat end,
        },
    }
}

-- Add the Enable function if it doesn't exist
if not Tooltip.Enable then
    function Tooltip:Enable()
        self.enabled = true
        
        -- Initialize theme integration if available
        if self.ThemeIntegration and self.ThemeIntegration.Initialize then
            self.ThemeIntegration:Initialize()
        end
        
        -- Notify user
        VUI:Print("Tooltip module enabled")
    end
end

-- Add the Disable function if it doesn't exist
if not Tooltip.Disable then
    function Tooltip:Disable()
        self.enabled = false
        
        -- Restore default tooltip behavior
        if GameTooltip and GameTooltip.SetBackdropColor then
            GameTooltip:SetBackdropColor(0, 0, 0, 0.8)
            GameTooltip:SetBackdropBorderColor(1, 1, 1, 1)
        end
        
        -- Notify user
        VUI:Print("Tooltip module disabled")
    end
end

-- Register module with VUI
VUI:RegisterModule("tooltip", Tooltip)

-- Return the module to make it accessible to other files
VUI.modules.tooltip = Tooltip