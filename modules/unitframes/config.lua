-- VUI UnitFrames Module - Configuration Panel
local _, VUI = ...
local UnitFrames = VUI.unitframes
local AceGUI = LibStub("AceGUI-3.0")

-- Function to create a standalone configuration panel
function UnitFrames:CreateConfigPanel()
    -- Create a frame
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("VUI UnitFrames Configuration")
    frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    frame:SetLayout("Flow")
    frame:SetWidth(600)
    frame:SetHeight(550)
    
    -- Create tabs
    local tabs = AceGUI:Create("TabGroup")
    tabs:SetLayout("Flow")
    tabs:SetTabs({
        {text = "General", value = "general"},
        {text = "Player", value = "player"},
        {text = "Target", value = "target"},
        {text = "Focus", value = "focus"},
        {text = "Party", value = "party"},
        {text = "Appearance", value = "appearance"}
    })
    tabs:SetCallback("OnGroupSelected", function(container, event, group)
        container:ReleaseChildren()
        if group == "general" then
            self:CreateGeneralTab(container)
        elseif group == "player" then
            self:CreatePlayerTab(container)
        elseif group == "target" then
            self:CreateTargetTab(container)
        elseif group == "focus" then
            self:CreateFocusTab(container)
        elseif group == "party" then
            self:CreatePartyTab(container)
        elseif group == "appearance" then
            self:CreateAppearanceTab(container)
        end
    end)
    tabs:SelectTab("general")
    
    frame:AddChild(tabs)
    
    return frame
end

-- Create the General tab
function UnitFrames:CreateGeneralTab(container)
    -- Enable/disable toggle
    local enableCheckbox = AceGUI:Create("CheckBox")
    enableCheckbox:SetLabel("Enable UnitFrames")
    enableCheckbox:SetWidth(350)
    enableCheckbox:SetValue(VUI:IsModuleEnabled("unitframes"))
    enableCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        if value then
            VUI:EnableModule("unitframes")
        else
            VUI:DisableModule("unitframes")
        end
    end)
    container:AddChild(enableCheckbox)
    
    -- Description text
    local desc = AceGUI:Create("Label")
    desc:SetText("The UnitFrames module replaces the default World of Warcraft unit frames with custom, highly customizable frames.")
    desc:SetFullWidth(true)
    container:AddChild(desc)
    
    -- Spacer
    container:AddChild(AceGUI:Create("Label"):SetText(" "):SetFullWidth(true))
    
    -- Style dropdown
    local styleDropdown = AceGUI:Create("Dropdown")
    styleDropdown:SetLabel("Frame Style")
    styleDropdown:SetWidth(200)
    styleDropdown:SetList({
        ["modern"] = "Modern",
        ["classic"] = "Classic",
        ["minimal"] = "Minimal"
    })
    styleDropdown:SetValue(self.settings.style)
    styleDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        self.settings.style = value
        self:UpdateFrames()
    end)
    container:AddChild(styleDropdown)
    
    -- Global scale slider
    local scaleSlider = AceGUI:Create("Slider")
    scaleSlider:SetLabel("Global Scale")
    scaleSlider:SetWidth(350)
    scaleSlider:SetSliderValues(0.5, 2.0, 0.05)
    scaleSlider:SetValue(self.settings.scale)
    scaleSlider:SetCallback("OnValueChanged", function(widget, event, value)
        self.settings.scale = value
        self:UpdateFrameScale()
    end)
    container:AddChild(scaleSlider)
    
    -- Class colored health bars toggle
    local classColorCheckbox = AceGUI:Create("CheckBox")
    classColorCheckbox:SetLabel("Use Class Colored Health Bars")
    classColorCheckbox:SetWidth(350)
    classColorCheckbox:SetValue(self.settings.classColoredBars)
    classColorCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        self.settings.classColoredBars = value
        self:UpdateAllFrames()
    end)
    container:AddChild(classColorCheckbox)
    
    -- Class colored borders toggle
    local classColorBorderCheckbox = AceGUI:Create("CheckBox")
    classColorBorderCheckbox:SetLabel("Use Class Colored Borders")
    classColorBorderCheckbox:SetWidth(350)
    classColorBorderCheckbox:SetValue(self.settings.classColoredBorders)
    classColorBorderCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        self.settings.classColoredBorders = value
        self:ApplyTheme()
    end)
    container:AddChild(classColorBorderCheckbox)
    
    -- Show portraits toggle
    local portraitsCheckbox = AceGUI:Create("CheckBox")
    portraitsCheckbox:SetLabel("Show Portraits")
    portraitsCheckbox:SetWidth(350)
    portraitsCheckbox:SetValue(self.settings.showPortraits)
    portraitsCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        self.settings.showPortraits = value
        self:UpdateFrames()
    end)
    container:AddChild(portraitsCheckbox)
    
    -- Use class icons toggle
    local classIconsCheckbox = AceGUI:Create("CheckBox")
    classIconsCheckbox:SetLabel("Use Class Icons as Portraits")
    classIconsCheckbox:SetWidth(350)
    classIconsCheckbox:SetValue(self.settings.useClassPortraits)
    classIconsCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        self.settings.useClassPortraits = value
        self:UpdateAllFrames()
    end)
    classIconsCheckbox:SetDisabled(not self.settings.showPortraits)
    container:AddChild(classIconsCheckbox)
    
    -- Spacer
    container:AddChild(AceGUI:Create("Label"):SetText(" "):SetFullWidth(true))
    
    -- Controls
    local controlGroup = AceGUI:Create("InlineGroup")
    controlGroup:SetTitle("Frame Controls")
    controlGroup:SetLayout("Flow")
    controlGroup:SetFullWidth(true)
    container:AddChild(controlGroup)
    
    -- Reset positions button
    local resetButton = AceGUI:Create("Button")
    resetButton:SetText("Reset Positions")
    resetButton:SetWidth(150)
    resetButton:SetCallback("OnClick", function()
        self:ResetPositions()
    end)
    controlGroup:AddChild(resetButton)
    
    -- Unlock frames button
    local unlockButton = AceGUI:Create("Button")
    unlockButton:SetText("Unlock Frames")
    unlockButton:SetWidth(150)
    unlockButton:SetCallback("OnClick", function()
        self:UnlockFrames()
    end)
    controlGroup:AddChild(unlockButton)
    
    -- Lock frames button
    local lockButton = AceGUI:Create("Button")
    lockButton:SetText("Lock Frames")
    lockButton:SetWidth(150)
    lockButton:SetCallback("OnClick", function()
        self:LockFrames()
    end)
    controlGroup:AddChild(lockButton)
