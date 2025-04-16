local _, VUI = ...

-- Media initialization
function VUI:InitializeMedia()
    -- Create the media table to store all textures, fonts, and sounds
    self.media = {
        textures = {},
        fonts = {},
        borders = {},
        backgrounds = {},
        statusbars = {},
    }
    
    -- Register default textures
    self.media.textures.logo = "Interface\\AddOns\\VUI\\media\\textures\\logo"
    self.media.textures.glow = "Interface\\AddOns\\VUI\\media\\textures\\glow"
    self.media.textures.highlight = "Interface\\AddOns\\VUI\\media\\textures\\highlight"
    
    -- Register default borders
    self.media.borders.thin = "Interface\\DialogFrame\\UI-DialogBox-Border"
    self.media.borders.dialog = "Interface\\DialogFrame\\UI-DialogBox-Border"
    self.media.borders.simple = "Interface\\AddOns\\VUI\\media\\textures\\border-simple"
    
    -- Register default backgrounds
    self.media.backgrounds.dark = "Interface\\AddOns\\VUI\\media\\textures\\background-dark"
    self.media.backgrounds.light = "Interface\\AddOns\\VUI\\media\\textures\\background-light"
    self.media.backgrounds.solid = "Interface\\AddOns\\VUI\\media\\textures\\background-solid"
    
    -- Register default statusbars
    self.media.statusbars.smooth = "Interface\\AddOns\\VUI\\media\\textures\\statusbar-smooth"
    self.media.statusbars.flat = "Interface\\AddOns\\VUI\\media\\textures\\statusbar-flat"
    self.media.statusbars.gloss = "Interface\\AddOns\\VUI\\media\\textures\\statusbar-gloss"
    
    -- Default fonts - using built-in WoW fonts to avoid file size issues
    self.media.fonts.normal = "Fonts\\FRIZQT__.TTF"
    self.media.fonts.bold = "Fonts\\ARIALN.TTF"
    self.media.fonts.header = "Fonts\\MORPHEUS.TTF"
    
    -- Load LibSharedMedia if available for more options
    if LibStub and LibStub:GetLibrary("LibSharedMedia-3.0", true) then
        local LSM = LibStub:GetLibrary("LibSharedMedia-3.0")
        
        -- Register our media with LibSharedMedia
        LSM:Register("font", "VUI Normal", self.media.fonts.normal)
        LSM:Register("font", "VUI Bold", self.media.fonts.bold)
        LSM:Register("font", "VUI Header", self.media.fonts.header)
        
        LSM:Register("statusbar", "VUI Smooth", self.media.statusbars.smooth)
        LSM:Register("statusbar", "VUI Flat", self.media.statusbars.flat)
        LSM:Register("statusbar", "VUI Gloss", self.media.statusbars.gloss)
        
        LSM:Register("border", "VUI Thin", self.media.borders.thin)
        LSM:Register("border", "VUI Simple", self.media.borders.simple)
        
        LSM:Register("background", "VUI Dark", self.media.backgrounds.dark)
        LSM:Register("background", "VUI Light", self.media.backgrounds.light)
        LSM:Register("background", "VUI Solid", self.media.backgrounds.solid)
    end
    
    -- Create color table
    self.colors = {
        white = {r = 1, g = 1, b = 1},
        black = {r = 0, g = 0, b = 0},
        gray = {r = 0.5, g = 0.5, b = 0.5},
        red = {r = 1, g = 0, b = 0},
        green = {r = 0, g = 1, b = 0},
        blue = {r = 0, g = 0, b = 1},
        yellow = {r = 1, g = 1, b = 0},
        orange = {r = 1, g = 0.5, b = 0},
        purple = {r = 0.7, g = 0, b = 1},
        
        -- Class colors
        class = {},
        
        -- Power types
        power = {
            ["MANA"] = {r = 0.25, g = 0.5, b = 1.0},
            ["RAGE"] = {r = 1.0, g = 0.0, b = 0.0},
            ["FOCUS"] = {r = 1.0, g = 0.5, b = 0.25},
            ["ENERGY"] = {r = 1.0, g = 1.0, b = 0.0},
            ["RUNES"] = {r = 0.5, g = 0.5, b = 0.5},
            ["RUNIC_POWER"] = {r = 0.0, g = 0.82, b = 1.0},
            ["SOUL_SHARDS"] = {r = 0.5, g = 0.32, b = 0.55},
            ["HOLY_POWER"] = {r = 0.95, g = 0.9, b = 0.6},
            ["FURY"] = {r = 0.788, g = 0.259, b = 0.992},
            ["MAELSTROM"] = {r = 0.0, g = 0.5, b = 1.0},
            ["INSANITY"] = {r = 0.4, g = 0, b = 0.8},
            ["LUNAR_POWER"] = {r = 0.3, g = 0.52, b = 0.9},
            ["PAIN"] = {r = 1.0, g = 0.61, b = 0.0},
        },
        
        -- Item quality colors
        quality = {
            [0] = {r = 0.62, g = 0.62, b = 0.62}, -- Poor
            [1] = {r = 1.00, g = 1.00, b = 1.00}, -- Common
            [2] = {r = 0.44, g = 0.83, b = 0.02}, -- Uncommon
            [3] = {r = 0.00, g = 0.44, b = 0.87}, -- Rare
            [4] = {r = 0.64, g = 0.21, b = 0.93}, -- Epic
            [5] = {r = 1.00, g = 0.50, b = 0.00}, -- Legendary
            [6] = {r = 0.98, g = 0.81, b = 0.21}, -- Artifact
            [7] = {r = 0.00, g = 0.80, b = 1.00}, -- Heirloom
        },
    }
    
    -- Populate class colors from the game's RAID_CLASS_COLORS
    for class, color in pairs(RAID_CLASS_COLORS) do
        self.colors.class[class] = {r = color.r, g = color.g, b = color.b}
    end
