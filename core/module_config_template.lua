-- VUI Module Configuration Template
-- This file provides a standard structure for module configurations
local addonName, VUI = ...

-- Create the Module Config Template namespace
VUI.ModuleConfigTemplate = {
    -- Config template version (used for compatibility checks)
    version = "0.2.0",
    author = "VUI Team"
}

-- Module config template reference
local ConfigTemplate = VUI.ModuleConfigTemplate

-- Set up module default settings
function ConfigTemplate:CreateDefaultsTable(moduleName, customDefaults)
    if not moduleName then
        VUI:Print("Error: Cannot create defaults without a module name")
        return nil
    end
    
    -- Default settings structure
    local defaults = {
        enabled = true,
        theme = "thunderstorm",
        scale = 1.0,
        positions = {},
        settings = {}
    }
    
    -- Merge custom defaults if provided
    if customDefaults then
        for k, v in pairs(customDefaults) do
            if k == "settings" and type(v) == "table" then
                -- Merge settings table separately to avoid overwriting nested tables
                for key, value in pairs(v) do
                    defaults.settings[key] = value
                end
            else
                defaults[k] = v
            end
        end
    end
    
    return defaults
end

-- Generate global config section for module
function ConfigTemplate:GenerateDefaultConfig(moduleName, options)
    if not moduleName then
        VUI:Print("Error: Cannot create config without a module name")
        return nil
    end
    
    -- Default options
    options = options or {}
    
    -- Base configuration structure
    local config = {
        name = moduleName,
        type = "group",
        order = options.order or 10,
        args = {
            header = {
                order = 1,
                type = "header",
                name = options.displayName or moduleName .. " Module",
            },
            description = {
                order = 2,
                type = "description",
                name = options.description or "Configuration for the " .. moduleName .. " module.",
                fontSize = "medium",
            },
            enabled = {
                order = 3,
                type = "toggle",
                name = "Enable",
                desc = "Enable or disable the " .. moduleName .. " module.",
                width = "full",
                get = function() return VUI.db.profile.modules[moduleName:lower()].enabled end,
                set = function(_, value)
                    VUI.db.profile.modules[moduleName:lower()].enabled = value
                    if value then
                        if VUI[moduleName] and VUI[moduleName].Enable then
                            VUI[moduleName]:Enable()
                        end
                    else
                        if VUI[moduleName] and VUI[moduleName].Disable then
                            VUI[moduleName]:Disable()
                        end
                    end
                end
            },
            spacer1 = {
                order = 4,
                type = "description",
                name = " ",
                width = "full",
            }
        }
    }
    
    -- Add scale option if requested
    if options.showScale then
        config.args.scale = {
            order = 5,
            type = "range",
            name = "Scale",
            desc = "Adjust the scale of the " .. moduleName .. " interface elements.",
            min = 0.5,
            max = 2.0,
            step = 0.05,
            get = function() return VUI.db.profile.modules[moduleName:lower()].scale or 1.0 end,
            set = function(_, value)
                VUI.db.profile.modules[moduleName:lower()].scale = value
                -- Call scale update function if module has one
                if VUI[moduleName] and VUI[moduleName].UpdateScale then
                    VUI[moduleName]:UpdateScale()
                end
            end
        }
    end
    
    -- Add theme dropdown if requested
    if options.showTheme then
        config.args.theme = {
            order = 6,
            type = "select",
            name = "Theme",
            desc = "Select the visual theme for the " .. moduleName .. " module.",
            values = {
                ["thunderstorm"] = "Thunder Storm",
                ["phoenixflame"] = "Phoenix Flame",
                ["arcanemystic"] = "Arcane Mystic",
                ["felenergy"] = "Fel Energy",
                ["classcolor"] = "Class Color"
            },
            get = function() return VUI.db.profile.modules[moduleName:lower()].theme or "thunderstorm" end,
            set = function(_, value)
                VUI.db.profile.modules[moduleName:lower()].theme = value
                -- Call theme update function if module has one
                if VUI[moduleName] and VUI[moduleName].ApplyTheme then
                    VUI[moduleName]:ApplyTheme(value)
                end
            end
        }
    end
    
    -- Add reset positions button if requested
    if options.showResetPositions then
        config.args.resetPositions = {
            order = 7,
            type = "execute",
            name = "Reset Positions",
            desc = "Reset all " .. moduleName .. " element positions to default.",
            func = function()
                VUI.db.profile.modules[moduleName:lower()].positions = {}
                -- Call position reset function if module has one
                if VUI[moduleName] and VUI[moduleName].ResetPositions then
                    VUI[moduleName]:ResetPositions()
                end
            end
        }
    end
    
    -- Add reset settings button if requested
    if options.showResetSettings then
        config.args.resetSettings = {
            order = 8,
            type = "execute",
            name = "Reset Settings",
            desc = "Reset all " .. moduleName .. " settings to default values.",
            func = function()
                -- Get defaults and reset settings
                local defaults = ConfigTemplate:CreateDefaultsTable(moduleName, options.defaults)
                for k, v in pairs(defaults) do
                    if k ~= "enabled" then -- Keep enabled state
                        VUI.db.profile.modules[moduleName:lower()][k] = v
                    end
                end
                
                -- Call settings reset function if module has one
                if VUI[moduleName] and VUI[moduleName].ResetSettings then
                    VUI[moduleName]:ResetSettings()
                end
            end
        }
    end
    
    -- Add spacer before custom sections
    config.args.spacer2 = {
        order = 9,
        type = "description",
        name = " ",
        width = "full",
    }
    
    -- Add custom settings section for module
    config.args.settingsGroup = {
        order = 10,
        type = "group",
        name = "Settings",
        guiInline = true,
        args = {}
    }
    
    -- Merge custom settings if provided
    if options.settings and type(options.settings) == "table" then
        for k, v in pairs(options.settings) do
            config.args.settingsGroup.args[k] = v
        end
    end
    
    return config
