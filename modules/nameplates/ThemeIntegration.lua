-- VUI Nameplates Theme Integration
local _, VUI = ...
local Nameplates = VUI.nameplates
local Media = VUI.Media

-- ThemeIntegration for Nameplates module
local ThemeIntegration = {}
Nameplates.ThemeIntegration = ThemeIntegration

-- Theme definitions for Nameplates module (using existing definitions from utils.lua)
ThemeIntegration.themes = {
    phoenixflame = {
        colors = {
            healthBar = {r = 0.9, g = 0.3, b = 0.0, a = 1.0},
            castBar = {r = 0.9, g = 0.5, b = 0.2, a = 1.0},
            border = {r = 0.9, g = 0.3, b = 0.0, a = 1.0},
            background = {r = 0.1, g = 0.03, b = 0.01, a = 0.8},
            glow = {r = 1.0, g = 0.6, b = 0.0, a = 1.0},
            highlight = {r = 1.0, g = 0.8, b = 0.4, a = 0.2},
            text = {r = 1.0, g = 0.9, b = 0.7, a = 1.0}
        },
        fonts = {
            name = Media:GetFont("expressway_bold"),
            level = Media:GetFont("expressway"),
            castName = Media:GetFont("expressway_bold")
        },
        textures = {
            border = "Interface\\AddOns\\VUI\\media\\textures\\themes\\phoenixflame\\border",
            background = "Interface\\AddOns\\VUI\\media\\textures\\themes\\phoenixflame\\background"
        }
    },
    
    thunderstorm = {
        colors = {
            healthBar = {r = 0.0, g = 0.6, b = 0.9, a = 1.0},
            castBar = {r = 0.2, g = 0.4, b = 0.8, a = 1.0},
            border = {r = 0.0, g = 0.6, b = 0.9, a = 1.0},
            background = {r = 0.03, g = 0.05, b = 0.1, a = 0.8},
            glow = {r = 0.4, g = 0.8, b = 1.0, a = 1.0},
            highlight = {r = 0.5, g = 0.7, b = 1.0, a = 0.2},
            text = {r = 0.7, g = 0.85, b = 1.0, a = 1.0}
        },
        fonts = {
            name = Media:GetFont("expressway_bold"),
            level = Media:GetFont("expressway"),
            castName = Media:GetFont("expressway_bold")
        },
        textures = {
            border = "Interface\\AddOns\\VUI\\media\\textures\\themes\\thunderstorm\\border",
            background = "Interface\\AddOns\\VUI\\media\\textures\\themes\\thunderstorm\\background"
        }
    },
    
    arcanemystic = {
        colors = {
            healthBar = {r = 0.6, g = 0.2, b = 0.8, a = 1.0},
            castBar = {r = 0.7, g = 0.3, b = 0.9, a = 1.0},
            border = {r = 0.6, g = 0.2, b = 0.8, a = 1.0},
            background = {r = 0.1, g = 0.03, b = 0.1, a = 0.8},
            glow = {r = 0.8, g = 0.4, b = 1.0, a = 1.0},
            highlight = {r = 0.7, g = 0.5, b = 1.0, a = 0.2},
            text = {r = 0.9, g = 0.8, b = 1.0, a = 1.0}
        },
        fonts = {
            name = Media:GetFont("expressway_bold"),
            level = Media:GetFont("expressway"),
            castName = Media:GetFont("expressway_bold")
        },
        textures = {
            border = "Interface\\AddOns\\VUI\\media\\textures\\themes\\arcanemystic\\border",
            background = "Interface\\AddOns\\VUI\\media\\textures\\themes\\arcanemystic\\background"
        }
    },
    
    felenergy = {
        colors = {
            healthBar = {r = 0.1, g = 0.8, b = 0.1, a = 1.0},
            castBar = {r = 0.3, g = 0.9, b = 0.3, a = 1.0},
            border = {r = 0.1, g = 0.8, b = 0.1, a = 1.0},
            background = {r = 0.03, g = 0.1, b = 0.03, a = 0.8},
            glow = {r = 0.4, g = 1.0, b = 0.4, a = 1.0},
            highlight = {r = 0.5, g = 1.0, b = 0.5, a = 0.2},
            text = {r = 0.7, g = 1.0, b = 0.7, a = 1.0}
        },
        fonts = {
            name = Media:GetFont("expressway_bold"),
            level = Media:GetFont("expressway"),
            castName = Media:GetFont("expressway_bold")
        },
        textures = {
            border = "Interface\\AddOns\\VUI\\media\\textures\\themes\\felenergy\\border",
            background = "Interface\\AddOns\\VUI\\media\\textures\\themes\\felenergy\\background"
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

-- Get colors for specific element type
function ThemeIntegration:GetColorForElementType(elementType)
    local theme = self:GetCurrentTheme()
    local color = theme.colors[elementType] or theme.colors.healthBar
    return color.r, color.g, color.b, color.a or 1.0
end

-- Apply theme colors to an element based on its type
function ThemeIntegration:ApplyThemeColors(element, elementType)
    if not element or not elementType then return nil end
    
    local r, g, b, a = self:GetColorForElementType(elementType)
    
    if element.SetColorTexture then
        element:SetColorTexture(r, g, b, a)
    elseif element.SetStatusBarColor then
        element:SetStatusBarColor(r, g, b, a)
    elseif element.SetVertexColor then
        element:SetVertexColor(r, g, b, a)
    elseif element.SetTextColor then
        element:SetTextColor(r, g, b, a)
    end
    
    return {r = r, g = g, b = b, a = a}
end

-- Apply theme textures to a frame
function ThemeIntegration:ApplyThemeTexture(frame, textureType)
    if not frame or not textureType then return end
    
    local theme = self:GetCurrentTheme()
    local texture = theme.textures[textureType]
    
    if texture and frame.SetTexture then
        frame:SetTexture(texture)
    end
end

-- Get theme font by type
function ThemeIntegration:GetThemeFont(fontType)
    local theme = self:GetCurrentTheme()
    fontType = fontType or "name"
    
    if theme.fonts[fontType] then
        return theme.fonts[fontType]
    end
    
    return self.themes[self.defaultTheme].fonts[fontType] or Media:GetFont("expressway")
end

-- Apply theme to a nameplate
function ThemeIntegration:ApplyThemeToNameplate(namePlate)
    if not namePlate or not namePlate.UnitFrame then return end
    
    local unitFrame = namePlate.UnitFrame
    
    -- Apply theme to health bar
    if unitFrame.healthBar then
        self:ApplyThemeColors(unitFrame.healthBar, "healthBar")
    end
    
    -- Apply theme to cast bar
    if unitFrame.castBar then
        self:ApplyThemeColors(unitFrame.castBar, "castBar")
    end
    
    -- Apply theme to name text
    if unitFrame.name then
        self:ApplyThemeColors(unitFrame.name, "text")
    end
    
    -- Apply theme to level text
    if unitFrame.level then
        self:ApplyThemeColors(unitFrame.level, "text")
    end
    
    -- Apply theme to borders if they exist
    if unitFrame.healthBar and unitFrame.healthBar.border then
        self:ApplyThemeColors(unitFrame.healthBar.border, "border")
    end
    
    if unitFrame.castBar and unitFrame.castBar.border then
        self:ApplyThemeColors(unitFrame.castBar.border, "border")
    end
    
    -- Apply theme to backgrounds
    if unitFrame.healthBar and unitFrame.healthBar.background then
        self:ApplyThemeColors(unitFrame.healthBar.background, "background")
    end
    
    if unitFrame.castBar and unitFrame.castBar.background then
        self:ApplyThemeColors(unitFrame.castBar.background, "background")
    end
end

-- Apply theme to all nameplates
function ThemeIntegration:ApplyThemeToAllNameplates()
    if not Nameplates.settings.useThemeColors then
        return -- Only proceed if theme colors are enabled
    end
    
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        self:ApplyThemeToNameplate(namePlate)
    end
end

-- Update theme for Plater
function ThemeIntegration:ApplyThemeToPlater()
    if not Nameplates.plater then return end
    
    local currentThemeName = VUI.db.profile.appearance.theme or self.defaultTheme
    Nameplates.plater:ApplyTheme(currentThemeName)
end

-- Initialize ThemeIntegration for Nameplates
function ThemeIntegration:Initialize()
    -- Replace the existing Utils:ApplyThemeColors function with our standardized version
    Nameplates.utils.ApplyThemeColors = function(utils, element, elementType)
        return ThemeIntegration:ApplyThemeColors(element, elementType)
    end
    
    -- Register for theme change events
    VUI.EventManager:RegisterCallback("VUI_THEME_CHANGED", function(themeName)
        if Nameplates.enabled and Nameplates.settings.useThemeColors then
            if Nameplates.settings.styling == "plater" and Nameplates.plater then
                self:ApplyThemeToPlater()
            else
                self:ApplyThemeToAllNameplates()
            end
        end
    end)
end