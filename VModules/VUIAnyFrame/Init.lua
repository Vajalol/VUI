-------------------------------------------------------------------------------
-- VUIAnyFrame Module
-- Allows repositioning of any UI element
-- Based on MoveAny by D4KiR with VUI integration
-------------------------------------------------------------------------------

local AddonName, VUI = ...
local MODNAME = "VUIAnyFrame"
local M = VUI:NewModule(MODNAME, "AceEvent-3.0", "AceConsole-3.0", "AceHook-3.0")

-- Localization
local L = LibStub("AceLocale-3.0"):GetLocale("VUI")

-- Module Constants
M.NAME = MODNAME
M.TITLE = "VUI Any Frame"
M.DESCRIPTION = "Move, scale, and customize any UI element"
M.VERSION = "1.0"

-- Default settings
M.defaults = {
    profile = {
        enabled = true,
        
        -- Frame settings
        frames = {},
        
        -- Global settings
        global = {
            grid = 10,
            snapToGrid = false,
            lockFrames = true,
            hideBlizzardFrames = {
                PlayerFrame = false,
                TargetFrame = false,
                MinimapCluster = false,
                BuffFrame = false,
                ChatFrame1 = false,
                MainMenuBar = false,
                ObjectiveTrackerFrame = false
            }
        },
        
        -- Minimap button
        minimap = {
            hide = false,
            minimapPos = 180
        }
    }
}

-- Initialize the module
function M:OnInitialize()
    -- Create the database
    self.db = VUI.db:RegisterNamespace(self.NAME, {
        profile = self.defaults.profile
    })
    
    -- Create a reference for compatibility
    _G.VUIAnyFrame = _G.VUIAnyFrame or {}
    _G.VUIAnyFrame.db = self.db
    
    -- Copy functions from the existing VUIAnyFrame module
    if _G.VUIAnyFrame then
        for key, func in pairs(_G.VUIAnyFrame) do
            if type(func) == "function" and not self[key] then
                self[key] = func
            end
        end
    end
    
    -- Initialize the configuration panel
    self:InitializeConfig()
    
    -- Register callback for theme changes
    VUI:RegisterCallback("OnThemeChanged", function()
        if self.UpdateTheme then
            self:UpdateTheme()
        end
    end)
    
    -- Set up minimap button
    if self.SetupDataBroker then
        self:SetupDataBroker()
    end
    
    -- Register slash commands
    self:RegisterChatCommand("vuianyframe", "SlashCommand")
    self:RegisterChatCommand("va", "SlashCommand")
    
    -- Debug message
    VUI:Debug(self.NAME .. " initialized")
end

-- Enable the module
function M:OnEnable()
    -- Register events
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("ADDON_LOADED")
    
    -- Apply saved frame settings
    if self.ApplyAllFrameSettings then
        self:ApplyAllFrameSettings()
    end
    
    -- Debug message
    VUI:Debug(self.NAME .. " enabled")
end

-- Disable the module
function M:OnDisable()
    -- Unregister all events
    self:UnregisterAllEvents()
    
    -- Reset frames to default positions if needed
    if self.ResetAllFrames then
        self:ResetAllFrames()
    end
    
    -- Debug message
    VUI:Debug(self.NAME .. " disabled")
end

-- Slash command handler
function M:SlashCommand(input)
    if input == "toggle" then
        self.db.profile.enabled = not self.db.profile.enabled
        VUI:Print("|cffff9900" .. self.TITLE .. ":|r " .. (self.db.profile.enabled and "Enabled" or "Disabled"))
    else
        -- Open configuration
        if self.ShowOptions then
            self:ShowOptions()
        else
            VUI.Config:OpenToCategory(self.TITLE)
        end
    end
end

-- Configuration initialization
function M:InitializeConfig()
    -- Register with VUI's configuration system
    VUI.Config:RegisterModuleOptions(self.NAME, function()
        -- Open the configuration panel
        if self.ShowOptions then
            self:ShowOptions()
        end
    end)
end

-- Event handler for PLAYER_ENTERING_WORLD
function M:PLAYER_ENTERING_WORLD()
    -- Apply frame settings after world loads
    if self.ApplyAllFrameSettings then
        C_Timer.After(1, function()
            self:ApplyAllFrameSettings()
        end)
    end
end

-- Export the module to VUI namespace
VUI.VUIAnyFrame = M