#!/bin/bash

# Check if required tools are installed
command -v convert >/dev/null 2>&1 || { echo "ImageMagick is required but not installed. Aborting."; exit 1; }

# Convert SVG files to TGA format
for theme in phoenixflame thunderstorm arcanemystic felenergy; do
  # Create directory if it doesn't exist
  mkdir -p media/textures/$theme/auctionator
  
  # Convert SVG to TGA
  svg_file="media/textures/$theme/auctionator/Logo.svg"
  tga_file="media/textures/$theme/auctionator/Logo.tga"
  
  if [ -f "$svg_file" ]; then
    echo "Converting $svg_file to $tga_file"
    convert -background transparent "$svg_file" "$tga_file"
    echo "Conversion completed: $tga_file"
  else
    echo "File not found: $svg_file"
  fi
done

echo "All conversions completed!"