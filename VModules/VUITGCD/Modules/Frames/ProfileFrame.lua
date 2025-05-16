---@type string, Namespace
local _, ns = ...

---@class ProfileFrame
local profileFrame = {}
ns.profileFrame = profileFrame

---@param profile ProfileSettings
local function activateProfile(profile)
    ns.settings.activeProfile = profile
    ns.settings:Save()
    ns.settingsFrame:syncWithSettings()
    ns.blocklistFrame:syncWithSettings()
    ns.profileFrame:syncWithSettings()
end

local function deleteCurrentProfile()
    ns.settings:DeleteCurrentProfile()
    ns.settings:Save()
    ns.settingsFrame:syncWithSettings()
    ns.blocklistFrame:syncWithSettings()
    ns.profileFrame:syncWithSettings()
end

---@param name string
local function createNewProfile(name)
    ns.settings:CreateNewProfile(name)
    ns.settings:Save()
    ns.settingsFrame:syncWithSettings()
    ns.blocklistFrame:syncWithSettings()
    ns.profileFrame:syncWithSettings()
end

local frame = CreateFrame("Frame", nil, UIParent)
frame:Hide()
frame.name = "Profile"
frame.parent = "TrufiGCD"
ns.utils.interfaceOptions_AddCategory(frame)

-- Profile selector section
local profileSelectorText = frame:CreateFontString(nil, "OVERLAY")
profileSelectorText:SetFont(STANDARD_TEXT_FONT, 12)
profileSelectorText:SetText("Active profile:")
profileSelectorText:SetPoint("TOPLEFT", 10, -50)

-- Create profile buttons container
local profileButtonsContainer = CreateFrame("Frame", nil, frame)
profileButtonsContainer:SetPoint("TOPLEFT", 30, -70)
profileButtonsContainer:SetSize(200, 80)

-- Create scrollframe for profile buttons
local scrollFrame = CreateFrame("ScrollFrame", nil, profileButtonsContainer, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 0, 0)
scrollFrame:SetPoint("BOTTOMRIGHT", -25, 0)

local scrollChild = CreateFrame("Frame")
scrollFrame:SetScrollChild(scrollChild)
scrollChild:SetSize(175, 10) -- Height will be adjusted dynamically

-- Active profile display
local activeProfileText = frame:CreateFontString(nil, "OVERLAY")
activeProfileText:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
activeProfileText:SetTextColor(0, 1, 0)
activeProfileText:SetPoint("TOPLEFT", profileSelectorText, "TOPRIGHT", 10, 0)

local function updateProfileButtons()
    -- Clear existing buttons
    for _, child in pairs({scrollChild:GetChildren()}) do
        child:Hide()
        child:SetParent(nil)
    end
    
    -- Create new buttons
    local buttonHeight = 25
    local yOffset = 0
    local buttonWidth = 175
    
    -- Safety check
    if not ns.settings or not ns.settings.profiles then
        return
    end
    
    for i, profile in pairs(ns.settings.profiles) do
        if profile and type(profile) == "table" then
            local btn = CreateFrame("Button", nil, scrollChild, "UIPanelButtonTemplate")
            btn:SetSize(buttonWidth, buttonHeight)
            btn:SetPoint("TOPLEFT", 0, -yOffset)
            btn:SetText(profile.name or "Unnamed Profile")
            
            -- Highlight active profile
            if ns.settings.activeProfile == profile then
                btn:SetNormalFontObject("GameFontHighlight")
                btn:SetHighlightFontObject("GameFontHighlight")
            end
            
            btn:SetScript("OnClick", function()
                activateProfile(profile)
            end)
            
            yOffset = yOffset + buttonHeight + 2
        end
    end
    
    -- Update scrollchild height
    scrollChild:SetHeight(math.max(yOffset, 10))
end

-- delete confirm frame
local frameConfirmDelete = CreateFrame("Frame", "TrGCDframeConfirmDelete", frame, "TooltipBorderBackdropTemplate")
frameConfirmDelete:Hide()
frameConfirmDelete:SetPoint("TOP", -90, -90)
frameConfirmDelete:SetWidth(230)
frameConfirmDelete:SetHeight(60)
frameConfirmDelete:SetFrameLevel(10)

local frameConfirmDeleteTitle = frameConfirmDelete:CreateFontString(frameConfirmDelete:GetName() .. "Title", "BACKGROUND", "GameFontHighlightSmall")
frameConfirmDeleteTitle:SetPoint("BOTTOMLEFT", frameConfirmDelete, "TOPLEFT", 5, 0)

local textureConfirmDelete = frameConfirmDelete:CreateTexture(nil, "BACKGROUND")
textureConfirmDelete:SetAllPoints(frameConfirmDelete)
textureConfirmDelete:SetColorTexture(0, 0, 0)
textureConfirmDelete:SetAlpha(0.8)

