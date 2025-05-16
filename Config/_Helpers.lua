-- Helper functions for Config modules
local VUI = _G.VUI

-- This file provides common helper functions for Config modules
VUI.ConfigHelpers = VUI.ConfigHelpers or {}

-- SafeGetModule: A robust function to get modules safely
-- Works with standard VUI modules, Data modules, and VModules
-- Handles different naming patterns and access methods
function VUI.ConfigHelpers.SafeGetModule(moduleName)
    local module
    
    -- Try multiple ways to access the module
    if VUI and VUI.GetModule and type(VUI.GetModule) == "function" then
        -- Try the standard method
        module = VUI:GetModule(moduleName, true) -- silent = true
    end
    
    -- Check direct module reference in VUI namespace
    if not module and VUI then
        -- For Data modules like Data.User, check VUI.User
        if moduleName:match("^Data%.") then
            local shortName = moduleName:match("Data%.(.+)")
            if shortName and VUI[shortName] then
                module = VUI[shortName]
            end
        -- For VModules, check both patterns (with/without VUI prefix)
        elseif moduleName:match("^VUI") then
            module = VUI[moduleName]
        else
            -- Try with VUI prefix
            module = VUI["VUI" .. moduleName]
        end
    end
    
    return module
end

-- SafeGetModuleWithRetry: Get a module with multiple retry attempts
-- Returns the module if found, or schedules a callback to retry
function VUI.ConfigHelpers.SafeGetModuleWithRetry(moduleName, callbackFn, maxAttempts)
    maxAttempts = maxAttempts or 3
    local attempts = 0
    
    local function tryGetModule()
        attempts = attempts + 1
        local module = VUI.ConfigHelpers.SafeGetModule(moduleName)
        
        if module then
            -- Module found, call the callback
            callbackFn(module)
            return true
        elseif attempts < maxAttempts then
            -- Retry after a delay with increasing interval
            C_Timer.After(attempts * 0.5, tryGetModule)
            return false
        else
            -- Max attempts reached
            return false
        end
    end
    
    -- Try immediately first
    local module = VUI.ConfigHelpers.SafeGetModule(moduleName)
    if module then
        return module
    else
        -- Start retry process
        tryGetModule()
        return nil
    end
end

-- FindVModule: Specialized function for Config Layout modules to find VModules
-- This is the recommended function for Config Layout modules to use
function VUI.ConfigHelpers.FindVModule(moduleName, onFoundCallback, maxAttempts)
    maxAttempts = maxAttempts or 3
    
    -- If VUI.SafeFindModuleWithRetry is available, use it (faster)
    if VUI.SafeFindModuleWithRetry then
        return VUI:SafeFindModuleWithRetry(moduleName, onFoundCallback, maxAttempts)
    end
    
    -- Fallback to our local implementation
    return VUI.ConfigHelpers.SafeGetModuleWithRetry(moduleName, onFoundCallback, maxAttempts)
end

-- Standard retry pattern for Config Layout modules 
function VUI.ConfigHelpers.ConfigLayoutModuleFinder(self, moduleName, enableCallback)
    VUI.ConfigHelpers.FindVModule(moduleName, function(module)
        if module and enableCallback then
            enableCallback(self, module)
        end
    end)
end

