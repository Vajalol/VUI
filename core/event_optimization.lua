local _, VUI = ...

-- Event Optimization System
-- Provides optimized event handling and registration to reduce overhead
-- Implements smart event batching, throttling, and prioritization

-- Create a safe debug function
local function SafeDebug(message)
    if type(VUI.Debug) == "function" then
        VUI.Debug(message)
    elseif VUI.Debug then
        pcall(function() VUI:Debug(message) end)
    elseif VUI.db and VUI.db.profile and VUI.db.profile.debugging then
        print("|cff00aaff[VUI]|r " .. message)
    end
end

-- Create namespace
VUI.EventOptimization = {}
local EventOpt = VUI.EventOptimization

-- Configuration
EventOpt.config = {
    enabled = true,                -- Master switch
    combatOptimizationEnabled = true, -- Additional optimizations during combat
    batchingEnabled = true,        -- Combine multiple events into batches
    throttlingEnabled = true,      -- Throttle high-frequency events
    priorityEnabled = true,        -- Process events based on priority
    batchInterval = 0.05,          -- Interval for processing batched events (in seconds)
    throttleInterval = {           -- Throttle intervals by priority
        critical = 0.01,           -- Process every 0.01 seconds
        high = 0.05,               -- Process every 0.05 seconds
        medium = 0.1,              -- Process every 0.1 seconds
        low = 0.2                  -- Process every 0.2 seconds
    },
    combatThrottleInterval = {     -- More aggressive throttling during combat
        critical = 0.02,           -- Process every 0.02 seconds
        high = 0.1,                -- Process every 0.1 seconds
        medium = 0.2,              -- Process every 0.2 seconds
        low = 0.5                  -- Process every 0.5 seconds
    },
    priorityLevels = {             -- Priority levels for different event types
        critical = 1,              -- Must process immediately (player health, combat state)
        high = 2,                  -- Process quickly (target changes, important auras)
        medium = 3,                -- Process regularly (party frames, etc.)
        low = 4                    -- Process when possible (non-essential events)
    },
    eventPriorities = {            -- Default priority for common events
        ["PLAYER_REGEN_DISABLED"] = 1,    -- Combat start (critical)
        ["PLAYER_REGEN_ENABLED"] = 1,     -- Combat end (critical)
        ["UNIT_HEALTH"] = 1,              -- Health changes (critical)
        ["UNIT_POWER_UPDATE"] = 1,        -- Power changes (critical)
        ["PLAYER_TARGET_CHANGED"] = 2,    -- Target change (high)
        ["UNIT_SPELLCAST_START"] = 2,     -- Spell cast start (high)
        ["UNIT_SPELLCAST_SUCCEEDED"] = 2, -- Spell cast success (high) 
        ["UNIT_AURA"] = 2,                -- Aura changes (high)
        ["GROUP_ROSTER_UPDATE"] = 3,      -- Group changes (medium)
        ["PLAYER_ENTERING_WORLD"] = 3,    -- Zone changes (medium)
        ["COMBAT_LOG_EVENT_UNFILTERED"] = 1, -- Combat log (depends on usage, default critical)
        ["ZONE_CHANGED_NEW_AREA"] = 3,    -- Zone changes (medium)
        ["PLAYER_EQUIPMENT_CHANGED"] = 4, -- Equipment changes (low)
        ["BAG_UPDATE"] = 4,               -- Bag changes (low)
        ["CHAT_MSG_ADDON"] = 3            -- Addon messages (medium)
    },
    -- Events that should never be throttled
    criticalEvents = {
        ["PLAYER_REGEN_DISABLED"] = true,
        ["PLAYER_REGEN_ENABLED"] = true,
        ["PLAYER_DEAD"] = true,
        ["PLAYER_ALIVE"] = true,
        ["PLAYER_UNGHOST"] = true
    },
    -- Events that should always be processed immediately
    instantEvents = {
        ["PLAYER_ENTERING_WORLD"] = true,
        ["PLAYER_LOGIN"] = true, 
        ["PLAYER_LOGOUT"] = true,
        ["ADDON_LOADED"] = true
    }
}

