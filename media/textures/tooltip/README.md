# Tooltip Media Files

This directory contains textures and media files for the tooltip module in the VUI addon suite.

## Required Files
- `border.svg` - Standard tooltip border texture
- `background.svg` - Standard tooltip background texture
- `quality_highlight.svg` - Item quality highlight bar texture
- Theme-specific textures in each theme directory:
  - `phoenixflame/tooltip/border.svg` - Phoenix Flame themed tooltip border
  - `phoenixflame/tooltip/background.svg` - Phoenix Flame themed background
  - `thunderstorm/tooltip/border.svg` - Thunder Storm themed tooltip border
  - `thunderstorm/tooltip/background.svg` - Thunder Storm themed background
  - `arcanemystic/tooltip/border.svg` - Arcane Mystic themed tooltip border
  - `arcanemystic/tooltip/background.svg` - Arcane Mystic themed background
  - `felenergy/tooltip/border.svg` - Fel Energy themed tooltip border
  - `felenergy/tooltip/background.svg` - Fel Energy themed background

## SVG to TGA Conversion
For WoW client compatibility, these SVG files need to be converted to TGA format:
- `border.tga`
- `background.tga`
- `quality_highlight.tga`
- Each theme's specific tooltip textures

## File Descriptions
- **border.svg**: The border texture for all tooltips in the WoW interface, used for items, spells, abilities, etc.

- **background.svg**: The background texture for all tooltips, providing a dark backdrop for tooltip content.

- **quality_highlight.svg**: A highlight texture used to indicate item quality in tooltips. This will be colored by the addon code based on the item's quality level.

- **Theme-specific textures**: Each theme has custom tooltip textures that match its visual style:
  - Phoenix Flame: Fiery orange/red tooltip with flame corner embellishments
  - Thunder Storm: Electric blue tooltip with lightning bolt corner details
  - Arcane Mystic: Violet/purple tooltip with arcane rune patterns
  - Fel Energy: Bright green tooltip with fel corruption tendrils