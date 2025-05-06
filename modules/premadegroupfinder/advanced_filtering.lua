-------------------------------------------------------------------------------
-- Title: VUI Premade Group Finder Advanced Filtering
-- Author: VortexQ8
-- Enhanced filtering system for premade group finder
-------------------------------------------------------------------------------

local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end
local PGF = VUI.modules.premadegroupfinder or {}

-- Skip if premadegroupfinder module is not available
if not PGF then return end

-- Create the advanced filtering namespace
PGF.AdvancedFiltering = {}
local AF = PGF.AdvancedFiltering

-- Initialize advanced filtering module
function AF:Initialize()
    self.isEnabled = PGF.settings.advanced.enhancedFiltering
    
    -- Cache for performance
    self.scoreCache = {}
    self.keywordBlacklist = {"wts", "boost", "carry", "gold", "sale", "selling", "buy", "token", "cheap"}
    
    -- Register for events
    if self.isEnabled then
        self:RegisterHooks()
    end
end

-- Register necessary hooks
function AF:RegisterHooks()
    -- Hook into search function
    if C_LFGList.Search then
        hooksecurefunc("C_LFGList.Search", function(categoryID, filters, preferredFilters)
            if self.isEnabled and PGF.enabled then
                self:StoreSearchParameters(categoryID, filters, preferredFilters)
            end
        end)
    end
    
    -- Hook into search result display
    if _G.LFGListSearchEntry_Update then
        hooksecurefunc("LFGListSearchEntry_Update", function(button)
            if self.isEnabled and PGF.enabled then
                self:ApplyResultFiltering(button)
            end
        end)
    end
    
    -- Hook into tooltip display
    if _G.LFGListUtil_SetSearchEntryTooltip then
        hooksecurefunc("LFGListUtil_SetSearchEntryTooltip", function(tooltip, resultID)
            if self.isEnabled and PGF.enabled then
                self:EnhanceTooltip(tooltip, resultID)
            end
        end)
    end
    
    -- Hook into search panel setup
    if _G.LFGListSearchPanel_SetupSearchEntries then
        hooksecurefunc("LFGListSearchPanel_SetupSearchEntries", function(panel)
            if self.isEnabled and PGF.enabled then
                self:PostProcessSearchResults(panel)
            end
        end)
    end
end

-- Store search parameters for filtering
function AF:StoreSearchParameters(categoryID, filters, preferredFilters)
    self.currentSearch = {
        categoryID = categoryID,
        filters = filters,
        preferredFilters = preferredFilters
    }
end

-- Apply enhanced filtering to a search result
function AF:ApplyResultFiltering(button)
    if not button or not button.resultID then return end
    
    local resultID = button.resultID
    local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
    if not searchResultInfo then return end
    
    -- Check if this result should be hidden
    local shouldHide = false
    
    -- Filter by advertisement keywords
    if PGF.settings.advanced.hideAds then
        shouldHide = self:IsAdvertisement(searchResultInfo)
    end
    
    -- Apply minimum item level filter if set
    if PGF.settings.filters.minimumItemLevel > 0 and searchResultInfo.requiredItemLevel < PGF.settings.filters.minimumItemLevel then
        shouldHide = true
    end
    
    -- Apply role filters
    if self:ShouldFilterByRole(searchResultInfo) then
        shouldHide = true
    end
    
    -- Apply voice chat filter
    if PGF.settings.filters.voiceChat and (not searchResultInfo.voiceChat or searchResultInfo.voiceChat == "") then
        shouldHide = true
    end
    
    -- Hide if needed
    if shouldHide then
        button:Hide()
    else
        -- Button is visible, enhance its appearance
        self:EnhanceSearchEntry(button, searchResultInfo)
    end
end

-- Post-process search results
function AF:PostProcessSearchResults(panel)
    if not panel.SearchBox or not panel.SearchBox:GetText() then return end
    
    -- Get current search text
    local searchText = panel.SearchBox:GetText():lower()
    
    -- Process all visible results
    for i=1, #panel.SearchEntries do
        local button = panel.SearchEntries[i]
        if button and button.resultID and button:IsShown() then
            local resultID = button.resultID
            local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
            
            -- Apply text search filtering
            if searchResultInfo and searchText ~= "" then
                local matchFound = false
                
                -- Check activity name
                local activityInfo = C_LFGList.GetActivityInfoTable(searchResultInfo.activityID)
                if activityInfo and activityInfo.fullName and activityInfo.fullName:lower():find(searchText) then
                    matchFound = true
                end
                
                -- Check group name
                if searchResultInfo.name and searchResultInfo.name:lower():find(searchText) then
                    matchFound = true
                end
                
                -- Check comment
                if searchResultInfo.comment and searchResultInfo.comment:lower():find(searchText) then
                    matchFound = true
                end
                
                -- Hide if no match
                if not matchFound then
                    button:Hide()
                end
            end
        end
    end
    
    -- Update the displayed results count
    local visibleCount = 0
    for i=1, #panel.SearchEntries do
        if panel.SearchEntries[i]:IsShown() then
            visibleCount = visibleCount + 1
        end
    end
    
    if panel.totalResults then
        panel.totalResults:SetText(format("%d/%d Results", visibleCount, panel.totalResultsText or 0))
    end
