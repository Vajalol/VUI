# VUI - UI Scaling System

## Overview

The UI Scaling System is a core accessibility feature that provides flexible control over interface element sizes. It allows players to adjust the size of UI components to suit their screen resolution, visibility needs, and personal preferences, ensuring comfortable gameplay across a wide range of displays and visual abilities.

## Key Features

### 1. Intelligent Resolution Detection

The system automatically detects screen resolution and can apply appropriate scaling based on preset multipliers for common display resolutions.

#### Key Capabilities:
- **Automatic Resolution Detection**: Identifies the player's screen resolution at startup
- **Resolution-Based Scaling**: Applies predetermined scale factors for common resolutions (4K, 1440p, 1080p, etc.)
- **Manual Override**: Allows users to disable automatic scaling and set their own preferences
- **Custom Resolution Multipliers**: Configure specific scale factors for different resolutions

#### Implementation Details:
- Uses WoW's GetPhysicalScreenSize() API for accurate resolution detection
- Maintains a database of optimal scaling values for standard resolutions
- Performs interpolation for non-standard resolutions to provide sensible defaults
- Monitors resolution changes and adjusts scaling automatically

### 2. Element Category-Based Scaling

Different types of UI elements can be scaled independently based on their importance and function.

#### Key Capabilities:
- **Critical Element Scaling**: Special handling for essential UI elements like unit frames and action bars
- **Important Element Scaling**: Dedicated scaling for important but non-critical elements like buffs and minimap
- **Optional Element Scaling**: Separate scaling for supplementary elements like damage meters
- **Decorative Element Scaling**: Independent control over purely visual UI elements

#### Implementation Details:
- Element categorization system with clear classification rules
- Priority-based scaling ensures critical elements remain visible and usable
- Category-specific scaling factors can be individually adjusted
- Elements can be reclassified by modules or users as needed

### 3. Module-Specific Scaling

Individual addon modules can have dedicated scaling controls to fine-tune specific UI components.

#### Key Capabilities:
- **Per-Module Control**: Adjust scaling for each VUI module independently
- **Inheritance Options**: Modules can inherit global scaling or use custom values
- **Granular Adjustments**: Fine-tune specific parts of the interface without affecting others
- **Module Presets**: Quick-apply optimal scaling presets for specific modules

#### Implementation Details:
- Module registration system for scale management
- Coordinates with the VUI module system for consistent scaling
- Provides an API for modules to register their frames and preferences
- Maintains original scale values for proper restoration when disabled

### 4. Text Readability Preservation

Special handling for text elements ensures they remain readable even when UI elements are scaled down.

#### Key Capabilities:
- **Inverse Text Scaling**: Compensates for element scaling to maintain text size
- **Font Enhancement**: Optimizes fonts for readability at different scales
- **Minimum Text Size**: Enforces minimum text sizes to prevent illegibility
- **Region-Specific Handling**: Different handling for headers, body text, and numeric displays

#### Implementation Details:
- Recursive font string processing for nested elements
- Original font size tracking for accurate restoration
- Smart font adjustments that consider the element's purpose
- Specialized handling for different font regions (headers, tooltips, etc.)

### 5. Frame Strata Awareness

UI elements at different frame strata levels can receive subtle scaling adjustments to enhance usability.

#### Key Capabilities:
- **Strata-Based Scaling**: Slightly larger scaling for higher strata (dialog, tooltip) elements
- **Focus Enhancement**: Makes interactive elements more prominent through scaling
- **Visual Hierarchy**: Reinforces UI hierarchy through subtle size differences
- **Toggle Option**: Can be enabled or disabled based on preference

#### Implementation Details:
- Defines specific scale adjustments for each frame strata level
- Combines with category-based scaling for precise control
- Updates dynamically when strata changes
- Provides subtle visual cues about element importance

### 6. Profile Management

Comprehensive profile system for saving, loading, and sharing UI scaling configurations.

