# TrufiGCD Spell Categorization System

## Overview

The TrufiGCD Spell Categorization system enhances the core functionality of TrufiGCD by providing visual distinctions for different types of abilities in the spell cast history. This allows players to quickly identify important cooldowns, defensive abilities, and other spell types within their recent cast history.

## Features

- **Category-Based Visual Styling**: Different spell types (offensive, defensive, healing, etc.) have unique visual styles
- **Theme Integration**: Visual styling adapts to the active VUI theme
- **Importance Levels**: Within each category, spells can be classified by importance (high, medium, low)
- **Pre-defined Class Spell Database**: Over 300 important class abilities are pre-categorized
- **Customizable Categories**: Each category can be enabled/disabled independently
- **Visual Indicators**: Combination of border colors, icon sizes, and glow effects

## Categories

The system organizes spells into the following categories:

| Category | Description | Visual Style |
|----------|-------------|--------------|
| Offensive | Damage-dealing abilities | Red borders, slight size increase |
| Defensive | Damage reduction & survival abilities | Green borders, medium size increase |
| Healing | Healing spells and HoTs | Bright green borders, slight size increase |
| Utility | Movement, crowd control, and utility | Blue borders, standard size |
| Interrupts | Spell interruption abilities | Orange borders, medium size increase |
| Dispels | Dispel and purge abilities | Purple borders, slight size increase |
| Major Cooldowns | Important class and role cooldowns | Gold borders, large size increase |
| Standard | Regular rotational abilities | Gray borders, standard size |

## Importance Levels

Within each category, spells are further classified by importance:

- **High**: Critical abilities with the strongest visual distinction
- **Medium**: Standard importance with normal visual emphasis
- **Low**: Minor abilities with subtle visual distinction

## Usage

The spell categorization system is enabled by default and requires no additional configuration. The system will automatically apply appropriate styling to all abilities as they appear in your cast history.

### Configuration Options

Access these options through the TrufiGCD configuration panel:

1. **Enable/Disable Categories**: Toggle the entire categorization system
2. **Individual Categories**: Enable or disable specific categories
3. **Visual Style Options**: Adjust border colors, glow effects, and size variations

## Integration with Other VUI Systems

- **Theme System**: Category colors adapt to each theme (Phoenix Flame, Thunder Storm, etc.)
- **Icon Customization**: Works with the existing icon customization system
- **Advanced Filtering**: Compatible with advanced spell filtering options

## Performance Considerations

The spell categorization system has been optimized for minimal performance impact:

- Efficient category lookups with pre-compiled spell tables
- Smart visual effect application that prioritizes important spells
- Frame recycling to minimize memory usage

## Future Enhancements

Future versions may include:

- User-defined custom categories
- Import/export of category settings
- Context-sensitive categorization based on combat situation
- Integration with the timeline view feature