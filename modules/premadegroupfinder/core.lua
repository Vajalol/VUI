-- VUI Premade Group Finder Module - Core Functionality
local _, VUI = ...
local PGF = VUI.premadegroupfinder

-- Constants
local ROLE_ICONS = {
    TANK = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:0:19:22:41|t",
    HEALER = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:1:20|t",
    DAMAGER = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:22:41|t",
}

local CLASS_COLORS = {
    ["WARRIOR"] = "|cFFC79C6E", -- Tan
    ["PALADIN"] = "|cFFF58CBA", -- Pink
    ["HUNTER"] = "|cFFABD473", -- Green
    ["ROGUE"] = "|cFFFFF569", -- Yellow
    ["PRIEST"] = "|cFFFFFFFF", -- White
    ["DEATHKNIGHT"] = "|cFFC41F3B", -- Red
    ["SHAMAN"] = "|cFF0070DE", -- Blue
    ["MAGE"] = "|cFF69CCF0", -- Light blue
    ["WARLOCK"] = "|cFF9482C9", -- Purple
    ["MONK"] = "|cFF00FF96", -- Jade
    ["DRUID"] = "|cFFFF7D0A", -- Orange
    ["DEMONHUNTER"] = "|cFFA330C9", -- Dark Purple
    ["EVOKER"] = "|cFF33937F", -- Teal
}

local AD_KEYWORDS = {
    "wts", "sell", "gold", "boost", "carry", "www", "http", ".com", "free", "twitch", "stream"
}

-- Set up hooks
function PGF:SetupHooks()
    if self.lfgFrameHooked then return end
    
    -- First, find the LFG List frame
    if not LFGListFrame then
        VUI:Print("Error: Cannot find LFGListFrame. Premade Group Finder enhancements disabled.")
        return
    end
    
    -- Save current scale
    local oldScale = LFGListFrame:GetScale()
    
    -- Apply our scale
    LFGListFrame:SetScale(self.settings.scale or 1.0)
    
    -- Make frame movable
    LFGListFrame:SetMovable(true)
    LFGListFrame:EnableMouse(true)
    
    -- Add custom header for dragging
    self:CreateDragHeader(LFGListFrame)
    
    -- Hook search results display
    if LFGListFrame.SearchPanel and LFGListFrame.SearchPanel.ScrollFrame and LFGListFrame.SearchPanel.ScrollFrame.buttons then
        for i, button in ipairs(LFGListFrame.SearchPanel.ScrollFrame.buttons) do
            self:HookSearchResult(button)
        end
        
        -- Hook results update
        hooksecurefunc("LFGListSearchPanel_UpdateResults", function(panel)
            self:UpdateSearchResults(panel)
        end)
    end
    
    -- Hook search entry tooltip
    hooksecurefunc("LFGListUtil_SetSearchEntryTooltip", function(tooltip, resultID)
        self:EnhanceSearchEntryTooltip(tooltip, resultID)
    end)
    
    -- Hook search results received
    hooksecurefunc("LFGListSearchPanel_UpdateResults", function(panel)
        if not self.enabled then return end
        self:ProcessSearchResults(panel)
    end)
    
    -- Hook application listing
    hooksecurefunc("LFGListApplicationViewer_UpdateApplicantMember", function(member, appID, memberIdx)
        if not self.enabled then return end
        self:EnhanceApplicantListing(member, appID, memberIdx)
    end)
    
    -- Hook activity finder
    if LFGListFrame.CategorySelection then
        hooksecurefunc("LFGListCategorySelection_SelectCategory", function(panel, categoryID, filters)
            if not self.enabled then return end
            self:EnhanceActivitySelection(panel, categoryID, filters)
        end)
    end
    
    -- Apply filters on search
    hooksecurefunc("LFGListSearchPanel_DoSearch", function(panel)
        if not self.enabled then return end
        C_Timer.After(0.5, function() self:ApplyFilters() end)
    end)
    
    -- Hook entry creation
    hooksecurefunc("LFGListEntryCreation_Update", function(panel)
        if not self.enabled then return end
        self:EnhanceEntryCreation(panel)
    end)
    
    -- Hook group creation button
    if LFGListFrame.EntryCreation and LFGListFrame.EntryCreation.ListGroupButton then
        self:HookButton(LFGListFrame.EntryCreation.ListGroupButton, "List Group", function()
            if not self.enabled then return end
            -- No custom action, just visual styling
        end)
    end
    
    -- Hook search button
    if LFGListFrame.SearchPanel and LFGListFrame.SearchPanel.SearchButton then
        self:HookButton(LFGListFrame.SearchPanel.SearchButton, "Search", function()
            if not self.enabled then return end
            -- Apply filters after search
            C_Timer.After(0.5, function() self:ApplyFilters() end)
        end)
    end
    
    -- Add custom filter UI
    self:CreateFilterUI()
    
    -- Add quick search buttons
    self:CreateQuickSearchButtons()
    
    -- Mark as hooked
    self.lfgFrameHooked = true
    
    -- Position the frame from saved settings
    if self.settings.position then
        local pos = self.settings.position
        LFGListFrame:ClearAllPoints()
        LFGListFrame:SetPoint(pos[1], UIParent, pos[1], pos[2], pos[3])
    end
    
    VUI:Print("Premade Group Finder enhancements initialized")
end

