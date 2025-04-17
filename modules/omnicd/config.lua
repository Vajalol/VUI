-- OmniCD Config Implementation
-- This file contains the configuration options for the OmniCD module
local _, VUI = ...
local OmniCD = VUI.omnicd
local AceGUI = LibStub("AceGUI-3.0")

-- Function to create a standalone configuration panel
function OmniCD:CreateConfigPanel()
    -- Create a frame
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("VUI OmniCD Configuration")
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
        {text = "Spells", value = "spells"},
        {text = "Zones", value = "zones"}
    })
    tabs:SetCallback("OnGroupSelected", function(container, event, group)
        container:ReleaseChildren()
        if group == "general" then
            self:CreateGeneralTab(container)
        elseif group == "display" then
            self:CreateDisplayTab(container)
        elseif group == "spells" then
            self:CreateSpellsTab(container)
        elseif group == "zones" then
            self:CreateZonesTab(container)
        end
    end)
    tabs:SelectTab("general")
    
    frame:AddChild(tabs)
    
    return frame
end

-- Create the General tab
function OmniCD:CreateGeneralTab(container)
    -- Enable/disable toggle
    local enableCheckbox = AceGUI:Create("CheckBox")
    enableCheckbox:SetLabel("Enable OmniCD")
    enableCheckbox:SetWidth(200)
    enableCheckbox:SetValue(VUI:IsModuleEnabled("omnicd"))
    enableCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        if value then
            VUI:EnableModule("omnicd")
        else
            VUI:DisableModule("omnicd")
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
    
    -- Show player names checkbox
    local namesCheckbox = AceGUI:Create("CheckBox")
    namesCheckbox:SetLabel("Show Player Names")
    namesCheckbox:SetWidth(200)
    namesCheckbox:SetValue(VUI.db.profile.modules.omnicd.showNames)
    namesCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.omnicd.showNames = value
    end)
    generalGroup:AddChild(namesCheckbox)
    
    -- Show cooldown text checkbox
    local cooldownTextCheckbox = AceGUI:Create("CheckBox")
    cooldownTextCheckbox:SetLabel("Show Cooldown Text")
    cooldownTextCheckbox:SetWidth(200)
    cooldownTextCheckbox:SetValue(VUI.db.profile.modules.omnicd.showCooldownText)
    cooldownTextCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.omnicd.showCooldownText = value
    end)
    generalGroup:AddChild(cooldownTextCheckbox)
    
    -- Show tooltips checkbox
    local tooltipsCheckbox = AceGUI:Create("CheckBox")
    tooltipsCheckbox:SetLabel("Show Tooltips")
    tooltipsCheckbox:SetWidth(200)
    tooltipsCheckbox:SetValue(VUI.db.profile.modules.omnicd.showTooltips)
    tooltipsCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.omnicd.showTooltips = value
    end)
    generalGroup:AddChild(tooltipsCheckbox)
    
    -- Position options group
    local positionGroup = AceGUI:Create("InlineGroup")
    positionGroup:SetTitle("Position")
    positionGroup:SetLayout("Flow")
    positionGroup:SetFullWidth(true)
    container:AddChild(positionGroup)
    
    -- Position button
    local positionButton = AceGUI:Create("Button")
    positionButton:SetText("Position OmniCD Frame")
    positionButton:SetWidth(200)
    positionButton:SetCallback("OnClick", function()
        if OmniCD.anchor:IsShown() then
            OmniCD.anchor:Hide()
        else
            OmniCD.anchor:Show()
        end
    end)
    positionGroup:AddChild(positionButton)
    
    -- Reset position button
    local resetButton = AceGUI:Create("Button")
    resetButton:SetText("Reset Position")
    resetButton:SetWidth(200)
    resetButton:SetCallback("OnClick", function()
        VUI.db.profile.modules.omnicd.position = {"TOPLEFT", "CENTER", 0, 150}
        if OmniCD.container then
            OmniCD.container:ClearAllPoints()
            OmniCD.container:SetPoint("TOPLEFT", UIParent, "CENTER", 0, 150)
        end
    end)
    positionGroup:AddChild(resetButton)
end

