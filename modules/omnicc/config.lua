-- OmniCC Config Implementation
-- This file contains the configuration options for the OmniCC module
local _, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end
local OmniCC = VUI.omnicc
local AceGUI = LibStub("AceGUI-3.0")

-- Function to create a standalone configuration panel
function OmniCC:CreateConfigPanel()
    -- Create a frame
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("VUI OmniCC Configuration")
    frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    frame:SetLayout("Flow")
    frame:SetWidth(550)
    frame:SetHeight(500)
    
    -- Create tabs
    local tabs = AceGUI:Create("TabGroup")
    tabs:SetLayout("Flow")
    tabs:SetTabs({
        {text = "General", value = "general"},
        {text = "Text", value = "text"},
        {text = "Rules", value = "rules"},
        {text = "Finish Effects", value = "effects"},
        {text = "Themes", value = "themes"},
        {text = "Groups", value = "groups"}
    })
    tabs:SetCallback("OnGroupSelected", function(container, event, group)
        container:ReleaseChildren()
        if group == "general" then
            self:CreateGeneralTab(container)
        elseif group == "text" then
            self:CreateTextTab(container)
        elseif group == "rules" then
            self:CreateRulesTab(container)
        elseif group == "effects" then
            self:CreateEffectsTab(container)
        elseif group == "themes" then
            self:CreateThemesTab(container)
        elseif group == "groups" then
            self:CreateGroupsTab(container)
        end
    end)
    tabs:SelectTab("general")
    
    frame:AddChild(tabs)
    
    return frame
end

-- Create the General tab
function OmniCC:CreateGeneralTab(container)
    -- Enable/disable toggle
    local enableCheckbox = AceGUI:Create("CheckBox")
    enableCheckbox:SetLabel("Enable OmniCC")
    enableCheckbox:SetWidth(200)
    enableCheckbox:SetValue(VUI:IsModuleEnabled("omnicc"))
    enableCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        if value then
            VUI:EnableModule("omnicc")
        else
            VUI:DisableModule("omnicc")
        end
    end)
    container:AddChild(enableCheckbox)
    
    -- Spacer
    container:AddChild(AceGUI:Create("Label"):SetText(" "):SetFullWidth(true))
    
    -- General options group
    local generalGroup = AceGUI:Create("InlineGroup")
    generalGroup:SetTitle("General Options")
    generalGroup:SetLayout("Flow")
    generalGroup:SetFullWidth(true)
    container:AddChild(generalGroup)
    
    -- Minimum duration slider
    local minDurationSlider = AceGUI:Create("Slider")
    minDurationSlider:SetLabel("Minimum Duration")
    minDurationSlider:SetWidth(300)
    minDurationSlider:SetSliderValues(0.5, 10, 0.5)
    minDurationSlider:SetValue(VUI.db.profile.modules.omnicc.minDuration)
    minDurationSlider:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.omnicc.minDuration = value
    end)
    generalGroup:AddChild(minDurationSlider)
    
    -- Minimum cooldown size slider
    local minSizeSlider = AceGUI:Create("Slider")
    minSizeSlider:SetLabel("Minimum Size")
    minSizeSlider:SetWidth(300)
    minSizeSlider:SetSliderValues(8, 32, 1)
    minSizeSlider:SetValue(VUI.db.profile.modules.omnicc.minSize)
    minSizeSlider:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.omnicc.minSize = value
    end)
    generalGroup:AddChild(minSizeSlider)
    
    -- Show cooldowns with charges
    local chargesCheckbox = AceGUI:Create("CheckBox")
    chargesCheckbox:SetLabel("Show Cooldowns with Charges")
    chargesCheckbox:SetWidth(300)
    chargesCheckbox:SetValue(VUI.db.profile.modules.omnicc.showCharges)
    chargesCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.omnicc.showCharges = value
    end)
    generalGroup:AddChild(chargesCheckbox)
    
    -- Compatibility options group
    local compatGroup = AceGUI:Create("InlineGroup")
    compatGroup:SetTitle("Compatibility")
    compatGroup:SetLayout("Flow")
    compatGroup:SetFullWidth(true)
    container:AddChild(compatGroup)
    
    -- Blacklist edit box
    local blacklistEditBox = AceGUI:Create("MultiLineEditBox")
    blacklistEditBox:SetLabel("Blacklisted Frame Names (one per line)")
    blacklistEditBox:SetFullWidth(true)
    blacklistEditBox:SetHeight(150)
    
    -- Convert blacklist table to string
    local blacklistStr = ""
    for i, name in ipairs(VUI.db.profile.modules.omnicc.blacklist) do
        blacklistStr = blacklistStr .. name
        if i < #VUI.db.profile.modules.omnicc.blacklist then
            blacklistStr = blacklistStr .. "\n"
        end
    end
    
    blacklistEditBox:SetText(blacklistStr)
    blacklistEditBox:SetCallback("OnEnterPressed", function(widget, event, text)
        local newBlacklist = {}
        for line in text:gmatch("[^\r\n]+") do
            if line and line ~= "" then
                table.insert(newBlacklist, line)
            end
        end
        VUI.db.profile.modules.omnicc.blacklist = newBlacklist
    end)
    compatGroup:AddChild(blacklistEditBox)
