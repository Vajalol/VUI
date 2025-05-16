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
    L["Enable Highlighting"] = "Enable Highlighting"
    L["Show highlights when cooldowns are activated"] = "Show highlights when cooldowns are activated"
    L["Shine Effect"] = "Shine Effect"
    L["Show shine effect when a cooldown is activated"] = "Show shine effect when a cooldown is activated"
    L["Glow Effect"] = "Glow Effect"
    L["Show glow effect when a cooldown is activated"] = "Show glow effect when a cooldown is activated"
    L["Highlight Colors"] = "Highlight Colors"
    L["Glow Color"] = "Glow Color"
    L["Set the color for the glow effect"] = "Set the color for the glow effect"
    L["Use Theme Color"] = "Use Theme Color"
    L["Use VUI theme color for highlight effects"] = "Use VUI theme color for highlight effects"
    L["Preview"] = "Preview"
    L["Highlights will appear as"] = "Highlights will appear as"
    L["when cooldowns are activated."] = "when cooldowns are activated."
    L["Currently using VUI theme color."] = "Currently using VUI theme color."
    L["Using custom color."] = "Using custom color."
    L["Test Highlight"] = "Test Highlight"
end

-- Store localization for global use
VUICD.L = VUICD.L or L

-- Local references
local E = VUICD
=======
local E = VUI.VUICD or VUI:GetModule("VUICD")
>>>>>>> f2841d4c299e00869d4563d9e99c5e582069affc
local P = E.Party

-- Ensure Party module DB exists
if not P.db then P.db = {profile = {}} end
if not P.db.profile then P.db.profile = {} end
if not P.db.profile.highlight then P.db.profile.highlight = {enabled = false, shine = true, glow = true, glowColor = {r=1, g=1, b=1}} end

function P:AddHighlightOptions(option)
    option.enabled = {
        order = 1,
        type = "toggle",
        name = L["Enable Highlighting"],
        desc = L["Show highlights when cooldowns are activated"],
        width = "full",
        get = function()
            return P.db.profile.highlight.enabled
        end,
        set = function(_, value)
            P.db.profile.highlight.enabled = value
            P:UpdateHighlights()
        end,
        disabled = function() return not E.DB.profile.modules.party end,
    }
    
    option.shine = {
        order = 2,
        type = "toggle",
        name = L["Shine Effect"],
        desc = L["Show shine effect when a cooldown is activated"],
        get = function()
            return P.db.profile.highlight.shine
        end,
        set = function(_, value)
            P.db.profile.highlight.shine = value
        end,
        disabled = function() 
            return not E.DB.profile.modules.party or 
                   not P.db.profile.highlight.enabled 
        end,
    }
    
    option.glow = {
        order = 3,
        type = "toggle",
        name = L["Glow Effect"],
        desc = L["Show glow effect when a cooldown is activated"],
        get = function()
            return P.db.profile.highlight.glow
        end,
        set = function(_, value)
            P.db.profile.highlight.glow = value
            P:UpdateHighlights()
        end,
        disabled = function() 
            return not E.DB.profile.modules.party or 
                   not P.db.profile.highlight.enabled 
        end,
    }
    
    option.coloringHeader = {
        order = 4,
        type = "header",
        name = L["Highlight Colors"],
    }
    
    option.glowColor = {
        order = 5,
        type = "color",
        name = L["Glow Color"],
        desc = L["Set the color for the glow effect"],
        hasAlpha = false,
        get = function()
            local c = P.db.profile.highlight.glowColor
            return c.r, c.g, c.b
        end,
        set = function(_, r, g, b)
            local c = P.db.profile.highlight.glowColor
            c.r, c.g, c.b = r, g, b
            P:UpdateHighlights()
        end,
        disabled = function() 
            return not E.DB.profile.modules.party or 
                   not P.db.profile.highlight.enabled or
                   not P.db.profile.highlight.glow or
                   P:GetThemeEnabled()
        end,
    }
    
    option.useThemeColors = {
        order = 6,
        type = "toggle",
        name = L["Use Theme Color"],
        desc = L["Use VUI theme color for highlight effects"],
        get = function()
            return P:GetThemeEnabled()
        end,
        set = function(_, value)
            E.DB.profile.border.themeBorder = value
            P:ApplyTheme()
        end,
        disabled = function() 
            return not E.DB.profile.modules.party or 
                   not P.db.profile.highlight.enabled
        end,
    }
    
    option.previewHeader = {
        order = 7,
        type = "header",
        name = L["Preview"],
    }
    
    option.previewDesc = {
        order = 8,
        type = "description",
        name = function()
            -- Get current theme color
            local themeEnabled = P:GetThemeEnabled()
            local color
            
            if themeEnabled then
                local themeColor = VUI:GetThemeColor()
                color = string.format("|cff%.2x%.2x%.2x", 
                    themeColor.r * 255, 
                    themeColor.g * 255, 
                    themeColor.b * 255)
            else
                local glowColor = P.db.profile.highlight.glowColor
                color = string.format("|cff%.2x%.2x%.2x", 
                    glowColor.r * 255, 
                    glowColor.g * 255, 
                    glowColor.b * 255)
            end
            
            return L["Highlights will appear as"] .. " " .. color .. "this color|r " .. 
                   L["when cooldowns are activated."] .. "\n\n" ..
                   (themeEnabled and L["Currently using VUI theme color."] or L["Using custom color."])
        end,
    }
    
    option.testHighlight = {
        order = 9,
        type = "execute",
        name = L["Test Highlight"],
        func = function()
            P:TestHighlight()
        end,
        disabled = function() 
            return not E.DB.profile.modules.party or 
                   not P.db.profile.highlight.enabled
        end,
    }
end