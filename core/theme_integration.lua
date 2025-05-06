local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end

-- Theme Integration System
-- Provides centralized theme management and integration for all UI elements
-- Manages the five theme systems: Thunder Storm, Phoenix Flame, Arcane Mystic, Fel Energy, and Class Color

-- Create namespace
VUI.ThemeIntegration = {}
local ThemeInt = VUI.ThemeIntegration

-- Theme definitions with color palettes
ThemeInt.themes = {
    -- Thunder Storm: Deep blue backgrounds with electric blue borders
    thunderstorm = {
        name = "Thunder Storm",
        colors = {
            background = {r = 0.04, g = 0.04, b = 0.10, a = 0.9},            -- #0A0A1A (Deep blue)
            border = {r = 0.05, g = 0.61, b = 0.90, a = 1.0},                -- #0D9DE6 (Electric blue)
            highlight = {r = 0.15, g = 0.71, b = 1.0, a = 1.0},              -- #26B5FF (Bright blue)
            text = {r = 0.9, g = 0.9, b = 1.0, a = 1.0},                     -- #E6E6FF (Light blue-white)
            header = {r = 0.2, g = 0.6, b = 1.0, a = 1.0},                   -- #3399FF (Medium blue)
            button = {r = 0.07, g = 0.07, b = 0.15, a = 1.0},                -- #121226 (Dark blue)
            buttonHover = {r = 0.09, g = 0.35, b = 0.65, a = 1.0},           -- #1759A6 (Medium-dark blue)
            shadow = {r = 0.0, g = 0.0, b = 0.1, a = 0.8},                   -- #00001A (Deep blue shadow)
            positive = {r = 0.0, g = 0.7, b = 1.0, a = 1.0},                 -- #00B3FF (Bright cyan)
            negative = {r = 0.0, g = 0.4, b = 0.7, a = 1.0},                 -- #0066B3 (Medium blue)
            neutral = {r = 0.3, g = 0.5, b = 0.85, a = 1.0},                 -- #4D80D9 (Medium-light blue)
        },
        gradients = {
            vertical = {
                {pos = 0.0, r = 0.04, g = 0.04, b = 0.15, a = 0.95},         -- #0A0A26 (Top color)
                {pos = 1.0, r = 0.02, g = 0.02, b = 0.08, a = 0.98},         -- #050514 (Bottom color)
            },
            horizontal = {
                {pos = 0.0, r = 0.02, g = 0.10, b = 0.25, a = 0.95},         -- #051940 (Left color)
                {pos = 1.0, r = 0.04, g = 0.04, b = 0.15, a = 0.95},         -- #0A0A26 (Right color)
            },
            button = {
                {pos = 0.0, r = 0.07, g = 0.07, b = 0.15, a = 1.0},          -- #121226 (Normal state)
                {pos = 1.0, r = 0.05, g = 0.18, b = 0.35, a = 1.0},          -- #0D2E59 (Bottom gradient)
            },
            buttonHover = {
                {pos = 0.0, r = 0.05, g = 0.21, b = 0.40, a = 1.0},          -- #0D3666 (Hover state top)
                {pos = 1.0, r = 0.09, g = 0.35, b = 0.65, a = 1.0},          -- #1759A6 (Hover state bottom)
            },
        },
        textures = {
            background = "Interface\\AddOns\\VUI\\media\\themes\\thunderstorm\\background.tga",
            border = "Interface\\AddOns\\VUI\\media\\themes\\thunderstorm\\border.tga",
            statusBar = "Interface\\AddOns\\VUI\\media\\themes\\thunderstorm\\statusbar.tga",
            button = "Interface\\AddOns\\VUI\\media\\themes\\thunderstorm\\button.tga",
            highlight = "Interface\\AddOns\\VUI\\media\\themes\\thunderstorm\\highlight.tga",
            glow = "Interface\\AddOns\\VUI\\media\\themes\\thunderstorm\\glow.tga",
        },
        fonts = {
            normal = "Interface\\AddOns\\VUI\\media\\fonts\\ContinuumMedium.ttf",
            bold = "Interface\\AddOns\\VUI\\media\\fonts\\ContinuumBold.ttf",
            header = "Interface\\AddOns\\VUI\\media\\fonts\\ContinuumBold.ttf",
            size = {
                small = 10,
                normal = 12,
                large = 14,
                header = 16,
            },
        },
    },
    
    -- Phoenix Flame: Dark red/brown backgrounds with fiery orange borders
    phoenixflame = {
        name = "Phoenix Flame",
        colors = {
            background = {r = 0.10, g = 0.04, b = 0.02, a = 0.9},            -- #1A0A05 (Dark red-brown)
            border = {r = 0.90, g = 0.30, b = 0.05, a = 1.0},                -- #E64D0D (Fiery orange)
            highlight = {r = 1.0, g = 0.64, b = 0.10, a = 1.0},              -- #FFA31A (Amber)
            text = {r = 1.0, g = 0.95, b = 0.8, a = 1.0},                    -- #FFF2CC (Light amber)
            header = {r = 1.0, g = 0.6, b = 0.2, a = 1.0},                   -- #FF9933 (Medium orange)
            button = {r = 0.15, g = 0.07, b = 0.04, a = 1.0},                -- #26120A (Dark brown)
            buttonHover = {r = 0.65, g = 0.22, b = 0.04, a = 1.0},           -- #A6380A (Medium-dark orange)
            shadow = {r = 0.1, g = 0.03, b = 0.0, a = 0.8},                  -- #1A0800 (Deep red-brown shadow)
            positive = {r = 1.0, g = 0.6, b = 0.0, a = 1.0},                 -- #FF9900 (Bright orange)
            negative = {r = 0.7, g = 0.2, b = 0.0, a = 1.0},                 -- #B33300 (Burnt orange)
            neutral = {r = 0.85, g = 0.45, b = 0.3, a = 1.0},                -- #D9734D (Medium orange-brown)
        },
        gradients = {
            vertical = {
                {pos = 0.0, r = 0.15, g = 0.06, b = 0.04, a = 0.95},         -- #260F0A (Top color)
                {pos = 1.0, r = 0.08, g = 0.03, b = 0.02, a = 0.98},         -- #140805 (Bottom color)
            },
            horizontal = {
                {pos = 0.0, r = 0.25, g = 0.10, b = 0.04, a = 0.95},         -- #40190A (Left color)
                {pos = 1.0, r = 0.15, g = 0.06, b = 0.04, a = 0.95},         -- #260F0A (Right color)
            },
            button = {
                {pos = 0.0, r = 0.15, g = 0.07, b = 0.04, a = 1.0},          -- #26120A (Normal state)
                {pos = 1.0, r = 0.35, g = 0.15, b = 0.05, a = 1.0},          -- #59260D (Bottom gradient)
            },
            buttonHover = {
                {pos = 0.0, r = 0.40, g = 0.17, b = 0.05, a = 1.0},          -- #662B0D (Hover state top)
                {pos = 1.0, r = 0.65, g = 0.22, b = 0.04, a = 1.0},          -- #A6380A (Hover state bottom)
            },
        },
        textures = {
            background = "Interface\\AddOns\\VUI\\media\\themes\\phoenixflame\\background.tga",
            border = "Interface\\AddOns\\VUI\\media\\themes\\phoenixflame\\border.tga",
            statusBar = "Interface\\AddOns\\VUI\\media\\themes\\phoenixflame\\statusbar.tga",
            button = "Interface\\AddOns\\VUI\\media\\themes\\phoenixflame\\button.tga",
            highlight = "Interface\\AddOns\\VUI\\media\\themes\\phoenixflame\\highlight.tga",
            glow = "Interface\\AddOns\\VUI\\media\\themes\\phoenixflame\\glow.tga",
        },
        fonts = {
            normal = "Interface\\AddOns\\VUI\\media\\fonts\\FiraSansCondensed-Regular.ttf",
            bold = "Interface\\AddOns\\VUI\\media\\fonts\\FiraSansCondensed-Bold.ttf",
            header = "Interface\\AddOns\\VUI\\media\\fonts\\FiraSansCondensed-Bold.ttf",
            size = {
                small = 10,
                normal = 12,
                large = 14,
                header = 16,
            },
        },
    },
    
    -- Arcane Mystic: Deep purple backgrounds with violet borders
    arcanemystic = {
        name = "Arcane Mystic",
        colors = {
            background = {r = 0.10, g = 0.04, b = 0.18, a = 0.9},            -- #1A0A2F (Deep purple)
            border = {r = 0.61, g = 0.05, b = 0.90, a = 1.0},                -- #9D0DE6 (Bright violet)
            highlight = {r = 0.80, g = 0.40, b = 1.0, a = 1.0},              -- #CC66FF (Light purple)
            text = {r = 0.95, g = 0.9, b = 1.0, a = 1.0},                    -- #F2E6FF (Light purple-white)
            header = {r = 0.70, g = 0.3, b = 0.9, a = 1.0},                  -- #B34DE6 (Medium purple)
            button = {r = 0.12, g = 0.05, b = 0.18, a = 1.0},                -- #1F0D2E (Dark purple)
            buttonHover = {r = 0.38, g = 0.09, b = 0.60, a = 1.0},           -- #61179A (Medium-dark purple)
            shadow = {r = 0.05, g = 0.0, b = 0.1, a = 0.8},                  -- #0D001A (Deep purple shadow)
            positive = {r = 0.75, g = 0.4, b = 1.0, a = 1.0},                -- #BF66FF (Bright violet)
            negative = {r = 0.40, g = 0.0, b = 0.6, a = 1.0},                -- #660099 (Dark violet)
            neutral = {r = 0.55, g = 0.3, b = 0.75, a = 1.0},                -- #8C4CBF (Medium purple)
        },
        gradients = {
            vertical = {
                {pos = 0.0, r = 0.12, g = 0.04, b = 0.18, a = 0.95},         -- #1F0A2E (Top color)
                {pos = 1.0, r = 0.06, g = 0.02, b = 0.10, a = 0.98},         -- #0F051A (Bottom color)
            },
            horizontal = {
                {pos = 0.0, r = 0.15, g = 0.04, b = 0.25, a = 0.95},         -- #260A40 (Left color)
                {pos = 1.0, r = 0.12, g = 0.04, b = 0.18, a = 0.95},         -- #1F0A2E (Right color)
            },
            button = {
                {pos = 0.0, r = 0.12, g = 0.05, b = 0.18, a = 1.0},          -- #1F0D2E (Normal state)
                {pos = 1.0, r = 0.20, g = 0.07, b = 0.30, a = 1.0},          -- #34124D (Bottom gradient)
            },
            buttonHover = {
                {pos = 0.0, r = 0.25, g = 0.08, b = 0.38, a = 1.0},          -- #401461 (Hover state top)
                {pos = 1.0, r = 0.38, g = 0.09, b = 0.60, a = 1.0},          -- #61179A (Hover state bottom)
            },
        },
        textures = {
            background = "Interface\\AddOns\\VUI\\media\\themes\\arcanemystic\\background.tga",
            border = "Interface\\AddOns\\VUI\\media\\themes\\arcanemystic\\border.tga",
            statusBar = "Interface\\AddOns\\VUI\\media\\themes\\arcanemystic\\statusbar.tga",
            button = "Interface\\AddOns\\VUI\\media\\themes\\arcanemystic\\button.tga",
            highlight = "Interface\\AddOns\\VUI\\media\\themes\\arcanemystic\\highlight.tga",
            glow = "Interface\\AddOns\\VUI\\media\\themes\\arcanemystic\\glow.tga",
        },
        fonts = {
            normal = "Interface\\AddOns\\VUI\\media\\fonts\\Montserrat-Regular.ttf",
            bold = "Interface\\AddOns\\VUI\\media\\fonts\\Montserrat-Bold.ttf",
            header = "Interface\\AddOns\\VUI\\media\\fonts\\Montserrat-Bold.ttf",
            size = {
                small = 10,
                normal = 12,
                large = 14,
                header = 16,
            },
        },
    },
    
    -- Fel Energy: Dark green backgrounds with fel green borders
    felenergy = {
        name = "Fel Energy",
        colors = {
            background = {r = 0.04, g = 0.10, b = 0.04, a = 0.9},            -- #0A1A0A (Dark green)
            border = {r = 0.10, g = 1.0, b = 0.10, a = 1.0},                 -- #1AFF1A (Fel green)
            highlight = {r = 0.40, g = 1.0, b = 0.4, a = 1.0},               -- #66FF66 (Light green)
            text = {r = 0.85, g = 1.0, b = 0.85, a = 1.0},                   -- #D9FFD9 (Light fel-white)
            header = {r = 0.3, g = 0.8, b = 0.3, a = 1.0},                   -- #4DCC4D (Medium green)
            button = {r = 0.05, g = 0.14, b = 0.05, a = 1.0},                -- #0D240D (Dark green)
            buttonHover = {r = 0.12, g = 0.50, b = 0.12, a = 1.0},           -- #1F801F (Medium-dark green)
            shadow = {r = 0.02, g = 0.08, b = 0.02, a = 0.8},                -- #051405 (Deep green shadow)
            positive = {r = 0.38, g = 1.0, b = 0.38, a = 1.0},               -- #61FF61 (Bright green)
            negative = {r = 0.1, g = 0.55, b = 0.1, a = 1.0},                -- #1A8C1A (Dark green)
            neutral = {r = 0.25, g = 0.75, b = 0.25, a = 1.0},               -- #40BF40 (Medium green)
        },
        gradients = {
            vertical = {
                {pos = 0.0, r = 0.05, g = 0.14, b = 0.05, a = 0.95},         -- #0D240D (Top color)
                {pos = 1.0, r = 0.03, g = 0.08, b = 0.03, a = 0.98},         -- #081408 (Bottom color)
            },
            horizontal = {
                {pos = 0.0, r = 0.08, g = 0.20, b = 0.08, a = 0.95},         -- #143314 (Left color)
                {pos = 1.0, r = 0.05, g = 0.14, b = 0.05, a = 0.95},         -- #0D240D (Right color)
            },
            button = {
                {pos = 0.0, r = 0.05, g = 0.14, b = 0.05, a = 1.0},          -- #0D240D (Normal state)
                {pos = 1.0, r = 0.08, g = 0.25, b = 0.08, a = 1.0},          -- #144014 (Bottom gradient)
            },
            buttonHover = {
                {pos = 0.0, r = 0.09, g = 0.30, b = 0.09, a = 1.0},          -- #174D17 (Hover state top)
                {pos = 1.0, r = 0.12, g = 0.50, b = 0.12, a = 1.0},          -- #1F801F (Hover state bottom)
            },
        },
        textures = {
            background = "Interface\\AddOns\\VUI\\media\\themes\\felenergy\\background.tga",
            border = "Interface\\AddOns\\VUI\\media\\themes\\felenergy\\border.tga",
            statusBar = "Interface\\AddOns\\VUI\\media\\themes\\felenergy\\statusbar.tga",
            button = "Interface\\AddOns\\VUI\\media\\themes\\felenergy\\button.tga",
            highlight = "Interface\\AddOns\\VUI\\media\\themes\\felenergy\\highlight.tga",
            glow = "Interface\\AddOns\\VUI\\media\\themes\\felenergy\\glow.tga",
        },
        fonts = {
            normal = "Interface\\AddOns\\VUI\\media\\fonts\\Exo2-Regular.ttf",
            bold = "Interface\\AddOns\\VUI\\media\\fonts\\Exo2-Bold.ttf",
            header = "Interface\\AddOns\\VUI\\media\\fonts\\Exo2-Bold.ttf",
            size = {
                small = 10,
                normal = 12,
                large = 14,
                header = 16,
            },
        },
    },
    
    -- Class Color: Dynamically colored based on player class
    classcolor = {
        name = "Class Color",
        colors = {
            -- Base theme with neutral colors that will be overridden per class
            background = {r = 0.07, g = 0.07, b = 0.07, a = 0.9},            -- #121212 (Dark gray)
            border = {r = 0.5, g = 0.5, b = 0.5, a = 1.0},                   -- #808080 (Gray - will be replaced)
            highlight = {r = 0.7, g = 0.7, b = 0.7, a = 1.0},                -- #B3B3B3 (Light gray - will be replaced)
            text = {r = 0.9, g = 0.9, b = 0.9, a = 1.0},                     -- #E6E6E6 (Very light gray)
            header = {r = 0.8, g = 0.8, b = 0.8, a = 1.0},                   -- #CCCCCC (Light gray - will be replaced)
            button = {r = 0.10, g = 0.10, b = 0.10, a = 1.0},                -- #1A1A1A (Dark gray)
            buttonHover = {r = 0.40, g = 0.40, b = 0.40, a = 1.0},           -- #666666 (Medium gray - will be replaced)
            shadow = {r = 0.0, g = 0.0, b = 0.0, a = 0.8},                   -- #000000 (Black shadow)
            positive = {r = 0, g = 0.7, b = 0, a = 1.0},                     -- #00B300 (Green)
            negative = {r = 0.7, g = 0, b = 0, a = 1.0},                     -- #B30000 (Red)
            neutral = {r = 0.5, g = 0.5, b = 0.5, a = 1.0},                  -- #808080 (Gray - will be replaced)
        },
        gradients = {
            vertical = {
                {pos = 0.0, r = 0.10, g = 0.10, b = 0.10, a = 0.95},         -- #1A1A1A (Top color)
                {pos = 1.0, r = 0.05, g = 0.05, b = 0.05, a = 0.98},         -- #0D0D0D (Bottom color)
            },
            horizontal = {
                {pos = 0.0, r = 0.12, g = 0.12, b = 0.12, a = 0.95},         -- #1F1F1F (Left color)
                {pos = 1.0, r = 0.10, g = 0.10, b = 0.10, a = 0.95},         -- #1A1A1A (Right color)
            },
            button = {
                {pos = 0.0, r = 0.10, g = 0.10, b = 0.10, a = 1.0},          -- #1A1A1A (Normal state)
                {pos = 1.0, r = 0.15, g = 0.15, b = 0.15, a = 1.0},          -- #262626 (Bottom gradient)
            },
            buttonHover = {
                {pos = 0.0, r = 0.20, g = 0.20, b = 0.20, a = 1.0},          -- #333333 (Hover state top)
                {pos = 1.0, r = 0.40, g = 0.40, b = 0.40, a = 1.0},          -- #666666 (Hover state bottom)
            },
        },
        textures = {
            background = "Interface\\AddOns\\VUI\\media\\themes\\classcolor\\background.tga",
            border = "Interface\\AddOns\\VUI\\media\\themes\\classcolor\\border.tga",
            statusBar = "Interface\\AddOns\\VUI\\media\\themes\\classcolor\\statusbar.tga",
            button = "Interface\\AddOns\\VUI\\media\\themes\\classcolor\\button.tga",
            highlight = "Interface\\AddOns\\VUI\\media\\themes\\classcolor\\highlight.tga",
            glow = "Interface\\AddOns\\VUI\\media\\themes\\classcolor\\glow.tga",
        },
        fonts = {
            normal = "Interface\\AddOns\\VUI\\media\\fonts\\PTSans-Regular.ttf",
            bold = "Interface\\AddOns\\VUI\\media\\fonts\\PTSans-Bold.ttf",
            header = "Interface\\AddOns\\VUI\\media\\fonts\\PTSans-Bold.ttf",
            size = {
                small = 10,
                normal = 12,
                large = 14,
                header = 16,
            },
        },
    },
}

