local _, VUI = ...

-- Database Optimizer Module
VUI.DBOptimizer = VUI.DBOptimizer or {}
local DBOptimizer = VUI.DBOptimizer

-- Cache for database values to reduce direct access
DBOptimizer.cache = {}

-- Statistics tracking
DBOptimizer.stats = {
    cacheHits = 0,
    cacheMisses = 0,
    cacheSize = 0,
    cacheMaxSize = 0,
    batchOperations = 0,
    directAccesses = 0,
    timeSaved = 0,
    lastCacheClean = GetTime()
}

-- Configuration defaults
DBOptimizer.settings = {
    enabled = true,
    cacheSize = 500,               -- Maximum number of entries to cache
    cacheTTL = 300,                -- Time-to-live for cache entries in seconds
    cleanupInterval = 120,         -- Cache cleanup interval in seconds
    batchSize = 10,                -- Maximum batch size for batch operations
    combatCaching = true,          -- Enhanced caching during combat
    trackStatistics = true,        -- Whether to track performance statistics
    excludedPaths = {},            -- Paths to exclude from caching
    logLevel = 1,                  -- 0: Off, 1: Errors, 2: Warnings, 3: Info, 4: Debug
    profilePerformance = false     -- Whether to profile performance
}

-- Constants
local MAX_CACHE_SIZE = 1000        -- Hard limit on cache size
local MIN_CLEANUP_INTERVAL = 30    -- Minimum cleanup interval in seconds
local DEFAULT_CACHE_TTL = 300      -- Default time-to-live for cache entries
local PERFORMANCE_TIMER_THRESHOLD = 0.001  -- Threshold for logging slow operations

-- Initialize the module
function DBOptimizer:Initialize()
    -- Load settings from profile
    self:LoadSettings()
    
    -- Register cleanup timer
    self:RegisterCleanupTimer()
    
    -- Register for combat events to adjust caching behavior
    self:RegisterCombatEvents()
    
    -- Log initialization
    self:Log(3, "Database Optimizer initialized")
end

-- Load settings from saved variables
function DBOptimizer:LoadSettings()
    if VUI.db and VUI.db.profile and VUI.db.profile.modules and VUI.db.profile.modules.dboptimizer then
        -- Merge saved settings with defaults
        for key, value in pairs(VUI.db.profile.modules.dboptimizer) do
            self.settings[key] = value
        end
    else
        -- Initialize settings in DB if they don't exist
        if VUI.db and VUI.db.profile then
            VUI.db.profile.modules = VUI.db.profile.modules or {}
            VUI.db.profile.modules.dboptimizer = CopyTable(self.settings)
        end
    end
    
    -- Validate settings
    self:ValidateSettings()
end

-- Validate settings to ensure they are within acceptable ranges
function DBOptimizer:ValidateSettings()
    -- Ensure cache size is reasonable
    if self.settings.cacheSize > MAX_CACHE_SIZE then
        self.settings.cacheSize = MAX_CACHE_SIZE
    elseif self.settings.cacheSize < 10 then
        self.settings.cacheSize = 10
    end
    
    -- Ensure cleanup interval is reasonable
    if self.settings.cleanupInterval < MIN_CLEANUP_INTERVAL then
        self.settings.cleanupInterval = MIN_CLEANUP_INTERVAL
    end
    
    -- Update max cache size stat
    self.stats.cacheMaxSize = self.settings.cacheSize
end

-- Register timer for cache cleanup
function DBOptimizer:RegisterCleanupTimer()
    if self.cleanupTimer then
        self.cleanupTimer:Cancel()
        self.cleanupTimer = nil
    end
    
    -- Create cleanup timer
    self.cleanupTimer = C_Timer.NewTicker(self.settings.cleanupInterval, function()
        if self.settings.enabled then
            self:CleanupCache()
        end
    end)
end

-- Register for combat events to adjust caching behavior
function DBOptimizer:RegisterCombatEvents()
    -- Create frame for combat events if needed
    if not self.eventFrame then
        self.eventFrame = CreateFrame("Frame")
        self.eventFrame:SetScript("OnEvent", function(_, event, ...)
            if event == "PLAYER_REGEN_DISABLED" then
                -- Entering combat, enhance caching if enabled
                if self.settings.combatCaching and self.settings.enabled then
                    self:EnhanceCachingForCombat()
                end
            elseif event == "PLAYER_REGEN_ENABLED" then
                -- Exiting combat, restore normal caching
                if self.settings.combatCaching and self.settings.enabled then
                    self:RestoreNormalCaching()
                    -- Perform cleanup after combat ends
                    self:CleanupCache()
                end
            end
        end)
    end
    
    -- Register combat events
    self.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    self.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
