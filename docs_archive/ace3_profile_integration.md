# Ace3 Profile Integration in VUI

## Overview

VUI leverages Ace3's powerful profile management system through the AceDB-3.0 and AceDBOptions-3.0 libraries. This integration provides a standardized, robust profile system with minimal code while delivering maximum functionality.

## Key Benefits

- **Cross-character profiles**: Share settings between characters
- **Role-specific profiles**: Maintain different settings for different specs/roles
- **Realm-specific profiles**: Share settings between characters on the same realm
- **Class-specific profiles**: Share settings between characters of the same class
- **Import/Export**: Share profiles with other players
- **Reset capabilities**: Reset to default values with a single click
- **Automatic handling**: All database operations are handled by Ace3

## How to Access

### In-Game UI

1. Type `/vui profile` to access the profiles section directly
2. Or open the main configuration panel (`/vui config`) and navigate to the Profiles tab

### Direct Command Access

The following slash commands are available:

- `/vui profile` - Opens the Profiles section of the configuration
- `/vui config` - Opens the main configuration panel

## Available Operations

Within the Profiles section, you can:

- **Select an existing profile**: Choose from the dropdown list
- **Create a new profile**: Enter a name for your new profile
- **Copy from another profile**: Copy settings from another existing profile
- **Delete a profile**: Remove an existing profile
- **Reset the current profile**: Reset to default settings

## Technical Implementation

The integration is accomplished through several key components:

1. **Database initialization**:
   ```lua
   self.db = LibStub("AceDB-3.0"):New("VUIDB", VUI.defaults, true)
   ```

2. **Profile options setup**:
   ```lua
   local profilesOptions = AceDBOptions:GetOptionsTable(self.db)
   self.options.args.profiles = profilesOptions
   ```

3. **Callback registration**:
   ```lua
   self.db.RegisterCallback(self, "OnProfileChanged", "UpdateUI")
   self.db.RegisterCallback(self, "OnProfileCopied", "UpdateUI")
   self.db.RegisterCallback(self, "OnProfileReset", "UpdateUI")
   ```

4. **UI update function**:
   ```lua
   function VUI:UpdateUI(_, database, profileKey)
       -- Update UI elements based on new profile settings
   end
   ```

## Default Profiles

VUI comes with several default profiles:

1. **Default**: The standard configuration for all characters
2. **Character Specific**: A unique profile for your current character
3. **Class Specific**: A shared profile for all characters of your current class
4. **Spec Specific**: A profile tied to your current specialization

## Profile Data Storage

Profile data is stored in the `VUIDB` saved variable, which persists between game sessions. The database structure follows the Ace3 standard format:

```lua
VUIDB = {
    ["profiles"] = {
        ["Default"] = {
            -- profile settings
        },
        ["CharacterName - RealmName"] = {
            -- character-specific settings
        },
        -- additional profiles
    },
    ["profileKeys"] = {
        ["CharacterName - RealmName"] = "Default" -- current profile assignment
    }
}
```

## Integration with VUI Modules

All VUI modules can access the current profile settings through:

```lua
self.db = VUI.db
local settings = self.db.profile.moduleName
```

When a profile changes, each module's `UpdateUI` method is called automatically if it exists.

## Best Practices

1. **Creating module-specific settings**:
   ```lua
   -- In module defaults:
   myModule = {
       enabled = true,
       setting1 = value1,
       setting2 = value2
   }
   
   -- Accessing in module code:
   local settings = VUI.db.profile.myModule
   ```

2. **Handling profile changes**:
   ```lua
   function MyModule:UpdateUI()
       -- Update all UI elements with new settings
   end
   ```

3. **Saving custom data**:
   ```lua
   -- Save data:
   VUI.db.profile.myModule.customData = newValue
   
   -- Retrieve data:
   local data = VUI.db.profile.myModule.customData
   ```

## Troubleshooting

**Issue**: Profile changes not reflecting in UI
**Solution**: Ensure your module implements an `UpdateUI` method and it's properly updating all elements

**Issue**: Settings not saved between sessions
**Solution**: Make sure you're saving to `VUI.db.profile.moduleName` and not to local variables

**Issue**: Profile reset doesn't fully reset UI
**Solution**: Ensure all UI elements are updated in your module's `UpdateUI` method