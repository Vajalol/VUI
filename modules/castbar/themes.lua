--[[
    VUI - Castbar Theme Integration
    Version: 0.0.1
    Author: VortexQ8
]]

local addonName, VUI = ...
local Castbar = VUI.Castbar
local MediaPath = "Interface\\AddOns\\VUI\\media\\"

-- Theme-specific castbar customizations
local themeCustomizations = {
    phoenixflame = {
        colors = {
            standard = {r = 0.9, g = 0.5, b = 0.2, a = 1.0},
            channeling = {r = 0.9, g = 0.4, b = 0.1, a = 1.0},
            uninterruptible = {r = 0.7, g = 0.5, b = 0.3, a = 1.0},
            success = {r = 0.9, g = 0.7, b = 0.2, a = 1.0},
            failed = {r = 0.9, g = 0.2, b = 0.1, a = 1.0}
        },
        statusBar = MediaPath.."textures\\themes\\phoenixflame\\castbar\\statusbar",
        border = MediaPath.."textures\\themes\\phoenixflame\\castbar\\border",
        font = MediaPath.."fonts\\expressway.ttf",
        fontOutline = "OUTLINE",
        textureStyle = "flame",
        particleEffect = "embers",
        soundEffect = "burning"
    },
    
    thunderstorm = {
        colors = {
            standard = {r = 0.2, g = 0.6, b = 0.9, a = 1.0},
            channeling = {r = 0.3, g = 0.5, b = 0.9, a = 1.0},
            uninterruptible = {r = 0.4, g = 0.4, b = 0.7, a = 1.0},
            success = {r = 0.4, g = 0.7, b = 0.9, a = 1.0},
            failed = {r = 0.9, g = 0.3, b = 0.3, a = 1.0}
        },
        statusBar = MediaPath.."textures\\themes\\thunderstorm\\castbar\\statusbar",
        border = MediaPath.."textures\\themes\\thunderstorm\\castbar\\border",
        font = MediaPath.."fonts\\expressway.ttf",
        fontOutline = "OUTLINE",
        textureStyle = "lightning",
        particleEffect = "static",
        soundEffect = "thunder"
    },
    
    arcanemystic = {
        colors = {
            standard = {r = 0.6, g = 0.3, b = 0.9, a = 1.0},
            channeling = {r = 0.5, g = 0.3, b = 0.8, a = 1.0},
            uninterruptible = {r = 0.5, g = 0.3, b = 0.5, a = 1.0},
            success = {r = 0.8, g = 0.5, b = 0.9, a = 1.0},
            failed = {r = 0.9, g = 0.3, b = 0.3, a = 1.0}
        },
        statusBar = MediaPath.."textures\\themes\\arcanemystic\\castbar\\statusbar",
        border = MediaPath.."textures\\themes\\arcanemystic\\castbar\\border",
        font = MediaPath.."fonts\\expressway.ttf",
        fontOutline = "OUTLINE",
        textureStyle = "arcane",
        particleEffect = "sparkles",
        soundEffect = "magic"
    },
    
    felenergy = {
        colors = {
            standard = {r = 0.3, g = 0.9, b = 0.3, a = 1.0},
            channeling = {r = 0.2, g = 0.8, b = 0.2, a = 1.0},
            uninterruptible = {r = 0.4, g = 0.6, b = 0.4, a = 1.0},
            success = {r = 0.5, g = 0.9, b = 0.5, a = 1.0},
            failed = {r = 0.9, g = 0.3, b = 0.3, a = 1.0}
        },
        statusBar = MediaPath.."textures\\themes\\felenergy\\castbar\\statusbar",
        border = MediaPath.."textures\\themes\\felenergy\\castbar\\border",
        font = MediaPath.."fonts\\expressway.ttf",
        fontOutline = "OUTLINE",
        textureStyle = "fel",
        particleEffect = "souls",
        soundEffect = "corruption"
    }
}

-- Get theme-specific asset path
function Castbar:GetThemeAssetPath(assetName, themeName)
    themeName = themeName or VUI.db.profile.appearance.theme or "thunderstorm"
    return MediaPath.."textures\\themes\\" .. themeName .. "\\castbar\\" .. assetName
end

-- Apply theme customizations to all castbars
function Castbar:ApplyThemeCustomizations(themeName)
    -- Use the current theme if none specified
    themeName = themeName or VUI.db.profile.appearance.theme or "thunderstorm"
    
    -- Get theme customizations
    local customizations = themeCustomizations[themeName]
    if not customizations then return end
    
    -- Apply theme colors to settings
    self.settings.colors = customizations.colors
    
    -- Apply theme styling to each castbar
    for unit, castbar in pairs(self.frames) do
        -- Update status bar texture
        if customizations.statusBar then
            castbar.bar:SetStatusBarTexture(customizations.statusBar)
            castbar.bg:SetTexture(customizations.statusBar)
        end
        
        -- Update border texture
        if customizations.border and castbar.border then
            castbar.border:SetBackdrop({
                edgeFile = customizations.border, 
                edgeSize = 2,
                insets = {left = 1, right = 1, top = 1, bottom = 1}
            })
            
            if castbar.iconBorder then
                castbar.iconBorder:SetBackdrop({
                    edgeFile = customizations.border, 
                    edgeSize = 2,
                    insets = {left = 1, right = 1, top = 1, bottom = 1}
                })
            end
        end
        
        -- Update font style
        if customizations.font then
            local fontFiles = {
                castbar.text,
                castbar.timer,
                castbar.targetText,
                castbar.latencyText,
                castbar.completionText
            }
            
            for _, fontObject in ipairs(fontFiles) do
                if fontObject then
                    local _, size, _ = fontObject:GetFont()
                    fontObject:SetFont(customizations.font, size, customizations.fontOutline or "OUTLINE")
                end
            end
        end
        
        -- Set colors
        castbar.bar:SetStatusBarColor(
            customizations.colors.standard.r,
            customizations.colors.standard.g,
            customizations.colors.standard.b,
            customizations.colors.standard.a
        )
    end
    
    -- Apply theme animations
    self:ApplyThemeIntegration(themeName)
end

-- Hook to VUI theme changed event
VUI.EventManager:RegisterCallback("VUI_THEME_CHANGED", function(themeName)
    if Castbar:IsEnabled() then
        Castbar:ApplyThemeCustomizations(themeName)
    end
end)