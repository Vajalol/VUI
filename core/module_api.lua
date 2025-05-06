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
    initErrors = {},            -- Track initialization errors
    retryAttempts = {},         -- Track retry attempts for modules
    initSequence = {},          -- Track initialization sequence
    initTimes = {},             -- Time taken to initialize each module
    templateApplied = {},       -- Modules that have template applied
    initStarted = {},           -- Modules where initialization has started
    initFinished = {},          -- Modules where initialization has completed
    dependencyState = {},       -- Track dependency state during initialization
    safetyCheck = {},           -- Results of safety checks on modules
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
    maxRetryAttempts = 3,       -- Maximum number of retry attempts
    autoRetry = true,           -- Automatically retry failed modules
    dbInitCheck = true,         -- Verify database initialization
    enforceTemplate = true,     -- Enforce module template application
    dependencyTimeout = 5,      -- Dependency resolution timeout (seconds)
    safeModeFallback = true,    -- Allow fallbacks for critical errors
    validateDB = true,          -- Validate database structure
}

-- Helper function to normalize module names for standardization
function ModAPI:NormalizeModuleName(name)
    local nameLower = string.lower(name)
    local nameCamel = name
    
    -- Convert first letter to uppercase and rest to lowercase for camelCase
    if #name > 0 then
        nameCamel = string.upper(string.sub(name, 1, 1)) .. string.lower(string.sub(name, 2))
    end
    
    return nameLower, nameCamel
end