end

-- Add get/set handler generators with appropriate path handling
ConfigTemplate.Handlers = {}

-- Generate a get handler for module settings
function ConfigTemplate.Handlers:GetHandler(moduleName, settingPath, default)
    return function()
        local settings = VUI.db.profile.modules[moduleName:lower()]
        
        -- Handle nested paths
        if type(settingPath) == "table" then
            local current = settings
            for i=1, #settingPath - 1 do
                if not current[settingPath[i]] then
                    return default
                end
                current = current[settingPath[i]]
            end
            return current[settingPath[#settingPath]] or default
        else
            return settings[settingPath] or default
        end
    end
end

-- Generate a set handler for module settings
function ConfigTemplate.Handlers:SetHandler(moduleName, settingPath, callback)
    return function(_, value)
        local settings = VUI.db.profile.modules[moduleName:lower()]
        
        -- Handle nested paths
        if type(settingPath) == "table" then
            local current = settings
            for i=1, #settingPath - 1 do
                if not current[settingPath[i]] then
                    current[settingPath[i]] = {}
                end
                current = current[settingPath[i]]
            end
            current[settingPath[#settingPath]] = value
        else
            settings[settingPath] = value
        end
        
        -- Call callback if provided
        if callback and type(callback) == "function" then
            callback(value)
        elseif VUI[moduleName] and callback and VUI[moduleName][callback] then
            VUI[moduleName][callback](VUI[moduleName], value)
        end
    end
end

-- Helper to generate color picker get/set handlers
function ConfigTemplate.Handlers:ColorHandler(moduleName, settingPath, callback)
    return {
        get = function()
            local color = ConfigTemplate.Handlers:GetHandler(moduleName, settingPath, {r=1, g=1, b=1, a=1})()
            return color.r, color.g, color.b, color.a
        end,
        set = function(_, r, g, b, a)
            ConfigTemplate.Handlers:SetHandler(moduleName, settingPath, callback)({r=r, g=g, b=b, a=a})
        end
    }
end

-- Generate common setting groups that modules can use
ConfigTemplate.SettingGroups = {}

-- Color settings group
function ConfigTemplate.SettingGroups:Colors(moduleName, colors, order)
    local group = {
        order = order or 20,
        type = "group",
        name = "Colors",
        guiInline = true,
        args = {}
    }
    
    -- Add color pickers
    local index = 1
    for name, settings in pairs(colors) do
        group.args[name] = {
            order = index,
            type = "color",
            name = settings.name or name,
            desc = settings.desc,
            hasAlpha = settings.hasAlpha or false,
            get = function()
                local color = ConfigTemplate.Handlers:GetHandler(moduleName, settings.path, settings.default or {r=1, g=1, b=1, a=1})()
                return color.r, color.g, color.b, color.a
            end,
            set = function(_, r, g, b, a)
                ConfigTemplate.Handlers:SetHandler(moduleName, settings.path, settings.callback)({r=r, g=g, b=b, a=a})
            end
        }
        index = index + 1
    end
    
    return group
end

-- Font settings group
function ConfigTemplate.SettingGroups:Fonts(moduleName, fonts, order)
    local group = {
        order = order or 30,
        type = "group",
        name = "Fonts",
        guiInline = true,
        args = {}
    }
    
    -- Get list of available fonts
    local fontList = {}
    for name, path in pairs(VUI.media.fonts) do
        fontList[name] = name
    end
    
    -- Add font selectors
    local index = 1
    for name, settings in pairs(fonts) do
        -- Font family dropdown
        group.args[name .. "Font"] = {
            order = index,
            type = "select",
            name = (settings.name or name) .. " Font",
            desc = settings.desc,
            values = fontList,
            get = ConfigTemplate.Handlers:GetHandler(moduleName, {settings.path[1], "font"}, settings.default.font or "Default"),
            set = ConfigTemplate.Handlers:SetHandler(moduleName, {settings.path[1], "font"}, settings.callback)
        }
        index = index + 1
        
        -- Font size slider
        group.args[name .. "Size"] = {
            order = index,
            type = "range",
            name = (settings.name or name) .. " Size",
            min = 6,
            max = 32,
            step = 1,
            get = ConfigTemplate.Handlers:GetHandler(moduleName, {settings.path[1], "size"}, settings.default.size or 12),
            set = ConfigTemplate.Handlers:SetHandler(moduleName, {settings.path[1], "size"}, settings.callback)
        }
        index = index + 1
        
        -- Font flags dropdown
        group.args[name .. "Flags"] = {
            order = index,
            type = "select",
            name = (settings.name or name) .. " Style",
            values = {
                [""] = "None",
                ["OUTLINE"] = "Outline",
                ["THICKOUTLINE"] = "Thick Outline",
                ["MONOCHROME"] = "Monochrome",
                ["OUTLINE,MONOCHROME"] = "Outline Monochrome"
            },
            get = ConfigTemplate.Handlers:GetHandler(moduleName, {settings.path[1], "flags"}, settings.default.flags or ""),
            set = ConfigTemplate.Handlers:SetHandler(moduleName, {settings.path[1], "flags"}, settings.callback)
        }
        index = index + 1
    end
    
    return group
end

-- Position settings group
function ConfigTemplate.SettingGroups:Positions(moduleName, elements, order)
    local group = {
        order = order or 40,
        type = "group",
        name = "Positions",
        guiInline = true,
        args = {
            description = {
                order = 1,
                type = "description",
                name = "Modify the position of UI elements. You can also drag elements in-game if they are movable.",
                fontSize = "medium",
                width = "full"
            },
            resetAll = {
                order = 2,
                type = "execute",
                name = "Reset All Positions",
                desc = "Reset all element positions to default.",
                func = function()
                    VUI.db.profile.modules[moduleName:lower()].positions = {}
                    -- Call position reset function if module has one
                    if VUI[moduleName] and VUI[moduleName].ResetPositions then
                        VUI[moduleName]:ResetPositions()
                    end
                end
            }
        }
    }
    
    -- Add position controls for each element
    local index = 3
    for name, settings in pairs(elements) do
        -- Element header
        group.args[name .. "Header"] = {
            order = index,
            type = "header",
            name = settings.name or name
        }
        index = index + 1
        
        -- X position
        group.args[name .. "X"] = {
            order = index,
            type = "range",
            name = "X Position",
            min = -1000,
            max = 1000,
            step = 1,
            get = ConfigTemplate.Handlers:GetHandler(moduleName, {"positions", name, "x"}, settings.default and settings.default.x or 0),
            set = ConfigTemplate.Handlers:SetHandler(moduleName, {"positions", name, "x"}, settings.callback)
        }
        index = index + 1
        
        -- Y position
        group.args[name .. "Y"] = {
            order = index,
            type = "range",
            name = "Y Position",
            min = -1000,
            max = 1000,
            step = 1,
            get = ConfigTemplate.Handlers:GetHandler(moduleName, {"positions", name, "y"}, settings.default and settings.default.y or 0),
            set = ConfigTemplate.Handlers:SetHandler(moduleName, {"positions", name, "y"}, settings.callback)
        }
        index = index + 1
        
        -- Reset this element button
        group.args[name .. "Reset"] = {
            order = index,
            type = "execute",
            name = "Reset",
            desc = "Reset position of " .. (settings.name or name) .. " to default.",
            func = function()
                VUI.db.profile.modules[moduleName:lower()].positions[name] = settings.default or {x=0, y=0}
                -- Call specific element position reset if available
                if VUI[moduleName] and VUI[moduleName].ResetPosition then
                    VUI[moduleName]:ResetPosition(name)
                end
            end
        }
        index = index + 1
    end
    
    return group
end

-- Texture settings group
function ConfigTemplate.SettingGroups:Textures(moduleName, textures, order)
    local group = {
        order = order or 50,
        type = "group",
        name = "Textures",
        guiInline = true,
        args = {}
    }
    
    -- Get list of available textures
    local textureList = {}
    for name, path in pairs(VUI.media.textures) do
        if type(path) == "string" then
            textureList[name] = name
        end
    end
    
    -- Add texture selectors
    local index = 1
    for name, settings in pairs(textures) do
        group.args[name] = {
            order = index,
            type = "select",
            name = settings.name or name,
            desc = settings.desc,
            values = textureList,
            get = ConfigTemplate.Handlers:GetHandler(moduleName, settings.path, settings.default or "Default"),
            set = ConfigTemplate.Handlers:SetHandler(moduleName, settings.path, settings.callback)
        }
        index = index + 1
    end
    
    return group
end

-- Example of how to use the config template:
--[[
-- Create a configuration for a module
local myModuleConfig = VUI.ModuleConfigTemplate:GenerateDefaultConfig("MyModule", {
    displayName = "My Awesome Module",
    description = "This module does amazing things!",
    showScale = true,
    showTheme = true,
    showResetPositions = true,
    showResetSettings = true,
    defaults = {
        enabled = true,
        theme = "phoenixflame",
        scale = 1.0,
        settings = {
            opacity = 0.8,
            showText = true,
            barWidth = 200
        }
    },
    settings = {
        -- Add module-specific settings here
        opacity = {
            order = 1,
            type = "range",
            name = "Opacity",
            min = 0,
            max = 1,
            step = 0.01,
            get = function() return VUI.db.profile.modules.mymodule.settings.opacity or 0.8 end,
            set = function(_, value) 
                VUI.db.profile.modules.mymodule.settings.opacity = value
                if VUI.MyModule and VUI.MyModule.UpdateOpacity then
                    VUI.MyModule:UpdateOpacity()
                end
            end
        },
        showText = {
            order = 2,
            type = "toggle",
            name = "Show Text",
            get = function() return VUI.db.profile.modules.mymodule.settings.showText end,
            set = function(_, value) 
                VUI.db.profile.modules.mymodule.settings.showText = value
                if VUI.MyModule and VUI.MyModule.UpdateText then
                    VUI.MyModule:UpdateText()
                end
            end
        }
    }
})

-- Add color settings group
myModuleConfig.args.colorGroup = VUI.ModuleConfigTemplate.SettingGroups:Colors("MyModule", {
    background = {
        name = "Background",
        desc = "Background color of the module frame",
        path = {"settings", "colors", "background"},
        default = {r=0, g=0, b=0, a=0.8},
        hasAlpha = true,
        callback = "UpdateColors"
    },
    border = {
        name = "Border",
        desc = "Border color of the module frame",
        path = {"settings", "colors", "border"},
        default = {r=0.5, g=0.5, b=0.5, a=1},
        hasAlpha = true,
        callback = "UpdateColors"
    }
})

-- Add font settings group
myModuleConfig.args.fontGroup = VUI.ModuleConfigTemplate.SettingGroups:Fonts("MyModule", {
    title = {
        name = "Title",
        path = {"settings", "fonts", "title"},
        default = {font="Default", size=14, flags="OUTLINE"},
        callback = "UpdateFonts"
    },
    text = {
        name = "Body Text",
        path = {"settings", "fonts", "text"},
        default = {font="Default", size=12, flags=""},
        callback = "UpdateFonts"
    }
})

-- Add to main options table
if VUI.options and VUI.options.args then
    VUI.options.args.MyModule = myModuleConfig
end
]]--