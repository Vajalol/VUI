--[[
    VUI - Module Manager
    Author: VortexQ8
    
    This file implements the module management system for VUI, providing a unified 
    interface for managing modules and their dependencies with optimized caching.
]]

-- Get addon environment
local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end
local L = VUI.L

-- Create the ModuleManager
local ModuleManager = {}
VUI.ModuleManager = ModuleManager

-- Cache frequently used globals for better performance
local GetTime = GetTime
local pairs = pairs
local type = type
local tinsert = table.insert
local tsort = table.sort
local min = math.min
local wipe = wipe

-- Module reference cache
local moduleCache = {}

-- Settings
local settings = {
    enabled = true,
    trackUsageStats = false,    -- Disabled for production release
    debugMode = false,          -- Debug output disabled in production release
    autoCleanupInterval = 300,  -- Cleanup unused cache entries every 5 minutes
}

-- Module usage statistics
local moduleStats = {
    accessCount = {},        -- Number of times each module was accessed
    lastAccess = {},         -- Last time each module was accessed
    dependencies = {},       -- Module dependencies
}

-- Initialize the module manager
function ModuleManager:Initialize()
    -- Load settings from database
    self:LoadSettings()
    
    -- Override VUI's GetModule function with our enhanced version
    if not self.originalGetModule then
        self.originalGetModule = VUI.GetModule
        VUI.GetModule = function(self, name, silent)
            return ModuleManager:GetModule(name, silent)
        end
    end
    
    -- Register message handlers
    VUI:RegisterMessage("MODULE_LOADED", function(_, moduleName, success)
        self:OnModuleLoaded(moduleName, success)
    end)
    
    VUI:RegisterMessage("MODULE_UNLOADED", function(_, moduleName)
        self:OnModuleUnloaded(moduleName)
    end)
    
    -- Set up cache cleanup timer
    C_Timer.NewTicker(settings.autoCleanupInterval, function()
        self:CleanupModuleCache()
    end)
    
    -- Debug messages disabled in production release
end

-- Cleanup unused entries in the module cache to prevent memory bloat
function ModuleManager:CleanupModuleCache()
    local now = GetTime()
    local cacheSize = 0
    local cleanedCount = 0
    
    -- Count cache entries and identify old ones
    for name, _ in pairs(moduleCache) do
        cacheSize = cacheSize + 1
        
        -- If this module hasn't been accessed recently (30+ minutes), remove it from cache
        if settings.trackUsageStats and moduleStats.lastAccess[name] and 
           (now - moduleStats.lastAccess[name] > 1800) then
            moduleCache[name] = nil
            cleanedCount = cleanedCount + 1
        end
    end
    
    -- Debug messages disabled in production release
end

-- Load settings from database
function ModuleManager:LoadSettings()
    -- Register with VUI database
    local dbSettings = VUI.db.profile.moduleManager
    if not dbSettings then
        VUI.db.profile.moduleManager = CopyTable(settings)
    else
        -- Update settings from database, keeping defaults for missing values
        for k, v in pairs(settings) do
            if dbSettings[k] == nil then
                dbSettings[k] = v
            else
                settings[k] = dbSettings[k]
            end
        end
    end
end

-- Enhanced GetModule function
function ModuleManager:GetModule(name, silent)
    if not name then
        return nil
    end
    
    -- Check cache first (fastest path)
    if moduleCache[name] then
        -- Update access stats
        if settings.trackUsageStats then
            moduleStats.accessCount[name] = (moduleStats.accessCount[name] or 0) + 1
            moduleStats.lastAccess[name] = GetTime()
        end
        
        return moduleCache[name]
    end
    
    -- Try original method
    local vModule = self.originalGetModule(VUI, name, true)
    
    if vModule then
        -- Cache the result for future access
        moduleCache[name] = vModule
        
        -- Update access stats
        if settings.trackUsageStats then
            moduleStats.accessCount[name] = (moduleStats.accessCount[name] or 0) + 1
            moduleStats.lastAccess[name] = GetTime()
        end
        
        return vModule
    end
    
    -- Module not found
    if not silent then
        VUI:Print("Module " .. name .. " not found.")
    end
    
    return nil
