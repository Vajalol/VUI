# VUI: A Comprehensive Development Roadmap (Revised)

## 1. Introduction & Project Vision

This document outlines the development roadmap for **VUI**, a new, massive, and unified addon suite designed for the retail version of World of Warcraft. The primary goal of VUI is to meticulously consolidate the functionality, aesthetics, and media assets of several well-regarded existing addons and WeakAuras into a single, cohesive, and high-quality package. The project will be authored by "VortexQ8" and will utilize the SUI addon (`https://github.com/Syiana/SUI`) as its foundational codebase. VUI aims to be a meticulously crafted suite, ensuring that no features from the original components are overlooked, and that the final product is both powerful and user-friendly. This roadmap is intended to guide an AI coder through the development process, ensuring a structured and thorough approach.

## 2. Phase 0: Foundation and Initial Setup

This initial phase focuses on preparing the development environment, acquiring the base codebase, performing the initial rebranding, and establishing the core directory structure for VUI.

### Step 0.1: Environment Setup
The AI coder should ensure a standard World of Warcraft addon development environment is configured. This typically includes a text editor suitable for Lua and XML (like VSCode with appropriate extensions), access to the WoW client (Retail), and tools for testing and debugging addons in-game.

### Step 0.2: Clone SUI Repository
The first crucial step is to obtain the SUI codebase. The AI coder will clone the SUI repository from its official GitHub page: `https://github.com/Syiana/SUI`. This local copy will serve as the starting point for VUI.

### Step 0.3: Initial Rebranding (SUI to VUI)
A comprehensive rebranding from SUI to VUI is required. This involves more than just a name change; it's about establishing VUI's identity from the ground up while leveraging SUI's structure.

*   **Folder Renaming:** The primary addon folder (e.g., `SUI`) in the `Interface\AddOns\` directory should be renamed to `VUI`.
*   **TOC File Modification (`VUI.toc`):**
    *   The `SUI.toc` file must be renamed to `VUI.toc`.
    *   Open `VUI.toc` and update the metadata:
        *   Change `## Title: SUI` (or similar) to `## Title: VUI`.
        *   Change `## Author: Syiana` (or similar) to `## Author: VortexQ8`.
        *   Add or update `## X-Website: https://github.com/Vajalol/VUI`.
        *   Add or update `## X-Curse-Project-ID: 1257198` (this is the CurseForge project ID for VUI).
        *   Update `## Version: 1.0.0` (or a suitable initial version for VUI, e.g., `0.1.0-alpha`).
*   **Codebase Search & Replace:** A careful global search and replace operation must be performed across all Lua and XML files within the VUI folder. The primary goal is to replace occurrences of "SUI" with "VUI" and "Syiana" with "VortexQ8". This must be done judiciously to avoid unintentionally altering variable names or function calls that might coincidentally contain these strings but are not related to the addon's name or author. Focus on explicit namespacing, comments, and displayed text. For example, `SUI_FunctionName` should become `VUI_FunctionName`, and text like "SUI Options" should become "VUI Options".

### Step 0.4: Directory Structure Setup
A clear and organized directory structure is paramount for managing a large addon suite. The AI coder will establish the following structure within the main `/VUI/` folder:

*   `/VUI/modules/`: This directory will house each integrated addon and each WeakAura-derived feature as a distinct submodule. Each submodule will have its own folder (e.g., `/VUI/modules/VUIBuffs/`, `/VUI/modules/VUIConsumables/`).
*   `/VUI/media/`: This central directory will store all media assets for VUI.
    *   `/VUI/media/icons/`: This subfolder will contain branding icons. The provided logo `vortex_thunderstorm.svg` (from `https://github.com/Vajalol/VUI/blob/main/media/icons/vortex_thunderstorm.svg`) should be placed here. Note: WoW primarily uses `.tga` or `.blp` file formats for in-game textures. The SVG logo might need to be converted to a suitable format (e.g., TGA) if it's intended for in-game display within VUI's UI. If it's for external branding, the SVG is fine as is.
    *   `/VUI/media/modules/`: This subfolder will contain further subdirectories, one for each module that requires its own media assets (e.g., `/VUI/media/modules/VUIBuffs/`, `/VUI/media/modules/VUIConsumables/`). This ensures that media assets are organized and namespacing conflicts are avoided.

