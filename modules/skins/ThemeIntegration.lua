--[[
    VUI - Skins ThemeIntegration
    Version: 1.0.0
    Author: VortexQ8
]]

local addonName, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end

if not VUI.modules or not VUI.modules.skins then return end

-- Create local namespace
local Skins = VUI.modules.skins
Skins.ThemeIntegration = {}
local ThemeIntegration = Skins.ThemeIntegration

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
        VUI:Print("Skins ThemeIntegration initialized")
    end
end

-- Apply the current theme to Skins UI elements
function ThemeIntegration:ApplyTheme(theme)
    activeTheme = theme or VUI.db.profile.appearance.theme or "thunderstorm"
    themeColors = VUI.media.themes[activeTheme] or {}
    
    if not Skins.enabled then return end
    
    -- Apply theme to skins UI elements
    self:ApplyThemeToSkinsUI()
    
    -- Apply theme to skins configuration
    self:ApplyThemeToSkinsConfig()
    
    -- Apply theme to theme picker
    self:ApplyThemeToThemePicker()
    
    -- Apply theme to skin preview windows
    self:ApplyThemeToPreviewWindows()
end

-- Apply theme to skins UI elements
function ThemeIntegration:ApplyThemeToSkinsUI()
    if not Skins.frame then return end
    
    local backgroundColor = self:GetColor("background")
    local borderColor = self:GetColor("border")
    local textColor = self:GetColor("text")
    
    -- Apply to main frame background
    if Skins.frame.background then
        Skins.frame.background:SetColorTexture(
            backgroundColor.r,
            backgroundColor.g,
            backgroundColor.b,
            0.9
        )
    end
    
    -- Apply to frame border
    if Skins.frame.border then
        Skins.frame.border:SetVertexColor(
            borderColor.r,
            borderColor.g,
            borderColor.b,
            1.0
        )
    end
    
    -- Apply to title text
    if Skins.frame.title then
        Skins.frame.title:SetTextColor(
            textColor.r,
            textColor.g,
            textColor.b,
            1.0
        )
    end
    
    -- Apply to section headers
    if Skins.frame.headers then
        for _, header in pairs(Skins.frame.headers) do
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

-- Apply theme to skins configuration
function ThemeIntegration:ApplyThemeToSkinsConfig()
    if not Skins.configFrame then return end
    
    local backgroundColor = self:GetColor("background")
    local borderColor = self:GetColor("border")
    
    -- Apply to configuration frame
    if Skins.configFrame.background then
        Skins.configFrame.background:SetColorTexture(
            backgroundColor.r,
            backgroundColor.g,
            backgroundColor.b,
            0.9
        )
    end
    
    if Skins.configFrame.border then
        Skins.configFrame.border:SetVertexColor(
            borderColor.r,
            borderColor.g,
            borderColor.b,
            1.0
        )
    end
    
    -- Apply to section tabs
    if Skins.configFrame.tabs then
        for _, tab in pairs(Skins.configFrame.tabs) do
            if tab.selected then
                if tab.background then
                    tab.background:SetColorTexture(
                        borderColor.r * 0.7,
                        borderColor.g * 0.7,
                        borderColor.b * 0.7,
                        0.7
                    )
                end
                
                if tab.text then
                    tab.text:SetTextColor(1, 1, 1, 1)
                end
            else
                if tab.background then
                    tab.background:SetColorTexture(
                        backgroundColor.r,
                        backgroundColor.g,
                        backgroundColor.b,
                        0.7
                    )
                end
                
                if tab.text then
                    tab.text:SetTextColor(0.8, 0.8, 0.8, 1)
                end
            end
            
            if tab.border then
                tab.border:SetVertexColor(
                    borderColor.r,
                    borderColor.g,
                    borderColor.b,
                    1.0
                )
            end
        end
    end
    
    -- Apply to checkboxes
    if Skins.configFrame.checkboxes then
        for _, checkbox in pairs(Skins.configFrame.checkboxes) do
            if checkbox.border then
                checkbox.border:SetVertexColor(
                    borderColor.r,
                    borderColor.g,
                    borderColor.b,
                    1.0
                )
            end
            
            if checkbox.check and checkbox:GetChecked() then
                checkbox.check:SetVertexColor(
                    borderColor.r,
                    borderColor.g,
                    borderColor.b,
                    1.0
                )
            end
        end
    end
    
    -- Apply to sliders
    if Skins.configFrame.sliders then
        for _, slider in pairs(Skins.configFrame.sliders) do
            if slider.thumb then
                slider.thumb:SetVertexColor(
                    borderColor.r,
                    borderColor.g,
                    borderColor.b,
                    1.0
                )
            end
            
            if slider.track then
                slider.track:SetColorTexture(
                    backgroundColor.r * 1.2,
                    backgroundColor.g * 1.2,
                    backgroundColor.b * 1.2,
                    1.0
                )
            end
        end
    end
end

-- Apply theme to theme picker
function ThemeIntegration:ApplyThemeToThemePicker()
    if not Skins.themePicker then return end
    
    local backgroundColor = self:GetColor("background")
    local borderColor = self:GetColor("border")
    
    -- Apply to theme picker frame
    if Skins.themePicker.background then
        Skins.themePicker.background:SetColorTexture(
            backgroundColor.r,
            backgroundColor.g,
            backgroundColor.b,
            0.9
        )
    end
    
    if Skins.themePicker.border then
        Skins.themePicker.border:SetVertexColor(
            borderColor.r,
            borderColor.g,
            borderColor.b,
            1.0
        )
    end
    
    -- Apply to theme items
    if Skins.themePicker.themes then
        for _, themeItem in pairs(Skins.themePicker.themes) do
            -- Don't color the theme previews - they show their own colors
            
            -- But do color the selection border if this is the active theme
            if themeItem.isActive and themeItem.selectionBorder then
                themeItem.selectionBorder:SetVertexColor(
                    borderColor.r,
                    borderColor.g,
                    borderColor.b,
                    1.0
                )
            end
            
            if themeItem.title then
                themeItem.title:SetTextColor(1, 1, 1, 1)
            end
        end
    end
end

-- Apply theme to skin preview windows
function ThemeIntegration:ApplyThemeToPreviewWindows()
    if not Skins.previewWindows then return end
    
    local backgroundColor = self:GetColor("background")
    local borderColor = self:GetColor("border")
    
    for _, preview in pairs(Skins.previewWindows) do
        if preview.background then
            preview.background:SetColorTexture(
                backgroundColor.r,
                backgroundColor.g,
                backgroundColor.b,
                0.9
            )
        end
        
        if preview.border then
            preview.border:SetVertexColor(
                borderColor.r,
                borderColor.g,
                borderColor.b,
                1.0
            )
        end
        
        if preview.title then
            preview.title:SetTextColor(1, 1, 1, 1)
        end
        
        -- Don't color the preview content - it should show its own styling
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