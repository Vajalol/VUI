-- VUI Module Initialization Template
-- This file provides a standard structure for module initialization
local addonName, VUI = ...

-- Create the Module Template namespace
VUI.ModuleTemplate = {
    -- Module template version (used for compatibility checks)
    version = "0.2.0",
    author = "VUI Team"
}

-- Module template reference
local Template = VUI.ModuleTemplate

-- Standard module initialization method
function Template:CreateNewModule(name, metadata)
    if not name then
        VUI:Print("Error: Cannot create module without a name")
        return nil
    end
    
    -- Create the module table
    local module = {}
    
    -- Default metadata
    local defaultMetadata = {
        name = name,
        description = "VUI module: " .. name,
        version = "0.1.0",
        author = "VUI Team",
        category = "Uncategorized",
        dependencies = {},
        conflicts = {},
        features = {},
        loadOrder = 50
    }
    
    -- Merge provided metadata with defaults
    if metadata then
        for k, v in pairs(metadata) do
            defaultMetadata[k] = v
        end
    end
    
    -- Register with module registry if available
    if VUI.ModuleRegistry then
        VUI.ModuleRegistry:RegisterModule(name, defaultMetadata)
    end
    
    -- Setup basic module methods
    -- Initialize method
    module.Initialize = function(self)
        -- Create settings if needed
        if not VUI.db.profile.modules[name:lower()] then
            VUI.db.profile.modules[name:lower()] = {}
        end
        
        -- Set default enabled state if not specified
        if VUI.db.profile.modules[name:lower()].enabled == nil then
            VUI.db.profile.modules[name:lower()].enabled = true
        end
        
        -- Add any module-specific initialization here
        -- ...
        
        -- Enable if set to enabled in profile
        if VUI.db.profile.modules[name:lower()].enabled then
            self:Enable()
        end
        
        -- Debug info
        if VUI.debug then
            VUI:Print(name .. " module initialized")
        end
    end
    
    -- Enable method
    module.Enable = function(self)
        self.enabled = true
        
        -- Add any module-specific enable code here
        -- ...
        
        -- Debug info
        if VUI.debug then
            VUI:Print(name .. " module enabled")
        end
    end
    
    -- Disable method
    module.Disable = function(self)
        self.enabled = false
        
        -- Add any module-specific disable code here
        -- ...
        
        -- Debug info
        if VUI.debug then
            VUI:Print(name .. " module disabled")
        end
    end
    
    -- Register events method
    module.RegisterEvents = function(self, events)
        if not self.eventFrame then
            self.eventFrame = CreateFrame("Frame")
            
            -- Set up event handler
            self.eventFrame:SetScript("OnEvent", function(frame, event, ...)
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
    
    -- Unregister events method
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
    
    -- Apply theme method
    module.ApplyTheme = function(self, theme)
        -- Get active theme or use provided one
        local activeTheme = theme or VUI.db.profile.theme or "thunderstorm"
        
        -- Apply theme to module elements
        -- ...
        
        -- Debug info
        if VUI.debug then
            VUI:Print(name .. " module applied theme: " .. activeTheme)
        end
    end
    
    -- Add to callbacks
    module.RegisterCallback = function(self, event, callback)
        if not VUI.callbacks then
            VUI.callbacks = {}
        end
        
        if not VUI.callbacks[event] then
            VUI.callbacks[event] = {}
        end
        
        table.insert(VUI.callbacks[event], { module = name, callback = callback })
    end
    
    -- Create config method
    module.CreateConfig = function(self)
        -- Create config structure
        local config = {
            name = name,
            type = "group",
            args = {
                header = {
                    order = 1,
                    type = "header",
                    name = name .. " Module",
                },
                enabled = {
                    order = 2,
                    type = "toggle",
                    name = "Enable",
                    desc = "Enable the " .. name .. " module",
                    get = function() return VUI.db.profile.modules[name:lower()].enabled end,
                    set = function(_, value)
                        VUI.db.profile.modules[name:lower()].enabled = value
                        if value then
                            self:Enable()
                        else
                            self:Disable()
                        end
                    end
                },
                -- Add more module-specific settings here
                -- ...
            }
        }
        
        -- Return generated config
        return config
    end
    
    -- Add config to options table
    module.AddConfig = function(self)
        if VUI.options and VUI.options.args then
            VUI.options.args[name] = self:CreateConfig()
        end
    end
    
    -- Add slash command handler
    module.RegisterSlashCommand = function(self, command, handler, help)
        if VUI.RegisterSlashCommand then
            VUI:RegisterSlashCommand(command, handler, help)
        end
    end
    
    -- Integration with ModuleRegistry for info
    module.GetModuleInfo = function(self)
        if VUI.ModuleRegistry and VUI.ModuleRegistry:IsModuleRegistered(name) then
            return VUI.ModuleRegistry:GetModuleMetadata(name)
        else
            return defaultMetadata
        end
    end
    
    -- Debugging helpers
    module.Debug = function(self, ...)
        if VUI.debug then
            VUI:Print("[" .. name .. "]", ...)
        end
    end
    
    -- Hook methods
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
    
    -- Unhook methods
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
    
    -- Return the created module
    return module
end

-- Example usage:
--[[ 
local MyModule = VUI.ModuleTemplate:CreateNewModule("MyModule", {
    description = "My awesome module",
    version = "1.0.0",
    author = "Your Name",
    category = "UI"
})

-- Add to VUI table
VUI.MyModule = MyModule

-- Hook initialization
if VUI.HookInitialize then
    VUI:HookInitialize(function()
        MyModule:Initialize()
    end)
end
]]--