end

-- Create the Text tab
function OmniCC:CreateTextTab(container)
    -- Text options group
    local textGroup = AceGUI:Create("InlineGroup")
    textGroup:SetTitle("Text Display")
    textGroup:SetLayout("Flow")
    textGroup:SetFullWidth(true)
    container:AddChild(textGroup)
    
    -- Text group left column
    local textLeftColumn = AceGUI:Create("SimpleGroup")
    textLeftColumn:SetLayout("Flow")
    textLeftColumn:SetWidth(250)
    textGroup:AddChild(textLeftColumn)
    
    -- Font scale slider
    local fontScaleSlider = AceGUI:Create("Slider")
    fontScaleSlider:SetLabel("Font Scale")
    fontScaleSlider:SetWidth(230)
    fontScaleSlider:SetSliderValues(0.5, 2.0, 0.05)
    fontScaleSlider:SetValue(VUI.db.profile.modules.omnicc.fontScale)
    fontScaleSlider:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.omnicc.fontScale = value
    end)
    textLeftColumn:AddChild(fontScaleSlider)
    
    -- Minimum font size slider
    local minFontSizeSlider = AceGUI:Create("Slider")
    minFontSizeSlider:SetLabel("Minimum Font Size")
    minFontSizeSlider:SetWidth(230)
    minFontSizeSlider:SetSliderValues(6, 16, 1)
    minFontSizeSlider:SetValue(VUI.db.profile.modules.omnicc.minFontSize)
    minFontSizeSlider:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.omnicc.minFontSize = value
    end)
    textLeftColumn:AddChild(minFontSizeSlider)
    
    -- Text group right column
    local textRightColumn = AceGUI:Create("SimpleGroup")
    textRightColumn:SetLayout("Flow")
    textRightColumn:SetWidth(250)
    textGroup:AddChild(textRightColumn)
    
    -- Font outline dropdown
    local outlineDropdown = AceGUI:Create("Dropdown")
    outlineDropdown:SetLabel("Font Outline")
    outlineDropdown:SetWidth(230)
    outlineDropdown:SetList({
        [""] = "None",
        ["OUTLINE"] = "Outline",
        ["THICKOUTLINE"] = "Thick Outline",
        ["MONOCHROME"] = "Monochrome"
    })
    outlineDropdown:SetValue(VUI.db.profile.modules.omnicc.fontOutline)
    outlineDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.omnicc.fontOutline = value
    end)
    textRightColumn:AddChild(outlineDropdown)
    
    -- Text anchor dropdown
    local anchorDropdown = AceGUI:Create("Dropdown")
    anchorDropdown:SetLabel("Text Position")
    anchorDropdown:SetWidth(230)
    anchorDropdown:SetList({
        ["CENTER"] = "Center",
        ["TOP"] = "Top",
        ["BOTTOM"] = "Bottom",
        ["LEFT"] = "Left",
        ["RIGHT"] = "Right"
    })
    anchorDropdown:SetValue(VUI.db.profile.modules.omnicc.textAnchor)
    anchorDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.omnicc.textAnchor = value
    end)
    textRightColumn:AddChild(anchorDropdown)
    
    -- Uniform text size
    local uniformTextCheckbox = AceGUI:Create("CheckBox")
    uniformTextCheckbox:SetLabel("Use Uniform Text Size")
    uniformTextCheckbox:SetWidth(230)
    uniformTextCheckbox:SetValue(VUI.db.profile.modules.omnicc.uniformTextSize)
    uniformTextCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.omnicc.uniformTextSize = value
        fontSizeSlider:SetDisabled(not value)
    end)
    container:AddChild(uniformTextCheckbox)
    
    -- Font size slider (only used with uniform text size)
    local fontSizeSlider = AceGUI:Create("Slider")
    fontSizeSlider:SetLabel("Font Size")
    fontSizeSlider:SetWidth(300)
    fontSizeSlider:SetSliderValues(8, 32, 1)
    fontSizeSlider:SetValue(VUI.db.profile.modules.omnicc.fontSize)
    fontSizeSlider:SetDisabled(not VUI.db.profile.modules.omnicc.uniformTextSize)
    fontSizeSlider:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.omnicc.fontSize = value
    end)
    container:AddChild(fontSizeSlider)
    
    -- Text color group
    local colorGroup = AceGUI:Create("InlineGroup")
    colorGroup:SetTitle("Text Colors")
    colorGroup:SetLayout("Flow")
    colorGroup:SetFullWidth(true)
    container:AddChild(colorGroup)
    
    -- Use color gradient checkbox
    local gradientCheckbox = AceGUI:Create("CheckBox")
    gradientCheckbox:SetLabel("Use Color Gradient")
    gradientCheckbox:SetWidth(200)
    gradientCheckbox:SetValue(VUI.db.profile.modules.omnicc.useColorGradient)
    gradientCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.omnicc.useColorGradient = value
        textColorPicker:SetDisabled(value)
    end)
    colorGroup:AddChild(gradientCheckbox)
    
    -- Text color picker
    local textColorPicker = AceGUI:Create("ColorPicker")
    textColorPicker:SetLabel("Text Color")
    textColorPicker:SetWidth(200)
    textColorPicker:SetDisabled(VUI.db.profile.modules.omnicc.useColorGradient)
    textColorPicker:SetColor(
        VUI.db.profile.modules.omnicc.textColor.r or 1,
        VUI.db.profile.modules.omnicc.textColor.g or 1,
        VUI.db.profile.modules.omnicc.textColor.b or 1,
        VUI.db.profile.modules.omnicc.textColor.a or 1
    )
    textColorPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
        VUI.db.profile.modules.omnicc.textColor = {r = r, g = g, b = b, a = a}
    end)
    colorGroup:AddChild(textColorPicker)
