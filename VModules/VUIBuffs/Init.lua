-------------------------------------------------------------------------------
-- VUIBuffs Module
-- Enhances buff/debuff display with configurable frames
-------------------------------------------------------------------------------

-- First, make sure we have a global placeholder for localization
-- This is critical for locale files that might load before the module is fully initialized
_G["VUIBuffs"] = _G["VUIBuffs"] or {}
_G["VUIBuffs"].L = _G["VUIBuffs"].L or {}

-- Now proceed with normal module initialization
local AddonName, VUI = ...
local MODNAME = "VUIBuffs"

-- Safety check to ensure VUI is available before calling NewModule
local M
if VUI and VUI.NewModule then
    M = VUI:NewModule(MODNAME, "AceEvent-3.0", "AceConsole-3.0", "AceTimer-3.0")
    -- Update the global reference with the actual module
    _G["VUIBuffs"] = M
else
    -- If VUI isn't ready, use the placeholder as a fallback
    M = _G["VUIBuffs"]
    
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
    if not M.ScheduleTimer then
        M.ScheduleTimer = function(self, ...) end
    end
end

-- Store the existing localization table that might have been populated by locale files
local existingL = _G["VUIBuffs"].L

-- Restore and merge any existing localization data
M.L = existingL

-- Module Constants
M.NAME = MODNAME
M.TITLE = "VUI Buffs"
M.DESCRIPTION = "Enhanced buff and debuff display with configurable frames"
M.VERSION = "1.0"

-- Default settings
M.defaults = {
    profile = {
        enabled = true,
        locked = true,
        clampToScreen = true,
        
        -- Frame settings
        frames = {
            player_buffs = {
                enabled = true,
                position = {"TOPRIGHT", UIParent, "TOPRIGHT", -180, -22},
                growDirection = "LEFT_DOWN",
                iconSize = 30,
                iconsPerRow = 8,
                showDuration = true,
                sortMethod = "TIME",
                sortDirection = "DESCENDING",
                filter = "HELPFUL",
                unitID = "player",
                showOnlyMine = false
            },
            player_debuffs = {
                enabled = true,
                position = {"TOPRIGHT", UIParent, "TOPRIGHT", -180, -90},
                growDirection = "LEFT_DOWN",
                iconSize = 30,
                iconsPerRow = 8,
                showDuration = true,
                sortMethod = "TIME",
                sortDirection = "DESCENDING",
                filter = "HARMFUL",
                unitID = "player",
                showOnlyMine = false
            },
            target_buffs = {
                enabled = true,
                position = {"TOPLEFT", UIParent, "TOPLEFT", 180, -22},
                growDirection = "RIGHT_DOWN",
                iconSize = 26,
                iconsPerRow = 8,
                showDuration = true,
                sortMethod = "TIME",
                sortDirection = "DESCENDING",
                filter = "HELPFUL",
                unitID = "target",
                showOnlyMine = true
            },
            target_debuffs = {
                enabled = true,
                position = {"TOPLEFT", UIParent, "TOPLEFT", 180, -82},
                growDirection = "RIGHT_DOWN",
                iconSize = 26,
                iconsPerRow = 8,
                showDuration = true,
                sortMethod = "TIME",
                sortDirection = "DESCENDING",
                filter = "HARMFUL",
                unitID = "target",
                showOnlyMine = false
            }
        },
        
        -- Visual settings
        visuals = {
            borderStyle = "VUI_BORDER_1PX",
            borderSize = 1,
            showCooldownSpiral = true,
            showCooldownNumbers = true,
            colorizeDebuffBorder = true,
            colorizeBuffs = true,
            useClassColors = true,
            glowImportantAuras = true,
            glowType = "pixel",
            
            -- Custom colors
            colors = {
                Magic = {r = 0.2, g = 0.6, b = 1.0, a = 1.0},
                Curse = {r = 0.6, g = 0.0, b = 1.0, a = 1.0},
                Disease = {r = 0.6, g = 0.4, b = 0.0, a = 1.0},
                Poison = {r = 0.0, g = 0.6, b = 0.0, a = 1.0},
                Buff = {r = 0.4, g = 0.4, b = 0.4, a = 1.0}
            }
        },
        
        -- Filter settings
        filtering = {
            whitelist = {},
            blacklist = {},
            trackWeaponEnchants = true,
            hideBlizzardFrames = true
        }
    }
}

-- Initialize the module
function M:OnInitialize()
    -- Create the database
    self.db = VUI.db:RegisterNamespace(self.NAME, {
        profile = self.defaults.profile
    })
    
    -- Create a reference in VUIBuffs (existing code expects this)
    _G.VUIBuffs = _G.VUIBuffs or {}
    _G.VUIBuffs.db = self.db
    
    -- Copy functions from the existing VUIBuffs module
    for key, func in pairs(VUIBuffs) do
        if type(func) == "function" and not self[key] then
            self[key] = func
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
    
    -- Initialize UI components (using existing code)
    if self.CreateFrames then
        self:CreateFrames()
    end
    
    -- Register slash command
    self:RegisterChatCommand("vuibuffs", "SlashCommand")
    
    -- Setup data broker
    if self.SetupDataBroker then
        self:SetupDataBroker()
    end
    
    -- Check for compatible addons
    if self.CheckForSupportedAddons then
        self:CheckForSupportedAddons()
    end
    
    -- Debug message
    VUI:Debug(self.NAME .. " initialized")
end

-- Enable the module
function M:OnEnable()
    -- Register events
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("UNIT_AURA")
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
    self:RegisterEvent("PLAYER_FOCUS_CHANGED")
    self:RegisterEvent("GROUP_ROSTER_UPDATE")
    
    -- Debug message
    VUI:Debug(self.NAME .. " enabled")
end

-- Disable the module
function M:OnDisable()
    -- Unregister all events
    self:UnregisterAllEvents()
    
    -- Hide all frames
    if self.frames then
        for _, frame in pairs(self.frames) do
            if frame:IsShown() then
                frame:Hide()
            end
        end
    end
    
    -- Debug message
    VUI:Debug(self.NAME .. " disabled")
end

-- Configuration initialization
function M:InitializeConfig()
    -- Register with VUI's configuration system
    VUI.Config:RegisterModuleOptions(self.NAME, function()
        -- Open the configuration panel
        if self.OpenOptions then
            self:OpenOptions()
        end
    end)
end

-- Export the module to VUI namespace
VUI.VUIBuffs = M