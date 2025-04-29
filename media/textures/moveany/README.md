# MoveAny Module Media Files

This directory contains textures and media files for the MoveAny module in the VUI addon suite.

## Required Files
- `frame.svg` - Standard frame texture for movable frames
- `handle.svg` - Standard handle texture for frame dragging
- `grid.svg` - Alignment grid texture
- Theme-specific textures in each theme directory:
  - `phoenixflame/moveany/frame.svg` - Phoenix Flame themed frame
  - `phoenixflame/moveany/handle.svg` - Phoenix Flame themed handle
  - `thunderstorm/moveany/frame.svg` - Thunder Storm themed frame
  - `thunderstorm/moveany/handle.svg` - Thunder Storm themed handle
  - `arcanemystic/moveany/frame.svg` - Arcane Mystic themed frame
  - `arcanemystic/moveany/handle.svg` - Arcane Mystic themed handle
  - `felenergy/moveany/frame.svg` - Fel Energy themed frame
  - `felenergy/moveany/handle.svg` - Fel Energy themed handle

## SVG to TGA Conversion
For WoW client compatibility, these SVG files need to be converted to TGA format:
- `frame.tga`
- `handle.tga`
- `grid.tga`
- Each theme's specific MoveAny textures

## File Descriptions
- **frame.svg**: The border texture for all movable frames in the WoW interface, used to highlight frames during movement.

- **handle.svg**: The handle texture that appears on movable frames, allowing users to drag and position UI elements.

- **grid.svg**: A grid texture that appears during frame movement to assist with precise alignment of UI elements.

- **Theme-specific textures**: Each theme has custom MoveAny textures that match its visual style:
  - Phoenix Flame: Fiery orange/red frames with flame corner embellishments
  - Thunder Storm: Electric blue frames with lightning bolt corner details
  - Arcane Mystic: Violet/purple frames with arcane rune patterns
  - Fel Energy: Bright green frames with fel corruption tendrils