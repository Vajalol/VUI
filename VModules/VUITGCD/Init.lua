-------------------------------------------------------------------------------
-- VUITGCD Module
-- Displays global cooldown icons and ability usage
-- Based on TrufiGCD with VUI integration
-------------------------------------------------------------------------------

local AddonName, VUI = ...
local MODNAME = "VUITGCD"
local M = VUI:NewModule(MODNAME, "AceEvent-3.0")

-- Localization
local L = LibStub("AceLocale-3.0"):GetLocale("VUI")

-- Module Constants
M.NAME = MODNAME
M.TITLE = "VUI Global Cooldowns"
M.DESCRIPTION = "Displays ability usage with animated icons"
M.VERSION = "1.0"

-- Default settings
M.defaults = {
    profile = {
        enabled = true,
        
        -- Icon settings
        iconSize = 30,
        iconAlpha = 1.0,
        fadeTime = 0.3,
        
        -- Layout settings
        direction = "DOWN",
        maxIcons = 10,
        
        -- Filter settings
        showGCDOnly = false,
        hideMacroText = true,
        
        -- Visual settings
        showBorder = true,
        showCooldownSwipe = true,
        colorBySpellType = true,
        
        -- Position settings
        position = {"CENTER", "CENTER", 0, 0}
    }
}

-- Initialize the module
function M:OnInitialize()
    -- Create the database
    self.db = VUI.db:RegisterNamespace(self.NAME, {
        profile = self.defaults.profile
    })
    
    -- Initialize the configuration panel
    self:InitializeConfig()
    
    -- Register callback for theme changes
    VUI:RegisterCallback("OnThemeChanged", function()
        if self.UpdateTheme then
            self:UpdateTheme()
        end
    end)
    
    -- Debug message
    VUI:Debug(self.NAME .. " initialized")
end

-- Enable the module
function M:OnEnable()
    -- Register core events
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    
    -- Debug message
    VUI:Debug(self.NAME .. " enabled")
end

-- Disable the module
function M:OnDisable()
    -- Unregister all events
    self:UnregisterAllEvents()
    
    -- Debug message
    VUI:Debug(self.NAME .. " disabled")
end

-- Configuration initialization
function M:InitializeConfig()
    -- Register with VUI's configuration system
    VUI.Config:RegisterModuleOptions(self.NAME, function()
        -- Open the configuration panel
        if self.OpenConfig then
            self:OpenConfig()
        end
    end)
end

-- Export the module to the namespace
VUI.VUITGCD = M

-- Initialize TrufiGCD to use the VUI.db
local originalLoad = _G.TrufiGCDChSave and _G.TrufiGCDChSave.Load
if VUITGCD and VUITGCD.settings and VUITGCD.settings.Load then
    local originalSettingsLoad = VUITGCD.settings.Load
    
    -- Override the settings load function
    VUITGCD.settings.Load = function(self)
        -- First load original settings
        if originalSettingsLoad then
            originalSettingsLoad(self)
        end
        
        -- Now apply any settings from VUI AceDB
        local moduleSettings = M.db and M.db.profile
        if moduleSettings then
            -- Map appropriate settings
            -- These would need to be customized based on the actual properties
            -- in TrufiGCD settings
            if moduleSettings.enabled ~= nil then
                -- Apply settings that exist in VUI AceDB
                -- Example:
                -- self.activeProfile.enabled = moduleSettings.enabled
            end
        end
    end
end