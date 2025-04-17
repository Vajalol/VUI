-- VUI Example Module - Configuration Panel
-- This file demonstrates how to create a full configuration panel for a module
local _, VUI = ...
local Example = VUI.example
local AceGUI = LibStub("AceGUI-3.0")

-- Function to create a standalone configuration panel
function Example:CreateConfigPanel()
    -- Create a frame
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("VUI Example Module Configuration")
    frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    frame:SetLayout("Flow")
    frame:SetWidth(550)
    frame:SetHeight(500)
    
    -- Create tabs
    local tabs = AceGUI:Create("TabGroup")
    tabs:SetLayout("Flow")
    tabs:SetTabs({
        {text = "General", value = "general"},
        {text = "Appearance", value = "appearance"},
        {text = "Advanced", value = "advanced"}
    })
    tabs:SetCallback("OnGroupSelected", function(container, event, group)
        container:ReleaseChildren()
        if group == "general" then
            self:CreateGeneralTab(container)
        elseif group == "appearance" then
            self:CreateAppearanceTab(container)
        elseif group == "advanced" then
            self:CreateAdvancedTab(container)
        end
    end)
    tabs:SelectTab("general")
    
    frame:AddChild(tabs)
    
    return frame
end

-- Create the General tab
function Example:CreateGeneralTab(container)
    -- Enable/disable toggle
    local enableCheckbox = AceGUI:Create("CheckBox")
    enableCheckbox:SetLabel("Enable Example Module")
    enableCheckbox:SetWidth(200)
    enableCheckbox:SetValue(VUI:IsModuleEnabled("example"))
    enableCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        if value then
            VUI:EnableModule("example")
        else
            VUI:DisableModule("example")
        end
    end)
    container:AddChild(enableCheckbox)
    
    -- Spacer
    container:AddChild(AceGUI:Create("Label"):SetText(" "):SetFullWidth(true))
    
    -- Scale slider
    local scaleSlider = AceGUI:Create("Slider")
    scaleSlider:SetLabel("UI Scale")
    scaleSlider:SetWidth(400)
    scaleSlider:SetSliderValues(0.5, 2.0, 0.1)
    scaleSlider:SetValue(self.settings.scale)
    scaleSlider:SetCallback("OnValueChanged", function(widget, event, value)
        self.settings.scale = value
        if self.frame then
            self.frame:SetScale(value)
        end
    end)
    container:AddChild(scaleSlider)
    
    -- Show title checkbox
    local titleCheckbox = AceGUI:Create("CheckBox")
    titleCheckbox:SetLabel("Show Title Bar")
    titleCheckbox:SetWidth(200)
    titleCheckbox:SetValue(self.settings.showTitle)
    titleCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        self.settings.showTitle = value
        self:UpdateUI()
    end)
    container:AddChild(titleCheckbox)
    
    -- Spacer
    container:AddChild(AceGUI:Create("Label"):SetText(" "):SetFullWidth(true))
    
    -- Position group
    local positionGroup = AceGUI:Create("InlineGroup")
    positionGroup:SetTitle("Position")
    positionGroup:SetLayout("Flow")
    positionGroup:SetFullWidth(true)
    container:AddChild(positionGroup)
    
    -- Position button
    local positionButton = AceGUI:Create("Button")
    positionButton:SetText("Reset Position")
    positionButton:SetWidth(150)
    positionButton:SetCallback("OnClick", function()
        self:ResetPosition()
    end)
    positionGroup:AddChild(positionButton)
    
    -- Visibility buttons
    local visibilityGroup = AceGUI:Create("InlineGroup")
    visibilityGroup:SetTitle("Visibility")
    visibilityGroup:SetLayout("Flow")
    visibilityGroup:SetFullWidth(true)
    container:AddChild(visibilityGroup)
    
    -- Show button
    local showButton = AceGUI:Create("Button")
    showButton:SetText("Show")
    showButton:SetWidth(100)
    showButton:SetCallback("OnClick", function()
        self:Show()
    end)
    visibilityGroup:AddChild(showButton)
    
    -- Hide button
    local hideButton = AceGUI:Create("Button")
    hideButton:SetText("Hide")
    hideButton:SetWidth(100)
    hideButton:SetCallback("OnClick", function()
        self:Hide()
    end)
    visibilityGroup:AddChild(hideButton)
    
    -- Toggle button
    local toggleButton = AceGUI:Create("Button")
    toggleButton:SetText("Toggle")
    toggleButton:SetWidth(100)
    toggleButton:SetCallback("OnClick", function()
        self:Toggle()
    end)
    visibilityGroup:AddChild(toggleButton)
end

