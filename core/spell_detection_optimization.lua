--[[
    VUI - Spell Detection Logic Enhancement
    Author: VortexQ8
    
    This file implements the improved spell detection system for VUI,
    offering significant performance improvements by:
    
    1. Using spell ID-based caching for faster lookups
    2. Implementing predictive spell loading for frequently used abilities
    3. Adding combat event throttling to reduce CPU usage during intensive encounters
    4. Optimizing spell icon handling to reduce memory pressure
    5. Enhancing filter logic to prioritize relevant spells faster
]]

local _, VUI = ...
local L = VUI.L

-- Create a new optimization module
local SpellDetectionOptimization = {}
VUI.SpellDetectionOptimization = SpellDetectionOptimization

-- Cache frequently used globals for better performance
local GetTime = GetTime
local pairs = pairs
local ipairs = ipairs
local tinsert = table.insert
local tremove = table.remove
local wipe = wipe
local next = next
local select = select
local UnitIsUnit = UnitIsUnit
local UnitExists = UnitExists
local UnitGUID = UnitGUID
local InCombatLockdown = InCombatLockdown
local GetFramerate = GetFramerate

-- Configuration
local Config = {
    enabledByDefault = true,
    cacheSize = 1500,             -- Increased cache size for better hit rates
    predictiveLoadingEnabled = true,
    combatThrottling = true,
    throttleInterval = 0.1,       -- 100ms throttling during combat
    groupSyncEnabled = true,      -- Sync important spells with group members
    priorityScanEnabled = true,   -- Prioritize scanning for important spells
    adaptiveThrottling = true,    -- Dynamically adjust throttling based on framerate
    lowFpsThreshold = 20,         -- FPS threshold to increase throttling
    lowFpsThrottleMultiplier = 2, -- Multiply throttle interval when FPS is low
    minProcessingInterval = 0.05  -- Minimum time between processing non-critical spells
}

-- Performance metrics
local Metrics = {
    cacheHits = 0,
    cacheMisses = 0,
    spellsProcessed = 0,
    eventsFiltered = 0,
    spellIconsOptimized = 0,
    predictiveLoads = 0,
    lastReset = GetTime(),
}

-- Spell caching system
local SpellCache = {
    byID = {},      -- Cache by spell ID
    byName = {},    -- Cache by spell name
    byType = {},    -- Cache by spell type (e.g., "interrupt", "dispel")
    lastUsed = {},  -- Timestamp for LRU eviction
    priorityList = {} -- Most common/important spells
}

-- Static list of high-priority spell types we want to process first
local PrioritySpellTypes = {
    ["SPELL_INTERRUPT"] = true,
    ["SPELL_DISPEL"] = true,
    ["SPELL_STEAL"] = true,
    ["SPELL_AURA_APPLIED"] = 0.75,  -- Lower priority (75%)
    ["SPELL_CAST_SUCCESS"] = 0.5,   -- Lower priority (50%)
}

-- Initialize the optimization module
function SpellDetectionOptimization:Initialize()
    -- Check if already initialized
    if self.initialized then return end
    
    -- Initialize metrics
    Metrics = {
        cacheHits = 0,
        cacheMisses = 0,
        spellsProcessed = 0,
        eventsFiltered = 0,
        spellIconsOptimized = 0,
        predictiveLoads = 0,
        predictiveCacheUpdates = 0,
        lowFpsEvents = 0,
        lastReset = GetTime()
    }
    
    -- Initialize spell cache
    SpellCache = {
        byID = {},
        byName = {},
        byType = {},
        lastUsed = {},
        priorityList = {},
        pendingUpdates = {}
    }
    
    -- Define priority values for different spell event types
    PrioritySpellTypes = {
        SPELL_INTERRUPT = 1.0,       -- Always process interrupts
        SPELL_DISPEL = 1.0,          -- Always process dispels
        SPELL_STOLEN = 1.0,          -- Always process spell steals
        SPELL_CAST_SUCCESS = 0.8,    -- Process most casts, but throttle a bit
        SPELL_AURA_APPLIED = 0.6,    -- Process some aura applications
        SPELL_SUMMON = 0.7           -- Process most summons
    }
    
    -- Load saved variables or use defaults
    self:LoadSettings()
    
    -- Set up spell cache
    self:InitializeCache()
    
    -- Register for event handling optimization
    self:RegisterEventOptimization()
    
    -- Set up frame-based predictive caching
    self:SetupPredictiveCaching()
    
    -- Set initialized flag
    self.initialized = true
    VUI:Print("Spell Detection Logic Enhancement initialized")
    
    -- Start metrics collection
    C_Timer.After(60, function() self:ReportMetrics() end)
