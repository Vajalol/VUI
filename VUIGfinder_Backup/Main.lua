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

-- Access imported namespaces
local Activity = VUIGfinder.Activity
local ActivityKeywords = VUIGfinder.ActivityKeywords
local AdvancedFilter = VUIGfinder.AdvancedFilter
local MemberInfo = VUIGfinder.MemberInfo
local Logger = VUIGfinder.Logger
local Settings = VUIGfinder.Settings
local Util = VUIGfinder.Util
local UI = VUIGfinder.UI

-- Main initialization function
function VUIGfinder.OnInitialize()
    -- Register callbacks
    if not VUIGfinder.initialized then
        -- Define callback system
        VUIGfinder.callbacks = {}
        function VUIGfinder:RegisterCallback(event, callback)
            self.callbacks[event] = self.callbacks[event] or {}
            table.insert(self.callbacks[event], callback)
        end
        
        function VUIGfinder:TriggerCallback(event, ...)
            if not self.callbacks[event] then return end
            for _, callback in ipairs(self.callbacks[event]) do
                callback(...)
            end
        end
        
        -- Initialize settings
        if Settings then
            Settings:Initialize()
        end
        
        -- Initialize logger
        if Logger then
            Logger:Initialize()
        end
        
        VUIGfinder.initialized = true
        Logger:Info("VUIGfinder initialized")
    end
    
    -- Register slash commands
    SLASH_VUIGFINDER1 = "/vuigfinder"
    SLASH_VUIGFINDER2 = "/vgf"
    
    SlashCmdList["VUIGFINDER"] = function(msg)
        VUIGfinder.HandleSlashCommand(msg)
    end
    
    -- Set up hooks for Group Finder UI
    VUIGfinder:SetupHooks()
    
    -- Create main UI
    VUIGfinder:CreateUI()
    
    -- Trigger initialize callback
    VUIGfinder:TriggerCallback("OnInitialize")
end

-- Handle slash commands
function VUIGfinder.HandleSlashCommand(msg)
    msg = string.lower(msg or "")
    local args = Util.StringSplit(msg, " ")
    local cmd = args[1]
    
    if cmd == "toggle" or cmd == "" then
        if Module.db.profile.enabled then
            Module.db.profile.enabled = false
            VUIGfinder:Print(L["VUIGfinder disabled"])
        else
            Module.db.profile.enabled = true
            VUIGfinder:Print(L["VUIGfinder enabled"])
        end
        
        -- Update state based on enabled flag
        VUIGfinder.UpdateEnabledState()
    elseif cmd == "debug" then
        if Module.db.profile.debug then
            Module.db.profile.debug = false
            VUIGfinder:Print("Debug mode disabled")
        else
            Module.db.profile.debug = true
            VUIGfinder:Print("Debug mode enabled")
        end
        
        -- Update logger level
        if Logger then
            if Module.db.profile.debug then
                Logger:SetLogLevel(Logger.LOG_LEVEL_DEBUG)
            else
                Logger:SetLogLevel(Logger.LOG_LEVEL_INFO)
            end
        end
    elseif cmd == "help" then
        VUIGfinder:Print("VUIGfinder commands:")
        VUIGfinder:Print("/vgf toggle - Toggle VUIGfinder")
        VUIGfinder:Print("/vgf debug - Toggle debug mode")
        VUIGfinder:Print("/vgf help - Show this help")
    end
end

-- Print to chat
function VUIGfinder:Print(msg)
    print("|cff33BBFF[VUI Gfinder]|r " .. msg)
end

-- Update enabled state
function VUIGfinder.UpdateEnabledState()
    if Module.db.profile.enabled then
        -- Register events
        Module:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED")
        Module:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED")
        
        -- Update UI elements
        VUIGfinder:UpdateFilterButtonVisibility()
    else
        -- Unregister events
        Module:UnregisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED")
        Module:UnregisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED")
        
        -- Hide UI elements
        VUIGfinder:UpdateFilterButtonVisibility()
    end
