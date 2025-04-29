# VUI Addon Sound Files

This directory contains sound files used by various modules in the VUI addon suite.

## Sound Directories

### MSBT Sound Files
Located in `/media/sounds/msbt/`:
- `crit.ogg` - Critical hit notification sound
- `proc.ogg` - Ability proc notification sound
- `lowhealth.ogg` - Low health warning sound
- `dodge.ogg` - Dodge notification sound
- `parry.ogg` - Parry notification sound
- `block.ogg` - Block notification sound
- `heal.ogg` - Healing received notification sound

### SpellNotifications Sound Files
Located in `/media/sounds/spellnotifications/`:
- `interrupt.ogg` - Spell interrupt notification
- `dispel.ogg` - Dispel notification
- `important.ogg` - Important spell cast notification

### Theme-Specific Sound Files
Each theme has its own set of sound effects in the corresponding theme directory:
- `/media/sounds/phoenixflame/` - Phoenix Flame theme sounds
- `/media/sounds/thunderstorm/` - Thunder Storm theme sounds
- `/media/sounds/arcanemystic/` - Arcane Mystic theme sounds
- `/media/sounds/felenergy/` - Fel Energy theme sounds

## File Format Requirements
- All sound files should be in OGG format for compatibility
- Keep file sizes small (under 100KB when possible) for performance
- Audio parameters: 44.1kHz, Stereo, Quality level 3-5
- All sounds should have consistent volume levels

## Usage Guidelines
1. Sound files are loaded on demand by the modules
2. Users can enable/disable sounds in module configuration
3. Custom theme sounds are only used when a specific theme is active
4. All sound files should be properly attributed and licensed for use