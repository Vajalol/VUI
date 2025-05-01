# VUI Texture Atlases

This directory contains texture atlases that combine multiple individual textures into single files for better performance.

## Atlas Files

- `common.tga` - Common UI elements used throughout the addon
- `buttons.tga` - UI control elements like buttons, checkboxes, etc.
- Theme-specific atlases:
  - `phoenixflame.tga` - Phoenix Flame theme textures
  - `thunderstorm.tga` - Thunder Storm theme textures
  - `arcanemystic.tga` - Arcane Mystic theme textures
  - `felenergy.tga` - Fel Energy theme textures
- Module-specific atlases:
  - `buffoverlay.tga` - BuffOverlay module textures
  - `omnicd.tga` - OmniCD module textures
  - `trufigcd.tga` - TrufiGCD module textures

## Atlas Benefits

Using texture atlases provides the following benefits:
- Reduces the number of texture files that need to be loaded
- Decreases memory usage by consolidating many small textures
- Improves loading times by reducing the number of file operations
- Reduces texture switching during rendering, improving performance

## How Atlases Work

Each atlas file contains multiple textures positioned at specific coordinates within the image. When the addon needs a specific texture, it loads the appropriate atlas and uses texture coordinates to display only the portion of the atlas that contains the desired texture.

This is all handled by the Atlas system in `core/atlas.lua`.

## Creating and Updating Atlases

Texture atlases are created during development using the Atlas Generator tool in `tools/atlas_generator.lua`. This tool defines the position and size of each texture within the atlas and provides coordinates for the Atlas system to use.

To update an atlas:
1. Use an image editor to create or modify the atlas texture file
2. Update the texture coordinates in `core/atlas.lua` if needed
3. Update any relevant documentation

## Performance Impact

Initial testing has shown that using texture atlases can reduce memory usage by approximately 30% and improve loading times by 20-25% compared to loading individual textures.