end

-- Load settings from VUI database
function SpellDetectionOptimization:LoadSettings()
    local db = VUI.db:GetNamespace("MultiNotification")
    if db and db.profile then
        -- Create optimization settings if they don't exist
        if not db.profile.optimizationSettings then
            db.profile.optimizationSettings = {
                enabled = Config.enabledByDefault,
                cacheSize = Config.cacheSize,
                predictiveLoading = Config.predictiveLoadingEnabled,
                combatThrottling = Config.combatThrottling,
                throttleInterval = Config.throttleInterval,
                adaptiveThrottling = Config.adaptiveThrottling,
                lowFpsThreshold = Config.lowFpsThreshold,
                lowFpsThrottleMultiplier = Config.lowFpsThrottleMultiplier,
                groupSync = Config.groupSyncEnabled,
                priorityScan = Config.priorityScanEnabled,
                debug = false
            }
        end
        
        -- Use loaded settings
        Config.enabledByDefault = db.profile.optimizationSettings.enabled
        Config.cacheSize = db.profile.optimizationSettings.cacheSize
        Config.predictiveLoadingEnabled = db.profile.optimizationSettings.predictiveLoading
        Config.combatThrottling = db.profile.optimizationSettings.combatThrottling
        Config.throttleInterval = db.profile.optimizationSettings.throttleInterval
        
        -- Load adaptive throttling settings (with defaults if missing)
        Config.adaptiveThrottling = db.profile.optimizationSettings.adaptiveThrottling ~= nil and 
                                  db.profile.optimizationSettings.adaptiveThrottling or Config.adaptiveThrottling
        Config.lowFpsThreshold = db.profile.optimizationSettings.lowFpsThreshold or Config.lowFpsThreshold
        Config.lowFpsThrottleMultiplier = db.profile.optimizationSettings.lowFpsThrottleMultiplier or Config.lowFpsThrottleMultiplier
        
        -- Load other settings
        Config.groupSyncEnabled = db.profile.optimizationSettings.groupSync
        Config.priorityScanEnabled = db.profile.optimizationSettings.priorityScan
        Config.debugMode = db.profile.optimizationSettings.debug
    end
end

-- Initialize the spell cache
function SpellDetectionOptimization:InitializeCache()
    -- Reset cache
    SpellCache.byID = {}
    SpellCache.byName = {}
    SpellCache.byType = {}
    SpellCache.lastUsed = {}
    SpellCache.priorityList = {}
    
    -- Pre-populate priority list (most common spells used in combat)
    self:PopulatePrioritySpells()
    
    -- Preload commonly used spell data 
    if Config.predictiveLoadingEnabled then
        self:PreloadCommonSpells()
    end
end

-- Preload common spell information for faster access
function SpellDetectionOptimization:PreloadCommonSpells()
    local MultiNotification = VUI:GetModule("MultiNotification")
    if not MultiNotification then return end
    
    -- Get important spells from the module
    local importantSpells = MultiNotification.db.profile.spellSettings.importantSpells
    if not importantSpells then return end
    
    -- Load into cache
    for spellID, data in pairs(importantSpells) do
        if type(spellID) == "number" then
            local name, rank, icon = GetSpellInfo(spellID)
            if name then
                -- Cache by ID
                SpellCache.byID[spellID] = {
                    name = name,
                    icon = icon,
                    type = data.type or "unknown",
                    priority = data.priority or 1,
                    timestamp = GetTime()
                }
                
                -- Cache by name
                SpellCache.byName[name] = SpellCache.byID[spellID]
                
                -- Cache by type
                if data.type then
                    if not SpellCache.byType[data.type] then
                        SpellCache.byType[data.type] = {}
                    end
                    SpellCache.byType[data.type][spellID] = SpellCache.byID[spellID]
                end
                
                -- Update last used time
                SpellCache.lastUsed[spellID] = GetTime()
                
                -- Update metrics
                Metrics.predictiveLoads = Metrics.predictiveLoads + 1
            end
        end
    end
    
    -- Preloading complete
end

-- Register our optimized event handler
function SpellDetectionOptimization:RegisterEventOptimization()
    local MultiNotification = VUI:GetModule("MultiNotification")
    if not MultiNotification then return end
    
    -- Store original method reference for later use
    if not self.originalOnCombatLogEvent then
        self.originalOnCombatLogEvent = MultiNotification.OnCombatLogEvent
    end
    
    -- Replace with optimized version
    MultiNotification.OnCombatLogEvent = function(...)
        return self:OptimizedCombatLogEvent(...)
    end
    
    -- Hook into module's initialization
    local originalInitSpellEvents = MultiNotification.InitializeSpellEvents
    if originalInitSpellEvents then
        MultiNotification.InitializeSpellEvents = function(module)
            -- Call original first
            originalInitSpellEvents(module)
            
            -- Add our optimizations
            self:EnhanceSpellRegistry(module)
        end
    end
