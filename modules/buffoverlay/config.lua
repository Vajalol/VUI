-- BuffOverlay Config Implementation
-- This file contains the configuration options for the BuffOverlay module
local _, VUI = ...
local BuffOverlay = VUI.modules.buffoverlay
local AceGUI = LibStub("AceGUI-3.0")

-- Function to create a standalone configuration panel
function BuffOverlay:CreateConfigPanel()
    -- Create a frame
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("VUI BuffOverlay Configuration")
    frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    frame:SetLayout("Flow")
    frame:SetWidth(550)
    frame:SetHeight(500)
    
    -- Create tabs
    local tabs = AceGUI:Create("TabGroup")
    tabs:SetLayout("Flow")
    tabs:SetTabs({
        {text = "General", value = "general"},
        {text = "Display", value = "display"},
        {text = "Filters", value = "filters"},
        {text = "Tracker", value = "tracker"}
    })
    tabs:SetCallback("OnGroupSelected", function(container, event, group)
        container:ReleaseChildren()
        if group == "general" then
            self:CreateGeneralTab(container)
        elseif group == "display" then
            self:CreateDisplayTab(container)
        elseif group == "filters" then
            self:CreateFiltersTab(container)
        elseif group == "tracker" then
            self:CreateTrackerTab(container)
        end
    end)
    tabs:SelectTab("general")
    
    frame:AddChild(tabs)
    
    return frame
end

-- Create the General tab
function BuffOverlay:CreateGeneralTab(container)
    -- Enable/disable toggle
    local enableCheckbox = AceGUI:Create("CheckBox")
    enableCheckbox:SetLabel("Enable BuffOverlay")
    enableCheckbox:SetWidth(200)
    enableCheckbox:SetValue(VUI:IsModuleEnabled("buffoverlay"))
    enableCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        if value then
            VUI:EnableModule("buffoverlay")
        else
            VUI:DisableModule("buffoverlay")
        end
    end)
    container:AddChild(enableCheckbox)
    
    -- Spacer
    container:AddChild(AceGUI:Create("Label"):SetText(" "):SetFullWidth(true))
    
    -- Scale slider
    local scaleSlider = AceGUI:Create("Slider")
    scaleSlider:SetLabel("Scale")
    scaleSlider:SetWidth(300)
    scaleSlider:SetSliderValues(0.5, 2.0, 0.05)
    scaleSlider:SetValue(VUI.db.profile.modules.buffoverlay.scale)
    scaleSlider:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.buffoverlay.scale = value
        BuffOverlay:UpdateSettings()
    end)
    container:AddChild(scaleSlider)
    
    -- Icon size slider
    local sizeSlider = AceGUI:Create("Slider")
    sizeSlider:SetLabel("Icon Size")
    sizeSlider:SetWidth(300)
    sizeSlider:SetSliderValues(16, 64, 1)
    sizeSlider:SetValue(VUI.db.profile.modules.buffoverlay.size)
    sizeSlider:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.buffoverlay.size = value
        BuffOverlay:SetupFrames()
    end)
    container:AddChild(sizeSlider)
    
    -- Icon spacing slider
    local spacingSlider = AceGUI:Create("Slider")
    spacingSlider:SetLabel("Icon Spacing")
    spacingSlider:SetWidth(300)
    spacingSlider:SetSliderValues(0, 20, 1)
    spacingSlider:SetValue(VUI.db.profile.modules.buffoverlay.spacing)
    spacingSlider:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.buffoverlay.spacing = value
        BuffOverlay:UpdateSettings()
    end)
    container:AddChild(spacingSlider)
    
    -- Growth direction dropdown
    local directionDropdown = AceGUI:Create("Dropdown")
    directionDropdown:SetLabel("Growth Direction")
    directionDropdown:SetWidth(200)
    directionDropdown:SetList({
        ["UP"] = "Up",
        ["DOWN"] = "Down",
        ["LEFT"] = "Left",
        ["RIGHT"] = "Right"
    })
    directionDropdown:SetValue(VUI.db.profile.modules.buffoverlay.growthDirection)
    directionDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.buffoverlay.growthDirection = value
        BuffOverlay:UpdateSettings()
    end)
    container:AddChild(directionDropdown)
    
    -- Positioning button
    local positionButton = AceGUI:Create("Button")
    positionButton:SetText("Position Frames")
    positionButton:SetWidth(200)
    positionButton:SetCallback("OnClick", function()
        if BuffOverlay.anchor:IsShown() then
            BuffOverlay.anchor:Hide()
        else
            BuffOverlay.anchor:Show()
        end
    end)
    container:AddChild(positionButton)
    
    -- Units to track header
    container:AddChild(AceGUI:Create("Heading"):SetText("Units to Track"):SetFullWidth(true))
    
    -- Player checkbox
    local playerCheckbox = AceGUI:Create("CheckBox")
    playerCheckbox:SetLabel("Track Player Buffs/Debuffs")
    playerCheckbox:SetWidth(250)
    playerCheckbox:SetValue(VUI.db.profile.modules.buffoverlay.trackPlayer)
    playerCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.buffoverlay.trackPlayer = value
        BuffOverlay:UpdateSettings()
    end)
    container:AddChild(playerCheckbox)
    
    -- Target checkbox
    local targetCheckbox = AceGUI:Create("CheckBox")
    targetCheckbox:SetLabel("Track Target Buffs/Debuffs")
    targetCheckbox:SetWidth(250)
    targetCheckbox:SetValue(VUI.db.profile.modules.buffoverlay.trackTarget)
    targetCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.buffoverlay.trackTarget = value
        BuffOverlay:UpdateSettings()
    end)
    container:AddChild(targetCheckbox)
    
    -- Focus checkbox
    local focusCheckbox = AceGUI:Create("CheckBox")
    focusCheckbox:SetLabel("Track Focus Buffs/Debuffs")
    focusCheckbox:SetWidth(250)
    focusCheckbox:SetValue(VUI.db.profile.modules.buffoverlay.trackFocus)
    focusCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.buffoverlay.trackFocus = value
        BuffOverlay:UpdateSettings()
    end)
    container:AddChild(focusCheckbox)
