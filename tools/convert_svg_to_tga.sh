#!/bin/bash
# Convert SVG assets to TGA format for WoW compatibility
# Author: VortexQ8

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "Error: ImageMagick is required for this script to work."
    echo "Please install ImageMagick before running this script."
    exit 1
fi

# Set base directory
BASE_DIR="media"

# Function to convert a single SVG file to TGA
convert_svg_to_tga() {
    local svg_file="$1"
    local tga_file="${svg_file%.svg}.tga"
    
    echo "Converting $svg_file to $tga_file..."
    
    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$tga_file")"
    
    # Convert SVG to TGA with transparency
    convert -background none "$svg_file" "$tga_file"
    
    if [ $? -eq 0 ]; then
        echo "✓ Successfully converted: $tga_file"
    else
        echo "✗ Failed to convert: $svg_file"
    fi
}

# Find all SVG files in media directory
echo "Finding all SVG files in $BASE_DIR directory..."
SVG_FILES=$(find "$BASE_DIR" -type f -name "*.svg")

if [ -z "$SVG_FILES" ]; then
    echo "No SVG files found in $BASE_DIR directory."
    exit 0
fi

# Count total files
TOTAL_FILES=$(echo "$SVG_FILES" | wc -l)
echo "Found $TOTAL_FILES SVG files to convert."

# Process each SVG file
COUNTER=0
for svg_file in $SVG_FILES; do
    COUNTER=$((COUNTER + 1))
    echo "[$COUNTER/$TOTAL_FILES] Processing $svg_file"
    
    # Check if corresponding TGA file already exists and is newer
    tga_file="${svg_file%.svg}.tga"
    if [ -f "$tga_file" ] && [ "$tga_file" -nt "$svg_file" ]; then
        echo "✓ TGA file already up to date: $tga_file"
    else
        convert_svg_to_tga "$svg_file"
    fi
done

echo "Conversion process complete!"
echo "Converted $COUNTER SVG files to TGA format for WoW compatibility."