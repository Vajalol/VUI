--[[
    VUI - Example Module: Spell Detection Optimization Implementation
    Author: VortexQ8
    
    This example demonstrates best practices for implementing the 
    Spell Detection Logic Enhancement in VUI modules.
]]

local _, VUI = ...
local ExampleModule = VUI:GetModule("Example") or VUI:NewModule("Example")

-- Reference to the optimization systems
local SpellDetectionOptimization = VUI.SpellDetectionOptimization

-- Example spell tracking table
local TrackedSpells = {
    -- High priority offensive cooldowns
    [190319] = { type = "offensive", name = "Combustion", class = "MAGE", priority = 3 },      -- Mage Fire
    [12472] = { type = "offensive", name = "Icy Veins", class = "MAGE", priority = 3 },        -- Mage Frost
    [1719] = { type = "offensive", name = "Recklessness", class = "WARRIOR", priority = 3 },    -- Warrior
    [51271] = { type = "offensive", name = "Pillar of Frost", class = "DEATHKNIGHT", priority = 3 }, -- DK Frost
    [275699] = { type = "offensive", name = "Apocalypse", class = "DEATHKNIGHT", priority = 3 },     -- DK Unholy
    
    -- High priority defensive cooldowns
    [31850] = { type = "defensive", name = "Ardent Defender", class = "PALADIN", priority = 3 },     -- Paladin Prot
    [115203] = { type = "defensive", name = "Fortifying Brew", class = "MONK", priority = 3 },       -- Monk Brew
    [22812] = { type = "defensive", name = "Barkskin", class = "DRUID", priority = 3 },             -- Druid
    [104773] = { type = "defensive", name = "Unending Resolve", class = "WARLOCK", priority = 3 },   -- Warlock
    
    -- Medium priority utility abilities
    [29166] = { type = "utility", name = "Innervate", class = "DRUID", priority = 2 },           -- Druid
    [64901] = { type = "utility", name = "Symbol of Hope", class = "PRIEST", priority = 2 },     -- Priest Holy
    [114018] = { type = "utility", name = "Shroud of Concealment", class = "ROGUE", priority = 2 }, -- Rogue
}

-- Optimization metrics
local Metrics = {
    spellsTracked = 0,
    eventsProcessed = 0,
    notificationsShown = 0,
    cachedLookups = 0,
    cacheHits = 0
}

-- Initialize the module with optimization
function ExampleModule:InitializeWithOptimization()
    -- Register important spells with the optimization system
    self:RegisterImportantSpells()
    
    -- Register for combat log events
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "OnCombatLogEventOptimized")
    
    -- Report metrics periodically if in debug mode
    C_Timer.After(60, function() self:ReportOptimizationMetrics() end)
    
    -- Cache most used spells proactively
    self:PreloadCommonSpells()
    
    VUI:Print("Example module initialized with spell detection optimization")
end

-- Register our important spells with the optimization system
function ExampleModule:RegisterImportantSpells()
    -- Check if optimization system is available
    if not SpellDetectionOptimization then return end
    
    -- Add our tracked spells to the optimization system
    for spellID, data in pairs(TrackedSpells) do
        -- This tells the optimization system these are important spells
        -- and they should be prioritized in the cache
        if SpellDetectionOptimization.AddPrioritySpell then
            SpellDetectionOptimization:AddPrioritySpell(spellID, data.priority or 1)
        end
    end
end

-- Preload commonly used spells for this module
function ExampleModule:PreloadCommonSpells()
    -- Check if optimization system is available
    if not SpellDetectionOptimization then return end
    
    -- Find high priority spells to preload
    for spellID, data in pairs(TrackedSpells) do
        if data.priority and data.priority >= 3 then
            -- Preload these high priority spells
            SpellDetectionOptimization:GetSpellInfo(spellID)
        end
    end
end