-- Create the Display tab
function OmniCD:CreateDisplayTab(container)
    -- Display options group
    local displayGroup = AceGUI:Create("InlineGroup")
    displayGroup:SetTitle("Display Options")
    displayGroup:SetLayout("Flow")
    displayGroup:SetFullWidth(true)
    container:AddChild(displayGroup)
    
    -- Icon size slider
    local iconSizeSlider = AceGUI:Create("Slider")
    iconSizeSlider:SetLabel("Icon Size")
    iconSizeSlider:SetWidth(300)
    iconSizeSlider:SetSliderValues(16, 64, 1)
    iconSizeSlider:SetValue(VUI.db.profile.modules.omnicd.iconSize)
    iconSizeSlider:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.omnicd.iconSize = value
        OmniCD:SetContainerLayout()
    end)
    displayGroup:AddChild(iconSizeSlider)
    
    -- Icon spacing slider
    local iconSpacingSlider = AceGUI:Create("Slider")
    iconSpacingSlider:SetLabel("Icon Spacing")
    iconSpacingSlider:SetWidth(300)
    iconSpacingSlider:SetSliderValues(0, 10, 1)
    iconSpacingSlider:SetValue(VUI.db.profile.modules.omnicd.iconSpacing)
    iconSpacingSlider:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.omnicd.iconSpacing = value
        OmniCD:SetContainerLayout()
    end)
    displayGroup:AddChild(iconSpacingSlider)
    
    -- Max icons slider
    local maxIconsSlider = AceGUI:Create("Slider")
    maxIconsSlider:SetLabel("Maximum Icons")
    maxIconsSlider:SetWidth(300)
    maxIconsSlider:SetSliderValues(5, 20, 1)
    maxIconsSlider:SetValue(VUI.db.profile.modules.omnicd.maxIcons)
    maxIconsSlider:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.omnicd.maxIcons = value
        OmniCD:SetContainerLayout()
    end)
    displayGroup:AddChild(maxIconsSlider)
    
    -- Growth direction dropdown
    local directionDropdown = AceGUI:Create("Dropdown")
    directionDropdown:SetLabel("Growth Direction")
    directionDropdown:SetWidth(200)
    directionDropdown:SetList({
        ["RIGHT"] = "Right",
        ["LEFT"] = "Left",
        ["UP"] = "Up",
        ["DOWN"] = "Down"
    })
    directionDropdown:SetValue(VUI.db.profile.modules.omnicd.growDirection)
    directionDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.omnicd.growDirection = value
        OmniCD:SetContainerLayout()
    end)
    displayGroup:AddChild(directionDropdown)
end

-- Create the Spells tab
function OmniCD:CreateSpellsTab(container)
    -- Class selection dropdown
    local classDropdown = AceGUI:Create("Dropdown")
    classDropdown:SetLabel("Select Class")
    classDropdown:SetWidth(200)
    
    -- Get class list (WoW version dependent)
    local classList = {}
    local classOrder = {
        "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST", 
        "DEATHKNIGHT", "SHAMAN", "MAGE", "WARLOCK", "MONK", 
        "DRUID", "DEMONHUNTER", "EVOKER"
    }
    
    -- Populate class list with localized names
    for _, className in ipairs(classOrder) do
        local localizedName, englishName = GetClassInfo(className)
        if localizedName then
            classList[className] = localizedName
        end
    end
    
    classDropdown:SetList(classList)
    classDropdown:SetValue("WARRIOR") -- Default to warrior
    
    container:AddChild(classDropdown)
    
    -- Spacer
    container:AddChild(AceGUI:Create("Label"):SetText(" "):SetFullWidth(true))
    
    -- Spells group
    local spellsGroup = AceGUI:Create("InlineGroup")
    spellsGroup:SetTitle("Class Spells")
    spellsGroup:SetLayout("Flow")
    spellsGroup:SetFullWidth(true)
    container:AddChild(spellsGroup)
    
    -- Function to update spells list based on class
    local function UpdateSpellsList(className)
        spellsGroup:ReleaseChildren()
        
        -- Sample spells for demonstration (in a real implementation, this would be dynamic)
        local spells = {
            WARRIOR = {871, 12975, 97462, 107574, 1719, 46924},
            PALADIN = {31850, 86659, 31884, 96231, 105809, 633},
            PRIEST = {33206, 62618, 47788, 47536, 109964, 47536},
            MAGE = {45438, 110960, 113724, 12042, 12051, 11958},
            MONK = {115203, 115176, 115310, 116680, 116844, 137562}
        }
        
        local classSpells = spells[className] or {}
        
        for _, spellID in ipairs(classSpells) do
            local name, _, icon = GetSpellInfo(spellID)
            if name then
                local spellRow = AceGUI:Create("SimpleGroup")
                spellRow:SetLayout("Flow")
                spellRow:SetFullWidth(true)
                
                -- Spell icon
                local iconWidget = AceGUI:Create("Icon")
                iconWidget:SetImage(icon)
                iconWidget:SetImageSize(24, 24)
                iconWidget:SetWidth(30)
                spellRow:AddChild(iconWidget)
                
                -- Spell name
                local nameWidget = AceGUI:Create("Label")
                nameWidget:SetText(name)
                nameWidget:SetWidth(150)
                spellRow:AddChild(nameWidget)
                
                -- Spell ID
                local idWidget = AceGUI:Create("Label")
                idWidget:SetText("ID: " .. spellID)
                idWidget:SetWidth(80)
                spellRow:AddChild(idWidget)
                
                -- Enable/disable
                local enabledCheckbox = AceGUI:Create("CheckBox")
                enabledCheckbox:SetLabel("")
                enabledCheckbox:SetWidth(30)
                enabledCheckbox:SetValue(VUI.db.profile.modules.omnicd.spellFilters[spellID] ~= false)
                enabledCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
                    VUI.db.profile.modules.omnicd.spellFilters[spellID] = value or nil
                end)
                spellRow:AddChild(enabledCheckbox)
                
                spellsGroup:AddChild(spellRow)
            end
        end
    end
    
    -- Initial update
    UpdateSpellsList("WARRIOR")
    
    -- Update when class changes
    classDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        UpdateSpellsList(value)
    end)