-- State tracking
ThemeInt.state = {
    currentTheme = "thunderstorm",         -- Default theme
    previousTheme = nil,                   -- Previously applied theme
    themeCallbacks = {},                   -- Callbacks for theme changes
    dynamicThemeData = {},                 -- Computed/generated theme data
    themeChangeCount = 0,                  -- Number of theme changes
    themeLoadTime = 0,                     -- Time taken to load theme
    moduleThemeStatus = {},                -- Status of theme updates by module
    customClassColors = {},                -- Custom class colors
}

-- Configuration
ThemeInt.config = {
    defaultTheme = "thunderstorm",         -- Default theme
    fallbackTheme = "thunderstorm",        -- Fallback theme if selected is unavailable
    autoApplyTheme = true,                 -- Automatically apply theme changes
    overrideFonts = true,                  -- Whether to override fonts with theme fonts
    colorIntensity = 1.0,                  -- Color intensity (0.5-1.5)
    useSystemFonts = false,                -- Use system fonts instead of theme fonts
    themePresets = {},                     -- User-saved theme presets
    gradientMode = true,                   -- Use gradient mode for panels
    fontSizeAdjust = 0,                    -- Adjust font size (-2 to +2)
    animateChanges = true,                 -- Animate theme changes
    disabledModules = {},                  -- Modules exempted from theme changes
}

