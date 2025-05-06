local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end

-- Module API System
-- Provides standardized interfaces and utilities for addon modules
-- Handles registration, initialization, and communication between modules

-- Create namespace
VUI.ModuleAPI = {}
local ModAPI = VUI.ModuleAPI

-- State tracking
ModAPI.state = {
    registeredModules = {},     -- All registered modules
    enabledModules = {},        -- Currently enabled modules
    disabledModules = {},       -- Explicitly disabled modules
    moduleStatus = {},          -- Status tracking for each module
    moduleOrder = {},           -- Load/init order for modules
    loadedCount = 0,            -- Number of loaded modules
    enabledCount = 0,           -- Number of enabled modules
    disabledCount = 0,          -- Number of disabled modules
    defaultSettings = {},       -- Default settings for each module
    moduleVersions = {},        -- Version tracking
    dependencyMap = {},         -- Module dependencies
    moduleCallbacks = {},       -- Per-module callbacks
    globalCallbacks = {},       -- Global module callbacks
    globalHooks = {},           -- Global hook references
    initStartTime = 0,          -- When initialization started
    moduleTypes = {},           -- Module type classifications
    originalFunctions = {},     -- Original function references for hooks
}

-- Configuration
ModAPI.config = {
    autoEnableModules = true,   -- Auto-enable modules when registered
    saveModuleState = true,     -- Save enabled/disabled state
    logModuleActivity = true,   -- Log module registrations/state changes
    trackPerformance = true,    -- Track performance metrics
    enforceCompatibility = true, -- Enforce version compatibility
    allowUnsafeModules = false, -- Allow modules that fail safety checks
    silentMode = false,         -- Suppress notifications
}

-- Register a module with VUI
function ModAPI:RegisterModule(name, module, moduleType, version)
    if not name or not module then
        self:LogError("Invalid module registration: Missing name or module")
        return false
    end
    
    -- Check if already registered
    if self.state.registeredModules[name] then
        self:LogWarning("Module already registered: " .. name)
        return false
    end
    
    -- Setup defaults
    moduleType = moduleType or "addon"
    version = version or "1.0.0"
    
    -- Add state tracking
    self.state.registeredModules[name] = module
    self.state.moduleStatus[name] = "registered"
    self.state.moduleTypes[name] = moduleType
    self.state.moduleVersions[name] = version
    self.state.loadedCount = self.state.loadedCount + 1
    table.insert(self.state.moduleOrder, name)
    
    -- Register in settings if needed
    if VUI.db and VUI.db.profile and VUI.db.profile.modules and not VUI.db.profile.modules[name] then
        VUI.db.profile.modules[name] = {}
    end
    
    -- Auto-enable if configured
    if self.config.autoEnableModules then
        self:EnableModule(name)
    end
    
    -- Log the registration
    if self.config.logModuleActivity then
        self:LogInfo("Registered module: " .. name .. " (v" .. version .. ", type: " .. moduleType .. ")")
    end
    
    -- Trigger callbacks
    self:TriggerCallback("OnModuleRegistered", name, module, moduleType, version)
    
    return true
end

-- Enable a module
function ModAPI:EnableModule(name)
    if not name or not self.state.registeredModules[name] then
        self:LogError("Cannot enable unknown module: " .. tostring(name))
        return false
    end
    
    local module = self.state.registeredModules[name]
    
    -- Already enabled, no need to enable again
    if self.state.enabledModules[name] then
        return true
    end
    
    -- Remove from disabled list if present
    if self.state.disabledModules[name] then
        self.state.disabledModules[name] = nil
        self.state.disabledCount = self.state.disabledCount - 1
    end
    
    -- Call module's enable method if it exists
    local success, err
    if module.Enable then
        success, err = pcall(module.Enable, module)
    elseif module.OnEnable then
        success, err = pcall(module.OnEnable, module)
    else
        -- No enable method, just mark as enabled
        success = true
    end
    
    if success then
        -- Mark as enabled
        self.state.enabledModules[name] = module
        self.state.moduleStatus[name] = "enabled"
        self.state.enabledCount = self.state.enabledCount + 1
        
        -- Save state if configured
        if self.config.saveModuleState and VUI.db and VUI.db.profile and VUI.db.profile.modules then
            if not VUI.db.profile.modules[name] then VUI.db.profile.modules[name] = {} end
            VUI.db.profile.modules[name].enabled = true
        end
        
        -- Log the operation
        if self.config.logModuleActivity then
            self:LogInfo("Enabled module: " .. name)
        end
        
        -- Trigger callbacks
        self:TriggerCallback("OnModuleEnabled", name, module)
        
        return true
    else
        -- Failed to enable
        self.state.moduleStatus[name] = "failed"
        self:LogError("Failed to enable module: " .. name .. (err and (" - " .. err) or ""))
        
        -- Trigger error callback
        self:TriggerCallback("OnModuleError", name, module, "enable", err)
        
        return false
    end
