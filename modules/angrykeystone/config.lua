-- Angry Keystones Config Implementation
-- This file contains the configuration options for the Angry Keystones module
local _, VUI = ...
local AngryKeystones = VUI.angrykeystone
local AceGUI = LibStub("AceGUI-3.0")

-- Function to create a standalone configuration panel
function AngryKeystones:CreateConfigPanel()
    -- Create a frame
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("VUI Angry Keystones Configuration")
    frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    frame:SetLayout("Flow")
    frame:SetWidth(550)
    frame:SetHeight(500)
    
    -- Create tabs
    local tabs = AceGUI:Create("TabGroup")
    tabs:SetLayout("Flow")
    tabs:SetTabs({
        {text = "General", value = "general"},
        {text = "Progress Tracker", value = "progress"},
        {text = "Objective Tracker", value = "objective"},
        {text = "Timer", value = "timer"}
    })
    tabs:SetCallback("OnGroupSelected", function(container, event, group)
        container:ReleaseChildren()
        if group == "general" then
            self:CreateGeneralTab(container)
        elseif group == "progress" then
            self:CreateProgressTab(container)
        elseif group == "objective" then
            self:CreateObjectiveTab(container)
        elseif group == "timer" then
            self:CreateTimerTab(container)
        end
    end)
    tabs:SelectTab("general")
    
    frame:AddChild(tabs)
    
    return frame
end