-- Helper function to convert RGB (0-1) to hex
local function RGBToHex(r, g, b)
    return string.format("|cff%02x%02x%02x", math.floor(r * 255), math.floor(g * 255), math.floor(b * 255))
end

-- Initialize theme system
function ThemeInt:Initialize()
    -- Load config from settings if available
    if VUI.db and VUI.db.profile and VUI.db.profile.appearance then
        self.state.currentTheme = VUI.db.profile.appearance.theme or self.config.defaultTheme
        self.config.colorIntensity = VUI.db.profile.appearance.colorIntensity or 1.0
        self.config.overrideFonts = VUI.db.profile.appearance.overrideFonts or true
        self.config.useSystemFonts = VUI.db.profile.appearance.useSystemFonts or false
        self.config.gradientMode = VUI.db.profile.appearance.gradientMode or true
        self.config.fontSizeAdjust = VUI.db.profile.appearance.fontSizeAdjust or 0
        self.config.animateChanges = VUI.db.profile.appearance.animateChanges or true
    end
    
    -- Ensure current theme is valid
    if not self.themes[self.state.currentTheme] then
        self.state.currentTheme = self.config.fallbackTheme
    end
    
    -- Generate class color variants
    self:GenerateClassColorThemes()
    
    -- Apply initial theme
    self:ApplyTheme(self.state.currentTheme)
    
    -- Register with VUI
    if VUI.RegisterSystem then
        VUI:RegisterSystem("ThemeIntegration", self)
    end
    
    -- Listen for profile changes
    if VUI.RegisterCallback then
        VUI:RegisterCallback("OnProfileChanged", function()
            -- Update current theme from profile
            if VUI.db and VUI.db.profile and VUI.db.profile.appearance then
                if VUI.db.profile.appearance.theme and 
                   VUI.db.profile.appearance.theme ~= self.state.currentTheme then
                    self:ApplyTheme(VUI.db.profile.appearance.theme)
                end
            end
        end)
    end
    
    -- Register theme commands if applicable
    if VUI.RegisterSlashCommand then
        VUI:RegisterSlashCommand("theme", function(args)
            local themeName = args
            if themeName and self.themes[themeName:lower()] then
                self:ApplyTheme(themeName:lower())
                VUI:Print("Applied theme: " .. self.themes[themeName:lower()].name)
            else
                -- List available themes if no valid theme specified
                VUI:Print("Available themes:")
                for key, theme in pairs(self.themes) do
                    if key == self.state.currentTheme then
                        VUI:Print("  " .. RGBToHex(1, 0.8, 0) .. theme.name .. " (Current)|r")
                    else
                        VUI:Print("  " .. theme.name)
                    end
                end
                VUI:Print("Usage: /vui theme <themename>")
            end
        end, "Switch between VUI themes")
    end
