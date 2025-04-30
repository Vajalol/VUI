-------------------------------------------------------------------------------
-- Title: PGFinder Advanced Filtering
-- Author: VortexQ8
-- Enhanced filtering options for the Premade Group Finder
-------------------------------------------------------------------------------

local _, VUI = ...
local PGF = VUI.modules.pgfinder

-- Skip if PGFinder module is not available
if not PGF then return end

-- Create the advanced filtering namespace
PGF.AdvancedFiltering = {}
local AF = PGF.AdvancedFiltering

-- Default settings
local defaults = {
    enabled = true,
    
    -- Score thresholds
    minLeaderScore = 0,
    minAvgScore = 0,
    
    -- Role requirements
    requireMyRole = false,
    showFullGroups = true,
    hideIncompatibleDungeons = true,
    
    -- Dungeon preferences
    preferredDungeons = {},
    avoidedDungeons = {},
    
    -- Time and group settings
    maxGroupAge = 0, -- 0 = no limit, otherwise in minutes
    voiceOnly = false,
    guildGroupsOnly = false,
    
    -- Additional filters
    hideBoostGroups = true,
    hideInProgressGroups = false,
    onlyShowFriendsGroups = false,
}

-- Initialize advanced filtering
function AF:Initialize()
    self.isEnabled = PGF.db.profile.advancedFiltering.enabled
    
    -- Register for events
    if self.isEnabled then
        self:RegisterHooks()
    end
end

-- Register necessary hooks
function AF:RegisterHooks()
    -- Hook into the search result display function
    if _G.LFGListUtil_SortSearchResults then
        PGF:RawHook("LFGListUtil_SortSearchResults", function(results)
            if self.isEnabled then
                return self:FilterSearchResults(results)
            else
                return PGF.hooks.LFGListUtil_SortSearchResults(results)
            end
        end, true)
    end
    
    -- Hook into the apply button status check
    if _G.LFGListSearchPanel_UpdateButtonStatus then
        PGF:SecureHook("LFGListSearchPanel_UpdateButtonStatus", function(panel)
            if self.isEnabled then
                self:UpdateFilterUI(panel)
            end
        end)
    end
    
    -- Hook into the search panel's display
    if _G.LFGListSearchPanel_SetCategory then
        PGF:SecureHook("LFGListSearchPanel_SetCategory", function(panel, categoryID, filters)
            if self.isEnabled then
                self:CreateFilterUI(panel, categoryID)
            end
        end)
    end
end

-- Filter search results based on advanced criteria
function AF:FilterSearchResults(results)
    -- If not enabled, use default sorting
    if not self.isEnabled then
        return PGF.hooks.LFGListUtil_SortSearchResults(results)
    end
    
    -- Apply advanced filtering to the results
    local filteredResults = {}
    local settings = PGF.db.profile.advancedFiltering
    
    for i, resultID in ipairs(results) do
        if self:PassesAdvancedFilters(resultID) then
            table.insert(filteredResults, resultID)
        end
    end
    
    -- Apply custom sorting to the filtered results
    self:SortFilteredResults(filteredResults)
    
    return filteredResults
end

-- Check if a result passes all advanced filters
function AF:PassesAdvancedFilters(resultID)
    local settings = PGF.db.profile.advancedFiltering
    
    -- Get info about the group
    local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
    if not searchResultInfo then return false end
    
    -- Check for minimum leader score
    if settings.minLeaderScore > 0 then
        local leaderScore = self:GetLeaderScore(resultID)
        if leaderScore < settings.minLeaderScore then
            return false
        end
    end
    
    -- Check for minimum average score
    if settings.minAvgScore > 0 then
        local avgScore = self:GetAverageGroupScore(resultID)
        if avgScore < settings.minAvgScore then
            return false
        end
    end
    
    -- Check for role requirements
    if settings.requireMyRole and not self:HasMyRole(resultID) then
        return false
    end
    
    -- Check for full groups
    if not settings.showFullGroups and searchResultInfo.numMembers >= 5 then
        return false
    end
    
    -- Check for incompatible dungeons
    if settings.hideIncompatibleDungeons and not self:IsDungeonCompatible(resultID) then
        return false
    end
    
    -- Check for preferred/avoided dungeons
    local activityInfo = C_LFGList.GetActivityInfoTable(searchResultInfo.activityID)
    if activityInfo then
        local dungeonName = activityInfo.fullName or ""
        
        -- Skip if it's an avoided dungeon
        if settings.avoidedDungeons[dungeonName] then
            return false
        end
    end
    
    -- Check for group age
    if settings.maxGroupAge > 0 and searchResultInfo.elapsedTime > (settings.maxGroupAge * 60) then
        return false
    end
    
    -- Check for voice requirement
    if settings.voiceOnly and not searchResultInfo.voiceChat then
        return false
    end
    
    -- Check for guild groups
    if settings.guildGroupsOnly and not self:IsGuildGroup(resultID) then
        return false
    end
    
    -- Check for boost groups
    if settings.hideBoostGroups and self:IsBoostGroup(resultID) then
        return false
    end
    
    -- Check for in-progress groups
    if settings.hideInProgressGroups and searchResultInfo.isDelisted then
        return false
    end
    
    -- Check for friends' groups
    if settings.onlyShowFriendsGroups and not self:HasFriendInGroup(resultID) then
        return false
    end
    
    -- Passed all filters
    return true
