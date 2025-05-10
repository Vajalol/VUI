-- VUIScrollingText Options
local _, VUI = ...
local MSBTOptions = {}
local VUIScrollingText = VUI:GetModule("VUIScrollingText")

-- Global references for "globals" used in callbacks.
local currentTab
local tabFrames = {}
local dropdownFrames = {}
local controlFrames = {}
local fontstring_table = {}
local DROPDOWN_FRAME_LEVEL = 2
local POPUP_MENU_LEVEL = 3
local DEFAULT_TAB_WIDTH = 130

-- Import from MSBTOptions
local function DisableControls(controls, disable)
    if (not controls) then return end
    for name, frame in pairs(controls) do
        if (frame.Disable) then frame:Disable(disable) end
        if (name == "dropdown") then UIDropDownMenu_DisableDropDown(frame) end
        if (name == "slider") then
            local sliderName = frame:GetName()
            _G[sliderName .. "Text"]:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, disable and 0.5 or 1.0)
            _G[sliderName .. "Low"]:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, disable and 0.5 or 1.0)
            _G[sliderName .. "High"]:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, disable and 0.5 or 1.0)
        end
    end
end

-- Create VUI integrated options page
function VUIScrollingText:CreateOptionsFrame()
    local optionsFrame = CreateFrame("Frame", "VUIScrollingTextOptions", UIParent, "BackdropTemplate")
    optionsFrame:Hide()
    optionsFrame:SetWidth(615)
    optionsFrame:SetHeight(550)
    optionsFrame:SetFrameStrata("MEDIUM")
    optionsFrame:SetToplevel(true)
    optionsFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    optionsFrame:SetPoint("CENTER")
    optionsFrame:EnableMouse(true)
    optionsFrame:SetMovable(true)
    optionsFrame:RegisterForDrag("LeftButton")
    optionsFrame:SetScript("OnDragStart", optionsFrame.StartMoving)
    optionsFrame:SetScript("OnDragStop", optionsFrame.StopMovingOrSizing)
    
    -- Create title
    local title = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -20)
    title:SetText("VUI Scrolling Text Options")
    
    -- Create close button
    local closeButton = CreateFrame("Button", nil, optionsFrame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", -5, -5)
    
    -- Create main tab panel
    local tabContainerFrame = CreateFrame("Frame", "VUIScrollingTextOptionsTabContainer", optionsFrame)
    tabContainerFrame:SetWidth(optionsFrame:GetWidth() - 25)
    tabContainerFrame:SetHeight(optionsFrame:GetHeight() - 55)
    tabContainerFrame:SetPoint("TOP", 0, -40)
    
    -- Create tabs
    self:CreateTabs(tabContainerFrame, {
        { name = "General", tooltip = "General Options" },
        { name = "ScrollAreas", tooltip = "Configure Scrolling Text Areas" },
        { name = "Events", tooltip = "Event Configuration" },
        { name = "Animations", tooltip = "Animation Settings" },
        { name = "Triggers", tooltip = "Trigger Configuration" },
        { name = "Profiles", tooltip = "Profile Management" },
    })
    
    return optionsFrame
end

function VUIScrollingText:CreateTabs(tabContainerFrame, tabInfo)
    -- Create tab frames first.
    for index, info in ipairs(tabInfo) do
        local name = info.name
        local tabFrame = CreateFrame("Frame", "VUIScrollingTextOptions" .. name .. "Tab", tabContainerFrame)
        tabFrame:SetWidth(tabContainerFrame:GetWidth() - 30)
        tabFrame:SetHeight(tabContainerFrame:GetHeight() - 30)
        tabFrame:SetPoint("TOPLEFT", 15, -15)
        tabFrame:Hide()
        tabFrames[name] = tabFrame
        
        -- Populate each tab with appropriate content
        self:PopulateTab(name, tabFrame)
    end
    
    -- Create tab buttons.
    for index, info in ipairs(tabInfo) do
        local name = info.name
        local tabButton = CreateFrame("Button", "VUIScrollingTextOptions" .. name .. "TabButton", tabContainerFrame, "OptionsFrameTabButtonTemplate")
        tabButton.name = name
        tabButton.tooltip = info.tooltip
        tabButton:SetID(index)
        
        if (index == 1) then
            tabButton:SetPoint("TOPLEFT", tabContainerFrame, "BOTTOMLEFT", 0, 1)
        else
            tabButton:SetPoint("LEFT", "VUIScrollingTextOptions" .. tabInfo[index-1].name .. "TabButton", "RIGHT", -16, 0)
        end
        
        tabButton:SetText(name)
        tabButton:SetScript("OnClick", function(self)
            VUIScrollingText:ChangeTab(self.name)
        end)
        
        -- Calculate width
        local textWidth = tabButton:GetFontString():GetStringWidth()
        if textWidth > DEFAULT_TAB_WIDTH then
            PanelTemplates_TabResize(tabButton, 0, nil, DEFAULT_TAB_WIDTH)
        end
    end
    
    -- Show first tab initially.
    self:ChangeTab(tabInfo[1].name)
end

function VUIScrollingText:ChangeTab(tabName)
    -- Hide all tabs and show the selected one.
    for name, frame in pairs(tabFrames) do
        if name == tabName then
            frame:Show()
            _G["VUIScrollingTextOptions" .. name .. "TabButton"]:SetChecked(true)
            currentTab = name
        else
            frame:Hide()
            _G["VUIScrollingTextOptions" .. name .. "TabButton"]:SetChecked(false)
        end
    end
end

function VUIScrollingText:PopulateTab(tabName, tabFrame)
    if tabName == "General" then
        self:CreateGeneralTab(tabFrame)
    elseif tabName == "ScrollAreas" then
        self:CreateScrollAreasTab(tabFrame)
    elseif tabName == "Events" then
        self:CreateEventsTab(tabFrame)
    elseif tabName == "Animations" then
        self:CreateAnimationsTab(tabFrame)
    elseif tabName == "Triggers" then
        self:CreateTriggersTab(tabFrame)
    elseif tabName == "Profiles" then
        self:CreateProfilesTab(tabFrame)
    end
end

function VUIScrollingText:CreateGeneralTab(tabFrame)
    -- Font section
    local fontSection = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    fontSection:SetPoint("TOPLEFT", 10, -15)
    fontSection:SetText("Font Settings")
    
    -- Font dropdown
    local fontDropdown = CreateFrame("Frame", "VUIScrollingTextFontDropdown", tabFrame, "UIDropDownMenuTemplate")
    fontDropdown:SetPoint("TOPLEFT", fontSection, "BOTTOMLEFT", -15, -10)
    UIDropDownMenu_SetWidth(fontDropdown, 200)
    UIDropDownMenu_SetText(fontDropdown, "Select Font")
    
    -- Font size slider
    local fontSizeSlider = CreateFrame("Slider", "VUIScrollingTextFontSizeSlider", tabFrame, "OptionsSliderTemplate")
    fontSizeSlider:SetPoint("TOPLEFT", fontDropdown, "BOTTOMLEFT", 15, -30)
    fontSizeSlider:SetMinMaxValues(8, 32)
    fontSizeSlider:SetValueStep(1)
    fontSizeSlider:SetObeyStepOnDrag(true)
    fontSizeSlider:SetValue(16)
    fontSizeSlider:SetWidth(200)
    
    local sliderName = fontSizeSlider:GetName()
    _G[sliderName .. "Text"]:SetText("Font Size: " .. fontSizeSlider:GetValue())
    _G[sliderName .. "Low"]:SetText("8")
    _G[sliderName .. "High"]:SetText("32")
    
    fontSizeSlider:SetScript("OnValueChanged", function(self, value)
        _G[self:GetName() .. "Text"]:SetText("Font Size: " .. math.floor(value))
    end)
    
    -- Output section
    local outputSection = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    outputSection:SetPoint("TOPLEFT", fontSizeSlider, "BOTTOMLEFT", -15, -30)
    outputSection:SetText("Output Settings")
    
    -- Create checkboxes for output settings
    local checkboxSettings = {
        { text = "Show Damage", tooltip = "Show damage numbers" },
        { text = "Show Healing", tooltip = "Show healing numbers" },
        { text = "Show Procs", tooltip = "Show ability procs" },
        { text = "Merge Similar", tooltip = "Merge similar messages" },
    }
    
    local lastCheckbox
    for i, setting in ipairs(checkboxSettings) do
        local checkbox = CreateFrame("CheckButton", "VUIScrollingText" .. setting.text:gsub(" ", "") .. "Checkbox", tabFrame, "OptionsCheckButtonTemplate")
        
        if i == 1 then
            checkbox:SetPoint("TOPLEFT", outputSection, "BOTTOMLEFT", 0, -10)
        else
            checkbox:SetPoint("TOPLEFT", lastCheckbox, "BOTTOMLEFT", 0, -5)
        end
        
        _G[checkbox:GetName() .. "Text"]:SetText(setting.text)
        checkbox.tooltipText = setting.tooltip
        
        lastCheckbox = checkbox
    end
end

function VUIScrollingText:CreateScrollAreasTab(tabFrame)
    -- Add scroll area section
    local scrollAreaSection = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    scrollAreaSection:SetPoint("TOPLEFT", 10, -15)
    scrollAreaSection:SetText("Scroll Areas")
    
    -- Create new scroll area button
    local newAreaButton = CreateFrame("Button", "VUIScrollingTextNewAreaButton", tabFrame, "UIPanelButtonTemplate")
    newAreaButton:SetSize(150, 22)
    newAreaButton:SetPoint("TOPLEFT", scrollAreaSection, "BOTTOMLEFT", 0, -10)
    newAreaButton:SetText("New Scroll Area")
    
    -- Scroll area list
    local scrollFrame = CreateFrame("ScrollFrame", "VUIScrollingTextScrollAreaList", tabFrame, "FauxScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", newAreaButton, "BOTTOMLEFT", 0, -10)
    scrollFrame:SetPoint("BOTTOMRIGHT", tabFrame, "BOTTOMRIGHT", -30, 10)
    
    -- Create area settings panel
    local settingsPanel = CreateFrame("Frame", "VUIScrollingTextAreaSettings", tabFrame, "BackdropTemplate")
    settingsPanel:SetSize(350, 450)
    settingsPanel:SetPoint("TOPRIGHT", tabFrame, "TOPRIGHT", -10, -35)
    settingsPanel:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 16,
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    })
    
    -- Area settings title
    local settingsTitle = settingsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    settingsTitle:SetPoint("TOP", 0, -15)
    settingsTitle:SetText("Scroll Area Settings")
    
    -- Area position controls
    local posLabel = settingsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    posLabel:SetPoint("TOPLEFT", 15, -40)
    posLabel:SetText("Position")
    
    local posX = CreateFrame("EditBox", "VUIScrollingTextPosXEdit", settingsPanel, "InputBoxTemplate")
    posX:SetSize(50, 20)
    posX:SetPoint("TOPLEFT", posLabel, "BOTTOMLEFT", 5, -5)
    posX:SetAutoFocus(false)
    posX:SetNumeric(true)
    
    local posY = CreateFrame("EditBox", "VUIScrollingTextPosYEdit", settingsPanel, "InputBoxTemplate")
    posY:SetSize(50, 20)
    posY:SetPoint("LEFT", posX, "RIGHT", 10, 0)
    posY:SetAutoFocus(false)
    posY:SetNumeric(true)
    
    -- Area size controls
    local sizeLabel = settingsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sizeLabel:SetPoint("TOPLEFT", posLabel, "BOTTOMLEFT", 0, -30)
    sizeLabel:SetText("Size")
    
    local width = CreateFrame("EditBox", "VUIScrollingTextWidthEdit", settingsPanel, "InputBoxTemplate")
    width:SetSize(50, 20)
    width:SetPoint("TOPLEFT", sizeLabel, "BOTTOMLEFT", 5, -5)
    width:SetAutoFocus(false)
    width:SetNumeric(true)
    
    local height = CreateFrame("EditBox", "VUIScrollingTextHeightEdit", settingsPanel, "InputBoxTemplate")
    height:SetSize(50, 20)
    height:SetPoint("LEFT", width, "RIGHT", 10, 0)
    height:SetAutoFocus(false)
    height:SetNumeric(true)
    
    -- Hide settings panel by default
    settingsPanel:Hide()
