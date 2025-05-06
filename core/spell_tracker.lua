local _, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end

-- Spell Tracker Module - Optimized spell detection and tracking system
VUI.SpellTracker = VUI.SpellTracker or {}
local SpellTracker = VUI.SpellTracker

-- Cache frequently used globals
local GetTime = GetTime
local UnitClass = UnitClass
local UnitGUID = UnitGUID
local GetSpellInfo = GetSpellInfo
local bit_band = bit.band
local tinsert = table.insert
local tremove = table.remove
local wipe = wipe
local pairs = pairs
local ipairs = ipairs
local next = next

-- Constants
local MAX_CACHE_SIZE = 1000
local MAX_EVENT_HISTORY = 100
local CACHE_CLEANUP_INTERVAL = 60
local SPELL_CATEGORY = {
    INTERRUPT = "interrupt",
    DISPEL = "dispel",
    IMPORTANT = "important",
    COOLDOWN = "cooldown",
    BUFF = "buff",
    DEBUFF = "debuff",
    CAST = "cast",
    SUMMON = "summon",
    RESOURCE = "resource",
    OTHER = "other"
}

local COMBAT_FLAGS = {
    HOSTILE = 0x00000040,
    FRIENDLY = 0x00000010
}

-- Module state
SpellTracker.initialized = false
SpellTracker.combatActive = false
SpellTracker.spellCache = {}
SpellTracker.guidCache = {}
SpellTracker.eventHistory = {}
SpellTracker.activeEvents = {}
SpellTracker.registeredCallbacks = {}
SpellTracker.throttledEvents = {}
SpellTracker.predictiveSpells = {}
SpellTracker.groupComposition = {}
SpellTracker.framePool = {}
SpellTracker.uniqueSpellCount = 0

-- Statistics
SpellTracker.stats = {
    eventsProcessed = 0,
    eventsThrottled = 0,
    cacheHits = 0,
    cacheMisses = 0,
    framePoolSize = 0,
    framePoolUsed = 0,
    framePoolCreated = 0,
    framePoolRecycled = 0,
    uniqueSpellsTracked = 0,
    callbacksTriggered = 0,
    predictsSuccessful = 0,
    predictsMissed = 0,
    memoryUsage = 0,
    combatEventsPerSecond = 0,
    peakEventsPerSecond = 0,
    lastUpdate = GetTime(),
    lastCleanup = GetTime()
}

-- Settings
SpellTracker.settings = {
    enabled = true,
    eventThrottling = true,
    throttlingThreshold = 20, -- Events per second
    maxHistorySize = 100,
    cacheCleanupInterval = 60,
    useFramePool = true,
    predictiveLoading = true,
    combatOptimization = true,
    logLevel = 1, -- 0: Off, 1: Error, 2: Warning, 3: Info, 4: Debug, 5: Trace
    trackStatistics = false,
    maxCacheSize = 500
}

-- Initialize the event frame
SpellTracker.eventFrame = CreateFrame("Frame")

----------------------------------------------------------
-- Core functionality
----------------------------------------------------------

-- Initialize the module
function SpellTracker:Initialize()
    if self.initialized then return end
    
    -- Load settings
    self:LoadSettings()
    
    -- Register combat log event
    self.eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    
    -- Register group/raid change events
    self.eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    self.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    
    -- Register combat state events
    self.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    self.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    
    -- Set up event handler
    self.eventFrame:SetScript("OnEvent", function(_, event, ...)
        if event == "COMBAT_LOG_EVENT_UNFILTERED" then
            self:ProcessCombatLogEvent(CombatLogGetCurrentEventInfo())
        elseif event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
            self:UpdateGroupComposition()
        elseif event == "PLAYER_REGEN_DISABLED" then
            self.combatActive = true
            self:OnCombatStart()
        elseif event == "PLAYER_REGEN_ENABLED" then
            self.combatActive = false
            self:OnCombatEnd()
        end
    end)
    
    -- Initialize frame pool
    self:InitializeFramePool()
    
    -- Set up timer for cache cleanup
    C_Timer.NewTicker(self.settings.cacheCleanupInterval, function()
        self:CleanupCache()
    end)
    
    -- Set up timer for statistics update
    if self.settings.trackStatistics then
        C_Timer.NewTicker(1, function()
            self:UpdateStatistics()
        end)
    end
    
    -- Update initial group composition
    self:UpdateGroupComposition()
    
    -- Mark as initialized
    self.initialized = true
    
    self:Log(3, "SpellTracker initialized")
end

-- Load settings from saved variables
function SpellTracker:LoadSettings()
    if VUI.db and VUI.db.profile and VUI.db.profile.modules and VUI.db.profile.modules.spelltracker then
        local savedSettings = VUI.db.profile.modules.spelltracker
        
        -- Apply saved settings
        for k, v in pairs(savedSettings) do
            self.settings[k] = v
        end
    else
        -- Initialize settings in DB
        if VUI.db and VUI.db.profile then
            VUI.db.profile.modules = VUI.db.profile.modules or {}
            VUI.db.profile.modules.spelltracker = CopyTable(self.settings)
        end
    end
end

-- Save current settings to saved variables
function SpellTracker:SaveSettings()
    if VUI.db and VUI.db.profile then
        VUI.db.profile.modules = VUI.db.profile.modules or {}
        VUI.db.profile.modules.spelltracker = CopyTable(self.settings)
    end
end