end

-- Create the Player tab
function UnitFrames:CreatePlayerTab(container)
    local settings = self.settings.frames.player
    
    -- Enable toggle
    local enableCheckbox = AceGUI:Create("CheckBox")
    enableCheckbox:SetLabel("Enable Player Frame")
    enableCheckbox:SetWidth(350)
    enableCheckbox:SetValue(settings.enabled)
    enableCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        settings.enabled = value
        self:UpdateFrameVisibility("player")
    end)
    container:AddChild(enableCheckbox)
    
    -- Spacer
    container:AddChild(AceGUI:Create("Label"):SetText(" "):SetFullWidth(true))
    
    -- Size group
    local sizeGroup = AceGUI:Create("InlineGroup")
    sizeGroup:SetTitle("Size")
    sizeGroup:SetLayout("Flow")
    sizeGroup:SetFullWidth(true)
    container:AddChild(sizeGroup)
    
    -- Width slider
    local widthSlider = AceGUI:Create("Slider")
    widthSlider:SetLabel("Width")
    widthSlider:SetWidth(350)
    widthSlider:SetSliderValues(100, 400, 10)
    widthSlider:SetValue(settings.width)
    widthSlider:SetCallback("OnValueChanged", function(widget, event, value)
        settings.width = value
        self:UpdateFrameSize("player")
    end)
    sizeGroup:AddChild(widthSlider)
    
    -- Height slider
    local heightSlider = AceGUI:Create("Slider")
    heightSlider:SetLabel("Height")
    heightSlider:SetWidth(350)
    heightSlider:SetSliderValues(30, 100, 5)
    heightSlider:SetValue(settings.height)
    heightSlider:SetCallback("OnValueChanged", function(widget, event, value)
        settings.height = value
        self:UpdateFrameSize("player")
    end)
    sizeGroup:AddChild(heightSlider)
    
    -- Scale slider
    local scaleSlider = AceGUI:Create("Slider")
    scaleSlider:SetLabel("Scale")
    scaleSlider:SetWidth(350)
    scaleSlider:SetSliderValues(0.5, 2.0, 0.05)
    scaleSlider:SetValue(settings.scale)
    scaleSlider:SetCallback("OnValueChanged", function(widget, event, value)
        settings.scale = value
        self:UpdateFrameScale("player")
    end)
    sizeGroup:AddChild(scaleSlider)
    
    -- Display options
    local displayGroup = AceGUI:Create("InlineGroup")
    displayGroup:SetTitle("Display Options")
    displayGroup:SetLayout("Flow")
    displayGroup:SetFullWidth(true)
    container:AddChild(displayGroup)
    
    -- Show health percent checkbox
    local healthPercCheckbox = AceGUI:Create("CheckBox")
    healthPercCheckbox:SetLabel("Show Health Percentage")
    healthPercCheckbox:SetWidth(200)
    healthPercCheckbox:SetValue(settings.showHealthPercent)
    healthPercCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        settings.showHealthPercent = value
        self:UpdatePlayerFrame()
    end)
    displayGroup:AddChild(healthPercCheckbox)
    
    -- Show power percent checkbox
    local powerPercCheckbox = AceGUI:Create("CheckBox")
    powerPercCheckbox:SetLabel("Show Power Percentage")
    powerPercCheckbox:SetWidth(200)
    powerPercCheckbox:SetValue(settings.showPowerPercent)
    powerPercCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        settings.showPowerPercent = value
        self:UpdatePlayerFrame()
    end)
    displayGroup:AddChild(powerPercCheckbox)
    
    -- Show power value checkbox
    local powerValueCheckbox = AceGUI:Create("CheckBox")
    powerValueCheckbox:SetLabel("Show Power Value")
    powerValueCheckbox:SetWidth(200)
    powerValueCheckbox:SetValue(settings.showPowerValue)
    powerValueCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        settings.showPowerValue = value
        self:UpdatePlayerFrame()
    end)
    displayGroup:AddChild(powerValueCheckbox)
    
    -- Show combat indicator checkbox
    local combatCheckbox = AceGUI:Create("CheckBox")
    combatCheckbox:SetLabel("Show Combat Indicator")
    combatCheckbox:SetWidth(200)
    combatCheckbox:SetValue(settings.showCombatIndicator)
    combatCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        settings.showCombatIndicator = value
        self:UpdatePlayerFrame()
    end)
    displayGroup:AddChild(combatCheckbox)
    
    -- Show resting indicator checkbox
    local restingCheckbox = AceGUI:Create("CheckBox")
    restingCheckbox:SetLabel("Show Resting Indicator")
    restingCheckbox:SetWidth(200)
    restingCheckbox:SetValue(settings.showRestingIndicator)
    restingCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        settings.showRestingIndicator = value
        self:UpdatePlayerFrame()
    end)
    displayGroup:AddChild(restingCheckbox)