end

-- Generate class color variant of theme
function ThemeInt:GenerateClassColorThemes()
    local classColors = {}
    
    -- Get class colors either from addon settings or use WoW's defaults
    if CUSTOM_CLASS_COLORS then
        classColors = CUSTOM_CLASS_COLORS
    else
        classColors = RAID_CLASS_COLORS
    end
    
    -- Store for future reference
    self.state.customClassColors = classColors
    
    -- Pre-compute class color theme variants
    for class, color in pairs(classColors) do
        local r, g, b = color.r, color.g, color.b
        
        -- Calculate complementary colors
        local complementaryColor = {
            r = 1 - r,
            g = 1 - g,
            b = 1 - b,
        }
        
        -- Calculate darker and lighter variants
        local darkerColor = {
            r = r * 0.6,
            g = g * 0.6,
            b = b * 0.6,
        }
        
        local lighterColor = {
            r = r + ((1 - r) * 0.4),
            g = g + ((1 - g) * 0.4),
            b = b + ((1 - b) * 0.4),
        }
        
        -- Store theme variations by class
        if not self.state.dynamicThemeData.classVariants then
            self.state.dynamicThemeData.classVariants = {}
        end
        
        self.state.dynamicThemeData.classVariants[class] = {
            primary = {r = r, g = g, b = b},
            darker = darkerColor,
            lighter = lighterColor,
            complementary = complementaryColor
        }
    end