end

-- Enhance caching for combat (more aggressive caching)
function DBOptimizer:EnhanceCachingForCombat()
    -- Store original settings
    self.originalSettings = {
        cacheTTL = self.settings.cacheTTL,
        cleanupInterval = self.settings.cleanupInterval
    }
    
    -- Increase TTL for combat to reduce cache misses
    self.settings.cacheTTL = self.settings.cacheTTL * 2
    
    -- Delay cleanup during combat
    self.settings.cleanupInterval = self.settings.cleanupInterval * 2
    
    -- Update cleanup timer
    self:RegisterCleanupTimer()
    
    self:Log(3, "Enhanced caching for combat")
end

-- Restore normal caching after combat
function DBOptimizer:RestoreNormalCaching()
    -- Restore original settings if they exist
    if self.originalSettings then
        self.settings.cacheTTL = self.originalSettings.cacheTTL
        self.settings.cleanupInterval = self.originalSettings.cleanupInterval
        
        -- Update cleanup timer
        self:RegisterCleanupTimer()
        
        self.originalSettings = nil
    end
    
    self:Log(3, "Restored normal caching after combat")
end

-- Generate a cache key from a table path
function DBOptimizer:GenerateCacheKey(tbl, path)
    if type(tbl) ~= "table" then
        return nil
    end
    
    -- Convert table to string representation for key generation
    local tblString = tostring(tbl)
    local key = tblString .. ":" .. tostring(path)
    
    return key
end

-- Check if a path should be excluded from caching
function DBOptimizer:IsExcludedPath(path)
    for _, excludedPath in ipairs(self.settings.excludedPaths) do
        if path:match(excludedPath) then
            return true
        end
    end
    
    return false
end

-- Get a value from the cache
function DBOptimizer:GetFromCache(tbl, path)
    if not self.settings.enabled then
        return nil, false
    end
    
    -- Generate cache key
    local key = self:GenerateCacheKey(tbl, path)
    if not key then
        return nil, false
    end
    
    -- Check if path should be excluded
    if self:IsExcludedPath(path) then
        return nil, false
    end
    
    -- Check cache
    local cacheEntry = self.cache[key]
    if cacheEntry then
        -- Check if entry has expired
        if GetTime() - cacheEntry.timestamp > self.settings.cacheTTL then
            -- Cache entry has expired
            self.cache[key] = nil
            self.stats.cacheMisses = self.stats.cacheMisses + 1
            self:Log(4, "Cache miss (expired): " .. key)
            return nil, false
        end
        
        -- Cache hit
        self.stats.cacheHits = self.stats.cacheHits + 1
        self:Log(4, "Cache hit: " .. key)
        
        -- Return the cached value
        return cacheEntry.value, true
    end
    
    -- Cache miss
    self.stats.cacheMisses = self.stats.cacheMisses + 1
    self:Log(4, "Cache miss: " .. key)
    return nil, false
end

-- Add a value to the cache
function DBOptimizer:AddToCache(tbl, path, value)
    if not self.settings.enabled then
        return
    end
    
    -- Generate cache key
    local key = self:GenerateCacheKey(tbl, path)
    if not key then
        return
    end
    
    -- Check if path should be excluded
    if self:IsExcludedPath(path) then
        return
    end
    
    -- Check cache size
    if self.stats.cacheSize >= self.settings.cacheSize then
        -- Cache is full, clean up old entries
        self:CleanupCache(true)
        
        -- If still full after cleanup, don't add new entry
        if self.stats.cacheSize >= self.settings.cacheSize then
            self:Log(2, "Cache full, skipping new entry: " .. key)
            return
        end
    end
    
    -- Add to cache
    self.cache[key] = {
        value = value,
        timestamp = GetTime(),
        path = path
    }
    
    -- Update cache size
    self.stats.cacheSize = self.stats.cacheSize + 1
    
    self:Log(4, "Added to cache: " .. key)
end

