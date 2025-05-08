local AddOnName, NS = ...
local VUICD, L, db = NS:unpack()

-- API functions for external addons
VUICD.API = {}

-- Get cooldown information for a spell
function VUICD.API:GetSpellCooldown(spellID, unit)
    if not spellID or not unit then return false, 0, 0 end
    
    -- If the unit is in our party and we're tracking their cooldowns
    if VUICD.Party and VUICD.Party.CD then
        local guid = UnitGUID(unit)
        if guid then
            -- Check from our tracked cooldowns
            return VUICD.Party.CD:IsOnCooldown(guid, spellID)
        end
    end
    
    -- Fallback to standard API
    local start, duration, enable = GetSpellCooldown(spellID)
    if start and duration then
        return (start > 0 and duration > 0), start, duration
    end
    
    return false, 0, 0
end

-- Get all tracked cooldowns for a unit
function VUICD.API:GetUnitCooldowns(unit)
    if not unit then return {} end
    
    local result = {}
    
    if VUICD.Party and VUICD.Party.CD then
        local guid = UnitGUID(unit)
        if guid then
            local spells = VUICD.Party.CD:GetActiveSpells(guid)
            
            for spellID, spellInfo in pairs(spells) do
                result[spellID] = {
                    id = spellID,
                    name = spellInfo.name,
                    icon = spellInfo.icon,
                    onCooldown = spellInfo.onCooldown,
                    start = spellInfo.start,
                    duration = spellInfo.duration,
                    remaining = spellInfo.remaining
                }
            end
        end
    end
    
    return result
end

-- Check if a unit has a specific spell
function VUICD.API:UnitHasSpell(unit, spellID)
    if not unit or not spellID then return false end
    
    -- Check directly if the unit is the player
    if UnitIsUnit(unit, "player") then
        return IsSpellKnown(spellID)
    end
    
    -- Otherwise, check our database
    if VUICD.Party and VUICD.Party.CD then
        local guid = UnitGUID(unit)
        if guid then
            local spells = VUICD.Party.CD:GetActiveSpells(guid)
            return spells[spellID] ~= nil
        end
    end
    
    return false
end

-- Get all cooldowns of a specific type for a unit
function VUICD.API:GetUnitCooldownsByType(unit, cooldownType)
    if not unit or not cooldownType then return {} end
    
    local result = {}
    
    if VUICD.Party and VUICD.Party.CD then
        local guid = UnitGUID(unit)
        if guid then
            local spells = VUICD.Party.CD:GetActiveSpells(guid)
            
            for spellID, spellInfo in pairs(spells) do
                if spellInfo[cooldownType] then
                    result[spellID] = {
                        id = spellID,
                        name = spellInfo.name,
                        icon = spellInfo.icon,
                        onCooldown = spellInfo.onCooldown,
                        start = spellInfo.start,
                        duration = spellInfo.duration,
                        remaining = spellInfo.remaining
                    }
                end
            end
        end
    end
    
    return result
end

-- Register a callback for cooldown events
function VUICD.API:RegisterCallback(event, callback)
    if not event or not callback then return end
    
    if not VUICD.callbacks then
        VUICD.callbacks = {}
    end
    
    if not VUICD.callbacks[event] then
        VUICD.callbacks[event] = {}
    end
    
    table.insert(VUICD.callbacks[event], callback)
end

-- Unregister a callback
function VUICD.API:UnregisterCallback(event, callback)
    if not event or not callback or not VUICD.callbacks or not VUICD.callbacks[event] then return end
    
    for i = #VUICD.callbacks[event], 1, -1 do
        if VUICD.callbacks[event][i] == callback then
            table.remove(VUICD.callbacks[event], i)
            break
        end
    end
end

-- Trigger a callback event
function VUICD.API:TriggerEvent(event, ...)
    if not event or not VUICD.callbacks or not VUICD.callbacks[event] then return end
    
    for _, callback in ipairs(VUICD.callbacks[event]) do
        callback(...)
    end
end

-- Get module version
function VUICD.API:GetVersion()
    return VUICD.Version
end

-- Create global accessor
_G["VUICD_API"] = VUICD.API