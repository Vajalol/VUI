-- VUI angrykeystone Module Initialization
local _, VUI = ...

-- Create module
VUI.angrykeystone = {}

-- Default settings
VUI.angrykeystone.defaults = {
    enabled = true,
    showObjectiveTracker = true,
    showEnemyCounter = true,
    showChestTimer = true,
    showDeathCounter = true,
    showKeystoneInfo = true,
    timerFormat = "mm:ss",
    progressFormat = "percent",
    announceProgress = false,
    showForces = true,
    showPercentage = true,
    useVUITheme = true, -- Use VUI theme by default
    customStyle = "thunderstorm" -- Fallback if not using VUI theme
}

-- Get configuration options for main UI integration
function VUI.angrykeystone:GetConfig()
    local config = {
        name = "AngryKeystones",
        type = "group",
        args = {
            enabled = {
                type = "toggle",
                name = "Enable AngryKeystones",
                desc = "Enable or disable the AngryKeystones module",
                get = function() return VUI.db.profile.modules.angrykeystone.enabled end,
                set = function(_, value) 
                    VUI.db.profile.modules.angrykeystone.enabled = value
                    if value then
                        self:Enable()
                    else
                        self:Disable()
                    end
                end,
                order = 1
            },
            showObjectiveTracker = {
                type = "toggle",
                name = "Show Objective Tracker",
                desc = "Show enhanced objective tracker during Mythic+ dungeons",
                get = function() return VUI.db.profile.modules.angrykeystone.showObjectiveTracker end,
                set = function(_, value) 
                    VUI.db.profile.modules.angrykeystone.showObjectiveTracker = value
                    self:RefreshSettings()
                end,
                order = 2
            },
            showEnemyCounter = {
                type = "toggle",
                name = "Show Enemy Forces",
                desc = "Show enemy forces percentage and count",
                get = function() return VUI.db.profile.modules.angrykeystone.showEnemyCounter end,
                set = function(_, value) 
                    VUI.db.profile.modules.angrykeystone.showEnemyCounter = value
                    self:RefreshSettings()
                end,
                order = 3
            },
            showChestTimer = {
                type = "toggle",
                name = "Show Chest Timer",
                desc = "Show time remaining for each chest/medal tier",
                get = function() return VUI.db.profile.modules.angrykeystone.showChestTimer end,
                set = function(_, value) 
                    VUI.db.profile.modules.angrykeystone.showChestTimer = value
                    self:RefreshSettings()
                end,
                order = 4
            },
            timerFormat = {
                type = "select",
                name = "Timer Format",
                desc = "Format for displaying the timer",
                values = {
                    ["mm:ss"] = "MM:SS",
                    ["mmss"] = "MMSS",
                    ["full"] = "Full Time"
                },
                get = function() return VUI.db.profile.modules.angrykeystone.timerFormat end,
                set = function(_, value) 
                    VUI.db.profile.modules.angrykeystone.timerFormat = value
                    self:RefreshSettings()
                end,
                order = 5
            },
            useVUITheme = {
                type = "toggle",
                name = "Use VUI Theme",
                desc = "Apply the current VUI theme to AngryKeystones interface",
                get = function() return VUI.db.profile.modules.angrykeystone.useVUITheme end,
                set = function(_, value) 
                    VUI.db.profile.modules.angrykeystone.useVUITheme = value
                    
                    -- Apply theme changes immediately if possible
                    if self.ThemeIntegration and self.ThemeIntegration.ApplyTheme then
                        self.ThemeIntegration:ApplyTheme()
                    end
                    
                    self:RefreshSettings()
                end,
                order = 6
            },
            customStyle = {
                type = "select",
                name = "Custom Style",
                desc = "Choose a custom style if not using VUI theme",
                disabled = function() return VUI.db.profile.modules.angrykeystone.useVUITheme end,
                values = {
                    ["thunderstorm"] = "Thunder Storm",
                    ["phoenixflame"] = "Phoenix Flame",
                    ["arcanemystic"] = "Arcane Mystic",
                    ["felenergy"] = "Fel Energy"
                },
                get = function() return VUI.db.profile.modules.angrykeystone.customStyle end,
                set = function(_, value) 
                    VUI.db.profile.modules.angrykeystone.customStyle = value
                    self:RefreshSettings()
                end,
                order = 7
            }
        }
    }
    
    return config
end

-- Register module config with the VUI ModuleAPI
VUI.ModuleAPI:RegisterModuleConfig("angrykeystone", VUI.angrykeystone:GetConfig())

-- Initialize module
function VUI.angrykeystone:Initialize()
    -- Initialize module components
    self:SetupHooks()
    
    -- Set default theme options if not set
    if VUI.db.profile.modules.angrykeystone.useVUITheme == nil then
        VUI.db.profile.modules.angrykeystone.useVUITheme = true
    end
    
    -- Load theme integration module
    self:LoadThemeIntegration()
    
    -- Print initialization message
    VUI:Print("AngryKeystones module initialized")
    
    -- Enable if set in profile
    if VUI.db.profile.modules.angrykeystone.enabled then
        self:Enable()
    end
end

-- Load the theme integration module
function VUI.angrykeystone:LoadThemeIntegration()
    -- Try to load the module directly
    local status, error = pcall(function()
        -- Load the ThemeIntegration file
        if VUI.angrykeystone.ThemeIntegration then
            -- Initialize theme integration
            VUI.angrykeystone.ThemeIntegration:Initialize()
            return true
        end
        return false
    end)
    
    if not status then
        VUI:Debug("Failed to load AngryKeystones theme integration: " .. tostring(error))
    end
end

-- Enable module
function VUI.angrykeystone:Enable()
    self.enabled = true
    
    -- Apply hooks and show frames
    self:ApplyHooks()
    
    VUI:Print("AngryKeystones module enabled")
end

-- Disable module
function VUI.angrykeystone:Disable()
    self.enabled = false
    
    -- Remove hooks and hide frames
    self:RemoveHooks()
    
    VUI:Print("AngryKeystones module disabled")
end

-- Set up hooks for this module
function VUI.angrykeystone:SetupHooks()
    -- Define hooks but don't apply them yet
end

-- Apply hooks
function VUI.angrykeystone:ApplyHooks()
    if not self.enabled then return end
    
    -- Apply the hooks defined in SetupHooks
    
    -- Apply theme integration if enabled
    if VUI.db.profile.modules.angrykeystone.useVUITheme and self.ThemeIntegration then
        self.ThemeIntegration:ApplyTheme()
        
        -- Register for theme change events if not already registered
        if not self.themeChangeRegistered then
            VUI:RegisterCallback("ThemeChanged", function()
                if self.enabled and VUI.db.profile.modules.angrykeystone.useVUITheme then
                    self.ThemeIntegration:ApplyTheme()
                end
            end)
            self.themeChangeRegistered = true
        end
    end
end

-- Remove hooks
function VUI.angrykeystone:RemoveHooks()
    -- Remove any applied hooks
    
    -- We keep theme change registration, but it will be ignored if module is disabled
end

-- Refresh settings based on configuration changes
function VUI.angrykeystone:RefreshSettings()
    if not self.enabled then return end
    
    -- Apply theme changes if needed
    if VUI.db.profile.modules.angrykeystone.useVUITheme and self.ThemeIntegration then
        self.ThemeIntegration:ApplyTheme()
    end
    
    -- Additional setting refreshes would go here
end
