local _, VUI = ...

-- Theme integration system
VUI.ThemeIntegration = {}

-- List of modules that need theme updates when theme changes
local themeAwareModules = {
    "bags",
    "paperdoll",
    "actionbars",
    "unitframes",
    "skins",
    "buffoverlay",
    "omnicc",
    "omnicd",
    "angrykeystone",
    "premadegroupfinder"
}

-- Apply the specified theme to all theme-aware modules
function VUI.ThemeIntegration:ApplyTheme(theme)
    -- Default to Thunder Storm if no theme specified
    theme = theme or "thunderstorm"
    
    -- Get theme data
    local themeData = VUI.media.themes[theme]
    if not themeData then
        print("|cff1784d1VUI|r: Theme '" .. theme .. "' not found. Using 'thunderstorm' instead.")
        theme = "thunderstorm"
        themeData = VUI.media.themes[theme] or {}
    end
    
    -- Store current theme
    VUI.db.profile.appearance.theme = theme
    
    -- Apply to each module that supports theming
    for _, moduleName in ipairs(themeAwareModules) do
        -- Check if module exists and is enabled
        local module = VUI[moduleName]
        if module and VUI:IsModuleEnabled(moduleName) and module.ApplyTheme then
            module:ApplyTheme(theme, themeData)
        end
    end
    
    -- Update UI elements that don't belong to specific modules
    VUI:UpdateUI()
    
    -- Print message about theme change
    print("|cff1784d1VUI|r: Applied theme: " .. theme)
end

-- Hook this function to be called when theme changes in config
function VUI:InitializeThemeIntegration()
    -- Store original UpdateUI function
    local originalUpdateUI = VUI.UpdateUI
    
    -- Override with enhanced version that also applies theme
    VUI.UpdateUI = function(self, forceThemeUpdate)
        -- Call original function
        if originalUpdateUI then
            originalUpdateUI(self)
        end
        
        -- Apply current theme to modules
        if forceThemeUpdate then
            local theme = VUI.db.profile.appearance.theme or "thunderstorm"
            VUI.ThemeIntegration:ApplyTheme(theme)
        end
    end
end