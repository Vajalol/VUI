-------------------------------------------------------------------------------
-- VUITGCD Module Initialization
-- Based on TrufiGCD (stevemyz@gmail.com)
-- Displays global cooldown icons and ability usage
-------------------------------------------------------------------------------

local AddonName, VUI = ...
local MODNAME = "VUITGCD"

-- Initialize global namespaces
if not _G.VUI then _G.VUI = {} end
if not _G.VUI.TGCD then _G.VUI.TGCD = {} end
if not _G.VUITGCD then _G.VUITGCD = {} end

-- Backward compatibility globals
_G.VUITGCD.settings = _G.VUITGCD.settings or {}
_G.VUITGCD.units = _G.VUITGCD.units or {}
_G.VUITGCD.constants = _G.VUITGCD.constants or {unitTypes = {}}

-- Create local namespace reference
local ns = _G.VUI.TGCD

-- Ensure required namespaces exist
ns.Utils = ns.Utils or {}
ns.Settings = ns.Settings or {}
ns.UI = ns.UI or {}
ns.Icons = ns.Icons or {}
ns.frameUtils = ns.frameUtils or {}

-- Basic utility functions required early
ns.Utils.size = function(tbl)
    if type(tbl) ~= "table" then return 0 end
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

ns.Utils.tableContains = function(table, element)
    if type(table) ~= "table" then return false end
    for _, value in pairs(table) do
        if value == element then return true end
    end
    return false
end

