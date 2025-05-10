# VUIMouseFireTrail

VUIMouseFireTrail is an enhanced cursor trail effect module for VUI (Vortex UI), inspired by EasyCursorTrails. It provides visually appealing cursor trails with numerous customization options.

## Features

- Multiple trail types (particles, textures, shapes, glow)
- Various trail shapes (flames, V-shape, arrows, U-shape, ellipse, spiral)
- Extensive color options including VUI theme integration
- Context-aware display (customizable for combat, instances, rest areas)
- Rich configuration options through VUI settings panel
- Glow and particle effects with adjustable properties
- Line connections between trail segments

## Usage

1. Enable the module in the VUI configuration panel
2. Customize appearance through the detailed settings
3. Use the `/vuitrail` command to toggle or configure the trail

## Theme Integration

VUIMouseFireTrail integrates with VUI's theme system, allowing trails to automatically match your selected UI theme. When the "Use VUI Theme Color" option is enabled, the trail will update its colors whenever the VUI theme changes.

## Configuration Options

### General Settings
- Trail Type: Choose between particles, textures, shapes, or glow
- Trail Count: Number of segments in the trail
- Trail Size: Size of each trail element
- Trail Opacity: Transparency of the trail
- Trail Smoothness: Adjusts how frequently the trail updates

### Appearance
- Color Mode: Choose from fire, arcane, frost, nature, rainbow, theme, or custom
- Custom Color: Set your own color when "Custom" is selected
- Shape Type: For shape trails, select V-shape, arrow, U-shape, etc.
- Texture: For texture trails, select the image to use

### Special Effects
- Connect Trail Segments: Draw lines between trail segments
- Enable Glow Effect: Add a glow around the cursor
- Glow Intensity: Brightness of the glow
- Pulsing Glow: Make the glow pulse in and out

### Display Conditions
- Show in Combat: Enable/disable during combat
- Show in Dungeons/Raids: Enable/disable in instances
- Show in Rest Areas: Enable/disable in cities and inns
- Show in Open World: Enable/disable in the open world
- Require Mouse Button: Only show when a mouse button is held
- Require Key Modifier: Only show when a modifier key is held