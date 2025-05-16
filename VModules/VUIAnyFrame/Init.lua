-------------------------------------------------------------------------------
-- VUIAnyFrame Module
-- Allows repositioning of any UI element
-- Based on MoveAny by D4KiR with VUI integration
-------------------------------------------------------------------------------

-- Create a global placeholder to ensure references work even during initialization
_G["VUIAnyFrame"] = _G["VUIAnyFrame"] or {}

-- Now attempt to initialize the module properly
local AddonName, VUI = ...
local MODNAME = "VUIAnyFrame"

-- Safety check to ensure VUI is available before calling NewModule
local M
if VUI and VUI.NewModule then
    M = VUI:NewModule(MODNAME, "AceEvent-3.0", "AceConsole-3.0", "AceHook-3.0")
    -- Update the global reference with the actual module
    _G["VUIAnyFrame"] = M
else
    -- If VUI isn't ready, use the placeholder as a fallback
    M = _G["VUIAnyFrame"]
    
    -- Add minimal AceEvent-like functionality to the placeholder
    -- This prevents 'attempt to call method RegisterEvent (a nil value)' errors
    if not M.RegisterEvent then
        M.RegisterEvent = function(self, ...) end -- Stub function that accepts parameters but does nothing
    end
    if not M.RegisterChatCommand then
        M.RegisterChatCommand = function(self, ...) end -- Stub function that accepts parameters but does nothing
    end
    
    -- Add additional Ace library stubs that might be needed
    if not M.UnregisterEvent then
        M.UnregisterEvent = function(self, ...) end
    end
    if not M.RegisterMessage then
        M.RegisterMessage = function(self, ...) end
    end
    
    -- Set a flag to attempt proper initialization later
    M.needsInit = true
end

-- Localization - Use the module's localization table directly
-- This avoids the 'No locales registered for VUI' error
local L = _G["VUIAnyFrame"].L or {}

-- Localization (changing to use M instead of VUIAnyFrame)
M.L = M.L or {}
local L = M.L

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

-- Initialize the VUIAnyFrame module
function M:OnInitialize()
    -- Create the database with proper error handling
    if VUI and VUI.db then
        -- Make sure namespaces exists to avoid nil indexing
        if not VUI.db.namespaces then
            VUI.db.namespaces = {}
        end
        
        -- Check if the namespace already exists before creating a new one
        if VUI.db.namespaces[self.NAME] then
            self.db = VUI.db.namespaces[self.NAME]
        else
            -- Create new namespace
            self.db = VUI.db:RegisterNamespace(self.NAME, {
                profile = self.defaults.profile
            })
        end
    else
        -- Create a basic database structure if VUI.db isn't available
        self.db = {
            profile = self.defaults.profile,
            RegisterCallback = function() end
        }
        VUI:Debug(self.NAME .. " using fallback database")
    end
    
    -- Register callback for theme changes
    if VUI then
        VUI:RegisterCallback("OnThemeChanged", function()
            if self.UpdateTheme then
                self:UpdateTheme()
            end
        end)
    end
    
    -- Initialize the configuration panel
    self:InitializeConfig()
    
    -- Register callback for theme changes
    if VUI and VUI.RegisterCallback then
        VUI:RegisterCallback("OnThemeChanged", function()
            if self.UpdateTheme then
                self:UpdateTheme()
            end
        end)
    end
    
    -- Set up minimap button
    if self.SetupDataBroker then
        self:SetupDataBroker()
    end
    
    -- Register slash commands
    self:RegisterChatCommand("vuianyframe", "SlashCommand")
    self:RegisterChatCommand("va", "SlashCommand")
    
    -- Debug message
    if VUI and VUI.Debug then
        VUI:Debug(self.NAME .. " initialized")
    end
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
    if VUI and VUI.Debug then
        VUI:Debug(self.NAME .. " enabled")
    end
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
    if VUI and VUI.Debug then
        VUI:Debug(self.NAME .. " disabled")
    end
end

-- Slash command handler
function M:SlashCommand(input)
    if input == "toggle" then
        self.db.profile.enabled = not self.db.profile.enabled
        if VUI and type(VUI.Print) == "function" then
            VUI:Print("|cffff9900" .. self.TITLE .. ":|r " .. (self.db.profile.enabled and "Enabled" or "Disabled"))
        else
            print("|cffff9900" .. self.TITLE .. ":|r " .. (self.db.profile.enabled and "Enabled" or "Disabled"))
        end
    else
        -- Open configuration
        if self.ShowOptions then
            self:ShowOptions()
        elseif VUI and VUI.Config and type(VUI.Config.OpenToCategory) == "function" then
            VUI.Config:OpenToCategory(self.TITLE)
        end
    end
end

-- Configuration initialization
function M:InitializeConfig()
    -- Register with VUI's configuration system
    if VUI and VUI.Config and type(VUI.Config.RegisterModuleOptions) == "function" then
        VUI.Config:RegisterModuleOptions(self.NAME, function()
            -- Open the configuration panel
            if self.ShowOptions then
                self:ShowOptions()
            end
        end)
    end
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