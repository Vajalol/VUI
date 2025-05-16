---@type string, Namespace
local _, ns = ...

-- Ensure the settings structure exists with all required properties
if not ns.settings then
    ns.settings = {
        activeProfile = {
            layoutSettings = {}
        }
    }
end

if not ns.settings.activeProfile then
    ns.settings.activeProfile = {
        layoutSettings = {}
    }
end

if not ns.settings.activeProfile.layoutSettings then
    ns.settings.activeProfile.layoutSettings = {}
end

-- Make sure LayoutSettings exists
ns.LayoutSettings = ns.LayoutSettings or {}
if not ns.LayoutSettings.New then
    ns.LayoutSettings.New = function()
        return {
            enable = false,
            direction = "Left",
            iconSize = 30,
            iconsNumber = 3
        }
    end
end

-- Initialize layoutSettings for each layout type if constants exist
if ns.constants and ns.constants.layoutTypes then
    for _, layoutType in ipairs(ns.constants.layoutTypes) do
        if not ns.settings.activeProfile.layoutSettings[layoutType] then
            ns.settings.activeProfile.layoutSettings[layoutType] = ns.LayoutSettings:New()
        end
    end
end

---@class SettingsFrame
local settingsFrame = {}
ns.settingsFrame = settingsFrame

local frame = CreateFrame("Frame", nil, UIParent)
frame:Hide()
frame.name = "TrufiGCD"
ns.utils.interfaceOptions_AddCategory(frame)
settingsFrame.frame = frame

SLASH_TRUFI1, SLASH_TRUFI2 = '/tgcd', '/trufigcd'
function SlashCmdList.TRUFI()
    Settings.OpenToCategory(frame.name)
end

---show/hide anchors button, text and frame
local showHideAnchorsButton = CreateFrame('Button', nil, frame, 'UIPanelButtonTemplate')
showHideAnchorsButton:SetWidth(100)
showHideAnchorsButton:SetHeight(22)
showHideAnchorsButton:SetPoint('TOPLEFT', 10, -30)
showHideAnchorsButton:SetText('Show')
ns.frameUtils.addTooltip(showHideAnchorsButton, "Show/Hide anchors", "Show or hide icon frame anchors to change their position")

local showHideAnchorsButtonLabel = showHideAnchorsButton:CreateFontString(nil, 'BACKGROUND')
showHideAnchorsButtonLabel:SetFont(STANDARD_TEXT_FONT, 10)
showHideAnchorsButtonLabel:SetText('Show/Hide anchors')
showHideAnchorsButtonLabel:SetPoint('TOP', 0, 10)

---frame after push show/hide button
local frameShowAnchors = CreateFrame('Frame', nil, UIParent)
frameShowAnchors:SetWidth(160)
frameShowAnchors:SetHeight(50)
frameShowAnchors:SetPoint('TOP', 0, -150)
frameShowAnchors:Hide()
frameShowAnchors:RegisterForDrag('LeftButton')
frameShowAnchors:SetScript('OnDragStart', frameShowAnchors.StartMoving)
frameShowAnchors:SetScript('OnDragStop', frameShowAnchors.StopMovingOrSizing)
frameShowAnchors:SetMovable(true)
frameShowAnchors:EnableMouse(true)

local frameShowAnchorsTexture = frameShowAnchors:CreateTexture(nil, 'BACKGROUND')
frameShowAnchorsTexture:SetAllPoints(frameShowAnchors)
frameShowAnchorsTexture:SetColorTexture(0, 0, 0)
frameShowAnchorsTexture:SetAlpha(0.5)

local frameShowAnchorsReturnButton = CreateFrame("Button", nil, frameShowAnchors, "UIPanelButtonTemplate")
frameShowAnchorsReturnButton:SetWidth(73)
frameShowAnchorsReturnButton:SetHeight(22)
frameShowAnchorsReturnButton:SetPoint("TOP", -37, -22)
frameShowAnchorsReturnButton:SetText("Settings")

