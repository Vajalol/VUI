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

-- Helper functions
function VUIGfinder.ResetSearchEntries()
    -- Make sure to wait at least some time between two resets
    if time() - VUIGfinder.lastSearchEntryReset > C.SEARCH_ENTRY_RESET_WAIT then
        VUIGfinder.previousSearchGroupKeys = VUIGfinder.Table_Copy_Shallow(VUIGfinder.currentSearchGroupKeys)
        VUIGfinder.currentSearchGroupKeys = {}
        VUIGfinder.previousSearchExpression = VUIGfinder.currentSearchExpression
        VUIGfinder.lastSearchEntryReset = time()
        VUIGfinder.searchResultIDInfo = {}
        VUIGfinder.numResultsBeforeFilter = 0
        VUIGfinder.numResultsAfterFilter = 0
    end
end

function VUIGfinder.GetUserSortingTable()
    local sorting = VUIGfinder.Dialog:GetSortingExpression()
    if VUIGfinder.Empty(sorting) then return {} end
    local sortingError = VUIGfinder.Expression:Validate(sorting, false)
    if sortingError then return {} end
    return VUIGfinder.Expression:ToTable(sorting, false, true)
end

-- Define user filtering function
function VUIGfinder.DoFilterSearchResults(searchResultInfo)
    -- Reset the search results
    VUIGfinder.ResetSearchEntries()
    
    -- If the feature isn't enabled, just return the original results
    if not Module.db.profile.enabled then
        C_LFGList.RequestAvailableActivities()
        return searchResultInfo
    end
    
    -- Get the user's expression from the dialog
    local expression = ""
    
    -- Check which filter type is active and get the expression
    if Module.db.profile.advanced.enabled then
        expression = Module.db.profile.advanced.expression
    else
        -- Build expression from UI panels based on which tab is active
        local activePanel = VUIGfinder.Dialog:GetActivePanel()
        if activePanel then
            expression = activePanel:GetExpression()
        end
    end
    
    -- Validate the expression
    VUIGfinder.currentSearchExpression = expression
    local expressionError = VUIGfinder.Empty(expression) and "empty" or VUIGfinder.Expression:Validate(expression)
    
    -- Store search result count before filtering
    VUIGfinder.numResultsBeforeFilter = #searchResultInfo
    
    -- If the expression has an error, just use the original results
    if expressionError then
        C_LFGList.RequestAvailableActivities()
        return searchResultInfo
    end
    
    -- Convert expression to a table of criteria
    local exprTable = VUIGfinder.Expression:ToTable(expression)
    if not exprTable then
        C_LFGList.RequestAvailableActivities()
        return searchResultInfo
    end
    
    -- Get sorting criteria if enabled
    local sortingActive = Module.db.profile.sorting.enabled and not VUIGfinder.Empty(Module.db.profile.sorting.expression) 
    local sortingTable = sortingActive and VUIGfinder.GetUserSortingTable() or {}
    local sortingExp = sortingActive and Module.db.profile.sorting.expression or ""
    
    -- Filter groups based on criteria
    local filteredGroups = {}
    local groupInfo = {}
    
    for i = 1, #searchResultInfo do
        -- Get all the info we need about this group
        local searchResultID = searchResultInfo[i]
        local activityInfo = C_LFGList.GetSearchResultInfo(searchResultID)
        if activityInfo and not activityInfo.isDelisted then
            VUIGfinder.currentSearchGroupKeys[searchResultID] = true
            VUIGfinder.searchResultIDInfo[searchResultID] = activityInfo
            
            -- Prepare group data for filtering
            groupInfo.searchResultID = searchResultID
            groupInfo.activityID = activityInfo.activityID
            groupInfo.name = activityInfo.name
            groupInfo.comment = activityInfo.comment
            groupInfo.voiceChat = activityInfo.voiceChat
            groupInfo.leaderName = activityInfo.leaderName
            groupInfo.numMembers = activityInfo.numMembers
            groupInfo.autoAccept = activityInfo.autoAccept
            groupInfo.age = time() - activityInfo.creationTime
            -- Add more group info fields for advanced filtering
            
            -- Evaluate expression for this group
            if VUIGfinder.Expression:Evaluate(exprTable, groupInfo) then
                table.insert(filteredGroups, searchResultID)
            end
        end
    end
    
    -- Sort if needed
    if next(sortingTable) then
        table.sort(filteredGroups, function(a, b)
            return VUIGfinder.Expression:EvaluateSorting(sortingTable, sortingExp, a, b)
        end)
    end
    
    -- Store results count after filtering
    VUIGfinder.numResultsAfterFilter = #filteredGroups
    VUIGfinder.currentSearchResults = filteredGroups
    
    -- Request data for available activities to ensure tooltips work
    C_LFGList.RequestAvailableActivities()
    
    return filteredGroups
end

-- Hook into the search results function
function Module:HookSearchResults()
    if not Module:IsHooked("LFGListUtil_SortSearchResults") then
        Module:RawHook("LFGListUtil_SortSearchResults", function(results)
            return VUIGfinder.DoFilterSearchResults(results)
        end, true)
    end
end