### Step 0.5: Version Control
It is highly recommended to use Git for version control. The AI coder should initialize a new Git repository in the `/VUI/` directory (if one doesn't already exist at `https://github.com/Vajalol/VUI`). The initial rebranded structure should be committed as the baseline for the project. Regular commits should be made throughout the development process.



## 3. Phase 1: Core Addon Module Integration

This phase involves integrating the specified third-party addons into VUI as self-contained modules. The module names have been updated to reflect the "VUI" prefix. A consistent approach should be applied for each addon.

**General Approach for Each Addon Module:**

*   **A. Obtain Source Code:** Clone or download the addon from its specified GitHub repository. Ensure the latest stable version is used.
*   **B. Analyze Structure & Functionality:** Before integration, thoroughly analyze the addon: its directory structure, main Lua files, XML frames, event handling, slash commands, and configuration management (SavedVariables).
*   **C. Create Module Folder:** Inside `/VUI/modules/`, create a dedicated folder for the addon using its new VUI-prefixed name (e.g., `/VUI/modules/VUIBuffs/`).
*   **D. Integrate Code:**
    *   Copy the addon's Lua, XML, and essential files into its module folder.
    *   Modify the code for VUI compatibility: namespacing (e.g., `VUI_ModuleName_FunctionName`, `VUI_ModuleName_FrameName`), adapting event handling, updating API calls for Retail, and managing dependencies.
*   **E. Integrate Media Assets:**
    *   Identify all media files (textures, fonts, sounds).
    *   Create the module-specific media folder: `/VUI/media/modules/VUIModuleName/` (e.g., `/VUI/media/modules/VUIBuffs/`).
    *   Copy assets to this folder and update all code paths to `Interface\AddOns\VUI\media\modules\VUIModuleName\asset_name`.
*   **F. TOC File Integration:** List the module's primary Lua/XML files in `VUI.toc`, ensuring correct load order (VUI core > libraries > modules).
*   **G. Configuration Integration:**
    *   Integrate options into VUI's main configuration panel (extended from SUI's). Design new categories/sections for each module (e.g., "VUI - Buffs").
    *   Aim for a configuration panel "even better than ElvUI's" in organization and clarity.
    *   Manage SavedVariables under a unified `VUI_SavedVariables` structure (e.g., `VUI_SavedVariables.VUIBuffs = { ...settings... }`).
*   **H. Testing:** Thoroughly test each module's functionality, configuration, and for Lua errors or conflicts within VUI.

**Specific Addon Modules to Integrate (Updated List):**

1.  **VUI Buffs (formerly buff-overlay)**
    *   Source: `https://github.com/clicketz/buff-overlay`
    *   Focus: Visual display of buffs/debuffs. Pay attention to anchoring and updates.
2.  **VUI AnyFrame (formerly MoveAny)**
    *   Source: `https://github.com/d4kir92/MoveAny`
    *   Focus: Moving/resizing default UI frames. Handle frame references carefully.
3.  **VUI Keystones (formerly Angry Keystones)**
    *   Source: `https://github.com/Ermad/angry-keystones`
    *   Focus: Mythic+ keystone enhancements. Interact with keystone data and UI.
4.  **VUI CC (formerly OmniCC)**
    *   Source: `https://github.com/tullamods/OmniCC`
    *   Focus: Cooldown text on abilities/items/buffs. Interacts deeply with UI cooldown displays.