end

-- Get theme data for the current theme
function ThemeInt:GetThemeData()
    local themeName = self.state.currentTheme
    local theme = self.themes[themeName]
    
    if not theme then
        return self.themes[self.config.fallbackTheme]
    end
    
    -- If using class color theme, apply class-specific variations
    if themeName == "classcolor" then
        local playerClass = select(2, UnitClass("player"))
        
        -- Deep copy the theme to avoid modifying the original
        local classTheme = {}
        for k, v in pairs(theme) do
            if type(v) == "table" then
                classTheme[k] = {}
                for innerK, innerV in pairs(v) do
                    if type(innerV) == "table" then
                        classTheme[k][innerK] = {}
                        for deepK, deepV in pairs(innerV) do
                            classTheme[k][innerK][deepK] = deepV
                        end
                    else
                        classTheme[k][innerK] = innerV
                    end
                end
            else
                classTheme[k] = v
            end
        end
        
        -- Adjust class theme with class colors if available
        if playerClass and self.state.dynamicThemeData.classVariants 
           and self.state.dynamicThemeData.classVariants[playerClass] then
            
            local classVariant = self.state.dynamicThemeData.classVariants[playerClass]
            
            -- Update theme colors with class colors
            classTheme.colors.border = {
                r = classVariant.primary.r, 
                g = classVariant.primary.g, 
                b = classVariant.primary.b, 
                a = 1.0
            }
            
            classTheme.colors.highlight = {
                r = classVariant.lighter.r, 
                g = classVariant.lighter.g, 
                b = classVariant.lighter.b, 
                a = 1.0
            }
            
            classTheme.colors.header = {
                r = classVariant.primary.r, 
                g = classVariant.primary.g, 
                b = classVariant.primary.b, 
                a = 1.0
            }
            
            classTheme.colors.buttonHover = {
                r = classVariant.darker.r, 
                g = classVariant.darker.g, 
                b = classVariant.darker.b, 
                a = 1.0
            }
            
            classTheme.colors.neutral = {
                r = classVariant.primary.r, 
                g = classVariant.primary.g, 
                b = classVariant.primary.b, 
                a = 1.0
            }
            
            -- Update gradients
            classTheme.gradients.buttonHover = {
                {
                    pos = 0.0, 
                    r = classVariant.darker.r * 0.8, 
                    g = classVariant.darker.g * 0.8, 
                    b = classVariant.darker.b * 0.8, 
                    a = 1.0
                },
                {
                    pos = 1.0, 
                    r = classVariant.primary.r, 
                    g = classVariant.primary.g, 
                    b = classVariant.primary.b, 
                    a = 1.0
                },
            }
        end
        
        return classTheme
    end
    
    -- Apply color intensity adjustment
    if self.config.colorIntensity ~= 1.0 then
        -- Create a copy of the theme to avoid modifying the original
        local adjustedTheme = {}
        for k, v in pairs(theme) do
            if type(v) == "table" then
                adjustedTheme[k] = {}
                for innerK, innerV in pairs(v) do
                    if type(innerV) == "table" then
                        adjustedTheme[k][innerK] = {}
                        for deepK, deepV in pairs(innerV) do
                            adjustedTheme[k][innerK][deepK] = deepV
                        end
                    else
                        adjustedTheme[k][innerK] = innerV
                    end
                end
            else
                adjustedTheme[k] = v
            end
        end
        
        -- Adjust color intensity for all color values
        for colorType, color in pairs(adjustedTheme.colors) do
            if type(color) == "table" and color.r and color.g and color.b then
                -- Adjust RGB values while preserving alpha
                color.r = math.min(1, math.max(0, color.r * self.config.colorIntensity))
                color.g = math.min(1, math.max(0, color.g * self.config.colorIntensity))
                color.b = math.min(1, math.max(0, color.b * self.config.colorIntensity))
            end
        end
        
        -- Adjust gradients
        for gradientType, steps in pairs(adjustedTheme.gradients) do
            for _, step in ipairs(steps) do
                if step.r and step.g and step.b then
                    -- Adjust RGB values while preserving alpha and position
                    step.r = math.min(1, math.max(0, step.r * self.config.colorIntensity))
                    step.g = math.min(1, math.max(0, step.g * self.config.colorIntensity))
                    step.b = math.min(1, math.max(0, step.b * self.config.colorIntensity))
                end
            end
        end
        
        return adjustedTheme
    end
    
    return theme
