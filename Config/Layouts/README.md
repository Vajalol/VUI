# VUI Config Layouts

This directory contains configuration layouts for all VUI modules. These layout files define how settings appear in the VUI config panel.

## Standardization Guidelines

All layout files should follow these guidelines to ensure consistency and maintainability:

### 1. File Naming and Organization

* All layout files MUST follow the underscore prefix naming convention: `_ModuleName.lua`
* Files are grouped in Load.xml by category:
  - Core configuration layouts: `_General.lua`, `_Chat.lua`, etc.
  - Core addon modules: `_VUIBuffs.lua`, `_VUICC.lua`, etc.
  - WeakAura replacements: `_VUIMissingRaidBuffs.lua`, etc.
  - New modules: `_VUISkin.lua`, etc.

### 2. Module Loading

Always use the standardized stable module loading pattern:

```lua
-- Safe access to helper functions with fallback
local SafeGetVModule

-- Initialize the helper function
local function InitHelpers()
    -- Use global if available, otherwise try to get from VUI
    SafeGetVModule = _G.SafeGetVModule
    
    -- If the global helper isn't available yet, create a simple version
    if not SafeGetVModule and VUI then
        SafeGetVModule = function(name)
            return VUI:GetModule(name, true)
        end
    end
end

function Layout:OnEnable()
    -- Initialize helpers
    InitHelpers()

    -- Database reference
    local db = VUI.db
    
    -- Get module safely
    local module = SafeGetVModule and SafeGetVModule("ModuleName")
    
    if not module then 
        -- Retry after a delay if helpers not loaded yet
        C_Timer.After(0.5, function()
            InitHelpers()
            self:OnEnable()
        end)
        return 
    end
    
    -- Rest of layout code
}
```

### 3. Layout Structure

Organize settings into logical sections separated by headers in this order:

1. Main settings (enable/disable, unlock frame)
2. Display settings (scale, transparency, visibility conditions)
3. Appearance settings (colors, textures, sizes)
4. Unit settings (if applicable)
5. Functionality settings (specific to module behavior)
6. Position settings (always last)

### 4. Column Allocation

* Each row must not exceed 12 total columns
* Standard column allocations:
  - 3: For 4 elements per row
  - 4: For 3 elements per row 
  - 6: For 2 elements per row
  - 12: For full width elements
* Never mix different column widths that don't add up to exactly 12
* Use full-width headers (no column specification needed)

### 5. Naming Conventions

* Use consistent and descriptive naming:
  - Enabled/disabled toggles: `enabled`
  - Scale sliders: `scale`
  - Transparency: `alpha` 
  - Frame unlock: `unlockFrame` or `movable`
* Follow camelCase for setting keys and variable names
* Use TitleCase for labels
* Group related settings with consistent prefixes

### 6. Callback Safety

Always add safety checks in callback functions with this pattern:

```lua
callback = function(self)
    if module and module.db then
        module.db.profile.setting = self:GetValue()
        -- Call the appropriate update function if it exists
        if module.UpdateFunction then
            module:UpdateFunction()
        end
    end
end
```

### 7. Setting Types and Requirements

* **Sliders**: Must have `min`, `max`, and `step` values. Common patterns:
  - Scale sliders: `min = 0.5, max = 2.0, step = 0.05`
  - Opacity sliders: `min = 0.1, max = 1.0, step = 0.05`
  - Size sliders: `min = [appropriate value], max = [appropriate value], step = 1`
* **Checkboxes**: Should include descriptive tooltips
* **Dropdowns**: Should use standardized option formatting: `{ value = 'value', text = 'Display Text' }`

## Template Usage

For new modules, use the `_StableTemplate.lua` as a starting point.

## Common Settings Groups

Most modules should include these sections in this order:

1. **Main Settings**: Enable/disable, basic functionality
2. **Display Settings**: Scale, visibility conditions, transparency
3. **Appearance**: Theme colors, textures, fonts
4. **Behavior/Functionality**: Module-specific options
5. **Position**: Frame positioning controls (always last)

## Practical Layout Example

```lua
-- Main settings row
{
    enabled = {
        key = 'modulePath.enabled',
        type = 'checkbox',
        label = 'Enable Module',
        tooltip = 'Enable or disable this module',
        column = 6,
        order = 1,
        callback = function(self)
            if module and module.db then
                module.db.profile.enabled = self:GetValue()
                if self:GetValue() then
                    if module.OnEnable then module:OnEnable() end
                else
                    if module.OnDisable then module:OnDisable() end
                end
            end
        end
    },
    unlockFrame = {
        key = 'modulePath.unlocked',
        type = 'checkbox',
        label = 'Unlock Frame',
        tooltip = 'Allow repositioning of the module frame',
        column = 6,
        order = 2,
        callback = function(self)
            if module and module.ToggleMovable then
                module:ToggleMovable(self:GetValue())
            end
        end
    },
},

-- Always use full-width headers
{
    header = {
        type = 'header',
        label = 'Display Settings'
    },
},

-- Appearance row with 3 equal elements (4 columns each)
{
    scale = {
        key = 'modulePath.scale',
        type = 'slider',
        label = 'Scale',
        tooltip = 'Set the scale of the display',
        min = 0.5,
        max = 2.0,
        step = 0.05,
        column = 4,
        order = 1,
        callback = function(self)
            if module and module.db then
                module.db.profile.scale = self:GetValue()
                if module.UpdateSize then
                    module:UpdateSize()
                end
            end
        end
    },
    alpha = {
        key = 'modulePath.alpha',
        type = 'slider',
        label = 'Transparency',
        tooltip = 'Set the transparency of the display',
        min = 0.1, 
        max = 1.0,
        step = 0.05,
        column = 4,
        order = 2,
        callback = function(self)
            if module and module.db then
                module.db.profile.alpha = self:GetValue()
                if module.UpdateDisplay then
                    module:UpdateDisplay()
                end
            end
        end
    },
    showInCombatOnly = {
        key = 'modulePath.showInCombatOnly',
        type = 'checkbox',
        label = 'Combat Only',
        tooltip = 'Only show during combat',
        column = 4,
        order = 3,
        callback = function(self)
            if module and module.db then
                module.db.profile.showInCombatOnly = self:GetValue()
                if module.UpdateVisibility then
                    module:UpdateVisibility()
                end
            end
        end
    }
}
```

## Testing

After creating or modifying a layout:

1. Check that all settings appear correctly and aligned
2. Verify that callbacks function properly
3. Ensure column allocations don't exceed 12 per row and rows are balanced
4. Test with both default and custom themes 