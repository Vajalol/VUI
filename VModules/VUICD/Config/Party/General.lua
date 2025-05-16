local _, VUI = ...
<<<<<<< HEAD

-- Use global reference pattern to avoid load order issues
_G["VUICD"] = _G["VUICD"] or {}
local VUICD = _G["VUICD"]

-- Ensure Party module exists
VUICD.Party = VUICD.Party or {}

-- Setup localization with fallbacks
local L = {}
local success = pcall(function() L = LibStub("AceLocale-3.0"):GetLocale("VUI") end)
if not success then
    -- Add fallbacks for localization
    L["Enable"] = "Enable"
    L["Enable/disable the party module"] = "Enable/disable the party module"
    L["Show Player"] = "Show Player"
    L["Show your own cooldowns in the party/raid frames"] = "Show your own cooldowns in the party/raid frames"
    L["Show Tooltip"] = "Show Tooltip"
    L["Show tooltips when hovering over cooldown icons"] = "Show tooltips when hovering over cooldown icons"
    L["Show Spell ID in Tooltip"] = "Show Spell ID in Tooltip"
    L["Show spell IDs in tooltips"] = "Show spell IDs in tooltips"
    L["Show Notes in Tooltip"] = "Show Notes in Tooltip"
    L["Show additional notes in tooltips"] = "Show additional notes in tooltips"
    L["Enable Alpha"] = "Enable Alpha"
    L["Enable opacity changes for activated and inactive icons"] = "Enable opacity changes for activated and inactive icons"
    L["Active Alpha"] = "Active Alpha"
    L["Opacity for active cooldowns"] = "Opacity for active cooldowns"
    L["Inactive Alpha"] = "Inactive Alpha"
    L["Opacity for inactive cooldowns"] = "Opacity for inactive cooldowns"
    L["Dim Alpha"] = "Dim Alpha"
    L["Opacity for dimmed cooldown swipes"] = "Opacity for dimmed cooldown swipes"
    L["Fill Alpha"] = "Fill Alpha"
    L["Opacity for cooldown fill color"] = "Opacity for cooldown fill color"
    L["Icon Textures"] = "Icon Textures"
    L["Icon Texture"] = "Icon Texture"
    L["Texture used for the cooldown icons"] = "Texture used for the cooldown icons"
    L["Extra Bar Texture"] = "Extra Bar Texture"
    L["Texture used for the extra bars"] = "Texture used for the extra bars"
    L["Highlight Width"] = "Highlight Width"
    L["Width of the highlight border"] = "Width of the highlight border"
    L["Theme Integration"] = "Theme Integration"
    L["Use VUI Theme Colors"] = "Use VUI Theme Colors"
    L["Apply VUI theme colors to status bars and highlights"] = "Apply VUI theme colors to status bars and highlights"
end

-- Store localization for global use
VUICD.L = VUICD.L or L

-- Local references
local E = VUICD
=======
local E = VUI.VUICD or VUI:GetModule("VUICD")
>>>>>>> f2841d4c299e00869d4563d9e99c5e582069affc
local P = E.Party

