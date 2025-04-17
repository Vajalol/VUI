# VUI Premade Group Finder

## Overview

The Premade Group Finder module enhances the default WoW LFG (Looking For Group) interface with additional features, improved visual styling, and advanced filtering capabilities. It seamlessly integrates with the VUI framework to provide a consistent user experience.

## Key Features

### Enhanced UI
- **Movable Frame**: The LFG frame can be moved around the screen
- **Custom Header**: Includes title and quick access settings button
- **Styled Components**: Uses VUI themes for consistent appearance
- **Compact Mode**: View more groups at once
- **Class-Colored Names**: Player names appear in their class colors

### Advanced Filtering
- **Item Level Filter**: Hide groups requiring higher item levels
- **Role Requirements**: Filter groups looking for specific roles (Tank, Healer, DPS)
- **Voice Chat Filter**: Find groups using voice communication
- **Auto-Refresh**: Automatically refresh the list periodically
- **Advertisement Filter**: Hide groups that appear to be selling services

### Quick Search
- **Favorite Activities**: Mark and filter activities you frequently run
- **Quick Search Buttons**: Instantly search for common group types
- **Player Blacklist**: Hide groups created by specific players

### Enhanced Information
- **Detailed Tooltips**: More information about each group
- **Group Composition**: See available roles at a glance
- **Visual Indicators**: Clearly see group requirements

## How to Use

### Basic Usage
1. Open the default LFG tool in World of Warcraft
2. The VUI enhancements will automatically apply
3. Use the custom filter controls at the top of the frame
4. Hover over groups to see enhanced tooltips
5. Use the star button to mark favorite activities
6. Use the X button to blacklist group leaders

### Slash Commands
- `/vuipgf toggle` - Toggle enhanced UI on or off
- `/vuipgf reset` - Reset the LFG frame position
- `/vuipgf config` - Open configuration panel
- `/vuipgf refresh` - Manually refresh the group list

### Configuration
The module can be configured through the VUI configuration panel:

1. **General tab**: Basic settings and positioning
2. **Appearance tab**: Visual customization options
3. **Filters tab**: Configure filtering behavior
4. **Advanced tab**: Advanced features and blacklist management
5. **Favorites tab**: Manage favorite activities

## Features by Category

### Dungeon/Raid Finder Enhancements
- Display Mythic+ scores (when Raider.IO is available)
- Show current affix information
- Filter by dungeon difficulty
- Mark and filter favorite dungeons

### PvP Group Finder Enhancements
- Show PvP rating information
- Filter by minimum rating
- Display group composition requirements

### General Group Finder Enhancements
- Improved activity selection with favorites marked
- Enhanced description display
- Quickly filter by group type

## Integration with VUI

The Premade Group Finder module is fully integrated with the VUI framework:

- Uses the VUI UI framework for all custom elements
- Adopts the current VUI theme for consistent appearance
- Uses the VUI settings system for configuration
- Accessible through the VUI configuration panel

## Compatible Addons

The Premade Group Finder module is designed to work alongside popular LFG-related addons:

- Raider.IO
- PremadeGroupsFilter
- RIO Score

When these addons are present, the VUI Premade Group Finder will enhance their information display rather than conflicting with them.