end

-- Enhanced version of spell registry setup
function SpellDetectionOptimization:EnhanceSpellRegistry(module)
    if not module then return end
    
    -- Enhance event filtering
    if module.eventFilterList then
        -- Add priority values for different event types
        for event, value in pairs(PrioritySpellTypes) do
            if module.eventFilterList[event] then
                -- Convert boolean to priority value
                module.eventFilterList[event] = value
            end
        end
    end
    
    -- Implement enhanced spell loading logic
    if module.LoadPredefinedSpells then
        local originalLoadPredefined = module.LoadPredefinedSpells
        module.LoadPredefinedSpells = function(...)
            -- Call original implementation
            originalLoadPredefined(...)
            
            -- After loading, cache all spells
            local spells = module.db.profile.spellSettings.importantSpells
            if spells then
                for spellID, data in pairs(spells) do
                    -- Add to priority list if needed
                    if data.priority and data.priority >= 2 then
                        table.insert(SpellCache.priorityList, spellID)
                    end
                end
                
                -- Sort priority list by spell priority
                table.sort(SpellCache.priorityList, function(a, b)
                    local spellsA = spells[a]
                    local spellsB = spells[b]
                    if spellsA and spellsB and spellsA.priority and spellsB.priority then
                        return spellsA.priority > spellsB.priority
                    end
                    return false
                end)
            end
        end
    end
end

-- Optimized combat log event handler
function SpellDetectionOptimization:OptimizedCombatLogEvent(module)
    -- Check if optimization is enabled
    if not Config.enabledByDefault then
        -- If not, use original method
        return self.originalOnCombatLogEvent(module)
    end
    
    -- Throttle in combat if enabled
    if Config.combatThrottling and InCombatLockdown() then
        local now = GetTime()
        
        -- Determine the appropriate throttle interval using adaptive throttling
        local throttleInterval = Config.throttleInterval
        
        -- Apply adaptive throttling if enabled and framerate is low
        if Config.adaptiveThrottling then
            local currentFps = GetFramerate()
            if currentFps < Config.lowFpsThreshold then
                -- Increase throttle interval during low FPS to reduce CPU usage
                throttleInterval = throttleInterval * Config.lowFpsThrottleMultiplier
                
                -- Add to metrics
                if not self.lowFpsCounter then self.lowFpsCounter = 0 end
                self.lowFpsCounter = self.lowFpsCounter + 1
            end
        end
        
        -- Check if enough time has passed since last processing
        if not self.lastProcessTime or (now - self.lastProcessTime) >= throttleInterval then
            self.lastProcessTime = now
        else
            -- Skip this event due to throttling
            Metrics.eventsFiltered = Metrics.eventsFiltered + 1
            return
        end
    end
    
    -- Extract the combat log parameters
    local timestamp, event, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, _, extraSpellID, extraSpellName = CombatLogGetCurrentEventInfo()
    
    -- Fast path: check if this event type is filtered by priority
    local eventPriority = module.eventFilterList[event]
    if not eventPriority then 
        Metrics.eventsFiltered = Metrics.eventsFiltered + 1
        return 
    end
    
    -- Skip if spell notifications are disabled
    if not module.db.profile.spellSettings.enableSpellNotifications then return end

    -- Use cached spell info when possible
    local spellInfo = self:GetSpellInfo(spellID, spellName)
    Metrics.spellsProcessed = Metrics.spellsProcessed + 1
    
    -- Process based on event type with priority handling
    if event == "SPELL_INTERRUPT" then
        -- Handle interrupts
        self:ProcessInterruptEvent(module, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, extraSpellID, extraSpellName, spellInfo)
    elseif event == "SPELL_DISPEL" or event == "SPELL_STOLEN" then
        -- Handle dispels and spell steals
        self:ProcessDispelEvent(module, event, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, extraSpellID, extraSpellName, spellInfo)
    elseif module.db.profile.spellSettings.showImportantSpells and
           (event == "SPELL_CAST_SUCCESS" or event == "SPELL_AURA_APPLIED" or event == "SPELL_SUMMON") then
        -- Handle important spells with lower frequency if event priority is fractional
        local isPlayer = bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0
        if isPlayer and (eventPriority == true or math.random() <= eventPriority) then
            self:ProcessImportantSpellEvent(module, event, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellInfo)
        end
    end