end

-- Create the Target tab (similar to Player)
function UnitFrames:CreateTargetTab(container)
    local settings = self.settings.frames.target
    
    -- Enable toggle
    local enableCheckbox = AceGUI:Create("CheckBox")
    enableCheckbox:SetLabel("Enable Target Frame")
    enableCheckbox:SetWidth(350)
    enableCheckbox:SetValue(settings.enabled)
    enableCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        settings.enabled = value
        self:UpdateFrameVisibility("target")
    end)
    container:AddChild(enableCheckbox)
    
    -- Spacer
    container:AddChild(AceGUI:Create("Label"):SetText(" "):SetFullWidth(true))
    
    -- Size group
    local sizeGroup = AceGUI:Create("InlineGroup")
    sizeGroup:SetTitle("Size")
    sizeGroup:SetLayout("Flow")
    sizeGroup:SetFullWidth(true)
    container:AddChild(sizeGroup)
    
    -- Width slider
    local widthSlider = AceGUI:Create("Slider")
    widthSlider:SetLabel("Width")
    widthSlider:SetWidth(350)
    widthSlider:SetSliderValues(100, 400, 10)
    widthSlider:SetValue(settings.width)
    widthSlider:SetCallback("OnValueChanged", function(widget, event, value)
        settings.width = value
        self:UpdateFrameSize("target")
    end)
    sizeGroup:AddChild(widthSlider)
    
    -- Height slider
    local heightSlider = AceGUI:Create("Slider")
    heightSlider:SetLabel("Height")
    heightSlider:SetWidth(350)
    heightSlider:SetSliderValues(30, 100, 5)
    heightSlider:SetValue(settings.height)
    heightSlider:SetCallback("OnValueChanged", function(widget, event, value)
        settings.height = value
        self:UpdateFrameSize("target")
    end)
    sizeGroup:AddChild(heightSlider)
    
    -- Scale slider
    local scaleSlider = AceGUI:Create("Slider")
    scaleSlider:SetLabel("Scale")
    scaleSlider:SetWidth(350)
    scaleSlider:SetSliderValues(0.5, 2.0, 0.05)
    scaleSlider:SetValue(settings.scale)
    scaleSlider:SetCallback("OnValueChanged", function(widget, event, value)
        settings.scale = value
        self:UpdateFrameScale("target")
    end)
    sizeGroup:AddChild(scaleSlider)
    
    -- Display options
    local displayGroup = AceGUI:Create("InlineGroup")
    displayGroup:SetTitle("Display Options")
    displayGroup:SetLayout("Flow")
    displayGroup:SetFullWidth(true)
    container:AddChild(displayGroup)
    
    -- Show health percent checkbox
    local healthPercCheckbox = AceGUI:Create("CheckBox")
    healthPercCheckbox:SetLabel("Show Health Percentage")
    healthPercCheckbox:SetWidth(200)
    healthPercCheckbox:SetValue(settings.showHealthPercent)
    healthPercCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        settings.showHealthPercent = value
        self:UpdateTargetFrame()
    end)
    displayGroup:AddChild(healthPercCheckbox)
    
    -- Show power percent checkbox
    local powerPercCheckbox = AceGUI:Create("CheckBox")
    powerPercCheckbox:SetLabel("Show Power Percentage")
    powerPercCheckbox:SetWidth(200)
    powerPercCheckbox:SetValue(settings.showPowerPercent)
    powerPercCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        settings.showPowerPercent = value
        self:UpdateTargetFrame()
    end)
    displayGroup:AddChild(powerPercCheckbox)
    
    -- Show detailed info checkbox
    local detailedInfoCheckbox = AceGUI:Create("CheckBox")
    detailedInfoCheckbox:SetLabel("Show Detailed Info")
    detailedInfoCheckbox:SetWidth(200)
    detailedInfoCheckbox:SetValue(settings.showDetailedInfo)
    detailedInfoCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        settings.showDetailedInfo = value
        self:UpdateTargetFrame()
    end)
    displayGroup:AddChild(detailedInfoCheckbox)
    
    -- Show classification indicator checkbox
    local classificationCheckbox = AceGUI:Create("CheckBox")
    classificationCheckbox:SetLabel("Show Classification Indicator")
    classificationCheckbox:SetWidth(250)
    classificationCheckbox:SetValue(settings.classificationIndicator)
    classificationCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        settings.classificationIndicator = value
        self:UpdateTargetFrame()
    end)
    displayGroup:AddChild(classificationCheckbox)