end

-- Create the Rules tab
function OmniCC:CreateRulesTab(container)
    -- Rules description
    local descLabel = AceGUI:Create("Label")
    descLabel:SetText("Rules allow you to configure different text settings based on the type of cooldown.")
    descLabel:SetFullWidth(true)
    container:AddChild(descLabel)
    
    -- Rules group
    local rulesGroup = AceGUI:Create("InlineGroup")
    rulesGroup:SetTitle("Rule Configurations")
    rulesGroup:SetLayout("Flow")
    rulesGroup:SetFullWidth(true)
    container:AddChild(rulesGroup)
    
    -- Sample rules
    local sampleRules = {
        {name = "Action Bars", pattern = "ActionButton", priority = 10},
        {name = "Pet Bars", pattern = "PetActionButton", priority = 20},
        {name = "Auras", pattern = "Aura", priority = 30},
    }
    
    -- Show rule list
    for i, rule in ipairs(sampleRules) do
        local ruleGroup = AceGUI:Create("SimpleGroup")
        ruleGroup:SetLayout("Flow")
        ruleGroup:SetFullWidth(true)
        
        -- Rule name
        local nameLabel = AceGUI:Create("Label")
        nameLabel:SetText(rule.name)
        nameLabel:SetWidth(150)
        ruleGroup:AddChild(nameLabel)
        
        -- Rule pattern
        local patternLabel = AceGUI:Create("Label")
        patternLabel:SetText(rule.pattern)
        patternLabel:SetWidth(150)
        ruleGroup:AddChild(patternLabel)
        
        -- Priority
        local priorityLabel = AceGUI:Create("Label")
        priorityLabel:SetText("Priority: " .. rule.priority)
        priorityLabel:SetWidth(100)
        ruleGroup:AddChild(priorityLabel)
        
        -- Edit button
        local editButton = AceGUI:Create("Button")
        editButton:SetText("Edit")
        editButton:SetWidth(80)
        editButton:SetCallback("OnClick", function()
            print("Would edit rule: " .. rule.name)
        end)
        ruleGroup:AddChild(editButton)
        
        rulesGroup:AddChild(ruleGroup)
    end
    
    -- Add rule button
    local addRuleButton = AceGUI:Create("Button")
    addRuleButton:SetText("Add New Rule")
    addRuleButton:SetWidth(150)
    addRuleButton:SetCallback("OnClick", function()
        print("Would add a new rule")
    end)
    container:AddChild(addRuleButton)
