# VUI Developer Guide

## Introduction
This guide is for developers interested in creating modules for VUI or extending the functionality of existing modules. VUI provides a robust framework for creating consistent, performance-optimized UI elements for World of Warcraft.

## Module Structure

### Basic Module Template
```lua
local addonName, VUI = ...

-- Create your module
VUI.MyModule = VUI:NewModule("MyModule")

-- Initialize module
function VUI.MyModule:OnInitialize()
    -- Set default configuration
    self.defaults = {
        profile = {
            enabled = true,
            -- module-specific settings
        }
    }
    
    -- Register with core
    VUI:RegisterModule("MyModule", self.defaults)
    
    -- Set up config panel
    self:CreateConfigPanel()
    
    -- Initialize theme integration
    if self.ThemeIntegration then
        self.ThemeIntegration:Initialize()
    end
    
    VUI:Print("MyModule initialized")
end

-- Enable module
function VUI.MyModule:OnEnable()
    -- Register events
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnPlayerEnteringWorld")
    
    -- Create frames and UI elements
    self:CreateFrames()
    
    VUI:Print("MyModule enabled")
end

-- Disable module
function VUI.MyModule:OnDisable()
    -- Unregister events
    self:UnregisterAllEvents()
    
    -- Hide frames
    if self.frame then
        self.frame:Hide()
    end
    
    VUI:Print("MyModule disabled")
end

-- Create module config panel
function VUI.MyModule:CreateConfigPanel()
    local options = {
        name = "My Module",
        type = "group",
        args = {
            enabled = {
                name = "Enable My Module",
                desc = "Enable or disable this module",
                type = "toggle",
                width = "full",
                order = 1,
                get = function() return VUI.db.profile.myModule.enabled end,
                set = function(_, value) 
                    VUI.db.profile.myModule.enabled = value
                    if value then
                        self:OnEnable()
                    else
                        self:OnDisable()
                    end
                end
            },
            -- More settings here
        }
    }
    
    -- Register with VUI's config system
    VUI.ModuleAPI:RegisterModuleConfig("myModule", options)
end

-- Create UI elements
function VUI.MyModule:CreateFrames()
    -- Create main frame
    self.frame = CreateFrame("Frame", "VUIMyModuleFrame", UIParent)
    self.frame:SetSize(200, 100)
    self.frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    
    -- Apply theme
    self:ApplyTheme(VUI.db.profile.theme)
end

-- Apply theme changes
function VUI.MyModule:ApplyTheme(theme)
    local colors = VUI.media.themes[theme]
    if not colors then return end
    
    if self.frame then
        -- Apply theme colors
        self.frame:SetBackdropColor(colors.background.r, colors.background.g, colors.background.b, 0.8)
        self.frame:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, 1)
    end
end

-- Event handlers
function VUI.MyModule:OnPlayerEnteringWorld()
    -- Update module on player entering world
end

-- Register with VUI initialization
VUI:RegisterCallback("OnInitialized", function()
    VUI.MyModule:OnInitialize()
end)

-- Register for theme changes
VUI:RegisterCallback("ThemeChanged", function(newTheme)
    VUI.MyModule:ApplyTheme(newTheme)
end)
```

### Module Directory Structure
```
modules/
  mymodule/
    init.lua               # Main module initialization
    core.lua               # Core functionality
    ThemeIntegration.lua   # Theme support
    config.lua             # Configuration options
    frames.lua             # UI elements 
    index.xml              # XML file inclusion
```

## Best Practices

### Performance Optimization
VUI includes several performance optimization systems that your module should utilize:

#### 1. Texture Atlas
```lua
-- Accessing the texture atlas
local atlasCoords = VUI.TextureAtlas:GetCoordinates("mymodule", "icon_name")
myTexture:SetTexCoord(atlasCoords.left, atlasCoords.right, atlasCoords.top, atlasCoords.bottom)

-- Registering with the texture atlas system
VUI.TextureAtlas:RegisterTexture("mymodule", "icon_name", "path/to/texture.tga", {
    left = 0, right = 0.5, top = 0, bottom = 0.5
})
```

#### 2. Frame Pooling
```lua
-- Create a pool for your frames
self.iconPool = VUI.FramePool:New("Button", self.frame, "VUIMyModuleIconTemplate")

-- Acquire a frame from the pool
local icon = self.iconPool:Acquire()
icon:Show()

-- Release a frame back to the pool when done
self.iconPool:Release(icon)
```

#### 3. Event Optimization
```lua
-- Register for events with throttling
VUI.EventManager:RegisterThrottled(self, "UNIT_AURA", 0.1, function(unit)
    if unit and UnitIsUnit(unit, "player") then
        self:UpdateAuras()
    end
end)
```

#### 4. Database Access Optimization
```lua
-- Cache frequently accessed settings
local function Initialize()
    -- Cache settings on initialization
    self.cachedSetting = VUI.db.profile.myModule.setting
    
    -- Add database watcher for this setting
    VUI.db:RegisterWatcher("profile.myModule.setting", function(newValue)
        self.cachedSetting = newValue
        self:UpdateUI()
    end)
end

-- Use cached value instead of frequent database access
function SomeFrequentFunction()
    if self.cachedSetting then
        -- Use cached value
    end
end
```

