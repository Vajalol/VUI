# VUI Master Plan

## Overview
VUI (Version 0.2.0) is a comprehensive World of Warcraft addon suite designed for The WarWithin Season 2. The project aims to combine multiple popular addons into a single cohesive package with unified styling, configuration, and functionality.

**Author:** VortexQ8

## Core Philosophy
VUI follows the approach of enhancing the existing Blizzard UI frames rather than completely replacing them. This ensures compatibility with game updates while providing extensive customization options.

## Modules Integrated

| Module | Status | Features |
|--------|--------|----------|
| BuffOverlay | ✓ | Enhanced buff tracking with customizable filters |
| TrufiGCD | ✓ | Spell cast tracking with customizable appearance |
| MoveAny | ✓ | Frame repositioning with memory |
| Auctionator | ✓ | Auction house enhancements |
| AngryKeystones | ✓ | M+ dungeon information display |
| OmniCC | ✓ | Cooldown count display |
| OmniCD | ✓ | Party cooldown tracking |
| idTip | ✓ | Displays spell and item IDs in tooltips |
| Premade Group Finder | ✓ | Advanced group finder filtering |
| SpellNotifications | ✓ | Important spell alerts |
| DetailsSkin | ✓ | Damage meter styling |
| MikScrollingBattleText | ✓ | Combat text customization |

## Theme System
VUI includes five comprehensive UI themes:

