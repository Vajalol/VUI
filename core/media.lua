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
        sounds = {},
        icons = {},
    }
    
    -- Register default textures
    self.media.textures.logo = "Interface\\AddOns\\VUI\\media\\textures\\logo.tga"
    self.media.textures.glow = "Interface\\AddOns\\VUI\\media\\textures\\glow.tga"
    self.media.textures.highlight = "Interface\\AddOns\\VUI\\media\\textures\\highlight.tga"
    
    -- Register default borders
    self.media.borders.thin = "Interface\\DialogFrame\\UI-DialogBox-Border"
    self.media.borders.dialog = "Interface\\DialogFrame\\UI-DialogBox-Border"
    self.media.borders.simple = "Interface\\AddOns\\VUI\\media\\textures\\common\\border-simple.tga"
    
    -- Register theme-specific borders
    self.media.borders.phoenixflame = "Interface\\AddOns\\VUI\\media\\textures\\themes\\phoenixflame\\border.tga"
    self.media.borders.thunderstorm = "Interface\\AddOns\\VUI\\media\\textures\\themes\\thunderstorm\\border.tga"
    self.media.borders.arcanemystic = "Interface\\AddOns\\VUI\\media\\textures\\themes\\arcanemystic\\border.tga"
    self.media.borders.felenergy = "Interface\\AddOns\\VUI\\media\\textures\\themes\\felenergy\\border.tga"
    
    -- Register default backgrounds
    self.media.backgrounds.dark = "Interface\\AddOns\\VUI\\media\\textures\\common\\background-dark.tga"
    self.media.backgrounds.light = "Interface\\AddOns\\VUI\\media\\textures\\common\\background-light.tga" 
    self.media.backgrounds.solid = "Interface\\AddOns\\VUI\\media\\textures\\common\\background-solid.tga"
    
    -- Register theme-specific backgrounds
    self.media.backgrounds.phoenixflame = "Interface\\AddOns\\VUI\\media\\textures\\themes\\phoenixflame\\background.tga"
    self.media.backgrounds.thunderstorm = "Interface\\AddOns\\VUI\\media\\textures\\themes\\thunderstorm\\background.tga"
    self.media.backgrounds.arcanemystic = "Interface\\AddOns\\VUI\\media\\textures\\themes\\arcanemystic\\background.tga"
    self.media.backgrounds.felenergy = "Interface\\AddOns\\VUI\\media\\textures\\themes\\felenergy\\background.tga"
    
    -- Register default statusbars
    self.media.statusbars.smooth = "Interface\\AddOns\\VUI\\media\\textures\\common\\statusbar-smooth.blp"
    self.media.statusbars.flat = "Interface\\AddOns\\VUI\\media\\textures\\common\\statusbar-flat.blp"
    self.media.statusbars.gloss = "Interface\\AddOns\\VUI\\media\\textures\\common\\statusbar-gloss.tga"
    
    -- Register theme-specific statusbars
    self.media.statusbars.phoenixflame = "Interface\\AddOns\\VUI\\media\\textures\\themes\\phoenixflame\\statusbar.blp"
    self.media.statusbars.thunderstorm = "Interface\\AddOns\\VUI\\media\\textures\\themes\\thunderstorm\\statusbar.blp"
    self.media.statusbars.arcanemystic = "Interface\\AddOns\\VUI\\media\\textures\\themes\\arcanemystic\\statusbar.blp"
    self.media.statusbars.felenergy = "Interface\\AddOns\\VUI\\media\\textures\\themes\\felenergy\\statusbar.blp"
    
    -- Register sounds
    self.media.sounds.select = "Sound\\Interface\\iAbilitiesOpen.ogg"
    self.media.sounds.close = "Sound\\Interface\\igMainMenuClose.ogg"
    self.media.sounds.warning = "Sound\\Interface\\AlarmClockWarning3.ogg"
    self.media.sounds.button = "Sound\\Interface\\igMainMenuOptionCheckBoxOn.ogg"
    
    -- Register module-specific textures
    self.media.textures.buffoverlay = {
        logo = "Interface\\AddOns\\VUI\\media\\textures\\buffoverlay\\logo.tga",
        logo_transparent = "Interface\\AddOns\\VUI\\media\\textures\\buffoverlay\\logo_transparent.tga"
    }
    
    self.media.textures.angrykeystone = {
        bar = "Interface\\AddOns\\VUI\\media\\textures\\angrykeystone\\bar.blp",
    }
    
    self.media.textures.omnicd = {
        border = "Interface\\AddOns\\VUI\\media\\textures\\omnicd\\border.tga",
    }
    
    self.media.textures.trufigcd = {
        border = "Interface\\AddOns\\VUI\\media\\textures\\trufigcd\\border.tga",
    }
    
    -- Theme-specific textures
    self.media.themes = {
        dark = {
            background = self.media.backgrounds.dark,
            border = self.media.borders.simple,
            statusbar = self.media.statusbars.smooth,
            colors = {
                backdrop = {r = 0.1, g = 0.1, b = 0.1, a = 0.8},
                border = {r = 0.4, g = 0.4, b = 0.4, a = 1},
                highlight = {r = 0.3, g = 0.3, b = 0.3, a = 0.5},
                text = {r = 1, g = 1, b = 1, a = 1},
                header = {r = 1, g = 0.9, b = 0.8, a = 1},
            }
        },
        light = {
            background = self.media.backgrounds.light,
            border = self.media.borders.simple,
            statusbar = self.media.statusbars.smooth,
            colors = {
                backdrop = {r = 0.8, g = 0.8, b = 0.8, a = 0.8},
                border = {r = 0.6, g = 0.6, b = 0.6, a = 1},
                highlight = {r = 0.7, g = 0.7, b = 0.7, a = 0.5},
                text = {r = 0.1, g = 0.1, b = 0.1, a = 1},
                header = {r = 0.1, g = 0.1, b = 0.3, a = 1},
            }
        },
        classic = {
            background = self.media.backgrounds.dark,
            border = self.media.borders.dialog,
            statusbar = self.media.statusbars.gloss,
            colors = {
                backdrop = {r = 0.15, g = 0.15, b = 0.2, a = 0.8},
                border = {r = 0.6, g = 0.5, b = 0.3, a = 1},
                highlight = {r = 0.4, g = 0.3, b = 0.2, a = 0.5},
                text = {r = 0.9, g = 0.8, b = 0.7, a = 1},
                header = {r = 1, g = 0.9, b = 0.7, a = 1},
            }
        },
        minimal = {
            background = self.media.backgrounds.solid,
            border = "",
            statusbar = self.media.statusbars.flat,
            colors = {
                backdrop = {r = 0.05, g = 0.05, b = 0.05, a = 0.5},
                border = {r = 0.3, g = 0.3, b = 0.3, a = 0.7},
                highlight = {r = 0.2, g = 0.2, b = 0.2, a = 0.3},
                text = {r = 1, g = 1, b = 1, a = 1},
                header = {r = 0.9, g = 0.9, b = 0.9, a = 1},
            }
        }
    }
    
    -- Default fonts - using built-in WoW fonts to avoid file size issues
    self.media.fonts.normal = "Fonts\\FRIZQT__.TTF"
    self.media.fonts.bold = "Fonts\\ARIALN.TTF"
    self.media.fonts.header = "Fonts\\MORPHEUS.TTF"
    
    -- External fonts included with the addon
    self.media.fonts.avant = "Interface\\AddOns\\VUI\\media\\Fonts\\AvantGarde.TTF"
    self.media.fonts.expressway = "Interface\\AddOns\\VUI\\media\\Fonts\\Expressway.ttf"
    self.media.fonts.inter = "Interface\\AddOns\\VUI\\media\\Fonts\\InterBold.ttf"
    self.media.fonts.prototype = "Interface\\AddOns\\VUI\\media\\Fonts\\Prototype.ttf"
    
    -- Load LibSharedMedia if available for more options
    if LibStub and LibStub:GetLibrary("LibSharedMedia-3.0", true) then
        local LSM = LibStub:GetLibrary("LibSharedMedia-3.0")
        
        -- Register our media with LibSharedMedia
        LSM:Register("font", "VUI Normal", self.media.fonts.normal)
        LSM:Register("font", "VUI Bold", self.media.fonts.bold)
        LSM:Register("font", "VUI Header", self.media.fonts.header)
        LSM:Register("font", "VUI Avant Garde", self.media.fonts.avant)
        LSM:Register("font", "VUI Expressway", self.media.fonts.expressway)
        LSM:Register("font", "VUI Inter", self.media.fonts.inter)
        LSM:Register("font", "VUI Prototype", self.media.fonts.prototype)
        
        LSM:Register("statusbar", "VUI Smooth", self.media.statusbars.smooth)
        LSM:Register("statusbar", "VUI Flat", self.media.statusbars.flat)
        LSM:Register("statusbar", "VUI Gloss", self.media.statusbars.gloss)
        
        LSM:Register("border", "VUI Thin", self.media.borders.thin)
        LSM:Register("border", "VUI Simple", self.media.borders.simple)
        
        LSM:Register("background", "VUI Dark", self.media.backgrounds.dark)
        LSM:Register("background", "VUI Light", self.media.backgrounds.light)
        LSM:Register("background", "VUI Solid", self.media.backgrounds.solid)
        
        LSM:Register("sound", "VUI Select", self.media.sounds.select)
        LSM:Register("sound", "VUI Close", self.media.sounds.close)
        LSM:Register("sound", "VUI Warning", self.media.sounds.warning)
        LSM:Register("sound", "VUI Button", self.media.sounds.button)
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
        
        -- UI specific colors
        header = {r = 1, g = 0.9, b = 0.8},
        title = {r = 0.9, g = 0.8, b = 0.6},
        highlight = {r = 0.25, g = 0.25, b = 0.25},
        
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
    
    -- Connect media to UI framework
    self:RegisterMediaWithUI()
