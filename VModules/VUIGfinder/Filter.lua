-- VUIGfinder Filter Implementation
-- Core filtering functionality for VUIGfinder

<<<<<<< HEAD
-- Create global aliases for backward compatibility
_G.VUIFinder = _G.VUIFinder or _G.VUIGfinder or {}
_G.VUIGfinder = _G.VUIGfinder or {}

local L = PGFinderLocals or {}; -- Strings with fallback
local VUI, VUIGfinderModule
=======
local L = PGFinderLocals; -- Strings
local VUI = _G.VUI
local VUIGfinderModule = VUI and (VUI.VUIGfinder or VUI:GetModule("VUIGfinder"))
>>>>>>> f2841d4c299e00869d4563d9e99c5e582069affc

-- Cache commonly used functions
local C_LFGList = C_LFGList
local GetNumGroupMembers = GetNumGroupMembers
local GetSpecializationInfoByID = GetSpecializationInfoByID
local UnitGroupRolesAssigned = UnitGroupRolesAssigned

-- Determine if a search result should be displayed
-- Moving the function definition earlier to ensure it's available before FilterSearchResults
local function ShouldDisplayResult(info, resultID)
    -- Skip if result is not valid
    if not info or not info.activityID then return false end
    
    -- Get activity information
    local activityInfo = activityInfoCache[info.activityID]
    if not activityInfo then
        if C_LFGList and C_LFGList.GetActivityInfoTable then
            local success, result = pcall(C_LFGList.GetActivityInfoTable, info.activityID)
            if success and result then
                activityInfo = result
                activityInfoCache[info.activityID] = activityInfo
            else
                return false
            end
        else
            return false
        end
    end
    
    -- Safety check for categoryID
    if not activityInfo or not activityInfo.categoryID then return false end
    
    -- Ensure filterSettings.categories exists
    if not filterSettings.categories then
        filterSettings.categories = {
            dungeon = true,
            raid = true,
            arena = true,
            rbg = true,
            custom = true,
            other = true
        }
    end
    
    -- Filter by category
    local categoryID = activityInfo.categoryID
    if categoryID == 2 and filterSettings.categories.dungeon == false then -- Dungeons
        return false
    elseif categoryID == 3 and filterSettings.categories.raid == false then -- Raids
        return false
    elseif categoryID == 4 and filterSettings.categories.arena == false then -- Arena
        return false
    elseif categoryID == 5 and filterSettings.categories.rbg == false then -- Rated Battleground
        return false
    elseif categoryID == 1 and filterSettings.categories.custom == false then -- Custom
        return false
    elseif (categoryID == 6 or categoryID == 7 or categoryID == 8 or categoryID == 9) and filterSettings.categories.other == false then -- Other
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
    
    -- Passed all filters
    return true
end

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
<<<<<<< HEAD
    VUI = _G.VUI
    if not VUI then return end
    
    -- Try to get the module, but handle the case where it doesn't exist
    local success, module = pcall(function() return VUI.GetModule and VUI:GetModule("VUIGfinder") end)
    if success and module then
        VUIGfinderModule = module
    else
        -- Create a minimal fallback module structure
        VUIGfinderModule = {
            db = {
                profile = {
                    filter = {
                        dungeon = true,
                        raid = true,
                        arena = true,
                        rbg = true,
                        custom = true,
                        other = true
                    },
                    defaultFilters = {
                        minMythicPlusLevel = 2,
                        maxMythicPlusLevel = 30,
                        minRating = 0,
                        maxRating = 3000
                    }
                }
            }
        }
    end
    
    -- Ensure module DB structure exists
    if not VUIGfinderModule.db then
        VUIGfinderModule.db = {}
    end
    
    if not VUIGfinderModule.db.profile then
        VUIGfinderModule.db.profile = {}
    end
    
    if not VUIGfinderModule.db.profile.filter then
        VUIGfinderModule.db.profile.filter = {
            dungeon = true,
            raid = true,
            arena = true,
            rbg = true,
            custom = true,
            other = true
        }
    end
    
    if not VUIGfinderModule.db.profile.defaultFilters then
        VUIGfinderModule.db.profile.defaultFilters = {
            minMythicPlusLevel = 2,
            maxMythicPlusLevel = 30,
            minRating = 0,
            maxRating = 3000
        }
    end
=======
>>>>>>> f2841d4c299e00869d4563d9e99c5e582069affc
    
    -- Load settings from VUI database
    if VUIGfinder.LoadSettings and type(VUIGfinder.LoadSettings) == "function" then
        VUIGfinder.LoadSettings()
    end
    
    -- Immediately export the ShouldDisplayResult function to ensure it's available
    VUIGfinder.ShouldDisplayResult = ShouldDisplayResult
    _G.VUIFinder.ShouldDisplayResult = ShouldDisplayResult
    
    -- Register events for filter updates
    -- These will be hooked in MainWrapper.lua
end

