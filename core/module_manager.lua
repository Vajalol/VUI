--[[
    VUI - Module Manager
    Author: VortexQ8
    Version: 1.0.0
    
    This file implements the module management system for VUI, providing a unified 
    interface for managing modules and their dependencies with optimized caching.
    
    Features:
    - Dependency-based loading priority system
    - Module reference caching for performance
    - Usage statistics tracking (optional)
    - Safe module access with fallbacks
    - Automatic dependency resolution
]]

-- Get addon environment
local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end
local L = VUI.L or {} -- Localization fallback

-- Create the ModuleManager
local ModuleManager = {}
VUI.ModuleManager = ModuleManager

-- Cache frequently used globals for better performance
local GetTime = GetTime
local pairs = pairs
local ipairs = ipairs
local type = type
local tinsert = table.insert
local tsort = table.sort
local min = math.min
local wipe = table.wipe or wipe
local format = string.format

-- Module reference cache
local moduleCache = {}

-- Settings
local settings = {
    enabled = true,
    trackUsageStats = false,    -- Disabled for production release
    debugMode = false,          -- Debug output disabled in production release
    autoCleanupInterval = 300,  -- Cleanup unused cache entries every 5 minutes
    dependencyTimeout = 10,     -- Maximum time to wait for dependencies in seconds
    autoDependencyResolution = true, -- Automatically resolve dependencies
    safeModeEnabled = true,     -- Enable safe mode with fallbacks
    initializeRetryCount = 3,   -- Number of retries for module initialization
}

-- Module management state
local moduleStats = {
    accessCount = {},        -- Number of times each module was accessed
    lastAccess = {},         -- Last time each module was accessed
    dependencies = {},       -- Module dependencies (explicit)
    implicitDeps = {},       -- Implicit dependencies (detected during loading)
    loadPriority = {},       -- Module load priorities (1-100, lower = higher priority)
    moduleCategories = {},   -- Module categories for organization
    initializeState = {},    -- Module initialization state tracking
    loadTime = {},           -- Time taken to load each module
    failureReasons = {},     -- Reasons for module load failures
}

-- Debug logging function with safety
function ModuleManager:DebugLog(message)
    if not settings.debugMode then return end
    
    -- Use VUI Debug system if available
    if VUI.Debug and type(VUI.Debug) == "function" then
        VUI:Debug("[ModuleManager] " .. tostring(message))
    else
        -- Fallback to print for critical debugging
        print("|cff33aaff[VUI:ModuleManager]|r " .. tostring(message))
    end
end

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
    if VUI.RegisterMessage then
        VUI:RegisterMessage("MODULE_LOADED", function(_, moduleName, success)
            self:OnModuleLoaded(moduleName, success)
        end)
        
        VUI:RegisterMessage("MODULE_UNLOADED", function(_, moduleName)
            self:OnModuleUnloaded(moduleName)
        end)
        
        -- Additional messages for dependency system
        VUI:RegisterMessage("MODULE_INITIALIZE_START", function(_, moduleName)
            self:OnModuleInitializeStart(moduleName)
        end)
        
        VUI:RegisterMessage("MODULE_INITIALIZE_COMPLETE", function(_, moduleName, success)
            self:OnModuleInitializeComplete(moduleName, success)
        end)
        
        VUI:RegisterMessage("MODULE_DEPENDENCY_DETECTED", function(_, moduleName, dependencyName)
            self:RegisterImplicitDependency(moduleName, dependencyName)
        end)
    end
    
    -- Set up cache cleanup timer
    C_Timer.NewTicker(settings.autoCleanupInterval, function()
        self:CleanupModuleCache()
    end)
    
    -- Register core modules with appropriate priorities
    self:RegisterDefaultModulePriorities()
    
    self:DebugLog("Module Manager initialized")
end

-- Register default priorities for core modules
function ModuleManager:RegisterDefaultModulePriorities()
    -- Core systems (priority 1-20)
    self:RegisterDependencies("core", {}, 10, "core")
    self:RegisterDependencies("database", {}, 15, "core")
    self:RegisterDependencies("events", {}, 20, "core")
    
    -- UI frameworks (priority 21-30)
    self:RegisterDependencies("themes", {"core"}, 25, "ui")
    self:RegisterDependencies("media", {"core"}, 25, "ui")
    
    -- Module systems (priority 31-40)
    self:RegisterDependencies("unitframes", {"core", "themes"}, 35, "unitframes")
    self:RegisterDependencies("actionbars", {"core", "themes"}, 35, "actionbars")
    
    -- Specific modules can register their dependencies later
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

