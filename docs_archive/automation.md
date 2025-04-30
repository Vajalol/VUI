# VUI Automation Module

## Overview

The VUI Automation module provides a comprehensive set of quality-of-life improvements and automated actions to streamline gameplay. It automates routine tasks, enhances the UI, and improves performance to create a more efficient and enjoyable WoW experience.

## Key Features

- **Vendor Automation**: Auto-sell junk items and auto-repair equipment
- **Quest Automation**: Auto-accept and complete quests, skip NPC gossip
- **Chat Automation**: Auto-screenshot achievements, thank players for services
- **Combat Automation**: Auto-roll on loot, release in battlegrounds, decline duels
- **Quality of Life**: Instant loot, improved mailbox functionality, auto-track quests
- **UI Automation**: Hide UI elements, lock frames after moving
- **Performance Optimization**: Auto-adjust graphics settings based on FPS

## Usage

### Basic Commands

- `/vuiauto` - Open configuration panel
- `/vuiauto toggle` - Toggle automation module on/off
- `/vuiauto vendor` - Toggle vendor automation on/off
- `/vuiauto quest` - Toggle quest automation on/off
- `/vuiauto help` - Show help information

## Configuration Options

The Automation module provides extensive configuration through the VUI configuration panel:

### Vendor Automation

- **Auto-sell Junk**: Automatically sell gray (poor quality) items
- **Auto-repair Equipment**: Automatically repair equipment at vendors
- **Use Guild Funds for Repairs**: Use guild bank for repairs when possible
- **Detailed Sell Report**: Show detailed information about sold items
- **Detailed Repair Report**: Show detailed information about repairs
- **Sell Items Below Quality**: Set quality threshold for auto-selling
- **Auto-Sell Value Limit**: Maximum value of items to auto-sell

### Quest Automation

- **Auto-accept Quests**: Automatically accept quests from NPCs
- **Only Auto-accept from Friends**: Only auto-accept quests from friends/guildmates
- **Auto-complete Quests**: Automatically complete quests when talking to NPCs
- **Auto-skip Gossip**: Automatically skip NPC gossip text

### Chat Automation

- **Auto-screenshot Achievements**: Take a screenshot when earning achievements
- **Auto-thank for Resurrection**: Thank players when they resurrect you
- **Auto-thank for Summon**: Thank players when they summon you

### Combat Automation

- **Auto-roll on Loot**: Automatically roll on loot items
- **Auto-roll Choice**: Choose how to roll (Need, Greed, Pass)
- **Auto-release in Battlegrounds**: Automatically release when you die in BGs
- **Auto-decline Duels**: Automatically decline duel requests

### Quality of Life

- **Instant Loot**: Loot items without showing the loot window
- **Fast Loot**: Speed up the looting process

### UI Automation

- **Hide Gryphons**: Hide the gryphon graphics on the action bar
- **Hide Talking Head**: Hide NPC dialog popup frames
- **Hide Objective Tracker in Combat**: Hide quest tracker during combat

### Performance Optimizations

- **Auto-adjust Effects**: Dynamically adjust graphics effects based on FPS
- **Target FPS**: Set the target frame rate for auto-adjustments

## Feature Details

### Vendor Automation

When visiting a vendor, the module can:

1. **Auto-repair Equipment**: Repairs all damaged items automatically
   - Uses guild funds if enabled and available
   - Reports repair costs if detailed reporting is enabled

2. **Auto-sell Items**: Sells unwanted items automatically
   - Sells items based on quality threshold settings
   - Respects a value limit to avoid selling valuable items
   - Reports sold items and total value if detailed reporting is enabled

Example usage:
```
/vuiauto vendor
```

### Quest Automation

Makes questing more efficient by:

1. **Auto-accepting Quests**: Automatically accepts quests when talking to NPCs
   - Can be limited to only accept from friends and guildmates

2. **Auto-completing Quests**: Automatically completes quests when talking to NPCs
   - Does not auto-select quest rewards if multiple choices are available

3. **Auto-skipping Gossip**: Skips unnecessary NPC dialog
   - Useful for repeated interactions with the same NPCs

Example usage:
```
/vuiauto quest
```

### Chat Automation

Enhances social interactions by:

1. **Auto-screenshots**: Takes screenshots when achievements are earned

2. **Auto-thank Messages**: Automatically thanks players for:
   - Resurrection
   - Summons
   - Portals
   - Buffs

3. **Auto-welcome/Farewell**: Greets players joining your group and says goodbye when they leave

### Combat Automation

Streamlines combat-related activities:

1. **Auto-roll on Loot**: Automatically rolls on loot based on your preferences
   - Configure to need, greed, or pass by default

2. **Auto-release in Battlegrounds**: Quickly gets you back into the action
   - Only activates in PvP instances

3. **Auto-decline Duels**: Prevents unwanted duel requests
   - Useful in crowded areas where duel spam is common

### Quality of Life Improvements

Various improvements to make gameplay smoother:

1. **Fast Loot**: Increases looting speed to minimize downtime
   - Works with auto-loot option

2. **Mailbox Tools**: Enhanced mailbox functionality
   - Auto-collect attachments
   - Open all mail with one click

3. **Auto-track Quests**: Automatically tracks quests when accepted

### UI Automation

Customizes UI elements for a cleaner interface:

1. **Hide Gryphons**: Removes decorative elements for a cleaner action bar

2. **Hide Talking Head**: Removes popup dialogue frames
   - Useful for repeated content or when focusing on gameplay

3. **Combat UI Adjustments**: Hides non-essential UI during combat
   - Improves visibility and performance in intense situations

### Performance Optimizations

Dynamically adjusts settings based on performance:

1. **Graphics Adjustments**: Automatically adjusts effect density and view distance
   - Maintains target FPS by reducing settings when performance drops
   - Increases settings when performance improves

2. **Situational CVars**: Applies different settings based on your current activity
   - Combat vs. out-of-combat
   - Instance vs. open world
   - Raid vs. solo play

## Implementation Notes

The Automation module uses a combination of event hooks and frame hooks to provide its functionality:

- **Event-driven automation**: Responds to game events like `MERCHANT_SHOW`, `QUEST_DETAIL`, etc.
- **Frame hooks**: Modifies the behavior of UI elements like the talking head frame
- **Performance monitoring**: Periodically checks FPS and adjusts settings accordingly

## Compatibility

The Automation module is designed to be compatible with other addons, but some features may overlap with specialized addons. In case of conflicts, you can disable specific automation features while keeping others active.

## Performance Impact

The module is designed to have minimal performance impact, and many features can actually improve game performance by:

- Reducing unnecessary visual effects during combat
- Dynamically adjusting graphics settings based on performance
- Streamlining repetitive actions to reduce client-side processing

## Limitations

- Some automation features may not work with non-standard UI modifications
- Auto-quest completion does not select quest rewards automatically when multiple choices are available
- Performance optimizations may conflict with graphics settings from other addons

## Troubleshooting

If you encounter issues with the Automation module:

1. **Disable specific features**: Use the configuration panel to disable problematic features
2. **Check for conflicts**: Disable other addons that might be trying to control the same functionality
3. **Reset settings**: Use `/vuiauto reset` to restore default settings