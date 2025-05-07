local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end

-- Texture Atlas System
-- Provides efficient texture loading by combining multiple textures into atlases
-- Significantly reduces file operations and memory usage

-- Create Atlas namespace
VUI.Atlas = {}
local Atlas = VUI.Atlas

-- Store atlas data
Atlas.atlases = {}
Atlas.coordinates = {}
Atlas.loaded = {}
Atlas.textureCache = {} -- Cache of loaded textures
Atlas.pendingTextureLoads = {} -- Queue for on-demand texture loading
Atlas.compressionLevel = "HIGH" -- Compression setting (LOW, MEDIUM, HIGH)
Atlas.stats = {
    texturesSaved = 0,
    memoryReduction = 0,
    atlasesLoaded = 0,
    cacheHits = 0,
    cacheMisses = 0,
    texturesCompressed = 0,
    onDemandLoaded = 0
}

-- Define atlas files for each theme
-- Each atlas contains commonly used textures combined into a single file
Atlas.files = {
    -- Common interface elements atlas
    common = {
        path = "Interface\\AddOns\\VUI\\media\\textures\\atlas\\common.tga",
        size = {width = 1024, height = 1024}
    },
    -- Common buttons and icons atlas
    buttons = {
        path = "Interface\\AddOns\\VUI\\media\\textures\\atlas\\buttons.tga",
        size = {width = 512, height = 512}
    },
    -- Theme-specific atlases (one per theme)
    themes = {
        phoenixflame = {
            path = "Interface\\AddOns\\VUI\\media\\textures\\atlas\\phoenixflame.tga",
            size = {width = 1024, height = 1024}
        },
        thunderstorm = {
            path = "Interface\\AddOns\\VUI\\media\\textures\\atlas\\thunderstorm.tga",
            size = {width = 1024, height = 1024}
        },
        arcanemystic = {
            path = "Interface\\AddOns\\VUI\\media\\textures\\atlas\\arcanemystic.tga",
            size = {width = 1024, height = 1024}
        },
        felenergy = {
            path = "Interface\\AddOns\\VUI\\media\\textures\\atlas\\felenergy.tga",
            size = {width = 1024, height = 1024}
        }
    },
    -- Module-specific atlases
    modules = {
        buffoverlay = {
            path = "Interface\\AddOns\\VUI\\media\\textures\\atlas\\buffoverlay.tga",
            size = {width = 512, height = 512}
        },
        omnicd = {
            path = "Interface\\AddOns\\VUI\\media\\textures\\atlas\\omnicd.tga",
            size = {width = 512, height = 512}
        },
        trufigcd = {
            path = "Interface\\AddOns\\VUI\\media\\textures\\atlas\\trufigcd.tga",
            size = {width = 512, height = 512}
        },
        multinotification = {
            path = "Interface\\AddOns\\VUI\\media\\textures\\atlas\\modules\\multinotification.tga",
            size = {width = 512, height = 512}
        },
        moveany = {
            path = "Interface\\AddOns\\VUI\\media\\textures\\atlas\\modules\\moveany.tga",
            size = {width = 512, height = 512}
        }
    }
}

-- Texture coordinate mappings for each atlas
-- These define where in the atlas each texture is located
Atlas.coordinates.common = {
    ["border-simple"] = {left = 0, right = 0.25, top = 0, bottom = 0.25},
    ["background-dark"] = {left = 0.25, right = 0.5, top = 0, bottom = 0.25},
    ["background-light"] = {left = 0.5, right = 0.75, top = 0, bottom = 0.25},
    ["background-solid"] = {left = 0.75, right = 1, top = 0, bottom = 0.25},
    ["statusbar-smooth"] = {left = 0, right = 0.25, top = 0.25, bottom = 0.3125},
    ["statusbar-flat"] = {left = 0.25, right = 0.5, top = 0.25, bottom = 0.3125},
    ["statusbar-gloss"] = {left = 0.5, right = 0.75, top = 0.25, bottom = 0.3125},
    ["glow"] = {left = 0, right = 0.25, top = 0.3125, bottom = 0.5625},
    ["highlight"] = {left = 0.25, right = 0.5, top = 0.3125, bottom = 0.5625},
    ["shadow"] = {left = 0.5, right = 0.75, top = 0.3125, bottom = 0.5625},
    ["logo"] = {left = 0, right = 0.5, top = 0.5625, bottom = 0.8125}
}

Atlas.coordinates.buttons = {
    ["button-normal"] = {left = 0, right = 0.25, top = 0, bottom = 0.25},
    ["button-highlight"] = {left = 0.25, right = 0.5, top = 0, bottom = 0.25},
    ["button-pushed"] = {left = 0.5, right = 0.75, top = 0, bottom = 0.25},
    ["button-disabled"] = {left = 0.75, right = 1, top = 0, bottom = 0.25},
    ["checkbox-normal"] = {left = 0, right = 0.125, top = 0.25, bottom = 0.375},
    ["checkbox-checked"] = {left = 0.125, right = 0.25, top = 0.25, bottom = 0.375},
    ["radio-normal"] = {left = 0.25, right = 0.375, top = 0.25, bottom = 0.375},
    ["radio-checked"] = {left = 0.375, right = 0.5, top = 0.25, bottom = 0.375},
    ["dropdown"] = {left = 0.5, right = 0.75, top = 0.25, bottom = 0.375},
    ["slider"] = {left = 0.75, right = 1, top = 0.25, bottom = 0.375},
    ["tab-selected"] = {left = 0, right = 0.25, top = 0.375, bottom = 0.5},
    ["tab-unselected"] = {left = 0.25, right = 0.5, top = 0.375, bottom = 0.5}
}

