-- ===================================================================================================================
-- Resource Cleanup System
-- A critical component for performance optimization that intelligently manages memory and resources during idle periods.
-- ===================================================================================================================

local addonName, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end

-- Create module
local ResourceCleanup = {
    name = "ResourceCleanup",
    config = {
        -- User configuration (customizable)
        enableResourceCleanup = true,           -- Master toggle
        enableLightCleanup = true,              -- Enable light cleanup
        enableDeepCleanup = true,               -- Enable deep cleanup
        
        -- Idle detection
        lightCleanupIdleThreshold = 30,         -- Seconds of idle time before light cleanup (30 seconds)
        deepCleanupIdleThreshold = 120,         -- Seconds of idle time before deep cleanup (2 minutes)
        
        -- Memory thresholds
        memoryThreshold = 35,                   -- MB of memory usage to trigger cleanup
        memoryThresholdRelative = 0.3,          -- 30% increase from baseline
        
        -- Framerate thresholds
        lowFramerateThreshold = 20,             -- FPS below which to trigger cleanup
        framerateDipThreshold = 0.25,           -- 25% drop triggers cleanup
        
        -- Combat settings
        postCombatBufferTime = 6,               -- Seconds to wait after combat before resuming cleanup
        combatCleanupDisabled = true,           -- Disable cleanup during combat
        
        -- Cache limits
        maxTextures = 200,                      -- Maximum textures to keep in cache
        maxFonts = 50,                          -- Maximum fonts to keep in cache
        maxSounds = 30,                         -- Maximum sounds to keep in cache
        maxStringTables = 500,                  -- Maximum string tables to keep in cache
        maxObjectPools = 300,                   -- Maximum object pools to keep
        
        -- Cleanup frequency
        memoryCheckInterval = 30,               -- Seconds between memory checks
        idleCheckInterval = 1,                  -- Seconds between idle checks
        gcInterval = 300,                       -- Seconds between forced garbage collections
        
        -- Debug settings
        debugMode = false,                      -- Enable debug logging
        trackCleanupStats = true                -- Track cleanup statistics
    },
    
    state = {
        -- Internal state tracking
        initialized = false,                    -- Module initialization flag
        lastActivityTime = 0,                   -- Last time user activity was detected
        inCombat = false,                       -- Combat state tracker
        exitedCombatTime = 0,                   -- Time when combat ended
        baselineMemory = 0,                     -- Baseline memory usage
        lastCleanupTime = 0,                    -- Last time cleanup was performed
        lastDeepCleanupTime = 0,                -- Last time deep cleanup was performed
        lastGCTime = 0,                         -- Last time GC was forced
        lastMemoryCheckTime = 0,                -- Last time memory was checked
        
        -- Performance tracking
        memorySamples = {},                     -- Recent memory usage samples
        frameRates = {},                        -- Recent framerate samples
        cleanupStats = {                        -- Statistics tracking
            lightCleanupCount = 0,              -- Light cleanup count
            deepCleanupCount = 0,               -- Deep cleanup count
            memoryCleanedTotal = 0,             -- Total MB of memory cleaned
            lastCleanupMemorySaved = 0,         -- MB saved in last cleanup
            averageMemorySaved = 0,             -- Average MB saved per cleanup
            totalFramesReclaimed = 0,           -- Total frames reclaimed
            texturesCleaned = 0,                -- Textures cleaned
            fontsCleaned = 0,                   -- Fonts cleaned
            soundsCleaned = 0,                  -- Sounds cleaned
            tablesCleaned = 0,                  -- Tables cleaned
            weakReferencesCleaned = 0           -- Weak references cleaned
        },
        
        -- Resource tracking
        registeredModules = {},                 -- Modules registered for cleanup
        exemptModules = {},                     -- Modules exempt from automatic cleanup
        cacheStats = {                          -- Cache statistics
            textureCount = 0,                   -- Current texture count
            fontCount = 0,                      -- Current font count
            soundCount = 0,                     -- Current sound count
            stringTableCount = 0,               -- Current string table count
            objectPoolCount = 0                 -- Current object pool count
        }
    }
}

