# VUI Addon Font Files

This directory contains font files used by various modules in the VUI addon suite. These fonts are sourced from official Blizzard UI files and open-source alternatives to ensure compatibility with the World of Warcraft client.

## Required Font Files

### Standard WoW Fonts
- `frizqt__.ttf` - The standard World of Warcraft font (Friz Quadrata)
- `skurri.ttf` - Alternative fantasy font used in various UI elements
- `morpheus.ttf` - Serif-style fantasy font used for certain UI elements
- `arialn.ttf` - Clean sans-serif font used for data text and numbers

### Themed Fonts
Themed fonts are optional variations that can be used with specific VUI themes:
- `phoenixflame/phoenix.ttf` - Special font optimized for the Phoenix Flame theme
- `thunderstorm/thunder.ttf` - Special font optimized for the Thunder Storm theme
- `arcanemystic/arcane.ttf` - Special font optimized for the Arcane Mystic theme
- `felenergy/fel.ttf` - Special font optimized for the Fel Energy theme

## Usage Guidelines
1. WoW requires specific font files to work correctly with language support
2. The frizqt__.ttf font is the most commonly used throughout the UI
3. All font files should be placed directly in this directory without subdirectories
4. Themed fonts should be placed in their respective theme directories

## Important Notes
- Font files must be compatible with the WoW client
- Standard WoW fonts are included in the game client; VUI references them
- Custom theme fonts are only used when a specific theme is active
- Font files are loaded during addon initialization and referenced by modules as needed