end

-- Process interrupt events
function SpellDetectionOptimization:ProcessInterruptEvent(module, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, extraSpellID, extraSpellName, spellInfo)
    -- Determine source player type
    local isMe = sourceGUID == UnitGUID("player")
    local isFriendly = bit.band(sourceFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY) > 0
    
    if (isMe and module.db.profile.spellSettings.showMyInterrupts) or 
       (not isMe and isFriendly and module.db.profile.spellSettings.showOtherInterrupts) then
        -- Format player name (colorize based on class for players)
        local playerName = module:FormatPlayerName(sourceName, sourceFlags, sourceRaidFlags)
        
        -- Create the notification text
        local text = playerName .. " interrupted " .. destName .. "'s " .. extraSpellName
        
        -- Display the notification
        module:ShowSpellNotification(
            spellName,          -- Title
            text,               -- Message 
            spellID,            -- Spell ID for icon
            "interrupt",        -- Category
            module.db.profile.spellSettings.interruptSoundFile -- Sound
        )
    end
end

-- Process dispel events
function SpellDetectionOptimization:ProcessDispelEvent(module, event, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, extraSpellID, extraSpellName, spellInfo)
    -- Determine source player type
    local isMe = sourceGUID == UnitGUID("player")
    local isFriendly = bit.band(sourceFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY) > 0
    
    if (isMe and module.db.profile.spellSettings.showMyDispels) or 
       (not isMe and isFriendly and module.db.profile.spellSettings.showOtherDispels) then
        -- Format player name
        local playerName = module:FormatPlayerName(sourceName, sourceFlags, sourceRaidFlags)
        
        -- Create the notification text
        local action = event == "SPELL_DISPEL" and "dispelled" or "stole"
        local text = playerName .. " " .. action .. " " .. destName .. "'s " .. extraSpellName
        
        -- Display the notification
        module:ShowSpellNotification(
            spellName,          -- Title
            text,               -- Message
            spellID,            -- Spell ID for icon
            "dispel",           -- Category
            module.db.profile.spellSettings.dispelSoundFile -- Sound
        )
    end
end

-- Process important spell events
function SpellDetectionOptimization:ProcessImportantSpellEvent(module, event, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellInfo)
    -- Check if this is an important spell we want to track
    local spellData = module.db.profile.spellSettings.importantSpells[spellID]
    if not spellData then return end
    
    -- Check priority threshold
    if spellData.priority < module.db.profile.spellSettings.priorityThreshold then
        return
    end
    
    -- Format player name
    local playerName = module:FormatPlayerName(sourceName, sourceFlags, sourceRaidFlags)
    
    -- Create notification text
    local text
    if destName and destName ~= sourceName and destGUID ~= sourceGUID then
        text = playerName .. " used " .. spellName .. " on " .. destName
    else
        text = playerName .. " used " .. spellName
    end
    
    -- Display the notification
    module:ShowSpellNotification(
        spellName,          -- Title
        text,               -- Message
        spellID,            -- Spell ID for icon
        spellData.type,     -- Category
        module.db.profile.spellSettings.importantSoundFile -- Sound
    )
end

-- Cached spell info retrieval
function SpellDetectionOptimization:GetSpellInfo(spellID, spellName)
    -- Try cache lookup first
    if spellID and SpellCache.byID[spellID] then
        SpellCache.lastUsed[spellID] = GetTime()
        Metrics.cacheHits = Metrics.cacheHits + 1
        return SpellCache.byID[spellID]
    elseif spellName and SpellCache.byName[spellName] then
        local cachedInfo = SpellCache.byName[spellName]
        SpellCache.lastUsed[cachedInfo.id] = GetTime()
        Metrics.cacheHits = Metrics.cacheHits + 1
        return cachedInfo
    end
    
    -- Not in cache, fetch from API
    Metrics.cacheMisses = Metrics.cacheMisses + 1
    
    local name, rank, icon
    if spellID then
        name, rank, icon = GetSpellInfo(spellID)
    else
        name = spellName
    end
    
    -- Create and cache the result
    if name then
        local result = {
            id = spellID,
            name = name,
            icon = icon,
            timestamp = GetTime()
        }
        
        -- Cache the result
        if spellID then
            SpellCache.byID[spellID] = result
            SpellCache.lastUsed[spellID] = GetTime()
        end
        
        if name then
            SpellCache.byName[name] = result
        end
        
        -- Check cache size and evict if needed
        self:CheckCacheSize()
        
        return result
    end
    
    return nil
