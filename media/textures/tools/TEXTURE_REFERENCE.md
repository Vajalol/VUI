# Tools Module Texture Reference

This document catalogs all texture assets created for the Tools module of the VUI addon.

## Position of Power

These textures display around action buttons and spell icons during proc or buff effects.

### Standard

- `media/textures/tools/positionofpower/border.svg` - Default border (currently not created, uses themed versions instead)

### Phoenix Flame Theme

- `media/textures/phoenixflame/tools/positionofpower/border.svg` - Fiery orange/amber themed border with flame effects

### Thunder Storm Theme

- `media/textures/thunderstorm/tools/positionofpower/border.svg` - Electric blue themed border with lightning accents

### Arcane Mystic Theme

- `media/textures/arcanemystic/tools/positionofpower/border.svg` - Violet/purple themed border with arcane runes

### Fel Energy Theme

- `media/textures/felenergy/tools/positionofpower/border.svg` - Fel green themed border with corruption effects

## Mouse Trail

These textures are used as particles for the mouse cursor trail effect.

### Standard

- `media/textures/tools/mousetrail/standard.svg` - Default white particle with subtle sparkle effect

### Phoenix Flame Theme

- `media/textures/phoenixflame/tools/mousetrail/trail.svg` - Fiery particle with ember effects

### Thunder Storm Theme

- `media/textures/thunderstorm/tools/mousetrail/trail.svg` - Electric particle with lightning bolt accents

### Arcane Mystic Theme

- `media/textures/arcanemystic/tools/mousetrail/trail.svg` - Arcane particle with rune symbols

### Fel Energy Theme

- `media/textures/felenergy/tools/mousetrail/trail.svg` - Fel energy particle with corruption tendrils

## Usage Notes

1. All textures are SVG format for resolution independence and better scaling
2. Each theme follows its specific color palette and visual language:
   - Phoenix Flame: Dark red/brown backgrounds (#1A0A05), fiery orange borders (#E64D0D), amber highlights (#FFA31A)
   - Thunder Storm: Deep blue backgrounds (#0A0A1A) with electric blue borders (#0D9DE6)
   - Arcane Mystic: Deep purple backgrounds (#1A0A2F) with violet borders (#9D0DE6)
   - Fel Energy: Dark green backgrounds (#0A1A0A) with fel green borders (#1AFF1A)
3. Animation effects are applied via Lua code using these static textures