end

-- Sort filtered results based on custom criteria
function AF:SortFilteredResults(results)
    local settings = PGF.db.profile.advancedFiltering
    
    -- Sort based on multiple criteria
    table.sort(results, function(a, b)
        local infoA = C_LFGList.GetSearchResultInfo(a)
        local infoB = C_LFGList.GetSearchResultInfo(b)
        if not infoA or not infoB then return false end
        
        -- First, prioritize preferred dungeons
        local activityInfoA = C_LFGList.GetActivityInfoTable(infoA.activityID)
        local activityInfoB = C_LFGList.GetActivityInfoTable(infoB.activityID)
        
        if activityInfoA and activityInfoB then
            local dungeonNameA = activityInfoA.fullName or ""
            local dungeonNameB = activityInfoB.fullName or ""
            
            local isPreferredA = settings.preferredDungeons[dungeonNameA] or false
            local isPreferredB = settings.preferredDungeons[dungeonNameB] or false
            
            if isPreferredA and not isPreferredB then
                return true
            elseif not isPreferredA and isPreferredB then
                return false
            end
        end
        
        -- Then, prioritize groups with friends
        local hasFriendA = self:HasFriendInGroup(a)
        local hasFriendB = self:HasFriendInGroup(b)
        
        if hasFriendA and not hasFriendB then
            return true
        elseif not hasFriendA and hasFriendB then
            return false
        end
        
        -- Then, prioritize higher scores
        local scoreA = self:GetAverageGroupScore(a)
        local scoreB = self:GetAverageGroupScore(b)
        
        if scoreA > scoreB then
            return true
        elseif scoreB > scoreA then
            return false
        end
        
        -- Finally, sort by freshness (newer first)
        return (infoA.elapsedTime or 0) < (infoB.elapsedTime or 0)
    end)
end

-- Helper function to get the leader's score (based on RIO or similar)
function AF:GetLeaderScore(resultID)
    local info = C_LFGList.GetSearchResultInfo(resultID)
    if not info then return 0 end
    
    -- Look for leader's score (this is where an integration with Raider.IO would occur)
    -- For now, return a placeholder value based on the activity's difficulty
    local activityInfo = C_LFGList.GetActivityInfoTable(info.activityID)
    if not activityInfo then return 0 end
    
    -- Base score on the dungeon/raid level
    local difficultyLevel = 0
    
    -- Parse activity name to extract M+ level
    local activityName = activityInfo.fullName or ""
    local keyLevel = activityName:match("+(%d+)")
    
    if keyLevel then
        difficultyLevel = tonumber(keyLevel) or 0
    elseif activityInfo.categoryID == 2 then -- Dungeons
        -- Approximate based on difficulty
        if activityInfo.shortName:find("Heroic") then
            difficultyLevel = 5
        elseif activityInfo.shortName:find("Mythic") then
            difficultyLevel = 10
        else
            difficultyLevel = 2
        end
    elseif activityInfo.categoryID == 3 then -- Raids
        -- Approximate based on difficulty
        if activityInfo.shortName:find("LFR") then
            difficultyLevel = 5
        elseif activityInfo.shortName:find("Normal") then
            difficultyLevel = 10
        elseif activityInfo.shortName:find("Heroic") then
            difficultyLevel = 15
        elseif activityInfo.shortName:find("Mythic") then
            difficultyLevel = 20
        end
    end
    
    -- Convert to an approximate score
    local score = difficultyLevel * 50
    
    -- Add leader bonus
    score = score + 200
    
    return score
