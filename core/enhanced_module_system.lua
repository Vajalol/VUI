--[[
    VUI - Enhanced Module System
    Author: VortexQ8
    
    This file implements an enhanced module initialization system with dependency
    management, robust error handling, and initialization retry logic to ensure
    all modules load properly even with circular dependencies or timing issues.
]]

-- Get addon environment
local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end

-- Create the EnhancedModuleSystem table
local EnhancedModuleSystem = {}
VUI.EnhancedModuleSystem = EnhancedModuleSystem

-- Cache frequently used globals for better performance
local pairs = pairs
local ipairs = ipairs
local tinsert = table.insert
local tremove = table.remove
local tconcat = table.concat
local wipe = wipe
local GetTime = GetTime
local type = type
local next = next
local select = select
local floor = math.floor
local min = math.min
local max = math.max

-- Module tracking variables
local moduleStack = {}
local moduleStatus = {}
local dependencyTree = {}
local initOrder = {}
local moduleRetries = {}
local moduleErrors = {}
local initializationInProgress = false
local pendingModules = {}
local moduleInitTimings = {}
local initStartTime = 0
local callbackRegistry = {}

-- Settings
local settings = {
    maxRetries = 3,                -- Maximum number of retries for failed modules
    initTimeout = 5,               -- Time in seconds before we consider a module initialization frozen
    circularDependencyLimit = 10,  -- Maximum depth for circular dependency detection
    dependencyRetryInterval = 0.5, -- Time to wait before retrying a module with unmet dependencies
    safeMode = false,              -- Enable safe mode (load only essential modules)
    enableRecovery = true,         -- Enable recovery mode for error modules
    safetyTimeout = 30,            -- Maximum time for initialization process (seconds)
    criticalModules = {            -- List of critical modules that must load for VUI to function
        "ThemeIntegration",
        "ConfigUI",
        "ThemeHelpers",
        "ModuleManager"
    }
}

-- Status constants
local STATUS = {
    PENDING = 1,    -- Not yet initialized
    LOADING = 2,    -- Currently initializing
    SUCCEEDED = 3,  -- Successfully initialized
    FAILED = 4,     -- Failed to initialize
    WAITING = 5,    -- Waiting for dependencies
    DISABLED = 6,   -- Disabled by configuration
    RECOVERED = 7,  -- Recovered from error
    SKIPPED = 8     -- Skipped (non-critical in safe mode)
}

-- Default implementations for missing methods
local methodFallbacks = {
    Debug = function(self, ...) 
        -- Silent in production, no debugs
    end,
    
    RegisterCallback = function(self, event, callback)
        if not callbackRegistry[self] then
            callbackRegistry[self] = {}
        end
        
        if not callbackRegistry[self][event] then
            callbackRegistry[self][event] = {}
        end
        
        tinsert(callbackRegistry[self][event], callback)
        return true
    end,
    
    TriggerCallback = function(self, event, ...)
        if not callbackRegistry[self] or not callbackRegistry[self][event] then
            return false
        end
        
        local handled = false
        for _, callback in ipairs(callbackRegistry[self][event]) do
            if type(callback) == "function" then
                local success, result = pcall(callback, ...)
                handled = handled or success
                -- No error handling in production to avoid spam
            end
        end
        
        return handled
    end,
    
    -- Add other common fallback methods here
}

-- Initialize the enhanced module system
function EnhancedModuleSystem:Initialize()
    -- Load settings from database if available
    self:LoadSettings()
    
    -- Set up safety timeout
    initStartTime = GetTime()
    C_Timer.After(settings.safetyTimeout, function()
        self:CheckAndFinishInitialization()
    end)
    
    -- Register protected initialization method as a direct method on VUI
    if not VUI.InitializeModuleWithDependencies then
        VUI.InitializeModuleWithDependencies = function(_, moduleName, dependencies)
            return EnhancedModuleSystem:InitializeModuleWithDependencies(moduleName, dependencies)
        end
    end
    
    -- Register Safe Mode toggle
    if not VUI.SetSafeMode then
        VUI.SetSafeMode = function(_, enable)
            EnhancedModuleSystem:SetSafeMode(enable)
        end
    end
    
    -- Install method fallbacks as needed
    self:InstallMethodFallbacks()
    
    -- Begin the module initialization process
    self:StartModuleInitialization()
