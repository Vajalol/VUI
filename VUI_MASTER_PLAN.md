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

## Implementation Roadmap

- **Phase 1: Core Framework (Completed)**
  - Module system implementation
  - Theme system development
  - Configuration UI creation

- **Phase 2: Module Integration (Completed)**
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
  - Remove duplicate files ✓
  - Ensure one-file-per-purpose structure ✓
  - Merge enhanced functionality into core files ✓

- **Phase 3: Theme Enhancement (Completed)**
  - Implement all themes across modules ✓
  - Add custom theme editor ✓
  - Improve media management ✓
  - Enhance user experience with smooth transitions ✓

- **Phase 4: Advanced Features (In Progress)**
  - Multi-notification support ✓
  - Custom important spell lists
  - Enhanced user experience features

- **Phase 5: Optimization**
  - Performance improvements
  - Memory usage reduction
  - Combat frame rate optimization

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

## Previous Milestone: Theme Enhancement (Completed) ✓
1. Implementing all themes across modules with the standardized ThemeIntegration system ✓
2. Developing the custom theme editor for user-created themes ✓
3. Improving media management for better performance ✓
   - Texture caching system implemented ✓
   - Lazy loading for non-essential textures ✓ 
   - Memory optimization through cache clearing ✓
   - Preloading functionality for theme assets ✓
   - Media Stats tab added to Theme Editor ✓
4. Enhancing user experience with smoother transitions and feedback ✓
   - Comprehensive animation framework implemented ✓
   - Fade, slide, scale, flash, glow, and shine effects added ✓
   - Smooth transitions for theme changes ✓
   - Animated dashboard modules and buttons ✓
   - Performance-aware animations (FPS-based disabling) ✓
5. Integrating the Multi-Notification system with existing notification modules ✓

## Current Focus: Advanced Features
1. Extending the custom important spell lists system
   - Adding spell category management
   - Implementing spell priority levels
   - Creating visual indicators for different spell types
2. Enhancing user experience features
   - Implementing keybinding improvements
   - Adding mouseover tooltips with enhanced information
   - Developing context-sensitive UI elements
3. Performance optimization
   - Reducing memory footprint during combat
   - Optimizing texture handling for raid environments
   - Implementing smart event handling

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

## Contribution Guidelines
- Fork the repository
- Create a new branch for your feature
- Follow the coding standards
- Submit pull requests with clear descriptions
- Test thoroughly before submission