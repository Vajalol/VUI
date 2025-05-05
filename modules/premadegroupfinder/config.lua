-- VUI Premade Group Finder Module - Configuration Panel
local _, VUI = ...
local PGF = VUI.premadegroupfinder
local AceGUI = LibStub("AceGUI-3.0")

-- Function to create a standalone configuration panel
function PGF:CreateConfigPanel()
    -- Create a frame
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("VUI Premade Group Finder Configuration")
    frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    frame:SetLayout("Flow")
    frame:SetWidth(575)
    frame:SetHeight(550)
    
    -- Create tabs
    local tabs = AceGUI:Create("TabGroup")
    tabs:SetLayout("Flow")
    tabs:SetTabs({
        {text = "General", value = "general"},
        {text = "Appearance", value = "appearance"},
        {text = "Filters", value = "filters"},
        {text = "Advanced", value = "advanced"},
        {text = "Favorites", value = "favorites"}
    })
    tabs:SetCallback("OnGroupSelected", function(container, event, group)
        container:ReleaseChildren()
        if group == "general" then
            self:CreateGeneralTab(container)
        elseif group == "appearance" then
            self:CreateAppearanceTab(container)
        elseif group == "filters" then
            self:CreateFiltersTab(container)
        elseif group == "advanced" then
            self:CreateAdvancedTab(container)
        elseif group == "favorites" then
            self:CreateFavoritesTab(container)
        end
    end)
    tabs:SelectTab("general")
    
    frame:AddChild(tabs)
    
    return frame
end

-- Create the General tab
function PGF:CreateGeneralTab(container)
    -- Enable/disable toggle
    local enableCheckbox = AceGUI:Create("CheckBox")
    enableCheckbox:SetLabel("Enable Premade Group Finder Enhancements")
    enableCheckbox:SetWidth(350)
    enableCheckbox:SetValue(VUI:IsModuleEnabled("premadegroupfinder"))
    enableCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        if value then
            VUI:EnableModule("premadegroupfinder")
        else
            VUI:DisableModule("premadegroupfinder")
        end
    end)
    container:AddChild(enableCheckbox)
    
    -- Description text
    local desc = AceGUI:Create("Label")
    desc:SetText("The Premade Group Finder module enhances the default LFG interface with additional features, filters, and visual improvements.")
    desc:SetFullWidth(true)
    container:AddChild(desc)
    
    -- Spacer
    container:AddChild(AceGUI:Create("Label"):SetText(" "):SetFullWidth(true))
    
    -- Position/Scale section
    local positionGroup = AceGUI:Create("InlineGroup")
    positionGroup:SetTitle("Position and Scale")
    positionGroup:SetLayout("Flow")
    positionGroup:SetFullWidth(true)
    container:AddChild(positionGroup)
    
    -- Scale slider
    local scaleSlider = AceGUI:Create("Slider")
    scaleSlider:SetLabel("UI Scale")
    scaleSlider:SetWidth(300)
    scaleSlider:SetSliderValues(0.5, 2.0, 0.05)
    scaleSlider:SetValue(self.settings.scale)
    scaleSlider:SetCallback("OnValueChanged", function(widget, event, value)
        self.settings.scale = value
        self:UpdateScale()
    end)
    positionGroup:AddChild(scaleSlider)
    
    -- Reset position button
    local resetPosButton = AceGUI:Create("Button")
    resetPosButton:SetText("Reset Position")
    resetPosButton:SetWidth(150)
    resetPosButton:SetCallback("OnClick", function()
        self:ResetPosition()
    end)
    positionGroup:AddChild(resetPosButton)
    
    -- Spacer
    container:AddChild(AceGUI:Create("Label"):SetText(" "):SetFullWidth(true))
    
    -- Quick commands section
    local commandsGroup = AceGUI:Create("InlineGroup")
    commandsGroup:SetTitle("Quick Commands")
    commandsGroup:SetLayout("Flow")
    commandsGroup:SetFullWidth(true)
    container:AddChild(commandsGroup)
    
    -- Description
    local commandsDesc = AceGUI:Create("Label")
    commandsDesc:SetText("The following slash commands are available:")
    commandsDesc:SetFullWidth(true)
    commandsGroup:AddChild(commandsDesc)
    
    -- Commands list
    local commands = {
        "/vuipgf toggle - Toggle enhanced UI",
        "/vuipgf reset - Reset position",
        "/vuipgf config - Open configuration",
        "/vuipgf refresh - Refresh group list"
    }
    
    for _, command in ipairs(commands) do
        local commandText = AceGUI:Create("Label")
        commandText:SetText(command)
        commandText:SetFullWidth(true)
        commandsGroup:AddChild(commandText)
    end
    
    -- Spacer
    container:AddChild(AceGUI:Create("Label"):SetText(" "):SetFullWidth(true))
    
    -- Version info
    local versionText = AceGUI:Create("Label")
    versionText:SetText("Version: " .. (VUI.version or "1.0.0"))
    versionText:SetFullWidth(true)
    container:AddChild(versionText)