end

-- Helper function to get average group score
function AF:GetAverageGroupScore(resultID)
    local info = C_LFGList.GetSearchResultInfo(resultID)
    if not info then return 0 end
    
    -- Start with leader's score
    local totalScore = self:GetLeaderScore(resultID)
    
    -- Average with estimated member scores (slightly lower than leader)
    local memberCount = info.numMembers or 1
    local averageMemberScore = totalScore * 0.85
    
    -- Calculate weighted average
    totalScore = totalScore + (averageMemberScore * (memberCount - 1))
    totalScore = totalScore / memberCount
    
    return math.floor(totalScore)
end

-- Check if the group has an available slot for the player's current role
function AF:HasMyRole(resultID)
    local info = C_LFGList.GetSearchResultInfo(resultID)
    if not info then return false end
    
    -- Get player's role
    local _, localizedClass, classID = UnitClass("player")
    local role = self:GetDefaultRole(classID)
    
    -- Check if the role is available
    if role == "TANK" and info.tanks and info.tanks.available > 0 then
        return true
    elseif role == "HEALER" and info.healers and info.healers.available > 0 then
        return true
    elseif role == "DAMAGER" and info.dps and info.dps.available > 0 then
        return true
    end
    
    return false
end

-- Get the default role for a class
function AF:GetDefaultRole(classID)
    -- Default roles by class
    local defaultRoles = {
        [1] = "DAMAGER",  -- Warrior
        [2] = "TANK",     -- Paladin
        [3] = "DAMAGER",  -- Hunter
        [4] = "DAMAGER",  -- Rogue
        [5] = "HEALER",   -- Priest
        [6] = "TANK",     -- Death Knight
        [7] = "HEALER",   -- Shaman
        [8] = "DAMAGER",  -- Mage
        [9] = "DAMAGER",  -- Warlock
        [10] = "HEALER",  -- Monk
        [11] = "DAMAGER", -- Druid
        [12] = "DAMAGER", -- Demon Hunter
        [13] = "DAMAGER", -- Evoker
    }
    
    -- Get specialization info
    local specIndex = GetSpecialization()
    if specIndex then
        local id, name, description, icon, role = GetSpecializationInfo(specIndex)
        if role then
            return role
        end
    end
    
    -- Fallback to class default
    return defaultRoles[classID] or "DAMAGER"
end

-- Check if the player meets the requirements for the dungeon
function AF:IsDungeonCompatible(resultID)
    local info = C_LFGList.GetSearchResultInfo(resultID)
    if not info then return false end
    
    -- Get activity info
    local activityInfo = C_LFGList.GetActivityInfoTable(info.activityID)
    if not activityInfo then return true end -- If we can't determine, assume compatible
    
    -- Check for Mythic+ level
    local keyLevel = 0
    local activityName = activityInfo.fullName or ""
    local keyLevelMatch = activityName:match("+(%d+)")
    
    if keyLevelMatch then
        keyLevel = tonumber(keyLevelMatch) or 0
    end
    
    -- Get player's item level
    local playerItemLevel = self:GetPlayerItemLevel()
    
    -- Check if player's item level is sufficient for the key level
    local recommendedItemLevel = 400 + (keyLevel * 3) -- Approximate formula
    return playerItemLevel >= recommendedItemLevel
end

-- Get player's item level
function AF:GetPlayerItemLevel()
    local avgItemLevel, avgItemLevelEquipped = GetAverageItemLevel()
    return avgItemLevelEquipped
end

-- Check if a group is a guild group
function AF:IsGuildGroup(resultID)
    local info = C_LFGList.GetSearchResultInfo(resultID)
    if not info or not info.leaderName then return false end
    
    -- Check if leader is in player's guild
    local leaderName = info.leaderName
    local totalMembers = GetNumGuildMembers()
    
    for i = 1, totalMembers do
        local name = GetGuildRosterInfo(i)
        if name and name:match("^([^-]+)") == leaderName then
            return true
        end
    end
    
    return false
end

