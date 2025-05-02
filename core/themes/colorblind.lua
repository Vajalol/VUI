--[[
    VUI - Colorblind Theme
    Author: VortexQ8
    
    This file implements the colorblind theme for VUI accessibility system.
    This theme provides colorblind-friendly color schemes for players with
    different types of color vision deficiencies.
]]

local _, VUI = ...

-- Only proceed if Theme system is available
if not VUI.Theme then return end

-- Colorblind type constants
local PROTANOPIA = "protanopia"     -- Red-blind
local DEUTERANOPIA = "deuteranopia" -- Green-blind
local TRITANOPIA = "tritanopia"     -- Blue-blind

-- Color transformation matrices for different types of colorblindness
-- These matrices are simplified simulations for use in theme colors
local colorTransformations = {
    [PROTANOPIA] = {
        -- Red-blind: reduce red component, enhance blue and green
        ["r"] = {0.567, 0.433, 0.0},
        ["g"] = {0.558, 0.442, 0.0},
        ["b"] = {0.0, 0.242, 0.758}
    },
    [DEUTERANOPIA] = {
        -- Green-blind: reduce green component, enhance red and blue
        ["r"] = {0.625, 0.375, 0.0},
        ["g"] = {0.7, 0.3, 0.0},
        ["b"] = {0.0, 0.3, 0.7}
    },
    [TRITANOPIA] = {
        -- Blue-blind: reduce blue component, enhance red and green
        ["r"] = {0.95, 0.05, 0.0},
        ["g"] = {0.433, 0.567, 0.0},
        ["b"] = {0.475, 0.525, 0.0}
    }
}

-- Base colors for the colorblind themes
local baseColors = {
    background = {
        light = {r = 0.9, g = 0.9, b = 0.9},
        medium = {r = 0.6, g = 0.6, b = 0.6},
        dark = {r = 0.2, g = 0.2, b = 0.2}
    },
    border = {
        light = {r = 0.9, g = 0.9, b = 0.9},
        medium = {r = 0.6, g = 0.6, b = 0.6},
        dark = {r = 0.2, g = 0.2, b = 0.2}
    },
    highlight = {
        primary = {r = 0.0, g = 0.0, b = 0.0},    -- Will be customized per colorblind type
        secondary = {r = 0.0, g = 0.0, b = 0.0},  -- Will be customized per colorblind type
        tertiary = {r = 0.0, g = 0.0, b = 0.0}    -- Will be customized per colorblind type
    },
    text = {
        normal = {r = 0.9, g = 0.9, b = 0.9},
        header = {r = 1.0, g = 1.0, b = 1.0},
        disabled = {r = 0.5, g = 0.5, b = 0.5}
    },
    class = {},
    status = {
        good = {r = 0.0, g = 0.0, b = 0.0},       -- Will be customized per colorblind type
        warning = {r = 0.0, g = 0.0, b = 0.0},    -- Will be customized per colorblind type
        danger = {r = 0.0, g = 0.0, b = 0.0},     -- Will be customized per colorblind type
        info = {r = 0.0, g = 0.0, b = 0.0}        -- Will be customized per colorblind type
    }
}

-- Highlight colors optimized for different types of colorblindness
local highlightColors = {
    [PROTANOPIA] = {
        primary = {r = 0.0, g = 0.8, b = 1.0},    -- Cyan instead of red
        secondary = {r = 0.0, g = 0.8, b = 0.0},  -- Green
        tertiary = {r = 0.9, g = 0.9, b = 0.0}    -- Yellow
    },
    [DEUTERANOPIA] = {
        primary = {r = 0.0, g = 0.0, b = 1.0},    -- Blue
        secondary = {r = 1.0, g = 0.5, b = 0.0},  -- Orange
        tertiary = {r = 0.8, g = 0.0, b = 0.8}    -- Purple
    },
    [TRITANOPIA] = {
        primary = {r = 1.0, g = 0.0, b = 0.0},    -- Red
        secondary = {r = 0.0, g = 0.0, b = 0.0},  -- Black
        tertiary = {r = 1.0, g = 1.0, b = 1.0}    -- White
    }
}

