-------------------------------------------------------------------------------
-- VUI Gfinder (based on Premade Groups Filter)
-- Module for VUI - Vortex UI Addon Suite
-------------------------------------------------------------------------------

local VUI = _G.VUI
local Module = VUI:GetModule("VUIGfinder")
if not Module then return end

local VUIGfinder = _G.VUIGfinder
local L = VUIGfinder.L

-- Create Util namespace
VUIGfinder.Util = {}
local Util = VUIGfinder.Util

-- String utilities

-- Trim whitespace from the beginning and end of a string
function Util.StringTrim(str)
    return str:match("^%s*(.-)%s*$")
end

-- Split a string into tokens by separators
function Util.StringSplit(str, sep)
    local tokens = {}
    local pattern = string.format("([^%s]+)", sep)
    for token in string.gmatch(str, pattern) do
        table.insert(tokens, token)
    end
    return tokens
end

-- Table utilities

-- Deep copy a table
function Util.TableCopy(orig)
    local copy
    if type(orig) == "table" then
        copy = {}
        for k, v in pairs(orig) do
            copy[k] = Util.TableCopy(v)
        end
    else
        copy = orig
    end
    return copy
end

-- Merge two tables (simple, non-recursive)
function Util.TableMerge(t1, t2)
    local result = Util.TableCopy(t1)
    for k, v in pairs(t2) do
        result[k] = v
    end
    return result
end

-- Check if table contains value
function Util.TableContains(table, value)
    for _, v in pairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

-- Count elements in table
function Util.TableCount(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

-- Get table keys as array
function Util.TableKeys(table)
    local keys = {}
    for k in pairs(table) do
        table.insert(keys, k)
    end
    return keys
end

-- Game utilities

-- Check if in a group
function Util.IsInGroup()
    return IsInGroup() or IsInRaid()
end

-- Get player spec ID
function Util.GetPlayerSpecID()
    local specID = GetSpecialization()
    if specID then
        return GetSpecializationInfo(specID)
    end
    return nil
end

-- Get player item level
function Util.GetPlayerItemLevel()
    local _, equipped = GetAverageItemLevel()
    return math.floor(equipped or 0)
end

-- Get player role
function Util.GetPlayerRole()
    local role = UnitGroupRolesAssigned("player")
    if role == "NONE" then
        local spec = Util.GetPlayerSpecID()
        if spec then
            -- Try to determine role from spec if not in group
            local _, _, _, _, role = GetSpecializationInfoByID(spec)
            return role
        end
    end
    return role
end

-- Get faction name
function Util.GetFactionName()
    local faction = UnitFactionGroup("player")
    if faction == "Alliance" then
        return FACTION_ALLIANCE
    elseif faction == "Horde" then
        return FACTION_HORDE
    else
        return FACTION_NEUTRAL
    end
end

-- Format time
function Util.FormatTime(seconds)
    if not seconds or seconds <= 0 then
        return "0s"
    elseif seconds < 60 then
        return string.format("%ds", seconds)
    elseif seconds < 3600 then
        return string.format("%dm %ds", math.floor(seconds/60), seconds%60)
    else
        return string.format("%dh %dm", math.floor(seconds/3600), math.floor((seconds%3600)/60))
    end
end

-- Version utilities

-- Compare version strings
function Util.CompareVersions(v1, v2)
    local v1parts = Util.StringSplit(v1, ".")
    local v2parts = Util.StringSplit(v2, ".")
    
    for i = 1, math.max(#v1parts, #v2parts) do
        local v1part = tonumber(v1parts[i] or "0") or 0
        local v2part = tonumber(v2parts[i] or "0") or 0
        
        if v1part > v2part then
            return 1
        elseif v1part < v2part then
            return -1
        end
    end
    
    return 0
end