-- Check if a group is likely a boost group
function AF:IsBoostGroup(resultID)
    local info = C_LFGList.GetSearchResultInfo(resultID)
    if not info then return false end
    
    -- Check various indicators of boost groups
    local title = info.name or ""
    local comment = info.comment or ""
    local voice = info.voiceChat or ""
    
    -- Common boost keywords
    local boostKeywords = {
        "wts", "selling", "boost", "carry", "gold", "sale", 
        "$", "€", "£", "cash", "pay", "buy", "cheap",
        "discount", "offer", "fast", "efficient", "guaranteed"
    }
    
    -- Check if any boost keywords are in the title or comment
    local fullText = title:lower() .. " " .. comment:lower() .. " " .. voice:lower()
    
    for _, keyword in ipairs(boostKeywords) do
        if fullText:find(keyword) then
            return true
        end
    end
    
    return false
end

-- Check if a friend is in the group
function AF:HasFriendInGroup(resultID)
    local info = C_LFGList.GetSearchResultInfo(resultID)
    if not info or not info.leaderName then return false end
    
    -- Check if leader is a friend
    local leaderName = info.leaderName
    local numFriends = C_FriendList.GetNumFriends()
    
    for i = 1, numFriends do
        local friend = C_FriendList.GetFriendInfoByIndex(i)
        if friend and friend.name and friend.name:match("^([^-]+)") == leaderName then
            return true
        end
    end
    
    -- Check battle.net friends as well
    local numBNetFriends = BNGetNumFriends()
    
    for i = 1, numBNetFriends do
        local accountInfo = C_BattleNet.GetFriendAccountInfo(i)
        if accountInfo and accountInfo.gameAccountInfo then
            local gameInfo = accountInfo.gameAccountInfo
            if gameInfo.characterName == leaderName then
                return true
            end
        end
    end
    
    return false
end

-- Create the filter UI
function AF:CreateFilterUI(panel, categoryID)
    -- Only create for certain categories
    if not (categoryID == 2 or categoryID == 3) then
        -- 2 = Dungeons, 3 = Raids
        return
    end
    
    -- Check if UI already exists
    if panel.VUIAdvancedFilters then
        panel.VUIAdvancedFilters:Show()
        return
    end
    
    -- Create the filter button
    local filterButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    filterButton:SetSize(100, 22)
    filterButton:SetText("VUI Filters")
    filterButton:SetPoint("TOPRIGHT", panel.RefreshButton, "TOPLEFT", -5, 0)
    filterButton:SetScript("OnClick", function()
        if panel.VUIFilterFrame and panel.VUIFilterFrame:IsShown() then
            panel.VUIFilterFrame:Hide()
        else
            self:ShowFilterFrame(panel)
        end
    end)
    
    panel.VUIAdvancedFilters = filterButton
    
    -- Apply theme to the button
    if PGF.ThemeIntegration then
        PGF.ThemeIntegration:ApplyButtonTheme(filterButton)
    end
end

