-- VUI omnicc Module Initialization
local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end

-- Create module
VUI.omnicc = {}

-- Default settings
VUI.omnicc.defaults = {
    enabled = true,
    showText = true,
    useDecimalThreshold = 2,
    minDuration = 3,
    minFontSize = 10,
    maxFontSize = 24,
    formatSetting = "short",
    animateFinish = true,
    showMilliseconds = true,
    enableCustomization = true,
    effectType = "pulse",
    colors = {
        days = {r = 0.8, g = 0.8, b = 0.8, a = 1.0},
        hours = {r = 0.8, g = 0.8, b = 0.8, a = 1.0},
        minutes = {r = 0.8, g = 0.8, b = 0.2, a = 1.0},
        seconds = {r = 0.8, g = 0.2, b = 0.2, a = 1.0},
        milliseconds = {r = 1.0, g = 0.0, b = 0.0, a = 1.0}
    }
}

-- Get configuration options for main UI integration
function VUI.omnicc:GetConfig()
    local config = {
        name = "OmniCC",
        type = "group",
        args = {
            enabled = {
                type = "toggle",
                name = "Enable OmniCC",
                desc = "Enable or disable the OmniCC module",
                get = function() return VUI.db.profile.modules.omnicc.enabled end,
                set = function(_, value) 
                    VUI.db.profile.modules.omnicc.enabled = value
                    if value then
                        self:Enable()
                    else
                        self:Disable()
                    end
                end,
                order = 1
            },
            showText = {
                type = "toggle",
                name = "Show Text",
                desc = "Show countdown text on cooldowns",
                get = function() return VUI.db.profile.modules.omnicc.showText end,
                set = function(_, value) 
                    VUI.db.profile.modules.omnicc.showText = value
                    self:RefreshSettings()
                end,
                order = 2
            },
            minDuration = {
                type = "range",
                name = "Minimum Duration",
                desc = "Minimum cooldown duration to show text (in seconds)",
                min = 0,
                max = 10,
                step = 0.5,
                get = function() return VUI.db.profile.modules.omnicc.minDuration end,
                set = function(_, value) 
                    VUI.db.profile.modules.omnicc.minDuration = value
                    self:RefreshSettings()
                end,
                order = 3
            },
            animateFinish = {
                type = "toggle",
                name = "Animate Finish",
                desc = "Play animation when cooldown completes",
                get = function() return VUI.db.profile.modules.omnicc.animateFinish end,
                set = function(_, value) 
                    VUI.db.profile.modules.omnicc.animateFinish = value
                    self:RefreshSettings()
                end,
                order = 4
            },
            effectType = {
                type = "select",
                name = "Finish Effect",
                desc = "Animation style when cooldown completes",
                values = {
                    ["pulse"] = "Pulse",
                    ["shine"] = "Shine",
                    ["flare"] = "Flare",
                    ["sparkle"] = "Sparkle",
                    ["none"] = "None"
                },
                get = function() return VUI.db.profile.modules.omnicc.effectType end,
                set = function(_, value) 
                    VUI.db.profile.modules.omnicc.effectType = value
                    self:RefreshSettings()
                end,
                order = 5
            }
        }
    }
    
    return config
end

-- Register module config with the VUI ModuleAPI
VUI.ModuleAPI:RegisterModuleConfig("omnicc", VUI.omnicc:GetConfig())

-- Initialize module
function VUI.omnicc:Initialize()
    -- Initialize module components
    self:SetupHooks()
    
    -- Initialize theme integration
    if self.ThemeIntegration then
        self.ThemeIntegration:Initialize()
    end

    -- Print initialization message
    VUI:Print("OmniCC module initialized")
    
    -- Enable if set in profile
    if VUI.db.profile.modules.omnicc.enabled then
        self:Enable()
    end
end

-- Enable module
function VUI.omnicc:Enable()
    self.enabled = true
    
    -- Apply hooks and show frames
    self:ApplyHooks()
    
    VUI:Print("OmniCC module enabled")
end

-- Disable module
function VUI.omnicc:Disable()
    self.enabled = false
    
    -- Remove hooks and hide frames
    self:RemoveHooks()
    
    VUI:Print("OmniCC module disabled")
end

-- Set up hooks for this module
function VUI.omnicc:SetupHooks()
    -- Define hooks but don't apply them yet
end

-- Apply hooks
function VUI.omnicc:ApplyHooks()
    if not self.enabled then return end
    -- Apply the hooks defined in SetupHooks
end

-- Remove hooks
function VUI.omnicc:RemoveHooks()
    -- Remove any applied hooks
end
