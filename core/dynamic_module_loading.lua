--[[
    VUI - Dynamic Module Loading System
    Author: VortexQ8
    
    This file implements dynamic module loading functionality for VUI,
    allowing modules to be loaded only when needed to reduce memory usage and
    improve initial loading times.
    
    Key features:
    1. On-demand module loading
    2. Dependency resolution and management
    3. State management for modules (loaded, unloaded, pending)
    4. Memory usage tracking and optimization
    5. Automatic cleanup of unused modules
]]

local _, VUI = ...
local L = VUI.L

-- Create the Dynamic Module Loading system
local DynamicModuleLoading = {}
VUI.DynamicModuleLoading = DynamicModuleLoading

-- Settings
local settings = {
    enabled = true,                    -- Master toggle
    autoCleanupEnabled = true,         -- Automatic cleanup of unused modules
    cleanupInterval = 300,             -- 5 minutes between cleanup checks
    inactiveThreshold = 600,           -- 10 minutes of inactivity before unloading
    combatBufferTime = 60,             -- Keep modules loaded for 1 minute after combat
    loadingThrottle = 0.5,             -- Minimum time between module loads (seconds)
    debugMode = false,                 -- Enable debug output
    preloadCoreModules = true,         -- Automatically load core modules at startup
    delayedStartup = true,             -- Delay non-essential module loading until after login
    aggressiveUnloading = false,       -- Aggressively unload unused modules
    preserveUserSettings = true,       -- Keep user settings when unloading modules
    profileBasedLoading = true,        -- Load modules based on character profile
}

-- Module states
local MODULE_STATE = {
    UNLOADED = 0,      -- Module files not loaded
    LOADING = 1,       -- Module is currently loading
    LOADED = 2,        -- Module is loaded but not initialized
    INITIALIZED = 3,   -- Module is loaded and initialized
    ENABLED = 4,       -- Module is fully loaded, initialized and enabled
    ERROR = 5,         -- Error occurred during module loading
}

-- Module categories
local MODULE_CATEGORY = {
    CORE = "core",         -- Essential core modules (always loaded)
    INTERFACE = "ui",      -- UI enhancements and modifications
    COMBAT = "combat",     -- Combat-related functionality
    SOCIAL = "social",     -- Chat, friends, guild features
    UTILITY = "utility",   -- Quality of life improvements
    PROFESSIONS = "prof",  -- Profession-related modules
    PVE = "pve",           -- PvE-specific features
    PVP = "pvp",           -- PvP-specific features
}

-- Module metadata storage
local moduleRegistry = {}
local moduleDependencies = {}
local moduleUsageStats = {}
local loadOperations = {}
local lastAccessed = {}
local moduleCategories = {}
local coreModules = {}

-- Internal state
local lastLoadTime = 0
local cleanupTimer = nil
local isPendingCleanup = false
local playerInCombat = false
local playerRecentlyInCombat = false
local combatExitTime = 0
local startupComplete = false
local pendingCallbacks = {}

-- Initialize the dynamic loading system
function DynamicModuleLoading:Initialize()
    -- Register with the database
    self:RegisterSettings()
    
    -- Register events
    self:RegisterEvents()
    
    -- Identify core modules
    self:IdentifyCoreModules()
    
    -- Set initial state
    startupComplete = false
    
    -- Start cleanup timer if enabled
    if settings.autoCleanupEnabled then
        self:StartCleanupTimer()
    end
    
    -- Schedule delayed startup if enabled
    if settings.delayedStartup then
        C_Timer.After(1, function() self:PerformDelayedStartup() end)
    else
        startupComplete = true
    end
    
    -- Register with performance monitoring
    if VUI.PerformanceMonitoring then
        VUI.PerformanceMonitoring:RegisterSystem("DynamicModuleLoading", function()
            return self:GetPerformanceMetrics()
        end)
    end
    
    VUI:Print("Dynamic Module Loading system initialized")
end

-- Register settings with the database
function DynamicModuleLoading:RegisterSettings()
    -- Register with VUI database
    local dbSettings = VUI.db.profile.dynamicLoading
    if not dbSettings then
        VUI.db.profile.dynamicLoading = CopyTable(settings)
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

