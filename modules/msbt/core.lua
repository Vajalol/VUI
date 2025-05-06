-------------------------------------------------------------------------------
-- Title: Mik's Scrolling Battle Text Core
-- Author: VortexQ8 (Original by Mikord)
-- Adapted for VUI integration
-------------------------------------------------------------------------------

local addonName, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end

-- Create mod namespace and set its name.
local mod = {}
local modName = "MikSBT"
_G[modName] = mod


-------------------------------------------------------------------------------
-- Imports.
-------------------------------------------------------------------------------

-- Local references to various functions for faster access.
local string_find = string.find
local string_sub = string.sub
local string_gsub = string.gsub
local string_match = string.match
local math_floor = math.floor
local GetSpellInfo = GetSpellInfo


-------------------------------------------------------------------------------
-- Mod constants
-------------------------------------------------------------------------------

-- Version information adapted for VUI
local MODULE_VERSION = "5.8.1"
mod.VERSION = 5.8
mod.VERSION_STRING = "v" .. MODULE_VERSION
mod.SVN_REVISION = 1
mod.CLIENT_VERSION = tonumber((select(4, GetBuildInfo())))

mod.COMMAND = "/msbt"

-------------------------------------------------------------------------------
-- Localization.
-------------------------------------------------------------------------------

-- Holds localized strings.
local translations = {}


-------------------------------------------------------------------------------
-- Theme Support
-------------------------------------------------------------------------------

