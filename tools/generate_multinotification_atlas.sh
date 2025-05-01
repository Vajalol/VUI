#!/bin/bash
# Atlas Texture Generator for MultiNotification Module
# This script helps generate the MultiNotification texture atlas

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "Error: ImageMagick is required for this script to work."
    echo "Please install ImageMagick before running this script."
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p media/textures/atlas/modules

# Define the source texture paths
NOTIFICATION_BG="media/textures/multinotification/notification-background.tga"
NOTIFICATION_BORDER="media/textures/multinotification/notification-border.tga"
NOTIFICATION_GLOW="media/textures/multinotification/notification-glow.tga"
NOTIFICATION_ICON_FRAME="media/textures/multinotification/notification-icon-frame.tga"
SPELL_ALERT_FRAME="media/textures/multinotification/spell-alert-frame.tga"
INTERRUPT_ICON="media/textures/multinotification/interrupt-icon.tga"
DISPEL_ICON="media/textures/multinotification/dispel-icon.tga"
IMPORTANT_ICON="media/textures/multinotification/important-icon.tga"
COOLDOWN_SPIRAL="media/textures/multinotification/cooldown-spiral.tga"

# Output path
OUTPUT="media/textures/atlas/modules/multinotification.tga"

# Atlas dimensions
WIDTH=512
HEIGHT=512

# Create a blank canvas
convert -size ${WIDTH}x${HEIGHT} xc:transparent "$OUTPUT"

# Combine textures according to atlas coordinates
echo "Combining MultiNotification textures into atlas..."

# notification-background: {left = 0, right = 0.25, top = 0, bottom = 0.25}
convert "$OUTPUT" "$NOTIFICATION_BG" -geometry 128x128+0+0 -composite "$OUTPUT"

# notification-border: {left = 0.25, right = 0.5, top = 0, bottom = 0.25}
convert "$OUTPUT" "$NOTIFICATION_BORDER" -geometry 128x128+128+0 -composite "$OUTPUT"

# notification-glow: {left = 0.5, right = 0.75, top = 0, bottom = 0.25}
convert "$OUTPUT" "$NOTIFICATION_GLOW" -geometry 128x128+256+0 -composite "$OUTPUT"

# notification-icon-frame: {left = 0.75, right = 1.0, top = 0, bottom = 0.25}
convert "$OUTPUT" "$NOTIFICATION_ICON_FRAME" -geometry 128x128+384+0 -composite "$OUTPUT"

# spell-alert-frame: {left = 0, right = 0.25, top = 0.25, bottom = 0.5}
convert "$OUTPUT" "$SPELL_ALERT_FRAME" -geometry 128x128+0+128 -composite "$OUTPUT"

# interrupt-icon: {left = 0.25, right = 0.375, top = 0.25, bottom = 0.375}
convert "$OUTPUT" "$INTERRUPT_ICON" -geometry 64x64+128+128 -composite "$OUTPUT"

# dispel-icon: {left = 0.375, right = 0.5, top = 0.25, bottom = 0.375}
convert "$OUTPUT" "$DISPEL_ICON" -geometry 64x64+192+128 -composite "$OUTPUT"

# important-icon: {left = 0.5, right = 0.625, top = 0.25, bottom = 0.375}
convert "$OUTPUT" "$IMPORTANT_ICON" -geometry 64x64+256+128 -composite "$OUTPUT"

# cooldown-spiral: {left = 0.625, right = 0.75, top = 0.25, bottom = 0.375}
convert "$OUTPUT" "$COOLDOWN_SPIRAL" -geometry 64x64+320+128 -composite "$OUTPUT"

echo "Atlas texture created at $OUTPUT"
echo "Use this texture in-game with the coordinate mappings defined in core/atlas.lua"