end

-- Create the Focus tab (simplified for brevity)
function UnitFrames:CreateFocusTab(container)
    local settings = self.settings.frames.focus
    
    -- Enable toggle
    local enableCheckbox = AceGUI:Create("CheckBox")
    enableCheckbox:SetLabel("Enable Focus Frame")
    enableCheckbox:SetWidth(350)
    enableCheckbox:SetValue(settings.enabled)
    enableCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        settings.enabled = value
        self:UpdateFrameVisibility("focus")
    end)
    container:AddChild(enableCheckbox)
    
    -- Spacer
    container:AddChild(AceGUI:Create("Label"):SetText(" "):SetFullWidth(true))
    
    -- Size group
    local sizeGroup = AceGUI:Create("InlineGroup")
    sizeGroup:SetTitle("Size")
    sizeGroup:SetLayout("Flow")
    sizeGroup:SetFullWidth(true)
    container:AddChild(sizeGroup)
    
    -- Width slider
    local widthSlider = AceGUI:Create("Slider")
    widthSlider:SetLabel("Width")
    widthSlider:SetWidth(350)
    widthSlider:SetSliderValues(100, 300, 10)
    widthSlider:SetValue(settings.width)
    widthSlider:SetCallback("OnValueChanged", function(widget, event, value)
        settings.width = value
        self:UpdateFrameSize("focus")
    end)
    sizeGroup:AddChild(widthSlider)
    
    -- Height slider
    local heightSlider = AceGUI:Create("Slider")
    heightSlider:SetLabel("Height")
    heightSlider:SetWidth(350)
    heightSlider:SetSliderValues(20, 80, 2)
    heightSlider:SetValue(settings.height)
    heightSlider:SetCallback("OnValueChanged", function(widget, event, value)
        settings.height = value
        self:UpdateFrameSize("focus")
    end)
    sizeGroup:AddChild(heightSlider)
    
    -- Scale slider
    local scaleSlider = AceGUI:Create("Slider")
    scaleSlider:SetLabel("Scale")
    scaleSlider:SetWidth(350)
    scaleSlider:SetSliderValues(0.5, 2.0, 0.05)
    scaleSlider:SetValue(settings.scale)
    scaleSlider:SetCallback("OnValueChanged", function(widget, event, value)
        settings.scale = value
        self:UpdateFrameScale("focus")
    end)
    sizeGroup:AddChild(scaleSlider)