-- Register for events
function DynamicModuleLoading:RegisterEvents()
    -- Create frame for events if needed
    if not self.frame then
        self.frame = CreateFrame("Frame")
        self.frame:SetScript("OnEvent", function(_, event, ...)
            if self[event] then
                self[event](self, ...)
            end
        end)
    end
    
    -- Register for relevant events
    self.frame:RegisterEvent("PLAYER_LOGIN")
    self.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    self.frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    self.frame:RegisterEvent("ADDON_LOADED")
    
    -- Special tracking for roster events to intelligently load social modules
    if settings.profileBasedLoading then
        self.frame:RegisterEvent("GROUP_ROSTER_UPDATE")
        self.frame:RegisterEvent("GUILD_ROSTER_UPDATE")
    end
end

-- Identify core modules that should always be loaded
function DynamicModuleLoading:IdentifyCoreModules()
    -- These modules are considered essential and always loaded
    coreModules = {
        ["MultiNotification"] = true,  -- Critical notification system
        ["BuffOverlay"] = true,        -- Core buff tracking
        ["MoveAny"] = true,            -- Frame movement/positioning
        ["OmniCC"] = true,             -- Cooldown count
    }
    
    -- Mark modules with appropriate categories
    moduleCategories = {
        -- Core UI modules
        ["MultiNotification"] = MODULE_CATEGORY.CORE,
        ["BuffOverlay"] = MODULE_CATEGORY.CORE,
        ["MoveAny"] = MODULE_CATEGORY.CORE,
        ["OmniCC"] = MODULE_CATEGORY.CORE,
        
        -- Combat modules
        ["OmniCD"] = MODULE_CATEGORY.COMBAT,
        ["TrufiGCD"] = MODULE_CATEGORY.COMBAT,
        ["DetailsSkin"] = MODULE_CATEGORY.COMBAT,
        ["MikScrollingBattleText"] = MODULE_CATEGORY.COMBAT,
        ["SpellNotifications"] = MODULE_CATEGORY.COMBAT,
        
        -- Social/UI modules
        ["Auctionator"] = MODULE_CATEGORY.SOCIAL,
        ["AngryKeystones"] = MODULE_CATEGORY.PVE,
        ["PremadeGroupFinder"] = MODULE_CATEGORY.SOCIAL,
        
        -- Utility modules
        ["idTip"] = MODULE_CATEGORY.UTILITY,
    }
end

-- Register a module with the dynamic loading system
function DynamicModuleLoading:RegisterModule(moduleName, category, dependencies, loadPriority)
    if not moduleName then return end
    
    -- Create module record if it doesn't exist
    if not moduleRegistry[moduleName] then
        moduleRegistry[moduleName] = {
            name = moduleName,
            state = MODULE_STATE.UNLOADED,
            category = category or MODULE_CATEGORY.UTILITY,
            dependencies = dependencies or {},
            priority = loadPriority or 5, -- Default medium priority (1-10 scale)
            files = {},
            lastLoaded = 0,
            loadCount = 0,
            loadTime = 0,
            memoryUsage = 0,
        }
    else
        -- Update existing record
        local module = moduleRegistry[moduleName]
        module.category = category or module.category
        module.dependencies = dependencies or module.dependencies
        module.priority = loadPriority or module.priority
    end
    
    -- Track dependencies
    if dependencies and #dependencies > 0 then
        moduleDependencies[moduleName] = dependencies
    end
    
    -- Automatically preload core modules if enabled
    if settings.preloadCoreModules and coreModules[moduleName] then
        self:LoadModule(moduleName)
    end
    
    -- Return the module record
    return moduleRegistry[moduleName]
end

-- Register a file with a module
function DynamicModuleLoading:RegisterModuleFile(moduleName, filePath, isRequired, loadOrder)
    if not moduleName or not filePath then return end
    
    -- Ensure module exists in registry
    if not moduleRegistry[moduleName] then
        self:RegisterModule(moduleName)
    end
    
    -- Add file to module's file list
    table.insert(moduleRegistry[moduleName].files, {
        path = filePath,
        required = (isRequired == nil) and true or isRequired, -- Default to required
        order = loadOrder or #moduleRegistry[moduleName].files + 1,
        loaded = false
    })
    
    -- Sort files by load order
    table.sort(moduleRegistry[moduleName].files, function(a, b)
        return a.order < b.order
    end)
end