end

function VUIScrollingText:CreateEventsTab(tabFrame)
    -- Events section
    local eventsSection = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    eventsSection:SetPoint("TOPLEFT", 10, -15)
    eventsSection:SetText("Event Configuration")
    
    -- Event categories
    local categories = {
        { name = "Outgoing", desc = "Outgoing damage/healing events" },
        { name = "Incoming", desc = "Incoming damage/healing events" },
        { name = "Notification", desc = "System notifications and alerts" },
    }
    
    local categoryButtons = {}
    for i, category in ipairs(categories) do
        local button = CreateFrame("Button", "VUIScrollingText" .. category.name .. "Button", tabFrame)
        button:SetSize(150, 30)
        
        if i == 1 then
            button:SetPoint("TOPLEFT", eventsSection, "BOTTOMLEFT", 10, -10)
        else
            button:SetPoint("TOPLEFT", categoryButtons[i-1], "BOTTOMLEFT", 0, -5)
        end
        
        button:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
        
        local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("LEFT", 10, 0)
        text:SetText(category.name)
        
        table.insert(categoryButtons, button)
    end
    
    -- Event list panel
    local eventPanel = CreateFrame("Frame", "VUIScrollingTextEventPanel", tabFrame, "BackdropTemplate")
    eventPanel:SetSize(400, 450)
    eventPanel:SetPoint("TOPRIGHT", tabFrame, "TOPRIGHT", -10, -35)
    eventPanel:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 16,
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    })
    
    -- Event panel title
    local panelTitle = eventPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    panelTitle:SetPoint("TOP", 0, -15)
    panelTitle:SetText("Select Event Type")
