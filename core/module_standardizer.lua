-- VUI Module Standardizer
-- Utility for standardizing module structure and integrating with the core system
local addonName, VUI = ...

-- Create the Module Standardizer namespace
VUI.ModuleStandardizer = {
    -- Version information
    version = "0.2.0",
    author = "VUI Team",
    
    -- Tracking status
    processed = {},
    
    -- Standardization options
    options = {
        autoFix = true, -- Automatically fix common issues
        autoRegister = true, -- Auto-register modules with registry
        enforceNaming = true, -- Enforce standard naming conventions
        backupOldFiles = true, -- Create backups of modified files
        validateStructure = true, -- Validate module structure
        logLevel = 2 -- 0 = none, 1 = errors only, 2 = normal, 3 = verbose
    }
}

-- Standardizer reference
local Standardizer = VUI.ModuleStandardizer

-- Log message with appropriate level
function Standardizer:Log(level, ...)
    if not self.options.logLevel or self.options.logLevel < level then
        return
    end
    
    if level == 1 then
        VUI:Print("|cFFFF0000[Standardizer Error]|r", ...)
    elseif level == 2 then
        VUI:Print("|cFFFFCC00[Standardizer]|r", ...)
    elseif level == 3 then
        VUI:Print("|cFF00AAFF[Standardizer Debug]|r", ...)
    end
end

-- Standardize a module by name
function Standardizer:StandardizeModule(moduleName)
    if not moduleName then
        self:Log(1, "No module name provided")
        return false
    end
    
    -- Check if already processed
    if self.processed[moduleName] then
        self:Log(3, "Module already processed:", moduleName)
        return true
    end
    
    -- Check if module exists in VUI table
    if not VUI[moduleName] then
        self:Log(1, "Module does not exist:", moduleName)
        return false
    end
    
    local module = VUI[moduleName]
    
    -- Check for basic required methods
    self:Log(3, "Checking required methods for", moduleName)
    self:EnsureRequiredMethods(moduleName, module)
    
    -- Register with module registry if not already registered
    if self.options.autoRegister and VUI.ModuleRegistry and not VUI.ModuleRegistry:IsModuleRegistered(moduleName) then
        self:Log(2, "Auto-registering module with registry:", moduleName)
        
        -- Generate basic metadata
        local metadata = self:GenerateModuleMetadata(moduleName, module)
        
        -- Register with registry
        VUI.ModuleRegistry:RegisterModule(moduleName, metadata)
    end
    
    -- Standardize module structure if needed
    self:StandardizeModuleStructure(moduleName, module)
    
    -- Mark as processed
    self.processed[moduleName] = true
    
    self:Log(2, "Successfully standardized module:", moduleName)
    return true
end

-- Ensure a module has all required methods
function Standardizer:EnsureRequiredMethods(moduleName, module)
    -- Required methods with default implementations
    local requiredMethods = {
        Initialize = function(self)
            -- Create settings if needed
            if not VUI.db.profile.modules[moduleName:lower()] then
                VUI.db.profile.modules[moduleName:lower()] = {}
            end
            
            -- Set default enabled state if not specified
            if VUI.db.profile.modules[moduleName:lower()].enabled == nil then
                VUI.db.profile.modules[moduleName:lower()].enabled = true
            end
            
            -- Enable if set to enabled in profile
            if VUI.db.profile.modules[moduleName:lower()].enabled then
                self:Enable()
            end
            
            self:Log(3, moduleName .. " initialized")
        end,
        
        Enable = function(self)
            self.enabled = true
            self:Log(3, moduleName .. " enabled")
        end,
        
        Disable = function(self)
            self.enabled = false
            self:Log(3, moduleName .. " disabled")
        end,
        
        ApplyTheme = function(self, theme)
            -- Default theme application does nothing
            self:Log(3, moduleName .. " applied theme: " .. (theme or "default"))
        end
    }
    
    -- Add missing methods
    for name, defaultFunc in pairs(requiredMethods) do
        if not module[name] then
            self:Log(2, "Adding missing method to " .. moduleName .. ": " .. name)
            module[name] = defaultFunc
        end
    end
end

-- Generate metadata for a module
function Standardizer:GenerateModuleMetadata(moduleName, module)
    -- Default metadata
    local metadata = {
        name = moduleName,
        description = "VUI module: " .. moduleName,
        version = "0.1.0",
        author = "VUI Team",
        category = self:DetermineModuleCategory(moduleName)
    }
    
    -- Use existing metadata if provided in module
    if module.metadata then
        for k, v in pairs(module.metadata) do
            metadata[k] = v
        end
    end
    
    return metadata
end

