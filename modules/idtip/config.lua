-- idTip Config Implementation
-- This file contains the configuration options for the idTip module
local _, VUI = ...
local idTip = VUI.idtip
local AceGUI = LibStub("AceGUI-3.0")

-- Function to create a standalone configuration panel
function idTip:CreateConfigPanel()
    -- Create a frame
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("VUI idTip Configuration")
    frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    frame:SetLayout("Flow")
    frame:SetWidth(550)
    frame:SetHeight(500)
    
    -- Create the content
    self:CreateGeneralOptions(frame)
    
    return frame
end

-- Create general options section
function idTip:CreateGeneralOptions(container)
    -- Enable/disable toggle
    local enableCheckbox = AceGUI:Create("CheckBox")
    enableCheckbox:SetLabel("Enable idTip")
    enableCheckbox:SetWidth(200)
    enableCheckbox:SetValue(VUI:IsModuleEnabled("idtip"))
    enableCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        if value then
            VUI:EnableModule("idtip")
        else
            VUI:DisableModule("idtip")
        end
    end)
    container:AddChild(enableCheckbox)
    
    -- Spacer
    container:AddChild(AceGUI:Create("Label"):SetText(" "):SetFullWidth(true))
    
    -- Display options group
    local displayGroup = AceGUI:Create("InlineGroup")
    displayGroup:SetTitle("Display Options")
    displayGroup:SetLayout("Flow")
    displayGroup:SetFullWidth(true)
    container:AddChild(displayGroup)
    
    -- Show aura IDs checkbox
    local auraCheckbox = AceGUI:Create("CheckBox")
    auraCheckbox:SetLabel("Show Aura IDs")
    auraCheckbox:SetWidth(200)
    auraCheckbox:SetValue(VUI.db.profile.modules.idtip.showAuraIDs)
    auraCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.idtip.showAuraIDs = value
    end)
    displayGroup:AddChild(auraCheckbox)
    
    -- Show item tooltips in color
    local colorItemsCheckbox = AceGUI:Create("CheckBox")
    colorItemsCheckbox:SetLabel("Color Item IDs")
    colorItemsCheckbox:SetWidth(200)
    colorItemsCheckbox:SetValue(VUI.db.profile.modules.idtip.colorItems or true)
    colorItemsCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.idtip.colorItems = value
    end)
    displayGroup:AddChild(colorItemsCheckbox)
    
    -- Show spell tooltips in color
    local colorSpellsCheckbox = AceGUI:Create("CheckBox")
    colorSpellsCheckbox:SetLabel("Color Spell IDs")
    colorSpellsCheckbox:SetWidth(200)
    colorSpellsCheckbox:SetValue(VUI.db.profile.modules.idtip.colorSpells or true)
    colorSpellsCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.idtip.colorSpells = value
    end)
    displayGroup:AddChild(colorSpellsCheckbox)
    
    -- Show quest tooltips in color
    local colorQuestsCheckbox = AceGUI:Create("CheckBox")
    colorQuestsCheckbox:SetLabel("Color Quest IDs")
    colorQuestsCheckbox:SetWidth(200)
    colorQuestsCheckbox:SetValue(VUI.db.profile.modules.idtip.colorQuests or true)
    colorQuestsCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.idtip.colorQuests = value
    end)
    displayGroup:AddChild(colorQuestsCheckbox)
    
    -- Show achievement tooltips in color
    local colorAchievementsCheckbox = AceGUI:Create("CheckBox")
    colorAchievementsCheckbox:SetLabel("Color Achievement IDs")
    colorAchievementsCheckbox:SetWidth(200)
    colorAchievementsCheckbox:SetValue(VUI.db.profile.modules.idtip.colorAchievements or true)
    colorAchievementsCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.idtip.colorAchievements = value
    end)
    displayGroup:AddChild(colorAchievementsCheckbox)
    
    -- Tooltip types group
    local typesGroup = AceGUI:Create("InlineGroup")
    typesGroup:SetTitle("Tooltip Types")
    typesGroup:SetLayout("Flow")
    typesGroup:SetFullWidth(true)
    container:AddChild(typesGroup)
    
    -- Create checkboxes for tooltip types
    local tooltipTypes = {
        {name = "Items", value = "showItems", default = true},
        {name = "Spells", value = "showSpells", default = true},
        {name = "Achievements", value = "showAchievements", default = true},
        {name = "Quests", value = "showQuests", default = true},
        {name = "NPCs", value = "showNPCs", default = true},
        {name = "Mounts", value = "showMounts", default = true},
        {name = "Currencies", value = "showCurrencies", default = true},
        {name = "Maps", value = "showMaps", default = true}
    }
    
    for _, type in ipairs(tooltipTypes) do
        -- Initialize setting if not exists
        if VUI.db.profile.modules.idtip[type.value] == nil then
            VUI.db.profile.modules.idtip[type.value] = type.default
        end
        
        local checkbox = AceGUI:Create("CheckBox")
        checkbox:SetLabel("Show " .. type.name .. " IDs")
        checkbox:SetWidth(200)
        checkbox:SetValue(VUI.db.profile.modules.idtip[type.value])
        checkbox:SetCallback("OnValueChanged", function(widget, event, value)
            VUI.db.profile.modules.idtip[type.value] = value
        end)
        typesGroup:AddChild(checkbox)
    end
    
    -- Advanced options group
    local advancedGroup = AceGUI:Create("InlineGroup")
    advancedGroup:SetTitle("Advanced Options")
    advancedGroup:SetLayout("Flow")
    advancedGroup:SetFullWidth(true)
    container:AddChild(advancedGroup)
    
    -- Show extra info checkbox
    local extraInfoCheckbox = AceGUI:Create("CheckBox")
    extraInfoCheckbox:SetLabel("Show Extra Information")
    extraInfoCheckbox:SetWidth(200)
    extraInfoCheckbox:SetValue(VUI.db.profile.modules.idtip.showExtraInfo or true)
    extraInfoCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.idtip.showExtraInfo = value
    end)
    advancedGroup:AddChild(extraInfoCheckbox)
    
    -- Add to shared tooltip checkbox
    local sharedTooltipCheckbox = AceGUI:Create("CheckBox")
    sharedTooltipCheckbox:SetLabel("Add to Shared Tooltips")
    sharedTooltipCheckbox:SetWidth(200)
    sharedTooltipCheckbox:SetValue(VUI.db.profile.modules.idtip.useSharedTooltips or true)
    sharedTooltipCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.idtip.useSharedTooltips = value
    end)
    advancedGroup:AddChild(sharedTooltipCheckbox)