-- Register a module with VUI
function ModAPI:RegisterModule(name, module, moduleType, version)
    if not name or not module then
        self:LogError("Invalid module registration: Missing name or module")
        return false
    end
    
    -- Get standardized versions of the name (lowercase and camelCase)
    local nameLower, nameCamel = self:NormalizeModuleName(name)
    
    -- Check if already registered under any name variant
    if self.state.registeredModules[name] or 
       self.state.registeredModules[nameLower] or 
       self.state.registeredModules[nameCamel] then
        self:LogWarning("Module already registered: " .. name)
        return false
    end
    
    -- Setup defaults
    moduleType = moduleType or "addon"
    version = version or "1.0.0"
    
    -- Add state tracking using the provided name
    self.state.registeredModules[name] = module
    self.state.moduleStatus[name] = "registered"
    self.state.moduleTypes[name] = moduleType
    self.state.moduleVersions[name] = version
    self.state.loadedCount = self.state.loadedCount + 1
    table.insert(self.state.moduleOrder, name)
    
    -- Also register standardized camelCase version if different
    if name ~= nameCamel then
        self.state.registeredModules[nameCamel] = module
        self.state.moduleStatus[nameCamel] = "registered"
        self.state.moduleTypes[nameCamel] = moduleType
        self.state.moduleVersions[nameCamel] = version
    end
    
    -- Also register lowercase version if different from original and camelCase
    if name ~= nameLower and nameCamel ~= nameLower then
        self.state.registeredModules[nameLower] = module
        self.state.moduleStatus[nameLower] = "registered"
        self.state.moduleTypes[nameLower] = moduleType
        self.state.moduleVersions[nameLower] = version
    end
    
    -- Set up the module in all named versions in the VUI namespace
    VUI[name] = module
    if name ~= nameCamel then
        VUI[nameCamel] = module
    end
    if name ~= nameLower and nameCamel ~= nameLower then
        VUI[nameLower] = module
    end
    
    -- Register in settings if needed
    if VUI.db and VUI.db.profile and VUI.db.profile.modules then
        if not VUI.db.profile.modules[name] then
            VUI.db.profile.modules[name] = {}
        end
        
        -- Ensure settings are accessible via standardized name too
        if name ~= nameLower then
            VUI.db.profile.modules[nameLower] = VUI.db.profile.modules[name]
        end
        if name ~= nameCamel then
            VUI.db.profile.modules[nameCamel] = VUI.db.profile.modules[name]
        end
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
    if not name then
        self:LogError("Cannot enable module with nil name")
        return false
    end
    
    -- Get standardized versions of the name (lowercase and camelCase)
    local nameLower, nameCamel = self:NormalizeModuleName(name)
    local moduleName = name
    
    -- Find the module under any of its name variants
    if not self.state.registeredModules[name] then
        if self.state.registeredModules[nameLower] then
            moduleName = nameLower
        elseif self.state.registeredModules[nameCamel] then
            moduleName = nameCamel
        else
            self:LogError("Cannot enable unknown module: " .. tostring(name))
            return false
        end
    end
    
    local module = self.state.registeredModules[moduleName]
    
    -- Already enabled, no need to enable again
    if self.state.enabledModules[moduleName] then
        return true
    end
    
    -- Remove from disabled list if present - check all possible name variants
    if self.state.disabledModules[name] then
        self.state.disabledModules[name] = nil
        self.state.disabledCount = self.state.disabledCount - 1
    end
    if name ~= nameLower and self.state.disabledModules[nameLower] then
        self.state.disabledModules[nameLower] = nil
        self.state.disabledCount = self.state.disabledCount - 1
    end
    if name ~= nameCamel and nameLower ~= nameCamel and self.state.disabledModules[nameCamel] then
        self.state.disabledModules[nameCamel] = nil
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
        -- Mark as enabled in all name variants
        self.state.enabledModules[name] = module
        self.state.moduleStatus[name] = "enabled"
        
        -- Also register with camelCase and lowercase if necessary
        if name ~= nameCamel then
            self.state.enabledModules[nameCamel] = module
            self.state.moduleStatus[nameCamel] = "enabled"
        end
        if name ~= nameLower and nameCamel ~= nameLower then
            self.state.enabledModules[nameLower] = module
            self.state.moduleStatus[nameLower] = "enabled"
        end
        
        self.state.enabledCount = self.state.enabledCount + 1
        
        -- Save state if configured
        if self.config.saveModuleState and VUI.db and VUI.db.profile and VUI.db.profile.modules then
            -- Make sure all name variants have the same settings
            if not VUI.db.profile.modules[name] then VUI.db.profile.modules[name] = {} end
            VUI.db.profile.modules[name].enabled = true
            
            if name ~= nameLower then
                if not VUI.db.profile.modules[nameLower] then VUI.db.profile.modules[nameLower] = {} end
                VUI.db.profile.modules[nameLower].enabled = true
                VUI.db.profile.modules[nameLower] = VUI.db.profile.modules[name] -- Reference same table
            end
            
            if name ~= nameCamel and nameLower ~= nameCamel then
                if not VUI.db.profile.modules[nameCamel] then VUI.db.profile.modules[nameCamel] = {} end
                VUI.db.profile.modules[nameCamel].enabled = true
                VUI.db.profile.modules[nameCamel] = VUI.db.profile.modules[name] -- Reference same table
            end
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
    if not name then
        self:LogError("Cannot disable module with nil name")
        return false
    end
    
    -- Get standardized versions of the name (lowercase and camelCase)
    local nameLower, nameCamel = self:NormalizeModuleName(name)
    local moduleName = name
    
    -- Find the module under any of its name variants
    if not self.state.registeredModules[name] then
        if self.state.registeredModules[nameLower] then
            moduleName = nameLower
        elseif self.state.registeredModules[nameCamel] then
            moduleName = nameCamel
        else
            self:LogError("Cannot disable unknown module: " .. tostring(name))
            return false
        end
    end
    
    local module = self.state.registeredModules[moduleName]
    
    -- Already disabled, no need to disable again
    if self.state.disabledModules[moduleName] then
        return true
    end
    
    -- Remove from enabled list if present - check all possible name variants
    if self.state.enabledModules[name] then
        self.state.enabledModules[name] = nil
    end
    if name ~= nameLower and self.state.enabledModules[nameLower] then
        self.state.enabledModules[nameLower] = nil
    end
    if name ~= nameCamel and nameLower ~= nameCamel and self.state.enabledModules[nameCamel] then
        self.state.enabledModules[nameCamel] = nil
    end
    
    self.state.enabledCount = self.state.enabledCount - 1
    
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
    
    -- Mark as disabled in all name variants
    self.state.disabledModules[name] = module
    self.state.moduleStatus[name] = "disabled"
    
    -- Also disable with camelCase and lowercase if necessary
    if name ~= nameCamel then
        self.state.disabledModules[nameCamel] = module
        self.state.moduleStatus[nameCamel] = "disabled"
    end
    if name ~= nameLower and nameCamel ~= nameLower then
        self.state.disabledModules[nameLower] = module
        self.state.moduleStatus[nameLower] = "disabled"
    end
    
    self.state.disabledCount = self.state.disabledCount + 1
    
    -- Save state if configured
    if self.config.saveModuleState and VUI.db and VUI.db.profile and VUI.db.profile.modules then
        -- Make sure all name variants have the same settings
        if not VUI.db.profile.modules[name] then VUI.db.profile.modules[name] = {} end
        VUI.db.profile.modules[name].enabled = false
        
        if name ~= nameLower then
            if not VUI.db.profile.modules[nameLower] then VUI.db.profile.modules[nameLower] = {} end
            VUI.db.profile.modules[nameLower].enabled = false
            VUI.db.profile.modules[nameLower] = VUI.db.profile.modules[name] -- Reference same table
        end
        
        if name ~= nameCamel and nameLower ~= nameCamel then
            if not VUI.db.profile.modules[nameCamel] then VUI.db.profile.modules[nameCamel] = {} end
            VUI.db.profile.modules[nameCamel].enabled = false
            VUI.db.profile.modules[nameCamel] = VUI.db.profile.modules[name] -- Reference same table
        end
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
    if not name then
        self:LogError("Cannot toggle module with nil name")
        return false
    end
    
    -- Get standardized versions of the name (lowercase and camelCase)
    local nameLower, nameCamel = self:NormalizeModuleName(name)
    local moduleName = name
    
    -- Find the module under any of its name variants
    if not self.state.registeredModules[name] then
        if self.state.registeredModules[nameLower] then
            moduleName = nameLower
        elseif self.state.registeredModules[nameCamel] then
            moduleName = nameCamel
        else
            self:LogError("Cannot toggle unknown module: " .. tostring(name))
            return false
        end
    end
    
    -- Check if the module is enabled under any of its name variants
    if self.state.enabledModules[name] or 
       self.state.enabledModules[nameLower] or 
       self.state.enabledModules[nameCamel] then
        return self:DisableModule(name)
    else
        return self:EnableModule(name)
    end
