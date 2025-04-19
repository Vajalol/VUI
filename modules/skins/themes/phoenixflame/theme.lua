-- Phoenix Flame Theme for VUI
local _, VUI = ...
local Skins = VUI:GetModule("skins")

-- Register the Phoenix Flame theme
local PhoenixFlame = {
    name = "Phoenix Flame",
    description = "A fiery, phoenix-inspired theme with vibrant reds, oranges, and subtle flame effects",
    
    -- Main colors
    colors = {
        backdrop = {
            primary = {r = 0.1, g = 0.04, b = 0.02, a = 0.9},  -- Dark red/brown backdrop
            secondary = {r = 0.15, g = 0.06, b = 0.03, a = 0.85},  -- Slightly lighter for alternating elements
            highlight = {r = 0.25, g = 0.1, b = 0.05, a = 0.6},  -- Highlight areas
        },
        border = {
            primary = {r = 0.9, g = 0.3, b = 0.05, a = 1.0},  -- Fiery orange border
            secondary = {r = 0.8, g = 0.2, b = 0.05, a = 1.0},  -- Deeper red border
            highlight = {r = 1.0, g = 0.5, b = 0.1, a = 1.0},  -- Brighter orange for highlights
        },
        text = {
            primary = {r = 1.0, g = 0.92, b = 0.8, a = 1.0},   -- Light cream/gold for primary text
            secondary = {r = 0.95, g = 0.8, b = 0.6, a = 1.0}, -- Light tan for secondary text
            header = {r = 1.0, g = 0.6, b = 0.2, a = 1.0},     -- Orange headers
            highlight = {r = 1.0, g = 0.7, b = 0.3, a = 1.0},  -- Amber highlight text
        },
        button = {
            normal = {r = 0.2, g = 0.07, b = 0.04, a = 1.0},   -- Dark red normal state
            hover = {r = 0.3, g = 0.12, b = 0.06, a = 1.0},    -- Lighter red hover state
            pressed = {r = 0.15, g = 0.05, b = 0.02, a = 1.0}, -- Darker red pressed state
            disabled = {r = 0.2, g = 0.1, b = 0.05, a = 0.5},  -- Faded, semi-transparent
        },
        class = {
            overlay = {r = 0.8, g = 0.2, b = 0.1, a = 0.2},    -- Red tint for class colors
        }
    },
    
    -- Border style settings
    border = {
        size = 1,
        glow = true,
        glowColor = {r = 0.8, g = 0.3, b = 0.05, a = 0.6},
        glowSize = 3
    },
    
    -- Shadow settings
    shadow = {
        enabled = true,
        color = {r = 0.9, g = 0.3, b = 0.05, a = 0.3},
        size = 4,
    },
    
    -- Gradient settings
    gradient = {
        enabled = true,
        orientation = "VERTICAL",
        minColor = {r = 0.1, g = 0.04, b = 0.02, a = 0.9},
        maxColor = {r = 0.15, g = 0.06, b = 0.02, a = 0.9},
    },
    
    -- Media paths
    media = {
        textures = {
            background = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\background.tga",
            border = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\border.tga",
            button = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\button.tga",
            statusbar = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\statusbar.tga",
            glow = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\glow.tga",
        },
        fonts = {
            primary = "Interface\\AddOns\\VUI\\media\\Fonts\\Expressway.ttf",
            header = "Interface\\AddOns\\VUI\\media\\Fonts\\MagistralTTBold.ttf",
        }
    },
    
    -- Special effects
    effects = {
        frameFlash = {
            enabled = true,
            speed = 1.5,
            minAlpha = 0.6,
            maxAlpha = 1.0,
            color = {r = 0.9, g = 0.4, b = 0.1, a = 0.3}
        },
        borderPulse = {
            enabled = true,
            speed = 1.2,
            minSize = 1,
            maxSize = 1.5,
        }
    }
}

