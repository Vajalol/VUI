-------------------------------------------------------------------------------
-- VUIAnyFrame Module
-- Allows repositioning of any UI element
-- Based on MoveAny by D4KiR with VUI integration
-------------------------------------------------------------------------------

-- Standard module registration
local AddonName, VUI = ...
local MODNAME = "VUIAnyFrame"
local M = VUI:NewModule(MODNAME, "AceEvent-3.0", "AceConsole-3.0", "AceHook-3.0")

-- For backward compatibility
_G.VUIAnyFrame = M
VUI.VUIAnyFrame = M

-- Localization
VUIAnyFrame.L = VUIAnyFrame.L or {}
local L = VUIAnyFrame.L

-- Localization (changing to use M instead of VUIAnyFrame)
M.L = M.L or {}
local L = M.L

-- Default settings
VUIAnyFrame.defaults = {
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

-- Initialize the VUIAnyFrame addon
function VUIAnyFrame:OnInitialize()
    -- Create and register VUIAnyFrame as a VUI module
    if VUI and VUI.NewModule then
        self.module = VUI:NewModule(MODNAME)
        VUI.VUIAnyFrame = self.module
        
        -- Copy VUIAnyFrame functions to the module
        for k, v in pairs(self) do
            if type(v) == "function" and not self.module[k] then
                self.module[k] = v
            end
        end
    end
    
    -- Create the database using VUI's db
    if VUI and VUI.db then
        self.db = VUI.db:RegisterNamespace(MODNAME, {
            profile = self.defaults.profile
        })
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
    
    -- Set up minimap button
    if self.SetupDataBroker then
        self:SetupDataBroker()
    end
    
    -- Register slash commands
    self:RegisterChatCommand("vuianyframe", "SlashCommand")
    self:RegisterChatCommand("va", "SlashCommand")
    
    -- Debug message
    if VUI and VUI.Debug then
        VUI:Debug(MODNAME .. " initialized")
    end
end

-- Enable the module
function VUIAnyFrame:OnEnable()
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
        VUI:Debug(MODNAME .. " enabled")
    end
end

-- Disable the module
function VUIAnyFrame:OnDisable()
    -- Unregister all events
    self:UnregisterAllEvents()
    
    -- Reset frames to default positions if needed
    if self.ResetAllFrames then
        self:ResetAllFrames()
    end
    
    -- Debug message
    if VUI and VUI.Debug then
        VUI:Debug(MODNAME .. " disabled")
    end
end

-- Slash command handler
function VUIAnyFrame:SlashCommand(input)
    if input == "toggle" then
        self.db.profile.enabled = not self.db.profile.enabled
        if VUI and VUI.Print then
            VUI:Print("|cffff9900" .. self.TITLE .. ":|r " .. (self.db.profile.enabled and "Enabled" or "Disabled"))
        end
    else
        -- Open configuration
        if self.ShowOptions then
            self:ShowOptions()
        elseif VUI and VUI.Config then
            VUI.Config:OpenToCategory(self.TITLE)
        end
    end
end

-- Configuration initialization
function VUIAnyFrame:InitializeConfig()
    -- Register with VUI's configuration system
    if VUI and VUI.Config then
        VUI.Config:RegisterModuleOptions(self.NAME, function()
            -- Open the configuration panel
            if self.ShowOptions then
                self:ShowOptions()
            end
        end)
    end
end

-- Event handler for PLAYER_ENTERING_WORLD
function VUIAnyFrame:PLAYER_ENTERING_WORLD()
    -- Apply frame settings after world loads
    if self.ApplyAllFrameSettings then
        C_Timer.After(1, function()
            self:ApplyAllFrameSettings()
        end)
    end
end