end

-- Disable a module
function ModAPI:DisableModule(name)
    if not name or not self.state.registeredModules[name] then
        self:LogError("Cannot disable unknown module: " .. tostring(name))
        return false
    end
    
    local module = self.state.registeredModules[name]
    
    -- Already disabled, no need to disable again
    if self.state.disabledModules[name] then
        return true
    end
    
    -- Remove from enabled list if present
    if self.state.enabledModules[name] then
        self.state.enabledModules[name] = nil
        self.state.enabledCount = self.state.enabledCount - 1
    end
    
    -- Call module's disable method if it exists
    local success, err
    if module.Disable then
        success, err = pcall(module.Disable, module)
    elseif module.OnDisable then
        success, err = pcall(module.OnDisable, module)
    else
        -- No disable method, just mark as disabled
        success = true
    end
    
    -- Mark as disabled regardless of success
    self.state.disabledModules[name] = module
    self.state.moduleStatus[name] = "disabled"
    self.state.disabledCount = self.state.disabledCount + 1
    
    -- Save state if configured
    if self.config.saveModuleState and VUI.db and VUI.db.profile and VUI.db.profile.modules then
        if not VUI.db.profile.modules[name] then VUI.db.profile.modules[name] = {} end
        VUI.db.profile.modules[name].enabled = false
    end
    
    -- Log the operation
    if self.config.logModuleActivity then
        if success then
            self:LogInfo("Disabled module: " .. name)
        else
            self:LogWarning("Module partially disabled with errors: " .. name .. (err and (" - " .. err) or ""))
        end
    end
    
    -- Trigger callbacks
    self:TriggerCallback("OnModuleDisabled", name, module)
    
    return success
end

-- Toggle a module's state
function ModAPI:ToggleModule(name)
    if not name or not self.state.registeredModules[name] then
        self:LogError("Cannot toggle unknown module: " .. tostring(name))
        return false
    end
    
    if self.state.enabledModules[name] then
        return self:DisableModule(name)
    else
        return self:EnableModule(name)
    end
end

-- Check if a module is loaded
function ModAPI:IsModuleLoaded(name)
    return self.state.registeredModules[name] ~= nil
end

-- Check if a module is enabled
function ModAPI:IsModuleEnabled(name)
    return self.state.enabledModules[name] ~= nil
end

-- Get a module by name
function ModAPI:GetModule(name)
    return self.state.registeredModules[name]
end

-- Get module status
function ModAPI:GetModuleStatus(name)
    return self.state.moduleStatus[name] or "unknown"
end

-- Register default settings for a module
function ModAPI:RegisterDefaults(moduleName, defaults)
    if not moduleName or not defaults then
        return false
    end
    
    self.state.defaultSettings[moduleName] = defaults
    
    -- Apply defaults if the module exists in the database
    if VUI.db and VUI.db.profile and VUI.db.profile.modules and VUI.db.profile.modules[moduleName] then
        for k, v in pairs(defaults) do
            if VUI.db.profile.modules[moduleName][k] == nil then
                VUI.db.profile.modules[moduleName][k] = v
            end
        end
    end
    
    return true
end

-- Register dependencies for a module
function ModAPI:RegisterDependencies(moduleName, dependencies, optional)
    if not moduleName or not dependencies or type(dependencies) ~= "table" then
        return false
    end
    
    -- Initialize dependency map for this module
    if not self.state.dependencyMap[moduleName] then
        self.state.dependencyMap[moduleName] = {required = {}, optional = {}}
    end
    
    -- Add dependencies
    if optional then
        for _, dep in ipairs(dependencies) do
            table.insert(self.state.dependencyMap[moduleName].optional, dep)
        end
    else
        for _, dep in ipairs(dependencies) do
            table.insert(self.state.dependencyMap[moduleName].required, dep)
        end
    end
    
    return true
end

