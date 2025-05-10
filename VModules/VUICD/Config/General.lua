local _, VUI = ...
local E = VUI:GetModule("VUICD")
local L = LibStub("AceLocale-3.0"):GetLocale("VUI")

-- Add the general options to the option table
function E:AddGeneralOptions(option)
    local themeColorOption = E.DB.profile.border.themeBorder
    
    option.header = {
        order = 1,
        type = "header",
        name = L["General Settings"],
    }
    
    option.enable = {
        order = 2,
        type = "toggle",
        name = L["Enable"],
        desc = L["Enable/disable the module"],
        width = "full",
        get = function()
            return E.DB.profile.enable
        end,
        set = function(_, value)
            E.DB.profile.enable = value
            E:ToggleModule()
        end,
    }
    
    option.showAnchor = {
        order = 3,
        type = "toggle",
        name = L["Show Anchor"],
        desc = L["Show/hide the anchor"],
        get = function()
            return E.DB.profile.showAnchor
        end,
        set = function(_, value)
            E.DB.profile.showAnchor = value
            E:UpdateAnchor()
        end,
        disabled = function() return not E.DB.profile.enable end,
    }
    
    option.mergeHealAbilities = {
        order = 4,
        type = "toggle",
        name = L["Merge Healing Abilities"],
        desc = L["Merge similar healing abilities to reduce clutter"],
        get = function()
            return E.DB.profile.mergeHealAbilities
        end,
        set = function(_, value)
            E.DB.profile.mergeHealAbilities = value
            E:UpdateAllIcons()
        end,
        disabled = function() return not E.DB.profile.enable end,
    }
    
    option.borderHeader = {
        order = 5,
        type = "header",
        name = L["Border Settings"],
    }
    
    option.borderEnabled = {
        order = 6,
        type = "toggle",
        name = L["Enable Border"],
        desc = L["Show a border around cooldown icons"],
        get = function()
            return E.DB.profile.border.enabled
        end,
        set = function(_, value)
            E.DB.profile.border.enabled = value
            E:UpdateBorders()
        end,
        disabled = function() return not E.DB.profile.enable end,
    }
    
    option.borderThickness = {
        order = 7,
        type = "range",
        name = L["Border Thickness"],
        desc = L["Sets the thickness of the border"],
        min = 1, max = 5, step = 1,
        get = function()
            return E.DB.profile.border.thickness
        end,
        set = function(_, value)
            E.DB.profile.border.thickness = value
            E:UpdateBorders()
        end,
        disabled = function() return not E.DB.profile.enable or not E.DB.profile.border.enabled end,
    }
    
    option.borderColoring = {
        order = 8,
        type = "select",
        name = L["Border Coloring"],
        desc = L["Sets how the border should be colored"],
        values = {
            ["class"] = L["Class Color"],
            ["custom"] = L["Custom Color"],
            ["theme"] = L["Theme Color"],
        },
        get = function()
            return E.DB.profile.border.coloring
        end,
        set = function(_, value)
            E.DB.profile.border.coloring = value
            E:UpdateBorders()
        end,
        disabled = function() return not E.DB.profile.enable or not E.DB.profile.border.enabled end,
    }
    
    option.borderColor = {
        order = 9,
        type = "color",
        name = L["Border Color"],
        desc = L["Sets the color for the border"],
        hasAlpha = true,
        get = function()
            local c = E.DB.profile.border.color
            return c.r, c.g, c.b, c.a
        end,
        set = function(_, r, g, b, a)
            local c = E.DB.profile.border.color
            c.r, c.g, c.b, c.a = r, g, b, a
            E:UpdateBorders()
        end,
        disabled = function() 
            return not E.DB.profile.enable or 
                   not E.DB.profile.border.enabled or 
                   E.DB.profile.border.coloring ~= "custom" 
        end,
    }
    
    option.borderTheme = {
        order = 10,
        type = "toggle",
        name = L["Use Theme Color"],
        desc = L["Use the VUI theme color for borders"],
        get = function()
            return E.DB.profile.border.themeBorder
        end,
        set = function(_, value)
            E.DB.profile.border.themeBorder = value
            E:UpdateBorders()
            -- Apply current theme
            E:ApplyTheme()
        end,
        disabled = function() 
            return not E.DB.profile.enable or 
                   not E.DB.profile.border.enabled or 
                   E.DB.profile.border.coloring ~= "theme" 
        end,
    }
    
    option.moduleHeader = {
        order = 11,
        type = "header",
        name = L["Module Settings"],
    }
    
    option.moduleParty = {
        order = 12,
        type = "toggle",
        name = L["Party Module"],
        desc = L["Enable/disable party cooldown tracking"],
        get = function()
            return E.DB.profile.modules.party
        end,
        set = function(_, value)
            E.DB.profile.modules.party = value
            E:ToggleModules()
        end,
        disabled = function() return not E.DB.profile.enable end,
    }
end