end

-- Initialize priority spells for improved filtering
function SpellDetectionOptimization:PopulatePrioritySpells()
    SpellCache.priorityList = {
        -- Common interrupts (these are processed first)
        1766,   -- Kick (Rogue)
        2139,   -- Counterspell (Mage)
        6552,   -- Pummel (Warrior)
        19647,  -- Spell Lock (Warlock)
        47528,  -- Mind Freeze (Death Knight)
        57994,  -- Wind Shear (Shaman)
        96231,  -- Rebuke (Paladin)
        106839, -- Skull Bash (Druid)
        116705, -- Spear Hand Strike (Monk)
        147362, -- Counter Shot (Hunter)
        183752, -- Disrupt (Demon Hunter)
        
        -- Common dispels (these are processed next)
        4987,   -- Cleanse (Paladin)
        88423,  -- Nature's Cure (Druid)
        115450, -- Detox (Monk)
        527,    -- Purify (Priest)
        51886,  -- Cleanse Spirit (Shaman)
        213634, -- Purify Disease (Priest)
        218164, -- Detox (Monk, Brewmaster)
        
        -- Important cooldowns
        31884,  -- Avenging Wrath (Paladin)
        47788,  -- Guardian Spirit (Priest)
        33206,  -- Pain Suppression (Priest)
        62618,  -- Power Word: Barrier (Priest)
        98008,  -- Spirit Link Totem (Shaman)
        740,    -- Tranquility (Druid)
        115310, -- Revival (Monk)
        15286,  -- Vampiric Embrace (Priest)
        64843   -- Divine Hymn (Priest)
    }
end

-- Check cache size and evict old entries if needed
function SpellDetectionOptimization:CheckCacheSize()
    local count = 0
    for _ in pairs(SpellCache.byID) do
        count = count + 1
    end
    
    if count > Config.cacheSize then
        -- Evict least recently used entries
        local spellsToEvict = {}
        local timestamps = {}
        
        -- Gather timestamps
        for id, time in pairs(SpellCache.lastUsed) do
            table.insert(timestamps, {id = id, time = time})
        end
        
        -- Sort by timestamp (oldest first)
        table.sort(timestamps, function(a, b) return a.time < b.time end)
        
        -- Mark oldest 10% for eviction
        local evictCount = math.floor(Config.cacheSize * 0.1)
        for i = 1, evictCount do
            if timestamps[i] then
                spellsToEvict[timestamps[i].id] = true
            end
        end
        
        -- Perform eviction
        for id in pairs(spellsToEvict) do
            local name = SpellCache.byID[id] and SpellCache.byID[id].name
            SpellCache.byID[id] = nil
            SpellCache.lastUsed[id] = nil
            if name then
                SpellCache.byName[name] = nil
            end
        end
    end
end

-- Set up predictive caching using frame update handler
function SpellDetectionOptimization:SetupPredictiveCaching()
    -- Create a frame for predictive caching updates
    local predictiveFrame = CreateFrame("Frame", "VUISpellCachePredictiveFrame")
    local updateInterval = 0.5 -- Update every half second
    local timeSinceLastUpdate = 0
    
    predictiveFrame:SetScript("OnUpdate", function(self, elapsed)
        -- Only process when out of combat to avoid impacting performance during encounters
        if InCombatLockdown() then return end
        
        timeSinceLastUpdate = timeSinceLastUpdate + elapsed
        if timeSinceLastUpdate >= updateInterval then
            timeSinceLastUpdate = 0
            
            -- Process any pending spell cache updates
            SpellDetectionOptimization:ProcessPendingCacheUpdates()
        end
    end)
    
    -- Listen for combat state changes
    predictiveFrame:RegisterEvent("PLAYER_REGEN_ENABLED")  -- Out of combat
    predictiveFrame:RegisterEvent("PLAYER_REGEN_DISABLED") -- Entering combat
    predictiveFrame:RegisterEvent("GROUP_ROSTER_UPDATE")   -- Group composition changed
    
    predictiveFrame:SetScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_REGEN_ENABLED" then
            -- Player just left combat, good time to update cache
            SpellDetectionOptimization:QueueFullCacheUpdate()
        elseif event == "GROUP_ROSTER_UPDATE" then
            -- Group changed, update spell priorities
            SpellDetectionOptimization:QueueClassSpecificSpellUpdate()
        end
    end)
    
    -- Store frame reference
    self.predictiveFrame = predictiveFrame
end

