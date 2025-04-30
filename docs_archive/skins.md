# VUI Skins Module

## Overview

The VUI Skins module provides a comprehensive and customizable framework for reskinning the World of Warcraft UI with a consistent and modern appearance. The framework handles both the Blizzard UI elements and supported third-party addons.

## Key Features

- **Consistent UI Styling**: Apply a unified visual style to all UI elements
- **Configurable Appearance**: Choose from various style options, colors, and design elements
- **Blizzard UI Skinning**: Reskin all Blizzard UI frames, dialogs, and components
- **Addon Integration**: Apply skins to supported third-party addons
- **Advanced UI Options**: Custom fonts, pixel-perfect mode, and enhanced visual effects
- **Performance Optimized**: Designed to have minimal performance impact
- **ButtonStyles**: Multiple button styling options (gradient, flat, shadow)
- **Interactive Highlights**: Enhanced visual feedback for interactive elements

## Usage

### Basic Controls

- `/vuiskin` - Shows available commands
- `/vuiskin apply` - Apply all skin settings
- `/vuiskin blizzard` - Toggle Blizzard UI skinning
- `/vuiskin addons` - Toggle addon skinning
- `/vuiskin reset` - Reset skin settings to default

### Configuration Options

The Skins module provides extensive configuration through the VUI configuration panel:

#### General Settings

- **Enable/Disable**: Toggle the entire skinning system
- **Blizzard UI Skinning**: Toggle skinning of Blizzard UI elements
- **Addon Skinning**: Toggle skinning of supported addons

#### Style Settings

- **Shadow Size**: Configure the size of shadows around frames
- **Shadow Alpha**: Adjust the transparency of shadows
- **Border Size**: Set the thickness of borders
- **Border Color**: Customize the color of frame borders
- **Backdrop Color**: Set the background color for frames
- **Interactive Highlights**: Toggle highlighting of interactive elements
- **Interactive Borders**: Toggle border color changes on interactive elements
- **Button Style**: Choose between Gradient, Flat, and Shadow styles

#### Advanced UI

- **Custom Fonts**: Apply custom fonts to UI elements
- **Font Selection**: Choose from available fonts
- **Font Size**: Adjust the text size
- **Font Style**: Configure font appearance (normal, outline, etc.)
- **Pixel Perfect Mode**: Enable precise pixel alignment for UI elements

## Skinned Elements

### Blizzard UI Elements

The skinning system can apply skins to the following Blizzard UI elements:

- Action Bars
- Bags and Bank
- Character Panel
- Chat Frame
- Collections UI
- Communities Panel
- Dressing Room
- Friends List
- Gossip Dialog
- Guild UI
- Help Menu
- LFG Tool
- Loot Window
- Mail UI
- Merchant Window
- Options Panel
- PvP UI
- Quest Log
- Spellbook
- Talent UI
- Taxi Map
- Time Manager
- Tooltips
- World Map
- Achievement UI
- Encounter Journal
- Calendar
- Macro UI
- Key Binding UI

### Supported Addons

The skinning system can also apply consistent skins to the following addons:

- Auctionator
- OmniCC
- Angry Keystones
- OmniCD
- BuffOverlay
- MoveAny
- idTip
- TrufiGCD
- Details
- Deadly Boss Mods (DBM)
- WeakAuras
- Plater

## Skinning Elements Programmatically

Addon developers can integrate with the VUI skinning system to ensure their UI elements match the overall styling:

```lua
-- Skin a frame
VUI.skins:SkinFrame(myFrame)

-- Skin a button with custom options
VUI.skins:SkinButton(myButton, {noHighlight = true})

-- Skin a check button
VUI.skins:SkinCheckButton(myCheckButton)

-- Skin a scrollbar
VUI.skins:SkinScrollBar(myScrollBar)

-- Skin a dropdown menu
VUI.skins:SkinDropDownMenu(myDropDown)

-- Skin a tab
VUI.skins:SkinTab(myTab)

-- Skin a slider
VUI.skins:SkinSlider(mySlider)

-- Skin an edit box
VUI.skins:SkinEditBox(myEditBox)

-- Add a shadow to a frame
VUI.skins:AddShadow(myFrame)

-- Apply font styling to a font string
VUI.skins:SkinFontString(myFontString)
```

## Integration with VUI

The Skins module integrates with other VUI systems:

- **Media System**: Uses VUI fonts and textures
- **Configuration System**: Seamlessly integrates with the main VUI options panel
- **Module API**: Built on the VUI Module API for consistent functionality

## Advanced Customization

### Creating Custom Skins

Addon developers can register custom skin functions for their addons:

```lua
-- Register a custom skin function
VUI.skins:RegisterAddonSkin("MyAddon", function(self)
    -- Skinning code here
    self:SkinFrame(MyAddonFrame)
    
    -- Skin child elements
    for _, child in ipairs({MyAddonFrame:GetChildren()}) do
        if child:IsObjectType("Button") then
            self:SkinButton(child)
        end
    end
end)
```

### Style Customization

Users can customize the appearance through the configuration panel or manually:

```lua
-- Example: Change border color
VUI.skins.settings.style.borderColor = {r = 0.5, g = 0.2, b = 0.8, a = 1.0}
VUI.skins:ApplySkins()
```

## Technical Details

The skinning system works by:

1. Replacing standard frame textures with custom textures
2. Applying consistent backdrop settings
3. Adding shadows and borders
4. Standardizing fonts and font sizes
5. Creating interactive effects for mouseover and click states
6. Hooking into frame creation functions for dynamic skinning

## Performance Considerations

- The skinning system is designed to have minimal performance impact
- Users can disable specific elements to optimize performance
- Pixel-perfect mode may have slight performance implications on lower-end systems

## Known Issues

- Some third-party addons may have elements that cannot be fully skinned
- Addons that use custom rendering may not fully integrate with the skinning system
- Certain Blizzard UI elements might revert to default appearance after specific events