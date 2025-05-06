--[[
    VUI - Profiles ThemeIntegration
    Version: 1.0.0
    Author: VortexQ8
]]

local addonName, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end

if not VUI.modules or not VUI.modules.profiles then return end

-- Create local namespace
local Profiles = VUI.modules.profiles
Profiles.ThemeIntegration = {}
local ThemeIntegration = Profiles.ThemeIntegration

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
        VUI:Print("Profiles ThemeIntegration initialized")
    end
end

-- Apply the current theme to Profiles UI elements
function ThemeIntegration:ApplyTheme(theme)
    activeTheme = theme or VUI.db.profile.appearance.theme or "thunderstorm"
    themeColors = VUI.media.themes[activeTheme] or {}
    
    if not Profiles.enabled then return end
    
    -- Apply theme to profiles UI elements
    self:ApplyThemeToProfilesUI()
    
    -- Apply theme to profile dropdown
    self:ApplyThemeToProfileDropdown()
    
    -- Apply theme to profile management buttons
    self:ApplyThemeToProfileButtons()
end

-- Apply theme to profiles UI elements
function ThemeIntegration:ApplyThemeToProfilesUI()
    if not Profiles.frame then return end
    
    local backgroundColor = self:GetColor("background")
    local borderColor = self:GetColor("border")
    local textColor = self:GetColor("text")
    
    -- Apply to main frame background
    if Profiles.frame.background then
        Profiles.frame.background:SetColorTexture(
            backgroundColor.r,
            backgroundColor.g,
            backgroundColor.b,
            0.9
        )
    end
    
    -- Apply to frame border
    if Profiles.frame.border then
        Profiles.frame.border:SetVertexColor(
            borderColor.r,
            borderColor.g,
            borderColor.b,
            1.0
        )
    end
    
    -- Apply to title text
    if Profiles.frame.title then
        Profiles.frame.title:SetTextColor(
            textColor.r,
            textColor.g,
            textColor.b,
            1.0
        )
    end
    
    -- Apply to section headers
    if Profiles.frame.headers then
        for _, header in pairs(Profiles.frame.headers) do
            if header.text then
                header.text:SetTextColor(
                    borderColor.r,
                    borderColor.g,
                    borderColor.b,
                    1.0
                )
            end
            
            if header.line then
                header.line:SetColorTexture(
                    borderColor.r,
                    borderColor.g,
                    borderColor.b,
                    0.7
                )
            end
        end
    end
end

-- Apply theme to profile dropdown
function ThemeIntegration:ApplyThemeToProfileDropdown()
    if not Profiles.dropdown then return end
    
    local borderColor = self:GetColor("border")
    local backgroundColor = self:GetColor("background")
    
    -- Apply to dropdown border
    if Profiles.dropdown.border then
        Profiles.dropdown.border:SetVertexColor(
            borderColor.r,
            borderColor.g,
            borderColor.b,
            1.0
        )
    end
    
    -- Apply to dropdown background
    if Profiles.dropdown.background then
        Profiles.dropdown.background:SetColorTexture(
            backgroundColor.r,
            backgroundColor.g,
            backgroundColor.b,
            0.9
        )
    end
    
    -- Apply to dropdown text
    if Profiles.dropdown.text then
        Profiles.dropdown.text:SetTextColor(
            borderColor.r,
            borderColor.g,
            borderColor.b,
            1.0
        )
    end
    
    -- Apply to dropdown list items
    if Profiles.dropdown.items then
        for _, item in pairs(Profiles.dropdown.items) do
            if item.background then
                item.background:SetColorTexture(
                    backgroundColor.r,
                    backgroundColor.g,
                    backgroundColor.b,
                    0.9
                )
            end
            
            if item.highlight then
                item.highlight:SetColorTexture(
                    borderColor.r,
                    borderColor.g,
                    borderColor.b,
                    0.3
                )
            end
            
            if item.text then
                item.text:SetTextColor(1, 1, 1, 1)
            end
        end
    end
end

-- Apply theme to profile management buttons
function ThemeIntegration:ApplyThemeToProfileButtons()
    if not Profiles.buttons then return end
    
    local borderColor = self:GetColor("border")
    local backgroundColor = self:GetColor("background")
    
    for _, button in pairs(Profiles.buttons) do
        if button.border then
            button.border:SetVertexColor(
                borderColor.r,
                borderColor.g,
                borderColor.b,
                1.0
            )
        end
        
        if button.background then
            button.background:SetColorTexture(
                backgroundColor.r,
                backgroundColor.g,
                backgroundColor.b,
                0.8
            )
        end
        
        if button.text then
            button.text:SetTextColor(1, 1, 1, 1)
        end
        
        if button.highlight then
            button.highlight:SetColorTexture(
                borderColor.r,
                borderColor.g,
                borderColor.b,
                0.3
            )
        end
    end
end

-- Get the appropriate color based on the current theme
function ThemeIntegration:GetColor(colorType)
    if not themeColors then return {r = 0.1, g = 0.1, b = 0.1, a = 0.85} end
    
    -- Map colorType to actual theme color
    local colorMap = {
        background = themeColors.darkColor or themeColors.backdrop or {r = 0.1, g = 0.1, b = 0.1, a = 0.85},
        border = themeColors.primaryColor or themeColors.border or {r = 0.4, g = 0.4, b = 0.4, a = 1.0},
        text = themeColors.textColor or {r = 0.9, g = 0.9, b = 0.9, a = 1.0},
        accent = themeColors.highlightColor or {r = 1.0, g = 0.82, b = 0.0, a = 1.0}
    }
    
    return colorMap[colorType] or colorMap.border
end

-- Convert a color table to a hex string
function ThemeIntegration:ColorToHex(color)
    if not color then return "ffffff" end
    
    return string.format("%02x%02x%02x", 
        math.floor(color.r * 255), 
        math.floor(color.g * 255), 
        math.floor(color.b * 255))
end