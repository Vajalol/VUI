-- VUIMouseFireTrail Module
-- Creates a customizable cursor trail effect
-- Based on EasyCursorTrails by Ridepad with enhancements for VUI theme integration

local AddonName, VUI = ...
local MODNAME = "VUIMouseFireTrail"
local M = VUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0", "AceConsole-3.0")

-- Localization
local L = LibStub("AceLocale-3.0"):GetLocale("VUI")

-- Module Constants
M.NAME = MODNAME
M.TITLE = "VUI Mouse Fire Trail"
M.DESCRIPTION = "Creates customizable effects that follow your mouse cursor"
M.VERSION = "2.0"

-- Default settings
M.defaults = {
    profile = {
        enabled = true,
        -- Trail properties
        trailCount = 25,            -- Number of segments in the trail
        trailType = "PARTICLE",     -- PARTICLE, TEXTURE, GLOW, SHAPE
        trailShape = "V_SHAPE",     -- V_SHAPE, ARROW, U_SHAPE, ELLIPSE, SPIRAL
        trailTexture = "flame01",   -- Texture to use for the trail
        trailSize = 25,             -- Size of each trail segment
        trailAlpha = 0.7,           -- Transparency of trail
        trailDecay = 0.92,          -- How quickly trail fades (0.8-0.98)
        trailVariation = 0.2,       -- Random size variation (0-1)
        trailSmoothing = 60,        -- Trail update frequency (fps)
        
        -- Appearance
        colorMode = "FIRE",         -- FIRE, ARCANE, FROST, NATURE, RAINBOW, THEME, CUSTOM
        customColorR = 1.0,         -- Custom color (red)
        customColorG = 1.0,         -- Custom color (green)
        customColorB = 1.0,         -- Custom color (blue)
        textureCategory = "Basic",  -- Texture category for texture mode
        
        -- Special effects
        connectSegments = false,    -- Connect trail segments with lines
        enableGlow = false,         -- Add glow effect
        pulsingGlow = false,        -- Make glow pulse
        
        -- Display conditions
        showInCombat = true,        -- Show during combat
        showInInstances = true,     -- Show in dungeons/raids
        showInRestArea = true,      -- Show in rest areas
        showInWorld = true,         -- Show in open world
        requireMouseButton = false, -- Only show when mouse button is held
        requireModifierKey = false, -- Only show when modifier key is held
        
        -- Theme integration
        useThemeColor = false,      -- Use theme color for trail effects
    }
}

-- Initialize the module
function M:OnInitialize()
    -- Create the database
    self.db = VUI.db:RegisterNamespace(self.NAME, {
        profile = self.defaults.profile
    })
    
    -- Initialize the configuration panel
    if self.InitializeConfig then
        self:InitializeConfig()
    end
    
    -- Register callback for theme changes
    VUI:RegisterCallback("OnThemeChanged", function()
        if self.UpdateTheme then
            self:UpdateTheme()
        end
    end)
    
    -- Debug message
    VUI:Debug("VUIMouseFireTrail initialized")
end

-- Enable the module
function M:OnEnable()
    -- Initialize the trail system
    if self.InitializeTrailSystem then
        self:InitializeTrailSystem()
    end
    
    -- Register events
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    
    -- Register slash command
    self:RegisterChatCommand("vuitrail", "SlashCommand")
    
    -- Debug message
    VUI:Debug("VUIMouseFireTrail enabled")
end

-- Disable the module
function M:OnDisable()
    -- Clean up any active effects
    if self.CleanupEffects then
        self:CleanupEffects()
    end
    
    -- Unregister events
    self:UnregisterAllEvents()
    
    -- Debug message
    VUI:Debug("VUIMouseFireTrail disabled")
end

-- Handle PLAYER_ENTERING_WORLD event
function M:PLAYER_ENTERING_WORLD()
    -- Validate textures when entering world
    if self.ValidateTextures then
        self:ValidateTextures()
    end
end

-- Slash command handler
function M:SlashCommand(input)
    if input == "toggle" then
        self.db.profile.enabled = not self.db.profile.enabled
        VUI:Print("|cffff9900VUIMouseFireTrail:|r " .. (self.db.profile.enabled and "Enabled" or "Disabled"))
    else
        -- Open configuration
        if self.OpenConfig then
            self:OpenConfig()
        else
            VUI.Config:OpenToCategory(self.TITLE)
        end
    end
end

-- Debug function
function M:Debug(...)
    VUI:Debug(self.NAME, ...)
end