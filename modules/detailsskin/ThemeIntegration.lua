--[[
    VUI - DetailsSkin ThemeIntegration
    Version: 0.2.0
    Author: VortexQ8
]]

local addonName, VUI = ...

if not VUI.modules.detailsskin then return end

-- Create local namespace
local DetailsSkin = VUI.modules.detailsskin
DetailsSkin.ThemeIntegration = {}
local ThemeIntegration = DetailsSkin.ThemeIntegration

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
        VUI:Print("DetailsSkin ThemeIntegration initialized")
    end
end

-- Apply the current theme to DetailsSkin
function ThemeIntegration:ApplyTheme(theme)
    activeTheme = theme or VUI.db.profile.appearance.theme or "thunderstorm"
    themeColors = VUI.media.themes[activeTheme] or {}
    
    -- Apply theme to all instances
    self:ApplyThemeToInstances()
    
    -- Apply theme to reports window if enabled
    if DetailsSkin.Reports then
        self:ApplyThemeToReports()
    end
    
    -- Apply theme to plugin frames
    self:ApplyThemeToPlugins()
end

-- Apply theme to all Details instances
function ThemeIntegration:ApplyThemeToInstances()
    if not _G.Details then return end
    
    local numInstances = _G.Details:GetNumInstances()
    for i = 1, numInstances do
        local instance = _G.Details:GetInstance(i)
        if instance then
            self:ApplyThemeToInstance(instance)
        end
    end
end

-- Apply theme to a specific Details instance
function ThemeIntegration:ApplyThemeToInstance(instance)
    if not instance then return end
    
    -- Get theme colors
    local backgroundColor = self:GetColor("background")
    local borderColor = self:GetColor("border")
    local accentColor = self:GetColor("accent")
    
    -- Apply theme-specific settings to instance
    instance.baseframe.backgroundimagefile = ""
    instance.baseframe.bgdisplay:SetVertexColor(
        backgroundColor.r, 
        backgroundColor.g, 
        backgroundColor.b, 
        backgroundColor.a or 0.8
    )
    
    -- Apply border color
    if instance.baseframe.BorderTop then
        instance.baseframe.BorderTop:SetVertexColor(
            borderColor.r, 
            borderColor.g, 
            borderColor.b, 
            borderColor.a or 1.0
        )
    end
    
    if instance.baseframe.BorderLeft then
        instance.baseframe.BorderLeft:SetVertexColor(
            borderColor.r, 
            borderColor.g, 
            borderColor.b, 
            borderColor.a or 1.0
        )
    end
    
    if instance.baseframe.BorderRight then
        instance.baseframe.BorderRight:SetVertexColor(
            borderColor.r, 
            borderColor.g, 
            borderColor.b, 
            borderColor.a or 1.0
        )
    end
    
    if instance.baseframe.BorderBottom then
        instance.baseframe.BorderBottom:SetVertexColor(
            borderColor.r, 
            borderColor.g, 
            borderColor.b, 
            borderColor.a or 1.0
        )
    end
    
    -- Apply to title bar
    if instance.baseframe.TitleBar then
        instance.baseframe.TitleBar:SetVertexColor(
            accentColor.r, 
            accentColor.g, 
            accentColor.b, 
            accentColor.a or 0.9
        )
    end
    
    -- Apply to bars if enabled
    if VUI.db.profile.modules.detailsskin.styleBars then
        -- Update bar colors based on theme
        instance:SetBarSettings(
            nil, -- texture stays the same
            nil, -- size
            {
                accentColor.r, 
                accentColor.g, 
                accentColor.b, 
                0.5  -- alpha
            }, -- fixedColor
            nil, -- backdropColor
            nil, -- barPadding
            nil  -- barCornerSize
        )
    end
    
    -- Update instance
    instance:InstanceRefresh()
end

-- Apply theme to reports window
function ThemeIntegration:ApplyThemeToReports()
    if not DetailsSkin.Reports or not DetailsSkin.Reports.styleReportWindow then return end
    
    -- Let Reports module apply theme
    DetailsSkin.Reports:styleReportWindow(activeTheme)
end

-- Apply theme to plugin frames
function ThemeIntegration:ApplyThemeToPlugins()
    if not _G.Details or not _G.Details.CreatePluginFrames then return end
    
    -- Style existing plugin frames
    if DetailsSkin and DetailsSkin.StylizePluginFrames then
        DetailsSkin:StylizePluginFrames(activeTheme)
    end
end

-- Get the appropriate color based on the current theme
function ThemeIntegration:GetColor(colorType)
    if not themeColors then return {r = 0.1, g = 0.1, b = 0.1, a = 0.85} end
    
    -- Map colorType to actual theme color
    local colorMap = {
        background = themeColors.darkColor or {r = 0.1, g = 0.1, b = 0.1, a = 0.85},
        border = themeColors.primaryColor or {r = 0.4, g = 0.4, b = 0.4, a = 1.0},
        accent = themeColors.highlightColor or {r = 0.6, g = 0.6, b = 0.6, a = 1.0},
        text = themeColors.textColor or {r = 0.9, g = 0.9, b = 0.9, a = 1.0}
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