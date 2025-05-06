--[[
    VUI - ActionBars ThemeIntegration
    Version: 1.0.0
    Author: VortexQ8
]]

local addonName, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end

if not VUI.actionbars then return end

-- Create local namespace
local ActionBars = VUI.actionbars
ActionBars.ThemeIntegration = {}
local ThemeIntegration = ActionBars.ThemeIntegration

-- Store theme colors
local themeColors = {}
local activeTheme = "thunderstorm"

-- Theme-specific assets paths
local themeAssets = {
    phoenixflame = {
        buttonBorder = "Interface\\AddOns\\VUI\\media\\textures\\themes\\phoenixflame\\actionbars\\border",
        buttonBackground = "Interface\\AddOns\\VUI\\media\\textures\\themes\\phoenixflame\\actionbars\\background",
        buttonHighlight = "Interface\\AddOns\\VUI\\media\\textures\\themes\\phoenixflame\\actionbars\\highlight",
        buttonPushed = "Interface\\AddOns\\VUI\\media\\textures\\themes\\phoenixflame\\actionbars\\pushed",
        cooldownOverlay = "Interface\\AddOns\\VUI\\media\\textures\\themes\\phoenixflame\\actionbars\\cooldown",
        barBackground = "Interface\\AddOns\\VUI\\media\\textures\\themes\\phoenixflame\\actionbars\\bar_bg"
    },
    thunderstorm = {
        buttonBorder = "Interface\\AddOns\\VUI\\media\\textures\\themes\\thunderstorm\\actionbars\\border",
        buttonBackground = "Interface\\AddOns\\VUI\\media\\textures\\themes\\thunderstorm\\actionbars\\background",
        buttonHighlight = "Interface\\AddOns\\VUI\\media\\textures\\themes\\thunderstorm\\actionbars\\highlight",
        buttonPushed = "Interface\\AddOns\\VUI\\media\\textures\\themes\\thunderstorm\\actionbars\\pushed",
        cooldownOverlay = "Interface\\AddOns\\VUI\\media\\textures\\themes\\thunderstorm\\actionbars\\cooldown",
        barBackground = "Interface\\AddOns\\VUI\\media\\textures\\themes\\thunderstorm\\actionbars\\bar_bg"
    },
    arcanemystic = {
        buttonBorder = "Interface\\AddOns\\VUI\\media\\textures\\themes\\arcanemystic\\actionbars\\border",
        buttonBackground = "Interface\\AddOns\\VUI\\media\\textures\\themes\\arcanemystic\\actionbars\\background",
        buttonHighlight = "Interface\\AddOns\\VUI\\media\\textures\\themes\\arcanemystic\\actionbars\\highlight",
        buttonPushed = "Interface\\AddOns\\VUI\\media\\textures\\themes\\arcanemystic\\actionbars\\pushed",
        cooldownOverlay = "Interface\\AddOns\\VUI\\media\\textures\\themes\\arcanemystic\\actionbars\\cooldown",
        barBackground = "Interface\\AddOns\\VUI\\media\\textures\\themes\\arcanemystic\\actionbars\\bar_bg"
    },
    felenergy = {
        buttonBorder = "Interface\\AddOns\\VUI\\media\\textures\\themes\\felenergy\\actionbars\\border",
        buttonBackground = "Interface\\AddOns\\VUI\\media\\textures\\themes\\felenergy\\actionbars\\background",
        buttonHighlight = "Interface\\AddOns\\VUI\\media\\textures\\themes\\felenergy\\actionbars\\highlight",
        buttonPushed = "Interface\\AddOns\\VUI\\media\\textures\\themes\\felenergy\\actionbars\\pushed",
        cooldownOverlay = "Interface\\AddOns\\VUI\\media\\textures\\themes\\felenergy\\actionbars\\cooldown",
        barBackground = "Interface\\AddOns\\VUI\\media\\textures\\themes\\felenergy\\actionbars\\bar_bg"
    }
}

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
        VUI:Print("ActionBars ThemeIntegration initialized")
    end
end

-- Apply the current theme to all action bars
function ThemeIntegration:ApplyTheme(theme)
    activeTheme = theme or VUI.db.profile.appearance.theme or "thunderstorm"
    themeColors = VUI.media.themes[activeTheme] or {}
    
    -- Apply theme to action buttons
    self:StyleActionButtons()
    
    -- Apply theme to action bar backgrounds
    self:StyleActionBarBackgrounds()
    
    -- Apply theme to cooldowns
    self:StyleCooldowns()
    
    -- Apply theme to hotkey text
    self:StyleHotkeyText()
    
    -- Update button borders based on theme
    self:UpdateButtonBorders()
end

-- Style all action buttons with theme colors and textures
function ThemeIntegration:StyleActionButtons()
    if not ActionBars.settings.enhancedButtonStyle then return end
    
    local assets = themeAssets[activeTheme] or themeAssets.thunderstorm
    
    -- This will be implemented in core.lua with actual button styling
    -- Placeholder for button styling implementation
end

-- Style action bar backgrounds
function ThemeIntegration:StyleActionBarBackgrounds()
    local assets = themeAssets[activeTheme] or themeAssets.thunderstorm
    
    -- This will be implemented in core.lua
    -- Placeholder for action bar background styling
end

-- Style cooldown overlays
function ThemeIntegration:StyleCooldowns()
    local assets = themeAssets[activeTheme] or themeAssets.thunderstorm
    
    -- This will be implemented in core.lua
    -- Placeholder for cooldown styling
end

-- Style hotkey text
function ThemeIntegration:StyleHotkeyText()
    if not ActionBars.settings.showHotkeys then return end
    
    local color = self:GetColor("hotkey")
    
    -- This will be implemented in core.lua
    -- Placeholder for hotkey text styling
end

-- Update button borders
function ThemeIntegration:UpdateButtonBorders()
    local assets = themeAssets[activeTheme] or themeAssets.thunderstorm
    local color = self:GetColor("border")
    
    -- This will be implemented in core.lua
    -- Placeholder for button border styling
end

-- Get the appropriate color based on the current theme
function ThemeIntegration:GetColor(colorType)
    if not themeColors then return {r = 0.1, g = 0.1, b = 0.1, a = 0.85} end
    
    -- Map colorType to actual theme color
    local colorMap = {
        background = themeColors.darkColor or {r = 0.1, g = 0.1, b = 0.1, a = 0.85},
        border = themeColors.primaryColor or {r = 0.4, g = 0.4, b = 0.4, a = 1.0},
        hotkey = themeColors.textColor or {r = 0.9, g = 0.9, b = 0.9, a = 1.0},
        button = themeColors.primaryColor or {r = 0.4, g = 0.4, b = 0.4, a = 1.0},
        highlight = themeColors.highlightColor or {r = 1.0, g = 0.82, b = 0.0, a = 1.0}
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