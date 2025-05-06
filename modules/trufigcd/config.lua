-- TrufiGCD Config Implementation
-- This file contains the configuration options for the TrufiGCD module
local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end
local TrufiGCD = VUI.modules.trufigcd
local AceGUI = LibStub("AceGUI-3.0")

-- Function to create a standalone configuration panel
function TrufiGCD:CreateConfigPanel()
    -- Create a frame
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("VUI TrufiGCD Configuration")
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
        {text = "Spell List", value = "spells"}
    })
    tabs:SetCallback("OnGroupSelected", function(container, event, group)
        container:ReleaseChildren()
        if group == "general" then
            self:CreateGeneralTab(container)
        elseif group == "display" then
            self:CreateDisplayTab(container)
        elseif group == "filters" then
            self:CreateFiltersTab(container)
        elseif group == "spells" then
            self:CreateSpellsTab(container)
        end
    end)
    tabs:SelectTab("general")
    
    frame:AddChild(tabs)
    
    return frame
end

-- Create the General tab
function TrufiGCD:CreateGeneralTab(container)
    -- Enable/disable toggle
    local enableCheckbox = AceGUI:Create("CheckBox")
    enableCheckbox:SetLabel("Enable TrufiGCD")
    enableCheckbox:SetWidth(200)
    enableCheckbox:SetValue(VUI:IsModuleEnabled("trufigcd"))
    enableCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        if value then
            VUI:EnableModule("trufigcd")
        else
            VUI:DisableModule("trufigcd")
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
    scaleSlider:SetValue(VUI.db.profile.modules.trufigcd.scale)
    scaleSlider:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.trufigcd.scale = value
        TrufiGCD:UpdateSettings()
    end)
    container:AddChild(scaleSlider)
    
    -- Icon size slider
    local sizeSlider = AceGUI:Create("Slider")
    sizeSlider:SetLabel("Icon Size")
    sizeSlider:SetWidth(300)
    sizeSlider:SetSliderValues(16, 64, 1)
    sizeSlider:SetValue(VUI.db.profile.modules.trufigcd.iconSize)
    sizeSlider:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.trufigcd.iconSize = value
        TrufiGCD:SetupFrames()
    end)
    container:AddChild(sizeSlider)
    
    -- Icon spacing slider
    local spacingSlider = AceGUI:Create("Slider")
    spacingSlider:SetLabel("Icon Spacing")
    spacingSlider:SetWidth(300)
    spacingSlider:SetSliderValues(0, 20, 1)
    spacingSlider:SetValue(VUI.db.profile.modules.trufigcd.iconSpacing)
    spacingSlider:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.trufigcd.iconSpacing = value
        TrufiGCD:PositionFrames()
    end)
    container:AddChild(spacingSlider)
    
    -- Max icons slider
    local maxIconsSlider = AceGUI:Create("Slider")
    maxIconsSlider:SetLabel("Maximum Icons")
    maxIconsSlider:SetWidth(300)
    maxIconsSlider:SetSliderValues(1, 20, 1)
    maxIconsSlider:SetValue(VUI.db.profile.modules.trufigcd.maxIcons)
    maxIconsSlider:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.trufigcd.maxIcons = value
        TrufiGCD:SetupFrames()
    end)
    container:AddChild(maxIconsSlider)
    
    -- Show spell name checkbox
    local spellNameCheckbox = AceGUI:Create("CheckBox")
    spellNameCheckbox:SetLabel("Show Spell Names")
    spellNameCheckbox:SetWidth(200)
    spellNameCheckbox:SetValue(VUI.db.profile.modules.trufigcd.showSpellName)
    spellNameCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.trufigcd.showSpellName = value
        TrufiGCD:SetupFrames()
    end)
    container:AddChild(spellNameCheckbox)
    
    -- Positioning button
    local positionButton = AceGUI:Create("Button")
    positionButton:SetText("Position Frames")
    positionButton:SetWidth(200)
    positionButton:SetCallback("OnClick", function()
        if TrufiGCD.anchor:IsShown() then
            TrufiGCD.anchor:Hide()
        else
            TrufiGCD.anchor:Show()
        end
    end)
    container:AddChild(positionButton)
    
    -- Clear button
    local clearButton = AceGUI:Create("Button")
    clearButton:SetText("Clear Current Display")
    clearButton:SetWidth(200)
    clearButton:SetCallback("OnClick", function()
        TrufiGCD:ClearSpells()
    end)
    container:AddChild(clearButton)
end

