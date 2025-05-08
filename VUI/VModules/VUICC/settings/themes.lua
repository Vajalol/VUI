-- VUICC: Theme management
-- Adapted from OmniCC (https://github.com/tullamods/OmniCC)

local AddonName, Addon = "VUI", VUI
local Module = Addon:GetModule("VUICC")
local Themes = {}

-- Helper function to create a deep copy of a table
local function copyTable(src)
    if type(src) ~= 'table' then return src end
    
    local result = {}
    for k, v in pairs(src) do
        if type(v) == 'table' then
            result[k] = copyTable(v)
        else
            result[k] = v
        end
    end
    
    return result
end

-- Get a list of all theme names
function Themes:GetList()
    local results = {'default'}
    
    for name in pairs(Module.db.themes) do
        table.insert(results, name)
    end
    
    table.sort(results)
    return results
end

-- Get a specific theme by name
function Themes:Get(name)
    if not name or name == 'default' then
        return Module.db.theme
    end
    
    return Module.db.themes[name]
end

-- Create a new theme
function Themes:New(name)
    if not name or name == '' or name == 'default' or Module.db.themes[name] then
        return false
    end
    
    -- Copy the default theme
    Module.db.themes[name] = copyTable(Module.db.theme)
    return true
end

-- Delete a theme
function Themes:Delete(name)
    if not name or name == 'default' or not Module.db.themes[name] then
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

-- Rename a theme
function Themes:Rename(oldName, newName)
    if not oldName or not newName or oldName == 'default' or newName == 'default' or 
       not Module.db.themes[oldName] or Module.db.themes[newName] or newName == '' then
        return false
    end
    
    -- Copy the theme with the new name
    Module.db.themes[newName] = copyTable(Module.db.themes[oldName])
    
    -- Remove the old theme
    Module.db.themes[oldName] = nil
    
    -- Update any rules using this theme
    for _, rule in pairs(Module.db.rules) do
        if rule.theme == oldName then
            rule.theme = newName
        end
    end
    
    return true
end

-- Update a theme setting
function Themes:SetThemeSetting(theme, key, value)
    local themeTable = self:Get(theme)
    if not themeTable then
        return false
    end
    
    themeTable[key] = value
    return true
end

-- Get font information
function Themes:GetFonts()
    local fonts = {}
    local mediaFonts = LibStub("LibSharedMedia-3.0"):HashTable("font")
    
    for name, path in pairs(mediaFonts) do
        table.insert(fonts, name)
    end
    
    table.sort(fonts)
    return fonts
end

-- Get font path from name
function Themes:GetFontPath(name)
    return LibStub("LibSharedMedia-3.0"):Fetch("font", name)
end

-- Get font outline options
function Themes:GetOutlines()
    return {
        NONE = "None",
        OUTLINE = "Outline",
        THICKOUTLINE = "Thick Outline",
        MONOCHROME = "Monochrome"
    }
end

-- Get anchor points
function Themes:GetAnchors()
    return {
        CENTER = "Center",
        TOP = "Top",
        TOPLEFT = "Top Left",
        TOPRIGHT = "Top Right",
        BOTTOM = "Bottom",
        BOTTOMLEFT = "Bottom Left",
        BOTTOMRIGHT = "Bottom Right",
        LEFT = "Left",
        RIGHT = "Right"
    }
end

-- Get effects list
function Themes:GetEffects()
    local effects = {}
    
    for _, effect in ipairs(Module.FX:GetList()) do
        effects[effect] = effect:gsub("^%l", string.upper)
    end
    
    return effects
end

-- Update module with Themes methods
Module.Themes = Themes