ns.Utils.tableCopy = function(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            copy[k] = ns.Utils.tableCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

ns.Utils.tablelength = function(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

ns.Utils.isEmpty = function(s)
    return s == nil or s == ''
end

ns.Utils.isNumber = function(s)
    return tonumber(s) ~= nil
end

ns.Utils.round = function(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

-- Constants
ns.constants = ns.constants or {}
ns.constants.unitTypes = ns.constants.unitTypes or {"player", "target", "focus", "party1", "party2", "party3", "party4", "arena1", "arena2", "arena3"}
ns.constants.directions = ns.constants.directions or {"UP", "RIGHT", "DOWN", "LEFT"}
ns.constants.TEXT_ANCHOR_POINTS = ns.constants.TEXT_ANCHOR_POINTS or {"TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "CENTER", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"}

-- Function to synchronize settings between VUI and TrufiGCD
local function syncSettings(module)
    if not module or not module.db or not module.db.profile then return end
    
    -- Ensure TrufiGCD settings exist
    if not ns.settings or not ns.settings.activeProfile then return end
    
    -- Sync general settings
    if ns.settings.activeProfile.enabledIn then
        ns.settings.activeProfile.enabledIn.enabled = module.db.profile.enabled
        
        -- Location settings
        if module.db.profile.instances then
            ns.settings.activeProfile.enabledIn.world = module.db.profile.instances.showInWorld
            ns.settings.activeProfile.enabledIn.party = module.db.profile.instances.showInInstances
            ns.settings.activeProfile.enabledIn.raid = module.db.profile.instances.showInRaid
            ns.settings.activeProfile.enabledIn.arena = module.db.profile.instances.showInPVP
            ns.settings.activeProfile.enabledIn.battleground = module.db.profile.instances.showInPVP
            ns.settings.activeProfile.enabledIn.combatOnly = module.db.profile.instances.combatOnly
        end
    end
    
    -- Sync layout settings for each unit type
    if ns.settings.activeProfile.layoutSettings then
        for unitType, layoutSettings in pairs(ns.settings.activeProfile.layoutSettings) do
            if unitType and layoutSettings then
                -- Get unit settings from VUI db
                local unitConfig = module.db.profile.unitSettings and module.db.profile.unitSettings[unitType]
                if unitConfig then
                    layoutSettings.enable = unitConfig.enable
                    layoutSettings.iconSize = module.db.profile.iconSize or 30
                    layoutSettings.direction = module.db.profile.direction or "DOWN"
                    layoutSettings.iconsNumber = module.db.profile.maxIcons or 8
                end
            end
        end
    end
    
    -- Update location check based on new settings
    if ns.locationCheck and ns.locationCheck.settingsChanged then
        ns.locationCheck.settingsChanged()
    end
    
    -- Save settings to ensure they're persisted
    if ns.settings.Save then
        ns.settings:Save()
    end
end

-- Module creation with safety for early loading
local M
if VUI and VUI.NewModule then
    M = VUI:NewModule(MODNAME, "AceEvent-3.0")
    
    -- Default settings - these values match TrufiGCD defaults
    M.defaults = {
        profile = {
            enabled = true,
            
            -- Layout defaults
            iconSize = 30,
            iconAlpha = 1.0,
            fadeTime = 0.5,
            maxIcons = 8,
            direction = "DOWN",
            
            -- Visual defaults
            showBorders = true,
            showSpellName = false,
            showCooldownSwipe = true,
            colorBySpellType = true,
            
            -- Masque support
            enableMasque = true,
            
            -- Filter settings
            showGCDOnly = false,
            hideMacroText = false,
            
            -- Location settings
            instances = {
                showInWorld = true,
                showInInstances = true,
                showInRaid = true,
                showInPVP = true,
                combatOnly = false,
            },
            
            -- Unit tracking
            unitSettings = {
                player = {
                    enable = true,
                    scale = 1.0,
                    alpha = 1.0,
                    position = {"CENTER", 0, 0},
                    lockFrame = false,
                },
                target = {
                    enable = false,
                    scale = 1.0,
                    alpha = 1.0,
                    position = {"CENTER", 40, 0},
                    lockFrame = false,
                },
                focus = {
                    enable = false,
                    scale = 1.0,
                    alpha = 1.0,
                    position = {"CENTER", -40, 0},
                    lockFrame = false,
                },
                party1 = {
                    enable = false,
                    scale = 1.0,
                    alpha = 1.0,
                    position = {"CENTER", 80, 0},
                    lockFrame = false,
                },
                party2 = {
                    enable = false,
                    scale = 1.0,
                    alpha = 1.0,
                    position = {"CENTER", 120, 0},
                    lockFrame = false,
                },
                party3 = {
                    enable = false,
                    scale = 1.0,
                    alpha = 1.0,
                    position = {"CENTER", 160, 0},
                    lockFrame = false,
                },
                party4 = {
                    enable = false,
                    scale = 1.0,
                    alpha = 1.0,
                    position = {"CENTER", 200, 0},
                    lockFrame = false,
                },
                arena1 = {
                    enable = false,
                    scale = 1.0,
                    alpha = 1.0,
                    position = {"CENTER", -80, 0},
                    lockFrame = false,
                },
                arena2 = {
                    enable = false,
                    scale = 1.0,
                    alpha = 1.0,
                    position = {"CENTER", -120, 0},
                    lockFrame = false,
                },
                arena3 = {
                    enable = false,
                    scale = 1.0,
                    alpha = 1.0,
                    position = {"CENTER", -160, 0},
                    lockFrame = false,
                }
            },
            
            -- Blocklist
            blocklist = {},
            
            -- Profile settings
            profiles = {},
            currentProfile = "Default",
        }
    }
    
    -- Register update events
    M:RegisterEvent("PLAYER_ENTERING_WORLD", function() 
        syncSettings(M) 
    end)
    
    -- Override OnEnable to ensure settings sync
    local originalOnEnable = M.OnEnable
    M.OnEnable = function(self)
        if originalOnEnable then originalOnEnable(self) end
        syncSettings(self)
    end
    
    -- Store module in global namespace for VUI integration
    VUI.VUITGCD = M
else
    -- Fallback for early loading
    M = {}
    M.NAME = MODNAME
    M.Debug = function(self, msg) print("[VUITGCD] " .. tostring(msg)) end
    M.OnInitialize = function() end
    M.OnEnable = function() end
    M.defaults = {
        profile = {
            enabled = true,
            -- other defaults as above
        }
    }
end

-- Connect to global namespace for backward compatibility
_G.VUITGCD.M = M

-- Module properties
M.NAME = MODNAME
M.TITLE = "VUI Global Cooldowns"
M.DESCRIPTION = "Displays ability usage with animated icons"
M.VERSION = GetAddOnMetadata("VUI", "Version") or "Unknown"

-- Add early load support
local earlyLoadFrame = CreateFrame("Frame")
earlyLoadFrame:RegisterEvent("ADDON_LOADED")
earlyLoadFrame:SetScript("OnEvent", function(self, event, addon)
    if addon == "VUI" then
        self:UnregisterEvent("ADDON_LOADED")
        
        -- Make the settings available to the TrufiGCD compatible namespace
        ns.settings = ns.settings or {}
        ns.settings.getModuleSettings = function()
            if VUI and VUI.VUITGCD and VUI.VUITGCD.db then
                return VUI.VUITGCD.db.profile
            end
            return M.defaults.profile
        end
        
        -- Print successful load message when in verbose mode
        if VUI and VUI.verbose then
            print("|cff00BBBBVUI TrufiGCD:|r Module initialized")
        end
    end
end)

-- Add SyncWithVUIConfig function after module initialization
function M:SyncWithVUIConfig()
    if not self.db or not self.db.profile then return end
    
    -- Get reference to TrufiGCD namespace
    local ns = _G.VUI.TGCD
    if not ns or not ns.settings or not ns.settings.activeProfile then return end
    
    -- Sync general settings
    if ns.settings.activeProfile.enabledIn then
        ns.settings.activeProfile.enabledIn.enabled = self.db.profile.enabled
        
        -- Location settings
        if self.db.profile.instances then
            ns.settings.activeProfile.enabledIn.world = self.db.profile.instances.showInWorld
            ns.settings.activeProfile.enabledIn.party = self.db.profile.instances.showInInstances
            ns.settings.activeProfile.enabledIn.raid = self.db.profile.instances.showInRaid
            ns.settings.activeProfile.enabledIn.arena = self.db.profile.instances.showInPVP
            ns.settings.activeProfile.enabledIn.battleground = self.db.profile.instances.showInPVP
            ns.settings.activeProfile.enabledIn.combatOnly = self.db.profile.instances.combatOnly
        end
    end
    
    -- Sync layout settings
    if ns.settings.activeProfile.layoutSettings then
        for layoutType, layoutSettings in pairs(ns.settings.activeProfile.layoutSettings) do
            layoutSettings.iconSize = self.db.profile.iconSize or 30
            layoutSettings.direction = self.db.profile.direction or "DOWN"
            layoutSettings.iconsNumber = self.db.profile.maxIcons or 8
            
            -- Enable settings based on unit type mapping
            if layoutType == "player" then
                layoutSettings.enable = self.db.profile.unitSettings and 
                                        self.db.profile.unitSettings.player and 
                                        self.db.profile.unitSettings.player.enable
            elseif layoutType == "target" then
                layoutSettings.enable = self.db.profile.unitSettings and 
                                        self.db.profile.unitSettings.target and 
                                        self.db.profile.unitSettings.target.enable
            elseif layoutType == "focus" then
                layoutSettings.enable = self.db.profile.unitSettings and 
                                        self.db.profile.unitSettings.focus and 
                                        self.db.profile.unitSettings.focus.enable
            elseif layoutType == "party" then
                layoutSettings.enable = self.db.profile.unitSettings and (
                    (self.db.profile.unitSettings.party1 and self.db.profile.unitSettings.party1.enable) or
                    (self.db.profile.unitSettings.party2 and self.db.profile.unitSettings.party2.enable) or
                    (self.db.profile.unitSettings.party3 and self.db.profile.unitSettings.party3.enable) or
                    (self.db.profile.unitSettings.party4 and self.db.profile.unitSettings.party4.enable)
                )
            elseif layoutType == "arena" then
                layoutSettings.enable = self.db.profile.unitSettings and (
                    (self.db.profile.unitSettings.arena1 and self.db.profile.unitSettings.arena1.enable) or
                    (self.db.profile.unitSettings.arena2 and self.db.profile.unitSettings.arena2.enable) or
                    (self.db.profile.unitSettings.arena3 and self.db.profile.unitSettings.arena3.enable)
                )
            end
        end
    end
    
    -- Update location check to apply changes
    if ns.locationCheck and ns.locationCheck.settingsChanged then
        ns.locationCheck.settingsChanged()
    end
    
    -- Save settings to ensure they're persisted
    if ns.settings.Save then
        ns.settings:Save()
    end
    
    -- Print debug message if in verbose mode
    if VUI and VUI.verbose then
        print("|cff00BBBBVUI TrufiGCD:|r Settings synced from VUI Config")
    end
end

-- Return the module
return M