end

-- Create the Effects tab
function OmniCC:CreateEffectsTab(container)
    -- Effects options group
    local effectsGroup = AceGUI:Create("InlineGroup")
    effectsGroup:SetTitle("Finish Effects")
    effectsGroup:SetLayout("Flow")
    effectsGroup:SetFullWidth(true)
    container:AddChild(effectsGroup)
    
    -- Enable effects checkbox
    local enableEffectsCheckbox = AceGUI:Create("CheckBox")
    enableEffectsCheckbox:SetLabel("Enable Finish Effects")
    enableEffectsCheckbox:SetWidth(200)
    enableEffectsCheckbox:SetValue(VUI.db.profile.modules.omnicc.enableEffects)
    enableEffectsCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.omnicc.enableEffects = value
        effectTypeDropdown:SetDisabled(not value)
        thresholdSlider:SetDisabled(not value)
    end)
    effectsGroup:AddChild(enableEffectsCheckbox)
    
    -- Effect type dropdown
    local effectTypeDropdown = AceGUI:Create("Dropdown")
    effectTypeDropdown:SetLabel("Effect Type")
    effectTypeDropdown:SetWidth(200)
    effectTypeDropdown:SetDisabled(not VUI.db.profile.modules.omnicc.enableEffects)
    effectTypeDropdown:SetList({
        ["PULSE"] = "Pulse",
        ["SHINE"] = "Shine",
        ["FLARE"] = "Flare"
    })
    effectTypeDropdown:SetValue(VUI.db.profile.modules.omnicc.effectType)
    effectTypeDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.omnicc.effectType = value
    end)
    effectsGroup:AddChild(effectTypeDropdown)
    
    -- Effect threshold slider
    local thresholdSlider = AceGUI:Create("Slider")
    thresholdSlider:SetLabel("Effect Threshold (seconds)")
    thresholdSlider:SetWidth(300)
    thresholdSlider:SetDisabled(not VUI.db.profile.modules.omnicc.enableEffects)
    thresholdSlider:SetSliderValues(0, 10, 0.5)
    thresholdSlider:SetValue(VUI.db.profile.modules.omnicc.effectThreshold)
    thresholdSlider:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.omnicc.effectThreshold = value
    end)
    effectsGroup:AddChild(thresholdSlider)
    
    -- Preview group
    local previewGroup = AceGUI:Create("InlineGroup")
    previewGroup:SetTitle("Preview")
    previewGroup:SetLayout("Flow")
    previewGroup:SetFullWidth(true)
    container:AddChild(previewGroup)
    
    -- Preview description
    local previewDesc = AceGUI:Create("Label")
    previewDesc:SetText("Click a button below to preview the effect:")
    previewDesc:SetFullWidth(true)
    previewGroup:AddChild(previewDesc)
    
    -- Preview buttons
    local previewPulseButton = AceGUI:Create("Button")
    previewPulseButton:SetText("Preview Pulse")
    previewPulseButton:SetWidth(150)
    previewPulseButton:SetCallback("OnClick", function()
        print("Would preview pulse effect")
    end)
    previewGroup:AddChild(previewPulseButton)
    
    local previewShineButton = AceGUI:Create("Button")
    previewShineButton:SetText("Preview Shine")
    previewShineButton:SetWidth(150)
    previewShineButton:SetCallback("OnClick", function()
        print("Would preview shine effect")
    end)
    previewGroup:AddChild(previewShineButton)
    
    local previewFlareButton = AceGUI:Create("Button")
    previewFlareButton:SetText("Preview Flare")
    previewFlareButton:SetWidth(150)
    previewFlareButton:SetCallback("OnClick", function()
        print("Would preview flare effect")
    end)
    previewGroup:AddChild(previewFlareButton)
end

