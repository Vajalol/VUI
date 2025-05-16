-- Core Configuration Module
local Core = VUI:NewModule("Config.Core")

-- Global configuration defaults and utilities 
Core.version = C_AddOns.GetAddOnMetadata("VUI", "version")

-- Initialization function
function Core:OnInitialize()
    -- Register modules dependencies
    self:RegisterDependency("Config.Install")
    self:RegisterDependency("Config.Gui")
    
    -- Setup base configuration hooks
    VUI.Config = function(toggle)
        local Gui = VUI:GetModule("Config.Gui")
        if Gui and Gui.OnEnable then
            Gui:OnEnable()
            
            if type(toggle) == "function" then
                return toggle()
            end
        else
            -- Fallback if GUI module not loaded
            VUI:Print("Configuration interface could not be loaded")
        end
    end
end

-- Safe module registration helper
function Core:RegisterDependency(moduleName)
    if not VUI:GetModule(moduleName, true) then
        VUI:Debug("CONFIG", "Module " .. moduleName .. " not found")
    end
end

-- Module management helpers
function Core:LoadModule(name)
    local module = VUI:GetModule(name, true)
    if module then
        if not module:IsEnabled() then
            module:Enable()
        end
        return module
    else
        VUI:Debug("CONFIG", "Failed to load module: " .. name)
        return nil
    end
end

-- Return the module
return Core 