-- Create the General tab
function AngryKeystones:CreateGeneralTab(container)
    -- Enable/disable toggle
    local enableCheckbox = AceGUI:Create("CheckBox")
    enableCheckbox:SetLabel("Enable Angry Keystones")
    enableCheckbox:SetWidth(200)
    enableCheckbox:SetValue(VUI:IsModuleEnabled("angrykeystone"))
    enableCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        if value then
            VUI:EnableModule("angrykeystone")
        else
            VUI:DisableModule("angrykeystone")
        end
    end)
    container:AddChild(enableCheckbox)
    
    -- Spacer
    container:AddChild(AceGUI:Create("Label"):SetText(" "):SetFullWidth(true))
    
    -- Module options group
    local generalGroup = AceGUI:Create("InlineGroup")
    generalGroup:SetTitle("Module Options")
    generalGroup:SetLayout("Flow")
    generalGroup:SetFullWidth(true)
    container:AddChild(generalGroup)
    
    -- Keystones tab
    local keystoneCheckbox = AceGUI:Create("CheckBox")
    keystoneCheckbox:SetLabel("Show Keystone Info")
    keystoneCheckbox:SetWidth(200)
    keystoneCheckbox:SetValue(VUI.db.profile.modules.angrykeystone.showKeystoneInfo)
    keystoneCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.angrykeystone.showKeystoneInfo = value
    end)
    generalGroup:AddChild(keystoneCheckbox)
    
    -- Schedule tab
    local scheduleCheckbox = AceGUI:Create("CheckBox")
    scheduleCheckbox:SetLabel("Show Affix Schedule")
    scheduleCheckbox:SetWidth(200)
    scheduleCheckbox:SetValue(VUI.db.profile.modules.angrykeystone.showScheduleInfo)
    scheduleCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.angrykeystone.showScheduleInfo = value
    end)
    generalGroup:AddChild(scheduleCheckbox)
    
    -- Time estimates
    local timeEstimatesCheckbox = AceGUI:Create("CheckBox")
    timeEstimatesCheckbox:SetLabel("Show Time Estimates")
    timeEstimatesCheckbox:SetWidth(200)
    timeEstimatesCheckbox:SetValue(VUI.db.profile.modules.angrykeystone.timeEstimates)
    timeEstimatesCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.angrykeystone.timeEstimates = value
    end)
    generalGroup:AddChild(timeEstimatesCheckbox)
    
    -- Auto screenshot completion
    local screenshotCheckbox = AceGUI:Create("CheckBox")
    screenshotCheckbox:SetLabel("Auto Screenshot on Completion")
    screenshotCheckbox:SetWidth(300)
    screenshotCheckbox:SetValue(VUI.db.profile.modules.angrykeystone.autoScreenshot)
    screenshotCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.angrykeystone.autoScreenshot = value
    end)
    generalGroup:AddChild(screenshotCheckbox)
    
    -- Clear database
    local clearButton = AceGUI:Create("Button")
    clearButton:SetText("Clear Dungeon History")
    clearButton:SetWidth(200)
    clearButton:SetCallback("OnClick", function()
        StaticPopupDialogs["VUI_ANGRYKEYSTONE_CLEAR_DATA"] = {
            text = "Are you sure you want to clear all dungeon completion history?",
            button1 = "Yes",
            button2 = "No",
            OnAccept = function()
                VUI.db.profile.modules.angrykeystone.completions = {}
                VUI.db.profile.modules.angrykeystone.timeData = {}
                print("Dungeon history cleared")
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
        StaticPopup_Show("VUI_ANGRYKEYSTONE_CLEAR_DATA")
    end)
    generalGroup:AddChild(clearButton)
end

-- Create the Progress tab
function AngryKeystones:CreateProgressTab(container)
    -- Progress options group
    local progressGroup = AceGUI:Create("InlineGroup")
    progressGroup:SetTitle("Progress Tracker")
    progressGroup:SetLayout("Flow")
    progressGroup:SetFullWidth(true)
    container:AddChild(progressGroup)
    
    -- Show progress tracker
    local progressCheckbox = AceGUI:Create("CheckBox")
    progressCheckbox:SetLabel("Show Progress Tracker")
    progressCheckbox:SetWidth(200)
    progressCheckbox:SetValue(VUI.db.profile.modules.angrykeystone.showProgressTracker)
    progressCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.angrykeystone.showProgressTracker = value
    end)
    progressGroup:AddChild(progressCheckbox)
    
    -- Detailed progress
    local detailedProgressCheckbox = AceGUI:Create("CheckBox")
    detailedProgressCheckbox:SetLabel("Show Detailed Progress")
    detailedProgressCheckbox:SetWidth(200)
    detailedProgressCheckbox:SetValue(VUI.db.profile.modules.angrykeystone.detailedProgress)
    detailedProgressCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.angrykeystone.detailedProgress = value
    end)
    progressGroup:AddChild(detailedProgressCheckbox)
    
    -- Show count
    local countCheckbox = AceGUI:Create("CheckBox")
    countCheckbox:SetLabel("Show Enemy Points")
    countCheckbox:SetWidth(200)
    countCheckbox:SetValue(VUI.db.profile.modules.angrykeystone.showEnemyPoints)
    countCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.angrykeystone.showEnemyPoints = value
    end)
    progressGroup:AddChild(countCheckbox)
    
    -- Position options group
    local positionGroup = AceGUI:Create("InlineGroup")
    positionGroup:SetTitle("Progress Tracker Position")
    positionGroup:SetLayout("Flow")
    positionGroup:SetFullWidth(true)
    container:AddChild(positionGroup)
    
    -- Anchoring dropdown
    local anchorDropdown = AceGUI:Create("Dropdown")
    anchorDropdown:SetLabel("Anchor Point")
    anchorDropdown:SetWidth(200)
    anchorDropdown:SetList({
        ["TOP"] = "Top",
        ["TOPRIGHT"] = "Top Right",
        ["TOPLEFT"] = "Top Left",
        ["BOTTOM"] = "Bottom",
        ["BOTTOMRIGHT"] = "Bottom Right",
        ["BOTTOMLEFT"] = "Bottom Left",
    })
    anchorDropdown:SetValue(VUI.db.profile.modules.angrykeystone.progressAnchor or "TOPRIGHT")
    anchorDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.angrykeystone.progressAnchor = value
    end)
    positionGroup:AddChild(anchorDropdown)
    
    -- X Offset slider
    local xOffsetSlider = AceGUI:Create("Slider")
    xOffsetSlider:SetLabel("X Offset")
    xOffsetSlider:SetWidth(200)
    xOffsetSlider:SetSliderValues(-300, 300, 1)
    xOffsetSlider:SetValue(VUI.db.profile.modules.angrykeystone.progressOffsetX or 0)
    xOffsetSlider:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.angrykeystone.progressOffsetX = value
    end)
    positionGroup:AddChild(xOffsetSlider)
    
    -- Y Offset slider
    local yOffsetSlider = AceGUI:Create("Slider")
    yOffsetSlider:SetLabel("Y Offset")
    yOffsetSlider:SetWidth(200)
    yOffsetSlider:SetSliderValues(-300, 300, 1)
    yOffsetSlider:SetValue(VUI.db.profile.modules.angrykeystone.progressOffsetY or 0)
    yOffsetSlider:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.angrykeystone.progressOffsetY = value
    end)
    positionGroup:AddChild(yOffsetSlider)
