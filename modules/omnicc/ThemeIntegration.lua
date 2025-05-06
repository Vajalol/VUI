-- VUI OmniCC Theme Integration
local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end
local OmniCC = VUI.omnicc
local Media = VUI.Media

-- ThemeIntegration for OmniCC module
local ThemeIntegration = {}
OmniCC.ThemeIntegration = ThemeIntegration

-- Theme definitions
ThemeIntegration.themes = {
    phoenixflame = {
        colors = {
            days = {r = 0.8, g = 0.6, b = 0.4, a = 1.0},
            hours = {r = 0.9, g = 0.7, b = 0.4, a = 1.0},
            minutes = {r = 1.0, g = 0.7, b = 0.3, a = 1.0},
            seconds = {r = 1.0, g = 0.6, b = 0.2, a = 1.0},
            milliseconds = {r = 1.0, g = 0.4, b = 0.0, a = 1.0}
        },
        textures = {
            shine = "Interface\\AddOns\\VUI\\media\\themes\\phoenixflame\\effects\\shine",
            pulse = "Interface\\AddOns\\VUI\\media\\themes\\phoenixflame\\effects\\pulse",
            flare = "Interface\\AddOns\\VUI\\media\\themes\\phoenixflame\\effects\\flare",
            sparkle = "Interface\\AddOns\\VUI\\media\\themes\\phoenixflame\\effects\\sparkle"
        },
        fonts = {
            regular = Media:GetFont("expressway"),
            bold = Media:GetFont("expressway_bold")
        },
        effects = {
            finishColor = {r = 1.0, g = 0.4, b = 0.0, a = 0.7},
            glowIntensity = 0.8,
            pulseDuration = 0.8,
            shineDuration = 0.6
        }
    },
    thunderstorm = {
        colors = {
            days = {r = 0.4, g = 0.6, b = 0.8, a = 1.0},
            hours = {r = 0.4, g = 0.7, b = 0.9, a = 1.0},
            minutes = {r = 0.3, g = 0.7, b = 1.0, a = 1.0},
            seconds = {r = 0.2, g = 0.6, b = 1.0, a = 1.0},
            milliseconds = {r = 0.0, g = 0.4, b = 1.0, a = 1.0}
        },
        textures = {
            shine = "Interface\\AddOns\\VUI\\media\\themes\\thunderstorm\\effects\\shine",
            pulse = "Interface\\AddOns\\VUI\\media\\themes\\thunderstorm\\effects\\pulse",
            flare = "Interface\\AddOns\\VUI\\media\\themes\\thunderstorm\\effects\\flare",
            sparkle = "Interface\\AddOns\\VUI\\media\\themes\\thunderstorm\\effects\\sparkle"
        },
        fonts = {
            regular = Media:GetFont("expressway"),
            bold = Media:GetFont("expressway_bold")
        },
        effects = {
            finishColor = {r = 0.0, g = 0.4, b = 1.0, a = 0.7},
            glowIntensity = 0.7,
            pulseDuration = 0.7,
            shineDuration = 0.55
        }
    },
    arcanemystic = {
        colors = {
            days = {r = 0.6, g = 0.4, b = 0.8, a = 1.0},
            hours = {r = 0.7, g = 0.4, b = 0.9, a = 1.0},
            minutes = {r = 0.7, g = 0.3, b = 1.0, a = 1.0},
            seconds = {r = 0.6, g = 0.2, b = 1.0, a = 1.0},
            milliseconds = {r = 0.4, g = 0.0, b = 1.0, a = 1.0}
        },
        textures = {
            shine = "Interface\\AddOns\\VUI\\media\\themes\\arcanemystic\\effects\\shine",
            pulse = "Interface\\AddOns\\VUI\\media\\themes\\arcanemystic\\effects\\pulse",
            flare = "Interface\\AddOns\\VUI\\media\\themes\\arcanemystic\\effects\\flare",
            sparkle = "Interface\\AddOns\\VUI\\media\\themes\\arcanemystic\\effects\\sparkle"
        },
        fonts = {
            regular = Media:GetFont("expressway"),
            bold = Media:GetFont("expressway_bold")
        },
        effects = {
            finishColor = {r = 0.4, g = 0.0, b = 1.0, a = 0.7},
            glowIntensity = 0.8,
            pulseDuration = 0.75,
            shineDuration = 0.55
        }
    },
    felenergy = {
        colors = {
            days = {r = 0.4, g = 0.8, b = 0.4, a = 1.0},
            hours = {r = 0.4, g = 0.9, b = 0.4, a = 1.0},
            minutes = {r = 0.3, g = 1.0, b = 0.3, a = 1.0},
            seconds = {r = 0.2, g = 1.0, b = 0.2, a = 1.0},
            milliseconds = {r = 0.0, g = 1.0, b = 0.0, a = 1.0}
        },
        textures = {
            shine = "Interface\\AddOns\\VUI\\media\\themes\\felenergy\\effects\\shine",
            pulse = "Interface\\AddOns\\VUI\\media\\themes\\felenergy\\effects\\pulse",
            flare = "Interface\\AddOns\\VUI\\media\\themes\\felenergy\\effects\\flare",
            sparkle = "Interface\\AddOns\\VUI\\media\\themes\\felenergy\\effects\\sparkle"
        },
        fonts = {
            regular = Media:GetFont("expressway"),
            bold = Media:GetFont("expressway_bold")
        },
        effects = {
            finishColor = {r = 0.0, g = 1.0, b = 0.3, a = 0.7},
            glowIntensity = 0.9,
            pulseDuration = 0.65,
            shineDuration = 0.5
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

-- Apply theme colors to cooldown text
function ThemeIntegration:ApplyThemeColors(cooldownText, timeLeft)
    if not cooldownText then return end
    
    local theme = self:GetCurrentTheme()
    local colorType = "seconds" -- Default
    
    if timeLeft then
        if timeLeft > 86400 then -- Days (>24h)
            colorType = "days"
        elseif timeLeft > 3600 then -- Hours (>1h)
            colorType = "hours"
        elseif timeLeft > 60 then -- Minutes (>1m)
            colorType = "minutes"
        elseif timeLeft > 0 then -- Seconds
            colorType = "seconds"
        else -- About to expire or expired
            colorType = "milliseconds"
        end
    end
    
    local color = theme.colors[colorType]
    cooldownText:SetTextColor(color.r, color.g, color.b, color.a)
end

-- Apply theme fonts to cooldown text
function ThemeIntegration:ApplyThemeFonts(cooldownText, isExpiring)
    if not cooldownText then return end
    
    local theme = self:GetCurrentTheme()
    local fontName = isExpiring and theme.fonts.bold or theme.fonts.regular
    local fontSize = cooldownText:GetFont() and select(2, cooldownText:GetFont()) or 12
    
    cooldownText:SetFont(fontName, fontSize, "OUTLINE")
end

-- Get theme texture by name
function ThemeIntegration:GetThemeTexture(textureName)
    local theme = self:GetCurrentTheme()
    local defaultTextures = self.themes[self.defaultTheme].textures
    
    if not theme.textures[textureName] then
        if defaultTextures[textureName] then
            return defaultTextures[textureName]
        end
        return nil
    end
    return theme.textures[textureName]
end

-- Get theme effect settings
function ThemeIntegration:GetThemeEffect(effectName)
    local theme = self:GetCurrentTheme()
    local defaultEffects = self.themes[self.defaultTheme].effects
    
    if not theme.effects[effectName] then
        if defaultEffects[effectName] then
            return defaultEffects[effectName]
        end
        return nil
    end
    return theme.effects[effectName]
end

-- Update all cooldown visuals based on theme
function ThemeIntegration:UpdateThemeForAllCooldowns()
    local cooldowns = OmniCC.activeCooldowns
    if not cooldowns then return end
    
    for cooldown, info in pairs(cooldowns) do
        if info.text and info.text:IsShown() then
            self:ApplyThemeFonts(info.text, info.timeLeft and info.timeLeft < 5)
            self:ApplyThemeColors(info.text, info.timeLeft or 0)
        end
    end
end

-- Initialize ThemeIntegration for OmniCC
function ThemeIntegration:Initialize()
    -- Create shorthands for theme integration functions
    OmniCC.GetThemeColors = function(cooldownText, timeLeft)
        return ThemeIntegration:ApplyThemeColors(cooldownText, timeLeft)
    end
    
    OmniCC.GetThemeFonts = function(cooldownText, isExpiring)
        return ThemeIntegration:ApplyThemeFonts(cooldownText, isExpiring)
    end
    
    OmniCC.GetThemeTexture = function(textureName)
        return ThemeIntegration:GetThemeTexture(textureName)
    end
    
    OmniCC.GetThemeEffect = function(effectName)
        return ThemeIntegration:GetThemeEffect(effectName)
    end
    
    -- Register for theme change events
    VUI.EventManager:RegisterCallback("VUI_THEME_CHANGED", function(themeName)
        ThemeIntegration:UpdateThemeForAllCooldowns()
    end)
end

-- Make theme-related functions accessible through OmniCC
OmniCC.UpdateThemeForAllCooldowns = function()
    ThemeIntegration:UpdateThemeForAllCooldowns()
end