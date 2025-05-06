--[[
    VUI - Module Initialization API
    Author: VortexQ8
    Version: 1.0.0
    
    This file implements a standardized initialization API for modules:
    - Provides consistent error handling during initialization
    - Integrates with the dependency-based loading system
    - Ensures proper database structure and initialization
    - Offers fallbacks for critical systems
    - Creates a unified initialization sequence for all modules
]]

local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end

-- Create namespace
VUI.ModuleInitAPI = {}
local InitAPI = VUI.ModuleInitAPI

-- Cache frequently used globals
local select = select
local type = type
local pcall = pcall
local pairs = pairs
local print = print
local tostring = tostring
local unpack = unpack or table.unpack

-- State tracking
InitAPI.state = {
    initializedModules = {},  -- Modules that have been initialized
    failedModules = {},       -- Modules that failed to initialize and why
    initSequence = {},        -- Track initialization sequence
    initTime = {},            -- Time taken to initialize each module
    dependencyState = {},     -- Track dependency state during initialization
    retryAttempts = {},       -- Track retry attempts
    templateApplied = {},     -- Modules that have template applied
    callbacksRegistered = {}, -- Callbacks registered by module
}

-- Configuration
InitAPI.config = {
    maxRetryAttempts = 3,     -- Maximum number of retry attempts
    autoRetry = true,         -- Automatically retry failed modules
    enforceTemplate = true,   -- Enforce module template
    dbInitCheck = true,       -- Verify database initialization
    silentMode = false,       -- Suppress console messages 
    trackPerformance = true,  -- Track initialization performance
    initTimeout = 5,          -- Initialize timeout in seconds
    fallbackEnabled = true,   -- Enable fallback mechanisms
    debugMode = false,        -- Enable debug output
}

-- Debug logging with safety
function InitAPI:Log(level, ...)
    if self.config.silentMode and level ~= "ERROR" then return end
    
    local message = table.concat({...}, " ")
    
    -- Try VUI's debug system first
    if VUI.Debug and type(VUI.Debug) == "function" then
        VUI:Debug("[ModuleInitAPI:" .. level .. "] " .. message)
        return
    end
    
    -- Fall back to print with color
    local color = "|cffaaaaaa" -- default gray
    if level == "ERROR" then
        color = "|cffff3333" -- red
    elseif level == "WARNING" then
        color = "|cffffcc00" -- yellow
    elseif level == "INFO" then
        color = "|cff33aaff" -- blue
    end
    
    print(color .. "[VUI:ModuleInit] " .. message .. "|r")
end

-- Safe call with error handling
function InitAPI:SafeCall(func, ...)
    if type(func) ~= "function" then
        return false, "Not a function"
    end
    
    local success, result = pcall(func, ...)
    if not success then
        return false, result
    end
    
    return true, result
end

-- Apply module template to a module
function InitAPI:ApplyTemplate(moduleName, module)
    if not moduleName or not module then
        return false, "Invalid module"
    end
    
    -- Skip if already applied
    if self.state.templateApplied[moduleName] then
        return true
    end
    
    -- Use VUI's template system to extend the module
    if VUI.ModuleTemplate and VUI.ModuleTemplate.Extend then
        module = VUI.ModuleTemplate:Extend(module)
        self.state.templateApplied[moduleName] = true
        return true
    else
        return false, "Module template not available"
    end
end

-- Validate module structure
function InitAPI:ValidateModule(moduleName, module)
    if not moduleName or not module then
        return false, "Invalid module"
    end
    
    -- Basic type validation
    if type(module) ~= "table" then
        return false, "Module must be a table"
    end
    
    -- Must have essential methods or be able to add them
    local requiredMethods = {
        "Initialize", 
        "OnInitialize", 
        "Enable", 
        "OnEnable", 
        "Disable", 
        "OnDisable"
    }
    
    -- If we have a template system, we can apply it to provide missing methods
    if VUI.ModuleTemplate and VUI.ModuleTemplate.Extend then
        -- Will add missing methods through template
        return true
    end
    
    -- Otherwise, at least one initialization method must exist
    if not module.Initialize and not module.OnInitialize then
        return false, "Module must have Initialize or OnInitialize method"
    end
    
    return true
end

-- Initialize database structure for a module
function InitAPI:InitializeDB(moduleName, module)
    if not moduleName or not module then
        return false, "Invalid module"
    end
    
    -- Skip if no database system
    if not VUI.db then
        return true, "No database system available"
    end
    
    -- Ensure profile path exists
    if not VUI.db.profile then
        VUI.db.profile = {}
    end
    
    if not VUI.db.profile.modules then
        VUI.db.profile.modules = {}
    end
    
    -- Create module DB if it doesn't exist
    if not VUI.db.profile.modules[moduleName] then
        VUI.db.profile.modules[moduleName] = {}
    end
    
    -- Attach DB reference to module
    module.db = VUI.db
    module.settings = VUI.db.profile.modules[moduleName]
    
    -- Apply any default settings
    if module.defaults and type(module.defaults) == "table" then
        for k, v in pairs(module.defaults) do
            if module.settings[k] == nil then
                module.settings[k] = v
            end
        end
    end
    
    return true