local textConfirmDelete = frameConfirmDelete:CreateFontString(nil, "BACKGROUND")
textConfirmDelete:SetFont(STANDARD_TEXT_FONT, 12)
textConfirmDelete:SetText("Confirm delete")
textConfirmDelete:SetPoint("TOP", 0, -10)

local buttonConfirmDeleteYes = CreateFrame("Button", nil, frameConfirmDelete, "UIPanelButtonTemplate")
buttonConfirmDeleteYes:SetWidth(100)
buttonConfirmDeleteYes:SetHeight(22)
buttonConfirmDeleteYes:SetPoint("TOP", -55, -30)
buttonConfirmDeleteYes:SetText("Yes")
buttonConfirmDeleteYes:SetScript("OnClick", function()
    frameConfirmDelete:Hide()
    deleteCurrentProfile()
end)

local buttonConfirmDeleteNo = CreateFrame("Button", nil, frameConfirmDelete, "UIPanelButtonTemplate")
buttonConfirmDeleteNo:SetWidth(100)
buttonConfirmDeleteNo:SetHeight(22)
buttonConfirmDeleteNo:SetPoint("TOP", 55, -30)
buttonConfirmDeleteNo:SetText("No")
buttonConfirmDeleteNo:SetScript("OnClick", function()
    frameConfirmDelete:Hide()
end)

-- delete button
local buttonDelete = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
buttonDelete:SetWidth(100)
buttonDelete:SetHeight(22)
buttonDelete:SetPoint("TOPLEFT", 190, -53)
buttonDelete:SetText("Delete")
buttonDelete:SetScript("OnClick", function()
    if ns.utils.size(ns.settings.profiles) > 1 then
        frameConfirmDelete:Show()
    end
end)

if ns.utils.size(ns.settings.profiles) <= 1 then
    buttonDelete:Disable()
else
    buttonDelete:Enable()
end
ns.frameUtils.addTooltip(buttonDelete, "Delete", "Delete the currently active profile")

---@param name string
local function nameValid(name)
    return name and string.len(name) > 0
end

local editboxNewProfile = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
editboxNewProfile:SetWidth(160)
editboxNewProfile:SetHeight(20)
editboxNewProfile:SetPoint("TOPLEFT", 18, -160)
editboxNewProfile:SetAutoFocus(false)
editboxNewProfile:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
ns.frameUtils.addTooltip(editboxNewProfile, "New profile", "Copy the active profile settings to a new one")

local editboxNewProfileText = editboxNewProfile:CreateFontString(nil, "BACKGROUND")
editboxNewProfileText:SetFont(STANDARD_TEXT_FONT, 12)
editboxNewProfileText:SetText("New profile")
editboxNewProfileText:SetPoint("TOPLEFT", 7, 15)

local buttonCreateNew = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
buttonCreateNew:SetWidth(60)
buttonCreateNew:SetHeight(22)
buttonCreateNew:SetPoint("TOPLEFT", 175, -158)
buttonCreateNew:SetText("New")
buttonCreateNew:Disable()

local function onNewProfileSubmit()
    local name = editboxNewProfile:GetText()
    if nameValid(name) then
        createNewProfile(name)
        buttonCreateNew:Disable()
        editboxNewProfile:SetText("")
        editboxNewProfile:ClearFocus()
    end
end
buttonCreateNew:SetScript("OnClick", onNewProfileSubmit)
editboxNewProfile:SetScript("OnEnterPressed", onNewProfileSubmit)

editboxNewProfile:SetScript("OnTextChanged", function()
    local name = editboxNewProfile:GetText()
    if nameValid(name) then
        buttonCreateNew:Enable()
    else
        buttonCreateNew:Disable()
    end
end)

profileFrame.syncWithSettings = function()
    -- Update active profile text display
    if ns.settings and ns.settings.activeProfile and ns.settings.activeProfile.name then
        activeProfileText:SetText(ns.settings.activeProfile.name)
    else
        activeProfileText:SetText("Default")
    end
    
    -- Update profile buttons
    updateProfileButtons()

    if ns.utils and ns.utils.size and ns.settings and ns.settings.profiles then
        if ns.utils.size(ns.settings.profiles) <= 1 then
            buttonDelete:Disable()
        else
            buttonDelete:Enable()
        end
    else
        -- Safely disable if we can't determine the size
        buttonDelete:Disable()
    end

    --TODO: move to the units module
    if ns.units then
        for _, unit in pairs(ns.units) do
            if unit and unit.iconQueue then
                -- Add safety check to ensure Resize method exists
                if unit.iconQueue.Resize then
                    unit.iconQueue:Resize()
                end
            end
            if unit and unit.Clear then
                unit:Clear()
            end
        end
    end
end

-- Initial setup
frame:SetScript("OnShow", function()
    updateProfileButtons()
end)
