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
        {text = "Healer Spells", value = "healerspells"},
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
        elseif group == "healerspells" then
            self:CreateHealerSpellsTab(container)
        elseif group == "spells" then
            self:CreateSpellsTab(container)
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
    sizeSlider:SetValue(VUI.db.profile.modules.buffoverlay.iconSize)
    sizeSlider:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.buffoverlay.iconSize = value
        BuffOverlay:SetupFrames()
    end)
    container:AddChild(sizeSlider)
end

-- Create the Display tab
function BuffOverlay:CreateDisplayTab(container)
    -- Icon backdrop color picker
    local backdropColor = AceGUI:Create("ColorPicker")
    backdropColor:SetLabel("Icon Background Color")
    backdropColor:SetWidth(200)
    backdropColor:SetColor(
        VUI.db.profile.modules.buffoverlay.backdropColor.r or 0,
        VUI.db.profile.modules.buffoverlay.backdropColor.g or 0,
        VUI.db.profile.modules.buffoverlay.backdropColor.b or 0,
        VUI.db.profile.modules.buffoverlay.backdropColor.a or 1
    )
    backdropColor:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
        VUI.db.profile.modules.buffoverlay.backdropColor = {r = r, g = g, b = b, a = a}
        BuffOverlay:UpdateSettings()
    end)
    container:AddChild(backdropColor)
end

-- Create the Filters tab
function BuffOverlay:CreateFiltersTab(container)
    -- Track self buffs
    local selfBuffsCheckbox = AceGUI:Create("CheckBox")
    selfBuffsCheckbox:SetLabel("Track Self Buffs")
    selfBuffsCheckbox:SetWidth(200)
    selfBuffsCheckbox:SetValue(VUI.db.profile.modules.buffoverlay.trackSelfBuffs)
    selfBuffsCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.buffoverlay.trackSelfBuffs = value
    end)
    container:AddChild(selfBuffsCheckbox)
    
    -- Track target buffs
    local targetBuffsCheckbox = AceGUI:Create("CheckBox")
    targetBuffsCheckbox:SetLabel("Track Target Buffs")
    targetBuffsCheckbox:SetWidth(200)
    targetBuffsCheckbox:SetValue(VUI.db.profile.modules.buffoverlay.trackTargetBuffs)
    targetBuffsCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.buffoverlay.trackTargetBuffs = value
    end)
    container:AddChild(targetBuffsCheckbox)
end