-- Determine a module's category based on name or features
function Standardizer:DetermineModuleCategory(moduleName)
    -- Convert to lowercase for consistent matching
    local lowerName = moduleName:lower()
    
    -- Category detection based on name
    local categoryPatterns = {
        ["^unit"] = "UI",
        ["frame$"] = "UI",
        ["bar[s]?$"] = "UI",
        ["^skin"] = "Visuals",
        ["skin$"] = "Visuals",
        ["color"] = "Visuals",
        ["^tooltip"] = "UI",
        ["^chat"] = "UI",
        ["^config"] = "Core",
        ["^util"] = "Tools",
        ["^tool"] = "Tools",
        ["^integration"] = "Core",
        ["^performance"] = "Core",
        ["notification"] = "Visuals",
        ["^buff"] = "Visuals",
        ["^aura"] = "Visuals",
        ["^action"] = "UI",
        ["^bag"] = "UI",
        ["^inventory"] = "UI",
        ["^profile"] = "Tools",
        ["^map"] = "UI",
        ["^quest"] = "UI",
        ["^vendor"] = "Tools",
        ["^auction"] = "Addons",
        ["^movable"] = "UI",
        ["^combat"] = "Tools"
    }
    
    -- Check each pattern
    for pattern, category in pairs(categoryPatterns) do
        if lowerName:match(pattern) then
            return category
        end
    end
    
    -- Check module directory (for embedded addons)
    if VUI.ModuleRegistry and VUI.ModuleRegistry.modules then
        for name, metadata in pairs(VUI.ModuleRegistry.modules) do
            local module = name:lower()
            if lowerName:match(module) and metadata.category then
                return metadata.category
            end
        end
    end
    
    -- Default to Uncategorized
    return "Uncategorized"
end

