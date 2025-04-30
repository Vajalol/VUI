# VUI Profiles Module

## Overview

The VUI Profiles module provides a comprehensive system for saving, sharing, and loading UI configurations. This allows players to create different setups for different characters, share their setups with friends, or backup their settings before making significant changes.

## Key Features

- **Profile Management**: Save, load, update, and delete profiles
- **Import/Export**: Share profiles with other players through text strings
- **Backup System**: Automatic backups to prevent loss of settings
- **UI Layout Saving**: Remember frame positions and sizes
- **Character-specific Profiles**: Maintain different settings per character
- **Merged Profiles**: Combine settings from multiple profiles
- **Profile Reports**: Generate detailed information about saved profiles

## Usage

### Basic Commands

- `/vuiprofile` - Opens the profile manager
- `/vuiprofile export` - Exports the current profile as a string
- `/vuiprofile import` - Opens the import dialog
- `/vuiprofile save <name>` - Saves current settings as a named profile
- `/vuiprofile load <name>` - Loads a saved profile
- `/vuiprofile delete <name>` - Deletes a saved profile
- `/vuiprofile list` - Lists all saved profiles
- `/vuiprofile backup` - Creates a manual backup
- `/vuiprofile help` - Shows help information

### Configuration Options

The Profiles module provides extensive configuration through the VUI configuration panel:

#### General Settings

- **Auto Save**: Automatically save profile changes at specified intervals
- **Auto Save Frequency**: Set how often auto-saves occur (in minutes)
- **Backup Count**: Control how many backups to keep

#### Display Settings

- **Show Import/Export Frame**: Toggle the dialog for import/export operations
- **Preview Changes**: Preview profile changes before applying them
- **Confirm Overwrite**: Require confirmation before overwriting existing profiles

#### Advanced Settings

- **Compress Exports**: Reduce the size of exported profile strings
- **Include Global Settings**: Include account-wide settings in profiles
- **Include Character Settings**: Include character-specific settings in profiles
- **Include UI Layout**: Save the position and size of UI elements

## Profile Management

### Creating a Profile

To save your current configuration as a new profile:

1. Configure VUI exactly as you want it
2. Open the VUI configuration panel and navigate to the Profiles section
3. Click "Create New Profile" and enter a name
4. Your current settings will be saved under that name

Alternatively, use the command: `/vuiprofile save MyProfileName`

### Loading a Profile

To apply a saved profile:

1. Open the VUI configuration panel and navigate to the Profiles section
2. Select a profile from the dropdown list
3. Click "Load Profile"
4. Confirm the change if prompted
5. Your UI will reload with the new settings

Alternatively, use the command: `/vuiprofile load MyProfileName`

### Updating a Profile

To update an existing profile with your current settings:

1. Make the desired changes to your UI
2. Open the Profiles section of the configuration panel
3. Select the profile you want to update
4. Click "Update Profile"
5. The profile will be updated, and a backup of the previous version is automatically created

### Deleting a Profile

To remove a saved profile:

1. Open the Profiles section of the configuration panel
2. Select the profile you want to delete
3. Click "Delete Profile" and confirm
4. The profile will be removed (a backup is automatically created before deletion)

## Sharing Profiles

### Exporting a Profile

To share your profile with other players:

1. Open the Profiles section of the configuration panel
2. Click "Export Current Profile"
3. A dialog will appear with a text string
4. Copy this string and share it with other players

Alternatively, use the command: `/vuiprofile export`

### Importing a Profile

To use a profile shared by another player:

1. Open the Profiles section of the configuration panel
2. Click "Import Profile"
3. Paste the profile string into the dialog
4. Click "Import"
5. Your UI will reload with the imported settings

Alternatively, use the command: `/vuiprofile import`

## Backup System

The Profiles module automatically creates backups in the following situations:

- When a profile is updated
- When a profile is deleted
- When a profile is imported
- When a profile is loaded
- At regular intervals, if auto-save is enabled
- When logging out, if auto-save is enabled

You can also manually create a backup at any time by clicking "Create Backup" in the configuration panel or using the command: `/vuiprofile backup`

### Restoring a Backup

To restore a previous backup:

1. Open the Profiles section of the configuration panel
2. Scroll down to the "Profile Backups" section
3. Select a backup from the dropdown
4. Click "Restore Backup"
5. Your UI will reload with the backup settings

## Advanced Usage

### Comparing Profiles

You can compare two profiles to see their differences:

```lua
VUI.profiles:CompareProfiles("Profile1", "Profile2")
```

This will list all differences between the two profiles in the chat window.

### Merging Profiles

You can combine settings from two different profiles:

```lua
VUI.profiles:MergeProfiles("TargetProfile", "SourceProfile", "NewMergedProfile")
```

This creates a new profile that primarily uses settings from the target profile but adds any missing settings from the source profile.

### Creating Profile Reports

To generate a detailed report of all saved profiles:

```lua
VUI.profiles:CreateProfileReport()
```

This will display a comprehensive list of all profiles and their settings in a dialog.

## Technical Details

### Profile Data Structure

Profiles store the following information:

- **Global Settings**: Account-wide settings
- **Character Settings**: Character-specific settings
- **UI Layout**: Frame positions and sizes
- **Metadata**: Version information, creation date, character info

### File Format

Exported profiles are formatted as:

```
VUI:format:serialized_data
```

Where:
- `format` indicates the serialization method (normal or compressed)
- `serialized_data` contains the actual profile data

## Compatibility

Profiles created with older versions of VUI can be imported into newer versions. However, importing a profile from a newer version into an older version may result in some settings being ignored or causing errors.

A version check is performed during import to warn of potential compatibility issues.

## Troubleshooting

If you encounter issues with profiles:

1. **Profile Import Errors**: Ensure you copied the entire profile string without any extra characters
2. **UI Issues After Import**: Try restoring a backup from before the import
3. **Missing Settings**: Different VUI versions may store different settings; ensure both users are on the same version
4. **Corrupt Profiles**: If a profile becomes corrupted, delete it and restore from a backup