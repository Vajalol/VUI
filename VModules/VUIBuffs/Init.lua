-------------------------------------------------------------------------------
-- VUIBuffs Module
-- Enhances buff/debuff display with configurable frames
-------------------------------------------------------------------------------

-- Standard module registration
local AddonName, VUI = ...
local MODNAME = "VUIBuffs"
local M = VUI:NewModule(MODNAME, "AceEvent-3.0", "AceConsole-3.0", "AceTimer-3.0")

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
    -- Module constants
    self.NAME = MODNAME
    self.TITLE = "VUI Buffs"
    self.DESCRIPTION = "Enhances buff/debuff display with configurable frames"
    self.VERSION = VUI.Version or "1.0"
    
    -- Create the database using VUI's db
    self.db = VUI.db:RegisterNamespace(self.NAME, {
        profile = self.defaults.profile
    })
    
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

-- Helper function for standardized debugging
function M:Debug(...)
    if VUI and VUI.Debug then
        VUI:Debug(self.NAME, ...)
    end
end