1. **Phoenix Flame**
   - Dark red/brown backgrounds (#1A0A05)
   - Fiery orange borders (#E64D0D)
   - Amber highlights (#FFA31A)

2. **Thunder Storm** (Default)
   - Deep blue backgrounds (#0A0A1A)
   - Electric blue borders (#0D9DE6)
   - Light blue highlights (#66CCFF)

3. **Arcane Mystic**
   - Deep purple backgrounds (#1A0A2F)
   - Violet borders (#9D0DE6)
   - Pink highlights (#FF66FF)

4. **Fel Energy**
   - Dark green backgrounds (#0A1A0A)
   - Fel green borders (#1AFF1A)
   - Lime highlights (#BFFF00)

5. **Class Color**
   - Dynamically generated based on character's class colors
   - Coordinated accent colors

## Sound Categories
- Interrupt
- Dispel
- Important
- Spell_notification

## Control Panel
- Unified settings panel
- Module-specific configurations
- Theme selection and customization
- Custom spell importance settings

# VUI Development Roadmap

This section outlines the development phases, current status, and upcoming work for the VUI addon suite.

## Phase 1: Initial Setup (Completed) ✓
- Core framework implementation ✓
- Basic module integration ✓
- Addon structure and file organization ✓
- Initial package structure ✓
- Base configuration system ✓

## Phase 2: Module Standardization (Completed) ✓
- Standardized configuration panels ✓
- Module standardization:
  - MSBT Module ✓
  - Auctionator Module ✓
  - AngryKeystones Module ✓
  - BuffOverlay Module enhancement ✓
  - OmniCC/OmniCD Integration ✓
  - DetailsSkin Module ✓
  - Custom Important Spell List ✓
  - TrufiGCD Module ✓
  - SpellNotifications Module ✓
  - PGFinder Module enhancement ✓
  - MoveAny Module standardization ✓
  - idTip Module standardization ✓
  - nameplates Module standardization ✓
  - tooltip Module standardization ✓
  - bags Module standardization ✓
  - castbar Module standardization ✓
  - actionbars Module standardization ✓
  - unitframes Module standardization ✓
  - infoframe Module standardization ✓
  - Paperdoll Module standardization ✓
  - EPF (Enhanced Profile Frames) Module standardization ✓
  - Profiles Module standardization ✓
  - Skins Module standardization ✓
  - Tools Module standardization ✓
  - VisualConfig Module standardization ✓
  - Multi-Notification Support ✓
- Unified logging system ✓
- Common API for module interactions ✓
- Theme foundation system ✓
- Shared utility functions ✓
- Module dependency management ✓
- Remove duplicate files ✓
- Ensure one-file-per-purpose structure ✓
- Merge enhanced functionality into core files ✓

## Phase 3: Theme Enhancement (Completed) ✓
- Implementing all themes across modules with the standardized ThemeIntegration system ✓
- Developing the custom theme editor for user-created themes ✓
- Improving media management for better performance ✓
  - Texture caching system implemented ✓
  - Lazy loading for non-essential textures ✓ 
  - Memory optimization through cache clearing ✓
  - Preloading functionality for theme assets ✓
  - Media Stats tab added to Theme Editor ✓
- Enhancing user experience with smoother transitions and feedback ✓
  - Comprehensive animation framework implemented ✓
  - Fade, slide, scale, flash, glow, and shine effects added ✓
  - Smooth transitions for theme changes ✓
  - Animated dashboard modules and buttons ✓
  - Performance-aware animations (FPS-based disabling) ✓
- Theme-aware module integration ✓
- Runtime theme switching system ✓
- Theme element inheritance ✓
- Comprehensive color schemes ✓
- Visual consistency across all modules ✓
- Integrating the Multi-Notification system with existing notification modules ✓

## Phase 4: Performance Optimization (In Progress) ⟳

### Completed Optimizations ✓
- Texture Atlas System Core Framework ✓
  - Atlas framework implementation ✓
  - Atlas texture mapping and coordinates system ✓
  - UI integration helpers for atlas textures ✓
  - Atlas generator tools for development ✓
  - Media system integration ✓
  - Statistics tracking in Theme Editor ✓
  - Module-specific atlas implementations:
    - MultiNotification atlas implementation ✓
    - BuffOverlay atlas implementation ✓ 
    - TrufiGCD atlas implementation ✓
- Frame Pooling for Dynamic UI Elements ✓
- Smart Event Registration ✓
- Media Loading Optimization ✓
- Memory Usage Monitoring ✓
- Frame Creation Efficiency ✓
- Performance metrics documentation ✓

### Completed Optimizations ✓
- OmniCD Texture Atlas Implementation ✓
- MoveAny Texture Atlas Implementation ✓
- DetailsSkin Texture Atlas Implementation ✓
- Frame Throttling During Combat ✓
- Reducing memory footprint during combat ✓
- Event handling optimization ✓
- Atlas-Based Theme Switching Performance ✓
- Resource Cleanup During Idle ✓
- Global Font System Optimization ✓

### Planned Optimizations ☐
- Database Access Optimization ✓
- Spell Detection Logic Enhancement ✓
- REMOVED: Dynamic Module Loading (not needed) ✗
- REMOVED: Frame rate based throttling (not needed) ✗

## Phase 5: Accessibility Enhancements (Completed) ✓
- High contrast mode ✓
- UI scaling options ✓
- Colorblind-friendly theme variants ✓
- Keyboard navigation enhancement ✓
- Audio feedback options ✓
- Profile management improvements ✓

## Phase 6: Context-Sensitive UI (Deferred) ✗
- Situation-aware information panels ☐
- Combat state reactive frames ☐
- Role-specific UI adaptations ☐
- Specialization-based layouts ☐
- Dungeon/Raid specific enhancements ☐
- PvP-optimized interfaces ☐

## Module-Specific Roadmap

### MultiNotification
- ✓ Core notification system
- ✓ Spell event tracking
- ✓ Theme integration
- ✓ Texture atlas implementation
- ✓ Frame pooling optimization
- ✓ Priority system enhancement
- ✓ Customizable positioning
- ✓ Animation variations
- ✓ Sound customization

### BuffOverlay
- ✓ Core buff tracking
- ✓ Theme integration  
- ✓ Texture atlas implementation
- ✓ Frame pooling optimization
- ✓ Enhanced visibility options
- ✓ Diminishing returns tracking
- ✓ Buff group categorization
- ✓ Special effects for important buffs

### TrufiGCD
- ✓ Core ability tracking
- ✓ Theme integration
- ✓ Texture atlas implementation
- ✓ Enhanced icon customization
- ✓ Advanced filtering options
- ✓ Spell categorization
- ✓ Timeline view option
- ✗ Integration with Details damage meter (Deferred)

### OmniCD
- ✓ Core cooldown tracking
- ✓ Theme integration
- ✓ Texture atlas implementation
- ✓ Enhanced party frame integration
- ✓ Priority system
- ✓ Specialized raid layouts

### DetailsSkin
- ✓ Core damage meter styling
- ✓ Theme integration
- ✓ Texture atlas implementation
- ✓ Dynamic texture loading
- ✓ Performance statistics tracking
- ✓ Skin registry system
- ✓ War Within skin integration
- ✓ Skin selection UI
- ✓ Enhanced graph styling
- ✓ Custom report templates
- ✗ Integration with other damage meters (not needed)

## Development Standards

### File Organization
- All files must follow one-file-per-purpose principle
- Module structure must be consistent across all modules
- Enhanced functionality should be merged into original files

### Coding Standards
- Clear commenting required
- Performance optimization is prioritized
- Local function caching for frequent WoW API calls
- Consistent formatting

### Media Management
- All original textures, sounds, and media files must be included
- Media quality is critical for addon presentation
- SVG assets converted to TGA format for WoW compatibility

### Module Naming
- Must use existing module names exactly as specified
- Enhancing existing modules rather than creating new ones

## Legend
- ✓ Completed
- ⟳ In Progress
- ☐ Planned
- ✗ Deferred

## Configuration Approach
- Tabbed interface for better organization of settings
- Intuitive controls for each module
- Preset configurations for common use cases
- Extensive tooltip documentation

## Documentation
- In-game help system
- Comprehensive configuration guide
- Module-specific documentation
- Theme customization guide

