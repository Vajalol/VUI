# VUI Module Testing Guide

This document describes the approach to testing and validating VUI modules, ensuring compatibility across different environments.

## Overview

VUI modules need to work correctly in both the World of Warcraft game environment and in testing environments. To ensure this, we've implemented a consistent pattern across all module files and created specialized testing tools.

## The Environment Fallback Pattern

All module files should use the following pattern at the top of the file to ensure they work in both game and testing environments:

```lua
-- Get addon environment
local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end

-- Rest of module code...
```

This pattern allows modules to:
1. Get the addon object normally in the game environment
2. Fall back to a global VUI object in testing environments (like our test_modules.lua)

## Testing Tools

### test_modules.lua

This is our main testing script that:
- Creates a mock WoW API environment
- Sets up a global VUI object with essential components
- Loads and tests module files individually
- Reports success or failures

To run the test:
```bash
lua test_modules.lua
```

This will show:
- If modules load correctly
- If namespaces are properly initialized
- If required functions exist

### find_namespace_issues.sh

This utility script helps identify modules that need the fallback pattern added:

```bash
./find_namespace_issues.sh
```

It searches all Lua files in the project for:
- Files that use VUI but don't have the fallback pattern
- Provides a detailed report of which files need updating

### add_fallback_pattern.sh

This utility script automatically adds the fallback pattern to all files that need it:

```bash
./add_fallback_pattern.sh
```

It will:
- Find files that need the fallback pattern
- Add the pattern after the VUI definition line
- Add a complete header if necessary
- Report how many files were updated

## Module Structure Best Practices

1. **Consistent Namespace Initialization**: 
   Each module should create its namespaces if they don't exist:
   ```lua
   if not VUI.ModuleName then
       VUI.ModuleName = {}
   end
   ```

2. **Local References**:
   Create local references for better performance and easier coding:
   ```lua
   local ModuleName = VUI.ModuleName
   ```

3. **Namespace Consistency**:
   Use consistent naming across all files (e.g., BuffOverlay vs buffoverlay)

4. **Error Handling**:
   Always check if objects exist before accessing their methods, using patterns like:
   ```lua
   if self.ThemeIntegration and self.ThemeIntegration.Initialize then
       self.ThemeIntegration:Initialize()
   end
   ```

## Integration With Workflows

The test_modules.lua script is integrated into the WoW Addon Validation workflow, providing automated testing with every change:

```bash
luac -p core/*.lua modules/*/*.lua && echo "Lua syntax validation passed!" && lua test_modules.lua
```

This workflow:
1. Validates Lua syntax with luac
2. Runs the module tests
3. Reports success or failure

## Development Workflow

When working on VUI, follow this workflow:

1. Make changes to modules
2. Run `find_namespace_issues.sh` to check for missing fallback patterns
3. Run `add_fallback_pattern.sh` if needed to fix fallback patterns
4. Run the validation workflow to ensure all tests pass
5. Create a release package with `./create_release_package.sh`

## Future Improvements

- Add specific tests for each module's functionality
- Expand mock API to test more complex interactions
- Add performance benchmarking