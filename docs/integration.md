# VUI Integration System

This document explains how the various components of the VUI addon suite connect and work together.

## Overview

VUI consists of several key systems:

1. **Core Framework** - The foundation of the addon
2. **UI Framework** - Tools for creating UI elements
3. **Widgets** - Advanced UI components
4. **Media System** - Handles textures, fonts, sounds, and themes
5. **Module API** - Simplifies module creation and integration
6. **Integration Layer** - Ensures all systems work together

## System Connections

The following diagram shows how the systems connect:

```
   +--------------+     +--------------+     +--------------+
   | Core         |     | UI Framework |     | Media System |
   | Framework    |<--->|              |<--->|              |
   |              |     |              |     |              |
   +--------------+     +--------------+     +--------------+
          ^                    ^                    ^
          |                    |                    |
          v                    v                    v
   +--------------+     +--------------+     +--------------+
   | Module API   |     | Widgets      |     | Integration  |
   |              |<--->|              |<--->| Layer        |
   |              |     |              |     |              |
   +--------------+     +--------------+     +--------------+
          ^                                         ^
          |                                         |
          v                                         v
   +-------------------------------------------------------+
   |                     Modules                           |
   | (BuffOverlay, TrufiGCD, MoveAny, OmniCD, etc.)       |
   |                                                       |
   +-------------------------------------------------------+
```

## Integration Process

### Initialization Sequence

1. When the addon loads, `init.lua` initializes the core framework
2. The UI and Media systems are initialized
3. The Integration Layer connects these systems
4. Modules are registered and initialized
5. Module UI is created when needed, using the frameworks

### Module Registration

When a module is registered with `VUI:RegisterModule()`, it automatically:

1. Gets extended with the Module Template to ensure consistent behavior
2. Gets connected to the UI Framework, Widget system, and Media system
3. Gets added to the configuration system

### Framework Access

Modules can access the frameworks in the following ways:

1. Through direct properties (after connection):
   - `module.UI` - Access to UI Framework
   - `module.Widgets` - Access to Widget Framework
   - `module.media` - Access to Media System

2. Through helper methods:
   - `module:CreateFrame()` - Creates a frame using the UI Framework
   - `module:CreateButton()` - Creates a button using the UI Framework
   - `module:CreateProgressBar()` - Creates a progress bar using the Widgets Framework

### Theme System

The theme system provides consistent appearance:

1. VUI has multiple themes: dark, light, classic, minimal
2. Themes include colors, borders, textures, and fonts
3. When a theme is selected, all UI elements are updated
4. Modules can hook into theme changes through the `ApplyTheme()` method

## Creating a Module

### Basic Module Creation

The simplest way to create a module is using the Module API:

```lua
-- In your module's init.lua
local Example = VUI.ModuleAPI:CreateModule("example")

-- Set up module defaults
local defaults = {
    enabled = true,
    -- Other settings
}

-- Initialize module settings
Example.settings = VUI.ModuleAPI:InitializeModuleSettings("example", defaults)

-- Register module configuration
VUI.ModuleAPI:RegisterModuleConfig("example", config)

-- Register slash command
VUI.ModuleAPI:RegisterModuleSlashCommand("example", "examplecmd", handler)

-- Initialize module
function Example:Initialize()
    -- Setup code
end

-- Enable module when needed
function Example:Enable()
    self.enabled = true
end

-- Disable module when needed
function Example:Disable()
    self.enabled = false
end
```

### Creating UI Elements

When creating UI elements, use the framework methods:

```lua
-- Create a frame
self.frame = self:CreateFrame("MyFrame", UIParent)

-- Create a button
self.button = self:CreateButton("MyButton", self.frame, "Click Me")

-- Create a progress bar widget
self.progressBar = self:CreateProgressBar("MyBar", self.frame, width, height, "Progress:")
```

## Testing Integration

The integration test utility (`/vuitest` command) checks if all systems are properly connected. It verifies:

1. Core components exist and function
2. Frameworks are loaded and accessible
3. Modules are properly registered
4. Cross-system connections are working

## Example Module

The Example module in `modules/example` demonstrates a complete implementation that follows all integration best practices. Use it as a reference when creating new modules.

## Troubleshooting

If you encounter integration issues:

1. Run `/vuitest` to diagnose connectivity problems
2. Check if the module is properly registered with `VUI:RegisterModule()`
3. Verify that UI elements are created using the framework methods
4. Ensure the module has the required connection methods
5. Check if theme updates are properly applied to UI elements