end

-- Apply theme by name
function ThemeInt:ApplyTheme(themeName)
    if not themeName or not self.themes[themeName] then
        if not self.themes[self.config.fallbackTheme] then
            -- Critical error: no valid theme available
            VUI:Print("|cffff0000Theme error: No valid theme available|r")
            return false
        end
        themeName = self.config.fallbackTheme
    end
    
    -- Record previous theme and update current
    self.state.previousTheme = self.state.currentTheme
    self.state.currentTheme = themeName
    
    -- Start timing for performance tracking
    local startTime = debugprofilestop()
    
    -- Save to profile if available
    if VUI.db and VUI.db.profile and VUI.db.profile.appearance then
        VUI.db.profile.appearance.theme = themeName
    end
    
    -- Trigger callbacks
    self:TriggerThemeCallbacks(themeName)
    
    -- Trigger global theme update
    if VUI.ThemeHelpers and VUI.ThemeHelpers.UpdateAllThemes then
        VUI.ThemeHelpers:UpdateAllThemes()
    end
    
    -- Record performance data
    self.state.themeLoadTime = debugprofilestop() - startTime
    self.state.themeChangeCount = self.state.themeChangeCount + 1
    
    return true
end

-- Get font information for current theme
function ThemeInt:GetFontInfo(style, size)
    local themeData = self:GetThemeData()
    
    -- Default fallbacks
    local fontFile = "Fonts\\FRIZQT__.TTF"
    local fontSize = 12
    
    if themeData and themeData.fonts then
        -- Get font file based on style
        if style == "bold" and themeData.fonts.bold then
            fontFile = themeData.fonts.bold
        elseif style == "header" and themeData.fonts.header then
            fontFile = themeData.fonts.header
        elseif themeData.fonts.normal then
            fontFile = themeData.fonts.normal
        end
        
        -- Get font size
        if size == "small" and themeData.fonts.size and themeData.fonts.size.small then
            fontSize = themeData.fonts.size.small
        elseif size == "large" and themeData.fonts.size and themeData.fonts.size.large then
            fontSize = themeData.fonts.size.large
        elseif size == "header" and themeData.fonts.size and themeData.fonts.size.header then
            fontSize = themeData.fonts.size.header
        elseif themeData.fonts.size and themeData.fonts.size.normal then
            fontSize = themeData.fonts.size.normal
        end
        
        -- Apply font size adjustment
        fontSize = fontSize + self.config.fontSizeAdjust
    end
    
    -- If configured to use system fonts, override with default WoW fonts
    if self.config.useSystemFonts then
        if style == "bold" then
            fontFile = "Fonts\\FRIZQT__.TTF"
        elseif style == "header" then
            fontFile = "Fonts\\FRIZQT__.TTF"
        else
            fontFile = "Fonts\\FRIZQT__.TTF"
        end
    end
    
    return fontFile, fontSize