-- Status colors optimized for different types of colorblindness
local statusColors = {
    [PROTANOPIA] = {
        good = {r = 0.0, g = 0.8, b = 0.8},       -- Cyan instead of green
        warning = {r = 0.7, g = 0.7, b = 0.0},    -- Yellow
        danger = {r = 0.0, g = 0.0, b = 1.0},     -- Blue instead of red
        info = {r = 0.7, g = 0.7, b = 0.7}        -- Gray
    },
    [DEUTERANOPIA] = {
        good = {r = 0.0, g = 0.0, b = 1.0},       -- Blue instead of green
        warning = {r = 1.0, g = 0.5, b = 0.0},    -- Orange
        danger = {r = 1.0, g = 0.0, b = 0.0},     -- Red
        info = {r = 0.7, g = 0.7, b = 0.7}        -- Gray
    },
    [TRITANOPIA] = {
        good = {r = 0.0, g = 0.7, b = 0.0},       -- Green
        warning = {r = 1.0, g = 0.7, b = 0.0},    -- Orange
        danger = {r = 1.0, g = 0.0, b = 0.0},     -- Red
        info = {r = 0.0, g = 0.0, b = 0.0}        -- Black
    }
}

-- Class colors optimized for different types of colorblindness
local classColors = {
    -- Protanopia-friendly class colors (avoiding red-green confusion)
    [PROTANOPIA] = {
        ["WARRIOR"]     = {r = 0.6, g = 0.6, b = 0.6},   -- Gray
        ["PALADIN"]     = {r = 0.9, g = 0.8, b = 0.0},   -- Gold
        ["HUNTER"]      = {r = 0.0, g = 0.8, b = 0.8},   -- Cyan
        ["ROGUE"]       = {r = 1.0, g = 0.9, b = 0.0},   -- Yellow
        ["PRIEST"]      = {r = 1.0, g = 1.0, b = 1.0},   -- White
        ["DEATHKNIGHT"] = {r = 0.0, g = 0.0, b = 0.8},   -- Blue
        ["SHAMAN"]      = {r = 0.0, g = 0.7, b = 1.0},   -- Blue
        ["MAGE"]        = {r = 0.0, g = 0.8, b = 1.0},   -- Cyan
        ["WARLOCK"]     = {r = 0.8, g = 0.6, b = 1.0},   -- Light purple
        ["MONK"]        = {r = 0.0, g = 0.8, b = 0.8},   -- Cyan
        ["DRUID"]       = {r = 1.0, g = 0.7, b = 0.0},   -- Orange
        ["DEMONHUNTER"] = {r = 0.8, g = 0.8, b = 0.0},   -- Yellow
        ["EVOKER"]      = {r = 0.0, g = 0.9, b = 0.9}    -- Bright cyan
    },
    
    -- Deuteranopia-friendly class colors (avoiding red-green confusion)
    [DEUTERANOPIA] = {
        ["WARRIOR"]     = {r = 0.6, g = 0.6, b = 0.6},   -- Gray
        ["PALADIN"]     = {r = 0.9, g = 0.8, b = 0.0},   -- Gold
        ["HUNTER"]      = {r = 0.0, g = 0.0, b = 1.0},   -- Blue
        ["ROGUE"]       = {r = 1.0, g = 0.9, b = 0.0},   -- Yellow
        ["PRIEST"]      = {r = 1.0, g = 1.0, b = 1.0},   -- White
        ["DEATHKNIGHT"] = {r = 0.8, g = 0.0, b = 0.0},   -- Red
        ["SHAMAN"]      = {r = 0.0, g = 0.0, b = 1.0},   -- Blue
        ["MAGE"]        = {r = 0.0, g = 0.5, b = 1.0},   -- Blue
        ["WARLOCK"]     = {r = 0.8, g = 0.0, b = 0.8},   -- Purple
        ["MONK"]        = {r = 0.0, g = 0.0, b = 0.8},   -- Blue
        ["DRUID"]       = {r = 1.0, g = 0.5, b = 0.0},   -- Orange
        ["DEMONHUNTER"] = {r = 0.8, g = 0.0, b = 0.8},   -- Purple
        ["EVOKER"]      = {r = 0.0, g = 0.0, b = 1.0}    -- Blue
    },
    
    -- Tritanopia-friendly class colors (avoiding blue-yellow confusion)
    [TRITANOPIA] = {
        ["WARRIOR"]     = {r = 0.6, g = 0.6, b = 0.6},   -- Gray
        ["PALADIN"]     = {r = 1.0, g = 0.0, b = 0.0},   -- Red
        ["HUNTER"]      = {r = 0.0, g = 0.8, b = 0.0},   -- Green
        ["ROGUE"]       = {r = 0.0, g = 0.0, b = 0.0},   -- Black
        ["PRIEST"]      = {r = 1.0, g = 1.0, b = 1.0},   -- White
        ["DEATHKNIGHT"] = {r = 0.8, g = 0.0, b = 0.0},   -- Red
        ["SHAMAN"]      = {r = 0.0, g = 0.8, b = 0.0},   -- Green
        ["MAGE"]        = {r = 0.0, g = 0.7, b = 0.0},   -- Green
        ["WARLOCK"]     = {r = 0.8, g = 0.0, b = 0.0},   -- Red
        ["MONK"]        = {r = 0.0, g = 0.8, b = 0.0},   -- Green
        ["DRUID"]       = {r = 1.0, g = 0.5, b = 0.0},   -- Orange
        ["DEMONHUNTER"] = {r = 0.7, g = 0.0, b = 0.0},   -- Dark red
        ["EVOKER"]      = {r = 0.0, g = 0.7, b = 0.0}    -- Green
    }
}

