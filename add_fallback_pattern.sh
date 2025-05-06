#!/bin/bash
# Script to add fallback pattern to Lua files that need it
# This helps ensure all modules work correctly in test environments

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== VUI Fallback Pattern Installer ===${NC}"
echo "This script adds the VUI fallback pattern to all Lua files that need it."
echo ""

# Define the correct fallback pattern
FALLBACK_PATTERN="if not VUI then VUI = _G.VUI end"

# Counters
TOTAL_FILES=0
UPDATED_FILES=0
ALREADY_FIXED=0

echo -e "${YELLOW}Searching for Lua files...${NC}"
LUA_FILES=$(find . -name "*.lua" -type f | grep -v "/libs/" | sort)

for FILE in $LUA_FILES; do
    ((TOTAL_FILES++))
    
    # Check if the file already has the proper fallback pattern
    if grep -q "$FALLBACK_PATTERN" "$FILE"; then
        echo -e "${GREEN}• Already fixed:${NC} $FILE"
        ((ALREADY_FIXED++))
        continue
    fi
    
    # Check if the file uses VUI at all
    if grep -q "VUI\." "$FILE" || grep -q "local .*, VUI" "$FILE"; then
        # Find the line where VUI is defined
        VUI_LINE=$(grep -n "local .*, VUI" "$FILE" | head -1 | cut -d':' -f1)
        
        if [ -n "$VUI_LINE" ]; then
            # Add the fallback pattern after the line where VUI is defined
            sed -i "${VUI_LINE}a\\-- Fallback for test environments\\if not VUI then VUI = _G.VUI end" "$FILE"
            echo -e "${BLUE}• Updated:${NC} $FILE"
            ((UPDATED_FILES++))
        else
            # If we can't find a "local _, VUI" line, add at the top of the file
            TMP_FILE=$(mktemp)
            echo "-- Get addon environment" > "$TMP_FILE"
            echo "local _, VUI = ..." >> "$TMP_FILE"
            echo "-- Fallback for test environments" >> "$TMP_FILE"
            echo "if not VUI then VUI = _G.VUI end" >> "$TMP_FILE"
            echo "" >> "$TMP_FILE"
            cat "$FILE" >> "$TMP_FILE"
            mv "$TMP_FILE" "$FILE"
            echo -e "${YELLOW}• Added complete header:${NC} $FILE"
            ((UPDATED_FILES++))
        fi
    fi
done

echo ""
echo -e "${BLUE}=== Results ===${NC}"
echo -e "Total Lua files processed: $TOTAL_FILES"
echo -e "Files updated: ${BLUE}$UPDATED_FILES${NC}"
echo -e "Files already fixed: ${GREEN}$ALREADY_FIXED${NC}"

echo ""
echo -e "${GREEN}Process completed!${NC}"
echo "Run the 'find_namespace_issues.sh' script again to verify all issues have been fixed."