-- VUI MoveAny Theme Integration
local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end
local MoveAny = VUI.moveany
local Media = VUI.Media

-- ThemeIntegration for MoveAny module
local ThemeIntegration = {}
MoveAny.ThemeIntegration = ThemeIntegration

-- Theme definitions for MoveAny module
ThemeIntegration.themes = {
    phoenixflame = {
        colors = {
            border = {r = 0.9, g = 0.3, b = 0.0, a = 0.5},
            background = {r = 0.1, g = 0.05, b = 0.02, a = 0.6},
            highlight = {r = 1.0, g = 0.5, b = 0.0, a = 0.7},
            text = {r = 1.0, g = 0.8, b = 0.6, a = 1.0}
        },
        fonts = {
            title = Media:GetFont("expressway_bold"),
            label = Media:GetFont("expressway")
        },
        textures = {
            border = "Interface\\AddOns\\VUI\\media\\textures\\themes\\phoenixflame\\border",
            background = "Interface\\AddOns\\VUI\\media\\textures\\themes\\phoenixflame\\background"
        }
    },
    
    thunderstorm = {
        colors = {
            border = {r = 0.0, g = 0.5, b = 0.9, a = 0.5},
            background = {r = 0.05, g = 0.05, b = 0.15, a = 0.6},
            highlight = {r = 0.2, g = 0.6, b = 1.0, a = 0.7},
            text = {r = 0.7, g = 0.85, b = 1.0, a = 1.0}
        },
        fonts = {
            title = Media:GetFont("expressway_bold"),
            label = Media:GetFont("expressway")
        },
        textures = {
            border = "Interface\\AddOns\\VUI\\media\\textures\\themes\\thunderstorm\\border",
            background = "Interface\\AddOns\\VUI\\media\\textures\\themes\\thunderstorm\\background"
        }
    },
    
    arcanemystic = {
        colors = {
            border = {r = 0.6, g = 0.1, b = 0.9, a = 0.5},
            background = {r = 0.1, g = 0.05, b = 0.15, a = 0.6},
            highlight = {r = 0.7, g = 0.3, b = 1.0, a = 0.7},
            text = {r = 0.9, g = 0.7, b = 1.0, a = 1.0}
        },
        fonts = {
            title = Media:GetFont("expressway_bold"),
            label = Media:GetFont("expressway")
        },
        textures = {
            border = "Interface\\AddOns\\VUI\\media\\textures\\themes\\arcanemystic\\border",
            background = "Interface\\AddOns\\VUI\\media\\textures\\themes\\arcanemystic\\background"
        }
    },
    
    felenergy = {
        colors = {
            border = {r = 0.1, g = 0.8, b = 0.1, a = 0.5},
            background = {r = 0.05, g = 0.15, b = 0.05, a = 0.6},
            highlight = {r = 0.3, g = 1.0, b = 0.3, a = 0.7},
            text = {r = 0.6, g = 1.0, b = 0.6, a = 1.0}
        },
        fonts = {
            title = Media:GetFont("expressway_bold"),
            label = Media:GetFont("expressway")
        },
        textures = {
            border = "Interface\\AddOns\\VUI\\media\\textures\\themes\\felenergy\\border",
            background = "Interface\\AddOns\\VUI\\media\\textures\\themes\\felenergy\\background"
        }
    }
}

-- Default theme fallback
ThemeIntegration.defaultTheme = "thunderstorm"

-- Get current theme configuration
function ThemeIntegration:GetCurrentTheme()
    local currentThemeName = VUI.db.profile.appearance.theme or self.defaultTheme
    return self.themes[currentThemeName] or self.themes[self.defaultTheme]
end

-- Apply theme colors to a frame
function ThemeIntegration:ApplyThemeColors(frame, colorType)
    if not frame then return end
    
    local theme = self:GetCurrentTheme()
    local colors = theme.colors[colorType or "text"]
    
    if not colors then
        colors = theme.colors.text -- fallback to text color
    end
    
    if frame.SetColorTexture then
        frame:SetColorTexture(colors.r, colors.g, colors.b, colors.a or 1.0)
    elseif frame.SetVertexColor then
        frame:SetVertexColor(colors.r, colors.g, colors.b, colors.a or 1.0)
    elseif frame.SetTextColor then
        frame:SetTextColor(colors.r, colors.g, colors.b, colors.a or 1.0)
    end
end

-- Apply theme textures to a frame
function ThemeIntegration:ApplyThemeTexture(frame, textureType)
    if not frame or not textureType then return end
    
    local theme = self:GetCurrentTheme()
    local texture = theme.textures[textureType]
    
    if not texture then
        texture = self.themes[self.defaultTheme].textures[textureType]
    end
    
    if texture and frame.SetTexture then
        frame:SetTexture(texture)
    end
end

-- Get theme font by type
function ThemeIntegration:GetThemeFont(fontType)
    local theme = self:GetCurrentTheme()
    fontType = fontType or "label"
    
    if theme.fonts[fontType] then
        return theme.fonts[fontType]
    end
    
    return self.themes[self.defaultTheme].fonts[fontType] or Media:GetFont("expressway")
end

-- Style a MoveAny anchor frame with current theme
function ThemeIntegration:StyleMoveAnchor(anchor)
    if not anchor then return end
    
    -- Find the border and label elements
    local border
    local label
    
    for i=1, anchor:GetNumRegions() do
        local region = select(i, anchor:GetRegions())
        if region:GetObjectType() == "Texture" then
            border = region
        elseif region:GetObjectType() == "FontString" then
            label = region
        end
    end
    
    -- Apply theme to border
    if border then
        self:ApplyThemeColors(border, "border")
    end
    
    -- Apply theme to label
    if label then
        label:SetFont(self:GetThemeFont("label"), 10, "OUTLINE")
        self:ApplyThemeColors(label, "text")
    end
end

-- Apply theme to all MoveAny anchors
function ThemeIntegration:StyleAllAnchors()
    if not MoveAny.anchors then return end
    
    for _, anchor in pairs(MoveAny.anchors) do
        self:StyleMoveAnchor(anchor)
    end
end

-- Update all UI elements with current theme
function ThemeIntegration:UpdateAllUIElements()
    self:StyleAllAnchors()
end

-- Initialize ThemeIntegration for MoveAny
function ThemeIntegration:Initialize()
    -- Replace existing border creation with themed version
    MoveAny.CreateBorder = function(frame)
        local border = frame:CreateTexture(nil, "OVERLAY")
        ThemeIntegration:ApplyThemeColors(border, "border")
        border:SetAllPoints()
        return border
    end
    
    -- Hook into the CreateAnchor function to apply theming
    local originalCreateAnchor = MoveAny.CreateAnchor
    MoveAny.CreateAnchor = function(self, name, width, height, frameToMove)
        local anchor = originalCreateAnchor(self, name, width, height, frameToMove)
        ThemeIntegration:StyleMoveAnchor(anchor)
        return anchor
    end
    
    -- Register for theme change events
    VUI.EventManager:RegisterCallback("VUI_THEME_CHANGED", function(themeName)
        ThemeIntegration:UpdateAllUIElements()
    end)
end

-- Make theme-related functions accessible through MoveAny
MoveAny.UpdateTheme = function()
    ThemeIntegration:UpdateAllUIElements()
end