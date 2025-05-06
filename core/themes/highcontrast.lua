--[[
    VUI - High Contrast Theme
    Author: VortexQ8
    
    This file implements the high contrast theme for VUI accessibility system.
    This theme is specifically designed for players with visual impairments.
]]

local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end

-- Only proceed if Theme system is available
if not VUI.Theme then return end

-- Register high contrast theme base (will be modified by accessibility system)
local highContrastTheme = {
    name = "highcontrast",
    displayName = "High Contrast",
    description = "Enhanced visibility theme for improved accessibility",
    
    -- Base colors - these will be modified by the accessibility system based on settings
    colors = {
        background = {
            light = {r = 1.0, g = 1.0, b = 1.0},
            medium = {r = 0.8, g = 0.8, b = 0.8},
            dark = {r = 0.0, g = 0.0, b = 0.0}
        },
        border = {
            light = {r = 1.0, g = 1.0, b = 1.0},
            medium = {r = 0.8, g = 0.8, b = 0.8},
            dark = {r = 0.0, g = 0.0, b = 0.0}
        },
        highlight = {
            primary = {r = 1.0, g = 1.0, b = 0.0},     -- Bright yellow for high visibility
            secondary = {r = 1.0, g = 1.0, b = 1.0},   -- White for maximum contrast
            tertiary = {r = 0.0, g = 0.0, b = 0.0}     -- Black for maximum contrast
        },
        text = {
            normal = {r = 1.0, g = 1.0, b = 1.0},      -- White text for better readability
            header = {r = 1.0, g = 1.0, b = 0.0},      -- Yellow headers for attention
            disabled = {r = 0.5, g = 0.5, b = 0.5}     -- Medium gray for disabled items
        },
        class = {},  -- Will be filled with high-contrast class colors
        status = {
            good = {r = 0.0, g = 1.0, b = 0.0},        -- Pure green for good status
            warning = {r = 1.0, g = 1.0, b = 0.0},     -- Pure yellow for warnings
            danger = {r = 1.0, g = 0.0, b = 0.0},      -- Pure red for dangers/errors
            info = {r = 0.0, g = 0.8, b = 1.0}         -- Bright blue for information
        }
    },
    
    -- Font settings for better readability
    fonts = {
        size = {
            small = 12,
            normal = 14,
            large = 16,
            header = 18
        },
        family = "Interface\\AddOns\\VUI\\media\\fonts\\Roboto-Bold.ttf",
        flags = "OUTLINE",
        shadowColor = {r = 0, g = 0, b = 0, a = 1},
        shadowOffset = {x = 1, y = -1}
    },
    
    -- Texture settings
    textures = {
        statusbar = "Interface\\AddOns\\VUI\\media\\textures\\minimalist",
        background = "Interface\\AddOns\\VUI\\media\\textures\\solid",
        border = "Interface\\AddOns\\VUI\\media\\textures\\white_border",
        glow = "Interface\\AddOns\\VUI\\media\\textures\\glow",
        shadow = "Interface\\AddOns\\VUI\\media\\textures\\shadow"
    },
    
    -- Layout settings
    layout = {
        border = {
            size = 2,             -- Thicker borders for better visibility
            offset = 0
        },
        shadow = {
            size = 5,             -- Larger shadows for depth
            offset = {x = 0, y = 0}
        },
        padding = 6,              -- More padding for easier targeting
        margin = 8,               -- More space between elements
        rounded = 0               -- Square corners are easier to distinguish
    },
    
    -- Animations adjusted for accessibility
    animations = {
        duration = {
            fast = 0.2,
            normal = 0.3,
            slow = 0.5
        },
        style = "LINEAR",         -- Linear animations are more predictable
        enabled = true,           -- Can be toggled off for motion sensitivity
        reducedMotion = false     -- Can be enabled for motion sensitivity
    }
}

-- Create high-contrast class colors
local classColors = {
    ["WARRIOR"]     = {r = 0.8, g = 0.7, b = 0.4},
    ["PALADIN"]     = {r = 1.0, g = 0.6, b = 0.8},
    ["HUNTER"]      = {r = 0.7, g = 1.0, b = 0.4},
    ["ROGUE"]       = {r = 1.0, g = 1.0, b = 0.0},
    ["PRIEST"]      = {r = 1.0, g = 1.0, b = 1.0},
    ["DEATHKNIGHT"] = {r = 1.0, g = 0.3, b = 0.3},
    ["SHAMAN"]      = {r = 0.0, g = 0.7, b = 1.0},
    ["MAGE"]        = {r = 0.3, g = 0.8, b = 1.0},
    ["WARLOCK"]     = {r = 0.8, g = 0.4, b = 1.0},
    ["MONK"]        = {r = 0.0, g = 1.0, b = 0.6},
    ["DRUID"]       = {r = 1.0, g = 0.5, b = 0.0},
    ["DEMONHUNTER"] = {r = 0.7, g = 0.3, b = 1.0},
    ["EVOKER"]      = {r = 0.0, g = 1.0, b = 0.8}
}

-- Add high-contrast class colors to theme
for class, color in pairs(classColors) do
    highContrastTheme.colors.class[class] = color
end

-- Register high contrast theme
VUI.Theme:RegisterTheme(highContrastTheme)

-- Initialize high contrast theme when VUI is ready
if VUI.isInitialized and VUI.Theme and VUI.Theme.UpdateThemeCache then
    VUI.Theme:UpdateThemeCache()
else
    -- Hook into OnInitialize to register theme when core is ready
    local originalOnInitialize = VUI.OnInitialize
    VUI.OnInitialize = function(self, ...)
        -- Call the original function first
        if originalOnInitialize then
            originalOnInitialize(self, ...)
        end
        
        -- Update theme cache if Theme module is ready
        if self.Theme and self.Theme.UpdateThemeCache then
            self.Theme:UpdateThemeCache()
        end
    end
end