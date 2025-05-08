# VUI Changelog

## [0.1.0-alpha](https://github.com/Vajalol/VUI) (2025-05-08)

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
