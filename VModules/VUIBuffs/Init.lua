-------------------------------------------------------------------------------
-- VUIBuffs Module
-- Enhances buff/debuff display with configurable frames
-------------------------------------------------------------------------------

<<<<<<< HEAD
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
        M.RegisterEvent = function(self, eventName, callback)
            -- Log that we tried to register but couldn't
            print("|cffff9900VUIBuffs Warning:|r Attempted to register event " .. eventName .. " but module not fully initialized")
        end
    end
    if not M.RegisterChatCommand then
        M.RegisterChatCommand = function(self, command)
            -- Log that we tried to register but couldn't
            print("|cffff9900VUIBuffs Warning:|r Attempted to register slash command /" .. command .. " but module not fully initialized")
        end
    end
    if not M.UnregisterEvent then
        M.UnregisterEvent = function(self, eventName)
            -- Log that we tried to unregister but couldn't
            print("|cffff9900VUIBuffs Warning:|r Attempted to unregister event " .. (eventName or "unknown") .. " but module not fully initialized")
        end
    end
    if not M.RegisterMessage then
        M.RegisterMessage = function(self, messageName)
            -- Log that we tried to register but couldn't
            print("|cffff9900VUIBuffs Warning:|r Attempted to register message " .. messageName .. " but module not fully initialized")
        end
    end
    if not M.ScheduleTimer then
        M.ScheduleTimer = function(self, callback, delay)
            -- Log that we tried to schedule but couldn't
            print("|cffff9900VUIBuffs Warning:|r Attempted to schedule timer but module not fully initialized")
            
            -- Try to use C_Timer as a fallback
            if type(callback) == "function" and delay and delay > 0 then
                C_Timer.After(delay, callback)
            end
        end
    end
end

-- Store the existing localization table that might have been populated by locale files
local existingL = _G["VUIBuffs"].L

-- Restore and merge any existing localization data
M.L = existingL
=======
-- Standard module registration
local AddonName, VUI = ...
local M = VUI:NewModule("VUIBuffs", "AceEvent-3.0", "AceConsole-3.0", "AceTimer-3.0")
>>>>>>> f2841d4c299e00869d4563d9e99c5e582069affc

-- For backward compatibility
_G.VUIBuffs = M
VUI.VUIBuffs = M

-- Localization setup
VUIBuffs.L = VUIBuffs.L or {}
local L = VUIBuffs.L

-- Provide compatibility function for localizations
VUIBuffs.GetSpellInfo = GetSpellInfo

-- Default settings
VUIBuffs.defaults = {
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

-- Initialize the VUIBuffs module
function M:OnInitialize()
<<<<<<< HEAD
    -- Create the database with consistent naming
    if VUI and VUI.db then
        -- Make sure namespaces exists to avoid nil indexing
        if not VUI.db.namespaces then
            VUI.db.namespaces = {}
        end
        
        -- Check if a namespace already exists with any of the possible names
        local namespace = VUI.db.namespaces["VUIBuffs"] or VUI.db.namespaces["vuibuffs"]
        
        if namespace then
            -- Use existing namespace
            self.db = namespace
            
            -- Ensure both versions are synchronized
            VUI.db.namespaces["VUIBuffs"] = namespace
            VUI.db.namespaces["vuibuffs"] = namespace
        else
            -- Create new namespace with proper case for consistency
            self.db = VUI.db:RegisterNamespace("VUIBuffs", {
                profile = self.defaults.profile
            })
            
            -- Also create lowercase reference for compatibility
            VUI.db.namespaces["vuibuffs"] = self.db
        end
    else
        -- Fallback if VUI.db isn't available
        self.db = {profile = self.defaults.profile}
    end
=======
    -- Module constants
    self.NAME = MODNAME
    self.TITLE = "VUI Buffs"
    self.DESCRIPTION = "Enhances buff/debuff display with configurable frames"
    self.VERSION = VUI.Version or "1.0"
    
    -- Create the database using VUI's db
    self.db = VUI.db:RegisterNamespace(self.NAME, {
        profile = self.defaults.profile
    })
>>>>>>> f2841d4c299e00869d4563d9e99c5e582069affc
    
    -- Register callback for theme changes
    if VUI then
        VUI:RegisterCallback("OnThemeChanged", function()
            if self.UpdateTheme then
                self:UpdateTheme()
            end
        end)
    end
    
    -- Register with VUI's configuration system
    if VUI and VUI.Config then
        VUI.Config:RegisterModuleOptions(MODNAME, function()
            -- Open the configuration panel
            if self.OpenOptions then
                self:OpenOptions()
            end
        end)
    end
    
    -- Initialize UI components
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
    if VUI and VUI.Debug then
        VUI:Debug(MODNAME .. " initialized")
    end
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
    self:Debug("enabled")
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
    self:Debug("disabled")
end

<<<<<<< HEAD
-- Configuration initialization
function M:InitializeConfig()
    -- Register with VUI's configuration system
    if VUI and VUI.Config and type(VUI.Config.RegisterModuleOptions) == "function" then
        VUI.Config:RegisterModuleOptions(self.NAME, function()
            -- Open the configuration panel
            if self.OpenOptions then
                self:OpenOptions()
            end
        end)
    end
end

-- Export the module to VUI namespace
VUI.VUIBuffs = M
=======
-- Helper function for standardized debugging
function M:Debug(...)
    if VUI and VUI.Debug then
        VUI:Debug(self.NAME, ...)
    end
end
>>>>>>> f2841d4c299e00869d4563d9e99c5e582069affc