-- Create the Healer Spells tab
function BuffOverlay:CreateHealerSpellsTab(container)
    -- Header with description
    local header = AceGUI:Create("Heading")
    header:SetText("PvE Healer Spell Tracking")
    header:SetFullWidth(true)
    container:AddChild(header)
    
    local desc = AceGUI:Create("Label")
    desc:SetText("Track important healer spells in Mythic+ dungeons and raids. These spells are updated for The War Within Season 2 based on Wowhead recommendations.")
    desc:SetFullWidth(true)
    container:AddChild(desc)
    
    -- Spacer
    container:AddChild(AceGUI:Create("Label"):SetText(" "):SetFullWidth(true))
    
    -- Enable healer spell tracking
    local trackHealerSpellsCheckbox = AceGUI:Create("CheckBox")
    trackHealerSpellsCheckbox:SetLabel("Track Healer Spells")
    trackHealerSpellsCheckbox:SetWidth(200)
    trackHealerSpellsCheckbox:SetValue(VUI.db.profile.modules.buffoverlay.trackHealerSpells)
    trackHealerSpellsCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.buffoverlay.trackHealerSpells = value
        BuffOverlay:UpdateAuras("player")
        BuffOverlay:UpdateAuras("target")
        BuffOverlay:UpdateAuras("focus")
    end)
    container:AddChild(trackHealerSpellsCheckbox)
    
    -- Show notifications for healer spells
    local showHealerSpellNotificationsCheckbox = AceGUI:Create("CheckBox")
    showHealerSpellNotificationsCheckbox:SetLabel("Show Notifications for Healer Spells")
    showHealerSpellNotificationsCheckbox:SetWidth(300)
    showHealerSpellNotificationsCheckbox:SetValue(VUI.db.profile.modules.buffoverlay.showHealerSpellNotifications)
    showHealerSpellNotificationsCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.buffoverlay.showHealerSpellNotifications = value
    end)
    container:AddChild(showHealerSpellNotificationsCheckbox)
    
    -- Spacer
    container:AddChild(AceGUI:Create("Label"):SetText(" "):SetFullWidth(true))
    
    -- Create a scroll frame to display the healer spells
    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("Flow")
    scrollFrame:SetFullWidth(true)
    scrollFrame:SetHeight(300)
    container:AddChild(scrollFrame)
    
    -- Create heading for each healer class
    local classes = {
        {"Restoration Druid", 7},
        {"Holy Paladin", 2},
        {"Restoration Shaman", 7},
        {"Holy Priest", 5},
        {"Discipline Priest", 5},
        {"Mistweaver Monk", 10},
        {"Preservation Evoker", 13}
    }
    
    local classColors = {
        [2] = {r = 0.96, g = 0.55, b = 0.73}, -- Paladin (pink)
        [5] = {r = 1.0, g = 1.0, b = 1.0},   -- Priest (white)
        [7] = {r = 0.0, g = 0.44, b = 0.87}, -- Shaman (blue)
        [10] = {r = 0.0, g = 1.0, b = 0.59}, -- Monk (green)
        [13] = {r = 0.2, g = 0.58, b = 0.5} -- Evoker (teal)
    }
    
    for _, classInfo in ipairs(classes) do
        local className, classID = unpack(classInfo)
        
        local classHeader = AceGUI:Create("Heading")
        classHeader:SetText(className)
        classHeader:SetFullWidth(true)
        
        -- Set class color if available
        if classColors[classID] then
            local color = classColors[classID]
            classHeader:SetColor(color.r, color.g, color.b)
        end
        
        scrollFrame:AddChild(classHeader)
        
        -- Display spells for this class
        local spellCount = 0
        for spellID, _ in pairs(self.HealerSpells) do
            local name, _, icon = GetSpellInfo(spellID)
            if name then
                -- Here we would determine if the spell belongs to the current class
                -- For simplicity, we're just displaying them based on our predefined order
                -- A more sophisticated implementation would filter by class
                
                local spellGroup = AceGUI:Create("SimpleGroup")
                spellGroup:SetLayout("Flow")
                spellGroup:SetFullWidth(true)
                
                -- Spell icon
                local iconWidget = AceGUI:Create("Icon")
                iconWidget:SetImage(icon)
                iconWidget:SetImageSize(24, 24)
                iconWidget:SetWidth(30)
                spellGroup:AddChild(iconWidget)
                
                -- Spell name
                local nameWidget = AceGUI:Create("Label")
                nameWidget:SetText(name .. " (" .. spellID .. ")")
                nameWidget:SetWidth(300)
                spellGroup:AddChild(nameWidget)
                
                scrollFrame:AddChild(spellGroup)
                spellCount = spellCount + 1
                
                -- Break after 8 spells for each class to keep the display manageable
                if spellCount >= 8 then
                    break
                end
            end
        end
        
        -- Add a spacer between classes
        scrollFrame:AddChild(AceGUI:Create("Label"):SetText(" "):SetFullWidth(true))
    end
end

