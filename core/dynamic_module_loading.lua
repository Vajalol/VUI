local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end

-- Dynamic Module Loading System
-- Provides an advanced module loading system that handles dependencies and load order
-- based on configuration and system requirements

-- Create namespace
VUI.DynamicModuleLoading = {}
local DML = VUI.DynamicModuleLoading

-- State tracking
DML.state = {
    loadedModules = {},       -- Modules that have been fully loaded
    pendingModules = {},      -- Modules waiting to be loaded
    failedModules = {},       -- Modules that failed to load
    moduleGraph = {},         -- Dependency graph for modules
    loadOrder = {},           -- Calculated load order
    loadPhase = 0,            -- Current loading phase
    totalModules = 0,         -- Total number of modules
    loadedCount = 0,          -- Number of loaded modules
    failedCount = 0,          -- Number of failed modules
    loadStartTime = 0,        -- When the load process started
    loadEndTime = 0,          -- When the load process completed
    moduleLoadTimes = {},     -- Time taken to load each module
    registeredPaths = {},     -- Paths where modules are located
    moduleCallbacks = {},     -- Callbacks for module load events
    conditionalModules = {},  -- Modules with conditional loading
    isLoading = false,        -- Whether a load is in progress
    cycleDetection = {}       -- For detecting dependency cycles
}

-- Configuration
DML.config = {
    enabled = true,           -- Master switch
    loadTimeout = 5,          -- Maximum seconds to spend loading modules
    autoResolve = true,       -- Automatically resolve dependencies
    loadOrder = {             -- Default load order by category
        "core",               -- Core systems (loaded first)
        "data",               -- Data providers
        "api",                -- API and integration modules
        "ui",                 -- UI systems
        "unitframes",         -- Unit frame modules
        "actionbars",         -- Action bar modules
        "combat",             -- Combat-related modules
        "utility",            -- Utility modules
        "optional"            -- Optional and user-preference modules
    },
    logLevel = 1,             -- 0=none, 1=errors, 2=warnings, 3=info, 4=debug
    loadingScreen = false,    -- Show loading screen during load
    debugMode = false,        -- Enable debug features
    moduleBlacklist = {},     -- Modules that should never load
    retryFailures = true,     -- Retry loading failed modules
    retryLimit = 3            -- Maximum number of load retries
}

-- Module registration
function DML:RegisterModule(name, data)
    if not name or not data then
        self:LogError("Invalid module registration: " .. (name or "unnamed"))
        return false
    end
    
    -- Normalize module data
    data.name = name
    data.category = data.category or "optional"
    data.dependencies = data.dependencies or {}
    data.optional = data.optional or {}
    data.requiredAddons = data.requiredAddons or {}
    data.loadCondition = data.loadCondition
    data.loadPhase = data.loadPhase or 2
    data.installFunction = data.installFunction
    data.priority = data.priority or 50  -- 1-100, lower = higher priority
    
    -- Skip blacklisted modules
    if self.config.moduleBlacklist[name] then
        self:LogInfo("Skipping blacklisted module: " .. name)
        return false
    end
    
    -- Register in pending modules
    self.state.pendingModules[name] = data
    self.state.totalModules = self.state.totalModules + 1
    
    -- Add to dependency graph
    self.state.moduleGraph[name] = data.dependencies
    
    -- Register conditional modules
    if data.loadCondition then
        self.state.conditionalModules[name] = data.loadCondition
    end
    
    self:LogDebug("Registered module: " .. name)
    return true
end

-- Register a path where modules are located
function DML:RegisterModulePath(path, category)
    if not path then return false end
    
    table.insert(self.state.registeredPaths, {
        path = path,
        category = category
    })
    
    self:LogDebug("Registered module path: " .. path)
    return true
end

-- Register a callback for module loading events
function DML:RegisterLoadCallback(event, callback)
    if not event or not callback then return false end
    
    if not self.state.moduleCallbacks[event] then
        self.state.moduleCallbacks[event] = {}
    end
    
    table.insert(self.state.moduleCallbacks[event], callback)
    return true
end

-- Trigger callbacks for a module loading event
function DML:TriggerLoadEvent(event, ...)
    if not event or not self.state.moduleCallbacks[event] then return end
    
    for _, callback in ipairs(self.state.moduleCallbacks[event]) do
        local success, err = pcall(callback, ...)
        if not success then
            self:LogError("Error in module load callback: " .. (err or "unknown error"))
        end
    end
