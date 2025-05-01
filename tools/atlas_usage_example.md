# Texture Atlas Usage Guide

This guide provides examples of how to use the texture atlas system for VUI modules.

## 1. Creating an Atlas Generator

Create a script to generate your module's atlas texture (replace 'mymodule' with your module name):

```bash
#!/bin/bash
# Atlas Texture Generator for MyModule
# This script generates the texture atlas for the MyModule module

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "Error: ImageMagick is required for this script to work."
    echo "Please install ImageMagick before running this script."
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p media/textures/atlas/modules

# Define the source texture paths
MODULE_TEXTURE1="media/textures/mymodule/texture1.tga"
MODULE_TEXTURE2="media/textures/mymodule/texture2.tga"
MODULE_TEXTURE3="media/textures/mymodule/texture3.tga"

# Output path
OUTPUT="media/textures/atlas/modules/mymodule.tga"

# Atlas dimensions
WIDTH=512
HEIGHT=512

# Create a blank canvas
convert -size ${WIDTH}x${HEIGHT} xc:transparent "$OUTPUT"

# Combine textures according to atlas coordinates
echo "Combining MyModule textures into atlas..."

# texture1: {left = 0, right = 0.5, top = 0, bottom = 0.5}
convert "$OUTPUT" "$MODULE_TEXTURE1" -geometry 256x256+0+0 -composite "$OUTPUT"

# texture2: {left = 0.5, right = 1.0, top = 0, bottom = 0.5}
convert "$OUTPUT" "$MODULE_TEXTURE2" -geometry 256x256+256+0 -composite "$OUTPUT"

# texture3: {left = 0, right = 0.5, top = 0.5, bottom = 1.0}
convert "$OUTPUT" "$MODULE_TEXTURE3" -geometry 256x256+0+256 -composite "$OUTPUT"

echo "Atlas texture created at $OUTPUT"
```

## 2. Add Texture Coordinates to Atlas Configuration

Update the `core/atlas.lua` file with your module's texture coordinates:

```lua
-- In coordinates.modules section
modules = {
    -- ...existing modules...
    
    mymodule = {
        ["texture1"] = {left = 0, right = 0.5, top = 0, bottom = 0.5},
        ["texture2"] = {left = 0.5, right = 1.0, top = 0, bottom = 0.5},
        ["texture3"] = {left = 0, right = 0.5, top = 0.5, bottom = 1.0}
    }
}
```

## 3. Register the Textures with the Media System

Add your module's textures to the RegisterWithMediaSystem function in `core/atlas.lua`:

```lua
-- Add module-specific textures for MyModule
VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\mymodule\\texture1.tga"] = {
    atlas = "modules.mymodule",
    key = "texture1"
}
VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\mymodule\\texture2.tga"] = {
    atlas = "modules.mymodule",
    key = "texture2"
}
VUI.media.atlasTextures["Interface\\AddOns\\VUI\\media\\textures\\mymodule\\texture3.tga"] = {
    atlas = "modules.mymodule",
    key = "texture3"
}
```

## 4. Add Preloading to Your Module

Add a preloading function to your module initialization:

```lua
-- Preload the atlas textures for better performance
function VUI.MyModule:PreloadAtlasTextures()
    -- Preload the module's texture atlas if available
    if VUI.Atlas and VUI.Atlas.PreloadAtlas then
        VUI.Atlas:PreloadAtlas("modules.mymodule")
        
        -- Log successful preload
        if VUI.debug then
            VUI:Debug("MyModule atlas textures preloaded")
        end
    end
end
```

## 5. Use Atlas Textures in Your Module

When creating a texture in your module:

```lua
-- Create a texture using the atlas system
local myTexture = myFrame:CreateTexture(nil, "ARTWORK")
myTexture:SetAllPoints()

if VUI.GetTextureCached then
    local atlasTexture = VUI:GetTextureCached("Interface\\AddOns\\VUI\\media\\textures\\mymodule\\texture1.tga")
    if atlasTexture and atlasTexture.isAtlas then
        VUI.Atlas:ApplyTextureCoordinates(myTexture, atlasTexture)
    else
        -- Fallback
        myTexture:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\mymodule\\texture1.tga")
    end
else
    -- Fallback
    myTexture:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\mymodule\\texture1.tga")
end
```

## 6. Add Theme Integration

Make sure your textures work with the theme system:

```lua
-- In your module's ThemeIntegration.lua
function MyModule:ApplyTheme()
    local theme = VUI.activeTheme
    
    -- Apply theme colors to atlas-based texture
    if self.myTexture then
        self.myTexture:SetVertexColor(theme.borderColor[1], theme.borderColor[2], theme.borderColor[3], 0.8)
    end
end
```

## 7. Update the Atlas Generator Script

Add your module to the `generate_all_atlases.sh` script:

```bash
echo "4. Generating MyModule atlas..."
if [ -f "tools/generate_mymodule_atlas.sh" ]; then
    bash tools/generate_mymodule_atlas.sh
else
    echo "   Script not found. Skipping."
fi
```

## Best Practices

1. **Consistency**: Keep your atlas organization consistent with other modules
2. **Documentation**: Create a documentation file at `docs/mymodule_atlas_implementation.md`
3. **Fallbacks**: Always provide fallbacks for users with older clients or when the atlas system is unavailable
4. **Performance Metrics**: Add comments about expected performance improvements
5. **Coordinate Planning**: Plan your texture coordinates carefully to maximize atlas space usage

## Example Timeline for Implementation

1. Identify textures to include in the atlas
2. Create the atlas generator script
3. Define texture coordinates in `core/atlas.lua`
4. Register textures with the media system
5. Update module code to use atlas textures with fallbacks
6. Add theme integration
7. Update `generate_all_atlases.sh`
8. Document the implementation
9. Test in-game to ensure textures display correctly
10. Compare memory usage and loading performance before/after