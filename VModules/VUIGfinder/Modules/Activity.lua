-------------------------------------------------------------------------------
-- VUI Gfinder (based on Premade Groups Filter)
-- Module for VUI - Vortex UI Addon Suite
-------------------------------------------------------------------------------

local VUI = _G.VUI
local Module = VUI:GetModule("VUIGfinder")
if not Module then return end

local VUIGfinder = _G.VUIGfinder
local L = VUIGfinder.L

-- Create Activity namespace
VUIGfinder.Activity = {}
local Activity = VUIGfinder.Activity

-- Activity categories
Activity.CATEGORY = {
    QUESTING = 1,
    DUNGEON = 2,
    RAID = 3,
    ARENA = 4,
    RATED_BG = 5,
    CUSTOM_PVE = 6,
    CUSTOM_PVP = 7,
    SKIRMISH = 8,
    BATTLEGROUND = 9,
    ISLAND = 10,
    SCENARIO = 11,
}

-- Difficulty levels
Activity.DIFFICULTY = {
    NORMAL = 1,
    HEROIC = 2,
    MYTHIC = 3,
    MYTHICPLUS = 4,
    TIMEWALKING = 5,
}

-- Activity info cache
local activityInfoCache = {}

-- Get activity info (with caching)
function Activity:GetActivityInfo(activityID)
    if not activityID then return nil end
    
    -- Check cache first
    if activityInfoCache[activityID] then
        return activityInfoCache[activityID]
    end
    
    -- Look up activity info
    local info = C_LFGList.GetActivityInfoTable(activityID)
    
    if info then
        -- Cache the result
        activityInfoCache[activityID] = info
        return info
    end
    
    return nil
end

-- Get activity name
function Activity:GetActivityName(activityID)
    local info = self:GetActivityInfo(activityID)
    return info and info.fullName or tostring(activityID)
end

-- Get activity group name
function Activity:GetActivityGroupName(activityID)
    local info = self:GetActivityInfo(activityID)
    return info and info.groupFinderActivityGroupInfo and info.groupFinderActivityGroupInfo.name or ""
end

-- Get activity category
function Activity:GetActivityCategory(activityID)
    local info = self:GetActivityInfo(activityID)
    return info and info.categoryID or 0
end

-- Get activity difficulty
function Activity:GetActivityDifficulty(activityID)
    local info = self:GetActivityInfo(activityID)
    local difficultyID = info and info.difficultyID or 0
    
    -- Map difficulty ID to our constants
    if difficultyID == 1 or difficultyID == 3 or difficultyID == 4 or difficultyID == 14 then
        return self.DIFFICULTY.NORMAL
    elseif difficultyID == 2 or difficultyID == 5 or difficultyID == 6 or difficultyID == 15 then
        return self.DIFFICULTY.HEROIC
    elseif difficultyID == 16 or difficultyID == 23 then
        return self.DIFFICULTY.MYTHIC
    elseif difficultyID == 8 then
        return self.DIFFICULTY.MYTHICPLUS
    elseif difficultyID == 24 then
        return self.DIFFICULTY.TIMEWALKING
    else
        return 0
    end
end

-- Get minimum item level for an activity
function Activity:GetActivityMinItemLevel(activityID)
    local info = self:GetActivityInfo(activityID)
    return info and info.minItemLevel or 0
end

-- Is this activity a dungeon?
function Activity:IsDungeonActivity(activityID)
    local category = self:GetActivityCategory(activityID)
    return category == self.CATEGORY.DUNGEON
end

-- Is this activity a raid?
function Activity:IsRaidActivity(activityID)
    local category = self:GetActivityCategory(activityID)
    return category == self.CATEGORY.RAID
end

-- Is this activity PvP related?
function Activity:IsPvPActivity(activityID)
    local category = self:GetActivityCategory(activityID)
    return category == self.CATEGORY.ARENA or 
           category == self.CATEGORY.RATED_BG or 
           category == self.CATEGORY.CUSTOM_PVP or 
           category == self.CATEGORY.SKIRMISH or 
           category == self.CATEGORY.BATTLEGROUND
end

-- Get minimum key level from Mythic+ listing name
function Activity:GetMythicPlusLevelFromName(name)
    if not name then return 0 end
    
    -- Extract key level from activity name
    local keyLevel = name:match("+%s*(%d+)")
    if keyLevel then
        return tonumber(keyLevel) or 0
    end
    
    -- Alternate format possibility
    keyLevel = name:match("(%d+)%s*[+]")
    if keyLevel then
        return tonumber(keyLevel) or 0
    end
    
    return 0
end