#!/bin/bash
# Atlas Texture Generator for BuffOverlay Module
# This script helps generate the BuffOverlay texture atlas

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "Error: ImageMagick is required for this script to work."
    echo "Please install ImageMagick before running this script."
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p media/textures/atlas/modules

# Define the source texture paths
BUFF_LOGO="media/textures/buffoverlay/logo.tga"
BUFF_LOGO_TRANSPARENT="media/textures/buffoverlay/logo_transparent.tga"
BUFF_BACKGROUND="media/textures/buffoverlay/background.tga"
BUFF_BORDER="media/textures/buffoverlay/border.tga"
BUFF_GLOW="media/textures/buffoverlay/glow.tga"
BUFF_ICON_FRAME="media/textures/buffoverlay/icon-frame.tga"
BUFF_COOLDOWN_SWIPE="media/textures/buffoverlay/cooldown-swipe.tga"
BUFF_PRIORITY_ICON="media/textures/buffoverlay/priority-icon.tga"

# Output path
OUTPUT="media/textures/atlas/modules/buffoverlay.tga"

# Atlas dimensions
WIDTH=512
HEIGHT=512

# Create a blank canvas
convert -size ${WIDTH}x${HEIGHT} xc:transparent "$OUTPUT"

# Combine textures according to atlas coordinates
echo "Combining BuffOverlay textures into atlas..."

# logo: {left = 0, right = 0.5, top = 0, bottom = 0.5}
convert "$OUTPUT" "$BUFF_LOGO" -geometry 256x256+0+0 -composite "$OUTPUT"

# logo_transparent: {left = 0.5, right = 1.0, top = 0, bottom = 0.5}
convert "$OUTPUT" "$BUFF_LOGO_TRANSPARENT" -geometry 256x256+256+0 -composite "$OUTPUT"

# background: {left = 0, right = 0.25, top = 0.5, bottom = 0.75}
convert "$OUTPUT" "$BUFF_BACKGROUND" -geometry 128x128+0+256 -composite "$OUTPUT"

# border: {left = 0.25, right = 0.5, top = 0.5, bottom = 0.75}
convert "$OUTPUT" "$BUFF_BORDER" -geometry 128x128+128+256 -composite "$OUTPUT"

# glow: {left = 0.5, right = 0.75, top = 0.5, bottom = 0.75}
convert "$OUTPUT" "$BUFF_GLOW" -geometry 128x128+256+256 -composite "$OUTPUT"

# icon-frame: {left = 0.75, right = 1.0, top = 0.5, bottom = 0.75}
convert "$OUTPUT" "$BUFF_ICON_FRAME" -geometry 128x128+384+256 -composite "$OUTPUT"

# cooldown-swipe: {left = 0, right = 0.25, top = 0.75, bottom = 1.0}
convert "$OUTPUT" "$BUFF_COOLDOWN_SWIPE" -geometry 128x128+0+384 -composite "$OUTPUT"

# priority-icon: {left = 0.25, right = 0.5, top = 0.75, bottom = 1.0}
convert "$OUTPUT" "$BUFF_PRIORITY_ICON" -geometry 128x128+128+384 -composite "$OUTPUT"

echo "Atlas texture created at $OUTPUT"
echo "Use this texture in-game with the coordinate mappings defined in core/atlas.lua"