-- Get options for the config panel
function OmniCC:GetOptions()
    return {
        type = "group",
        name = "OmniCC",
        args = {
            enable = {
                type = "toggle",
                name = "Enable",
                desc = "Enable or disable the OmniCC module",
                order = 1,
                get = function() return VUI:IsModuleEnabled("omnicc") end,
                set = function(_, value)
                    if value then
                        VUI:EnableModule("omnicc")
                    else
                        VUI:DisableModule("omnicc")
                    end
                end,
            },
            general = {
                type = "group",
                name = "General Settings",
                order = 2,
                inline = true,
                disabled = function() return not VUI:IsModuleEnabled("omnicc") end,
                args = {
                    minDuration = {
                        type = "range",
                        name = "Minimum Duration",
                        desc = "The minimum duration a cooldown must be to show text",
                        min = 0.5,
                        max = 10,
                        step = 0.5,
                        order = 1,
                        get = function() return VUI.db.profile.modules.omnicc.minDuration end,
                        set = function(_, value)
                            VUI.db.profile.modules.omnicc.minDuration = value
                        end,
                    },
                    minSize = {
                        type = "range",
                        name = "Minimum Size",
                        desc = "The minimum size a cooldown must be to show text",
                        min = 8,
                        max = 32,
                        step = 1,
                        order = 2,
                        get = function() return VUI.db.profile.modules.omnicc.minSize end,
                        set = function(_, value)
                            VUI.db.profile.modules.omnicc.minSize = value
                        end,
                    }
                }
            },
            text = {
                type = "group",
                name = "Text Settings",
                order = 3,
                inline = true,
                disabled = function() return not VUI:IsModuleEnabled("omnicc") end,
                args = {
                    fontScale = {
                        type = "range",
                        name = "Font Scale",
                        desc = "How big the cooldown text is",
                        min = 0.5,
                        max = 2.0,
                        step = 0.05,
                        order = 1,
                        get = function() return VUI.db.profile.modules.omnicc.fontScale end,
                        set = function(_, value)
                            VUI.db.profile.modules.omnicc.fontScale = value
                        end,
                    },
                    minFontSize = {
                        type = "range",
                        name = "Minimum Font Size",
                        desc = "The minimum font size to use",
                        min = 6,
                        max = 16,
                        step = 1,
                        order = 2,
                        get = function() return VUI.db.profile.modules.omnicc.minFontSize end,
                        set = function(_, value)
                            VUI.db.profile.modules.omnicc.minFontSize = value
                        end,
                    }
                }
            },
            effects = {
                type = "group",
                name = "Finish Effects",
                order = 4,
                inline = true,
                disabled = function() return not VUI:IsModuleEnabled("omnicc") end,
                args = {
                    enableEffects = {
                        type = "toggle",
                        name = "Enable Effects",
                        desc = "Show an effect when a cooldown completes",
                        order = 1,
                        get = function() return VUI.db.profile.modules.omnicc.enableEffects end,
                        set = function(_, value)
                            VUI.db.profile.modules.omnicc.enableEffects = value
                        end,
                    },
                    effectType = {
                        type = "select",
                        name = "Effect Type",
                        desc = "The type of effect to display when a cooldown finishes",
                        values = {
                            ["PULSE"] = "Pulse",
                            ["SHINE"] = "Shine",
                            ["FLARE"] = "Flare"
                        },
                        disabled = function() return not VUI.db.profile.modules.omnicc.enableEffects end,
                        order = 2,
                        get = function() return VUI.db.profile.modules.omnicc.effectType end,
                        set = function(_, value)
                            VUI.db.profile.modules.omnicc.effectType = value
                        end,
                    }
                }
            }
        }
    }
end

