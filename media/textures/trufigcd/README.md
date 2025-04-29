# TrufiGCD Media Files

This directory contains textures and media files for the TrufiGCD module in the VUI addon suite.

## Required Files
- `border.svg` - Standard border for ability icons
- `flash.svg` - Animation flash effect for when abilities are used
- Theme-specific borders in each theme directory:
  - `phoenixflame/trufigcd_border.svg`
  - `thunderstorm/trufigcd_border.svg`
  - `arcanemystic/trufigcd_border.svg`
  - `felenergy/trufigcd_border.svg`

## SVG to TGA Conversion
For WoW client compatibility, these SVG files need to be converted to TGA format:
- `border.tga`
- `flash.tga`
- Each theme's `trufigcd_border.tga` file

## File Descriptions
- **border.svg**: Standard border that frames ability icons in the TrufiGCD tracking display. Uses a neutral gray/white gradient that works well with the default UI.

- **flash.svg**: Radial white glow used for the animation effect when a new ability is used. This creates a brief flash highlighting the most recently used ability.

- **Theme-specific borders**: Each theme has a custom border that matches its visual style:
  - Phoenix Flame: Fiery orange/red border with flame corner accents
  - Thunder Storm: Electric blue border with lightning bolt corner accents
  - Arcane Mystic: Violet/purple border with arcane rune corner accents
  - Fel Energy: Bright green border with fel corruption tendrils