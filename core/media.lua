local _, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end

-- Enhanced Media Management System
-- Provides better performance through texture caching, lazy loading, and memory management
-- Now with texture atlas support for further optimization

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
        atlasTextures = {}  -- Map of texture paths to atlas information
    }
    
    -- Create caches for loaded assets
    self.mediaCache = {
        textures = {},      -- Cache for loaded textures
        fonts = {},         -- Cache for loaded fonts
        sounds = {}         -- Cache for loaded sounds
    }
    
    -- Create statistics tracking
    self.mediaStats = {
        texturesLoaded = 0, -- Count of loaded textures
        cacheMisses = 0,    -- Count of cache misses
        cacheHits = 0,      -- Count of cache hits
        memoryUsage = 0,    -- Estimated memory usage
        atlasTexturesSaved = 0,  -- Count of textures saved by atlas system
        atlasMemoryReduction = 0 -- Estimated memory saved by atlas system
    }
    
    -- Create lazy loading queue for media assets
    self.mediaQueue = {}    -- Queue for lazy loading assets
    self.mediaQueueActive = false
    
    -- Register callback for theme changes to clear unused cache
    self:RegisterCallback("ThemeChanged", function() self:ClearUnusedMediaCache() end)
    
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
        -- Legacy themes (kept for backward compatibility)
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
        },
        
        -- New VUI themes
        thunderstorm = {
            name = "Thunder Storm",
            description = "Dark blue theme with electric blue accents",
            background = self.media.backgrounds.thunderstorm,
            border = self.media.borders.thunderstorm,
            statusbar = self.media.statusbars.thunderstorm,
            icon = "Interface\\AddOns\\VUI\\media\\textures\\themes\\thunderstorm\\icon.svg",
            preview = "Interface\\AddOns\\VUI\\media\\textures\\themes\\thunderstorm\\preview.tga",
            colors = {
                backdrop = {r = 0.04, g = 0.04, b = 0.1, a = 0.8}, -- Deep blue background
                border = {r = 0.05, g = 0.62, b = 0.9, a = 1}, -- Electric blue borders
                highlight = {r = 0.1, g = 0.4, b = 0.8, a = 0.3},
                text = {r = 0.8, g = 0.9, b = 1.0, a = 1},
                header = {r = 0.5, g = 0.8, b = 1.0, a = 1},
            },
            effects = {
                glow = "Interface\\AddOns\\VUI\\media\\textures\\themes\\thunderstorm\\glow.tga",
                spark = "Interface\\AddOns\\VUI\\media\\textures\\themes\\thunderstorm\\spark.tga",
            }
        },
        
        phoenixflame = {
            name = "Phoenix Flame",
            description = "Fiery theme with dark red backgrounds and orange accents",
            background = self.media.backgrounds.phoenixflame,
            border = self.media.borders.phoenixflame,
            statusbar = self.media.statusbars.phoenixflame,
            icon = "Interface\\AddOns\\VUI\\media\\textures\\themes\\phoenixflame\\icon.svg",
            preview = "Interface\\AddOns\\VUI\\media\\textures\\themes\\phoenixflame\\preview.tga",
            colors = {
                backdrop = {r = 0.1, g = 0.04, b = 0.02, a = 0.8}, -- Dark red background
                border = {r = 0.9, g = 0.3, b = 0.05, a = 1}, -- Fiery orange borders
                highlight = {r = 0.8, g = 0.4, b = 0.1, a = 0.3},
                text = {r = 1.0, g = 0.9, b = 0.7, a = 1},
                header = {r = 1.0, g = 0.7, b = 0.4, a = 1},
            },
            effects = {
                glow = "Interface\\AddOns\\VUI\\media\\textures\\themes\\phoenixflame\\glow.tga",
                spark = "Interface\\AddOns\\VUI\\media\\textures\\themes\\phoenixflame\\spark.tga",
            }
        },
        
        arcanemystic = {
            name = "Arcane Mystic",
            description = "Mystical purple theme with arcane accents",
            background = self.media.backgrounds.arcanemystic,
            border = self.media.borders.arcanemystic,
            statusbar = self.media.statusbars.arcanemystic,
            icon = "Interface\\AddOns\\VUI\\media\\textures\\themes\\arcanemystic\\icon.svg",
            preview = "Interface\\AddOns\\VUI\\media\\textures\\themes\\arcanemystic\\preview.tga",
            colors = {
                backdrop = {r = 0.1, g = 0.04, b = 0.18, a = 0.8}, -- Deep purple background
                border = {r = 0.62, g = 0.05, b = 0.9, a = 1}, -- Violet borders
                highlight = {r = 0.4, g = 0.1, b = 0.8, a = 0.3},
                text = {r = 0.9, g = 0.8, b = 1.0, a = 1},
                header = {r = 0.8, g = 0.5, b = 1.0, a = 1},
            },
            effects = {
                glow = "Interface\\AddOns\\VUI\\media\\textures\\themes\\arcanemystic\\glow.tga",
                spark = "Interface\\AddOns\\VUI\\media\\textures\\themes\\arcanemystic\\spark.tga",
            }
        },
        
        felenergy = {
            name = "Fel Energy",
            description = "Demonic green theme with fel energy accents",
            background = self.media.backgrounds.felenergy,
            border = self.media.borders.felenergy,
            statusbar = self.media.statusbars.felenergy,
            icon = "Interface\\AddOns\\VUI\\media\\textures\\themes\\felenergy\\icon.svg",
            preview = "Interface\\AddOns\\VUI\\media\\textures\\themes\\felenergy\\preview.tga",
            colors = {
                backdrop = {r = 0.04, g = 0.1, b = 0.04, a = 0.8}, -- Dark green background
                border = {r = 0.1, g = 0.9, b = 0.1, a = 1}, -- Fel green borders
                highlight = {r = 0.1, g = 0.8, b = 0.1, a = 0.3},
                text = {r = 0.7, g = 1.0, b = 0.7, a = 1},
                header = {r = 0.4, g = 1.0, b = 0.4, a = 1},
            },
            effects = {
                glow = "Interface\\AddOns\\VUI\\media\\textures\\themes\\felenergy\\glow.tga",
                spark = "Interface\\AddOns\\VUI\\media\\textures\\themes\\felenergy\\spark.tga",
            }
        }
    }
    
    -- Default fonts - now using PT Sans Narrow as our standard font
    self.media.fonts.normal = "Interface\\AddOns\\VUI\\media\\Fonts\\PTSansNarrow-Regular.ttf"
    self.media.fonts.bold = "Interface\\AddOns\\VUI\\media\\Fonts\\PTSansNarrow-Bold.ttf"
    self.media.fonts.header = "Fonts\\MORPHEUS.TTF"
    
    -- Initialize preloading of essential textures
    self:InitializePreloading()
    
    -- External fonts included with the addon
    self.media.fonts.avant = "Interface\\AddOns\\VUI\\media\\Fonts\\AvantGarde.TTF"
    self.media.fonts.expressway = "Interface\\AddOns\\VUI\\media\\Fonts\\Expressway.ttf"
    self.media.fonts.inter = "Interface\\AddOns\\VUI\\media\\Fonts\\InterBold.ttf"
    self.media.fonts.prototype = "Interface\\AddOns\\VUI\\media\\Fonts\\Prototype.ttf"
    self.media.fonts.ptsans = "Interface\\AddOns\\VUI\\media\\Fonts\\PTSansNarrow-Regular.ttf"
    self.media.fonts.ptsansbold = "Interface\\AddOns\\VUI\\media\\Fonts\\PTSansNarrow-Bold.ttf"
    
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
        LSM:Register("font", "VUI PT Sans Narrow", self.media.fonts.ptsans)
        LSM:Register("font", "VUI PT Sans Narrow Bold", self.media.fonts.ptsansbold)
        
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
    self.UI.GetTexture = function(_, category, name, priority)
        return self:GetTexture(category, name, priority)
    end
    
    -- Connect theme asset functions
    self.UI.GetThemeAsset = function(_, assetType, themeName, priority)
        return self:GetThemeAsset(assetType, themeName, priority)
    end
    
    -- Connect color functions
    self.UI.GetColor = function(_, name, subtype, key)
        return self:GetColor(name, subtype, key)
    end
    
    -- Connect sound functions
    self.UI.PlaySound = function(_, sound)
        self:PlaySound(sound)
    end
    
    -- Connect media management functions
    self.UI.ClearMediaCache = function(_)
        self:ClearUnusedMediaCache()
    end
    
    self.UI.PreloadThemeTextures = function(_, themeName)
        self:PreloadThemeTextures(themeName)
    end
    
    self.UI.GetMediaStats = function(_)
        return self:GetMediaStats()
    end
    
    -- Notify about connection
    self:Debug("Media connected to UI framework with enhanced performance management")
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