local frameShowAnchorsHideButton = CreateFrame("Button", nil, frameShowAnchors, "UIPanelButtonTemplate")
frameShowAnchorsHideButton:SetWidth(73)
frameShowAnchorsHideButton:SetHeight(22)
frameShowAnchorsHideButton:SetPoint("TOP", 37, -22)
frameShowAnchorsHideButton:SetText("Hide")

local frameShowAnchorsButtonText = frameShowAnchors:CreateFontString(nil, "BACKGROUND")
frameShowAnchorsButtonText:SetFont(STANDARD_TEXT_FONT, 12)
frameShowAnchorsButtonText:SetText('TrufiGCD')
frameShowAnchorsButtonText:SetPoint("TOP", 0, -8)

frameShowAnchorsReturnButton:SetScript("OnClick", function()
    Settings.OpenToCategory(frame.name)
end)

local anchorDisplayed = false

settingsFrame.toggleAnchors = function()
    if anchorDisplayed then
        showHideAnchorsButton:SetText("Show")
        frameShowAnchors:Hide()
        for _, unit in pairs(ns.units) do
            local unitSettings = ns.settings.activeProfile.unitSettings[unit.unitType]
            unitSettings.point, _, _, unitSettings.x, unitSettings.y = unit.iconQueue.frame:GetPoint()
            unit.iconQueue:HideAnchor()
        end
        ns.settings:Save()
    else
        showHideAnchorsButton:SetText("Hide")
        frameShowAnchors:Show()
        for _, unit in pairs(ns.units) do
            local layout = ns.settings.activeProfile.layoutSettings[unit.layoutType]
            if layout.enable then
                unit.iconQueue:ShowAnchor()
            end
        end
    end
    anchorDisplayed = not anchorDisplayed
end

frameShowAnchorsHideButton:SetScript("OnClick", function() settingsFrame.toggleAnchors() end)
showHideAnchorsButton:SetScript("OnClick", function() settingsFrame.toggleAnchors() end)

---tooltip settings
local tooltipText = frame:CreateFontString(nil, "BACKGROUND")
tooltipText:SetFont(STANDARD_TEXT_FONT, 12)
tooltipText:SetText("Tooltip:")
tooltipText:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -70, -360)

---enable tooltip checkbox
local tooltipEnableCheckbox = ns.frameUtils.createCheckButton({
    frame = frame,
    text = "Enable",
    position = "TOPRIGHT",
    x = -90,
    y = -380,
    name = "TrGCDCheckTooltip",
    checked = ns.settings.activeProfile.tooltipEnabled,
    tooltip = "Show tooltip when hovering an icon",
    onClick = function()
        ns.settings.activeProfile.tooltipEnabled = not ns.settings.activeProfile.tooltipEnabled
        ns.settings:Save()
    end
})

---Stop moving with displayed tooltip checkbox
local stopMovingCheckbox = ns.frameUtils.createCheckButton({
    frame = frame,
    text = "Stop icons",
    position = "TOPRIGHT",
    x = -90,
    y = -410,
    name = "TrGCDCheckTooltipMove",
    checked = ns.settings.activeProfile.tooltipStopScroll,
    tooltip = "Stop moving icons when hovering an icon",
    onClick = function()
        ns.settings.activeProfile.tooltipStopScroll = not ns.settings.activeProfile.tooltipStopScroll
        ns.settings:Save()
    end
})

---Print spell ID to the chat checkbox
local spellIdCheckbox = ns.frameUtils.createCheckButton({
    frame = frame,
    text = "Spell ID",
    position = "TOPRIGHT",
    x = -90,
    y = -440,
    name = "TrGCDCheckTooltipSpellID",
    checked = ns.settings.activeProfile.tooltipPrintSpellId,
    tooltip = "Print spell ID to the chat when hovering an icon",
    onClick = function()
        ns.settings.activeProfile.tooltipPrintSpellId = not ns.settings.activeProfile.tooltipPrintSpellId
        ns.settings:Save()
    end
})