-- Create the Appearance tab
function Example:CreateAppearanceTab(container)
    -- Color pickers for appearance settings
    
    -- Background color
    local bgColorPicker = AceGUI:Create("ColorPicker")
    bgColorPicker:SetLabel("Background Color")
    bgColorPicker:SetHasAlpha(true)
    bgColorPicker:SetColor(
        self.settings.backgroundColor.r,
        self.settings.backgroundColor.g,
        self.settings.backgroundColor.b,
        self.settings.backgroundColor.a
    )
    bgColorPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
        self.settings.backgroundColor.r = r
        self.settings.backgroundColor.g = g
        self.settings.backgroundColor.b = b
        self.settings.backgroundColor.a = a
        
        if self.frame then
            self.frame:SetBackdropColor(r, g, b, a)
        end
    end)
    container:AddChild(bgColorPicker)
    
    -- Text color
    local textColorPicker = AceGUI:Create("ColorPicker")
    textColorPicker:SetLabel("Text Color")
    textColorPicker:SetHasAlpha(true)
    textColorPicker:SetColor(
        self.settings.textColor.r,
        self.settings.textColor.g,
        self.settings.textColor.b,
        self.settings.textColor.a
    )
    textColorPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
        self.settings.textColor.r = r
        self.settings.textColor.g = g
        self.settings.textColor.b = b
        self.settings.textColor.a = a
        
        if self.label then
            self.label:SetTextColor(r, g, b, a)
        end
    end)
    container:AddChild(textColorPicker)
    
    -- Spacer
    container:AddChild(AceGUI:Create("Label"):SetText(" "):SetFullWidth(true))
    
    -- Theme options
    local themeGroup = AceGUI:Create("InlineGroup")
    themeGroup:SetTitle("Theme")
    themeGroup:SetLayout("Flow")
    themeGroup:SetFullWidth(true)
    container:AddChild(themeGroup)
    
    -- Theme dropdown
    local themeDropdown = AceGUI:Create("Dropdown")
    themeDropdown:SetLabel("UI Theme")
    themeDropdown:SetWidth(200)
    themeDropdown:SetList({
        ["dark"] = "Dark",
        ["light"] = "Light",
        ["classic"] = "Classic",
        ["minimal"] = "Minimal"
    })
    themeDropdown:SetValue(VUI.db.profile.appearance.theme)
    themeDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.appearance.theme = value
        VUI:UpdateUI()
    end)
    themeGroup:AddChild(themeDropdown)
    
    -- Apply theme button
    local applyButton = AceGUI:Create("Button")
    applyButton:SetText("Apply Theme")
    applyButton:SetWidth(150)
    applyButton:SetCallback("OnClick", function()
        self:ApplyTheme()
    end)
    themeGroup:AddChild(applyButton)
end

-- Create the Advanced tab
function Example:CreateAdvancedTab(container)
    -- Description
    local desc = AceGUI:Create("Label")
    desc:SetText("This tab demonstrates how to create more advanced configuration options for your modules.")
    desc:SetFullWidth(true)
    container:AddChild(desc)
    
    -- Spacer
    container:AddChild(AceGUI:Create("Label"):SetText(" "):SetFullWidth(true))
    
    -- Module information
    local infoGroup = AceGUI:Create("InlineGroup")
    infoGroup:SetTitle("Module Information")
    infoGroup:SetLayout("Flow")
    infoGroup:SetFullWidth(true)
    container:AddChild(infoGroup)
    
    -- Version info
    local versionLabel = AceGUI:Create("Label")
    versionLabel:SetText("Version: " .. (VUI.version or "0.0.1"))
    versionLabel:SetFullWidth(true)
    infoGroup:AddChild(versionLabel)
    
    -- Integration status
    local integrationLabel = AceGUI:Create("Label")
    integrationLabel:SetText("Integration Status:")
    integrationLabel:SetFullWidth(true)
    infoGroup:AddChild(integrationLabel)
    
    local checks = {
        "UI Framework: " .. (self.UI and "|cFF00FF00Connected|r" or "|cFFFF0000Not Connected|r"),
        "Widgets: " .. (self.Widgets and "|cFF00FF00Connected|r" or "|cFFFF0000Not Connected|r"),
        "Media: " .. (self.media and "|cFF00FF00Connected|r" or "|cFFFF0000Not Connected|r")
    }
    
    for _, check in ipairs(checks) do
        local checkLabel = AceGUI:Create("Label")
        checkLabel:SetText("   • " .. check)
        checkLabel:SetFullWidth(true)
        infoGroup:AddChild(checkLabel)
    end
    
    -- Spacer
    container:AddChild(AceGUI:Create("Label"):SetText(" "):SetFullWidth(true))
    
    -- Debug actions
    local debugGroup = AceGUI:Create("InlineGroup")
    debugGroup:SetTitle("Debug Actions")
    debugGroup:SetLayout("Flow")
    debugGroup:SetFullWidth(true)
    container:AddChild(debugGroup)
    
    -- Test framework integration
    local testButton = AceGUI:Create("Button")
    testButton:SetText("Run Integration Test")
    testButton:SetWidth(200)
    testButton:SetCallback("OnClick", function()
        -- Run test via the integration test utility
        VUI:Print("Running integration test...")
        SlashCmdList["VUITEST"]()
    end)
    debugGroup:AddChild(testButton)
end

-- Register our config panel with the module API
VUI.ModuleAPI:AddModuleConfigPanel("example", function() 
    return Example:CreateConfigPanel() 
end)