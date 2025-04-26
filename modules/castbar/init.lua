--[[
    VUI - Castbar Module
    Version: 0.0.1
    Author: VortexQ8
]]

local addonName, VUI = ...
VUI.Castbar = VUI.Castbar or {}
local Castbar = VUI.Castbar
local ModuleAPI = VUI.ModuleAPI

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
        self:ApplyThemeIntegration()
    end
    
    VUI:Print("Castbar module initialized")
end

-- Called when Saved Variables are loaded
function Castbar:OnInitialize()
    -- Setup Module Configuration
    self:SetupConfig()
end

-- Register for VUI Core events
VUI.EventManager:RegisterCallback("VUI_CONFIG_LOADED", function()
    Castbar:Initialize()
end)

VUI.EventManager:RegisterCallback("VUI_THEME_CHANGED", function(theme)
    if Castbar:IsEnabled() and Castbar.settings.animations.themeIntegration then
        Castbar:ApplyThemeIntegration(theme)
    end
end)