-- Register a callback for module events
function ModAPI:RegisterCallback(event, callback, moduleName)
    if not event or not callback then 
        return false 
    end
    
    if moduleName then
        -- Per-module callback
        if not self.state.moduleCallbacks[moduleName] then
            self.state.moduleCallbacks[moduleName] = {}
        end
        
        if not self.state.moduleCallbacks[moduleName][event] then
            self.state.moduleCallbacks[moduleName][event] = {}
        end
        
        table.insert(self.state.moduleCallbacks[moduleName][event], callback)
    else
        -- Global callback
        if not self.state.globalCallbacks[event] then
            self.state.globalCallbacks[event] = {}
        end
        
        table.insert(self.state.globalCallbacks[event], callback)
    end
    
    return true
end

-- Trigger callbacks for an event
function ModAPI:TriggerCallback(event, ...)
    -- First call global callbacks
    if self.state.globalCallbacks[event] then
        for _, callback in ipairs(self.state.globalCallbacks[event]) do
            local success, err = pcall(callback, ...)
            if not success and not self.config.silentMode then
                self:LogError("Error in global callback for " .. event .. ": " .. (err or "unknown error"))
            end
        end
    end
    
    -- Then call module-specific callbacks if this event pertains to a module
    local moduleName = ...
    if moduleName and self.state.moduleCallbacks[moduleName] and self.state.moduleCallbacks[moduleName][event] then
        for _, callback in ipairs(self.state.moduleCallbacks[moduleName][event]) do
            local success, err = pcall(callback, ...)
            if not success and not self.config.silentMode then
                self:LogError("Error in module callback for " .. moduleName .. "." .. event .. ": " .. (err or "unknown error"))
            end
        end
    end
end

-- Hook a function in a module
function ModAPI:HookFunction(moduleName, functionName, hook, secure)
    if not moduleName or not functionName or not hook then
        return false
    end
    
    local module = self:GetModule(moduleName)
    if not module then
        self:LogError("Cannot hook function in unknown module: " .. moduleName)
        return false
    end
    
    -- Check if the function exists
    if type(module[functionName]) ~= "function" then
        self:LogError("Function does not exist in module: " .. moduleName .. "." .. functionName)
        return false
    end
    
    -- Store original function reference
    if not self.state.originalFunctions[moduleName] then
        self.state.originalFunctions[moduleName] = {}
    end
    
    -- Only store the original if we haven't hooked it before
    if not self.state.originalFunctions[moduleName][functionName] then
        self.state.originalFunctions[moduleName][functionName] = module[functionName]
    end
    
    local originalFunc = self.state.originalFunctions[moduleName][functionName]
    
    -- Create hook function
    if secure then
        -- Secure hook: Call original function first, then hook
        module[functionName] = function(...)
            local result = {originalFunc(...)}
            hook(...)
            return unpack(result)
        end
    else
        -- Regular hook: Allow hook to modify behavior
        module[functionName] = function(...)
            return hook(originalFunc, ...)
        end
    end
    
    -- Track the hook
    if not self.state.globalHooks[moduleName] then
        self.state.globalHooks[moduleName] = {}
    end
    
    self.state.globalHooks[moduleName][functionName] = hook
    
    return true
end

-- Unhook a function in a module
function ModAPI:UnhookFunction(moduleName, functionName)
    if not moduleName or not functionName then
        return false
    end
    
    local module = self:GetModule(moduleName)
    if not module then
        self:LogError("Cannot unhook function in unknown module: " .. moduleName)
        return false
    end
    
    -- Check if we have stored the original function
    if not self.state.originalFunctions[moduleName] or not self.state.originalFunctions[moduleName][functionName] then
        self:LogWarning("Function was not hooked: " .. moduleName .. "." .. functionName)
        return false
    end
    
    -- Restore original function
    module[functionName] = self.state.originalFunctions[moduleName][functionName]
    
    -- Remove hook tracking
    if self.state.globalHooks[moduleName] then
        self.state.globalHooks[moduleName][functionName] = nil
    end
    
    -- Clean up original function reference
    self.state.originalFunctions[moduleName][functionName] = nil
    
    return true
end