-- Disable hooks
function PGF:DisableHooks()
    if not self.lfgFrameHooked then return end
    
    -- Restore original behavior where possible
    if LFGListFrame then
        LFGListFrame:SetMovable(false)
        LFGListFrame:EnableMouse(false)
        LFGListFrame:SetScale(1.0)
        
        if self.dragHeader then
            self.dragHeader:Hide()
        end
        
        -- Hide custom UI elements
        if self.filterFrame then
            self.filterFrame:Hide()
        end
        
        if self.quickSearchFrame then
            self.quickSearchFrame:Hide()
        end
    end
    
    -- Mark as unhooked
    self.lfgFrameHooked = false
    
    VUI:Print("Premade Group Finder enhancements disabled")
end

-- Create drag header
function PGF:CreateDragHeader(frame)
    if self.dragHeader then return self.dragHeader end
    
    self.dragHeader = self:CreateFrame("VUIPGFDragHeader", frame)
    self.dragHeader:SetHeight(24)
    self.dragHeader:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    self.dragHeader:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    
    -- Make it blend visually
    self.dragHeader:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
    self.dragHeader:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
    
    -- Add title
    self.dragHeaderText = self.dragHeader:CreateFontString(nil, "OVERLAY")
    self.dragHeaderText:SetPoint("LEFT", self.dragHeader, "LEFT", 10, 0)
    self.dragHeaderText:SetText("|cFFFFD100Enhanced Premade Group Finder|r")
    
    -- Apply font
    local fontPath = VUI:GetFont(VUI.db.profile.appearance.font)
    local fontSize = VUI.db.profile.appearance.fontSize
    self.dragHeaderText:SetFont(fontPath, fontSize, "")
    
    -- Set up dragging
    self.dragHeader:SetScript("OnMouseDown", function()
        frame:StartMoving()
    end)
    
    self.dragHeader:SetScript("OnMouseUp", function()
        frame:StopMovingOrSizing()
        
        -- Save position
        local point, _, _, xOfs, yOfs = frame:GetPoint()
        self.settings.position = {point, xOfs, yOfs}
    end)
    
    -- Add settings button
    self.settingsButton = self:CreateButton("VUIPGFSettingsButton", self.dragHeader, "Settings")
    self.settingsButton:SetSize(80, 18)
    self.settingsButton:SetPoint("RIGHT", self.dragHeader, "RIGHT", -5, 0)
    self.settingsButton:SetScript("OnClick", function()
        self:OpenConfig()
    end)
    
    return self.dragHeader
end

