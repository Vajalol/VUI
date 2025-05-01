-- Atlas Generation Tool
-- This file is used during development to combine individual textures into texture atlases.
-- Not used during normal addon operation - only for development and maintenance.

local _, VUI = ...

-- Atlas Generator
VUI.AtlasGenerator = {
    outputPath = "media/textures/atlas/",
    texturePaths = {},
    atlasDefinitions = {}
}

local AtlasGenerator = VUI.AtlasGenerator

-- Define textures to combine into atlases
function AtlasGenerator:Initialize()
    -- Common interface elements
    self.atlasDefinitions.common = {
        size = {width = 1024, height = 1024},
        textures = {
            {
                path = "media/textures/common/border-simple.tga",
                position = {x = 0, y = 0},
                size = {width = 256, height = 256},
                key = "border-simple"
            },
            {
                path = "media/textures/common/background-dark.tga",
                position = {x = 256, y = 0},
                size = {width = 256, height = 256},
                key = "background-dark"
            },
            {
                path = "media/textures/common/background-light.tga",
                position = {x = 512, y = 0},
                size = {width = 256, height = 256},
                key = "background-light"
            },
            {
                path = "media/textures/common/background-solid.tga",
                position = {x = 768, y = 0},
                size = {width = 256, height = 256},
                key = "background-solid"
            },
            {
                path = "media/textures/common/statusbar-smooth.blp",
                position = {x = 0, y = 256},
                size = {width = 256, height = 64},
                key = "statusbar-smooth"
            },
            {
                path = "media/textures/common/statusbar-flat.blp",
                position = {x = 256, y = 256},
                size = {width = 256, height = 64},
                key = "statusbar-flat"
            },
            {
                path = "media/textures/common/statusbar-gloss.tga",
                position = {x = 512, y = 256},
                size = {width = 256, height = 64},
                key = "statusbar-gloss"
            },
            {
                path = "media/textures/glow.tga",
                position = {x = 0, y = 320},
                size = {width = 256, height = 256},
                key = "glow"
            },
            {
                path = "media/textures/highlight.tga",
                position = {x = 256, y = 320},
                size = {width = 256, height = 256},
                key = "highlight"
            },
            {
                path = "media/textures/shadow.tga",
                position = {x = 512, y = 320},
                size = {width = 256, height = 256},
                key = "shadow"
            },
            {
                path = "media/textures/logo.tga",
                position = {x = 0, y = 576},
                size = {width = 512, height = 256},
                key = "logo"
            }
        }
    }
    
    -- Theme-specific atlases (example for thunderstorm theme)
    self.atlasDefinitions.thunderstorm = {
        size = {width = 1024, height = 1024},
        textures = {
            {
                path = "media/textures/themes/thunderstorm/border.tga",
                position = {x = 0, y = 0},
                size = {width = 256, height = 256},
                key = "border"
            },
            {
                path = "media/textures/themes/thunderstorm/background.tga",
                position = {x = 256, y = 0},
                size = {width = 256, height = 256},
                key = "background"
            },
            {
                path = "media/textures/themes/thunderstorm/statusbar.blp",
                position = {x = 0, y = 256},
                size = {width = 256, height = 64},
                key = "statusbar"
            },
            {
                path = "media/textures/themes/thunderstorm/glow.tga",
                position = {x = 0, y = 320},
                size = {width = 256, height = 256},
                key = "glow"
            },
            {
                path = "media/textures/themes/thunderstorm/spark.tga",
                position = {x = 256, y = 320},
                size = {width = 256, height = 256},
                key = "spark"
            },
            {
                path = "media/textures/themes/thunderstorm/preview.tga",
                position = {x = 0, y = 576},
                size = {width = 512, height = 256},
                key = "preview"
            }
        }
    }
    
    -- Generate coordinate information
    self:GenerateCoordinateInfo()
end

-- Generate coordinate information for each texture in each atlas
function AtlasGenerator:GenerateCoordinateInfo()
    local coordinateInfo = {}
    
    for atlasName, atlas in pairs(self.atlasDefinitions) do
        coordinateInfo[atlasName] = {}
        
        for _, texture in ipairs(atlas.textures) do
            local left = texture.position.x / atlas.size.width
            local right = (texture.position.x + texture.size.width) / atlas.size.width
            local top = texture.position.y / atlas.size.height
            local bottom = (texture.position.y + texture.size.height) / atlas.size.height
            
            coordinateInfo[atlasName][texture.key] = {
                left = left,
                right = right,
                top = top,
                bottom = bottom
            }
        end
    end
    
    -- Print coordinate information for copy-pasting into atlas.lua
    self:PrintCoordinates(coordinateInfo)
end

