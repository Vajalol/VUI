-------------------------------------------------------------------------------
-- VUI Gfinder (based on Premade Groups Filter)
-- Module for VUI - Vortex UI Addon Suite
-------------------------------------------------------------------------------

local VUI = _G.VUI
local Module = VUI:GetModule("VUIGfinder")
if not Module then return end

local VUIGfinder = _G.VUIGfinder
local L = VUIGfinder.L

-- Create AdvancedFilter namespace
VUIGfinder.AdvancedFilter = {}
local AdvancedFilter = VUIGfinder.AdvancedFilter
local Util = VUIGfinder.Util
local Activity = VUIGfinder.Activity
local Logger = VUIGfinder.Logger

-- Operators supported in filter expressions
AdvancedFilter.operators = {
    ["and"] = function(a, b) return a and b end,
    ["or"] = function(a, b) return a or b end,
    ["not"] = function(a) return not a end,
    ["<"] = function(a, b) return a < b end,
    [">"] = function(a, b) return a > b end,
    ["<="] = function(a, b) return a <= b end,
    [">="] = function(a, b) return a >= b end,
    ["=="] = function(a, b) return a == b end,
    ["~="] = function(a, b) return a ~= b end,
    ["contains"] = function(a, b) return string.find(string.lower(a), string.lower(b)) ~= nil end,
}

-- Aliases for operators
AdvancedFilter.operatorAliases = {
    ["&&"] = "and",
    ["||"] = "or",
    ["!"] = "not",
    ["!="] = "~=",
    ["="] = "==",
}

-- Info fields available for filtering
AdvancedFilter.availableFields = {
    -- Activity info
    ["activityid"] = function(searchResult) return searchResult.activityID end,
    ["activityname"] = function(searchResult) return Activity:GetActivityName(searchResult.activityID) end,
    ["categoryid"] = function(searchResult) return Activity:GetActivityCategory(searchResult.activityID) end,
    ["difficulty"] = function(searchResult) return Activity:GetActivityDifficulty(searchResult.activityID) end,
    ["isdungeon"] = function(searchResult) return Activity:IsDungeonActivity(searchResult.activityID) end,
    ["israid"] = function(searchResult) return Activity:IsRaidActivity(searchResult.activityID) end,
    ["ispvp"] = function(searchResult) return Activity:IsPvPActivity(searchResult.activityID) end,
    
    -- Group info
    ["groupname"] = function(searchResult) return searchResult.name or "" end,
    ["comment"] = function(searchResult) return searchResult.comment or "" end,
    ["voicechat"] = function(searchResult) return searchResult.voiceChat and searchResult.voiceChat ~= "" end,
    ["ilvl"] = function(searchResult) return searchResult.requiredItemLevel or 0 end,
    ["hlvl"] = function(searchResult) return searchResult.requiredHonorLevel or 0 end,
    ["members"] = function(searchResult) return searchResult.numMembers or 0 end,
    ["tanks"] = function(searchResult) return (searchResult.numTanks or 0) end,
    ["heals"] = function(searchResult) return (searchResult.numHealers or 0) end,
    ["dps"] = function(searchResult) return (searchResult.numDamagers or 0) end,
    ["tanks_needed"] = function(searchResult) 
        local tanks, healers, dps = C_LFGList.GetAvailableRoles()
        return tanks and searchResult.numTanks < searchResult.maxTanks
    end,
    ["heals_needed"] = function(searchResult)
        local tanks, healers, dps = C_LFGList.GetAvailableRoles()
        return healers and searchResult.numHealers < searchResult.maxHealers
    end,
    ["dps_needed"] = function(searchResult)
        local tanks, healers, dps = C_LFGList.GetAvailableRoles()
        return dps and searchResult.numDamagers < searchResult.maxDamagers
    end,
    ["age"] = function(searchResult) return searchResult.age or 0 end,
    ["elapsed"] = function(searchResult) return searchResult.elapsed or 0 end,
    ["autoaccept"] = function(searchResult) return searchResult.autoAccept end,
    ["questid"] = function(searchResult) return searchResult.questID end,
    ["mythicplus"] = function(searchResult)
        if Activity:GetActivityDifficulty(searchResult.activityID) ~= Activity.DIFFICULTY.MYTHICPLUS then
            return 0
        end
        return Activity:GetMythicPlusLevelFromName(searchResult.name) or 0
    end,
    ["matchingid"] = function(searchResult) return searchResult.matchingID end,
}