-- Helper function to get a texture by name with caching
function VUI:GetTexture(category, name, priority)
    if not category or not name then return "" end
    
    -- Get the texture path
    local texturePath = ""
    if self.media[category] and self.media[category][name] then
        texturePath = self.media[category][name]
    else
        return "" -- Return empty string if not found
    end
    
    -- If we have a texture path, use the caching system
    if texturePath and texturePath ~= "" then
        return self:GetTextureCached(texturePath, priority)
    else
        return texturePath
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

-- Get theme-specific asset for the current or specified theme with caching
function VUI:GetThemeAsset(assetType, themeName, priority)
    themeName = themeName or self.db.profile.appearance.theme or "thunderstorm"
    
    local texturePath
    -- Check if we have a direct registration for this theme and asset type
    if self.media[assetType] and self.media[assetType][themeName] then
        texturePath = self.media[assetType][themeName]
    else
        -- Otherwise get a path based on the standard theme structure
        texturePath = self:GetThemeTexturePath(themeName, assetType)
    end
    
    -- Use texture caching for better performance
    if texturePath and texturePath ~= "" then
        -- Theme assets like borders are HIGH priority
        return self:GetTextureCached(texturePath, priority or "HIGH")
    else
        return texturePath
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

-- Helper function to get a font by name or return a path
-- Enhanced with font atlas support and caching
function VUI:GetFont(fontName)
    -- Handle nil case
    if not fontName then
        return self.media.fonts.normal
    end
    
    -- Check font cache first for best performance
    if self.mediaCache.fonts[fontName] then
        self.mediaStats.cacheHits = self.mediaStats.cacheHits + 1
        return self.mediaCache.fonts[fontName]
    end
    
    local fontPath
    
    -- Check if this is a theme-specific font request (format: "theme_fonttype")
    local theme, fontType = fontName:match("^(%w+)_(%w+)$")
    if theme and fontType and self.FontAtlas then
        fontPath = self.FontAtlas:GetThemeFont(theme, fontType)
        if fontPath then
            -- Cache and return the result
            self.mediaCache.fonts[fontName] = fontPath
            self.mediaStats.cacheMisses = self.mediaStats.cacheMisses + 1
            return fontPath
        end
    end
    
    -- If it's a known font name in our media
    if self.media.fonts[fontName:lower()] then
        fontPath = self.media.fonts[fontName:lower()]
        self.mediaCache.fonts[fontName] = fontPath
        self.mediaStats.cacheMisses = self.mediaStats.cacheMisses + 1
        return fontPath
    end
    
    -- If it already looks like a path, return it
    if fontName:find("\\") then
        -- Cache path-like entries too
        self.mediaCache.fonts[fontName] = fontName
        self.mediaStats.cacheMisses = self.mediaStats.cacheMisses + 1
        return fontName
    end
    
    -- Check LibSharedMedia if available
    if LibStub and LibStub:GetLibrary("LibSharedMedia-3.0", true) then
        local LSM = LibStub:GetLibrary("LibSharedMedia-3.0")
        fontPath = LSM:Fetch("font", fontName)
        if fontPath then
            -- Cache and return the result
            self.mediaCache.fonts[fontName] = fontPath
            self.mediaStats.cacheMisses = self.mediaStats.cacheMisses + 1
            return fontPath
        end
    end
    
    -- Default fallback
    self.mediaCache.fonts[fontName] = self.media.fonts.normal
    self.mediaStats.cacheMisses = self.mediaStats.cacheMisses + 1
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

