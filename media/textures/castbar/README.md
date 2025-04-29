# Cast Bar Media Files

This directory contains textures and media files for the cast bar module in the VUI addon suite.

## Required Files
- `bar.svg` - Standard cast bar texture
- `background.svg` - Standard cast bar background texture
- `success.svg` - Animation texture for successful cast completion
- `fail.svg` - Animation texture for interrupted/failed cast
- Theme-specific textures in each theme directory:
  - `phoenixflame/castbar/bar.svg` - Phoenix Flame themed cast bar
  - `phoenixflame/castbar/background.svg` - Phoenix Flame themed background
  - `thunderstorm/castbar/bar.svg` - Thunder Storm themed cast bar
  - `thunderstorm/castbar/background.svg` - Thunder Storm themed background
  - `arcanemystic/castbar/bar.svg` - Arcane Mystic themed cast bar
  - `arcanemystic/castbar/background.svg` - Arcane Mystic themed background
  - `felenergy/castbar/bar.svg` - Fel Energy themed cast bar
  - `felenergy/castbar/background.svg` - Fel Energy themed background

## SVG to TGA Conversion
For WoW client compatibility, these SVG files need to be converted to TGA format:
- `bar.tga`
- `background.tga`
- `success.tga`
- `fail.tga`
- Each theme's specific `bar.tga` and `background.tga` files

## File Descriptions
- **bar.svg**: The main progress bar that fills as a spell is cast. Used for player, target, and focus cast bars.

- **background.svg**: The background frame that holds the cast bar progress element.

- **success.svg**: Flash effect that appears when a cast is successfully completed. Provides visual feedback to the player.

- **fail.svg**: Flash effect that appears when a cast is interrupted or fails. Provides clear visual feedback.

- **Theme-specific textures**: Each theme has custom cast bar textures that match its visual style:
  - Phoenix Flame: Fiery orange/red cast bar with flame effects
  - Thunder Storm: Electric blue cast bar with lightning bolt motifs
  - Arcane Mystic: Violet/purple cast bar with arcane rune patterns
  - Fel Energy: Bright green cast bar with fel corruption tendril effects