-- Create filter UI
function PGF:CreateFilterUI()
    if self.filterFrame then return self.filterFrame end
    
    -- Create filter frame
    self.filterFrame = self:CreateFrame("VUIPGFFilterFrame", LFGListFrame.SearchPanel)
    self.filterFrame:SetHeight(50)
    self.filterFrame:SetPoint("TOPLEFT", LFGListFrame.SearchPanel, "TOPLEFT", 0, -70)
    self.filterFrame:SetPoint("TOPRIGHT", LFGListFrame.SearchPanel, "TOPRIGHT", 0, -70)
    
    -- Apply background color
    self.filterFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
    
    -- Create minimum ilvl slider
    local ilvlText = self.filterFrame:CreateFontString(nil, "OVERLAY")
    ilvlText:SetPoint("TOPLEFT", self.filterFrame, "TOPLEFT", 15, -10)
    ilvlText:SetText("Min iLevel:")
    
    -- Apply font
    local fontPath = VUI:GetFont(VUI.db.profile.appearance.font)
    local fontSize = VUI.db.profile.appearance.fontSize - 1
    ilvlText:SetFont(fontPath, fontSize, "")
    
    self.ilvlSlider = self:CreateSlider(self.filterFrame, "VUIPGFIlvlSlider", "", 0, 500, 5)
    self.ilvlSlider:SetWidth(150)
    self.ilvlSlider:SetPoint("LEFT", ilvlText, "RIGHT", 10, 0)
    self.ilvlSlider:SetValue(self.settings.filters.minimumItemLevel)
    self.ilvlSlider:SetScript("OnValueChanged", function(_, value)
        self.settings.filters.minimumItemLevel = value
        self.filters.minIlvl = value
        self:ApplyFilters()
    end)
    
    -- Create role checkboxes
    local rolesText = self.filterFrame:CreateFontString(nil, "OVERLAY")
    rolesText:SetPoint("LEFT", self.ilvlSlider, "RIGHT", 20, 0)
    rolesText:SetText("Roles:")
    rolesText:SetFont(fontPath, fontSize, "")
    
    -- Tank
    self.tankCheckbox = self:CreateCheckButton("VUIPGFTankCheckbox", self.filterFrame, "Tank", "Interface\\AddOns\\VUI\\media\\icons\\premadegroupfinder\\tank.svg")
    self.tankCheckbox:SetPoint("LEFT", rolesText, "RIGHT", 5, 0)
    self.tankCheckbox:SetChecked(self.settings.filters.tankOnly)
    self.tankCheckbox:SetScript("OnClick", function(cb)
        self.settings.filters.tankOnly = cb:GetChecked()
        self.filters.roleRequired.tank = cb:GetChecked()
        self:ApplyFilters()
    end)
    
    -- Healer
    self.healerCheckbox = self:CreateCheckButton("VUIPGFHealerCheckbox", self.filterFrame, "Healer", "Interface\\AddOns\\VUI\\media\\icons\\premadegroupfinder\\healer.svg")
    self.healerCheckbox:SetPoint("LEFT", self.tankCheckbox, "RIGHT", 60, 0)
    self.healerCheckbox:SetChecked(self.settings.filters.healerOnly)
    self.healerCheckbox:SetScript("OnClick", function(cb)
        self.settings.filters.healerOnly = cb:GetChecked()
        self.filters.roleRequired.healer = cb:GetChecked()
        self:ApplyFilters()
    end)
    
    -- DPS
    self.dpsCheckbox = self:CreateCheckButton("VUIPGFDPSCheckbox", self.filterFrame, "DPS", "Interface\\AddOns\\VUI\\media\\icons\\premadegroupfinder\\dps.svg")
    self.dpsCheckbox:SetPoint("LEFT", self.healerCheckbox, "RIGHT", 60, 0)
    self.dpsCheckbox:SetChecked(self.settings.filters.dpsOnly)
    self.dpsCheckbox:SetScript("OnClick", function(cb)
        self.settings.filters.dpsOnly = cb:GetChecked()
        self.filters.roleRequired.dps = cb:GetChecked()
        self:ApplyFilters()
    end)
    
    -- Voice chat
    self.voiceChatCheckbox = self:CreateCheckButton("VUIPGFVoiceChatCheckbox", self.filterFrame, "Voice Chat", "Interface\\AddOns\\VUI\\media\\icons\\premadegroupfinder\\voicechat.svg")
    self.voiceChatCheckbox:SetPoint("LEFT", self.dpsCheckbox, "RIGHT", 60, 0)
    self.voiceChatCheckbox:SetChecked(self.settings.filters.voiceChat)
    self.voiceChatCheckbox:SetScript("OnClick", function(cb)
        self.settings.filters.voiceChat = cb:GetChecked()
        self.filters.voiceChat = cb:GetChecked()
        self:ApplyFilters()
    end)
    
    -- Create refresh button
    self.refreshButton = self:CreateButton("VUIPGFRefreshButton", self.filterFrame, "Refresh", "Interface\\AddOns\\VUI\\media\\icons\\premadegroupfinder\\refresh.svg")
    self.refreshButton:SetSize(80, 20)
    self.refreshButton:SetPoint("TOPRIGHT", self.filterFrame, "TOPRIGHT", -15, -15)
    self.refreshButton:SetScript("OnClick", function()
        self:RefreshList()
    end)
    
    -- Create reset filters button
    self.resetFiltersButton = self:CreateButton("VUIPGFResetFiltersButton", self.filterFrame, "Reset Filters", "Interface\\AddOns\\VUI\\media\\icons\\premadegroupfinder\\filter.svg")
    self.resetFiltersButton:SetSize(100, 20)
    self.resetFiltersButton:SetPoint("RIGHT", self.refreshButton, "LEFT", -10, 0)
    self.resetFiltersButton:SetScript("OnClick", function()
        self:ResetFilters()
    end)
    
    return self.filterFrame
end

-- Create quick search buttons
function PGF:CreateQuickSearchButtons()
    if self.quickSearchFrame then return self.quickSearchFrame end
    
    -- Create container frame
    self.quickSearchFrame = self:CreateFrame("VUIPGFQuickSearchFrame", LFGListFrame.SearchPanel)
    self.quickSearchFrame:SetHeight(30)
    self.quickSearchFrame:SetPoint("TOPLEFT", self.filterFrame, "BOTTOMLEFT", 0, 0)
    self.quickSearchFrame:SetPoint("TOPRIGHT", self.filterFrame, "BOTTOMRIGHT", 0, 0)
    
    -- Apply background color
    self.quickSearchFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
    
    -- Quick search label
    local quickSearchText = self.quickSearchFrame:CreateFontString(nil, "OVERLAY")
    quickSearchText:SetPoint("TOPLEFT", self.quickSearchFrame, "TOPLEFT", 15, -8)
    quickSearchText:SetText("Quick Search:")
    
    -- Apply font
    local fontPath = VUI:GetFont(VUI.db.profile.appearance.font)
    local fontSize = VUI.db.profile.appearance.fontSize - 1
    quickSearchText:SetFont(fontPath, fontSize, "")
    
    -- Create the quick search buttons
    local buttonWidth = 100
    local quickSearches = {
        { text = "M+ Dungeons", categoryID = 2, filters = 4, icon = "Interface\\AddOns\\VUI\\media\\icons\\premadegroupfinder\\mythicplus.svg" },
        { text = "Raid", categoryID = 2, filters = 2, icon = "Interface\\AddOns\\VUI\\media\\icons\\premadegroupfinder\\raid.svg" },
        { text = "Rated PvP", categoryID = 4, filters = 0, icon = "Interface\\AddOns\\VUI\\media\\icons\\premadegroupfinder\\pvp.svg" },
        { text = "Questing", categoryID = 1, filters = 0, icon = "Interface\\AddOns\\VUI\\media\\icons\\premadegroupfinder\\questing.svg" },
        { text = "Favorites", categoryID = nil, filters = nil, isFavorites = true, icon = "Interface\\AddOns\\VUI\\media\\icons\\premadegroupfinder\\favorites.svg" }
    }
    
    local prevButton
    for i, search in ipairs(quickSearches) do
        local button = self:CreateButton("VUIPGFQuickSearch"..i, self.quickSearchFrame, search.text, search.icon)
        button:SetSize(buttonWidth, 20)
        
        if i == 1 then
            button:SetPoint("LEFT", quickSearchText, "RIGHT", 15, 0)
        else
            button:SetPoint("LEFT", prevButton, "RIGHT", 10, 0)
        end
        
        button:SetScript("OnClick", function()
            if search.isFavorites then
                self:ShowFavorites()
            else
                self:QuickSearch(search.categoryID, search.filters)
            end
        end)
        
        prevButton = button
    end
    
    return self.quickSearchFrame
