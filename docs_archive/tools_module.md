# VUI Tools Module

The Tools module provides various quality-of-life enhancements for World of Warcraft, including graphical elements for Position of Power and Mouse Trail effects.

## Features

### Position of Power
Highlights abilities and spells that have temporary power increases (procs) with customizable themed borders.

- **Border Textures**: Located in `media/textures/[theme]/tools/positionofpower/border.svg`
- **Theme Variations**: All four VUI themes have unique styled borders with themed effects:
  - Phoenix Flame: Fiery orange borders with ember effects
  - Thunder Storm: Electric blue borders with lightning accents
  - Arcane Mystic: Violet borders with rune symbols
  - Fel Energy: Fel green borders with corruption tendrils

### Mouse Trail
Adds themed particle effects that follow the mouse cursor movement.

- **Trail Textures**: Located in `media/textures/[theme]/tools/mousetrail/trail.svg`
- **Standard Version**: Basic white particle available in `media/textures/tools/mousetrail/standard.svg`
- **Theme Variations**: Each theme has unique visual effects:
  - Phoenix Flame: Fiery ember particles with flame flicker
  - Thunder Storm: Electric static particles with lightning bolts
  - Arcane Mystic: Arcane energy with rune symbols
  - Fel Energy: Fel corruption with energy tendrils

## Implementation Notes

- All textures use SVG format for better scaling across different resolutions
- Each theme maintains consistent color schemes and visual language across all modules
- Animation effects are handled in Lua code using these static textures as the base

## Configuration Options

The Tools module is fully configurable through the VUI control panel:

- Enable/disable individual tool features
- Adjust opacity and scale of visual elements
- Change themes on a per-tool basis
- Set the fade duration and intensity of effects