-- Theme-specific coordinates (showing thunderstorm as example, others would be similar)
Atlas.coordinates.themes = {
    thunderstorm = {
        ["border"] = {left = 0, right = 0.25, top = 0, bottom = 0.25},
        ["background"] = {left = 0.25, right = 0.5, top = 0, bottom = 0.25},
        ["statusbar"] = {left = 0, right = 0.25, top = 0.25, bottom = 0.3125},
        ["glow"] = {left = 0, right = 0.25, top = 0.3125, bottom = 0.5625},
        ["spark"] = {left = 0.25, right = 0.5, top = 0.3125, bottom = 0.5625},
        ["preview"] = {left = 0, right = 0.5, top = 0.5625, bottom = 0.8125}
    },
    phoenixflame = {
        ["border"] = {left = 0, right = 0.25, top = 0, bottom = 0.25},
        ["background"] = {left = 0.25, right = 0.5, top = 0, bottom = 0.25},
        ["statusbar"] = {left = 0, right = 0.25, top = 0.25, bottom = 0.3125},
        ["glow"] = {left = 0, right = 0.25, top = 0.3125, bottom = 0.5625},
        ["spark"] = {left = 0.25, right = 0.5, top = 0.3125, bottom = 0.5625},
        ["preview"] = {left = 0, right = 0.5, top = 0.5625, bottom = 0.8125}
    },
    arcanemystic = {
        ["border"] = {left = 0, right = 0.25, top = 0, bottom = 0.25},
        ["background"] = {left = 0.25, right = 0.5, top = 0, bottom = 0.25},
        ["statusbar"] = {left = 0, right = 0.25, top = 0.25, bottom = 0.3125},
        ["glow"] = {left = 0, right = 0.25, top = 0.3125, bottom = 0.5625},
        ["spark"] = {left = 0.25, right = 0.5, top = 0.3125, bottom = 0.5625},
        ["preview"] = {left = 0, right = 0.5, top = 0.5625, bottom = 0.8125}
    },
    felenergy = {
        ["border"] = {left = 0, right = 0.25, top = 0, bottom = 0.25},
        ["background"] = {left = 0.25, right = 0.5, top = 0, bottom = 0.25},
        ["statusbar"] = {left = 0, right = 0.25, top = 0.25, bottom = 0.3125},
        ["glow"] = {left = 0, right = 0.25, top = 0.3125, bottom = 0.5625},
        ["spark"] = {left = 0.25, right = 0.5, top = 0.3125, bottom = 0.5625},
        ["preview"] = {left = 0, right = 0.5, top = 0.5625, bottom = 0.8125}
    }
}