-- Create the Display tab
function TrufiGCD:CreateDisplayTab(container)
    -- Direction dropdown
    local directionDropdown = AceGUI:Create("Dropdown")
    directionDropdown:SetLabel("Growth Direction")
    directionDropdown:SetWidth(200)
    directionDropdown:SetList({
        ["LEFT"] = "Left",
        ["RIGHT"] = "Right",
        ["UP"] = "Up",
        ["DOWN"] = "Down"
    })
    directionDropdown:SetValue(VUI.db.profile.modules.trufigcd.direction)
    directionDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.trufigcd.direction = value
        TrufiGCD:PositionFrames()
    end)
    container:AddChild(directionDropdown)
    
    -- Fade time slider
    local fadeSlider = AceGUI:Create("Slider")
    fadeSlider:SetLabel("Fade Time (seconds)")
    fadeSlider:SetWidth(300)
    fadeSlider:SetSliderValues(0.1, 5.0, 0.1)
    fadeSlider:SetValue(VUI.db.profile.modules.trufigcd.fadeTime)
    fadeSlider:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.trufigcd.fadeTime = value
    end)
    container:AddChild(fadeSlider)
    
    -- Only in combat checkbox
    local combatCheckbox = AceGUI:Create("CheckBox")
    combatCheckbox:SetLabel("Only Show In Combat")
    combatCheckbox:SetWidth(200)
    combatCheckbox:SetValue(VUI.db.profile.modules.trufigcd.onlyInCombat)
    combatCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.trufigcd.onlyInCombat = value
    end)
    container:AddChild(combatCheckbox)
    
    -- Hide out of combat checkbox
    local hideCheckbox = AceGUI:Create("CheckBox")
    hideCheckbox:SetLabel("Hide Out Of Combat")
    hideCheckbox:SetWidth(200)
    hideCheckbox:SetValue(VUI.db.profile.modules.trufigcd.hideOutOfCombat)
    hideCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.trufigcd.hideOutOfCombat = value
        if value and not InCombatLockdown() then
            TrufiGCD:ClearSpells()
        end
    end)
    container:AddChild(hideCheckbox)
    
    -- Ignore items checkbox
    local itemsCheckbox = AceGUI:Create("CheckBox")
    itemsCheckbox:SetLabel("Ignore Items")
    itemsCheckbox:SetWidth(200)
    itemsCheckbox:SetValue(VUI.db.profile.modules.trufigcd.ignoreItems)
    itemsCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.trufigcd.ignoreItems = value
    end)
    container:AddChild(itemsCheckbox)
    
    -- Track pet spells checkbox
    local petCheckbox = AceGUI:Create("CheckBox")
    petCheckbox:SetLabel("Track Pet Spells")
    petCheckbox:SetWidth(200)
    petCheckbox:SetValue(VUI.db.profile.modules.trufigcd.trackPetSpells)
    petCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.trufigcd.trackPetSpells = value
    end)
    container:AddChild(petCheckbox)
    
    -- Display header for appearance
    container:AddChild(AceGUI:Create("Heading"):SetText("Appearance"):SetFullWidth(true))
    
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
    borderDropdown:SetValue(VUI.db.profile.modules.trufigcd.borderStyle or "default")
    borderDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.trufigcd.borderStyle = value
        TrufiGCD:UpdateSettings()
    end)
    container:AddChild(borderDropdown)
    
    -- Icon backdrop color picker
    local backdropColor = AceGUI:Create("ColorPicker")
    backdropColor:SetLabel("Icon Background Color")
    backdropColor:SetWidth(200)
    backdropColor:SetColor(
        VUI.db.profile.modules.trufigcd.backdropColor.r or 0,
        VUI.db.profile.modules.trufigcd.backdropColor.g or 0,
        VUI.db.profile.modules.trufigcd.backdropColor.b or 0,
        VUI.db.profile.modules.trufigcd.backdropColor.a or 1
    )
    backdropColor:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
        VUI.db.profile.modules.trufigcd.backdropColor = {r = r, g = g, b = b, a = a}
        TrufiGCD:UpdateSettings()
    end)
    container:AddChild(backdropColor)
    
    -- Spell name color picker
    local nameColor = AceGUI:Create("ColorPicker")
    nameColor:SetLabel("Spell Name Color")
    nameColor:SetWidth(200)
    nameColor:SetColor(
        VUI.db.profile.modules.trufigcd.nameColor.r or 1,
        VUI.db.profile.modules.trufigcd.nameColor.g or 1,
        VUI.db.profile.modules.trufigcd.nameColor.b or 1,
        VUI.db.profile.modules.trufigcd.nameColor.a or 1
    )
    nameColor:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
        VUI.db.profile.modules.trufigcd.nameColor = {r = r, g = g, b = b, a = a}
        TrufiGCD:UpdateSettings()
    end)
    container:AddChild(nameColor)
