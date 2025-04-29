# MikScrollingBattleText Module for VUI

## Overview
This module integrates MikScrollingBattleText (MSBT) functionality into the VUI addon suite, providing theme-integrated scrolling combat text with customizable animations, colors, and sound effects.

## Features
- **Theme Integration**: Fully supports all VUI themes (Phoenix Flame, Thunder Storm, Arcane Mystic, Fel Energy)
- **Theme-Specific Sound Effects**: Each theme has unique sound effects for combat events
- **Theme-Specific Animation Paths**: Custom text movement patterns that match each theme's visual style
- **Color Integration**: Text and background colors match the current VUI theme
- **Enhanced Configuration**: Accessible through the VUI control panel

## File Structure
- `init.lua`: Main module entry point and initialization
- `core.lua`: Core functionality and utility functions
- `ThemeIntegration.lua`: Theme support for colors, animations, and sounds
- `MSBTMedia.lua`: Media registration for sounds and fonts
- Various MSBT original files adapted for VUI

## Sound Categories
The module includes the following sound events:
- Low Health
- Low Mana
- Cooldown
- Critical Hit
- Ability Proc
- Dodge
- Parry
- Block
- Healing

## Theme-Specific Files
Each theme has its own set of media files:
- Sound effects in `media/sounds/<theme>/msbt/`
- Animation paths in `media/textures/<theme>/msbt/`

## Configuration Options
- Enable/disable module
- Toggle VUI theme integration
- Toggle theme-colored text
- Enhanced fonts option
- Sound effects toggle
- Test functionality for previewing animations

## Credits
- Original MSBT by Mikord
- VUI integration by VortexQ8