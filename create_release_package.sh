#!/bin/bash
# VUI Release Packaging Script
# This script creates a clean release package for distribution

# Configuration
VERSION="1.0.0"
RELEASE_NAME="VUI-${VERSION}"
TEMP_DIR="release_temp"
RELEASE_DIR="release"

# Colors for pretty output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Creating release package for VUI v${VERSION}...${NC}"

# Create directories if they don't exist
mkdir -p $RELEASE_DIR
mkdir -p $TEMP_DIR

# Clean any previous temp files
rm -rf "${TEMP_DIR}/*"

echo -e "${GREEN}Step 1:${NC} Copying addon files to temporary directory..."

# First copy all files
cp -r core $TEMP_DIR/
cp -r docs $TEMP_DIR/
cp -r libs $TEMP_DIR/
cp -r media $TEMP_DIR/
cp -r modules $TEMP_DIR/
cp init.lua $TEMP_DIR/
cp VUI.toc $TEMP_DIR/
cp README.md $TEMP_DIR/
cp CHANGES.md $TEMP_DIR/
cp RELEASE_NOTES_v1.0.0.md $TEMP_DIR/
cp VUI_Verification_Report.md $TEMP_DIR/
cp ROADMAP.md $TEMP_DIR/
cp generated-icon.png $TEMP_DIR/
cp LICENSE $TEMP_DIR/

echo -e "${GREEN}Step 2:${NC} Removing development and debug files..."

# Remove debug and development files
find $TEMP_DIR -name "*_debug.lua" -delete
# Keep test_modules.lua but remove other test files
find $TEMP_DIR -name "test_*.lua" ! -name "test_modules.lua" -delete
find $TEMP_DIR -name "*.bak" -delete
find $TEMP_DIR -name "*.ds_store" -delete -ignore_readdir_race

# Copy test_modules.lua to release package for developer use
cp test_modules.lua $TEMP_DIR/

# Remove any .git related files that might have been copied
find $TEMP_DIR -name ".git*" -delete -ignore_readdir_race

echo -e "${GREEN}Step 3:${NC} Creating release package..."

# Create release zip file
cd $TEMP_DIR
zip -r "../${RELEASE_DIR}/${RELEASE_NAME}.zip" *
cd ..

# Calculate size
SIZE=$(du -sh "${RELEASE_DIR}/${RELEASE_NAME}.zip" | cut -f1)

echo -e "${GREEN}Step 4:${NC} Cleaning up temporary files..."
rm -rf $TEMP_DIR

echo -e "${YELLOW}Release package created successfully!${NC}"
echo -e "Version: ${VERSION}"
echo -e "Package: ${RELEASE_DIR}/${RELEASE_NAME}.zip"
echo -e "Size: ${SIZE}"
echo -e "\nThe release package is ready for distribution."