end

-- Get options for the config panel
function idTip:GetOptions()
    return {
        type = "group",
        name = "idTip",
        args = {
            enable = {
                type = "toggle",
                name = "Enable",
                desc = "Enable or disable the idTip module",
                order = 1,
                get = function() return VUI:IsModuleEnabled("idtip") end,
                set = function(_, value)
                    if value then
                        VUI:EnableModule("idtip")
                    else
                        VUI:DisableModule("idtip")
                    end
                end,
            },
            general = {
                type = "group",
                name = "General Settings",
                order = 2,
                inline = true,
                disabled = function() return not VUI:IsModuleEnabled("idtip") end,
                args = {
                    showAuraIDs = {
                        type = "toggle",
                        name = "Show Aura IDs",
                        desc = "Show spell IDs for auras on unit tooltips",
                        order = 1,
                        get = function() return VUI.db.profile.modules.idtip.showAuraIDs end,
                        set = function(_, value)
                            VUI.db.profile.modules.idtip.showAuraIDs = value
                        end,
                    },
                    showExtraInfo = {
                        type = "toggle",
                        name = "Show Extra Information",
                        desc = "Show additional information where available (bonus IDs, item levels, etc.)",
                        order = 2,
                        get = function() return VUI.db.profile.modules.idtip.showExtraInfo end,
                        set = function(_, value)
                            VUI.db.profile.modules.idtip.showExtraInfo = value
                        end,
                    }
                }
            },
            tooltipTypes = {
                type = "group",
                name = "Tooltip Types",
                order = 3,
                inline = true,
                disabled = function() return not VUI:IsModuleEnabled("idtip") end,
                args = {
                    showItems = {
                        type = "toggle",
                        name = "Items",
                        desc = "Show IDs on item tooltips",
                        order = 1,
                        get = function() return VUI.db.profile.modules.idtip.showItems end,
                        set = function(_, value)
                            VUI.db.profile.modules.idtip.showItems = value
                        end,
                    },
                    showSpells = {
                        type = "toggle",
                        name = "Spells",
                        desc = "Show IDs on spell tooltips",
                        order = 2,
                        get = function() return VUI.db.profile.modules.idtip.showSpells end,
                        set = function(_, value)
                            VUI.db.profile.modules.idtip.showSpells = value
                        end,
                    },
                    showQuests = {
                        type = "toggle",
                        name = "Quests",
                        desc = "Show IDs on quest tooltips",
                        order = 3,
                        get = function() return VUI.db.profile.modules.idtip.showQuests end,
                        set = function(_, value)
                            VUI.db.profile.modules.idtip.showQuests = value
                        end,
                    },
                    showNPCs = {
                        type = "toggle",
                        name = "NPCs",
                        desc = "Show IDs on NPC tooltips",
                        order = 4,
                        get = function() return VUI.db.profile.modules.idtip.showNPCs end,
                        set = function(_, value)
                            VUI.db.profile.modules.idtip.showNPCs = value
                        end,
                    }
                }
            }
        }
    }
end