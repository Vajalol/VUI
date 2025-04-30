-------------------------------------------------------------------------------
-- Title: AngryKeystones Configuration UI
-- Author: VortexQ8
-- Configuration UI for AngryKeystones module
-------------------------------------------------------------------------------

local _, VUI = ...
local AK = VUI.modules.angrykeystones

-- Skip if AngryKeystones module is not available
if not AK then return end

-- Create the config namespace
AK.Config = {}
local Config = AK.Config

-- Create configuration UI
function Config:CreateConfigUI(container)
    local AceGUI = LibStub("AceGUI-3.0")
    
    -- General group
    local generalGroup = AceGUI:Create("InlineGroup")
    generalGroup:SetTitle("General Options")
    generalGroup:SetLayout("Flow")
    generalGroup:SetFullWidth(true)
    container:AddChild(generalGroup)
    
    -- Enable checkbox
    local enableCheckbox = AceGUI:Create("CheckBox")
    enableCheckbox:SetLabel("Enable AngryKeystones Integration")
    enableCheckbox:SetWidth(300)
    enableCheckbox:SetValue(AK.db.profile.enabled)
    enableCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        AK.db.profile.enabled = value
        if value then
            VUI:EnableModule("angrykeystones")
        else
            VUI:DisableModule("angrykeystones")
        end
    end)
    generalGroup:AddChild(enableCheckbox)
    
    -- VUI theme checkbox
    local themeCheckbox = AceGUI:Create("CheckBox")
    themeCheckbox:SetLabel("Use VUI Theme")
    themeCheckbox:SetWidth(300)
    themeCheckbox:SetValue(AK.db.profile.useVUITheme)
    themeCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        AK.db.profile.useVUITheme = value
        
        -- Apply theme changes immediately
        if AK.ThemeIntegration then
            AK.ThemeIntegration:ApplyTheme()
        end
    end)
    generalGroup:AddChild(themeCheckbox)
    
    -- Enhanced timers checkbox
    local enhancedTimersCheckbox = AceGUI:Create("CheckBox")
    enhancedTimersCheckbox:SetLabel("Enable Enhanced Timers")
    enhancedTimersCheckbox:SetWidth(300)
    enhancedTimersCheckbox:SetValue(AK.db.profile.enhancedTimers)
    enhancedTimersCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        AK.db.profile.enhancedTimers = value
    end)
    generalGroup:AddChild(enhancedTimersCheckbox)
    
    -- Chest timer notifications checkbox
    local chestTimerCheckbox = AceGUI:Create("CheckBox")
    chestTimerCheckbox:SetLabel("Enable Chest Timer Notifications")
    chestTimerCheckbox:SetWidth(300)
    chestTimerCheckbox:SetValue(AK.db.profile.chestTimerNotifications)
    chestTimerCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        AK.db.profile.chestTimerNotifications = value
    end)
    generalGroup:AddChild(chestTimerCheckbox)
    
    -- Progress precision slider
    local progressPrecisionSlider = AceGUI:Create("Slider")
    progressPrecisionSlider:SetLabel("Progress Percentage Precision")
    progressPrecisionSlider:SetWidth(300)
    progressPrecisionSlider:SetSliderValues(0, 4, 1)
    progressPrecisionSlider:SetValue(AK.db.profile.progressPrecision)
    progressPrecisionSlider:SetCallback("OnValueChanged", function(widget, event, value)
        AK.db.profile.progressPrecision = value
        
        -- Update progress display if ProgressTracker is active
        if AK.ProgressTracker then
            AK.ProgressTracker:Reset()
        end
    end)
    generalGroup:AddChild(progressPrecisionSlider)
    
    -- Enhanced timers checkbox
    local enhancedTimersCheckbox = AceGUI:Create("CheckBox")
    enhancedTimersCheckbox:SetLabel("Enable Enhanced Timer Display")
    enhancedTimersCheckbox:SetWidth(300)
    enhancedTimersCheckbox:SetValue(AK.db.profile.enhancedTimers)
    enhancedTimersCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        AK.db.profile.enhancedTimers = value
        
        if value and AK.EnhancedTimers then
            AK.EnhancedTimers:Enable()
        elseif not value and AK.EnhancedTimers then
            AK.EnhancedTimers:Disable()
        end
    end)
    generalGroup:AddChild(enhancedTimersCheckbox)
    
    -- Chest timer notifications checkbox
    local chestTimerCheckbox = AceGUI:Create("CheckBox")
    chestTimerCheckbox:SetLabel("Enable Chest Timer Notifications")
    chestTimerCheckbox:SetWidth(300)
    chestTimerCheckbox:SetValue(AK.db.profile.chestTimerNotifications)
    chestTimerCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        AK.db.profile.chestTimerNotifications = value
        
        if value and AK.ChestTimerNotifications then
            AK.ChestTimerNotifications:Enable()
        elseif not value and AK.ChestTimerNotifications then
            AK.ChestTimerNotifications:Disable()
        end
    end)
    generalGroup:AddChild(chestTimerCheckbox)
    
    -- Timer Styles group
    local timerStylesGroup = AceGUI:Create("InlineGroup")
    timerStylesGroup:SetTitle("Timer Styles")
    timerStylesGroup:SetLayout("Flow")
    timerStylesGroup:SetFullWidth(true)
    container:AddChild(timerStylesGroup)
    
    -- Show milliseconds checkbox
    local millisecondsCheckbox = AceGUI:Create("CheckBox")
    millisecondsCheckbox:SetLabel("Show Milliseconds")
    millisecondsCheckbox:SetWidth(300)
    millisecondsCheckbox:SetValue(AK.db.profile.timerStyles.showMilliseconds)
    millisecondsCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        AK.db.profile.timerStyles.showMilliseconds = value
    end)
    timerStylesGroup:AddChild(millisecondsCheckbox)
    
    -- Color gradient checkbox
    local colorGradientCheckbox = AceGUI:Create("CheckBox")
    colorGradientCheckbox:SetLabel("Use Color Gradient for Timers")
    colorGradientCheckbox:SetWidth(300)
    colorGradientCheckbox:SetValue(AK.db.profile.timerStyles.colorGradient)
    colorGradientCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        AK.db.profile.timerStyles.colorGradient = value
        
        -- Apply changes immediately
        if AK.ThemeIntegration then
            AK.ThemeIntegration:ApplyTheme()
        end
    end)
    timerStylesGroup:AddChild(colorGradientCheckbox)
    
    -- Font size slider
    local fontSizeSlider = AceGUI:Create("Slider")
    fontSizeSlider:SetLabel("Timer Font Size")
    fontSizeSlider:SetWidth(300)
    fontSizeSlider:SetSliderValues(10, 24, 1)
    fontSizeSlider:SetValue(AK.db.profile.timerStyles.fontSize)
    fontSizeSlider:SetCallback("OnValueChanged", function(widget, event, value)
        AK.db.profile.timerStyles.fontSize = value
        
        -- Apply changes immediately
        if AK.ThemeIntegration then
            AK.ThemeIntegration:ApplyTheme()
        end
    end)
    timerStylesGroup:AddChild(fontSizeSlider)
    
    -- Objective Styles group
    local objectiveStylesGroup = AceGUI:Create("InlineGroup")
    objectiveStylesGroup:SetTitle("Objective Styles")
    objectiveStylesGroup:SetLayout("Flow")
    objectiveStylesGroup:SetFullWidth(true)
    container:AddChild(objectiveStylesGroup)
    
    -- Progress bar width slider
    local progressBarWidthSlider = AceGUI:Create("Slider")
    progressBarWidthSlider:SetLabel("Progress Bar Width")
    progressBarWidthSlider:SetWidth(300)
    progressBarWidthSlider:SetSliderValues(100, 300, 10)
    progressBarWidthSlider:SetValue(AK.db.profile.objectiveStyles.progressBarWidth)
    progressBarWidthSlider:SetCallback("OnValueChanged", function(widget, event, value)
        AK.db.profile.objectiveStyles.progressBarWidth = value
        
        -- Apply changes immediately
        if AK.ThemeIntegration then
            AK.ThemeIntegration:ApplyTheme()
        end
    end)
    objectiveStylesGroup:AddChild(progressBarWidthSlider)
    
    -- Show percent symbol checkbox
    local percentSymbolCheckbox = AceGUI:Create("CheckBox")
    percentSymbolCheckbox:SetLabel("Show Percent Symbol")
    percentSymbolCheckbox:SetWidth(300)
    percentSymbolCheckbox:SetValue(AK.db.profile.objectiveStyles.showPercentSymbol)
    percentSymbolCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        AK.db.profile.objectiveStyles.showPercentSymbol = value
        
        -- Apply changes immediately
        if AK.ThemeIntegration then
            AK.ThemeIntegration:ApplyTheme()
        end
    end)
    objectiveStylesGroup:AddChild(percentSymbolCheckbox)
    
    -- Color by type checkbox
    local colorByTypeCheckbox = AceGUI:Create("CheckBox")
    colorByTypeCheckbox:SetLabel("Color Progress Bars by Objective Type")
    colorByTypeCheckbox:SetWidth(300)
    colorByTypeCheckbox:SetValue(AK.db.profile.objectiveStyles.colorByType)
    colorByTypeCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        AK.db.profile.objectiveStyles.colorByType = value
        
        -- Apply changes immediately
        if AK.ThemeIntegration then
            AK.ThemeIntegration:ApplyTheme()
        end
    end)
    objectiveStylesGroup:AddChild(colorByTypeCheckbox)
end

-- Get options for the config panel
function Config:GetOptions()
    return {
        type = "group",
        name = "AngryKeystones",
        args = {
            enable = {
                type = "toggle",
                name = "Enable",
                desc = "Enable or disable the AngryKeystones module",
                order = 1,
                get = function() return VUI:IsModuleEnabled("angrykeystones") end,
                set = function(_, value)
                    if value then
                        VUI:EnableModule("angrykeystones")
                    else
                        VUI:DisableModule("angrykeystones")
                    end
                end,
            },
            config = {
                type = "execute",
                name = "Open Configuration",
                desc = "Open the configuration UI",
                order = 2,
                func = function()
                    VUI:OpenConfig("angrykeystones")
                end,
            },
        },
    }
end