-- Load a module and its dependencies
function DynamicModuleLoading:LoadModule(moduleName, callback)
    if not moduleName or not moduleRegistry[moduleName] then
        if settings.debugMode then
            VUI:Print("Cannot load unknown module: " .. (moduleName or "nil"))
        end
        
        if callback then
            callback(false, "Module not found")
        end
        return false
    end
    
    -- Check if module is already loaded or loading
    local module = moduleRegistry[moduleName]
    if module.state == MODULE_STATE.ENABLED or module.state == MODULE_STATE.INITIALIZED then
        -- Module already loaded and initialized
        self:UpdateModuleAccess(moduleName)
        
        if callback then
            callback(true, "Module already loaded")
        end
        return true
    elseif module.state == MODULE_STATE.LOADING then
        -- Module is currently loading, register callback
        if callback then
            if not pendingCallbacks[moduleName] then
                pendingCallbacks[moduleName] = {}
            end
            table.insert(pendingCallbacks[moduleName], callback)
        end
        return true
    end
    
    -- Check throttle to prevent too many modules loading at once
    local now = GetTime()
    if now - lastLoadTime < settings.loadingThrottle then
        -- Queue loading for later
        C_Timer.After(settings.loadingThrottle, function()
            self:LoadModule(moduleName, callback)
        end)
        return true
    end
    
    -- Update last load time
    lastLoadTime = now
    
    -- Set module state to loading
    module.state = MODULE_STATE.LOADING
    
    -- Register callback
    if callback then
        if not pendingCallbacks[moduleName] then
            pendingCallbacks[moduleName] = {}
        end
        table.insert(pendingCallbacks[moduleName], callback)
    end
    
    -- Check and load dependencies first
    local dependencies = module.dependencies or moduleDependencies[moduleName] or {}
    local pendingDependencies = 0
    
    if #dependencies > 0 then
        for _, depName in ipairs(dependencies) do
            if not self:IsModuleLoaded(depName) then
                pendingDependencies = pendingDependencies + 1
                
                -- Load dependency
                self:LoadModule(depName, function(success, message)
                    if not success then
                        if settings.debugMode then
                            VUI:Print("Failed to load dependency " .. depName .. " for " .. moduleName .. ": " .. message)
                        end
                    end
                    
                    pendingDependencies = pendingDependencies - 1
                    if pendingDependencies == 0 then
                        -- All dependencies loaded, now load this module
                        self:LoadModuleFiles(moduleName)
                    end
                end)
            end
        end
    end
    
    -- If no dependencies or all already loaded, load module files directly
    if pendingDependencies == 0 then
        self:LoadModuleFiles(moduleName)
    end
    
    return true
end