-- Standardize module structure 
function Standardizer:StandardizeModuleStructure(moduleName, module)
    -- Add a logger method if missing
    if not module.Log then
        module.Log = function(self, level, ...)
            if level == 1 then
                VUI:Print("|cFFFF0000[" .. moduleName .. " Error]|r", ...)
            elseif level == 2 or not level then
                VUI:Print("|cFFFFCC00[" .. moduleName .. "]|r", ...)
            elseif level == 3 then
                if VUI.debug then
                    VUI:Print("|cFF00AAFF[" .. moduleName .. " Debug]|r", ...)
                end
            end
        end
    end
    
    -- Ensure there's a valid enabled property
    if module.enabled == nil then
        module.enabled = false
    end
    
    -- Add config-related methods if missing
    if not module.CreateConfig then
        module.CreateConfig = function(self)
            if VUI.ModuleConfigTemplate then
                return VUI.ModuleConfigTemplate:GenerateDefaultConfig(moduleName)
            else
                -- Fallback simple config
                return {
                    name = moduleName,
                    type = "group",
                    args = {
                        header = {
                            order = 1,
                            type = "header",
                            name = moduleName .. " Module",
                        },
                        enabled = {
                            order = 2,
                            type = "toggle",
                            name = "Enable",
                            desc = "Enable the " .. moduleName .. " module",
                            get = function() return VUI.db.profile.modules[moduleName:lower()].enabled end,
                            set = function(_, value)
                                VUI.db.profile.modules[moduleName:lower()].enabled = value
                                if value then
                                    self:Enable()
                                else
                                    self:Disable()
                                end
                            end
                        }
                    }
                }
            end
        end
    end
    
    -- Add config registration if missing
    if not module.RegisterConfig then
        module.RegisterConfig = function(self)
            if VUI.options and VUI.options.args then
                VUI.options.args[moduleName] = self:CreateConfig()
            end
        end
    end
    
    -- Add event registration helpers if missing
    if not module.RegisterEvents then
        module.RegisterEvents = function(self, events)
            if not self.eventFrame then
                self.eventFrame = CreateFrame("Frame")
                self.eventFrame:SetScript("OnEvent", function(_, event, ...)
                    if self[event] then
                        self[event](self, ...)
                    end
                end)
            end
            
            if type(events) == "table" then
                for _, event in ipairs(events) do
                    self.eventFrame:RegisterEvent(event)
                end
            else
                self.eventFrame:RegisterEvent(events)
            end
        end
        
        module.UnregisterEvents = function(self, events)
            if not self.eventFrame then
                return
            end
            
            if type(events) == "table" then
                for _, event in ipairs(events) do
                    self.eventFrame:UnregisterEvent(event)
                end
            elseif events then
                self.eventFrame:UnregisterEvent(events)
            else
                self.eventFrame:UnregisterAllEvents()
            end
        end
    end
    
    -- Add module callbacks if missing
    if not module.RegisterCallback then
        module.RegisterCallback = function(self, event, func)
            if not VUI.callbacks then
                VUI.callbacks = {}
            end
            
            if not VUI.callbacks[event] then
                VUI.callbacks[event] = {}
            end
            
            local callback = {
                module = moduleName,
                func = func
            }
            
            table.insert(VUI.callbacks[event], callback)
        end
        
        module.UnregisterCallback = function(self, event)
            if not VUI.callbacks or not VUI.callbacks[event] then
                return
            end
            
            -- Remove all callbacks for this module and event
            for i = #VUI.callbacks[event], 1, -1 do
                if VUI.callbacks[event][i].module == moduleName then
                    table.remove(VUI.callbacks[event], i)
                end
            end
        end
        
        -- Also add callback firing if it doesn't exist in VUI
        if not VUI.FireCallback then
            VUI.FireCallback = function(self, event, ...)
                if not self.callbacks or not self.callbacks[event] then
                    return
                end
                
                for _, callback in ipairs(self.callbacks[event]) do
                    if type(callback.func) == "function" then
                        callback.func(...)
                    elseif VUI[callback.module] and VUI[callback.module][callback.func] then
                        VUI[callback.module][callback.func](VUI[callback.module], ...)
                    end
                end
            end
        end
    end
    
    -- Add slash command registration if missing
    if not module.RegisterSlashCommand and VUI.RegisterSlashCommand then
        module.RegisterSlashCommand = function(self, command, handler, help)
            VUI:RegisterSlashCommand(command, handler, help)
        end
    end
    
    -- Add hook methods if missing
    if not module.Hook then
        module.Hook = function(self, object, method, hook, secure)
            -- Create hooks table if it doesn't exist
            if not self.hooks then
                self.hooks = {}
            end
            
            -- Check if already hooked
            if self.hooks[object] and self.hooks[object][method] then
                return
            end
            
            -- Create object table if it doesn't exist
            if not self.hooks[object] then
                self.hooks[object] = {}
            end
            
            -- Store original method
            self.hooks[object][method] = object[method]
            
            -- Create hook
            if secure then
                -- Create secure hook (doesn't replace original function)
                hooksecurefunc(object, method, hook)
            else
                -- Replace method with hook
                object[method] = function(...)
                    -- Call hook
                    local result = hook(...)
                    
                    -- Call original method if hook didn't return a value
                    if result == nil then
                        return self.hooks[object][method](...)
                    else
                        return result
                    end
                end
            end
        end
        
        module.Unhook = function(self, object, method)
            -- Check if hooks table exists
            if not self.hooks then
                return
            end
            
            -- Check if method is hooked
            if self.hooks[object] and self.hooks[object][method] then
                -- Restore original method
                object[method] = self.hooks[object][method]
                self.hooks[object][method] = nil
            end
        end
    end
    
    -- Add theme methods if missing
    if not module.UpdateTheme then
        module.UpdateTheme = function(self)
            self:ApplyTheme(VUI.db.profile.theme or "thunderstorm")
        end
    end
    
    -- Add module lifecycle hooks to ensure proper integration
    -- Store original Initialize method
    local originalInit = module.Initialize
    
    -- Replace with standardized version
    module.Initialize = function(self)
        -- Create settings if needed
        if not VUI.db.profile.modules[moduleName:lower()] then
            VUI.db.profile.modules[moduleName:lower()] = {}
        end
        
        -- Set default enabled state if not specified
        if VUI.db.profile.modules[moduleName:lower()].enabled == nil then
            VUI.db.profile.modules[moduleName:lower()].enabled = true
        end
        
        -- Call original initialization
        if originalInit then
            originalInit(self)
        end
        
        -- Register config if not already registered
        if self.RegisterConfig and VUI.options and not VUI.options.args[moduleName] then
            self:RegisterConfig()
        end
        
        -- Enable if set to enabled in profile and not explicitly enabled by original Init
        if VUI.db.profile.modules[moduleName:lower()].enabled and not self.enabled then
            self:Enable()
        end
        
        -- Apply theme
        if self.ApplyTheme then
            self:ApplyTheme(VUI.db.profile.theme or "thunderstorm")
        end
        
        -- Mark as initialized
        self.initialized = true
        
        self:Log(2, "Module initialized")
    end
end

-- Standardize all modules in the VUI table
function Standardizer:StandardizeAllModules()
    local count = 0
    
    -- Process all modules in VUI table
    for name, module in pairs(VUI) do
        if type(module) == "table" and module.Initialize and type(name) == "string" and name ~= "ModuleStandardizer" then
            if self:StandardizeModule(name) then
                count = count + 1
            end
        end
    end
    
    self:Log(2, "Standardized " .. count .. " modules")
    return count
end

-- Hook into VUI initialization
if VUI.HookInitialize then
    VUI:HookInitialize(function()
        -- Automatically standardize modules if enabled
        if Standardizer.options.autoFix then
            Standardizer:StandardizeAllModules()
        end
    end)
end

-- Register standardization command
if VUI.RegisterSlashCommand then
    VUI:RegisterSlashCommand("standardize", function(input)
        if input and input ~= "" then
            Standardizer:StandardizeModule(input)
        else
            Standardizer:StandardizeAllModules()
        end
    end, "Standardize modules to ensure consistent structure and behavior")
end