-- Local references for better performance
local GetTime = GetTime
local collectgarbage = collectgarbage
local GetFramerate = GetFramerate
local min = math.min
local max = math.max
local floor = math.floor
local format = string.format
local tinsert = table.insert
local tremove = table.remove
local UpdateAddOnMemoryUsage = UpdateAddOnMemoryUsage
local GetAddOnMemoryUsage = GetAddOnMemoryUsage
local pairs = pairs
local ipairs = ipairs
local type = type
local pcall = pcall

-- Initialize the module
function ResourceCleanup:Initialize()
    if self.state.initialized then return end
    
    -- Hook event handlers
    self:RegisterEvents()
    
    -- Setup idle detection
    self:SetupIdleDetection()
    
    -- Get baseline memory usage
    self:UpdateMemoryBaseline()
    
    -- Setup timers
    self:SetupTimers()
    
    -- Register for VUI messages
    VUI:RegisterMessage("MODULE_INITIALIZED", function(_, moduleName)
        if self.state.registeredModules[moduleName] then

        end
    end)
    
    -- Register for combat events from VUI's core event system
    VUI:RegisterMessage("PLAYER_ENTERING_COMBAT", function()
        self.state.inCombat = true
        self:OnEnteringCombat()
    end)
    
    VUI:RegisterMessage("PLAYER_LEAVING_COMBAT", function()
        self.state.inCombat = false
        self.state.exitedCombatTime = GetTime()
        self:OnLeavingCombat()
    end)
    
    -- Register for zone change notifications
    VUI:RegisterMessage("ZONE_CHANGED", function()
        self:OnZoneChange()
    end)
    
    -- Mark as initialized
    self.state.initialized = true
    self.state.lastActivityTime = GetTime()
    self.state.lastCleanupTime = GetTime()
    self.state.lastGCTime = GetTime()
    

end

-- Register required events
function ResourceCleanup:RegisterEvents()
    -- No direct event registration needed - we use VUI messages
end

-- Setup idle detection by hooking into UI events
function ResourceCleanup:SetupIdleDetection()
    -- Note: In an actual client we'd hook mouse and keyboard events
    -- In the addon context, we'll use a combination of frame updates and interaction events
    
    -- Store old handlers to maintain functionality
    local oldOnMouseDown = VUI.UIParent and VUI.UIParent:GetScript("OnMouseDown")
    local oldOnKeyDown = VUI.UIParent and VUI.UIParent:GetScript("OnKeyDown")
    
    -- Update activity time on user interaction
    local function UpdateLastActivityTime()
        self.state.lastActivityTime = GetTime()
    end
    
    -- Hook UI parent frame for mouse events if it exists
    if VUI.UIParent then
        VUI.UIParent:SetScript("OnMouseDown", function(...)
            UpdateLastActivityTime()
            if oldOnMouseDown then oldOnMouseDown(...) end
        end)
        
        VUI.UIParent:SetScript("OnKeyDown", function(...)
            UpdateLastActivityTime()
            if oldOnKeyDown then oldOnKeyDown(...) end
        end)
    end
    
    -- Hook functions that indicate user activity
    hooksecurefunc("StaticPopup_Show", UpdateLastActivityTime)
    hooksecurefunc("ChatEdit_ActivateChat", UpdateLastActivityTime)
    
    -- Additional hooks for common UI interactions
    if VUI.HookInteraction then
        VUI:HookInteraction(UpdateLastActivityTime)
    end
end

-- Update baseline memory usage (after initialization or major changes)
function ResourceCleanup:UpdateMemoryBaseline()
    collectgarbage("collect") -- Initial collection to stabilize
    
    -- Wait a moment and then get the baseline
    C_Timer.After(1, function()
        UpdateAddOnMemoryUsage()
        self.state.baselineMemory = GetAddOnMemoryUsage(addonName) / 1024 -- Convert to MB
        

    end)