end

-- Check if a module is loaded
function ModAPI:IsModuleLoaded(name)
    if not name then return false end
    
    -- Get standardized versions of the name (lowercase and camelCase)
    local nameLower, nameCamel = self:NormalizeModuleName(name)
    
    -- Check all possible name variants
    return self.state.registeredModules[name] ~= nil or
           self.state.registeredModules[nameLower] ~= nil or
           self.state.registeredModules[nameCamel] ~= nil
end

-- Check if a module is enabled
function ModAPI:IsModuleEnabled(name)
    if not name then return false end
    
    -- Get standardized versions of the name (lowercase and camelCase)
    local nameLower, nameCamel = self:NormalizeModuleName(name)
    
    -- Check all possible name variants
    return self.state.enabledModules[name] ~= nil or
           self.state.enabledModules[nameLower] ~= nil or
           self.state.enabledModules[nameCamel] ~= nil
end

-- Get a module by name
function ModAPI:GetModule(name)
    if not name then return nil end
    
    -- Get standardized versions of the name (lowercase and camelCase)
    local nameLower, nameCamel = self:NormalizeModuleName(name)
    
    -- Try to find the module under any of its name variants
    if self.state.registeredModules[name] then
        return self.state.registeredModules[name]
    elseif self.state.registeredModules[nameLower] then
        return self.state.registeredModules[nameLower]
    elseif self.state.registeredModules[nameCamel] then
        return self.state.registeredModules[nameCamel]
    end
    
    return nil