end

-- Call a method on a module if available
function ModuleManager:CallModuleMethod(moduleName, methodName, ...)
    if not moduleName or not methodName then
        return nil
    end
    
    -- Get module
    local module = self:GetModule(moduleName, true)
    
    if module then
        -- Module exists, call method directly
        if type(module[methodName]) == "function" then
            return module[methodName](module, ...)
        else
            -- Debug messages disabled in production release
        end
    else
        -- Debug messages disabled in production release
    end
    
    return nil
end

-- Check if a module is available
function ModuleManager:IsModuleAvailable(moduleName)
    if not moduleName then
        return false
    end
    
    -- Check cache first (fastest path)
    if moduleCache[moduleName] then
        -- Update access stats
        if settings.trackUsageStats then
            moduleStats.lastAccess[moduleName] = GetTime()
        end
        return true
    end
    
    -- Check if module exists in VUI
    local module = self.originalGetModule(VUI, moduleName, true)
    if module then
        -- Cache for future reference
        moduleCache[moduleName] = module
        
        -- Update access stats
        if settings.trackUsageStats then
            moduleStats.lastAccess[moduleName] = GetTime()
        end
        
        return true
    end
    
    return false
end

-- Register module dependencies (for documentation/reference only)
function ModuleManager:RegisterDependencies(moduleName, dependencies)
    if not moduleName or not dependencies or #dependencies == 0 then
        return
    end
    
    -- Store dependencies for reference
    moduleStats.dependencies[moduleName] = dependencies
end

-- Reload a module (remove from cache to force reload on next access)
function ModuleManager:ReloadModule(moduleName)
    if not moduleName then
        return false
    end
    
    -- Remove from cache
    if moduleCache[moduleName] then
        moduleCache[moduleName] = nil
        
        -- Debug messages disabled in production release
        
        return true
    end
    
    return false
end

-- Handle MODULE_LOADED message
function ModuleManager:OnModuleLoaded(moduleName, success)
    if success then
        -- Update module cache
        local module = self.originalGetModule(VUI, moduleName, true)
        if module then
            moduleCache[moduleName] = module
        end
    end
end

-- Handle MODULE_UNLOADED message
function ModuleManager:OnModuleUnloaded(moduleName)
    -- Remove from cache
    moduleCache[moduleName] = nil
end

