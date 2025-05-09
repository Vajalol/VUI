-- VUICC: Settings implementation
-- Adapted from OmniCC (https://github.com/tullamods/OmniCC)

local AddonName, Addon = "VUI", VUI
local Module = Addon:GetModule("VUICC")
local Settings = Module.Settings

-- Initialize the database
function Settings:Init()
    -- Default settings
    local defaults = {
        profile = {
            enabled = true,
            disableBlizzardCooldownText = true,
            minimumDuration = 2,
            minEffectDuration = 30,
            tenthsDuration = 0,
            mmSSDuration = 0,
            spiralOpacity = 0.7,
            -- Default theme
            theme = {
                fontSize = 18,
                fontFace = 'Friz Quadrata TT',
                fontOutline = 'OUTLINE',
                minSize = 0.5,
                minDuration = 3,
                tenthsThreshold = 0,
                mmssThreshold = 0,
                xOff = 0,
                yOff = 0,
                anchor = 'CENTER',
                styles = {
                    soon = {
                        r = 1.0, g = 0.0, b = 0.0, a = 1.0,
                        scale = 1.0
                    },
                    seconds = {
                        r = 1.0, g = 1.0, b = 0.0, a = 1.0,
                        scale = 1.0
                    },
                    minutes = {
                        r = 1.0, g = 1.0, b = 1.0, a = 1.0,
                        scale = 1.0
                    },
                    hours = {
                        r = 0.7, g = 0.7, b = 0.7, a = 1.0,
                        scale = 0.75
                    },
                    days = {
                        r = 0.7, g = 0.7, b = 0.7, a = 1.0,
                        scale = 0.75
                    }
                },
                effect = 'pulse',
                effectSettings = {}
            },
            themes = {},
            rules = {}
        }
    }
    
    -- Initialize database with defaults
    if not Module.db then
        Module.db = {}
    end
    
    -- Merge defaults
    for k, v in pairs(defaults.profile) do
        if Module.db[k] == nil then
            Module.db[k] = v
        end
    end
    
    -- Make sure themes and rules exist
    if not Module.db.themes then
        Module.db.themes = {}
    end
    
    if not Module.db.rules then
        Module.db.rules = {}
    end
end

-- Get all themes
function Settings:GetThemes()
    return Module.db.themes
end

-- Get theme by name
function Settings:GetTheme(name)
    if not name or name == 'default' then
        return Module.db.theme
    end
    
    return Module.db.themes[name]
end

-- Add a new theme
function Settings:AddTheme(name)
    if name == '' or name == 'default' or Module.db.themes[name] then
        return false
    end
    
    -- Copy default theme
    local theme = {}
    for k, v in pairs(Module.db.theme) do
        if type(v) == 'table' then
            theme[k] = {}
            for k2, v2 in pairs(v) do
                if type(v2) == 'table' then
                    theme[k][k2] = {}
                    for k3, v3 in pairs(v2) do
                        theme[k][k2][k3] = v3
                    end
                else
                    theme[k][k2] = v2
                end
            end
        else
            theme[k] = v
        end
    end
    
    Module.db.themes[name] = theme
    return true
end

-- Delete a theme
function Settings:DeleteTheme(name)
    if name == 'default' or not Module.db.themes[name] then
        return false
    end
    
    -- Remove the theme
    Module.db.themes[name] = nil
    
    -- Update any rules using this theme
    for _, rule in pairs(Module.db.rules) do
        if rule.theme == name then
            rule.theme = 'default'
        end
    end
    
    return true
end

-- Get all rules
function Settings:GetRules()
    return Module.db.rules
end

-- Add a new rule
function Settings:AddRule(pattern, theme)
    if pattern == '' then
        return false
    end
    
    -- Check if rule already exists
    for _, rule in pairs(Module.db.rules) do
        if rule.pattern == pattern then
            return false
        end
    end
    
    -- Add the rule
    table.insert(Module.db.rules, {
        pattern = pattern,
        theme = theme or 'default'
    })
    
    return true
end

-- Delete a rule
function Settings:DeleteRule(index)
    if not Module.db.rules[index] then
        return false
    end
    
    table.remove(Module.db.rules, index)
    return true
end

-- Update module with Settings methods
Module.Settings = Settings