-- Theme support for VUI integration
local function ApplyTheme()
    local currentTheme = VUI.db.profile.appearance.theme or "thunderstorm"
    
    -- Register theme-specific sounds
    if currentTheme == "phoenixflame" then
        mod.Media.RegisterSound("MSBT Low Health", "Interface\\Addons\\VUI\\media\\sounds\\phoenixflame\\msbt\\LowHealth.ogg")
        mod.Media.RegisterSound("MSBT Low Mana", "Interface\\Addons\\VUI\\media\\sounds\\phoenixflame\\msbt\\LowMana.ogg")
        mod.Media.RegisterSound("MSBT Cooldown", "Interface\\Addons\\VUI\\media\\sounds\\phoenixflame\\msbt\\Cooldown.ogg")
        mod.Media.RegisterSound("MSBT Crit", "Interface\\Addons\\VUI\\media\\sounds\\phoenixflame\\msbt\\Crit.ogg")
        mod.Media.RegisterSound("MSBT Proc", "Interface\\Addons\\VUI\\media\\sounds\\phoenixflame\\msbt\\Proc.ogg")
        mod.Media.RegisterSound("MSBT Dodge", "Interface\\Addons\\VUI\\media\\sounds\\phoenixflame\\msbt\\Dodge.ogg")
        mod.Media.RegisterSound("MSBT Parry", "Interface\\Addons\\VUI\\media\\sounds\\phoenixflame\\msbt\\Parry.ogg")
        mod.Media.RegisterSound("MSBT Block", "Interface\\Addons\\VUI\\media\\sounds\\phoenixflame\\msbt\\Block.ogg")
        mod.Media.RegisterSound("MSBT Heal", "Interface\\Addons\\VUI\\media\\sounds\\phoenixflame\\msbt\\Heal.ogg")
    elseif currentTheme == "thunderstorm" then
        mod.Media.RegisterSound("MSBT Low Health", "Interface\\Addons\\VUI\\media\\sounds\\thunderstorm\\msbt\\LowHealth.ogg")
        mod.Media.RegisterSound("MSBT Low Mana", "Interface\\Addons\\VUI\\media\\sounds\\thunderstorm\\msbt\\LowMana.ogg")
        mod.Media.RegisterSound("MSBT Cooldown", "Interface\\Addons\\VUI\\media\\sounds\\thunderstorm\\msbt\\Cooldown.ogg")
        mod.Media.RegisterSound("MSBT Crit", "Interface\\Addons\\VUI\\media\\sounds\\thunderstorm\\msbt\\Crit.ogg")
        mod.Media.RegisterSound("MSBT Proc", "Interface\\Addons\\VUI\\media\\sounds\\thunderstorm\\msbt\\Proc.ogg")
        mod.Media.RegisterSound("MSBT Dodge", "Interface\\Addons\\VUI\\media\\sounds\\thunderstorm\\msbt\\Dodge.ogg")
        mod.Media.RegisterSound("MSBT Parry", "Interface\\Addons\\VUI\\media\\sounds\\thunderstorm\\msbt\\Parry.ogg")
        mod.Media.RegisterSound("MSBT Block", "Interface\\Addons\\VUI\\media\\sounds\\thunderstorm\\msbt\\Block.ogg")
        mod.Media.RegisterSound("MSBT Heal", "Interface\\Addons\\VUI\\media\\sounds\\thunderstorm\\msbt\\Heal.ogg")
    elseif currentTheme == "arcanemystic" then
        mod.Media.RegisterSound("MSBT Low Health", "Interface\\Addons\\VUI\\media\\sounds\\arcanemystic\\msbt\\LowHealth.ogg")
        mod.Media.RegisterSound("MSBT Low Mana", "Interface\\Addons\\VUI\\media\\sounds\\arcanemystic\\msbt\\LowMana.ogg")
        mod.Media.RegisterSound("MSBT Cooldown", "Interface\\Addons\\VUI\\media\\sounds\\arcanemystic\\msbt\\Cooldown.ogg")
        mod.Media.RegisterSound("MSBT Crit", "Interface\\Addons\\VUI\\media\\sounds\\arcanemystic\\msbt\\Crit.ogg")
        mod.Media.RegisterSound("MSBT Proc", "Interface\\Addons\\VUI\\media\\sounds\\arcanemystic\\msbt\\Proc.ogg")
        mod.Media.RegisterSound("MSBT Dodge", "Interface\\Addons\\VUI\\media\\sounds\\arcanemystic\\msbt\\Dodge.ogg")
        mod.Media.RegisterSound("MSBT Parry", "Interface\\Addons\\VUI\\media\\sounds\\arcanemystic\\msbt\\Parry.ogg")
        mod.Media.RegisterSound("MSBT Block", "Interface\\Addons\\VUI\\media\\sounds\\arcanemystic\\msbt\\Block.ogg")
        mod.Media.RegisterSound("MSBT Heal", "Interface\\Addons\\VUI\\media\\sounds\\arcanemystic\\msbt\\Heal.ogg")
    elseif currentTheme == "felenergy" then
        mod.Media.RegisterSound("MSBT Low Health", "Interface\\Addons\\VUI\\media\\sounds\\felenergy\\msbt\\LowHealth.ogg")
        mod.Media.RegisterSound("MSBT Low Mana", "Interface\\Addons\\VUI\\media\\sounds\\felenergy\\msbt\\LowMana.ogg")
        mod.Media.RegisterSound("MSBT Cooldown", "Interface\\Addons\\VUI\\media\\sounds\\felenergy\\msbt\\Cooldown.ogg")
        mod.Media.RegisterSound("MSBT Crit", "Interface\\Addons\\VUI\\media\\sounds\\felenergy\\msbt\\Crit.ogg")
        mod.Media.RegisterSound("MSBT Proc", "Interface\\Addons\\VUI\\media\\sounds\\felenergy\\msbt\\Proc.ogg")
        mod.Media.RegisterSound("MSBT Dodge", "Interface\\Addons\\VUI\\media\\sounds\\felenergy\\msbt\\Dodge.ogg")
        mod.Media.RegisterSound("MSBT Parry", "Interface\\Addons\\VUI\\media\\sounds\\felenergy\\msbt\\Parry.ogg")
        mod.Media.RegisterSound("MSBT Block", "Interface\\Addons\\VUI\\media\\sounds\\felenergy\\msbt\\Block.ogg")
        mod.Media.RegisterSound("MSBT Heal", "Interface\\Addons\\VUI\\media\\sounds\\felenergy\\msbt\\Heal.ogg")
    else
        -- Fallback to default sounds
        mod.Media.RegisterSound("MSBT Low Health", "Interface\\Addons\\VUI\\media\\sounds\\msbt\\LowHealth.ogg")
        mod.Media.RegisterSound("MSBT Low Mana", "Interface\\Addons\\VUI\\media\\sounds\\msbt\\LowMana.ogg")
        mod.Media.RegisterSound("MSBT Cooldown", "Interface\\Addons\\VUI\\media\\sounds\\msbt\\Cooldown.ogg")
        mod.Media.RegisterSound("MSBT Crit", "Interface\\Addons\\VUI\\media\\sounds\\msbt\\Crit.ogg")
        mod.Media.RegisterSound("MSBT Proc", "Interface\\Addons\\VUI\\media\\sounds\\msbt\\Proc.ogg")
        mod.Media.RegisterSound("MSBT Dodge", "Interface\\Addons\\VUI\\media\\sounds\\msbt\\Dodge.ogg")
        mod.Media.RegisterSound("MSBT Parry", "Interface\\Addons\\VUI\\media\\sounds\\msbt\\Parry.ogg")
        mod.Media.RegisterSound("MSBT Block", "Interface\\Addons\\VUI\\media\\sounds\\msbt\\Block.ogg")
        mod.Media.RegisterSound("MSBT Heal", "Interface\\Addons\\VUI\\media\\sounds\\msbt\\Heal.ogg")
    end
    
    -- Apply theme textures as well
    -- Animation paths and other theme-specific textures will be updated here
