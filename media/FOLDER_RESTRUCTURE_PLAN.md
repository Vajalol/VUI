# VUI Media Folder Restructuring Plan

## Current Issues

The current media folder structure contains duplicate folder names with inconsistent capitalization:
- `media/textures` and `media/Textures`
- `media/icons` and `media/Icons`
- `media/fonts` and `media/Fonts`

This creates confusion and makes it difficult to manage assets.

## Standardization Plan

We will standardize on lowercase folder names for all media assets:

1. `media/textures` - All texture assets
2. `media/icons` - All icon assets
3. `media/fonts` - All font assets

## Migration Tasks

### Textures Migration

1. Move all files from `media/Textures/*` to appropriately named subdirectories in `media/textures/`
   - `media/Textures/Chat/*` → `media/textures/chat/`
   - `media/Textures/ClassPortraits/*` → `media/textures/classportraits/`
   - `media/Textures/Config/*` → `media/textures/config/`
   - `media/Textures/Core/*` → `media/textures/core/`
   - `media/Textures/Map/*` → `media/textures/map/`
   - `media/Textures/Nameplates/*` → `media/textures/nameplates/`
   - `media/Textures/RaidFrames/*` → `media/textures/raidframes/`
   - `media/Textures/Status/*` → `media/textures/status/`
   - `media/Textures/Tooltip/*` → `media/textures/tooltip/`
   - `media/Textures/UnitFrames/*` → `media/textures/unitframes/`

2. Remove the capitalized `media/Textures` directory after migration

### Icons Migration

1. Move all files from `media/Icons/*` to `media/icons/`
2. Remove the capitalized `media/Icons` directory after migration

### Fonts Migration

1. Move all files from `media/Fonts/*` to `media/fonts/`
2. Move `media/Fonts/temp/*` to `media/fonts/temp/`
3. Remove the capitalized `media/Fonts` directory after migration

## Code Update

After file migration, update all references in the codebase to use the standardized lowercase paths.

## Implementation Timeline

1. Create backup of current media structure
2. Perform file migrations
3. Update code references
4. Validate addon functionality
5. Remove empty directories

## Notes

- All SVG assets remain in their current locations
- All new assets should use the standardized lowercase folder structure
- This restructuring should be done in a single update to minimize disruption