-- Create and register themes for each colorblind type
local function CreateColorblindTheme(type)
    local theme = {
        name = "colorblind_" .. type,
        displayName = "Colorblind (" .. type .. ")",
        description = "Optimized for " .. type .. " color vision",
        
        -- Copy base colors
        colors = CopyTable(baseColors),
        
        -- Font settings optimized for readability
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
        
        -- Texture settings with clear patterns
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
                size = 2,         -- Thicker borders for better visibility
                offset = 0
            },
            shadow = {
                size = 4,
                offset = {x = 0, y = 0}
            },
            padding = 6,          -- More padding for easier targeting
            margin = 8,           -- More space between elements
            rounded = 3           -- Slightly rounded corners
        },
        
        -- Standard animations
        animations = {
            duration = {
                fast = 0.2,
                normal = 0.3,
                slow = 0.5
            },
            style = "SMOOTH",
            enabled = true,
            reducedMotion = false
        },
        
        -- Colorblind specific settings
        colorblind = {
            type = type,
            textLabels = true,        -- Add text labels to color-coded elements
            patterns = true,          -- Add patterns to distinguish colors
            enhancedBorders = true,   -- Add distinctive borders
            simplifiedUI = false      -- Optional simplified UI layout
        }
    }
    
    -- Set type-specific highlight colors
    if highlightColors[type] then
        theme.colors.highlight.primary = highlightColors[type].primary
        theme.colors.highlight.secondary = highlightColors[type].secondary
        theme.colors.highlight.tertiary = highlightColors[type].tertiary
    end
    
    -- Set type-specific status colors
    if statusColors[type] then
        theme.colors.status.good = statusColors[type].good
        theme.colors.status.warning = statusColors[type].warning
        theme.colors.status.danger = statusColors[type].danger
        theme.colors.status.info = statusColors[type].info
    end
    
    -- Set type-specific class colors
    if classColors[type] then
        theme.colors.class = classColors[type]
    end
    
    -- Register the theme
    VUI.Theme:RegisterTheme(theme)
end

-- Create themes for each colorblind type
CreateColorblindTheme(PROTANOPIA)
CreateColorblindTheme(DEUTERANOPIA)
CreateColorblindTheme(TRITANOPIA)

-- Function to transform colors for colorblindness (used by accessibility system)
function VUI.TransformColorForColorblindness(color, colorblindType, intensity)
    if not color or not colorblindType or not colorTransformations[colorblindType] then
        return color
    end
    
    intensity = intensity or 1.0
    
    local r, g, b = color.r, color.g, color.b
    local newR, newG, newB = r, g, b
    
    local transform = colorTransformations[colorblindType]
    
    -- Apply transformation matrix with intensity
    newR = r * (1 - intensity) + (transform.r[1] * r + transform.r[2] * g + transform.r[3] * b) * intensity
    newG = g * (1 - intensity) + (transform.g[1] * r + transform.g[2] * g + transform.g[3] * b) * intensity
    newB = b * (1 - intensity) + (transform.b[1] * r + transform.b[2] * g + transform.b[3] * b) * intensity
    
    -- Ensure values are within valid range
    newR = max(0, min(1, newR))
    newG = max(0, min(1, newG))
    newB = max(0, min(1, newB))
    
    -- Return transformed color
    return {r = newR, g = newG, b = newB}
end

-- Register with VUI core
VUI:RegisterScript("core/themes/colorblind.lua")