-- Clean up expired or least recently used cache entries
function DBOptimizer:CleanupCache(forced)
    if not self.settings.enabled then
        return
    end
    
    local now = GetTime()
    local cacheSize = 0
    local expiredCount = 0
    local oldestTime = now
    local oldestKey = nil
    
    -- Update last cleanup time
    self.stats.lastCacheClean = now
    
    -- First pass: remove expired entries and count valid entries
    for key, entry in pairs(self.cache) do
        if now - entry.timestamp > self.settings.cacheTTL then
            -- Entry has expired
            self.cache[key] = nil
            expiredCount = expiredCount + 1
        else
            -- Entry is still valid
            cacheSize = cacheSize + 1
            
            -- Track oldest entry for potential removal
            if entry.timestamp < oldestTime then
                oldestTime = entry.timestamp
                oldestKey = key
            end
        end
    end
    
    -- Update cache size stat
    self.stats.cacheSize = cacheSize
    
    -- If cache is still too large, remove oldest entries
    if forced and cacheSize > self.settings.cacheSize * 0.9 and oldestKey then
        -- Remove the oldest entry
        self.cache[oldestKey] = nil
        self.stats.cacheSize = cacheSize - 1
        
        self:Log(3, "Removed oldest cache entry: " .. oldestKey)
    end
    
    self:Log(3, "Cache cleanup: removed " .. expiredCount .. " expired entries, current size: " .. self.stats.cacheSize)
end

-- Reset cache and statistics
function DBOptimizer:Reset()
    -- Clear cache
    wipe(self.cache)
    
    -- Reset statistics
    self.stats.cacheHits = 0
    self.stats.cacheMisses = 0
    self.stats.cacheSize = 0
    self.stats.batchOperations = 0
    self.stats.directAccesses = 0
    self.stats.timeSaved = 0
    self.stats.lastCacheClean = GetTime()
    
    self:Log(2, "Database optimizer reset")
end

-- Get a value from a table using a dot-separated path
function DBOptimizer:GetValue(tbl, path, useCache)
    if not self.settings.enabled then
        -- Direct access if disabled
        return self:GetValueDirect(tbl, path)
    end
    
    -- Use cache by default if not specified
    if useCache == nil then
        useCache = true
    end
    
    -- Track performance
    local startTime = nil
    if self.settings.profilePerformance then
        startTime = debugprofilestop()
    end
    
    -- Try to get from cache
    if useCache then
        local cachedValue, found = self:GetFromCache(tbl, path)
        if found then
            -- Track performance
            if startTime and self.settings.profilePerformance then
                local elapsed = debugprofilestop() - startTime
                self.stats.timeSaved = self.stats.timeSaved + elapsed
                
                if elapsed > PERFORMANCE_TIMER_THRESHOLD then
                    self:Log(4, "Cache access took " .. elapsed .. "ms for " .. path)
                end
            end
            
            return cachedValue
        end
    end
    
    -- Cache miss or cache disabled, get directly
    local value = self:GetValueDirect(tbl, path)
    
    -- Add to cache
    if useCache then
        self:AddToCache(tbl, path, value)
    end
    
    -- Track performance
    if startTime and self.settings.profilePerformance then
        local elapsed = debugprofilestop() - startTime
        
        if elapsed > PERFORMANCE_TIMER_THRESHOLD then
            self:Log(4, "Direct access took " .. elapsed .. "ms for " .. path)
        end
    end
    
    return value
end

