# VUI Module Standardization Guide

This document outlines the standardized approach for creating and registering VUI modules.

## Module Structure

Every VModule should follow this directory structure:

```
VModules/
└── ModuleName/
    ├── Load.xml                   # Main XML file that loads all module files
    ├── Main.lua                   # Module initialization, registration, and core functionality
    ├── Options.lua                # Configuration options (if complex enough to warrant separation)
    ├── locale/                    # Optional localization files
    │   ├── enUS.lua
    │   └── ...
    ├── service/                   # Business logic files
    │   ├── Config.lua             # Configuration implementation (if too complex for Options.lua)
    │   └── ...
    └── ui/                        # UI components
        ├── Frames.lua
        └── ...
```

## Module Registration Pattern

All modules should be registered using this standardized pattern:

1. **Module Creation**:
   ```lua
   local AddonName, VUI = ...
   local MODNAME = "ModuleName"
   local M = VUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0", "AceConsole-3.0") -- Add needed Ace3 mixins
   ```

2. **Module Constants**:
   ```lua
   -- Module Constants
   M.NAME = MODNAME
   M.TITLE = "Module Display Name" -- Used in UI
   M.DESCRIPTION = "Module description text"
   M.VERSION = "1.0"
   ```

3. **Default Settings**:
   ```lua
   -- Default settings
   M.defaults = {
       profile = {
           enabled = true,
           -- Add module-specific defaults here
       }
   }
   ```

4. **Database Registration**:
   ```lua
   -- In OnInitialize
   self.db = VUI.db:RegisterNamespace(self.NAME, {
       profile = self.defaults.profile
   })
   ```

5. **Configuration Registration**:
   ```lua
   -- In InitializeConfig
   VUI.Config:RegisterModuleOptions(self.NAME, options, self.TITLE)
   ```

6. **Theme Integration**:
   ```lua
   -- In OnInitialize
   VUI:RegisterCallback("OnThemeChanged", function()
       if self.UpdateTheme then
           self:UpdateTheme()
       end
   end)
   ```

7. **Event Handling**:
   ```lua
   -- In OnEnable
   self:RegisterEvent("PLAYER_ENTERING_WORLD")
   self:RegisterEvent("OTHER_EVENTS_AS_NEEDED")
   
   -- In OnDisable
   self:UnregisterAllEvents()
   ```

## Standard Lifecycle Methods

Every module should implement these standard methods:

1. **OnInitialize**: Called when the addon is loaded
   ```lua
   function M:OnInitialize()
       -- Database initialization
       -- Config registration
       -- Theme callback registration
   end
   ```

2. **OnEnable**: Called when the module is enabled
   ```lua
   function M:OnEnable()
       -- Register events
       -- Start timers
       -- Initialize frames
   end
   ```

3. **OnDisable**: Called when the module is disabled
   ```lua
   function M:OnDisable()
       -- Unregister events
       -- Cancel timers
       -- Hide frames
   end
   ```

4. **InitializeConfig**: Create and register configuration options
   ```lua
   function M:InitializeConfig()
       -- Create config table
       -- Register with VUI.Config
   end
   ```

5. **UpdateTheme**: Update visuals based on current theme
   ```lua
   function M:UpdateTheme()
       -- Get active theme
       -- Apply theme colors/textures
   end
   ```

## Configuration Format

All modules should follow this standardized configuration format:

```lua
local options = {
    name = self.TITLE,
    desc = self.DESCRIPTION,
    type = "group",
    args = {
        header = {
            type = "header",
            name = self.TITLE,
            order = 1,
        },
        version = {
            type = "description",
            name = "|cffff9900Version:|r " .. self.VERSION,
            order = 2,
        },
        desc = {
            type = "description",
            name = self.DESCRIPTION,
            order = 3,
        },
        spacer = {
            type = "description",
            name = " ",
            order = 4,
        },
        enabled = {
            type = "toggle",
            name = L["Enable"],
            desc = L["Enable_Desc"] or "Enable or disable this module",
            width = "full",
            order = 5,
            get = function() return self.db.profile.enabled end,
            set = function(_, val) 
                self.db.profile.enabled = val
                if val then
                    self:Enable()
                else
                    self:Disable()
                end
            end,
        },
        -- Module-specific options
    }
}
```

## Debug Helpers

Include standardized debug helper:

```lua
function M:Debug(...)
    VUI:Debug(self.NAME, ...)
end
```

## Slash Command Pattern

If the module has slash commands, use this format:

```lua
function M:SlashCommand(input)
    if input == "toggle" then
        self.db.profile.enabled = not self.db.profile.enabled
        VUI:Print("|cffff9900" .. self.TITLE .. ":|r " .. (self.db.profile.enabled and "Enabled" or "Disabled"))
    else
        -- Open configuration
        VUI.Config:OpenToCategory(self.TITLE)
    end
end
```

## Database Access Pattern

Always access database values through the module's db reference:

```lua
-- Reading values
local value = self.db.profile.settingName

-- Writing values
self.db.profile.settingName = newValue
```

## Event Handling Pattern

Handle events with dedicated methods:

```lua
function M:EVENT_NAME(...)
    -- Event handler logic
end
```

## Theme Integration Pattern

Follow this pattern for theme-aware modules:

```lua
function M:UpdateTheme()
    local theme = VUI:GetActiveTheme()
    -- Apply theme colors to UI elements
    local primaryColor = theme.colors.primary
    local secondaryColor = theme.colors.secondary
    
    -- Apply colors to frames, etc.
end
```

This standardized approach ensures consistency across all VModules and simplifies maintenance and feature additions.