end

-- Register a callback for theme changes
function ThemeInt:RegisterThemeChangeCallback(callback)
    if not callback then return end
    
    table.insert(self.state.themeCallbacks, callback)
    return true
end

-- Unregister a theme change callback
function ThemeInt:UnregisterThemeChangeCallback(callback)
    if not callback then return end
    
    for i, registeredCallback in ipairs(self.state.themeCallbacks) do
        if registeredCallback == callback then
            table.remove(self.state.themeCallbacks, i)
            return true
        end
    end
    
    return false
end

-- Trigger all theme change callbacks
function ThemeInt:TriggerThemeCallbacks(themeName)
    for _, callback in ipairs(self.state.themeCallbacks) do
        local success, err = pcall(callback, themeName)
        if not success then
            VUI:Print("|cffff0000Theme error: " .. (err or "unknown error") .. "|r")
        end
    end
end

-- Get color information for text
function ThemeInt:GetTextColor(type)
    local themeData = self:GetThemeData()
    type = type or "text"
    
    if themeData and themeData.colors and themeData.colors[type] then
        return themeData.colors[type].r, themeData.colors[type].g, themeData.colors[type].b, themeData.colors[type].a
    end
    
    -- Fallback
    return 1, 1, 1, 1
end

-- Get hex color code for text
function ThemeInt:GetColorHex(type)
    local r, g, b = self:GetTextColor(type)
    return RGBToHex(r, g, b)