end

function VUIScrollingText:CreateAnimationsTab(tabFrame)
    -- Animations section
    local animSection = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    animSection:SetPoint("TOPLEFT", 10, -15)
    animSection:SetText("Animation Settings")
    
    -- Animation styles dropdown
    local styleDropdown = CreateFrame("Frame", "VUIScrollingTextAnimStyleDropdown", tabFrame, "UIDropDownMenuTemplate")
    styleDropdown:SetPoint("TOPLEFT", animSection, "BOTTOMLEFT", -15, -10)
    UIDropDownMenu_SetWidth(styleDropdown, 200)
    UIDropDownMenu_SetText(styleDropdown, "Select Animation Style")
    
    -- Preview area
    local previewFrame = CreateFrame("Frame", "VUIScrollingTextAnimPreview", tabFrame, "BackdropTemplate")
    previewFrame:SetSize(300, 200)
    previewFrame:SetPoint("TOP", tabFrame, "TOP", 0, -100)
    previewFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    
    -- Preview label
    local previewLabel = previewFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    previewLabel:SetPoint("TOP", 0, -10)
    previewLabel:SetText("Animation Preview")
    
    -- Preview button
    local previewButton = CreateFrame("Button", "VUIScrollingTextPreviewButton", tabFrame, "UIPanelButtonTemplate")
    previewButton:SetSize(100, 22)
    previewButton:SetPoint("TOP", previewFrame, "BOTTOM", 0, -10)
    previewButton:SetText("Preview")
    
    -- Animation settings
    local settingsFrame = CreateFrame("Frame", "VUIScrollingTextAnimSettings", tabFrame)
    settingsFrame:SetSize(tabFrame:GetWidth() - 30, 150)
    settingsFrame:SetPoint("BOTTOM", tabFrame, "BOTTOM", 0, 20)
    
    -- Speed slider
    local speedSlider = CreateFrame("Slider", "VUIScrollingTextSpeedSlider", settingsFrame, "OptionsSliderTemplate")
    speedSlider:SetPoint("TOPLEFT", 15, -30)
    speedSlider:SetMinMaxValues(0.5, 3.0)
    speedSlider:SetValueStep(0.1)
    speedSlider:SetObeyStepOnDrag(true)
    speedSlider:SetValue(1.0)
    speedSlider:SetWidth(200)
    
    local sliderName = speedSlider:GetName()
    _G[sliderName .. "Text"]:SetText("Animation Speed: " .. speedSlider:GetValue())
    _G[sliderName .. "Low"]:SetText("Slow")
    _G[sliderName .. "High"]:SetText("Fast")
    
    speedSlider:SetScript("OnValueChanged", function(self, value)
        _G[self:GetName() .. "Text"]:SetText("Animation Speed: " .. string.format("%.1f", value))
    end)
    
    -- Fade settings
    local fadeCheck = CreateFrame("CheckButton", "VUIScrollingTextFadeCheck", settingsFrame, "OptionsCheckButtonTemplate")
    fadeCheck:SetPoint("TOPLEFT", speedSlider, "BOTTOMLEFT", 0, -20)
    _G[fadeCheck:GetName() .. "Text"]:SetText("Enable Fade")
