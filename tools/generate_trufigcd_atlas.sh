#!/bin/bash
# Atlas Texture Generator for TrufiGCD Module
# This script generates the texture atlas for the TrufiGCD module

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "Error: ImageMagick is required for this script to work."
    echo "Please install ImageMagick before running this script."
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p media/textures/atlas/modules

# Define the source texture paths
TRUFI_LOGO="media/textures/trufigcd/logo.tga"
TRUFI_LOGO_TRANSPARENT="media/textures/trufigcd/logo_transparent.tga"
TRUFI_BACKGROUND="media/textures/trufigcd/background.tga"
TRUFI_BORDER="media/textures/trufigcd/border.tga"
TRUFI_ICON_FRAME="media/textures/trufigcd/icon-frame.tga"
TRUFI_CONFIG_BUTTON="media/textures/trufigcd/config-button.tga"
TRUFI_CONFIG_BUTTON_HIGHLIGHT="media/textures/trufigcd/config-button-highlight.tga"
TRUFI_COOLDOWN_SWIPE="media/textures/trufigcd/cooldown-swipe.tga"

# Output path
OUTPUT="media/textures/atlas/modules/trufigcd.tga"

# Atlas dimensions
WIDTH=512
HEIGHT=512

# Create a blank canvas
convert -size ${WIDTH}x${HEIGHT} xc:transparent "$OUTPUT"

# Combine textures according to atlas coordinates
echo "Combining TrufiGCD textures into atlas..."

# logo: {left = 0, right = 0.5, top = 0, bottom = 0.5}
convert "$OUTPUT" "$TRUFI_LOGO" -geometry 256x256+0+0 -composite "$OUTPUT"

# logo_transparent: {left = 0.5, right = 1.0, top = 0, bottom = 0.5}
convert "$OUTPUT" "$TRUFI_LOGO_TRANSPARENT" -geometry 256x256+256+0 -composite "$OUTPUT"

# background: {left = 0, right = 0.25, top = 0.5, bottom = 0.75}
convert "$OUTPUT" "$TRUFI_BACKGROUND" -geometry 128x128+0+256 -composite "$OUTPUT"

# border: {left = 0.25, right = 0.5, top = 0.5, bottom = 0.75}
convert "$OUTPUT" "$TRUFI_BORDER" -geometry 128x128+128+256 -composite "$OUTPUT"

# icon-frame: {left = 0.5, right = 0.75, top = 0.5, bottom = 0.75}
convert "$OUTPUT" "$TRUFI_ICON_FRAME" -geometry 128x128+256+256 -composite "$OUTPUT"

# config-button: {left = 0.75, right = 0.875, top = 0.5, bottom = 0.625}
convert "$OUTPUT" "$TRUFI_CONFIG_BUTTON" -geometry 64x64+384+256 -composite "$OUTPUT"

# config-button-highlight: {left = 0.875, right = 1.0, top = 0.5, bottom = 0.625}
convert "$OUTPUT" "$TRUFI_CONFIG_BUTTON_HIGHLIGHT" -geometry 64x64+448+256 -composite "$OUTPUT"

# cooldown-swipe: {left = 0, right = 0.25, top = 0.75, bottom = 1.0}
convert "$OUTPUT" "$TRUFI_COOLDOWN_SWIPE" -geometry 128x128+0+384 -composite "$OUTPUT"

echo "Atlas texture created at $OUTPUT"
echo "Use this texture in-game with the coordinate mappings defined in core/atlas.lua"