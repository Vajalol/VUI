-------------------------------------------------------------------------------
-- Title: VUI BuffOverlay Sorting
-- Author: VortexQ8
-- Priority-based sorting system for buff/debuff display
-------------------------------------------------------------------------------

local _, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end
local BuffOverlay = VUI.modules.buffoverlay

if not BuffOverlay then return end

-- Cache tables for performance
BuffOverlay.SpellPriorities = {} -- Cache for spell priorities
BuffOverlay.AuraCache = {
    player = {},
    target = {},
    focus = {},
    pet = {},
    mouseover = {},
}

-- Get the sort priority for an aura
-- Higher values will be shown first
function BuffOverlay:GetSortPriority(unitID, spellID, auraData)
    if not spellID then return 0 end
    
    -- Check cache first
    local cacheKey = unitID .. "_" .. spellID
    if self.SpellPriorities[cacheKey] then
        return self.SpellPriorities[cacheKey]
    end
    
    -- Base priority
    local priority = 0
    
    -- Get category and use it as base priority
    local category = self:GetAuraCategory(unitID, spellID, auraData.isDebuff)
    local categoryInfo = self.Categories[category] or self.Categories.MINOR
    priority = categoryInfo.priority * 100 -- Base on category (0-10,000 range)
    
    -- Whitelist spells get a bonus
    if VUI.db.profile.modules.buffoverlay.whitelist and
       VUI.db.profile.modules.buffoverlay.whitelist[spellID] then
        priority = priority + 5000 -- Big bump for manually whitelisted spells
    end
    
    -- Adjust by remaining duration if available
    if auraData.expirationTime and auraData.expirationTime > 0 then
        local remaining = auraData.expirationTime - GetTime()
        if remaining > 0 then
            -- Shorter duration gets higher priority (up to +1000 for very short durations)
            if remaining < 5 then
                priority = priority + (1000 - (remaining * 200)) -- 0-5 seconds: +1000 to +0
            elseif remaining < 30 then
                priority = priority + 100 -- Small boost for <30 sec buffs
            end
        end
    end
    
    -- Adjust by stack count if available
    if auraData.count and auraData.count > 1 then
        -- Higher stacks are more important (up to +500 for 20+ stacks)
        priority = priority + math.min(auraData.count * 25, 500)
    end
    
    -- Personal buffs/debuffs are more important
    if auraData.unitCaster and UnitIsUnit(auraData.unitCaster, "player") then
        priority = priority + 2000 -- Big boost for player-cast auras
    end
    
    -- Adjust based on aura type
    if auraData.isDebuff then
        -- Debuffs with certain magic schools are more important
        if auraData.debuffType then
            if auraData.debuffType == "Magic" then
                priority = priority + 300
            elseif auraData.debuffType == "Curse" then
                priority = priority + 400
            elseif auraData.debuffType == "Disease" then
                priority = priority + 350
            elseif auraData.debuffType == "Poison" then
                priority = priority + 375
            end
        end
    else
        -- Buff type bonus (base value already includes this distinction)
    end
    
    -- Store in cache for future lookups
    self.SpellPriorities[cacheKey] = priority
    
    return priority
end

-- Get the sort order for display
-- Returns a table of sorted aura IDs with their display data
function BuffOverlay:GetSortedAuras(unitID)
    if not unitID or not UnitExists(unitID) then return {} end
    
    local auras = {}
    
    -- Process buffs and debuffs together
    local function processAuras(auraType)
        local isDebuff = (auraType == "HARMFUL")
        local i = 1
        
        while true do
            local name, icon, count, debuffType, duration, expirationTime, unitCaster, 
                  isStealable, nameplateShowPersonal, auraID, canApplyAura, isBossDebuff, 
                  castByPlayer, nameplateShowAll = UnitAura(unitID, i, auraType)
            
            if not name then break end
            
            -- Skip if it's filtered out
            if self:ShouldShowAura(unitID, auraID, isDebuff) then
                local auraData = {
                    name = name,
                    icon = icon,
                    count = count,
                    debuffType = debuffType,
                    duration = duration,
                    expirationTime = expirationTime,
                    unitCaster = unitCaster,
                    auraID = auraID,
                    isDebuff = isDebuff,
                    isBossDebuff = isBossDebuff,
                    castByPlayer = castByPlayer,
                    index = i,
                    type = auraType,
                }
                
                -- Get priority for sorting
                auraData.priority = self:GetSortPriority(unitID, auraID, auraData)
                
                -- Get category for display
                auraData.category = self:GetAuraCategory(unitID, auraID, isDebuff)
                
                -- Add to list
                table.insert(auras, auraData)
            end
            
            i = i + 1
        end
    end
    
    -- Process both buffs and debuffs
    processAuras("HELPFUL")
    processAuras("HARMFUL")
    
    -- Sort by priority (higher values first)
    table.sort(auras, function(a, b)
        return a.priority > b.priority
    end)
    
    -- Update aura cache for this unit
    self.AuraCache[unitID] = auras
    
    return auras