-- Enhance tooltips with additional information
function VUIGfinder.OnLFGListSearchEntryOnEnter(self)
    if not Module.db.profile.ui.tooltipEnhancement then return end
    
    local resultID = self.resultID
    local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
    if not searchResultInfo then return end
    
    -- Add custom tooltip info
    if GameTooltip:IsShown() then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(L["Group Details"], 1, 1, 1)
        
        -- Add activity name
        local activityInfo = C_LFGList.GetActivityInfoTable(searchResultInfo.activityID)
        if activityInfo then
            GameTooltip:AddLine(L["Activity"] .. ": " .. activityInfo.fullName, 1, 0.85, 0)
        end
        
        -- Add difficulty
        if activityInfo and activityInfo.difficultyID and C.DIFFICULTY_MAP[activityInfo.difficultyID] then
            local difficultyName = VUIGfinder.GetDifficultyNameByID(activityInfo.difficultyID)
            if difficultyName then
                GameTooltip:AddLine(L["Difficulty"] .. ": " .. difficultyName, 1, 0.85, 0)
            end
        end
        
        -- Add mythic plus level if applicable
        if searchResultInfo.activityID and VUIGfinder.IsMythicPlusActivity(searchResultInfo.activityID) then
            local leaderScore, _, _, _ = VUIGfinder.GetRatingInfoForSearchResult(resultID) 
            if leaderScore then
                GameTooltip:AddLine(L["Leader Score"] .. ": " .. leaderScore, 1, 0.85, 0)
            end
        end
        
        -- Add group composition information
        local membersText = L["Members"] .. ": " .. searchResultInfo.numMembers
        GameTooltip:AddLine(membersText, 1, 0.85, 0)
        
        -- Add creation time
        local age = time() - searchResultInfo.creationTime
        local formattedTime = VUIGfinder.FormatTime(age)
        GameTooltip:AddLine(L["Created"] .. ": " .. formattedTime .. " " .. L["ago"], 1, 0.85, 0)
        
        GameTooltip:Show()
    end
end

-- Initialize the full module
function Module:InitializeUI()
    -- Initialize all the module components
    VUIGfinder.Expression:Initialize()
    VUIGfinder.Dialog:Initialize()
    
    -- Hook into tooltips
    if LFGListSearchEntry_OnEnter and not Module:IsHooked("LFGListSearchEntry_OnEnter") then
        Module:RawHook("LFGListSearchEntry_OnEnter", VUIGfinder.OnLFGListSearchEntryOnEnter, true)
    end
    
    -- Hook into search results
    self:HookSearchResults()
    
    -- Additional UI initialization code
    if Module.db.profile.ui.oneClickSignUp then
        VUIGfinder.OneClickSignUp:Initialize()
    end
    
    if Module.db.profile.ui.persistSignUpNote then
        VUIGfinder.PersistSignUpNote:Initialize()
    end
    
    if Module.db.profile.ui.signUpOnEnter then
        VUIGfinder.SignUpOnEnter:Initialize()
    end
    
    -- Update the "Use VUIGfinder" button
    if Module.db.profile.ui.usePGFButton then
        VUIGfinder.UsePGFButton:Create()
    end
    
    -- Add slash command
    SLASH_VUIGFINDER1 = "/vuigfinder"
    SLASH_VUIGFINDER2 = "/vgf"
    SlashCmdList["VUIGFINDER"] = function(msg)
        VUIGfinder.Dialog:Toggle()
    end
end

-- Reset all filters to default values
function Module:ResetAllFilters()
    -- General settings
    self.db.profile.advanced.enabled = false
    self.db.profile.advanced.expression = ""
    self.db.profile.sorting.enabled = false
    self.db.profile.sorting.expression = ""
    
    -- Dungeon settings
    self.db.profile.dungeon.minimumDifficulty = C.NORMAL
    self.db.profile.dungeon.maximumDifficulty = C.MYTHICPLUS
    self.db.profile.dungeon.minMythicPlusLevel = 2
    self.db.profile.dungeon.maxMythicPlusLevel = 30
    self.db.profile.dungeon.minMembers = 1
    self.db.profile.dungeon.maxMembers = 5
    self.db.profile.dungeon.filterRoleTank = false
    self.db.profile.dungeon.filterRoleHealer = false
    self.db.profile.dungeon.filterRoleDPS = false
    self.db.profile.dungeon.noFullGroups = false
    self.db.profile.dungeon.hideVoiceChat = false
    
    -- Raid settings
    self.db.profile.raid.minimumDifficulty = C.NORMAL
    self.db.profile.raid.maximumDifficulty = C.MYTHIC
    
    -- Arena settings
    self.db.profile.arena.minRating = 0
    self.db.profile.arena.maxRating = 3000
    
    -- RBG settings
    self.db.profile.rbg.minRating = 0
    self.db.profile.rbg.maxRating = 3000
    
    -- If the dialog is open, update it
    if VUIGfinder.Dialog and VUIGfinder.Dialog.frame and VUIGfinder.Dialog.frame:IsShown() then
        if VUIGfinder.Dialog.GetActivePanel then
            local panel = VUIGfinder.Dialog:GetActivePanel()
            if panel and panel.ResetFilters then
                panel:ResetFilters()
            end
        end
    end
end

-- Note: GUI registration is done in /VUI/Config/Layouts/_VUIGfinder.lua

-- Initialize module when player enters world
function Module:PLAYER_ENTERING_WORLD()
    Module:InitializeUI()
end