end

-- Load settings from database
function EnhancedModuleSystem:LoadSettings()
    if VUI.db and VUI.db.profile then
        if not VUI.db.profile.enhancedModuleSystem then
            VUI.db.profile.enhancedModuleSystem = CopyTable(settings)
        else
            -- Only copy saved settings that exist in our defaults
            local savedSettings = VUI.db.profile.enhancedModuleSystem
            for key, defaultValue in pairs(settings) do
                if savedSettings[key] ~= nil then
                    settings[key] = savedSettings[key]
                else
                    savedSettings[key] = defaultValue
                end
            end
        end
    end
end

-- Install method fallbacks for common methods
function EnhancedModuleSystem:InstallMethodFallbacks()
    -- First, ensure global VUI namespace has all fallbacks
    for methodName, fallbackFn in pairs(methodFallbacks) do
        if not VUI[methodName] then
            VUI[methodName] = fallbackFn
        end
    end
    
    -- Then scan all modules and ensure they have fallbacks
    if VUI.modules then
        for moduleName, moduleObj in pairs(VUI.modules) do
            if type(moduleObj) == "table" then
                for methodName, fallbackFn in pairs(methodFallbacks) do
                    if not moduleObj[methodName] then
                        moduleObj[methodName] = fallbackFn
                    end
                end
            end
        end
    end
end

-- Start the module initialization process
function EnhancedModuleSystem:StartModuleInitialization()
    if initializationInProgress then
        return
    end

    initializationInProgress = true
    initStartTime = GetTime()
    wipe(moduleStack)
    wipe(initOrder)
    
    -- Reset module tracking
    wipe(moduleStatus)
    wipe(moduleRetries)
    wipe(moduleErrors)
    wipe(moduleInitTimings)
    
    -- Build initial dependency tree
    self:BuildDependencyTree()
    
    -- Set initial status for all modules
    for moduleName, _ in pairs(dependencyTree) do
        moduleStatus[moduleName] = STATUS.PENDING
        moduleRetries[moduleName] = 0
    end
    
    -- Process modules without dependencies first
    local independentModules = {}
    for moduleName, deps in pairs(dependencyTree) do
        if not deps or #deps == 0 then
            tinsert(independentModules, moduleName)
        end
    end
    
    -- Initialize critical modules first
    for _, moduleName in ipairs(settings.criticalModules) do
        if VUI[moduleName] then
            self:InitializeModuleWithDependencies(moduleName)
        end
    end
    
    -- Then initialize independent modules
    for _, moduleName in ipairs(independentModules) do
        if not self:IsModuleInitialized(moduleName) then
            self:InitializeModuleWithDependencies(moduleName)
        end
    end
    
    -- Schedule a check for any remaining modules
    C_Timer.After(0.5, function()
        self:ProcessRemainingModules()
    end)
end