end

-- Determine if an aura should be shown based on filters
function BuffOverlay:ShouldShowAura(unitID, spellID, isDebuff)
    if not spellID then return false end
    
    -- Check for blacklist
    if VUI.db.profile.modules.buffoverlay.blacklist and
       VUI.db.profile.modules.buffoverlay.blacklist[spellID] then
        return false
    end
    
    -- Always show whitelist
    if VUI.db.profile.modules.buffoverlay.whitelist and
       VUI.db.profile.modules.buffoverlay.whitelist[spellID] then
        return true
    end
    
    -- Always show healer spells if tracking is enabled
    if VUI.db.profile.modules.buffoverlay.trackHealerSpells and 
       self.HealerSpells and 
       self.HealerSpells[spellID] then
        return true
    end
    
    -- Filter based on unit type
    if unitID == "player" then
        -- Player aura filters
        if isDebuff then
            return VUI.db.profile.modules.buffoverlay.showPlayerDebuffs
        else
            return VUI.db.profile.modules.buffoverlay.showPlayerBuffs
        end
    elseif unitID == "target" then
        -- Target aura filters
        if isDebuff then
            return VUI.db.profile.modules.buffoverlay.showTargetDebuffs
        else
            return VUI.db.profile.modules.buffoverlay.showTargetBuffs
        end
    elseif unitID == "focus" then
        -- Focus aura filters
        if isDebuff then
            return VUI.db.profile.modules.buffoverlay.showFocusDebuffs
        else
            return VUI.db.profile.modules.buffoverlay.showFocusBuffs
        end
    elseif unitID == "pet" then
        -- Pet aura filters
        if isDebuff then
            return VUI.db.profile.modules.buffoverlay.showPetDebuffs
        else
            return VUI.db.profile.modules.buffoverlay.showPetBuffs
        end
    end
    
    -- Default behavior based on global settings
    if isDebuff then
        return VUI.db.profile.modules.buffoverlay.showDebuffs
    else
        return VUI.db.profile.modules.buffoverlay.showBuffs
    end
end

-- Check for aura changes between old and new aura lists
-- Returns a table with added and removed auras
function BuffOverlay:CheckAuraChanges(unitID, oldAuras, newAuras)
    local changes = {
        added = {},
        removed = {},
    }
    
    if not oldAuras or not newAuras then
        return changes
    end
    
    -- Create lookup table for old auras
    local oldAuraMap = {}
    for _, aura in ipairs(oldAuras) do
        oldAuraMap[aura.auraID] = aura
    end
    
    -- Create lookup table for new auras
    local newAuraMap = {}
    for _, aura in ipairs(newAuras) do
        newAuraMap[aura.auraID] = aura
        
        -- Check if this aura is new
        if not oldAuraMap[aura.auraID] then
            table.insert(changes.added, aura)
        end
    end
    
    -- Check which auras have been removed
    for _, aura in ipairs(oldAuras) do
        if not newAuraMap[aura.auraID] then
            table.insert(changes.removed, aura)
        end
    end
    
    return changes
end

-- Check for aura refresh (same ID but different expiration or count)
function BuffOverlay:CheckAuraRefresh(oldAura, newAura)
    if not oldAura or not newAura or oldAura.auraID ~= newAura.auraID then
        return false
    end
    
    -- Check if expiration time has changed
    if oldAura.expirationTime ~= newAura.expirationTime then
        return true
    end
    
    -- Check if stack count has changed
    if oldAura.count ~= newAura.count then
        return true
    end
    
    return false
end