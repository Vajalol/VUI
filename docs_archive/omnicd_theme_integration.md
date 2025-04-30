# OmniCD Theme Integration Documentation

## Overview

The OmniCD module in VUI has been enhanced with theme-specific animations that integrate with the four main themes:
- Phoenix Flame
- Thunder Storm
- Arcane Mystic
- Fel Energy

Each theme provides unique visual effects and animations for cooldown tracking, creating a cohesive and immersive user experience across the entire UI.

## Animation Features

### General Animations

All OmniCD cooldown icons use the following base animations regardless of theme:

1. **Show Animation**: Scale and fade in when a cooldown icon appears
2. **Hide Animation**: Scale and fade out when a cooldown icon disappears
3. **Pulse Animation**: Gentle pulsing effect for important cooldowns
4. **Ready Animation**: Visual emphasis when a cooldown completes

### Theme-Specific Animations

#### Phoenix Flame Theme

The Phoenix Flame theme features fiery animations with ember effects:

- **During Cooldown**: A rotating flame glow surrounds the icon
- **Cooldown Complete**: Embers rise from the icon with a flame burst effect
- **Colors**: Fiery orange/red color scheme (#FF6600, #FF9933)

#### Thunder Storm Theme

The Thunder Storm theme features electric animations with lightning effects:

- **During Cooldown**: Lightning flashes around the icon that periodically change position
- **Cooldown Complete**: An electric surge radiates outward
- **Colors**: Electric blue color scheme (#0099FF, #66CCFF)

#### Arcane Mystic Theme

The Arcane Mystic theme features mystical arcane energy:

- **During Cooldown**: A rotating arcane rune surrounds the icon
- **Cooldown Complete**: An arcane burst effect emanates from the center
- **Colors**: Violet/purple color scheme (#9933FF, #CC99FF)

#### Fel Energy Theme

The Fel Energy theme features fel corruption effects:

- **During Cooldown**: A pulsing fel glow surrounds the icon
- **Cooldown Complete**: A fel explosion effect with green energy
- **Colors**: Fel green color scheme (#33FF33, #66FF66)

## Performance Considerations

1. Animations can be disabled entirely through the configuration panel
2. Option to automatically disable animations during combat for improved performance
3. All animations are implemented with efficient scaling and alpha transformations

## Technical Implementation

### Animation Architecture

The OmniCD animation system uses a modular approach:

1. **Core Animation Functions**: Common utilities for creating animation groups, translations, scales, rotations, and alpha animations
2. **Theme-Specific Implementations**: Each theme has its own implementation function that applies the appropriate textures and effects
3. **Theme-Switching Support**: Animations update automatically when the user switches themes

### SVG Texture Assets

All animation textures use SVG format for better scaling and quality:

- Located in `media/textures/{themename}/omnicd/` directories
- Each theme has specific textures like flames, lightning, runes, and explosions

### Configuration Integration

The animation system integrates with the VUI configuration panel:

- Enable/disable animations
- Toggle combat performance mode
- Preview animation effects for each theme

## Future Enhancements

Potential future improvements to the animation system:

1. Support for additional custom themes
2. More granular control over individual animation types
3. Specialized animations for different spell types (defensive/offensive cooldowns)
4. Additional performance optimizations