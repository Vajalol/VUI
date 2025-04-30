-- VUI idTip Theme Integration
local _, VUI = ...
local IdTip = VUI.idtip
local Media = VUI.Media

-- ThemeIntegration for idTip module
local ThemeIntegration = {}
IdTip.ThemeIntegration = ThemeIntegration

-- Theme definitions for idTip module
ThemeIntegration.themes = {
    phoenixflame = {
        colors = {
            spell = {r = 0.8, g = 0.4, b = 0.0, a = 1.0},
            item = {r = 0.9, g = 0.3, b = 0.0, a = 1.0},
            quest = {r = 1.0, g = 0.7, b = 0.3, a = 1.0},
            achievement = {r = 1.0, g = 0.8, b = 0.2, a = 1.0},
            currency = {r = 0.9, g = 0.8, b = 0.4, a = 1.0},
            zone = {r = 0.8, g = 0.5, b = 0.2, a = 1.0},
            npc = {r = 0.8, g = 0.6, b = 0.3, a = 1.0},
            mount = {r = 0.9, g = 0.5, b = 0.1, a = 1.0},
            pet = {r = 0.7, g = 0.4, b = 0.2, a = 1.0},
            talent = {r = 0.9, g = 0.6, b = 0.3, a = 1.0},
            default = {r = 1.0, g = 0.8, b = 0.6, a = 1.0}
        },
        fonts = {
            main = Media:GetFont("expressway")
        }
    },
    
    thunderstorm = {
        colors = {
            spell = {r = 0.7, g = 0.8, b = 1.0, a = 1.0},
            item = {r = 1.0, g = 0.7, b = 0.7, a = 1.0},
            quest = {r = 1.0, g = 0.8, b = 0.5, a = 1.0},
            achievement = {r = 0.9, g = 0.8, b = 0.1, a = 1.0},
            currency = {r = 0.9, g = 0.9, b = 0.5, a = 1.0},
            zone = {r = 0.5, g = 0.8, b = 0.9, a = 1.0},
            npc = {r = 0.6, g = 0.7, b = 0.9, a = 1.0},
            mount = {r = 0.5, g = 0.7, b = 1.0, a = 1.0},
            pet = {r = 0.7, g = 0.8, b = 0.9, a = 1.0},
            talent = {r = 0.6, g = 0.8, b = 1.0, a = 1.0},
            default = {r = 0.7, g = 0.85, b = 1.0, a = 1.0}
        },
        fonts = {
            main = Media:GetFont("expressway")
        }
    },
    
    arcanemystic = {
        colors = {
            spell = {r = 0.8, g = 0.5, b = 1.0, a = 1.0},
            item = {r = 0.9, g = 0.6, b = 0.9, a = 1.0},
            quest = {r = 0.8, g = 0.7, b = 1.0, a = 1.0},
            achievement = {r = 0.7, g = 0.6, b = 0.9, a = 1.0},
            currency = {r = 0.8, g = 0.7, b = 0.9, a = 1.0},
            zone = {r = 0.6, g = 0.5, b = 0.9, a = 1.0},
            npc = {r = 0.7, g = 0.5, b = 0.8, a = 1.0},
            mount = {r = 0.7, g = 0.4, b = 0.9, a = 1.0},
            pet = {r = 0.8, g = 0.6, b = 1.0, a = 1.0},
            talent = {r = 0.9, g = 0.7, b = 1.0, a = 1.0},
            default = {r = 0.8, g = 0.6, b = 1.0, a = 1.0}
        },
        fonts = {
            main = Media:GetFont("expressway")
        }
    },
    
    felenergy = {
        colors = {
            spell = {r = 0.5, g = 1.0, b = 0.5, a = 1.0},
            item = {r = 0.6, g = 0.9, b = 0.6, a = 1.0},
            quest = {r = 0.7, g = 1.0, b = 0.7, a = 1.0},
            achievement = {r = 0.6, g = 0.8, b = 0.3, a = 1.0},
            currency = {r = 0.7, g = 0.9, b = 0.5, a = 1.0},
            zone = {r = 0.4, g = 0.8, b = 0.4, a = 1.0},
            npc = {r = 0.5, g = 0.8, b = 0.5, a = 1.0},
            mount = {r = 0.3, g = 0.9, b = 0.3, a = 1.0},
            pet = {r = 0.6, g = 0.9, b = 0.6, a = 1.0},
            talent = {r = 0.4, g = 1.0, b = 0.4, a = 1.0},
            default = {r = 0.6, g = 1.0, b = 0.6, a = 1.0}
        },
        fonts = {
            main = Media:GetFont("expressway")
        }
    }
}

-- Default theme fallback
ThemeIntegration.defaultTheme = "thunderstorm"

-- Get current theme configuration
function ThemeIntegration:GetCurrentTheme()
    local currentThemeName = VUI.db.profile.appearance.theme or self.defaultTheme
    return self.themes[currentThemeName] or self.themes[self.defaultTheme]
end

-- Get color for specific ID type
function ThemeIntegration:GetColorForIdType(idType)
    local theme = self:GetCurrentTheme()
    
    -- Map idType to color key
    local colorKey = "default"
    if idType == "Spell" or idType == "Aura" then
        colorKey = "spell"
    elseif idType == "Item" then
        colorKey = "item"
    elseif idType == "Quest" then
        colorKey = "quest"
    elseif idType == "Achievement" then
        colorKey = "achievement"
    elseif idType == "Currency" then
        colorKey = "currency"
    elseif idType == "Zone" or idType == "Map" then
        colorKey = "zone"
    elseif idType == "NPC" or idType == "Creature" then
        colorKey = "npc"
    elseif idType == "Mount" then
        colorKey = "mount"
    elseif idType == "Pet" or idType == "BattlePet" then
        colorKey = "pet"
    elseif idType == "Talent" or idType == "PvPTalent" then
        colorKey = "talent"
    end
    
    local color = theme.colors[colorKey] or theme.colors.default
    return color.r, color.g, color.b, color.a or 1.0
end

-- Get font for idTip text
function ThemeIntegration:GetFont()
    local theme = self:GetCurrentTheme()
    return theme.fonts.main
end

-- Apply themed colors to tooltip line
function ThemeIntegration:ApplyThemeToLine(line, idType)
    if not line or not idType then return end
    
    local r, g, b, a = self:GetColorForIdType(idType)
    line:SetTextColor(r, g, b, a)
end

-- Initialize theme integration
function ThemeIntegration:Initialize()
    -- Override the AddIdToTooltip function to use themed colors
    local originalAddIdToTooltip = IdTip.AddIdToTooltip
    IdTip.AddIdToTooltip = function(self, tooltip, idType, id, isInline)
        -- First call the original function
        local line = originalAddIdToTooltip(self, tooltip, idType, id, isInline)
        
        -- If a line was added, apply themed colors
        if line then
            ThemeIntegration:ApplyThemeToLine(line, idType)
        end
        
        return line
    end
    
    -- Register for theme change events
    VUI.EventManager:RegisterCallback("VUI_THEME_CHANGED", function(themeName)
        -- Force tooltip refresh when theme changes
        if GameTooltip:IsShown() then
            GameTooltip:Hide()
            GameTooltip:Show()
        end
    end)
end