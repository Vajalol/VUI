# VUI Changelog

## [0.7.1-alpha](https://github.com/Vajalol/VUI) (2025-05-09)

### Added
- UI Scale feature in Misc settings panel:
  - Options to enable/disable UI scaling
  - Slider for precise scale adjustment (0.5-1.0)
  - Auto Scale button to calculate optimal scale based on screen resolution
  - Reset button to quickly return to default scale
  - Emergency slash command (/vui-reset-scale) to recover from UI scaling issues
  - Combat-safe scaling that waits until combat ends to apply changes

## [0.7.0-alpha](https://github.com/Vajalol/VUI) (2025-05-09)

### Added
- Enhanced General.Stats module with advanced information displays:
  - Color-changing FPS display (Red, Yellow, Green) based on framerate values
  - Color-changing MS display (Green, Yellow, Orange, Red) based on latency values
  - Added loot specialization display showing current loot spec with:
    - Class-colored text 
    - Specialization icon
    - Automatic fallback to current spec if no loot spec is selected
  - Optimized Stats frame width handling for new display elements

## [0.6.0-alpha](https://github.com/Vajalol/VUI) (2025-05-09)

### Added
- Enhanced Castbar features with advanced information display:
  - Latency Display: Shows network latency in milliseconds on the left side of castbars
  - Target Name Display: Shows the name of the spell target on the right side of castbars
  - Color-coded target names based on class
  - Visual latency indicator for player castbar
  - Comprehensive configuration options in the Castbars settings panel

## [0.5.0-alpha](https://github.com/Vajalol/VUI) (2025-05-09)

### Added
- Enhanced Chat System with advanced features:
  - Chat History: Persistence of up to 500 lines between game sessions
  - Chat Copy: Improved copy button with movable, resizable copy window
  - Emoji Support: Comprehensive emoji conversion system with 34+ emoji textures
  - Whisper Sound: Custom notification sound when receiving whispers
  - Comprehensive configuration options in the Chat settings panel

## [0.4.0-alpha](https://github.com/Vajalol/VUI) (2025-05-09)

### Added
- Enhanced Tooltip features with extensive unit information:
  - Target Info: Shows current target of the unit being inspected
  - Targeted Info: Shows which raid/party members are targeting the current unit
  - Player Titles: Displays full player titles in tooltips
  - Guild Ranks: Shows detailed guild information with color-coded ranks
  - Role Information: Displays unit role (tank, healer, dps) with appropriate icons
  - Mount Display: Shows the current mount of players with name
  - Gender Information: Displays player character gender
  - Item Level: Shows average item level of inspected players with coloring by quality
  - Comprehensive configuration options in the Tooltip settings panel

## [0.3.0-alpha](https://github.com/Vajalol/VUI) (2025-05-09)

### Added
- Implemented new Player Stats feature in General module:
  - Transparent, movable and resizable frame showing detailed player statistics
  - Displays Crit, Haste, Mastery, Versatility, Speed, Leech, and Avoidance percentages
  - Color-coded values with pulse animation effects when stats increase significantly
  - Bloodlust/Heroism tracking with timer and stack count display
  - Comprehensive configuration options in General settings panel
  - Position and size saving functionality

## [0.2.0-alpha](https://github.com/Vajalol/VUI) (2025-05-08)

### Added
- Enhanced configuration layouts for multiple modules:
  - VUIMissingRaidBuffs: Comprehensive buff tracking options
  - VUIMouseFireTrail: Expanded particle customization
  - VUIHealerMana: Enhanced display and color settings
  - VUIScrollingText: Extensive scroll areas and performance options
  - VUIPositionOfPower: Improved color settings
- Created new layout file for VUINotifications with complete configuration panel
- Standardized all module icons to use vortex_thunderstorm logo
- Added high-quality TGA version of main logo for better in-game compatibility

### Changed
- Converted SVG icons to TGA format for better in-game compatibility
- Improved icon directory structure with dedicated subdirectories
- Integrated VUIPlater with Nameplates configuration section for better usability
- Enhanced Media organization with improved folder structure

### Fixed
- Icon format compatibility with World of Warcraft client
- Configuration panel consistency across all modules
- Module organization for better user experience

## [0.1.0-alpha](https://github.com/Vajalol/VUI) (2025-05-07)

### Added
- Initial release based on SUI framework
- Complete rebranding from SUI to VUI
- Comprehensive module system for addon integrations
- All 10 core addon modules integrated:
  - VUIBuffs, VUIAnyFrame, VUIKeystones, VUICC, VUICD, VUIIDs
  - VUIGfinder, VUITGCD, VUIAuctionator, VUINotifications
- All 5 WeakAura-derived modules implemented:
  - VUIConsumables, VUIPositionOfPower, VUIMissingRaidBuffs 
  - VUIMouseFireTrail, VUIHealerMana
- VUIPlater module with complete Whiiskeyz profile replication
- Unified configuration panel for all modules
- Consolidated media directory with consistent structure
- Enhanced animation system for UI elements

### Changed
- Standardized all media references to use uppercase "Media" directory
- Removed test framework in favor of direct in-game error reporting
- Organized configuration options with improved categorization
- Streamlined loading process for better performance

### Fixed
- Media directory case sensitivity issues for cross-OS compatibility
- Module loading order to ensure proper initialization
- Framework dependency issues for standalone operation
