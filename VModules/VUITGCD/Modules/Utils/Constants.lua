-- VUITGCD Constants.lua
-- Contains constants and defaults for the VUITGCD module

local _, ns = ...
<<<<<<< HEAD
local addonName, VUI = ...

-- Create TGCD namespace if it doesn't exist
if _G.VUI and not _G.VUI.TGCD then
    _G.VUI.TGCD = {}
end
local VUITGCD = _G.VUI and _G.VUI.TGCD or {}
=======
local VUITGCD = _G.VUI and (_G.VUI.VUITGCD or _G.VUI:GetModule("VUITGCD")) or {}
>>>>>>> f2841d4c299e00869d4563d9e99c5e582069affc

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

-- Media paths - use VUI media system
ns.constants.mediaPath = function(file)
    if not _G.VUI or not _G.VUI.GetMediaPath then
        return "Interface\\AddOns\\VUI\\Media\\modules\\VUITGCD\\" .. file
    end
    return _G.VUI:GetMediaPath("modules/VUITGCD/" .. file)
end

-- Get texture from VUI Media system if available
local function GetTexturePath(texture)
    if VUI and VUI.Media and VUI.Media.VUITGCD and VUI.Media.VUITGCD.Textures and VUI.Media.VUITGCD.Textures[texture] then
        return VUI.Media.VUITGCD.Textures[texture]
    else
        -- Fallbacks for common textures
        if texture == "background" then
            return "Interface\\AddOns\\VUI\\Media\\modules\\VUITGCD\\textures\\background"
        elseif texture == "cross" then
            return "Interface\\TargetingFrame\\UI-RaidTargetingIcon_7"
        elseif texture == "border" then
            return "Interface\\AddOns\\VUI\\Media\\Textures\\borders\\border-tooltip"
        elseif texture == "glow" then
            return "Interface\\AddOns\\VUI\\Media\\Textures\\glow\\glow_square"
        end
        return texture
    end
end

-- Default texture paths
ns.constants.textures = {
    background = GetTexturePath("Background"),
    cross = GetTexturePath("Cross"),
    border = GetTexturePath("Border"),
    glow = GetTexturePath("Glow")
}

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
    -- Make sure TGCD exists
    _G.VUI.TGCD = _G.VUI.TGCD or {}
    _G.VUI.TGCD.Constants = ns.constants
    
    -- Export to VUITGCD global as well for compatibility
    if not _G.VUITGCD then _G.VUITGCD = {} end
    _G.VUITGCD.Constants = ns.constants
    
    -- Connect to VUI media system
    if VUI.Media and VUI.Media.VUITGCD and VUI.Media.VUITGCD.Textures then
        -- Update textures using the media system
        ns.constants.textures = {
            background = VUI.Media.VUITGCD.Textures.Background,
            cross = VUI.Media.VUITGCD.Textures.Cross,
            border = VUI.Media.VUITGCD.Textures.Border,
            glow = VUI.Media.VUITGCD.Textures.Glow
        }
        
        -- Make textures available in the global namespace for legacy code
        if _G.VUITGCD then
            _G.VUITGCD.Textures = VUI.Media.VUITGCD.Textures
        end
    end
end