end

-- Register module callbacks for main events
function InitAPI:RegisterCallbacks(moduleName, module)
    if not moduleName or not module then
        return false, "Invalid module"
    end
    
    -- Skip if already registered
    if self.state.callbacksRegistered[moduleName] then
        return true
    end
    
    -- Register profile callbacks if available
    if VUI.db and VUI.db.RegisterCallback then
        if module.UpdateUI or module.OnProfileChanged then
            local callback = module.OnProfileChanged or module.UpdateUI
            VUI.db.RegisterCallback(module, "OnProfileChanged", callback)
            VUI.db.RegisterCallback(module, "OnProfileCopied", callback)
            VUI.db.RegisterCallback(module, "OnProfileReset", callback)
        end
    end
    
    -- Register theme callbacks if available
    if VUI.RegisterThemeCallback and module.ApplyTheme then
        VUI:RegisterThemeCallback(module, "OnThemeChanged", module.ApplyTheme)
    end
    
    self.state.callbacksRegistered[moduleName] = true
    return true
end

-- Call initialization method with proper error handling
function InitAPI:CallInitialize(moduleName, module)
    if not moduleName or not module then
        return false, "Invalid module"
    end
    
    -- Check module state
    if self.state.initializedModules[moduleName] then
        self:Log("INFO", "Module already initialized:", moduleName)
        return true
    end
    
    -- Use the appropriate initialization method
    local initFunc
    if type(module.OnInitialize) == "function" then
        initFunc = module.OnInitialize
    elseif type(module.Initialize) == "function" then
        initFunc = module.Initialize
    end
    
    -- If no initialization function, mark as initialized anyway
    if not initFunc then
        self.state.initializedModules[moduleName] = true
        self:Log("WARNING", "No initialization method for module:", moduleName)
        return true
    end
    
    -- Track performance if enabled
    local startTime = 0
    if self.config.trackPerformance then
        startTime = debugprofilestop()
    end
    
    -- Call the initialization function
    local success, err = self:SafeCall(initFunc, module)
    
    -- Track initialization time
    if self.config.trackPerformance then
        local endTime = debugprofilestop()
        self.state.initTime[moduleName] = endTime - startTime
    end
    
    -- Handle result
    if success then
        self.state.initializedModules[moduleName] = true
        self:Log("INFO", "Initialized module:", moduleName)
        return true
    else
        -- Record failure details
        self.state.failedModules[moduleName] = {
            error = err,
            time = time(),
            attempts = (self.state.retryAttempts[moduleName] or 0) + 1
        }
        self.state.retryAttempts[moduleName] = (self.state.retryAttempts[moduleName] or 0) + 1
        
        self:Log("ERROR", "Failed to initialize module:", moduleName, "-", err)
        return false, err
    end
end

-- Initialize a module with the complete standardized sequence
function InitAPI:InitializeModule(moduleName, module)
    if not moduleName or not module then
        self:Log("ERROR", "Invalid module in InitializeModule")
        return false, "Invalid module"
    end
    
    -- Already initialized, skip
    if self.state.initializedModules[moduleName] then
        return true
    end
    
    -- Check retry limit
    if self.state.retryAttempts[moduleName] and self.state.retryAttempts[moduleName] >= self.config.maxRetryAttempts then
        self:Log("ERROR", "Module", moduleName, "exceeded retry limit")
        return false, "Retry limit exceeded"
    end
    
    -- Record initialization sequence
    table.insert(self.state.initSequence, moduleName)
    
    -- Step 1: Apply module template if needed and available
    if self.config.enforceTemplate then
        local success, err = self:ApplyTemplate(moduleName, module)
        if not success and self.config.fallbackEnabled == false then
            self:Log("ERROR", "Failed to apply template to module:", moduleName, "-", err)
            return false, "Template application failed: " .. tostring(err)
        end
    end
    
    -- Step 2: Validate module structure
    local success, err = self:ValidateModule(moduleName, module)
    if not success then
        self:Log("ERROR", "Module validation failed for:", moduleName, "-", err)
        return false, "Validation failed: " .. tostring(err)
    end
    
    -- Step 3: Initialize database
    local success, err = self:InitializeDB(moduleName, module)
    if not success then
        self:Log("ERROR", "Database initialization failed for:", moduleName, "-", err)
        return false, "DB initialization failed: " .. tostring(err)
    end
    
    -- Step 4: Register standard callbacks
    local success, err = self:RegisterCallbacks(moduleName, module)
    if not success then
        self:Log("WARNING", "Callback registration failed for:", moduleName, "-", err)
        -- Non-critical, continue
    end
    
    -- Step 5: Call module's initialization method
    local success, err = self:CallInitialize(moduleName, module)
    if not success then
        -- If auto-retry is enabled and we haven't exceeded the limit, we'll let the caller try again
        return false, "Initialization failed: " .. tostring(err)
    end
    
    -- Register with VUI.ModuleManager if available
    if VUI.ModuleManager and VUI.ModuleManager.RegisterModule then
        VUI.ModuleManager:RegisterModule(moduleName, {
            name = moduleName,
            module = module,
            priority = module.loadPriority or 50,
            category = module.category or "optional"
        })
    end
    
    -- Successfully initialized
    self:Log("INFO", "Module", moduleName, "successfully initialized")
    
    -- If module has OnPostInitialize, call it after successful initialization
    if type(module.OnPostInitialize) == "function" then
        self:SafeCall(module.OnPostInitialize, module)
    end
    
    return true
