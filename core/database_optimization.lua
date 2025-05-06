-- ===================================================================================================================
-- Database Access Optimization System
-- Improves performance by implementing intelligent caching, batch processing, and query optimization
-- ===================================================================================================================

local addonName, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end

-- Create module
local DBOpt = VUI:NewModule("DatabaseOptimization", "AceEvent-3.0", "AceTimer-3.0")

-- Constants
local CACHE_CLEANUP_INTERVAL = 60 -- Seconds between cache cleanup operations
local BATCH_SIZE = 5 -- Number of operations to batch together
local THROTTLE_PERIOD = 0.2 -- Seconds to wait for batching similar operations
local DEBUG_MODE = false -- Always false in production release

-- Initialization
function DBOpt:OnInitialize()
    -- Initialize state
    self.state = {
        -- Main data cache - structure: {key = {value = data, timestamp = time, accessCount = n}}
        dataCache = {},
        
        -- Batch processing queues
        writeQueue = {},
        
        -- Usage statistics - disabled in production release
        stats = {
            cacheHits = 0,
            cacheMisses = 0,
            batchedWrites = 0,
            directWrites = 0,
            cacheSize = 0,
            cacheCleaned = 0,
            moduleAccess = {},
            enabled = false -- Statistics tracking disabled in production
        },
        
        -- Optimization settings
        cacheEnabled = true,
        batchingEnabled = true,
        
        -- Track database writing operations
        pendingWriteTimer = nil,
        
        -- Excluded paths that should never be cached
        excludedPaths = {
            -- Add critical paths that should never be cached
            ["combat"] = true,
            ["position"] = true,
            ["temp"] = true
        },
        
        -- Module database paths
        moduleDatabasePaths = {},
        
        -- Last accessed paths for efficient retrieval
        lastAccessedPaths = {},
        
        -- Cache size limit by module (in entries)
        moduleCacheLimits = {}
    }
    
    -- Create statistics trackers for each module
    for _, moduleName in ipairs(VUI.modules) do
        self.state.stats.moduleAccess[moduleName] = {
            reads = 0,
            writes = 0,
            cached = 0
        }
    end
    
    -- Default configuration
    self.config = {
        enableCaching = true,
        enableBatching = true,
        cacheLifetime = 300, -- 5 minutes
        maxCacheEntries = 1000,
        batchDelay = 0.2,
        debugMode = false,
        cacheByModule = {
            -- Module-specific cache limits
            BuffOverlay = 100,
            TrufiGCD = 50,
            OmniCD = 200,
            MultiNotification = 100
        }
    }
    
    -- Initialize module cache limits
    for module, limit in pairs(self.config.cacheByModule) do
        self.state.moduleCacheLimits[module] = limit
    end
    
    -- Register with Resource Cleanup system if available
    if VUI.ResourceCleanup then
        VUI.ResourceCleanup:RegisterModule("DatabaseOptimization", function() self:PerformDeepCleanup() end)
    end
    
    -- Start periodic cache cleanup
    self:ScheduleRepeatingTimer("CleanupCache", CACHE_CLEANUP_INTERVAL)
    
    -- Register events
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_LEAVING_WORLD")
    self:RegisterEvent("PLAYER_REGEN_DISABLED") -- Combat start
    self:RegisterEvent("PLAYER_REGEN_ENABLED") -- Combat end
    
    -- Debug message
    if DEBUG_MODE then
        VUI:Debug("Database Optimization System initialized")
    end
end

-- Process event callbacks
function DBOpt:PLAYER_ENTERING_WORLD()
    -- Preload frequently accessed settings
    self:PreloadFrequentSettings()
end

function DBOpt:PLAYER_LEAVING_WORLD()
    -- Process any pending writes immediately
    self:ProcessWriteQueue(true)
    -- Perform cleanup to save memory
    self:CleanupCache(true)
end

function DBOpt:PLAYER_REGEN_DISABLED()
    -- Combat started - process any pending writes
    self:ProcessWriteQueue(true)
    -- Enable aggressive caching for combat
    self.state.inCombat = true
end

function DBOpt:PLAYER_REGEN_ENABLED()
    -- Combat ended
    self.state.inCombat = false
    -- Schedule a cleanup for a few seconds after combat
    self:ScheduleTimer("CleanupCache", 5)
end

-- Preload frequently accessed settings
function DBOpt:PreloadFrequentSettings()
    -- Identify and preload commonly accessed settings
    local commonSettings = {
        -- Core settings
        {db = VUI.db, path = "profile.general.scale"},
        {db = VUI.db, path = "profile.theme"},
        
        -- Module settings that are accessed frequently
        {db = VUI.BuffOverlay and VUI.BuffOverlay.db, path = "profile.general"},
        {db = VUI.MultiNotification and VUI.MultiNotification.db, path = "profile.general"}
    }
    
    -- Preload each setting into cache
    for _, setting in ipairs(commonSettings) do
        if setting.db then
            local value = self:GetNestedValue(setting.db, setting.path)
            if value ~= nil then
                self:CacheValue(setting.db, setting.path, value)
                if DEBUG_MODE then
                    VUI:Debug("Preloaded: " .. setting.path)
                end
            end
        end
    end