end

-- Get module status
function ModAPI:GetModuleStatus(name)
    if not name then return "unknown" end
    
    -- Get standardized versions of the name (lowercase and camelCase)
    local nameLower, nameCamel = self:NormalizeModuleName(name)
    
    -- Try to find the status under any of its name variants
    if self.state.moduleStatus[name] then
        return self.state.moduleStatus[name]
    elseif self.state.moduleStatus[nameLower] then
        return self.state.moduleStatus[nameLower]
    elseif self.state.moduleStatus[nameCamel] then
        return self.state.moduleStatus[nameCamel]
    end
    
    return "unknown"
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
-- Helper function to sort modules by dependencies
function ModAPI:SortModulesByDependencies()
    local modules = {}
    local result = {}
    local visited = {}
    local inProgress = {}
    local circular = {}
    
    -- Build dependency graph
    for name, _ in pairs(self.state.registeredModules) do
        modules[name] = {}
        
        -- Add required dependencies
        if self.state.dependencyMap[name] and self.state.dependencyMap[name].required then
            for _, dep in ipairs(self.state.dependencyMap[name].required) do
                table.insert(modules[name], dep)
            end
        end
    end
    
    -- Topological sort implementation
    local function visit(name)
        if circular[name] then
            self:LogError("Circular dependency detected for module: " .. name)
            return false
        end
        
        if visited[name] then return true end
        
        if inProgress[name] then
            circular[name] = true
            return false
        end
        
        inProgress[name] = true
        
        if modules[name] then
            for _, dep in ipairs(modules[name]) do
                if not visited[dep] and not visit(dep) then
                    return false
                end
            end
        end
        
        inProgress[name] = nil
        visited[name] = true
        table.insert(result, name)
        return true
    end
    
    -- Process all modules
    for name, _ in pairs(self.state.registeredModules) do
        if not visited[name] then
            visit(name)
        end
    end
    
    -- Check for circular dependencies
    for name, isCircular in pairs(circular) do
        if isCircular then
            self:LogError("Circular dependency chain including module: " .. name)
        end
    end
    
    return result
end