end

-- Setup hooks
function VUIGfinder:SetupHooks()
    -- Hook into the search results display
    hooksecurefunc("LFGListUtil_SortSearchResults", function(results)
        VUIGfinder:ProcessSearchResults(results)
    end)
    
    -- Hook into the application dialog
    hooksecurefunc("LFGListApplicationDialog_Show", function(dialog, resultID)
        VUIGfinder:EnhanceSignUpDialog(dialog, resultID)
    end)
    
    -- Hook into tooltip display
    if Module.db.profile.ui.tooltipEnhancement then
        hooksecurefunc("LFGListSearchEntry_OnEnter", function(self)
            VUIGfinder:EnhanceSearchEntryTooltip(self, GameTooltip)
        end)
    end
    
    -- Hook one-click sign up if enabled
    if Module.db.profile.ui.oneClickSignUp then
        hooksecurefunc("LFGListSearchEntry_OnClick", function(self, button)
            if button == "LeftButton" and IsModifiedClick("CHATLINK") then
                VUIGfinder:OneClickSignUp(self.resultID)
                return true
            end
        end)
    end
    
    Logger:Debug("Hooks set up")
end

-- Main function to process search results
function VUIGfinder:ProcessSearchResults(results)
    -- Store original results count
    VUIGfinder.numResultsBeforeFilter = #results
    
    -- Apply filter if advanced mode is enabled
    if Module.db.profile.advanced.enabled and Module.db.profile.advanced.expression ~= "" then
        -- Apply advanced filtering
        if AdvancedFilter then
            local filteredResults = AdvancedFilter:ApplyFilter(results, Module.db.profile.advanced.expression)
            results = filteredResults
        end
    else
        -- Apply basic filtering
        results = VUIGfinder:ApplyBasicFilters(results)
    end
    
    -- Apply custom sorting if enabled
    if Module.db.profile.sorting.enabled and Module.db.profile.sorting.expression ~= "" then
        -- Apply custom sorting
        if AdvancedFilter then
            results = AdvancedFilter:ApplySorting(results, Module.db.profile.sorting.expression)
        end
    end
    
    -- Store filtered results count
    VUIGfinder.numResultsAfterFilter = #results
    
    -- Store current results for reference
    VUIGfinder.currentSearchResults = results
    
    -- Update UI elements
    VUIGfinder:UpdateFilterIndicator()
    
    Logger:Debug("Processed search results: before = %d, after = %d", 
        VUIGfinder.numResultsBeforeFilter, VUIGfinder.numResultsAfterFilter)
end