end

-- Cache a database value
function DBOpt:CacheValue(db, path, value)
    if not self.state.cacheEnabled or not db or not path then
        return
    end
    
    -- Check if path is in excluded list
    for excluded in pairs(self.state.excludedPaths) do
        if string.find(path, excluded) then
            return
        end
    end
    
    -- Generate cache key
    local cacheKey = self:GenerateCacheKey(db, path)
    
    -- Store in cache
    self.state.dataCache[cacheKey] = {
        value = value,
        timestamp = GetTime(),
        accessCount = 1
    }
    
    -- Update cache size
    self.state.stats.cacheSize = self.state.stats.cacheSize + 1
    
    -- Check if we need to clean up the cache
    if self.state.stats.cacheSize > self.config.maxCacheEntries then
        self:CleanupCache(false) -- Non-forced cleanup
    end
end

-- Get a value from the cache
function DBOpt:GetCachedValue(db, path)
    if not self.state.cacheEnabled or not db or not path then
        return nil, false
    end
    
    -- Generate cache key
    local cacheKey = self:GenerateCacheKey(db, path)
    
    -- Check if value exists in cache
    local entry = self.state.dataCache[cacheKey]
    if entry then
        -- Update access count and timestamp
        entry.accessCount = entry.accessCount + 1
        entry.timestamp = GetTime()
        
        -- Update stats
        self.state.stats.cacheHits = self.state.stats.cacheHits + 1
        
        -- Track module access if applicable
        self:TrackModuleAccess(db, "cached")
        
        return entry.value, true
    end
    
    -- Update stats
    self.state.stats.cacheMisses = self.state.stats.cacheMisses + 1
    
    return nil, false
end

-- Queue a database write operation
function DBOpt:QueueDatabaseWrite(db, path, value, immediate)
    if not db or not path then
        return false
    end
    
    -- Track module access if applicable
    self:TrackModuleAccess(db, "writes")
    
    -- Check if batching is disabled or immediate write requested
    if immediate or not self.state.batchingEnabled or self.state.inCombat then
        -- Perform immediate write
        self:SetNestedValue(db, path, value)
        
        -- Update cache
        self:CacheValue(db, path, value)
        
        -- Update stats
        self.state.stats.directWrites = self.state.stats.directWrites + 1
        
        return true
    end
    
    -- Add to write queue
    table.insert(self.state.writeQueue, {
        db = db,
        path = path,
        value = value,
        timestamp = GetTime()
    })
    
    -- Schedule processing if not already scheduled
    if not self.state.pendingWriteTimer then
        self.state.pendingWriteTimer = self:ScheduleTimer("ProcessWriteQueue", THROTTLE_PERIOD)
    end
    
    return true
end

-- Process the write queue
function DBOpt:ProcessWriteQueue(force)
    if self.state.pendingWriteTimer then
        self:CancelTimer(self.state.pendingWriteTimer)
        self.state.pendingWriteTimer = nil
    end
    
    -- Process writes in batch
    local count = 0
    local currentTime = GetTime()
    
    -- Group similar operations
    local operations = {}
    
    -- Group by database and path
    for _, op in ipairs(self.state.writeQueue) do
        local key = tostring(op.db) .. ":" .. op.path
        operations[key] = op
    end
    
    -- Apply grouped operations
    for _, op in pairs(operations) do
        -- Apply the write
        self:SetNestedValue(op.db, op.path, op.value)
        
        -- Update cache
        self:CacheValue(op.db, op.path, op.value)
        
        count = count + 1
    end
    
    -- Update stats
    self.state.stats.batchedWrites = self.state.stats.batchedWrites + count
    
    -- Clear the queue
    wipe(self.state.writeQueue)
    
    if DEBUG_MODE and count > 0 then
        VUI:Debug("Processed " .. count .. " database writes")
    end
end

-- Clean up the cache
function DBOpt:CleanupCache(force)
    local currentTime = GetTime()
    local cleanupCount = 0
    local cacheLifetime = self.config.cacheLifetime
    
    -- Make cleanup more aggressive during combat
    if self.state.inCombat then
        cacheLifetime = cacheLifetime / 2
    end
    
    -- Temporary table for entries to remove
    local toRemove = {}
    
    -- Identify entries to remove
    for key, entry in pairs(self.state.dataCache) do
        -- Remove if too old or force cleanup
        if force or (currentTime - entry.timestamp > cacheLifetime) then
            table.insert(toRemove, key)
            cleanupCount = cleanupCount + 1
        end
    end
    
    -- Remove identified entries
    for _, key in ipairs(toRemove) do
        self.state.dataCache[key] = nil
    end
    
    -- Update stats
    self.state.stats.cacheSize = self.state.stats.cacheSize - cleanupCount
    self.state.stats.cacheCleaned = self.state.stats.cacheCleaned + cleanupCount
    
    if DEBUG_MODE and cleanupCount > 0 then
        VUI:Debug("Cleaned " .. cleanupCount .. " cache entries")
    end
