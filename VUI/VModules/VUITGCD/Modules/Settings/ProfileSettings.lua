-- VUITGCD ProfileSettings.lua
-- Manages profile settings structure

local _, ns = ...
local VUITGCD = _G.VUI and _G.VUI.TGCD or {}

-- Define namespace if not created yet
if not ns.profileSettings then ns.profileSettings = {} end

-- Create a class-like structure for ProfileSettings
---@class ProfileSettings
ns.profileSettings.__index = ns.profileSettings

-- Constructor for ProfileSettings
---@param name string
---@return ProfileSettings
function ns.profileSettings:New(name)
    local self = setmetatable({}, ns.profileSettings)
    
    self.name = name or "Default"
    self.enableInWorld = true
    self.enableInDungeons = true
    self.enableInRaids = true
    self.enableInPvP = true
    self.disableOutOfCombat = false
    self.disableInCities = true
    self.showGlow = true
    self.glowEffect = "blizz"
    self.showTooltips = true
    self.showSpellNames = false
    
    -- Unit settings
    self.layoutSettings = {}
    self.filterSettings = {}
    
    -- Blocked spells
    self.innerBlocklist = {}
    
    -- Initialize default settings for each unit type
    self:InitializeDefaultUnitSettings()
    
    -- Initialize default blocklist
    self:InitializeDefaultBlocklist()
    
    return self
end

-- Initialize default unit settings
function ns.profileSettings:InitializeDefaultUnitSettings()
    -- Create layout settings for each tracked unit
    for _, unitType in ipairs(ns.constants.unitTypes) do
        self.layoutSettings[unitType] = {
            enable = (unitType == "player"), -- Only player enabled by default
            iconSize = ns.constants.defaultIconSize,
            maxIcons = 8,
            layout = "horizontal",
            point = "CENTER",
            relativePoint = "CENTER",
            xOffset = 0,
            yOffset = 0,
            showLabel = true,
            useClassColor = true
        }
        
        -- Initialize filter settings
        self.filterSettings[unitType] = {
            showFriendlySpells = true,
            showEnemySpells = true,
            minDuration = 0,
            maxDuration = 0,  -- 0 means no maximum
            minCooldown = 0,
            maxCooldown = 0   -- 0 means no maximum
        }
    end
end

-- Initialize default blocklist
function ns.profileSettings:InitializeDefaultBlocklist()
    for spellId, blocked in pairs(ns.constants.defaultBlocklist) do
        self.innerBlocklist[spellId] = blocked
    end
end

-- Load settings from saved data
---@param data table
function ns.profileSettings:Load(data)
    if not data then return end
    
    -- Load basic settings
    self.name = data.name or self.name
    self.enableInWorld = data.enableInWorld
    self.enableInDungeons = data.enableInDungeons
    self.enableInRaids = data.enableInRaids
    self.enableInPvP = data.enableInPvP
    self.disableOutOfCombat = data.disableOutOfCombat
    self.disableInCities = data.disableInCities
    self.showGlow = data.showGlow
    self.glowEffect = data.glowEffect
    self.showTooltips = data.showTooltips
    self.showSpellNames = data.showSpellNames
    
    -- Load unit settings
    if data.layoutSettings then
        for unitType, settings in pairs(data.layoutSettings) do
            -- Make sure we only load for valid unit types
            if self.layoutSettings[unitType] then
                for k, v in pairs(settings) do
                    self.layoutSettings[unitType][k] = v
                end
            end
        end
    end
    
    -- Load filter settings
    if data.filterSettings then
        for unitType, settings in pairs(data.filterSettings) do
            -- Make sure we only load for valid unit types
            if self.filterSettings[unitType] then
                for k, v in pairs(settings) do
                    self.filterSettings[unitType][k] = v
                end
            end
        end
    end
    
    -- Load blocklist
    if data.innerBlocklist then
        for spellId, blocked in pairs(data.innerBlocklist) do
            self.innerBlocklist[spellId] = blocked
        end
    end
end

-- Save settings to a table
---@return table
function ns.profileSettings:Save()
    local data = {
        name = self.name,
        enableInWorld = self.enableInWorld,
        enableInDungeons = self.enableInDungeons,
        enableInRaids = self.enableInRaids,
        enableInPvP = self.enableInPvP,
        disableOutOfCombat = self.disableOutOfCombat,
        disableInCities = self.disableInCities,
        showGlow = self.showGlow,
        glowEffect = self.glowEffect,
        showTooltips = self.showTooltips,
        showSpellNames = self.showSpellNames,
        
        -- Deep copy layout settings
        layoutSettings = {},
        filterSettings = {},
        innerBlocklist = {}
    }
    
    -- Copy layout settings
    for unitType, settings in pairs(self.layoutSettings) do
        data.layoutSettings[unitType] = {}
        for k, v in pairs(settings) do
            data.layoutSettings[unitType][k] = v
        end
    end
    
    -- Copy filter settings
    for unitType, settings in pairs(self.filterSettings) do
        data.filterSettings[unitType] = {}
        for k, v in pairs(settings) do
            data.filterSettings[unitType][k] = v
        end
    end
    
    -- Copy blocklist
    for spellId, blocked in pairs(self.innerBlocklist) do
        data.innerBlocklist[spellId] = blocked
    end
    
    return data
end

-- Reset profile to defaults
function ns.profileSettings:Reset()
    self.enableInWorld = true
    self.enableInDungeons = true
    self.enableInRaids = true
    self.enableInPvP = true
    self.disableOutOfCombat = false
    self.disableInCities = true
    self.showGlow = true
    self.glowEffect = "blizz"
    self.showTooltips = true
    self.showSpellNames = false
    
    -- Reset unit settings
    self:InitializeDefaultUnitSettings()
    
    -- Reset blocklist
    self.innerBlocklist = {}
    self:InitializeDefaultBlocklist()
end

-- Export to global if needed
if _G.VUI then
    _G.VUI.TGCD.ProfileSettings = ns.profileSettings
end