5.  **VUI CD (formerly OmniCD - Party Cooldown Tracker)**
    *   Source: (User specified as "Party Cooldown Tracker", e.g., `https://github.com/jordonwow/OmniCD`. AI coder to verify.)
    *   Focus: Tracks party cooldowns. Involves communication and a dedicated display UI.
6.  **VUI IDs (formerly idTip)**
    *   Source: `https://github.com/wow-addon/idTip`
    *   Focus: Enhances tooltips with IDs. Hooks tooltip generation.
7.  **VUI Gfinder (formerly PremadeGroupFinder)**
    *   Source: (User specified name. AI coder to identify a suitable addon if no direct link, e.g., enhancing Premade Group Finder functionality like `https://www.curseforge.com/wow/addons/premade-groups-filter`)
    *   Focus: Improves Premade Group Finder interface and filtering.
8.  **VUI TGCD (formerly TrufiGCD)**
    *   Source: `https://github.com/Trufi/TrufiGCD`
    *   Focus: Displays recent ability history. Captures combat/ability events.
9.  **VUI Auctionator**
    *   Source: `https://github.com/Auctionator/Auctionator`
    *   Focus: Enhances Auction House. Complex integration due to many features.
10. **VUI Notifications (formerly SpellNotifications)**
    *   Source: `https://github.com/jobackman/SpellNotifications`
    *   Focus: Notifications for specific spells/events. Combat log parsing and alerts.

## 4. Phase 2: WeakAura Feature Replication as Modules

This phase focuses on re-implementing the functionality of the specified WeakAuras as native Lua modules within VUI, using the new "VUI" naming convention. The goal is to provide the exact features, or better, coded as modules.

**General Approach for Each WeakAura-derived Module:**

*   **A. Analyze WeakAura:** Import from Wago.io, study behavior (triggers, conditions, visuals, custom options, internal Lua/structure).
*   **B. Design Lua Module:** Define core logic in Lua (event registration, API calls, conditional logic). Design UI elements (frames, textures, text) for a VUI-themable style.
*   **C. Create Module Folder:** Inside `/VUI/modules/`, create a folder using the new VUI-prefixed name (e.g., `/VUI/modules/VUIConsumables/`).
*   **D. Implement Lua Code & XML Frames:** Write Lua code and create XML frame definitions within the module's folder.
*   **E. Media Asset Handling:**
    *   For consistency, use `/VUI/media/modules/VUIModuleName/` for textures specific to that WeakAura-derived module (e.g., `/VUI/media/modules/VUIConsumables/textures/mytexture.tga`).
    *   Extract/recreate/find licensed alternatives for custom textures/sounds used by the WeakAura.
    *   Place assets in the dedicated media folder and update code references.
*   **F. TOC File Integration:** Add module's Lua/XML files to `VUI.toc`.
*   **G. Configuration Integration:** Integrate customizable options into VUI's main configuration panel under a module-specific section (e.g., "VUI - Consumables").
*   **H. Testing:** Rigorously test for accurate replication of functionality and visuals, and for any errors.

**Specific WeakAuras to Replicate (Updated Names):**

1.  **VUI Consumables (formerly Luxthos - Consumables)**
    *   Wago: `https://wago.io/MTSDyaGz9`
    *   Focus: Tracks player consumables (flasks, food, potions, runes).
2.  **VUI Position of Power (formerly Position of Power)**
    *   Wago: `https://wago.io/rdxO3TmdV`
    *   Focus: Tracks buffs/effects related to positioning or stacking. Analyze triggers.
3.  **VUI Missing Raid Buffs (formerly Missing Raid Buffs)**
    *   Wago: `https://wago.io/BQce7Fj5J`
    *   Focus: Scans group/raid for missing standard buffs.
