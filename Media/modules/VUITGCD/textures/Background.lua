-- Background texture file for VUITGCD module
local addonName, VUI = ...

if not VUI.Media then VUI.Media = {} end
if not VUI.Media.VUITGCD then VUI.Media.VUITGCD = {} end

-- Register textures
VUI.Media.VUITGCD.Textures = {
    -- Background for icon frames
    Background = "Interface\\AddOns\\VUI\\Media\\modules\\VUITGCD\\textures\\background",
    -- Cross texture for canceled spells
    Cross = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_7",
    -- Default frame border
    Border = "Interface\\AddOns\\VUI\\Media\\Textures\\borders\\border-tooltip",
    -- Default glow effect
    Glow = "Interface\\AddOns\\VUI\\Media\\Textures\\glow\\glow_square"
}

-- Texture paths for compatibility with original TrufiGCD
if _G.VUITGCD then
    _G.VUITGCD.Textures = VUI.Media.VUITGCD.Textures
end 