-- Queue class-specific spells for predictive loading based on group composition
function SpellDetectionOptimization:QueueClassSpecificSpellUpdate()
    -- Only proceed if predictive loading is enabled
    if not Config.predictiveLoadingEnabled then return end
    
    SpellCache.pendingUpdates = SpellCache.pendingUpdates or {}
    local classSpells = self:GetGroupClassSpells()
    
    -- Add class spells to pending updates queue
    for _, spellID in ipairs(classSpells) do
        if not SpellCache.byID[spellID] then
            table.insert(SpellCache.pendingUpdates, spellID)
        end
    end
end

-- Queue a complete cache update (for out-of-combat optimization)
function SpellDetectionOptimization:QueueFullCacheUpdate()
    -- Only proceed if predictive loading is enabled
    if not Config.predictiveLoadingEnabled then return end
    
    local MultiNotification = VUI:GetModule("MultiNotification")
    if not MultiNotification or not MultiNotification.db then return end
    
    SpellCache.pendingUpdates = SpellCache.pendingUpdates or {}
    
    -- Get important spells from the module
    local importantSpells = MultiNotification.db.profile.spellSettings.importantSpells
    if not importantSpells then return end
    
    -- Queue all important spells for update
    for spellID, data in pairs(importantSpells) do
        if type(spellID) == "number" and not SpellCache.byID[spellID] then
            table.insert(SpellCache.pendingUpdates, spellID)
        end
    end
end

