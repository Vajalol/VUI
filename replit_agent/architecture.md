# VUI - Architecture Overview

## 1. Overview

VUI (Vortex UI) is a comprehensive World of Warcraft addon suite designed to enhance the game's default user interface. The addon integrates multiple popular addons into a single, cohesive package with consistent theming, centralized configuration, and enhanced performance optimization. Rather than completely replacing the default UI, VUI takes the approach of enhancing existing Blizzard UI frames.

### Key Features

- **Performance Optimization**: Texture atlas system, frame pooling, combat performance tuning
- **Unified Notification System**: Centralized alert system for spell alerts, interrupts, dispels
- **Comprehensive Theming**: Five complete themes with consistent application across all modules
- **Modular Architecture**: Numerous independent modules that can be enabled/disabled
- **Enhanced UI Components**: Improvements to unitframes, actionbars, tooltips, castbars, etc.

## 2. System Architecture

### Core Structure

VUI follows a modular architecture pattern where functionality is divided into:

1. **Core System**: Base functionality, theme handling, initialization, event management
2. **Module System**: Independent modules that provide specific UI enhancements
3. **Theming System**: Manages the visual appearance across all components

### Technology Stack

- **Language**: Lua 5.1 (World of Warcraft's scripting environment)
- **Libraries**: 
  - Ace3 framework (AceGUI, AceConfig, AceDB, etc.)
  - LibSharedMedia-3.0 for shared media resources

### Configuration Management

VUI uses AceDB for persistent storage of user preferences with:
- Global saved variables: `VUIDB`
- Character-specific saved variables: `VUICharacterDB`
- Profile system for sharing configurations between characters

## 3. Key Components

### Core Components

#### Initialization System
- **Location**: `init.lua`
- **Purpose**: Initializes the addon, creates global tables, and sets up modules
- **Features**: Module registration, library reference establishment

#### Media System
- **Location**: `media/Load.xml`
- **Purpose**: Manages textures, fonts, sounds, and other media assets
- **Features**: Texture atlas optimization for reduced memory usage

#### Theme Management
- **Location**: `modules/skins/themes/`
- **Purpose**: Manages the visual appearance of all UI elements
- **Features**: Five core themes (Thunder Storm, Phoenix Flame, Arcane Mystic, Fel Energy, Class Color)

### Module System

VUI consists of 26+ independent modules, each handling a specific UI enhancement:

| Module Category | Examples | Purpose |
|-----------------|----------|---------|
| Core UI Enhancements | unitframes, actionbars, castbar | Improves basic UI elements |
| Information Display | tooltip, infoframe, trufigcd | Provides additional information |
| Tracking Systems | buffoverlay, omnicd | Tracks buffs, debuffs, and cooldowns |
| Quality of Life | moveany, automation | Improves usability and convenience |
| External Integrations | detailsskin, angrykeystone | Enhances 3rd party addons |
| Utility | tools, visualconfig | Provides additional functionality |

#### Module Architecture
- Each module follows a standardized structure:
  - `init.lua`: Module initialization and configuration
  - `core.lua`: Core functionality
  - `ThemeIntegration.lua`: Theme application for the module
  - Additional specialized files for complex modules

### Optimization Systems

#### Texture Atlas System
- **Location**: `tools/atlas_generator.lua` and module-specific atlas files
- **Purpose**: Combines individual textures into texture atlases
- **Benefits**: Reduces memory usage by 30-40%, improves performance

#### Frame Pooling
- **Implementation**: Throughout various modules
- **Purpose**: Recycles UI elements instead of destroying and recreating them
- **Benefits**: Reduces garbage collection, improves performance during rapid UI updates

## 4. Data Flow

### Initialization Flow

1. `init.lua` creates the global `VUI` table and namespace
2. Libraries and dependencies are loaded
3. Core systems are initialized
4. Modules are registered and initialized based on their enabled status
5. User configuration is loaded from saved variables

### Event Handling

- VUI uses the WoW event system to respond to game events
- Modules register for specific events related to their functionality
- The core system handles throttling and batching of events for performance

### Module Communication

- Modules communicate through:
  - Direct function calls
  - Callback system for loosely coupled modules
  - Hooks into original functions for UI customization

## 5. External Dependencies

### WoW API

- VUI extensively interacts with the World of Warcraft API
- Version compatibility: 11.0.5 (The War Within)

### Libraries

- **Ace3 Suite**:
  - AceDB-3.0: Database management
  - AceGUI-3.0: UI creation
  - AceConfig-3.0: Configuration interface
  - AceHook-3.0: Function hooking
  - AceEvent-3.0: Event handling

- **LibSharedMedia-3.0**: Media resource sharing between addons

### Module-specific Integrations

- **Details!**: Damage meter integration through DetailsSkin module
- **Auctionator**: Auction house enhancement
- **AngryKeystones**: Mythic+ dungeon information
- **OmniCD**: Party cooldown tracking

## 6. Development Tools

### Texture Generation

- **Tools**: ImageMagick for texture manipulation and atlas generation
- **Scripts**: Multiple scripts in the `/tools` directory to generate and maintain texture atlases
- **Purpose**: Optimize memory usage and maintain visual consistency

### Module Standardization

- **Tools**: Module verification and standardization utilities
- **Location**: `tools/module_verifier.lua`, `tools/module_standardization_utility.lua`
- **Purpose**: Enforce consistent structure across modules

### Release Packaging

- **Script**: `create_release_package.sh`
- **Purpose**: Creates clean release packages for distribution
- **Features**: Removes development and debug files, optimizes for distribution

## 7. Performance Considerations

### Memory Optimization

- **Texture Atlas System**: Combines multiple textures into single files
- **Frame Pooling**: Recycles UI elements to reduce garbage collection
- **Resource Cleanup**: Automated cleanup of unused resources

### Combat Performance

- **Event Throttling**: Reduces processing during high-intensity gameplay
- **Conditional Processing**: Adjusts update frequency based on combat status
- **Frame Updates**: Optimizes the frequency of UI updates

## 8. Extensibility

### Module API

- Standard module API for creating new modules
- Hooks and callbacks for extending existing functionality
- Theming integration for visual consistency

### Configuration System

- Centralized configuration through the AceConfig framework
- Profile system for sharing settings between characters
- Import/export functionality for configuration sharing