end

-- Create the Objective tab
function AngryKeystones:CreateObjectiveTab(container)
    -- Objective options group
    local objectiveGroup = AceGUI:Create("InlineGroup")
    objectiveGroup:SetTitle("Objective Tracker")
    objectiveGroup:SetLayout("Flow")
    objectiveGroup:SetFullWidth(true)
    container:AddChild(objectiveGroup)
    
    -- Show objective tracker
    local objectiveCheckbox = AceGUI:Create("CheckBox")
    objectiveCheckbox:SetLabel("Show Enhanced Objective Tracker")
    objectiveCheckbox:SetWidth(300)
    objectiveCheckbox:SetValue(VUI.db.profile.modules.angrykeystone.showObjectiveTracker)
    objectiveCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.angrykeystone.showObjectiveTracker = value
    end)
    objectiveGroup:AddChild(objectiveCheckbox)
    
    -- Show key info
    local keyInfoCheckbox = AceGUI:Create("CheckBox")
    keyInfoCheckbox:SetLabel("Show Keystone Info in Tracker")
    keyInfoCheckbox:SetWidth(300)
    keyInfoCheckbox:SetValue(VUI.db.profile.modules.angrykeystone.showKeyInfo)
    keyInfoCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.angrykeystone.showKeyInfo = value
    end)
    objectiveGroup:AddChild(keyInfoCheckbox)
    
    -- Show completion time
    local completionTimeCheckbox = AceGUI:Create("CheckBox")
    completionTimeCheckbox:SetLabel("Show Completion Time")
    completionTimeCheckbox:SetWidth(200)
    completionTimeCheckbox:SetValue(VUI.db.profile.modules.angrykeystone.showCompletionTime)
    completionTimeCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.angrykeystone.showCompletionTime = value
    end)
    objectiveGroup:AddChild(completionTimeCheckbox)
    
    -- Show percent progress
    local percentProgressCheckbox = AceGUI:Create("CheckBox")
    percentProgressCheckbox:SetLabel("Show Percent Progress")
    percentProgressCheckbox:SetWidth(200)
    percentProgressCheckbox:SetValue(VUI.db.profile.modules.angrykeystone.showPercentProgress)
    percentProgressCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.angrykeystone.showPercentProgress = value
    end)
    objectiveGroup:AddChild(percentProgressCheckbox)
end

