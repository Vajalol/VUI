--[[
    VUI - UnitFrames ThemeIntegration
    Version: 0.3.0
    Author: VortexQ8
]]

local addonName, VUI = ...

if not VUI.UnitFrames then return end

-- Create local namespace
local UnitFrames = VUI.UnitFrames
UnitFrames.ThemeIntegration = {}
local ThemeIntegration = UnitFrames.ThemeIntegration

-- Store theme colors
local themeColors = {}
local activeTheme = "thunderstorm"

-- Initialize theme integration
function ThemeIntegration:Initialize()
    -- Get current theme colors
    activeTheme = VUI.db.profile.appearance.theme or "thunderstorm"
    themeColors = VUI.media.themes[activeTheme] or {}
    
    -- Register for theme changes
    if VUI.callbacks and VUI.callbacks.RegisterCallback then
        VUI.callbacks:RegisterCallback("OnThemeChanged", function(theme)
            self:ApplyTheme(theme)
        end)
    end
    
    -- Apply the theme immediately
    self:ApplyTheme(activeTheme)
    
    -- Log initialization
    if VUI.debug then
        VUI:Print("UnitFrames ThemeIntegration initialized")
    end
end

-- Apply the current theme to unit frames
function ThemeIntegration:ApplyTheme(theme)
    activeTheme = theme or VUI.db.profile.appearance.theme or "thunderstorm"
    themeColors = VUI.media.themes[activeTheme] or {}
    
    -- Call the existing ApplyTheme function to apply the theme to unitframes
    if UnitFrames.ApplyTheme then
        UnitFrames:ApplyTheme()
    end
end

-- Get the appropriate color based on the current theme
function ThemeIntegration:GetColor(colorType)
    if not themeColors then return {r = 0.1, g = 0.1, b = 0.1, a = 0.85} end
    
    -- Map colorType to actual theme color
    local colorMap = {
        background = themeColors.darkColor or {r = 0.1, g = 0.1, b = 0.1, a = 0.85},
        border = themeColors.primaryColor or {r = 0.4, g = 0.4, b = 0.4, a = 1.0},
        health = themeColors.primaryColor or {r = 0.4, g = 0.4, b = 0.4, a = 1.0},
        mana = {r = 0.2, g = 0.4, b = 0.8, a = 1.0},
        rage = {r = 0.8, g = 0.2, b = 0.2, a = 1.0},
        energy = {r = 0.8, g = 0.8, b = 0.2, a = 1.0},
        focus = {r = 0.8, g = 0.5, b = 0.2, a = 1.0},
        runic = {r = 0.2, g = 0.8, b = 0.8, a = 1.0},
        text = themeColors.textColor or {r = 0.9, g = 0.9, b = 0.9, a = 1.0},
        highlight = themeColors.highlightColor or {r = 1.0, g = 0.82, b = 0.0, a = 1.0}
    }
    
    return colorMap[colorType] or colorMap.border
end

-- Get a hex color string from the theme
function ThemeIntegration:GetHexColor(colorType)
    local color = self:GetColor(colorType)
    return self:ColorToHex(color)
end

-- Convert a color table to a hex string
function ThemeIntegration:ColorToHex(color)
    if not color then return "ffffff" end
    
    return string.format("%02x%02x%02x", 
        math.floor(color.r * 255), 
        math.floor(color.g * 255), 
        math.floor(color.b * 255))
end

-- Get a theme texture path
function ThemeIntegration:GetThemeTexture(textureType)
    local basePath = "Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. activeTheme .. "\\unitframes\\"
    
    local texturePaths = {
        border = basePath .. "border",
        background = basePath .. "background",
        health = basePath .. "healthbar",
        power = basePath .. "powerbar",
        highlight = basePath .. "highlight",
        glow = basePath .. "glow",
        shadow = basePath .. "shadow"
    }
    
    return texturePaths[textureType] or texturePaths.border
end