end

-- Create the Zones tab
function OmniCD:CreateZonesTab(container)
    -- Zones options group
    local zonesGroup = AceGUI:Create("InlineGroup")
    zonesGroup:SetTitle("Zone Settings")
    zonesGroup:SetLayout("Flow")
    zonesGroup:SetFullWidth(true)
    container:AddChild(zonesGroup)
    
    -- Enable in different zone types
    local zoneTypes = {
        {name = "Arena", key = "ARENA", default = true},
        {name = "Battleground", key = "BATTLEGROUND", default = true},
        {name = "Raid", key = "RAID", default = true},
        {name = "Dungeon", key = "DUNGEON", default = true},
        {name = "World PvP", key = "OUTDOOR_PVP", default = false},
        {name = "Outdoor", key = "OUTDOOR", default = false}
    }
    
    for _, zone in ipairs(zoneTypes) do
        local zoneCheckbox = AceGUI:Create("CheckBox")
        zoneCheckbox:SetLabel("Enable in " .. zone.name)
        zoneCheckbox:SetWidth(200)
        
        -- Initialize settings if missing
        if not VUI.db.profile.modules.omnicd.zoneSettings then 
            VUI.db.profile.modules.omnicd.zoneSettings = {} 
        end
        if not VUI.db.profile.modules.omnicd.zoneSettings[zone.key] then
            VUI.db.profile.modules.omnicd.zoneSettings[zone.key] = {enabled = zone.default}
        end
        
        zoneCheckbox:SetValue(VUI.db.profile.modules.omnicd.zoneSettings[zone.key].enabled)
        zoneCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
            VUI.db.profile.modules.omnicd.zoneSettings[zone.key].enabled = value
        end)
        zonesGroup:AddChild(zoneCheckbox)
    end
end

-- Get options for the config panel
function OmniCD:GetOptions()
    return {
        type = "group",
        name = "OmniCD",
        args = {
            enable = {
                type = "toggle",
                name = "Enable",
                desc = "Enable or disable the OmniCD module",
                order = 1,
                get = function() return VUI:IsModuleEnabled("omnicd") end,
                set = function(_, value)
                    if value then
                        VUI:EnableModule("omnicd")
                    else
                        VUI:DisableModule("omnicd")
                    end
                end,
            },
            general = {
                type = "group",
                name = "General Settings",
                order = 2,
                inline = true,
                disabled = function() return not VUI:IsModuleEnabled("omnicd") end,
                args = {
                    showNames = {
                        type = "toggle",
                        name = "Show Player Names",
                        desc = "Show player names above cooldown icons",
                        order = 1,
                        get = function() return VUI.db.profile.modules.omnicd.showNames end,
                        set = function(_, value)
                            VUI.db.profile.modules.omnicd.showNames = value
                        end,
                    },
                    showCooldownText = {
                        type = "toggle",
                        name = "Show Cooldown Text",
                        desc = "Show the cooldown timer text",
                        order = 2,
                        get = function() return VUI.db.profile.modules.omnicd.showCooldownText end,
                        set = function(_, value)
                            VUI.db.profile.modules.omnicd.showCooldownText = value
                        end,
                    }
                }
            },
            display = {
                type = "group",
                name = "Display Settings",
                order = 3,
                inline = true,
                disabled = function() return not VUI:IsModuleEnabled("omnicd") end,
                args = {
                    iconSize = {
                        type = "range",
                        name = "Icon Size",
                        desc = "The size of cooldown icons",
                        min = 16,
                        max = 64,
                        step = 1,
                        order = 1,
                        get = function() return VUI.db.profile.modules.omnicd.iconSize end,
                        set = function(_, value)
                            VUI.db.profile.modules.omnicd.iconSize = value
                            if OmniCD.SetContainerLayout then
                                OmniCD:SetContainerLayout()
                            end
                        end,
                    },
                    growDirection = {
                        type = "select",
                        name = "Growth Direction",
                        desc = "The direction to grow the cooldown icons",
                        values = {
                            ["RIGHT"] = "Right",
                            ["LEFT"] = "Left",
                            ["UP"] = "Up",
                            ["DOWN"] = "Down"
                        },
                        order = 2,
                        get = function() return VUI.db.profile.modules.omnicd.growDirection end,
                        set = function(_, value)
                            VUI.db.profile.modules.omnicd.growDirection = value
                            if OmniCD.SetContainerLayout then
                                OmniCD:SetContainerLayout()
                            end
                        end,
                    }
                }
            }
        }
    }
end