end

-- Check if a module can be loaded based on dependencies
function DML:CanLoadModule(name)
    local moduleData = self.state.pendingModules[name]
    if not moduleData then return false end
    
    -- Check if all dependencies are loaded
    for _, dep in ipairs(moduleData.dependencies) do
        if not self.state.loadedModules[dep] and not moduleData.optional[dep] then
            return false
        end
    end
    
    -- Check for required addons
    for _, addon in ipairs(moduleData.requiredAddons) do
        local loaded, finished = IsAddOnLoaded(addon)
        if not loaded or not finished then
            return false
        end
    end
    
    -- Check for conditional loading
    if moduleData.loadCondition and type(moduleData.loadCondition) == "function" then
        local success, result = pcall(moduleData.loadCondition)
        if not success or not result then
            return false
        end
    end
    
    return true
end

-- Load a specific module
function DML:LoadModule(name)
    if self.state.loadedModules[name] then
        return true
    end
    
    if self.state.failedModules[name] and self.state.failedModules[name].retries >= self.config.retryLimit then
        return false
    end
    
    local moduleData = self.state.pendingModules[name]
    if not moduleData then
        self:LogError("Attempted to load unknown module: " .. name)
        return false
    end
    
    -- Ensure dependencies are loaded first
    for _, dep in ipairs(moduleData.dependencies) do
        if not self.state.loadedModules[dep] and not moduleData.optional[dep] then
            -- If not optional and not loaded, try to load it
            if not self:LoadModule(dep) then
                if not moduleData.optional[dep] then
                    self:LogError("Failed to load dependency " .. dep .. " for module " .. name)
                    
                    -- Record failure
                    self.state.failedModules[name] = {
                        reason = "missing_dependency",
                        dependency = dep,
                        retries = (self.state.failedModules[name] and self.state.failedModules[name].retries or 0) + 1
                    }
                    
                    self.state.failedCount = self.state.failedCount + 1
                    self:TriggerLoadEvent("MODULE_LOAD_FAILED", name, "missing_dependency", dep)
                    return false
                end
                
                -- Skip the optional dependency
                self:LogWarning("Optional dependency " .. dep .. " not loaded for module " .. name)
            end
        end
    end
    
    -- Trigger pre-load event
    self:TriggerLoadEvent("MODULE_PRELOAD", name)
    
    -- Start timing
    local startTime = debugprofilestop()
    
    -- Try to load the module
    local success, err = pcall(function()
        -- Call install function if provided
        if moduleData.installFunction and type(moduleData.installFunction) == "function" then
            moduleData.installFunction()
        end
        
        -- Look for module in registered paths
        for _, pathInfo in ipairs(self.state.registeredPaths) do
            if not moduleData.category or moduleData.category == pathInfo.category then
                local modulePath = pathInfo.path .. "/" .. name
                
                -- Try to load module files if they exist
                local initFile = modulePath .. "/init.lua"
                local coreFile = modulePath .. "/core.lua"
                local indexFile = modulePath .. "/index.xml"
                
                -- Different loading strategies
                if DoesFileExist(initFile) then
                    LoadAddOnFile(initFile)
                elseif DoesFileExist(indexFile) then
                    LoadAddOnFile(indexFile)
                elseif DoesFileExist(coreFile) then
                    LoadAddOnFile(coreFile)
                else
                    -- Try direct module file
                    local directFile = modulePath .. ".lua"
                    if DoesFileExist(directFile) then
                        LoadAddOnFile(directFile)
                    end
                end
            end
        end
    end)
    
    -- Calculate load time
    local loadTime = debugprofilestop() - startTime
    self.state.moduleLoadTimes[name] = loadTime
    
    -- Handle result
    if success then
        -- Mark as loaded
        self.state.loadedModules[name] = moduleData
        self.state.pendingModules[name] = nil
        self.state.loadedCount = self.state.loadedCount + 1
        
        self:LogInfo("Loaded module: " .. name .. " in " .. string.format("%.2f", loadTime) .. "ms")
        self:TriggerLoadEvent("MODULE_LOADED", name, loadTime)
        return true
    else
        -- Record failure
        self.state.failedModules[name] = {
            reason = "load_error",
            error = err,
            retries = (self.state.failedModules[name] and self.state.failedModules[name].retries or 0) + 1
        }
        
        self.state.failedCount = self.state.failedCount + 1
        self:LogError("Failed to load module: " .. name .. " - " .. (err or "unknown error"))
        self:TriggerLoadEvent("MODULE_LOAD_FAILED", name, "load_error", err)
        return false
    end
