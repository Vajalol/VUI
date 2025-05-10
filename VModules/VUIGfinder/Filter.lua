-- VUIGfinder Filter Implementation
-- Core filtering functionality for VUIGfinder

local L = PGFinderLocals; -- Strings
local VUI, VUIGfinderModule

-- Cache commonly used functions
local C_LFGList = C_LFGList
local GetNumGroupMembers = GetNumGroupMembers
local GetSpecializationInfoByID = GetSpecializationInfoByID
local UnitGroupRolesAssigned = UnitGroupRolesAssigned

-- Filter settings
local filterSettings = {
    minLeaderScore = 0,
    maxLeaderScore = 10000,
    minMythicLevel = 0,
    maxMythicLevel = 40,
    minRating = 0,
    maxRating = 3000,
    roles = {
        TANK = true,
        HEALER = true,
        DAMAGER = true
    },
    difficulties = {
        normal = true,
        heroic = true,
        mythic = true,
        mythicplus = true
    },
    categories = {
        dungeon = true,
        raid = true,
        arena = true,
        rbg = true,
        custom = true,
        other = true
    }
}

-- Activity cache
local activityInfoCache = {}
local groupInfoCache = {}
local lastRefreshTime = 0

-- Initialize filter module
local function InitializeFilter()
    VUI = _G.VUI
    VUIGfinderModule = VUI and VUI:GetModule("VUIGfinder")
    
    -- Load settings from VUI database
    LoadSettings()
    
    -- Register events for filter updates
    -- These will be hooked in MainWrapper.lua
end

-- Load settings from VUI database
local function LoadSettings()
    if VUIGfinderModule and VUIGfinderModule.db and VUIGfinderModule.db.profile then
        local db = VUIGfinderModule.db.profile
        
        -- Load dungeon settings
        if db.filter and db.filter.dungeon then
            filterSettings.categories.dungeon = db.filter.dungeon
            if db.defaultFilters then
                filterSettings.minMythicLevel = db.defaultFilters.minMythicPlusLevel or 2
                filterSettings.maxMythicLevel = db.defaultFilters.maxMythicPlusLevel or 30
            end
        end
        
        -- Load raid settings
        if db.filter and db.filter.raid then
            filterSettings.categories.raid = db.filter.raid
        end
        
        -- Load arena settings
        if db.filter and db.filter.arena then
            filterSettings.categories.arena = db.filter.arena
            if db.defaultFilters then
                filterSettings.minRating = db.defaultFilters.minRating or 0
                filterSettings.maxRating = db.defaultFilters.maxRating or 3000
            end
        end
        
        -- Load other settings
        if db.filter then
            filterSettings.categories.rbg = db.filter.rbg or true
            filterSettings.categories.custom = db.filter.custom or true
            filterSettings.categories.other = db.filter.other or true
        end
        
        -- Load role settings
        -- This would come from character/specialization data
    end
end

