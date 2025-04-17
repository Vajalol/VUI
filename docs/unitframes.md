# VUI UnitFrames Module

## Overview

The UnitFrames module replaces the default World of Warcraft unit frames with highly customizable frames that integrate with the VUI styling system. It provides enhanced functionality and a consistent look across all unit frames while allowing extensive customization.

## Key Features

- **Complete Unit Frame Replacement**: Replaces player, target, focus, pet, party, boss, and arena frames
- **Customizable Layout**: Adjust the size, scale, and position of each frame type
- **Style Integration**: Frames automatically adapt to your chosen VUI theme
- **Class Colors**: Option to use class colors for health bars and borders
- **Unit Portraits**: Display unit portraits with optional class icons
- **Status Indicators**: Combat, resting, leader, and PvP status indicators
- **Role Indicators**: Display role icons in party frames
- **Custom Coloring**: Customize colors for health, power, and reactions
- **Movable Frames**: Easily position frames through the configuration UI
- **Frame Visibility**: Control which frames are displayed

## Usage

### Basic Controls

- `/vuiuf` - Shows available commands
- `/vuiuf toggle` - Toggles UnitFrames on/off
- `/vuiuf reset` - Resets all frame positions to default
- `/vuiuf unlock` - Unlocks frames for repositioning
- `/vuiuf lock` - Locks frames after positioning

### Configuration Options

The UnitFrames module provides extensive configuration through the VUI configuration panel:

#### General Settings

- **Frame Style**: Choose between Modern, Classic, and Minimal styles
- **Global Scale**: Adjust the overall size of all frames
- **Class Colored Bars**: Use class colors for health bars
- **Class Colored Borders**: Use class colors for frame borders
- **Show Portraits**: Toggle display of unit portraits
- **Use Class Icons**: Use class icons instead of character portraits

#### Frame-Specific Settings

Each frame type (Player, Target, Focus, Party, etc.) has its own configuration tab with settings for:

- **Enable/Disable**: Toggle individual frame types
- **Size**: Adjust width and height
- **Scale**: Set frame-specific scaling
- **Display Options**: Configure what information is shown
- **Layout**: Change arrangement (vertical/horizontal for party frames)

#### Appearance Settings

- **Health Colors**: Customize colors for different unit states
- **Power Colors**: Set colors for different power types
- **Reaction Colors**: Configure colors for hostile, neutral, and friendly units

## Frame Types

### Player Frame

The player frame displays:
- Health bar with optional percentage
- Power bar with optional percentage
- Player name
- Level
- Combat indicator (optional)
- Resting indicator (optional)
- Portrait (optional)

### Target Frame

The target frame displays:
- Health bar with optional percentage
- Power bar with optional percentage
- Target name
- Target level and classification
- Reaction coloring
- Portrait (optional)

### Focus Frame

A smaller frame showing your focus target with:
- Health bar with optional percentage
- Power bar
- Focus name
- Portrait (optional)

### Party Frames

Displays frames for all party members with:
- Health and power bars
- Name and level
- Role icons (optional)
- Group numbers (optional)
- Vertical or horizontal layout options

### Boss and Arena Frames

Specialized frames for boss encounters and arena matches with:
- Health and power bars
- Name information
- Classification indicators
- Spec and trinket indicators (arena frames)

## Integration with VUI

The UnitFrames module integrates with other VUI systems:

- **Theme System**: Automatically adapts to your chosen VUI theme
- **Media System**: Uses VUI fonts and textures
- **Configuration System**: Seamlessly integrates with the main VUI options panel

## Customization Tips

1. **Unlock frames** to reposition them to your preferred layout
2. **Experiment with styles** to find your preferred appearance
3. **Adjust the health and power display** settings to show the information you need
4. **Customize colors** to improve visibility for different unit types
5. **Enable class coloring** to make player classes more identifiable
6. **Use the scale settings** to fine-tune the size of individual frames

## Known Issues

- Some third-party addons that modify unit frames may conflict with VUI UnitFrames
- For best compatibility, disable other unit frame addons when using VUI UnitFrames

## Compatibility

The UnitFrames module is compatible with most other VUI modules and has been designed to work alongside other UI components.