end

-- Create the Appearance tab
function PGF:CreateAppearanceTab(container)
    -- Enhanced tooltip option
    local enhancedTooltipCheckbox = AceGUI:Create("CheckBox")
    enhancedTooltipCheckbox:SetLabel("Enhanced Tooltips")
    enhancedTooltipCheckbox:SetWidth(200)
    enhancedTooltipCheckbox:SetValue(self.settings.appearance.enhancedTooltip)
    enhancedTooltipCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        self.settings.appearance.enhancedTooltip = value
        self:UpdateUI()
    end)
    container:AddChild(enhancedTooltipCheckbox)
    
    -- Colored names option
    local coloredNamesCheckbox = AceGUI:Create("CheckBox")
    coloredNamesCheckbox:SetLabel("Colored Player Names")
    coloredNamesCheckbox:SetWidth(200)
    coloredNamesCheckbox:SetValue(self.settings.appearance.coloredNames)
    coloredNamesCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        self.settings.appearance.coloredNames = value
        self:UpdateUI()
    end)
    container:AddChild(coloredNamesCheckbox)
    
    -- Compact list option
    local compactListCheckbox = AceGUI:Create("CheckBox")
    compactListCheckbox:SetLabel("Compact List")
    compactListCheckbox:SetWidth(200)
    compactListCheckbox:SetValue(self.settings.appearance.compactList)
    compactListCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        self.settings.appearance.compactList = value
        self:UpdateUI()
    end)
    container:AddChild(compactListCheckbox)
    
    -- Description for compact list
    local compactDesc = AceGUI:Create("Label")
    compactDesc:SetText("Compact list shows more groups at once by reducing the height of each entry.")
    compactDesc:SetFullWidth(true)
    container:AddChild(compactDesc)
    
    -- Spacer
    container:AddChild(AceGUI:Create("Label"):SetText(" "):SetFullWidth(true))
    
    -- Information display section
    local displayGroup = AceGUI:Create("InlineGroup")
    displayGroup:SetTitle("Information Display")
    displayGroup:SetLayout("Flow")
    displayGroup:SetFullWidth(true)
    container:AddChild(displayGroup)
    
    -- Show leader score option
    local leaderScoreCheckbox = AceGUI:Create("CheckBox")
    leaderScoreCheckbox:SetLabel("Show Leader Score")
    leaderScoreCheckbox:SetWidth(200)
    leaderScoreCheckbox:SetValue(self.settings.appearance.showLeaderScore)
    leaderScoreCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        self.settings.appearance.showLeaderScore = value
        self:UpdateUI()
    end)
    displayGroup:AddChild(leaderScoreCheckbox)
    
    -- Show role option
    local showRoleCheckbox = AceGUI:Create("CheckBox")
    showRoleCheckbox:SetLabel("Show Group Roles")
    showRoleCheckbox:SetWidth(200)
    showRoleCheckbox:SetValue(self.settings.appearance.showRole)
    showRoleCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        self.settings.appearance.showRole = value
        self:UpdateUI()
    end)
    displayGroup:AddChild(showRoleCheckbox)
    
    -- Show item level option
    local showItemLevelCheckbox = AceGUI:Create("CheckBox")
    showItemLevelCheckbox:SetLabel("Show Item Level")
    showItemLevelCheckbox:SetWidth(200)
    showItemLevelCheckbox:SetValue(self.settings.appearance.showItemLevel)
    showItemLevelCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        self.settings.appearance.showItemLevel = value
        self:UpdateUI()
    end)
    displayGroup:AddChild(showItemLevelCheckbox)
    
    -- Show activity name option
    local showActivityNameCheckbox = AceGUI:Create("CheckBox")
    showActivityNameCheckbox:SetLabel("Show Activity Name")
    showActivityNameCheckbox:SetWidth(200)
    showActivityNameCheckbox:SetValue(self.settings.appearance.showActivityName)
    showActivityNameCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        self.settings.appearance.showActivityName = value
        self:UpdateUI()
    end)
    displayGroup:AddChild(showActivityNameCheckbox)
    
    -- Spacer
    container:AddChild(AceGUI:Create("Label"):SetText(" "):SetFullWidth(true))
    
    -- Theme integration section
    local themeGroup = AceGUI:Create("InlineGroup")
    themeGroup:SetTitle("Theme Integration")
    themeGroup:SetLayout("Flow")
    themeGroup:SetFullWidth(true)
    container:AddChild(themeGroup)
    
    -- Theme description
    local themeDesc = AceGUI:Create("Label")
    themeDesc:SetText("The Premade Group Finder will automatically use the VUI theme selected in the general settings.")
    themeDesc:SetFullWidth(true)
    themeGroup:AddChild(themeDesc)
    
    -- Apply theme button
    local applyThemeButton = AceGUI:Create("Button")
    applyThemeButton:SetText("Apply Current Theme")
    applyThemeButton:SetWidth(150)
    applyThemeButton:SetCallback("OnClick", function()
        self:ApplyTheme()
        VUI:Print("Applied current theme to Premade Group Finder")
    end)
    themeGroup:AddChild(applyThemeButton)
