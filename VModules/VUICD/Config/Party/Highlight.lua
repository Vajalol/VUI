local _, VUI = ...
local E = VUI:GetModule("VUICD")
local P = E.Party
local L = LibStub("AceLocale-3.0"):GetLocale("VUI")

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