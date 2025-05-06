-- Get addon environment
local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end

local VUI, E, L = unpack(select(2, ...))

-- Create the Tools module
local TOOLS = VUI:NewModule('Tools', 'AceHook-3.0', 'AceEvent-3.0')

-- Register module with VUI
VUI.TOOLS = TOOLS

-- Path constants
local TOOLS_MEDIA_PATH = 'Interface\\AddOns\\VUI\\media\\textures\\tools\\'
local THEME_MEDIA_PATH = 'Interface\\AddOns\\VUI\\media\\textures\\%s\\tools\\'

-- Default settings
TOOLS.defaults = {
    profile = {
        enabled = true,
        positionOfPower = {
            enabled = true,
            scale = 1.0,
            alpha = 0.8,
            theme = 'default', -- Uses default theme from VUI
        },
        mouseTrail = {
            enabled = true,
            scale = 1.0,
            alpha = 0.7,
            fadeSpeed = 0.8,
            theme = 'default', -- Uses default theme from VUI
            particleCount = 8,
        }
    }
}

-- Initialize the module
function TOOLS:Initialize()
    -- Skip initialization if module is disabled
    if not self.db.profile.enabled then return end
    
    -- Register our media paths
    self:RegisterMediaPaths()
    
    -- Initialize Position of Power feature
    if self.db.profile.positionOfPower.enabled then
        self:InitPositionOfPower()
    end
    
    -- Initialize Mouse Trail feature
    if self.db.profile.mouseTrail.enabled then
        self:InitMouseTrail()
    end
    
    -- Initialize theme integration
    if self.ThemeIntegration and self.ThemeIntegration.Initialize then
        self.ThemeIntegration:Initialize()
    end
    
    -- Module successfully loaded
    self:Print("Tools module loaded")
end

-- Register media paths for the module
function TOOLS:RegisterMediaPaths()
    -- Register standard media
    VUI:RegisterMedia('tools', 'positionofpower', 'border', TOOLS_MEDIA_PATH..'positionofpower\\border')
    VUI:RegisterMedia('tools', 'mousetrail', 'standard', TOOLS_MEDIA_PATH..'mousetrail\\standard')
    
    -- Register themed media for each theme
    for _, theme in ipairs({'phoenixflame', 'thunderstorm', 'arcanemystic', 'felenergy'}) do
        local themePath = THEME_MEDIA_PATH:format(theme)
        VUI:RegisterMedia('tools', 'positionofpower', theme..'_border', themePath..'positionofpower\\border')
        VUI:RegisterMedia('tools', 'mousetrail', theme..'_trail', themePath..'mousetrail\\trail')
    end
end

-- Initialize Position of Power feature
function TOOLS:InitPositionOfPower()
    -- Placeholder for position of power initialization
    -- This will be implemented when we add the actual functionality 
end

-- Initialize Mouse Trail feature
function TOOLS:InitMouseTrail()
    -- Placeholder for mouse trail initialization
    -- This will be implemented when we add the actual functionality
end

-- Module callback when settings change
function TOOLS:UpdateSettings()
    -- Reload the module with new settings
    self:Initialize()
end

