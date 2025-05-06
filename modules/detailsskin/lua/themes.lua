local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end
local DS = VUI.detailsskin or {}
VUI.detailsskin = DS

-- Reference to LSM for texture registration
local LSM = LibStub("LibSharedMedia-3.0")

-- Theme color definitions
DS.ThemeColors = {
    -- Phoenix Flame theme (fiery orange/red)
    phoenixflame = {
        primary = {r = 0.90, g = 0.30, b = 0.05},       -- Bright orange
        secondary = {r = 1.00, g = 0.64, b = 0.10},     -- Amber highlight
        background = {r = 0.10, g = 0.04, b = 0.02},    -- Dark brown
        border = {r = 0.80, g = 0.20, b = 0.05},        -- Fiery red
        highlight = {r = 1.00, g = 0.50, b = 0.10},     -- Bright highlight
        shadow = {r = 0.05, g = 0.02, b = 0.01},        -- Deep shadow
        text = {r = 1.00, g = 0.90, b = 0.80},          -- Light text
        backdrop = {r = 0.15, g = 0.08, b = 0.04}       -- Slightly lighter background
    },
    
    -- Thunder Storm theme (electric blue)
    thunderstorm = {
        primary = {r = 0.05, g = 0.61, b = 0.90},       -- Electric blue
        secondary = {r = 0.10, g = 0.40, b = 0.80},     -- Deep blue highlight
        background = {r = 0.04, g = 0.04, b = 0.10},    -- Dark blue
        border = {r = 0.10, g = 0.50, b = 0.90},        -- Bright blue
        highlight = {r = 0.40, g = 0.65, b = 1.00},     -- Light blue highlight
        shadow = {r = 0.02, g = 0.02, b = 0.05},        -- Deep shadow
        text = {r = 0.80, g = 0.90, b = 1.00},          -- Light blue text
        backdrop = {r = 0.08, g = 0.08, b = 0.15}       -- Slightly lighter background
    },
    
    -- Arcane Mystic theme (purple/violet)
    arcanemystic = {
        primary = {r = 0.61, g = 0.05, b = 0.90},       -- Bright violet
        secondary = {r = 0.40, g = 0.10, b = 0.80},     -- Deep purple highlight
        background = {r = 0.10, g = 0.04, b = 0.18},    -- Dark purple
        border = {r = 0.50, g = 0.10, b = 0.90},        -- Bright purple
        highlight = {r = 0.70, g = 0.40, b = 1.00},     -- Light purple highlight
        shadow = {r = 0.05, g = 0.02, b = 0.10},        -- Deep shadow
        text = {r = 0.90, g = 0.80, b = 1.00},          -- Light purple text
        backdrop = {r = 0.15, g = 0.08, b = 0.25}       -- Slightly lighter background
    },
    
    -- Fel Energy theme (green)
    felenergy = {
        primary = {r = 0.10, g = 0.90, b = 0.10},       -- Bright green
        secondary = {r = 0.40, g = 0.80, b = 0.10},     -- Yellow-green highlight
        background = {r = 0.04, g = 0.10, b = 0.04},    -- Dark green
        border = {r = 0.10, g = 0.80, b = 0.10},        -- Bright green
        highlight = {r = 0.40, g = 1.00, b = 0.40},     -- Light green highlight
        shadow = {r = 0.02, g = 0.05, b = 0.02},        -- Deep shadow
        text = {r = 0.80, g = 1.00, b = 0.80},          -- Light green text
        backdrop = {r = 0.08, g = 0.15, b = 0.08}       -- Slightly lighter background
    }
}

-- Theme animation settings
DS.ThemeAnimations = {
    phoenixflame = {
        barFlash = "Interface\\AddOns\\VUI\\media\\textures\\themes\\phoenixflame\\detail_flash.tga",
        barGlow = "Interface\\AddOns\\VUI\\media\\textures\\themes\\phoenixflame\\detail_glow.tga",
        barHighlight = "Interface\\AddOns\\VUI\\media\\textures\\themes\\phoenixflame\\detail_highlight.tga",
        flashSpeed = 0.3,
        glowSpeed = 0.5,
        pulseIntensity = 1.2
    },
    
    thunderstorm = {
        barFlash = "Interface\\AddOns\\VUI\\media\\textures\\themes\\thunderstorm\\detail_flash.tga",
        barGlow = "Interface\\AddOns\\VUI\\media\\textures\\themes\\thunderstorm\\detail_glow.tga",
        barHighlight = "Interface\\AddOns\\VUI\\media\\textures\\themes\\thunderstorm\\detail_highlight.tga",
        flashSpeed = 0.25,
        glowSpeed = 0.4,
        pulseIntensity = 1.15
    },
    
    arcanemystic = {
        barFlash = "Interface\\AddOns\\VUI\\media\\textures\\themes\\arcanemystic\\detail_flash.tga",
        barGlow = "Interface\\AddOns\\VUI\\media\\textures\\themes\\arcanemystic\\detail_glow.tga",
        barHighlight = "Interface\\AddOns\\VUI\\media\\textures\\themes\\arcanemystic\\detail_highlight.tga",
        flashSpeed = 0.35,
        glowSpeed = 0.6,
        pulseIntensity = 1.25
    },
    
    felenergy = {
        barFlash = "Interface\\AddOns\\VUI\\media\\textures\\themes\\felenergy\\detail_flash.tga",
        barGlow = "Interface\\AddOns\\VUI\\media\\textures\\themes\\felenergy\\detail_glow.tga",
        barHighlight = "Interface\\AddOns\\VUI\\media\\textures\\themes\\felenergy\\detail_highlight.tga",
        flashSpeed = 0.2,
        glowSpeed = 0.3,
        pulseIntensity = 1.1
    }
}