end

-- Setup periodic timers for cleanup checks
function ResourceCleanup:SetupTimers()
    -- Regular idle check
    C_Timer.NewTicker(self.config.idleCheckInterval, function()
        self:CheckIdleStatus()
    end)
    
    -- Memory usage check
    C_Timer.NewTicker(self.config.memoryCheckInterval, function()
        self:CheckMemoryUsage()
    end)
    
    -- Periodic GC if enabled
    C_Timer.NewTicker(self.config.gcInterval, function()
        self:PerformPeriodicGC()
    end)
end

-- Check if player is idle and trigger cleanup if needed
function ResourceCleanup:CheckIdleStatus()
    if not self.config.enableResourceCleanup then return end
    
    local currentTime = GetTime()
    local idleTime = currentTime - self.state.lastActivityTime
    
    -- Skip if in combat and combat cleanup is disabled
    if self.state.inCombat and self.config.combatCleanupDisabled then
        return
    end
    
    -- Skip during post-combat buffer period
    if (currentTime - self.state.exitedCombatTime) < self.config.postCombatBufferTime then
        return
    end
    
    -- Check for deep cleanup first (longer idle time)
    if self.config.enableDeepCleanup and 
       idleTime >= self.config.deepCleanupIdleThreshold and
       (currentTime - self.state.lastDeepCleanupTime) >= self.config.deepCleanupIdleThreshold then
        self:PerformDeepCleanup()
        self.state.lastDeepCleanupTime = currentTime
        self.state.lastCleanupTime = currentTime
    -- Otherwise check for light cleanup
    elseif self.config.enableLightCleanup and 
           idleTime >= self.config.lightCleanupIdleThreshold and
           (currentTime - self.state.lastCleanupTime) >= self.config.lightCleanupIdleThreshold then
        self:PerformLightCleanup()
        self.state.lastCleanupTime = currentTime
    end
end

