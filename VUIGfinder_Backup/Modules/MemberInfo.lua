-------------------------------------------------------------------------------
-- VUI Gfinder (based on Premade Groups Filter)
-- Module for VUI - Vortex UI Addon Suite
-------------------------------------------------------------------------------

local VUI = _G.VUI
local Module = VUI:GetModule("VUIGfinder")
if not Module then return end

local VUIGfinder = _G.VUIGfinder
local L = VUIGfinder.L

-- Create MemberInfo namespace
VUIGfinder.MemberInfo = {}
local MemberInfo = VUIGfinder.MemberInfo
local Util = VUIGfinder.Util

-- Class colors
MemberInfo.CLASS_COLORS = {
    ["WARRIOR"]     = {r = 0.78, g = 0.61, b = 0.43},
    ["PALADIN"]     = {r = 0.96, g = 0.55, b = 0.73},
    ["HUNTER"]      = {r = 0.67, g = 0.83, b = 0.45},
    ["ROGUE"]       = {r = 1.00, g = 0.96, b = 0.41},
    ["PRIEST"]      = {r = 1.00, g = 1.00, b = 1.00},
    ["DEATHKNIGHT"] = {r = 0.77, g = 0.12, b = 0.23},
    ["SHAMAN"]      = {r = 0.00, g = 0.44, b = 0.87},
    ["MAGE"]        = {r = 0.25, g = 0.78, b = 0.92},
    ["WARLOCK"]     = {r = 0.53, g = 0.53, b = 0.93},
    ["MONK"]        = {r = 0.00, g = 1.00, b = 0.59},
    ["DRUID"]       = {r = 1.00, g = 0.49, b = 0.04},
    ["DEMONHUNTER"] = {r = 0.64, g = 0.19, b = 0.79},
    ["EVOKER"]      = {r = 0.20, g = 0.58, b = 0.50},
}

-- Role icons
MemberInfo.ROLE_ATLAS = {
    TANK = "groupfinder-icon-role-large-tank",
    HEALER = "groupfinder-icon-role-large-heal",
    DAMAGER = "groupfinder-icon-role-large-dps",
    NONE = "groupfinder-icon-emptyslot"
}

-- Get class color from a class name
function MemberInfo:GetClassColor(className)
    if not className then return {r = 1, g = 1, b = 1} end
    
    -- Convert to uppercase
    className = string.upper(className)
    
    -- Return class color or default white
    return self.CLASS_COLORS[className] or {r = 1, g = 1, b = 1}
end

-- Format a class name with color
function MemberInfo:GetColoredClassName(className)
    if not className then return "" end
    
    -- Convert to uppercase for table lookup
    local colorData = self:GetClassColor(className)
    
    -- Get localized class name
    local localizedClass = LOCALIZED_CLASS_NAMES_MALE[string.upper(className)] or className
    
    -- Format with color
    return string.format("|cff%02x%02x%02x%s|r",
        math.floor(colorData.r * 255),
        math.floor(colorData.g * 255),
        math.floor(colorData.b * 255),
        localizedClass)
end

-- Get formatted member info string
function MemberInfo:GetMemberInfo(memberInfo)
    if not memberInfo then return "" end
    
    local result = ""
    
    -- Add role icon if available
    if memberInfo.role then
        local roleIcon = self.ROLE_ATLAS[memberInfo.role]
        if roleIcon then
            result = result .. CreateAtlasMarkup(roleIcon, 16, 16) .. " "
        end
    end
    
    -- Add class color and name
    if memberInfo.class then
        result = result .. self:GetColoredClassName(memberInfo.class)
    elseif memberInfo.name then
        result = result .. memberInfo.name
    end
    
    -- Add level if available
    if memberInfo.level and memberInfo.level > 0 then
        result = result .. " (" .. memberInfo.level .. ")"
    end
    
    -- Add item level if available
    if memberInfo.itemLevel and memberInfo.itemLevel > 0 then
        result = result .. " [" .. math.floor(memberInfo.itemLevel) .. "]"
    end
    
    return result
end

-- Format group composition string
function MemberInfo:GetGroupComposition(searchResult)
    if not searchResult then return "" end
    
    local result = ""
    
    -- Format as T/H/D
    local tanks = searchResult.numTanks or 0
    local healers = searchResult.numHealers or 0
    local dps = searchResult.numDamagers or 0
    local total = searchResult.numMembers or 0
    
    -- Tank info with coloring based on slots
    if tanks == searchResult.maxTanks then
        result = result .. "|cff00ff00" .. tanks .. "/" .. searchResult.maxTanks .. "|r"
    else
        result = result .. "|cffff9900" .. tanks .. "/" .. searchResult.maxTanks .. "|r"
    end
    
    result = result .. " "
    
    -- Healer info with coloring based on slots
    if healers == searchResult.maxHealers then
        result = result .. "|cff00ff00" .. healers .. "/" .. searchResult.maxHealers .. "|r"
    else
        result = result .. "|cffff9900" .. healers .. "/" .. searchResult.maxHealers .. "|r"
    end
    
    result = result .. " "
    
    -- DPS info with coloring based on slots
    if dps == searchResult.maxDamagers then
        result = result .. "|cff00ff00" .. dps .. "/" .. searchResult.maxDamagers .. "|r"
    else
        result = result .. "|cffff9900" .. dps .. "/" .. searchResult.maxDamagers .. "|r"
    end
    
    -- Total members
    result = result .. " (" .. total .. ")"
    
    return result
end

-- Get leader info string
function MemberInfo:GetLeaderInfo(searchResult)
    if not searchResult or not searchResult.leaderName then
        return ""
    end
    
    local result = searchResult.leaderName
    
    -- Add class color if available
    if searchResult.leaderClass then
        result = self:GetColoredClassName(searchResult.leaderClass)
    end
    
    return result
end