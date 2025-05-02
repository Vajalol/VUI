-- Database Optimization Configuration
local addonName, VUI = ...

-- Configuration options for Database Optimization module
function VUI.DatabaseOptimization:GetConfig()
    local options = {
        type = "group",
        name = "Database Optimization",
        order = 900,
        args = {
            header = {
                type = "header",
                name = "Database Access Optimization",
                order = 1
            },
            description = {
                type = "description",
                name = "Configure database access optimization settings to improve performance.",
                order = 2
            },
            enabled = {
                type = "toggle",
                name = "Enable Database Optimization",
                desc = "Enable or disable the database optimization system.",
                width = "full",
                order = 10,
                get = function() return self.config.enableCaching end,
                set = function(_, value) 
                    self.config.enableCaching = value 
                    self.state.cacheEnabled = value
                end
            },
            enableBatching = {
                type = "toggle",
                name = "Enable Write Batching",
                desc = "Group database write operations together for better performance.",
                width = "full",
                order = 11,
                get = function() return self.config.enableBatching end,
                set = function(_, value) 
                    self.config.enableBatching = value 
                    self.state.batchingEnabled = value
                end
            },
            cacheLifetime = {
                type = "range",
                name = "Cache Lifetime (seconds)",
                desc = "How long items remain in the cache before being purged.",
                min = 30,
                max = 1800,
                step = 30,
                order = 20,
                get = function() return self.config.cacheLifetime end,
                set = function(_, value) self.config.cacheLifetime = value end
            },
            maxCacheEntries = {
                type = "range",
                name = "Maximum Cache Entries",
                desc = "Maximum number of items to keep in the cache.",
                min = 100,
                max = 10000,
                step = 100,
                order = 21,
                get = function() return self.config.maxCacheEntries end,
                set = function(_, value) self.config.maxCacheEntries = value end
            },
            batchDelay = {
                type = "range",
                name = "Batch Processing Delay (seconds)",
                desc = "How long to wait before processing batched operations.",
                min = 0.1,
                max = 2.0,
                step = 0.1,
                order = 22,
                get = function() return self.config.batchDelay end,
                set = function(_, value) self.config.batchDelay = value end
            },
            debugHeader = {
                type = "header",
                name = "Debug Options",
                order = 30
            },
            debugMode = {
                type = "toggle",
                name = "Debug Mode",
                desc = "Enable database optimization debug logging.",
                width = "full",
                order = 31,
                get = function() return self.config.debugMode end,
                set = function(_, value) self.config.debugMode = value end
            },
            statsHeader = {
                type = "header",
                name = "Current Statistics",
                order = 40
            },
            statsText = {
                type = "description",
                name = function()
                    local stats = self:GetStats()
                    if not stats then
                        return "No statistics available."
                    end
                    
                    return string.format(
                        "Cache Hit Rate: %.1f%%\n" ..
                        "Cache Size: %d entries\n" ..
                        "Batched Writes: %d\n" ..
                        "Direct Writes: %d\n",
                        stats.hitRate * 100,
                        stats.cacheSize,
                        stats.batchedWrites,
                        stats.directWrites
                    )
                end,
                order = 41,
                fontSize = "medium"
            },
            cleanupCache = {
                type = "execute",
                name = "Clean Cache Now",
                desc = "Immediately clean the database cache.",
                order = 50,
                func = function() self:CleanupCache(true) end
            },
            resetStats = {
                type = "execute",
                name = "Reset Statistics",
                desc = "Reset all database optimization statistics.",
                order = 51,
                func = function() 
                    self.state.stats.cacheHits = 0
                    self.state.stats.cacheMisses = 0
                    self.state.stats.batchedWrites = 0 
                    self.state.stats.directWrites = 0
                    self.state.stats.cacheCleaned = 0
                    
                    -- Reset module stats
                    for module, _ in pairs(self.state.stats.moduleAccess) do
                        self.state.stats.moduleAccess[module] = {
                            reads = 0,
                            writes = 0,
                            cached = 0
                        }
                    end
                end
            },
            moduleHeader = {
                type = "header",
                name = "Module Cache Settings",
                order = 60
            },
        }
    }
    
    -- Add module-specific cache settings
    local moduleOrder = 61
    for module, limit in pairs(self.config.cacheByModule) do
        options.args["module_" .. module] = {
            type = "range",
            name = module .. " Cache Limit",
            desc = "Maximum cache entries for " .. module .. " module.",
            min = 10,
            max = 1000,
            step = 10,
            order = moduleOrder,
            get = function() return self.config.cacheByModule[module] or 100 end,
            set = function(_, value) 
                self.config.cacheByModule[module] = value 
                self.state.moduleCacheLimits[module] = value
            end
        }
        moduleOrder = moduleOrder + 1
    end
    
    return options
end

-- Register with config system
if VUI.options and VUI.options.args.performance then
    VUI.options.args.performance.args.databaseOptimization = VUI.DatabaseOptimization:GetConfig()
end