end

function VUIScrollingText:CreateTriggersTab(tabFrame)
    -- Triggers section
    local triggerSection = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    triggerSection:SetPoint("TOPLEFT", 10, -15)
    triggerSection:SetText("Trigger Configuration")
    
    -- Trigger list
    local triggerList = CreateFrame("Frame", "VUIScrollingTextTriggerList", tabFrame, "BackdropTemplate")
    triggerList:SetSize(200, 450)
    triggerList:SetPoint("TOPLEFT", triggerSection, "BOTTOMLEFT", 0, -10)
    triggerList:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    
    -- Add trigger button
    local addButton = CreateFrame("Button", "VUIScrollingTextAddTriggerButton", tabFrame, "UIPanelButtonTemplate")
    addButton:SetSize(100, 22)
    addButton:SetPoint("BOTTOMLEFT", triggerList, "BOTTOMLEFT", 10, 10)
    addButton:SetText("Add Trigger")
    
    -- Trigger settings panel
    local settingsPanel = CreateFrame("Frame", "VUIScrollingTextTriggerSettings", tabFrame, "BackdropTemplate")
    settingsPanel:SetSize(350, 450)
    settingsPanel:SetPoint("TOPRIGHT", tabFrame, "TOPRIGHT", -10, -35)
    settingsPanel:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 16,
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    })
    
    -- Settings title
    local settingsTitle = settingsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    settingsTitle:SetPoint("TOP", 0, -15)
    settingsTitle:SetText("Trigger Settings")
    
    -- Trigger type dropdown
    local typeLabel = settingsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    typeLabel:SetPoint("TOPLEFT", 15, -40)
    typeLabel:SetText("Trigger Type:")
    
    local typeDropdown = CreateFrame("Frame", "VUIScrollingTextTriggerTypeDropdown", settingsPanel, "UIDropDownMenuTemplate")
    typeDropdown:SetPoint("TOPLEFT", typeLabel, "BOTTOMLEFT", -15, -5)
    UIDropDownMenu_SetWidth(typeDropdown, 200)
    
    -- Pattern input
    local patternLabel = settingsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    patternLabel:SetPoint("TOPLEFT", typeDropdown, "BOTTOMLEFT", 15, -15)
    patternLabel:SetText("Pattern:")
    
    local patternEdit = CreateFrame("EditBox", "VUIScrollingTextPatternEdit", settingsPanel, "InputBoxTemplate")
    patternEdit:SetSize(250, 20)
    patternEdit:SetPoint("TOPLEFT", patternLabel, "BOTTOMLEFT", 5, -5)
    patternEdit:SetAutoFocus(false)
    
    -- Action section
    local actionLabel = settingsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    actionLabel:SetPoint("TOPLEFT", patternEdit, "BOTTOMLEFT", -5, -20)
    actionLabel:SetText("Action:")
    
    -- Hide settings panel by default
    settingsPanel:Hide()
