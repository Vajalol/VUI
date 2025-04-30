# VUI Module Standardization Guide

## Overview

This document defines the standards and best practices for creating modules within the VUI addon system. Following these guidelines ensures all modules are consistent, maintainable, and fully integrated with the core systems.

## Module Structure

### File Organization

Modules should follow this file structure:

```
modules/
  modulename/
    index.xml       # Main XML file that loads all module files in the correct order
    init.lua        # Module initialization and registration
    config.lua      # Module configuration options
    core.lua        # Main module functionality
    [optional files]  # Additional functionality as needed
```

### Module Initialization

Each module should be created using the standardized template pattern:

```lua
-- Module initialization in init.lua
local addonName, VUI = ...

-- Create module using template
local ModuleName = VUI.ModuleTemplate:CreateNewModule("ModuleName", {
    description = "Description of what the module does",
    version = "1.0.0",
    author = "Your Name",
    category = "UI" -- Core, UI, Visuals, Tools, Addons, etc.
})

-- Add to VUI table
VUI.ModuleName = ModuleName

-- Hook initialization
if VUI.HookInitialize then
    VUI:HookInitialize(function()
        ModuleName:Initialize()
    end)
end
```

### Required Methods

All modules must implement these methods:

1. **Initialize()** - Sets up the module, registers events, creates frames, etc.
2. **Enable()** - Enables module functionality (called automatically if enabled in settings)
3. **Disable()** - Disables module functionality
4. **ApplyTheme(theme)** - Applies theme settings to the module

### Standard Methods

These methods are provided by the template system:

1. **RegisterEvents(events)** - Register for game events
2. **UnregisterEvents(events)** - Unregister from game events
3. **RegisterCallback(event, callback)** - Register for VUI internal events
4. **UnregisterCallback(event)** - Unregister from VUI internal events
5. **CreateConfig()** - Generate configuration options
6. **RegisterConfig()** - Register configuration with options panel
7. **RegisterSlashCommand(command, handler, help)** - Register a slash command
8. **Hook(object, method, hook, secure)** - Hook into a function
9. **Unhook(object, method)** - Remove a hook
10. **Log(level, ...)** - Log a message with appropriate level
11. **Debug(...)** - Log a debug message (only shown when debug mode is enabled)
12. **GetModuleInfo()** - Get module metadata from registry

## Configuration Standards

### Default Options

Each module should define its default settings in a standardized way:

```lua
-- In config.lua
local moduleName = "ModuleName"
local lowerName = moduleName:lower()

-- Generate module configuration
local moduleConfig = VUI.ModuleConfigTemplate:GenerateDefaultConfig(moduleName, {
    displayName = "Friendly Module Name",
    description = "Detailed description of what this module does",
    showScale = true,       -- Include scale slider
    showTheme = true,       -- Include theme dropdown
    showResetPositions = true,  -- Include reset positions button
    showResetSettings = true,   -- Include reset settings button
    defaults = {
        enabled = true,
        theme = "thunderstorm",
        scale = 1.0,
        settings = {
            -- Module-specific settings with defaults
            opacity = 0.8,
            fontSize = 12,
            showIcon = true
        }
    },
    settings = {
        -- Custom settings controls
        opacity = {
            order = 1,
            type = "range",
            name = "Opacity",
            min = 0,
            max = 1,
            step = 0.01,
            get = function() return VUI.db.profile.modules[lowerName].settings.opacity or 0.8 end,
            set = function(_, value) 
                VUI.db.profile.modules[lowerName].settings.opacity = value
                if VUI[moduleName].UpdateOpacity then
                    VUI[moduleName]:UpdateOpacity()
                end
            end
        }
    }
})

-- Add to options panel
if VUI.options and VUI.options.args then
    VUI.options.args[moduleName] = moduleConfig
end
```

### Accessing Settings

Use this pattern to access module settings:

```lua
-- Access module settings
local settings = VUI.db.profile.modules[self.name:lower()]

-- Use settings with defaults
local opacity = settings.settings.opacity or 0.8
local scale = settings.scale or 1.0
```

## Theming System

### Theme Integration

Modules should support the VUI theming system:

```lua
function Module:ApplyTheme(themeName)
    local theme = themeName or VUI.db.profile.theme or "thunderstorm"
    
    -- Get theme colors
    local colors = VUI.media.themes[theme]
    
    -- Apply colors to module elements
    self.frame:SetBackdropColor(colors.background.r, colors.background.g, colors.background.b, colors.background.a)
    self.frame:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, colors.border.a)
    
    -- Update any other themed elements
    -- ...
end
```

### Theme Colors

Standard theme colors include:

- `background` - Main background color
- `border` - Border color
- `text` - Normal text color
- `highlight` - Highlight color
- `accent` - Accent color

## Integration with Core Systems

### Module Registry

Modules are automatically registered with the central Module Registry, which provides:

- Dependency tracking
- Conflict detection
- Metadata storage
- Module listings in dashboards

### Event System

Use the standard event registration:

```lua
-- Register for game events
self:RegisterEvents({"PLAYER_ENTERING_WORLD", "UNIT_SPELLCAST_SUCCEEDED"})

-- Handle events with methods named after the event
function Module:PLAYER_ENTERING_WORLD()
    -- Handle event
end

function Module:UNIT_SPELLCAST_SUCCEEDED(unit, lineID, spellID)
    -- Handle event with parameters
end
```

### Callback System

Use callbacks for VUI internal events:

```lua
-- Register for internal events
self:RegisterCallback("ThemeChanged", "UpdateTheme")
self:RegisterCallback("ProfileChanged", function()
    -- Handle profile change
end)
```

## Best Practices

### Performance

1. Avoid creating frames or registering events in initialization if the module is disabled
2. Use event filtering where possible
3. Throttle frequent update functions
4. Use local variables for frequently accessed values

### Maintainability

1. Add comments to explain complex functionality
2. Use descriptive variable and function names
3. Group related functionality into separate files
4. Follow consistent indentation and naming conventions

### Integration

1. Use the theme system rather than hardcoding colors
2. Use callbacks to respond to system-wide changes
3. Store user settings in the standard location
4. Respect user settings for enabled/disabled state

## Validation

Use the Module Standardizer to validate and fix common issues:

```lua
/vui standardize ModuleName   -- Standardize a specific module
/vui standardize              -- Standardize all modules
```

## Upgrading Existing Modules

To upgrade existing modules to the new standard:

1. Convert module to use the ModuleTemplate
2. Update configuration to use ModuleConfigTemplate
3. Ensure all required methods are implemented
4. Add theme support
5. Run the standardizer to fix any remaining issues

## Examples

See the following modules for reference implementations:

- `modules/buffoverlay/` - Visual enhancement module
- `modules/actionbars/` - UI element module
- `modules/profiles/` - Tool module
- `modules/auctionator/` - Embedded addon module