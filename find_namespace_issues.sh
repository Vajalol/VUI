#!/bin/bash
# Script to find modules with namespace initialization issues
# This helps identify modules that need fallback patterns added

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== VUI Namespace Initialization Checker ===${NC}"
echo "This script identifies files that may need the VUI fallback pattern."
echo ""

# Define the correct fallback pattern to look for
FALLBACK_PATTERN="if not VUI then VUI = _G.VUI end"

# Search all Lua files in the project
TOTAL_FILES=0
MISSING_FALLBACK=0
FOUND_FILES=()

echo -e "${YELLOW}Searching for Lua files...${NC}"
LUA_FILES=$(find . -name "*.lua" -type f | grep -v "/libs/" | sort)

for FILE in $LUA_FILES; do
    ((TOTAL_FILES++))
    
    # Check if the file has the proper fallback pattern
    if ! grep -q "$FALLBACK_PATTERN" "$FILE"; then
        # Additional check - does it use VUI at all?
        if grep -q "VUI\." "$FILE" || grep -q "local .*, VUI" "$FILE"; then
            echo -e "${RED}• Missing fallback:${NC} $FILE"
            FOUND_FILES+=("$FILE")
            ((MISSING_FALLBACK++))
        fi
    fi
done

echo ""
echo -e "${BLUE}=== Results ===${NC}"
echo -e "Total Lua files checked: $TOTAL_FILES"
echo -e "Files missing fallback pattern: ${RED}$MISSING_FALLBACK${NC}"

if [ $MISSING_FALLBACK -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}Recommendation:${NC}"
    echo "Add the following pattern after the 'local _, VUI = ...' line in each file:"
    echo 'if not VUI then VUI = _G.VUI end'
    
    echo ""
    echo -e "${YELLOW}Example command to fix a specific file:${NC}"
    echo 'sed -i "/local _, VUI = .../a if not VUI then VUI = _G.VUI end" filename.lua'
    
    echo ""
    echo -e "${YELLOW}Files to fix:${NC}"
    for FILE in "${FOUND_FILES[@]}"; do
        echo "$FILE"
    done
else
    echo -e "${GREEN}All files have proper fallback patterns!${NC}"
fi