end

function VUIScrollingText:CreateProfilesTab(tabFrame)
    -- Profiles section
    local profilesSection = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    profilesSection:SetPoint("TOPLEFT", 10, -15)
    profilesSection:SetText("Profile Management")
    
    -- Current profile
    local currentLabel = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    currentLabel:SetPoint("TOPLEFT", profilesSection, "BOTTOMLEFT", 5, -15)
    currentLabel:SetText("Current Profile:")
    
    local currentProfile = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    currentProfile:SetPoint("LEFT", currentLabel, "RIGHT", 5, 0)
    currentProfile:SetText("Default")
    
    -- Profile list frame
    local listFrame = CreateFrame("Frame", "VUIScrollingTextProfileList", tabFrame, "BackdropTemplate")
    listFrame:SetSize(200, 350)
    listFrame:SetPoint("TOPLEFT", currentLabel, "BOTTOMLEFT", 0, -15)
    listFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    
    -- List title
    local listTitle = listFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    listTitle:SetPoint("TOP", 0, -10)
    listTitle:SetText("Available Profiles")
    
    -- Profile buttons
    local newButton = CreateFrame("Button", "VUIScrollingTextNewProfileButton", tabFrame, "UIPanelButtonTemplate")
    newButton:SetSize(90, 22)
    newButton:SetPoint("TOPLEFT", listFrame, "BOTTOMLEFT", 10, -10)
    newButton:SetText("New")
    
    local copyButton = CreateFrame("Button", "VUIScrollingTextCopyProfileButton", tabFrame, "UIPanelButtonTemplate")
    copyButton:SetSize(90, 22)
    copyButton:SetPoint("LEFT", newButton, "RIGHT", 10, 0)
    copyButton:SetText("Copy")
    
    -- Profile details frame
    local detailsFrame = CreateFrame("Frame", "VUIScrollingTextProfileDetails", tabFrame, "BackdropTemplate")
    detailsFrame:SetSize(350, 350)
    detailsFrame:SetPoint("TOPRIGHT", tabFrame, "TOPRIGHT", -10, -35)
    detailsFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 16,
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    })
    
    -- Details title
    local detailsTitle = detailsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    detailsTitle:SetPoint("TOP", 0, -15)
    detailsTitle:SetText("Profile Details")
    
    -- Profile actions
    local renameButton = CreateFrame("Button", "VUIScrollingTextRenameProfileButton", detailsFrame, "UIPanelButtonTemplate")
    renameButton:SetSize(100, 22)
    renameButton:SetPoint("BOTTOMLEFT", 20, 15)
    renameButton:SetText("Rename")
    
    local deleteButton = CreateFrame("Button", "VUIScrollingTextDeleteProfileButton", detailsFrame, "UIPanelButtonTemplate")
    deleteButton:SetSize(100, 22)
    deleteButton:SetPoint("LEFT", renameButton, "RIGHT", 10, 0)
    deleteButton:SetText("Delete")
    
    local resetButton = CreateFrame("Button", "VUIScrollingTextResetProfileButton", detailsFrame, "UIPanelButtonTemplate")
    resetButton:SetSize(100, 22)
    resetButton:SetPoint("LEFT", deleteButton, "RIGHT", 10, 0)
    resetButton:SetText("Reset")
end

-- Register the options panel with VUI
function VUIScrollingText:RegisterOptions()
    -- Create options frame
    local optionsFrame = self:CreateOptionsFrame()
    
    -- Add to VUI configuration
    VUI.Config:RegisterModuleOptions("VUIScrollingText", function()
        optionsFrame:Show()
    end)
    
    -- Add slash command handler
    self:RegisterChatCommand("vuiscroll", function()
        optionsFrame:Show()
    end)
end