-- Create the Themes tab
function OmniCC:CreateThemesTab(container)
    -- Theme description
    local descLabel = AceGUI:Create("Label")
    descLabel:SetText("Theme settings control the appearance of cooldown text and effects based on the active VUI theme.")
    descLabel:SetFullWidth(true)
    container:AddChild(descLabel)
    
    -- Current theme display
    local currentTheme = VUI.db.profile.theme or "thunderstorm"
    local themeLabel = AceGUI:Create("Label")
    themeLabel:SetText("Current Theme: " .. currentTheme:gsub("^%l", string.upper))
    themeLabel:SetFontObject(GameFontHighlight)
    themeLabel:SetFullWidth(true)
    container:AddChild(themeLabel)
    
    -- Note: Theme selection is managed through the VUI Dashboard
    local noteLabel = AceGUI:Create("Label")
    noteLabel:SetText("Note: Theme selection is managed through the VUI Dashboard.")
    noteLabel:SetFullWidth(true)
    container:AddChild(noteLabel)
    
    -- Preview Header
    local previewHeader = AceGUI:Create("Heading")
    previewHeader:SetText("Theme Preview")
    previewHeader:SetFullWidth(true)
    container:AddChild(previewHeader)
    
    -- Theme preview group
    local previewGroup = AceGUI:Create("InlineGroup")
    previewGroup:SetLayout("Flow")
    previewGroup:SetFullWidth(true)
    previewGroup:SetHeight(150)
    container:AddChild(previewGroup)
    
    -- Create preview frames for each duration type
    local durationTypes = {
        {name = "Days", time = 172800, text = "2d"},
        {name = "Hours", time = 7200, text = "2h"},
        {name = "Minutes", time = 300, text = "5m"},
        {name = "Seconds", time = 45, text = "45s"},
        {name = "Low Time", time = 3, text = "3.0"}
    }
    
    for i, durationType in ipairs(durationTypes) do
        local preview = AceGUI:Create("SimpleGroup")
        preview:SetWidth(80)
        preview:SetHeight(100)
        preview:SetLayout("Flow")
        
        local label = AceGUI:Create("Label")
        label:SetText(durationType.name)
        label:SetWidth(80)
        preview:AddChild(label)
        
        local frame = AceGUI:Create("Frame")
        frame:SetWidth(50)
        frame:SetHeight(50)
        frame.frame:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        frame.frame:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
        
        -- Create text display
        local textDisplay = frame.frame:CreateFontString(nil, "OVERLAY")
        textDisplay:SetPoint("CENTER", frame.frame, "CENTER", 0, 0)
        
        -- Apply theme colors for this duration type
        local theme = self:GetCurrentTheme()
        if theme and theme.colors then
            local colorKey
            if durationType.time >= 86400 then
                colorKey = "days"
            elseif durationType.time >= 3600 then
                colorKey = "hours"
            elseif durationType.time >= 60 then
                colorKey = "minutes"
            elseif durationType.time >= 10 then
                colorKey = "seconds"
            else
                colorKey = "milliseconds"
            end
            
            local color = theme.colors[colorKey]
            if color then
                textDisplay:SetTextColor(color.r, color.g, color.b, color.a or 1.0)
            end
        end
        
        -- Set font and text
        local fontPath = theme and theme.fonts and theme.fonts.regular or DEFAULT_FONT_FACE
        textDisplay:SetFont(fontPath, 16, "OUTLINE")
        textDisplay:SetText(durationType.text)
        
        preview:AddChild(frame)
        previewGroup:AddChild(preview)
    end
    
    -- Advanced theme options group
    local advancedGroup = AceGUI:Create("InlineGroup")
    advancedGroup:SetTitle("Advanced Theme Options")
    advancedGroup:SetLayout("Flow")
    advancedGroup:SetFullWidth(true)
    container:AddChild(advancedGroup)
    
    -- Theme honor checkbox
    local honorThemeCheckbox = AceGUI:Create("CheckBox")
    honorThemeCheckbox:SetLabel("Honor VUI Theme Settings")
    honorThemeCheckbox:SetWidth(200)
    honorThemeCheckbox:SetValue(VUI.db.profile.modules.omnicc.honorTheme or true)
    honorThemeCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.omnicc.honorTheme = value
        
        -- Refresh all cooldowns
        self:RefreshSettings()
    end)
    advancedGroup:AddChild(honorThemeCheckbox)
    
    -- Effect brightness slider
    local brightnessSlider = AceGUI:Create("Slider")
    brightnessSlider:SetLabel("Effect Brightness")
    brightnessSlider:SetWidth(300)
    brightnessSlider:SetSliderValues(0.1, 2.0, 0.1)
    brightnessSlider:SetValue(VUI.db.profile.modules.omnicc.effectBrightness or 1.0)
    brightnessSlider:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.omnicc.effectBrightness = value
    end)
    advancedGroup:AddChild(brightnessSlider)
    
    -- Theme animation preview button
    local previewButton = AceGUI:Create("Button")
    previewButton:SetText("Preview Finish Effect")
    previewButton:SetWidth(150)
    previewButton:SetCallback("OnClick", function()
        -- Create a temporary frame for the preview
        local previewFrame = CreateFrame("Frame", nil, UIParent)
        previewFrame:SetSize(64, 64)
        previewFrame:SetPoint("CENTER", 0, 0)
        
        -- Show the finish effect
        self:PlayFinishAnimation(previewFrame)
        
        -- Clean up after 2 seconds
        C_Timer.After(2, function()
            previewFrame:Hide()
            previewFrame = nil
        end)
    end)
    advancedGroup:AddChild(previewButton)
