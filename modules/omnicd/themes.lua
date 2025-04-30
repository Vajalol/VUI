-- VUI OmniCD Theme Integration
local _, VUI = ...
local OmniCD = VUI.omnicd
local Media = VUI.Media

-- Theme definitions
OmniCD.themes = {
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
            cooldown = {r = 0.0, g = 0.3, b = 0.8, a = 1.0}
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
            background = {r = 0.1, g = 0.02, b = 0.15, a = 0.8},
            border = {r = 0.6, g = 0.0, b = 0.9, a = 0.8},
            highlight = {r = 0.8, g = 0.2, b = 1.0, a = 0.9},
            text = {r = 0.8, g = 0.5, b = 1.0, a = 1.0},
            ready = {r = 0.2, g = 0.8, b = 0.2, a = 1.0},
            cooldown = {r = 0.5, g = 0.0, b = 0.9, a = 1.0}
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
            glowIntensity = 0.85
        },
        sounds = {
            cooldownReady = "Interface\\AddOns\\VUI\\media\\sounds\\arcanemystic_ready.ogg"
        }
    },
    felenergy = {
        colors = {
            background = {r = 0.05, g = 0.1, b = 0.05, a = 0.8},
            border = {r = 0.0, g = 0.9, b = 0.2, a = 0.8},
            highlight = {r = 0.2, g = 1.0, b = 0.4, a = 0.9},
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
OmniCD.defaultTheme = "thunderstorm"

-- Get current theme configuration
function OmniCD:GetCurrentTheme()
    local currentThemeName = VUI.db.profile.theme or self.defaultTheme
    return self.themes[currentThemeName] or self.themes[self.defaultTheme]
end

-- Apply theme colors to a frame
function OmniCD:ApplyThemeColors(frame, colorType)
    if not frame then return end
    
    local theme = self:GetCurrentTheme()
    local colors
    
    if not theme or not theme.colors or not theme.colors[colorType] then
        -- Fallback colors
        if colorType == "background" then
            frame:SetVertexColor(0.05, 0.05, 0.1, 0.8)
        elseif colorType == "border" then
            frame:SetVertexColor(0.0, 0.4, 0.9, 0.8)
        elseif colorType == "highlight" then
            frame:SetVertexColor(0.2, 0.7, 1.0, 0.9)
        elseif colorType == "text" then
            frame:SetTextColor(0.5, 0.8, 1.0, 1.0)
        elseif colorType == "ready" then
            frame:SetVertexColor(0.2, 0.8, 0.2, 1.0)
        elseif colorType == "cooldown" then
            frame:SetVertexColor(0.0, 0.3, 0.8, 1.0)
        end
    else
        -- Apply theme colors
        colors = theme.colors[colorType]
        if frame.SetTextColor and colorType == "text" then
            frame:SetTextColor(colors.r, colors.g, colors.b, colors.a)
        else
            frame:SetVertexColor(colors.r, colors.g, colors.b, colors.a)
        end
    end
end

-- Get theme texture for a specific element
function OmniCD:GetThemeTexture(textureType)
    local theme = self:GetCurrentTheme()
    if not theme or not theme.textures or not theme.textures[textureType] then
        -- Fallback to default textures
        local defaultTextures = {
            border = "Interface\\AddOns\\VUI\\media\\themes\\thunderstorm\\border",
            icon_border = "Interface\\AddOns\\VUI\\media\\themes\\thunderstorm\\icon_border",
            bar = "Interface\\AddOns\\VUI\\media\\themes\\thunderstorm\\statusbar",
            background = "Interface\\AddOns\\VUI\\media\\themes\\thunderstorm\\background",
            glow = "Interface\\AddOns\\VUI\\media\\themes\\thunderstorm\\glow"
        }
        return defaultTextures[textureType] or defaultTextures.border
    end
    return theme.textures[textureType]
end

-- Apply theme fonts to a text element
function OmniCD:ApplyThemeFont(textElement, fontType, size, flags)
    if not textElement then return end
    
    local theme = self:GetCurrentTheme()
    local fontPath
    
    if not theme or not theme.fonts or not theme.fonts[fontType] then
        fontPath = Media:GetFont("expressway")
    else
        fontPath = theme.fonts[fontType]
    end
    
    if not size then
        local _, currentSize = textElement:GetFont()
        size = currentSize or 10
    end
    
    textElement:SetFont(fontPath, size, flags or "OUTLINE")
end

-- Get theme effect setting
function OmniCD:GetThemeEffectSetting(effectName)
    local theme = self:GetCurrentTheme()
    if not theme or not theme.effects or theme.effects[effectName] == nil then
        -- Fallback default effects
        local defaultEffects = {
            readyPulse = true,
            cooldownSpiral = true,
            glowIntensity = 0.7
        }
        return defaultEffects[effectName]
    end
    return theme.effects[effectName]
end

-- Get theme sound
function OmniCD:GetThemeSound(soundName)
    local theme = self:GetCurrentTheme()
    if not theme or not theme.sounds or not theme.sounds[soundName] then
        -- Fallback to default sounds
        local defaultSounds = {
            cooldownReady = "Interface\\AddOns\\VUI\\media\\sounds\\cooldown_ready.ogg"
        }
        return defaultSounds[soundName] or defaultSounds.cooldownReady
    end
    return theme.sounds[soundName]
end

-- Update all UI elements with current theme
function OmniCD:UpdateAllUIWithTheme()
    if not self.iconFrames then return end
    
    -- Update all icon frames with theme settings
    for _, frame in ipairs(self.iconFrames) do
        -- Update icon border texture
        if frame.border then
            frame.border:SetTexture(self:GetThemeTexture("icon_border"))
            -- Color depends on state
            if frame.ready then
                self:ApplyThemeColors(frame.border, "ready")
            else
                self:ApplyThemeColors(frame.border, "border")
            end
        end
        
        -- Update cooldown text
        if frame.cooldownText then
            self:ApplyThemeFont(frame.cooldownText, "cooldown")
            self:ApplyThemeColors(frame.cooldownText, "text")
        end
        
        -- Update spell name
        if frame.spellName then
            self:ApplyThemeFont(frame.spellName, "regular")
            self:ApplyThemeColors(frame.spellName, "text")
        end
        
        -- Update status bar if it exists
        if frame.statusBar then
            frame.statusBar:SetStatusBarTexture(self:GetThemeTexture("bar"))
            self:ApplyThemeColors(frame.statusBar, "cooldown")
            
            if frame.statusBar.bg then
                frame.statusBar.bg:SetTexture(self:GetThemeTexture("background"))
                self:ApplyThemeColors(frame.statusBar.bg, "background")
            end
        end
        
        -- Update glow if it exists
        if frame.glow then
            frame.glow:SetTexture(self:GetThemeTexture("glow"))
            -- Only show if enabled in theme
            if self:GetThemeEffectSetting("readyPulse") and frame.ready then
                frame.glow:Show()
                self:ApplyThemeColors(frame.glow, "highlight")
            else
                frame.glow:Hide()
            end
        end
    end
    
    -- Update anchor frame if it exists
    if self.anchor then
        if self.anchor.bg then
            self.anchor.bg:SetTexture(self:GetThemeTexture("background"))
            self:ApplyThemeColors(self.anchor.bg, "background")
        end
        
        if self.anchor.border then
            self.anchor.border:SetTexture(self:GetThemeTexture("border"))
            self:ApplyThemeColors(self.anchor.border, "border")
        end
        
        if self.anchor.title then
            self:ApplyThemeFont(self.anchor.title, "regular")
            self:ApplyThemeColors(self.anchor.title, "text")
        end
    end
end

-- Register for theme change events
VUI.EventManager:RegisterCallback("VUI_THEME_CHANGED", function(themeName)
    OmniCD:UpdateAllUIWithTheme()
end)