-- Entry point for loading settings
local function LoadSettings(force)
    if VUIGfinderModule and VUIGfinderModule.db then
        return VUIGfinderModule.db.profile
    else
        -- Debug message with safe lookup
        local debugFn = VUI and VUI.Debug or print
        if type(debugFn) == "function" then
            debugFn("VUIGfinder: Using fallback settings")
        end
        
        -- Return fallback settings
        return {
            filter = {
                dungeon = true,
                raid = true,
                arena = true,
                rbg = true,
                custom = true,
                other = true
            },
            defaultFilters = {
                minMythicPlusLevel = 2,
                maxMythicPlusLevel = 30,
                minRating = 0,
                maxRating = 3000
            }
        }
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
    
    -- The most robust way to get the filter function - try multiple approaches
    local checkResult = nil
    
    -- First try the local function (should work if file loaded properly)
    if ShouldDisplayResult then
        checkResult = ShouldDisplayResult
    -- Otherwise try global namespaces
    elseif VUIGfinder.ShouldDisplayResult and type(VUIGfinder.ShouldDisplayResult) == "function" then
        checkResult = VUIGfinder.ShouldDisplayResult
    elseif _G.VUIFinder.ShouldDisplayResult and type(_G.VUIFinder.ShouldDisplayResult) == "function" then
        checkResult = _G.VUIFinder.ShouldDisplayResult
    end
    
    -- If we don't have any filter function, just return the original results
    if not checkResult then
        -- Log warning
        local debugFn = VUI and VUI.Debug or print
        if type(debugFn) == "function" then
            debugFn("VUIGfinder: ShouldDisplayResult not found, skipping filtering")
        end
        
        -- Export the function again as emergency measure
        if ShouldDisplayResult then
            VUIGfinder.ShouldDisplayResult = ShouldDisplayResult
            _G.VUIFinder.ShouldDisplayResult = ShouldDisplayResult
        end
        
        return searchResults
    end
    
    -- Filter each result using pcall for safety
    for i, resultID in ipairs(searchResults) do
        -- Get info about the group
        local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
        
        -- Use pcall to prevent any errors from breaking the filter
        local success, shouldDisplay = pcall(function()
            return searchResultInfo and checkResult(searchResultInfo, resultID)
        end)
        
        -- Only include if the check succeeded and returned true
        if success and shouldDisplay then
            table.insert(filteredResults, resultID)
        elseif not success then
            -- Log filter error but include the result anyway to avoid filtering too much
            local debugFn = VUI and VUI.Debug or print
            if type(debugFn) == "function" then
                debugFn("VUIGfinder Filter Error: " .. tostring(shouldDisplay))
            end
            table.insert(filteredResults, resultID)
        end
    end
    
    -- Update the panel with filtered results
    panel.results = filteredResults
    panel.totalResults = #filteredResults
    
    -- Update the UI to show filtering stats
    if VUIGfinder.UpdateFilterStats then
        VUIGfinder.UpdateFilterStats(totalResults, #filteredResults)
    end
    
    -- Return the filtered results
    return filteredResults
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
    if not newSettings then return end
    
    for k, v in pairs(newSettings) do
        if type(filterSettings[k]) == "table" and type(v) == "table" then
            -- Create the table if it doesn't exist
            if not filterSettings[k] then filterSettings[k] = {} end
            
            for subK, subV in pairs(v) do
                filterSettings[k][subK] = subV
            end
        else
            filterSettings[k] = v
        end
    end
    
    -- Save to VUI database if available
    if not VUIGfinderModule or not VUIGfinderModule.db or not VUIGfinderModule.db.profile then
        return
    end
    
    local db = VUIGfinderModule.db.profile
    
    -- Ensure the filter and defaultFilters structures exist
    if not db.filter then
        db.filter = {
            dungeon = true,
            raid = true,
            arena = true,
            rbg = true,
            custom = true,
            other = true
        }
    end
    
    if not db.defaultFilters then
        db.defaultFilters = {
            minMythicPlusLevel = 2,
            maxMythicPlusLevel = 30,
            minRating = 0,
            maxRating = 3000
        }
    end
    
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

-- Export functions
VUIGfinder.ShouldDisplayResult = ShouldDisplayResult
VUIGfinder.InitializeFilter = InitializeFilter
VUIGfinder.FilterSearchResults = FilterSearchResults
VUIGfinder.LoadFilterSettings = LoadSettings
VUIGfinder.GetFilterSettings = GetFilterSettings
VUIGfinder.UpdateFilterSettings = UpdateFilterSettings

-- Also make them available through VUIFinder namespace for backward compatibility
_G.VUIFinder = _G.VUIFinder or {}
_G.VUIFinder.ShouldDisplayResult = ShouldDisplayResult
_G.VUIFinder.InitializeFilter = InitializeFilter
_G.VUIFinder.FilterSearchResults = FilterSearchResults
_G.VUIFinder.LoadFilterSettings = LoadSettings
_G.VUIFinder.GetFilterSettings = GetFilterSettings
_G.VUIFinder.UpdateFilterSettings = UpdateFilterSettings