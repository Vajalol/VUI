# ActionBars Module Media Files

This directory contains textures and media files for the ActionBars module in the VUI addon suite.

## Required Files
- `button.svg` - Standard action button texture
- `macro_icon.svg` - Macro icon overlay texture
- `cooldown.svg` - Cooldown overlay for action buttons
- Theme-specific textures in each theme directory:
  - `phoenixflame/actionbars/button.svg` - Phoenix Flame themed button
  - `thunderstorm/actionbars/button.svg` - Thunder Storm themed button
  - `arcanemystic/actionbars/button.svg` - Arcane Mystic themed button
  - `felenergy/actionbars/button.svg` - Fel Energy themed button

## SVG to TGA Conversion
For WoW client compatibility, these SVG files need to be converted to TGA format:
- `button.tga`
- `macro_icon.tga`
- `cooldown.tga`
- Each theme's specific actionbar textures

## File Descriptions
- **button.svg**: The standard button texture used for all actionbar buttons, stance buttons, pet buttons, etc. This serves as the background for all abilities and items placed on actionbars.

- **macro_icon.svg**: A small overlay texture used to indicate that a button contains a macro rather than a standard ability.

- **cooldown.svg**: A special overlay texture that displays when an ability is on cooldown. The game engine will handle the actual cooldown "sweep" animation.

- **Theme-specific textures**: Each theme has custom button textures that match its visual style:
  - Phoenix Flame: Fiery orange/red buttons with flame corner embellishments
  - Thunder Storm: Electric blue buttons with lightning bolt corner details
  - Arcane Mystic: Violet/purple buttons with arcane rune patterns
  - Fel Energy: Bright green buttons with fel corruption tendrils