-- Load actual module files
function DynamicModuleLoading:LoadModuleFiles(moduleName)
    local module = moduleRegistry[moduleName]
    if not module then return false end
    
    -- Performance tracking
    local startTime = debugprofilestop()
    local initialMemory = gcinfo()
    
    -- First pass: load required files
    local loadedFiles = 0
    local totalFiles = #module.files
    local success = true
    local errorMessage = nil
    
    for i, fileInfo in ipairs(module.files) do
        if fileInfo.required and not fileInfo.loaded then
            if fileInfo.path and fileInfo.path ~= "" then
                local loadSuccess, loadError = pcall(function()
                    VUI:LoadFile(fileInfo.path)
                end)
                
                if loadSuccess then
                    fileInfo.loaded = true
                    loadedFiles = loadedFiles + 1
                else
                    success = false
                    errorMessage = "Error loading " .. fileInfo.path .. ": " .. (loadError or "unknown error")
                    break
                end
            end
        end
    end
    
    -- Second pass: load optional files if successful so far
    if success then
        for i, fileInfo in ipairs(module.files) do
            if not fileInfo.required and not fileInfo.loaded then
                if fileInfo.path and fileInfo.path ~= "" then
                    local loadSuccess, loadError = pcall(function()
                        VUI:LoadFile(fileInfo.path)
                    end)
                    
                    if loadSuccess then
                        fileInfo.loaded = true
                        loadedFiles = loadedFiles + 1
                    else
                        -- Non-critical error for optional files
                        if settings.debugMode then
                            VUI:Print("Warning: Failed to load optional file " .. fileInfo.path .. " for " .. moduleName .. ": " .. (loadError or "unknown error"))
                        end
                    end
                end
            end
        end
    end
    
    -- Update module state based on result
    if not success then
        module.state = MODULE_STATE.ERROR
        if settings.debugMode then
            VUI:Print("Failed to load module " .. moduleName .. ": " .. (errorMessage or "unknown error"))
        end
    else
        -- Attempt to initialize the module
        local initSuccess = self:InitializeModule(moduleName)
        
        if initSuccess then
            module.state = MODULE_STATE.INITIALIZED
            
            -- Try to enable the module if it has an OnEnable method
            local vModule = VUI:GetModule(moduleName)
            if vModule and vModule.Enable and not vModule:IsEnabled() then
                vModule:Enable()
                module.state = MODULE_STATE.ENABLED
            elseif vModule and vModule.OnEnable and vModule.enabledState ~= true then
                if type(vModule.OnEnable) == "function" then
                    vModule:OnEnable()
                end
                module.state = MODULE_STATE.ENABLED
                vModule.enabledState = true
            end
        else
            module.state = MODULE_STATE.LOADED
        end
    end
    
    -- Update statistics
    module.lastLoaded = GetTime()
    module.loadCount = module.loadCount + 1
    module.loadTime = debugprofilestop() - startTime
    module.memoryUsage = gcinfo() - initialMemory
    
    -- Process pending callbacks
    if pendingCallbacks[moduleName] then
        for _, cb in ipairs(pendingCallbacks[moduleName]) do
            if type(cb) == "function" then
                cb(success, success and "Module loaded successfully" or (errorMessage or "Failed to load module"))
            end
        end
        pendingCallbacks[moduleName] = nil
    end
    
    -- Update metrics
    moduleUsageStats[moduleName] = moduleUsageStats[moduleName] or {}
    moduleUsageStats[moduleName].loadTime = module.loadTime
    moduleUsageStats[moduleName].memoryUsage = module.memoryUsage
    
    -- Record for tracking accesses
    self:UpdateModuleAccess(moduleName)
    
    if settings.debugMode then
        if success then
            VUI:Print(string.format("Loaded module %s (%d/%d files) in %.2fms with %.2fKB memory", 
                moduleName, loadedFiles, totalFiles, module.loadTime, module.memoryUsage))
        end
    end
    
    -- Fire module loaded event to notify other systems
    VUI:SendMessage("MODULE_LOADED", moduleName, success)
    
    return success
end

-- Initialize a module
function DynamicModuleLoading:InitializeModule(moduleName)
    local vModule = VUI:GetModule(moduleName)
    if not vModule then
        -- Module exists in our registry but not in VUI's module system
        if settings.debugMode then
            VUI:Print("Warning: Module " .. moduleName .. " registered but not found in VUI modules")
        end
        return false
    end
    
    -- Check if module is already initialized
    if vModule.initialized then
        return true
    end
    
    -- Call module's OnInitialize method if it exists
    if vModule.OnInitialize and type(vModule.OnInitialize) == "function" then
        local success, error = pcall(function()
            vModule:OnInitialize()
        end)
        
        if not success then
            if settings.debugMode then
                VUI:Print("Error initializing module " .. moduleName .. ": " .. (error or "unknown error"))
            end
            return false
        end
    end
    
    vModule.initialized = true
    return true
end

-- Check if a module is loaded
function DynamicModuleLoading:IsModuleLoaded(moduleName)
    if not moduleName or not moduleRegistry[moduleName] then
        return false
    end
    
    local state = moduleRegistry[moduleName].state
    return state == MODULE_STATE.LOADED or state == MODULE_STATE.INITIALIZED or state == MODULE_STATE.ENABLED
end

