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

-- Create Activity namespace
VUIGfinder.Activity = {}
local Activity = VUIGfinder.Activity

-- Category IDs
Activity.CATEGORY_DUNGEON = 2
Activity.CATEGORY_RAID = 3
Activity.CATEGORY_ARENA = 4
Activity.CATEGORY_SCENARIO = 6
Activity.CATEGORY_PVP = 5 -- PvP
Activity.CATEGORY_CUSTOM = 7 -- Custom
Activity.CATEGORY_RATED_BG = 8 -- Rated BG
Activity.CATEGORY_ISLAND = 9 -- Island Expedition
Activity.CATEGORY_PVE = 1

-- Difficulty levels
Activity.DIFFICULTY = {
    NORMAL = 1,
    HEROIC = 2,
    MYTHIC = 3,
    MYTHICPLUS = 4,
    ARENA2V2 = 5,
    ARENA3V3 = 6,
    ARENA5V5 = 7,
}

-- Create a cache for activity info (name, group, category)
Activity.cache = {}

-- Initialize the activity cache
function Activity:Initialize()
    self.cache = {}
end

-- Get activity name from ID
function Activity:GetActivityName(activityID)
    if not activityID then return nil end
    
    -- Check cache first
    if self.cache[activityID] and self.cache[activityID].name then
        return self.cache[activityID].name
    end
    
    -- Get from API
    local activityInfo = C_LFGList.GetActivityInfoTable(activityID)
    if activityInfo then
        -- Cache the result
        self.cache[activityID] = self.cache[activityID] or {}
        self.cache[activityID].name = activityInfo.fullName
        
        return activityInfo.fullName
    end
    
    return nil
end

-- Get activity group from ID
function Activity:GetActivityGroup(activityID)
    if not activityID then return nil end
    
    -- Check cache first
    if self.cache[activityID] and self.cache[activityID].group then
        return self.cache[activityID].group
    end
    
    -- Get from API
    local activityInfo = C_LFGList.GetActivityInfoTable(activityID)
    if activityInfo then
        -- Cache the result
        self.cache[activityID] = self.cache[activityID] or {}
        self.cache[activityID].group = activityInfo.groupFinderActivityGroupID
        
        return activityInfo.groupFinderActivityGroupID
    end
    
    return nil
end

-- Get activity category from ID
function Activity:GetActivityCategory(activityID)
    if not activityID then return nil end
    
    -- Check cache first
    if self.cache[activityID] and self.cache[activityID].category then
        return self.cache[activityID].category
    end
    
    -- Get from API
    local activityInfo = C_LFGList.GetActivityInfoTable(activityID)
    if activityInfo then
        -- Cache the result
        self.cache[activityID] = self.cache[activityID] or {}
        self.cache[activityID].category = activityInfo.categoryID
        
        return activityInfo.categoryID
    end
    
    return nil
end

-- Get activity difficulty from ID
function Activity:GetActivityDifficulty(activityID)
    if not activityID then return nil end
    
    -- Get activity info
    local activityInfo = C_LFGList.GetActivityInfoTable(activityID)
    if not activityInfo then return nil end
    
    -- Check difficulty ID in our mapping
    local difficultyID = activityInfo.difficultyID
    if difficultyID and C.DIFFICULTY_MAP[difficultyID] then
        return C.DIFFICULTY_MAP[difficultyID]
    end
    
    -- Could not determine difficulty, guess based on category
    local categoryID = activityInfo.categoryID
    
    if categoryID == self.CATEGORY_ARENA then
        if string.find(activityInfo.fullName, "2v2") then
            return self.DIFFICULTY.ARENA2V2
        elseif string.find(activityInfo.fullName, "3v3") then
            return self.DIFFICULTY.ARENA3V3
        end
    end
    
    return self.DIFFICULTY.NORMAL -- Default to normal if we can't determine
end

-- Check if activity is a dungeon
function Activity:IsDungeonActivity(activityID)
    local category = self:GetActivityCategory(activityID)
    return category == self.CATEGORY_DUNGEON
end

-- Check if activity is a raid
function Activity:IsRaidActivity(activityID)
    local category = self:GetActivityCategory(activityID)
    return category == self.CATEGORY_RAID
end

-- Check if activity is PvP
function Activity:IsPvPActivity(activityID)
    local category = self:GetActivityCategory(activityID)
    return category == self.CATEGORY_PVP or
           category == self.CATEGORY_ARENA or
           category == self.CATEGORY_RATED_BG