-- Check memory usage and trigger cleanup if thresholds exceeded
function ResourceCleanup:CheckMemoryUsage()
    if not self.config.enableResourceCleanup then return end
    
    -- Update memory samples
    self:UpdateMemorySamples()
    
    -- Get current memory usage
    local currentMemory = self.state.memorySamples[#self.state.memorySamples] or 0
    
    -- Skip if in combat and combat cleanup is disabled
    if self.state.inCombat and self.config.combatCleanupDisabled then
        return
    end
    
    -- Check absolute threshold
    local absoluteThresholdExceeded = currentMemory >= self.config.memoryThreshold
    
    -- Check relative threshold (% increase from baseline)
    local relativeThresholdExceeded = false
    if self.state.baselineMemory > 0 then
        local percentIncrease = (currentMemory - self.state.baselineMemory) / self.state.baselineMemory
        relativeThresholdExceeded = percentIncrease >= self.config.memoryThresholdRelative
    end
    
    -- Trigger cleanup if either threshold is exceeded
    if absoluteThresholdExceeded or relativeThresholdExceeded then
        local currentTime = GetTime()
        
        -- Perform deep cleanup if we haven't done one recently
        if (currentTime - self.state.lastDeepCleanupTime) >= self.config.deepCleanupIdleThreshold then
            self:PerformDeepCleanup()
            self.state.lastDeepCleanupTime = currentTime
        else
            self:PerformLightCleanup()
        end
        
        self.state.lastCleanupTime = currentTime
    end
end

-- Perform light cleanup (non-aggressive)
function ResourceCleanup:PerformLightCleanup()
    if self.config.debugMode then

    end
    
    -- Track memory before cleanup
    local memoryBefore = self:GetCurrentMemoryUsage()
    
    -- Clean target resources
    self:CleanTextureCache(false) -- false = not aggressive
    self:CleanWeakReferences(false)
    self:TrimTextTables(false)
    self:TrimObjectPools(false)
    
    -- Notify modules for light cleanup
    self:NotifyModulesForCleanup(false)
    
    -- Run garbage collector once
    collectgarbage("collect")
    
    -- Track stats
    self.state.cleanupStats.lightCleanupCount = self.state.cleanupStats.lightCleanupCount + 1
    
    -- Track memory savings
    local memoryAfter = self:GetCurrentMemoryUsage()
    local memorySaved = max(0, memoryBefore - memoryAfter)
    
    self.state.cleanupStats.lastCleanupMemorySaved = memorySaved
    self.state.cleanupStats.memoryCleanedTotal = self.state.cleanupStats.memoryCleanedTotal + memorySaved
    
    -- Update average
    local totalCleanups = self.state.cleanupStats.lightCleanupCount + self.state.cleanupStats.deepCleanupCount
    if totalCleanups > 0 then
        self.state.cleanupStats.averageMemorySaved = self.state.cleanupStats.memoryCleanedTotal / totalCleanups
    end
    
    if self.config.debugMode then

    end
end

-- Perform deep cleanup (aggressive)
function ResourceCleanup:PerformDeepCleanup()
    if self.config.debugMode then

    end
    
    -- Track memory before cleanup
    local memoryBefore = self:GetCurrentMemoryUsage()
    
    -- Aggressively clean all caches
    self:CleanTextureCache(true) -- true = aggressive
    self:CleanFontCache(true)
    self:CleanSoundCache(true)
    self:CleanWeakReferences(true)
    self:TrimTextTables(true)
    self:TrimObjectPools(true)
    
    -- Notify modules for deep cleanup
    self:NotifyModulesForCleanup(true)
    
    -- Run garbage collector multiple times
    collectgarbage("collect")
    C_Timer.After(0.5, function() collectgarbage("collect") end)
    
    -- Track stats
    self.state.cleanupStats.deepCleanupCount = self.state.cleanupStats.deepCleanupCount + 1
    
    -- Track memory savings
    local memoryAfter = self:GetCurrentMemoryUsage()
    local memorySaved = max(0, memoryBefore - memoryAfter)
    
    self.state.cleanupStats.lastCleanupMemorySaved = memorySaved
    self.state.cleanupStats.memoryCleanedTotal = self.state.cleanupStats.memoryCleanedTotal + memorySaved
    
    -- Update average
    local totalCleanups = self.state.cleanupStats.lightCleanupCount + self.state.cleanupStats.deepCleanupCount
    if totalCleanups > 0 then
        self.state.cleanupStats.averageMemorySaved = self.state.cleanupStats.memoryCleanedTotal / totalCleanups
    end
    
    if self.config.debugMode then

    end
end

-- Clean texture cache
function ResourceCleanup:CleanTextureCache(aggressive)
    if not VUI.TextureCache then return end
    
    local textures = VUI.TextureCache
    local textureUsage = VUI.TextureUsageCount or {}
    local currentCount = 0
    local cleanedCount = 0
    
    -- Count current textures
    for _ in pairs(textures) do
        currentCount = currentCount + 1
    end
    
    self.state.cacheStats.textureCount = currentCount
    
    -- Determine how many to clean
    local maxTextures = self.config.maxTextures
    local targetCleanCount = aggressive and floor(currentCount * 0.5) or max(0, currentCount - maxTextures)
    
    if targetCleanCount <= 0 then
        return
    end
    
    -- Build a list of textures with their usage count
    local textureList = {}
    for texturePath in pairs(textures) do
        tinsert(textureList, {
            path = texturePath,
            usage = textureUsage[texturePath] or 0
        })
    end
    
    -- Sort by usage (least used first)
    table.sort(textureList, function(a, b)
        return a.usage < b.usage
    end)
    
    -- Remove least used textures
    for i = 1, min(targetCleanCount, #textureList) do
        local texturePath = textureList[i].path
        textures[texturePath] = nil
        textureUsage[texturePath] = nil
        cleanedCount = cleanedCount + 1
    end
    
    self.state.cleanupStats.texturesCleaned = self.state.cleanupStats.texturesCleaned + cleanedCount
    
    if self.config.debugMode then

    end
end

-- Clean font cache
function ResourceCleanup:CleanFontCache(aggressive)
    if not VUI.FontCache then return end
    
    local fonts = VUI.FontCache
    local fontUsage = VUI.FontUsageCount or {}
    local currentCount = 0
    local cleanedCount = 0
    
    -- Count current fonts
    for _ in pairs(fonts) do
        currentCount = currentCount + 1
    end
    
    self.state.cacheStats.fontCount = currentCount
    
    -- Determine how many to clean
    local maxFonts = self.config.maxFonts
    local targetCleanCount = aggressive and floor(currentCount * 0.5) or max(0, currentCount - maxFonts)
    
    if targetCleanCount <= 0 then
        return
    end
    
    -- Build a list of fonts with their usage count
    local fontList = {}
    for fontPath in pairs(fonts) do
        tinsert(fontList, {
            path = fontPath,
            usage = fontUsage[fontPath] or 0
        })
    end
    
    -- Sort by usage (least used first)
    table.sort(fontList, function(a, b)
        return a.usage < b.usage
    end)
    
    -- Remove least used fonts
    for i = 1, min(targetCleanCount, #fontList) do
        local fontPath = fontList[i].path
        fonts[fontPath] = nil
        fontUsage[fontPath] = nil
        cleanedCount = cleanedCount + 1
    end
    
    self.state.cleanupStats.fontsCleaned = self.state.cleanupStats.fontsCleaned + cleanedCount
    
    if self.config.debugMode then

    end
end

-- Clean sound cache
function ResourceCleanup:CleanSoundCache(aggressive)
    if not VUI.SoundCache then return end
    
    local sounds = VUI.SoundCache
    local soundUsage = VUI.SoundUsageCount or {}
    local currentCount = 0
    local cleanedCount = 0
    
    -- Count current sounds
    for _ in pairs(sounds) do
        currentCount = currentCount + 1
    end
    
    self.state.cacheStats.soundCount = currentCount
    
    -- Determine how many to clean
    local maxSounds = self.config.maxSounds
    local targetCleanCount = aggressive and floor(currentCount * 0.7) or max(0, currentCount - maxSounds)
    
    if targetCleanCount <= 0 then
        return
    end
    
    -- Build a list of sounds with their usage count
    local soundList = {}
    for soundPath in pairs(sounds) do
        tinsert(soundList, {
            path = soundPath,
            usage = soundUsage[soundPath] or 0
        })
    end
    
    -- Sort by usage (least used first)
    table.sort(soundList, function(a, b)
        return a.usage < b.usage
    end)
    
    -- Remove least used sounds
    for i = 1, min(targetCleanCount, #soundList) do
        local soundPath = soundList[i].path
        sounds[soundPath] = nil
        soundUsage[soundPath] = nil
        cleanedCount = cleanedCount + 1
    end
    
    self.state.cleanupStats.soundsCleaned = self.state.cleanupStats.soundsCleaned + cleanedCount
    
    if self.config.debugMode then

    end
end

-- Clean weak references
function ResourceCleanup:CleanWeakReferences(aggressive)
    if not VUI.WeakReferences then return end
    
    local weakRefs = VUI.WeakReferences
    local cleanedCount = 0
    local currentCount = 0
    
    -- Count and clean in one pass
    for key, value in pairs(weakRefs) do
        currentCount = currentCount + 1
        
        -- Check if reference is valid
        if value == nil or (type(value) == "table" and next(value) == nil) then
            weakRefs[key] = nil
            cleanedCount = cleanedCount + 1
        end
    end
    
    -- In aggressive mode, also wipe tables with just one entry
    if aggressive then
        for key, value in pairs(weakRefs) do
            if type(value) == "table" then
                local count = 0
                for _ in pairs(value) do
                    count = count + 1
                    if count > 1 then break end
                end
                
                if count <= 1 then
                    weakRefs[key] = nil
                    cleanedCount = cleanedCount + 1
                end
            end
        end
    end
    
    self.state.cleanupStats.weakReferencesCleaned = self.state.cleanupStats.weakReferencesCleaned + cleanedCount
    
    if self.config.debugMode and cleanedCount > 0 then

    end
end

-- Trim text tables
function ResourceCleanup:TrimTextTables(aggressive)
    if not VUI.TextTables then return end
    
    local textTables = VUI.TextTables
    local cleanedCount = 0
    local currentCount = 0
    
    -- Count current tables
    for _ in pairs(textTables) do
        currentCount = currentCount + 1
    end
    
    self.state.cacheStats.stringTableCount = currentCount
    
    -- Determine how many to clean
    local maxTables = self.config.maxStringTables
    local targetCleanCount = aggressive and floor(currentCount * 0.3) or max(0, currentCount - maxTables)
    
    if targetCleanCount <= 0 and not aggressive then
        return
    end
    
    -- In aggressive mode, we also trim large tables
    if aggressive then
        for key, tbl in pairs(textTables) do
            if type(tbl) == "table" and #tbl > 100 then
                -- Trim to half size for very large tables
                for i = 1, floor(#tbl / 2) do
                    tremove(tbl, 1)
                    cleanedCount = cleanedCount + 1
                end
            end
        end
    end
    
    -- Build a list of tables
    local tableList = {}
    for tableName, tbl in pairs(textTables) do
        local tableSize = 0
        if type(tbl) == "table" then
            for _ in pairs(tbl) do
                tableSize = tableSize + 1
            end
        end
        
        tinsert(tableList, {
            name = tableName,
            size = tableSize
        })
    end
    
    -- Sort by size (smallest first - we keep big ones that have more data)
    table.sort(tableList, function(a, b)
        return a.size < b.size
    end)
    
    -- Remove smallest tables up to target count
    for i = 1, min(targetCleanCount, #tableList) do
        local tableName = tableList[i].name
        textTables[tableName] = nil
        cleanedCount = cleanedCount + 1
    end
    
    self.state.cleanupStats.tablesCleaned = self.state.cleanupStats.tablesCleaned + cleanedCount
    
    if self.config.debugMode and cleanedCount > 0 then

    end
end

-- Trim object pools
function ResourceCleanup:TrimObjectPools(aggressive)
    if not VUI.ObjectPools then return end
    
    local objectPools = VUI.ObjectPools
    local cleanedCount = 0
    local currentCount = 0
    
    -- Count current pools
    for poolName, pool in pairs(objectPools) do
        if type(pool) == "table" and pool.numInactive then
            currentCount = currentCount + pool.numInactive
        end
    end
    
    self.state.cacheStats.objectPoolCount = currentCount
    
    -- Process each pool
    for poolName, pool in pairs(objectPools) do
        if type(pool) == "table" and pool.numInactive and pool.DestroyInactive then
            local inactiveObjects = pool.numInactive or 0
            local targetCount = aggressive and floor(inactiveObjects * 0.7) or floor(inactiveObjects * 0.3)
            
            if targetCount > 0 then
                -- Use the pool's own method to destroy inactive objects
                if pool.DestroyInactive(pool, targetCount) then
                    cleanedCount = cleanedCount + targetCount
                end
            end
        end
    end
    
    self.state.cleanupStats.totalFramesReclaimed = self.state.cleanupStats.totalFramesReclaimed + cleanedCount
    
    if self.config.debugMode and cleanedCount > 0 then

    end
end

-- Notify registered modules to perform their cleanup
function ResourceCleanup:NotifyModulesForCleanup(deepCleanup)
    for moduleName, cleanupFunc in pairs(self.state.registeredModules) do
        -- Skip exempt modules if this is an automatic cleanup
        if not self.state.exemptModules[moduleName] then
            -- Call the module's cleanup function
            local success, result = pcall(cleanupFunc, deepCleanup)
            
            -- Skip debug output in production
        end
    end
end

-- Handle entering combat
function ResourceCleanup:OnEnteringCombat()
    -- Nothing special to do here, just update state (already done in message handler)
end

-- Handle leaving combat
function ResourceCleanup:OnLeavingCombat()
    -- Consider a light cleanup after an extended combat session
    local combatDuration = GetTime() - self.state.exitedCombatTime
    
    if combatDuration > 120 then -- 2+ minute combat
        -- Schedule a cleanup after the buffer period
        C_Timer.After(self.config.postCombatBufferTime + 1, function()
            if not self.state.inCombat then -- Double check we're still out of combat
                self:PerformLightCleanup()
            end
        end)
    end
end

-- Handle zone changes
function ResourceCleanup:OnZoneChange()
    -- Clean memory when changing zones as this is a good opportunity
    -- Schedule cleanup to happen after the zone change completes
    C_Timer.After(2, function()
        if not self.state.inCombat then
            self:PerformLightCleanup()
        end
    end)
end

-- Perform periodic garbage collection
function ResourceCleanup:PerformPeriodicGC()
    local currentTime = GetTime()
    
    -- Skip in combat
    if self.state.inCombat then return end
    
    -- Skip if we've done a cleanup recently
    if (currentTime - self.state.lastCleanupTime) < 60 then return end
    
    -- Do a collect step
    collectgarbage("step", 100)
    
    self.state.lastGCTime = currentTime
end

-- Update memory usage samples
function ResourceCleanup:UpdateMemorySamples()
    UpdateAddOnMemoryUsage()
    local memory = GetAddOnMemoryUsage(addonName) / 1024  -- Convert to MB
    
    -- Add to history, keeping last 5 samples
    tinsert(self.state.memorySamples, memory)
    if #self.state.memorySamples > 5 then
        tremove(self.state.memorySamples, 1)
    end
end

-- Get current memory usage
function ResourceCleanup:GetCurrentMemoryUsage()
    UpdateAddOnMemoryUsage()
    return GetAddOnMemoryUsage(addonName) / 1024  -- Convert to MB
end

-- Register a module for cleanup
function ResourceCleanup:RegisterModule(moduleName, cleanupFunc)
    if not moduleName or type(cleanupFunc) ~= "function" then
        return false
    end
    
    self.state.registeredModules[moduleName] = cleanupFunc
    
    -- Skip debug output in production
    
    return true
end

-- Set a module as exempt from automatic cleanup
function ResourceCleanup:SetModuleExempt(moduleName, exempt)
    if not moduleName then return false end
    
    self.state.exemptModules[moduleName] = exempt and true or nil
    
    -- Skip debug output in production
    
    return true
end

-- Get cleanup statistics
function ResourceCleanup:GetStats()
    return self.state.cleanupStats
end

-- Get current cache statistics
function ResourceCleanup:GetCacheStats()
    return self.state.cacheStats
end

-- Reset statistics
function ResourceCleanup:ResetStats()
    self.state.cleanupStats = {
        lightCleanupCount = 0,
        deepCleanupCount = 0,
        memoryCleanedTotal = 0,
        lastCleanupMemorySaved = 0,
        averageMemorySaved = 0,
        totalFramesReclaimed = 0,
        texturesCleaned = 0,
        fontsCleaned = 0,
        soundsCleaned = 0,
        tablesCleaned = 0,
        weakReferencesCleaned = 0
    }
    
    return true
end

-- Module export for VUI
VUI.ResourceCleanup = ResourceCleanup

-- Initialize on VUI ready
if VUI.isInitialized then
    ResourceCleanup:Initialize()
else
    -- Instead of using RegisterCallback, we'll hook into OnInitialize
    local originalOnInitialize = VUI.OnInitialize
    VUI.OnInitialize = function(self, ...)
        -- Call the original function first
        if originalOnInitialize then
            originalOnInitialize(self, ...)
        end
        
        -- Initialize resource cleanup after VUI is initialized
        if ResourceCleanup.Initialize then
            ResourceCleanup:Initialize()
        end
    end
end

-- Return the module
return ResourceCleanup