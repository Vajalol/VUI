--[[
    VUI - Module Manager
    Author: VortexQ8
    
    This file implements the module management system for VUI, integrating with
    the dynamic module loading system to provide a unified interface for managing
    modules and their dependencies.
]]

local _, VUI = ...
local L = VUI.L

-- Create the ModuleManager
local ModuleManager = {}
VUI.ModuleManager = ModuleManager

-- Reference to the DynamicModuleLoading system
local DynamicLoading = VUI.DynamicModuleLoading

-- Module reference cache
local moduleCache = {}

-- Settings
local settings = {
    enabled = true,
    trackUsageStats = true,
    moduleTimeout = 5.0,  -- Maximum time (seconds) to wait for a module to load
    autoRetry = true,     -- Auto-retry module loading on failure
    maxRetries = 3,       -- Maximum number of retries for module loading
    debugMode = false,    -- Enable debug output
}

-- Module usage statistics
local moduleStats = {
    accessCount = {},        -- Number of times each module was accessed
    loadTime = {},           -- Time taken to load each module
    lastAccess = {},         -- Last time each module was accessed
    failureCount = {},       -- Number of times module loading failed
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
    
    -- Wait for dynamic module loading to be available
    if not DynamicLoading then
        VUI:Print("Module Manager initialized (waiting for Dynamic Module Loading)")
        return
    end
    
    VUI:Print("Module Manager initialized")
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
    
    -- Check cache first
    if moduleCache[name] then
        -- Update access stats
        if settings.trackUsageStats then
            moduleStats.accessCount[name] = (moduleStats.accessCount[name] or 0) + 1
            moduleStats.lastAccess[name] = GetTime()
        end
        
        -- Notify DynamicLoading that module was accessed
        if DynamicLoading then
            DynamicLoading:UpdateModuleAccess(name)
        end
        
        return moduleCache[name]
    end
    
    -- Try original method
    local vModule = self.originalGetModule(VUI, name, true)
    
    if vModule then
        -- Cache the result
        moduleCache[name] = vModule
        
        -- Update access stats
        if settings.trackUsageStats then
            moduleStats.accessCount[name] = (moduleStats.accessCount[name] or 0) + 1
            moduleStats.lastAccess[name] = GetTime()
        end
        
        -- Notify DynamicLoading that module was accessed
        if DynamicLoading then
            DynamicLoading:UpdateModuleAccess(name)
        end
        
        return vModule
    end
    
    -- Module not found, use dynamic loading if available
    if DynamicLoading and settings.enabled then
        if DynamicLoading:IsModuleLoaded(name) then
            -- Module is loaded but not in cache, try again with original method
            vModule = self.originalGetModule(VUI, name, true)
            
            if vModule then
                moduleCache[name] = vModule
                
                -- Update access stats
                if settings.trackUsageStats then
                    moduleStats.accessCount[name] = (moduleStats.accessCount[name] or 0) + 1
                    moduleStats.lastAccess[name] = GetTime()
                end
                
                return vModule
            end
        else
            -- Try to load the module
            DynamicLoading:LoadModule(name, function(success, message)
                if success then
                    -- Module loaded, update cache
                    local module = self.originalGetModule(VUI, name, true)
                    if module then
                        moduleCache[name] = module
                    end
                else
                    -- Failed to load
                    if settings.debugMode then
                        VUI:Print("Failed to load module " .. name .. ": " .. message)
                    end
                    
                    -- Track failure
                    if settings.trackUsageStats then
                        moduleStats.failureCount[name] = (moduleStats.failureCount[name] or 0) + 1
                    end
                    
                    -- Auto-retry if enabled
                    if settings.autoRetry and moduleStats.failureCount[name] < settings.maxRetries then
                        if settings.debugMode then
                            VUI:Print("Retrying load of module " .. name .. " (attempt " .. moduleStats.failureCount[name] + 1 .. "/" .. settings.maxRetries .. ")")
                        end
                        
                        C_Timer.After(1, function()
                            DynamicLoading:LoadModule(name)
                        end)
                    end
                end
            end)
            
            -- Return nil for now, module will be available later
            if not silent then
                VUI:Print("Module " .. name .. " is being loaded dynamically. It will be available shortly.")
            end
            
            return nil
        end
    end
    
    -- Module not found and can't be loaded
    if not silent then
        VUI:Print("Module " .. name .. " not found.")
    end
    
    return nil
end

-- Call a method on a module, loading it if necessary
function ModuleManager:CallModuleMethod(moduleName, methodName, ...)
    if not moduleName or not methodName then
        return nil
    end
    
    -- Get module (will load if needed)
    local module = self:GetModule(moduleName, true)
    
    if module then
        -- Module already loaded, call method directly
        if type(module[methodName]) == "function" then
            return module[methodName](module, ...)
        else
            if settings.debugMode then
                VUI:Print("Method " .. methodName .. " not found in module " .. moduleName)
            end
            return nil
        end
    elseif DynamicLoading and settings.enabled then
        -- Module not loaded, load it first then call method
        if DynamicLoading:IsModuleLoaded(moduleName) then
            -- Module is loaded but not in cache for some reason
            module = self.originalGetModule(VUI, moduleName, true)
            
            if module and type(module[methodName]) == "function" then
                return module[methodName](module, ...)
            end
        else
            -- Queue for loading and execution
            local args = {...}
            
            DynamicLoading:LoadModule(moduleName, function(success)
                if success then
                    -- Module loaded, get reference and call method
                    local loadedModule = self.originalGetModule(VUI, moduleName, true)
                    
                    if loadedModule and type(loadedModule[methodName]) == "function" then
                        loadedModule[methodName](loadedModule, unpack(args))
                    else
                        if settings.debugMode then
                            VUI:Print("Method " .. methodName .. " not found in module " .. moduleName .. " after loading")
                        end
                    end
                else
                    if settings.debugMode then
                        VUI:Print("Failed to load module " .. moduleName .. " for method call " .. methodName)
                    end
                end
            end)
            
            -- Return nil for now
            return nil
        end
    end
    
    return nil
end

-- Check if a module is available
function ModuleManager:IsModuleAvailable(moduleName)
    if not moduleName then
        return false
    end
    
    -- Check cache first
    if moduleCache[moduleName] then
        return true
    end
    
    -- Check if module exists in VUI
    local module = self.originalGetModule(VUI, moduleName, true)
    if module then
        -- Cache for future reference
        moduleCache[moduleName] = module
        return true
    end
    
    -- Check dynamic loading system
    if DynamicLoading then
        return DynamicLoading:IsModuleLoaded(moduleName)
    end
    
    return false
end

-- Register module dependencies
function ModuleManager:RegisterDependencies(moduleName, dependencies)
    if not moduleName or not dependencies or #dependencies == 0 then
        return
    end
    
    -- Store dependencies
    moduleStats.dependencies[moduleName] = dependencies
    
    -- Register with dynamic loading system if available
    if DynamicLoading then
        DynamicLoading:RegisterModule(moduleName, nil, dependencies)
    end
end

-- Reload a module
function ModuleManager:ReloadModule(moduleName)
    if not moduleName then
        return false
    end
    
    -- Remove from cache
    moduleCache[moduleName] = nil
    
    -- Use dynamic loading if available
    if DynamicLoading then
        return DynamicLoading:ReloadModule(moduleName)
    end
    
    -- Can't reload without dynamic loading
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
        loadedCount = 0,
        mostAccessed = {},
        failedModules = {},
    }
    
    -- Count modules
    for name in pairs(moduleStats.accessCount) do
        stats.moduleCount = stats.moduleCount + 1
        
        if self:IsModuleAvailable(name) then
            stats.loadedCount = stats.loadedCount + 1
        end
    end
    
    -- Find most accessed modules
    local accessList = {}
    for name, count in pairs(moduleStats.accessCount) do
        table.insert(accessList, {name = name, count = count})
    end
    
    table.sort(accessList, function(a, b) return a.count > b.count end)
    
    -- Get top 5
    for i = 1, math.min(5, #accessList) do
        table.insert(stats.mostAccessed, accessList[i])
    end
    
    -- Find modules with load failures
    for name, count in pairs(moduleStats.failureCount) do
        if count > 0 then
            table.insert(stats.failedModules, {name = name, failures = count})
        end
    end
    
    -- Sort by failure count
    table.sort(stats.failedModules, function(a, b) return a.failures > b.failures end)
    
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
                desc = "Enables enhanced module management and dynamic loading",
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
            autoRetry = {
                order = 3,
                type = "toggle",
                name = "Auto-Retry Loading",
                desc = "Automatically retry loading modules if they fail",
                get = function() return settings.autoRetry end,
                set = function(_, value) 
                    settings.autoRetry = value
                    VUI.db.profile.moduleManager.autoRetry = value
                end,
                width = "full",
                disabled = function() return not settings.enabled end,
            },
            debugMode = {
                order = 4,
                type = "toggle",
                name = "Debug Mode",
                desc = "Show detailed information about module operations",
                get = function() return settings.debugMode end,
                set = function(_, value) 
                    settings.debugMode = value
                    VUI.db.profile.moduleManager.debugMode = value
                end,
                width = "full",
                disabled = function() return not settings.enabled end,
            },
            advancedHeader = {
                order = 5,
                type = "header",
                name = "Advanced Settings",
            },
            moduleTimeout = {
                order = 6,
                type = "range",
                name = "Module Timeout",
                desc = "Maximum time to wait for a module to load (in seconds)",
                min = 1,
                max = 30,
                step = 1,
                get = function() return settings.moduleTimeout end,
                set = function(_, value) 
                    settings.moduleTimeout = value
                    VUI.db.profile.moduleManager.moduleTimeout = value
                end,
                width = "full",
                disabled = function() return not settings.enabled end,
            },
            maxRetries = {
                order = 7,
                type = "range",
                name = "Maximum Retries",
                desc = "Maximum number of retries for module loading",
                min = 1,
                max = 10,
                step = 1,
                get = function() return settings.maxRetries end,
                set = function(_, value) 
                    settings.maxRetries = value
                    VUI.db.profile.moduleManager.maxRetries = value
                end,
                width = "full",
                disabled = function() return not settings.enabled or not settings.autoRetry end,
            },
            clearCache = {
                order = 8,
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
                order = 9,
                type = "execute",
                name = "Reset Usage Statistics",
                desc = "Reset all module usage statistics",
                func = function()
                    wipe(moduleStats.accessCount)
                    wipe(moduleStats.loadTime)
                    wipe(moduleStats.lastAccess)
                    wipe(moduleStats.failureCount)
                    VUI:Print("Module usage statistics reset")
                end,
                width = "full",
                disabled = function() return not settings.enabled or not settings.trackUsageStats end,
            },
        }
    }
    
    return options
end

-- Register with VUI core
VUI:RegisterScript("core/module_manager.lua")