-- Apply the theme to an element
function PhoenixFlame:ApplyToElement(frame, elementType)
    -- Based on the element type, apply different styles
    if not frame then return end
    
    -- Apply backdrop style
    if frame.SetBackdrop and frame.SetBackdropColor and frame.SetBackdropBorderColor then
        -- Create a backdrop based on the element type
        local backdrop = {
            bgFile = self.media.textures.background or "Interface\\Buttons\\WHITE8x8",
            edgeFile = self.media.textures.border or "Interface\\Buttons\\WHITE8x8",
            tile = false,
            tileSize = 0,
            edgeSize = self.border.size,
            insets = { left = 0, right = 0, top = 0, bottom = 0 }
        }
        
        frame:SetBackdrop(backdrop)
        
        -- Apply colors based on element type
        local bgColor = self.colors.backdrop.primary
        local borderColor = self.colors.border.primary
        
        if elementType == "button" then
            bgColor = self.colors.button.normal
        elseif elementType == "header" then
            bgColor = self.colors.backdrop.secondary
            borderColor = self.colors.border.highlight
        elseif elementType == "tooltip" then
            bgColor = self.colors.backdrop.secondary
            -- Increase alpha for tooltips
            bgColor.a = 0.95
        end
        
        frame:SetBackdropColor(bgColor.r, bgColor.g, bgColor.b, bgColor.a)
        frame:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
    end
    
    -- Apply text colors if it's a FontString
    if frame.GetObjectType and frame:GetObjectType() == "FontString" then
        local textColor = self.colors.text.primary
        
        if elementType == "header" then
            textColor = self.colors.text.header
            -- Also set the font for headers
            if self.media.fonts.header then
                frame:SetFont(self.media.fonts.header, frame:GetFont():GetHeight(), "OUTLINE")
            end
        elseif elementType == "secondary" then
            textColor = self.colors.text.secondary
        elseif elementType == "highlight" then
            textColor = self.colors.text.highlight
        end
        
        frame:SetTextColor(textColor.r, textColor.g, textColor.b, textColor.a)
    end
    
    -- Add special effects based on frame type
    if self.effects.frameFlash.enabled and (elementType == "header" or elementType == "feature") then
        -- Add a subtle flash effect to important elements
        -- This would be implemented in a real addon by creating animation groups
    end
    
    -- Apply glow if enabled
    if self.border.glow and not frame.vui_phoenixGlow then
        -- In a real implementation, this would add a subtle fiery glow around the frame
        -- For now, we'll just mark the frame as having a glow
        frame.vui_phoenixGlow = true
    end
    
    -- Mark the frame as themed with Phoenix Flame
    frame.vui_phoenixFlameThemed = true
    
    return frame
end

-- Apply the theme globally (when selected as the active theme)
function PhoenixFlame:Apply()
    -- This would be the function called when the theme is activated
    -- It would update global skin colors and settings
    
    -- Update the skin module's color settings
    if Skins and Skins.settings and Skins.settings.style then
        -- Set main backdrop color
        Skins.settings.style.backdropColor = self.colors.backdrop.primary
        
        -- Set border color
        Skins.settings.style.borderColor = self.colors.border.primary
        
        -- Set shadow color and size if shadows are enabled
        if self.shadow.enabled then
            Skins.settings.style.shadowSize = self.shadow.size
            Skins.settings.style.shadowColor = self.shadow.color
        end
        
        -- Set border size
        Skins.settings.style.borderSize = self.border.size
        
        -- Enable/disable gradient backdrops
        Skins.settings.style.gradientBackdrop = self.gradient.enabled
    end
    
    -- Print a message indicating the theme has been applied
    if VUI.Print then
        VUI:Print("Phoenix Flame theme applied. Enjoy the warmth!")
    end
end

-- Register the theme with the Skins module
if Skins and Skins.RegisterTheme then
    Skins:RegisterTheme("PhoenixFlame", PhoenixFlame)
end

-- Return the theme object for external usage
VUI.themes = VUI.themes or {}
VUI.themes.PhoenixFlame = PhoenixFlame