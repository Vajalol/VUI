-- VUI SpellNotifications Theme Integration
-- Author: VortexQ8

local addonName, VUI = ...
local module = VUI:GetModule("SpellNotifications")

-- Apply theme to a notification frame
function module:ApplyTheme(frame)
    local currentTheme = VUI.db.profile.appearance.theme or "thunderstorm"
    local themeSettings = self.db.profile.theme[currentTheme]
    
    if themeSettings then
        -- Apply texture assets
        frame.texture:SetTexture(themeSettings.texture)
        frame.glow:SetTexture(themeSettings.glow)
        frame.border:SetTexture(themeSettings.border or "Interface\\AddOns\\VUI\\media\\textures\\" .. currentTheme .. "\\border")
        
        -- Apply colors
        if themeSettings.color then
            frame.texture:SetVertexColor(unpack(themeSettings.color))
            frame.border:SetVertexColor(unpack(themeSettings.color))
        end
        
        -- Store theme-specific sound file in the frame for later use
        frame.themeSoundFile = themeSettings.sound
    end
end

-- Apply theme to all notification frames
function module:ApplyThemeToAll()
    for _, frame in pairs(self.frames) do
        self:ApplyTheme(frame)
    end
end

-- Register theme change handler
function module:RegisterThemeHooks()
    -- Register for theme change events
    VUI:RegisterCallback("ThemeChanged", function()
        module:ApplyThemeToAll()
    end)
end

-- Get theme-specific sound file for notification type
function module:GetThemeSoundFile(notificationType)
    local currentTheme = VUI.db.profile.appearance.theme or "thunderstorm"
    local themeSettings = self.db.profile.theme[currentTheme]
    
    if themeSettings and themeSettings.sounds then
        -- Use theme-specific notification type sound if available
        if notificationType and themeSettings.sounds[notificationType] then
            return themeSettings.sounds[notificationType]
        end
        
        -- Fall back to general theme sound
        if themeSettings.sound then
            return themeSettings.sound
        end
    end
    
    -- Default fallback
    return self.db.profile.soundFile
end