function ModAPI:InitializeAllModules()
    -- Record start time for performance tracking
    self.state.initStartTime = debugprofilestop()
    self.state.initErrors = {}  -- Reset error tracking
    
    -- Trigger pre-initialization callback
    self:TriggerCallback("OnBeforeModulesInitialized")
    
    -- Sort modules based on dependencies
    local sortedModules = self:SortModulesByDependencies()
    
    -- Track initialization order for debugging
    self.state.initSequence = {}
    
    -- Initialize each module in dependency order
    for _, name in ipairs(sortedModules) do
        local module = self.state.registeredModules[name]
        
        if module then
            -- Track module initialization
            table.insert(self.state.initSequence, name)
            local moduleStartTime = debugprofilestop()
            self.state.initStarted[name] = true
            
            -- Check if we should initialize this module
            local shouldInit = true
            local missingDeps = {}
            
            -- Check dependencies more thoroughly
            if self.state.dependencyMap[name] and self.state.dependencyMap[name].required then
                for _, dep in ipairs(self.state.dependencyMap[name].required) do
                    if not self:IsModuleLoaded(dep) then
                        table.insert(missingDeps, dep)
                        shouldInit = false
                    elseif self.state.moduleStatus[dep] == "error" or self.state.moduleStatus[dep] == "skipped" then
                        table.insert(missingDeps, dep .. " (failed)")
                        shouldInit = false
                    end
                end
            end
            
            if shouldInit then
                -- Safety check for DB initialization
                if self.config.dbInitCheck and module.db == nil and VUI.db and VUI.db.profile and VUI.db.profile.modules then
                    -- Get standardized versions of the name (lowercase and camelCase)
                    local nameLower, nameCamel = self:NormalizeModuleName(name)
                    
                    -- Try to find the module settings under any of its name variants
                    if VUI.db.profile.modules[name] then
                        -- Set up database reference
                        module.db = VUI.db.profile.modules[name]
                        self:SafeDebug("DBInit", "Auto-initialized DB reference for module: " .. name)
                    elseif VUI.db.profile.modules[nameLower] then
                        -- Set up database reference using lowercase variant
                        module.db = VUI.db.profile.modules[nameLower]
                        self:SafeDebug("DBInit", "Auto-initialized DB reference for module: " .. name .. " using lowercase name: " .. nameLower)
                    elseif VUI.db.profile.modules[nameCamel] then
                        -- Set up database reference using camelCase variant
                        module.db = VUI.db.profile.modules[nameCamel]
                        self:SafeDebug("DBInit", "Auto-initialized DB reference for module: " .. name .. " using camelCase name: " .. nameCamel)
                    else
                        -- No existing settings found, create new entry
                        VUI.db.profile.modules[name] = {}
                        module.db = VUI.db.profile.modules[name]
                        self:SafeDebug("DBInit", "Created new DB entry for module: " .. name)
                    end
                end
                
                -- Check for module template application
                if self.config.enforceTemplate and not self.state.templateApplied[name] then
                    -- Try to apply template methods if missing
                    if not module.GetName and VUI.ModuleTemplate and VUI.ModuleTemplate.GetName then
                        module.GetName = VUI.ModuleTemplate.GetName
                    end
                    
                    if not module.Enable and VUI.ModuleTemplate and VUI.ModuleTemplate.Enable then
                        module.Enable = VUI.ModuleTemplate.Enable
                    end
                    
                    if not module.Disable and VUI.ModuleTemplate and VUI.ModuleTemplate.Disable then
                        module.Disable = VUI.ModuleTemplate.Disable
                    end
                    
                    self.state.templateApplied[name] = true
                    self:SafeDebug("Template", "Applied module template to: " .. name)
                end
                
                -- Attempt to initialize the module
                local success, err
                
                -- Call module's initialize method if it exists
                if module.Initialize then
                    success, err = pcall(module.Initialize, module)
                elseif module.OnInitialize then
                    success, err = pcall(module.OnInitialize, module)
                else
                    -- No initialize method, just mark as initialized
                    success = true
                end
                
                if success then
                    self.state.moduleStatus[name] = "initialized"
                    self.state.initFinished[name] = true
                    
                    -- Auto-enable if configured and not explicitly disabled
                    if self.config.autoEnableModules and not self.state.disabledModules[name] then
                        self:EnableModule(name)
                    end
                else
                    self.state.moduleStatus[name] = "error"
                    self:LogError("Failed to initialize module: " .. name .. " - " .. (err or "unknown error"))
                    
                    -- Add to retry queue if auto-retry is enabled
                    if self.config.autoRetry then
                        self.state.retryAttempts[name] = (self.state.retryAttempts[name] or 0) + 1
                        
                        if self.state.retryAttempts[name] <= self.config.maxRetryAttempts then
                            self:LogInfo("Queuing retry attempt " .. self.state.retryAttempts[name] .. 
                                " of " .. self.config.maxRetryAttempts .. " for module: " .. name)
                        end
                    end
                    
                    -- Trigger error callback
                    self:TriggerCallback("OnModuleError", name, module, "initialize", err)
                end
                
                -- Record initialization time
                self.state.initTimes[name] = debugprofilestop() - moduleStartTime
            else
                -- Skip initialization due to missing dependencies
                self.state.moduleStatus[name] = "skipped"
                
                local depList = table.concat(missingDeps, ", ")
                self:LogWarning("Skipped initialization of module due to missing dependencies: " .. 
                    name .. " (missing: " .. depList .. ")")
            end
        end
    end
    
    -- Process any modules queued for retry
    if self.config.autoRetry then
        local retriedCount = 0
        
        for name, attempts in pairs(self.state.retryAttempts) do
            if attempts <= self.config.maxRetryAttempts and self.state.moduleStatus[name] == "error" then
                self:LogInfo("Retrying module initialization: " .. name .. " (attempt " .. attempts .. ")")
                
                local module = self.state.registeredModules[name]
                local success, err
                
                if module.Initialize then
                    success, err = pcall(module.Initialize, module)
                elseif module.OnInitialize then
                    success, err = pcall(module.OnInitialize, module)
                end
                
                if success then
                    self.state.moduleStatus[name] = "initialized"
                    self.state.initFinished[name] = true
                    retriedCount = retriedCount + 1
                    
                    -- Auto-enable if configured and not explicitly disabled
                    if self.config.autoEnableModules and not self.state.disabledModules[name] then
                        self:EnableModule(name)
                    end
                else
                    self:LogError("Retry failed for module: " .. name .. " - " .. (err or "unknown error"))
                end
            end
        end
        
        if retriedCount > 0 then
            self:LogInfo("Successfully recovered " .. retriedCount .. " module(s) through retry")
        end
    end
    
    -- Trigger post-initialization callback
    self:TriggerCallback("OnModulesInitialized")
    
    -- Log performance
    if self.config.trackPerformance then
        local initTime = debugprofilestop() - self.state.initStartTime
        local initialized = 0
        local errors = 0
        local skipped = 0
        
        for _, status in pairs(self.state.moduleStatus) do
            if status == "initialized" or status == "enabled" then
                initialized = initialized + 1
            elseif status == "error" then
                errors = errors + 1
            elseif status == "skipped" then
                skipped = skipped + 1
            end
        end
        
        self:LogInfo("Initialization complete: " .. initialized .. " successful, " .. 
            errors .. " failed, " .. skipped .. " skipped in " .. string.format("%.2fms", initTime))
        
        -- Log detailed timing for each module if enabled
        if self.config.trackPerformance then
            for name, time in pairs(self.state.initTimes) do
                self:SafeDebug("ModuleTime", name .. ": " .. string.format("%.2fms", time))
            end
        end
    end
    
    -- Return initialization summary
    return {
        success = (self.state.loadedCount > 0),
        initialized = self.state.initSequence,
        errors = self.state.initErrors,
        time = debugprofilestop() - self.state.initStartTime
    }
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