--------------------------------------------------
-- Enhanced Media Management Functions
--------------------------------------------------

-- Get a texture with caching for better performance
function VUI:GetTextureCached(texturePath, priority)
    if not texturePath then return nil end
    
    -- Check if this texture is available in an atlas
    if self.media.atlasTextures and self.media.atlasTextures[texturePath] then
        local atlasInfo = self.media.atlasTextures[texturePath]
        local atlasPath = self.Atlas:GetAtlasFile(atlasInfo.atlas)
        local coords = self.Atlas:GetTextureCoordinates(atlasInfo.atlas, atlasInfo.key)
        
        if atlasPath and coords then
            -- Ensure atlas is loaded
            self.Atlas:PreloadAtlas(atlasInfo.atlas)
            
            -- Add to stats
            self.mediaStats.cacheHits = self.mediaStats.cacheHits + 1
            
            -- Create a table containing atlas info
            return {
                isAtlas = true,
                path = atlasPath,
                coords = coords,
                originalPath = texturePath
            }
        end
    end
    
    -- If not in atlas, continue with normal texture handling
    
    -- Check if texture is in cache
    if self.mediaCache.textures[texturePath] then
        self.mediaStats.cacheHits = self.mediaStats.cacheHits + 1
        return self.mediaCache.textures[texturePath]
    end
    
    -- Cache miss, will need to load the texture
    self.mediaStats.cacheMisses = self.mediaStats.cacheMisses + 1
    
    -- If it's a high priority texture, load immediately
    if priority == "HIGH" then
        local texture = self:LoadTexture(texturePath)
        self.mediaCache.textures[texturePath] = texture
        return texture
    end
    
    -- Otherwise queue for lazy loading and return a placeholder
    -- Add to lazy loading queue if not already queued
    local alreadyQueued = false
    for _, item in ipairs(self.mediaQueue) do
        if item.path == texturePath then
            alreadyQueued = true
            break
        end
    end
    
    if not alreadyQueued then
        table.insert(self.mediaQueue, {
            type = "texture",
            path = texturePath,
            priority = priority or "MEDIUM"
        })
        
        -- Start lazy loading if not already active
        if not self.mediaQueueActive then
            self:ProcessMediaQueue()
        end
    end
    
    -- Return a placeholder texture for now (solid color based on theme)
    local placeholder = self:GetPlaceholderTexture()
    return placeholder