end

-- Create the Filters tab
function PGF:CreateFiltersTab(container)
    -- Filter behavior section
    local behaviorGroup = AceGUI:Create("InlineGroup")
    behaviorGroup:SetTitle("Filter Behavior")
    behaviorGroup:SetLayout("Flow")
    behaviorGroup:SetFullWidth(true)
    container:AddChild(behaviorGroup)
    
    -- Auto clear option
    local autoClearCheckbox = AceGUI:Create("CheckBox")
    autoClearCheckbox:SetLabel("Auto Clear")
    autoClearCheckbox:SetWidth(200)
    autoClearCheckbox:SetValue(self.settings.filters.autoClear)
    autoClearCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        self.settings.filters.autoClear = value
    end)
    behaviorGroup:AddChild(autoClearCheckbox)
    
    -- Auto clear description
    local autoClearDesc = AceGUI:Create("Label")
    autoClearDesc:SetText("Automatically clear filters when closing and reopening the finder")
    autoClearDesc:SetFullWidth(true)
    behaviorGroup:AddChild(autoClearDesc)
    
    -- Auto refresh option
    local autoRefreshCheckbox = AceGUI:Create("CheckBox")
    autoRefreshCheckbox:SetLabel("Auto Refresh")
    autoRefreshCheckbox:SetWidth(200)
    autoRefreshCheckbox:SetValue(self.settings.filters.autoRefresh)
    autoRefreshCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        self.settings.filters.autoRefresh = value
        self:SetupAutoRefresh()
    end)
    behaviorGroup:AddChild(autoRefreshCheckbox)
    
    -- Refresh interval slider
    local refreshIntervalSlider = AceGUI:Create("Slider")
    refreshIntervalSlider:SetLabel("Refresh Interval (seconds)")
    refreshIntervalSlider:SetWidth(350)
    refreshIntervalSlider:SetSliderValues(10, 300, 5)
    refreshIntervalSlider:SetValue(self.settings.filters.refreshInterval)
    refreshIntervalSlider:SetCallback("OnValueChanged", function(widget, event, value)
        self.settings.filters.refreshInterval = value
        self:SetupAutoRefresh()
    end)
    behaviorGroup:AddChild(refreshIntervalSlider)
    
    -- Spacer
    container:AddChild(AceGUI:Create("Label"):SetText(" "):SetFullWidth(true))
    
    -- Filter criteria section
    local criteriaGroup = AceGUI:Create("InlineGroup")
    criteriaGroup:SetTitle("Filter Criteria")
    criteriaGroup:SetLayout("Flow")
    criteriaGroup:SetFullWidth(true)
    container:AddChild(criteriaGroup)
    
    -- Minimum item level slider
    local minIlvlSlider = AceGUI:Create("Slider")
    minIlvlSlider:SetLabel("Minimum Item Level")
    minIlvlSlider:SetWidth(350)
    minIlvlSlider:SetSliderValues(0, 500, 5)
    minIlvlSlider:SetValue(self.settings.filters.minimumItemLevel)
    minIlvlSlider:SetCallback("OnValueChanged", function(widget, event, value)
        self.settings.filters.minimumItemLevel = value
        self.filters.minIlvl = value
        self:UpdateFilters()
    end)
    criteriaGroup:AddChild(minIlvlSlider)
    
    -- Role filters heading
    local rolesHeading = AceGUI:Create("Heading")
    rolesHeading:SetText("Role Filters")
    rolesHeading:SetFullWidth(true)
    criteriaGroup:AddChild(rolesHeading)
    
    -- Description for role filters
    local rolesDesc = AceGUI:Create("Label")
    rolesDesc:SetText("Only show groups looking for specific roles:")
    rolesDesc:SetFullWidth(true)
    criteriaGroup:AddChild(rolesDesc)
    
    -- Tank only option
    local tankOnlyCheckbox = AceGUI:Create("CheckBox")
    tankOnlyCheckbox:SetLabel("Tank Only")
    tankOnlyCheckbox:SetWidth(150)
    tankOnlyCheckbox:SetValue(self.settings.filters.tankOnly)
    tankOnlyCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        self.settings.filters.tankOnly = value
        self.filters.roleRequired.tank = value
        self:UpdateFilters()
    end)
    criteriaGroup:AddChild(tankOnlyCheckbox)
    
    -- Healer only option
    local healerOnlyCheckbox = AceGUI:Create("CheckBox")
    healerOnlyCheckbox:SetLabel("Healer Only")
    healerOnlyCheckbox:SetWidth(150)
    healerOnlyCheckbox:SetValue(self.settings.filters.healerOnly)
    healerOnlyCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        self.settings.filters.healerOnly = value
        self.filters.roleRequired.healer = value
        self:UpdateFilters()
    end)
    criteriaGroup:AddChild(healerOnlyCheckbox)
    
    -- DPS only option
    local dpsOnlyCheckbox = AceGUI:Create("CheckBox")
    dpsOnlyCheckbox:SetLabel("DPS Only")
    dpsOnlyCheckbox:SetWidth(150)
    dpsOnlyCheckbox:SetValue(self.settings.filters.dpsOnly)
    dpsOnlyCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        self.settings.filters.dpsOnly = value
        self.filters.roleRequired.dps = value
        self:UpdateFilters()
    end)
    criteriaGroup:AddChild(dpsOnlyCheckbox)
    
    -- Voice chat option
    local voiceChatCheckbox = AceGUI:Create("CheckBox")
    voiceChatCheckbox:SetLabel("Voice Chat Only")
    voiceChatCheckbox:SetWidth(150)
    voiceChatCheckbox:SetValue(self.settings.filters.voiceChat)
    voiceChatCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        self.settings.filters.voiceChat = value
        self.filters.voiceChat = value
        self:UpdateFilters()
    end)
    criteriaGroup:AddChild(voiceChatCheckbox)
    
    -- Spacer
    container:AddChild(AceGUI:Create("Label"):SetText(" "):SetFullWidth(true))
    
    -- Reset filters button
    local resetFiltersButton = AceGUI:Create("Button")
    resetFiltersButton:SetText("Reset All Filters")
    resetFiltersButton:SetWidth(150)
    resetFiltersButton:SetCallback("OnClick", function()
        self:ResetFilters()
        
        -- Update the UI to reflect reset values
        minIlvlSlider:SetValue(0)
        tankOnlyCheckbox:SetValue(false)
        healerOnlyCheckbox:SetValue(false)
        dpsOnlyCheckbox:SetValue(false)
        voiceChatCheckbox:SetValue(false)
        
        VUI:Print("All filters have been reset")
    end)
    container:AddChild(resetFiltersButton)
