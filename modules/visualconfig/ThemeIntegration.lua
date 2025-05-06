--[[
    VUI - VisualConfig ThemeIntegration
    Version: 1.0.0
    Author: VortexQ8
]]

local addonName, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end

if not VUI.modules or not VUI.modules.visualconfig then return end

-- Create local namespace
local VisualConfig = VUI.modules.visualconfig
VisualConfig.ThemeIntegration = {}
local ThemeIntegration = VisualConfig.ThemeIntegration

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
        VUI:Print("VisualConfig ThemeIntegration initialized")
    end
end

-- Apply the current theme to VisualConfig UI elements
function ThemeIntegration:ApplyTheme(theme)
    activeTheme = theme or VUI.db.profile.appearance.theme or "thunderstorm"
    themeColors = VUI.media.themes[activeTheme] or {}
    
    if not VisualConfig.enabled or not VisualConfig.settings.general.useVUITheme then return end
    
    -- Apply theme to main configuration UI
    self:ApplyThemeToMainConfig()
    
    -- Apply theme to category panels
    self:ApplyThemeToCategoryPanels()
    
    -- Apply theme to widget elements
    self:ApplyThemeToWidgets()
    
    -- Apply theme to theme editor if available
    self:ApplyThemeToThemeEditor()
end

-- Apply theme to main configuration UI
function ThemeIntegration:ApplyThemeToMainConfig()
    if not VisualConfig.frame then return end
    
    local backgroundColor = self:GetColor("background")
    local borderColor = self:GetColor("border")
    local textColor = self:GetColor("text")
    
    -- Apply to main frame background
    if VisualConfig.frame.background then
        VisualConfig.frame.background:SetColorTexture(
            backgroundColor.r,
            backgroundColor.g,
            backgroundColor.b,
            0.9
        )
    end
    
    -- Apply to frame border
    if VisualConfig.frame.border then
        VisualConfig.frame.border:SetVertexColor(
            borderColor.r,
            borderColor.g,
            borderColor.b,
            1.0
        )
    end
    
    -- Apply to title text
    if VisualConfig.frame.title then
        VisualConfig.frame.title:SetTextColor(
            textColor.r,
            textColor.g,
            textColor.b,
            1.0
        )
    end
    
    -- Apply to category list
    if VisualConfig.frame.categoryList then
        if VisualConfig.frame.categoryList.background then
            VisualConfig.frame.categoryList.background:SetColorTexture(
                backgroundColor.r * 0.8,
                backgroundColor.g * 0.8,
                backgroundColor.b * 0.8,
                0.9
            )
        end
        
        if VisualConfig.frame.categoryList.border then
            VisualConfig.frame.categoryList.border:SetVertexColor(
                borderColor.r,
                borderColor.g,
                borderColor.b,
                1.0
            )
        end
        
        -- Apply to category buttons
        if VisualConfig.frame.categoryButtons then
            for _, button in pairs(VisualConfig.frame.categoryButtons) do
                -- Style based on selected state
                if button.selected then
                    if button.background then
                        button.background:SetColorTexture(
                            borderColor.r * 0.7,
                            borderColor.g * 0.7,
                            borderColor.b * 0.7,
                            0.7
                        )
                    end
                    
                    if button.text then
                        button.text:SetTextColor(1, 1, 1, 1)
                    end
                else
                    if button.background then
                        button.background:SetColorTexture(
                            backgroundColor.r * 1.2,
                            backgroundColor.g * 1.2,
                            backgroundColor.b * 1.2,
                            0.5
                        )
                    end
                    
                    if button.text then
                        button.text:SetTextColor(0.8, 0.8, 0.8, 1)
                    end
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
    
    -- Apply to content area
    if VisualConfig.frame.contentArea then
        if VisualConfig.frame.contentArea.background then
            VisualConfig.frame.contentArea.background:SetColorTexture(
                backgroundColor.r,
                backgroundColor.g,
                backgroundColor.b,
                0.8
            )
        end
        
        if VisualConfig.frame.contentArea.border then
            VisualConfig.frame.contentArea.border:SetVertexColor(
                borderColor.r,
                borderColor.g,
                borderColor.b,
                1.0
            )
        end
    end
    
    -- Apply to footer area
    if VisualConfig.frame.footer then
        if VisualConfig.frame.footer.background then
            VisualConfig.frame.footer.background:SetColorTexture(
                backgroundColor.r * 0.8,
                backgroundColor.g * 0.8,
                backgroundColor.b * 0.8,
                0.8
            )
        end
        
        if VisualConfig.frame.footer.border then
            VisualConfig.frame.footer.border:SetVertexColor(
                borderColor.r,
                borderColor.g,
                borderColor.b,
                1.0
            )
        end
        
        -- Apply to footer buttons
        if VisualConfig.frame.footer.buttons then
            for _, button in pairs(VisualConfig.frame.footer.buttons) do
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
end

