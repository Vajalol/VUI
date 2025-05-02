--[[
    VUI - Module Icons
    Author: VortexQ8
    
    This file defines the icons for each module in the VUI addon suite.
    These icons are used in the main configuration interface.
]]

local _, VUI = ...

-- Module Icons Table
-- Using standard WoW icons that match each module's functionality
VUI.ModuleIcons = {
    -- Core modules
    ["chat"] = "Interface\\Icons\\INV_Misc_Note_01",
    
    -- Primary modules
    ["buffoverlay"] = "Interface\\Icons\\Spell_Holy_DivineSpirit",
    ["trufigcd"] = "Interface\\Icons\\Ability_Rogue_QuickRecovery",
    ["moveany"] = "Interface\\Icons\\INV_Misc_EngGizmos_30",
    ["auctionator"] = "Interface\\Icons\\INV_Misc_Coin_01",
    ["angrykeystone"] = "Interface\\Icons\\INV_Relics_Hourglass",
    ["omnicc"] = "Interface\\Icons\\Spell_Nature_TimeStop",
    ["omnicd"] = "Interface\\Icons\\Ability_Creature_Cursed_04",
    ["idtip"] = "Interface\\Icons\\INV_Misc_QuestionMark",
    ["premadegroupfinder"] = "Interface\\Icons\\Achievement_GuildPerk_EverybodysFriend",
    ["detailsskin"] = "Interface\\Icons\\INV_Misc_Book_11",
    ["msbt"] = "Interface\\Icons\\Spell_Shadow_SoulLeech_2",
    ["multinotification"] = "Interface\\Icons\\Spell_Nature_EarthBind"
}

-- Function to get a module's icon
function VUI:GetModuleIcon(moduleName)
    -- Return the icon for the specified module, or a default icon if not found
    return VUI.ModuleIcons[moduleName] or "Interface\\Icons\\INV_Misc_QuestionMark"
end