-- State tracking
EventOpt.state = {
    inCombat = false,
    registeredEvents = {},         -- All registered events
    eventCallbacks = {},           -- Callbacks for each event
    eventLastFired = {},           -- When each event was last processed
    eventBatches = {},             -- Batches of events waiting to be processed
    eventQueue = {},               -- Priority queue of events
    eventCount = {                 -- Statistics
        registered = 0,
        processed = 0,
        throttled = 0,
        batched = 0,
        skipped = 0
    },
    processingBatch = false,       -- Flag to prevent batch reentry
    lastBatchProcess = 0,          -- Time when the last batch was processed
    highFrequencyEvents = {},      -- Events firing frequently
    eventPriority = {},            -- Custom priority for events
    eventThrottled = {},           -- Whether an event is currently throttled
    moduleEvents = {},             -- Events registered by each module
    moduleExemptions = {},         -- Modules exempt from throttling
    lastCombatCheck = 0            -- Time of last combat state check
}

-- Initialize the event optimization system
function EventOpt:Initialize()
    -- Create a frame for handling events
    self.frame = CreateFrame("Frame")
    
    -- Set up the event handlers
    self.frame:SetScript("OnEvent", function(_, event, ...)
        self:ProcessEvent(event, ...)
    end)
    
    -- Set up regular updates for batch processing
    self.frame:SetScript("OnUpdate", function(_, elapsed)
        self:OnUpdate(elapsed)
    end)
    
    -- Initialize event state
    self.state.inCombat = UnitAffectingCombat("player")
    
    -- Monitor combat state
    self.frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    self.frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    
    -- Register the system with VUI
    if VUI.RegisterModule then
        VUI:RegisterModule("EventOptimization", self)
    end
    
    -- Use safe way to log initialization
    if type(VUI.Debug) == "function" then
        -- Call as function
        VUI.Debug("Event Optimization System initialized")
    elseif VUI.Debug then
        -- Try method call if it exists but isn't a direct function
        pcall(function() VUI:Debug("Event Optimization System initialized") end)
    else
        -- Fallback if Debug not available
        if VUI.db and VUI.db.profile and VUI.db.profile.debugging then
            print("|cff00aaff[VUI]|r Event Optimization System initialized")
        end
    end
end

-- Register an event with optimal handling
function EventOpt:RegisterEvent(event, callback, module, priority)
    if not event or not callback then return end
    
    -- Determine priority if not provided
    priority = priority or self.config.eventPriorities[event] or self.config.priorityLevels.medium
    
    -- Initialize event tracking if this is the first registration
    if not self.state.registeredEvents[event] then
        self.state.registeredEvents[event] = true
        self.state.eventCallbacks[event] = {}
        self.state.eventLastFired[event] = 0
        self.state.eventThrottled[event] = false
        self.state.eventPriority[event] = priority
        
        -- Register with WoW API
        self.frame:RegisterEvent(event)
        
        self.state.eventCount.registered = self.state.eventCount.registered + 1
    end
    
    -- Store the callback with metadata
    table.insert(self.state.eventCallbacks[event], {
        func = callback,
        module = module or "unknown",
        priority = priority
    })
    
    -- Track which events each module has registered
    if module then
        if not self.state.moduleEvents[module] then
            self.state.moduleEvents[module] = {}
        end
        self.state.moduleEvents[module][event] = true
    end
    
    -- Safe debug call
    if type(VUI.Debug) == "function" then
        VUI.Debug("Registered event: " .. event .. " for module: " .. (module or "unknown") .. " with priority: " .. priority)
    elseif VUI.Debug then
        pcall(function() VUI:Debug("Registered event: " .. event .. " for module: " .. (module or "unknown") .. " with priority: " .. priority) end)
    end
end

-- Unregister an event
function EventOpt:UnregisterEvent(event, callback, module)
    if not event or not self.state.registeredEvents[event] then return end
    
    -- If callback is nil, remove all callbacks for this event from the module
    if not callback and module and self.state.eventCallbacks[event] then
        local remaining = {}
        for _, cbInfo in ipairs(self.state.eventCallbacks[event]) do
            if cbInfo.module ~= module then
                table.insert(remaining, cbInfo)
            end
        end
        self.state.eventCallbacks[event] = remaining
    
    -- Otherwise, remove the specific callback
    elseif callback and self.state.eventCallbacks[event] then
        local remaining = {}
        for _, cbInfo in ipairs(self.state.eventCallbacks[event]) do
            if cbInfo.func ~= callback then
                table.insert(remaining, cbInfo)
            end
        end
        self.state.eventCallbacks[event] = remaining
    end
    
    -- If no callbacks remain, unregister the event completely
    if #self.state.eventCallbacks[event] == 0 then
        self.frame:UnregisterEvent(event)
        self.state.registeredEvents[event] = nil
        self.state.eventCallbacks[event] = nil
        self.state.eventLastFired[event] = nil
        self.state.eventThrottled[event] = nil
        
        self.state.eventCount.registered = self.state.eventCount.registered - 1
    end
    
    -- Update module event tracking
    if module and self.state.moduleEvents[module] then
        self.state.moduleEvents[module][event] = nil
    end
    
    SafeDebug("Unregistered event: " .. event .. (module and (" for module: " .. module) or ""))