-- Module-specific coordinates 
Atlas.coordinates.modules = {
    buffoverlay = {
        ["logo"] = {left = 0, right = 0.5, top = 0, bottom = 0.5},
        ["logo_transparent"] = {left = 0.5, right = 1.0, top = 0, bottom = 0.5},
        ["background"] = {left = 0, right = 0.25, top = 0.5, bottom = 0.75},
        ["border"] = {left = 0.25, right = 0.5, top = 0.5, bottom = 0.75},
        ["glow"] = {left = 0.5, right = 0.75, top = 0.5, bottom = 0.75},
        ["icon-frame"] = {left = 0.75, right = 1.0, top = 0.5, bottom = 0.75},
        ["cooldown-swipe"] = {left = 0, right = 0.25, top = 0.75, bottom = 1.0},
        ["priority-icon"] = {left = 0.25, right = 0.5, top = 0.75, bottom = 1.0}
    },
    omnicd = {
        ["logo"] = {left = 0, right = 0.5, top = 0, bottom = 0.5},
        ["logo_transparent"] = {left = 0.5, right = 1.0, top = 0, bottom = 0.5},
        ["background"] = {left = 0, right = 0.25, top = 0.5, bottom = 0.75},
        ["border"] = {left = 0.25, right = 0.5, top = 0.5, bottom = 0.75},
        ["icon-frame"] = {left = 0.5, right = 0.75, top = 0.5, bottom = 0.75},
        ["header"] = {left = 0.75, right = 1.0, top = 0.5, bottom = 0.75},
        ["cooldown-swipe"] = {left = 0, right = 0.25, top = 0.75, bottom = 1.0},
        ["ready-pulse"] = {left = 0.25, right = 0.5, top = 0.75, bottom = 1.0},
        ["highlight"] = {left = 0.5, right = 0.75, top = 0.75, bottom = 1.0},
        ["statusbar"] = {left = 0.75, right = 1.0, top = 0.75, bottom = 1.0}
    },
    trufigcd = {
        ["logo"] = {left = 0, right = 0.5, top = 0, bottom = 0.5},
        ["logo_transparent"] = {left = 0.5, right = 1.0, top = 0, bottom = 0.5},
        ["background"] = {left = 0, right = 0.25, top = 0.5, bottom = 0.75},
        ["border"] = {left = 0.25, right = 0.5, top = 0.5, bottom = 0.75},
        ["icon-frame"] = {left = 0.5, right = 0.75, top = 0.5, bottom = 0.75},
        ["config-button"] = {left = 0.75, right = 0.875, top = 0.5, bottom = 0.625},
        ["config-button-highlight"] = {left = 0.875, right = 1.0, top = 0.5, bottom = 0.625},
        ["cooldown-swipe"] = {left = 0, right = 0.25, top = 0.75, bottom = 1.0}
    },
    multinotification = {
        ["notification-background"] = {left = 0, right = 0.25, top = 0, bottom = 0.25},
        ["notification-border"] = {left = 0.25, right = 0.5, top = 0, bottom = 0.25},
        ["notification-glow"] = {left = 0.5, right = 0.75, top = 0, bottom = 0.25},
        ["notification-icon-frame"] = {left = 0.75, right = 1.0, top = 0, bottom = 0.25},
        ["spell-alert-frame"] = {left = 0, right = 0.25, top = 0.25, bottom = 0.5},
        ["interrupt-icon"] = {left = 0.25, right = 0.375, top = 0.25, bottom = 0.375},
        ["dispel-icon"] = {left = 0.375, right = 0.5, top = 0.25, bottom = 0.375},
        ["important-icon"] = {left = 0.5, right = 0.625, top = 0.25, bottom = 0.375},
        ["cooldown-spiral"] = {left = 0.625, right = 0.75, top = 0.25, bottom = 0.375}
    },
    moveany = {
        ["logo"] = {left = 0, right = 0.5, top = 0, bottom = 0.5},
        ["logo_transparent"] = {left = 0.5, right = 1.0, top = 0, bottom = 0.5},
        ["background"] = {left = 0, right = 0.25, top = 0.5, bottom = 0.75},
        ["border"] = {left = 0.25, right = 0.5, top = 0.5, bottom = 0.75},
        ["header"] = {left = 0.5, right = 0.75, top = 0.5, bottom = 0.75},
        ["grid"] = {left = 0.75, right = 1.0, top = 0.5, bottom = 0.75},
        ["handle"] = {left = 0, right = 0.125, top = 0.75, bottom = 0.875},
        ["mover"] = {left = 0.125, right = 0.25, top = 0.75, bottom = 0.875},
        ["lock"] = {left = 0.25, right = 0.375, top = 0.75, bottom = 0.875},
        ["unlock"] = {left = 0.375, right = 0.5, top = 0.75, bottom = 0.875},
        ["hidden"] = {left = 0.5, right = 0.625, top = 0.75, bottom = 0.875},
        ["visible"] = {left = 0.625, right = 0.75, top = 0.75, bottom = 0.875}
    }
}

-- Get atlas texture path and coordinates for a given texture
function Atlas:GetTextureInfo(texturePath)
    -- Convert texture path to atlas key
    local atlasKey = self:GetAtlasKeyFromTexturePath(texturePath)
    if not atlasKey then
        return nil, nil -- Not in an atlas
    end
    
    -- Determine which atlas contains this texture
    local atlasName, textureKey = self:GetAtlasForTexture(atlasKey)
    if not atlasName or not textureKey then
        return nil, nil -- Not found in any atlas
    end
    
    -- Get the atlas file and coordinates
    local atlasFile = self:GetAtlasFile(atlasName)
    local coords = self:GetTextureCoordinates(atlasName, textureKey)
    
    if not atlasFile or not coords then
        return nil, nil
    end
    
    return atlasFile, coords
end

-- Parse texture path to get atlas key
function Atlas:GetAtlasKeyFromTexturePath(texturePath)
    -- Safety check
    if not texturePath then return nil end
    
    -- Common textures (like border-simple, background-dark, etc.)
    if texturePath:match("common[/\\]([%w-]+)%.%w+$") then
        return texturePath:match("common[/\\]([%w-]+)%.%w+$")
    end
    
    -- Theme-specific textures
    local theme, textureType = texturePath:match("themes[/\\](%w+)[/\\]([%w-]+)%.%w+$")
    if theme and textureType then
        return textureType
    end
    
    -- Module-specific textures
    local module, fileName = texturePath:match("([%w-]+)[/\\]([%w-_]+)%.%w+$")
    if module and fileName and self.coordinates.modules[module] then
        return fileName
    end
    
    return nil
end

-- Get the atlas name for a given texture
function Atlas:GetAtlasForTexture(atlasKey)
    -- Check common atlas
    if self.coordinates.common[atlasKey] then
        return "common", atlasKey
    end
    
    -- Check buttons atlas
    if self.coordinates.buttons[atlasKey] then
        return "buttons", atlasKey
    end
    
    -- Check theme atlases
    for theme, coords in pairs(self.coordinates.themes) do
        if coords[atlasKey] then
            return "themes." .. theme, atlasKey
        end
    end
    
    -- Check module atlases
    for module, coords in pairs(self.coordinates.modules) do
        if coords[atlasKey] then
            return "modules." .. module, atlasKey
        end
    end
    
    return nil, nil
end