-- Apply theme to category panels
function ThemeIntegration:ApplyThemeToCategoryPanels()
    if not VisualConfig.panels then return end
    
    local backgroundColor = self:GetColor("background")
    local borderColor = self:GetColor("border")
    
    -- Apply theme to each panel
    for _, panel in pairs(VisualConfig.panels) do
        if panel.background then
            panel.background:SetColorTexture(
                backgroundColor.r,
                backgroundColor.g,
                backgroundColor.b,
                0.8
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
        
        -- Apply to section headers
        if panel.headers then
            for _, header in pairs(panel.headers) do
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
end

-- Apply theme to widget elements
function ThemeIntegration:ApplyThemeToWidgets()
    if not VisualConfig.widgets then return end
    
    local backgroundColor = self:GetColor("background")
    local borderColor = self:GetColor("border")
    
    -- Apply theme to each widget type
    
    -- Checkboxes
    if VisualConfig.widgets.checkboxes then
        for _, checkbox in pairs(VisualConfig.widgets.checkboxes) do
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
    
    -- Sliders
    if VisualConfig.widgets.sliders then
        for _, slider in pairs(VisualConfig.widgets.sliders) do
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
    
    -- Dropdowns
    if VisualConfig.widgets.dropdowns then
        for _, dropdown in pairs(VisualConfig.widgets.dropdowns) do
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
            
            -- Style dropdown list if it's open
            if dropdown.list and dropdown.list:IsShown() then
                if dropdown.list.background then
                    dropdown.list.background:SetColorTexture(
                        backgroundColor.r,
                        backgroundColor.g,
                        backgroundColor.b,
                        0.95
                    )
                end
                
                if dropdown.list.border then
                    dropdown.list.border:SetVertexColor(
                        borderColor.r,
                        borderColor.g,
                        borderColor.b,
                        1.0
                    )
                end
                
                -- Style dropdown items
                if dropdown.list.items then
                    for _, item in pairs(dropdown.list.items) do
                        if item.highlight then
                            item.highlight:SetColorTexture(
                                borderColor.r,
                                borderColor.g,
                                borderColor.b,
                                0.3
                            )
                        end
                    end
                end
            end
        end
    end
    
    -- Input boxes
    if VisualConfig.widgets.inputBoxes then
        for _, inputBox in pairs(VisualConfig.widgets.inputBoxes) do
            if inputBox.border then
                inputBox.border:SetVertexColor(
                    borderColor.r,
                    borderColor.g,
                    borderColor.b,
                    1.0
                )
            end
            
            if inputBox.background then
                inputBox.background:SetColorTexture(
                    backgroundColor.r * 0.7,
                    backgroundColor.g * 0.7,
                    backgroundColor.b * 0.7,
                    0.8
                )
            end
        end
    end
    
    -- Buttons
    if VisualConfig.widgets.buttons then
        for _, button in pairs(VisualConfig.widgets.buttons) do
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
    
    -- Color pickers
    if VisualConfig.widgets.colorPickers then
        for _, colorPicker in pairs(VisualConfig.widgets.colorPickers) do
            if colorPicker.border then
                colorPicker.border:SetVertexColor(
                    borderColor.r,
                    borderColor.g,
                    borderColor.b,
                    1.0
                )
            end
        end
    end
end

-- Apply theme to theme editor
function ThemeIntegration:ApplyThemeToThemeEditor()
    if not VisualConfig.themeEditor then return end
    
    local backgroundColor = self:GetColor("background")
    local borderColor = self:GetColor("border")
    
    -- Apply to theme editor frame
    if VisualConfig.themeEditor.background then
        VisualConfig.themeEditor.background:SetColorTexture(
            backgroundColor.r,
            backgroundColor.g,
            backgroundColor.b,
            0.9
        )
    end
    
    if VisualConfig.themeEditor.border then
        VisualConfig.themeEditor.border:SetVertexColor(
            borderColor.r,
            borderColor.g,
            borderColor.b,
            1.0
        )
    end
    
    if VisualConfig.themeEditor.title then
        VisualConfig.themeEditor.title:SetTextColor(1, 1, 1, 1)
    end
    
    -- Apply to theme previews
    if VisualConfig.themeEditor.previews then
        for _, preview in pairs(VisualConfig.themeEditor.previews) do
            if preview.border then
                preview.border:SetVertexColor(
                    borderColor.r,
                    borderColor.g,
                    borderColor.b,
                    1.0
                )
            end
            
            -- Don't change the preview content - it shows the theme being previewed
        end
    end
    
    -- Apply to theme editor color pickers
    if VisualConfig.themeEditor.colorPickers then
        for _, colorPicker in pairs(VisualConfig.themeEditor.colorPickers) do
            if colorPicker.border then
                colorPicker.border:SetVertexColor(
                    borderColor.r,
                    borderColor.g,
                    borderColor.b,
                    1.0
                )
            end
            
            if colorPicker.label then
                colorPicker.label:SetTextColor(1, 1, 1, 1)
            end
        end
    end
    
    -- Apply to theme editor buttons
    if VisualConfig.themeEditor.buttons then
        for _, button in pairs(VisualConfig.themeEditor.buttons) do
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