end

-- Hook search result button
function PGF:HookSearchResult(button)
    if button.VUIHooked then return end
    
    -- Create favorite button
    local favoriteButton = self:CreateButton("VUIPGFFavorite"..button:GetName(), button, "", "Interface\\AddOns\\VUI\\media\\icons\\premadegroupfinder\\favorite.svg")
    favoriteButton:SetSize(20, 20)
    favoriteButton:SetPoint("TOPRIGHT", button, "TOPRIGHT", -5, -5)
    favoriteButton:Hide() -- Initially hidden
    
    favoriteButton:SetScript("OnClick", function()
        local resultID = button.resultID
        if resultID then
            local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
            if searchResultInfo and searchResultInfo.activityID then
                self:ToggleFavoriteActivity(searchResultInfo.activityID)
            end
        end
    end)
    
    -- Create blacklist button
    local blacklistButton = self:CreateButton("VUIPGFBlacklist"..button:GetName(), button, "", "Interface\\AddOns\\VUI\\media\\icons\\premadegroupfinder\\blacklist.svg")
    blacklistButton:SetSize(20, 20)
    blacklistButton:SetPoint("TOPRIGHT", favoriteButton, "TOPLEFT", -2, 0)
    blacklistButton:Hide() -- Initially hidden
    
    blacklistButton:SetScript("OnClick", function()
        local resultID = button.resultID
        if resultID then
            local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
            if searchResultInfo and searchResultInfo.leaderName then
                self:BlacklistLeader(searchResultInfo.leaderName)
                self:ApplyFilters() -- Refresh the list filtering
            end
        end
    end)
    
    -- Store buttons on the result button
    button.VUIFavoriteButton = favoriteButton
    button.VUIBlacklistButton = blacklistButton
    
    -- Mark as hooked
    button.VUIHooked = true
end

-- Process search results
function PGF:ProcessSearchResults(panel)
    -- Skip if search results are empty
    local results = panel.results
    if not results or #results == 0 then return end
    
    -- Process each result
    for i, resultID in ipairs(results) do
        local info = C_LFGList.GetSearchResultInfo(resultID)
        if info then
            -- Store in our cache
            self.groupCache[resultID] = info
            
            -- Process the result
            self:ProcessResult(resultID, info)
        end
    end
    
    -- Apply filtering
    self:ApplyFilters()
end

-- Process individual result
function PGF:ProcessResult(resultID, info)
    -- Skip if already processed
    if info.VUIProcessed then return end
    
    -- Add our custom data
    info.isAd = self:IsAdvertisement(info)
    info.roleNeeded = self:GetNeededRoles(info)
    
    -- Mark as processed
    info.VUIProcessed = true
    
    -- Store back in cache
    self.groupCache[resultID] = info
end

-- Apply filters to search results
function PGF:ApplyFilters()
    local panel = LFGListFrame.SearchPanel
    if not panel or not panel.results then return end
    
    -- Get the scroll frame and buttons
    local scrollFrame = panel.ScrollFrame
    if not scrollFrame or not scrollFrame.buttons then return end
    
    -- Get visible buttons
    local buttons = scrollFrame.buttons
    local offset = HybridScrollFrame_GetOffset(scrollFrame)
    
    -- Process each visible button
    for i, button in ipairs(buttons) do
        local resultIdx = i + offset
        if resultIdx <= #panel.results then
            local resultID = panel.results[resultIdx]
            local info = self.groupCache[resultID]
            
            if info then
                -- Filter based on our criteria
                local show = self:ShouldShowResult(resultID, info)
                
                -- Hide or show the result
                if not show then
                    -- Mark the result frame as filtered
                    button.VUIFiltered = true
                    button:Hide()
                else
                    -- Enhance visible result
                    button.VUIFiltered = false
                    button:Show()
                    self:EnhanceResultButton(button, resultID, info)
                end
            end
        end
    end
    
    -- Update the scroll frame to adjust for hidden buttons
    self:UpdateScrollFrame(scrollFrame)
end

-- Check if result should be shown
function PGF:ShouldShowResult(resultID, info)
    -- Always show if filtering not enabled
    if not self.enabled then return true end
    
    -- Check item level
    if self.filters.minIlvl > 0 and info.requiredItemLevel < self.filters.minIlvl then
        return false
    end
    
    -- Check roles
    if (self.filters.roleRequired.tank and not info.roleNeeded.tank) or
       (self.filters.roleRequired.healer and not info.roleNeeded.healer) or
       (self.filters.roleRequired.dps and not info.roleNeeded.dps) then
        return false
    end
    
    -- Check voice chat
    if self.filters.voiceChat and not info.voiceChat then
        return false
    end
    
    -- Check blacklist
    if info.leaderName and self.blacklist[info.leaderName] then
        return false
    end
    
    -- Check for advertisements
    if self.settings.advanced.hideAds and info.isAd then
        return false
    end
    
    return true