---Scrolling icons checkbox
local scrollingCheckbox = ns.frameUtils.createCheckButton({
    frame = frame,
    text = "Scrolling icons",
    position = "TOPRIGHT",
    x = -90,
    y = -80,
    name = "TrGCDCheckModScroll",
    checked = ns.settings.activeProfile.iconsScroll,
    tooltip = "Icons will be disappearing without moving",
    onClick = function()
        ns.settings.activeProfile.iconsScroll = not ns.settings.activeProfile.iconsScroll
        ns.settings:Save()
    end
})

--EnableIn checkboxes: Enable, World, PvE, Arena, Bg
local enableInText = frame:CreateFontString(nil, "BACKGROUND")
enableInText:SetFont(STANDARD_TEXT_FONT, 12)
enableInText:SetText("Enable in:")
enableInText:SetPoint("TOPRIGHT", -53, -175)

local combatOnlyCheckbox = ns.frameUtils.createCheckButton({
    frame = frame,
    text = "Combat only",
    position = "TOPRIGHT",
    x = -90,
    y = -110,
    name = "trgcdcheckenablein6",
    checked = ns.settings.activeProfile.enabledIn.combatOnly,
    onClick = function()
        ns.settings.activeProfile.enabledIn.combatOnly = not ns.settings.activeProfile.enabledIn.combatOnly
        ns.settings:Save()
        ns.locationCheck.settingsChanged()
    end
})

local enableCheckbox = ns.frameUtils.createCheckButton({
    frame = frame,
    text = "Enable addon",
    position = "TOPRIGHT",
    x = -90,
    y = -140,
    name = "trgcdcheckenablein0",
    checked = ns.settings.activeProfile.enabledIn.enabled,
    onClick = function()
        ns.settings.activeProfile.enabledIn.enabled = not ns.settings.activeProfile.enabledIn.enabled
        ns.settings:Save()
        ns.locationCheck.settingsChanged()
    end
})

local worldCheckbox = ns.frameUtils.createCheckButton({
    frame = frame,
    text = "World",
    position = "TOPRIGHT",
    x = -90,
    y = -200,
    name = "trgcdcheckenablein1",
    checked = ns.settings.activeProfile.enabledIn.world,
    onClick = function()
        ns.settings.activeProfile.enabledIn.world = not ns.settings.activeProfile.enabledIn.world
        ns.settings:Save()
        ns.locationCheck.settingsChanged()
    end
})

local partyCheckbox = ns.frameUtils.createCheckButton({
    frame = frame,
    text = "Party",
    position = "TOPRIGHT",
    x = -90,
    y = -230,
    name = "trgcdcheckenablein2",
    checked = ns.settings.activeProfile.enabledIn.party,
    onClick = function()
        ns.settings.activeProfile.enabledIn.party = not ns.settings.activeProfile.enabledIn.party
        ns.settings:Save()
        ns.locationCheck.settingsChanged()
    end
})

local raidCheckbox = ns.frameUtils.createCheckButton({
    frame = frame,
    text = "Raid",
    position = "TOPRIGHT",
    x = -90,
    y = -260,
    name = "trgcdcheckenablein5",
    checked = ns.settings.activeProfile.enabledIn.raid,
    onClick = function()
        ns.settings.activeProfile.enabledIn.raid = not ns.settings.activeProfile.enabledIn.raid
        ns.settings:Save()
        ns.locationCheck.settingsChanged()
    end
})

local arenaCheckbox = ns.frameUtils.createCheckButton({
    frame = frame,
    text = "Arena",
    position = "TOPRIGHT",
    x = -90,
    y = -290,
    name = "trgcdcheckenablein3",
    checked = ns.settings.activeProfile.enabledIn.arena,
    onClick = function()
        ns.settings.activeProfile.enabledIn.arena = not ns.settings.activeProfile.enabledIn.arena
        ns.settings:Save()
        ns.locationCheck.settingsChanged()
    end
})