-- Get a value directly from a table using a dot-separated path
function DBOptimizer:GetValueDirect(tbl, path)
    if type(tbl) ~= "table" then
        return nil
    end
    
    -- Track direct accesses
    self.stats.directAccesses = self.stats.directAccesses + 1
    
    -- Handle simple case
    if not path or path == "" then
        return tbl
    end
    
    -- Split path into segments
    local segments = {}
    for segment in path:gmatch("[^%.]+") do
        segments[#segments + 1] = segment
    end
    
    -- Traverse the table
    local current = tbl
    for i = 1, #segments do
        if type(current) ~= "table" then
            return nil
        end
        
        local key = segments[i]
        
        -- Handle array indices
        if key:match("^%d+$") then
            key = tonumber(key)
        end
        
        current = current[key]
        
        if current == nil then
            return nil
        end
    end
    
    return current
end

-- Set a value in a table using a dot-separated path
function DBOptimizer:SetValue(tbl, path, value)
    if type(tbl) ~= "table" then
        return false
    end
    
    -- Split path into segments
    local segments = {}
    for segment in path:gmatch("[^%.]+") do
        segments[#segments + 1] = segment
    end
    
    -- Handle empty path
    if #segments == 0 then
        return false
    end
    
    -- Traverse the table to the parent of the target
    local current = tbl
    for i = 1, #segments - 1 do
        local key = segments[i]
        
        -- Handle array indices
        if key:match("^%d+$") then
            key = tonumber(key)
        end
        
        -- Create tables as needed
        if current[key] == nil or type(current[key]) ~= "table" then
            current[key] = {}
        end
        
        current = current[key]
    end
    
    -- Set the value
    local finalKey = segments[#segments]
    
    -- Handle array indices
    if finalKey:match("^%d+$") then
        finalKey = tonumber(finalKey)
    end
    
    current[finalKey] = value
    
    -- Update cache if enabled
    if self.settings.enabled then
        -- Generate cache key
        local key = self:GenerateCacheKey(tbl, path)
        if key then
            -- Update cached value
            self.cache[key] = {
                value = value,
                timestamp = GetTime(),
                path = path
            }
            
            self:Log(4, "Updated cache for: " .. path)
        end
    end
    
    return true
end

-- Batch operations to reduce database access
function DBOptimizer:BatchOperation(operations, callback)
    if not self.settings.enabled or type(operations) ~= "table" or #operations == 0 then
        if callback and type(callback) == "function" then
            callback(false)
        end
        return false
    end
    
    -- Track batch operations
    self.stats.batchOperations = self.stats.batchOperations + 1
    
    -- Calculate batch size
    local batchSize = math.min(#operations, self.settings.batchSize)
    
    -- Track performance
    local startTime = nil
    if self.settings.profilePerformance then
        startTime = debugprofilestop()
    end
    
    -- Process operations in batches
    local currentIndex = 1
    local results = {}
    
    local processBatch = function()
        local endIndex = math.min(currentIndex + batchSize - 1, #operations)
        
        for i = currentIndex, endIndex do
            local op = operations[i]
            
            if op.type == "get" then
                results[i] = self:GetValue(op.table, op.path, op.useCache)
            elseif op.type == "set" then
                results[i] = self:SetValue(op.table, op.path, op.value)
            else
                -- Unknown operation type
                results[i] = nil
            end
        end
        
        -- Update current index
        currentIndex = endIndex + 1
        
        -- Check if there are more operations
        if currentIndex <= #operations then
            -- Process next batch on next frame for responsiveness
            C_Timer.After(0, processBatch)
        else
            -- All operations complete
            if callback and type(callback) == "function" then
                callback(true, results)
            end
            
            -- Track performance
            if startTime and self.settings.profilePerformance then
                local elapsed = debugprofilestop() - startTime
                
                if elapsed > PERFORMANCE_TIMER_THRESHOLD then
                    self:Log(3, "Batch operation took " .. elapsed .. "ms for " .. #operations .. " operations")
                end
            end
        end
    end
    
    -- Start processing
    processBatch()
    
    return true
end

-- Log message at the specified level
function DBOptimizer:Log(level, message)
    if not self.settings.logLevel or self.settings.logLevel < level then
        return
    end
    
    local levelText = "INFO"
    if level == 1 then
        levelText = "ERROR"
    elseif level == 2 then
        levelText = "WARN"
    elseif level == 4 then
        levelText = "DEBUG"
    end
    
    if VUI.Logger then
        VUI.Logger:Log("DBOptimizer", levelText, message)
    else
        print("|cFF1784D1VUI|r DBOptimizer [" .. levelText .. "]: " .. message)
    end
end

-- Get stats for display or debug
function DBOptimizer:GetStats()
    local hitRate = 0
    local totalAccesses = self.stats.cacheHits + self.stats.cacheMisses
    
    if totalAccesses > 0 then
        hitRate = self.stats.cacheHits / totalAccesses * 100
    end
    
    local stats = {
        enabled = self.settings.enabled,
        cacheHits = self.stats.cacheHits,
        cacheMisses = self.stats.cacheMisses,
        hitRate = hitRate,
        cacheSize = self.stats.cacheSize,
        cacheMaxSize = self.stats.cacheMaxSize,
        batchOperations = self.stats.batchOperations,
        directAccesses = self.stats.directAccesses,
        timeSaved = self.stats.timeSaved,
        lastCacheClean = GetTime() - self.stats.lastCacheClean,
        settings = CopyTable(self.settings)
    }
    
    return stats
end

-- Get configuration options for settings panel
function DBOptimizer:GetConfig()
    local options = {
        type = "group",
        name = "Database Optimizer",
        desc = "Configure database access optimization settings",
        get = function(info)
            return self.settings[info[#info]]
        end,
        set = function(info, value)
            self.settings[info[#info]] = value
            
            -- Save settings
            if VUI.db and VUI.db.profile and VUI.db.profile.modules then
                VUI.db.profile.modules.dboptimizer = VUI.db.profile.modules.dboptimizer or {}
                VUI.db.profile.modules.dboptimizer[info[#info]] = value
            end
            
            -- Handle special cases
            if info[#info] == "enabled" and not value then
                -- Clear cache when disabling
                self:Reset()
            elseif info[#info] == "cleanupInterval" then
                -- Update cleanup timer
                self:RegisterCleanupTimer()
            end
            
            -- Validate settings
            self:ValidateSettings()
        end,
        args = {
            header = {
                type = "header",
                name = "Database Access Optimization",
                order = 1
            },
            enabled = {
                type = "toggle",
                name = "Enable Database Optimization",
                desc = "Enable or disable database access optimization",
                width = "full",
                order = 2
            },
            general = {
                type = "group",
                name = "General Settings",
                inline = true,
                order = 3,
                args = {
                    cacheSize = {
                        type = "range",
                        name = "Cache Size",
                        desc = "Maximum number of entries to cache",
                        min = 10,
                        max = MAX_CACHE_SIZE,
                        step = 10,
                        width = "full",
                        order = 1
                    },
                    cacheTTL = {
                        type = "range",
                        name = "Cache TTL",
                        desc = "Time-to-live for cache entries in seconds",
                        min = 30,
                        max = 3600,
                        step = 30,
                        width = "full",
                        order = 2
                    },
                    cleanupInterval = {
                        type = "range",
                        name = "Cleanup Interval",
                        desc = "Cache cleanup interval in seconds",
                        min = MIN_CLEANUP_INTERVAL,
                        max = 600,
                        step = 10,
                        width = "full",
                        order = 3
                    },
                    batchSize = {
                        type = "range",
                        name = "Batch Size",
                        desc = "Maximum batch size for batch operations",
                        min = 1,
                        max = 50,
                        step = 1,
                        width = "full",
                        order = 4
                    }
                }
            },
            advanced = {
                type = "group",
                name = "Advanced Settings",
                inline = true,
                order = 4,
                args = {
                    combatCaching = {
                        type = "toggle",
                        name = "Enhanced Combat Caching",
                        desc = "Enable enhanced caching during combat",
                        width = "full",
                        order = 1
                    },
                    trackStatistics = {
                        type = "toggle",
                        name = "Track Statistics",
                        desc = "Track and display performance statistics",
                        width = "full",
                        order = 2
                    },
                    logLevel = {
                        type = "select",
                        name = "Log Level",
                        desc = "Set the logging level for database optimizer",
                        values = {
                            [0] = "Off",
                            [1] = "Errors",
                            [2] = "Warnings",
                            [3] = "Info",
                            [4] = "Debug"
                        },
                        width = "full",
                        order = 3
                    },
                    profilePerformance = {
                        type = "toggle",
                        name = "Profile Performance",
                        desc = "Profile database access performance (may impact performance)",
                        width = "full",
                        order = 4
                    }
                }
            },
            stats = {
                type = "group",
                name = "Statistics",
                inline = true,
                order = 5,
                args = {
                    statsHeader = {
                        type = "description",
                        name = function()
                            local stats = self:GetStats()
                            local text = "Cache Hits: " .. stats.cacheHits .. "\n"
                            text = text .. "Cache Misses: " .. stats.cacheMisses .. "\n"
                            text = text .. "Hit Rate: " .. string.format("%.2f%%", stats.hitRate) .. "\n"
                            text = text .. "Cache Size: " .. stats.cacheSize .. " / " .. stats.cacheMaxSize .. "\n"
                            text = text .. "Batch Operations: " .. stats.batchOperations .. "\n"
                            text = text .. "Direct Accesses: " .. stats.directAccesses .. "\n"
                            text = text .. "Time Saved: " .. string.format("%.2fms", stats.timeSaved) .. "\n"
                            text = text .. "Last Cleanup: " .. string.format("%.1fs ago", stats.lastCacheClean)
                            return text
                        end,
                        fontSize = "medium",
                        order = 1
                    },
                    resetButton = {
                        type = "execute",
                        name = "Reset Cache & Stats",
                        desc = "Reset the cache and performance statistics",
                        func = function() self:Reset() end,
                        width = "full",
                        order = 2
                    },
                    cleanupButton = {
                        type = "execute",
                        name = "Force Cleanup",
                        desc = "Force a cache cleanup",
                        func = function() self:CleanupCache(true) end,
                        width = "full",
                        order = 3
                    }
                }
            }
        }
    }
    
    return options
end

-- Initialize module when addon is ready
if VUI.initialized then
    DBOptimizer:Initialize()
else
    VUI:RegisterCallback("OnInitialized", function()
        DBOptimizer:Initialize()
    end)
end