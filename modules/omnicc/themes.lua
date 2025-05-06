-- VUI OmniCC Theme Integration
local _, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end
local OmniCC = VUI.omnicc
local Media = VUI.Media

-- Theme definitions
OmniCC.themes = {
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
            finishColor = {r = 0.0, g = 0.6, b = 1.0, a = 0.7},
            glowIntensity = 0.75,
            pulseDuration = 0.7,
            shineDuration = 0.5
        }
    },
    arcanemystic = {
        colors = {
            days = {r = 0.6, g = 0.4, b = 0.8, a = 1.0},
            hours = {r = 0.7, g = 0.4, b = 0.9, a = 1.0},
            minutes = {r = 0.7, g = 0.3, b = 1.0, a = 1.0},
            seconds = {r = 0.6, g = 0.2, b = 1.0, a = 1.0},
            milliseconds = {r = 0.5, g = 0.0, b = 1.0, a = 1.0}
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
            finishColor = {r = 0.5, g = 0.0, b = 1.0, a = 0.7},
            glowIntensity = 0.85,
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
OmniCC.defaultTheme = "thunderstorm"

-- Get current theme configuration
function OmniCC:GetCurrentTheme()
    local currentThemeName = VUI.db.profile.theme or self.defaultTheme
    return self.themes[currentThemeName] or self.themes[self.defaultTheme]
end

-- Apply theme colors to cooldown text
function OmniCC:ApplyThemeColors(cooldownText, timeLeft)
    if not cooldownText then return end
    
    local theme = self:GetCurrentTheme()
    local colors
    
    if not theme then
        colors = self.defaults.colors
    else
        colors = theme.colors
    end
    
    if timeLeft >= 86400 then -- days
        cooldownText:SetTextColor(colors.days.r, colors.days.g, colors.days.b, colors.days.a)
    elseif timeLeft >= 3600 then -- hours
        cooldownText:SetTextColor(colors.hours.r, colors.hours.g, colors.hours.b, colors.hours.a)
    elseif timeLeft >= 60 then -- minutes
        cooldownText:SetTextColor(colors.minutes.r, colors.minutes.g, colors.minutes.b, colors.minutes.a)
    elseif timeLeft >= 0 then -- seconds
        cooldownText:SetTextColor(colors.seconds.r, colors.seconds.g, colors.seconds.b, colors.seconds.a)
    else -- milliseconds (shouldn't normally reach here)
        cooldownText:SetTextColor(colors.milliseconds.r, colors.milliseconds.g, colors.milliseconds.b, colors.milliseconds.a)
    end
end

-- Get theme texture for a specific effect
function OmniCC:GetThemeTexture(effectType)
    local theme = self:GetCurrentTheme()
    if not theme or not theme.textures or not theme.textures[effectType] then
        -- Fallback to default textures if needed
        local defaultTextures = {
            shine = "Interface\\AddOns\\VUI\\media\\themes\\thunderstorm\\effects\\shine",
            pulse = "Interface\\AddOns\\VUI\\media\\themes\\thunderstorm\\effects\\pulse",
            flare = "Interface\\AddOns\\VUI\\media\\themes\\thunderstorm\\effects\\flare",
            sparkle = "Interface\\AddOns\\VUI\\media\\themes\\thunderstorm\\effects\\sparkle"
        }
        return defaultTextures[effectType] or defaultTextures.pulse
    end
    return theme.textures[effectType]
end

-- Apply theme fonts to cooldown text
function OmniCC:ApplyThemeFonts(cooldownText, isBold)
    if not cooldownText then return end
    
    local theme = self:GetCurrentTheme()
    local fontPath
    
    if not theme or not theme.fonts then
        fontPath = DEFAULT_FONT_FACE
    else
        fontPath = isBold and theme.fonts.bold or theme.fonts.regular
    end
    
    local _, size, flags = cooldownText:GetFont()
    if fontPath and size then
        cooldownText:SetFont(fontPath, size, flags)
    end
end

-- Get theme effect settings
function OmniCC:GetThemeEffectSettings(effectName)
    local theme = self:GetCurrentTheme()
    if not theme or not theme.effects or not theme.effects[effectName] then
        -- Fallback to default values
        local defaultEffects = {
            finishColor = {r = 0.0, g = 0.6, b = 1.0, a = 0.7},
            glowIntensity = 0.75,
            pulseDuration = 0.7,
            shineDuration = 0.5
        }
        return defaultEffects[effectName]
    end
    return theme.effects[effectName]
end

-- Update all cooldown visuals based on theme
function OmniCC:UpdateThemeForAllCooldowns()
    if not self.activeCooldowns then return end
    
    for cooldown, info in pairs(self.activeCooldowns) do
        if info.text and info.text:IsShown() then
            self:ApplyThemeFonts(info.text, info.timeLeft and info.timeLeft < 5)
            self:ApplyThemeColors(info.text, info.timeLeft or 0)
        end
    end
end

-- Register for theme change events
VUI.EventManager:RegisterCallback("VUI_THEME_CHANGED", function(themeName)
    OmniCC:UpdateThemeForAllCooldowns()
end)