end

-- Create the Advanced tab
function PGF:CreateAdvancedTab(container)
    -- Advanced options section
    local advancedGroup = AceGUI:Create("InlineGroup")
    advancedGroup:SetTitle("Advanced Options")
    advancedGroup:SetLayout("Flow")
    advancedGroup:SetFullWidth(true)
    container:AddChild(advancedGroup)
    
    -- Auto apply option
    local autoApplyCheckbox = AceGUI:Create("CheckBox")
    autoApplyCheckbox:SetLabel("Auto Apply Filters")
    autoApplyCheckbox:SetWidth(200)
    autoApplyCheckbox:SetValue(self.settings.advanced.autoApply)
    autoApplyCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        self.settings.advanced.autoApply = value
    end)
    advancedGroup:AddChild(autoApplyCheckbox)
    
    -- Auto apply description
    local autoApplyDesc = AceGUI:Create("Label")
    autoApplyDesc:SetText("Automatically apply saved filters when opening the finder")
    autoApplyDesc:SetFullWidth(true)
    advancedGroup:AddChild(autoApplyDesc)
    
    -- Hide advertisements option
    local hideAdsCheckbox = AceGUI:Create("CheckBox")
    hideAdsCheckbox:SetLabel("Hide Advertisements")
    hideAdsCheckbox:SetWidth(200)
    hideAdsCheckbox:SetValue(self.settings.advanced.hideAds)
    hideAdsCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        self.settings.advanced.hideAds = value
        self:UpdateFilters()
    end)
    advancedGroup:AddChild(hideAdsCheckbox)
    
    -- Hide ads description
    local hideAdsDesc = AceGUI:Create("Label")
    hideAdsDesc:SetText("Hide groups that appear to be advertisements (groups with keywords like 'WTS', 'boost', etc.)")
    hideAdsDesc:SetFullWidth(true)
    advancedGroup:AddChild(hideAdsDesc)
    
    -- Show raider.io option
    local showRaiderIOCheckbox = AceGUI:Create("CheckBox")
    showRaiderIOCheckbox:SetLabel("Show Raider.IO")
    showRaiderIOCheckbox:SetWidth(200)
    showRaiderIOCheckbox:SetValue(self.settings.advanced.showRaiderIO)
    showRaiderIOCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        self.settings.advanced.showRaiderIO = value
        self:UpdateFilters()
    end)
    advancedGroup:AddChild(showRaiderIOCheckbox)
    
    -- Show player info option
    local showPlayerInfoCheckbox = AceGUI:Create("CheckBox")
    showPlayerInfoCheckbox:SetLabel("Show Player Info")
    showPlayerInfoCheckbox:SetWidth(200)
    showPlayerInfoCheckbox:SetValue(self.settings.advanced.showPlayerInfo)
    showPlayerInfoCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        self.settings.advanced.showPlayerInfo = value
    end)
    advancedGroup:AddChild(showPlayerInfoCheckbox)
    
    -- Mark favorites option
    local markFavoritesCheckbox = AceGUI:Create("CheckBox")
    markFavoritesCheckbox:SetLabel("Mark Favorites")
    markFavoritesCheckbox:SetWidth(200)
    markFavoritesCheckbox:SetValue(self.settings.advanced.markFavorites)
    markFavoritesCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        self.settings.advanced.markFavorites = value
        self:UpdateUI()
    end)
    advancedGroup:AddChild(markFavoritesCheckbox)
    
    -- Spacer
    container:AddChild(AceGUI:Create("Label"):SetText(" "):SetFullWidth(true))
    
    -- Blacklist section
    local blacklistGroup = AceGUI:Create("InlineGroup")
    blacklistGroup:SetTitle("Blacklist Management")
    blacklistGroup:SetLayout("Flow")
    blacklistGroup:SetFullWidth(true)
    container:AddChild(blacklistGroup)
    
    -- Blacklist description
    local blacklistDesc = AceGUI:Create("Label")
    blacklistDesc:SetText("The blacklist allows you to hide groups created by specific players. To add players to the blacklist, hover over a group in the finder and click the X button.")
    blacklistDesc:SetFullWidth(true)
    blacklistGroup:AddChild(blacklistDesc)
    
    -- Count blacklisted players
    local blacklistCount = 0
    for _ in pairs(self.settings.blacklist) do
        blacklistCount = blacklistCount + 1
    end
    
    -- Display count
    local blacklistCountText = AceGUI:Create("Label")
    blacklistCountText:SetText("Currently blacklisted players: " .. blacklistCount)
    blacklistCountText:SetFullWidth(true)
    blacklistGroup:AddChild(blacklistCountText)
    
    -- Clear blacklist button
    local clearBlacklistButton = AceGUI:Create("Button")
    clearBlacklistButton:SetText("Clear Blacklist")
    clearBlacklistButton:SetWidth(150)
    clearBlacklistButton:SetCallback("OnClick", function()
        self.settings.blacklist = {}
        self.blacklist = {}
        self:UpdateFilters()
        blacklistCountText:SetText("Currently blacklisted players: 0")
        VUI:Print("Blacklist has been cleared")
    end)
    blacklistGroup:AddChild(clearBlacklistButton)