end

-- Update scroll frame to account for hidden buttons
function PGF:UpdateScrollFrame(scrollFrame)
    local totalHeight = 0
    local visibleButtons = 0
    
    for i, button in ipairs(scrollFrame.buttons) do
        if not button.VUIFiltered then
            totalHeight = totalHeight + button:GetHeight()
            visibleButtons = visibleButtons + 1
        end
    end
    
    -- Update the scroll frame height
    local resultHeight = scrollFrame.buttons[1]:GetHeight()
    local displayedHeight = visibleButtons * resultHeight
    
    HybridScrollFrame_Update(scrollFrame, displayedHeight, scrollFrame:GetHeight())
end

-- Enhance result button
function PGF:EnhanceResultButton(button, resultID, info)
    -- Skip if not VUI hooked
    if not button.VUIHooked then return end
    
    -- Show our custom buttons if applicable
    if self.settings.advanced.markFavorites then
        button.VUIFavoriteButton:Show()
        
        -- Update favorite button status with proper coloring
        -- The icon is already set via the texture, no need to use text
        if info.activityID and self.favoriteActivities[info.activityID] then
            -- For favorite status, use gold highlight
            if button.VUIFavoriteButton.icon then
                button.VUIFavoriteButton.icon:SetVertexColor(1, 0.84, 0, 1) -- Bright gold
            end
        else
            -- For non-favorite status, use dimmed appearance
            if button.VUIFavoriteButton.icon then
                button.VUIFavoriteButton.icon:SetVertexColor(0.6, 0.6, 0.6, 0.7) -- Dimmed
            end
        end
    else
        button.VUIFavoriteButton:Hide()
    end
    
    -- Show blacklist button
    button.VUIBlacklistButton:Show()
    
    -- Enhance activity name
    if button.ActivityName and self.settings.appearance.showActivityName then
        local fontPath = VUI:GetFont(VUI.db.profile.appearance.font)
        local fontSize = VUI.db.profile.appearance.fontSize - 1
        button.ActivityName:SetFont(fontPath, fontSize, "")
        
        -- Color activity name for favorite activities
        if info.activityID and self.favoriteActivities[info.activityID] then
            button.ActivityName:SetText("|cFFFFD100" .. info.name .. "|r")
        end
    end
    
    -- Enhance leader name
    if button.LeaderName and info.leaderName and self.settings.appearance.coloredNames then
        local _, classFilename = C_LFGList.GetSearchResultLeaderInfo(resultID)
        if classFilename and CLASS_COLORS[classFilename] then
            button.LeaderName:SetText(CLASS_COLORS[classFilename] .. info.leaderName .. "|r")
        end
    end
    
    -- Add item level if available
    if self.settings.appearance.showItemLevel and button.ItemLevel and info.requiredItemLevel > 0 then
        button.ItemLevel:SetText("iLvl: " .. info.requiredItemLevel)
        button.ItemLevel:Show()
    end
    
    -- Add role indicators
    if self.settings.appearance.showRole and button.RoleCount then
        local roleText = ""
        if info.roleNeeded.tank then roleText = roleText .. ROLE_ICONS.TANK end
        if info.roleNeeded.healer then roleText = roleText .. ROLE_ICONS.HEALER end
        if info.roleNeeded.dps then roleText = roleText .. ROLE_ICONS.DAMAGER end
        
        button.RoleCount:SetText(roleText)
    end
    
    -- If we have compact mode enabled, adjust the height
    if self.settings.appearance.compactList then
        button:SetHeight(40) -- Smaller height for compact display
    else
        button:SetHeight(60) -- Default height
    end
end

-- Check if a listing is likely an advertisement
function PGF:IsAdvertisement(info)
    if not info.comment then return false end
    
    -- Convert to lowercase for case-insensitive matching
    local lowerComment = string.lower(info.comment)
    
    -- Check for ad keywords
    for _, keyword in ipairs(AD_KEYWORDS) do
        if lowerComment:find(keyword) then
            return true
        end
    end
    
    return false
end

-- Get needed roles from result info
function PGF:GetNeededRoles(info)
    local roles = {
        tank = false,
        healer = false,
        dps = false
    }
    
    -- Get available slots
    local numMembers = info.numMembers or 0
    local numTanks = info.numTanks or 0
    local numHealers = info.numHealers or 0
    local numDPS = info.numDPS or 0
    
    -- Check if full
    local maxMembers = 5 -- Default for 5-man
    if info.maxMembers and info.maxMembers > 0 then
        maxMembers = info.maxMembers
    end
    
    if numMembers >= maxMembers then
        return roles -- No roles needed, group is full
    end
    
    -- Determine needed roles based on content type
    local activityInfo = C_LFGList.GetActivityInfoTable(info.activityID)
    if activityInfo then
        -- Dungeon/raid logic
        if activityInfo.categoryID == 2 then
            -- Check tanks
            local maxTanks = (maxMembers <= 5) and 1 or 2 -- 1 for 5-man, 2 for raids
            roles.tank = numTanks < maxTanks
            
            -- Check healers
            local maxHealers = (maxMembers <= 5) and 1 or (maxMembers <= 10) and 2 or 5 -- 1 for 5-man, 2 for 10-man, 5 for 25-man
            roles.healer = numHealers < maxHealers
            
            -- Check DPS
            local maxDPS = maxMembers - maxTanks - maxHealers
            roles.dps = numDPS < maxDPS
        
        -- PvP logic  
        elseif activityInfo.categoryID == 4 then
            -- Most PvP groups don't strictly require roles, so all are potentially needed
            roles.tank = true
            roles.healer = true
            roles.dps = true
        
        -- General/questing logic
        else
            -- For general activities, any role is welcome
            roles.tank = true
            roles.healer = true
            roles.dps = true
        end
    else
        -- If activity info not available, consider all roles needed
        roles.tank = true
        roles.healer = true
        roles.dps = true
    end
    
    return roles
