# VUI Module Integration Guide

This guide provides step-by-step instructions for integrating a new module into the VUI addon suite.

## Prerequisites

Before starting the integration process, you should:

1. Understand the basic structure of World of Warcraft addons
2. Have your module code ready (or have the existing addon you want to integrate)
3. Review the VUI integration.md documentation

## Directory Structure

Create the following directory structure for your module:

```
modules/
└── yourmodule/
    ├── init.lua     - Initialization and module registration
    ├── core.lua     - Main functionality 
    └── config.lua   - Configuration panel (optional)
```

## Step 1: Create init.lua

This file initializes your module and registers it with VUI:

```lua
-- VUI YourModule - Initialization
local _, VUI = ...

-- Create the module using the module API
local YourModule = VUI.ModuleAPI:CreateModule("yourmodule")

-- Set up module defaults
local defaults = {
    enabled = true,
    -- Add your module-specific settings here
}

-- Initialize module settings
YourModule.settings = VUI.ModuleAPI:InitializeModuleSettings("yourmodule", defaults)

-- Register module configuration
local config = {
    type = "group",
    name = "Your Module",
    desc = "Configuration for Your Module",
    args = {
        enable = {
            type = "toggle",
            name = "Enable",
            desc = "Enable or disable Your Module",
            order = 1,
            get = function() return VUI:IsModuleEnabled("yourmodule") end,
            set = function(_, value)
                if value then
                    VUI:EnableModule("yourmodule")
                else
                    VUI:DisableModule("yourmodule")
                end
            end,
        },
        -- Add your module-specific configuration options here
    }
}

-- Register module config
VUI.ModuleAPI:RegisterModuleConfig("yourmodule", config)

-- Register slash command (optional)
VUI.ModuleAPI:RegisterModuleSlashCommand("yourmodule", "yourslashcmd", function(input)
    -- Handle slash command
end)

-- Initialize module
function YourModule:Initialize()
    -- Your initialization code here
    
    -- Register for UI integration when the UI is loaded
    VUI.ModuleAPI:EnableModuleUI("yourmodule", function(module)
        module:CreateUI()
    end)
end

-- Enable module
function YourModule:Enable()
    self.enabled = true
    -- Your enabling code here
end

-- Disable module
function YourModule:Disable()
    self.enabled = false
    -- Your disabling code here
end

-- Register the module with VUI
VUI.yourmodule = YourModule
```

## Step 2: Create core.lua

This file contains the main functionality of your module:

```lua
-- VUI YourModule - Core Functionality
local _, VUI = ...
local YourModule = VUI.yourmodule

-- Create the main UI
function YourModule:CreateUI()
    -- Skip if frame already exists
    if self.frame then 
        return self.frame 
    end
    
    -- Create main frame using VUI UI framework
    self.frame = self:CreateFrame("VUIYourModuleFrame", UIParent)
    self.frame:SetSize(300, 200)
    
    -- Use stored position if available
    if self.settings.position then
        local pos = self.settings.position
        self.frame:SetPoint(pos[1], UIParent, pos[1], pos[2], pos[3])
    else
        self.frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
    
    -- Make frame movable
    self.frame:SetMovable(true)
    self.frame:EnableMouse(true)
    self.frame:RegisterForDrag("LeftButton")
    self.frame:SetScript("OnDragStart", self.frame.StartMoving)
    self.frame:SetScript("OnDragStop", function(frame)
        frame:StopMovingOrSizing()
        
        -- Save new position
        local point, _, _, xOfs, yOfs = frame:GetPoint()
        self.settings.position = {point, xOfs, yOfs}
    end)
    
    -- Add your module-specific UI elements here
    
    -- Implement your module functionality here
    
    -- Apply current theme
    self:ApplyTheme()
    
    return self.frame
end

-- Apply current theme
function YourModule:ApplyTheme()
    if not self.frame then return end
    
    -- Get theme colors
    local theme = VUI.db.profile.appearance.theme or "dark"
    local themeData = VUI.media.themes[theme]
    
    if not themeData then return end
    
    -- Apply theme colors to your UI elements
    -- Example:
    self.frame:SetBackdropColor(
        themeData.colors.backdrop.r,
        themeData.colors.backdrop.g,
        themeData.colors.backdrop.b,
        themeData.colors.backdrop.a
    )
end

-- Add any additional functions your module needs
```

## Step 3: Create config.lua (Optional)

This file creates a detailed configuration panel for your module:

```lua
-- VUI YourModule - Configuration Panel
local _, VUI = ...
local YourModule = VUI.yourmodule
local AceGUI = LibStub("AceGUI-3.0")

-- Function to create a standalone configuration panel
function YourModule:CreateConfigPanel()
    -- Create a frame
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("Your Module Configuration")
    frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    frame:SetLayout("Flow")
    frame:SetWidth(550)
    frame:SetHeight(500)
    
    -- Add your configuration controls here
    
    return frame
end

-- Register our config panel with the module API
VUI.ModuleAPI:AddModuleConfigPanel("yourmodule", function() 
    return YourModule:CreateConfigPanel() 
end)
```

## Step 4: Update VUI.toc

Add your module files to the VUI.toc file:

```
# YourModule
modules\yourmodule\init.lua
modules\yourmodule\core.lua
modules\yourmodule\config.lua
```

## Step 5: Integrating Existing Addon Code

If you're integrating an existing addon, follow these guidelines:

1. **Identify Core Functionality**: Find the essential parts of the addon that provide its primary functionality.

2. **Move Initialization**: Replace the original addon's initialization with VUI module registration.

3. **Adapt UI Creation**: Modify UI creation to use VUI UI Framework methods:
   - `CreateFrame` → `self:CreateFrame`
   - `CreateTexture` → `frame:CreateTexture`
   - Global frame references → local module references

4. **Adapt Settings**: Convert saved variables to use VUI settings system.

5. **Adapt Event Handling**: Register events through the module.

6. **Compatibility Layer**: If other addons depend on your module, create compatibility wrappers.

## Integration Checklist

Use this checklist to ensure your module is properly integrated:

- [ ] Module structure follows VUI conventions
- [ ] Module registers with VUI.ModuleAPI:CreateModule
- [ ] Module settings use VUI settings system
- [ ] UI elements are created using VUI framework methods
- [ ] Configuration options appear in VUI config panel
- [ ] Module responds to theme changes
- [ ] Module can be enabled/disabled through VUI
- [ ] Slash commands work properly
- [ ] Module code passes validation

## Example Module

Refer to the Example module in `modules/example` for a complete implementation that follows all best practices.

## Troubleshooting

If you encounter issues during integration:

1. Check the VUI integration.md document for framework details
2. Review your module's initialization sequence
3. Verify that UI elements are created using the framework methods
4. Ensure proper event registration
5. Test your module with the integration test utility (`/vuitest`)

## Need Help?

If you need assistance with integrating your module, consult the VUI documentation or reach out to the development team for guidance.