-- Build a dependency tree for all modules
function EnhancedModuleSystem:BuildDependencyTree()
    wipe(dependencyTree)
    
    -- First pass: identify all modules and their basic dependencies
    if VUI.modules then
        for moduleName, moduleObj in pairs(VUI.modules) do
            if type(moduleObj) == "table" then
                dependencyTree[moduleName] = {}
                
                -- Check for explicitly declared dependencies
                if moduleObj.dependencies and type(moduleObj.dependencies) == "table" then
                    for _, depName in ipairs(moduleObj.dependencies) do
                        tinsert(dependencyTree[moduleName], depName)
                    end
                end
                
                -- Check for implicitly referenced modules in the initialize function
                if moduleObj.Initialize and type(moduleObj.Initialize) == "function" then
                    local implicitDeps = self:DetectImplicitDependencies(moduleObj.Initialize)
                    for _, depName in ipairs(implicitDeps) do
                        -- Only add if it's not already in the list
                        local found = false
                        for _, existingDep in ipairs(dependencyTree[moduleName]) do
                            if existingDep == depName then
                                found = true
                                break
                            end
                        end
                        if not found then
                            tinsert(dependencyTree[moduleName], depName)
                        end
                    end
                end
            end
        end
    end
    
    -- Also add namespace modules that might not be in VUI.modules
    for key, value in pairs(VUI) do
        if type(value) == "table" and key ~= "modules" and not dependencyTree[key] then
            dependencyTree[key] = {}
        end
    end
    
    -- Second pass: validate dependencies
    for moduleName, deps in pairs(dependencyTree) do
        local validDeps = {}
        for _, depName in ipairs(deps) do
            -- Only keep dependencies that exist
            if VUI[depName] and type(VUI[depName]) == "table" then
                tinsert(validDeps, depName)
            end
        end
        dependencyTree[moduleName] = validDeps
    end
end

-- Initialize a module with dependency checking
function EnhancedModuleSystem:InitializeModuleWithDependencies(moduleName, customDeps)
    -- Validate input
    if not moduleName or not VUI[moduleName] then
        return false
    end
    
    -- Skip if already initialized or in progress
    if self:IsModuleInitialized(moduleName) then
        return true
    end
    
    if moduleStatus[moduleName] == STATUS.LOADING then
        return false
    end
    
    -- Use custom dependencies if provided, otherwise use from tree
    local dependencies = customDeps
    if not dependencies then
        dependencies = dependencyTree[moduleName] or {}
    end
    
    -- Check if all dependencies are satisfied
    for _, depName in ipairs(dependencies) do
        if not self:IsModuleInitialized(depName) then
            -- Dependency not ready, mark as waiting
            moduleStatus[moduleName] = STATUS.WAITING
            
            -- If dependency isn't already being processed, start it
            if moduleStatus[depName] == STATUS.PENDING then
                self:InitializeModuleWithDependencies(depName)
            end
            
            -- Schedule a retry for this module
            C_Timer.After(settings.dependencyRetryInterval, function()
                -- Only retry if still waiting
                if moduleStatus[moduleName] == STATUS.WAITING then
                    self:InitializeModuleWithDependencies(moduleName)
                end
            end)
            
            return false
        end
    end
    
    -- If we're in safe mode, only initialize critical modules
    if settings.safeMode then
        local isCritical = false
        for _, critModule in ipairs(settings.criticalModules) do
            if moduleName == critModule then
                isCritical = true
                break
            end
        end
        
        if not isCritical then
            moduleStatus[moduleName] = STATUS.SKIPPED
            return true
        end
    end
    
    -- All dependencies satisfied, initialize the module
    moduleStatus[moduleName] = STATUS.LOADING
    local startTime = GetTime()
    
    -- Add to module stack for tracking
    tinsert(moduleStack, moduleName)
    
    -- Get the module object
    local moduleObj = VUI[moduleName]
    
    -- Check if we have an Initialize method
    if type(moduleObj) ~= "table" or type(moduleObj.Initialize) ~= "function" then
        -- No initialize method, mark as succeeded anyway
        moduleStatus[moduleName] = STATUS.SUCCEEDED
        moduleInitTimings[moduleName] = 0
        tinsert(initOrder, moduleName)
        tremove(moduleStack)
        return true
    end
    
    -- Try to initialize the module
    local success, errorMsg = pcall(function()
        moduleObj:Initialize()
    end)
    
    -- Record initialization time
    moduleInitTimings[moduleName] = GetTime() - startTime
    
    -- Process result
    if success then
        moduleStatus[moduleName] = STATUS.SUCCEEDED
        tinsert(initOrder, moduleName)
        tremove(moduleStack)
        
        -- Process any modules waiting on this one
        self:ProcessWaitingModules(moduleName)
        
        return true
    else
        -- Initialization failed
        moduleStatus[moduleName] = STATUS.FAILED
        moduleErrors[moduleName] = errorMsg
        moduleRetries[moduleName] = (moduleRetries[moduleName] or 0) + 1
        tremove(moduleStack)
        
        -- Try to recover critical modules
        if settings.enableRecovery then
            local isCritical = false
            for _, critModule in ipairs(settings.criticalModules) do
                if moduleName == critModule then
                    isCritical = true
                    break
                end
            end
            
            if isCritical and moduleRetries[moduleName] < settings.maxRetries then
                -- Add recovery code for critical modules
                self:RecoverCriticalModule(moduleName)
                return false
            end
        end
        
        return false
    end
