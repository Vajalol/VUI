-- VUITGCD UnitSettings.lua
-- Manages unit-specific settings

local _, ns = ...
local VUITGCD = _G.VUI and _G.VUI.TGCD or {}

-- Define namespace if not created yet
if not ns.unitSettings then ns.unitSettings = {} end

-- Create a class-like structure for UnitSettings
---@class UnitSettings
ns.unitSettings.__index = ns.unitSettings

-- Constructor for UnitSettings
---@param unitId string
---@return UnitSettings
function ns.unitSettings:New(unitId)
    local self = setmetatable({}, ns.unitSettings)
    
    self.unitId = unitId
    self.layoutSettings = ns.layoutSettings:New(unitId)
    self.filterSettings = {}  -- Additional unit-specific filtering options
    
    return self
end

-- Load settings from profile
---@param profileSettings table
function ns.unitSettings:Load(profileSettings)
    if not profileSettings then return end
    
    -- Load layout settings
    if profileSettings.layoutSettings and profileSettings.layoutSettings[self.unitId] then
        self.layoutSettings:Load(profileSettings.layoutSettings[self.unitId])
    end
    
    -- Load filter settings if they exist
    if profileSettings.filterSettings and profileSettings.filterSettings[self.unitId] then
        self.filterSettings = {}
        
        for k, v in pairs(profileSettings.filterSettings[self.unitId]) do
            self.filterSettings[k] = v
        end
    end
end

-- Save settings to profile
---@param profileSettings table
function ns.unitSettings:Save(profileSettings)
    if not profileSettings then return end
    
    -- Ensure structures exist
    if not profileSettings.layoutSettings then
        profileSettings.layoutSettings = {}
    end
    
    if not profileSettings.filterSettings then
        profileSettings.filterSettings = {}
    end
    
    -- Save layout settings
    profileSettings.layoutSettings[self.unitId] = self.layoutSettings:Save()
    
    -- Save filter settings
    profileSettings.filterSettings[self.unitId] = {}
    for k, v in pairs(self.filterSettings) do
        profileSettings.filterSettings[self.unitId][k] = v
    end
end

-- Reset settings to defaults
function ns.unitSettings:Reset()
    self.layoutSettings:Reset(self.unitId)
    
    -- Reset filter settings to defaults
    self.filterSettings = {
        showFriendlySpells = true,
        showEnemySpells = true,
        minDuration = 0,
        maxDuration = 0,  -- 0 means no maximum
        minCooldown = 0,
        maxCooldown = 0   -- 0 means no maximum
    }
end

-- Set a filter setting
---@param key string
---@param value any
function ns.unitSettings:SetFilterSetting(key, value)
    self.filterSettings[key] = value
end

-- Get a filter setting
---@param key string
---@return any
function ns.unitSettings:GetFilterSetting(key)
    return self.filterSettings[key]
end

-- Determine if a spell should be filtered
---@param spellId number
---@param isFriendly boolean
---@param duration number
---@param cooldown number
---@return boolean
function ns.unitSettings:ShouldFilterSpell(spellId, isFriendly, duration, cooldown)
    -- Skip if spell is in blocklist
    if ns.innerBlocklist and ns.innerBlocklist:IsBlocked(spellId) then
        return true
    end
    
    -- Check friendly/enemy filter
    if isFriendly and not self.filterSettings.showFriendlySpells then
        return true
    end
    
    if not isFriendly and not self.filterSettings.showEnemySpells then
        return true
    end
    
    -- Check duration
    if duration and self.filterSettings.minDuration > 0 and duration < self.filterSettings.minDuration then
        return true
    end
    
    if duration and self.filterSettings.maxDuration > 0 and duration > self.filterSettings.maxDuration then
        return true
    end
    
    -- Check cooldown
    if cooldown and self.filterSettings.minCooldown > 0 and cooldown < self.filterSettings.minCooldown then
        return true
    end
    
    if cooldown and self.filterSettings.maxCooldown > 0 and cooldown > self.filterSettings.maxCooldown then
        return true
    end
    
    -- Spell passes all filters
    return false
end

-- Export to global if needed
if _G.VUI then
    _G.VUI.TGCD.UnitSettings = ns.unitSettings
end