end

-- Connect our media with the UI framework
function VUI:RegisterMediaWithUI()
    -- Wait until UI is loaded
    if not self.UI then return end
    
    -- Register theme media with UI
    self.UI.themes = self.media.themes
    
    -- Connect font functions
    self.UI.GetFont = function(_, fontName)
        return self:GetFont(fontName)
    end
    
    -- Connect texture functions
    self.UI.GetTexture = function(_, category, name)
        return self:GetTexture(category, name)
    end
    
    -- Connect color functions
    self.UI.GetColor = function(_, name, subtype, key)
        return self:GetColor(name, subtype, key)
    end
    
    -- Connect sound functions
    self.UI.PlaySound = function(_, sound)
        self:PlaySound(sound)
    end
    
    -- Notify about connection
    self:Print("Media connected to UI framework")
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

-- Get theme-specific texture path
function VUI:GetThemeTexturePath(themeName, textureType, assetName)
    themeName = themeName or self.db.profile.appearance.theme or "thunderstorm"
    return "Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. themeName .. "\\" .. (textureType or "") .. (assetName and "\\" .. assetName or "")
end

-- Get common texture path
function VUI:GetCommonTexturePath(textureType, assetName)
    return "Interface\\AddOns\\VUI\\media\\textures\\common\\" .. (textureType or "") .. (assetName and "\\" .. assetName or "")
