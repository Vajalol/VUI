-- ThemeIntegration.lua for Tooltip Module
-- Standardized theme integration for the VUI tooltip module

local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end

if not VUI.tooltip then return end

-- Create local namespace
local Tooltip = VUI.tooltip
Tooltip.ThemeIntegration = {}
local ThemeIntegration = Tooltip.ThemeIntegration

-- Initialize theme integration
function ThemeIntegration:Initialize()
    -- Register for theme changes
    if VUI.callbacks and VUI.callbacks.RegisterCallback then
        VUI.callbacks:RegisterCallback("OnThemeChanged", function(theme)
            if Tooltip.enabled and Tooltip.settings.useThemeColors then
                self:ApplyTheme(theme)
            end
        end)
    end
    
    -- Initial theme application
    self:ApplyTheme(VUI.activeTheme)
    
    -- Log initialization
    if VUI.debug then
        VUI:Print("Tooltip ThemeIntegration initialized")
    end
end

-- Apply the current theme to tooltips
function ThemeIntegration:ApplyTheme(theme)
    if not theme then 
        theme = VUI.activeTheme or "thunderstorm" 
    end
    
    local themeColors = VUI.themes and VUI.themes[theme] or {}
    local tooltipColors = {
        -- Default fallback colors if theme doesn't provide specifics
        background = themeColors.darkColor or {r = 0.1, g = 0.1, b = 0.1, a = 0.85},
        border = themeColors.primaryColor or {r = 0.4, g = 0.4, b = 0.4, a = 1.0},
        header = themeColors.highlightColor or {r = 1.0, g = 0.82, b = 0.0, a = 1.0},
        statusBar = themeColors.primaryColor or {r = 0.4, g = 0.4, b = 0.4, a = 1.0}
    }
    
    -- Store the theme colors in the tooltip module for reference
    Tooltip.themeColors = tooltipColors
    
    -- Only apply immediately if the module is enabled and using theme colors
    if Tooltip.enabled and Tooltip.settings.useThemeColors then
        -- If there's a StyleAllTooltips function available, call it to refresh all tooltip styling
        if Tooltip.StyleAllTooltips then
            Tooltip:StyleAllTooltips()
        elseif Tooltip.RefreshStyle then
            Tooltip:RefreshStyle()
        end
    end
end

-- Get the appropriate color based on the current theme
function ThemeIntegration:GetColor(colorType)
    if not Tooltip.themeColors then return {r = 0.1, g = 0.1, b = 0.1, a = 0.85} end
    
    return Tooltip.themeColors[colorType] or Tooltip.themeColors.border
end

-- Convert a color table to a hex string
function ThemeIntegration:ColorToHex(color)
    if not color then return "ffffff" end
    
    return string.format("%02x%02x%02x", 
        math.floor(color.r * 255), 
        math.floor(color.g * 255), 
        math.floor(color.b * 255))
end