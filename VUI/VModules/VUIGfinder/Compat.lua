-------------------------------------------------------------------------------
-- VUI Gfinder (based on Premade Groups Filter)
-- Module for VUI - Vortex UI Addon Suite
-------------------------------------------------------------------------------

local VUI = _G.VUI
local Module = VUI:GetModule("VUIGfinder")
if not Module then return end

local VUIGfinder = _G.VUIGfinder
local L = VUIGfinder.L
local C = VUIGfinder.C

-- Helper functions that are used throughout the addon
function VUIGfinder.Empty(value)
    return value == nil or value == ""
end

function VUIGfinder.Table_Copy_Shallow(t)
    if not t then return nil end
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = v
    end
    return copy
end

function VUIGfinder.Table_Copy_Deep(t)
    if type(t) ~= "table" then return t end
    local copy = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            copy[k] = VUIGfinder.Table_Copy_Deep(v)
        else
            copy[k] = v
        end
    end
    return copy
end

function VUIGfinder.Table_Count(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

function VUIGfinder.String_Split(str, sep)
    local fields = {}
    local pattern = string.format("([^%s]+)", sep)
    str:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

function VUIGfinder.String_TrimWhitespace(str)
    return str:match("^%s*(.-)%s*$")
end

function VUIGfinder.GetMediaPath(subPath)
    return "Interface\\AddOns\\VUI\\media\\modules\\VUIGfinder\\" .. subPath
end

function VUIGfinder.FormatTime(seconds)
    if seconds < 60 then
        return string.format("%ds", seconds)
    elseif seconds < 3600 then
        return string.format("%dm %ds", math.floor(seconds/60), seconds%60)
    else
        return string.format("%dh %dm", math.floor(seconds/3600), math.floor((seconds%3600)/60))
    end
end

function VUIGfinder.GetDifficultyNameByID(difficultyID)
    if not difficultyID then return nil end
    local difficulty = C.DIFFICULTY_MAP[difficultyID]
    if not difficulty then return nil end
    
    if difficulty == C.NORMAL then
        return L["Normal"]
    elseif difficulty == C.HEROIC then
        return L["Heroic"]
    elseif difficulty == C.MYTHIC then
        return L["Mythic"]
    elseif difficulty == C.MYTHICPLUS then
        return L["Mythic+"]
    elseif difficulty == C.ARENA2V2 then
        return L["Arena 2v2"]
    elseif difficulty == C.ARENA3V3 then
        return L["Arena 3v3"]
    else
        return nil
    end
end

function VUIGfinder.GetClassColor(className)
    if not className then return nil end
    local color = RAID_CLASS_COLORS[className]
    if not color then return nil end
    return color.r, color.g, color.b
end

function VUIGfinder.IsMythicPlusActivity(activityID)
    if not activityID then return false end
    local activityInfo = C_LFGList.GetActivityInfoTable(activityID)
    if not activityInfo then return false end
    return C.DIFFICULTY_MAP[activityInfo.difficultyID] == C.MYTHICPLUS
end

function VUIGfinder.GetRatingInfoForSearchResult(resultID)
    if not resultID then return nil end
    local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
    if not searchResultInfo or not searchResultInfo.leaderName then return nil end
    
    -- In a real implementation, this would extract the rating info from the leader
    -- Since we don't have the actual game API available, we'll return placeholder values
    -- In the actual implementation, you would extract this info from the proper API
    return 0, 0, 0, 0
end