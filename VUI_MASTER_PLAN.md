# VUI Master Development Plan

## Project Overview
VUI (Version 0.3.0) is a unified World of Warcraft addon suite for The War Within, combining multiple popular addons into a cohesive package with consistent theming, centralized configuration, and enhanced performance.

## Core Design Principles
1. **Unified Experience**: All modules share a consistent visual style and behavior
2. **Performance First**: Optimized code with throttling and on-demand loading
3. **Modular Architecture**: Components can be enabled/disabled independently
4. **Theme Integration**: All UI elements adapt to the selected theme

## Theme System
- **Thunder Storm**: Deep blue backgrounds (#0A0A1A) with electric blue borders (#0D9DE6) - DEFAULT
- **Phoenix Flame**: Dark red/brown backgrounds (#1A0A05) with fiery orange borders (#E64D0D) and amber highlights (#FFA31A)
- **Arcane Mystic**: Deep purple backgrounds (#1A0A2F) with violet borders (#9D0DE6)
- **Fel Energy**: Dark green backgrounds (#0A1A0A) with fel green borders (#1AFF1A)

## Module Standards
1. **Consistent File Structure**:
   - `/modules/[modulename]/init.lua` - Module initialization
   - `/modules/[modulename]/core.lua` - Core functionality
   - `/modules/[modulename]/config.lua` - Configuration UI

2. **Module Registration Process**:
   - Initialize with VUI.ModuleAPI:CreateModule
   - Register settings, config panel, and slash commands
   - Implement Initialize, Enable, and Disable methods

3. **Module Integration Requirements**:
   - Use VUI UI framework for all UI elements
   - Respond to theme changes
   - Support enabling/disabling
   - Use standard naming conventions

## Implementation Priorities

### Immediate Tasks (Current Focus)
1. **Standardize Module Structure**
   - Create consistent module loading patterns
   - Normalize module registration
   - Implement standardized initialization sequences

2. **Complete High-Priority Modules**
   - Finalize SpellNotifications multi-notification support
   - Enhance BuffOverlay module
   - Fix OmniCC/OmniCD theme integration

3. **Improve Theme System**
   - Ensure consistent theme application
   - Centralize theme asset management
   - Standardize theme application methods

### Medium-Term Tasks
1. **UI Framework Enhancement**
   - Improve UI components
   - Create better widgets library
   - Standardize frame creation

2. **Configuration System Refinement**
   - Implement tabbed interface
   - Add search functionality
   - Create visual previews

3. **Documentation**
   - Consolidate documentation
   - Create user guides
   - Improve developer documentation

### Long-Term Tasks
1. **Performance Optimization**
   - Apply throttling to all high-frequency operations
   - Batch frame updates for better performance
   - Optimize event handlers

2. **Complete Integration**
   - Finalize all module integrations
   - Polish all UI elements
   - Conduct quality assurance testing

## Module Status

### Completed Modules
- **SpellNotifications** (Priority: HIGH)
  - ✓ Create spelllist.lua with custom important spells
  - ✓ Implement spelllistui.lua with UI for spell management
  - ✓ Update init.lua with configuration options
  - ✓ Update core.lua for important spell checking
  - ✓ Fix TableToString/StringToTable usage
  - ✓ Add theme-specific notification visuals

- **MSBT** (Priority: MEDIUM)
  - ✓ Complete theme integration for all message types
  - ✓ Implement custom animation paths
  - ✓ Implement scroll area customization

- **Auctionator** (Priority: MEDIUM)
  - ✓ Finish theme integration for all panels
  - ✓ Create theme-specific button and input styles
  - ✓ Add advanced theming configuration

- **AngryKeystones** (Priority: HIGH)
  - ✓ Complete theme integration for all elements
  - ✓ Add enhanced timer displays with theme visuals
  - ✓ Implement completion percentage refinements
  - ✓ Create better chest timer notifications

- **PGFinder** (Priority: MEDIUM)
  - ✓ Finalize theme integration for all panels
  - ✓ Implement advanced filtering options
  - ✓ Add group rating visualization
  - ✓ Create integrated role requirement display

- **DetailsSkin** (Priority: HIGH)
  - ✓ Finalize theme integration across all panels
  - ✓ Implement consistent header/footer styling
  - ✓ Add theme-specific graph and bar textures
  - ✓ Create custom report formatting templates

### In-Progress Modules
- **BuffOverlay** (Priority: HIGH)
  - ✓ Implement theme-specific buff frame styling
  - ✓ Add custom buff/debuff categorization
  - ✓ Create priority-based sorting system
  - ✓ Implement enhanced timer displays
  - ◯ Add class-specific buff highlighting

- **OmniCC/OmniCD** (Priority: HIGH)
  - ✓ Complete theme styling for cooldown displays
  - ✓ Implement enhanced cooldown group management
  - ✓ Add theme-specific cooldown animations
  - ◯ Fix theme-specific textures

### Pending Modules
- **UnitFrames** (Priority: MEDIUM)
  - ◯ Implement theme-specific frame designs
  - ◯ Add customizable layouts
  - ◯ Create buff/debuff integration

- **ActionBars** (Priority: LOW)
  - ◯ Create theme-specific button styling
  - ◯ Implement multi-row configurations
  - ◯ Add condition-based bar swapping

- **Bags** (Priority: LOW)
  - ◯ Implement combined bag view
  - ◯ Add item categorization
  - ◯ Create theme-specific bag frames

## Core System Improvements

### Theme System
- **Theme Application Method**: `ApplyTheme(frame, type)` applies the current theme to any frame
- **Theme Component Types**:
  - Background
  - Border
  - Text
  - Highlight
  - Interaction
- **Theme Color Keys**:
  - primary, secondary, accent
  - backdrop, border, highlight
  - text, subtext, disabled

### UI Framework
- **Standard Frame Creation**: `CreateFrame(name, parent, template)`
- **Standard Texture Creation**: `CreateTexture(frame, layer, name, template)`
- **Standard Font Creation**: `CreateFontString(frame, layer, font, size)`

### Configuration System
- **Standard Module Config**: Registration via `RegisterModuleConfig(name, config)`
- **Config Panel Creation**: Generate via `AddModuleConfigPanel(name, createFn)`
- **Settings Management**: Use `InitializeModuleSettings(name, defaults)`

## Media Resources Organization
- **Theme Textures**: `/media/textures/themes/[theme_name]/[texture_name].tga`
- **Sound Files**: `/media/sounds/[theme_name]/[sound_type].ogg`
- **Fonts**: `/media/fonts/[font_name].ttf`
- **Icons**: `/media/icons/[icon_name].tga`

## Development Guidelines
1. **Code Organization**:
   - Keep functionality separated into logical files
   - Use descriptive variable names
   - Comment complex sections
   - Follow consistent indentation

2. **Performance**:
   - Throttle high-frequency updates
   - Minimize table creation in loops
   - Batch frame updates
   - Use event delegation

3. **UI Design**:
   - Follow WoW UI guidelines
   - Make frames movable
   - Support scaling
   - Use theme colors consistently
   - Test in different resolutions

4. **Testing**:
   - Test with all themes
   - Verify memory usage
   - Check for taint issues
   - Test with and without other addons

## Version Release Plan
- **Version 0.4.0**:
  - Complete SpellNotifications multi-notification support
  - Enhance BuffOverlay with class-specific highlights
  - Fix remaining OmniCC/OmniCD theme issues
  - Implement standardized module loading

- **Version 0.5.0**:
  - Implement UnitFrames module
  - Add ActionBars module
  - Create Bags module
  - Improve theme propagation system

- **Version 1.0.0**:
  - Finalize all module integrations
  - Complete user documentation
  - Polish all UI elements
  - Conduct final quality assurance

## Important Notes
- Always maintain backward compatibility with saved settings
- Don't create enhanced versions of files - improve existing ones
- Keep error handling simple - WoW errors are preferred for easier debugging
- Focus on high-priority modules first
- Follow module integration standards for all new modules
- Maintain consistent naming conventions
- Always test with all available themes