end

-- Create the Display tab
function BuffOverlay:CreateDisplayTab(container)
    -- Show tooltip checkbox
    local tooltipCheckbox = AceGUI:Create("CheckBox")
    tooltipCheckbox:SetLabel("Show Tooltip on Hover")
    tooltipCheckbox:SetWidth(250)
    tooltipCheckbox:SetValue(VUI.db.profile.modules.buffoverlay.showTooltip)
    tooltipCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.buffoverlay.showTooltip = value
        BuffOverlay:SetupFrames()
    end)
    container:AddChild(tooltipCheckbox)
    
    -- Show timer checkbox
    local timerCheckbox = AceGUI:Create("CheckBox")
    timerCheckbox:SetLabel("Show Timer")
    tooltipCheckbox:SetWidth(250)
    timerCheckbox:SetValue(VUI.db.profile.modules.buffoverlay.showTimer)
    timerCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.buffoverlay.showTimer = value
        BuffOverlay:UpdateSettings()
    end)
    container:AddChild(timerCheckbox)
    
    -- Show stack count checkbox
    local stackCountCheckbox = AceGUI:Create("CheckBox")
    stackCountCheckbox:SetLabel("Show Stack Count")
    stackCountCheckbox:SetWidth(250)
    stackCountCheckbox:SetValue(VUI.db.profile.modules.buffoverlay.showStackCount)
    stackCountCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.buffoverlay.showStackCount = value
        BuffOverlay:UpdateSettings()
    end)
    container:AddChild(stackCountCheckbox)
    
    -- Use OmniCC timers (if available)
    if VUI:IsModuleEnabled("omnicc") then
        local omniCCCheckbox = AceGUI:Create("CheckBox")
        omniCCCheckbox:SetLabel("Use OmniCC Timers")
        omniCCCheckbox:SetWidth(250)
        omniCCCheckbox:SetValue(VUI.db.profile.modules.buffoverlay.useOmniCCTimers)
        omniCCCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
            VUI.db.profile.modules.buffoverlay.useOmniCCTimers = value
            BuffOverlay:SetupWithOmniCC()
        end)
        container:AddChild(omniCCCheckbox)
    end
    
    -- Border style dropdown
    local borderDropdown = AceGUI:Create("Dropdown")
    borderDropdown:SetLabel("Border Style")
    borderDropdown:SetWidth(200)
    borderDropdown:SetList({
        ["default"] = "Default",
        ["thin"] = "Thin",
        ["none"] = "None",
        ["class"] = "Class Colored"
    })
    borderDropdown:SetValue(VUI.db.profile.modules.buffoverlay.borderStyle)
    borderDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.buffoverlay.borderStyle = value
        BuffOverlay:UpdateSettings()
    end)
    container:AddChild(borderDropdown)
    
    -- Show notifications checkbox
    local notificationsCheckbox = AceGUI:Create("CheckBox")
    notificationsCheckbox:SetLabel("Show Gain/Fade Notifications")
    notificationsCheckbox:SetWidth(250)
    notificationsCheckbox:SetValue(VUI.db.profile.modules.buffoverlay.showNotifications)
    notificationsCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.buffoverlay.showNotifications = value
    end)
    container:AddChild(notificationsCheckbox)
    
    -- Display header for visual examples
    container:AddChild(AceGUI:Create("Heading"):SetText("Visual Preview"):SetFullWidth(true))
    
    -- Create a preview frame
    local previewFrame = AceGUI:Create("SimpleGroup")
    previewFrame:SetLayout("Flow")
    previewFrame:SetWidth(350)
    previewFrame:SetHeight(150)
    container:AddChild(previewFrame)
    
    -- We'd need to manually create some visual preview elements here
    -- This is simplified for this example