end

-- Get theme-specific asset for the current or specified theme
function VUI:GetThemeAsset(assetType, themeName)
    themeName = themeName or self.db.profile.appearance.theme or "thunderstorm"
    
    -- Check if we have a direct registration for this theme and asset type
    if self.media[assetType] and self.media[assetType][themeName] then
        return self.media[assetType][themeName]
    end
    
    -- Otherwise return a path based on the standard theme structure
    return self:GetThemeTexturePath(themeName, assetType)
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

-- Helper function to get a font by name or return a path
function VUI:GetFont(fontName)
    if not fontName then
        return self.media.fonts.normal
    end
    
    -- If it's a known font name in our media
    if self.media.fonts[fontName] then
        return self.media.fonts[fontName]
    end
    
    -- If it already looks like a path, return it
    if fontName:find("\\") then
        return fontName
    end
    
    -- Check LibSharedMedia if available
    if LibStub and LibStub:GetLibrary("LibSharedMedia-3.0", true) then
        local LSM = LibStub:GetLibrary("LibSharedMedia-3.0")
        local path = LSM:Fetch("font", fontName)
        if path then
            return path
        end
    end
    
    -- Default fallback
    return self.media.fonts.normal
end

-- Play a UI sound
function VUI:PlaySound(sound)
    if not sound then return end
    
    -- If it's already a path, play it directly
    if type(sound) == "string" and sound:find("\\") then
        PlaySoundFile(sound, "Master")
        return
    end
    
    -- If it's a named sound in our media
    if type(sound) == "string" and self.media.sounds[sound] then
        PlaySoundFile(self.media.sounds[sound], "Master")
        return
    end
    
    -- Check if it's a kit from the game
    if type(sound) == "string" then
        -- Try to play as a sound kit
        local success = pcall(function() PlaySound(sound) end)
        if success then return end
    end
    
    -- If we're here, we couldn't play the sound
    self:Print("Could not play sound: " .. tostring(sound))
end
