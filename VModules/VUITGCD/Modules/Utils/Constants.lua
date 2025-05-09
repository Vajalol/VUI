-- VUITGCD Constants.lua
-- Contains constants and defaults for the VUITGCD module

local _, ns = ...
local VUITGCD = _G.VUI and _G.VUI.TGCD or {}

-- Define namespace if not created yet
if not ns.constants then ns.constants = {} end

-- Unit Types
ns.constants.unitTypes = {
    "player",
    "target",
    "focus",
    "party1",
    "party2",
    "party3",
    "party4",
    "arena1",
    "arena2",
    "arena3",
    "arena4",
    "arena5"
}

-- Default spell icon size
ns.constants.defaultIconSize = 30
ns.constants.maxIconsPerLine = 10
ns.constants.maxIconFadeAlpha = 0.5
ns.constants.defaultAlpha = 1.0

-- Default fade duration
ns.constants.defaultFadeDuration = 0.3

-- Default position anchor
ns.constants.defaultAnchor = "BOTTOMLEFT"

-- Default blocklist for spells that shouldn't be tracked
ns.constants.defaultBlocklist = {
    -- Auto attacks
    [6603] = true,   -- Auto Attack
    [75] = true,     -- Auto Shot
    
    -- Common buffs/procs that clutter the display
    [32362] = true,  -- Lava Surge
    [16246] = true,  -- Clearcasting
}

-- Layout types
ns.constants.layoutTypes = {
    "horizontal",
    "vertical"
}

-- Default scale factor 
ns.constants.defaultScale = 1.0

-- Media paths
ns.constants.mediaPath = function(file)
    return _G.VUI:GetMediaPath("modules/VUITGCD/" .. file)
end

-- Default glow effect
ns.constants.defaultGlowEffect = "blizz"
ns.constants.availableGlowEffects = {
    "none",
    "blizz",
    "pixel",
    "shine"
}

-- Default settings
ns.constants.defaultSettings = {
    enabled = true,
    iconSize = ns.constants.defaultIconSize,
    fadeTime = 3.0,
    maxIcons = 8,
    showCooldowns = true,
    showGlow = true,
    showTooltips = true,
    glowEffect = ns.constants.defaultGlowEffect,
    trackFriendlySpells = true,
    trackEnemySpells = true,
    showSpellNames = false
}

-- Export to global if needed
if _G.VUI then
    _G.VUI.TGCD.Constants = ns.constants
end