-- Optimized combat log event handler
function ExampleModule:OnCombatLogEventOptimized(...)
    -- Track performance
    Metrics.eventsProcessed = Metrics.eventsProcessed + 1
    
    -- Extract the combat log parameters
    local timestamp, event, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, 
          destGUID, destName, destFlags, destRaidFlags, spellID, spellName = CombatLogGetCurrentEventInfo()
    
    -- Only process events we care about
    if event ~= "SPELL_CAST_SUCCESS" and event ~= "SPELL_AURA_APPLIED" then
        return
    end
    
    -- Check if we're tracking this spell
    if not TrackedSpells[spellID] then 
        return
    end
    
    Metrics.spellsTracked = Metrics.spellsTracked + 1
    
    -- Now we need spell info, use the optimization system when available
    local name, _, icon
    
    if SpellDetectionOptimization then
        -- Use the optimized spell info lookup
        local spellInfo = SpellDetectionOptimization:GetSpellInfo(spellID)
        if spellInfo then
            name = spellInfo.name
            icon = spellInfo.icon
            Metrics.cachedLookups = Metrics.cachedLookups + 1
            
            -- Check if this was a cache hit
            if spellInfo.fromCache then
                Metrics.cacheHits = Metrics.cacheHits + 1
            end
        else
            -- Fallback to API if needed
            name, _, icon = GetSpellInfo(spellID)
        end
    else
        -- Standard API call if optimization isn't available
        name, _, icon = GetSpellInfo(spellID)
    end
    
    if not name then return end
    
    -- Determine source player info
    local isPlayer = bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0
    
    -- Only track player casts
    if not isPlayer then return end
    
    -- Optimization: use cached player name formatting when available
    local playerName
    local multiNotification = VUI:GetModule("MultiNotification")
    
    if multiNotification and multiNotification.GetCachedPlayerName then
        -- Use the enhanced name caching for better performance
        playerName = multiNotification:GetCachedPlayerName(sourceName, sourceFlags, sourceRaidFlags)
    elseif multiNotification then
        -- Fall back to standard formatting
        playerName = multiNotification:FormatPlayerName(sourceName, sourceFlags, sourceRaidFlags)
    else
        -- Simple fallback
        playerName = sourceName
    end
    
    -- Create notification message
    local spellType = TrackedSpells[spellID].type or "ability"
    local text
    
    if destName and destName ~= sourceName and destGUID ~= sourceGUID then
        text = playerName .. " used " .. name .. " on " .. destName
    else
        text = playerName .. " used " .. name
    end
    
    -- Use MultiNotification if available (with optimization benefits)
    if multiNotification then
        multiNotification:ShowSpellNotification(
            name,       -- Title
            text,       -- Message
            icon,       -- Icon  
            spellType,  -- Category
            nil         -- Let the system determine sound
        )
    else
        -- Fallback direct notification
        VUI:Print(text)
    end
    
    Metrics.notificationsShown = Metrics.notificationsShown + 1
end

-- Report optimization metrics
function ExampleModule:ReportOptimizationMetrics()
    -- Check if debug mode is enabled
    local debugMode = false
    
    if SpellDetectionOptimization and SpellDetectionOptimization.Config then
        debugMode = SpellDetectionOptimization.Config.debugMode
    end
    
    if debugMode then
        VUI:Print("|cFF88FF88== Example Module Spell Metrics ==|r")
        VUI:Print(string.format("Events Processed: %d", Metrics.eventsProcessed))
        VUI:Print(string.format("Spells Tracked: %d", Metrics.spellsTracked))
        VUI:Print(string.format("Notifications Shown: %d", Metrics.notificationsShown))
        
        if Metrics.cachedLookups > 0 then
            local hitRatio = Metrics.cacheHits / Metrics.cachedLookups * 100
            VUI:Print(string.format("Cache Usage: %d lookups, %.1f%% hit ratio", 
                Metrics.cachedLookups, hitRatio))
        end
    end
    
    -- Reset metrics
    Metrics.eventsProcessed = 0
    Metrics.spellsTracked = 0
    Metrics.notificationsShown = 0
    Metrics.cachedLookups = 0
    Metrics.cacheHits = 0
    
    -- Schedule next report
    C_Timer.After(60, function() self:ReportOptimizationMetrics() end)
end

-- Apply optimization when module loads
function ExampleModule:OnEnable()
    self:InitializeWithOptimization()
end

-- Register this file with the module
VUI:RegisterModuleScript("Example", "spell_detection_optimized")