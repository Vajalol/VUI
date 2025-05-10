Purpose:
Perform a comprehensive diagnosis, validation, and cleanup of all modules in the VModules directory. This is to ensure no missing files, no incomplete logic, and no feature loss while maintaining high code quality and structural integrity.

📁 Modules to Audit
1. ✅ VUIAnyFrame    ( From https://github.com/d4kir92/MoveAny )  goal is 100% identical same feautres but we rename it to VUIAnyFrame and make it intgrate with our addon VUI.
2. ✅ VUIAuctionator  ( From https://github.com/Auctionator/Auctionator ) goal is 100% identical same feautres but we rename it to Auctionator and make it intgrate with our addon VUI.
3. ✅ VUIBuffs       ( From by https://github.com/clicketz/buff-overlay ) goal is 100% identical same feautres but we rename it to VUIBuffs and make it intgrate with our addon VUI.
4. ✅ VUICC     ( From by https://github.com/tullamods/OmniCC )  goal is 100% identical same feautres but we rename it to VUICC and make it intgrate with our addon VUI.
5. ✅ VUICD   ( From https://www.curseforge.com/wow/addons/omnicd/download/6411074 ) goal is 100% identical same feautres but we rename it to VUICD and make it intgrate with our addon VUI.
6. ✅ VUIConsumables ( From  https://wago.io/MTSDyaGz9 ) goal is 100% identical we rename this module to VUI Consumables.
7. ✅ VUIepf ( From https://www.curseforge.com/wow/addons/epf-enhanced/download/6305501 ) goal is 100% identical same feautres but we rename it to VUIepf and make it intgrate with our addon VUI.
8. ✅ VUIGfinder ( From https://www.curseforge.com/wow/addons/premade-group-finder/download/6270586 ) goal is 100% identical same feautres but we rename it to VUIGfinder and make it intgrate with our addon VUI.
9. ✅ VUIHealerMana ( From https://wago.io/ebWkTh8By ) goal is 100% identical we rename this module to VUI Healer Mana.
10. ✅ VUIIDs   ( From https://github.com/wow-addon/idTip ) goal is 100% identical same feautres but we rename it to VUIIDs and make it intgrate with our addon VUI.
11. ✅ VUIKeystones ( From https://github.com/Ermad/angry-keystones ) goal is 100% identical we rename it to VUIKeystones and make it intgrate with our addon VUI.
12. ✅ VUIMissingRaidBuffs ( From https://wago.io/BQce7Fj5J ) goal is 100% identical we rename this module to VUI Missing Raid Buffs.
13. ✅ VUIMouseFireTrail ( From https://wago.io/RzZVq4F1a ) goal is 100% identical we rename this module to VUI mouse fire trail.
14. ✅ VUINotifications ( From https://github.com/jobackman/SpellNotifications ) goal is 100% identical same feautres but we rename it to VUINotifications and make it intgrate with our addon VUI.
15. ✅ VUIPlater ( From https://wago.io/whiiskeyzplater ) goal is 100% identical should provide all the textures needed to be 100% identical and we name it VUI Plater.
16. ✅ VUIPositionOfPower ( From  https://wago.io/MTSDyaGz9 ) goal is 100% identical we rename this module to VUI Position of Power.
17. ✅ VUIScrollingText  ( From https://www.curseforge.com/wow/addons/mik-scrolling-battle-text/download/5781390 ) goal is 100% identical same feautres but we rename it to VUIScrollingText and make it intgrate with our addon VUI.
18. ✅ VUITGCD    ( From https://github.com/Trufi/TrufiGCD ) goal is 100% identical same feautres but we rename it to VUITGCD and make it intgrate with our addon VUI.

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
❗️Never create new files unless they are necessary or incomplete Module and take it from the Module orginal source and edit it if needed
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