end

-- Create the Party tab
function UnitFrames:CreatePartyTab(container)
    local settings = self.settings.frames.party
    
    -- Enable toggle
    local enableCheckbox = AceGUI:Create("CheckBox")
    enableCheckbox:SetLabel("Enable Party Frames")
    enableCheckbox:SetWidth(350)
    enableCheckbox:SetValue(settings.enabled)
    enableCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        settings.enabled = value
        self:UpdateFrameVisibility("party")
    end)
    container:AddChild(enableCheckbox)
    
    -- Spacer
    container:AddChild(AceGUI:Create("Label"):SetText(" "):SetFullWidth(true))
    
    -- Layout group
    local layoutGroup = AceGUI:Create("InlineGroup")
    layoutGroup:SetTitle("Layout")
    layoutGroup:SetLayout("Flow")
    layoutGroup:SetFullWidth(true)
    container:AddChild(layoutGroup)
    
    -- Vertical layout toggle
    local verticalCheckbox = AceGUI:Create("CheckBox")
    verticalCheckbox:SetLabel("Vertical Layout")
    verticalCheckbox:SetWidth(200)
    verticalCheckbox:SetValue(settings.vertical)
    verticalCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        settings.vertical = value
        self:UpdateFrameSize("party")
    end)
    layoutGroup:AddChild(verticalCheckbox)
    
    -- Spacing slider
    local spacingSlider = AceGUI:Create("Slider")
    spacingSlider:SetLabel("Spacing")
    spacingSlider:SetWidth(350)
    spacingSlider:SetSliderValues(0, 20, 1)
    spacingSlider:SetValue(settings.spacing)
    spacingSlider:SetCallback("OnValueChanged", function(widget, event, value)
        settings.spacing = value
        self:UpdateFrameSize("party")
    end)
    layoutGroup:AddChild(spacingSlider)
    
    -- Size group
    local sizeGroup = AceGUI:Create("InlineGroup")
    sizeGroup:SetTitle("Size")
    sizeGroup:SetLayout("Flow")
    sizeGroup:SetFullWidth(true)
    container:AddChild(sizeGroup)
    
    -- Width slider
    local widthSlider = AceGUI:Create("Slider")
    widthSlider:SetLabel("Width")
    widthSlider:SetWidth(350)
    widthSlider:SetSliderValues(100, 300, 10)
    widthSlider:SetValue(settings.width)
    widthSlider:SetCallback("OnValueChanged", function(widget, event, value)
        settings.width = value
        self:UpdateFrameSize("party")
    end)
    sizeGroup:AddChild(widthSlider)
    
    -- Height slider
    local heightSlider = AceGUI:Create("Slider")
    heightSlider:SetLabel("Height")
    heightSlider:SetWidth(350)
    heightSlider:SetSliderValues(20, 80, 2)
    heightSlider:SetValue(settings.height)
    heightSlider:SetCallback("OnValueChanged", function(widget, event, value)
        settings.height = value
        self:UpdateFrameSize("party")
    end)
    sizeGroup:AddChild(heightSlider)
    
    -- Scale slider
    local scaleSlider = AceGUI:Create("Slider")
    scaleSlider:SetLabel("Scale")
    scaleSlider:SetWidth(350)
    scaleSlider:SetSliderValues(0.5, 2.0, 0.05)
    scaleSlider:SetValue(settings.scale)
    scaleSlider:SetCallback("OnValueChanged", function(widget, event, value)
        settings.scale = value
        self:UpdateFrameScale("party")
    end)
    sizeGroup:AddChild(scaleSlider)
    
    -- Display options
    local displayGroup = AceGUI:Create("InlineGroup")
    displayGroup:SetTitle("Display Options")
    displayGroup:SetLayout("Flow")
    displayGroup:SetFullWidth(true)
    container:AddChild(displayGroup)
    
    -- Show role icon checkbox
    local roleIconCheckbox = AceGUI:Create("CheckBox")
    roleIconCheckbox:SetLabel("Show Role Icons")
    roleIconCheckbox:SetWidth(200)
    roleIconCheckbox:SetValue(settings.showRoleIcon)
    roleIconCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        settings.showRoleIcon = value
        self:UpdatePartyFrames()
    end)
    displayGroup:AddChild(roleIconCheckbox)
    
    -- Show group number checkbox
    local groupNumberCheckbox = AceGUI:Create("CheckBox")
    groupNumberCheckbox:SetLabel("Show Group Numbers")
    groupNumberCheckbox:SetWidth(200)
    groupNumberCheckbox:SetValue(settings.showGroupNumber)
    groupNumberCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        settings.showGroupNumber = value
        self:UpdatePartyFrames()
    end)
    displayGroup:AddChild(groupNumberCheckbox)