end

-- Create the Favorites tab
function PGF:CreateFavoritesTab(container)
    -- Favorites description
    local favDesc = AceGUI:Create("Label")
    favDesc:SetText("Favorite activities appear highlighted in the Premade Group Finder and can be quickly filtered using the 'Favorites' quick search button.")
    favDesc:SetFullWidth(true)
    container:AddChild(favDesc)
    
    -- Instructions
    local instructions = AceGUI:Create("Label")
    instructions:SetText("To add an activity to favorites, hover over a group in the finder and click the star button.")
    instructions:SetFullWidth(true)
    container:AddChild(instructions)
    
    -- Spacer
    container:AddChild(AceGUI:Create("Label"):SetText(" "):SetFullWidth(true))
    
    -- Favorites management section
    local favManageGroup = AceGUI:Create("InlineGroup")
    favManageGroup:SetTitle("Favorites Management")
    favManageGroup:SetLayout("Flow")
    favManageGroup:SetFullWidth(true)
    container:AddChild(favManageGroup)
    
    -- Count favorite activities
    local favoritesCount = 0
    for _ in pairs(self.settings.favoriteActivities) do
        favoritesCount = favoritesCount + 1
    end
    
    -- Display count
    local favoritesCountText = AceGUI:Create("Label")
    favoritesCountText:SetText("Favorite activities: " .. favoritesCount)
    favoritesCountText:SetFullWidth(true)
    favManageGroup:AddChild(favoritesCountText)
    
    -- Clear favorites button
    local clearFavoritesButton = AceGUI:Create("Button")
    clearFavoritesButton:SetText("Clear All Favorites")
    clearFavoritesButton:SetWidth(150)
    clearFavoritesButton:SetCallback("OnClick", function()
        self.settings.favoriteActivities = {}
        self.favoriteActivities = {}
        self:UpdateUI()
        favoritesCountText:SetText("Favorite activities: 0")
        VUI:Print("All favorites have been cleared")
    end)
    favManageGroup:AddChild(clearFavoritesButton)
    
    -- Spacer
    container:AddChild(AceGUI:Create("Label"):SetText(" "):SetFullWidth(true))
    
    -- Quick search section
    local quickSearchGroup = AceGUI:Create("InlineGroup")
    quickSearchGroup:SetTitle("Quick Search")
    quickSearchGroup:SetLayout("Flow")
    quickSearchGroup:SetFullWidth(true)
    container:AddChild(quickSearchGroup)
    
    -- Quick search description
    local quickSearchDesc = AceGUI:Create("Label")
    quickSearchDesc:SetText("The following buttons allow you to quickly search for specific types of activities:")
    quickSearchDesc:SetFullWidth(true)
    quickSearchGroup:AddChild(quickSearchDesc)
    
    -- Quick search buttons
    local buttonWidth = 120
    local quickSearches = {
        { text = "M+ Dungeons", categoryID = 2, filters = 4 },
        { text = "Raid", categoryID = 2, filters = 2 },
        { text = "Rated PvP", categoryID = 4, filters = 0 },
        { text = "Questing", categoryID = 1, filters = 0 },
        { text = "Favorites", categoryID = nil, filters = nil, isFavorites = true }
    }
    
    for i, search in ipairs(quickSearches) do
        local button = AceGUI:Create("Button")
        button:SetText(search.text)
        button:SetWidth(buttonWidth)
        button:SetCallback("OnClick", function()
            if search.isFavorites then
                self:ShowFavorites()
                VUI:Print("Showing favorite activities")
            else
                self:QuickSearch(search.categoryID, search.filters)
                VUI:Print("Searching for " .. search.text)
            end
        end)
        quickSearchGroup:AddChild(button)
    end
end

-- Register our config panel with the module API
VUI.ModuleAPI:AddModuleConfigPanel("premadegroupfinder", function() 
    return PGF:CreateConfigPanel() 
end)