end

-- Check if activity is an island expedition
function Activity:IsIslandActivity(activityID)
    local category = self:GetActivityCategory(activityID)
    return category == self.CATEGORY_ISLAND
end

-- Extract Mythic+ level from group name
function Activity:GetMythicPlusLevelFromName(name)
    if not name then return nil end
    
    -- Try to find patterns like "M+10", "M+ 15", "Mythic+20", etc.
    local level = name:match("[Mm]%+%s*(%d+)") or
                  name:match("[Mm][Yy][Tt][Hh][Ii][Cc]%+%s*(%d+)") or
                  name:match("(%d+)%s*%+") or
                  name:match("%((%d+)") or
                  name:match("(1%d)%s") -- Look for numbers 10-19 followed by space
    
    if level then
        level = tonumber(level)
        if level and level >= 2 and level <= 99 then
            return level
        end
    end
    
    return nil
end

-- Get the minimum and maximum roles needed for an activity
function Activity:GetRoleRequirements(activityID)
    local activityInfo = C_LFGList.GetActivityInfoTable(activityID)
    if not activityInfo then return nil end
    
    local result = {
        minTanks = 0,
        maxTanks = 0,
        minHealers = 0,
        maxHealers = 0,
        minDPS = 0,
        maxDPS = 0,
    }
    
    -- Get category
    local categoryID = activityInfo.categoryID
    
    -- Dungeon (normal 5-man composition)
    if categoryID == self.CATEGORY_DUNGEON then
        result.minTanks = 1
        result.maxTanks = 1
        result.minHealers = 1
        result.maxHealers = 1
        result.minDPS = 3
        result.maxDPS = 3
    -- Raid (variable composition)
    elseif categoryID == self.CATEGORY_RAID then
        result.minTanks = 2
        result.maxTanks = 2
        result.minHealers = 4
        result.maxHealers = 6
        result.minDPS = 12
        result.maxDPS = 22
    -- Arena 2v2
    elseif categoryID == self.CATEGORY_ARENA and string.find(activityInfo.fullName, "2v2") then
        result.minTanks = 0
        result.maxTanks = 1
        result.minHealers = 0
        result.maxHealers = 1
        result.minDPS = 1
        result.maxDPS = 2
    -- Arena 3v3
    elseif categoryID == self.CATEGORY_ARENA and string.find(activityInfo.fullName, "3v3") then
        result.minTanks = 0
        result.maxTanks = 1
        result.minHealers = 0
        result.maxHealers = 1
        result.minDPS = 2
        result.maxDPS = 3
    -- Rated BG
    elseif categoryID == self.CATEGORY_RATED_BG then
        result.minTanks = 0
        result.maxTanks = 2
        result.minHealers = 2
        result.maxHealers = 3
        result.minDPS = 5
        result.maxDPS = 8
    -- PvP
    elseif categoryID == self.CATEGORY_PVP then
        result.minTanks = 0
        result.maxTanks = 5
        result.minHealers = 0
        result.maxHealers = 5
        result.minDPS = 0
        result.maxDPS = 40
    -- Default/Custom
    else
        result.minTanks = 0
        result.maxTanks = 5
        result.minHealers = 0
        result.maxHealers = 5
        result.minDPS = 0
        result.maxDPS = 40
    end
    
    return result
end

-- Get a formatted string describing the activity
function Activity:GetActivityString(activityID)
    if not activityID then return "" end
    
    local activityInfo = C_LFGList.GetActivityInfoTable(activityID)
    if not activityInfo then return "" end
    
    local activityName = activityInfo.fullName or "Unknown Activity"
    local difficulty = self:GetActivityDifficulty(activityID)
    
    local difficultyString = ""
    if difficulty == self.DIFFICULTY.NORMAL then
        difficultyString = L["Normal"]
    elseif difficulty == self.DIFFICULTY.HEROIC then
        difficultyString = L["Heroic"]
    elseif difficulty == self.DIFFICULTY.MYTHIC then
        difficultyString = L["Mythic"]
    elseif difficulty == self.DIFFICULTY.MYTHICPLUS then
        difficultyString = L["Mythic+"]
    end
    
    if difficultyString ~= "" then
        return activityName .. " (" .. difficultyString .. ")"
    else
        return activityName
    end
end