### Theme Integration
To ensure your module works with all VUI themes:

```lua
-- Create a ThemeIntegration.lua file with:
local addonName, VUI = ...
if not VUI.modules then VUI.modules = {} end
if not VUI.modules.myModule then VUI.modules.myModule = {} end

local ThemeIntegration = {}
VUI.modules.myModule.ThemeIntegration = ThemeIntegration

function ThemeIntegration:Initialize()
    -- Register for theme changes
    VUI:RegisterCallback("ThemeChanged", function(theme)
        self:ApplyTheme(theme)
    end)
end

function ThemeIntegration:ApplyTheme(theme)
    local module = VUI.modules.myModule
    if not module.frame then return end
    
    local colors = VUI.media.themes[theme] or {}
    
    -- Apply theme colors to main frame
    module.frame:SetBackdrop({
        bgFile = "Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. theme .. "\\background.tga",
        edgeFile = "Interface\\AddOns\\VUI\\media\\textures\\common\\border-simple.tga",
        tile = false,
        tileSize = 0,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    
    -- Apply colors
    module.frame:SetBackdropColor(colors.background.r, colors.background.g, colors.background.b, 0.8)
    module.frame:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, 1)
    
    -- Other theme-specific changes
end
```

## Module API Reference

### Core Module Functions
- `VUI:NewModule(name)` - Creates a new module
- `VUI:RegisterModule(name, defaults)` - Registers a module with the core
- `VUI:Print(message)` - Prints a message to chat with VUI prefix
- `VUI:RegisterCallback(event, callback)` - Register for VUI events
- `VUI:TriggerCallback(event, ...)` - Trigger a callback event

### Database Access
- `VUI.db.profile.moduleName.setting` - Access module settings
- `VUI.db:RegisterWatcher(path, callback)` - Watch for changes in settings

### Theme System
- `VUI.media.themes[themeName]` - Access theme colors
- `VUI.media.fonts[fontName]` - Access themed fonts
- `VUI.media.textures[textureName]` - Access textures

### Performance Tools
- `VUI.TextureAtlas` - Texture atlas system
- `VUI.FramePool` - Frame pooling system
- `VUI.EventManager` - Event handling optimization
- `VUI.PerformanceMonitor` - Performance tracking

### Animation
- `VUI.UI.Animation:FadeIn(frame, duration, targetAlpha)` - Fade in animation
- `VUI.UI.Animation:FadeOut(frame, duration, callback)` - Fade out animation
- `VUI.UI.Animation:Scale(frame, startScale, endScale, duration)` - Scale animation
- `VUI.UI.Animation:Slide(frame, startOffset, endOffset, duration)` - Slide animation
- `VUI.UI.Animation:Flash(frame, duration, count)` - Flash effect
- `VUI.UI.Animation:Glow(frame, color, duration)` - Glow effect
- `VUI.UI.Animation:Bounce(frame, height, duration)` - Bounce effect

## Module Integration Checklist

When developing a module for VUI, ensure you:

1. **Follow naming conventions**
   - Use PascalCase for module names (MyModule)
   - Use camelCase for variables and functions (myFunction)
   - Prefix frames with VUI (VUIMyModuleFrame)

2. **Implement standard methods**
   - OnInitialize
   - OnEnable
   - OnDisable
   - CreateConfigPanel
   - ApplyTheme

3. **Optimize performance**
   - Use texture atlas system
   - Implement frame pooling
   - Cache database values
   - Throttle event processing

4. **Support all themes**
   - Create ThemeIntegration.lua
   - Apply theme colors to all elements
   - Support dynamic theme switching

5. **Document your code**
   - Add comments for complex functions
   - Document all public APIs
   - Include examples where appropriate

6. **Test with multiple resolutions**
   - Ensure UI scales properly
   - Verify appearance on different screen sizes

## Debugging and Testing

### Debug Mode
Enable debug mode in the VUI settings to get additional information:

```lua
if VUI.debug then
    VUI:Print("Debug: " .. someValue)
end
```

### Performance Testing
Use the VUI performance tools to monitor your module's impact:

```lua
-- Start tracking
local tracker = VUI.PerformanceMonitor:StartTracking("MyModule:Function")

-- Your code here

-- End tracking
tracker:Stop()
```

### Testing Themes
Test your module with all five VUI themes to ensure proper appearance:

```lua
function TestAllThemes()
    local themes = {"phoenix", "thunderstorm", "arcane", "fel", "class"}
    for _, theme in ipairs(themes) do
        VUI:Print("Testing theme: " .. theme)
        VUI.modules.myModule.ThemeIntegration:ApplyTheme(theme)
        -- Wait for visual inspection
    end
end
```

## Contributing to VUI
If you've developed a module that you believe should be included in the core VUI package:

1. Ensure your code follows all VUI standards and best practices
2. Create comprehensive documentation
3. Test thoroughly with all themes and various configurations
4. Submit your module for review

## Example Modules
For inspiration and examples, review these core VUI modules:

- `modules/buffoverlay/` - For buff/debuff tracking
- `modules/multinotification/` - For notification systems
- `modules/detailsskin/` - For styling external addons

## Conclusion
By following these guidelines, you can create modules that integrate seamlessly with VUI, maintain consistent visual styling, and perform optimally even in demanding situations like raids and battlegrounds.