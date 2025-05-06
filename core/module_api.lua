-- VUI Module API
-- This file provides a standardized API for modules to interact with the VUI framework
local _, VUI = ...

-- Create the Module API namespace
VUI.ModuleAPI = {}

-- Documentation for how to use profiles in modules:
--[[
    Profile Integration for Module Developers:
    
    1. Access the current profile settings:
       local settings = VUI.db.profile.yourModuleName
    
    2. Save settings to profile:
       VUI.db.profile.yourModuleName.setting = value
    
    3. Register for profile changes:
       Implement UpdateUI() in your module:
       function YourModule:UpdateUI()
           -- Update UI based on VUI.db.profile.yourModuleName settings
       end
    
    4. Define default settings in your module's defaults table:
       defaultSettings = {
           yourModuleName = {
               setting1 = value1,
               setting2 = value2,
           }
       }
    
    5. For character-specific settings, use:
       VUI.charDB.profile.yourModuleName
]]

-- These functions are meant to be called from modules' init.lua files

-- Create and register a new VUI module
function VUI.ModuleAPI:CreateModule(name)
    -- Convert name to lowercase for consistency
    local lowerName = name:lower()
    
    -- Create a new module using the template
    local module = VUI.ModuleTemplate:Create(lowerName)
    
    -- Register it with VUI
    VUI:RegisterModule(lowerName, module)
    
    -- Update namespace
    VUI[lowerName] = module
    
    -- Register with Dashboard if available
    if VUI.Dashboard and VUI.Dashboard.RegisterModule then
        VUI.Dashboard:RegisterModule(lowerName, {
            description = "VUI " .. name .. " Module",
            getStatus = function()
                return {
                    enabled = VUI.db.profile.modules[lowerName] and VUI.db.profile.modules[lowerName].enabled or false
                }
            end,
            config = function()
                InterfaceOptionsFrame_OpenToCategory("VUI")
                InterfaceOptionsFrame_OpenToCategory("VUI " .. name)
            end
        })
    end
    
    return module
end

-- Initialize a module's settings with defaults
function VUI.ModuleAPI:InitializeModuleSettings(name, defaults)
    name = name:lower()
    
    -- Ensure db is initialized
    if not VUI.db then
        VUI.db = {
            profile = {
                modules = {},
                appearance = {
                    theme = "thunderstorm"
                },
                debugging = false
            }
        }
    end
    
    -- Create module entry in database if needed
    if not VUI.db.profile then
        VUI.db.profile = {}
    end
    
    if not VUI.db.profile.modules then
        VUI.db.profile.modules = {}
    end
    
    if not VUI.db.profile.modules[name] then
        VUI.db.profile.modules[name] = {
            enabled = true -- Enabled by default
        }
    end
    
    -- Apply defaults
    if defaults then
        for k, v in pairs(defaults) do
            if VUI.db.profile.modules[name][k] == nil then
                VUI.db.profile.modules[name][k] = v
            end
        end
    end
    
    return VUI.db.profile.modules[name]
end

-- Get a module's settings
function VUI.ModuleAPI:GetModuleSettings(name)
    name = name:lower()
    
    if VUI.db and VUI.db.profile and VUI.db.profile.modules and VUI.db.profile.modules[name] then
        return VUI.db.profile.modules[name]
    end
    
    return {}
end

-- Register a module's configuration options
function VUI.ModuleAPI:RegisterModuleConfig(name, configOptions)
    name = name:lower()
    
    -- Add to the options table
    if not VUI.options.args.modules then
        VUI.options.args.modules = {
            type = "group",
            name = "Modules",
            order = 2,
            args = {}
        }
    end
    
    -- Add module config
    VUI.options.args.modules.args[name] = configOptions
    
    -- Add to the module's GetOptions function
    local module = VUI[name]
    if module then
        module.GetOptions = function()
            return configOptions
        end
    end
    
    return true
end

-- Register a slash command for a module
function VUI.ModuleAPI:RegisterModuleSlashCommand(name, command, handler)
    name = name:lower()
    
    -- Create the slash command handler
    _G["SLASH_" .. command:upper() .. "1"] = "/" .. command:lower()
    SlashCmdList[command:upper()] = function(input)
        if handler then
            handler(input)
        else
            -- Default handler opens module config
            if VUI.options.args.modules and VUI.options.args.modules.args[name] then
                InterfaceOptionsFrame_OpenToCategory(VUI.name)
                InterfaceOptionsFrame_OpenToCategory(VUI.options.args.modules.args[name].name)
            else
                VUI:Print("No configuration available for " .. name)
            end
        end
    end
    
    return true
end

-- Enable a module's UI elements once the UI framework is fully loaded
function VUI.ModuleAPI:EnableModuleUI(name, initFunc)
    name = name:lower()
    
    -- Get the module
    local module = VUI[name]
    if not module then return false end
    
    -- Register for PLAYER_LOGIN event for UI setup
    VUI:RegisterEvent("PLAYER_LOGIN", function()
        -- Only run once all frameworks are available
        if not VUI.UI or not VUI.Widgets then
            VUI:ScheduleTimer(function()
                VUI.ModuleAPI:EnableModuleUI(name, initFunc)
            end, 0.5)
            return
        end
        
        -- Set up UI connections
        if not module.uiConnected then
            if module.ConnectUI then module:ConnectUI(VUI.UI) end
            if module.ConnectWidgets then module:ConnectWidgets(VUI.Widgets) end
            if module.ConnectMedia then module:ConnectMedia(VUI.media) end
            module.uiConnected = true
        end
        
        -- Call initialization function
        if initFunc then
            initFunc(module)
        end
    end)
    
    return true
end

-- Add a module's configuration panel to the VUI config system
function VUI.ModuleAPI:AddModuleConfigPanel(name, panelFunc)
    name = name:lower()
    
    -- Get the module
    local module = VUI[name]
    if not module then return false end
    
    -- Add the panel creation function
    module.CreateConfigPanel = panelFunc
    
    -- Add option to open config panel
    if module.GetOptions and module:GetOptions() and module:GetOptions().args then
        local options = module:GetOptions()
        
        options.args.openConfig = {
            type = "execute",
            name = "Open Configuration Panel",
            desc = "Opens the detailed configuration panel for " .. name,
            order = -1, -- Place at the top
            func = function()
                if module.CreateConfigPanel then
                    module:CreateConfigPanel():Show()
                end
            end
        }
    end
    
    return true
end

-- Register a module frame to participate in theme updates
function VUI.ModuleAPI:RegisterModuleFrame(name, frame)
    name = name:lower()
    
    -- Get the module
    local module = VUI[name]
    if not module then return false end
    
    -- Add to module's frames collection
    if not module.frames then
        module.frames = {}
    end
    
    table.insert(module.frames, frame)
    
    return true
end

-- Apply current VUI theme to a module frame
function VUI.ModuleAPI:ApplyThemeToFrame(frame)
    if not frame or not VUI.UI then return false end
    
    -- Apply theme if the frame supports it
    if frame.UpdateAppearance then
        frame:UpdateAppearance(VUI.db.profile.appearance)
        return true
    end
    
    return false
end