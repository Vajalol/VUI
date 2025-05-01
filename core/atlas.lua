local _, VUI = ...

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
Atlas.stats = {
    texturesSaved = 0,
    memoryReduction = 0,
    atlasesLoaded = 0
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
        ["border"] = {left = 0, right = 0.5, top = 0, bottom = 0.5}
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
    -- Register atlases with VUI's media system
    self:RegisterWithMediaSystem()
    
    -- Add methods to handle texture atlas usage
    self:ExtendMediaSystem()
    
    -- Preload common atlases
    self:PreloadAtlas("common")
    self:PreloadAtlas("buttons")
    
    -- Preload current theme atlas
    local currentTheme = VUI.db.profile.appearance.theme or "thunderstorm"
    self:PreloadAtlas("themes." .. currentTheme)
    
    -- Listen for theme changes to preload new theme atlas
    VUI:RegisterCallback("ThemeChanged", function(newTheme)
        self:PreloadAtlas("themes." .. newTheme)
    end)
    
    VUI:Debug("Texture Atlas System initialized")
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
    VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\omnicd\\border.tga"] = {
        atlas = "modules.omnicd",
        key = "border"
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
end

-- Extend VUI's media system with atlas methods
function Atlas:ExtendMediaSystem()
    -- Store original GetTextureCached function
    VUI.GetTextureCachedOriginal = VUI.GetTextureCached
    
    -- Override with atlas-aware version
    VUI.GetTextureCached = function(self, texturePath, priority)
        -- Check if this texture is in an atlas
        if self.media.atlasTextures and self.media.atlasTextures[texturePath] then
            local atlasInfo = self.media.atlasTextures[texturePath]
            local atlasPath = VUI.Atlas:GetAtlasFile(atlasInfo.atlas)
            local coords = VUI.Atlas:GetTextureCoordinates(atlasInfo.atlas, atlasInfo.key)
            
            if atlasPath and coords then
                -- Ensure atlas is loaded
                VUI.Atlas:PreloadAtlas(atlasInfo.atlas)
                
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
        
        -- Fall back to original method if not in atlas
        return self:GetTextureCachedOriginal(texturePath, priority)
    end
    
    -- Add atlas stats to media stats
    local originalGetMediaStats = VUI.GetMediaStats
    VUI.GetMediaStats = function(self)
        local stats = originalGetMediaStats(self)
        
        -- Add atlas stats
        stats.atlasTexturesSaved = VUI.Atlas.stats.texturesSaved
        stats.atlasMemoryReduction = VUI.Atlas.stats.memoryReduction
        stats.atlasesLoaded = VUI.Atlas.stats.atlasesLoaded
        
        return stats
    end
end

-- Function to apply atlas texture to a texture object
function Atlas:ApplyTextureCoordinates(textureObject, atlasInfo)
    if not textureObject or not atlasInfo or not atlasInfo.isAtlas then return end
    
    textureObject:SetTexture(atlasInfo.path)
    textureObject:SetTexCoord(
        atlasInfo.coords.left,
        atlasInfo.coords.right,
        atlasInfo.coords.top,
        atlasInfo.coords.bottom
    )
end

-- Get atlas stats for display
function Atlas:GetStats()
    return {
        texturesSaved = self.stats.texturesSaved,
        memoryReduction = string.format("%.2f MB", self.stats.memoryReduction),
        atlasesLoaded = self.stats.atlasesLoaded
    }
end

-- Return the atlas system
VUI:RegisterModule("Atlas", Atlas)