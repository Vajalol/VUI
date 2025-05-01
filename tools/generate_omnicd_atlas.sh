#!/bin/bash
# Atlas Texture Generator for OmniCD Module
# This script generates the texture atlas for the OmniCD module

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "Error: ImageMagick is required for this script to work."
    echo "Please install ImageMagick before running this script."
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p media/textures/atlas/modules

# Define the source texture paths
OMNICD_LOGO="media/textures/omnicd/logo.tga"
OMNICD_LOGO_TRANSPARENT="media/textures/omnicd/logo_transparent.tga"
OMNICD_BACKGROUND="media/textures/omnicd/background.tga"
OMNICD_BORDER="media/textures/omnicd/border.tga"
OMNICD_ICON_FRAME="media/textures/omnicd/icon-frame.tga"
OMNICD_HEADER="media/textures/omnicd/header.tga"
OMNICD_COOLDOWN_SWIPE="media/textures/omnicd/cooldown-swipe.tga"
OMNICD_READY_PULSE="media/textures/omnicd/ready-pulse.tga"
OMNICD_HIGHLIGHT="media/textures/omnicd/highlight.tga"
OMNICD_STATUS_BAR="media/textures/omnicd/statusbar.tga"

# Output path
OUTPUT="media/textures/atlas/modules/omnicd.tga"

# Atlas dimensions
WIDTH=512
HEIGHT=512

# Create a blank canvas
convert -size ${WIDTH}x${HEIGHT} xc:transparent "$OUTPUT"

# Combine textures according to atlas coordinates
echo "Combining OmniCD textures into atlas..."

# logo: {left = 0, right = 0.5, top = 0, bottom = 0.5}
convert "$OUTPUT" "$OMNICD_LOGO" -geometry 256x256+0+0 -composite "$OUTPUT"

# logo_transparent: {left = 0.5, right = 1.0, top = 0, bottom = 0.5}
convert "$OUTPUT" "$OMNICD_LOGO_TRANSPARENT" -geometry 256x256+256+0 -composite "$OUTPUT"

# background: {left = 0, right = 0.25, top = 0.5, bottom = 0.75}
convert "$OUTPUT" "$OMNICD_BACKGROUND" -geometry 128x128+0+256 -composite "$OUTPUT"

# border: {left = 0.25, right = 0.5, top = 0.5, bottom = 0.75}
convert "$OUTPUT" "$OMNICD_BORDER" -geometry 128x128+128+256 -composite "$OUTPUT"

# icon-frame: {left = 0.5, right = 0.75, top = 0.5, bottom = 0.75}
convert "$OUTPUT" "$OMNICD_ICON_FRAME" -geometry 128x128+256+256 -composite "$OUTPUT"

# header: {left = 0.75, right = 1.0, top = 0.5, bottom = 0.75}
convert "$OUTPUT" "$OMNICD_HEADER" -geometry 128x128+384+256 -composite "$OUTPUT"

# cooldown-swipe: {left = 0, right = 0.25, top = 0.75, bottom = 1.0}
convert "$OUTPUT" "$OMNICD_COOLDOWN_SWIPE" -geometry 128x128+0+384 -composite "$OUTPUT"

# ready-pulse: {left = 0.25, right = 0.5, top = 0.75, bottom = 1.0}
convert "$OUTPUT" "$OMNICD_READY_PULSE" -geometry 128x128+128+384 -composite "$OUTPUT"

# highlight: {left = 0.5, right = 0.75, top = 0.75, bottom = 1.0}
convert "$OUTPUT" "$OMNICD_HIGHLIGHT" -geometry 128x128+256+384 -composite "$OUTPUT"

# statusbar: {left = 0.75, right = 1.0, top = 0.75, bottom = 1.0}
convert "$OUTPUT" "$OMNICD_STATUS_BAR" -geometry 128x128+384+384 -composite "$OUTPUT"

echo "Atlas texture created at $OUTPUT"
echo "Use this texture in-game with the coordinate mappings defined in core/atlas.lua"