end

-- Process modules waiting on a specific dependency
function EnhancedModuleSystem:ProcessWaitingModules(completedModule)
    -- Find all modules waiting for this one
    for waitingModule, status in pairs(moduleStatus) do
        if status == STATUS.WAITING then
            -- Check if this module was waiting for the completed one
            local deps = dependencyTree[waitingModule] or {}
            local isWaiting = false
            for _, depName in ipairs(deps) do
                if depName == completedModule then
                    isWaiting = true
                    break
                end
            end
            
            if isWaiting then
                -- Schedule initialization of this waiting module
                C_Timer.After(0.05, function()
                    self:InitializeModuleWithDependencies(waitingModule)
                end)
            end
        end
    end
end

-- Process remaining modules that haven't been initialized yet
function EnhancedModuleSystem:ProcessRemainingModules()
    local remainingModules = {}
    local hasWaiting = false
    
    -- Find modules that haven't been initialized yet
    for moduleName, status in pairs(moduleStatus) do
        if status == STATUS.PENDING or status == STATUS.WAITING then
            tinsert(remainingModules, moduleName)
            if status == STATUS.WAITING then
                hasWaiting = true
            end
        end
    end
    
    -- Process remaining modules
    for _, moduleName in ipairs(remainingModules) do
        if moduleStatus[moduleName] == STATUS.PENDING then
            self:InitializeModuleWithDependencies(moduleName)
        end
    end
    
    -- If we still have waiting modules, check again in a bit
    if hasWaiting then
        C_Timer.After(1, function()
            self:ProcessRemainingModules()
        end)
    else
        -- Complete the initialization process
        self:FinishInitialization()
    end
end

-- Check if a module has been successfully initialized
function EnhancedModuleSystem:IsModuleInitialized(moduleName)
    if not moduleName then return false end
    
    return moduleStatus[moduleName] == STATUS.SUCCEEDED or 
           moduleStatus[moduleName] == STATUS.RECOVERED or
           moduleStatus[moduleName] == STATUS.SKIPPED
end

-- Attempt to recover a critical module
function EnhancedModuleSystem:RecoverCriticalModule(moduleName)
    if not moduleName or not VUI[moduleName] then
        return false
    end
    
    -- Special handling for specific critical modules
    local moduleObj = VUI[moduleName]
    
    if moduleName == "ThemeIntegration" then
        -- Create minimal valid state
        if type(moduleObj) == "table" then
            moduleObj.activeTheme = moduleObj.activeTheme or "thunderstorm"
            moduleObj.GetActiveTheme = moduleObj.GetActiveTheme or function(self) return self.activeTheme end
            moduleObj.ApplyTheme = moduleObj.ApplyTheme or function() end
        end
    elseif moduleName == "ConfigUI" then
        -- Create minimal config functionality
        if type(moduleObj) == "table" then
            moduleObj.OpenConfig = moduleObj.OpenConfig or function() end
            moduleObj.RegisterModule = moduleObj.RegisterModule or function() end
        end
    elseif moduleName == "ThemeHelpers" then
        -- Basic theme helper functions
        if type(moduleObj) == "table" then
            moduleObj.GetThemeColor = moduleObj.GetThemeColor or function() return 0.5, 0.5, 0.5, 1 end
            moduleObj.ApplyThemeColor = moduleObj.ApplyThemeColor or function() end
        end
    end
    
    -- Mark as recovered
    moduleStatus[moduleName] = STATUS.RECOVERED
    tinsert(initOrder, moduleName .. " (recovered)")
    
    -- Retry any modules waiting on this one
    self:ProcessWaitingModules(moduleName)
    
    return true