end

-- Calculate dependency-based load order
function DML:CalculateLoadOrder()
    local order = {}
    self.state.cycleDetection = {}
    
    -- Helper function for topological sort
    local function visit(name, visiting)
        if self.state.loadedModules[name] then
            return true
        end
        
        if visiting[name] then
            self:LogError("Circular dependency detected for module: " .. name)
            return false
        end
        
        if self.state.cycleDetection[name] then
            return true
        end
        
        visiting[name] = true
        
        local deps = self.state.moduleGraph[name] or {}
        for _, dep in ipairs(deps) do
            if not self.state.loadedModules[dep] and not self:IsOptionalDependency(name, dep) then
                if not visit(dep, visiting) then
                    return false
                end
            end
        end
        
        visiting[name] = nil
        self.state.cycleDetection[name] = true
        table.insert(order, name)
        return true
    end
    
    -- Sort modules by category and priority
    local modulesByCategory = {}
    for name, data in pairs(self.state.pendingModules) do
        local category = data.category or "optional"
        
        if not modulesByCategory[category] then
            modulesByCategory[category] = {}
        end
        
        table.insert(modulesByCategory[category], name)
    end
    
    -- Process in category order
    for _, category in ipairs(self.config.loadOrder) do
        if modulesByCategory[category] then
            -- Sort by priority within category
            table.sort(modulesByCategory[category], function(a, b)
                local priorityA = self.state.pendingModules[a] and self.state.pendingModules[a].priority or 50
                local priorityB = self.state.pendingModules[b] and self.state.pendingModules[b].priority or 50
                return priorityA < priorityB  -- Lower number = higher priority
            end)
            
            -- Calculate dependencies for this category
            for _, name in ipairs(modulesByCategory[category]) do
                visit(name, {})
            end
        end
    end
    
    -- Handle any modules not in a specific category
    for name in pairs(self.state.pendingModules) do
        if not VUI.tContains(order, name) then
            visit(name, {})
        end
    end
    
    self.state.loadOrder = order
    return order
end

-- Check if a dependency is optional for a module
function DML:IsOptionalDependency(moduleName, depName)
    local moduleData = self.state.pendingModules[moduleName]
    if not moduleData then return false end
    
    return moduleData.optional[depName] or false
end

