--[[
    VUI - Castbar Module
    Version: 1.0.0
    Author: VortexQ8
]]

local addonName, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end
VUI.Castbar = VUI.Castbar or {}
local Castbar = VUI.Castbar
local ModuleAPI = VUI.ModuleAPI

-- Add explicit version field
Castbar.version = "1.0.0"

-- Get configuration options for main UI integration
function Castbar:GetConfig()
    local config = {
        name = "Castbar",
        type = "group",
        args = {
            enabled = {
                type = "toggle",
                name = "Enable Castbar",
                desc = "Enable or disable the Castbar module",
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
            playerCastbar = {
                type = "toggle",
                name = "Player Castbar",
                desc = "Show castbar for your character",
                get = function() return self.db.units.player.enabled end,
                set = function(_, value) 
                    self.db.units.player.enabled = value
                    self:UpdatePlayerCastbar()
                end,
                order = 2
            },
            targetCastbar = {
                type = "toggle",
                name = "Target Castbar",
                desc = "Show castbar for your target",
                get = function() return self.db.units.target.enabled end,
                set = function(_, value) 
                    self.db.units.target.enabled = value
                    self:UpdateTargetCastbar()
                end,
                order = 3
            },
            focusCastbar = {
                type = "toggle",
                name = "Focus Castbar",
                desc = "Show castbar for your focus target",
                get = function() return self.db.units.focus.enabled end,
                set = function(_, value) 
                    self.db.units.focus.enabled = value
                    self:UpdateFocusCastbar()
                end,
                order = 4
            },
            configButton = {
                type = "execute",
                name = "Advanced Settings",
                desc = "Open detailed configuration panel",
                func = function()
                    -- This would open a detailed config panel
                    if self.ShowAdvancedOptions then
                        self:ShowAdvancedOptions()
                    end
                end,
                order = 5
            }
        }
    }
    
    return config
end

-- Register module config with the VUI ModuleAPI
ModuleAPI:RegisterModuleConfig("castbar", Castbar:GetConfig())

-- Default castbar settings
local defaults = {
    enabled = true,
    units = {
        player = {
            enabled = true,
            width = 220,
            height = 22,
            position = {"CENTER", "UIParent", "CENTER", 0, -225},
            showIcon = true,
            showLatency = true,
            showTimer = true,
            showTargetName = true,
            showCompletionText = true,
            attachToPlayerFrame = false,
            scale = 1.0
        },
        target = {
            enabled = true,
            width = 220,
            height = 22,
            position = {"CENTER", "UIParent", "CENTER", 0, -190},
            showIcon = true,
            showTimer = true,
            scale = 1.0
        },
        focus = {
            enabled = true,
            width = 220,
            height = 18,
            position = {"CENTER", "UIParent", "CENTER", 0, -160},
            showIcon = true,
            showTimer = true,
            scale = 0.9
        },
        pet = {
            enabled = false,
            width = 180,
            height = 16,
            position = {"CENTER", "UIParent", "CENTER", 0, -130},
            showIcon = true,
            showTimer = true,
            scale = 0.8
        }
    },
    colors = {
        standard = {r = 0.2, g = 0.7, b = 0.9, a = 1.0},
        channeling = {r = 0.2, g = 0.3, b = 0.9, a = 1.0},
        uninterruptible = {r = 0.7, g = 0.7, b = 0.7, a = 1.0},
        success = {r = 0.2, g = 0.8, b = 0.2, a = 1.0},
        failed = {r = 0.8, g = 0.2, b = 0.2, a = 1.0}
    },
    animations = {
        enabled = true,
        castStart = true,
        castComplete = true,
        castFail = true,
        iconPulse = true,
        textPulse = true,
        barPulse = true,
        themeIntegration = true
    }
}

-- Initialize module settings
Castbar.settings = ModuleAPI:InitializeModuleSettings("castbar", defaults)

-- Register module with VUI
ModuleAPI:RegisterModule("castbar", "Castbar", defaults, function() 
    return Castbar.settings.enabled 
end)

function Castbar:IsEnabled()
    return self.settings.enabled
end

function Castbar:Initialize()
    if not self:IsEnabled() then return end
    
    -- Load the core functionality
    self:SetupCastbars()
    self:RegisterEvents()
    
    -- Initialize animations
    if self.settings.animations.enabled then
        self:InitializeAnimations()
    end
    
    -- Theme integration
    if self.settings.animations.themeIntegration then
        if self.ThemeIntegration and self.ThemeIntegration.Initialize then
            self.ThemeIntegration:Initialize()
        else
            self:ApplyThemeIntegration()
        end
    end
    
    VUI:Print("Castbar module initialized")
end

-- Called when Saved Variables are loaded
function Castbar:OnInitialize()
    -- Setup Module Configuration
    self:SetupConfig()
end

-- Register for VUI Core events
-- Create local EventManager fallback if needed
if not VUI.EventManager then
    VUI.EventManager = {
        callbacks = {},
        
        -- Fallback RegisterCallback function
        RegisterCallback = function(self, event, callback)
            if not self.callbacks[event] then
                self.callbacks[event] = {}
            end
            table.insert(self.callbacks[event], callback)
        end,
        
        -- Fallback TriggerCallback function
        TriggerCallback = function(self, event, ...)
            if self.callbacks[event] then
                for _, callback in ipairs(self.callbacks[event]) do
                    callback(...)
                end
            end
        end
    }
    
    -- Add to global events to capture initialization
    if not VUI.RegisteredEvents then VUI.RegisteredEvents = {} end
    table.insert(VUI.RegisteredEvents, function()
        VUI.EventManager:TriggerCallback("VUI_CONFIG_LOADED")
    end)
    
    -- Hook into VUI's theme system
    if VUI.RegisterCallback then
        VUI:RegisterCallback("ThemeChanged", function(_, theme)
            VUI.EventManager:TriggerCallback("VUI_THEME_CHANGED", theme)
        end)
    end
    
    VUI:Print("Created EventManager fallback for Castbar module")
end

-- Register initialization callback
VUI.EventManager:RegisterCallback("VUI_CONFIG_LOADED", function()
    Castbar:Initialize()
end)

-- Register theme change callback
VUI.EventManager:RegisterCallback("VUI_THEME_CHANGED", function(theme)
    if Castbar:IsEnabled() and Castbar.settings.animations.themeIntegration then
        if Castbar.ThemeIntegration and Castbar.ThemeIntegration.ApplyTheme then
            Castbar.ThemeIntegration:ApplyTheme(theme)
        else
            Castbar:ApplyThemeIntegration(theme)
        end
    end
end)

-- Initialize immediately if VUI is already loaded
if VUI.isInitialized then
    Castbar:Initialize()
end