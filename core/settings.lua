local _, VUI = ...

-- Apply all settings from the current profile
function VUI:ApplySettings()
    -- Get the current theme
    local theme = self.db.profile.appearance.theme or "thunderstorm"
    
    -- Apply theme settings
    self.ThemeIntegration:ApplyTheme(theme)
    
    -- Apply statusbar texture settings
    local statusbarTexture = self.db.profile.appearance.statusbarTexture or "smooth"
    self:ApplyStatusBarTexture(statusbarTexture)
    
    -- Apply scale settings
    local scale = self.db.profile.appearance.scale or 1.0
    self:ApplyUIScale(scale)
    
    -- Apply compact mode settings
    local compactMode = self.db.profile.appearance.compactMode or false
    self:ApplyCompactMode(compactMode)
    
    -- Apply animation settings
    local enableAnimations = self.db.profile.appearance.enableAnimations or true
    self:ApplyAnimationSettings(enableAnimations)
    
    -- Apply class color settings
    local useClassColors = self.db.profile.appearance.useClassColors or true
    self:ApplyClassColorSettings(useClassColors)
    
    -- Update the config panel if it's open
    if self.configFrame and self.configFrame:IsShown() then
        self:UpdateConfigTheme()
    end
    
    -- Print theme change message
    print("|cff1784d1VUI|r: Applied appearance settings")
end

-- Apply statusbar texture to all relevant elements
function VUI:ApplyStatusBarTexture(textureStyle)
    -- Get the statusbar texture path
    local texturePath = self.Utils:GetStatusBarTexture()
    
    -- Apply to all modules that use statusbars
    for _, moduleName in ipairs({"unitframes", "castbar", "actionbars", "buffoverlay", "omnicd"}) do
        local module = self[moduleName]
        if module and self:IsModuleEnabled(moduleName) and module.ApplyStatusBarTexture then
            module:ApplyStatusBarTexture(texturePath)
        end
    end
end

-- Apply UI scale settings
function VUI:ApplyUIScale(scale)
    -- Store the scale in settings
    self.db.profile.appearance.scale = scale
    
    -- Apply scale to modules that support scaling
    for _, moduleName in ipairs(self.modules) do
        local module = self[moduleName]
        if module and self:IsModuleEnabled(moduleName) and module.ApplyScale then
            module:ApplyScale(scale)
        end
    end
end

-- Apply compact mode settings
function VUI:ApplyCompactMode(isCompact)
    -- Store the setting
    self.db.profile.appearance.compactMode = isCompact
    
    -- Apply to modules that support compact mode
    for _, moduleName in ipairs(self.modules) do
        local module = self[moduleName]
        if module and self:IsModuleEnabled(moduleName) and module.ApplyCompactMode then
            module:ApplyCompactMode(isCompact)
        end
    end
end

-- Apply animation settings
function VUI:ApplyAnimationSettings(enableAnimations)
    -- Store the setting
    self.db.profile.appearance.enableAnimations = enableAnimations
    
    -- Apply to modules that use animations
    for _, moduleName in ipairs({"unitframes", "castbar", "actionbars", "buffoverlay", "omnicd"}) do
        local module = self[moduleName]
        if module and self:IsModuleEnabled(moduleName) and module.ApplyAnimationSettings then
            module:ApplyAnimationSettings(enableAnimations)
        end
    end
end

-- Apply class color settings
function VUI:ApplyClassColorSettings(useClassColors)
    -- Store the setting
    self.db.profile.appearance.useClassColors = useClassColors
    
    -- Apply to modules that use class colors
    for _, moduleName in ipairs({"unitframes", "chat", "nameplates"}) do
        local module = self[moduleName]
        if module and self:IsModuleEnabled(moduleName) and module.ApplyClassColorSettings then
            module:ApplyClassColorSettings(useClassColors)
        end
    end
end