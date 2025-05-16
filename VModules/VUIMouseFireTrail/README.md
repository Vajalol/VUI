# VUI Mouse Fire Trail

## Overview
VUIMouseFireTrail provides customizable visual effects that follow your mouse cursor as you move it around the screen. This module is based on the EasyCursorTrails addon, reimplemented for the VUI framework with enhanced features and improved reliability.

## Features

### Visual Effect Types
- **Particle** - Individual particles follow your cursor
- **Texture** - Custom textures follow your mouse movements
- **Glow** - A glowing effect around your cursor
- **Shape** - Predefined shapes that follow cursor movement

### Trail Shapes (for Shape mode)
- **V_Shape** - Classic V-shaped trail
- **Arrow** - Arrow-shaped trail
- **U_Shape** - U-shaped pattern
- **Ellipse** - Elliptical pattern
- **Spiral** - Spiral pattern

### Color Options
- **Fire** - Orange/red fire-like colors
- **Arcane** - Purple/pink arcane-themed colors
- **Frost** - Blue/cyan frost-themed colors
- **Nature** - Green nature-themed colors
- **Rainbow** - Continuously shifting rainbow colors
- **Theme** - Uses the current VUI theme color
- **Custom** - Set your own custom color

### Texture Categories
- **Basic** - Simple basic textures
- **Flame** - Fire and flame textures
- **Bubble** - Bubble and liquid effect textures
- **Circle** - Circular and ring textures
- **Fantasy** - Fantasy-themed textures (fairy dust, sparkles)
- **Heart** - Heart-shaped textures
- **Magic** - Magical effect textures
- **Military** - Combat-themed textures
- **Nature** - Nature-themed textures (leaves, raindrops)
- **Shapes** - Geometric shape textures
- **Star** - Star and glitter textures

### Special Effects
- **Connect Segments** - Draw lines connecting the trail segments
- **Enable Glow** - Add a glow effect to the trail
- **Pulsing Glow** - Make the glow pulse in size and intensity

### Display Conditions
- **Show During Combat** - Enable/disable during combat
- **Show In Instances** - Enable/disable in dungeons and raids
- **Show In World** - Enable/disable in the open world
- **Require Mouse Button** - Only show when a mouse button is held
- **Require Modifier Key** - Only show when a modifier key is held (Shift, Ctrl, Alt)

## Configuration

### Basic Settings
1. Open the VUI configuration panel (`/vui`)
2. Navigate to VUI Modules > VUI Mouse Effects
3. Toggle "Enable Fire Trail" to turn the effect on/off
4. Adjust the settings to your preference

### Quick Commands
- `/vuitrail toggle` - Quickly toggle the trail effect on/off
- `/vuitrail` - Open the configuration panel

## Customization Tips

### For a subtle effect:
- Use Particle mode
- Set Trail Size to 10-15
- Set Trail Alpha to 0.3-0.5
- Choose Theme color

### For a flashy effect:
- Use Texture mode
- Set Trail Size to 30-40
- Enable Glow
- Choose Rainbow color
- Set Trail Count to 30+

### For a professional gaming look:
- Use Shape mode with V_Shape
- Set Trail Size to 15-20
- Choose a solid color like Frost
- Set Trail Count to 15-20
- Disable in instances to avoid distractions during raids

## Troubleshooting
- If the trail isn't visible, make sure the module is enabled
- Check that display conditions aren't filtering it out
- If performance is impacted, reduce Trail Count and Trail Size
- If textures appear broken, try a different Texture Category

## Compatibility
This module is fully compatible with all WoW versions including The War Within expansion.