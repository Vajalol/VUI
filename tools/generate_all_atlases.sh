#!/bin/bash
# Master Atlas Generator Script
# This script runs all individual atlas generation scripts

echo "VUI Texture Atlas Generator"
echo "=========================="
echo ""

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "Error: ImageMagick is required for atlas generation."
    echo "Please install ImageMagick before running this script."
    exit 1
fi

echo "1. Generating MultiNotification atlas..."
if [ -f "tools/generate_multinotification_atlas.sh" ]; then
    bash tools/generate_multinotification_atlas.sh
else
    echo "   Script not found. Skipping."
fi

# Additional module atlas generation
echo "2. Generating BuffOverlay atlas..."
if [ -f "tools/generate_buffoverlay_atlas.sh" ]; then
    bash tools/generate_buffoverlay_atlas.sh
else
    echo "   Script not found. Skipping."
fi

echo "3. Generating TrufiGCD atlas..."
if [ -f "tools/generate_trufigcd_atlas.sh" ]; then
    bash tools/generate_trufigcd_atlas.sh
else
    echo "   Script not found. Skipping."
fi

echo "4. Generating OmniCD atlas..."
if [ -f "tools/generate_omnicd_atlas.sh" ]; then
    bash tools/generate_omnicd_atlas.sh
else
    echo "   Script not found. Skipping."
fi

echo ""
echo "Atlas generation complete."
echo "You should now have updated atlas textures in media/textures/atlas/modules/"
echo ""
echo "Remember to test these changes in-game to ensure your textures are correctly positioned in the atlas."