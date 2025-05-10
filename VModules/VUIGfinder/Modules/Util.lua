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

-- String split function
function Util.StringSplit(str, delimiter)
    local result = {}
    local pattern = "[^" .. delimiter .. "]+"
    
    for match in string.gmatch(str, pattern) do
        table.insert(result, match)
    end
    
    return result
end

-- String trim function
function Util.StringTrim(str)
    return str:match("^%s*(.-)%s*$")
end

-- Check if a string starts with a specified prefix
function Util.StringStartsWith(str, prefix)
    return string.sub(str, 1, string.len(prefix)) == prefix
end

-- Check if a string ends with a specified suffix
function Util.StringEndsWith(str, suffix)
    return suffix == "" or string.sub(str, -string.len(suffix)) == suffix
end

-- Check if a string contains a substring
function Util.StringContains(str, substring)
    return string.find(str, substring, 1, true) ~= nil
end

-- Deep copy a table
function Util.TableDeepCopy(orig)
    local orig_type = type(orig)
    local copy
    
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[Util.TableDeepCopy(orig_key)] = Util.TableDeepCopy(orig_value)
        end
        setmetatable(copy, Util.TableDeepCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    
    return copy
end

-- Merge two tables
function Util.TableMerge(t1, t2)
    for k, v in pairs(t2) do
        if type(v) == "table" and type(t1[k]) == "table" then
            Util.TableMerge(t1[k], v)
        else
            t1[k] = v
        end
    end
    
    return t1
end

-- Count number of elements in a table
function Util.TableCount(t)
    local count = 0
    
    for _ in pairs(t) do
        count = count + 1
    end
    
    return count
end

-- Check if a table is empty
function Util.TableIsEmpty(t)
    return next(t) == nil
end

-- Convert table to string for debugging
function Util.TableToString(t, indent)
    indent = indent or 0
    local result = string.rep("  ", indent) .. "{\n"
    
    for k, v in pairs(t) do
        result = result .. string.rep("  ", indent + 1)
        
        -- Format key
        if type(k) == "string" then
            result = result .. "[\"" .. k .. "\"] = "
        else
            result = result .. "[" .. tostring(k) .. "] = "
        end
        
        -- Format value
        if type(v) == "table" then
            result = result .. Util.TableToString(v, indent + 1) .. ",\n"
        elseif type(v) == "string" then
            result = result .. "\"" .. v .. "\",\n"
        else
            result = result .. tostring(v) .. ",\n"
        end
    end
    
    result = result .. string.rep("  ", indent) .. "}"
    return result
end

-- Convert a hex color to RGB (0-1)
function Util.HexToRGB(hex)
    hex = hex:gsub("#", "")
    
    local r = tonumber("0x" .. hex:sub(1, 2)) / 255
    local g = tonumber("0x" .. hex:sub(3, 4)) / 255
    local b = tonumber("0x" .. hex:sub(5, 6)) / 255
    
    return r, g, b
end

-- Convert RGB (0-1) to a hex color
function Util.RGBToHex(r, g, b)
    r = math.floor(r * 255 + 0.5)
    g = math.floor(g * 255 + 0.5)
    b = math.floor(b * 255 + 0.5)
    
    return string.format("#%02x%02x%02x", r, g, b)
end

-- Format a number with commas as thousands separators
function Util.FormatNumber(number)
    local formatted = tostring(number)
    local k
    
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    
    return formatted
end

-- Format a time in seconds to a human-readable string
function Util.FormatTime(seconds)
    if seconds < 60 then
        return string.format("%d s", seconds)
    elseif seconds < 3600 then
        local minutes = math.floor(seconds / 60)
        local remainingSeconds = seconds % 60
        return string.format("%d m %d s", minutes, remainingSeconds)
    else
        local hours = math.floor(seconds / 3600)
        local remainingMinutes = math.floor((seconds % 3600) / 60)
        return string.format("%d h %d m", hours, remainingMinutes)
    end
end

-- Format a timestamp as a date string
function Util.FormatDate(timestamp)
    return date("%Y-%m-%d %H:%M:%S", timestamp)
end

-- Extract a number from a string
function Util.ExtractNumber(str)
    local number = string.match(str, "(%d+)")
    return number and tonumber(number) or nil
end

-- Build a color code string for WoW UI
function Util.ColorToString(r, g, b, a)
    if type(r) == "table" then
        g = r.g
        b = r.b
        a = r.a
        r = r.r
    end
    
    a = a or 1
    
    return string.format("|c%02x%02x%02x%02x", a * 255, r * 255, g * 255, b * 255)
end

-- Debug function to print a value with type info
function Util.Print(label, value)
    if type(value) == "table" then
        print(label .. ": " .. Util.TableToString(value))
    else
        print(label .. ": " .. tostring(value) .. " (" .. type(value) .. ")")
    end
end