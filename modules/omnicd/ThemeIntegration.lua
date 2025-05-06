-- VUI OmniCD Theme Integration
local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end
local OmniCD = VUI.omnicd
local Media = VUI.Media
local Atlas = VUI.Atlas

-- ThemeIntegration for OmniCD module with Atlas texture support
local ThemeIntegration = {}
OmniCD.ThemeIntegration = ThemeIntegration

-- Theme definitions
ThemeIntegration.themes = {
    phoenixflame = {
        colors = {
            background = {r = 0.1, g = 0.05, b = 0.02, a = 0.8},
            border = {r = 0.9, g = 0.4, b = 0.0, a = 0.8},
            highlight = {r = 1.0, g = 0.7, b = 0.2, a = 0.9},
            text = {r = 1.0, g = 0.8, b = 0.5, a = 1.0},
            ready = {r = 0.2, g = 0.8, b = 0.2, a = 1.0},
            cooldown = {r = 0.8, g = 0.3, b = 0.0, a = 1.0}
        },
        textures = {
            border = "Interface\\AddOns\\VUI\\media\\themes\\phoenixflame\\border",
            icon_border = "Interface\\AddOns\\VUI\\media\\themes\\phoenixflame\\icon_border",
            bar = "Interface\\AddOns\\VUI\\media\\themes\\phoenixflame\\statusbar",
            background = "Interface\\AddOns\\VUI\\media\\themes\\phoenixflame\\background",
            glow = "Interface\\AddOns\\VUI\\media\\themes\\phoenixflame\\glow"
        },
        fonts = {
            regular = Media:GetFont("expressway"),
            cooldown = Media:GetFont("expressway_bold")
        },
        effects = {
            readyPulse = true,
            cooldownSpiral = true,
            glowIntensity = 0.8
        },
        sounds = {
            cooldownReady = "Interface\\AddOns\\VUI\\media\\sounds\\phoenixflame_ready.ogg"
        }
    },
    thunderstorm = {
        colors = {
            background = {r = 0.05, g = 0.05, b = 0.1, a = 0.8},
            border = {r = 0.0, g = 0.4, b = 0.9, a = 0.8},
            highlight = {r = 0.2, g = 0.7, b = 1.0, a = 0.9},
            text = {r = 0.5, g = 0.8, b = 1.0, a = 1.0},
            ready = {r = 0.2, g = 0.8, b = 0.2, a = 1.0},
            cooldown = {r = 0.0, g = 0.6, b = 0.9, a = 1.0}
        },
        textures = {
            border = "Interface\\AddOns\\VUI\\media\\themes\\thunderstorm\\border",
            icon_border = "Interface\\AddOns\\VUI\\media\\themes\\thunderstorm\\icon_border",
            bar = "Interface\\AddOns\\VUI\\media\\themes\\thunderstorm\\statusbar",
            background = "Interface\\AddOns\\VUI\\media\\themes\\thunderstorm\\background",
            glow = "Interface\\AddOns\\VUI\\media\\themes\\thunderstorm\\glow"
        },
        fonts = {
            regular = Media:GetFont("expressway"),
            cooldown = Media:GetFont("expressway_bold")
        },
        effects = {
            readyPulse = true,
            cooldownSpiral = true,
            glowIntensity = 0.7
        },
        sounds = {
            cooldownReady = "Interface\\AddOns\\VUI\\media\\sounds\\thunderstorm_ready.ogg"
        }
    },
    arcanemystic = {
        colors = {
            background = {r = 0.1, g = 0.02, b = 0.1, a = 0.8},
            border = {r = 0.6, g = 0.0, b = 0.9, a = 0.8},
            highlight = {r = 0.7, g = 0.2, b = 1.0, a = 0.9},
            text = {r = 0.9, g = 0.7, b = 1.0, a = 1.0},
            ready = {r = 0.2, g = 0.8, b = 0.2, a = 1.0},
            cooldown = {r = 0.5, g = 0.0, b = 0.8, a = 1.0}
        },
        textures = {
            border = "Interface\\AddOns\\VUI\\media\\themes\\arcanemystic\\border",
            icon_border = "Interface\\AddOns\\VUI\\media\\themes\\arcanemystic\\icon_border",
            bar = "Interface\\AddOns\\VUI\\media\\themes\\arcanemystic\\statusbar",
            background = "Interface\\AddOns\\VUI\\media\\themes\\arcanemystic\\background",
            glow = "Interface\\AddOns\\VUI\\media\\themes\\arcanemystic\\glow"
        },
        fonts = {
            regular = Media:GetFont("expressway"),
            cooldown = Media:GetFont("expressway_bold")
        },
        effects = {
            readyPulse = true,
            cooldownSpiral = true,
            glowIntensity = 0.8
        },
        sounds = {
            cooldownReady = "Interface\\AddOns\\VUI\\media\\sounds\\arcanemystic_ready.ogg"
        }
    },
    felenergy = {
        colors = {
            background = {r = 0.05, g = 0.1, b = 0.05, a = 0.8},
            border = {r = 0.0, g = 0.8, b = 0.3, a = 0.8},
            highlight = {r = 0.2, g = 1.0, b = 0.2, a = 0.9},
            text = {r = 0.5, g = 1.0, b = 0.6, a = 1.0},
            ready = {r = 0.2, g = 0.8, b = 0.2, a = 1.0},
            cooldown = {r = 0.0, g = 0.8, b = 0.3, a = 1.0}
        },
        textures = {
            border = "Interface\\AddOns\\VUI\\media\\themes\\felenergy\\border",
            icon_border = "Interface\\AddOns\\VUI\\media\\themes\\felenergy\\icon_border",
            bar = "Interface\\AddOns\\VUI\\media\\themes\\felenergy\\statusbar",
            background = "Interface\\AddOns\\VUI\\media\\themes\\felenergy\\background",
            glow = "Interface\\AddOns\\VUI\\media\\themes\\felenergy\\glow"
        },
        fonts = {
            regular = Media:GetFont("expressway"),
            cooldown = Media:GetFont("expressway_bold")
        },
        effects = {
            readyPulse = true,
            cooldownSpiral = true,
            glowIntensity = 0.9
        },
        sounds = {
            cooldownReady = "Interface\\AddOns\\VUI\\media\\sounds\\felenergy_ready.ogg"
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

-- Apply theme colors to a frame
function ThemeIntegration:ApplyThemeColors(frame, colorType)
    if not frame then return end
    
    local theme = self:GetCurrentTheme()
    local colors = theme.colors[colorType or "text"]
    
    if not colors then
        colors = theme.colors.text -- fallback to text color
    end
    
    if frame.SetColorTexture then
        frame:SetColorTexture(colors.r, colors.g, colors.b, colors.a or 1.0)
    elseif frame.SetVertexColor then
        frame:SetVertexColor(colors.r, colors.g, colors.b, colors.a or 1.0)
    elseif frame.SetTextColor then
        frame:SetTextColor(colors.r, colors.g, colors.b, colors.a or 1.0)
    end
end

-- Get theme texture by name
function ThemeIntegration:GetThemeTexture(textureName)
    local theme = self:GetCurrentTheme()
    local defaultTextures = self.themes[self.defaultTheme].textures
    
    local texturePath
    if not theme.textures[textureName] then
        if defaultTextures[textureName] then
            texturePath = defaultTextures[textureName]
        else
            return nil
        end
    else
        texturePath = theme.textures[textureName]
    end
    
    -- Use Atlas texture system if available
    return VUI:GetTextureCached(texturePath)
end

-- Get theme font by name
function ThemeIntegration:GetThemeFont(fontType)
    local theme = self:GetCurrentTheme()
    local defaultFonts = self.themes[self.defaultTheme].fonts
    
    fontType = fontType or "regular"
    if not theme.fonts[fontType] then
        if defaultFonts[fontType] then
            return defaultFonts[fontType]
        end
        return Media:GetFont("expressway") -- global fallback
    end
    return theme.fonts[fontType]
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

-- Get theme sound path
function ThemeIntegration:GetThemeSound(soundName)
    local theme = self:GetCurrentTheme()
    local defaultSounds = self.themes[self.defaultTheme].sounds
    
    if not theme.sounds[soundName] then
        if defaultSounds[soundName] then
            return defaultSounds[soundName]
        end
        return nil
    end
    return theme.sounds[soundName]
end

-- Apply theme to all cooldown icons and bars
function ThemeIntegration:ApplyThemeToAllIcons()
    if not OmniCD.icons then return end
    
    for _, iconFrame in pairs(OmniCD.icons) do
        if iconFrame.border then
            iconFrame.border:SetTexture(self:GetThemeTexture("icon_border"))
        end
        
        if iconFrame.cooldownText then
            iconFrame.cooldownText:SetFont(self:GetThemeFont("cooldown"), 
                iconFrame.cooldownText:GetFont() and select(2, iconFrame.cooldownText:GetFont()) or 12, 
                "OUTLINE")
            self:ApplyThemeColors(iconFrame.cooldownText, "text")
        end
        
        if iconFrame.readyGlow and iconFrame.readyGlow:IsShown() then
            iconFrame.readyGlow:SetTexture(self:GetThemeTexture("glow"))
        end
    end
end

-- Apply theme to all cooldown bars
function ThemeIntegration:ApplyThemeToBars()
    if not OmniCD.bars then return end
    
    for _, bar in pairs(OmniCD.bars) do
        if bar.statusBar then
            bar.statusBar:SetStatusBarTexture(self:GetThemeTexture("bar"))
            self:ApplyThemeColors(bar.statusBar, "cooldown")
        end
        
        if bar.background then
            bar.background:SetTexture(self:GetThemeTexture("background"))
            self:ApplyThemeColors(bar.background, "background")
        end
        
        if bar.border then
            bar.border:SetTexture(self:GetThemeTexture("border"))
            self:ApplyThemeColors(bar.border, "border")
        end
        
        if bar.text then
            bar.text:SetFont(self:GetThemeFont("regular"), 
                bar.text:GetFont() and select(2, bar.text:GetFont()) or 10, 
                "OUTLINE")
            self:ApplyThemeColors(bar.text, "text")
        end
        
        if bar.timeText then
            bar.timeText:SetFont(self:GetThemeFont("cooldown"), 
                bar.timeText:GetFont() and select(2, bar.timeText:GetFont()) or 10, 
                "OUTLINE")
            self:ApplyThemeColors(bar.timeText, "text")
        end
    end
end

-- Update all UI elements with current theme
function ThemeIntegration:UpdateAllUIElements()
    self:ApplyThemeToAllIcons()
    self:ApplyThemeToBars()
end

-- Initialize ThemeIntegration for OmniCD
function ThemeIntegration:Initialize()
    -- Create shorthands for theme integration functions
    OmniCD.GetThemeColors = function(frame, colorType)
        return ThemeIntegration:ApplyThemeColors(frame, colorType)
    end
    
    OmniCD.GetThemeTexture = function(textureName)
        return ThemeIntegration:GetThemeTexture(textureName)
    end
    
    OmniCD.GetThemeFont = function(fontType)
        return ThemeIntegration:GetThemeFont(fontType)
    end
    
    OmniCD.GetThemeEffect = function(effectName)
        return ThemeIntegration:GetThemeEffect(effectName)
    end
    
    OmniCD.GetThemeSound = function(soundName)
        return ThemeIntegration:GetThemeSound(soundName)
    end
    
    -- Register for theme change events
    VUI.EventManager:RegisterCallback("VUI_THEME_CHANGED", function(themeName)
        ThemeIntegration:UpdateAllUIElements()
    end)
end

-- Make theme-related functions accessible through OmniCD
OmniCD.UpdateAllUIElements = function()
    ThemeIntegration:UpdateAllUIElements()
end