-- Apply basic filters to search results
function VUIGfinder:ApplyBasicFilters(results)
    local filtered = {}
    
    for _, result in ipairs(results) do
        local passFilter = true
        
        -- Get activity info
        local activityInfo = C_LFGList.GetActivityInfoTable(result.activityID)
        
        if activityInfo then
            local categoryID = activityInfo.categoryID
            
            -- Dungeon filters
            if categoryID == Activity.CATEGORY_DUNGEON then
                if not Module.db.profile.dungeon.enabled then
                    passFilter = false
                else
                    local difficulty = Activity:GetActivityDifficulty(result.activityID)
                    
                    -- Check difficulty range
                    if difficulty < Module.db.profile.dungeon.minimumDifficulty or
                       difficulty > Module.db.profile.dungeon.maximumDifficulty then
                        passFilter = false
                    end
                    
                    -- Check M+ level
                    if difficulty == C.MYTHICPLUS then
                        local keyLevel = Activity:GetMythicPlusLevelFromName(result.name)
                        if keyLevel < Module.db.profile.dungeon.minMythicPlusLevel or
                           keyLevel > Module.db.profile.dungeon.maxMythicPlusLevel then
                            passFilter = false
                        end
                    end
                end
            -- Raid filters
            elseif categoryID == Activity.CATEGORY_RAID then
                if not Module.db.profile.raid.enabled then
                    passFilter = false
                else
                    local difficulty = Activity:GetActivityDifficulty(result.activityID)
                    
                    -- Check difficulty range
                    if difficulty < Module.db.profile.raid.minimumDifficulty or
                       difficulty > Module.db.profile.raid.maximumDifficulty then
                        passFilter = false
                    end
                end
            -- Arena filters
            elseif categoryID == Activity.CATEGORY_ARENA then
                if not Module.db.profile.arena.enabled then
                    passFilter = false
                else
                    -- Extract rating from name or comment
                    local rating = VUIGfinder:ExtractRatingFromText(result.name) or
                                   VUIGfinder:ExtractRatingFromText(result.comment) or 0
                    
                    -- Check rating range
                    if rating < Module.db.profile.arena.minRating or
                       rating > Module.db.profile.arena.maxRating then
                        passFilter = false
                    end
                end
            -- Rated BG filters
            elseif categoryID == Activity.CATEGORY_RATED_BG then
                if not Module.db.profile.rbg.enabled then
                    passFilter = false
                else
                    -- Extract rating from name or comment
                    local rating = VUIGfinder:ExtractRatingFromText(result.name) or
                                   VUIGfinder:ExtractRatingFromText(result.comment) or 0
                    
                    -- Check rating range
                    if rating < Module.db.profile.rbg.minRating or
                       rating > Module.db.profile.rbg.maxRating then
                        passFilter = false
                    end
                end
            end
        end
        
        -- Add to filtered results if it passed all filters
        if passFilter then
            table.insert(filtered, result)
        end
    end
    
    return filtered
end

-- Extract rating from text
function VUIGfinder:ExtractRatingFromText(text)
    if not text then return nil end
    
    -- Look for common rating patterns (e.g., "1800+", "2400 cr", "1550 mmr")
    local rating = text:match("(%d%d%d%d)%+") or
                  text:match("(%d%d%d%d)%s*[cr]") or
                  text:match("(%d%d%d%d)%s*mmr") or
                  text:match("(%d%d%d%d)%s*rating")
    
    if rating then
        return tonumber(rating)
    else
        -- Try more general pattern
        rating = text:match("(%d%d%d%d)[%+%s]")
        if rating then
            return tonumber(rating)
        end
    end
    
    return nil
end

-- Update the filter indicator UI
function VUIGfinder:UpdateFilterIndicator()
    -- Implement filter indicator UI update
    -- This will show how many results were filtered
    if VUIGfinder.numResultsBeforeFilter > 0 and VUIGfinder.numResultsAfterFilter < VUIGfinder.numResultsBeforeFilter then
        -- Show indicator
        if LFGListFrame.SearchPanel.ResultsText then
            LFGListFrame.SearchPanel.ResultsText:SetText(string.format(
                "Showing %d/%d results", 
                VUIGfinder.numResultsAfterFilter, 
                VUIGfinder.numResultsBeforeFilter
            ))
        end
    end
end

-- Update filter button visibility
function VUIGfinder:UpdateFilterButtonVisibility()
    -- Implement filter button visibility update
    if VUIGfinder.FilterButton then
        if Module.db.profile.enabled and Module.db.profile.ui.usePGFButton then
            VUIGfinder.FilterButton:Show()
        else
            VUIGfinder.FilterButton:Hide()
        end
    end
end