end

-- Perform deep cleanup (called by resource cleanup system)
function DBOpt:PerformDeepCleanup()
    -- Force a complete cache cleanup
    self:CleanupCache(true)
    
    -- Process any pending writes
    self:ProcessWriteQueue(true)
    
    -- Clear last accessed paths
    wipe(self.state.lastAccessedPaths)
    
    return true
end

-- Generate a cache key for a db and path
function DBOpt:GenerateCacheKey(db, path)
    -- Create a unique identifier for this database and path
    return tostring(db) .. ":" .. path
end

-- Helper to get a nested value from a table using a dot-separated path
function DBOpt:GetNestedValue(tbl, path)
    if not tbl or not path then return nil end
    
    local value = tbl
    for segment in string.gmatch(path, "[^%.]+") do
        if type(value) ~= "table" then
            return nil
        end
        value = value[segment]
        if value == nil then
            return nil
        end
    end
    
    return value
end

-- Helper to set a nested value in a table using a dot-separated path
function DBOpt:SetNestedValue(tbl, path, value)
    if not tbl or not path then return false end
    
    local segments = {}
    for segment in string.gmatch(path, "[^%.]+") do
        table.insert(segments, segment)
    end
    
    local current = tbl
    for i = 1, #segments - 1 do
        local segment = segments[i]
        if type(current[segment]) ~= "table" then
            current[segment] = {}
        end
        current = current[segment]
    end
    
    current[segments[#segments]] = value
    return true
end

-- Track access statistics by module
function DBOpt:TrackModuleAccess(db, accessType)
    -- Try to determine which module this DB belongs to
    local moduleName = nil
    for name, moduleDB in pairs(self.state.moduleDatabasePaths) do
        if db == moduleDB then
            moduleName = name
            break
        end
    end
    
    -- If we found a module, update its stats
    if moduleName and self.state.stats.moduleAccess[moduleName] then
        self.state.stats.moduleAccess[moduleName][accessType] = 
            (self.state.stats.moduleAccess[moduleName][accessType] or 0) + 1
    end
end

-- Register a module database
function DBOpt:RegisterModuleDatabase(moduleName, db)
    if not moduleName or not db then
        return false
    end
    
    self.state.moduleDatabasePaths[moduleName] = db
    
    -- Initialize stats if needed
    if not self.state.stats.moduleAccess[moduleName] then
        self.state.stats.moduleAccess[moduleName] = {
            reads = 0,
            writes = 0,
            cached = 0
        }
    end
    
    if DEBUG_MODE then
        VUI:Debug(string.format("Registered %s module database", moduleName))
    end
    
    return true
end

-- Get database access statistics
function DBOpt:GetStats()
    -- Combine all stats
    local stats = {
        cacheHits = self.state.stats.cacheHits,
        cacheMisses = self.state.stats.cacheMisses,
        hitRate = self.state.stats.cacheHits / math.max(1, (self.state.stats.cacheHits + self.state.stats.cacheMisses)),
        cacheSize = self.state.stats.cacheSize,
        batchedWrites = self.state.stats.batchedWrites,
        directWrites = self.state.stats.directWrites,
        moduleStats = {}
    }
    
    -- Add module-specific stats
    for module, data in pairs(self.state.stats.moduleAccess) do
        stats.moduleStats[module] = {
            reads = data.reads or 0,
            writes = data.writes or 0,
            cached = data.cached or 0,
            cacheHitRate = (data.cached or 0) / math.max(1, (data.reads or 0))
        }
    end
    
    return stats
end

-- Add a path to the exclusion list
function DBOpt:AddExcludedPath(path)
    if not path then return false end
    
    self.state.excludedPaths[path] = true
    return true
end

-- Remove a path from the exclusion list
function DBOpt:RemoveExcludedPath(path)
    if not path then return false end
    
    self.state.excludedPaths[path] = nil
    return true
end

-- Set module-specific cache limit
function DBOpt:SetModuleCacheLimit(moduleName, limit)
    if not moduleName or not limit or type(limit) ~= "number" then
        return false
    end
    
    self.state.moduleCacheLimits[moduleName] = limit
    return true
end

-- Public API - Optimized database access functions

-- Get a value with caching
function DBOpt:Get(db, path, defaultValue)
    if not db or not path then
        return defaultValue
    end
    
    -- Track access
    self:TrackModuleAccess(db, "reads")
    
    -- Check cache first
    local cachedValue, found = self:GetCachedValue(db, path)
    if found then
        return cachedValue
    end
    
    -- Cache miss - get from database
    local value = self:GetNestedValue(db, path)
    
    -- If value is nil and default provided, use default
    if value == nil and defaultValue ~= nil then
        value = defaultValue
    end
    
    -- Cache the result if not nil
    if value ~= nil then
        self:CacheValue(db, path, value)
    end
    
    return value
end

-- Set a value with optional batching
function DBOpt:Set(db, path, value, immediate)
    return self:QueueDatabaseWrite(db, path, value, immediate)
end

-- Export module
VUI.DatabaseOptimization = DBOpt