-- Show the filter frame with all options
function AF:ShowFilterFrame(panel)
    -- Create filter frame if it doesn't exist
    if not panel.VUIFilterFrame then
        local frame = CreateFrame("Frame", nil, panel, "BackdropTemplate")
        frame:SetSize(250, 400)
        frame:SetPoint("TOPLEFT", panel, "TOPRIGHT", 5, 0)
        frame:SetFrameStrata("DIALOG")
        frame:EnableMouse(true)
        
        -- Apply backdrop
        frame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 32,
            edgeSize = 32,
            insets = { left = 11, right = 12, top = 12, bottom = 11 }
        })
        
        -- Add title
        local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        title:SetPoint("TOPLEFT", 16, -16)
        title:SetPoint("TOPRIGHT", -16, -16)
        title:SetJustifyH("CENTER")
        title:SetText("VUI Advanced Filters")
        
        -- Create scrolling content frame
        local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", 12, -36)
        scrollFrame:SetPoint("BOTTOMRIGHT", -30, 48)
        
        local content = CreateFrame("Frame", nil, scrollFrame)
        content:SetSize(scrollFrame:GetWidth(), 500) -- Makes it scrollable
        scrollFrame:SetScrollChild(content)
        
        -- Add controls to the content frame
        local yOffset = -10
        local spacing = 25
        
        -- Score filters section
        local scoreTitle = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        scoreTitle:SetPoint("TOPLEFT", 10, yOffset)
        scoreTitle:SetPoint("TOPRIGHT", -10, yOffset)
        scoreTitle:SetJustifyH("LEFT")
        scoreTitle:SetText("Score Requirements")
        yOffset = yOffset - 20
        
        -- Min Leader Score slider
        local leaderScoreSlider = CreateFrame("Slider", nil, content, "OptionsSliderTemplate")
        leaderScoreSlider:SetPoint("TOPLEFT", 10, yOffset)
        leaderScoreSlider:SetPoint("TOPRIGHT", -10, yOffset)
        leaderScoreSlider:SetMinMaxValues(0, 3000)
        leaderScoreSlider:SetValueStep(50)
        leaderScoreSlider:SetObeyStepOnDrag(true)
        leaderScoreSlider:SetValue(PGF.db.profile.advancedFiltering.minLeaderScore)
        leaderScoreSlider.Low:SetText("0")
        leaderScoreSlider.High:SetText("3000")
        leaderScoreSlider.Text:SetText("Min Leader Score: " .. leaderScoreSlider:GetValue())
        
        leaderScoreSlider:SetScript("OnValueChanged", function(self, value)
            value = math.floor(value / 50) * 50 -- Round to nearest 50
            PGF.db.profile.advancedFiltering.minLeaderScore = value
            self.Text:SetText("Min Leader Score: " .. value)
            panel.SearchBox:GetScript("OnTextChanged")(panel.SearchBox)
        end)
        
        yOffset = yOffset - spacing
        
        -- Min Average Score slider
        local avgScoreSlider = CreateFrame("Slider", nil, content, "OptionsSliderTemplate")
        avgScoreSlider:SetPoint("TOPLEFT", 10, yOffset)
        avgScoreSlider:SetPoint("TOPRIGHT", -10, yOffset)
        avgScoreSlider:SetMinMaxValues(0, 3000)
        avgScoreSlider:SetValueStep(50)
        avgScoreSlider:SetObeyStepOnDrag(true)
        avgScoreSlider:SetValue(PGF.db.profile.advancedFiltering.minAvgScore)
        avgScoreSlider.Low:SetText("0")
        avgScoreSlider.High:SetText("3000")
        avgScoreSlider.Text:SetText("Min Average Score: " .. avgScoreSlider:GetValue())
        
        avgScoreSlider:SetScript("OnValueChanged", function(self, value)
            value = math.floor(value / 50) * 50 -- Round to nearest 50
            PGF.db.profile.advancedFiltering.minAvgScore = value
            self.Text:SetText("Min Average Score: " .. value)
            panel.SearchBox:GetScript("OnTextChanged")(panel.SearchBox)
        end)
        
        yOffset = yOffset - spacing - 15
        
        -- Role filters section
        local roleTitle = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        roleTitle:SetPoint("TOPLEFT", 10, yOffset)
        roleTitle:SetPoint("TOPRIGHT", -10, yOffset)
        roleTitle:SetJustifyH("LEFT")
        roleTitle:SetText("Role Requirements")
        yOffset = yOffset - 20
        
        -- Require my role checkbox
        local requireRoleCheckbox = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
        requireRoleCheckbox:SetPoint("TOPLEFT", 10, yOffset)
        requireRoleCheckbox:SetChecked(PGF.db.profile.advancedFiltering.requireMyRole)
        requireRoleCheckbox.text:SetText("Require My Role Available")
        requireRoleCheckbox.text:SetFontObject("GameFontNormal")
        
        requireRoleCheckbox:SetScript("OnClick", function(self)
            PGF.db.profile.advancedFiltering.requireMyRole = self:GetChecked()
            panel.SearchBox:GetScript("OnTextChanged")(panel.SearchBox)
        end)
        
        yOffset = yOffset - spacing
        
        -- Show full groups checkbox
        local fullGroupsCheckbox = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
        fullGroupsCheckbox:SetPoint("TOPLEFT", 10, yOffset)
        fullGroupsCheckbox:SetChecked(PGF.db.profile.advancedFiltering.showFullGroups)
        fullGroupsCheckbox.text:SetText("Show Full Groups")
        fullGroupsCheckbox.text:SetFontObject("GameFontNormal")
        
        fullGroupsCheckbox:SetScript("OnClick", function(self)
            PGF.db.profile.advancedFiltering.showFullGroups = self:GetChecked()
            panel.SearchBox:GetScript("OnTextChanged")(panel.SearchBox)
        end)
        
        yOffset = yOffset - spacing
        
        -- Hide incompatible dungeons checkbox
        local incompatibleCheckbox = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
        incompatibleCheckbox:SetPoint("TOPLEFT", 10, yOffset)
        incompatibleCheckbox:SetChecked(PGF.db.profile.advancedFiltering.hideIncompatibleDungeons)
        incompatibleCheckbox.text:SetText("Hide Incompatible Dungeons")
        incompatibleCheckbox.text:SetFontObject("GameFontNormal")
        
        incompatibleCheckbox:SetScript("OnClick", function(self)
            PGF.db.profile.advancedFiltering.hideIncompatibleDungeons = self:GetChecked()
            panel.SearchBox:GetScript("OnTextChanged")(panel.SearchBox)
        end)
        
        yOffset = yOffset - spacing - 15
        
        -- Additional filters section
        local additionalTitle = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        additionalTitle:SetPoint("TOPLEFT", 10, yOffset)
        additionalTitle:SetPoint("TOPRIGHT", -10, yOffset)
        additionalTitle:SetJustifyH("LEFT")
        additionalTitle:SetText("Additional Filters")
        yOffset = yOffset - 20
        
        -- Hide boost groups checkbox
        local boostCheckbox = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
        boostCheckbox:SetPoint("TOPLEFT", 10, yOffset)
        boostCheckbox:SetChecked(PGF.db.profile.advancedFiltering.hideBoostGroups)
        boostCheckbox.text:SetText("Hide Boost Groups")
        boostCheckbox.text:SetFontObject("GameFontNormal")
        
        boostCheckbox:SetScript("OnClick", function(self)
            PGF.db.profile.advancedFiltering.hideBoostGroups = self:GetChecked()
            panel.SearchBox:GetScript("OnTextChanged")(panel.SearchBox)
        end)
        
        yOffset = yOffset - spacing
        
        -- Hide in-progress groups checkbox
        local inProgressCheckbox = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
        inProgressCheckbox:SetPoint("TOPLEFT", 10, yOffset)
        inProgressCheckbox:SetChecked(PGF.db.profile.advancedFiltering.hideInProgressGroups)
        inProgressCheckbox.text:SetText("Hide In-Progress Groups")
        inProgressCheckbox.text:SetFontObject("GameFontNormal")
        
        inProgressCheckbox:SetScript("OnClick", function(self)
            PGF.db.profile.advancedFiltering.hideInProgressGroups = self:GetChecked()
            panel.SearchBox:GetScript("OnTextChanged")(panel.SearchBox)
        end)
        
        yOffset = yOffset - spacing
        
        -- Friends groups only checkbox
        local friendsCheckbox = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
        friendsCheckbox:SetPoint("TOPLEFT", 10, yOffset)
        friendsCheckbox:SetChecked(PGF.db.profile.advancedFiltering.onlyShowFriendsGroups)
        friendsCheckbox.text:SetText("Only Show Friend's Groups")
        friendsCheckbox.text:SetFontObject("GameFontNormal")
        
        friendsCheckbox:SetScript("OnClick", function(self)
            PGF.db.profile.advancedFiltering.onlyShowFriendsGroups = self:GetChecked()
            panel.SearchBox:GetScript("OnTextChanged")(panel.SearchBox)
        end)
        
        yOffset = yOffset - spacing
        
        -- Guild groups only checkbox
        local guildCheckbox = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
        guildCheckbox:SetPoint("TOPLEFT", 10, yOffset)
        guildCheckbox:SetChecked(PGF.db.profile.advancedFiltering.guildGroupsOnly)
        guildCheckbox.text:SetText("Only Show Guild Groups")
        guildCheckbox.text:SetFontObject("GameFontNormal")
        
        guildCheckbox:SetScript("OnClick", function(self)
            PGF.db.profile.advancedFiltering.guildGroupsOnly = self:GetChecked()
            panel.SearchBox:GetScript("OnTextChanged")(panel.SearchBox)
        end)
        
        yOffset = yOffset - spacing
        
        -- Voice required checkbox
        local voiceCheckbox = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
        voiceCheckbox:SetPoint("TOPLEFT", 10, yOffset)
        voiceCheckbox:SetChecked(PGF.db.profile.advancedFiltering.voiceOnly)
        voiceCheckbox.text:SetText("Voice Chat Required")
        voiceCheckbox.text:SetFontObject("GameFontNormal")
        
        voiceCheckbox:SetScript("OnClick", function(self)
            PGF.db.profile.advancedFiltering.voiceOnly = self:GetChecked()
            panel.SearchBox:GetScript("OnTextChanged")(panel.SearchBox)
        end)
        
        yOffset = yOffset - spacing
        
        -- Maximum group age slider
        local ageSlider = CreateFrame("Slider", nil, content, "OptionsSliderTemplate")
        ageSlider:SetPoint("TOPLEFT", 10, yOffset)
        ageSlider:SetPoint("TOPRIGHT", -10, yOffset)
        ageSlider:SetMinMaxValues(0, 60)
        ageSlider:SetValueStep(5)
        ageSlider:SetObeyStepOnDrag(true)
        ageSlider:SetValue(PGF.db.profile.advancedFiltering.maxGroupAge)
        ageSlider.Low:SetText("No Limit")
        ageSlider.High:SetText("60 min")
        
        local ageText = "Max Group Age: " .. (PGF.db.profile.advancedFiltering.maxGroupAge > 0 and PGF.db.profile.advancedFiltering.maxGroupAge .. " min" or "No Limit")
        ageSlider.Text:SetText(ageText)
        
        ageSlider:SetScript("OnValueChanged", function(self, value)
            value = math.floor(value / 5) * 5 -- Round to nearest 5
            PGF.db.profile.advancedFiltering.maxGroupAge = value
            
            local text = "Max Group Age: " .. (value > 0 and value .. " min" or "No Limit")
            self.Text:SetText(text)
            
            panel.SearchBox:GetScript("OnTextChanged")(panel.SearchBox)
        end)
        
        yOffset = yOffset - spacing - 15
        
        -- Add buttons at the bottom
        local resetButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        resetButton:SetSize(100, 25)
        resetButton:SetPoint("BOTTOMLEFT", 16, 14)
        resetButton:SetText("Reset")
        resetButton:SetScript("OnClick", function()
            self:ResetFilters()
            panel.VUIFilterFrame:Hide()
            panel.VUIFilterFrame = nil
            panel.SearchBox:GetScript("OnTextChanged")(panel.SearchBox)
        end)
        
        local closeButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        closeButton:SetSize(100, 25)
        closeButton:SetPoint("BOTTOMRIGHT", -16, 14)
        closeButton:SetText("Close")
        closeButton:SetScript("OnClick", function()
            panel.VUIFilterFrame:Hide()
        end)
        
        -- Apply theme to frame and buttons
        if PGF.ThemeIntegration then
            PGF.ThemeIntegration:ApplyFrameTheme(frame)
            PGF.ThemeIntegration:ApplyButtonTheme(resetButton)
            PGF.ThemeIntegration:ApplyButtonTheme(closeButton)
        end
        
        panel.VUIFilterFrame = frame
    end
    
    -- Show the filter frame
    panel.VUIFilterFrame:Show()
