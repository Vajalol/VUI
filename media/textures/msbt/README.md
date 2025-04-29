# MSBT Module Media Files

This directory contains textures and media files for the MikScrollingBattleText (MSBT) module in the VUI addon suite.

## Required Files
- `animpath.svg` - Standard animation path texture
- `/font/` directory - Contains font files used for battle text display
- `/sounds/` directory - Contains notification sounds for important events
- Theme-specific textures in each theme directory:
  - `phoenixflame/msbt/animpath.svg` - Phoenix Flame themed animation path
  - `thunderstorm/msbt/animpath.svg` - Thunder Storm themed animation path
  - `arcanemystic/msbt/animpath.svg` - Arcane Mystic themed animation path
  - `felenergy/msbt/animpath.svg` - Fel Energy themed animation path

## SVG to TGA Conversion
For WoW client compatibility, these SVG files need to be converted to TGA format:
- `animpath.tga`
- Each theme's specific animation path textures

## File Descriptions
- **animpath.svg**: Vector paths that define how scrolling combat text moves across the screen. Different paths can be selected in the MSBT configuration.

- **Theme-specific animation paths**: Each theme has custom animation paths that match its visual style:
  - Phoenix Flame: Orange/red paths with flame-like movements
  - Thunder Storm: Electric blue paths with lightning zigzag patterns 
  - Arcane Mystic: Purple paths with arcane rune markers and spiral patterns
  - Fel Energy: Fel green paths with corrupted, chaotic patterns

## Font Files
The following fonts should be included in the `/font/` directory:
- `frizqt__.ttf` - The standard WoW font
- `skurri.ttf` - Alternative fantasy font
- `morpheus.ttf` - Serif-style fantasy font

## Sound Files
The following sound files should be included in the `/sounds/` directory:
- `crit.ogg` - Critical hit notification
- `proc.ogg` - Ability proc notification
- `lowhealth.ogg` - Low health warning