-- Load modules in calculated order
function DML:LoadModules()
    if not self.config.enabled then return end
    
    -- Don't run multiple loads simultaneously
    if self.state.isLoading then return end
    
    self.state.isLoading = true
    self.state.loadStartTime = debugprofilestop()
    
    -- Calculate load order if not already done
    if #self.state.loadOrder == 0 then
        self:CalculateLoadOrder()
    end
    
    self:LogInfo("Beginning module loading for " .. #self.state.loadOrder .. " modules")
    self:TriggerLoadEvent("MODULES_LOADING_STARTED", #self.state.loadOrder)
    
    -- Load modules in order
    for _, name in ipairs(self.state.loadOrder) do
        if not self.state.loadedModules[name] then
            self:LoadModule(name)
            
            -- Protect against infinite loops
            if (debugprofilestop() - self.state.loadStartTime) / 1000 > self.config.loadTimeout then
                self:LogError("Module loading timed out after " .. self.config.loadTimeout .. " seconds")
                break
            end
        end
    end
    
    -- Retry failed modules if configured
    if self.config.retryFailures then
        local retriedAny = false
        
        for name, info in pairs(self.state.failedModules) do
            if info.retries < self.config.retryLimit then
                self:LogInfo("Retrying failed module: " .. name)
                self:LoadModule(name)
                retriedAny = true
            end
        end
        
        if retriedAny then
            -- Attempt to load any remaining modules that might now have dependencies satisfied
            for name in pairs(self.state.pendingModules) do
                if not self.state.loadedModules[name] and self:CanLoadModule(name) then
                    self:LoadModule(name)
                end
            end
        end
    end
    
    self.state.loadEndTime = debugprofilestop()
    self.state.isLoading = false
    
    local loadTimeMs = self.state.loadEndTime - self.state.loadStartTime
    self:LogInfo("Module loading completed in " .. string.format("%.2f", loadTimeMs) .. "ms")
    self:LogInfo("Loaded " .. self.state.loadedCount .. " modules, " .. self.state.failedCount .. " failed")
    
    self:TriggerLoadEvent("MODULES_LOADING_COMPLETED", self.state.loadedCount, self.state.failedCount, loadTimeMs)
end

-- Reload a specific module
function DML:ReloadModule(name)
    if not name then return false end
    
    -- Remove from loaded modules
    if self.state.loadedModules[name] then
        local moduleData = self.state.loadedModules[name]
        self.state.loadedModules[name] = nil
        self.state.pendingModules[name] = moduleData
        self.state.loadedCount = self.state.loadedCount - 1
        
        -- Also mark any modules that depend on this one for reload
        for depName, deps in pairs(self.state.moduleGraph) do
            if VUI.tContains(deps, name) and self.state.loadedModules[depName] then
                self:ReloadModule(depName)
            end
        end
    end
    
    -- Clear from failed modules if present
    if self.state.failedModules[name] then
        self.state.failedModules[name] = nil
        self.state.failedCount = self.state.failedCount - 1
    end
    
    -- Recalculate load order
    self:CalculateLoadOrder()
    
    -- Load the module
    return self:LoadModule(name)
end

-- Get a loaded module
function DML:GetModule(name)
    return self.state.loadedModules[name]
end

-- Check if a module is loaded
function DML:IsModuleLoaded(name)
    return self.state.loadedModules[name] ~= nil
end

-- Get load statistics
function DML:GetStats()
    local stats = {
        total = self.state.totalModules,
        loaded = self.state.loadedCount,
        failed = self.state.failedCount,
        pending = self.state.totalModules - self.state.loadedCount - self.state.failedCount,
        loadTime = (self.state.loadEndTime - self.state.loadStartTime),
        moduleTimes = {}
    }
    
    -- Find slowest modules
    local modulesByTime = {}
    for name, time in pairs(self.state.moduleLoadTimes) do
        table.insert(modulesByTime, {name = name, time = time})
    end
    
    table.sort(modulesByTime, function(a, b) return a.time > b.time end)
    
    -- Add top 5 slowest modules
    for i = 1, math.min(5, #modulesByTime) do
        stats.moduleTimes[modulesByTime[i].name] = modulesByTime[i].time
    end
    
    -- Add failure information
    stats.failures = {}
    for name, info in pairs(self.state.failedModules) do
        stats.failures[name] = info.reason
    end
    
    return stats
end

-- Logging functions
function DML:LogDebug(message)
    if self.config.logLevel >= 4 then
        if VUI.Debug then
            VUI:Debug("[ModuleLoader] " .. message)
        end
    end
end

function DML:LogInfo(message)
    if self.config.logLevel >= 3 then
        if VUI.Print then
            VUI:Print("[ModuleLoader] " .. message)
        end
    end
end

function DML:LogWarning(message)
    if self.config.logLevel >= 2 then
        if VUI.Print then
            VUI:Print("|cffff9900[ModuleLoader Warning]|r " .. message)
        end
    end
end

function DML:LogError(message)
    if self.config.logLevel >= 1 then
        if VUI.Print then
            VUI:Print("|cffff0000[ModuleLoader Error]|r " .. message)
        end
    end
end

-- Initialize the module loading system
function DML:Initialize()
    -- Register with VUI if possible
    if VUI.RegisterSystem then
        VUI:RegisterSystem("DynamicModuleLoading", self)
    end
    
    -- Add helper to VUI namespace
    VUI.LoadModule = function(name)
        return self:LoadModule(name)
    end
    
    -- Add module access to VUI namespace
    VUI.GetModule = function(name)
        return self:GetModule(name)
    end
    
    self:LogInfo("Dynamic Module Loading system initialized")
end

-- Call initialize
DML:Initialize()

-- Return the module
return DML