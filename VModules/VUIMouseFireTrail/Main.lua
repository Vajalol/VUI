-- VUIMouseFireTrail Module
-- Creates a customizable cursor trail effect
-- Based on EasyCursorTrails by Ridepad with enhancements for VUI theme integration

local AddonName, _ = ...
local MODNAME = "VUIMouseFireTrail"

-- Use global reference instead of local addon variable to fix load order issues
local VUI = _G["VUI"]

-- Check if VUI exists before proceeding
if not VUI then return end

-- Set up global reference early to prevent nil errors
_G["VUIMouseFireTrail"] = _G["VUIMouseFireTrail"] or {}

-- Try to create the module with error handling
local M

if VUI.NewModule then
    M = VUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0", "AceConsole-3.0")
    -- Update the global reference with the actual module
    _G["VUIMouseFireTrail"] = M
else
    -- Create minimal module object to prevent errors
    M = {
        NAME = MODNAME,
        TITLE = "VUI Mouse Fire Trail",
        DESCRIPTION = "Creates customizable effects that follow your mouse cursor",
        VERSION = "2.0",
        OnEnable = function() end,
        OnDisable = function() end
    }
    
    -- Register in VUI namespace
    VUI[MODNAME] = M
    
    -- Update the global reference with our placeholder
    _G["VUIMouseFireTrail"] = M
    
    -- Try initialization again after delay
    C_Timer.After(0.5, function()
        if VUI and VUI.NewModule then
            local RealModule = VUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0", "AceConsole-3.0")
            
            -- Transfer any properties from temporary module
            for k, v in pairs(M) do
                if k ~= "NAME" and k ~= "TITLE" and type(v) ~= "function" then
                    RealModule[k] = v
                end
            end
            
            -- Replace with real module
            VUI[MODNAME] = RealModule
            
            -- Update the global reference with the actual module
            _G["VUIMouseFireTrail"] = RealModule
            
            -- Initialize the module
            if RealModule.OnInitialize then RealModule:OnInitialize() end
            if RealModule.OnEnable then RealModule:OnEnable() end
        end
    end)
end

-- Set global namespace for other files to access
VUI.VUIMouseFireTrail = M

-- Localization
-- Use global reference pattern for localization tables
local L = VUI.L or LibStub("AceLocale-3.0"):GetLocale("VUI")

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
    -- Create the database with consistent naming
    if VUI and VUI.db then
        -- Make sure namespaces exists to avoid nil indexing
        if not VUI.db.namespaces then
            VUI.db.namespaces = {}
        end
        
        -- Check if a namespace already exists with any of the possible names
        local namespace = VUI.db.namespaces["VUIMouseFireTrail"] or VUI.db.namespaces["vuimousefiretrail"]
        
        if namespace then
            -- Use existing namespace
            self.db = namespace
            
            -- Ensure both versions are synchronized
            VUI.db.namespaces["VUIMouseFireTrail"] = namespace
            VUI.db.namespaces["vuimousefiretrail"] = namespace
        else
            -- Create new namespace with proper case for consistency
            self.db = VUI.db:RegisterNamespace("VUIMouseFireTrail", {
                profile = self.defaults.profile
            })
            
            -- Also create lowercase reference for compatibility
            VUI.db.namespaces["vuimousefiretrail"] = self.db
        end
    else
        -- Fallback if VUI.db isn't available
        self.db = {profile = self.defaults.profile}
    end
    
    -- Initialize the configuration panel
    if self.InitializeConfig then
        self:InitializeConfig()
    end
    
    -- Register callback for theme changes with safety checks
    if VUI and VUI.RegisterCallback and type(VUI.RegisterCallback) == "function" then
        pcall(function()
            VUI:RegisterCallback("OnThemeChanged", function()
                if self and self.UpdateTheme and type(self.UpdateTheme) == "function" then
                    pcall(function() self:UpdateTheme() end)
                end
            end)
        end)
    end
    
    -- Debug message
    VUI:Debug("VUIMouseFireTrail initialized")
    
    -- Fire callback to notify the config system
    if VUI.FireCallback then
        VUI:FireCallback("OnModuleInitialized", MODNAME)
    end
end

-- Enable the module
function M:OnEnable()
    -- Initialize the trail system with safety check
    if self.InitializeTrailSystem and type(self.InitializeTrailSystem) == "function" then
        pcall(function() self:InitializeTrailSystem() end)
    end
    
    -- Register events with safety check
    if self.RegisterEvent and type(self.RegisterEvent) == "function" then
        pcall(function() self:RegisterEvent("PLAYER_ENTERING_WORLD") end)
    else
        -- Fallback for when RegisterEvent isn't available
        local frame = CreateFrame("Frame")
        frame:RegisterEvent("PLAYER_ENTERING_WORLD")
        frame:SetScript("OnEvent", function(_, event, ...)
            if event == "PLAYER_ENTERING_WORLD" and self and self.PLAYER_ENTERING_WORLD and type(self.PLAYER_ENTERING_WORLD) == "function" then
                pcall(function() self:PLAYER_ENTERING_WORLD() end)
            end
        end)
        -- Store the frame for later cleanup
        self.eventFrame = frame
    end
    
    -- Register slash command with safety check
    if self.RegisterChatCommand and type(self.RegisterChatCommand) == "function" then
        pcall(function() self:RegisterChatCommand("vuitrail", "SlashCommand") end)
    else
        -- Fallback: Register with SlashCmdList
        _G.SLASH_VUIMOUSEFIRETRAIL1 = "/vuitrail"
        SlashCmdList["VUIMOUSEFIRETRAIL"] = function(input)
            if self and self.SlashCommand and type(self.SlashCommand) == "function" then
                pcall(function() self:SlashCommand(input) end)
            else
                -- Simple fallback
                if input == "toggle" then
                    if self and self.db and self.db.profile then
                        self.db.profile.enabled = not self.db.profile.enabled
                        print("|cffff9900VUIMouseFireTrail:|r " .. (self.db.profile.enabled and "Enabled" or "Disabled"))
                    end
                end
            end
        end
    end
    
    -- Debug message with safety check
    if VUI and VUI.Debug and type(VUI.Debug) == "function" then
        pcall(function() VUI:Debug("VUIMouseFireTrail enabled") end)
    end
end

-- Disable the module
function M:OnDisable()
    -- Clean up any active effects with safety check
    if self.CleanupEffects and type(self.CleanupEffects) == "function" then
        pcall(function() self:CleanupEffects() end)
    end
    
    -- Unregister events with safety check
    if self.UnregisterAllEvents and type(self.UnregisterAllEvents) == "function" then
        pcall(function() self:UnregisterAllEvents() end)
    end
    
    -- Clean up the event frame if we created one
    if self.eventFrame then
        self.eventFrame:SetScript("OnEvent", nil)
        self.eventFrame:UnregisterAllEvents()
        self.eventFrame = nil
    end
    
    -- Debug message with safety check
    if VUI and VUI.Debug and type(VUI.Debug) == "function" then
        pcall(function() VUI:Debug("VUIMouseFireTrail disabled") end)
    end
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