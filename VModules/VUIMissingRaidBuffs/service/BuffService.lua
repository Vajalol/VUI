-- VUIMissingRaidBuffs BuffService
-- Provides centralized buff scanning and tracking functionality
-- Based on Missing Raid Buffs WeakAura (https://wago.io/BQce7Fj5J)

local AddonName, VUI = ...
local M = VUI:GetModule("VUIMissingRaidBuffs")
local BuffService = {}
M.BuffService = BuffService

-- Cached functions for performance
local UnitBuff = UnitBuff
local UnitDebuff = UnitDebuff
local UnitClass = UnitClass
local UnitName = UnitName
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local pairs = pairs
local wipe = wipe

-- Internal state
local missingBuffs = {}
local buffProviders = {}
local groupComposition = {}

-- Initialize the buff service
function BuffService:Initialize()
    self:ScanGroupComposition()
    self:ScanMissingBuffs()
    M:Debug("BuffService initialized")
end

-- Scan the current group composition for buff providers
function BuffService:ScanGroupComposition()
    wipe(groupComposition)
    wipe(buffProviders)
    
    -- Always add player
    local _, playerClass = UnitClass("player")
    if playerClass then
        groupComposition[playerClass] = (groupComposition[playerClass] or 0) + 1
    end
    
    -- Scan party/raid members
    if IsInGroup() then
        local unit = IsInRaid() and "raid" or "party"
        local maxMembers = IsInRaid() and 40 or 4
        
        for i = 1, maxMembers do
            local unitID = unit..i
            if UnitExists(unitID) then
                local _, class = UnitClass(unitID)
                if class then
                    groupComposition[class] = (groupComposition[class] or 0) + 1
                end
            end
        end
    end
    
    -- Identify available buff providers
    for buffKey, buffData in pairs(M.raidBuffs) do
        buffProviders[buffKey] = false
        for classID, _ in pairs(buffData.providedBy or {}) do
            if groupComposition[classID] and groupComposition[classID] > 0 then
                buffProviders[buffKey] = true
                break
            end
        end
    end
    
    return groupComposition, buffProviders
end

-- Helper function to check for buff by spell ID
function BuffService:HasBuff(unit, spellID)
    local i = 1
    while true do
        local name, _, _, _, _, _, _, _, _, id = UnitBuff(unit, i)
        if not name then break end
        if id == spellID then return true end
        i = i + 1
    end
    return false
end

-- Helper function to check for debuff by spell ID
function BuffService:HasDebuff(unit, spellID)
    local i = 1
    while true do
        local name, _, _, _, _, _, _, _, _, id = UnitDebuff(unit, i)
        if not name then break end
        if id == spellID then return true end
        i = i + 1
    end
    return false
end

-- Check for missing buffs
function BuffService:ScanMissingBuffs()
    wipe(missingBuffs)
    
    -- Skip if player is dead
    if UnitIsDeadOrGhost("player") then
        return missingBuffs
    end
    
    -- Check each raid buff
    for buffKey, buffData in pairs(M.raidBuffs) do
        -- Skip under certain conditions but continue with the loop
        local skipThisBuff = false
        
        -- Skip if not tracking this buff
        if not M.db.profile[buffData.track] then
            skipThisBuff = true
        end
        
        -- Skip temporary buffs (like Bloodlust) for normal checks
        if not skipThisBuff and buffData.temporary then
            skipThisBuff = true
        end
        
        -- Skip if no provider available in group
        if not skipThisBuff and not buffProviders[buffKey] and M.db.profile.displayInGroupOnly then
            skipThisBuff = true
        end
        
        -- Process the buff if not skipped
        if not skipThisBuff then
            local hasThisBuff = false
            
            -- Use the specific check function if provided
            if buffData.checkFunction then
                hasThisBuff = buffData.checkFunction()
            else
                -- Check for any of the spell IDs
                for spellID, _ in pairs(buffData.spellIDs or {}) do
                    if self:HasBuff("player", spellID) then
                        hasThisBuff = true
                        break
                    end
                end
            end
            
            -- Add to missing buffs if not found
            if not hasThisBuff then
                missingBuffs[buffKey] = buffData
            end
        end
    end
    
    return missingBuffs
end

-- Get the current missing buffs
function BuffService:GetMissingBuffs()
    return missingBuffs
end

-- Get the buff providers information
function BuffService:GetBuffProviders()
    return buffProviders
end

-- Get the group composition
function BuffService:GetGroupComposition()
    return groupComposition
end

-- Return the service
return BuffService