-- Initialize module settings with defaults
-- CreateModuleSettings function - creates and returns module settings
-- This function ensures all modules have consistent DB field access
function ModAPI:CreateModuleSettings(moduleName, defaults)
    if not moduleName then
        self:LogError("Cannot create module settings: Missing module name")
        return {}
    end
    
    -- Get standardized versions of the name (lowercase and camelCase)
    local nameLower, nameCamel = self:NormalizeModuleName(moduleName)
    
    -- Ensure VUI database structure exists
    if not VUI.db then VUI.db = {} end
    if not VUI.db.profile then VUI.db.profile = {} end
    if not VUI.db.profile.modules then VUI.db.profile.modules = {} end
    
    -- Try to find existing settings under any of the name variants
    local settings
    if VUI.db.profile.modules[moduleName] then
        settings = VUI.db.profile.modules[moduleName]
    elseif VUI.db.profile.modules[nameLower] then
        settings = VUI.db.profile.modules[nameLower]
        -- Also create references with other names for consistency
        VUI.db.profile.modules[moduleName] = settings
    elseif VUI.db.profile.modules[nameCamel] then
        settings = VUI.db.profile.modules[nameCamel]
        -- Also create references with other names for consistency
        VUI.db.profile.modules[moduleName] = settings
    else
        -- No existing settings, create new entry
        settings = {}
        VUI.db.profile.modules[moduleName] = settings
        
        -- Also create standardized name entries pointing to the same table
        if moduleName ~= nameLower then
            VUI.db.profile.modules[nameLower] = settings
        end
        if moduleName ~= nameCamel and nameLower ~= nameCamel then
            VUI.db.profile.modules[nameCamel] = settings
        end
    end
    
    -- Merge defaults if provided
    if defaults then
        for k, v in pairs(defaults) do
            if settings[k] == nil then
                settings[k] = v
            end
        end
    end
    
    return settings