end

-- Check if a search result is an advertisement
function AF:IsAdvertisement(searchResultInfo)
    -- Don't have enough info to determine
    if not searchResultInfo or not searchResultInfo.name or not searchResultInfo.comment then
        return false
    end
    
    -- Combine name and comment
    local fullText = (searchResultInfo.name .. " " .. searchResultInfo.comment):lower()
    
    -- Check for multiple keywords in a single group
    local keywordCount = 0
    for _, keyword in ipairs(self.keywordBlacklist) do
        if fullText:find(keyword) then
            keywordCount = keywordCount + 1
            if keywordCount >= 2 then
                return true
            end
        end
    end
    
    -- Check for obvious price formats (e.g., "100k", "500g", "$10")
    if fullText:match("%d+%s*[kg$]") or fullText:match("%$%s*%d+") then
        return true
    end
    
    -- Check for website URLs or Discord invites
    if fullText:match("discord%.gg") or fullText:match("www%.") or fullText:match("%.com") then
        local keywordFound = false
        for _, keyword in ipairs(self.keywordBlacklist) do
            if fullText:find(keyword) then
                keywordFound = true
                break
            end
        end
        
        if keywordFound then
            return true
        end
    end
    
    return false
end

-- Check if a result should be filtered by role requirements
function AF:ShouldFilterByRole(searchResultInfo)
    -- Skip if no role filters are enabled
    if not PGF.settings.filters.tankOnly and 
       not PGF.settings.filters.healerOnly and 
       not PGF.settings.filters.dpsOnly then
        return false
    end
    
    -- Check tank role
    if PGF.settings.filters.tankOnly and 
       (not searchResultInfo.tanks or searchResultInfo.tanks.available == 0) then
        return true
    end
    
    -- Check healer role
    if PGF.settings.filters.healerOnly and 
       (not searchResultInfo.healers or searchResultInfo.healers.available == 0) then
        return true
    end
    
    -- Check dps role
    if PGF.settings.filters.dpsOnly and 
       (not searchResultInfo.dps or searchResultInfo.dps.available == 0) then
        return true
    end
    
    return false
end

-- Enhance search entry with additional information
function AF:EnhanceSearchEntry(button, searchResultInfo)
    if not button or not searchResultInfo then return end
    
    -- Apply colored name if enabled
    if PGF.settings.appearance.coloredNames then
        self:ApplyColoredName(button, searchResultInfo)
    end
    
    -- Show leader score if enabled and RaiderIO integration enabled
    if PGF.settings.appearance.showLeaderScore and PGF.settings.advanced.showRaiderIO then
        self:ShowLeaderScore(button, searchResultInfo)
    end
    
    -- Show item level if enabled
    if PGF.settings.appearance.showItemLevel then
        self:ShowItemLevel(button, searchResultInfo)
    end
    
    -- Change entry style based on settings
    if PGF.settings.appearance.compactList then
        self:ApplyCompactStyle(button)
    else
        self:ApplyStandardStyle(button)
    end
end

-- Apply colored name to search entry
function AF:ApplyColoredName(button, searchResultInfo)
    if not button.Name then return end
    
    -- Try to get leader class from leader name
    local leaderName = searchResultInfo.leaderName
    if not leaderName then return end
    
    -- Default to no class coloring
    button.Name:SetTextColor(1, 1, 1)
    
    -- Get leader class from info if available
    if searchResultInfo.leaderClass then
        local classColor = RAID_CLASS_COLORS[searchResultInfo.leaderClass]
        if classColor then
            button.Name:SetTextColor(classColor.r, classColor.g, classColor.b)
        end
    end
end

