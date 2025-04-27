# VUI - Unified World of Warcraft Addon Suite

![VUI Logo](media/textures/logo.tga)

## Overview

VUI (Version 0.2.0) is a comprehensive UI enhancement suite for World of Warcraft: The War Within, designed to provide a unified, visually cohesive interface experience with maximum customization. This addon suite combines the functionality of nine popular addons into a single package with a centralized configuration system, allowing players to maintain a consistent visual style throughout their entire UI.

## Core Features

### Unified Configuration System
- **Central Control Panel**: Single configuration interface for all modules with tab-based navigation
- **Profile System**: Create, save, and share complete UI configurations
- **Character-Specific Settings**: Set different configurations for each character
- **Import/Export**: Share your profiles with other VUI users
- **Real-time Preview**: See changes as you make them without committing

### Advanced Theme System
- **Four Complete Themes**: Transform your entire UI with a single click
  - **Thunder Storm**: Deep blue backgrounds (#0A0A1A) with electric blue borders (#0D9DE6)
  - **Phoenix Flame**: Dark red/brown backgrounds (#1A0A05) with fiery orange borders (#E64D0D) and amber highlights (#FFA31A)
  - **Arcane Mystic**: Deep purple backgrounds (#1A0A2F) with violet borders (#9D0DE6)
  - **Fel Energy**: Dark green backgrounds (#0A1A0A) with fel green borders (#1AFF1A)
- **Theme Components**: Each theme includes:
  - Color schemes for all UI elements
  - Custom textures and borders
  - Animation effects
  - Font styles
  - Sound schemes
- **Theme Editor**: Create your own themes or customize existing ones

### Performance Optimization
- **Smart Throttling**: Resource-intensive operations are throttled
- **On-Demand Loading**: Modules load only when needed
- **Memory Management**: Efficient memory usage to minimize impact
- **FPS Protection**: Automatic scaling of effects based on performance
- **Combat Optimization**: Reduced processing during combat for maximum performance

### Comprehensive Module Integration
- **21 Integrated Modules**: All fully compatible with the theme system
- **Standardized API**: Consistent behavior across all modules
- **Inter-Module Communication**: Modules share information efficiently
- **Global Settings**: Some settings apply across multiple modules for consistency

## Included Modules

### Core Addons
1. **BuffOverlay**
   - Enhanced buff tracking and visualization
   - Custom visual effects for important buffs
   - Categorized buff display
   - Countdown timers and stack visualization
   - Buff filtering system

2. **TrufiGCD**
   - Spell cast tracking and history
   - Visual cast sequence display
   - Customizable spell icons
   - Cooldown tracking
   - Spellbook integration

3. **MoveAny**
   - Flexible UI element positioning
   - Lock/unlock any frame
   - Save position profiles
   - Grid snapping
   - Position reset options

4. **Auctionator**
   - Auction house enhancements
   - Price history tracking
   - One-click posting
   - Purchase history
   - Market value analysis

5. **Angry Keystones**
   - Mythic+ dungeon information
   - Timer optimization
   - Affix details
   - Enemy forces counter
   - Route planning

6. **OmniCC**
   - Enhanced cooldown count and visualization
   - Custom text and colors
   - Font customization
   - Position options
   - Minimum duration thresholds

7. **OmniCD**
   - Party cooldown tracking
   - Raid cooldown overview
   - Customizable icons and layouts
   - Pre-planned cooldown rotations
   - Priority system

8. **idTip**
   - ID display in tooltips
   - Spell IDs
   - Item IDs
   - NPC IDs
   - Quest IDs

9. **Premade Group Finder**
   - Enhanced group finder functionality
   - Advanced filtering
   - Auto-refresh
   - Score visualization
   - Group history tracking

10. **SpellNotifications**
    - Advanced combat notifications
    - Customizable sound alerts
    - Visual spell effects
    - Combat event tracking
    - Critical event emphasis

### Interface Enhancements

11. **Bags**
    - Combined bag view
    - Item categorization
    - Auto-sorting
    - Item level display
    - Search enhancement

12. **Paperdoll (Character Panel)**
    - Enhanced stats display
    - Item level summary
    - Detailed stat breakdowns
    - Gear optimization suggestions
    - Visual equipment comparison

13. **ActionBars**
    - Multi-row configurations
    - Condition-based bar swapping
    - Enhanced keybind display
    - Macro integration
    - Combat state adaptation

14. **UnitFrames**
    - Customizable player/target frames
    - Role-specific layouts
    - Buff/debuff integration
    - Resource visualization
    - Status indicators

15. **Castbar**
    - Enhanced cast visualization
    - Interrupt indication
    - Cast history
    - Latency display
    - Channeling optimization

16. **Tooltip**
    - Enhanced information display
    - Role/spec information
    - Achievement tracking
    - Guild integration
    - Item comparison

### Visual & Performance

17. **Skins**
    - Consistent UI styling across all Blizzard frames
    - Third-party addon styling
    - Custom border options
    - Background effects
    - Text enhancements

18. **Profiles**
    - Complete configuration management
    - Character-specific settings
    - Import/export functionality
    - Backup system
    - Configuration snapshots

19. **Automation**
    - Routine task automation
    - Smart quest handling
    - Vendor interactions
    - Loot management
    - Social interactions

20. **Visual Config**
    - Advanced visual customization tools
    - Color picker
    - Texture browser
    - Animation editor
    - Layout tools

21. **InfoFrame**
    - Information display panel
    - Performance metrics
    - Character statistics
    - Combat data
    - Event tracking

## Installation Guide

### Basic Installation
1. Download the latest release from GitHub or your preferred addon repository
2. Extract the VUI folder to your World of Warcraft\_retail_\Interface\AddOns directory
3. Ensure the path structure is correct: ...\Interface\AddOns\VUI\
4. Restart World of Warcraft or reload your UI (/reload)
5. Type /vui to open the configuration panel

### Advanced Installation
1. For patch-specific versions, check the compatibility notes
2. If you're upgrading from a previous version, backup your WTF folder first
3. When upgrading, delete the old VUI folder completely before installing the new version
4. Check for optional modules in the "optionals" folder of the download
5. For best performance, disable any standalone versions of the integrated addons

## Detailed Configuration Guide

VUI can be configured through the in-game configuration panel, accessible by typing `/vui` in the chat window.

### General Tab
- **Welcome Panel**: Quick overview and getting started information
- **Core Settings**: Basic addon functionality options
  - Enable/disable VUI globally
  - Set update frequency
  - Configure performance options
  - Set debug options
- **Character-Specific Settings**: Options that apply only to the current character
- **Reset Options**: Reset various aspects of VUI to defaults
  - Reset current module
  - Reset all settings
  - Reset positions
  - Reset only visual settings

### Appearance Tab
- **Theme Selection**: Choose and preview the four main themes
  - Each theme includes a visual preview
  - Apply themes with a single click
  - Custom theme creation
- **Font Settings**: Configure all text elements
  - Font family selection
  - Size options
  - Outline and shadow settings
- **Border Style**: Customize UI borders
  - Border thickness
  - Style options (solid, gradient, glow)
  - Corner options (rounded, square, beveled)
- **Texture Settings**: Configure background textures
  - Statusbar textures
  - Background patterns
  - Special effects
- **Opacity Settings**: Control transparency levels
  - Background opacity
  - Border opacity
  - Text opacity
- **Animation Settings**: Configure UI animations
  - Enable/disable animations
  - Speed settings
  - Complexity options

### Modules Tab
Organized into three categories:

#### Core Addons
- BuffOverlay, TrufiGCD, MoveAny, Auctionator, AngryKeystones, OmniCC, OmniCD, idTip, PremadeGroupFinder, SpellNotifications
- Each module has:
  - Enable/disable toggle
  - Quick settings panel
  - "Settings" button for detailed configuration

#### Interface Enhancements
- Bags, Paperdoll, ActionBars, UnitFrames, Castbar, Tooltip
- Each enhancement has:
  - Enable/disable toggle
  - Visual style options
  - Layout configuration
  - Integration options

#### Visual & Performance
- Skins, Profiles, Automation, VisualConfig, InfoFrame
- Each module has:
  - Enable/disable toggle
  - Performance impact indicator
  - Customization options
  - Integration settings

### Profiles Tab
- **Profile Management**: Create, select, delete and copy profiles
- **Import/Export**: Share profiles between characters or players
- **Backup System**: Automatic and manual backup options
- **Character Specific**: Set profiles to automatically load for specific characters
- **Default Profile**: Set a fallback profile

### About Tab
- **Version Information**: Current version and update checking
- **Authors**: Credits and contributor information
- **Thanks**: Acknowledgements for resources and inspiration
- **Help Resources**: Links to documentation and support
- **Reporting Issues**: How to submit bug reports or suggestions

## Theme Customization Guide

### Basic Theme Selection
1. Open VUI configuration panel (/vui)
2. Navigate to the Appearance tab
3. Select one of the four base themes
4. Click "Apply Theme" to immediately activate

### Advanced Theme Customization
1. Select a base theme as your starting point
2. Navigate to Visual & Performance > VisualConfig
3. Use the color picker to adjust individual elements
4. Save your custom theme with a unique name
5. Export your theme to share with others

### Theme Components
Each theme controls these elements:
- **Colors**: Primary, secondary, and accent colors
- **Textures**: Background, border, and special effect textures
- **Fonts**: Text style, size, and color
- **Animations**: Transition effects and durations
- **Sounds**: UI interaction sounds
- **Special Effects**: Glows, particles, and other visual effects

## Module-Specific Guides

### BuffOverlay Configuration
- **Display Options**: Size, position, and grouping
- **Filter System**: Show/hide specific buff types
- **Visual Options**: Icon style, border, and glow effects
- **Sound Alerts**: Configure audio cues for important buffs
- **Integration**: How it works with other modules

### Action Bars Setup
- **Layout Options**: Number of bars, buttons per row, and spacing
- **Visibility**: Show/hide based on combat state, stance, or other conditions
- **Keybinding Display**: Customize how keybinds appear
- **Special Bars**: Stance bars, pet bars, and extra action buttons
- **Theme Integration**: How themes affect your action bars

### UnitFrames Customization
- **Frame Selection**: Player, target, focus, party, raid, etc.
- **Layout Options**: Size, position, and orientation
- **Element Configuration**: Health, mana, castbars, buffs/debuffs
- **Role-Specific Layouts**: Different setups for tank, healer, and DPS
- **Advanced Options**: Combat feedback, portrait style, and text format

### OmniCD for Raid Leaders
- **Setup for Raid Leading**: Track important cooldowns
- **Cooldown Categories**: Group abilities by importance
- **Visual Display**: Position, size, and style options
- **Announcement Options**: Chat and raid warning integration
- **Planning Tools**: Pre-plan cooldown rotations

## Performance Optimization Tips

### General Performance Settings
- **Reduce Animation Complexity**: Lower animation effects in busy situations
- **Adjust Update Frequency**: Change how often UI elements update
- **Optimize Combat Settings**: Reduce UI load during intense fights
- **Memory Management**: Clear caches and unused data

### Settings for Low-End Systems
- **Minimal Mode**: Enable the performance-focused preset
- **Reduce Texture Resolution**: Lower quality for better performance
- **Disable Complex Modules**: Turn off resource-intensive features
- **Combat-Only Mode**: Only show certain elements during combat

### Settings for High-End Systems
- **Maximum Visual Quality**: Enable all visual enhancements
- **Increase Update Frequency**: Get more responsive updates
- **Enable All Animations**: Use the full animation suite
- **Extended Information Display**: Show more detailed information

## Troubleshooting Guide

### Common Issues and Solutions
- **UI Not Loading**: Reset UI cache or check for conflicting addons
- **Theme Not Applying**: Clear theme cache or reset appearance settings
- **Module Conflicts**: Identify and resolve conflicts with other addons
- **Performance Issues**: Apply optimization settings or disable heavy modules
- **Profile Corruption**: Restore from backup or reset specific settings

### Advanced Troubleshooting
- **Diagnostic Mode**: Enable VUI's built-in diagnostic tools
- **Log Analysis**: Check for error patterns in the VUI log
- **Component Testing**: Isolate and test individual components
- **Clean Installation**: Complete removal and fresh install process
- **Compatibility Mode**: Special settings for problematic environments

## Version History and Updates

See the [CHANGES.md](CHANGES.md) for a detailed version history and changelog.

### Update Process
1. Back up your current profiles
2. Download the newest version
3. Replace the old VUI folder completely
4. Start the game and check for migration messages
5. Reconfigure any new options as needed

## Community and Support

- **GitHub Repository**: Source code and issue tracking
- **Discord Community**: Real-time help and discussion
- **Configuration Sharing**: Share and find community-created themes and profiles
- **Contributing**: Guidelines for contributing to VUI development

## Credits

VUI is developed by VortexQ8, with inspiration and elements derived from:
- SUI by Syiana (framework base)
- Individual module authors (see respective module credits)
- Community contributors and testers

## License

VUI is released under the MIT License. See the LICENSE file for more details.