-------------------------------------------------------------------------------
-- Title: Mik's Scrolling Battle Text Core
-- Author: VortexQ8 (Original by Mikord)
-- Adapted for VUI integration
-------------------------------------------------------------------------------

local addonName, VUI = ...

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