end

-- Hook button appearance
function PGF:HookButton(button, text, onClick)
    if not button then return end
    
    -- Save original appearance
    local origText = button:GetText()
    
    -- Apply our styling
    button:SetText(text or origText)
    
    -- Apply our UI theme
    local fontPath = VUI:GetFont(VUI.db.profile.appearance.font)
    local textObj = button:GetFontString()
    if textObj then
        textObj:SetFont(fontPath, 12, "")
    end
    
    -- Hook click handler
    if onClick then
        button:HookScript("OnClick", onClick)
    end
    
    return button
end

-- Reset filters
function PGF:ResetFilters()
    -- Reset filter UI
    if self.ilvlSlider then
        self.ilvlSlider:SetValue(0)
    end
    
    if self.tankCheckbox then
        self.tankCheckbox:SetChecked(false)
    end
    
    if self.healerCheckbox then
        self.healerCheckbox:SetChecked(false)
    end
    
    if self.dpsCheckbox then
        self.dpsCheckbox:SetChecked(false)
    end
    
    if self.voiceChatCheckbox then
        self.voiceChatCheckbox:SetChecked(false)
    end
    
    -- Reset filter state
    self.settings.filters.minimumItemLevel = 0
    self.settings.filters.tankOnly = false
    self.settings.filters.healerOnly = false
    self.settings.filters.dpsOnly = false
    self.settings.filters.voiceChat = false
    
    self.filters.minIlvl = 0
    self.filters.roleRequired.tank = false
    self.filters.roleRequired.healer = false
    self.filters.roleRequired.dps = false
    self.filters.voiceChat = false
    
    -- Apply updated filters
    self:ApplyFilters()
    
    VUI:Print("Premade Group Finder filters reset")
end

-- Toggle favorite activity
function PGF:ToggleFavoriteActivity(activityID)
    if not activityID then return end
    
    if self.favoriteActivities[activityID] then
        self.favoriteActivities[activityID] = nil
        VUI:Print("Removed activity from favorites")
    else
        self.favoriteActivities[activityID] = true
        VUI:Print("Added activity to favorites")
    end
    
    -- Save to settings
    self.settings.favoriteActivities = self.favoriteActivities
    
    -- Update UI
    self:ApplyFilters()
end

-- Blacklist a leader
function PGF:BlacklistLeader(leaderName)
    if not leaderName then return end
    
    self.blacklist[leaderName] = true
    self.settings.blacklist = self.blacklist
    
    VUI:Print("Blacklisted leader: " .. leaderName)
end

-- Quick search function
function PGF:QuickSearch(categoryID, filters)
    if not LFGListFrame or not LFGListFrame.CategorySelection then return end
    
    -- Select the category
    LFGListCategorySelection_SelectCategory(LFGListFrame.CategorySelection, categoryID, filters)
    
    -- Trigger search
    LFGListSearchPanel_DoSearch(LFGListFrame.SearchPanel)
    
    VUI:Print("Searching for activities...")
end

-- Show favorites
function PGF:ShowFavorites()
    if not LFGListFrame or not LFGListFrame.SearchPanel then return end
    
    -- First, do a general search if not already done
    if #LFGListFrame.SearchPanel.results == 0 then
        self:QuickSearch(2, 0) -- General search, all categories
    end
    
    -- Create a filter that only shows favorites
    self.showingFavorites = true
    
    -- Apply special favorites filter
    C_Timer.After(0.5, function()
        local panel = LFGListFrame.SearchPanel
        if not panel or not panel.results then return end
        
        -- Get the scroll frame and buttons
        local scrollFrame = panel.ScrollFrame
        if not scrollFrame or not scrollFrame.buttons then return end
        
        -- Filter results to only show favorites
        for i, resultID in ipairs(panel.results) do
            local info = self.groupCache[resultID]
            if info and info.activityID then
                -- Hide if not a favorite activity
                if not self.favoriteActivities[info.activityID] then
                    table.remove(panel.results, i)
                end
            end
        end
        
        -- Update display
        LFGListSearchPanel_UpdateResults(panel)
        
        VUI:Print("Showing favorite activities")
    end)
end

