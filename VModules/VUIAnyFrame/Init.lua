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
    if not M.RegisterEvent then
        M.RegisterEvent = function(self, ...) end
    end
    if not M.RegisterChatCommand then
        M.RegisterChatCommand = function(self, ...) end
    end
    if not M.UnregisterEvent then
        M.UnregisterEvent = function(self, ...) end
    end
    if not M.RegisterMessage then
        M.RegisterMessage = function(self, ...) end
    end
    
    -- Set a flag to attempt proper initialization later
    M.needsInit = true
end

-- Define colors (same as MoveAny)
local colors = {}
colors["bg"] = {0.03, 0.03, 0.03}
colors["se"] = {1.0, 1.0, 0.0}
colors["el"] = {0.6, 0.84, 1.0}
colors["hidden"] = {1.0, 0.0, 0.0}
colors["clickthrough"] = {0.2, 0.2, 1.0}

-- Localization
M.L = M.L or {}
local L = M.L

-- Set module metadata
M.TITLE = "VUI AnyFrame"
M.VERSION = "1.0.0"
M.DESCRIPTION = "Allows you to move and modify any UI frame."
M.AUTHOR = "VUI Team, based on MoveAny by D4KiR"
M.CATEGORY = "UI Management"

-- D4Lib Compatibility Layer
-- Add required D4Lib functions to VUIAnyFrame
M.D4 = M.D4 or {}

-- D4Lib Output
M.MSG = function(self, msg)
    if VUI and VUI.Print then
        VUI:Print("|cff00aaff" .. self.TITLE .. ":|r " .. msg)
    else
        print("|cff00aaff" .. self.TITLE .. ":|r " .. msg)
    end
end

-- D4Lib Math/Grid
M.Round = function(self, val, decimal)
    if decimal then
        return math.floor((val * 10^decimal) + 0.5) / (10^decimal)
    else
        return math.floor(val + 0.5)
    end
end

-- D4Lib Settings (similar to original MoveAny but using VUI's database)
M.GetCVar = function(self, key)
    return GetCVar(key) or ""
end

-- Default settings (matching MoveAny's structure)
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
            hideBlizzardFrames = {},
            customScale = 1.0,
            useUIScale = true
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
        self.db = VUI.db:RegisterNamespace(self.NAME, self.defaults)
    else
        -- Create a basic database structure if VUI.db isn't available
        self.db = {
            profile = self.defaults.profile,
            RegisterCallback = function() end
        }
        if VUI and VUI.Debug then
            VUI:Debug(self.NAME .. " using fallback database")
        end
    end
    
    -- Register callback for theme changes
    if VUI and VUI.RegisterCallback then
        VUI:RegisterCallback("OnThemeChanged", function()
            if self.UpdateTheme then
                self:UpdateTheme()
            end
        end)
    end
    
    -- Register slash commands
    self:RegisterChatCommand("vuianyframe", "SlashCommand")
    self:RegisterChatCommand("va", "SlashCommand")
    
    -- Initialize the module components
    self:InitSettings()
    self:CreateFrames()
    
    -- Debug message
    if VUI and VUI.Debug then
        VUI:Debug(self.NAME .. " initialized")
    end
    
    -- Set up VUI Integration
    self:InitVUIIntegration()
end

-- Enable the module
function M:OnEnable()
    -- Register events
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("ADDON_LOADED")
    
    -- Apply saved frame settings
    self:ApplySettings()
    
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
    self:ResetAllFrameSettings()
    
    -- Debug message
    if VUI and VUI.Debug then
        VUI:Debug(self.NAME .. " disabled")
    end
end

-- PLAYER_ENTERING_WORLD event handler
function M:PLAYER_ENTERING_WORLD()
    -- Apply frame settings after world loads
    C_Timer.After(1, function()
        self:ApplySettings()
    end)
    
    -- Register common widgets that should be movable
    C_Timer.After(2, function()
        self:RegisterCommonWidgets()
    end)
end

-- PLAYER_REGEN_DISABLED event handler
function M:PLAYER_REGEN_DISABLED()
    -- Auto-lock frames in combat
    if self.db.profile.global.lockFrames then
        self:Lock()
    end
end

-- PLAYER_REGEN_ENABLED event handler
function M:PLAYER_REGEN_ENABLED()
    -- Re-apply settings after combat
    C_Timer.After(0.5, function()
        self:ApplySettings()
    end)
end

-- ADDON_LOADED event handler
function M:ADDON_LOADED(event, addonName)
    -- Check if it's our addon or a dependency
    if addonName == "VUI" or addonName == "Blizzard_CompactRaidFrames" then
        C_Timer.After(1, function()
            self:RegisterCommonWidgets()
            self:ApplySettings()
        end)
    end
end

-- Slash command handler
function M:SlashCommand(input)
    if not input or input == "" then
        self:ToggleLock()
    elseif input == "enable" or input == "on" then
        self.db.profile.enabled = true
        self:OnEnable()
        self:Print("Enabled")
    elseif input == "disable" or input == "off" then
        self.db.profile.enabled = false
        self:OnDisable()
        self:Print("Disabled")
    elseif input == "toggle" then
        self.db.profile.enabled = not self.db.profile.enabled
        if self.db.profile.enabled then
            self:OnEnable()
        else
            self:OnDisable()
        end
        self:Print(self.db.profile.enabled and "Enabled" or "Disabled")
    elseif input == "unlock" then
        self:Unlock()
    elseif input == "lock" then
        self:Lock()
    elseif input == "reset" then
        self:ResetAllFrameSettings()
        self:Print("All frames reset to default positions")
    elseif input == "config" or input == "options" then
        self:OpenOptions()
    else
        self:Print("Commands:")
        self:Print("/va - Toggle lock/unlock")
        self:Print("/va lock - Lock frames")
        self:Print("/va unlock - Unlock frames")
        self:Print("/va reset - Reset all frames")
        self:Print("/va config - Open configuration")
        self:Print("/va enable/disable - Enable/Disable addon")
    end
end

-- Toggle lock/unlock state
function M:ToggleLock()
    if self.db.profile.global.lockFrames then
        self:Unlock()
    else
        self:Lock()
    end
end

-- Print a formatted message
function M:Print(...)
    if VUI and VUI.Print then
        VUI:Print("|cff00aaff" .. self.TITLE .. ":|r ", ...)
    else
        print("|cff00aaff" .. self.TITLE .. ":|r ", ...)
    end
end

-- Get color by key
function M:GetColor(key)
    return colors[key][1], colors[key][2], colors[key][3]
end 