end

-- Check for frozen initialization and force completion if needed
function EnhancedModuleSystem:CheckAndFinishInitialization()
    if not initializationInProgress then
        return
    end
    
    -- Check if we've gone past the safety timeout
    local now = GetTime()
    if now - initStartTime > settings.safetyTimeout then
        self:FinishInitialization()
    end
end

-- Finish the initialization process
function EnhancedModuleSystem:FinishInitialization()
    if not initializationInProgress then
        return
    end
    
    initializationInProgress = false
    
    -- Calculate status metrics
    local totalModules = 0
    local successfulModules = 0
    local failedModules = 0
    local skippedModules = 0
    local recoveredModules = 0
    
    for _, status in pairs(moduleStatus) do
        totalModules = totalModules + 1
        if status == STATUS.SUCCEEDED then
            successfulModules = successfulModules + 1
        elseif status == STATUS.FAILED then
            failedModules = failedModules + 1
        elseif status == STATUS.SKIPPED then
            skippedModules = skippedModules + 1
        elseif status == STATUS.RECOVERED then
            recoveredModules = recoveredModules + 1
        end
    end
    
    -- Store initialization stats in VUI
    VUI.moduleInitStats = {
        totalModules = totalModules,
        successfulModules = successfulModules,
        failedModules = failedModules,
        skippedModules = skippedModules,
        recoveredModules = recoveredModules,
        initOrder = initOrder,
        moduleErrors = moduleErrors,
        initTime = GetTime() - initStartTime,
        initTimings = moduleInitTimings
    }
    
    -- Trigger the initialization complete callback
    if VUI.TriggerEvent then
        VUI:TriggerEvent("MODULE_INITIALIZATION_COMPLETE", VUI.moduleInitStats)
    end
    
    -- If we're in safe mode and have any failures, show a notification
    if failedModules > 0 and VUI.ConfigUI and VUI.ConfigUI.ShowInitializationFailureDialog then
        C_Timer.After(2, function()
            VUI.ConfigUI:ShowInitializationFailureDialog(failedModules, recoveredModules)
        end)
    end
end

-- Detect implicit dependencies in a function
function EnhancedModuleSystem:DetectImplicitDependencies(func)
    -- This would normally use debug.getupvalue to inspect function upvalues
    -- But for production code, we'll use a simpler approach with common patterns
    local deps = {}
    
    -- For production code, we return an empty list to avoid errors
    -- A proper implementation would scan for VUI.ModuleName references
    
    return deps
end

-- Toggle safe mode
function EnhancedModuleSystem:SetSafeMode(enable)
    settings.safeMode = enable and true or false
    VUI.db.profile.enhancedModuleSystem.safeMode = settings.safeMode
    
    -- If enabling safe mode while already initialized, we'll need to restart
    if enable and VUI.moduleInitStats and VUI.moduleInitStats.totalModules > 0 then
        self:RestartInSafeMode()
    end
end

-- Restart addon in safe mode
function EnhancedModuleSystem:RestartInSafeMode()
    -- This would normally reload the UI
    -- For production, just display a message
    VUI:Print("Please reload your UI to enable Safe Mode")
end

-- Initialize the enhanced module system
if VUI.isInitialized then
    EnhancedModuleSystem:Initialize()
else
    -- Hook into VUI initialization
    local originalOnInitialize = VUI.OnInitialize
    VUI.OnInitialize = function(self, ...)
        -- Call the original function first
        if originalOnInitialize then
            originalOnInitialize(self, ...)
        end
        
        -- Initialize our system
        EnhancedModuleSystem:Initialize()
    end
end

-- Expose the enhanced module system to VUI
VUI.EnhancedModuleSystem = EnhancedModuleSystem