end

-- Create the Filters tab
function BuffOverlay:CreateFiltersTab(container)
    -- Filter buffs checkbox
    local filterBuffsCheckbox = AceGUI:Create("CheckBox")
    filterBuffsCheckbox:SetLabel("Filter Buffs (only show whitelisted)")
    filterBuffsCheckbox:SetWidth(300)
    filterBuffsCheckbox:SetValue(VUI.db.profile.modules.buffoverlay.filterBuffs)
    filterBuffsCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.buffoverlay.filterBuffs = value
        BuffOverlay:UpdateSettings()
    end)
    container:AddChild(filterBuffsCheckbox)
    
    -- Filter debuffs checkbox
    local filterDebuffsCheckbox = AceGUI:Create("CheckBox")
    filterDebuffsCheckbox:SetLabel("Filter Debuffs (only show whitelisted)")
    filterDebuffsCheckbox:SetWidth(300)
    filterDebuffsCheckbox:SetValue(VUI.db.profile.modules.buffoverlay.filterDebuffs)
    filterDebuffsCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.buffoverlay.filterDebuffs = value
        BuffOverlay:UpdateSettings()
    end)
    container:AddChild(filterDebuffsCheckbox)
    
    -- Spacer
    container:AddChild(AceGUI:Create("Label"):SetText(" "):SetFullWidth(true))
    
    -- Whitelist/Blacklist Management
    container:AddChild(AceGUI:Create("Heading"):SetText("Manage Tracked Spells"):SetFullWidth(true))
    
    -- Add spell group
    local addGroup = AceGUI:Create("SimpleGroup")
    addGroup:SetLayout("Flow")
    addGroup:SetFullWidth(true)
    container:AddChild(addGroup)
    
    -- Spell input
    local spellInput = AceGUI:Create("EditBox")
    spellInput:SetLabel("Spell ID or Name")
    spellInput:SetWidth(300)
    addGroup:AddChild(spellInput)
    
    -- Add to whitelist button
    local addWhitelistButton = AceGUI:Create("Button")
    addWhitelistButton:SetText("Add to Whitelist")
    addWhitelistButton:SetWidth(150)
    addWhitelistButton:SetCallback("OnClick", function()
        local input = spellInput:GetText()
        local spellID = tonumber(input)
        
        -- If it's not a number, try to look up the spell ID by name
        if not spellID then
            -- This is a simplified example; in a real addon you'd need a more
            -- robust way to convert spell names to IDs
            spellID = select(7, GetSpellInfo(input))
        end
        
        if spellID then
            BuffOverlay:AddToWhitelist(spellID)
            self:CreateFiltersTab(container) -- Refresh the tab
        else
            print("Invalid spell ID or name")
        end
    end)
    addGroup:AddChild(addWhitelistButton)
    
    -- Add to blacklist button
    local addBlacklistButton = AceGUI:Create("Button")
    addBlacklistButton:SetText("Add to Blacklist")
    addBlacklistButton:SetWidth(150)
    addBlacklistButton:SetCallback("OnClick", function()
        local input = spellInput:GetText()
        local spellID = tonumber(input)
        
        -- If it's not a number, try to look up the spell ID by name
        if not spellID then
            spellID = select(7, GetSpellInfo(input))
        end
        
        if spellID then
            BuffOverlay:AddToBlacklist(spellID)
            self:CreateFiltersTab(container) -- Refresh the tab
        else
            print("Invalid spell ID or name")
        end
    end)
    addGroup:AddChild(addBlacklistButton)
    
    -- Tracked spells list
    container:AddChild(AceGUI:Create("Heading"):SetText("Currently Tracked Spells"):SetFullWidth(true))
    
    -- Create a scroll frame for the list
    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("Flow")
    scrollFrame:SetFullWidth(true)
    scrollFrame:SetHeight(200)
    container:AddChild(scrollFrame)
    
    -- Get tracked spells
    local trackedSpells = BuffOverlay:GetTrackedBuffs()
    
    -- Create entry for each spell
    for _, spell in ipairs(trackedSpells) do
        local spellGroup = AceGUI:Create("SimpleGroup")
        spellGroup:SetLayout("Flow")
        spellGroup:SetFullWidth(true)
        spellGroup:SetHeight(24)
        
        -- Icon
        local icon = AceGUI:Create("Icon")
        icon:SetImage(spell.icon)
        icon:SetImageSize(20, 20)
        icon:SetWidth(24)
        icon:SetHeight(24)
        spellGroup:AddChild(icon)
        
        -- Name and ID text
        local text = AceGUI:Create("Label")
        text:SetText(spell.name .. " (" .. spell.spellID .. ")")
        text:SetWidth(300)
        spellGroup:AddChild(text)
        
        -- Whitelist toggle
        local whitelistToggle = AceGUI:Create("CheckBox")
        whitelistToggle:SetLabel("Whitelist")
        whitelistToggle:SetValue(spell.inWhitelist)
        whitelistToggle:SetWidth(100)
        whitelistToggle:SetCallback("OnValueChanged", function(widget, event, value)
            if value then
                BuffOverlay:AddToWhitelist(spell.spellID)
            else
                BuffOverlay:RemoveFromWhitelist(spell.spellID)
            end
        end)
        spellGroup:AddChild(whitelistToggle)
        
        -- Blacklist toggle
        local blacklistToggle = AceGUI:Create("CheckBox")
        blacklistToggle:SetLabel("Blacklist")
        blacklistToggle:SetValue(spell.inBlacklist)
        blacklistToggle:SetWidth(100)
        blacklistToggle:SetCallback("OnValueChanged", function(widget, event, value)
            if value then
                BuffOverlay:AddToBlacklist(spell.spellID)
            else
                BuffOverlay:RemoveFromBlacklist(spell.spellID)
            end
        end)
        spellGroup:AddChild(blacklistToggle)
        
        scrollFrame:AddChild(spellGroup)
    end
    
    if #trackedSpells == 0 then
        local noneLabel = AceGUI:Create("Label")
        noneLabel:SetText("No spells are currently being tracked. Add spells above.")
        noneLabel:SetFullWidth(true)
        scrollFrame:AddChild(noneLabel)
    end