-- Get atlas file from atlas name
function Atlas:GetAtlasFile(atlasName)
    if atlasName == "common" then
        return self.files.common.path
    elseif atlasName == "buttons" then
        return self.files.buttons.path
    elseif atlasName:find("^themes%.") then
        local theme = atlasName:match("^themes%.(.+)$")
        return self.files.themes[theme] and self.files.themes[theme].path
    elseif atlasName:find("^modules%.") then
        local module = atlasName:match("^modules%.(.+)$")
        return self.files.modules[module] and self.files.modules[module].path
    end
    
    return nil
end

-- Get texture coordinates from atlas name and key
function Atlas:GetTextureCoordinates(atlasName, textureKey)
    if atlasName == "common" then
        return self.coordinates.common[textureKey]
    elseif atlasName == "buttons" then
        return self.coordinates.buttons[textureKey]
    elseif atlasName:find("^themes%.") then
        local theme = atlasName:match("^themes%.(.+)$")
        return self.coordinates.themes[theme] and self.coordinates.themes[theme][textureKey]
    elseif atlasName:find("^modules%.") then
        local module = atlasName:match("^modules%.(.+)$")
        return self.coordinates.modules[module] and self.coordinates.modules[module][textureKey]
    end
    
    return nil
end

-- Preload an atlas to ensure it's available
function Atlas:PreloadAtlas(atlasName)
    if self.loaded[atlasName] then
        return -- Already loaded
    end
    
    local atlasPath = self:GetAtlasFile(atlasName)
    if not atlasPath then
        return -- Invalid atlas
    end
    
    -- Add to loaded atlases
    self.loaded[atlasName] = true
    self.stats.atlasesLoaded = self.stats.atlasesLoaded + 1
    
    -- Update stats (approximate values)
    if atlasName == "common" or atlasName == "buttons" then
        self.stats.texturesSaved = self.stats.texturesSaved + VUI:TableCount(self.coordinates[atlasName])
    elseif atlasName:find("^themes%.") then
        local theme = atlasName:match("^themes%.(.+)$")
        self.stats.texturesSaved = self.stats.texturesSaved + 
            VUI:TableCount(self.coordinates.themes[theme])
    elseif atlasName:find("^modules%.") then
        local module = atlasName:match("^modules%.(.+)$")
        self.stats.texturesSaved = self.stats.texturesSaved + 
            VUI:TableCount(self.coordinates.modules[module])
    end
    
    -- Estimate memory saved (very approximate)
    self.stats.memoryReduction = self.stats.texturesSaved * 0.05
end

-- Initialize the texture atlas system
function Atlas:Initialize()
    -- Initialize texture cache and optimization settings
    self.textureCache = {}
    self.pendingTextureLoads = {}
    
    -- Determine default compression level based on system performance
    self:DetermineOptimalCompressionLevel()
    
    -- Register atlases with VUI's media system
    self:RegisterWithMediaSystem()
    
    -- Add methods to handle texture atlas usage
    self:ExtendMediaSystem()
    
    -- Preload common atlases (essential ones immediately, others on-demand)
    self:PreloadAtlas("common")
    self:PreloadAtlas("buttons")
    
    -- Preload current theme atlas
    local currentTheme = VUI.db.profile.appearance.theme or "thunderstorm"
    self:PreloadAtlas("themes." .. currentTheme)
    
    -- Queue module-specific atlases for on-demand loading based on enabled modules
    self:QueueModuleAtlases()
    
    -- Listen for theme changes to preload new theme atlas
    VUI:RegisterCallback("ThemeChanged", function(newTheme)
        self:PreloadAtlas("themes." .. newTheme)
    end)
    

end