end

-- Create the Appearance tab
function UnitFrames:CreateAppearanceTab(container)
    -- Animation options group
    local animGroup = AceGUI:Create("InlineGroup")
    animGroup:SetTitle("Animation Settings")
    animGroup:SetLayout("Flow")
    animGroup:SetFullWidth(true)
    container:AddChild(animGroup)
    
    -- Enable smooth updates toggle
    local smoothCheckbox = AceGUI:Create("CheckBox")
    smoothCheckbox:SetLabel("Enable Smooth Value Transitions")
    smoothCheckbox:SetWidth(350)
    smoothCheckbox:SetValue(self.settings.enableSmoothUpdates)
    smoothCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        self.settings.enableSmoothUpdates = value
        self:UpdateAllFrames()
    end)
    animGroup:AddChild(smoothCheckbox)
    
    -- Animation duration slider
    local durationSlider = AceGUI:Create("Slider")
    durationSlider:SetLabel("Animation Duration (seconds)")
    durationSlider:SetWidth(350)
    durationSlider:SetSliderValues(0.1, 1.0, 0.05)
    durationSlider:SetValue(self.settings.animationDuration or 0.3)
    durationSlider:SetCallback("OnValueChanged", function(widget, event, value)
        self.settings.animationDuration = value
        -- Update animation durations
        for frame in pairs(self.animatedFrames or {}) do
            if frame.fadeInAnimation then
                local alpha = frame.fadeInAnimation:GetAnimations()
                alpha:SetDuration(value)
            end
            if frame.fadeOutAnimation then
                local alpha = frame.fadeOutAnimation:GetAnimations()
                alpha:SetDuration(value)
            end
        end
    end)
    animGroup:AddChild(durationSlider)
    
    -- Combat animation toggle
    local combatAnimCheckbox = AceGUI:Create("CheckBox")
    combatAnimCheckbox:SetLabel("Show Combat State Animations")
    combatAnimCheckbox:SetWidth(350)
    combatAnimCheckbox:SetValue(self.settings.showCombatAnimations)
    combatAnimCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        self.settings.showCombatAnimations = value
        self:UpdateAllFrames()
    end)
    animGroup:AddChild(combatAnimCheckbox)
    
    -- Health change animation toggle
    local healthAnimCheckbox = AceGUI:Create("CheckBox")
    healthAnimCheckbox:SetLabel("Show Health Change Animations")
    healthAnimCheckbox:SetWidth(350)
    healthAnimCheckbox:SetValue(self.settings.showHealthChangeAnimations)
    healthAnimCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        self.settings.showHealthChangeAnimations = value
    end)
    animGroup:AddChild(healthAnimCheckbox)
    
    -- Power change animation toggle
    local powerAnimCheckbox = AceGUI:Create("CheckBox")
    powerAnimCheckbox:SetLabel("Show Power Change Animations")
    powerAnimCheckbox:SetWidth(350)
    powerAnimCheckbox:SetValue(self.settings.showPowerChangeAnimations)
    powerAnimCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        self.settings.showPowerChangeAnimations = value
    end)
    animGroup:AddChild(powerAnimCheckbox)
    
    -- Fade animations toggle
    local fadeAnimCheckbox = AceGUI:Create("CheckBox")
    fadeAnimCheckbox:SetLabel("Use Fade In/Out Animations")
    fadeAnimCheckbox:SetWidth(350)
    fadeAnimCheckbox:SetValue(self.settings.useFadeAnimations)
    fadeAnimCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        self.settings.useFadeAnimations = value
    end)
    animGroup:AddChild(fadeAnimCheckbox)
    
    -- Health color group
    local healthGroup = AceGUI:Create("InlineGroup")
    healthGroup:SetTitle("Health Colors")
    healthGroup:SetLayout("Flow")
    healthGroup:SetFullWidth(true)
    container:AddChild(healthGroup)
    
    -- Tapped color picker
    local tappedPicker = AceGUI:Create("ColorPicker")
    tappedPicker:SetLabel("Tapped Units")
    tappedPicker:SetHasAlpha(true)
    tappedPicker:SetColor(
        self.settings.colors.health.tapped.r,
        self.settings.colors.health.tapped.g,
        self.settings.colors.health.tapped.b,
        self.settings.colors.health.tapped.a
    )
    tappedPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
        self.settings.colors.health.tapped.r = r
        self.settings.colors.health.tapped.g = g
        self.settings.colors.health.tapped.b = b
        self.settings.colors.health.tapped.a = a
        self:UpdateAllFrames()
    end)
    healthGroup:AddChild(tappedPicker)
    
    -- Disconnected color picker
    local dcPicker = AceGUI:Create("ColorPicker")
    dcPicker:SetLabel("Disconnected Units")
    dcPicker:SetHasAlpha(true)
    dcPicker:SetColor(
        self.settings.colors.health.disconnected.r,
        self.settings.colors.health.disconnected.g,
        self.settings.colors.health.disconnected.b,
        self.settings.colors.health.disconnected.a
    )
    dcPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
        self.settings.colors.health.disconnected.r = r
        self.settings.colors.health.disconnected.g = g
        self.settings.colors.health.disconnected.b = b
        self.settings.colors.health.disconnected.a = a
        self:UpdateAllFrames()
    end)
    healthGroup:AddChild(dcPicker)
    
    -- Reaction colors
    local reactionGroup = AceGUI:Create("InlineGroup")
    reactionGroup:SetTitle("Reaction Colors")
    reactionGroup:SetLayout("Flow")
    reactionGroup:SetFullWidth(true)
    container:AddChild(reactionGroup)
    
    -- Hostile color picker
    local hostilePicker = AceGUI:Create("ColorPicker")
    hostilePicker:SetLabel("Hostile")
    hostilePicker:SetHasAlpha(true)
    hostilePicker:SetColor(
        self.settings.colors.health.reaction.hostile.r,
        self.settings.colors.health.reaction.hostile.g,
        self.settings.colors.health.reaction.hostile.b,
        self.settings.colors.health.reaction.hostile.a
    )
    hostilePicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
        self.settings.colors.health.reaction.hostile.r = r
        self.settings.colors.health.reaction.hostile.g = g
        self.settings.colors.health.reaction.hostile.b = b
        self.settings.colors.health.reaction.hostile.a = a
        self:UpdateAllFrames()
    end)
    reactionGroup:AddChild(hostilePicker)
    
    -- Neutral color picker
    local neutralPicker = AceGUI:Create("ColorPicker")
    neutralPicker:SetLabel("Neutral")
    neutralPicker:SetHasAlpha(true)
    neutralPicker:SetColor(
        self.settings.colors.health.reaction.neutral.r,
        self.settings.colors.health.reaction.neutral.g,
        self.settings.colors.health.reaction.neutral.b,
        self.settings.colors.health.reaction.neutral.a
    )
    neutralPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
        self.settings.colors.health.reaction.neutral.r = r
        self.settings.colors.health.reaction.neutral.g = g
        self.settings.colors.health.reaction.neutral.b = b
        self.settings.colors.health.reaction.neutral.a = a
        self:UpdateAllFrames()
    end)
    reactionGroup:AddChild(neutralPicker)
    
    -- Friendly color picker
    local friendlyPicker = AceGUI:Create("ColorPicker")
    friendlyPicker:SetLabel("Friendly")
    friendlyPicker:SetHasAlpha(true)
    friendlyPicker:SetColor(
        self.settings.colors.health.reaction.friendly.r,
        self.settings.colors.health.reaction.friendly.g,
        self.settings.colors.health.reaction.friendly.b,
        self.settings.colors.health.reaction.friendly.a
    )
    friendlyPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
        self.settings.colors.health.reaction.friendly.r = r
        self.settings.colors.health.reaction.friendly.g = g
        self.settings.colors.health.reaction.friendly.b = b
        self.settings.colors.health.reaction.friendly.a = a
        self:UpdateAllFrames()
    end)
    reactionGroup:AddChild(friendlyPicker)
    
    -- Power colors group (truncated for brevity)
    local powerGroup = AceGUI:Create("InlineGroup")
    powerGroup:SetTitle("Power Colors")
    powerGroup:SetLayout("Flow")
    powerGroup:SetFullWidth(true)
    container:AddChild(powerGroup)
    
    -- MANA color picker
    local manaPicker = AceGUI:Create("ColorPicker")
    manaPicker:SetLabel("Mana")
    manaPicker:SetHasAlpha(true)
    manaPicker:SetColor(
        self.settings.colors.power.MANA.r,
        self.settings.colors.power.MANA.g,
        self.settings.colors.power.MANA.b,
        self.settings.colors.power.MANA.a
    )
    manaPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
        self.settings.colors.power.MANA.r = r
        self.settings.colors.power.MANA.g = g
        self.settings.colors.power.MANA.b = b
        self.settings.colors.power.MANA.a = a
        self:UpdateAllFrames()
    end)
    powerGroup:AddChild(manaPicker)
    
    -- RAGE color picker
    local ragePicker = AceGUI:Create("ColorPicker")
    ragePicker:SetLabel("Rage")
    ragePicker:SetHasAlpha(true)
    ragePicker:SetColor(
        self.settings.colors.power.RAGE.r,
        self.settings.colors.power.RAGE.g,
        self.settings.colors.power.RAGE.b,
        self.settings.colors.power.RAGE.a
    )
    ragePicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
        self.settings.colors.power.RAGE.r = r
        self.settings.colors.power.RAGE.g = g
        self.settings.colors.power.RAGE.b = b
        self.settings.colors.power.RAGE.a = a
        self:UpdateAllFrames()
    end)
    powerGroup:AddChild(ragePicker)
    
    -- ENERGY color picker
    local energyPicker = AceGUI:Create("ColorPicker")
    energyPicker:SetLabel("Energy")
    energyPicker:SetHasAlpha(true)
    energyPicker:SetColor(
        self.settings.colors.power.ENERGY.r,
        self.settings.colors.power.ENERGY.g,
        self.settings.colors.power.ENERGY.b,
        self.settings.colors.power.ENERGY.a
    )
    energyPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
        self.settings.colors.power.ENERGY.r = r
        self.settings.colors.power.ENERGY.g = g
        self.settings.colors.power.ENERGY.b = b
        self.settings.colors.power.ENERGY.a = a
        self:UpdateAllFrames()
    end)
    powerGroup:AddChild(energyPicker)
end

-- Register our config panel with the module API
VUI.ModuleAPI:AddModuleConfigPanel("unitframes", function() 
    return UnitFrames:CreateConfigPanel() 
end)