-- Show leader score on search entry
function AF:ShowLeaderScore(button, searchResultInfo)
    -- Create score display if it doesn't exist
    if not button.VUILeaderScore then
        button.VUILeaderScore = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        button.VUILeaderScore:SetPoint("RIGHT", button.ActivityName or button.Name, "LEFT", -5, 0)
        button.VUILeaderScore:SetJustifyH("RIGHT")
    end
    
    -- Get leader score
    local score = self:GetLeaderScore(button.resultID)
    
    -- Update score display
    if score > 0 then
        button.VUILeaderScore:SetText("[" .. score .. "]")
        
        -- Set color based on score
        if score >= 2000 then
            button.VUILeaderScore:SetTextColor(1, 0.5, 0) -- Orange for high scores
        elseif score >= 1000 then
            button.VUILeaderScore:SetTextColor(0, 1, 0) -- Green for good scores
        else
            button.VUILeaderScore:SetTextColor(1, 1, 1) -- White for normal scores
        end
        
        button.VUILeaderScore:Show()
    else
        button.VUILeaderScore:Hide()
    end
end

-- Show item level on search entry
function AF:ShowItemLevel(button, searchResultInfo)
    -- Create item level display if it doesn't exist
    if not button.VUIItemLevel then
        button.VUIItemLevel = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        button.VUIItemLevel:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -5, 5)
    end
    
    -- Update item level display
    if searchResultInfo.requiredItemLevel > 0 then
        button.VUIItemLevel:SetText("iLvl: " .. searchResultInfo.requiredItemLevel)
        button.VUIItemLevel:Show()
        
        -- Set color based on player's item level
        local playerItemLevel = GetAverageItemLevel()
        if playerItemLevel < searchResultInfo.requiredItemLevel then
            button.VUIItemLevel:SetTextColor(1, 0, 0) -- Red if player doesn't meet requirement
        else
            button.VUIItemLevel:SetTextColor(0, 1, 0) -- Green if player meets requirement
        end
    else
        button.VUIItemLevel:Hide()
    end
end

-- Apply compact style to search entry
function AF:ApplyCompactStyle(button)
    -- Set compact height
    button:SetHeight(40)
    
    -- Adjust name position
    if button.Name then
        button.Name:SetPoint("TOPLEFT", 10, -5)
    end
    
    -- Adjust activity name position
    if button.ActivityName then
        button.ActivityName:SetPoint("TOPLEFT", button.Name, "BOTTOMLEFT", 0, -2)
    end
end

-- Apply standard style to search entry
function AF:ApplyStandardStyle(button)
    -- Set standard height
    button:SetHeight(56)
    
    -- Adjust name position
    if button.Name then
        button.Name:SetPoint("TOPLEFT", 10, -10)
    end
    
    -- Adjust activity name position
    if button.ActivityName then
        button.ActivityName:SetPoint("TOPLEFT", button.Name, "BOTTOMLEFT", 0, -4)
    end
end

-- Enhance tooltip with additional information
function AF:EnhanceTooltip(tooltip, resultID)
    if not tooltip or not resultID then return end
    
    local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
    if not searchResultInfo then return end
    
    -- Add extra information to tooltip
    if PGF.settings.appearance.enhancedTooltip then
        -- Add voice chat information
        if searchResultInfo.voiceChat and searchResultInfo.voiceChat ~= "" then
            tooltip:AddLine(" ")
            tooltip:AddLine("Voice Chat:", 1, 1, 1)
            tooltip:AddLine(searchResultInfo.voiceChat, 0.5, 0.8, 1)
        end
        
        -- Add activity information
        local activityInfo = C_LFGList.GetActivityInfoTable(searchResultInfo.activityID)
        if activityInfo then
            tooltip:AddLine(" ")
            tooltip:AddLine("Activity Info:", 1, 1, 1)
            
            if activityInfo.fullName then
                tooltip:AddDoubleLine("Name:", activityInfo.fullName, 1, 1, 1, 0.5, 0.8, 1)
            end
            
            if activityInfo.categoryID then
                local categoryName = nil
                if activityInfo.categoryID == 2 then
                    categoryName = "Dungeons"
                elseif activityInfo.categoryID == 3 then
                    categoryName = "Raids"
                elseif activityInfo.categoryID == 4 then
                    categoryName = "Arenas"
                elseif activityInfo.categoryID == 5 then
                    categoryName = "Battlegrounds"
                elseif activityInfo.categoryID == 6 then
                    categoryName = "Custom"
                end
                
                if categoryName then
                    tooltip:AddDoubleLine("Category:", categoryName, 1, 1, 1, 0.5, 0.8, 1)
                end
            end
            
            if activityInfo.difficulty then
                tooltip:AddDoubleLine("Difficulty:", activityInfo.difficulty, 1, 1, 1, 0.5, 0.8, 1)
            end
        end
        
        -- Add group details
        tooltip:AddLine(" ")
        tooltip:AddLine("Group Details:", 1, 1, 1)
        tooltip:AddDoubleLine("Created:", string.format("%d minutes ago", math.floor(searchResultInfo.age / 60)), 1, 1, 1, 0.5, 0.8, 1)
        tooltip:AddDoubleLine("Members:", searchResultInfo.numMembers, 1, 1, 1, 0.5, 0.8, 1)
        
        -- Show leader score if enabled and RaiderIO integration enabled
        if PGF.settings.advanced.showRaiderIO then
            local score = self:GetLeaderScore(resultID)
            if score > 0 then
                tooltip:AddLine(" ")
                tooltip:AddLine("Leader Ratings:", 1, 1, 1)
                tooltip:AddDoubleLine("Score:", score, 1, 1, 1, self:GetScoreColor(score))
            end
        end
    end
    
    -- Show the tooltip
    tooltip:Show()