-- Unload a module to free memory
function DynamicModuleLoading:UnloadModule(moduleName, force)
    if not moduleName or not moduleRegistry[moduleName] then
        return false
    end
    
    -- Skip core modules unless forced
    if coreModules[moduleName] and not force then
        return false
    end
    
    local module = moduleRegistry[moduleName]
    
    -- Skip if module is not loaded
    if module.state == MODULE_STATE.UNLOADED or module.state == MODULE_STATE.LOADING then
        return false
    end
    
    -- Check if other modules depend on this one
    for name, deps in pairs(moduleDependencies) do
        if name ~= moduleName then
            for _, dep in ipairs(deps) do
                if dep == moduleName and self:IsModuleLoaded(name) then
                    -- Can't unload because another loaded module depends on this
                    if force then
                        -- If forced, unload the dependent module first
                        self:UnloadModule(name, true)
                    else
                        if settings.debugMode then
                            VUI:Print("Cannot unload " .. moduleName .. ": " .. name .. " depends on it")
                        end
                        return false
                    end
                end
            end
        end
    end
    
    -- Get module object
    local vModule = VUI:GetModule(moduleName)
    if vModule then
        -- Call module's OnDisable method if it exists
        if vModule.OnDisable and type(vModule.OnDisable) == "function" then
            local success, error = pcall(function()
                vModule:OnDisable()
            end)
            
            if not success and settings.debugMode then
                VUI:Print("Error disabling module " .. moduleName .. ": " .. (error or "unknown error"))
            end
        end
        
        -- Clear module data while preserving configuration if required
        if vModule.db and settings.preserveUserSettings then
            -- Keep the database but clear other fields
            local savedDB = vModule.db
            for k in pairs(vModule) do
                if k ~= "db" and k ~= "defaults" and k ~= "name" then
                    vModule[k] = nil
                end
            end
            vModule.db = savedDB
        else
            -- Clear everything
            for k in pairs(vModule) do
                if k ~= "name" then
                    vModule[k] = nil
                end
            end
        end
        
        -- Mark as uninitialized
        vModule.initialized = false
        vModule.enabledState = false
    end
    
    -- Reset module state and mark files as unloaded
    module.state = MODULE_STATE.UNLOADED
    for _, fileInfo in ipairs(module.files) do
        fileInfo.loaded = false
    end
    
    -- Force garbage collection to clean up memory
    collectgarbage("collect")
    
    -- Update statistics
    module.lastUnloaded = GetTime()
    
    if settings.debugMode then
        VUI:Print("Unloaded module: " .. moduleName)
    end
    
    -- Fire module unloaded event to notify other systems
    VUI:SendMessage("MODULE_UNLOADED", moduleName)
    
    return true
end

-- Reload a module (unload then load)
function DynamicModuleLoading:ReloadModule(moduleName, callback)
    if not moduleName or not moduleRegistry[moduleName] then
        if callback then
            callback(false, "Module not found")
        end
        return false
    end
    
    -- Unload first
    self:UnloadModule(moduleName, true)
    
    -- Then load
    return self:LoadModule(moduleName, callback)
end

-- Update module access timestamp
function DynamicModuleLoading:UpdateModuleAccess(moduleName)
    if not moduleName then return end
    
    lastAccessed[moduleName] = GetTime()
end

-- Start automatic cleanup timer
function DynamicModuleLoading:StartCleanupTimer()
    if cleanupTimer then
        return
    end
    
    cleanupTimer = C_Timer.NewTicker(settings.cleanupInterval, function()
        if not isPendingCleanup and not playerInCombat and not playerRecentlyInCombat then
            self:PerformCleanup()
        end
    end)
end

-- Perform memory cleanup
function DynamicModuleLoading:PerformCleanup()
    if playerInCombat or playerRecentlyInCombat then
        return
    end
    
    isPendingCleanup = true
    
    local now = GetTime()
    local unloadedCount = 0
    local memoryFreed = 0
    
    -- Get current memory usage
    local memBefore = gcinfo()
    
    -- Identify modules to unload
    for name, module in pairs(moduleRegistry) do
        if self:IsModuleLoaded(name) and not coreModules[name] then
            local lastAccess = lastAccessed[name] or 0
            
            -- Check if module has been unused for a while
            if (now - lastAccess) > settings.inactiveThreshold then
                -- Skip if it's a combat module and player recently exited combat
                local skipUnload = false
                
                if moduleCategories[name] == MODULE_CATEGORY.COMBAT then
                    if (now - combatExitTime) < settings.combatBufferTime then
                        skipUnload = true
                    end
                end
                
                if not skipUnload then
                    -- Try to unload
                    local success = self:UnloadModule(name, settings.aggressiveUnloading)
                    if success then
                        unloadedCount = unloadedCount + 1
                        if moduleUsageStats[name] and moduleUsageStats[name].memoryUsage then
                            memoryFreed = memoryFreed + moduleUsageStats[name].memoryUsage
                        end
                    end
                end
            end
        end
    end
    
    -- Force garbage collection
    collectgarbage("collect")
    
    -- Calculate actual memory freed
    local memAfter = gcinfo()
    local actualFreed = memBefore - memAfter
    
    if settings.debugMode and unloadedCount > 0 then
        VUI:Print(string.format("Cleanup: Unloaded %d unused modules, freed %.2fKB memory", 
            unloadedCount, actualFreed))
    end
    
    isPendingCleanup = false
    
    -- Record results for performance monitoring
    VUI:SendMessage("MEMORY_CLEANUP_COMPLETED", unloadedCount, actualFreed)