local battlegroundCheckbox = ns.frameUtils.createCheckButton({
    frame = frame,
    text = "Battleground",
    position = "TOPRIGHT",
    x = -90,
    y = -320,
    name = "trgcdcheckenablein4",
    checked = ns.settings.activeProfile.enabledIn.battleground,
    onClick = function()
        ns.settings.activeProfile.enabledIn.battleground = not ns.settings.activeProfile.enabledIn.battleground
        ns.settings:Save()
        ns.locationCheck.settingsChanged()
    end
})

--labels for checkboxes and sliders
local labelEnable = frame:CreateFontString(nil, "BACKGROUND")
labelEnable:SetFont(STANDARD_TEXT_FONT, 12)
labelEnable:SetText("Enable")
labelEnable:SetPoint("TOPLEFT", 20, -65)

local labelFade = frame:CreateFontString(nil, "BACKGROUND")
labelFade:SetFont(STANDARD_TEXT_FONT, 12)
labelFade:SetText("Fade")
labelFade:SetPoint("TOPLEFT", 105, -65)

local labelSize = frame:CreateFontString(nil, "BACKGROUND")
labelSize:SetFont(STANDARD_TEXT_FONT, 12)
labelSize:SetText("Icons size")
labelSize:SetPoint("TOPLEFT", 245, -65)

local labelNumber = frame:CreateFontString(nil, "BACKGROUND")
labelNumber:SetFont(STANDARD_TEXT_FONT, 12)
labelNumber:SetText("Icons number")
labelNumber:SetPoint("TOPLEFT", 390, -65)

---@class LayoutSettingsFrame
local LayoutSettingsFrame = {}
LayoutSettingsFrame.__index = LayoutSettingsFrame