-- SafeGetVModule: Drop-in replacement for layout files
-- Will replace the individual SafeGetVModule functions in layout files
function VUI.ConfigHelpers.SafeGetVModule(moduleName)
    if not moduleName then return nil end
    
    local module = nil
    
    -- Method 1: Try direct namespace access 
    if VUI[moduleName] then
        module = VUI[moduleName]
    end
    
    -- Method 2: Try with GetModule
    if not module and VUI.GetModule then
        module = VUI:GetModule(moduleName, true)
    end
    
    -- Method 3: Try with direct global access
    if not module and _G[moduleName] then
        module = _G[moduleName]
    end
    
    -- Method 4: Try with lowercase
    if not module and VUI[string.lower(moduleName)] then
        module = VUI[string.lower(moduleName)]
    end
    
    -- Method 5: Try with VUITGCD special case
    if not module and moduleName == "VUITGCD" and VUI.VUITGCD then
        module = VUI.VUITGCD
    end
    
    -- Method 6: Try with VUI prefix if not already using it
    if not module and not moduleName:match("^VUI") then
        -- Try with VUI prefix
        module = VUI["VUI"..moduleName]
        
        -- Try with global with VUI prefix
        if not module and _G["VUI"..moduleName] then
            module = _G["VUI"..moduleName]
        end
    end
    
    -- Method 7: Try alternate case formats
    if not module then
        -- Try all uppercase
        module = VUI[string.upper(moduleName)] or _G[string.upper(moduleName)]
        
        -- Try title case
        if not module then
            local firstChar = string.sub(moduleName, 1, 1)
            local rest = string.sub(moduleName, 2)
            local titleCase = string.upper(firstChar) .. rest
            module = VUI[titleCase] or _G[titleCase]
        end
    end
    
    -- Method 8: Look in VUI.TGCD namespace for VUITGCD
    if not module and moduleName == "VUITGCD" and VUI.TGCD then
        module = VUI.TGCD
    end
    
    -- If module found, ensure it has a proper database connection
    if module then
        if VUI.db and not module.db then
            -- Create minimal database structure if missing
            module.db = module.db or {}
            module.db.profile = module.db.profile or {}
            
            -- Ensure vmodules path exists
            if not VUI.db.profile.vmodules then
                VUI.db.profile.vmodules = {}
            end
            
            -- Create module specific path
            local dbKey = string.lower(moduleName:gsub("^VUI", ""))
            if not VUI.db.profile.vmodules[dbKey] then
                VUI.db.profile.vmodules[dbKey] = {}
            end
            
            -- Connect them with metatable for two-way sync
            setmetatable(module.db.profile, {
                __index = function(t, k)
                    return VUI.db.profile.vmodules[dbKey][k]
                end,
                __newindex = function(t, k, v)
                    VUI.db.profile.vmodules[dbKey][k] = v
                end
            })
        end
    end
    
    return module
end

-- Make SafeGetVModule available globally for layout files
_G.SafeGetVModule = VUI.ConfigHelpers.SafeGetVModule

-- VUI Configuration Helpers
-- This file contains helper functions used by all Config files
-- to ensure consistency and proper module loading

--[[
    HOW TO ADD A NEW VMODULE LAYOUT:
    
    1. Create a new file in Config/Layouts/ with the name _VUIModuleName.lua
    2. Use the standard template pattern below:
    
    -- Example template:
    -- -------------------------------------------
    -- VUI Module Name Configuration
    -- Brief description of the module
    -- 
    
    local Layout = VUI:NewModule('Config.Layout.VUIModuleName')
    
    -- Initialize with the standard layout helper
    VUI.ConfigHelpers.CreateStandardLayout(Layout, "VUIModuleName", "VUI Module Display Name", "vmodules.vuimodulename")
    
    -- Define module-specific layout construction
    function Layout:BuildModuleLayout(module, db)
        -- Add module-specific settings here using table.insert(Layout.layout.rows, {...})
    end
    
    return Layout
]]

-- Create namespace if it doesn't exist
VUI.ConfigHelpers = VUI.ConfigHelpers or {}