-- Register atlas textures with the VUI media system
function Atlas:RegisterWithMediaSystem()
    -- Map common texture paths to atlas textures
    VUI.media.atlasTextures = {
        ["Interface\\AddOns\\VUI\\media\\textures\\common\\border-simple.tga"] = {
            atlas = "common",
            key = "border-simple"
        },
        ["Interface\\AddOns\\VUI\\media\\textures\\common\\background-dark.tga"] = {
            atlas = "common",
            key = "background-dark"
        },
        ["Interface\\AddOns\\VUI\\media\\textures\\common\\background-light.tga"] = {
            atlas = "common",
            key = "background-light"
        },
        ["Interface\\AddOns\\VUI\\media\\textures\\common\\background-solid.tga"] = {
            atlas = "common",
            key = "background-solid"
        },
        ["Interface\\AddOns\\VUI\\media\\textures\\common\\statusbar-smooth.blp"] = {
            atlas = "common",
            key = "statusbar-smooth"
        },
        ["Interface\\AddOns\\VUI\\media\\textures\\common\\statusbar-flat.blp"] = {
            atlas = "common",
            key = "statusbar-flat"
        },
        ["Interface\\AddOns\\VUI\\media\\textures\\common\\statusbar-gloss.tga"] = {
            atlas = "common",
            key = "statusbar-gloss"
        },
        ["Interface\\AddOns\\VUI\\media\\textures\\glow.tga"] = {
            atlas = "common",
            key = "glow"
        },
        ["Interface\\AddOns\\VUI\\media\\textures\\highlight.tga"] = {
            atlas = "common",
            key = "highlight"
        },
        ["Interface\\AddOns\\VUI\\media\\textures\\logo.tga"] = {
            atlas = "common",
            key = "logo"
        }
    }
    
    -- Add theme-specific textures
    for theme, _ in pairs(self.coordinates.themes) do
        VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. theme .. "\\border.tga"] = {
            atlas = "themes." .. theme,
            key = "border"
        }
        VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. theme .. "\\background.tga"] = {
            atlas = "themes." .. theme,
            key = "background"
        }
        VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. theme .. "\\statusbar.blp"] = {
            atlas = "themes." .. theme,
            key = "statusbar"
        }
        VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. theme .. "\\glow.tga"] = {
            atlas = "themes." .. theme,
            key = "glow"
        }
        VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. theme .. "\\spark.tga"] = {
            atlas = "themes." .. theme,
            key = "spark"
        }
        VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. theme .. "\\preview.tga"] = {
            atlas = "themes." .. theme,
            key = "preview"
        }
    end
    
    -- Add module-specific textures for BuffOverlay
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\buffoverlay\\logo.tga"] = {
        atlas = "modules.buffoverlay",
        key = "logo"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\buffoverlay\\logo_transparent.tga"] = {
        atlas = "modules.buffoverlay",
        key = "logo_transparent"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\buffoverlay\\background.tga"] = {
        atlas = "modules.buffoverlay",
        key = "background"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\buffoverlay\\border.tga"] = {
        atlas = "modules.buffoverlay",
        key = "border"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\buffoverlay\\glow.tga"] = {
        atlas = "modules.buffoverlay",
        key = "glow"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\buffoverlay\\icon-frame.tga"] = {
        atlas = "modules.buffoverlay",
        key = "icon-frame"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\buffoverlay\\cooldown-swipe.tga"] = {
        atlas = "modules.buffoverlay",
        key = "cooldown-swipe"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\buffoverlay\\priority-icon.tga"] = {
        atlas = "modules.buffoverlay",
        key = "priority-icon"
    }
    -- Add module-specific textures for OmniCD
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\omnicd\\logo.tga"] = {
        atlas = "modules.omnicd",
        key = "logo"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\omnicd\\logo_transparent.tga"] = {
        atlas = "modules.omnicd",
        key = "logo_transparent"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\omnicd\\background.tga"] = {
        atlas = "modules.omnicd",
        key = "background"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\omnicd\\border.tga"] = {
        atlas = "modules.omnicd",
        key = "border"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\omnicd\\icon-frame.tga"] = {
        atlas = "modules.omnicd",
        key = "icon-frame"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\omnicd\\header.tga"] = {
        atlas = "modules.omnicd",
        key = "header"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\omnicd\\cooldown-swipe.tga"] = {
        atlas = "modules.omnicd",
        key = "cooldown-swipe"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\omnicd\\ready-pulse.tga"] = {
        atlas = "modules.omnicd",
        key = "ready-pulse"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\omnicd\\highlight.tga"] = {
        atlas = "modules.omnicd",
        key = "highlight"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\omnicd\\statusbar.tga"] = {
        atlas = "modules.omnicd",
        key = "statusbar"
    }
    -- Add module-specific textures for TrufiGCD
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\trufigcd\\logo.tga"] = {
        atlas = "modules.trufigcd",
        key = "logo"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\trufigcd\\logo_transparent.tga"] = {
        atlas = "modules.trufigcd",
        key = "logo_transparent"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\trufigcd\\background.tga"] = {
        atlas = "modules.trufigcd",
        key = "background"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\trufigcd\\border.tga"] = {
        atlas = "modules.trufigcd",
        key = "border"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\trufigcd\\icon-frame.tga"] = {
        atlas = "modules.trufigcd",
        key = "icon-frame"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\trufigcd\\config-button.tga"] = {
        atlas = "modules.trufigcd",
        key = "config-button"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\trufigcd\\config-button-highlight.tga"] = {
        atlas = "modules.trufigcd",
        key = "config-button-highlight"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\trufigcd\\cooldown-swipe.tga"] = {
        atlas = "modules.trufigcd",
        key = "cooldown-swipe"
    }
    
    -- Add MultiNotification textures
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\multinotification\\notification-background.tga"] = {
        atlas = "modules.multinotification",
        key = "notification-background"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\multinotification\\notification-border.tga"] = {
        atlas = "modules.multinotification",
        key = "notification-border"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\multinotification\\notification-glow.tga"] = {
        atlas = "modules.multinotification",
        key = "notification-glow"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\multinotification\\notification-icon-frame.tga"] = {
        atlas = "modules.multinotification",
        key = "notification-icon-frame"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\multinotification\\spell-alert-frame.tga"] = {
        atlas = "modules.multinotification",
        key = "spell-alert-frame"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\multinotification\\interrupt-icon.tga"] = {
        atlas = "modules.multinotification",
        key = "interrupt-icon"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\multinotification\\dispel-icon.tga"] = {
        atlas = "modules.multinotification",
        key = "dispel-icon"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\multinotification\\important-icon.tga"] = {
        atlas = "modules.multinotification",
        key = "important-icon"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\multinotification\\cooldown-spiral.tga"] = {
        atlas = "modules.multinotification",
        key = "cooldown-spiral"
    }
    
    -- Add MoveAny module textures
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\moveany\\logo.tga"] = {
        atlas = "modules.moveany",
        key = "logo"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\moveany\\logo_transparent.tga"] = {
        atlas = "modules.moveany",
        key = "logo_transparent"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\moveany\\background.tga"] = {
        atlas = "modules.moveany",
        key = "background"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\moveany\\border.tga"] = {
        atlas = "modules.moveany",
        key = "border"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\moveany\\header.tga"] = {
        atlas = "modules.moveany",
        key = "header"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\moveany\\grid.tga"] = {
        atlas = "modules.moveany",
        key = "grid"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\moveany\\handle.tga"] = {
        atlas = "modules.moveany",
        key = "handle"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\moveany\\mover.tga"] = {
        atlas = "modules.moveany",
        key = "mover"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\moveany\\lock.tga"] = {
        atlas = "modules.moveany",
        key = "lock"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\moveany\\unlock.tga"] = {
        atlas = "modules.moveany",
        key = "unlock"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\moveany\\hidden.tga"] = {
        atlas = "modules.moveany",
        key = "hidden"
    }
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\moveany\\visible.tga"] = {
        atlas = "modules.moveany",
        key = "visible"
    }