-- Main filter function for search results
local function FilterSearchResults(panel)
    if not panel then return end
    
    -- Check if we have results
    local searchResults = panel.results
    if not searchResults or #searchResults == 0 then return end
    
    -- Track how many results we started with
    local totalResults = #searchResults
    local filteredResults = {}
    
    -- Filter each result
    for i, resultID in ipairs(searchResults) do
        -- Get info about the group
        local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
        if searchResultInfo and ShouldDisplayResult(searchResultInfo, resultID) then
            table.insert(filteredResults, resultID)
        end
    end
    
    -- Update the panel with filtered results
    panel.results = filteredResults
    panel.totalResults = #filteredResults
    
    -- Update the UI to show filtering stats
    UpdateFilterStats(totalResults, #filteredResults)
    
    -- Return the filtered results
    return filteredResults
end

-- Determine if a search result should be displayed
local function ShouldDisplayResult(info, resultID)
    -- Skip if result is not valid
    if not info or not info.activityID then return false end
    
    -- Get activity information
    local activityInfo = activityInfoCache[info.activityID]
    if not activityInfo then
        activityInfo = C_LFGList.GetActivityInfoTable(info.activityID)
        if activityInfo then
            activityInfoCache[info.activityID] = activityInfo
        else
            return false
        end
    end
    
    -- Filter by category
    local categoryID = activityInfo.categoryID
    if categoryID == 2 and not filterSettings.categories.dungeon then -- Dungeons
        return false
    elseif categoryID == 3 and not filterSettings.categories.raid then -- Raids
        return false
    elseif categoryID == 4 and not filterSettings.categories.arena then -- Arena
        return false
    elseif categoryID == 5 and not filterSettings.categories.rbg then -- Rated Battleground
        return false
    elseif categoryID == 1 and not filterSettings.categories.custom then -- Custom
        return false
    elseif (categoryID == 6 or categoryID == 7 or categoryID == 8 or categoryID == 9) and not filterSettings.categories.other then -- Other
        return false
    end
    
    -- Filter by mythic+ level
    if activityInfo.isMythicPlusActivity and info.mythicPlusRating then
        local level = info.activityID - 400 -- This calculation depends on Blizzard's ID scheme
        if level < filterSettings.minMythicLevel or level > filterSettings.maxMythicLevel then
            return false
        end
    end
    
    -- Filter by rating for PvP
    if (categoryID == 4 or categoryID == 5) and info.pvpRating then
        if info.pvpRating < filterSettings.minRating or info.pvpRating > filterSettings.maxRating then
            return false
        end
    end
    
    -- Filter by leader score if available
    if info.leaderOverallDungeonScore and 
       (info.leaderOverallDungeonScore < filterSettings.minLeaderScore or 
        info.leaderOverallDungeonScore > filterSettings.maxLeaderScore) then
        return false
    end
    
    -- Filter by role requirements
    -- This would evaluate if the group needs roles that match the player's preferences
    
    -- Passed all filters
    return true
end

-- Update UI to show filtering statistics
local function UpdateFilterStats(total, filtered)
    -- This will be implemented in the UI module
    if VUIGfinder.UpdateFilterStats then
        VUIGfinder.UpdateFilterStats(total, filtered)
    end
end

-- Get the current filter settings
local function GetFilterSettings()
    return filterSettings
end

-- Update filter settings
local function UpdateFilterSettings(newSettings)
    for k, v in pairs(newSettings) do
        if type(filterSettings[k]) == "table" and type(v) == "table" then
            for subK, subV in pairs(v) do
                filterSettings[k][subK] = subV
            end
        else
            filterSettings[k] = v
        end
    end
    
    -- Save to VUI database if available
    if VUIGfinderModule and VUIGfinderModule.db and VUIGfinderModule.db.profile then
        local db = VUIGfinderModule.db.profile
        
        -- Update dungeon settings
        if newSettings.categories and newSettings.categories.dungeon ~= nil then
            db.filter.dungeon = newSettings.categories.dungeon
        end
        if newSettings.minMythicLevel or newSettings.maxMythicLevel then
            db.defaultFilters.minMythicPlusLevel = newSettings.minMythicLevel or db.defaultFilters.minMythicPlusLevel
            db.defaultFilters.maxMythicPlusLevel = newSettings.maxMythicLevel or db.defaultFilters.maxMythicPlusLevel
        end
        
        -- Update raid settings
        if newSettings.categories and newSettings.categories.raid ~= nil then
            db.filter.raid = newSettings.categories.raid
        end
        
        -- Update arena settings
        if newSettings.categories and newSettings.categories.arena ~= nil then
            db.filter.arena = newSettings.categories.arena
        end
        if newSettings.minRating or newSettings.maxRating then
            db.defaultFilters.minRating = newSettings.minRating or db.defaultFilters.minRating
            db.defaultFilters.maxRating = newSettings.maxRating or db.defaultFilters.maxRating
        end
        
        -- Update other category settings
        if newSettings.categories then
            if newSettings.categories.rbg ~= nil then db.filter.rbg = newSettings.categories.rbg end
            if newSettings.categories.custom ~= nil then db.filter.custom = newSettings.categories.custom end
            if newSettings.categories.other ~= nil then db.filter.other = newSettings.categories.other end
        end
    end
end

-- Export functions
VUIGfinder.FilterSearchResults = FilterSearchResults
VUIGfinder.GetFilterSettings = GetFilterSettings
VUIGfinder.UpdateFilterSettings = UpdateFilterSettings
VUIGfinder.InitializeFilter = InitializeFilter
VUIGfinder.ShouldDisplayResult = ShouldDisplayResult