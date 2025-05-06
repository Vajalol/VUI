-- VUI MultiNotification Theme Integration
-- Provides theme support for the MultiNotification module
local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end

-- Get module reference
local module = VUI:GetModule("MultiNotification")

-- Apply theme to all notification frames
function module:ApplyTheme()
    local currentTheme = VUI.db.profile.appearance.theme or "thunderstorm"
    
    -- Update theme in settings if it doesn't exist
    if not self.db.profile.theme[currentTheme] then
        -- Clone from a similar theme as fallback
        local fallbackTheme = "thunderstorm"
        if self.db.profile.theme[fallbackTheme] then
            self.db.profile.theme[currentTheme] = CopyTable(self.db.profile.theme[fallbackTheme])
        end
    end
    
    -- Apply theme to all active notifications
    self:ApplyThemeToAll()
    
    -- Return true if successful
    return true
end

-- Register theme change callbacks
function module:RegisterThemeCallbacks()
    -- Register for theme change events
    VUI:RegisterCallback("ThemeChanged", function()
        module:ApplyTheme()
    end)
end

-- Get theme colors for a specific category
function module:GetThemeColorsForCategory(category)
    local currentTheme = VUI.db.profile.appearance.theme or "thunderstorm"
    local themeSettings = self.db.profile.theme[currentTheme]
    
    if themeSettings and themeSettings.colors then
        return themeSettings.colors
    end
    
    -- Return default colors as fallback
    return {
        background = {0, 0.6, 1, 1},
        border = {0, 0.6, 1, 1},
        text = {0.8, 0.9, 1, 1},
        glow = {0.2, 0.5, 1, 0.8}
    }
end

-- Get theme textures for a specific category
function module:GetThemeTexturesForCategory(category)
    local currentTheme = VUI.db.profile.appearance.theme or "thunderstorm"
    local themeSettings = self.db.profile.theme[currentTheme]
    
    if themeSettings and themeSettings.textures then
        return themeSettings.textures
    end
    
    -- Return default textures as fallback
    return {
        background = "Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\notification.tga",
        border = "Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\border.tga",
        glow = "Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\glow.tga"
    }
end

-- Get theme sound for a specific notification type
function module:GetThemeSoundFile(notificationType)
    local currentTheme = VUI.db.profile.appearance.theme or "thunderstorm"
    local themeSettings = self.db.profile.theme[currentTheme]
    
    if themeSettings and themeSettings.sounds and themeSettings.sounds[notificationType] then
        return themeSettings.sounds[notificationType]
    elseif themeSettings and themeSettings.sounds and themeSettings.sounds.system then
        -- Use system sound as fallback
        return themeSettings.sounds.system
    end
    
    -- Return default sound as ultimate fallback
    return "Interface\\AddOns\\VUI\\media\\sounds\\thunderstorm\\notification.ogg"
end

-- Initialize theme integration
function module:InitializeThemeIntegration()
    self:RegisterThemeCallbacks()
    
    -- Apply current theme
    self:ApplyTheme()
end