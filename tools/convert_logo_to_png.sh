#!/bin/bash
# Convert SVG logo to PNG format for WoW compatibility

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "Error: ImageMagick is required for this script to work."
    echo "Please install ImageMagick before running this script."
    exit 1
fi

# Create various sizes of the logo
echo "Converting Vortex logo to PNG formats..."

# Main icon (using static version for better display in interface)
convert -background none media/vortex_logo_static.svg -resize 256x256 generated-icon.png
echo "Created main icon: generated-icon.png"

# Create a TGA version for in-game assets
convert -background none media/vortex_logo_static.svg -resize 256x256 media/textures/logo.tga
echo "Created TGA logo for in-game use: media/textures/logo.tga"

# Create atlas-ready version
convert -background none media/vortex_logo_static.svg -resize 512x256 media/textures/atlas/common_logo.png
echo "Created atlas-ready logo: media/textures/atlas/common_logo.png"

# Create a BLP version (needs BLPConverter for actual WoW use)
# echo "Note: For proper BLP conversion, you'll need to use BLPConverter separately"
# convert -background none media/vortex_logo_static.svg -resize 256x256 media/textures/logo.png
# echo "Created PNG for BLP conversion: media/textures/logo.png"

echo "Logo conversion complete!"