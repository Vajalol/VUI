#!/bin/bash
# Atlas Texture Generator for MoveAny Module
# This script generates the texture atlas for the MoveAny module

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "Error: ImageMagick is required for this script to work."
    echo "Please install ImageMagick before running this script."
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p media/textures/atlas/modules

# Define the source texture paths
MOVEANY_LOGO="media/textures/moveany/logo.tga"
MOVEANY_LOGO_TRANSPARENT="media/textures/moveany/logo_transparent.tga"
MOVEANY_BACKGROUND="media/textures/moveany/background.tga"
MOVEANY_BORDER="media/textures/moveany/border.tga"
MOVEANY_HEADER="media/textures/moveany/header.tga"
MOVEANY_GRID="media/textures/moveany/grid.tga"
MOVEANY_HANDLE="media/textures/moveany/handle.tga"
MOVEANY_MOVER="media/textures/moveany/mover.tga"
MOVEANY_LOCK="media/textures/moveany/lock.tga"
MOVEANY_UNLOCK="media/textures/moveany/unlock.tga"
MOVEANY_HIDDEN="media/textures/moveany/hidden.tga"
MOVEANY_VISIBLE="media/textures/moveany/visible.tga"

# Output path
OUTPUT="media/textures/atlas/modules/moveany.tga"

# Atlas dimensions
WIDTH=512
HEIGHT=512

# Create a blank canvas
convert -size ${WIDTH}x${HEIGHT} xc:transparent "$OUTPUT"

# Combine textures according to atlas coordinates
echo "Combining MoveAny textures into atlas..."

# logo: {left = 0, right = 0.5, top = 0, bottom = 0.5}
convert "$OUTPUT" "$MOVEANY_LOGO" -geometry 256x256+0+0 -composite "$OUTPUT"

# logo_transparent: {left = 0.5, right = 1.0, top = 0, bottom = 0.5}
convert "$OUTPUT" "$MOVEANY_LOGO_TRANSPARENT" -geometry 256x256+256+0 -composite "$OUTPUT"

# background: {left = 0, right = 0.25, top = 0.5, bottom = 0.75}
convert "$OUTPUT" "$MOVEANY_BACKGROUND" -geometry 128x128+0+256 -composite "$OUTPUT"

# border: {left = 0.25, right = 0.5, top = 0.5, bottom = 0.75}
convert "$OUTPUT" "$MOVEANY_BORDER" -geometry 128x128+128+256 -composite "$OUTPUT"

# header: {left = 0.5, right = 0.75, top = 0.5, bottom = 0.75}
convert "$OUTPUT" "$MOVEANY_HEADER" -geometry 128x128+256+256 -composite "$OUTPUT"

# grid: {left = 0.75, right = 1.0, top = 0.5, bottom = 0.75}
convert "$OUTPUT" "$MOVEANY_GRID" -geometry 128x128+384+256 -composite "$OUTPUT"

# handle: {left = 0, right = 0.125, top = 0.75, bottom = 0.875}
convert "$OUTPUT" "$MOVEANY_HANDLE" -geometry 64x64+0+384 -composite "$OUTPUT"

# mover: {left = 0.125, right = 0.25, top = 0.75, bottom = 0.875}
convert "$OUTPUT" "$MOVEANY_MOVER" -geometry 64x64+64+384 -composite "$OUTPUT"

# lock: {left = 0.25, right = 0.375, top = 0.75, bottom = 0.875}
convert "$OUTPUT" "$MOVEANY_LOCK" -geometry 64x64+128+384 -composite "$OUTPUT"

# unlock: {left = 0.375, right = 0.5, top = 0.75, bottom = 0.875}
convert "$OUTPUT" "$MOVEANY_UNLOCK" -geometry 64x64+192+384 -composite "$OUTPUT"

# hidden: {left = 0.5, right = 0.625, top = 0.75, bottom = 0.875}
convert "$OUTPUT" "$MOVEANY_HIDDEN" -geometry 64x64+256+384 -composite "$OUTPUT"

# visible: {left = 0.625, right = 0.75, top = 0.75, bottom = 0.875}
convert "$OUTPUT" "$MOVEANY_VISIBLE" -geometry 64x64+320+384 -composite "$OUTPUT"

echo "Atlas texture created at $OUTPUT"
echo "Use this texture in-game with the coordinate mappings defined in core/atlas.lua"