#### Key Capabilities:
- **Named Profiles**: Save complete sets of scaling settings
- **Quick Switching**: Easily switch between different scaling configurations
- **Per-Character Settings**: Optional character-specific scaling profiles
- **Import/Export**: Share scaling profiles between characters or players

#### Implementation Details:
- Complete profile storage including all scaling settings
- Profile metadata with name, description, and intended use
- Database integration for persistent storage
- Validation to prevent loading invalid profiles

## Integration with VUI Modules

The UI Scaling system integrates with all VUI modules to ensure consistent scaling behavior:

- **UnitFrames**: Optimized scaling for player, target, and party frames
- **ActionBars**: Special handling for button scaling with icon clarity preservation
- **MultiNotification**: Scaling that maintains notification visibility and readability
- **BuffOverlay**: Buff icon scaling with size-appropriate text elements
- **DetailsSkin**: Damage meter scaling with improved graph readability

## Performance Considerations

The UI Scaling system is designed for minimal performance impact:

- Scales are applied efficiently using native WoW API functions
- Text scaling is batched and throttled to prevent performance spikes
- Resolution detection occurs only when needed (startup, resolution changes)
- Scale calculations are cached to reduce redundant operations
- Frame updates are staggered to distribute processing load

## Configuration

All UI scaling features can be configured through the VUI settings panel under the "UI Scaling" tab. The configuration options are organized into logical sections:

1. **General Settings**: Global scale control and automatic resolution adjustment
2. **Element Categories**: Scaling factors for different types of UI elements
3. **Module-Specific Scaling**: Individual control over each VUI module
4. **Resolution Settings**: Custom scaling factors for different screen resolutions
5. **Profiles**: Save, load, and manage scaling profiles

## Accessibility Benefits

The UI Scaling system provides significant accessibility advantages:

- **Visual Impairment Support**: Larger UI elements for users with visual impairments
- **High-Resolution Display Optimization**: Prevents tiny UI on high-DPI displays
- **Small-Screen Accommodation**: Efficient space usage on smaller displays
- **Readability Focus**: Ensures text remains legible regardless of scaling
- **Personalization**: Allows fine-tuning to individual visual needs

## Developer API

Addon developers can integrate with the UI Scaling system using these key functions:

```lua
-- Register an element for scaling with a specific category
local elementID = VUI.UIScaling:RegisterElement(frame, category, options)

-- Unregister an element when no longer needed
VUI.UIScaling:UnregisterElement(elementID)

-- Get element category constants
local CATEGORIES = VUI.UIScaling:GetElementCategories()

-- Register for scaling change notifications
VUI:RegisterModuleFunction(self, "OnUIScalingChanged", self.UpdateScaling)
```

## Implementation Example

To make module frames work properly with UI scaling:

```lua
function MyModule:Initialize()
    -- Create frames
    self.frame = CreateFrame("Frame", "VUIMyModuleFrame", UIParent)
    
    -- Register with UI Scaling system
    local CATEGORIES = VUI.UIScaling:GetElementCategories()
    VUI.UIScaling:RegisterElement(self.frame, CATEGORIES.IMPORTANT, {hasText = true})
    
    -- Register for scaling change notifications
    VUI:RegisterModuleFunction(self, "OnUIScalingChanged", self.UpdateLayout)
end

function MyModule:UpdateLayout(enabled, scale)
    -- Respond to scaling changes
    if enabled then
        -- Make any necessary layout adjustments
        self:RefreshAllElements()
    end
end
```

## Future Enhancements

Planned improvements to the UI Scaling system:

1. **Dynamic Context Scaling**: Automatically adjust scaling based on gameplay context (combat, cities, raids)
2. **Scaling Templates**: Pre-configured scaling templates for different gameplay styles
3. **Component-Level Control**: Finer-grained control over sub-components within modules
4. **Layout Adaptation**: Smart layout adjustments based on scaling changes
5. **Visual Preview**: Real-time preview of scaling changes before applying