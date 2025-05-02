# VUI Help System Guide

This document provides details on the VUI Help System that offers contextual assistance to users.

## Overview

The VUI Help System is designed to offer immediate, contextual assistance to users who are learning to use the addon. It creates a more accessible experience by providing helpful information when and where it's needed.

## Features

### Contextual Help

- **Module-specific Help**: When opening a module's configuration panel, relevant help for that module is displayed
- **Tooltips**: Enhanced tooltips with detailed information about UI elements
- **First-time Setup**: Special walkthrough assistance for first-time users

### Help Commands

- **/vui help** - Opens the general help window
- **/vui help [module]** - Shows help for a specific module (e.g. /vui help buffoverlay)
- **/vui help themes** - Displays information about available themes

### First-time User Experience

The Help System includes a comprehensive welcome guide for new users that explains:

- Core addon features
- Basic configuration options
- Key commands
- Getting started steps

This guide is displayed automatically on first login after installing or updating VUI, but can be disabled in settings.

## Customization Options

The following options can be configured:

- **Show Tooltips**: Enable/disable enhanced tooltips
- **Contextual Help**: Enable/disable help that appears based on what you're doing
- **Show Tips**: Show occasional helpful tips about VUI features
- **Help Detail Level**: Basic, Detailed, or Advanced information
- **First-time Help**: Enable/disable welcome help shown to new users

## Integration with Modules

The Help System is integrated with all major VUI modules:

- **BuffOverlay**: Information about categories, visibility options, and special effects
- **TrufiGCD**: Timeline view options and spell tracking details
- **MultiNotification**: Animation styles and notification priorities
- **OmniCD**: Party/raid cooldown tracking and priority system
- **DetailsSkin**: Theme-specific appearance features and customization

## Technical Design

The Help System is built with a modular structure that allows for easy extension:

- **Database-driven Help Content**: All help content is stored in a structured database
- **Tiered Information**: Multiple detail levels to match user needs
- **UI Integration**: Non-intrusive UI elements that provide help when needed
- **Module API**: Simple API for module developers to integrate help content

## For Module Developers

Module developers can integrate with the Help System using the following API:

```lua
-- Register help content for your module
VUI.modules.help:RegisterModuleHelp("yourmodule", {
    title = "Your Module Help",
    content = "Description of your module's purpose",
    features = {
        "Feature 1 description",
        "Feature 2 description"
    },
    tips = {
        "Helpful tip 1",
        "Helpful tip 2"
    }
})

-- Show help for your module in your own UI
VUI.modules.help:ShowModuleHelp("yourmodule")

-- Add a help button to your frame
VUI.modules.help:AddHelpButton(yourFrame, "yourmodule")
```

## Performance Considerations

The Help System is designed to have minimal performance impact:

- Help content is loaded on-demand to minimize memory usage
- Display elements use the VUI frame pooling system
- Event listeners are only active when help features are enabled

## Future Enhancements

Planned enhancements for future versions:

- Interactive tutorials for complex features
- Class-specific help content
- Situation-aware assistance (combat, questing, PvP, etc.)
- Video tutorials integration
- More detailed tooltips with spell mechanics explanations