end

-- Extend VUI's media system with atlas methods
function Atlas:ExtendMediaSystem()
    -- Store original GetTextureCached function
    VUI.GetTextureCachedOriginal = VUI.GetTextureCached
    
    -- Override with atlas-aware version and texture caching
    VUI.GetTextureCached = function(self, texturePath, priority)
        -- Check if this texture is already in our memory cache
        local cachedTexture, cachedCoords = VUI.Atlas:GetCachedTexture(texturePath)
        if cachedTexture then
            -- Update last accessed time
            if VUI.Atlas.textureCache[texturePath] then
                VUI.Atlas.textureCache[texturePath].lastAccessed = GetTime()
            end
            
            -- Return the cached texture information
            return {
                isAtlas = true,
                texture = cachedTexture,
                coords = cachedCoords,
                cached = true,
                originalPath = texturePath
            }
        end
        
        -- Check if this texture is in an atlas
        if self.media.atlasTextures and self.media.atlasTextures[texturePath] then
            local atlasInfo = self.media.atlasTextures[texturePath]
            local atlasPath = VUI.Atlas:GetAtlasFile(atlasInfo.atlas)
            local coords = VUI.Atlas:GetTextureCoordinates(atlasInfo.atlas, atlasInfo.key)
            
            if atlasPath and coords then
                -- For high-priority textures, load immediately
                if priority and priority >= 3 then
                    -- Ensure atlas is loaded
                    VUI.Atlas:PreloadAtlas(atlasInfo.atlas)
                    
                    -- Create texture and add to cache
                    local texture = CreateFrame("Frame"):CreateTexture(nil, "BACKGROUND")
                    texture:SetTexture(atlasPath)
                    texture:SetTexCoord(coords.left, coords.right, coords.top, coords.bottom)
                    
                    -- Apply texture compression for memory efficiency
                    texture = VUI.Atlas:CompressTexture(texture)
                    
                    -- Cache the texture for future use
                    VUI.Atlas:CacheTexture(texturePath, texture, coords)
                    
                    -- Add to stats
                    self.mediaStats.cacheHits = self.mediaStats.cacheHits + 1
                    
                    -- Return the texture information
                    return {
                        isAtlas = true,
                        texture = texture,
                        path = atlasPath,
                        coords = coords,
                        originalPath = texturePath
                    }
                else
                    -- For low-priority textures, load on-demand
                    VUI.Atlas:QueueTextureForLoading(atlasInfo.atlas, atlasInfo.key, priority or 1)
                    
                    -- Just return the information for now
                    return {
                        isAtlas = true,
                        path = atlasPath,
                        coords = coords,
                        queuedForLoading = true,
                        originalPath = texturePath
                    }
                end
            end
        end
        
        -- Fall back to original method if not in atlas
        return self:GetTextureCachedOriginal(texturePath, priority)
    end
    
    -- Add atlas stats to media stats
    local originalGetMediaStats = VUI.GetMediaStats
    VUI.GetMediaStats = function(self)
        local stats = originalGetMediaStats(self)
        
        -- Add enhanced atlas stats
        stats.atlasTexturesSaved = VUI.Atlas.stats.texturesSaved
        stats.atlasMemoryReduction = VUI.Atlas.stats.memoryReduction
        stats.atlasesLoaded = VUI.Atlas.stats.atlasesLoaded
        stats.atlasCacheHits = VUI.Atlas.stats.cacheHits
        stats.atlasCacheMisses = VUI.Atlas.stats.cacheMisses
        stats.atlasTexturesCompressed = VUI.Atlas.stats.texturesCompressed
        stats.atlasOnDemandLoaded = VUI.Atlas.stats.onDemandLoaded
        stats.atlasCompressionLevel = VUI.Atlas.compressionLevel
        
        return stats
    end
end