end

-- Get leader score
function AF:GetLeaderScore(resultID)
    -- Check cache first for performance
    if self.scoreCache[resultID] then
        return self.scoreCache[resultID]
    end
    
    -- Default score if not found
    local score = 0
    
    -- Get search result info
    local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
    if not searchResultInfo then
        return 0
    end
    
    -- Try to find Raider.IO score if available
    if PGF.settings.advanced.showRaiderIO and _G.RaiderIO and _G.RaiderIO.GetScore then
        local leaderName = searchResultInfo.leaderName
        if leaderName and leaderName ~= "" then
            -- Remove realm information if present
            local name = leaderName:match("([^-]+)")
            
            -- Try to get Raider.IO score
            local rioProfile = _G.RaiderIO.GetProfile(name)
            if rioProfile and rioProfile.mythicKeystoneProfile and rioProfile.mythicKeystoneProfile.currentScore then
                score = rioProfile.mythicKeystoneProfile.currentScore
            end
        end
    end
    
    -- If no Raider.IO score, use approximate score based on activity
    if score == 0 then
        -- Get activity info
        local activityInfo = C_LFGList.GetActivityInfoTable(searchResultInfo.activityID)
        if activityInfo then
            -- Base score on the dungeon/raid level
            local baseScore = 0
            
            -- Parse activity name to extract M+ level
            local activityName = activityInfo.fullName or ""
            local keyLevel = activityName:match("+(%d+)")
            
            if keyLevel then
                -- M+ key level
                local level = tonumber(keyLevel) or 0
                baseScore = level * 100
            elseif activityInfo.categoryID == 2 then -- Dungeons
                -- Approximate based on difficulty
                if activityInfo.shortName and activityInfo.shortName:find("Heroic") then
                    baseScore = 500
                elseif activityInfo.shortName and activityInfo.shortName:find("Mythic") then
                    baseScore = 1000
                else
                    baseScore = 200
                end
            elseif activityInfo.categoryID == 3 then -- Raids
                -- Approximate based on difficulty
                if activityInfo.shortName and activityInfo.shortName:find("LFR") then
                    baseScore = 500
                elseif activityInfo.shortName and activityInfo.shortName:find("Normal") then
                    baseScore = 1000
                elseif activityInfo.shortName and activityInfo.shortName:find("Heroic") then
                    baseScore = 1500
                elseif activityInfo.shortName and activityInfo.shortName:find("Mythic") then
                    baseScore = 2000
                end
            end
            
            -- Add leader bonus
            score = baseScore + 200
            
            -- Item level bonus
            if searchResultInfo.requiredItemLevel > 0 then
                score = score + ((searchResultInfo.requiredItemLevel - 400) * 2)
            end
        end
    end
    
    -- Cache the score
    self.scoreCache[resultID] = score
    
    return math.floor(score)
end

-- Get score color based on value
function AF:GetScoreColor(score)
    if score >= 2000 then
        return 1, 0.5, 0 -- Orange for high scores
    elseif score >= 1500 then
        return 0, 1, 0 -- Green for good scores
    elseif score >= 1000 then
        return 0, 0.7, 1 -- Blue for decent scores
    elseif score >= 500 then
        return 0.5, 0.5, 1 -- Light blue for average scores
    else
        return 0.7, 0.7, 0.7 -- Gray for low scores
    end
end

-- Get average group score (for groups with multiple members)
function AF:GetAverageGroupScore(resultID)
    local leaderScore = self:GetLeaderScore(resultID)
    
    -- Approximate average as slightly lower than leader
    return math.floor(leaderScore * 0.9)
end

-- Enable advanced filtering
function AF:Enable()
    self.isEnabled = true
    self:RegisterHooks()
end

-- Disable advanced filtering
function AF:Disable()
    self.isEnabled = false
end