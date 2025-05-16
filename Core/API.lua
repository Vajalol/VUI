-- Safe module creation with error handling
function VUI:NewModule(name, ...)
    if not self or not name then
        print("VUI Error: Attempted to create module with invalid parameters")
        return {}
    end
    
    -- Track module loading attempts
    self._loadedModules = self._loadedModules or {}
    self._loadedModules[name] = true
    
    -- Capture varargs
    local args = {...}
    
    -- Define a default fallback module for error cases
    local defaultModule = {
        name = name,
        GetName = function() return name end,
        IsEnabled = function() return false end,
        Enable = function() end,
        Disable = function() end,
        isFallback = true
    }
    
    -- Use pcall to safely create the module
    local success, module = pcall(function() 
        return self.oldNewModule(self, name, unpack(args)) 
    end)
    
    if not success then
        print("VUI Error: Failed to create module " .. name)
        return defaultModule
    end
    
    return module
end

-- Override AceAddon's NewModule for safety
if not VUI.oldNewModule then
    VUI.oldNewModule = VUI.NewModule
    -- Make sure this is a function reference, not a function call
    VUI.NewModule = function(self, name, ...) 
        return VUI:NewModule(name, ...)
    end
end 