end

-- Load a texture immediately without caching
function VUI:LoadTexture(texturePath)
    if not texturePath then return nil end
    
    -- Check if this is an atlas texture first
    if self.media.atlasTextures and self.media.atlasTextures[texturePath] then
        local atlasInfo = self.media.atlasTextures[texturePath]
        local atlasPath = self.Atlas:GetAtlasFile(atlasInfo.atlas)
        local coords = self.Atlas:GetTextureCoordinates(atlasInfo.atlas, atlasInfo.key)
        
        if atlasPath and coords then
            -- Ensure atlas is loaded
            self.Atlas:PreloadAtlas(atlasInfo.atlas)
            
            -- Create a table containing atlas info
            return {
                isAtlas = true,
                path = atlasPath,
                coords = coords,
                originalPath = texturePath
            }
        end
    end
    
    -- Regular texture loading
    -- Estimate texture size for memory tracking (very approximate)
    local memoryEstimate = 0.1 -- MB, very rough estimate
    self.mediaStats.memoryUsage = self.mediaStats.memoryUsage + memoryEstimate
    self.mediaStats.texturesLoaded = self.mediaStats.texturesLoaded + 1
    
    return texturePath
end

-- Generate a placeholder texture (solid color based on theme)
function VUI:GetPlaceholderTexture()
    return "Interface\\Buttons\\WHITE8x8"
