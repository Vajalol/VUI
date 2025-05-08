---@class VUIBuffs: AceModule
local VUIBuffs = LibStub("AceAddon-3.0"):GetAddon("VUIBuffs")
local L = VUIBuffs.L

-- Media paths
VUIBuffs.Media = {
    -- Bars
    Bars = {
        Smooth = "Interface\\AddOns\\VUI\\Media\\modules\\VUIBuffs\\bar\\smooth",
    },
    
    -- Borders
    Borders = {
        Default = "Interface\\AddOns\\VUI\\Media\\modules\\VUIBuffs\\border\\edge-default",
    },
    
    -- Icons
    Icons = {
        Default = "Interface\\AddOns\\VUI\\Media\\modules\\VUIBuffs\\icon\\vui_buffs",
    },
    
    -- Textures
    Textures = {
        Logo = "Interface\\AddOns\\VUI\\Media\\modules\\VUIBuffs\\textures\\logo",
        LogoTransparent = "Interface\\AddOns\\VUI\\Media\\modules\\VUIBuffs\\textures\\logo_transparent",
    },
}

-- Helper function to get media path
function VUIBuffs:GetMediaPath(mediaType, key)
    if not self.Media or not self.Media[mediaType] or not self.Media[mediaType][key] then
        return nil
    end
    
    return self.Media[mediaType][key]
end