-- Module config panel
function TOOLS:GetOptions()
    local options = {
        order = 8, -- Position in config panel
        type = "group",
        name = L["Tools"],
        args = {
            header = {
                order = 1,
                type = "header",
                name = L["Tools Module"],
            },
            enabled = {
                order = 2,
                type = "toggle",
                name = L["Enable"],
                desc = L["Enable the Tools module"],
                get = function() return self.db.profile.enabled end,
                set = function(_, value) 
                    self.db.profile.enabled = value
                    self:UpdateSettings()
                end,
            },
            -- Position of Power section
            positionOfPowerHeader = {
                order = 3,
                type = "header",
                name = L["Position of Power"],
            },
            positionOfPowerEnabled = {
                order = 4,
                type = "toggle",
                name = L["Enable Position of Power"],
                desc = L["Highlights abilities and spells that have temporary power increases"],
                get = function() return self.db.profile.positionOfPower.enabled end,
                set = function(_, value) 
                    self.db.profile.positionOfPower.enabled = value
                    self:UpdateSettings()
                end,
            },
            positionOfPowerTheme = {
                order = 5,
                type = "select",
                name = L["Border Theme"],
                desc = L["Select the visual theme for position of power borders"],
                get = function() return self.db.profile.positionOfPower.theme end,
                set = function(_, value) 
                    self.db.profile.positionOfPower.theme = value
                    self:UpdateSettings()
                end,
                values = function()
                    return {
                        ["default"] = L["Use VUI Theme"],
                        ["phoenixflame"] = L["Phoenix Flame"],
                        ["thunderstorm"] = L["Thunder Storm"],
                        ["arcanemystic"] = L["Arcane Mystic"],
                        ["felenergy"] = L["Fel Energy"],
                    }
                end,
                disabled = function() return not self.db.profile.positionOfPower.enabled end,
            },
            positionOfPowerScale = {
                order = 6,
                type = "range",
                name = L["Scale"],
                desc = L["Adjust the size of position of power borders"],
                min = 0.5, max = 2, step = 0.1,
                get = function() return self.db.profile.positionOfPower.scale end,
                set = function(_, value) 
                    self.db.profile.positionOfPower.scale = value
                    self:UpdateSettings()
                end,
                disabled = function() return not self.db.profile.positionOfPower.enabled end,
            },
            positionOfPowerAlpha = {
                order = 7,
                type = "range",
                name = L["Opacity"],
                desc = L["Adjust the transparency of position of power borders"],
                min = 0.1, max = 1, step = 0.1,
                get = function() return self.db.profile.positionOfPower.alpha end,
                set = function(_, value) 
                    self.db.profile.positionOfPower.alpha = value
                    self:UpdateSettings()
                end,
                disabled = function() return not self.db.profile.positionOfPower.enabled end,
            },
            -- Mouse Trail section
            mouseTrailHeader = {
                order = 8,
                type = "header",
                name = L["Mouse Trail"],
            },
            mouseTrailEnabled = {
                order = 9,
                type = "toggle",
                name = L["Enable Mouse Trail"],
                desc = L["Adds particle effects that follow your mouse cursor"],
                get = function() return self.db.profile.mouseTrail.enabled end,
                set = function(_, value) 
                    self.db.profile.mouseTrail.enabled = value
                    self:UpdateSettings()
                end,
            },
            mouseTrailTheme = {
                order = 10,
                type = "select",
                name = L["Trail Theme"],
                desc = L["Select the visual theme for mouse trail particles"],
                get = function() return self.db.profile.mouseTrail.theme end,
                set = function(_, value) 
                    self.db.profile.mouseTrail.theme = value
                    self:UpdateSettings()
                end,
                values = function()
                    return {
                        ["default"] = L["Use VUI Theme"],
                        ["phoenixflame"] = L["Phoenix Flame"],
                        ["thunderstorm"] = L["Thunder Storm"],
                        ["arcanemystic"] = L["Arcane Mystic"],
                        ["felenergy"] = L["Fel Energy"],
                    }
                end,
                disabled = function() return not self.db.profile.mouseTrail.enabled end,
            },
            mouseTrailScale = {
                order = 11,
                type = "range",
                name = L["Scale"],
                desc = L["Adjust the size of mouse trail particles"],
                min = 0.5, max = 2, step = 0.1,
                get = function() return self.db.profile.mouseTrail.scale end,
                set = function(_, value) 
                    self.db.profile.mouseTrail.scale = value
                    self:UpdateSettings()
                end,
                disabled = function() return not self.db.profile.mouseTrail.enabled end,
            },
            mouseTrailAlpha = {
                order = 12,
                type = "range",
                name = L["Opacity"],
                desc = L["Adjust the transparency of mouse trail particles"],
                min = 0.1, max = 1, step = 0.1,
                get = function() return self.db.profile.mouseTrail.alpha end,
                set = function(_, value) 
                    self.db.profile.mouseTrail.alpha = value
                    self:UpdateSettings()
                end,
                disabled = function() return not self.db.profile.mouseTrail.enabled end,
            },
            mouseTrailFadeSpeed = {
                order = 13,
                type = "range",
                name = L["Fade Speed"],
                desc = L["Adjust how quickly the mouse trail particles fade out"],
                min = 0.1, max = 2, step = 0.1,
                get = function() return self.db.profile.mouseTrail.fadeSpeed end,
                set = function(_, value) 
                    self.db.profile.mouseTrail.fadeSpeed = value
                    self:UpdateSettings()
                end,
                disabled = function() return not self.db.profile.mouseTrail.enabled end,
            },
            mouseTrailParticleCount = {
                order = 14,
                type = "range",
                name = L["Particle Count"],
                desc = L["Adjust the number of particles in the mouse trail"],
                min = 1, max = 20, step = 1,
                get = function() return self.db.profile.mouseTrail.particleCount end,
                set = function(_, value) 
                    self.db.profile.mouseTrail.particleCount = value
                    self:UpdateSettings()
                end,
                disabled = function() return not self.db.profile.mouseTrail.enabled end,
            },
        },
    }
    
    return options
end

-- Register callbacks
VUI:RegisterModule(TOOLS)