-- Process a combat log event
function SpellTracker:ProcessCombatLogEvent(timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
    if not self.settings.enabled then return end
    
    -- Update statistics
    self.stats.eventsProcessed = self.stats.eventsProcessed + 1
    
    -- Apply event throttling if enabled
    if self.settings.eventThrottling and self:ShouldThrottleEvent(eventType, sourceGUID, destGUID, ...) then
        self.stats.eventsThrottled = self.stats.eventsThrottled + 1
        self:Log(5, "Throttled event: " .. (eventType or "unknown"))
        return
    end
    
    -- Track this event in history
    self:AddToEventHistory(timestamp, eventType, sourceGUID, sourceName, destGUID, destName, ...)
    
    -- Handle different event types
    if eventType:match("SPELL_") then
        local spellID, spellName, spellSchool = ...
        
        -- Cache spell info
        self:CacheSpellInfo(spellID, spellName, spellSchool)
        
        -- Cache unit info
        if sourceGUID and sourceName then
            self:CacheUnitInfo(sourceGUID, sourceName, sourceFlags)
        end
        
        if destGUID and destName then
            self:CacheUnitInfo(destGUID, destName, destFlags)
        end
        
        -- Specific event handling
        if eventType == "SPELL_CAST_START" or eventType == "SPELL_CAST_SUCCESS" then
            self:HandleSpellCast(timestamp, sourceGUID, sourceName, spellID, spellName, eventType)
        elseif eventType == "SPELL_AURA_APPLIED" or eventType == "SPELL_AURA_REFRESH" or eventType == "SPELL_AURA_REMOVED" then
            local auraType = select(4, ...)
            self:HandleAuraEvent(timestamp, sourceGUID, sourceName, destGUID, destName, spellID, spellName, eventType, auraType)
        elseif eventType == "SPELL_INTERRUPT" then
            local extraSpellID, extraSpellName = select(4, ...)
            self:HandleInterruptEvent(timestamp, sourceGUID, sourceName, destGUID, destName, spellID, spellName, extraSpellID, extraSpellName)
        elseif eventType == "SPELL_DISPEL" then
            local extraSpellID, extraSpellName, extraSpellSchool, auraType = select(4, ...)
            self:HandleDispelEvent(timestamp, sourceGUID, sourceName, destGUID, destName, spellID, spellName, extraSpellID, extraSpellName, auraType)
        end
        
        -- Trigger callbacks for this spell event
        self:TriggerCallbacks("SPELL", {
            timestamp = timestamp,
            eventType = eventType,
            sourceGUID = sourceGUID,
            sourceName = sourceName, 
            sourceFlags = sourceFlags,
            destGUID = destGUID,
            destName = destName,
            destFlags = destFlags,
            spellID = spellID,
            spellName = spellName,
            spellSchool = spellSchool
        })
    elseif eventType:match("DAMAGE") then
        -- Handle damage events
        local spellID, spellName, spellSchool
        
        if eventType == "SPELL_DAMAGE" or eventType == "SPELL_PERIODIC_DAMAGE" then
            spellID, spellName, spellSchool = ...
            -- Cache spell info
            self:CacheSpellInfo(spellID, spellName, spellSchool)
        end
        
        -- Cache unit info
        if sourceGUID and sourceName then
            self:CacheUnitInfo(sourceGUID, sourceName, sourceFlags)
        end
        
        if destGUID and destName then
            self:CacheUnitInfo(destGUID, destName, destFlags)
        end
        
        -- Trigger callbacks for damage events
        self:TriggerCallbacks("DAMAGE", {
            timestamp = timestamp,
            eventType = eventType,
            sourceGUID = sourceGUID,
            sourceName = sourceName,
            sourceFlags = sourceFlags,
            destGUID = destGUID,
            destName = destName,
            destFlags = destFlags,
            spellID = spellID,
            spellName = spellName,
            spellSchool = spellSchool
        })
    elseif eventType:match("HEAL") then
        -- Handle healing events
        local spellID, spellName, spellSchool = ...
        
        -- Cache spell info
        self:CacheSpellInfo(spellID, spellName, spellSchool)
        
        -- Cache unit info
        if sourceGUID and sourceName then
            self:CacheUnitInfo(sourceGUID, sourceName, sourceFlags)
        end
        
        if destGUID and destName then
            self:CacheUnitInfo(destGUID, destName, destFlags)
        end
        
        -- Trigger callbacks for healing events
        self:TriggerCallbacks("HEAL", {
            timestamp = timestamp,
            eventType = eventType,
            sourceGUID = sourceGUID,
            sourceName = sourceName,
            sourceFlags = sourceFlags,
            destGUID = destGUID,
            destName = destName,
            destFlags = destFlags,
            spellID = spellID,
            spellName = spellName,
            spellSchool = spellSchool
        })
    elseif eventType == "UNIT_DIED" or eventType == "UNIT_DESTROYED" then
        -- Handle unit death events
        if destGUID and destName then
            self:CacheUnitInfo(destGUID, destName, destFlags)
            
            -- Trigger callbacks for death events
            self:TriggerCallbacks("DEATH", {
                timestamp = timestamp,
                eventType = eventType,
                destGUID = destGUID,
                destName = destName,
                destFlags = destFlags
            })
        end
    end
end

-- Add an event to the event history
function SpellTracker:AddToEventHistory(timestamp, eventType, sourceGUID, sourceName, destGUID, destName, ...)
    -- Limit history size
    if #self.eventHistory >= self.settings.maxHistorySize then
        tremove(self.eventHistory, 1)
    end
    
    -- Add new event to history
    tinsert(self.eventHistory, {
        timestamp = timestamp,
        eventType = eventType,
        sourceGUID = sourceGUID,
        sourceName = sourceName,
        destGUID = destGUID,
        destName = destName,
        args = {...}
    })
end

-- Check if an event should be throttled
function SpellTracker:ShouldThrottleEvent(eventType, sourceGUID, destGUID, ...)
    if not self.settings.eventThrottling then
        return false
    end
    
    -- Don't throttle important events
    if eventType == "SPELL_INTERRUPT" or 
       eventType == "SPELL_DISPEL" or 
       eventType == "SPELL_AURA_APPLIED" or 
       eventType == "SPELL_AURA_REMOVED" or
       eventType == "UNIT_DIED" then
        return false
    end
    
    -- Get spell ID if present
    local spellID
    if eventType:match("SPELL_") then
        spellID = ...
    end
    
    -- Create a unique key for this event
    local key = eventType
    if spellID then
        key = key .. ":" .. spellID
    end
    if sourceGUID then
        key = key .. ":" .. sourceGUID
    end
    if destGUID then
        key = key .. ":" .. destGUID
    end
    
    -- Check if this event is already throttled
    local now = GetTime()
    local lastTime = self.throttledEvents[key]
    
    if lastTime and (now - lastTime < (1 / self.settings.throttlingThreshold)) then
        -- Event is happening too frequently, throttle it
        return true
    end
    
    -- Update last time for this event
    self.throttledEvents[key] = now
    
    return false
end

-- Cache spell information
function SpellTracker:CacheSpellInfo(spellID, spellName, spellSchool)
    if not spellID then return end
    
    -- Check if we already have this spell cached
    if self.spellCache[spellID] then
        self.stats.cacheHits = self.stats.cacheHits + 1
        -- Update timestamp
        self.spellCache[spellID].lastSeen = GetTime()
        return
    end
    
    -- Get additional spell information if not provided
    if not spellName then
        spellName = GetSpellInfo(spellID)
    end
    
    -- Cache miss, add to cache
    self.spellCache[spellID] = {
        id = spellID,
        name = spellName,
        school = spellSchool,
        icon = select(3, GetSpellInfo(spellID)),
        firstSeen = GetTime(),
        lastSeen = GetTime(),
        categories = {},
        seenCount = 1
    }
    
    self.stats.cacheMisses = self.stats.cacheMisses + 1
    self.uniqueSpellCount = self.uniqueSpellCount + 1
    
    -- Categorize the spell if possible
    self:CategorizeSpell(spellID)
    
    self:Log(4, "Cached new spell: " .. (spellName or "Unknown") .. " (" .. spellID .. ")")
    
    -- If cache is too large, schedule a cleanup
    if self.uniqueSpellCount > self.settings.maxCacheSize and GetTime() - self.stats.lastCleanup > 10 then
        self:CleanupCache()
    end
end

-- Cache unit information
function SpellTracker:CacheUnitInfo(guid, name, flags)
    if not guid or not name then return end
    
    -- Check if unit is already cached
    if self.guidCache[guid] then
        -- Update last seen time
        self.guidCache[guid].lastSeen = GetTime()
        return
    end
    
    -- Determine unit type from flags
    local unitType = "unknown"
    local reaction = "neutral"
    
    if flags then
        if bit_band(flags, COMBAT_FLAGS.HOSTILE) > 0 then
            reaction = "hostile"
        elseif bit_band(flags, COMBAT_FLAGS.FRIENDLY) > 0 then
            reaction = "friendly"
        end
        
        -- Extract unit type from GUID if possible
        local unitTypeFromGUID = strsplit("-", guid)
        if unitTypeFromGUID then
            unitType = unitTypeFromGUID
        end
    end
    
    -- Cache the unit
    self.guidCache[guid] = {
        name = name,
        type = unitType,
        reaction = reaction,
        firstSeen = GetTime(),
        lastSeen = GetTime(),
        class = nil,  -- Will be filled if discovered
        spec = nil,   -- Will be filled if discovered
        spellsSeen = {}
    }
    
    -- Try to determine class if it's a player
    if guid:match("Player") then
        -- Try to get class from UnitClass if available
        for i = 1, GetNumGroupMembers() do
            local unit = IsInRaid() and "raid"..i or "party"..i
            if UnitGUID(unit) == guid then
                local class = select(2, UnitClass(unit))
                if class then
                    self.guidCache[guid].class = class
                    break
                end
            end
        end
    end
    
    self:Log(5, "Cached new unit: " .. name .. " (" .. guid .. ")")
end

-- Handle a spell cast event
function SpellTracker:HandleSpellCast(timestamp, sourceGUID, sourceName, spellID, spellName, eventType)
    -- Add to active events
    local key = sourceGUID .. ":" .. spellID
    
    if eventType == "SPELL_CAST_START" then
        self.activeEvents[key] = {
            type = "cast",
            timestamp = timestamp,
            sourceGUID = sourceGUID,
            sourceName = sourceName,
            spellID = spellID,
            spellName = spellName,
            startTime = GetTime()
        }
    elseif eventType == "SPELL_CAST_SUCCESS" then
        -- Add cast to unit's spell history
        if self.guidCache[sourceGUID] then
            self.guidCache[sourceGUID].spellsSeen[spellID] = (self.guidCache[sourceGUID].spellsSeen[spellID] or 0) + 1
            
            -- Try to determine class/spec from spells cast
            if not self.guidCache[sourceGUID].class then
                self:DetermineClassFromSpell(sourceGUID, spellID)
            end
        end
        
        -- Remove from active events if it was a cast start
        if self.activeEvents[key] and self.activeEvents[key].type == "cast" then
            self.activeEvents[key] = nil
        end
    end
end

-- Handle an aura event (buff/debuff applied or removed)
function SpellTracker:HandleAuraEvent(timestamp, sourceGUID, sourceName, destGUID, destName, spellID, spellName, eventType, auraType)
    -- Generate a unique key for this aura
    local key = destGUID .. ":" .. spellID
    
    if eventType == "SPELL_AURA_APPLIED" or eventType == "SPELL_AURA_REFRESH" then
        -- Add to active events
        self.activeEvents[key] = {
            type = "aura",
            auraType = auraType or "BUFF", -- Default to BUFF if not specified
            timestamp = timestamp,
            sourceGUID = sourceGUID,
            sourceName = sourceName,
            destGUID = destGUID,
            destName = destName,
            spellID = spellID,
            spellName = spellName,
            startTime = GetTime()
        }
        
        -- Add cast to unit's spell history
        if self.guidCache[sourceGUID] then
            self.guidCache[sourceGUID].spellsSeen[spellID] = (self.guidCache[sourceGUID].spellsSeen[spellID] or 0) + 1
        end
        
    elseif eventType == "SPELL_AURA_REMOVED" then
        -- Remove from active events
        self.activeEvents[key] = nil
    end
end

-- Handle an interrupt event
function SpellTracker:HandleInterruptEvent(timestamp, sourceGUID, sourceName, destGUID, destName, spellID, spellName, extraSpellID, extraSpellName)
    -- Cache the interrupted spell
    if extraSpellID then
        self:CacheSpellInfo(extraSpellID, extraSpellName)
    end
    
    -- Mark spell as an interrupt if not already categorized
    if self.spellCache[spellID] and not self.spellCache[spellID].categories[SPELL_CATEGORY.INTERRUPT] then
        self.spellCache[spellID].categories[SPELL_CATEGORY.INTERRUPT] = true
    end
    
    -- Add to unit's spell history
    if self.guidCache[sourceGUID] then
        self.guidCache[sourceGUID].spellsSeen[spellID] = (self.guidCache[sourceGUID].spellsSeen[spellID] or 0) + 1
    end
    
    -- Trigger specific interrupt callbacks
    self:TriggerCallbacks("INTERRUPT", {
        timestamp = timestamp,
        sourceGUID = sourceGUID,
        sourceName = sourceName,
        destGUID = destGUID,
        destName = destName,
        spellID = spellID,
        spellName = spellName,
        extraSpellID = extraSpellID,
        extraSpellName = extraSpellName
    })
end

-- Handle a dispel event
function SpellTracker:HandleDispelEvent(timestamp, sourceGUID, sourceName, destGUID, destName, spellID, spellName, extraSpellID, extraSpellName, auraType)
    -- Cache the dispelled spell
    if extraSpellID then
        self:CacheSpellInfo(extraSpellID, extraSpellName)
    end
    
    -- Mark spell as a dispel if not already categorized
    if self.spellCache[spellID] and not self.spellCache[spellID].categories[SPELL_CATEGORY.DISPEL] then
        self.spellCache[spellID].categories[SPELL_CATEGORY.DISPEL] = true
    end
    
    -- Add to unit's spell history
    if self.guidCache[sourceGUID] then
        self.guidCache[sourceGUID].spellsSeen[spellID] = (self.guidCache[sourceGUID].spellsSeen[spellID] or 0) + 1
    end
    
    -- Trigger specific dispel callbacks
    self:TriggerCallbacks("DISPEL", {
        timestamp = timestamp,
        sourceGUID = sourceGUID,
        sourceName = sourceName,
        destGUID = destGUID,
        destName = destName,
        spellID = spellID,
        spellName = spellName,
        extraSpellID = extraSpellID,
        extraSpellName = extraSpellName,
        auraType = auraType
    })
end

-- Try to determine a unit's class based on spells cast
function SpellTracker:DetermineClassFromSpell(guid, spellID)
    if not guid or not spellID or not self.guidCache[guid] then return end
    
    -- Check if we have this spell in class-specific spell lists
    local classSpells = VUI.spellData and VUI.spellData.classSpells or {}
    
    for class, spells in pairs(classSpells) do
        for _, id in ipairs(spells) do
            if id == spellID then
                self.guidCache[guid].class = class
                self:Log(3, "Determined class for " .. self.guidCache[guid].name .. ": " .. class)
                return
            end
        end
    end
end

-- Categorize a spell into one or more categories
function SpellTracker:CategorizeSpell(spellID)
    if not spellID or not self.spellCache[spellID] then return end
    
    -- Try to categorize based on spell lists (if modules provide categorization data)
    local categoryFound = false
    
    -- Check for interrupts
    if VUI.spellData and VUI.spellData.interrupts then
        for _, id in ipairs(VUI.spellData.interrupts) do
            if id == spellID then
                self.spellCache[spellID].categories[SPELL_CATEGORY.INTERRUPT] = true
                categoryFound = true
                break
            end
        end
    end
    
    -- Check for dispels
    if VUI.spellData and VUI.spellData.dispels then
        for _, id in ipairs(VUI.spellData.dispels) do
            if id == spellID then
                self.spellCache[spellID].categories[SPELL_CATEGORY.DISPEL] = true
                categoryFound = true
                break
            end
        end
    end
    
    -- Check for cooldowns
    if VUI.spellData and VUI.spellData.cooldowns then
        for _, id in ipairs(VUI.spellData.cooldowns) do
            if id == spellID then
                self.spellCache[spellID].categories[SPELL_CATEGORY.COOLDOWN] = true
                categoryFound = true
                break
            end
        end
    end
    
    -- Check for important spells
    if VUI.spellData and VUI.spellData.important then
        for _, id in ipairs(VUI.spellData.important) do
            if id == spellID then
                self.spellCache[spellID].categories[SPELL_CATEGORY.IMPORTANT] = true
                categoryFound = true
                break
            end
        end
    end
    
    -- If no category was found, mark as OTHER
    if not categoryFound then
        self.spellCache[spellID].categories[SPELL_CATEGORY.OTHER] = true
    end
end

-- Update information about group composition
function SpellTracker:UpdateGroupComposition()
    -- Clear current composition
    wipe(self.groupComposition)
    
    -- Add player
    local playerGUID = UnitGUID("player")
    local _, playerClass = UnitClass("player")
    
    if playerGUID and playerClass then
        self.groupComposition[playerGUID] = {
            name = UnitName("player"),
            class = playerClass,
            spec = GetSpecialization() and GetSpecializationInfo(GetSpecialization()) or nil
        }
    end
    
    -- Check if in a group
    local numMembers = GetNumGroupMembers()
    if numMembers > 0 then
        -- Determine if in raid or party
        local unit = IsInRaid() and "raid" or "party"
        
        -- Loop through members
        for i = 1, numMembers do
            local unitID = unit .. i
            
            -- Skip if it's the player in a party
            if unit == "party" and i == numMembers then
                break
            end
            
            local guid = UnitGUID(unitID)
            local name = UnitName(unitID)
            local _, class = UnitClass(unitID)
            
            if guid and class then
                -- Try to get specialization for group members
                local spec
                if UnitIsVisible(unitID) then
                    local specID = GetInspectSpecialization(unitID)
                    if specID and specID > 0 then
                        spec = specID
                    end
                end
                
                self.groupComposition[guid] = {
                    name = name,
                    class = class,
                    spec = spec
                }
                
                -- Also update guidCache if we have this unit
                if self.guidCache[guid] then
                    self.guidCache[guid].class = class
                end
            end
        end
    end
    
    -- After updating composition, preload important spells
    if self.settings.predictiveLoading then
        self:PreloadImportantSpells()
    end
    
    self:Log(3, "Updated group composition: " .. self:GetGroupCompositionString())
end

-- Preload important spells based on group composition
function SpellTracker:PreloadImportantSpells()
    if not self.settings.predictiveLoading then return end
    
    -- Important spell lists per class
    local importantSpellsByClass = VUI.spellData and VUI.spellData.importantByClass or {}
    
    -- Clear predictive spells
    wipe(self.predictiveSpells)
    
    -- Add spells based on group composition
    for guid, info in pairs(self.groupComposition) do
        local class = info.class
        
        if class and importantSpellsByClass[class] then
            for _, spellID in ipairs(importantSpellsByClass[class]) do
                -- Preload this spell
                self:CacheSpellInfo(spellID)
                
                -- Mark as predictively loaded
                self.predictiveSpells[spellID] = true
            end
        end
    end
    
    self:Log(3, "Preloaded " .. #self.predictiveSpells .. " important spells based on group composition")
end

-- Get a string representation of the current group composition
function SpellTracker:GetGroupCompositionString()
    local result = ""
    local classCounts = {}
    
    for _, info in pairs(self.groupComposition) do
        classCounts[info.class] = (classCounts[info.class] or 0) + 1
    end
    
    for class, count in pairs(classCounts) do
        result = result .. class .. ":" .. count .. " "
    end
    
    return result
end

-- Register a callback for spell events
function SpellTracker:RegisterCallback(eventType, key, callback)
    if not callback or type(callback) ~= "function" then
        self:Log(1, "Invalid callback registered for " .. eventType)
        return false
    end
    
    -- Initialize callbacks for this event type if needed
    self.registeredCallbacks[eventType] = self.registeredCallbacks[eventType] or {}
    
    -- Add callback
    self.registeredCallbacks[eventType][key] = callback
    
    self:Log(4, "Registered callback for " .. eventType .. " with key " .. key)
    
    return true
end

-- Unregister a callback
function SpellTracker:UnregisterCallback(eventType, key)
    if not self.registeredCallbacks[eventType] then
        return false
    end
    
    -- Remove callback
    if self.registeredCallbacks[eventType][key] then
        self.registeredCallbacks[eventType][key] = nil
        self:Log(4, "Unregistered callback for " .. eventType .. " with key " .. key)
        return true
    end
    
    return false
end

-- Trigger callbacks for an event
function SpellTracker:TriggerCallbacks(eventType, eventData)
    if not self.registeredCallbacks[eventType] then
        return
    end
    
    -- Call all registered callbacks for this event type
    for key, callback in pairs(self.registeredCallbacks[eventType]) do
        -- Add handler key to event data
        eventData.handlerKey = key
        
        -- Call the callback
        local success, err = pcall(callback, eventData)
        
        if not success then
            self:Log(1, "Error in callback for " .. eventType .. " (" .. key .. "): " .. (err or "unknown error"))
        else
            self.stats.callbacksTriggered = self.stats.callbacksTriggered + 1
        end
    end
end

-- Get cached spell info
function SpellTracker:GetSpellInfo(spellID)
    if not spellID then return nil end
    
    -- Check cache first
    if self.spellCache[spellID] then
        self.stats.cacheHits = self.stats.cacheHits + 1
        -- Update last seen time
        self.spellCache[spellID].lastSeen = GetTime()
        return self.spellCache[spellID]
    end
    
    -- Cache miss, try to load spell info
    local spellName, _, spellIcon = GetSpellInfo(spellID)
    
    if spellName then
        -- Add to cache
        self.spellCache[spellID] = {
            id = spellID,
            name = spellName,
            icon = spellIcon,
            firstSeen = GetTime(),
            lastSeen = GetTime(),
            categories = {},
            seenCount = 0
        }
        
        self.stats.cacheMisses = self.stats.cacheMisses + 1
        self.uniqueSpellCount = self.uniqueSpellCount + 1
        
        -- Categorize the spell if possible
        self:CategorizeSpell(spellID)
        
        return self.spellCache[spellID]
    end
    
    -- Spell not found
    self.stats.cacheMisses = self.stats.cacheMisses + 1
    return nil
end

-- Cleanup old entries in caches
function SpellTracker:CleanupCache()
    local now = GetTime()
    self.stats.lastCleanup = now
    
    -- Count spells and units before cleanup
    local spellCountBefore = self.uniqueSpellCount
    local unitCountBefore = 0
    for _ in pairs(self.guidCache) do
        unitCountBefore = unitCountBefore + 1
    end
    
    -- Cleanup spell cache - remove oldest entries first
    if self.uniqueSpellCount > self.settings.maxCacheSize * 0.8 then
        -- Sort spells by lastSeen
        local spellList = {}
        for id, info in pairs(self.spellCache) do
            tinsert(spellList, {id = id, lastSeen = info.lastSeen})
        end
        
        -- Sort by lastSeen (oldest first)
        table.sort(spellList, function(a, b) return a.lastSeen < b.lastSeen end)
        
        -- Remove oldest spells until we're below the threshold
        local toRemove = math.max(0, #spellList - self.settings.maxCacheSize * 0.6)
        for i = 1, toRemove do
            local id = spellList[i].id
            -- Don't remove important/predictive spells
            if not self.spellCache[id].categories[SPELL_CATEGORY.IMPORTANT] and not self.predictiveSpells[id] then
                self.spellCache[id] = nil
                self.uniqueSpellCount = self.uniqueSpellCount - 1
            end
        end
    end
    
    -- Cleanup GUID cache - remove entries older than 10 minutes
    local unitRemoved = 0
    for guid, info in pairs(self.guidCache) do
        if now - info.lastSeen > 600 then -- 10 minutes
            self.guidCache[guid] = nil
            unitRemoved = unitRemoved + 1
        end
    end
    
    -- Cleanup throttled events - remove entries older than 5 seconds
    for key, time in pairs(self.throttledEvents) do
        if now - time > 5 then
            self.throttledEvents[key] = nil
        end
    end
    
    -- Cleanup active events - remove entries older than 5 minutes
    for key, event in pairs(self.activeEvents) do
        if now - event.startTime > 300 then -- 5 minutes
            self.activeEvents[key] = nil
        end
    end
    
    self:Log(3, string.format("Cache cleanup: Spells %d -> %d, Units %d -> %d, Removed %d units", 
        spellCountBefore, self.uniqueSpellCount, unitCountBefore, unitCountBefore - unitRemoved, unitRemoved))
end

-- Handle combat start
function SpellTracker:OnCombatStart()
    if not self.settings.combatOptimization then return end
    
    -- Save current settings
    self.preCombaSettings = {
        eventThrottling = self.settings.eventThrottling,
        throttlingThreshold = self.settings.throttlingThreshold
    }
    
    -- Increase throttling during combat for better performance
    self.settings.eventThrottling = true
    self.settings.throttlingThreshold = self.settings.throttlingThreshold * 0.7 -- More aggressive throttling
    
    self:Log(3, "Combat started - optimizing settings")
end

-- Handle combat end
function SpellTracker:OnCombatEnd()
    if not self.settings.combatOptimization or not self.preCombaSettings then return end
    
    -- Restore pre-combat settings
    self.settings.eventThrottling = self.preCombaSettings.eventThrottling
    self.settings.throttlingThreshold = self.preCombaSettings.throttlingThreshold
    
    -- Clear saved settings
    self.preCombaSettings = nil
    
    -- Perform cache cleanup after combat
    self:CleanupCache()
    
    self:Log(3, "Combat ended - restoring settings")
end

-- Update statistics
function SpellTracker:UpdateStatistics()
    if not self.settings.trackStatistics then return end
    
    local now = GetTime()
    local elapsed = now - self.stats.lastUpdate
    
    if elapsed < 0.1 then
        return
    end
    
    -- Calculate events per second
    self.stats.combatEventsPerSecond = self.stats.eventsProcessed / elapsed
    
    -- Track peak events per second
    if self.stats.combatEventsPerSecond > self.stats.peakEventsPerSecond then
        self.stats.peakEventsPerSecond = self.stats.combatEventsPerSecond
    end
    
    -- Reset counters
    self.stats.eventsProcessed = 0
    self.stats.lastUpdate = now
    
    -- Update memory usage estimate
    local memoryUsage = 0
    
    -- Estimate spell cache memory
    memoryUsage = memoryUsage + (self.uniqueSpellCount * 50) -- ~50 bytes per spell entry
    
    -- Estimate GUID cache memory
    local guidCount = 0
    for _ in pairs(self.guidCache) do
        guidCount = guidCount + 1
    end
    memoryUsage = memoryUsage + (guidCount * 100) -- ~100 bytes per GUID entry
    
    -- Estimate event history memory
    memoryUsage = memoryUsage + (#self.eventHistory * 50) -- ~50 bytes per history entry
    
    -- Estimate active events memory
    local activeCount = 0
    for _ in pairs(self.activeEvents) do
        activeCount = activeCount + 1
    end
    memoryUsage = memoryUsage + (activeCount * 50) -- ~50 bytes per active event
    
    -- Estimate frame pool memory
    memoryUsage = memoryUsage + (self.stats.framePoolSize * 500) -- ~500 bytes per frame
    
    -- Update memory usage stat
    self.stats.memoryUsage = memoryUsage
    
    -- Update unique spells tracked
    self.stats.uniqueSpellsTracked = self.uniqueSpellCount
end

----------------------------------------------------------
-- Frame pool functionality
----------------------------------------------------------

-- Initialize the frame pool
function SpellTracker:InitializeFramePool()
    if not self.settings.useFramePool then return end
    
    -- Initialize frame pool
    self.framePool = {
        available = {},
        used = {},
        size = 0
    }
    
    self.stats.framePoolSize = 0
    self.stats.framePoolUsed = 0
    
    self:Log(3, "Frame pool initialized")
end

-- Create a new frame
function SpellTracker:CreateFrame(frameType, parent, template)
    -- Use frame pool if enabled
    if self.settings.useFramePool then
        return self:GetFrameFromPool(frameType, parent, template)
    else
        -- Create frame directly
        local frame = CreateFrame(frameType, nil, parent, template)
        return frame
    end
end

-- Get a frame from the pool
function SpellTracker:GetFrameFromPool(frameType, parent, template)
    frameType = frameType or "Frame"
    
    -- Check if we have an available frame of this type
    local key = frameType .. ":" .. (template or "")
    
    if self.framePool.available[key] and #self.framePool.available[key] > 0 then
        -- Use an existing frame
        local frame = tremove(self.framePool.available[key])
        
        -- Reset the frame
        frame:ClearAllPoints()
        frame:SetParent(parent or UIParent)
        frame:Show()
        
        -- Add to used frames
        self.framePool.used[frame] = key
        
        -- Update stats
        self.stats.framePoolUsed = self.stats.framePoolUsed + 1
        self.stats.framePoolRecycled = self.stats.framePoolRecycled + 1
        
        return frame
    end
    
    -- No existing frame, create a new one
    local frame = CreateFrame(frameType, nil, parent, template)
    
    -- Add to used frames
    self.framePool.used[frame] = key
    
    -- Update stats
    self.framePool.size = self.framePool.size + 1
    self.stats.framePoolSize = self.framePool.size
    self.stats.framePoolUsed = self.stats.framePoolUsed + 1
    self.stats.framePoolCreated = self.stats.framePoolCreated + 1
    
    return frame
end

-- Release a frame back to the pool
function SpellTracker:ReleaseFrame(frame)
    if not self.settings.useFramePool or not frame then return end
    
    -- Check if this frame is in the used list
    local key = self.framePool.used[frame]
    if not key then return end
    
    -- Hide the frame
    frame:ClearAllPoints()
    frame:Hide()
    
    -- Initialize the available list for this type if needed
    self.framePool.available[key] = self.framePool.available[key] or {}
    
    -- Add to available frames
    tinsert(self.framePool.available[key], frame)
    
    -- Remove from used frames
    self.framePool.used[frame] = nil
    
    -- Update stats
    self.stats.framePoolUsed = self.stats.framePoolUsed - 1
end

----------------------------------------------------------
-- Utility functions
----------------------------------------------------------

-- Get statistics
function SpellTracker:GetStats()
    return self.stats
end

-- Get status of the module
function SpellTracker:GetStatus()
    return {
        enabled = self.settings.enabled,
        initialized = self.initialized,
        combatActive = self.combatActive,
        spellsCached = self.uniqueSpellCount,
        guidsCached = self:GetGUIDCount(),
        activeEvents = self:GetActiveEventCount(),
        callbacksRegistered = self:GetCallbackCount(),
        eventsPerSecond = self.stats.combatEventsPerSecond,
        peakEventsPerSecond = self.stats.peakEventsPerSecond,
        memoryUsage = self.stats.memoryUsage,
        cacheHitRate = self:GetCacheHitRate()
    }
end

-- Get the number of GUIDs in the cache
function SpellTracker:GetGUIDCount()
    local count = 0
    for _ in pairs(self.guidCache) do
        count = count + 1
    end
    return count
end

-- Get the number of active events
function SpellTracker:GetActiveEventCount()
    local count = 0
    for _ in pairs(self.activeEvents) do
        count = count + 1
    end
    return count
end

-- Get the number of registered callbacks
function SpellTracker:GetCallbackCount()
    local count = 0
    for _, callbacks in pairs(self.registeredCallbacks) do
        for _ in pairs(callbacks) do
            count = count + 1
        end
    end
    return count
end

-- Get the cache hit rate
function SpellTracker:GetCacheHitRate()
    local total = self.stats.cacheHits + self.stats.cacheMisses
    if total == 0 then
        return 0
    end
    return (self.stats.cacheHits / total) * 100
end

-- Log a message
function SpellTracker:Log(level, message)
    if not self.settings.logLevel or self.settings.logLevel < level then
        return
    end
    
    local prefix = "|cff1784d1VUI SpellTracker|r: "
    
    if level == 1 then
        prefix = "|cffff0000VUI SpellTracker ERROR|r: "
    elseif level == 2 then
        prefix = "|cffffcc00VUI SpellTracker WARNING|r: "
    elseif level == 4 then
        prefix = "|cff888888VUI SpellTracker DEBUG|r: "
    elseif level == 5 then
        prefix = "|cff888888VUI SpellTracker TRACE|r: "
    end
    
    -- Skip debug and trace logs in production release
    if level >= 4 then return end
    
    if VUI.Logger then
        local logLevel = "INFO"
        if level == 1 then logLevel = "ERROR"
        elseif level == 2 then logLevel = "WARN"
        end
        
        VUI.Logger:Log("SpellTracker", logLevel, message)
    else
        VUI:Print(prefix .. message)
    end
end

-- Reset the module
function SpellTracker:Reset()
    -- Clear caches
    wipe(self.spellCache)
    wipe(self.guidCache)
    wipe(self.eventHistory)
    wipe(self.activeEvents)
    wipe(self.throttledEvents)
    wipe(self.predictiveSpells)
    
    -- Reset statistics
    wipe(self.stats)
    self.stats = {
        eventsProcessed = 0,
        eventsThrottled = 0,
        cacheHits = 0,
        cacheMisses = 0,
        framePoolSize = self.framePool and self.framePool.size or 0,
        framePoolUsed = self.framePool and self.stats.framePoolUsed or 0,
        framePoolCreated = self.framePool and self.stats.framePoolCreated or 0,
        framePoolRecycled = self.framePool and self.stats.framePoolRecycled or 0,
        uniqueSpellsTracked = 0,
        callbacksTriggered = 0,
        predictsSuccessful = 0,
        predictsMissed = 0,
        memoryUsage = 0,
        combatEventsPerSecond = 0,
        peakEventsPerSecond = 0,
        lastUpdate = GetTime(),
        lastCleanup = GetTime()
    }
    
    self.uniqueSpellCount = 0
    
    -- Reset frame pool
    if self.framePool then
        -- Hide all frames in the pool
        for _, frames in pairs(self.framePool.available) do
            for _, frame in ipairs(frames) do
                frame:ClearAllPoints()
                frame:Hide()
            end
        end
        
        for frame, _ in pairs(self.framePool.used) do
            frame:ClearAllPoints()
            frame:Hide()
        end
        
        -- Reset the pool
        self.framePool = {
            available = {},
            used = {},
            size = 0
        }
        
        self.stats.framePoolSize = 0
        self.stats.framePoolUsed = 0
    end
    
    -- Update group composition
    self:UpdateGroupComposition()
    
    self:Log(2, "SpellTracker reset")
end

-- Get configuration options for settings panel
function SpellTracker:GetConfig()
    local options = {
        type = "group",
        name = "Spell Tracker",
        desc = "Configure the spell detection and tracking system",
        get = function(info)
            return self.settings[info[#info]]
        end,
        set = function(info, value)
            self.settings[info[#info]] = value
            
            -- Save settings
            if VUI.db and VUI.db.profile then
                VUI.db.profile.modules = VUI.db.profile.modules or {}
                VUI.db.profile.modules.spelltracker = VUI.db.profile.modules.spelltracker or {}
                VUI.db.profile.modules.spelltracker[info[#info]] = value
            end
        end,
        args = {
            header = {
                type = "header",
                name = "Spell Detection and Tracking",
                order = 1
            },
            description = {
                type = "description",
                name = "Configure the spell detection and tracking system used by various VUI modules.",
                fontSize = "medium",
                order = 2
            },
            enabled = {
                type = "toggle",
                name = "Enable Spell Tracker",
                desc = "Enable or disable the spell tracker module",
                width = "full",
                order = 3
            },
            general = {
                type = "group",
                name = "General Settings",
                inline = true,
                order = 4,
                args = {
                    eventThrottling = {
                        type = "toggle",
                        name = "Event Throttling",
                        desc = "Enable throttling of frequent events to improve performance",
                        width = "full",
                        order = 1
                    },
                    throttlingThreshold = {
                        type = "range",
                        name = "Throttling Threshold",
                        desc = "Maximum events per second before throttling kicks in",
                        min = 5,
                        max = 100,
                        step = 1,
                        disabled = function() return not self.settings.eventThrottling end,
                        width = "full",
                        order = 2
                    },
                    maxCacheSize = {
                        type = "range",
                        name = "Maximum Cache Size",
                        desc = "Maximum number of spells to cache",
                        min = 100,
                        max = 2000,
                        step = 100,
                        width = "full",
                        order = 3
                    },
                    maxHistorySize = {
                        type = "range",
                        name = "History Size",
                        desc = "Maximum number of events to keep in history",
                        min = 10,
                        max = 500,
                        step = 10,
                        width = "full",
                        order = 4
                    }
                }
            },
            optimization = {
                type = "group",
                name = "Optimization Settings",
                inline = true,
                order = 5,
                args = {
                    useFramePool = {
                        type = "toggle",
                        name = "Use Frame Pool",
                        desc = "Recycle frames to reduce memory usage",
                        width = "full",
                        order = 1
                    },
                    predictiveLoading = {
                        type = "toggle",
                        name = "Predictive Loading",
                        desc = "Preload important spells based on group composition",
                        width = "full",
                        order = 2
                    },
                    combatOptimization = {
                        type = "toggle",
                        name = "Combat Optimization",
                        desc = "Apply additional optimizations during combat",
                        width = "full",
                        order = 3
                    }
                }
            },
            debug = {
                type = "group",
                name = "Debug Settings",
                inline = true,
                order = 6,
                args = {
                    trackStatistics = {
                        type = "toggle",
                        name = "Track Statistics",
                        desc = "Track performance statistics",
                        width = "full",
                        order = 1
                    },
                    logLevel = {
                        type = "select",
                        name = "Log Level",
                        desc = "Set the log level for the spell tracker",
                        values = {
                            [0] = "Off",
                            [1] = "Error",
                            [2] = "Warning",
                            [3] = "Info",
                            [4] = "Debug",
                            [5] = "Trace"
                        },
                        width = "full",
                        order = 2
                    },
                    resetButton = {
                        type = "execute",
                        name = "Reset Tracker",
                        desc = "Clear all caches and reset statistics",
                        func = function() self:Reset() end,
                        width = "full",
                        order = 3
                    }
                }
            },
            stats = {
                type = "group",
                name = "Statistics",
                inline = true,
                order = 7,
                args = {
                    statsHeader = {
                        type = "description",
                        name = function()
                            local status = self:GetStatus()
                            local hitRate = self:GetCacheHitRate()
                            
                            local text = "Spells Cached: " .. status.spellsCached .. "\n"
                            text = text .. "Units Cached: " .. status.guidsCached .. "\n"
                            text = text .. "Active Events: " .. status.activeEvents .. "\n"
                            text = text .. "Callbacks: " .. status.callbacksRegistered .. "\n"
                            text = text .. "Events/Second: " .. string.format("%.1f", status.eventsPerSecond) .. "\n"
                            text = text .. "Peak Events/Second: " .. string.format("%.1f", status.peakEventsPerSecond) .. "\n"
                            text = text .. "Cache Hit Rate: " .. string.format("%.1f%%", hitRate) .. "\n"
                            text = text .. "Memory Usage: " .. string.format("%.2f KB", status.memoryUsage / 1024)
                            
                            return text
                        end,
                        fontSize = "medium",
                        order = 1
                    }
                }
            }
        }
    }
    
    return options
end

-- Initialize the module when the addon is loaded
if VUI.initialized then
    SpellTracker:Initialize()
else
    VUI:RegisterCallback("OnInitialized", function()
        SpellTracker:Initialize()
    end)
end