-- FindVModule: Set up a callback for delayed module loading with multiple attempts
function VUI.ConfigHelpers.FindVModule(moduleName, callback, attempts)
    if not moduleName or not callback then return end
    
    attempts = attempts or 0
    local maxAttempts = 3
    
    -- Try to get the module
    local module = VUI.ConfigHelpers.SafeGetVModule(moduleName)
    
    if module then
        -- Module found, call the callback
        callback(module)
        
        -- Ensure the enabled property is properly set in vmodules
        if VUI.db and VUI.db.profile then
            local dbPath = 'vmodules.' .. string.lower(moduleName:gsub("^VUI", ""))
            local pathParts = {}
            for part in dbPath:gmatch("[^%.]+") do
                table.insert(pathParts, part)
            end
            
            local current = VUI.db.profile
            for i = 1, #pathParts-1 do
                if not current[pathParts[i]] then
                    current[pathParts[i]] = {}
                end
                current = current[pathParts[i]]
            end
            
            if #pathParts > 0 then
                if not current[pathParts[#pathParts]] then
                    current[pathParts[#pathParts]] = {}
                end
                
                -- If module has a db, sync the enabled state
                if module.db and module.db.profile then
                    if module.db.profile.enabled ~= nil then
                        current[pathParts[#pathParts]].enabled = module.db.profile.enabled
                    else
                        module.db.profile.enabled = current[pathParts[#pathParts]].enabled or false
                    end
                else
                    current[pathParts[#pathParts]].enabled = current[pathParts[#pathParts]].enabled or false
                end
            end
        end
        
        return module
    elseif attempts < maxAttempts then
        -- Register for module callbacks
        if VUI._moduleCallbacks then
            VUI._moduleCallbacks[moduleName] = VUI._moduleCallbacks[moduleName] or {}
            table.insert(VUI._moduleCallbacks[moduleName], callback)
        end
        
        -- Use timer for retry with increasing delay
        local delay = 0.5 * (attempts + 1)
        C_Timer.After(delay, function()
            VUI.ConfigHelpers.FindVModule(moduleName, callback, attempts + 1)
        end)
        
        -- Log retry attempt
        VUI:Debug("CONFIG", "Retry " .. (attempts + 1) .. "/" .. maxAttempts .. " finding module: " .. moduleName)
    else
        -- Max attempts reached
        VUI:Debug("CONFIG", "Failed to find module after " .. maxAttempts .. " attempts: " .. moduleName)
    end
    
    return nil
end

-- CreateStandardLayout: Helper for creating consistent layout structure
function VUI.ConfigHelpers.CreateStandardLayout(layoutModule, vmoduleName, layoutTitle, dbPath)
    if not layoutModule then return end
    
    -- Replace OnEnable with standardized version
    layoutModule.OnEnable = function(self)
        -- Database reference
        local db = VUI.db
        
        -- Get module safely using multiple methods
        local module = VUI.ConfigHelpers.SafeGetVModule(vmoduleName)
        
        -- Debug output
        if module then
            VUI:Debug("CONFIG", "Found module: " .. vmoduleName)
        else
            VUI:Debug("CONFIG", "Module not found: " .. vmoduleName .. ", will attempt delayed loading")
        end
        
        -- Determine DB path and module status
        local moduleDbPath = dbPath or ('vmodules.vui' .. string.lower(vmoduleName:gsub("^VUI", "")))
        local moduleStatus = module and "Module Status: Loaded" or "Module Status: Not Loaded"
        
        -- Ensure the database path exists
        if db and db.profile then
            local pathParts = {}
            for part in moduleDbPath:gmatch("[^%.]+") do
                table.insert(pathParts, part)
            end
            
            local current = db.profile
            for i = 1, #pathParts-1 do
                local part = pathParts[i]
                if not current[part] then
                    current[part] = {}
                end
                current = current[part]
            end
            
            -- Ensure the final property exists
            if #pathParts > 0 and not current[pathParts[#pathParts]] then
                current[pathParts[#pathParts]] = {}
            end
        end
        
        -- Create the basic layout structure - must be defined regardless of module status
        layoutModule.layout = {
            layoutConfig = { padding = { top = 15 } },
            database = db.profile,
            rows = {
                {
                    header = {
                        type = 'header',
                        label = layoutTitle or vmoduleName
                    },
                },
                {
                    enabled = {
                        key = dbPath and dbPath .. '.enabled' or ('vmodules.' .. string.lower(vmoduleName:gsub("^VUI", "")) .. '.enabled'),
                        type = 'checkbox',
                        label = 'Enable Module',
                        tooltip = 'Enable or disable this module',
                        column = 6,
                        order = 1,
                        callback = function(self)
                            -- Get latest module reference - it might have loaded since layout creation
                            local currentModule = VUI.ConfigHelpers.SafeGetVModule(vmoduleName) or module
                            if currentModule and currentModule.db then
                                local isEnabled = self:GetValue()
                                currentModule.db.profile.enabled = isEnabled
                                
                                -- Create db path if it doesn't exist
                                if db and db.profile then
                                    local pathParts = {}
                                    for part in moduleDbPath:gmatch("[^%.]+") do
                                        table.insert(pathParts, part)
                                    end
                                    
                                    local current = db.profile
                                    for i = 1, #pathParts-1 do
                                        if not current[pathParts[i]] then
                                            current[pathParts[i]] = {}
                                        end
                                        current = current[pathParts[i]]
                                    end
                                    
                                    if #pathParts > 0 then
                                        if not current[pathParts[#pathParts]] then
                                            current[pathParts[#pathParts]] = {}
                                        end
                                        current[pathParts[#pathParts]].enabled = isEnabled
                                    end
                                end
                                
                                -- Enable or disable module depending on setting
                                if isEnabled then
                                    if currentModule.OnEnable and not currentModule:IsEnabled() then 
                                        currentModule:Enable() 
                                    end
                                else
                                    if currentModule.OnDisable and currentModule:IsEnabled() then 
                                        currentModule:Disable() 
                                    end
                                end
                            end
                        end
                    },
                    loadModule = {
                        type = 'button',
                        text = 'Reload UI',
                        tooltip = 'Reload the user interface to ensure module loads correctly',
                        column = 6,
                        order = 2,
                        onClick = function()
                            ReloadUI()
                        end
                    }
                },
                {
                    moduleStatus = {
                        type = 'label',
                        label = moduleStatus,
                        column = 12,
                        order = 1,
                    }
                }
            }
        }
        
        -- If module builder function is provided and module is found, call it
        if self.BuildModuleLayout and module then
            -- Call the builder function to add module-specific layout elements
            self:BuildModuleLayout(module, db)
        else
            -- If module not found, try to find it with a delay and rebuild
            if not module and self.BuildModuleLayout then
                VUI:Debug("CONFIG", "Attempting delayed module loading for: " .. vmoduleName)
                
                VUI.ConfigHelpers.FindVModule(vmoduleName, function(foundModule)
                    if foundModule then
                        VUI:Debug("CONFIG", "Module found with delay: " .. vmoduleName)
                        
                        -- Update module status
                        if layoutModule.layout and layoutModule.layout.rows and layoutModule.layout.rows[3] and 
                           layoutModule.layout.rows[3].moduleStatus then
                            layoutModule.layout.rows[3].moduleStatus.label = "Module Status: Loaded"
                        end
                        
                        -- Add module-specific elements
                        self:BuildModuleLayout(foundModule, db)
                        
                        -- Force layout refresh if possible
                        if VUI.RefreshModuleUI then
                            VUI:RefreshModuleUI(vmoduleName)
                        end
                    end
                end)
            end
            
            -- Add basic placeholder content if module not found
            if not module then
                table.insert(layoutModule.layout.rows, {
                    placeholderInfo = {
                        type = 'label',
                        label = "This module is currently unavailable or not loaded.",
                        column = 12,
                        order = 1,
                    }
                })
                
                -- Add hint about how to enable
                table.insert(layoutModule.layout.rows, {
                    enableHint = {
                        type = 'label',
                        label = "Try enabling the module and reloading the UI to access its settings.",
                        column = 12,
                        order = 2,
                    }
                })
            end
        end
    end
    
    return layoutModule
end

-- Helper function to open module options that works with all VUI modules
VUI.ConfigHelpers.StandardOpenOptions = function(moduleName)
    -- Handle all possible VUI.Config patterns consistently
    if VUI then
        if VUI.Config and type(VUI.Config) == "function" then
            -- When Config is a function, call it directly
            VUI.Config(moduleName)
        elseif VUI.Config and type(VUI.Config) == "table" then
            -- When Config is a table
            if VUI.Config.OpenModule and type(VUI.Config.OpenModule) == "function" then
                -- Use OpenModule if available 
                VUI.Config:OpenModule(moduleName)
            elseif VUI.Config.Open and type(VUI.Config.Open) == "function" then
                -- Use Open if available
                VUI.Config:Open(moduleName)
            elseif VUI.Config.OpenToCategory and type(VUI.Config.OpenToCategory) == "function" then
                -- Use OpenToCategory if available
                VUI.Config:OpenToCategory(moduleName)
            end
        elseif VUI.OpenConfig and type(VUI.OpenConfig) == "function" then
            -- Try direct OpenConfig method on VUI
            VUI:OpenConfig(moduleName)
        elseif VUI.Options and VUI.Options.OpenToCategory and type(VUI.Options.OpenToCategory) == "function" then
            -- Try VUI.Options as a fallback
            VUI.Options:OpenToCategory(moduleName)
        elseif _G.AceConfigDialog and type(_G.AceConfigDialog.Open) == "function" then
            -- Fallback to AceConfigDialog if available
            _G.AceConfigDialog:Open(moduleName)
        else
            -- Last resort fallback using Blizzard's system
            pcall(function()
                InterfaceOptionsFrame_OpenToCategory(moduleName)
                InterfaceOptionsFrame_OpenToCategory(moduleName) -- Twice to handle Blizzard UI bug
            end)
        end
    elseif _G.AceConfigDialog and type(_G.AceConfigDialog.Open) == "function" then
        -- Fallback to AceConfigDialog if available
        _G.AceConfigDialog:Open(moduleName)
    else
        -- Last resort fallback using Blizzard's system
        pcall(function()
            InterfaceOptionsFrame_OpenToCategory(moduleName)
            InterfaceOptionsFrame_OpenToCategory(moduleName) -- Twice to handle Blizzard UI bug
        end)
    end
end

-- Create a global alias for StandardOpenOptions for modules to use directly
_G.OpenVUIModuleOptions = VUI.ConfigHelpers.StandardOpenOptions 