end

-- Get module initialization stats
function InitAPI:GetStats()
    local stats = {
        initialized = 0,
        failed = 0,
        attempts = 0,
        averageTime = 0,
        slowestModule = "",
        slowestTime = 0,
        initSequence = self.state.initSequence,
        failureDetails = {}
    }
    
    -- Count initialized and failed modules
    for _ in pairs(self.state.initializedModules) do
        stats.initialized = stats.initialized + 1
    end
    
    for moduleName, details in pairs(self.state.failedModules) do
        stats.failed = stats.failed + 1
        stats.failureDetails[moduleName] = details.error
    end
    
    -- Calculate performance stats if tracking is enabled
    if self.config.trackPerformance then
        local totalTime = 0
        local moduleCount = 0
        
        for moduleName, time in pairs(self.state.initTime) do
            totalTime = totalTime + time
            moduleCount = moduleCount + 1
            
            if time > stats.slowestTime then
                stats.slowestTime = time
                stats.slowestModule = moduleName
            end
        end
        
        if moduleCount > 0 then
            stats.averageTime = totalTime / moduleCount
        end
    end
    
    -- Calculate retry attempts
    for _, attempts in pairs(self.state.retryAttempts) do
        stats.attempts = stats.attempts + attempts
    end
    
    return stats
end

-- Reset initialization state
function InitAPI:Reset()
    self.state.initializedModules = {}
    self.state.failedModules = {}
    self.state.initSequence = {}
    self.state.initTime = {}
    self.state.dependencyState = {}
    self.state.retryAttempts = {}
    self.state.templateApplied = {}
    self.state.callbacksRegistered = {}
    
    self:Log("INFO", "Module initialization state has been reset")
    return true
end

-- Initialize all modules respecting dependencies
function InitAPI:InitializeAll(modules)
    -- If no modules provided, use VUI's modules
    if not modules and VUI.modules then
        modules = VUI.modules
    end
    
    if not modules or type(modules) ~= "table" then
        self:Log("ERROR", "No modules to initialize")
        return false, "No modules available"
    end
    
    -- Use ModuleManager to calculate dependency-based order if available
    local initOrder = {}
    
    if VUI.ModuleManager and VUI.ModuleManager.CalculateInitOrder then
        initOrder = VUI.ModuleManager:CalculateInitOrder()
        self:Log("INFO", "Using dependency-based initialization order for", #initOrder, "modules")
    else
        -- Otherwise just process in whatever order they come
        for name in pairs(modules) do
            table.insert(initOrder, name)
        end
        self:Log("INFO", "Initializing", #initOrder, "modules in standard order")
    end
    
    -- Stats for reporting
    local initialized = 0
    local failed = 0
    
    -- Process each module in initialization order
    for _, moduleName in ipairs(initOrder) do
        local module = modules[moduleName]
        
        if module then
            local success, err = self:InitializeModule(moduleName, module)
            
            if success then
                initialized = initialized + 1
            else
                failed = failed + 1
                self:Log("ERROR", "Failed to initialize module:", moduleName, "-", err)
                
                -- If autoRetry is disabled, just continue to the next module
                if not self.config.autoRetry then
                    -- Skip retries
                elseif self.state.retryAttempts[moduleName] and self.state.retryAttempts[moduleName] < self.config.maxRetryAttempts then
                    -- Add it back to the list to try again later
                    table.insert(initOrder, moduleName)
                end
            end
        end
    end
    
    self:Log("INFO", "Module initialization complete:", initialized, "successful,", failed, "failed")
    return initialized, failed
end

-- Get initialization status for a specific module
function InitAPI:GetModuleStatus(moduleName)
    if not moduleName then
        return "unknown"
    end
    
    if self.state.initializedModules[moduleName] then
        return "initialized"
    end
    
    if self.state.failedModules[moduleName] then
        return "failed"
    end
    
    return "pending"
end

-- Attach the API to VUI
VUI.InitModule = function(moduleName, module)
    return InitAPI:InitializeModule(moduleName, module)
end

-- Initialize the API
function InitAPI:Initialize()
    self:Log("INFO", "Module Initialization API loaded")
    
    -- Register with other systems
    if VUI.RegisterSubsystem then
        VUI:RegisterSubsystem("ModuleInitAPI", self)
    end
end

-- Call initialization if VUI is already initialized
if VUI.isInitialized then
    InitAPI:Initialize()
else
    -- Setup initialization when VUI is ready
    if VUI.RegisterCallback then
        VUI:RegisterCallback("OnInitialized", function() 
            InitAPI:Initialize() 
        end)
    end
end