end

-- Create the Groups tab
function OmniCC:CreateGroupsTab(container)
    -- Groups description
    local descLabel = AceGUI:Create("Label")
    descLabel:SetText("Cooldown groups allow you to create priority-based styling for different types of abilities.")
    descLabel:SetFullWidth(true)
    container:AddChild(descLabel)
    
    -- Groups configuration container
    local groupsContainer = AceGUI:Create("SimpleGroup")
    groupsContainer:SetLayout("Flow")
    groupsContainer:SetFullWidth(true)
    container:AddChild(groupsContainer)
    
    -- Get all groups sorted by priority
    local groups = self:GetAllGroups()
    
    -- Display each group in the list
    for i, group in ipairs(groups) do
        local groupFrame = AceGUI:Create("InlineGroup")
        groupFrame:SetTitle(group.name)
        groupFrame:SetLayout("Flow")
        groupFrame:SetFullWidth(true)
        
        -- Left column for settings
        local leftCol = AceGUI:Create("SimpleGroup")
        leftCol:SetLayout("Flow")
        leftCol:SetWidth(250)
        
        -- Priority slider
        local prioritySlider = AceGUI:Create("Slider")
        prioritySlider:SetLabel("Priority")
        prioritySlider:SetWidth(230)
        prioritySlider:SetSliderValues(1, 100, 1)
        prioritySlider:SetValue(group.priority or 50)
        prioritySlider:SetCallback("OnValueChanged", function(widget, event, value)
            group.priority = value
            
            -- Update groups when priority changes
            self:UpdateGroupPriorities()
        end)
        leftCol:AddChild(prioritySlider)
        
        -- Scale slider
        local scaleSlider = AceGUI:Create("Slider")
        scaleSlider:SetLabel("Text Scale")
        scaleSlider:SetWidth(230)
        scaleSlider:SetSliderValues(0.5, 2.0, 0.1)
        scaleSlider:SetValue(group.scale or 1.0)
        scaleSlider:SetCallback("OnValueChanged", function(widget, event, value)
            group.scale = value
            
            -- Refresh settings when scale changes
            self:RefreshSettings()
        end)
        leftCol:AddChild(scaleSlider)
        
        groupFrame:AddChild(leftCol)
        
        -- Right column for color and rules
        local rightCol = AceGUI:Create("SimpleGroup")
        rightCol:SetLayout("Flow")
        rightCol:SetWidth(250)
        
        -- Text color picker
        local colorPicker = AceGUI:Create("ColorPicker")
        colorPicker:SetLabel("Text Color")
        colorPicker:SetWidth(230)
        
        -- Set initial color from group
        if group.textColor then
            colorPicker:SetColor(
                group.textColor.r or 1,
                group.textColor.g or 1,
                group.textColor.b or 1,
                group.textColor.a or 1
            )
        else
            colorPicker:SetColor(1, 1, 1, 1)
        end
        
        colorPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
            group.textColor = {r = r, g = g, b = b, a = a}
            
            -- Refresh settings when color changes
            self:RefreshSettings()
        end)
        rightCol:AddChild(colorPicker)
        
        -- Edit rules button
        local editRulesButton = AceGUI:Create("Button")
        editRulesButton:SetText("Edit Rules")
        editRulesButton:SetWidth(230)
        editRulesButton:SetCallback("OnClick", function()
            -- Here we would open a dialog to edit the group rules
            -- For now, we'll just print a message
            VUI:Print("Group rules editing not yet implemented")
        end)
        rightCol:AddChild(editRulesButton)
        
        groupFrame:AddChild(rightCol)
        
        -- Add the group frame to the container
        groupsContainer:AddChild(groupFrame)
    end
    
    -- Add new group button
    local addGroupButton = AceGUI:Create("Button")
    addGroupButton:SetText("Add New Group")
    addGroupButton:SetWidth(150)
    addGroupButton:SetCallback("OnClick", function()
        -- Here we would open a dialog to create a new group
        -- For now, we'll just print a message
        VUI:Print("Group creation not yet implemented")
    end)
    container:AddChild(addGroupButton)
end