end

-- Helper function to create a color object from RGB values
function VUI:CreateColor(r, g, b, a)
    return {r = r or 1, g = g or 1, b = b or 1, a = a or 1}
end

-- Helper function to get a color by name
function VUI:GetColor(name, subtype, key)
    if not name then return self:CreateColor(1, 1, 1) end
    
    if subtype and key and self.colors[name] and self.colors[name][subtype] and self.colors[name][subtype][key] then
        return self.colors[name][subtype][key]
    elseif subtype and self.colors[name] and self.colors[name][subtype] then
        return self.colors[name][subtype]
    elseif self.colors[name] then
        return self.colors[name]
    else
        return self:CreateColor(1, 1, 1) -- Default to white
    end
end

-- Helper function to get a texture by name
function VUI:GetTexture(category, name)
    if not category or not name then return "" end
    
    if self.media[category] and self.media[category][name] then
        return self.media[category][name]
    else
        return "" -- Return empty string if not found
    end
end

-- Helper function to apply a texture to a frame
function VUI:ApplyTexture(frame, texture)
    if not frame or not texture then return end
    
    if type(texture) == "string" then
        frame:SetTexture(texture)
    elseif type(texture) == "table" and texture.r and texture.g and texture.b then
        frame:SetColorTexture(texture.r, texture.g, texture.b, texture.a or 1)
    end
end

-- Helper function to apply a color to a font string
function VUI:ApplyFontColor(fontString, color)
    if not fontString or not color then return end
    
    if type(color) == "table" and color.r and color.g and color.b then
        fontString:SetTextColor(color.r, color.g, color.b, color.a or 1)
    elseif type(color) == "string" and self.colors[color] then
        local c = self.colors[color]
        fontString:SetTextColor(c.r, c.g, c.b, c.a or 1)
    end
end

-- Helper function to set font on a font string
function VUI:ApplyFont(fontString, font, size, flags)
    if not fontString then return end
    
    local fontPath = font
    if type(font) == "string" and not font:find("\\") then
        -- If it's not a path, look it up in our media table
        fontPath = self:GetTexture("fonts", font) or "Fonts\\FRIZQT__.TTF"
    end
    
    fontString:SetFont(fontPath, size or 12, flags or "")
end

-- Helper function to create a backdrop table for Frame:SetBackdrop
function VUI:CreateBackdrop(bgColor, borderColor, borderSize, inset)
    bgColor = bgColor or self:GetColor("black")
    borderColor = borderColor or self:GetColor("gray")
    borderSize = borderSize or 1
    inset = inset or 0
    
    local backdrop = {
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = false,
        tileSize = 0,
        edgeSize = borderSize,
        insets = {left = inset, right = inset, top = inset, bottom = inset}
    }
    
    return backdrop, {r = bgColor.r, g = bgColor.g, b = bgColor.b, a = bgColor.a or 1}, 
                     {r = borderColor.r, g = borderColor.g, b = borderColor.b, a = borderColor.a or 1}
end