end

-- Process the media loading queue
function VUI:ProcessMediaQueue()
    self.mediaQueueActive = true
    
    -- Process up to 5 items per frame
    local function ProcessNextBatch()
        local itemsProcessed = 0
        local itemsRemaining = #self.mediaQueue
        
        if itemsRemaining == 0 then
            self.mediaQueueActive = false
            return
        end
        
        -- Sort queue by priority
        table.sort(self.mediaQueue, function(a, b)
            if a.priority == "HIGH" and b.priority ~= "HIGH" then
                return true
            elseif a.priority ~= "HIGH" and b.priority == "HIGH" then
                return false
            else
                return a.priority < b.priority
            end
        end)
        
        -- Process up to 5 items
        for i = 1, math.min(5, itemsRemaining) do
            local item = table.remove(self.mediaQueue, 1)
            
            if item.type == "texture" then
                self.mediaCache.textures[item.path] = self:LoadTexture(item.path)
            elseif item.type == "font" then
                self.mediaCache.fonts[item.path] = item.path -- No font loading required
            elseif item.type == "sound" then
                self.mediaCache.sounds[item.path] = item.path -- No sound loading required
            end
            
            itemsProcessed = itemsProcessed + 1
            
            -- Prevent processing too much in one frame (performance safeguard)
            if itemsProcessed >= 5 then
                break
            end
        end
        
        -- If there are more items, schedule the next batch
        if #self.mediaQueue > 0 then
            C_Timer.After(0.1, ProcessNextBatch)
        else
            self.mediaQueueActive = false
        end
    end
    
    -- Start processing
    ProcessNextBatch()
end

-- Clear unused textures from cache to free memory
function VUI:ClearUnusedMediaCache()
    local currentTheme = self.db.profile.appearance.theme or "thunderstorm"
    local texturesToKeep = {}
    
    -- Identify textures to keep (current theme)
    local function MarkTextureForKeeping(texturePath)
        if texturePath and type(texturePath) == "string" then
            texturesToKeep[texturePath] = true
        end
    end
    
    -- Mark theme textures
    if self.media.themes[currentTheme] then
        local theme = self.media.themes[currentTheme]
        MarkTextureForKeeping(theme.background)
        MarkTextureForKeeping(theme.border)
        MarkTextureForKeeping(theme.statusbar)
        if theme.effects then
            for _, texture in pairs(theme.effects) do
                MarkTextureForKeeping(texture)
            end
        end
    end
    
    -- Mark common textures
    MarkTextureForKeeping(self.media.textures.logo)
    MarkTextureForKeeping(self.media.textures.glow)
    MarkTextureForKeeping(self.media.textures.highlight)
    
    -- Clear unused textures
    for path in pairs(self.mediaCache.textures) do
        if not texturesToKeep[path] then
            self.mediaCache.textures[path] = nil
            
            -- Adjust memory usage estimate
            local memoryEstimate = 0.1 -- MB, very rough estimate
            self.mediaStats.memoryUsage = self.mediaStats.memoryUsage - memoryEstimate
        end
    end
    
    -- Force garbage collection
    collectgarbage("collect")
    
    -- Debug info
    self:Debug("Media cache cleared. Kept " .. self:TableCount(texturesToKeep) .. " textures. Memory estimate: " .. 
               string.format("%.2f", self.mediaStats.memoryUsage) .. " MB")
end

-- Count table entries (helper function)
function VUI:TableCount(t)
    local count = 0
    if type(t) ~= "table" then return 0 end
    for _ in pairs(t) do count = count + 1 end
    return count
end