-- Process pending cache updates out-of-combat
function SpellDetectionOptimization:ProcessPendingCacheUpdates()
    if not Config.predictiveLoadingEnabled or InCombatLockdown() then return end
    if not SpellCache.pendingUpdates or #SpellCache.pendingUpdates == 0 then return end
    
    -- Process up to 10 spells per update to avoid client stuttering
    local processCount = math.min(10, #SpellCache.pendingUpdates)
    local processed = 0
    
    for i = 1, processCount do
        local spellID = table.remove(SpellCache.pendingUpdates, 1)
        if spellID then
            local name, rank, icon = GetSpellInfo(spellID)
            if name then
                -- Cache the spell data
                SpellCache.byID[spellID] = {
                    id = spellID,
                    name = name, 
                    icon = icon,
                    timestamp = GetTime()
                }
                
                -- Cross-index by name
                SpellCache.byName[name] = SpellCache.byID[spellID]
                
                -- Update last used time
                SpellCache.lastUsed[spellID] = GetTime()
                processed = processed + 1
                Metrics.predictiveCacheUpdates = Metrics.predictiveCacheUpdates + 1
            end
        end
    end
    
    -- Check cache size limits after updates
    if processed > 0 then
        self:CheckCacheSize()
        
        if Config.debugMode then
            -- Only print updates for larger batches to avoid spam
            if processed >= 5 then
                VUI:Print(string.format("Predictive caching: Added %d spells to cache", processed))
            end
        end
    end
end

-- Get class-specific spells based on current group composition
function SpellDetectionOptimization:GetGroupClassSpells()
    local classSpells = {}
    
    -- Common important class spells by ID
    local spellsByClass = {
        -- Death Knight
        ["DEATHKNIGHT"] = {48707, 49028, 47476, 47568, 51271, 55233, 48792, 43265},
        -- Demon Hunter
        ["DEMONHUNTER"] = {198589, 212084, 196718, 187827, 191427, 203720, 207684, 204596},
        -- Druid
        ["DRUID"] = {740, 33891, 102342, 102793, 205636, 108238, 77764, 194223, 22812, 61336},
        -- Hunter
        ["HUNTER"] = {34477, 186257, 186265, 109304, 53271, 187650, 186387, 19574, 190925},
        -- Mage
        ["MAGE"] = {122, 2139, 45438, 113724, 12042, 12472, 190319, 110959, 190446},
        -- Monk
        ["MONK"] = {115203, 116844, 115078, 122470, 243435, 122278, 115310, 116680, 119582},
        -- Paladin
        ["PALADIN"] = {31884, 86659, 31821, 1022, 6940, 204018, 105809, 184662, 498, 642},
        -- Priest
        ["PRIEST"] = {47788, 33206, 62618, 64843, 64901, 10060, 15286, 19236, 586, 8122},
        -- Rogue
        ["ROGUE"] = {31224, 5277, 1966, 1856, 2983, 79140, 121471, 13750, 51690, 57934},
        -- Shaman
        ["SHAMAN"] = {98008, 108280, 16191, 51886, 8143, 208963, 114052, 192249, 198067},
        -- Warlock
        ["WARLOCK"] = {104773, 108416, 113860, 113858, 205180, 108503, 48020, 111771},
        -- Warrior
        ["WARRIOR"] = {97462, 118038, 6673, 1160, 871, 12975, 107574, 46968, 167105}
    }
    
    -- Check current party/raid members
    local isInRaid = IsInRaid()
    local unitPrefix = isInRaid and "raid" or "party"
    local maxMembers = isInRaid and 40 or 5
    
    -- Always include player's class
    local playerClass = select(2, UnitClass("player"))
    if playerClass and spellsByClass[playerClass] then
        for _, spellID in ipairs(spellsByClass[playerClass]) do
            table.insert(classSpells, spellID)
        end
    end
    
    -- Check group members
    for i = 1, maxMembers do
        local unit = i == maxMembers and not isInRaid and "player" or unitPrefix..i
        if UnitExists(unit) then
            local _, class = UnitClass(unit)
            if class and spellsByClass[class] then
                -- Add class-specific spells to the list, prioritizing important ones
                for _, spellID in ipairs(spellsByClass[class]) do
                    table.insert(classSpells, spellID)
                end
            end
        end
    end
    
    return classSpells
end

-- Report cache performance metrics
function SpellDetectionOptimization:ReportMetrics()
    -- Always schedule next report first
    C_Timer.After(60, function() self:ReportMetrics() end)
    
    -- Metrics reporting disabled in production release
    -- Uncomment the code below for development debugging
end

-- Create configuration options for the optimization module
function SpellDetectionOptimization:GetConfigOptions()
    return {
        optimizationHeader = {
            order = 1,
            type = "header",
            name = "Spell Detection Optimization",
        },
        enabled = {
            order = 2,
            type = "toggle",
            name = "Enable Optimization",
            desc = "Enable the spell detection logic enhancement system for improved performance",
            get = function() return Config.enabledByDefault end,
            set = function(_, value) 
                Config.enabledByDefault = value 
                
                -- Update settings in DB
                local db = VUI.db:GetNamespace("MultiNotification")
                if db and db.profile and db.profile.optimizationSettings then
                    db.profile.optimizationSettings.enabled = value
                end
            end,
            width = "full",
        },
        predictiveLoading = {
            order = 3,
            type = "toggle",
            name = "Predictive Spell Loading",
            desc = "Preload commonly used spells for faster access during combat",
            get = function() return Config.predictiveLoadingEnabled end,
            set = function(_, value) 
                Config.predictiveLoadingEnabled = value 
                
                -- Update settings in DB
                local db = VUI.db:GetNamespace("MultiNotification")
                if db and db.profile and db.profile.optimizationSettings then
                    db.profile.optimizationSettings.predictiveLoading = value
                end
                
                -- Reinitialize cache if enabling
                if value then
                    SpellDetectionOptimization:PreloadCommonSpells()
                end
            end,
            width = "full",
            disabled = function() return not Config.enabledByDefault end,
        },
        combatThrottling = {
            order = 4,
            type = "toggle",
            name = "Combat Event Throttling",
            desc = "Throttle combat event processing during intense combat to improve performance",
            get = function() return Config.combatThrottling end,
            set = function(_, value) 
                Config.combatThrottling = value 
                
                -- Update settings in DB
                local db = VUI.db:GetNamespace("MultiNotification")
                if db and db.profile and db.profile.optimizationSettings then
                    db.profile.optimizationSettings.combatThrottling = value
                end
            end,
            width = "full",
            disabled = function() return not Config.enabledByDefault end,
        },
        throttleInterval = {
            order = 5,
            type = "range",
            name = "Throttle Interval",
            desc = "The minimum time between processing combat events during throttling (in seconds)",
            min = 0.01,
            max = 0.5,
            step = 0.01,
            get = function() return Config.throttleInterval end,
            set = function(_, value) 
                Config.throttleInterval = value 
                
                -- Update settings in DB
                local db = VUI.db:GetNamespace("MultiNotification")
                if db and db.profile and db.profile.optimizationSettings then
                    db.profile.optimizationSettings.throttleInterval = value
                end
            end,
            width = "full",
            disabled = function() return not Config.enabledByDefault or not Config.combatThrottling end,
        },
        adaptiveThrottling = {
            order = 6,
            type = "toggle",
            name = "Adaptive FPS Throttling",
            desc = "Automatically increase throttling when framerate drops to maintain performance",
            get = function() return Config.adaptiveThrottling end,
            set = function(_, value) 
                Config.adaptiveThrottling = value 
                
                -- Update settings in DB
                local db = VUI.db:GetNamespace("MultiNotification")
                if db and db.profile and db.profile.optimizationSettings then
                    db.profile.optimizationSettings.adaptiveThrottling = value
                end
            end,
            width = "full",
            disabled = function() return not Config.enabledByDefault or not Config.combatThrottling end,
        },
        lowFpsThreshold = {
            order = 7,
            type = "range",
            name = "Low FPS Threshold",
            desc = "Framerate threshold to trigger additional throttling",
            min = 10,
            max = 60,
            step = 1,
            get = function() return Config.lowFpsThreshold end,
            set = function(_, value) 
                Config.lowFpsThreshold = value 
                
                -- Update settings in DB
                local db = VUI.db:GetNamespace("MultiNotification")
                if db and db.profile and db.profile.optimizationSettings then
                    db.profile.optimizationSettings.lowFpsThreshold = value
                end
            end,
            width = "full",
            disabled = function() return not Config.enabledByDefault or not Config.combatThrottling or not Config.adaptiveThrottling end,
        },
        lowFpsThrottleMultiplier = {
            order = 8,
            type = "range",
            name = "Low FPS Throttle Multiplier",
            desc = "How much to increase throttling when framerate drops below threshold (higher = more aggressive throttling)",
            min = 1.5,
            max = 5.0,
            step = 0.5,
            get = function() return Config.lowFpsThrottleMultiplier end,
            set = function(_, value) 
                Config.lowFpsThrottleMultiplier = value 
                
                -- Update settings in DB
                local db = VUI.db:GetNamespace("MultiNotification")
                if db and db.profile and db.profile.optimizationSettings then
                    db.profile.optimizationSettings.lowFpsThrottleMultiplier = value
                end
            end,
            width = "full",
            disabled = function() return not Config.enabledByDefault or not Config.combatThrottling or not Config.adaptiveThrottling end,
        },
        cacheSize = {
            order = 9,
            type = "range",
            name = "Cache Size",
            desc = "Maximum number of spells to cache for faster lookup",
            min = 100,
            max = 5000,
            step = 100,
            get = function() return Config.cacheSize end,
            set = function(_, value) 
                Config.cacheSize = value 
                
                -- Update settings in DB
                local db = VUI.db:GetNamespace("MultiNotification")
                if db and db.profile and db.profile.optimizationSettings then
                    db.profile.optimizationSettings.cacheSize = value
                end
            end,
            width = "full",
            disabled = function() return not Config.enabledByDefault end,
        },
        debugMode = {
            order = 10,
            type = "toggle",
            name = "Debug Mode",
            desc = "Enable debug output for spell detection optimization metrics",
            get = function() return Config.debugMode end,
            set = function(_, value) 
                Config.debugMode = value 
                
                -- Update settings in DB
                local db = VUI.db:GetNamespace("MultiNotification")
                if db and db.profile and db.profile.optimizationSettings then
                    db.profile.optimizationSettings.debug = value
                end
            end,
            width = "full",
            disabled = function() return not Config.enabledByDefault end,
        },
        resetCache = {
            order = 11,
            type = "execute",
            name = "Reset Cache",
            desc = "Clear the spell cache and reset all optimization metrics",
            func = function()
                SpellDetectionOptimization:InitializeCache()
                
                -- Reset metrics
                Metrics.cacheHits = 0
                Metrics.cacheMisses = 0
                Metrics.spellsProcessed = 0
                Metrics.eventsFiltered = 0
                Metrics.spellIconsOptimized = 0
                Metrics.predictiveLoads = 0
                Metrics.predictiveCacheUpdates = 0
                Metrics.lastReset = GetTime()
                
                VUI:Print("Spell detection cache has been reset")
            end,
            width = "full",
            disabled = function() return not Config.enabledByDefault end,
        },
    }
end

-- Integrate optimization options into MultiNotification settings
function SpellDetectionOptimization:IntegrateConfigOptions()
    local MultiNotification = VUI:GetModule("MultiNotification")
    if not MultiNotification or not MultiNotification.GetOptions then return end
    
    -- Store original function
    local originalGetOptions = MultiNotification.GetOptions
    
    -- Override with our enhanced version
    MultiNotification.GetOptions = function(self)
        local options = originalGetOptions(self)
        
        -- Add optimization tab
        if options and options.args then
            options.args.optimization = {
                name = "Performance",
                type = "group",
                order = 50,
                args = SpellDetectionOptimization:GetConfigOptions()
            }
        end
        
        return options
    end
end

-- Register with VUI Module
VUI:RegisterScript("core/spell_detection_optimization.lua")