-- Graph textures for Details charts
DS.ThemeBarTextures = {
    phoenixflame = "Interface\\AddOns\\VUI\\media\\textures\\themes\\phoenixflame\\detail_bar.tga",
    thunderstorm = "Interface\\AddOns\\VUI\\media\\textures\\themes\\thunderstorm\\detail_bar.tga",
    arcanemystic = "Interface\\AddOns\\VUI\\media\\textures\\themes\\arcanemystic\\detail_bar.tga",
    felenergy = "Interface\\AddOns\\VUI\\media\\textures\\themes\\felenergy\\detail_bar.tga"
}

-- Header/Footer styles for each theme
DS.ThemeHeaderStyles = {
    phoenixflame = {
        texture = "Interface\\AddOns\\VUI\\modules\\detailsskin\\textures\\phoenixflame_title_bar.svg",
        height = 22,
        fontSize = 11,
        iconSize = 14,
        borderSize = 1,
        borderColor = {r = 0.90, g = 0.30, b = 0.05, a = 0.8},
        backdropColor = {r = 0.10, g = 0.04, b = 0.02, a = 0.9},
        textColor = {r = 1.00, g = 0.90, b = 0.80, a = 1.0}
    },
    
    thunderstorm = {
        texture = "Interface\\AddOns\\VUI\\modules\\detailsskin\\textures\\thunderstorm_title_bar.svg",
        height = 22,
        fontSize = 11,
        iconSize = 14,
        borderSize = 1,
        borderColor = {r = 0.05, g = 0.61, b = 0.90, a = 0.8},
        backdropColor = {r = 0.04, g = 0.04, b = 0.10, a = 0.9},
        textColor = {r = 0.80, g = 0.90, b = 1.00, a = 1.0}
    },
    
    arcanemystic = {
        texture = "Interface\\AddOns\\VUI\\modules\\detailsskin\\textures\\arcanemystic_title_bar.svg",
        height = 22,
        fontSize = 11,
        iconSize = 14,
        borderSize = 1,
        borderColor = {r = 0.61, g = 0.05, b = 0.90, a = 0.8},
        backdropColor = {r = 0.10, g = 0.04, b = 0.18, a = 0.9},
        textColor = {r = 0.90, g = 0.80, b = 1.00, a = 1.0}
    },
    
    felenergy = {
        texture = "Interface\\AddOns\\VUI\\modules\\detailsskin\\textures\\felenergy_title_bar.svg",
        height = 22,
        fontSize = 11,
        iconSize = 14,
        borderSize = 1,
        borderColor = {r = 0.10, g = 0.90, b = 0.10, a = 0.8},
        backdropColor = {r = 0.04, g = 0.10, b = 0.04, a = 0.9},
        textColor = {r = 0.80, g = 1.00, b = 0.80, a = 1.0}
    }
}

-- Function to register theme textures with the shared media library
function DS:RegisterThemeMedia()
    for theme, texture in pairs(self.ThemeBarTextures) do
        LSM:Register("statusbar", "VUI_DetailsSkin_" .. theme, texture)
    end
    
    -- Register other textures for shared use
    for theme, anim in pairs(self.ThemeAnimations) do
        LSM:Register("background", "VUI_DetailsSkin_Flash_" .. theme, anim.barFlash)
        LSM:Register("background", "VUI_DetailsSkin_Glow_" .. theme, anim.barGlow)
        LSM:Register("background", "VUI_DetailsSkin_Highlight_" .. theme, anim.barHighlight)
    end
end

-- Function to get theme-specific bar texture
function DS:GetBarTexture(theme)
    theme = theme or VUI.db.profile.appearance.theme or "thunderstorm"
    return self.ThemeBarTextures[theme] or self.ThemeBarTextures.thunderstorm
end

-- Function to get theme-specific color set
function DS:GetThemeColors(theme)
    theme = theme or VUI.db.profile.appearance.theme or "thunderstorm"
    return self.ThemeColors[theme] or self.ThemeColors.thunderstorm
end

-- Function to get theme-specific header style
function DS:GetHeaderStyle(theme)
    theme = theme or VUI.db.profile.appearance.theme or "thunderstorm"
    return self.ThemeHeaderStyles[theme] or self.ThemeHeaderStyles.thunderstorm
end

-- Function to get theme-specific animation settings
function DS:GetAnimationSettings(theme)
    theme = theme or VUI.db.profile.appearance.theme or "thunderstorm"
    return self.ThemeAnimations[theme] or self.ThemeAnimations.thunderstorm
end

-- Export functions to the DS namespace
DS.Themes = {
    RegisterThemeMedia = function() DS:RegisterThemeMedia() end,
    GetBarTexture = function(theme) return DS:GetBarTexture(theme) end,
    GetThemeColors = function(theme) return DS:GetThemeColors(theme) end,
    GetHeaderStyle = function(theme) return DS:GetHeaderStyle(theme) end,
    GetAnimationSettings = function(theme) return DS:GetAnimationSettings(theme) end
}