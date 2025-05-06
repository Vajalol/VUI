--[[
    VUI - Tools ThemeIntegration
    Version: 1.0.0
    Author: VortexQ8
]]

local addonName, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end

if not VUI.modules or not VUI.modules.tools then return end

-- Create local namespace
local Tools = VUI.modules.tools
Tools.ThemeIntegration = {}
local ThemeIntegration = Tools.ThemeIntegration

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
        VUI:Print("Tools ThemeIntegration initialized")
    end
end

-- Apply the current theme to Tools UI elements
function ThemeIntegration:ApplyTheme(theme)
    activeTheme = theme or VUI.db.profile.appearance.theme or "thunderstorm"
    themeColors = VUI.media.themes[activeTheme] or {}
    
    if not Tools.enabled then return end
    
    -- Apply theme to tools UI elements
    self:ApplyThemeToToolsUI()
    
    -- Apply theme to tool frames
    self:ApplyThemeToToolFrames()
    
    -- Apply theme to configuration panels
    self:ApplyThemeToConfigPanels()
end

-- Apply theme to tools UI elements
function ThemeIntegration:ApplyThemeToToolsUI()
    if not Tools.frame then return end
    
    local backgroundColor = self:GetColor("background")
    local borderColor = self:GetColor("border")
    local textColor = self:GetColor("text")
    
    -- Apply to main frame background
    if Tools.frame.background then
        Tools.frame.background:SetColorTexture(
            backgroundColor.r,
            backgroundColor.g,
            backgroundColor.b,
            0.9
        )
    end
    
    -- Apply to frame border
    if Tools.frame.border then
        Tools.frame.border:SetVertexColor(
            borderColor.r,
            borderColor.g,
            borderColor.b,
            1.0
        )
    end
    
    -- Apply to title text
    if Tools.frame.title then
        Tools.frame.title:SetTextColor(
            textColor.r,
            textColor.g,
            textColor.b,
            1.0
        )
    end
    
    -- Apply to section headers
    if Tools.frame.headers then
        for _, header in pairs(Tools.frame.headers) do
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
    
    -- Apply to tool buttons
    if Tools.frame.buttons then
        for _, button in pairs(Tools.frame.buttons) do
            if button.background then
                button.background:SetColorTexture(
                    backgroundColor.r * 1.2,
                    backgroundColor.g * 1.2,
                    backgroundColor.b * 1.2,
                    0.8
                )
            end
            
            if button.border then
                button.border:SetVertexColor(
                    borderColor.r,
                    borderColor.g,
                    borderColor.b,
                    1.0
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
end

-- Apply theme to individual tool frames
function ThemeIntegration:ApplyThemeToToolFrames()
    if not Tools.toolFrames then return end
    
    local backgroundColor = self:GetColor("background")
    local borderColor = self:GetColor("border")
    
    -- Apply theme to each tool frame
    for toolName, toolFrame in pairs(Tools.toolFrames) do
        if toolFrame.background then
            toolFrame.background:SetColorTexture(
                backgroundColor.r,
                backgroundColor.g,
                backgroundColor.b,
                0.9
            )
        end
        
        if toolFrame.border then
            toolFrame.border:SetVertexColor(
                borderColor.r,
                borderColor.g,
                borderColor.b,
                1.0
            )
        end
        
        if toolFrame.title then
            toolFrame.title:SetTextColor(1, 1, 1, 1)
        end
        
        -- Apply to tool frame buttons
        if toolFrame.buttons then
            for _, button in pairs(toolFrame.buttons) do
                if button.background then
                    button.background:SetColorTexture(
                        backgroundColor.r * 1.2,
                        backgroundColor.g * 1.2,
                        backgroundColor.b * 1.2,
                        0.8
                    )
                end
                
                if button.border then
                    button.border:SetVertexColor(
                        borderColor.r,
                        borderColor.g,
                        borderColor.b,
                        1.0
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
        
        -- Apply to input boxes
        if toolFrame.inputBoxes then
            for _, inputBox in pairs(toolFrame.inputBoxes) do
                if inputBox.background then
                    inputBox.background:SetColorTexture(0.1, 0.1, 0.1, 0.8)
                end
                
                if inputBox.border then
                    inputBox.border:SetVertexColor(
                        borderColor.r,
                        borderColor.g,
                        borderColor.b,
                        1.0
                    )
                end
            end
        end
        
        -- Apply to output frames
        if toolFrame.outputFrames then
            for _, outputFrame in pairs(toolFrame.outputFrames) do
                if outputFrame.background then
                    outputFrame.background:SetColorTexture(0.05, 0.05, 0.05, 0.9)
                end
                
                if outputFrame.border then
                    outputFrame.border:SetVertexColor(
                        borderColor.r,
                        borderColor.g,
                        borderColor.b,
                        1.0
                    )
                end
            end
        end
    end
end

-- Apply theme to configuration panels
function ThemeIntegration:ApplyThemeToConfigPanels()
    if not Tools.configPanels then return end
    
    local backgroundColor = self:GetColor("background")
    local borderColor = self:GetColor("border")
    
    -- Apply theme to each config panel
    for _, panel in pairs(Tools.configPanels) do
        if panel.background then
            panel.background:SetColorTexture(
                backgroundColor.r,
                backgroundColor.g,
                backgroundColor.b,
                0.9
            )
        end
        
        if panel.border then
            panel.border:SetVertexColor(
                borderColor.r,
                borderColor.g,
                borderColor.b,
                1.0
            )
        end
        
        -- Apply to checkboxes
        if panel.checkboxes then
            for _, checkbox in pairs(panel.checkboxes) do
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
        if panel.sliders then
            for _, slider in pairs(panel.sliders) do
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
        
        -- Apply to dropdown menus
        if panel.dropdowns then
            for _, dropdown in pairs(panel.dropdowns) do
                if dropdown.button and dropdown.button.border then
                    dropdown.button.border:SetVertexColor(
                        borderColor.r,
                        borderColor.g,
                        borderColor.b,
                        1.0
                    )
                end
                
                if dropdown.button and dropdown.button.background then
                    dropdown.button.background:SetColorTexture(
                        backgroundColor.r * 1.2,
                        backgroundColor.g * 1.2,
                        backgroundColor.b * 1.2,
                        0.8
                    )
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