end

-- Apply theme to a FontString
function ThemeInt:ApplyFontTheme(fontString, style, size)
    if not fontString or not fontString.SetFont then return end
    
    local fontFile, fontSize = self:GetFontInfo(style, size)
    fontString:SetFont(fontFile, fontSize)
    
    -- Set color based on style
    if style == "header" then
        fontString:SetTextColor(self:GetTextColor("header"))
    else
        fontString:SetTextColor(self:GetTextColor("text"))
    end
end

-- Apply theme to a frame
function ThemeInt:ApplyFrameTheme(frame, frameType)
    if not frame then return end
    
    frameType = frameType or "background"
    local themeData = self:GetThemeData()
    
    -- Apply texture if available
    if frame.SetTexture and themeData.textures and themeData.textures[frameType] then
        frame:SetTexture(themeData.textures[frameType])
    end
    
    -- Apply color based on frame type
    if frame.SetVertexColor and themeData.colors and themeData.colors[frameType] then
        frame:SetVertexColor(
            themeData.colors[frameType].r,
            themeData.colors[frameType].g,
            themeData.colors[frameType].b,
            themeData.colors[frameType].a
        )
    end
end

-- Apply gradient to a texture
function ThemeInt:ApplyGradient(texture, gradientType, vertical)
    if not texture or not texture.SetGradient then return end
    
    local themeData = self:GetThemeData()
    gradientType = gradientType or "vertical"
    
    if themeData and themeData.gradients and themeData.gradients[gradientType] then
        local gradient = themeData.gradients[gradientType]
        
        if #gradient >= 2 then
            local orientation = vertical and "VERTICAL" or "HORIZONTAL"
            local min = gradient[1]
            local max = gradient[2]
            
            texture:SetGradient(
                orientation,
                min.r, min.g, min.b, min.a,
                max.r, max.g, max.b, max.a
            )
        end
    end
end

-- Apply theme to a StatusBar
function ThemeInt:ApplyStatusBarTheme(statusBar, barType)
    if not statusBar or not statusBar.SetStatusBarTexture then return end
    
    barType = barType or "statusBar"
    local themeData = self:GetThemeData()
    
    -- Apply texture
    if themeData.textures and themeData.textures[barType] then
        statusBar:SetStatusBarTexture(themeData.textures[barType])
    end
    
    -- Apply color based on bar type
    if statusBar.SetStatusBarColor and themeData.colors and themeData.colors[barType] then
        statusBar:SetStatusBarColor(
            themeData.colors[barType].r,
            themeData.colors[barType].g,
            themeData.colors[barType].b,
            themeData.colors[barType].a
        )
    end
end

-- Initialize the theme integration system
ThemeInt:Initialize()

-- Return the module
return ThemeInt