---@param layoutType LayoutType
---@param offset number
function LayoutSettingsFrame:New(layoutType, offset)
    -- Validate input parameters
    if not layoutType then
        layoutType = "horizontal" -- Default to horizontal if layoutType is nil
    end
    
    if not offset or type(offset) ~= "number" then
        offset = 1 -- Default offset value
    end
    
    ---@class LayoutSettingsFrame
    local obj = setmetatable({}, LayoutSettingsFrame)
    obj.layoutType = layoutType
    
    -- Ensure settings exist
    if not ns.settings then
        ns.settings = {
            activeProfile = {
                layoutSettings = {}
            }
        }
    end
    
    if not ns.settings.activeProfile then
        ns.settings.activeProfile = {
            layoutSettings = {}
        }
    end
    
    if not ns.settings.activeProfile.layoutSettings then
        ns.settings.activeProfile.layoutSettings = {}
    end
    
    -- Ensure layoutSettings[layoutType] exists
    if not ns.settings.activeProfile.layoutSettings[layoutType] then
        ns.settings.activeProfile.layoutSettings[layoutType] = ns.LayoutSettings and ns.LayoutSettings.New and ns.LayoutSettings:New() or {
            enable = false,
            direction = "Left",
            iconSize = 30,
            iconsNumber = 3
        }
    end
    
    -- Make sure all required properties exist in layoutSettings
    local layoutSettings = ns.settings.activeProfile.layoutSettings[layoutType]
    if not layoutSettings.enable then layoutSettings.enable = false end
    if not layoutSettings.direction then layoutSettings.direction = "Left" end
    if not layoutSettings.iconSize then layoutSettings.iconSize = 30 end
    if not layoutSettings.iconsNumber then layoutSettings.iconsNumber = 3 end
    
    -- Create UI elements with safety checks
    obj.buttonEnable = ns.frameUtils and ns.frameUtils.createCheckButton and ns.frameUtils.createCheckButton({
        frame = frame,
        text = layoutType:gsub("^%l", string.upper),
        position = "TOPLEFT",
        x = 10,
        y = -50 - offset * 40,
        name = "trgcdcheckenable" .. layoutType,
        checked = ns.settings.activeProfile.layoutSettings[layoutType].enable,
        onClick = function()
            if not ns.settings or not ns.settings.activeProfile or not ns.settings.activeProfile.layoutSettings or not ns.settings.activeProfile.layoutSettings[layoutType] then
                return
            end
            
            ns.settings.activeProfile.layoutSettings[layoutType].enable = not ns.settings.activeProfile.layoutSettings[layoutType].enable

            if ns.units then
                for _, unit in pairs(ns.units) do
                    if unit.layoutType == layoutType then
                        if ns.settings.activeProfile.layoutSettings[layoutType].enable then
                            if unit.iconQueue and unit.iconQueue.ShowAnchor then
                                unit.iconQueue:ShowAnchor()
                            end
                        else
                            if unit.iconQueue and unit.iconQueue.HideAnchor then
                                unit.iconQueue:HideAnchor()
                            end
                        end
                        if unit.Clear then
                            unit:Clear()
                        end
                    end
                end
            end

            if ns.settings.Save then
                ns.settings:Save()
            end
        end
    })

    -- Continue only if frameUtils exists
    if ns.frameUtils then
        ---dropdown menu
        obj.directionDropdown = CreateFrame("Button", "trgcdframemenu_btn_" .. layoutType, frame, "UIPanelButtonTemplate")
        obj.directionDropdown:SetSize(80, 22)
        obj.directionDropdown:SetText(ns.settings.activeProfile.layoutSettings[layoutType].direction or "Left")
        obj.directionDropdown.value = ns.settings.activeProfile.layoutSettings[layoutType].direction or "Left"

        -- Add click handler to cycle through directions
        obj.directionDropdown:SetScript("OnClick", function(self)
            local directions = {"Left", "Right", "Up", "Down"}
            local currentIndex = 1
            
            -- Find current direction in the list
            for i, dir in ipairs(directions) do
                if dir == self.value then
                    currentIndex = i
                    break
                end
            end
            
            -- Move to next direction (or back to first)
            currentIndex = currentIndex % #directions + 1
            local newDirection = directions[currentIndex]
            
            -- Update the button display and value
            self:SetText(newDirection)
            self.value = newDirection
            
            -- Update settings
            ns.settings.activeProfile.layoutSettings[layoutType].direction = newDirection
            ns.settings:Save()
            
            -- Update display if needed
            if ns.units then
                for _, unit in pairs(ns.units) do
                    if unit.layoutType == layoutType then
                        unit.iconQueue:UpdateDirection(newDirection)
                    end
                end
            end
        end)

        ---Size Slider
        obj.sizeSlider = CreateFrame("Slider", "trgcdframesizeslider" .. layoutType, frame, "VUITGCD_OptionsSliderTemplate")
        if obj.sizeSlider then
            obj.sizeSlider:SetWidth(170)
            obj.sizeSlider:SetPoint("TOPLEFT", 190, -55 - offset * 40)
            
            -- Safely access and set slider text
            local lowText = _G[obj.sizeSlider:GetName() .. 'Low']
            local highText = _G[obj.sizeSlider:GetName() .. 'High']
            local valueText = _G[obj.sizeSlider:GetName() .. 'Text']
            
            if lowText then lowText:SetText('10') end
            if highText then highText:SetText('100') end
            
            if valueText and ns.settings and ns.settings.activeProfile and 
               ns.settings.activeProfile.layoutSettings and 
               ns.settings.activeProfile.layoutSettings[layoutType] then
                valueText:SetText(ns.settings.activeProfile.layoutSettings[layoutType].iconSize)
            elseif valueText then
                valueText:SetText('30') -- Default
            end
            
            obj.sizeSlider:SetMinMaxValues(10,100)
            obj.sizeSlider:SetValueStep(1)
            
            -- Safely set value
            if ns.settings and ns.settings.activeProfile and 
               ns.settings.activeProfile.layoutSettings and 
               ns.settings.activeProfile.layoutSettings[layoutType] then
                obj.sizeSlider:SetValue(ns.settings.activeProfile.layoutSettings[layoutType].iconSize)
            else
                obj.sizeSlider:SetValue(30) -- Default
            end
            
            obj.sizeSlider:SetScript("OnValueChanged", function(_, value)
                if not ns.settings or not ns.settings.activeProfile or 
                   not ns.settings.activeProfile.layoutSettings or 
                   not ns.settings.activeProfile.layoutSettings[layoutType] then
                    return
                end
                
                value = math.ceil(value)
                local textFrame = _G[obj.sizeSlider:GetName() .. 'Text']
                if textFrame then
                    textFrame:SetText(value)
                end
                
                ns.settings.activeProfile.layoutSettings[layoutType].iconSize = value
                
                if ns.settings.Save then
                    ns.settings:Save()
                end

                if ns.units then
                    for _, unit in pairs(ns.units) do
                        if unit.layoutType == layoutType and unit.iconQueue then
                            if unit.iconQueue.Resize then
                                unit.iconQueue:Resize()
                            end
                            if unit.Clear then
                                unit:Clear()
                            end
                        end
                    end
                end
            end)
            obj.sizeSlider:Show()
        end

        ---Icons number slider
        obj.iconsNumber = CreateFrame("Slider", "trgcdframewidthslider" .. layoutType, frame, "VUITGCD_OptionsSliderTemplate")
        if obj.iconsNumber then
            obj.iconsNumber:SetWidth(100)
            obj.iconsNumber:SetPoint("TOPLEFT", 390, -55 - offset * 40)
            
            -- Safely access and set slider text
            local lowText = _G[obj.iconsNumber:GetName() .. 'Low']
            local highText = _G[obj.iconsNumber:GetName() .. 'High']
            local valueText = _G[obj.iconsNumber:GetName() .. 'Text']
            
            if lowText then lowText:SetText('1') end
            if highText then highText:SetText('8') end
            
            if valueText and ns.settings and ns.settings.activeProfile and 
               ns.settings.activeProfile.layoutSettings and 
               ns.settings.activeProfile.layoutSettings[layoutType] then
                valueText:SetText(ns.settings.activeProfile.layoutSettings[layoutType].iconsNumber)
            elseif valueText then
                valueText:SetText('3') -- Default
            end
            
            obj.iconsNumber:SetMinMaxValues(1,8)
            obj.iconsNumber:SetValueStep(1)
            
            -- Safely set value
            if ns.settings and ns.settings.activeProfile and 
               ns.settings.activeProfile.layoutSettings and 
               ns.settings.activeProfile.layoutSettings[layoutType] then
                obj.iconsNumber:SetValue(ns.settings.activeProfile.layoutSettings[layoutType].iconsNumber)
            else
                obj.iconsNumber:SetValue(3) -- Default
            end
            
            obj.iconsNumber:SetScript("OnValueChanged", function (_, value)
                if not ns.settings or not ns.settings.activeProfile or 
                   not ns.settings.activeProfile.layoutSettings or 
                   not ns.settings.activeProfile.layoutSettings[layoutType] then
                    return
                end
                
                value = math.ceil(value)
                local textFrame = _G[obj.iconsNumber:GetName() .. 'Text']
                if textFrame then
                    textFrame:SetText(value)
                end
                
                ns.settings.activeProfile.layoutSettings[layoutType].iconsNumber = value
                
                if ns.settings.Save then
                    ns.settings:Save()
                end

                if ns.units then
                    for _, unit in pairs(ns.units) do
                        if unit.layoutType == layoutType and unit.iconQueue then
                            if unit.iconQueue.Resize then
                                unit.iconQueue:Resize()
                            end
                            if unit.Clear then
                                unit:Clear()
                            end
                        end
                    end
                end
            end)
            obj.iconsNumber:Show()
        end
    end

    return obj
