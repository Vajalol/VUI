#!/bin/bash
# Module verification script for VUI addon
# Checks all modules for proper initialization, theme integration, and version consistency

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Settings
OLD_VERSION="0.3.0"
NEW_VERSION="1.0.0"
MODULE_DIR="modules"

# Counters
MODULES_CHECKED=0
MODULES_NEED_VERSION_UPDATE=0
MODULES_MISSING_INIT=0
MODULES_MISSING_THEME=0
MODULES_WITH_ERRORS=0

echo -e "${BLUE}=== VUI Module Verification ===${NC}"
echo -e "Checking modules in ${MODULE_DIR}/"
echo ""

# Get all module directories
MODULE_DIRS=$(find $MODULE_DIR -maxdepth 1 -mindepth 1 -type d | sort)

# For each module, check:
# 1. If init.lua exists
# 2. If ThemeIntegration.lua exists
# 3. If the version in init.lua is correct
# 4. If the version in ThemeIntegration.lua is correct (if it exists)

for MODULE in $MODULE_DIRS; do
    MODULE_NAME=$(basename $MODULE)
    ((MODULES_CHECKED++))
    
    echo -e "${YELLOW}Checking module:${NC} $MODULE_NAME"
    
    # Check for init.lua
    if [ -f "$MODULE/init.lua" ]; then
        # Check version in init.lua
        if grep -q "Version: $OLD_VERSION" "$MODULE/init.lua"; then
            echo -e "  ${RED}• init.lua has old version ($OLD_VERSION)${NC}"
            ((MODULES_NEED_VERSION_UPDATE++))
        else
            echo -e "  ${GREEN}• init.lua version OK${NC}"
        fi
    else
        echo -e "  ${RED}• Missing init.lua${NC}"
        ((MODULES_MISSING_INIT++))
    fi
    
    # Check for ThemeIntegration.lua
    if [ -f "$MODULE/ThemeIntegration.lua" ]; then
        # Check version in ThemeIntegration.lua
        if grep -q "Version: $OLD_VERSION" "$MODULE/ThemeIntegration.lua"; then
            echo -e "  ${RED}• ThemeIntegration.lua has old version ($OLD_VERSION)${NC}"
            ((MODULES_NEED_VERSION_UPDATE++))
        else
            echo -e "  ${GREEN}• ThemeIntegration.lua version OK${NC}"
        fi
    else
        echo -e "  ${YELLOW}• No ThemeIntegration.lua found${NC}"
        ((MODULES_MISSING_THEME++))
    fi
    
    # Check for OnInitialize or Initialize function
    if [ -f "$MODULE/init.lua" ]; then
        if grep -q -E "function.*OnInitialize|function.*Initialize" "$MODULE/init.lua"; then
            echo -e "  ${GREEN}• Initialization function found${NC}"
        else
            echo -e "  ${RED}• No initialization function found${NC}"
            ((MODULES_WITH_ERRORS++))
        fi
    fi
    
    # Check for ThemeIntegration initialization
    if [ -f "$MODULE/ThemeIntegration.lua" ] && [ -f "$MODULE/init.lua" ]; then
        if grep -q -E "ThemeIntegration.*Initialize|ApplyTheme" "$MODULE/init.lua"; then
            echo -e "  ${GREEN}• Theme integration initialization found${NC}"
        else
            echo -e "  ${RED}• No theme integration initialization found${NC}"
            ((MODULES_WITH_ERRORS++))
        fi
    fi
    
    echo ""
done

# Summary
echo -e "${BLUE}=== Verification Summary ===${NC}"
echo -e "Total modules checked: $MODULES_CHECKED"
echo -e "Modules needing version update: ${YELLOW}$MODULES_NEED_VERSION_UPDATE${NC}"
echo -e "Modules missing init.lua: ${RED}$MODULES_MISSING_INIT${NC}"
echo -e "Modules missing ThemeIntegration.lua: ${YELLOW}$MODULES_MISSING_THEME${NC}"
echo -e "Modules with other issues: ${RED}$MODULES_WITH_ERRORS${NC}"

if [ $MODULES_NEED_VERSION_UPDATE -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}Some modules need version updates. Consider running:${NC}"
    echo 'find modules -name "*.lua" -type f -exec sed -i "s/Version: 0.3.0/Version: 1.0.0/g" {} \;'
fi