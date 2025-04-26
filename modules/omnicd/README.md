# OmniCD Module

## Overview

The OmniCD module provides cooldown tracking functionality for the VUI addon suite. It monitors and displays cooldowns from group members with intuitive, customizable displays and theme-integrated animations.

## Features

- Track important cooldowns for all group members
- Customizable display options (size, direction, spacing)
- Class-colored borders for easy identification
- Remaining time displays
- Priority-based cooldown sorting
- Automatic zone-type detection (arena, raid, dungeon)
- Four theme-specific animation styles

## Files

- `init.lua`: Module initialization and core setup
- `core.lua`: Main cooldown tracking functionality
- `config.lua`: Configuration panel and options
- `animations.lua`: Theme-integrated animation system

## Animation System

The OmniCD module features an advanced animation system that integrates with VUI's theme framework. Each theme (Phoenix Flame, Thunder Storm, Arcane Mystic, and Fel Energy) provides unique visual effects for cooldown tracking.

See `docs/omnicd_theme_integration.md` for detailed information about the animation system.

## Configuration

Users can configure OmniCD through the VUI configuration panel:

1. **General options**:
   - Enable/disable module
   - Show player names
   - Show tooltips

2. **Display options**:
   - Icon size
   - Icon spacing
   - Growth direction
   - Maximum icon count

3. **Animation options**:
   - Enable/disable animations
   - Disable animations in combat for performance
   - Preview theme animations

4. **Spell options**:
   - Filter which spells to track by class
   - Set spell priorities

5. **Zone options**:
   - Configure where OmniCD is active (arena, raid, battleground, etc.)

## Performance

The module includes several performance optimizations:

- Efficient cooldown tracking with update throttling
- Option to disable animations during combat
- Smart filtering to only track relevant cooldowns
- Memory usage optimizations

## Development Notes

### Adding New Spells

To add new spells to track:
1. Add the spell ID to the `CLASS_SPELL_LIST` table in `core.lua`
2. Set a priority in the `SPELL_PRIORITY` table

### Adding New Theme Animations

To add animations for a new theme:
1. Create new SVG assets in `media/textures/{themename}/omnicd/`
2. Add a new theme function in `animations.lua` following the pattern of existing themes
3. Update the `ApplyThemeAnimations` function to call your new theme function