end

mod.ApplyTheme = ApplyTheme

-------------------------------------------------------------------------------
-- Utility Functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Returns whether or not the passed condition evaluates to true.
-- ****************************************************************************
local function TestBit(value, condition)
    return (bit.band(value, condition) == condition)
end


-- ****************************************************************************
-- Takes an amount and makes sure it fits inside the constraints of a signed 32-bit
-- integer for correct truncation.
-- ****************************************************************************
local function ConstrainAmount(amount)
    if (amount < -2147483648) then
        return -2147483648
    elseif (amount > 2147483647) then
        return 2147483647
    end

    return amount
end


-- ****************************************************************************
-- Erase the passed table.
-- ****************************************************************************
local function EraseTable(t)
    for k in pairs(t) do
        t[k] = nil
    end
    return t
end
mod.EraseTable = EraseTable


-- ****************************************************************************
-- Looks up a spell ID and returns the appropriate skill name.
-- ****************************************************************************
local function GetSkillName(spellId)
    return GetSpellInfo(spellId) or tostring(spellId)
end
mod.GetSkillName = GetSkillName


-- ****************************************************************************
-- Returns a shortened version of an amount.
-- ****************************************************************************
local function ShortenNumber(number)
    if number >= 1000000 then
        return string.format("%.1fm", number / 1000000)
    elseif number >= 1000 then
        return string.format("%.1fk", number / 1000)
    end
    return tostring(number)
end
mod.ShortenNumber = ShortenNumber


-- ****************************************************************************
-- Returns a number with thousand separators.
-- ****************************************************************************
local function SeparateNumber(amount)
    local separator = mod.translations["THOUSAND_SEPARATOR"] or ","
    local amount_string = tostring(amount)
        
    if amount_string:match("%.") then
        local left_part, right_part = amount_string:match("^([^.]*)%.(.*)$")
        return left_part:reverse():gsub("(%d%d%d)", "%1" .. separator):reverse():gsub("^" .. separator, "") .. "." .. right_part
    else
        return amount_string:reverse():gsub("(%d%d%d)", "%1" .. separator):reverse():gsub("^" .. separator, "")
    end
end
mod.SeparateNumber = SeparateNumber

-- ****************************************************************************
-- Format a number to be printed.
-- ****************************************************************************
local function FormatNumber(amount, profile)
    -- Return shortened version of the number of configured to do so.
    if (profile.shortenNumbers) then return ShortenNumber(amount) end

    -- Return the separated version of the number if configured to do so.
    if (profile.formattedNumbers) then return SeparateNumber(amount) end
    
    -- Return the normal amount.
    return amount
end
mod.FormatNumber = FormatNumber