-- Enhance search entry tooltip
function PGF:EnhanceSearchEntryTooltip(tooltip, resultID)
    if not self.enabled or not self.settings.appearance.enhancedTooltip then return end
    
    local info = C_LFGList.GetSearchResultInfo(resultID)
    if not info then return end
    
    -- Get leader info
    local leaderName, classFilename = C_LFGList.GetSearchResultLeaderInfo(resultID)
    
    -- Add enhanced data
    tooltip:AddLine(" ")
    tooltip:AddLine("|cFFFFD100Enhanced Information:|r")
    
    -- Leader class
    if leaderName and classFilename then
        tooltip:AddLine("Leader: " .. (CLASS_COLORS[classFilename] or "") .. leaderName .. "|r")
    end
    
    -- Item level
    if info.requiredItemLevel > 0 then
        tooltip:AddLine("Required iLevel: |cFFFFFFFF" .. info.requiredItemLevel .. "|r")
    end
    
    -- Member composition
    tooltip:AddLine("Group Composition: |cFFFFFFFF" .. info.numMembers .. "/" .. (info.maxMembers or 0) .. "|r")
    
    local roleText = ""
    if info.numTanks and info.numTanks > 0 then 
        roleText = roleText .. ROLE_ICONS.TANK .. " " .. info.numTanks .. " "
    end
    
    if info.numHealers and info.numHealers > 0 then 
        roleText = roleText .. ROLE_ICONS.HEALER .. " " .. info.numHealers .. " "
    end
    
    if info.numDPS and info.numDPS > 0 then 
        roleText = roleText .. ROLE_ICONS.DAMAGER .. " " .. info.numDPS
    end
    
    tooltip:AddLine("Roles: " .. roleText)
    
    -- Voice chat
    if info.voiceChat then
        tooltip:AddLine("Voice Chat: |cFF00FF00Yes|r")
    else
        tooltip:AddLine("Voice Chat: |cFFFF0000No|r")
    end
    
    -- Creation time
    if info.elapsedTime then
        local minutes = math.floor(info.elapsedTime / 60)
        local timeText = minutes > 0 
            and minutes .. " minute" .. (minutes > 1 and "s" or "")
            or "Less than a minute"
        tooltip:AddLine("Created: |cFFFFFFFF" .. timeText .. " ago|r")
    end
    
    -- If it's a favorite, add indicator
    if info.activityID and self.favoriteActivities[info.activityID] then
        tooltip:AddLine("|cFFFFD100★ Favorite Activity ★|r")
    end
    
    -- If it's blacklisted, add indicator
    if leaderName and self.blacklist[leaderName] then
        tooltip:AddLine("|cFFFF0000⚠ Blacklisted Leader ⚠|r")
    end
    
    -- If it's an ad, add indicator
    if self:IsAdvertisement(info) then
        tooltip:AddLine("|cFFFF6600⚠ Possible Advertisement ⚠|r")
    end
    
    -- Add social info if available
    local activityInfo = C_LFGList.GetActivityInfoTable(info.activityID)
    if activityInfo and self.settings.advanced.showPlayerInfo then
        -- Add leader playing time if available
        -- This would require RaiderIO or other data sources
        if self.settings.advanced.showRaiderIO then
            -- Placeholder for Raider.IO integration
            -- Would show score/rating if available
        end
    end
    
    tooltip:Show() -- Refresh the tooltip
end

-- Enhance applicant listing
function PGF:EnhanceApplicantListing(member, appID, memberIdx)
    if not self.enabled then return end
    
    -- Get applicant info
    local name, class, localizedClass, level, itemLevel, tank, healer, damage, assignedRole = C_LFGList.GetApplicantMemberInfo(appID, memberIdx)
    
    if not name then return end
    
    -- Apply colored name if enabled
    if self.settings.appearance.coloredNames and member.Name and class and CLASS_COLORS[class] then
        member.Name:SetText(CLASS_COLORS[class] .. name .. "|r")
    end
    
    -- Add item level if enabled
    if self.settings.appearance.showItemLevel and member.ItemLevel and itemLevel > 0 then
        member.ItemLevel:SetText(itemLevel)
    end
end

-- Enhance activity selection
function PGF:EnhanceActivitySelection(panel, categoryID, filters)
    if not self.enabled then return end
    
    -- Mark favorite activities
    if panel.ScrollFrame and panel.ScrollFrame.buttons then
        for _, button in ipairs(panel.ScrollFrame.buttons) do
            if button.activityID and self.favoriteActivities[button.activityID] then
                -- Create or update favorite indicator
                if not button.favoriteIndicator then
                    button.favoriteIndicator = button:CreateFontString(nil, "OVERLAY")
                    button.favoriteIndicator:SetPoint("RIGHT", button, "RIGHT", -5, 0)
                    
                    local fontPath = VUI:GetFont(VUI.db.profile.appearance.font)
                    button.favoriteIndicator:SetFont(fontPath, 16, "")
                end
                
                button.favoriteIndicator:SetText("|cFFFFD100★|r")
                button.favoriteIndicator:Show()
            elseif button.favoriteIndicator then
                button.favoriteIndicator:Hide()
            end
        end
    end
end

-- Enhance entry creation
function PGF:EnhanceEntryCreation(panel)
    if not self.enabled then return end
    
    -- Apply our theme to elements
    if panel.Name and panel.Name.EditBox then
        local fontPath = VUI:GetFont(VUI.db.profile.appearance.font)
        panel.Name.EditBox:SetFont(fontPath, 12, "")
    end
    
    if panel.Description and panel.Description.EditBox then
        local fontPath = VUI:GetFont(VUI.db.profile.appearance.font)
        panel.Description.EditBox:SetFont(fontPath, 12, "")
    end
    
    -- Hook the create button
    if panel.ListGroupButton then
        self:HookButton(panel.ListGroupButton, "List Group", nil)
    end
