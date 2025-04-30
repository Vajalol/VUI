-- VUI Module Helper
-- Simple utility functions to help with module management and standardization
local _, VUI = ...

-- Create the module helper
VUI.ModuleHelper = {
    version = "1.0.0"
}

local Helper = VUI.ModuleHelper

-- Register a module 
function Helper:RegisterModule(name, module)
    if not name or not module then
        VUI:Print("Error registering module: Missing name or module")
        return
    end
    
    -- Add to VUI table
    VUI[name] = module
    
    -- Create database entry if it doesn't exist
    if VUI.db and VUI.db.profile and VUI.db.profile.modules and not VUI.db.profile.modules[name:lower()] then
        VUI.db.profile.modules[name:lower()] = {
            enabled = true
        }
    end
    
    -- Add basic methods if they don't exist
    if not module.Enable then
        module.Enable = function(self)
            self.enabled = true
            if VUI.debug then
                VUI:Print(name .. " enabled")
            end
        end
    end
    
    if not module.Disable then
        module.Disable = function(self)
            self.enabled = false
            if VUI.debug then
                VUI:Print(name .. " disabled")
            end
        end
    end
    
    if not module.ApplyTheme then
        module.ApplyTheme = function(self, theme)
            -- Default empty theme handler
        end
    end
    
    VUI:Print("Module registered: " .. name)
    return module
end

-- Apply a theme to all modules
function Helper:ApplyThemeToAllModules(theme)
    for name, module in pairs(VUI) do
        if type(module) == "table" and module.ApplyTheme then
            module:ApplyTheme(theme)
        end
    end
end

-- Get a list of all modules
function Helper:GetAllModules()
    local modules = {}
    
    for name, module in pairs(VUI) do
        if type(module) == "table" and type(name) == "string" and 
           (module.Initialize or module.Enable or module.Disable) then
            table.insert(modules, {
                name = name,
                module = module,
                enabled = module.enabled or false
            })
        end
    end
    
    return modules
end

-- Get enabled status for a module
function Helper:IsModuleEnabled(name)
    -- Check database first
    if VUI.db and VUI.db.profile and VUI.db.profile.modules and 
       VUI.db.profile.modules[name:lower()] then
        return VUI.db.profile.modules[name:lower()].enabled
    end
    
    -- Fallback to module state
    if VUI[name] and VUI[name].enabled ~= nil then
        return VUI[name].enabled
    end
    
    return false
end

-- Enable a module
function Helper:EnableModule(name)
    if not VUI[name] then return false end
    
    -- Update database
    if VUI.db and VUI.db.profile and VUI.db.profile.modules then
        if not VUI.db.profile.modules[name:lower()] then
            VUI.db.profile.modules[name:lower()] = {}
        end
        VUI.db.profile.modules[name:lower()].enabled = true
    end
    
    -- Call module's enable method
    if VUI[name].Enable then
        VUI[name]:Enable()
    end
    
    return true
end

-- Disable a module
function Helper:DisableModule(name)
    if not VUI[name] then return false end
    
    -- Update database
    if VUI.db and VUI.db.profile and VUI.db.profile.modules and
       VUI.db.profile.modules[name:lower()] then
        VUI.db.profile.modules[name:lower()].enabled = false
    end
    
    -- Call module's disable method
    if VUI[name].Disable then
        VUI[name]:Disable()
    end
    
    return true
end

-- Check if a module exists
function Helper:ModuleExists(name)
    return VUI[name] ~= nil
end

-- Initialize all modules
function Helper:InitializeAllModules()
    for name, module in pairs(VUI) do
        if type(module) == "table" and module.Initialize and type(name) == "string" then
            -- Create settings if they don't exist
            if VUI.db and VUI.db.profile and not VUI.db.profile.modules[name:lower()] then
                VUI.db.profile.modules[name:lower()] = {
                    enabled = true
                }
            end
            
            -- Initialize the module
            module:Initialize()
        end
    end
end

-- Add slash command
SLASH_VUIMODULE1 = "/vuimodule"
SlashCmdList["VUIMODULE"] = function(msg)
    local cmd, arg = string.match(msg, "^(%S+)%s*(.*)$")
    
    if cmd == "enable" and arg ~= "" then
        Helper:EnableModule(arg)
        VUI:Print("Enabled module: " .. arg)
    elseif cmd == "disable" and arg ~= "" then
        Helper:DisableModule(arg)
        VUI:Print("Disabled module: " .. arg)
    elseif cmd == "list" then
        local modules = Helper:GetAllModules()
        VUI:Print("Available modules:")
        for _, module in ipairs(modules) do
            local status = module.enabled and "|cFF00FF00Enabled|r" or "|cFFFF0000Disabled|r"
            VUI:Print("  - " .. module.name .. ": " .. status)
        end
    else
        VUI:Print("Module Helper commands:")
        VUI:Print("  /vuimodule enable <name> - Enable a module")
        VUI:Print("  /vuimodule disable <name> - Disable a module")
        VUI:Print("  /vuimodule list - List all modules")
    end
end