-- Initialize all modules
function ModAPI:InitializeAllModules()
    -- Record start time for performance tracking
    self.state.initStartTime = debugprofilestop()
    
    -- Trigger pre-initialization callback
    self:TriggerCallback("OnBeforeModulesInitialized")
    
    -- Initialize each module in the order they were registered
    for _, name in ipairs(self.state.moduleOrder) do
        local module = self.state.registeredModules[name]
        
        if module then
            -- Check if we should initialize this module
            local shouldInit = true
            
            -- Check dependencies
            if self.state.dependencyMap[name] and self.state.dependencyMap[name].required then
                for _, dep in ipairs(self.state.dependencyMap[name].required) do
                    if not self:IsModuleLoaded(dep) then
                        self:LogWarning("Module " .. name .. " missing required dependency: " .. dep)
                        shouldInit = false
                        break
                    end
                end
            end
            
            if shouldInit then
                -- Call module's initialize method if it exists
                if module.Initialize then
                    local success, err = pcall(module.Initialize, module)
                    if not success then
                        self.state.moduleStatus[name] = "error"
                        self:LogError("Failed to initialize module: " .. name .. " - " .. (err or "unknown error"))
                        
                        -- Trigger error callback
                        self:TriggerCallback("OnModuleError", name, module, "initialize", err)
                    else
                        self.state.moduleStatus[name] = "initialized"
                        
                        -- Auto-enable if configured and not explicitly disabled
                        if self.config.autoEnableModules and not self.state.disabledModules[name] then
                            self:EnableModule(name)
                        end
                    end
                elseif module.OnInitialize then
                    local success, err = pcall(module.OnInitialize, module)
                    if not success then
                        self.state.moduleStatus[name] = "error"
                        self:LogError("Failed to initialize module: " .. name .. " - " .. (err or "unknown error"))
                        
                        -- Trigger error callback
                        self:TriggerCallback("OnModuleError", name, module, "initialize", err)
                    else
                        self.state.moduleStatus[name] = "initialized"
                        
                        -- Auto-enable if configured and not explicitly disabled
                        if self.config.autoEnableModules and not self.state.disabledModules[name] then
                            self:EnableModule(name)
                        end
                    end
                else
                    -- No initialize method, just mark as initialized
                    self.state.moduleStatus[name] = "initialized"
                    
                    -- Auto-enable if configured and not explicitly disabled
                    if self.config.autoEnableModules and not self.state.disabledModules[name] then
                        self:EnableModule(name)
                    end
                end
            else
                -- Skip initialization due to missing dependencies
                self.state.moduleStatus[name] = "skipped"
                self:LogWarning("Skipped initialization of module due to missing dependencies: " .. name)
            end
        end
    end
    
    -- Trigger post-initialization callback
    self:TriggerCallback("OnModulesInitialized")
    
    -- Log performance
    if self.config.trackPerformance then
        local initTime = debugprofilestop() - self.state.initStartTime
        self:LogInfo("Initialized " .. self.state.loadedCount .. " modules in " .. string.format("%.2fms", initTime))
    end
    
    return true
end

-- Get statistics for module system
function ModAPI:GetStats()
    local stats = {
        registered = self.state.loadedCount,
        enabled = self.state.enabledCount,
        disabled = self.state.disabledCount,
        types = {},
        status = {},
        initTime = (debugprofilestop() - self.state.initStartTime),
    }
    
    -- Count modules by type
    for name, moduleType in pairs(self.state.moduleTypes) do
        stats.types[moduleType] = (stats.types[moduleType] or 0) + 1
    end
    
    -- Count modules by status
    for name, status in pairs(self.state.moduleStatus) do
        stats.status[status] = (stats.status[status] or 0) + 1
    end
    
    return stats
end

-- Logging methods
function ModAPI:LogInfo(message)
    if VUI.Debug then
        VUI:Debug("[ModuleAPI] " .. message)
    end
end

function ModAPI:LogWarning(message)
    if VUI.Print then
        VUI:Print("|cffff9900[ModuleAPI Warning]|r " .. message)
    end
end

function ModAPI:LogError(message)
    if VUI.Print then
        VUI:Print("|cffff0000[ModuleAPI Error]|r " .. message)
    end
end

-- Register the ModuleAPI with VUI
function ModAPI:Initialize()
    VUI.RegisterModule = function(name, module, moduleType, version)
        return ModAPI:RegisterModule(name, module, moduleType, version)
    end
    
    VUI.GetModule = function(name)
        return ModAPI:GetModule(name)
    end
    
    VUI.InitializeModules = function()
        return ModAPI:InitializeAllModules()
    end
    
    if VUI.RegisterSystem then
        VUI:RegisterSystem("ModuleAPI", self)
    end
    
    self:LogInfo("Module API system initialized")
end

-- Initialize on load
ModAPI:Initialize()

-- Return the module
return ModAPI