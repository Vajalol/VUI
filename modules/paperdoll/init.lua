--[[
    VUI - Paperdoll Module Initialization
    Version: 1.0.0
    Author: VortexQ8
]]

local addonName, VUI = ...

-- Create the paperdoll module if it doesn't exist
if not VUI.modules then VUI.modules = {} end
if not VUI.modules.paperdoll then VUI.modules.paperdoll = {} end

local Paperdoll = VUI.modules.paperdoll

-- Initialize the module
function Paperdoll:Initialize()
    -- Initialize theme integration if available
    if self.ThemeIntegration and self.ThemeIntegration.Initialize then
        self.ThemeIntegration:Initialize()
    end
    
    -- Initialize main Paperdoll functionality
    if self.OnInitialize then
        self:OnInitialize()
    end
    
    if VUI.debug then
        VUI:Print("Paperdoll module initialized")
    end
end

-- Apply theme changes when theme is changed
function Paperdoll:OnThemeChanged(theme)
    if self.ThemeIntegration and self.ThemeIntegration.ApplyTheme then
        self.ThemeIntegration:ApplyTheme(theme)
    else
        -- Legacy fallback
        local themeColors = VUI.media.themes[theme] or {}
        if self.ApplyTheme then
            self:ApplyTheme(theme, themeColors)
        end
    end
end

-- Initialize when VUI is ready
if VUI.isInitialized then
    Paperdoll:Initialize()
else
    -- Hook into VUI initialization
    local originalOnInitialize = VUI.OnInitialize
    VUI.OnInitialize = function(self, ...)
        -- Call original function if it exists
        if originalOnInitialize then
            originalOnInitialize(self, ...)
        end
        
        -- Initialize our module
        Paperdoll:Initialize()
    end
end

-- Register for theme changes
if VUI.RegisterCallback then
    VUI.RegisterCallback(Paperdoll, "ThemeChanged", function(_, newTheme)
        Paperdoll:OnThemeChanged(newTheme)
    end)
else
    -- Create a fallback callback system if not available
    if not VUI.callbacks then
        VUI.callbacks = {}
    end
    if not VUI.callbacks.ThemeChanged then
        VUI.callbacks.ThemeChanged = {}
    end
    table.insert(VUI.callbacks.ThemeChanged, function(newTheme)
        Paperdoll:OnThemeChanged(newTheme)
    end)
end