-- Function to apply atlas texture to a texture object
function Atlas:ApplyTextureCoordinates(textureObject, atlasInfo)
    if not textureObject or not atlasInfo or not atlasInfo.isAtlas then return end
    
    -- If we have a cached texture, use that directly
    if atlasInfo.cached and atlasInfo.texture then
        -- Clone the texture properties to the target texture object
        textureObject:SetTexture(atlasInfo.texture:GetTexture())
        textureObject:SetTexCoord(
            atlasInfo.coords.left,
            atlasInfo.coords.right,
            atlasInfo.coords.top,
            atlasInfo.coords.bottom
        )
        
        -- Apply compression settings
        self:CompressTexture(textureObject)
        return
    end
    
    -- If it's queued for loading but not yet loaded, prioritize it
    if atlasInfo.queuedForLoading then
        -- Extract atlas name and key from the path
        local atlasName, textureKey
        for atlas, info in pairs(self.files) do
            if info.path == atlasInfo.path then
                atlasName = atlas
                break
            end
        end
        
        -- Extract module atlas name if needed
        if not atlasName then
            for module, info in pairs(self.files.modules) do
                if info.path == atlasInfo.path then
                    atlasName = "modules." .. module
                    break
                end
            end
        end
        
        -- Extract theme atlas name if needed
        if not atlasName then
            for theme, info in pairs(self.files.themes) do
                if info.path == atlasInfo.path then
                    atlasName = "themes." .. theme
                    break
                end
            end
        end
        
        -- Find the texture key by coordinates
        if atlasName then
            for key, coords in pairs(self:GetCoordinatesTable(atlasName)) do
                if coords.left == atlasInfo.coords.left and 
                   coords.right == atlasInfo.coords.right and
                   coords.top == atlasInfo.coords.top and
                   coords.bottom == atlasInfo.coords.bottom then
                    textureKey = key
                    break
                end
            end
        end
        
        -- If we found both, prioritize loading
        if atlasName and textureKey then
            self:QueueTextureForLoading(atlasName, textureKey, 10) -- High priority
        end
    end
    
    -- Otherwise use the traditional approach
    textureObject:SetTexture(atlasInfo.path)
    textureObject:SetTexCoord(
        atlasInfo.coords.left,
        atlasInfo.coords.right,
        atlasInfo.coords.top,
        atlasInfo.coords.bottom
    )
    
    -- Apply compression
    self:CompressTexture(textureObject)
end

-- Helper function to get the coordinates table for an atlas
function Atlas:GetCoordinatesTable(atlasName)
    if atlasName == "common" then
        return self.coordinates.common
    elseif atlasName == "buttons" then
        return self.coordinates.buttons
    elseif atlasName:find("^themes%.") then
        local theme = atlasName:match("^themes%.(.+)$")
        return self.coordinates.themes[theme]
    elseif atlasName:find("^modules%.") then
        local module = atlasName:match("^modules%.(.+)$")
        return self.coordinates.modules[module]
    end
    return {}
end

-- Compress texture atlas for better memory efficiency
function Atlas:CompressTexture(texture, level)
    -- Skip if no texture
    if not texture then return texture end
    
    local compressionLevel = level or self.compressionLevel
    local result = texture
    
    -- Apply compression based on level
    if compressionLevel == "LOW" then
        -- Light compression - just drop mipmap levels
        texture:SetTextureLevels(3) -- Reduce mipmap levels
    elseif compressionLevel == "MEDIUM" then
        -- Medium compression - drop mipmaps and reduce detail
        texture:SetTextureLevels(2)
        
        -- Set the texture to a slightly lower resolution if possible
        if texture.SetResolution then
            texture:SetResolution(64)
        end
    elseif compressionLevel == "HIGH" then
        -- High compression - maximum memory savings
        texture:SetTextureLevels(1) -- Minimal mipmaps
        
        -- Set the texture to a lower resolution if possible
        if texture.SetResolution then
            texture:SetResolution(32)
        end
        
        -- Reduce texture quality if possible
        if texture.SetTextureQuality then
            texture:SetTextureQuality(1)
        end
    end
    
    -- Update stats
    self.stats.texturesCompressed = self.stats.texturesCompressed + 1
    
    return result
end

-- Set compression level for texture atlases
function Atlas:SetCompressionLevel(level)
    if level ~= "LOW" and level ~= "MEDIUM" and level ~= "HIGH" then
        return false -- Invalid level
    end
    
    -- Set new compression level
    self.compressionLevel = level
    
    -- Re-compress any textures in the cache
    for texturePath, textureInfo in pairs(self.textureCache) do
        if textureInfo.texture then
            textureInfo.texture = self:CompressTexture(textureInfo.texture, level)
        end
    end
    
    return true
end

-- Implement texture cache system for better performance
function Atlas:GetCachedTexture(texturePath)
    -- Check if the texture is already in our cache
    if self.textureCache[texturePath] then
        self.stats.cacheHits = self.stats.cacheHits + 1
        return self.textureCache[texturePath].texture, self.textureCache[texturePath].coords
    end
    
    -- Not in cache
    self.stats.cacheMisses = self.stats.cacheMisses + 1
    return nil, nil
end

-- Add texture to cache system
function Atlas:CacheTexture(texturePath, texture, coords)
    -- Skip if already cached
    if self.textureCache[texturePath] then
        return
    end
    
    -- Apply compression before caching
    local compressedTexture = self:CompressTexture(texture)
    
    -- Add to cache
    self.textureCache[texturePath] = {
        texture = compressedTexture,
        coords = coords,
        lastAccessed = GetTime(),
        size = (texture.GetTexSize and texture:GetTexSize()) or 0
    }
    
    -- Limit cache size (simple LRU implementation)
    self:ManageTextureCache()
end