end

function LayoutSettingsFrame:SyncWithSettings()
    -- Ensure settings exist
    if not ns.settings then
        ns.settings = {
            activeProfile = {
                layoutSettings = {}
            }
        }
    end
    
    if not ns.settings.activeProfile then
        ns.settings.activeProfile = {
            layoutSettings = {}
        }
    end
    
    if not ns.settings.activeProfile.layoutSettings then
        ns.settings.activeProfile.layoutSettings = {}
    end
    
    -- Ensure layoutSettings[layoutType] exists
    if not ns.settings.activeProfile.layoutSettings[self.layoutType] then
        ns.settings.activeProfile.layoutSettings[self.layoutType] = ns.LayoutSettings and ns.LayoutSettings.New and ns.LayoutSettings:New() or {
            enable = false,
            direction = "Left",
            iconSize = 30,
            iconsNumber = 3
        }
    end
    
    local layoutSettings = ns.settings.activeProfile.layoutSettings[self.layoutType]
    
    -- Ensure all required properties exist in layoutSettings
    if type(layoutSettings) ~= "table" then
        layoutSettings = {
            enable = false,
            direction = "Left",
            iconSize = 30,
            iconsNumber = 3
        }
        ns.settings.activeProfile.layoutSettings[self.layoutType] = layoutSettings
    end
    
    if layoutSettings.enable == nil then layoutSettings.enable = false end
    if layoutSettings.direction == nil then layoutSettings.direction = "Left" end
    if layoutSettings.iconSize == nil then layoutSettings.iconSize = 30 end
    if layoutSettings.iconsNumber == nil then layoutSettings.iconsNumber = 3 end

    -- Now safely use the properties
    if self.buttonEnable and self.buttonEnable.SetChecked then
        self.buttonEnable:SetChecked(layoutSettings.enable)
    end
    
    if self.directionDropdown then
        self.directionDropdown:SetText(layoutSettings.direction)
        self.directionDropdown.value = layoutSettings.direction
    end

    if self.sizeSlider and self.sizeSlider:GetName() then
        local textFrame = _G[self.sizeSlider:GetName() .. 'Text']
        if textFrame then
            textFrame:SetText(layoutSettings.iconSize)
        end
        self.sizeSlider:SetValue(layoutSettings.iconSize)
    end

    if self.iconsNumber and self.iconsNumber:GetName() then
        local textFrame = _G[self.iconsNumber:GetName() .. 'Text']
        if textFrame then
            textFrame:SetText(layoutSettings.iconsNumber)
        end
        self.iconsNumber:SetValue(layoutSettings.iconsNumber)
    end

    -- Update units only if they exist
    if ns.units then
        for _, unit in pairs(ns.units) do
            if unit.layoutType == self.layoutType then
                if unit.iconQueue then
                    if unit.iconQueue.Resize then
                        unit.iconQueue:Resize()
                    end
                    if unit.iconQueue.UpdateOffset then
                        unit.iconQueue:UpdateOffset()
                    end
                end
            end
        end
    end