end

-- Update UI
function PGF:UpdateUI()
    if not self.enabled or not LFGListFrame then return end
    
    -- Update filter UI
    if self.ilvlSlider then
        self.ilvlSlider:SetValue(self.settings.filters.minimumItemLevel)
    end
    
    if self.tankCheckbox then
        self.tankCheckbox:SetChecked(self.settings.filters.tankOnly)
    end
    
    if self.healerCheckbox then
        self.healerCheckbox:SetChecked(self.settings.filters.healerOnly)
    end
    
    if self.dpsCheckbox then
        self.dpsCheckbox:SetChecked(self.settings.filters.dpsOnly)
    end
    
    if self.voiceChatCheckbox then
        self.voiceChatCheckbox:SetChecked(self.settings.filters.voiceChat)
    end
    
    -- Apply filters
    self:ApplyFilters()
    
    -- Apply theme
    self:ApplyTheme()
end

-- Apply theme
function PGF:ApplyTheme()
    if not self.enabled then return end
    
    -- Get theme colors
    local theme = VUI.db.profile.appearance.theme or "thunderstorm"
    local themeData = VUI.media.themes[theme]
    
    if not themeData then return end
    
    -- Apply to our frames
    if self.dragHeader then
        self.dragHeader:SetBackdropColor(
            themeData.colors.header.r,
            themeData.colors.header.g,
            themeData.colors.header.b,
            themeData.colors.header.a
        )
        
        self.dragHeader:SetBackdropBorderColor(
            themeData.colors.border.r,
            themeData.colors.border.g,
            themeData.colors.border.b,
            themeData.colors.border.a
        )
    end
    
    if self.filterFrame then
        self.filterFrame:SetBackdropColor(
            themeData.colors.backdrop.r,
            themeData.colors.backdrop.g,
            themeData.colors.backdrop.b,
            themeData.colors.backdrop.a
        )
        
        self.filterFrame:SetBackdropBorderColor(
            themeData.colors.border.r,
            themeData.colors.border.g,
            themeData.colors.border.b,
            themeData.colors.border.a
        )
    end
    
    if self.quickSearchFrame then
        self.quickSearchFrame:SetBackdropColor(
            themeData.colors.backdrop.r,
            themeData.colors.backdrop.g,
            themeData.colors.backdrop.b,
            themeData.colors.backdrop.a
        )
        
        self.quickSearchFrame:SetBackdropBorderColor(
            themeData.colors.border.r,
            themeData.colors.border.g,
            themeData.colors.border.b,
            themeData.colors.border.a
        )
    end
    
    -- Update buttons
    self:UpdateButtonStyles()
end

-- Update button styles
function PGF:UpdateButtonStyles()
    -- Helper functions for button styling
    local function ApplyButtonStyle(button)
        if not button then return end
        
        -- Get theme colors
        local theme = VUI.db.profile.appearance.theme or "thunderstorm"
        local themeData = VUI.media.themes[theme]
        
        if not themeData then return end
        
        -- Apply theme to button
        button:SetBackdropColor(
            themeData.colors.button.r,
            themeData.colors.button.g,
            themeData.colors.button.b,
            themeData.colors.button.a
        )
        
        button:SetBackdropBorderColor(
            themeData.colors.border.r,
            themeData.colors.border.g,
            themeData.colors.border.b,
            themeData.colors.border.a
        )
    end
    
    -- Apply to our buttons
    if self.settingsButton then
        ApplyButtonStyle(self.settingsButton)
    end
    
    if self.refreshButton then
        ApplyButtonStyle(self.refreshButton)
    end
    
    if self.resetFiltersButton then
        ApplyButtonStyle(self.resetFiltersButton)
    end
    
    -- Apply to quick search buttons
    if self.quickSearchFrame then
        for i=1, 5 do
            local button = _G["VUIPGFQuickSearch"..i]
            if button then
                ApplyButtonStyle(button)
            end
        end
    end
end

-- Event Handlers

-- Search results received
function PGF:OnSearchResultsReceived()
    -- Process results after a short delay to ensure all data is loaded
    C_Timer.After(0.5, function()
        if LFGListFrame and LFGListFrame.SearchPanel then
            self:ProcessSearchResults(LFGListFrame.SearchPanel)
        end
    end)
end

-- Availability update
function PGF:OnAvailabilityUpdate()
    -- Update filters if search panel is showing
    if LFGListFrame and LFGListFrame.SearchPanel and LFGListFrame.SearchPanel:IsVisible() then
        self:ApplyFilters()
    end
end

-- Applicant list updated
function PGF:OnApplicantListUpdated()
    -- Apply enhancements to applicant list
    if LFGListFrame and LFGListFrame.ApplicationViewer then
        -- Refresh view to apply our customizations
        LFGListApplicationViewer_UpdateApplicantButtons(LFGListFrame.ApplicationViewer)
    end
end

-- Active entry update
function PGF:OnActiveEntryUpdate()
    -- Update UI if we have an active group
    if LFGListFrame and LFGListFrame.ApplicationViewer and LFGListFrame.ApplicationViewer:IsVisible() then
        self:UpdateUI()
    end
end

-- Entry creation failed
function PGF:OnEntryCreationFailed()
    -- Show nicer error message
    VUI:Print("|cFFFF0000Group creation failed. Please check your settings and try again.|r")
end