-- Register module dependencies and priority
function ModuleManager:RegisterDependencies(moduleName, dependencies, priority, category)
    if not moduleName then
        return false
    end
    
    -- Initialize dependency list if needed
    if not moduleStats.dependencies[moduleName] then
        moduleStats.dependencies[moduleName] = {}
    end
    
    -- Add explicit dependencies
    if dependencies and type(dependencies) == "table" then
        moduleStats.dependencies[moduleName] = dependencies
    end
    
    -- Set priority if provided
    if priority and type(priority) == "number" then
        moduleStats.loadPriority[moduleName] = priority
    elseif not moduleStats.loadPriority[moduleName] then
        -- Default priority (50 is middle priority)
        moduleStats.loadPriority[moduleName] = 50
    end
    
    -- Set category if provided
    if category and type(category) == "string" then
        moduleStats.moduleCategories[moduleName] = category
    elseif not moduleStats.moduleCategories[moduleName] then
        -- Default category
        moduleStats.moduleCategories[moduleName] = "optional"
    end
    
    return true
end

-- Automatically detect and register implicit dependencies
function ModuleManager:RegisterImplicitDependency(moduleName, dependencyName)
    if not moduleName or not dependencyName or moduleName == dependencyName then
        return false
    end
    
    -- Initialize implicit dependency tracking
    if not moduleStats.implicitDeps[moduleName] then
        moduleStats.implicitDeps[moduleName] = {}
    end
    
    -- Add the dependency if not already present
    if not tContains(moduleStats.implicitDeps[moduleName], dependencyName) then
        tinsert(moduleStats.implicitDeps[moduleName], dependencyName)
        
        -- Log detection (if debug is enabled)
        if settings.debugMode then
            self:DebugLog("Detected implicit dependency: " .. moduleName .. " depends on " .. dependencyName)
        end
        
        return true
    end
    
    return false
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

-- Calculate the dependency-based initialization order
function ModuleManager:CalculateInitOrder()
    local order = {}
    local visited = {}
    local visiting = {}
    
    -- Topological sort using depth-first search
    local function visit(name)
        if visited[name] then
            return true
        end
        
        if visiting[name] then
            -- Circular dependency detected
            self:DebugLog("Circular dependency detected for module: " .. name)
            return false
        end
        
        visiting[name] = true
        
        -- Process explicit dependencies first
        if moduleStats.dependencies[name] then
            for _, dep in ipairs(moduleStats.dependencies[name]) do
                if not visit(dep) then
                    return false
                end
            end
        end
        
        -- Process implicit dependencies
        if moduleStats.implicitDeps[name] then
            for _, dep in ipairs(moduleStats.implicitDeps[name]) do
                if not visit(dep) then
                    return false
                end
            end
        end
        
        visiting[name] = nil
        visited[name] = true
        table.insert(order, name)
        return true
    end
    
    -- Get full list of modules
    local allModules = {}
    
    -- Add modules with explicit dependencies
    for name in pairs(moduleStats.dependencies) do
        if not allModules[name] then
            allModules[name] = true
        end
    end
    
    -- Add modules with implicit dependencies
    for name in pairs(moduleStats.implicitDeps) do
        if not allModules[name] then
            allModules[name] = true
        end
    end
    
    -- Add modules in cache
    for name in pairs(moduleCache) do
        if not allModules[name] then
            allModules[name] = true
        end
    end
    
    -- Sort the modules by category and priority first
    local modulesByCategory = {}
    local categoryOrder = {
        "core",         -- Core systems first
        "data",         -- Data providers 
        "api",          -- API modules
        "ui",           -- UI frameworks
        "unitframes",   -- Unit frames
        "actionbars",   -- Action bars
        "buffs",        -- Buff/debuff modules
        "combat",       -- Combat modules
        "utility",      -- Utility functions
        "optional"      -- Optional features
    }
    
    -- Group modules by category
    for name in pairs(allModules) do
        local category = moduleStats.moduleCategories[name] or "optional"
        
        if not modulesByCategory[category] then
            modulesByCategory[category] = {}
        end
        
        table.insert(modulesByCategory[category], name)
    end
    
    -- Process modules in category order
    for _, category in ipairs(categoryOrder) do
        if modulesByCategory[category] then
            -- Sort by priority within category
            table.sort(modulesByCategory[category], function(a, b)
                local priorityA = moduleStats.loadPriority[a] or 50
                local priorityB = moduleStats.loadPriority[b] or 50
                return priorityA < priorityB -- Lower number = higher priority
            end)
            
            -- Calculate dependencies
            for _, name in ipairs(modulesByCategory[category]) do
                visit(name)
            end
        end
    end
    
    -- Handle any modules not in a specific category
    for name in pairs(allModules) do
        if not visited[name] then
            visit(name)
        end
    end
    
    return order
end

