--[[
    VUI - BuffOverlay ThemeIntegration
    Version: 0.2.0
    Author: VortexQ8
]]

local addonName, VUI = ...

if not VUI.modules.buffoverlay then return end

-- Create local namespace
local BuffOverlay = VUI.modules.buffoverlay
BuffOverlay.ThemeIntegration = {}
local ThemeIntegration = BuffOverlay.ThemeIntegration

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
        VUI:Print("BuffOverlay ThemeIntegration initialized")
    end
end

-- Apply the current theme to BuffOverlay
function ThemeIntegration:ApplyTheme(theme)
    activeTheme = theme or VUI.db.profile.appearance.theme or "thunderstorm"
    themeColors = VUI.media.themes[activeTheme] or {}
    
    -- Apply theme to existing buff frames
    self:ApplyThemeToAllBuffFrames()
    
    -- Apply theme to container frame
    self:StyleContainerFrame()
    
    -- Apply theme to configuration panel
    self:StyleConfigPanel()
end

-- Apply theme to all existing buff frames
function ThemeIntegration:ApplyThemeToAllBuffFrames()
    if not BuffOverlay.buffFrames then return end
    
    for _, frame in pairs(BuffOverlay.buffFrames) do
        self:ApplyThemeToBuffFrame(frame)
    end
end

-- Apply theme to a specific buff frame
function ThemeIntegration:ApplyThemeToBuffFrame(frame)
    if not frame then return end
    
    -- Get theme assets from the existing theme system
    local themeData = BuffOverlay.ThemeAssets[activeTheme]
    if not themeData then
        -- Use thunderstorm as default if theme data is missing
        themeData = BuffOverlay.ThemeAssets.thunderstorm
    end
    
    -- Set theme-specific textures
    if frame.themeOverlay then
        frame.themeOverlay:SetTexture(themeData.effects.spark or "Interface\\AddOns\\VUI\\media\\textures\\shared\\glow.tga")
    end
    
    -- Apply theme colors
    local colors = themeData.colors
    if frame.themeOverlay then
        frame.themeOverlay:SetVertexColor(colors.glow.r, colors.glow.g, colors.glow.b)
    end
    
    if frame.glow then
        frame.glow:SetVertexColor(colors.glow.r, colors.glow.g, colors.glow.b)
    end
    
    -- Apply border colors based on frame properties
    if frame.border then
        -- Use appropriate border color based on buff priority
        local borderColor = colors.border
        if frame.priority == "important" then
            borderColor = colors.important or {r = 0.9, g = 0.4, b = 0.0}
        elseif frame.priority == "critical" then
            borderColor = colors.critical or {r = 0.9, g = 0.0, b = 0.0}
        elseif frame.isPurge then
            borderColor = colors.purge or {r = 0.5, g = 0.0, b = 0.7}
        elseif frame.isOffensive then
            borderColor = colors.offensive or {r = 0.8, g = 0.2, b = 0.2}
        end
        
        frame.border:SetVertexColor(borderColor.r, borderColor.g, borderColor.b)
    end
    
    -- Create or update theme-specific animations
    BuffOverlay:CreateThemeAnimations(frame, activeTheme)
end

-- Style the main container frame
function ThemeIntegration:StyleContainerFrame()
    if not BuffOverlay.container then return end
    
    local container = BuffOverlay.container
    local backgroundColor = self:GetColor("background")
    local borderColor = self:GetColor("border")
    
    -- Style container background if it exists
    if container.background then
        container.background:SetColorTexture(
            backgroundColor.r, 
            backgroundColor.g, 
            backgroundColor.b, 
            backgroundColor.a or 0.5
        )
    end
    
    -- Style container border if it exists
    if container.border then
        container.border:SetColorTexture(
            borderColor.r, 
            borderColor.g, 
            borderColor.b, 
            borderColor.a or 0.8
        )
    end
end

-- Style the configuration panel
function ThemeIntegration:StyleConfigPanel()
    if not BuffOverlay.configPanel then return end
    
    local panel = BuffOverlay.configPanel
    local backgroundColor = self:GetColor("background")
    local borderColor = self:GetColor("border")
    local textColor = self:GetColor("text")
    
    -- Apply background color
    if panel.bg then
        panel.bg:SetColorTexture(
            backgroundColor.r,
            backgroundColor.g,
            backgroundColor.b,
            backgroundColor.a or 0.7
        )
    end
    
    -- Apply border color
    if panel.border then
        panel.border:SetColorTexture(
            borderColor.r,
            borderColor.g,
            borderColor.b,
            borderColor.a or 0.8
        )
    end
    
    -- Apply text colors to all text elements
    if panel.titleText and panel.titleText.SetTextColor then
        panel.titleText:SetTextColor(textColor.r, textColor.g, textColor.b, textColor.a or 1.0)
    end
    
    -- Apply colors to all category headers
    if panel.categoryHeaders then
        for _, header in pairs(panel.categoryHeaders) do
            if header.text and header.text.SetTextColor then
                header.text:SetTextColor(textColor.r, textColor.g, textColor.b, textColor.a or 1.0)
            end
            
            if header.line then
                header.line:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, 0.5)
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