end

-- Set a module as exempt from throttling
function EventOpt:SetModuleExempt(module, exempt)
    if not module then return end
    self.state.moduleExemptions[module] = exempt == true
    SafeDebug("Module " .. module .. " is now " .. (exempt and "exempt from" or "subject to") .. " event throttling")
end

-- Process an event when it fires
function EventOpt:ProcessEvent(event, ...)
    if not event or not self.state.registeredEvents[event] then return end
    
    local currentTime = GetTime()
    local args = {...}
    
    -- Handle critical events immediately
    if self.config.criticalEvents[event] or self.config.instantEvents[event] then
        self:ExecuteEventCallbacks(event, args)
        self.state.eventLastFired[event] = currentTime
        return
    end
    
    -- Combat status events always processed immediately
    if event == "PLAYER_REGEN_DISABLED" then
        self.state.inCombat = true
        SafeDebug("Combat started - adjusting event throttling")
    elseif event == "PLAYER_REGEN_ENABLED" then
        self.state.inCombat = false
        SafeDebug("Combat ended - restoring normal event processing")
    end
    
    -- Update high frequency event tracking
    local timeSinceLastFired = currentTime - (self.state.eventLastFired[event] or 0)
    if timeSinceLastFired < 0.1 then
        self.state.highFrequencyEvents[event] = (self.state.highFrequencyEvents[event] or 0) + 1
        if self.state.highFrequencyEvents[event] > 10 and not self.state.eventThrottled[event] then
            self.state.eventThrottled[event] = true
            SafeDebug("Auto-throttling high frequency event: " .. event)
        end
    else
        -- Reset counter for low frequency events
        if self.state.highFrequencyEvents[event] and self.state.highFrequencyEvents[event] > 0 then
            self.state.highFrequencyEvents[event] = self.state.highFrequencyEvents[event] - 1
            if self.state.highFrequencyEvents[event] <= 5 and self.state.eventThrottled[event] then
                self.state.eventThrottled[event] = false
                SafeDebug("Removed throttling for event: " .. event)
            end
        end
    end
    
    -- Determine if we should throttle this event
    local shouldThrottle = self.config.throttlingEnabled and 
                          (self.state.eventThrottled[event] or self.state.inCombat)
    
    -- Get the appropriate throttle interval based on priority and combat state
    local priority = self.state.eventPriority[event] or self.config.priorityLevels.medium
    local throttleInterval
    
    if self.state.inCombat and self.config.combatOptimizationEnabled then
        -- Use combat throttle intervals
        if priority == self.config.priorityLevels.critical then
            throttleInterval = self.config.combatThrottleInterval.critical
        elseif priority == self.config.priorityLevels.high then
            throttleInterval = self.config.combatThrottleInterval.high
        elseif priority == self.config.priorityLevels.medium then
            throttleInterval = self.config.combatThrottleInterval.medium
        else
            throttleInterval = self.config.combatThrottleInterval.low
        end
    else
        -- Use normal throttle intervals
        if priority == self.config.priorityLevels.critical then
            throttleInterval = self.config.throttleInterval.critical
        elseif priority == self.config.priorityLevels.high then
            throttleInterval = self.config.throttleInterval.high
        elseif priority == self.config.priorityLevels.medium then
            throttleInterval = self.config.throttleInterval.medium
        else
            throttleInterval = self.config.throttleInterval.low
        end
    end
    
    -- Skip if throttled and not enough time has passed
    if shouldThrottle and (currentTime - (self.state.eventLastFired[event] or 0) < throttleInterval) then
        self.state.eventCount.throttled = self.state.eventCount.throttled + 1
        return
    end
    
    -- If batching is enabled, add to batch
    if self.config.batchingEnabled and priority > self.config.priorityLevels.critical then
        if not self.state.eventBatches[event] then
            self.state.eventBatches[event] = {}
        end
        
        table.insert(self.state.eventBatches[event], {
            args = args,
            time = currentTime,
            priority = priority
        })
        
        self.state.eventCount.batched = self.state.eventCount.batched + 1
    else
        -- Process immediately if not batched
        self:ExecuteEventCallbacks(event, args)
        self.state.eventCount.processed = self.state.eventCount.processed + 1
    end
    
    -- Update last fired time
    self.state.eventLastFired[event] = currentTime