-- Print coordinate information in a format that can be copied into atlas.lua
function AtlasGenerator:PrintCoordinates(coordinateInfo)
    for atlasName, coords in pairs(coordinateInfo) do
        print("Atlas.coordinates." .. atlasName .. " = {")
        
        for textureName, texCoords in pairs(coords) do
            print(string.format('    ["%s"] = {left = %.2f, right = %.2f, top = %.2f, bottom = %.2f},',
                textureName, texCoords.left, texCoords.right, texCoords.top, texCoords.bottom))
        end
        
        print("}")
    end
end

-- Create atlas texture combiners for each defined atlas
function AtlasGenerator:GenerateAtlases()
    -- This would interface with an external texture combining tool
    -- or use canvas drawing to combine textures
    -- Note: This is a simplified version and would need external tools in practice
    
    print("Atlas generation would create the following files:")
    for atlasName, _ in pairs(self.atlasDefinitions) do
        print(self.outputPath .. atlasName .. ".tga")
    end
    
    print("\nPlease use an image editor to combine the textures according to")
    print("the coordinates specified in the atlas definitions.")
    
    -- In a full implementation, this would actually generate the texture atlases
    -- but that's beyond the scope of this Lua-only implementation
end

-- Create an atlas template documentation file
function AtlasGenerator:CreateDocumentation()
    local docFile = self.outputPath .. "ATLAS_DOCUMENTATION.md"
    local content = [[# Texture Atlas Documentation

This document describes the texture atlases used in VUI and how to work with them.

## Atlases Overview

VUI uses the following texture atlases:

- **common.tga**: Common interface elements used across the addon
- **buttons.tga**: Button textures and UI controls
- **themes/phoenixflame.tga**: Phoenix Flame theme textures
- **themes/thunderstorm.tga**: Thunder Storm theme textures
- **themes/arcanemystic.tga**: Arcane Mystic theme textures
- **themes/felenergy.tga**: Fel Energy theme textures
- **modules/buffoverlay.tga**: BuffOverlay module textures
- **modules/omnicd.tga**: OmniCD module textures
- **modules/trufigcd.tga**: TrufiGCD module textures

## Working with Atlas Textures

When creating a UI element that uses a texture from an atlas:

1. Use the Atlas system to apply the texture:
```lua
local button = CreateFrame("Button", nil, parent)
button:SetSize(32, 32)

-- Get the atlas texture information
local atlasInfo = VUI:GetTextureCached("Interface\\AddOns\\VUI\\media\\textures\\common\\border-simple.tga")

-- Apply the atlas texture to the button
VUI.Atlas:ApplyTextureCoordinates(button, atlasInfo)
```

2. For theme-specific textures, use the theme key:
```lua
local themeName = VUI.db.profile.appearance.theme
local borderTexture = "Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. themeName .. "\\border.tga"
local atlasInfo = VUI:GetTextureCached(borderTexture)
VUI.Atlas:ApplyTextureCoordinates(frame, atlasInfo)
```

## Atlas Coordinates

Each atlas contains multiple textures positioned at specific coordinates within the atlas image. These coordinates are defined in `atlas.lua`.

Example coordinate map for common.tga:
{coordinateMap}

## Updating Atlas Textures

When updating or adding textures to an atlas:

1. Edit the atlas image file in an image editor
2. Update the coordinates in `atlas.lua`
3. Run the AtlasGenerator (this file) to verify coordinates
4. Update the Atlas documentation if needed

## Performance Benefits

Using texture atlases provides the following benefits:
- Reduces the number of texture file loads
- Decreases memory usage
- Improves loading times
- Reduces texture switching during rendering
]]

    -- Add coordinate map example
    local coordMap = ""
    for texName, coords in pairs(self.atlasDefinitions.common.textures) do
        local left = coords.position.x / self.atlasDefinitions.common.size.width
        local right = (coords.position.x + coords.size.width) / self.atlasDefinitions.common.size.width
        local top = coords.position.y / self.atlasDefinitions.common.size.height
        local bottom = (coords.position.y + coords.size.height) / self.atlasDefinitions.common.size.height
        
        coordMap = coordMap .. string.format("- %s: left = %.2f, right = %.2f, top = %.2f, bottom = %.2f\n", 
            texName, left, right, top, bottom)
    end
    
    content = content:gsub("{coordinateMap}", coordMap)
    
    -- In a full implementation, this would write to a file
    print("Would write documentation to: " .. docFile)
    print("Documentation would include:")
    print(content:sub(1, 200) .. "...")
end

-- Run the atlas generator
function AtlasGenerator:Run()
    self:Initialize()
    self:GenerateAtlases()
    self:CreateDocumentation()
    print("Atlas Generator completed")
end

-- Add command to run the atlas generator (for development only)
SLASH_ATLASGEN1 = "/atlasgen"
SlashCmdList["ATLASGEN"] = function()
    VUI.AtlasGenerator:Run()
end