end

-- Create the Tracker tab
function BuffOverlay:CreateTrackerTab(container)
    -- This tab provides a real-time preview of currently active buffs/debuffs
    container:AddChild(AceGUI:Create("Heading"):SetText("Current Active Auras"):SetFullWidth(true))
    
    -- Create unit tabs
    local unitTabs = AceGUI:Create("TabGroup")
    unitTabs:SetLayout("Flow")
    unitTabs:SetFullWidth(true)
    unitTabs:SetTabs({
        {text = "Player", value = "player"},
        {text = "Target", value = "target"},
        {text = "Focus", value = "focus"}
    })
    unitTabs:SetCallback("OnGroupSelected", function(widget, event, unit)
        widget:ReleaseChildren()
        self:CreateAuraList(widget, unit)
    end)
    unitTabs:SelectTab("player")
    
    container:AddChild(unitTabs)
    
    -- Add quick tracking buttons
    container:AddChild(AceGUI:Create("Heading"):SetText("Quick Actions"):SetFullWidth(true))
    
    local buttonGroup = AceGUI:Create("SimpleGroup")
    buttonGroup:SetLayout("Flow")
    buttonGroup:SetFullWidth(true)
    container:AddChild(buttonGroup)
    
    -- Track hovered aura button
    local trackHoveredButton = AceGUI:Create("Button")
    trackHoveredButton:SetText("Track Hovered Aura")
    trackHoveredButton:SetWidth(200)
    trackHoveredButton:SetCallback("OnClick", function()
        local tooltip = GameTooltip:GetSpellId()
        if tooltip then
            BuffOverlay:AddToWhitelist(tooltip)
            print("Added spell to BuffOverlay whitelist: " .. GetSpellInfo(tooltip))
        else
            print("No spell currently hovered")
        end
    end)
    buttonGroup:AddChild(trackHoveredButton)
    
    -- Clear all filters button
    local clearButton = AceGUI:Create("Button")
    clearButton:SetText("Clear All Filters")
    clearButton:SetWidth(200)
    clearButton:SetCallback("OnClick", function()
        StaticPopupDialogs["VUI_BUFFOVERLAY_CONFIRM_CLEAR"] = {
            text = "Are you sure you want to clear all BuffOverlay filters?",
            button1 = "Yes",
            button2 = "No",
            OnAccept = function()
                VUI.db.profile.modules.buffoverlay.whitelist = {}
                VUI.db.profile.modules.buffoverlay.blacklist = {}
                BuffOverlay:UpdateSettings()
                self:CreateTrackerTab(container) -- Refresh
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
        StaticPopup_Show("VUI_BUFFOVERLAY_CONFIRM_CLEAR")
    end)
    buttonGroup:AddChild(clearButton)
end

-- Helper function to create a list of current auras for a unit
function BuffOverlay:CreateAuraList(container, unit)
    if not UnitExists(unit) then
        local noUnitLabel = AceGUI:Create("Label")
        noUnitLabel:SetText("No " .. unit .. " exists")
        noUnitLabel:SetFullWidth(true)
        container:AddChild(noUnitLabel)
        return
    end
    
    -- Create a scroll frame
    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("Flow")
    scrollFrame:SetFullWidth(true)
    scrollFrame:SetHeight(350)
    container:AddChild(scrollFrame)
    
    -- Title with unit name
    local unitName = UnitName(unit) or unit
    local unitLabel = AceGUI:Create("Label")
    unitLabel:SetText("Auras on " .. unitName)
    unitLabel:SetFullWidth(true)
    scrollFrame:AddChild(unitLabel)
    
    -- Process buffs
    local auras = {}
    
    -- Get buffs
    for i = 1, 40 do
        local name, icon, count, debuffType, duration, expirationTime, source, _, _, spellID = UnitBuff(unit, i)
        if not name then break end
        
        table.insert(auras, {
            name = name,
            icon = icon,
            count = count,
            duration = duration,
            expirationTime = expirationTime,
            isDebuff = false,
            spellID = spellID,
            index = i
        })
    end
    
    -- Get debuffs
    for i = 1, 40 do
        local name, icon, count, debuffType, duration, expirationTime, source, _, _, spellID = UnitDebuff(unit, i)
        if not name then break end
        
        table.insert(auras, {
            name = name,
            icon = icon,
            count = count,
            duration = duration,
            expirationTime = expirationTime,
            isDebuff = true,
            debuffType = debuffType,
            spellID = spellID,
            index = i
        })
    end
    
    -- No auras message
    if #auras == 0 then
        local noAurasLabel = AceGUI:Create("Label")
        noAurasLabel:SetText("No auras found on this unit")
        noAurasLabel:SetFullWidth(true)
        scrollFrame:AddChild(noAurasLabel)
        return
    end
    
    -- Create aura entries
    for _, aura in ipairs(auras) do
        local auraGroup = AceGUI:Create("SimpleGroup")
        auraGroup:SetLayout("Flow")
        auraGroup:SetFullWidth(true)
        auraGroup:SetHeight(32)
        
        -- Icon
        local icon = AceGUI:Create("Icon")
        icon:SetImage(aura.icon)
        icon:SetImageSize(24, 24)
        icon:SetWidth(32)
        icon:SetHeight(32)
        auraGroup:AddChild(icon)
        
        -- Info text
        local timeLeft = aura.expirationTime > 0 and aura.expirationTime - GetTime() or 0
        local timeString = timeLeft > 0 and string.format(" (%.1fs)", timeLeft) or ""
        local countString = aura.count and aura.count > 1 and " x" .. aura.count or ""
        local text = AceGUI:Create("Label")
        text:SetText(aura.name .. countString .. timeString)
        text:SetWidth(200)
        auraGroup:AddChild(text)
        
        -- Add to whitelist button
        local whitelistButton = AceGUI:Create("Button")
        whitelistButton:SetText("Add to Whitelist")
        whitelistButton:SetWidth(120)
        whitelistButton:SetCallback("OnClick", function()
            if aura.spellID then
                BuffOverlay:AddToWhitelist(aura.spellID)
                print("Added " .. aura.name .. " to whitelist")
            end
        end)
        auraGroup:AddChild(whitelistButton)
        
        -- Add to blacklist button
        local blacklistButton = AceGUI:Create("Button")
        blacklistButton:SetText("Add to Blacklist")
        blacklistButton:SetWidth(120)
        blacklistButton:SetCallback("OnClick", function()
            if aura.spellID then
                BuffOverlay:AddToBlacklist(aura.spellID)
                print("Added " .. aura.name .. " to blacklist")
            end
        end)
        auraGroup:AddChild(blacklistButton)
        
        scrollFrame:AddChild(auraGroup)
    end
    
    -- Auto-refresh the aura list every 0.5 seconds
    if self.refreshTimer then
        VUI.utils.cancelTimer(self.refreshTimer)
    end
    
    self.refreshTimer = VUI.utils.after(0.5, function()
        self:CreateAuraList(container, unit)
    end)
end