-- Create the Timer tab
function AngryKeystones:CreateTimerTab(container)
    -- Timer options group
    local timerGroup = AceGUI:Create("InlineGroup")
    timerGroup:SetTitle("Timer Display")
    timerGroup:SetLayout("Flow")
    timerGroup:SetFullWidth(true)
    container:AddChild(timerGroup)
    
    -- Show timer
    local timerCheckbox = AceGUI:Create("CheckBox")
    timerCheckbox:SetLabel("Show Timer")
    timerCheckbox:SetWidth(200)
    timerCheckbox:SetValue(VUI.db.profile.modules.angrykeystone.showTimer)
    timerCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.angrykeystone.showTimer = value
    end)
    timerGroup:AddChild(timerCheckbox)
    
    -- Show +2/+3 timers
    local plusTimersCheckbox = AceGUI:Create("CheckBox")
    plusTimersCheckbox:SetLabel("Show +2/+3 Timers")
    plusTimersCheckbox:SetWidth(200)
    plusTimersCheckbox:SetValue(VUI.db.profile.modules.angrykeystone.showPlusTimers)
    plusTimersCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.angrykeystone.showPlusTimers = value
    end)
    timerGroup:AddChild(plusTimersCheckbox)
    
    -- Show death counter
    local deathCounterCheckbox = AceGUI:Create("CheckBox")
    deathCounterCheckbox:SetLabel("Show Death Counter")
    deathCounterCheckbox:SetWidth(200)
    deathCounterCheckbox:SetValue(VUI.db.profile.modules.angrykeystone.showDeathCounter)
    deathCounterCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.angrykeystone.showDeathCounter = value
    end)
    timerGroup:AddChild(deathCounterCheckbox)
    
    -- Color coding
    local colorCodingCheckbox = AceGUI:Create("CheckBox")
    colorCodingCheckbox:SetLabel("Color Code Timer")
    colorCodingCheckbox:SetWidth(200)
    colorCodingCheckbox:SetValue(VUI.db.profile.modules.angrykeystone.colorCodeTimer)
    colorCodingCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.angrykeystone.colorCodeTimer = value
    end)
    timerGroup:AddChild(colorCodingCheckbox)
    
    -- Chest colors group
    local chestColorsGroup = AceGUI:Create("InlineGroup")
    chestColorsGroup:SetTitle("Chest Time Colors")
    chestColorsGroup:SetLayout("Flow")
    chestColorsGroup:SetFullWidth(true)
    chestColorsGroup:SetDisabled(not VUI.db.profile.modules.angrykeystone.colorCodeTimer)
    container:AddChild(chestColorsGroup)
    
    -- +3 Chest color
    local plus3ColorPicker = AceGUI:Create("ColorPicker")
    plus3ColorPicker:SetLabel("+3 Chest Color")
    plus3ColorPicker:SetWidth(200)
    plus3ColorPicker:SetColor(
        VUI.db.profile.modules.angrykeystone.plus3Color.r or 0,
        VUI.db.profile.modules.angrykeystone.plus3Color.g or 1,
        VUI.db.profile.modules.angrykeystone.plus3Color.b or 0,
        VUI.db.profile.modules.angrykeystone.plus3Color.a or 1
    )
    plus3ColorPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
        VUI.db.profile.modules.angrykeystone.plus3Color = {r = r, g = g, b = b, a = a}
    end)
    chestColorsGroup:AddChild(plus3ColorPicker)
    
    -- +2 Chest color
    local plus2ColorPicker = AceGUI:Create("ColorPicker")
    plus2ColorPicker:SetLabel("+2 Chest Color")
    plus2ColorPicker:SetWidth(200)
    plus2ColorPicker:SetColor(
        VUI.db.profile.modules.angrykeystone.plus2Color.r or 1,
        VUI.db.profile.modules.angrykeystone.plus2Color.g or 1,
        VUI.db.profile.modules.angrykeystone.plus2Color.b or 0,
        VUI.db.profile.modules.angrykeystone.plus2Color.a or 1
    )
    plus2ColorPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
        VUI.db.profile.modules.angrykeystone.plus2Color = {r = r, g = g, b = b, a = a}
    end)
    chestColorsGroup:AddChild(plus2ColorPicker)
    
    -- +1 Chest color
    local plus1ColorPicker = AceGUI:Create("ColorPicker")
    plus1ColorPicker:SetLabel("+1 Chest Color")
    plus1ColorPicker:SetWidth(200)
    plus1ColorPicker:SetColor(
        VUI.db.profile.modules.angrykeystone.plus1Color.r or 1,
        VUI.db.profile.modules.angrykeystone.plus1Color.g or 1,
        VUI.db.profile.modules.angrykeystone.plus1Color.b or 1,
        VUI.db.profile.modules.angrykeystone.plus1Color.a or 1
    )
    plus1ColorPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
        VUI.db.profile.modules.angrykeystone.plus1Color = {r = r, g = g, b = b, a = a}
    end)
    chestColorsGroup:AddChild(plus1ColorPicker)
    
    -- Overtime color
    local overtimeColorPicker = AceGUI:Create("ColorPicker")
    overtimeColorPicker:SetLabel("Overtime Color")
    overtimeColorPicker:SetWidth(200)
    overtimeColorPicker:SetColor(
        VUI.db.profile.modules.angrykeystone.overtimeColor.r or 1,
        VUI.db.profile.modules.angrykeystone.overtimeColor.g or 0,
        VUI.db.profile.modules.angrykeystone.overtimeColor.b or 0,
        VUI.db.profile.modules.angrykeystone.overtimeColor.a or 1
    )
    overtimeColorPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
        VUI.db.profile.modules.angrykeystone.overtimeColor = {r = r, g = g, b = b, a = a}
    end)
    chestColorsGroup:AddChild(overtimeColorPicker)
    
    -- Update disabled state when color coding is toggled
    colorCodingCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.angrykeystone.colorCodeTimer = value
        chestColorsGroup:SetDisabled(not value)
    end)