end

-- Create the Filters tab
function TrufiGCD:CreateFiltersTab(container)
    -- Event filtering header
    container:AddChild(AceGUI:Create("Heading"):SetText("Event Filtering"):SetFullWidth(true))
    
    -- Filter by cast events
    local castEventsCheckbox = AceGUI:Create("CheckBox")
    castEventsCheckbox:SetLabel("Filter By Cast Events")
    castEventsCheckbox:SetWidth(200)
    castEventsCheckbox:SetValue(VUI.db.profile.modules.trufigcd.filterByCastEvents)
    castEventsCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.trufigcd.filterByCastEvents = value
    end)
    container:AddChild(castEventsCheckbox)
    
    -- Track cast success
    local castSuccessCheckbox = AceGUI:Create("CheckBox")
    castSuccessCheckbox:SetLabel("Track Cast Success")
    castSuccessCheckbox:SetWidth(200)
    castSuccessCheckbox:SetValue(VUI.db.profile.modules.trufigcd.trackCastSuccess)
    castSuccessCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.trufigcd.trackCastSuccess = value
    end)
    container:AddChild(castSuccessCheckbox)
    
    -- Track cast start
    local castStartCheckbox = AceGUI:Create("CheckBox")
    castStartCheckbox:SetLabel("Track Cast Start")
    castStartCheckbox:SetWidth(200)
    castStartCheckbox:SetValue(VUI.db.profile.modules.trufigcd.trackCastStart)
    castStartCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.trufigcd.trackCastStart = value
    end)
    container:AddChild(castStartCheckbox)
    
    -- Track aura events
    local auraEventsCheckbox = AceGUI:Create("CheckBox")
    auraEventsCheckbox:SetLabel("Track Aura Events")
    auraEventsCheckbox:SetWidth(200)
    auraEventsCheckbox:SetValue(VUI.db.profile.modules.trufigcd.trackAuraEvents)
    auraEventsCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.trufigcd.trackAuraEvents = value
    end)
    container:AddChild(auraEventsCheckbox)
    
    -- Spell filtering header
    container:AddChild(AceGUI:Create("Heading"):SetText("Spell Filtering"):SetFullWidth(true))
    
    -- Add spell group
    local addGroup = AceGUI:Create("SimpleGroup")
    addGroup:SetLayout("Flow")
    addGroup:SetFullWidth(true)
    container:AddChild(addGroup)
    
    -- Spell input
    local spellInput = AceGUI:Create("EditBox")
    spellInput:SetLabel("Spell ID or Name")
    spellInput:SetWidth(200)
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
            spellID = select(7, GetSpellInfo(input))
        end
        
        if spellID then
            TrufiGCD:AddToWhitelist(spellID)
            VUI:Print("Added " .. (GetSpellInfo(spellID) or input) .. " to TrufiGCD whitelist")
        else
            VUI:Print("Invalid spell ID or name")
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
            TrufiGCD:AddToBlacklist(spellID)
            VUI:Print("Added " .. (GetSpellInfo(spellID) or input) .. " to TrufiGCD blacklist")
        else
            VUI:Print("Invalid spell ID or name")
        end
    end)
    addGroup:AddChild(addBlacklistButton)
    
    -- Clear filters button
    local clearButton = AceGUI:Create("Button")
    clearButton:SetText("Clear All Filters")
    clearButton:SetWidth(150)
    clearButton:SetCallback("OnClick", function()
        StaticPopupDialogs["VUI_TRUFIGCD_CONFIRM_CLEAR"] = {
            text = "Are you sure you want to clear all TrufiGCD spell filters?",
            button1 = "Yes",
            button2 = "No",
            OnAccept = function()
                VUI.db.profile.modules.trufigcd.whitelist = {}
                VUI.db.profile.modules.trufigcd.blacklist = {}
                VUI:Print("TrufiGCD spell filters cleared")
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
        StaticPopup_Show("VUI_TRUFIGCD_CONFIRM_CLEAR")
    end)
    addGroup:AddChild(clearButton)
end

-- Create the Spells tab to view and manage spell lists
function TrufiGCD:CreateSpellsTab(container)
    -- Create a scroll frame for the spell lists
    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("Flow")
    scrollFrame:SetFullWidth(true)
    scrollFrame:SetHeight(400)
    container:AddChild(scrollFrame)
    
    -- Whitelist header
    scrollFrame:AddChild(AceGUI:Create("Heading"):SetText("Whitelist"):SetFullWidth(true))
    
    -- Process whitelist
    local whitelistFound = false
    for spellID in pairs(VUI.db.profile.modules.trufigcd.whitelist) do
        whitelistFound = true
        local name, _, icon = GetSpellInfo(spellID)
        if name then
            local spellGroup = AceGUI:Create("SimpleGroup")
            spellGroup:SetLayout("Flow")
            spellGroup:SetFullWidth(true)
            spellGroup:SetHeight(30)
            
            -- Icon display
            local iconWidget = AceGUI:Create("Icon")
            iconWidget:SetImage(icon)
            iconWidget:SetImageSize(20, 20)
            iconWidget:SetWidth(30)
            iconWidget:SetHeight(30)
            spellGroup:AddChild(iconWidget)
            
            -- Spell info
            local info = AceGUI:Create("Label")
            info:SetText(name .. " (ID: " .. spellID .. ")")
            info:SetWidth(300)
            spellGroup:AddChild(info)
            
            -- Remove button
            local removeButton = AceGUI:Create("Button")
            removeButton:SetText("Remove")
            removeButton:SetWidth(100)
            removeButton:SetCallback("OnClick", function()
                TrufiGCD:RemoveFromWhitelist(spellID)
                self:CreateSpellsTab(container)
            end)
            spellGroup:AddChild(removeButton)
            
            scrollFrame:AddChild(spellGroup)
        end
    end
    
    if not whitelistFound then
        local noSpells = AceGUI:Create("Label")
        noSpells:SetText("No spells in whitelist. If empty, all spells are tracked (except blacklisted ones).")
        noSpells:SetFullWidth(true)
        scrollFrame:AddChild(noSpells)
    end
    
    -- Spacer
    scrollFrame:AddChild(AceGUI:Create("Label"):SetText(" "):SetFullWidth(true))
    
    -- Blacklist header
    scrollFrame:AddChild(AceGUI:Create("Heading"):SetText("Blacklist"):SetFullWidth(true))
    
    -- Process blacklist
    local blacklistFound = false
    for spellID in pairs(VUI.db.profile.modules.trufigcd.blacklist) do
        blacklistFound = true
        local name, _, icon = GetSpellInfo(spellID)
        if name then
            local spellGroup = AceGUI:Create("SimpleGroup")
            spellGroup:SetLayout("Flow")
            spellGroup:SetFullWidth(true)
            spellGroup:SetHeight(30)
            
            -- Icon display
            local iconWidget = AceGUI:Create("Icon")
            iconWidget:SetImage(icon)
            iconWidget:SetImageSize(20, 20)
            iconWidget:SetWidth(30)
            iconWidget:SetHeight(30)
            spellGroup:AddChild(iconWidget)
            
            -- Spell info
            local info = AceGUI:Create("Label")
            info:SetText(name .. " (ID: " .. spellID .. ")")
            info:SetWidth(300)
            spellGroup:AddChild(info)
            
            -- Remove button
            local removeButton = AceGUI:Create("Button")
            removeButton:SetText("Remove")
            removeButton:SetWidth(100)
            removeButton:SetCallback("OnClick", function()
                TrufiGCD:RemoveFromBlacklist(spellID)
                self:CreateSpellsTab(container)
            end)
            spellGroup:AddChild(removeButton)
            
            scrollFrame:AddChild(spellGroup)
        end
    end
    
    if not blacklistFound then
        local noSpells = AceGUI:Create("Label")
        noSpells:SetText("No spells in blacklist.")
        noSpells:SetFullWidth(true)
        scrollFrame:AddChild(noSpells)
    end
    
    -- Add currently casting spell button
    local currentSpellButton = AceGUI:Create("Button")
    currentSpellButton:SetText("Add Current/Last Cast Spell")
    currentSpellButton:SetFullWidth(true)
    currentSpellButton:SetCallback("OnClick", function()
        local spell = UnitCastingInfo("player") or UnitChannelInfo("player")
        if spell then
            local spellID = select(7, GetSpellInfo(spell))
            if spellID then
                TrufiGCD:AddToWhitelist(spellID)
                VUI:Print("Added current spell " .. spell .. " to whitelist")
                self:CreateSpellsTab(container)
            end
        else
            VUI:Print("No spell currently being cast")
        end
    end)
    container:AddChild(currentSpellButton)
end