end

-- Update filter UI state
function AF:UpdateFilterUI(panel)
    if not panel.VUIAdvancedFilters then
        return
    end
    
    -- Update filter button state based on applied filters
    local hasActiveFilters = false
    local settings = PGF.db.profile.advancedFiltering
    
    -- Check if any non-default filters are active
    if settings.minLeaderScore > 0 or
       settings.minAvgScore > 0 or
       settings.requireMyRole or
       not settings.showFullGroups or
       settings.hideIncompatibleDungeons ~= defaults.hideIncompatibleDungeons or
       settings.maxGroupAge > 0 or
       settings.voiceOnly or
       settings.guildGroupsOnly or
       settings.hideBoostGroups ~= defaults.hideBoostGroups or
       settings.hideInProgressGroups ~= defaults.hideInProgressGroups or
       settings.onlyShowFriendsGroups ~= defaults.onlyShowFriendsGroups then
        hasActiveFilters = true
    end
    
    -- Visual indicator for active filters
    if hasActiveFilters then
        panel.VUIAdvancedFilters:SetText("VUI Filters*")
        if PGF.ThemeIntegration then
            PGF.ThemeIntegration:ApplyButtonActiveTheme(panel.VUIAdvancedFilters)
        else
            panel.VUIAdvancedFilters:SetNormalFontObject("GameFontHighlight")
        end
    else
        panel.VUIAdvancedFilters:SetText("VUI Filters")
        if PGF.ThemeIntegration then
            PGF.ThemeIntegration:ApplyButtonTheme(panel.VUIAdvancedFilters)
        else
            panel.VUIAdvancedFilters:SetNormalFontObject("GameFontNormal")
        end
    end
end

-- Reset all filters to defaults
function AF:ResetFilters()
    for k, v in pairs(defaults) do
        PGF.db.profile.advancedFiltering[k] = v
    end
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