-- Remove oldest or least used textures from cache if it gets too large
function Atlas:ManageTextureCache()
    local maxCacheEntries = 100 -- Maximum number of textures to keep in cache
    
    -- Count cache entries
    local count = 0
    for _ in pairs(self.textureCache) do
        count = count + 1
    end
    
    -- If cache is not too large, do nothing
    if count <= maxCacheEntries then
        return
    end
    
    -- Create sorted list of textures by last access time
    local sortedTextures = {}
    for path, info in pairs(self.textureCache) do
        table.insert(sortedTextures, {
            path = path,
            lastAccessed = info.lastAccessed
        })
    end
    
    -- Sort by last accessed time (oldest first)
    table.sort(sortedTextures, function(a, b)
        return a.lastAccessed < b.lastAccessed
    end)
    
    -- Remove oldest entries until we're under the limit
    for i = 1, count - maxCacheEntries do
        self.textureCache[sortedTextures[i].path] = nil
    end
end

-- Queue texture for on-demand loading
function Atlas:QueueTextureForLoading(atlasName, textureKey, priority)
    if not atlasName or not textureKey then
        return
    end
    
    -- Add to queue with priority (higher = more important)
    table.insert(self.pendingTextureLoads, {
        atlasName = atlasName,
        textureKey = textureKey,
        priority = priority or 1,
        queued = GetTime()
    })
    
    -- Sort queue by priority (highest first)
    table.sort(self.pendingTextureLoads, function(a, b)
        return a.priority > b.priority
    end)
    
    -- Start the on-demand loading process if not already running
    self:ProcessTextureLoadQueue()
end

-- Process texture load queue (load textures one at a time)
function Atlas:ProcessTextureLoadQueue()
    -- Skip if queue is empty
    if #self.pendingTextureLoads == 0 then
        return
    end
    
    -- Get highest priority texture from queue
    local nextTexture = table.remove(self.pendingTextureLoads, 1)
    
    -- Get atlas file and coordinates for texture
    local atlasFile = self:GetAtlasFile(nextTexture.atlasName)
    local coords = self:GetTextureCoordinates(nextTexture.atlasName, nextTexture.textureKey)
    
    if atlasFile and coords then
        -- Create texture object
        local texture = CreateFrame("Frame"):CreateTexture(nil, "BACKGROUND")
        texture:SetTexture(atlasFile)
        texture:SetTexCoord(coords.left, coords.right, coords.top, coords.bottom)
        
        -- Apply compression
        texture = self:CompressTexture(texture)
        
        -- Add to cache
        local texturePath = atlasFile .. ":" .. nextTexture.textureKey
        self:CacheTexture(texturePath, texture, coords)
        
        -- Update stats
        self.stats.onDemandLoaded = self.stats.onDemandLoaded + 1
    end
    
    -- Process next texture in queue (if any)
    if #self.pendingTextureLoads > 0 then
        -- Schedule next texture load with a slight delay to prevent freezing
        C_Timer.After(0.01, function()
            self:ProcessTextureLoadQueue()
        end)
    end
end

-- Determine optimal compression level based on system performance
function Atlas:DetermineOptimalCompressionLevel()
    -- Default to medium compression
    local level = "MEDIUM"
    
    -- Check if we have performance settings
    if VUI.db and VUI.db.profile and VUI.db.profile.performance then
        -- If memory management is enabled, use high compression
        if VUI.db.profile.performance.memoryManagement then
            level = "HIGH"
        -- If texture optimization is disabled, use low compression
        elseif not VUI.db.profile.performance.textureOptimization then
            level = "LOW"
        end
        
        -- If lite mode is enabled, use high compression regardless
        if VUI.db.profile.liteMode and VUI.db.profile.liteMode.enabled then
            level = "HIGH"
        end
    end
    
    -- Set the compression level
    self.compressionLevel = level
    
    -- Log the selected compression level
    VUI:Print("Atlas texture compression level: " .. level)
    
    return level
end

-- Queue module-specific atlases for on-demand loading based on enabled modules
function Atlas:QueueModuleAtlases()
    -- Check if modules are defined
    if not VUI.db or not VUI.db.profile or not VUI.db.profile.modules then
        return
    end
    
    -- Queue each module's atlas if the module is enabled
    for moduleName, moduleSettings in pairs(VUI.db.profile.modules) do
        if moduleSettings.enabled and self.files.modules[moduleName] then
            -- Queue this module's atlas textures with low priority (will load when needed)
            local atlasName = "modules." .. moduleName
            
            -- Get all texture keys for this module
            if self.coordinates.modules[moduleName] then
                for textureKey, _ in pairs(self.coordinates.modules[moduleName]) do
                    -- Queue for loading with low priority (1)
                    self:QueueTextureForLoading(atlasName, textureKey, 1)
                end
            end
        end
    end
end

-- Enhanced atlas stats for display
function Atlas:GetStats()
    return {
        texturesSaved = self.stats.texturesSaved,
        memoryReduction = string.format("%.2f MB", self.stats.memoryReduction),
        atlasesLoaded = self.stats.atlasesLoaded,
        cacheHits = self.stats.cacheHits,
        cacheMisses = self.stats.cacheMisses,
        texturesCompressed = self.stats.texturesCompressed,
        onDemandLoaded = self.stats.onDemandLoaded,
        compressionLevel = self.compressionLevel,
        cachingEnabled = (next(self.textureCache) ~= nil) and "Yes" or "No",
        pendingLoads = #self.pendingTextureLoads
    }
end

-- Return the atlas system
VUI:RegisterModule("Atlas", Atlas)