-- Initialize modules in dependency order
function ModuleManager:InitializeModules()
    local order = self:CalculateInitOrder()
    
    self:DebugLog("Initializing " .. #order .. " modules in dependency order")
    
    -- Track module initialization
    moduleStats.initializeState = {}
    
    -- Start module initialization timer
    local startTime = GetTime()
    
    -- Initialize modules in calculated order
    for _, name in ipairs(order) do
        self:InitializeModule(name)
        
        -- Check for timeout to prevent freezing the UI
        if (GetTime() - startTime) > settings.dependencyTimeout then
            self:DebugLog("Module initialization timed out after " .. settings.dependencyTimeout .. " seconds")
            break
        end
    end
    
    -- Collect failure info
    local failedCount = 0
    for name, state in pairs(moduleStats.initializeState) do
        if state == "failed" then
            failedCount = failedCount + 1
        end
    end
    
    self:DebugLog("Module initialization complete: " .. 
                 (order and #order or 0) .. " total, " .. 
                 failedCount .. " failed")
                 
    -- Trigger a VUI message if available
    if VUI.SendMessage then
        VUI:SendMessage("MODULE_INITIALIZATION_COMPLETE", #order, failedCount)
    end
    
    return #order - failedCount, failedCount
end

-- Initialize a specific module with dependency handling
function ModuleManager:InitializeModule(name)
    if not name then return false end
    
    -- Skip already initialized modules
    if moduleStats.initializeState[name] == "complete" then
        return true
    end
    
    -- Check if module is in progress (prevents recursion)
    if moduleStats.initializeState[name] == "inprogress" then
        self:DebugLog("Circular initialization detected for module: " .. name)
        moduleStats.initializeState[name] = "failed"
        moduleStats.failureReasons[name] = "circular_dependency"
        return false
    end
    
    -- Mark as in progress
    moduleStats.initializeState[name] = "inprogress"
    
    -- Get the module
    local module = self:GetModule(name, true)
    if not module then
        self:DebugLog("Module not found: " .. name)
        moduleStats.initializeState[name] = "failed"
        moduleStats.failureReasons[name] = "not_found"
        return false
    end
    
    -- Trigger pre-initialize
    if VUI.SendMessage then
        VUI:SendMessage("MODULE_INITIALIZE_START", name)
    end
    
    -- First make sure dependencies are initialized
    if moduleStats.dependencies[name] then
        for _, dep in ipairs(moduleStats.dependencies[name]) do
            if not self:InitializeModule(dep) then
                -- Failed to initialize dependency
                self:DebugLog("Failed to initialize dependency " .. dep .. " for module " .. name)
                moduleStats.initializeState[name] = "failed"
                moduleStats.failureReasons[name] = "dependency_failed:" .. dep
                return false
            end
        end
    end
    
    -- Handle implicit dependencies
    if moduleStats.implicitDeps[name] then
        for _, dep in ipairs(moduleStats.implicitDeps[name]) do
            if not self:InitializeModule(dep) then
                -- This is an implicit dependency, so we can continue but log the issue
                self:DebugLog("Warning: Implicit dependency " .. dep .. " failed to initialize for module " .. name)
            end
        end
    end
    
    -- Start timing
    local startTime = GetTime()
    
    -- Initialize the module
    local success, err = pcall(function()
        -- Check for OnInitialize method
        if module.OnInitialize and type(module.OnInitialize) == "function" then
            module:OnInitialize()
        elseif module.Initialize and type(module.Initialize) == "function" then
            module:Initialize()
        end
    end)
    
    -- Calculate init time
    local endTime = GetTime()
    local initTime = (endTime - startTime) * 1000 -- milliseconds
    moduleStats.loadTime[name] = initTime
    
    -- Handle result
    if success then
        moduleStats.initializeState[name] = "complete"
        self:DebugLog(string.format("Initialized module %s in %.2fms", name, initTime))
        
        -- Trigger post-initialize
        if VUI.SendMessage then
            VUI:SendMessage("MODULE_INITIALIZE_COMPLETE", name, true)
        end
        
        return true
    else
        moduleStats.initializeState[name] = "failed"
        moduleStats.failureReasons[name] = "error:" .. (err or "unknown error")
        self:DebugLog("Failed to initialize module " .. name .. ": " .. (err or "unknown error"))
        
        -- Trigger failure message
        if VUI.SendMessage then
            VUI:SendMessage("MODULE_INITIALIZE_COMPLETE", name, false, err)
        end
        
        return false
    end
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
    
    -- Clean up dependency tracking
    moduleStats.initializeState[moduleName] = nil
end

-- Handle MODULE_INITIALIZE_START message
function ModuleManager:OnModuleInitializeStart(moduleName)
    -- Mark as in progress
    moduleStats.initializeState[moduleName] = "inprogress"
end

-- Handle MODULE_INITIALIZE_COMPLETE message
function ModuleManager:OnModuleInitializeComplete(moduleName, success)
    -- Update state based on success
    if success then
        moduleStats.initializeState[moduleName] = "complete"
    else
        moduleStats.initializeState[moduleName] = "failed"
    end
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

-- Get dependency status for a module
function ModuleManager:GetModuleDependencyStatus(moduleName)
    if not moduleName then
        return nil
    end
    
    local result = {
        name = moduleName,
        initialized = moduleStats.initializeState[moduleName] == "complete",
        failed = moduleStats.initializeState[moduleName] == "failed",
        inProgress = moduleStats.initializeState[moduleName] == "inprogress",
        dependencies = {},
        missingDependencies = {},
        initTime = moduleStats.loadTime[moduleName] or 0,
        failureReason = moduleStats.failureReasons[moduleName] or "unknown",
        category = moduleStats.moduleCategories[moduleName] or "unknown",
        priority = moduleStats.loadPriority[moduleName] or 50
    }
    
    -- Get explicit dependencies
    if moduleStats.dependencies[moduleName] then
        for _, dep in ipairs(moduleStats.dependencies[moduleName]) do
            table.insert(result.dependencies, dep)
            
            -- Check if dependency is available and initialized
            if not moduleStats.initializeState[dep] or moduleStats.initializeState[dep] ~= "complete" then
                table.insert(result.missingDependencies, dep)
            end
        end
    end
    
    -- Add implicit dependencies
    if moduleStats.implicitDeps[moduleName] then
        for _, dep in ipairs(moduleStats.implicitDeps[moduleName]) do
            if not VUI.tContains(result.dependencies, dep) then
                table.insert(result.dependencies, dep)
                
                -- Check if dependency is available and initialized
                if not moduleStats.initializeState[dep] or moduleStats.initializeState[dep] ~= "complete" then
                    table.insert(result.missingDependencies, dep)
                end
            end
        end
    end
    
    return result
end

-- Get all modules with their dependency status
function ModuleManager:GetAllModuleDependencyStatus()
    local result = {}
    
    -- Build complete list of modules
    local allModules = {}
    
    -- Add modules with explicit dependencies
    for name in pairs(moduleStats.dependencies) do
        if not allModules[name] then
            allModules[name] = true
        end
    end
    
    -- Add modules with implicit dependencies
    for name in pairs(moduleStats.implicitDeps) do
        if not allModules[name] then
            allModules[name] = true
        end
    end
    
    -- Add modules in initialization state
    for name in pairs(moduleStats.initializeState) do
        if not allModules[name] then
            allModules[name] = true
        end
    end
    
    -- Add modules in cache
    for name in pairs(moduleCache) do
        if not allModules[name] then
            allModules[name] = true
        end
    end
    
    -- Get status for each module
    for name in pairs(allModules) do
        table.insert(result, self:GetModuleDependencyStatus(name))
    end
    
    -- Sort by category and then priority
    table.sort(result, function(a, b)
        if a.category == b.category then
            return a.priority < b.priority -- Lower priority number = higher priority
        else
            -- Default category order
            local categoryOrder = {
                "core", "data", "api", "ui", "unitframes", "actionbars", 
                "buffs", "combat", "utility", "optional"
            }
            
            local aIndex = VUI.tIndexOf(categoryOrder, a.category) or 99
            local bIndex = VUI.tIndexOf(categoryOrder, b.category) or 99
            
            return aIndex < bIndex
        end
    end)
    
    return result
end

-- Module export for VUI
VUI.ModuleManager = ModuleManager

-- Initialize on VUI ready
if VUI.isInitialized then
    ModuleManager:Initialize()
    
    -- Schedule module initialization after a short delay
    C_Timer.After(0.5, function()
        ModuleManager:InitializeModules()
    end)
else
    -- Instead of using RegisterScript, we'll hook into OnInitialize
    local originalOnInitialize = VUI.OnInitialize
    VUI.OnInitialize = function(self, ...)
        -- Call the original function first
        if originalOnInitialize then
            originalOnInitialize(self, ...)
        end
        
        -- Initialize module manager
        if ModuleManager.Initialize then
            ModuleManager:Initialize()
            
            -- Schedule module initialization after a short delay
            C_Timer.After(0.5, function()
                if ModuleManager.InitializeModules then
                    ModuleManager:InitializeModules()
                end
            end)
        end
    end
end

-- Provide migration path for existing code
if not VUI.tContains then 
    VUI.tContains = function(table, value)
        if not table then return false end
        for _, v in pairs(table) do
            if v == value then return true end
        end
        return false
    end
end

if not VUI.tIndexOf then
    VUI.tIndexOf = function(table, value)
        if not table then return nil end
        for i, v in ipairs(table) do
            if v == value then return i end
        end
        return nil
    end
end