-- Create the Spells tab
function BuffOverlay:CreateSpellsTab(container)
    -- Spell list table
    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("Flow")
    scrollFrame:SetFullWidth(true)
    scrollFrame:SetHeight(400)
    container:AddChild(scrollFrame)
    
    -- Add header
    scrollFrame:AddChild(AceGUI:Create("Heading"):SetText("Tracked Spells"):SetFullWidth(true))
    
    -- Process spell list
    for spellID, spellData in pairs(VUI.db.profile.modules.buffoverlay.spells) do
        local name, _, icon = GetSpellInfo(spellID)
        if name then
            local spellGroup = AceGUI:Create("SimpleGroup")
            spellGroup:SetLayout("Flow")
            spellGroup:SetFullWidth(true)
            
            -- Spell icon
            local iconWidget = AceGUI:Create("Icon")
            iconWidget:SetImage(icon)
            iconWidget:SetImageSize(24, 24)
            iconWidget:SetWidth(30)
            spellGroup:AddChild(iconWidget)
            
            -- Spell name
            local nameWidget = AceGUI:Create("Label")
            nameWidget:SetText(name)
            nameWidget:SetWidth(150)
            spellGroup:AddChild(nameWidget)
            
            -- Remove button
            local removeButton = AceGUI:Create("Button")
            removeButton:SetText("Remove")
            removeButton:SetWidth(80)
            removeButton:SetCallback("OnClick", function()
                VUI.db.profile.modules.buffoverlay.spells[spellID] = nil
                self:CreateSpellsTab(container) -- Refresh tab
            end)
            spellGroup:AddChild(removeButton)
            
            scrollFrame:AddChild(spellGroup)
        end
    end
    
    -- Add spell section
    scrollFrame:AddChild(AceGUI:Create("Heading"):SetText("Add New Spell"):SetFullWidth(true))
    
    local addGroup = AceGUI:Create("SimpleGroup")
    addGroup:SetLayout("Flow")
    addGroup:SetFullWidth(true)
    
    -- Spell input
    local spellInput = AceGUI:Create("EditBox")
    spellInput:SetLabel("Spell ID or Name")
    spellInput:SetWidth(200)
    addGroup:AddChild(spellInput)
    
    -- Add button
    local addButton = AceGUI:Create("Button")
    addButton:SetText("Add Spell")
    addButton:SetWidth(100)
    addButton:SetCallback("OnClick", function()
        local input = spellInput:GetText()
        local spellID = tonumber(input)
        
        -- If it's not a number, try to look up the spell ID by name
        if not spellID then
            spellID = select(7, GetSpellInfo(input))
        end
        
        if spellID then
            VUI.db.profile.modules.buffoverlay.spells[spellID] = true
            print("Added " .. (GetSpellInfo(spellID) or input) .. " to BuffOverlay tracked spells")
            self:CreateSpellsTab(container) -- Refresh tab
        else
            print("Invalid spell ID or name")
        end
    end)
    addGroup:AddChild(addButton)
    
    scrollFrame:AddChild(addGroup)
end

-- Update settings
function BuffOverlay:UpdateSettings()
    local settings = VUI.db.profile.modules.buffoverlay
    
    -- Update container scale
    if self.container then
        self.container:SetScale(settings.scale)
    end
    
    -- Re-create frames with new settings
    self:SetupFrames()
end

-- Get options for the config panel
function BuffOverlay:GetOptions()
    return {
        type = "group",
        name = "BuffOverlay",
        args = {
            enable = {
                type = "toggle",
                name = "Enable",
                desc = "Enable or disable the BuffOverlay module",
                order = 1,
                get = function() return VUI:IsModuleEnabled("buffoverlay") end,
                set = function(_, value)
                    if value then
                        VUI:EnableModule("buffoverlay")
                    else
                        VUI:DisableModule("buffoverlay")
                    end
                end,
            },
            general = {
                type = "group",
                name = "General Settings",
                order = 2,
                inline = true,
                disabled = function() return not VUI:IsModuleEnabled("buffoverlay") end,
                args = {
                    scale = {
                        type = "range",
                        name = "Scale",
                        desc = "Adjust the scale of the spell icons",
                        min = 0.5,
                        max = 2.0,
                        step = 0.05,
                        order = 1,
                        get = function() return VUI.db.profile.modules.buffoverlay.scale end,
                        set = function(_, value)
                            VUI.db.profile.modules.buffoverlay.scale = value
                            BuffOverlay:UpdateSettings()
                        end,
                    },
                    iconSize = {
                        type = "range",
                        name = "Icon Size",
                        desc = "Size of the buff icons",
                        min = 16,
                        max = 64,
                        step = 1,
                        order = 2,
                        get = function() return VUI.db.profile.modules.buffoverlay.iconSize end,
                        set = function(_, value)
                            VUI.db.profile.modules.buffoverlay.iconSize = value
                            BuffOverlay:SetupFrames()
                        end,
                    }
                }
            }
        }
    }
end