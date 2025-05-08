# VUI Changelog

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