-- Parse a filter expression
function AdvancedFilter:ParseExpression(expression)
    -- Trivial case: empty expression
    if not expression or expression == "" then
        return function(searchResult) return true end
    end
    
    -- Attempt to create a filter function from the expression
    local filterFunc = loadstring("return function(searchResult) return " .. expression .. " end")
    
    -- If compilation failed, return a pass-through function
    if not filterFunc then
        Logger:Error("Failed to parse filter expression: %s", expression)
        return function(searchResult) return true end
    end
    
    -- Create an environment for the filter function
    local env = {}
    
    -- Add field accessors to environment
    for field, accessor in pairs(self.availableFields) do
        env[field] = function(searchResult)
            return accessor(searchResult)
        end
    end
    
    -- Add operators to environment
    for op, func in pairs(self.operators) do
        env[op] = func
    end
    
    -- Add operator aliases
    for alias, op in pairs(self.operatorAliases) do
        env[alias] = self.operators[op]
    end
    
    -- Add utility functions
    env.contains = function(a, b) return string.find(string.lower(tostring(a)), string.lower(tostring(b))) ~= nil end
    
    -- Add global references
    env.searchResult = nil
    env.string = string
    env.math = math
    env.tonumber = tonumber
    env.tostring = tostring
    
    -- Set environment for the filter function
    setfenv(filterFunc(), env)
    
    -- Return the compiled filter function
    return filterFunc()
end

-- Apply a filter to search results
function AdvancedFilter:ApplyFilter(searchResults, filterExpression)
    -- Parse the filter expression
    local filterFunc = self:ParseExpression(filterExpression)
    
    -- Apply the filter
    local filtered = {}
    for _, searchResult in ipairs(searchResults) do
        if filterFunc(searchResult) then
            table.insert(filtered, searchResult)
        end
    end
    
    return filtered
end

-- Parse a sorting expression
function AdvancedFilter:ParseSortExpression(expression)
    -- Trivial case: empty expression
    if not expression or expression == "" then
        return nil
    end
    
    local fields = {}
    local directions = {}
    
    -- Parse the expression
    -- Format: field1[+|-], field2[+|-], ...
    for field in string.gmatch(expression, "([^,]+)") do
        local fieldName = field:match("^%s*(%S+)")
        local direction = field:match("[%+%-]$")
        
        if fieldName and self.availableFields[string.lower(fieldName)] then
            fieldName = string.lower(fieldName)
            if direction == "-" then
                direction = false -- Descending
            else
                direction = true -- Ascending (default)
            end
            
            table.insert(fields, fieldName)
            table.insert(directions, direction)
        end
    end
    
    -- If no valid fields, return nil
    if #fields == 0 then
        return nil
    end
    
    -- Create sort function
    return function(a, b)
        for i, field in ipairs(fields) do
            local aValue = self.availableFields[field](a)
            local bValue = self.availableFields[field](b)
            
            if aValue ~= bValue then
                if directions[i] then
                    return aValue < bValue
                else
                    return aValue > bValue
                end
            end
        end
        
        return false
    end
end

-- Apply sorting to search results
function AdvancedFilter:ApplySorting(searchResults, sortExpression)
    -- Parse the sort expression
    local sortFunc = self:ParseSortExpression(sortExpression)
    
    -- If no sort function, return the original results
    if not sortFunc then
        return searchResults
    end
    
    -- Create a copy of the search results
    local sorted = {}
    for i, result in ipairs(searchResults) do
        sorted[i] = result
    end
    
    -- Sort the results
    table.sort(sorted, sortFunc)
    
    return sorted
end