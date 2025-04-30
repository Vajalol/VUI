# VUI Visual Configuration Module

## Overview

The VUI Visual Configuration module enhances the configuration experience with visual tools, intuitive interfaces, and quality-of-life improvements. It transforms the standard settings UI into a more user-friendly and powerful system that makes customizing VUI easier and more efficient.

## Key Features

- **Layout Editor**: Visually position and resize UI elements
- **Presets Manager**: Save, load, and share complete UI configurations
- **Enhanced Color Picker**: Advanced color selection with history and presets
- **Improved Config UI**: Icons, better organization, and search functionality
- **Theme System**: Consistent styling across configuration panels
- **Visual Previews**: See changes before applying them

## Usage

### Basic Commands

- `/vuivisual` - Open the visual configuration panel
- `/vuivisual editor` - Open the visual layout editor
- `/vuivisual presets` - Open the presets manager
- `/vuivisual theme` - Open the theme editor
- `/vuivisual colors` - Open the enhanced color picker
- `/vuivisual reset` - Reset to default settings
- `/vuivisual help` - Show help information

## Components

### Layout Editor

The Layout Editor allows you to visually arrange UI elements by dragging and dropping them into position. This makes it much easier to create a customized interface layout without having to manually adjust coordinates.

#### Features:

- **Visual Representation**: See all UI elements in a single view
- **Drag and Drop**: Position elements by simply dragging them
- **Grid System**: Optional grid with snapping for precise alignment
- **Alignment Guides**: Guidelines appear when elements are aligned
- **Dimension Display**: Shows exact size and position while moving elements
- **Multiple Selection**: Select and move groups of related elements together
- **Undo/Redo**: Track changes and revert if needed

#### Usage:

1. Open the Layout Editor with `/vuivisual editor`
2. Drag elements to position them
3. Right-click for additional options
4. Click "Apply" to save your changes

### Presets Manager

The Presets Manager allows you to save complete UI configurations as presets, which can be loaded later or shared with other players.

#### Features:

- **Save Current Setup**: Create a preset from your current configuration
- **Visual Previews**: See what a preset looks like before loading it
- **Import/Export**: Share presets with other players
- **Categories**: Organize presets by type or purpose
- **Comparison**: Compare presets to see differences
- **Auto-backup**: Automatically backs up your current setup before loading a preset

#### Usage:

1. Open the Presets Manager with `/vuivisual presets`
2. Click "New Preset" to save your current setup
3. Select a preset and click "Load" to apply it
4. Use "Export" to share a preset with others

### Enhanced Color Picker

The Enhanced Color Picker improves upon the standard WoW color picker with additional features that make selecting and managing colors easier.

#### Features:

- **Color History**: Remembers recently used colors
- **Preset Colors**: Common colors available for quick selection
- **Class Colors**: Quick access to WoW class colors
- **Live Preview**: See changes in real-time
- **Color Harmony**: Suggests complementary colors
- **RGB/HSV/Hex Input**: Input exact color values

#### Usage:

1. Open the Color Picker when selecting a color in any configuration panel
2. Use the enhanced features to select your desired color
3. Click "Okay" to apply the color

### Configuration Enhancements

The module improves the standard configuration UI with various enhancements for a better user experience.

#### Features:

- **Module Icons**: Visual identification of different modules
- **Organized Options**: Related options are grouped together
- **Search Functionality**: Find settings quickly
- **Recent Changes**: See recently modified options
- **Status Indicators**: Shows which modules are enabled/disabled
- **Visual Previews**: Preview changes before applying them
- **Window Position Memory**: Configuration windows remember their positions

#### Usage:

These enhancements are automatically applied to the VUI configuration UI when the Visual Configuration module is enabled.

## Advanced Usage

### Creating Custom Presets

You can create and customize presets to save specific configurations:

1. Configure VUI to your liking
2. Open the Presets Manager (`/vuivisual presets`)
3. Click "New Preset"
4. Enter a name and optional description
5. The preset will save all current settings

### Exporting Presets

To share your configuration with other players:

1. Open the Presets Manager
2. Select the preset you want to share
3. Click "Export"
4. Copy the exported string and share it

### Importing Presets

To use a preset shared by another player:

1. Open the Presets Manager
2. Click "Import"
3. Paste the shared string
4. Click "Import" to add it to your presets
5. Select the imported preset and click "Load" to apply it

### Customizing the Layout Editor Grid

You can adjust the Layout Editor grid to suit your needs:

1. Open the Visual Configuration panel (`/vuivisual`)
2. Navigate to the "Layout Editor" section
3. Adjust the "Grid Size" slider
4. Toggle "Snap to Grid" as desired

## Integration with Other Modules

The Visual Configuration module enhances all other VUI modules:

- **UnitFrames**: Visually position and resize unit frames
- **Skins**: Preview skin changes before applying them
- **Profiles**: Visual comparison of different profiles
- **Automation**: Intuitive configuration of automation settings

## Technical Details

The Visual Configuration module uses several techniques to enhance the UI:

- **Ace3 Config Hooks**: Enhances the Ace3 configuration system
- **Frame Management**: Tracks and manipulates UI frames
- **Color Management**: Enhanced color handling and storage
- **Serialization**: Converts settings to shareable strings
- **Visual Rendering**: Creates visual representations of UI elements

## Compatibility

The Visual Configuration module is designed to work with all other VUI modules and enhances their configuration experience. It's also compatible with most third-party addons, though some advanced features may not work with addons that use non-standard configuration methods.

## Troubleshooting

If you encounter issues with the Visual Configuration module:

1. **Reset to Defaults**: Use `/vuivisual reset` to restore default settings
2. **Module Conflicts**: If UI problems occur, check for conflicts with other UI customization addons
3. **Preset Problems**: If a preset isn't loading correctly, it may have been created with a different version of VUI
4. **Layout Issues**: If UI elements aren't appearing in the Layout Editor, try reloading the UI

## Known Limitations

- The module cannot modify protected frames (frames that Blizzard has restricted for security reasons)
- Some third-party addons may not be fully compatible with the Layout Editor
- Very complex UI setups might cause performance issues in the Layout Editor