end

-- Execute all callbacks for an event
function EventOpt:ExecuteEventCallbacks(event, args)
    if not event or not self.state.eventCallbacks[event] then return end
    
    -- Sort callbacks by priority (lower number = higher priority)
    table.sort(self.state.eventCallbacks[event], function(a, b)
        return a.priority < b.priority
    end)
    
    -- Execute callbacks
    for _, cbInfo in ipairs(self.state.eventCallbacks[event]) do
        -- Check if the module is exempt from throttling
        local isExempt = self.state.moduleExemptions[cbInfo.module]
        
        -- Execute the callback
        if isExempt or not self.state.inCombat or cbInfo.priority <= self.config.priorityLevels.high then
            local success, err = pcall(cbInfo.func, unpack(args))
            if not success then
                SafeDebug("Error executing event callback: " .. (err or "unknown error"))
            end
        else
            -- Skip lower priority callbacks during combat to save performance
            self.state.eventCount.skipped = self.state.eventCount.skipped + 1
        end
    end
end

-- Process batched events
function EventOpt:ProcessBatches()
    if self.state.processingBatch then return end
    
    self.state.processingBatch = true
    local currentTime = GetTime()
    
    -- Process batches by priority
    for event, batch in pairs(self.state.eventBatches) do
        if #batch > 0 then
            -- Find the most recent batch entry
            local mostRecent = batch[#batch]
            
            -- Execute callbacks with the most recent data
            self:ExecuteEventCallbacks(event, mostRecent.args)
            self.state.eventCount.processed = self.state.eventCount.processed + 1
            
            -- Clear the batch
            self.state.eventBatches[event] = {}
        end
    end
    
    self.state.lastBatchProcess = currentTime
    self.state.processingBatch = false
end

-- Frame update handler
function EventOpt:OnUpdate(elapsed)
    local currentTime = GetTime()
    
    -- Process batched events on interval
    if self.config.batchingEnabled and
       (currentTime - self.state.lastBatchProcess) >= self.config.batchInterval then
        self:ProcessBatches()
    end
    
    -- Update combat state if needed
    if (currentTime - self.state.lastCombatCheck) >= 0.5 then
        local inCombat = UnitAffectingCombat("player")
        if inCombat ~= self.state.inCombat then
            self.state.inCombat = inCombat
            SafeDebug("Combat state changed to: " .. (inCombat and "in combat" or "out of combat"))
            
            -- Notify other systems of combat state change
            VUI:SendMessage("VUI_COMBAT_STATE_CHANGED", inCombat)
        end
        self.state.lastCombatCheck = currentTime
    end
end

-- Get performance statistics
function EventOpt:GetStats()
    local stats = {
        registered = self.state.eventCount.registered,
        processed = self.state.eventCount.processed,
        throttled = self.state.eventCount.throttled,
        batched = self.state.eventCount.batched,
        skipped = self.state.eventCount.skipped,
        highFrequency = 0
    }
    
    -- Count high frequency events
    for event, count in pairs(self.state.highFrequencyEvents) do
        if count > 5 then
            stats.highFrequency = stats.highFrequency + 1
        end
    end
    
    -- Count events by priority
    stats.byPriority = {0, 0, 0, 0}
    for event, priority in pairs(self.state.eventPriority) do
        stats.byPriority[priority] = stats.byPriority[priority] + 1
    end
    
    -- Count events by module
    stats.byModule = {}
    for module, events in pairs(self.state.moduleEvents) do
        stats.byModule[module] = 0
        for _ in pairs(events) do
            stats.byModule[module] = stats.byModule[module] + 1
        end
    end
    
    return stats
end

-- Register with VUI
EventOpt:Initialize()

-- Return the module
return EventOpt