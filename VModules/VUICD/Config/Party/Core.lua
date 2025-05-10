local _, VUI = ...
local E = VUI:GetModule("VUICD")
local P = E.Party
local L = LibStub("AceLocale-3.0"):GetLocale("VUI")

function P:AddPartyOptions(option)
    option.general = {
        order = 1,
        type = "group",
        name = L["General"],
        args = {},
    }
    
    option.icons = {
        order = 2,
        type = "group",
        name = L["Icons"],
        args = {},
    }
    
    option.position = {
        order = 3,
        type = "group",
        name = L["Position"],
        args = {},
    }
    
    option.visibility = {
        order = 4,
        type = "group",
        name = L["Visibility"],
        args = {},
    }
    
    option.highlight = {
        order = 5,
        type = "group",
        name = L["Highlight"],
        args = {},
    }
    
    option.priority = {
        order = 6,
        type = "group",
        name = L["Priority"],
        args = {},
    }
    
    option.spells = {
        order = 7,
        type = "group",
        name = L["Spells"],
        args = {},
    }
    
    option.extraBars = {
        order = 8,
        type = "group",
        name = L["Extra Bars"],
        args = {},
    }
    
    -- Load submodule options
    P:AddGeneralOptions(option.general.args)
    P:AddIconsOptions(option.icons.args)
    P:AddPositionOptions(option.position.args)
    P:AddVisibilityOptions(option.visibility.args)
    P:AddHighlightOptions(option.highlight.args)
    P:AddPriorityOptions(option.priority.args)
    P:AddSpellsOptions(option.spells.args)
    P:AddExtraBarsOptions(option.extraBars.args)
end

-- Helper functions for options system
function P:GetLSMTable(lsmType)
    local table = {}
    for k, v in pairs(LibStub("LibSharedMedia-3.0"):HashTable(lsmType)) do
        table[k] = k
    end
    return table
end

function P:GetThemeEnabled()
    local useTheme = E.DB.profile.border.themeBorder
    return useTheme
end

-- Apply theme color to Party module elements
function P:ApplyTheme()
    if not P.bars then
        return
    end
    
    local themeColor = VUI:GetThemeColor()
    
    -- Apply to status bars if theme coloring is enabled
    for i = 1, #P.bars do
        local statusBar = P.bars[i].statusBar
        if statusBar and statusBar.SetStatusBarColor then
            if P:GetThemeEnabled() then
                statusBar:SetStatusBarColor(themeColor.r, themeColor.g, themeColor.b)
            else
                -- Use class color or default color as appropriate
                local classColor = P.bars[i].classColor or {r=0.5, g=0.5, b=0.5}
                statusBar:SetStatusBarColor(classColor.r, classColor.g, classColor.b)
            end
        end
    end
end

-- Create preview of current settings 
function P:CreatePreview(frame)
    if not frame then return end
    
    -- Clear existing content
    frame:ReleaseChildren()
    
    -- Create preview image
    local preview = AceGUI:Create("Icon")
    preview:SetImage("Interface\\AddOns\\VUI\\VModules\\VUICD\\Media\\preview_party.tga")
    preview:SetImageSize(350, 180)
    preview:SetFullWidth(true)
    preview:SetHeight(200)
    frame:AddChild(preview)
    
    -- Add description text
    local desc = AceGUI:Create("Label")
    desc:SetText(L["The party module shows cooldowns from everyone in your party or raid."])
    desc:SetFullWidth(true)
    frame:AddChild(desc)
    
    -- Test button
    local testButton = AceGUI:Create("Button")
    testButton:SetText(L["Test"])
    testButton:SetWidth(100)
    testButton:SetCallback("OnClick", function()
        P:TestMode()
    end)
    frame:AddChild(testButton)
end