end

function ModAPI:InitializeModuleSettings(moduleName, defaults)
    if not moduleName or not defaults then
        self:LogError("Cannot initialize settings: Missing module name or defaults")
        return {}
    end
    
    -- Get standardized versions of the name (lowercase and camelCase)
    local nameLower, nameCamel = self:NormalizeModuleName(moduleName)
    
    -- Ensure VUI database structure exists
    if not VUI.db then VUI.db = {} end
    if not VUI.db.profile then VUI.db.profile = {} end
    if not VUI.db.profile.modules then VUI.db.profile.modules = {} end
    
    -- Try to find existing settings under any of the name variants
    local settings
    if VUI.db.profile.modules[moduleName] then
        settings = VUI.db.profile.modules[moduleName]
    elseif VUI.db.profile.modules[nameLower] then
        settings = VUI.db.profile.modules[nameLower]
        -- Also create references with other names for consistency
        VUI.db.profile.modules[moduleName] = settings
    elseif VUI.db.profile.modules[nameCamel] then
        settings = VUI.db.profile.modules[nameCamel]
        -- Also create references with other names for consistency
        VUI.db.profile.modules[moduleName] = settings
    else
        -- No existing settings, create new entry
        settings = {}
        VUI.db.profile.modules[moduleName] = settings
        
        -- Also create standardized name entries pointing to the same table
        if moduleName ~= nameLower then
            VUI.db.profile.modules[nameLower] = settings
        end
        if moduleName ~= nameCamel and nameLower ~= nameCamel then
            VUI.db.profile.modules[nameCamel] = settings
        end
    end
    
    -- Merge defaults with existing settings
    for k, v in pairs(defaults) do
        if settings[k] == nil then
            settings[k] = v
        end
    end
    
    -- Register defaults for this module (store but don't apply them)
    if not self.state.defaultSettings then
        self.state.defaultSettings = {}
    end
    self.state.defaultSettings[moduleName] = defaults
    
    return settings
end

-- Register defaults for a module
function ModAPI:RegisterDefaults(moduleName, defaults)
    if not moduleName or not defaults then return end
    
    -- Store defaults in state
    if not self.state.defaultSettings then
        self.state.defaultSettings = {}
    end
    self.state.defaultSettings[moduleName] = defaults
    
    -- Also store with standardized names for consistency
    local nameLower, nameCamel = self:NormalizeModuleName(moduleName)
    if moduleName ~= nameLower then
        self.state.defaultSettings[nameLower] = defaults
    end
    if moduleName ~= nameCamel and nameLower ~= nameCamel then
        self.state.defaultSettings[nameCamel] = defaults
    end
    
    return true
end

-- Logging methods with fallback protection
function ModAPI:LogInfo(message)
    if VUI and VUI.Debug then
        VUI:Debug("[ModuleAPI] " .. message)
    elseif VUI and VUI.Print then
        -- Fallback to Print if Debug not available
        VUI:Print("|cff00aaff[ModuleAPI Info]|r " .. message)
    elseif _G.DEFAULT_CHAT_FRAME then
        -- Ultimate fallback if VUI functions are not available
        _G.DEFAULT_CHAT_FRAME:AddMessage("|cff00aaff[VUI:ModuleAPI Info]|r " .. message)
    end
end

function ModAPI:LogWarning(message)
    if VUI and VUI.Print then
        VUI:Print("|cffff9900[ModuleAPI Warning]|r " .. message)
    elseif _G.DEFAULT_CHAT_FRAME then
        -- Fallback if VUI.Print is not available
        _G.DEFAULT_CHAT_FRAME:AddMessage("|cffff9900[VUI:ModuleAPI Warning]|r " .. message)
    end
end

function ModAPI:LogError(message)
    if VUI and VUI.Print then
        VUI:Print("|cffff0000[ModuleAPI Error]|r " .. message)
    elseif _G.DEFAULT_CHAT_FRAME then
        -- Fallback if VUI.Print is not available
        _G.DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[VUI:ModuleAPI Error]|r " .. message)
    end
    
    -- Record error for debugging
    table.insert(self.state.initErrors, message)
end

-- Enhanced debug helper with safe fallbacks
function ModAPI:SafeDebug(category, message)
    if not category or not message then return end
    
    local fullMessage = "[" .. category .. "] " .. message
    
    -- Try VUI's debug functionality first
    if VUI and VUI.Debug then
        VUI:Debug(fullMessage)
    elseif VUI and VUI.Print then
        -- Fallback to Print if Debug not available
        VUI:Print("|cff00aaff" .. fullMessage .. "|r")
    elseif _G.DEFAULT_CHAT_FRAME then
        -- Ultimate fallback if VUI functions are not available
        _G.DEFAULT_CHAT_FRAME:AddMessage("|cff00aaff[VUI Debug]|r " .. fullMessage)
    end
    
    -- If in debug mode, record all debug messages
    if self.config.trackPerformance then
        if not self.state.debugLog then
            self.state.debugLog = {}
        end
        table.insert(self.state.debugLog, {time = debugprofilestop(), msg = fullMessage})
    end
end

-- Create a new module with standardized structure
function ModAPI:CreateModule(name, defaults)
    if not name then
        self:LogError("Cannot create module: Missing module name")
        return nil
    end
    
    -- Create the module object
    local module = {}
    
    -- Set up standardized module properties
    module.name = name
    module.title = "VUI " .. name:gsub("^%l", string.upper)
    module.version = "1.0.0"
    module.author = "VortexQ8"
    
    -- Initialize database settings
    module.db = self:CreateModuleSettings(name, defaults or {})
    
    -- Add standard methods
    module.Enable = function(self)
        if VUI.ModuleAPI.state.enabledModules[name] then
            return -- Already enabled
        end
        
        -- Call OnEnable if it exists
        if self.OnEnable then
            self:OnEnable()
        end
        
        -- Update enabled state in DB
        if self.db then
            self.db.enabled = true
        end
        
        -- Update module state tracking
        VUI.ModuleAPI.state.enabledModules[name] = true
        VUI.ModuleAPI.state.disabledModules[name] = nil
    end
    
    module.Disable = function(self)
        if not VUI.ModuleAPI.state.enabledModules[name] then
            return -- Already disabled
        end
        
        -- Call OnDisable if it exists
        if self.OnDisable then
            self:OnDisable()
        end
        
        -- Update enabled state in DB
        if self.db then
            self.db.enabled = false
        end
        
        -- Update module state tracking
        VUI.ModuleAPI.state.enabledModules[name] = nil
        VUI.ModuleAPI.state.disabledModules[name] = true
    end
    
    -- Register the module
    self:RegisterModule(name, module)
    
    -- Store a reference in VUI namespace
    VUI[name] = module
    
    return module
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
    
    -- Expose module creation function
    VUI.ModuleAPI.CreateModule = function(name, defaults)
        return ModAPI:CreateModule(name, defaults)
    end
    
    -- Expose settings initialization function
    VUI.InitializeModuleSettings = function(moduleName, defaults)
        return ModAPI:InitializeModuleSettings(moduleName, defaults)
    end
    
    -- Expose module name standardization
    VUI.NormalizeModuleName = function(name)
        return ModAPI:NormalizeModuleName(name)
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