-- Get media usage statistics
function VUI:GetMediaStats()
    local stats = {
        texturesLoaded = self.mediaStats.texturesLoaded,
        cacheMisses = self.mediaStats.cacheMisses,
        cacheHits = self.mediaStats.cacheHits,
        cacheHitRate = self.mediaStats.cacheHits / (self.mediaStats.cacheHits + self.mediaStats.cacheMisses + 0.001) * 100,
        memoryUsage = string.format("%.2f", self.mediaStats.memoryUsage) .. " MB",
        cacheSize = self:TableCount(self.mediaCache.textures),
        queueSize = #self.mediaQueue,
        
        -- Font system stats
        fontCacheSize = self:TableCount(self.mediaCache.fonts),
    }
    
    -- Add atlas stats if Atlas system is initialized
    if self.Atlas and self.Atlas.GetStats then
        local atlasStats = self.Atlas:GetStats()
        stats.atlasTexturesSaved = atlasStats.texturesSaved
        stats.atlasMemoryReduction = atlasStats.memoryReduction
        stats.atlasesLoaded = atlasStats.atlasesLoaded
    end
    
    -- Add font system stats if FontIntegration system is initialized
    if self.FontIntegration and self.FontIntegration.GetStats then
        local fontStats = self.FontIntegration:GetStats()
        stats.fontObjectsCreated = fontStats.fontObjectsCreated
        stats.fontObjectsReused = fontStats.fontObjectsReused
        stats.fontCalls = fontStats.getCalls
        stats.fontCacheHits = fontStats.cacheHits
        stats.fontCacheMisses = fontStats.cacheMisses
        
        if fontStats.getCalls > 0 then
            stats.fontCacheHitRate = fontStats.cacheHits / (fontStats.getCalls) * 100
        else
            stats.fontCacheHitRate = 0
        end
        
        stats.fontMemoryEstimate = string.format("%.2f", fontStats.memoryEstimate / 1024 / 1024) .. " MB"
    end
    
    return stats
end

-- Preload essential textures for the current theme
function VUI:PreloadThemeTextures(themeName)
    themeName = themeName or self.db.profile.appearance.theme or "thunderstorm"
    
    self:Debug("Preloading textures for theme: " .. themeName)
    
    -- Preload theme assets
    if self.media.themes[themeName] then
        local theme = self.media.themes[themeName]
        
        -- Load core theme assets at HIGH priority
        self:GetTextureCached(theme.background, "HIGH")
        self:GetTextureCached(theme.border, "HIGH")
        self:GetTextureCached(theme.statusbar, "HIGH")
        
        -- Load effects at MEDIUM priority
        if theme.effects then
            for _, texture in pairs(theme.effects) do
                self:GetTextureCached(texture, "MEDIUM")
            end
        end
        
        -- Theme preview can be loaded at LOW priority
        if theme.preview then
            self:GetTextureCached(theme.preview, "LOW")
        end
    end
    
    -- Preload common textures
    self:GetTextureCached(self.media.textures.logo, "HIGH")
    self:GetTextureCached(self.media.textures.glow, "HIGH")
    self:GetTextureCached(self.media.textures.highlight, "MEDIUM")
    
    -- Preload module-specific textures
    for moduleName, moduleTextures in pairs(self.media.textures) do
        if type(moduleTextures) == "table" and moduleName ~= "fonts" and moduleName ~= "sounds" then
            for _, texture in pairs(moduleTextures) do
                self:GetTextureCached(texture, "LOW")
            end
        end
    end
end

-- Initialize preloading of theme textures
function VUI:InitializePreloading()
    -- Start preloading after a short delay to not impact initial loading
    C_Timer.After(1, function()
        self:PreloadThemeTextures()
    end)
    
    -- Set up event to preload new theme when theme changes
    self:RegisterCallback("ThemeChanged", function(newTheme) 
        -- Clear the old theme's cache first
        self:ClearUnusedMediaCache()
        -- Then preload the new theme
        self:PreloadThemeTextures(newTheme)
    end)
end