end

-- Perform delayed startup loading
function DynamicModuleLoading:PerformDelayedStartup()
    -- Load core modules first
    for name in pairs(coreModules) do
        if not self:IsModuleLoaded(name) then
            self:LoadModule(name)
        end
    end
    
    -- Wait a bit before loading non-essential modules
    C_Timer.After(3, function()
        -- Load regularly used modules based on profile preferences
        self:LoadProfileModules()
        
        -- Mark startup as complete
        startupComplete = true
        
        -- Fire event to notify other systems
        VUI:SendMessage("MODULE_LOADING_COMPLETE")
    end)
end

-- Load modules based on user profile
function DynamicModuleLoading:LoadProfileModules()
    -- Check if profile-based module preferences exist
    local profile = VUI.db.profile.modulePreferences
    if not profile then
        return
    end
    
    -- Load modules marked as auto-load in profile
    for name, prefs in pairs(profile) do
        if prefs.autoLoad and moduleRegistry[name] and not self:IsModuleLoaded(name) then
            self:LoadModule(name)
        end
    end
end

-- Get module state
function DynamicModuleLoading:GetModuleState(moduleName)
    if not moduleName or not moduleRegistry[moduleName] then
        return nil
    end
    
    return moduleRegistry[moduleName].state
end

-- Get memory usage statistics
function DynamicModuleLoading:GetMemoryUsage()
    local stats = {
        totalMemory = 0,
        moduleCount = 0,
        loadedModules = 0,
        largestModules = {},
    }
    
    -- Collect memory usage stats
    local moduleMemoryList = {}
    
    for name, module in pairs(moduleRegistry) do
        local memUsage = moduleUsageStats[name] and moduleUsageStats[name].memoryUsage or 0
        
        if self:IsModuleLoaded(name) then
            stats.totalMemory = stats.totalMemory + memUsage
            stats.loadedModules = stats.loadedModules + 1
            
            table.insert(moduleMemoryList, {name = name, memory = memUsage})
        end
        
        stats.moduleCount = stats.moduleCount + 1
    end
    
    -- Sort by memory usage to find largest modules
    table.sort(moduleMemoryList, function(a, b) return a.memory > b.memory end)
    
    -- Get top 5 memory users
    for i = 1, math.min(5, #moduleMemoryList) do
        table.insert(stats.largestModules, moduleMemoryList[i])
    end
    
    return stats
end

-- Get performance metrics for monitoring
function DynamicModuleLoading:GetPerformanceMetrics()
    local memStats = self:GetMemoryUsage()
    local moduleTimings = {}
    
    -- Get module load timings
    for name, stats in pairs(moduleUsageStats) do
        if stats.loadTime then
            table.insert(moduleTimings, {
                name = name,
                loadTime = stats.loadTime,
                memory = stats.memoryUsage or 0
            })
        end
    end
    
    -- Sort by load time
    table.sort(moduleTimings, function(a, b) return a.loadTime > b.loadTime end)
    
    -- Return metrics
    return {
        totalMemory = memStats.totalMemory,
        loadedModules = memStats.loadedModules, 
        totalModules = memStats.moduleCount,
        largestModules = memStats.largestModules,
        slowestModules = moduleTimings,
        settings = settings,
    }
end

-- Get module list with status
function DynamicModuleLoading:GetModuleList()
    local moduleList = {}
    
    for name, module in pairs(moduleRegistry) do
        table.insert(moduleList, {
            name = name,
            state = module.state,
            category = module.category or "unknown",
            priority = module.priority or 5,
            isCore = coreModules[name] or false,
            loadCount = module.loadCount or 0,
            lastLoaded = module.lastLoaded or 0,
            loadTime = moduleUsageStats[name] and moduleUsageStats[name].loadTime or 0,
            memoryUsage = moduleUsageStats[name] and moduleUsageStats[name].memoryUsage or 0,
            fileCount = #module.files,
            dependencies = moduleDependencies[name] or {},
        })
    end
    
    return moduleList
end

-- Check if initialization is complete
function DynamicModuleLoading:IsStartupComplete()
    return startupComplete
end

-- Process PLAYER_LOGIN event
function DynamicModuleLoading:PLAYER_LOGIN()
    -- If not using delayed startup, load core modules now
    if not settings.delayedStartup then
        for name in pairs(coreModules) do
            if not self:IsModuleLoaded(name) then
                self:LoadModule(name)
            end
        end
        
        -- Mark startup as complete
        startupComplete = true
    end
end

-- Track combat state for smart module loading
function DynamicModuleLoading:PLAYER_REGEN_DISABLED()
    playerInCombat = true
    
    -- Auto-load combat modules when entering combat
    if settings.enabled then
        for name, module in pairs(moduleRegistry) do
            if moduleCategories[name] == MODULE_CATEGORY.COMBAT and not self:IsModuleLoaded(name) then
                -- Preload important combat modules
                self:LoadModule(name)
            end
        end
    end
end

-- Record combat exit for buffer time
function DynamicModuleLoading:PLAYER_REGEN_ENABLED()
    playerInCombat = false
    combatExitTime = GetTime()
    
    -- Set recently in combat flag
    playerRecentlyInCombat = true
    
    -- Clear after buffer time
    C_Timer.After(settings.combatBufferTime, function()
        playerRecentlyInCombat = false
    end)
    
    -- Schedule cleanup
    if settings.autoCleanupEnabled and not isPendingCleanup then
        C_Timer.After(settings.combatBufferTime + 10, function()
            if not playerInCombat and not playerRecentlyInCombat and not isPendingCleanup then
                self:PerformCleanup()
            end
        end)
    end
end

-- Handle roster update for smart loading
function DynamicModuleLoading:GROUP_ROSTER_UPDATE()
    -- Auto-load relevant modules when joining a group
    if settings.enabled and settings.profileBasedLoading and IsInGroup() then
        -- Check if this is a dungeon/raid group
        local inInstance, instanceType = IsInInstance()
        
        if inInstance then
            if instanceType == "party" or instanceType == "raid" then
                -- Load PvE modules
                for name, module in pairs(moduleRegistry) do
                    if moduleCategories[name] == MODULE_CATEGORY.PVE and not self:IsModuleLoaded(name) then
                        self:LoadModule(name)
                    end
                end
            elseif instanceType == "pvp" or instanceType == "arena" then
                -- Load PvP modules
                for name, module in pairs(moduleRegistry) do
                    if moduleCategories[name] == MODULE_CATEGORY.PVP and not self:IsModuleLoaded(name) then
                        self:LoadModule(name)
                    end
                end
            end
        end
    end
end

-- Create module configuration options 
function DynamicModuleLoading:GetConfigOptions()
    local options = {
        name = "Dynamic Module Loading",
        type = "group",
        args = {
            enabled = {
                order = 1,
                type = "toggle",
                name = "Enable Dynamic Module Loading",
                desc = "Enables on-demand loading and unloading of modules to reduce memory usage",
                get = function() return settings.enabled end,
                set = function(_, value) 
                    settings.enabled = value
                    VUI.db.profile.dynamicLoading.enabled = value
                end,
                width = "full",
            },
            autoCleanupEnabled = {
                order = 2,
                type = "toggle",
                name = "Enable Automatic Cleanup",
                desc = "Periodically unload unused modules to free memory",
                get = function() return settings.autoCleanupEnabled end,
                set = function(_, value) 
                    settings.autoCleanupEnabled = value
                    VUI.db.profile.dynamicLoading.autoCleanupEnabled = value
                    
                    if value and not cleanupTimer then
                        self:StartCleanupTimer()
                    elseif not value and cleanupTimer then
                        cleanupTimer:Cancel()
                        cleanupTimer = nil
                    end
                end,
                width = "full",
                disabled = function() return not settings.enabled end,
            },
            preloadCoreModules = {
                order = 3,
                type = "toggle",
                name = "Preload Core Modules",
                desc = "Automatically load essential modules at startup",
                get = function() return settings.preloadCoreModules end,
                set = function(_, value) 
                    settings.preloadCoreModules = value
                    VUI.db.profile.dynamicLoading.preloadCoreModules = value
                end,
                width = "full",
                disabled = function() return not settings.enabled end,
            },
            delayedStartup = {
                order = 4,
                type = "toggle",
                name = "Delayed Startup Loading",
                desc = "Delay loading non-essential modules until after login to improve initial loading time",
                get = function() return settings.delayedStartup end,
                set = function(_, value) 
                    settings.delayedStartup = value
                    VUI.db.profile.dynamicLoading.delayedStartup = value
                end,
                width = "full",
                disabled = function() return not settings.enabled end,
            },
            preserveUserSettings = {
                order = 5,
                type = "toggle",
                name = "Preserve User Settings",
                desc = "Keep user settings when unloading modules",
                get = function() return settings.preserveUserSettings end,
                set = function(_, value) 
                    settings.preserveUserSettings = value
                    VUI.db.profile.dynamicLoading.preserveUserSettings = value
                end,
                width = "full",
                disabled = function() return not settings.enabled end,
            },
            cleanupHeader = {
                order = 6,
                type = "header",
                name = "Cleanup Settings",
            },
            cleanupInterval = {
                order = 7,
                type = "range",
                name = "Cleanup Interval",
                desc = "Time between automatic cleanup checks (in seconds)",
                min = 60,
                max = 1800,
                step = 60,
                get = function() return settings.cleanupInterval end,
                set = function(_, value) 
                    settings.cleanupInterval = value
                    VUI.db.profile.dynamicLoading.cleanupInterval = value
                    
                    -- Restart cleanup timer if running
                    if cleanupTimer then
                        cleanupTimer:Cancel()
                        cleanupTimer = nil
                        self:StartCleanupTimer()
                    end
                end,
                width = "full",
                disabled = function() return not settings.enabled or not settings.autoCleanupEnabled end,
            },
            inactiveThreshold = {
                order = 8,
                type = "range",
                name = "Inactivity Threshold",
                desc = "Time before considering a module inactive (in seconds)",
                min = 60,
                max = 3600,
                step = 60,
                get = function() return settings.inactiveThreshold end,
                set = function(_, value) 
                    settings.inactiveThreshold = value
                    VUI.db.profile.dynamicLoading.inactiveThreshold = value
                end,
                width = "full",
                disabled = function() return not settings.enabled or not settings.autoCleanupEnabled end,
            },
            combatBufferTime = {
                order = 9,
                type = "range",
                name = "Combat Buffer Time",
                desc = "Time to keep combat modules loaded after exiting combat (in seconds)",
                min = 0,
                max = 300,
                step = 10,
                get = function() return settings.combatBufferTime end,
                set = function(_, value) 
                    settings.combatBufferTime = value
                    VUI.db.profile.dynamicLoading.combatBufferTime = value
                end,
                width = "full",
                disabled = function() return not settings.enabled or not settings.autoCleanupEnabled end,
            },
            aggressiveUnloading = {
                order = 10,
                type = "toggle",
                name = "Aggressive Unloading",
                desc = "Force unloading of modules even if they are dependencies of other modules",
                get = function() return settings.aggressiveUnloading end,
                set = function(_, value) 
                    settings.aggressiveUnloading = value
                    VUI.db.profile.dynamicLoading.aggressiveUnloading = value
                end,
                width = "full",
                disabled = function() return not settings.enabled or not settings.autoCleanupEnabled end,
            },
            advancedHeader = {
                order = 11,
                type = "header",
                name = "Advanced Settings",
            },
            debugMode = {
                order = 12,
                type = "toggle",
                name = "Debug Mode",
                desc = "Show detailed information about module loading and unloading",
                get = function() return settings.debugMode end,
                set = function(_, value) 
                    settings.debugMode = value
                    VUI.db.profile.dynamicLoading.debugMode = value
                end,
                width = "full",
                disabled = function() return not settings.enabled end,
            },
            manualCleanup = {
                order = 13,
                type = "execute",
                name = "Perform Cleanup Now",
                desc = "Manually perform a memory cleanup operation",
                func = function()
                    self:PerformCleanup()
                end,
                width = "full",
                disabled = function() 
                    return not settings.enabled or playerInCombat or playerRecentlyInCombat or isPendingCleanup
                end,
            },
            loadingThrottle = {
                order = 14,
                type = "range",
                name = "Loading Throttle",
                desc = "Minimum time between module loads (in seconds)",
                min = 0.1,
                max = 2.0,
                step = 0.1,
                get = function() return settings.loadingThrottle end,
                set = function(_, value) 
                    settings.loadingThrottle = value
                    VUI.db.profile.dynamicLoading.loadingThrottle = value
                end,
                width = "full",
                disabled = function() return not settings.enabled end,
            },
        }
    }
    
    return options
end

-- Register with VUI core
VUI:RegisterScript("core/dynamic_module_loading.lua")