-- Enhance the search entry tooltip
function VUIGfinder:EnhanceSearchEntryTooltip(searchEntry, tooltip)
    -- Don't modify tooltip if enhancement is disabled
    if not Module.db.profile.ui.tooltipEnhancement then
        return
    end
    
    local resultID = searchEntry.resultID
    local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
    
    if not searchResultInfo then
        return
    end
    
    -- Add header
    tooltip:AddLine(" ")
    tooltip:AddLine(L["Group Details"], VUI.COLOR_HEADER_R, VUI.COLOR_HEADER_G, VUI.COLOR_HEADER_B)
    
    -- Add activity info
    local activityInfo = C_LFGList.GetActivityInfoTable(searchResultInfo.activityID)
    if activityInfo then
        tooltip:AddDoubleLine(L["Activity"], activityInfo.fullName, 1, 1, 1, 1, 1, 1)
        
        local difficulty = Activity:GetActivityDifficulty(searchResultInfo.activityID)
        local difficultyName = ""
        
        if difficulty == C.NORMAL then
            difficultyName = L["Normal"]
        elseif difficulty == C.HEROIC then
            difficultyName = L["Heroic"]
        elseif difficulty == C.MYTHIC then
            difficultyName = L["Mythic"]
        elseif difficulty == C.MYTHICPLUS then
            local keyLevel = Activity:GetMythicPlusLevelFromName(searchResultInfo.name)
            difficultyName = string.format(L["Mythic+"] .. " %d", keyLevel or 0)
        elseif difficulty == C.ARENA2V2 then
            difficultyName = L["Arena 2v2"]
        elseif difficulty == C.ARENA3V3 then
            difficultyName = L["Arena 3v3"]
        end
        
        if difficultyName ~= "" then
            tooltip:AddDoubleLine(L["Difficulty"], difficultyName, 1, 1, 1, 1, 1, 1)
        end
    end
    
    -- Add leader info if available
    if searchResultInfo.leaderName then
        tooltip:AddDoubleLine(L["Leader"], MemberInfo:GetLeaderInfo(searchResultInfo), 1, 1, 1, 1, 1, 1)
    end
    
    -- Add member composition
    tooltip:AddDoubleLine(L["Members"], MemberInfo:GetGroupComposition(searchResultInfo), 1, 1, 1, 1, 1, 1)
    
    -- Add age
    if searchResultInfo.age and searchResultInfo.age > 0 then
        tooltip:AddDoubleLine(L["Created"], UI:FormatTimeAgo(searchResultInfo.age), 1, 1, 1, 1, 1, 1)
    end
    
    -- Add voice chat info
    if searchResultInfo.voiceChat and searchResultInfo.voiceChat ~= "" then
        tooltip:AddDoubleLine(VOICE_CHAT, searchResultInfo.voiceChat, 1, 1, 1, 1, 1, 1)
    end
    
    -- Add CTRL+Click tip for one-click sign up
    if Module.db.profile.ui.oneClickSignUp then
        tooltip:AddLine(" ")
        tooltip:AddLine("|cffcccccc" .. "CTRL+Click to sign up" .. "|r")
    end
    
    tooltip:Show()
end

-- Create the main UI components
function VUIGfinder:CreateUI()
    -- Create filter button
    if not VUIGfinder.FilterButton and LFGListFrame.SearchPanel then
        VUIGfinder.FilterButton = CreateFrame("Button", "VUIGfinderFilterButton", LFGListFrame.SearchPanel, "UIPanelButtonTemplate")
        VUIGfinder.FilterButton:SetSize(100, 22)
        VUIGfinder.FilterButton:SetPoint("TOPRIGHT", LFGListFrame.SearchPanel.RefreshButton, "TOPLEFT", -5, 0)
        VUIGfinder.FilterButton:SetText(L["Open Filter Dialog"])
        VUIGfinder.FilterButton:SetScript("OnClick", function()
            VUIGfinder:ToggleFilterDialog()
        end)
        
        -- Update visibility
        VUIGfinder:UpdateFilterButtonVisibility()
    end
    
    -- Create filter dialog (will be implemented in Dialog.lua)
    -- VUIGfinder:CreateFilterDialog()
end

-- Toggle the filter dialog
function VUIGfinder:ToggleFilterDialog()
    -- Forward to Dialog.lua implementation
    if VUIGfinder.Dialog and VUIGfinder.Dialog.Toggle then
        VUIGfinder.Dialog:Toggle()
    end
end

-- Registration function
Module:RegisterEvent("PLAYER_LOGIN", function()
    VUIGfinder.OnInitialize()
end)