-- Get module usage statistics
function ModuleManager:GetModuleStats()
    local stats = {
        moduleCount = 0,
        cacheSize = 0,
        mostAccessed = {},
        recentAccess = {},
        memoryUsage = 0,
    }
    
    -- Count modules and get cache size
    stats.cacheSize = 0
    for _ in pairs(moduleCache) do
        stats.cacheSize = stats.cacheSize + 1
    end
    
    -- Skip detailed stats if tracking is disabled
    if not settings.trackUsageStats then
        return stats
    end
    
    stats.moduleCount = 0
    for _ in pairs(moduleStats.accessCount) do
        stats.moduleCount = stats.moduleCount + 1
    end
    
    -- Find most accessed modules
    local accessList = {}
    for name, count in pairs(moduleStats.accessCount) do
        tinsert(accessList, {name = name, count = count})
    end
    
    tsort(accessList, function(a, b) return a.count > b.count end)
    
    -- Get top 5 most accessed
    for i = 1, min(5, #accessList) do
        tinsert(stats.mostAccessed, accessList[i])
    end
    
    -- Find most recently accessed modules
    local recentList = {}
    for name, time in pairs(moduleStats.lastAccess) do
        tinsert(recentList, {name = name, time = time})
    end
    
    tsort(recentList, function(a, b) return a.time > b.time end)
    
    -- Get top 5 most recent
    for i = 1, min(5, #recentList) do
        tinsert(stats.recentAccess, {
            name = recentList[i].name,
            elapsed = GetTime() - recentList[i].time
        })
    end
    
    -- Estimate memory usage (very rough estimate)
    stats.memoryUsage = stats.cacheSize * 10  -- ~10kb per module is a rough estimate
    
    return stats
end

-- Get configuration options
function ModuleManager:GetConfigOptions()
    local options = {
        name = "Module Manager",
        type = "group",
        args = {
            enabled = {
                order = 1,
                type = "toggle",
                name = "Enable Module Manager",
                desc = "Enables enhanced module management with optimized caching",
                get = function() return settings.enabled end,
                set = function(_, value) 
                    settings.enabled = value
                    VUI.db.profile.moduleManager.enabled = value
                end,
                width = "full",
            },
            trackUsageStats = {
                order = 2,
                type = "toggle",
                name = "Track Module Usage",
                desc = "Keep statistics about module usage for optimization",
                get = function() return settings.trackUsageStats end,
                set = function(_, value) 
                    settings.trackUsageStats = value
                    VUI.db.profile.moduleManager.trackUsageStats = value
                end,
                width = "full",
                disabled = function() return not settings.enabled end,
            },
            debugMode = {
                order = 3,
                type = "toggle",
                name = "Debug Mode",
                desc = "Debug mode disabled in production release",
                get = function() return false end,
                set = function(_, value) 
                    -- Debug mode always disabled in production
                    settings.debugMode = false
                    VUI.db.profile.moduleManager.debugMode = false
                end,
                width = "full",
                disabled = true, -- Always disabled in production
            },
            advancedHeader = {
                order = 4,
                type = "header",
                name = "Cache Settings",
            },
            autoCleanupInterval = {
                order = 5,
                type = "range",
                name = "Cache Cleanup Interval",
                desc = "How often to check and clean up unused modules from cache (in seconds)",
                min = 60,
                max = 1800,
                step = 60,
                get = function() return settings.autoCleanupInterval end,
                set = function(_, value) 
                    settings.autoCleanupInterval = value
                    VUI.db.profile.moduleManager.autoCleanupInterval = value
                end,
                width = "full",
                disabled = function() return not settings.enabled end,
            },
            clearCache = {
                order = 6,
                type = "execute",
                name = "Clear Module Cache",
                desc = "Clear the module cache, forcing all modules to be reloaded when accessed",
                func = function()
                    wipe(moduleCache)
                    VUI:Print("Module cache cleared")
                end,
                width = "full",
                disabled = function() return not settings.enabled end,
            },
            resetStats = {
                order = 7,
                type = "execute",
                name = "Reset Usage Statistics",
                desc = "Reset all module usage statistics",
                func = function()
                    wipe(moduleStats.accessCount)
                    wipe(moduleStats.lastAccess)
                    VUI:Print("Module usage statistics reset")
                end,
                width = "full",
                disabled = function() return not settings.enabled or not settings.trackUsageStats end,
            },
            cleanupNow = {
                order = 8,
                type = "execute",
                name = "Run Cache Cleanup Now",
                desc = "Immediately clean up unused modules from the cache",
                func = function()
                    ModuleManager:CleanupModuleCache()
                    VUI:Print("Module cache cleanup complete")
                end,
                width = "full",
                disabled = function() return not settings.enabled end,
            },
        }
    }
    
    return options
end

-- Module export for VUI
VUI.ModuleManager = ModuleManager

-- Initialize on VUI ready
if VUI.isInitialized then
    ModuleManager:Initialize()
else
    -- Instead of using RegisterScript, we'll hook into OnInitialize
    local originalOnInitialize = VUI.OnInitialize
    VUI.OnInitialize = function(self, ...)
        -- Call the original function first
        if originalOnInitialize then
            originalOnInitialize(self, ...)
        end
        
        -- Initialize module after VUI is initialized
        if ModuleManager.Initialize then
            ModuleManager:Initialize()
        end
    end
end