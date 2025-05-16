-- SettingsFrameInit.lua
-- Safely initializes VUICD settings frames

-- Use global reference pattern to avoid load order issues
_G["VUICD"] = _G["VUICD"] or {}
local VUICD = _G["VUICD"]

-- Ensure Frames module is initialized
VUICD.Frames = VUICD.Frames or {}

-- Get localization through global reference or fallback
local L = VUICD.L or {}

-- Helper function to safely get localized text
local function GetLocalizedText(key, default)
    return (L and L[key]) or default or key
end

-- Initialize the settings frame
function VUICD.Frames:InitSettingsFrame()
    -- Check if the frame already exists
    if self.settingsFrame then
        return self.settingsFrame
    end
    
    -- Create the settings frame
    local frame = CreateFrame("Frame", "VUICD_SettingsFrame", UIParent)
    frame:SetSize(800, 600)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("HIGH")
    frame:Hide()
    
    -- Add title
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 20, -20)
    title:SetText(GetLocalizedText("VUICD Settings", "VUICD Settings"))
    
    -- Add close button
    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", -5, -5)
    
    -- Make the frame movable
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    
    -- Store the frame reference
    self.settingsFrame = frame
    
    -- Initialize tabs if needed
    self:InitSettingsTabs()
    
    return frame
end

-- Initialize settings tabs
function VUICD.Frames:InitSettingsTabs()
    local frame = self.settingsFrame
    if not frame then return end
    
    -- Create tab container
    frame.tabs = {}
    frame.tabFrames = {}
    
    -- Define tabs
    local tabs = {
        {name = GetLocalizedText("General", "General"), id = "general"},
        {name = GetLocalizedText("Party", "Party"), id = "party"},
        {name = GetLocalizedText("Raid", "Raid"), id = "raid"},
        {name = GetLocalizedText("Extra Bars", "Extra Bars"), id = "extrabars"},
        {name = GetLocalizedText("Profiles", "Profiles"), id = "profiles"}
    }
    
    -- Create tab buttons
    for i, tab in ipairs(tabs) do
        local tabButton = CreateFrame("Button", "VUICD_SettingsTab" .. i, frame, "CharacterFrameTabButtonTemplate")
        tabButton:SetID(i)
        tabButton:SetText(tab.name)
        tabButton:SetScript("OnClick", function()
            self:SelectTab(i)
        end)
        
        -- Position the tab
        if i == 1 then
            tabButton:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 20, 0)
        else
            tabButton:SetPoint("LEFT", frame.tabs[i-1], "RIGHT", -15, 0)
        end
        
        -- Create content frame
        local contentFrame = CreateFrame("Frame", "VUICD_SettingsTabContent" .. i, frame)
        contentFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -50)
        contentFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -20, 20)
        contentFrame:Hide()
        
        -- Store references
        frame.tabs[i] = tabButton
        frame.tabFrames[i] = contentFrame
        
        -- Store tab ID for easier access
        contentFrame.tabID = tab.id
    end
    
    -- Initialize first tab
    if #frame.tabs > 0 then
        self:SelectTab(1)
    end
end

-- Select a tab
function VUICD.Frames:SelectTab(tabIndex)
    local frame = self.settingsFrame
    if not frame or not frame.tabs or not frame.tabFrames then return end
    
    -- Hide all tab content frames
    for _, contentFrame in ipairs(frame.tabFrames) do
        contentFrame:Hide()
    end
    
    -- Update tab appearance
    for i, tabButton in ipairs(frame.tabs) do
        if i == tabIndex then
            PanelTemplates_SelectTab(tabButton)
            frame.tabFrames[i]:Show()
            
            -- Initialize tab content if needed
            if frame.tabFrames[i].tabID and not frame.tabFrames[i].initialized then
                self:InitTabContent(frame.tabFrames[i])
            end
        else
            PanelTemplates_DeselectTab(tabButton)
        end
    end
end

-- Initialize tab content
function VUICD.Frames:InitTabContent(contentFrame)
    if not contentFrame or not contentFrame.tabID then return end
    
    -- Mark as initialized
    contentFrame.initialized = true
    
    -- Create content based on tab ID
    local tabID = contentFrame.tabID
    
    if tabID == "general" then
        self:InitGeneralTab(contentFrame)
    elseif tabID == "party" then
        self:InitPartyTab(contentFrame)
    elseif tabID == "raid" then
        self:InitRaidTab(contentFrame)
    elseif tabID == "extrabars" then
        self:InitExtraBarsTab(contentFrame)
    elseif tabID == "profiles" then
        self:InitProfilesTab(contentFrame)
    end
end

-- Initialize general tab
function VUICD.Frames:InitGeneralTab(contentFrame)
    -- Create a title
    local title = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 10, -10)
    title:SetText(GetLocalizedText("General Settings", "General Settings"))
    
    -- Create a description
    local desc = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10)
    desc:SetText(GetLocalizedText("Configure the general addon settings", "Configure the general addon settings"))
    
    -- Add settings controls here
    -- This is just a placeholder for a more complete implementation
end

-- Initialize party tab
function VUICD.Frames:InitPartyTab(contentFrame)
    -- Create a title
    local title = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 10, -10)
    title:SetText(GetLocalizedText("Party Settings", "Party Settings"))
    
    -- Create a description
    local desc = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10)
    desc:SetText(GetLocalizedText("Configure party frame settings", "Configure party frame settings"))
    
    -- Add settings controls here
    -- This is just a placeholder for a more complete implementation
end

-- Initialize raid tab
function VUICD.Frames:InitRaidTab(contentFrame)
    -- Create a title
    local title = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 10, -10)
    title:SetText(GetLocalizedText("Raid Settings", "Raid Settings"))
    
    -- Create a description
    local desc = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10)
    desc:SetText(GetLocalizedText("Configure raid frame settings", "Configure raid frame settings"))
    
    -- Add settings controls here
    -- This is just a placeholder for a more complete implementation
end

-- Initialize extra bars tab
function VUICD.Frames:InitExtraBarsTab(contentFrame)
    -- Create a title
    local title = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 10, -10)
    title:SetText(GetLocalizedText("Extra Bars Settings", "Extra Bars Settings"))
    
    -- Create a description
    local desc = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10)
    desc:SetText(GetLocalizedText("Configure extra cooldown bars", "Configure extra cooldown bars"))
    
    -- Add settings controls here
    -- This is just a placeholder for a more complete implementation
end

-- Initialize profiles tab
function VUICD.Frames:InitProfilesTab(contentFrame)
    -- Create a title
    local title = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 10, -10)
    title:SetText(GetLocalizedText("Profile Settings", "Profile Settings"))
    
    -- Create a description
    local desc = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10)
    desc:SetText(GetLocalizedText("Manage your profiles", "Manage your profiles"))
    
    -- Add settings controls here
    -- This is just a placeholder for a more complete implementation
end

-- Function to show the settings frame
function VUICD.Frames:ShowSettingsFrame()
    if not self.settingsFrame then
        self:InitSettingsFrame()
    end
    
    self.settingsFrame:Show()
end

-- Function to hide the settings frame
function VUICD.Frames:HideSettingsFrame()
    if self.settingsFrame then
        self.settingsFrame:Hide()
    end
end

-- Initialize the settings frame when this file is loaded
VUICD.Frames:InitSettingsFrame() 