function P:AddGeneralOptions(option)
    option.enable = {
        order = 1,
        type = "toggle",
        name = L["Enable"],
        desc = L["Enable/disable the party module"],
        width = "full",
        get = function() 
            return E.DB.profile.modules.party
        end,
        set = function(_, value)
            E.DB.profile.modules.party = value
            E:ToggleModules()
        end,
    }
    
    option.showPlayer = {
        order = 2,
        type = "toggle",
        name = L["Show Player"],
        desc = L["Show your own cooldowns in the party/raid frames"],
        get = function()
            return P.db.profile.general.showPlayer
        end,
        set = function(_, value)
            P.db.profile.general.showPlayer = value
            P:Refresh()
        end,
        disabled = function() return not E.DB.profile.modules.party end,
    }
    
    option.showTooltip = {
        order = 3,
        type = "toggle",
        name = L["Show Tooltip"],
        desc = L["Show tooltips when hovering over cooldown icons"],
        get = function()
            return P.db.profile.general.showTooltip
        end,
        set = function(_, value)
            P.db.profile.general.showTooltip = value
        end,
        disabled = function() return not E.DB.profile.modules.party end,
    }
    
    option.showTooltipID = {
        order = 4,
        type = "toggle",
        name = L["Show Spell ID in Tooltip"],
        desc = L["Show spell IDs in tooltips"],
        get = function()
            return P.db.profile.general.showTooltipID
        end,
        set = function(_, value)
            P.db.profile.general.showTooltipID = value
        end,
        disabled = function() 
            return not E.DB.profile.modules.party or 
                   not P.db.profile.general.showTooltip 
        end,
    }
    
    option.showNotes = {
        order = 5,
        type = "toggle",
        name = L["Show Notes in Tooltip"],
        desc = L["Show additional notes in tooltips"],
        get = function()
            return P.db.profile.general.showTooltipNotes
        end,
        set = function(_, value)
            P.db.profile.general.showTooltipNotes = value
        end,
        disabled = function() 
            return not E.DB.profile.modules.party or 
                   not P.db.profile.general.showTooltip 
        end,
    }
    
    option.enableAlpha = {
        order = 6,
        type = "toggle",
        name = L["Enable Alpha"],
        desc = L["Enable opacity changes for activated and inactive icons"],
        get = function()
            return P.db.profile.general.enableAlpha
        end,
        set = function(_, value)
            P.db.profile.general.enableAlpha = value
            P:UpdateActiveIcons()
        end,
        disabled = function() return not E.DB.profile.modules.party end,
    }
    
    option.activeAlpha = {
        order = 7,
        type = "range",
        name = L["Active Alpha"],
        desc = L["Opacity for active cooldowns"],
        min = 0, max = 1, step = 0.01,
        get = function()
            return P.db.profile.general.activeAlpha
        end,
        set = function(_, value)
            P.db.profile.general.activeAlpha = value
            P:UpdateActiveIcons()
        end,
        disabled = function() 
            return not E.DB.profile.modules.party or 
                   not P.db.profile.general.enableAlpha 
        end,
    }
    
    option.inactiveAlpha = {
        order = 8,
        type = "range",
        name = L["Inactive Alpha"],
        desc = L["Opacity for inactive cooldowns"],
        min = 0, max = 1, step = 0.01,
        get = function()
            return P.db.profile.general.inactiveAlpha
        end,
        set = function(_, value)
            P.db.profile.general.inactiveAlpha = value
            P:UpdateActiveIcons()
        end,
        disabled = function() 
            return not E.DB.profile.modules.party or 
                   not P.db.profile.general.enableAlpha 
        end,
    }
    
    option.dimAlpha = {
        order = 9,
        type = "range",
        name = L["Dim Alpha"],
        desc = L["Opacity for dimmed cooldown swipes"],
        min = 0, max = 1, step = 0.01,
        get = function()
            return P.db.profile.general.dimAlpha
        end,
        set = function(_, value)
            P.db.profile.general.dimAlpha = value
            P:UpdateAllSwipes()
        end,
        disabled = function() return not E.DB.profile.modules.party end,
    }
    
    option.fillAlpha = {
        order = 10,
        type = "range",
        name = L["Fill Alpha"],
        desc = L["Opacity for cooldown fill color"],
        min = 0, max = 1, step = 0.01,
        get = function()
            return P.db.profile.general.fillAlpha
        end,
        set = function(_, value)
            P.db.profile.general.fillAlpha = value
            P:UpdateAllSwipes()
        end,
        disabled = function() return not E.DB.profile.modules.party end,
    }
    
    option.iconTextureHeader = {
        order = 11,
        type = "header",
        name = L["Icon Textures"],
    }
    
    option.iconTexture = {
        order = 12,
        type = "select",
        dialogControl = 'LSM30_Statusbar',
        name = L["Icon Texture"],
        desc = L["Texture used for the cooldown icons"],
        values = function() return P:GetLSMTable("statusbar") end,
        get = function()
            return P.db.profile.general.iconTexture
        end,
        set = function(_, value)
            P.db.profile.general.iconTexture = value
            P:UpdateAllIcons()
        end,
        disabled = function() return not E.DB.profile.modules.party end,
    }
    
    option.extraBarTexture = {
        order = 13,
        type = "select",
        dialogControl = 'LSM30_Statusbar',
        name = L["Extra Bar Texture"],
        desc = L["Texture used for the extra bars"],
        values = function() return P:GetLSMTable("statusbar") end,
        get = function()
            return P.db.profile.general.extraBarTexture
        end,
        set = function(_, value)
            P.db.profile.general.extraBarTexture = value
            P:UpdateExtraBars()
        end,
        disabled = function() return not E.DB.profile.modules.party end,
    }
    
    option.highlightWidth = {
        order = 14,
        type = "range",
        name = L["Highlight Width"],
        desc = L["Width of the highlight border"],
        min = 1, max = 3, step = 1,
        get = function()
            return P.db.profile.general.highlightWidth
        end,
        set = function(_, value)
            P.db.profile.general.highlightWidth = value
            P:UpdateHighlights()
        end,
        disabled = function() return not E.DB.profile.modules.party end,
    }
    
    option.themeHeader = {
        order = 15,
        type = "header",
        name = L["Theme Integration"],
    }
    
    option.useThemeColors = {
        order = 16,
        type = "toggle",
        name = L["Use VUI Theme Colors"],
        desc = L["Apply VUI theme colors to status bars and highlights"],
        get = function()
            return P:GetThemeEnabled()
        end,
        set = function(_, value)
            E.DB.profile.border.themeBorder = value
            P:ApplyTheme()
        end,
        disabled = function() return not E.DB.profile.modules.party end,
    }
end