4.  **VUI mouse fire trail (formerly Frogski's mouse fire trail)**
    *   Wago: `https://wago.io/RzZVq4F1a`
    *   Focus: Cosmetic visual effect following the mouse cursor.
5.  **VUI Healer Mana (formerly Healer Mana)**
    *   Wago: `https://wago.io/ebWkTh8By`
    *   Focus: Displays healer mana in group/raid.

## 5. Phase 3: New Feature Module - VUI Plater

This phase introduces a significant new module: **VUI Plater**. The goal is to replicate the functionality and appearance of the **Whiiskeyz Plater profile** (`https://wago.io/whiiskeyzplater`) as a standalone nameplate module within VUI, ensuring it is "exactly identical" and includes all necessary textures.

### Step 5.1: In-Depth Analysis of Whiiskeyz Plater Profile
*   **A. Import and Study:** Import the Whiiskeyz Plater profile into the Plater addon in-game. Meticulously document its appearance for various unit types (friendly/enemy players, NPCs, different states like casting, debuffed, targeted, etc.).
*   **B. Deconstruct Profile:** Export the Plater profile and examine its structure. Plater profiles are complex tables of settings, scripts, and animations. Identify:
    *   Core visual elements: health bar textures, cast bar textures, class icons, debuff/buff icons and their styling, threat indicators, custom text displays.
    *   Custom Lua scripts: Understand what each script does (e.g., custom coloring, dynamic text, aura tracking, event reactions).
    *   Animations and conditional styling: How nameplates change based on unit status, auras, or combat events.
    *   Texture and Media Usage: Identify all custom textures, fonts, or sounds used. The user emphasized the need for "all the textures needed to be 100% identical."

### Step 5.2: Designing the VUI Plater Module
*   **A. Core Nameplate Handling:** WoW provides APIs for interacting with and modifying nameplates (`C_NamePlate.GetNamePlateForUnit`, events like `NAME_PLATE_UNIT_ADDED`, `NAME_PLATE_UNIT_REMOVED`). VUI Plater will need to hook into this system to apply its custom appearance.
*   **B. Replicating Visuals:**
    *   Recreate the textures, bars, icons, and text elements as defined by the Whiiskeyz profile. This will involve creating new frames and textures, and positioning them relative to the Blizzard nameplates.
    *   Media assets (textures, fonts) identified in Step 5.1.A must be acquired (extracted if licensing permits, recreated, or sourced as identical open alternatives) and stored in `/VUI/media/modules/VUIPlater/`.
*   **C. Re-implementing Logic:**
    *   Translate the logic from Plater's scripts and conditional settings into VUI Plater's Lua code. This is the most complex part and requires a deep understanding of both the Plater profile and WoW's combat event system and API.
    *   Event handling will be crucial for dynamic updates (e.g., auras, health changes, casting).
*   **D. Modularity:** Design VUI Plater to be a self-contained module within `/VUI/modules/VUIPlater/`.

### Step 5.3: Implementation of VUI Plater
*   **A. Iterative Development:** Start by replicating the basic structure and appearance of the nameplates for a single unit type (e.g., enemy NPC). Then, incrementally add features: cast bars, auras, class icons, target highlighting, threat, custom scripts, etc.
*   **B. Texture Management:** Ensure all textures are correctly pathed and loaded. If direct extraction from Plater/WeakAura is not feasible or permissible, the AI coder will need to find or create pixel-perfect replacements.
*   **C. Performance:** Nameplates update very frequently and for many units. Code must be highly optimized. Avoid creating excessive frames or running heavy calculations in frequently called functions. Use throttling and efficient event handling.

### Step 5.4: Configuration for VUI Plater
*   Following the user's earlier guidance (applied here as well), integrate VUI Plater's configuration into the main VUI settings panel. 
*   While the goal is an "exact replica" of Whiiskeyz Plater's look, decide on the level of customization to expose. A full replication of Plater's own extensive options for this single profile might be overly complex. Focus on options that allow users to toggle key features of the Whiiskeyz style or make minor adjustments, rather than rebuilding the entire Plater customization engine.
*   Examples: toggle specific aura displays, adjust colors if desired (though default should be Whiiskeyz), enable/disable certain script-driven effects if they become configurable elements.

### Step 5.5: Testing VUI Plater
*   Test extensively in various environments: crowded areas, dungeons, raids, PvP.
*   Verify appearance and behavior against the original Whiiskeyz Plater profile running in the Plater addon.
*   Check for Lua errors and performance issues (CPU/memory usage related to nameplates).

## 6. Phase 4: UI/UX Unification and Configuration Panel Enhancement (Formerly Phase 3)

With modules integrated/replicated, including VUI Plater, this phase focuses on refining the overall user experience.

### Step 6.1: Consistent UI Styling
Ensure all integrated modules, new VUI-specific frames, and VUI Plater adhere to a consistent visual style or can be themed by VUI's core styling options. This might involve:
*   Defining a VUI-specific texture pack, color palette, and font selection (leveraging `/VUI/media/`).
*   Creating template XML frames or Lua functions for UI elements.
*   Allowing user customization over VUI's appearance via the config panel.

### Step 6.2: Configuration Panel Overhaul
As per user request, the VUI configuration panel (extended from SUI's) needs to be highly organized, clear, and comprehensive, surpassing ElvUI's panel in usability.
*   **Structure:** Logical hierarchy: Main VUI section (general settings, styling, profiles), then clear categories for each module (e.g., "VUI - Buffs", "VUI - Consumables", "VUI - Plater").
*   **Layout:** Intuitive, efficient use of space, uncluttered.
*   **Common Controls:** Robust, reusable UI controls (checkboxes, sliders, dropdowns, color pickers, text inputs).
*   **Help Text/Tooltips:** Clear explanations for each option.
*   **Profiles:** Advanced profile system (save, load, share VUI configurations).

### Step 6.3: Slash Commands and Minimap Icon
*   Implement slash commands (e.g., `/vui` for options, `/vui help`, `/vui toggle module_name`).
*   Provide a minimap icon for config panel access (with hide option).

## 7. Phase 5: Testing, Debugging, and Performance Optimization (Formerly Phase 4)

### Step 7.1: Comprehensive Testing
*   Functional, scenario (solo, group, raid, PvP), and conflict testing (with other popular addons).
*   UI responsiveness and correctness.

### Step 7.2: Debugging
*   Use in-game error reporting and debugging tools.
*   Consider alpha/beta testing.

### Step 7.3: Performance Optimization
*   CPU profiling and memory management for all modules, especially VUI Plater and combat-heavy modules.
*   Efficient event handling and update throttling.

## 8. Phase 6: Documentation and Release Preparation (Formerly Phase 5)

### Step 8.1: Code Comments and Internal Documentation
Well-commented Lua code.

### Step 8.2: User Guide (Basic)
`README.md` covering installation, configuration, main features, bug reporting.

### Step 8.3: Packaging for Release
Clean directory, updated `.toc` (version, date), zip archive for distribution.

## 9. Ongoing Considerations & Best Practices (Formerly Phase 8)

### Step 9.1: Handling Updates from Original Addons
Manual monitoring and integration, or focus on feature parity. This is a significant ongoing task.

### Step 9.2: Licensing and Attribution
Review and comply with licenses of SUI and all integrated components. Include original licenses/copyrights and attribute authors.

### Step 9.3: Localization
English-only for now, but design with future localization in mind (externalize strings).

### Step 9.4: Community Feedback and Iteration
Gather feedback, fix bugs, consider future feature requests.

## 10. Conclusion (Formerly Phase 9)

Developing VUI is a substantial undertaking. This revised roadmap, incorporating the new VUI Plater and updated module names, provides a comprehensive guide for the AI coder. The emphasis remains on quality, stability, user experience, and meticulous replication of desired features.

--- 
*This roadmap is a living document and may be updated as development progresses and new information becomes available.*
