Purpose:
Perform a comprehensive diagnosis, validation, and cleanup of all modules in the VModules directory. This is to ensure no missing files, no incomplete logic, and no feature loss while maintaining high code quality and structural integrity.

📁 Modules to Audit
VUIAnyFrame

VUIAuctionator

VUIBuffs

VUICC

VUICD

VUIConsumables

VUIepf

VUIGfinder

VUIHealerMana

VUIIDs

VUIKeystones

VUIMissingRaidBuffs

VUIMouseFireTrail

VUINotifications

VUIPlater

VUIPositionOfPower

VUIScrollingText

VUITGCD

✅ What to Check in Each Module
1. Structure Audit
Verify all required source, config, and UI files are present.

Identify missing files that break functionality or integration.

Flag and report any orphaned or unused files.

2. Code Completeness
Ensure all functions, locals, and object definitions are:

Properly declared and implemented.

Free of TODO, FIXME, or placeholders.

Have working logic and consistent returns.

3. System Integration
Confirm module registers correctly (event hooks, slash commands, UI frames).

Ensure it responds to runtime triggers (e.g. frame updates, combat state).

Check dependencies on other modules or global managers.

4. Function Validation
Analyze every function:

Validate parameters, return types, and internal logic.

Ensure no dead code, infinite loops, or unhandled exceptions.

Refactor any clumsy or redundant logic into cleaner, reusable components.

5. Feature Preservation
Do NOT remove or simplify features unless they are explicitly deprecated.

If unsure about a feature’s purpose, flag it for human review.

Maintain original user-visible behavior and outputs.

6. Visual/UI Layer Check (if applicable)
Confirm UI frames/widgets are correctly created, positioned, and skinned.

Ensure responsiveness and no Lua UI errors on interaction.

⚠️ File Creation Rule
❗️Never create new files unless they are necessary to fix broken or incomplete functionality.
Only generate new files if:

A core component is missing.

It is essential for restoring or completing an expected behavior.

No existing file already serves the purpose.

Document each added file with:

Filename

Purpose

Justification

🧪 Deliverables
At the end of the audit, provide:

📋 Module Status Report:
For each module:

✅ Fully valid and polished

⚠️ Issues found (with short summary)

🛠️ Files added or corrected

📁 Changes Summary:
Total issues fixed

List of files added or restructured

List of flagged items needing review

🔁 Optional Enhancements
If time allows, also:

Improve comments and docstrings.

Normalize naming conventions and file naming.

Add logging for runtime validation (optional debug mode).

Highlight sections that can be modularized or offloaded to shared utilities.