end

---@type {[LayoutType]: LayoutSettingsFrame}
local layoutSettingsFrames = {}
for index, layoutType in ipairs(ns.constants.layoutTypes) do
    layoutSettingsFrames[layoutType] = LayoutSettingsFrame:New(layoutType, index)
end

settingsFrame.syncWithSettings = function()
    -- Ensure settings exist
    if not ns.settings then
        ns.settings = {
            activeProfile = {
                enabledIn = {
                    combatOnly = false,
                    enabled = true,
                    world = true,
                    party = true,
                    raid = true,
                    arena = true,
                    battleground = true
                },
                tooltipEnabled = true,
                tooltipStopScroll = true,
                tooltipPrintSpellId = false,
                iconsScroll = true,
                layoutSettings = {}
            }
        }
    end
    
    if not ns.settings.activeProfile then
        ns.settings.activeProfile = {
            enabledIn = {
                combatOnly = false,
                enabled = true,
                world = true,
                party = true,
                raid = true,
                arena = true,
                battleground = true
            },
            tooltipEnabled = true,
            tooltipStopScroll = true,
            tooltipPrintSpellId = false,
            iconsScroll = true,
            layoutSettings = {}
        }
    end
    
    local settings = ns.settings.activeProfile
    
    -- Make sure all required settings exist
    if not settings.enabledIn then
        settings.enabledIn = {
            combatOnly = false,
            enabled = true,
            world = true,
            party = true,
            raid = true,
            arena = true,
            battleground = true
        }
    end
    
    -- Ensure specific settings fields exist
    settings.tooltipEnabled = settings.tooltipEnabled ~= nil and settings.tooltipEnabled or true
    settings.tooltipStopScroll = settings.tooltipStopScroll ~= nil and settings.tooltipStopScroll or true
    settings.tooltipPrintSpellId = settings.tooltipPrintSpellId ~= nil and settings.tooltipPrintSpellId or false
    settings.iconsScroll = settings.iconsScroll ~= nil and settings.iconsScroll or true
    
    -- Ensure all enabledIn fields exist
    if not settings.enabledIn then settings.enabledIn = {} end
    settings.enabledIn.combatOnly = settings.enabledIn.combatOnly ~= nil and settings.enabledIn.combatOnly or false
    settings.enabledIn.enabled = settings.enabledIn.enabled ~= nil and settings.enabledIn.enabled or true
    settings.enabledIn.world = settings.enabledIn.world ~= nil and settings.enabledIn.world or true
    settings.enabledIn.party = settings.enabledIn.party ~= nil and settings.enabledIn.party or true
    settings.enabledIn.raid = settings.enabledIn.raid ~= nil and settings.enabledIn.raid or true
    settings.enabledIn.arena = settings.enabledIn.arena ~= nil and settings.enabledIn.arena or true
    settings.enabledIn.battleground = settings.enabledIn.battleground ~= nil and settings.enabledIn.battleground or true

    -- Safely update checkbox states only if they exist
    if tooltipEnableCheckbox and tooltipEnableCheckbox.SetChecked then
        tooltipEnableCheckbox:SetChecked(settings.tooltipEnabled)
    end
    
    if stopMovingCheckbox and stopMovingCheckbox.SetChecked then
        stopMovingCheckbox:SetChecked(settings.tooltipStopScroll)
    end
    
    if spellIdCheckbox and spellIdCheckbox.SetChecked then
        spellIdCheckbox:SetChecked(settings.tooltipPrintSpellId)
    end
    
    if scrollingCheckbox and scrollingCheckbox.SetChecked then
        scrollingCheckbox:SetChecked(settings.iconsScroll)
    end

    if combatOnlyCheckbox and combatOnlyCheckbox.SetChecked then
        combatOnlyCheckbox:SetChecked(settings.enabledIn.combatOnly)
    end
    
    if enableCheckbox and enableCheckbox.SetChecked then
        enableCheckbox:SetChecked(settings.enabledIn.enabled)
    end
    
    if worldCheckbox and worldCheckbox.SetChecked then
        worldCheckbox:SetChecked(settings.enabledIn.world)
    end
    
    if partyCheckbox and partyCheckbox.SetChecked then
        partyCheckbox:SetChecked(settings.enabledIn.party)
    end
    
    if raidCheckbox and raidCheckbox.SetChecked then
        raidCheckbox:SetChecked(settings.enabledIn.raid)
    end
    
    if arenaCheckbox and arenaCheckbox.SetChecked then
        arenaCheckbox:SetChecked(settings.enabledIn.arena)
    end
    
    if battlegroundCheckbox and battlegroundCheckbox.SetChecked then
        battlegroundCheckbox:SetChecked(settings.enabledIn.battleground)
    end

    -- Ensure layoutSettings exists
    if not settings.layoutSettings then
        settings.layoutSettings = {}
    end
    
    -- Update layout settings safely
    if layoutSettingsFrames then
        for layoutType, layoutSettings in pairs(layoutSettingsFrames) do
            -- Make sure the layout settings for this type exist
            if not settings.layoutSettings[layoutType] then
                settings.layoutSettings[layoutType] = ns.LayoutSettings and ns.LayoutSettings.New and ns.LayoutSettings:New() or {
                    enable = false,
                    direction = "Left",
                    iconSize = 30,
                    iconsNumber = 3
                }
            end
            
            -- Safely call SyncWithSettings if available
            if layoutSettings and layoutSettings.SyncWithSettings then
                layoutSettings:SyncWithSettings()
            end
        end
    end
end
