--[[
    VUI - InfoFrame ThemeIntegration
    Version: 1.0.0
    Author: VortexQ8
]]

local addonName, VUI = ...

if not VUI.InfoFrame then return end

-- Create local namespace
local InfoFrame = VUI.InfoFrame
InfoFrame.ThemeIntegration = {}
local ThemeIntegration = InfoFrame.ThemeIntegration

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
        VUI:Print("InfoFrame ThemeIntegration initialized")
    end
end

-- Apply the current theme to InfoFrame
function ThemeIntegration:ApplyTheme(theme)
    activeTheme = theme or VUI.db.profile.appearance.theme or "thunderstorm"
    themeColors = VUI.media.themes[activeTheme] or {}
    
    -- Apply theme to main frame
    self:StyleMainFrame()
    
    -- Apply theme to status bars
    self:StyleStatusBars()
    
    -- Apply theme to text elements
    self:StyleTextElements()
    
    -- Apply theme to borders
    self:StyleBorders()
    
    -- Apply theme to icons
    self:StyleIcons()
end

-- Style the main info frame
function ThemeIntegration:StyleMainFrame()
    if not InfoFrame.frame then return end
    
    local color = self:GetColor("background")
    local borderColor = self:GetColor("border")
    
    -- Style main frame background
    if InfoFrame.frame.bg then
        InfoFrame.frame.bg:SetColorTexture(color.r, color.g, color.b, color.a)
    end
    
    -- Style main frame border
    if InfoFrame.frame.borderFrame then
        InfoFrame.frame.borderFrame:SetBackdropBorderColor(
            borderColor.r, borderColor.g, borderColor.b, borderColor.a
        )
    end
end

-- Style status bars in the InfoFrame
function ThemeIntegration:StyleStatusBars()
    if not InfoFrame.frame then return end
    
    local bars = {
        InfoFrame.frame.healthBar,
        InfoFrame.frame.powerBar,
        InfoFrame.frame.experienceBar,
        InfoFrame.frame.reputationBar,
        InfoFrame.frame.honorBar,
        InfoFrame.frame.achievementBar
    }
    
    for _, bar in pairs(bars) do
        if bar then
            -- Update bar texture
            local texturePath = "Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. activeTheme .. "\\statusbar"
            if bar.SetStatusBarTexture then
                bar:SetStatusBarTexture(texturePath)
            end
            
            -- Update bar background
            if bar.bg then
                bar.bg:SetColorTexture(0.1, 0.1, 0.1, 0.7)
            end
        end
    end
end

-- Style text elements in the InfoFrame
function ThemeIntegration:StyleTextElements()
    if not InfoFrame.frame then return end
    
    local textColor = self:GetColor("text")
    local highlightColor = self:GetColor("highlight")
    
    local textElements = {
        InfoFrame.frame.titleText,
        InfoFrame.frame.locationText,
        InfoFrame.frame.clockText,
        InfoFrame.frame.statsText,
        InfoFrame.frame.performanceText
    }
    
    for _, text in pairs(textElements) do
        if text and text.SetTextColor then
            text:SetTextColor(textColor.r, textColor.g, textColor.b, textColor.a)
        end
    end
    
    -- Style value texts with highlight color
    local valueTexts = {
        InfoFrame.frame.healthText,
        InfoFrame.frame.powerText,
        InfoFrame.frame.experienceText,
        InfoFrame.frame.reputationText,
        InfoFrame.frame.honorText
    }
    
    for _, text in pairs(valueTexts) do
        if text and text.SetTextColor then
            text:SetTextColor(highlightColor.r, highlightColor.g, highlightColor.b, highlightColor.a)
        end
    end
end

-- Style borders in the InfoFrame
function ThemeIntegration:StyleBorders()
    if not InfoFrame.frame then return end
    
    local borderColor = self:GetColor("border")
    
    -- Style section borders
    local borders = {
        InfoFrame.frame.statsBorder,
        InfoFrame.frame.performanceBorder,
        InfoFrame.frame.resourcesBorder,
        InfoFrame.frame.progressBorder
    }
    
    for _, border in pairs(borders) do
        if border and border.SetBackdropBorderColor then
            border:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
        end
    end
end

-- Style icons in the InfoFrame
function ThemeIntegration:StyleIcons()
    if not InfoFrame.frame then return end
    
    -- Apply theme-specific icon styling if needed
    local iconBorderColor = self:GetColor("border")
    
    -- Style icon borders
    local icons = {
        InfoFrame.frame.currencyIcons,
        InfoFrame.frame.bagIcons,
        InfoFrame.frame.professionIcons
    }
    
    for _, iconGroup in pairs(icons) do
        if iconGroup then
            for _, icon in pairs(iconGroup) do
                if icon and icon.border and icon.border.SetVertexColor then
                    icon.border:SetVertexColor(iconBorderColor.r, iconBorderColor.g, iconBorderColor.b, iconBorderColor.a)
                end
            end
        end
    end
end

-- Get the appropriate color based on the current theme
function ThemeIntegration:GetColor(colorType)
    if not themeColors then return {r = 0.1, g = 0.1, b = 0.1, a = 0.85} end
    
    -- Map colorType to actual theme color
    local colorMap = {
        background = themeColors.darkColor or {r = 0.1, g = 0.1, b = 0.1, a = 0.85},
        border = themeColors.primaryColor or {r = 0.4, g = 0.4, b = 0.4, a = 1.0},
        text = themeColors.textColor or {r = 0.9, g = 0.9, b = 0.9, a = 1.0},
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