end

-- Get options for the config panel
function AngryKeystones:GetOptions()
    return {
        type = "group",
        name = "Angry Keystones",
        args = {
            enable = {
                type = "toggle",
                name = "Enable",
                desc = "Enable or disable the Angry Keystones module",
                order = 1,
                get = function() return VUI:IsModuleEnabled("angrykeystone") end,
                set = function(_, value)
                    if value then
                        VUI:EnableModule("angrykeystone")
                    else
                        VUI:DisableModule("angrykeystone")
                    end
                end,
            },
            general = {
                type = "group",
                name = "General Settings",
                order = 2,
                inline = true,
                disabled = function() return not VUI:IsModuleEnabled("angrykeystone") end,
                args = {
                    showKeystoneInfo = {
                        type = "toggle",
                        name = "Show Keystone Info",
                        desc = "Show enhanced keystone information",
                        order = 1,
                        get = function() return VUI.db.profile.modules.angrykeystone.showKeystoneInfo end,
                        set = function(_, value)
                            VUI.db.profile.modules.angrykeystone.showKeystoneInfo = value
                        end,
                    },
                    showScheduleInfo = {
                        type = "toggle",
                        name = "Show Affix Schedule",
                        desc = "Show the affix rotation schedule",
                        order = 2,
                        get = function() return VUI.db.profile.modules.angrykeystone.showScheduleInfo end,
                        set = function(_, value)
                            VUI.db.profile.modules.angrykeystone.showScheduleInfo = value
                        end,
                    },
                    timeEstimates = {
                        type = "toggle",
                        name = "Show Time Estimates",
                        desc = "Show estimated completion times based on your history",
                        order = 3,
                        get = function() return VUI.db.profile.modules.angrykeystone.timeEstimates end,
                        set = function(_, value)
                            VUI.db.profile.modules.angrykeystone.timeEstimates = value
                        end,
                    }
                }
            },
            progress = {
                type = "group",
                name = "Progress Tracker",
                order = 3,
                inline = true,
                disabled = function() return not VUI:IsModuleEnabled("angrykeystone") end,
                args = {
                    showProgressTracker = {
                        type = "toggle",
                        name = "Show Progress Tracker",
                        desc = "Show the enemy forces progress tracker",
                        order = 1,
                        get = function() return VUI.db.profile.modules.angrykeystone.showProgressTracker end,
                        set = function(_, value)
                            VUI.db.profile.modules.angrykeystone.showProgressTracker = value
                        end,
                    },
                    detailedProgress = {
                        type = "toggle",
                        name = "Show Detailed Progress",
                        desc = "Show detailed enemy forces progress",
                        order = 2,
                        get = function() return VUI.db.profile.modules.angrykeystone.detailedProgress end,
                        set = function(_, value)
                            VUI.db.profile.modules.angrykeystone.detailedProgress = value
                        end,
                    }
                }
            },
            timer = {
                type = "group",
                name = "Timer",
                order = 4,
                inline = true,
                disabled = function() return not VUI:IsModuleEnabled("angrykeystone") end,
                args = {
                    showTimer = {
                        type = "toggle",
                        name = "Show Timer",
                        desc = "Show the challenge mode timer",
                        order = 1,
                        get = function() return VUI.db.profile.modules.angrykeystone.showTimer end,
                        set = function(_, value)
                            VUI.db.profile.modules.angrykeystone.showTimer = value
                        end,
                    },
                    showPlusTimers = {
                        type = "toggle",
                        name = "Show +2/+3 Timers",
                        desc = "Show the timers for +2 and +3 key upgrades",
                        order = 2,
                        get = function() return VUI.db.profile.modules.angrykeystone.showPlusTimers end,
                        set = function(_, value)
                            VUI.db.profile.modules.angrykeystone.showPlusTimers = value
                        end,
                    }
                }
            }
        }
    }
end