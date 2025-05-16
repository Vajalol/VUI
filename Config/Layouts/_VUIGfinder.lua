--[[
    VUI Group Finder Module Configuration
    Enhanced group finder tool
]]

local Layout = VUI:NewModule('Config.Layout.VUIGfinder')

-- Initialize with the standard layout helper
VUI.ConfigHelpers.CreateStandardLayout(Layout, "VUIGfinder", "VUI Group Finder", "vmodules.vuigfinder")

-- Define module-specific layout construction
function Layout:BuildModuleLayout(module, db)
    -- Extend the base layout with module-specific settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Group Finder Settings'
        },
    })
    
    -- Add basic settings
    table.insert(Layout.layout.rows, {
        enableModule = {
            key = 'vmodules.vuigfinder.enableModule',
            type = 'checkbox',
            label = 'Enable Group Finder',
            tooltip = 'Enable VUI enhanced group finder',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.general.enableModule = self:GetValue()
                    if module.UpdateSettings then
                        module:UpdateSettings()
                    end
                end
            end
        },
        enhanceBlizzardUI = {
            key = 'vmodules.vuigfinder.enhanceBlizzardUI',
            type = 'checkbox',
            label = 'Enhance Blizzard UI',
            tooltip = 'Add enhancements to Blizzard\'s group finder UI',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.general.enhanceBlizzardUI = self:GetValue()
                    if module.UpdateBlizzardEnhancements then
                        module:UpdateBlizzardEnhancements()
                    end
                end
            end
        },
        enableKeywords = {
            key = 'vmodules.vuigfinder.enableKeywords',
            type = 'checkbox',
            label = 'Enable Keyword Filtering',
            tooltip = 'Enable automatic filtering by keywords',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.filter.enableKeywords = self:GetValue()
                end
            end
        },
    })
    
    -- Additional general settings
    table.insert(Layout.layout.rows, {
        automaticRefresh = {
            key = 'vmodules.vuigfinder.automaticRefresh',
            type = 'checkbox',
            label = 'Automatic Refresh',
            tooltip = 'Automatically refresh group listings',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.general.automaticRefresh = self:GetValue()
                    if module.UpdateRefreshSettings then
                        module:UpdateRefreshSettings()
                    end
                end
            end
        },
        refreshInterval = {
            key = 'vmodules.vuigfinder.refreshInterval',
            type = 'slider',
            label = 'Refresh Interval',
            tooltip = 'How often to refresh group listings (seconds)',
            min = 5,
            max = 60,
            step = 5,
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.general.refreshInterval = self:GetValue()
                    if module.UpdateRefreshSettings then
                        module:UpdateRefreshSettings()
                    end
                end
            end
        },
        persistentFilters = {
            key = 'vmodules.vuigfinder.persistentFilters',
            type = 'checkbox',
            label = 'Persistent Filters',
            tooltip = 'Remember your filters between sessions',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.general.persistentFilters = self:GetValue()
                end
            end
        },
    })
    
    -- Filter settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Filter Settings'
        },
    })
    
    table.insert(Layout.layout.rows, {
        minItemLevel = {
            key = 'vmodules.vuigfinder.minItemLevel',
            type = 'slider',
            label = 'Minimum Item Level',
            tooltip = 'Minimum item level for group filtering',
            min = 0,
            max = 500,
            step = 5,
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.filter.minItemLevel = self:GetValue()
                end
            end
        },
        maxItemLevel = {
            key = 'vmodules.vuigfinder.maxItemLevel',
            type = 'slider',
            label = 'Maximum Item Level',
            tooltip = 'Maximum item level for group filtering',
            min = 0,
            max = 500,
            step = 5,
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.filter.maxItemLevel = self:GetValue()
                end
            end
        },
        preferVoiceChat = {
            key = 'vmodules.vuigfinder.preferVoiceChat',
            type = 'checkbox',
            label = 'Prefer Voice Chat',
            tooltip = 'Prioritize groups with voice chat',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.filter.preferVoiceChat = self:GetValue()
                end
            end
        },
    })
    
    -- Advanced filtering
    table.insert(Layout.layout.rows, {
        minGroupMembers = {
            key = 'vmodules.vuigfinder.minGroupMembers',
            type = 'slider',
            label = 'Min Group Members',
            tooltip = 'Minimum number of group members',
            min = 1,
            max = 5,
            step = 1,
            column = 3,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.filter.minGroupMembers = self:GetValue()
                end
            end
        },
        maxGroupMembers = {
            key = 'vmodules.vuigfinder.maxGroupMembers',
            type = 'slider',
            label = 'Max Group Members',
            tooltip = 'Maximum number of group members',
            min = 1,
            max = 5,
            step = 1,
            column = 3,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.filter.maxGroupMembers = self:GetValue()
                end
            end
        },
        minLeaderRaiderIO = {
            key = 'vmodules.vuigfinder.minLeaderRaiderIO',
            type = 'slider',
            label = 'Min Leader Score',
            tooltip = 'Minimum Raider.IO/rating score for group leader',
            min = 0,
            max = 4000,
            step = 100,
            column = 3,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.filter.minLeaderRaiderIO = self:GetValue()
                end
            end
        },
        filterByRoleFilled = {
            key = 'vmodules.vuigfinder.filterByRoleFilled',
            type = 'checkbox',
            label = 'Filter by Role Needed',
            tooltip = 'Only show groups that need your role',
            column = 3,
            order = 4,
            callback = function(self)
                if module and module.db then
                    module.db.profile.filter.filterByRoleFilled = self:GetValue()
                end
            end
        },
    })
    
    -- Keyword management
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Keyword Management'
        },
    })
    
    table.insert(Layout.layout.rows, {
        excludeKeywords = {
            key = 'vmodules.vuigfinder.excludeKeywords',
            type = 'checkbox',
            label = 'Exclude Keywords',
            tooltip = 'Filter out groups with these keywords',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.filter.excludeKeywords = self:GetValue()
                end
            end
        },
        whitelistKeywords = {
            key = 'vmodules.vuigfinder.whitelistKeywords',
            type = 'checkbox',
            label = 'Whitelist Keywords',
            tooltip = 'Only show groups with these keywords',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.filter.whitelistKeywords = self:GetValue()
                end
            end
        },
        caseSensitiveKeywords = {
            key = 'vmodules.vuigfinder.caseSensitiveKeywords',
            type = 'checkbox',
            label = 'Case Sensitive',
            tooltip = 'Make keyword matching case sensitive',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.filter.caseSensitiveKeywords = self:GetValue()
                end
            end
        },
    })
    
    table.insert(Layout.layout.rows, {
        keywordEditor = {
            type = 'button',
            label = 'Keyword Editor',
            tooltip = 'Open the keyword editor to manage your filter keywords',
            column = 12,
            order = 1,
            callback = function()
                if module and module.OpenKeywordEditor then
                    module:OpenKeywordEditor()
                end
            end
        },
    })
    
    -- Display settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Display Settings'
        },
    })
    
    table.insert(Layout.layout.rows, {
        colorByDifficulty = {
            key = 'vmodules.vuigfinder.colorByDifficulty',
            type = 'checkbox',
            label = 'Color by Difficulty',
            tooltip = 'Color group listings based on difficulty',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.colorByDifficulty = self:GetValue()
                    if module.RefreshUI then
                        module:RefreshUI()
                    end
                end
            end
        },
        showPlayerScore = {
            key = 'vmodules.vuigfinder.showPlayerScore',
            type = 'checkbox',
            label = 'Show Player Score',
            tooltip = 'Show player mythic+ score where available',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.showPlayerScore = self:GetValue()
                    if module.RefreshUI then
                        module:RefreshUI()
                    end
                end
            end
        },
        showEstimatedTime = {
            key = 'vmodules.vuigfinder.showEstimatedTime',
            type = 'checkbox',
            label = 'Show Estimated Time',
            tooltip = 'Show estimated completion time for dungeon groups',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.showEstimatedTime = self:GetValue()
                    if module.RefreshUI then
                        module:RefreshUI()
                    end
                end
            end
        },
    })
    
    -- Additional display options
    table.insert(Layout.layout.rows, {
        compactView = {
            key = 'vmodules.vuigfinder.compactView',
            type = 'checkbox',
            label = 'Compact View',
            tooltip = 'Use a more compact listing view',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.compactView = self:GetValue()
                    if module.UpdateDisplayMode then
                        module:UpdateDisplayMode()
                    end
                end
            end
        },
        enhancedTooltips = {
            key = 'vmodules.vuigfinder.enhancedTooltips',
            type = 'checkbox',
            label = 'Enhanced Tooltips',
            tooltip = 'Show enhanced tooltips with more group information',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.enhancedTooltips = self:GetValue()
                end
            end
        },
        showApplicantHistory = {
            key = 'vmodules.vuigfinder.showApplicantHistory',
            type = 'checkbox',
            label = 'Show Applicant History',
            tooltip = 'Show history of your group applications',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.showApplicantHistory = self:GetValue()
                    if module.RefreshUI then
                        module:RefreshUI()
                    end
                end
            end
        },
    })
    
    -- Notification settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Notification Settings'
        },
    })
    
    table.insert(Layout.layout.rows, {
        notifyOnApplication = {
            key = 'vmodules.vuigfinder.notifyOnApplication',
            type = 'checkbox',
            label = 'Notify on Application',
            tooltip = 'Notify when your application status changes',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.notifications.notifyOnApplication = self:GetValue()
                end
            end
        },
        notifyOnNewGroups = {
            key = 'vmodules.vuigfinder.notifyOnNewGroups',
            type = 'checkbox',
            label = 'Notify on New Groups',
            tooltip = 'Notify when new groups matching your filters appear',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.notifications.notifyOnNewGroups = self:GetValue()
                end
            end
        },
        enableSoundAlerts = {
            key = 'vmodules.vuigfinder.enableSoundAlerts',
            type = 'checkbox',
            label = 'Enable Sound Alerts',
            tooltip = 'Play sound alerts for notifications',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.notifications.enableSoundAlerts = self:GetValue()
                end
            end
        },
    })
    
    -- Group tracking
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Group Tracking'
        },
    })
    
    table.insert(Layout.layout.rows, {
        trackApplications = {
            key = 'vmodules.vuigfinder.trackApplications',
            type = 'checkbox',
            label = 'Track Applications',
            tooltip = 'Track your group finder applications',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.tracking.trackApplications = self:GetValue()
                end
            end
        },
        trackCompletedGroups = {
            key = 'vmodules.vuigfinder.trackCompletedGroups',
            type = 'checkbox',
            label = 'Track Completed Groups',
            tooltip = 'Track groups you\'ve completed activities with',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.tracking.trackCompletedGroups = self:GetValue()
                end
            end
        },
        trackPlayerNotes = {
            key = 'vmodules.vuigfinder.trackPlayerNotes',
            type = 'checkbox',
            label = 'Track Player Notes',
            tooltip = 'Save notes about players you\'ve grouped with',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.tracking.trackPlayerNotes = self:GetValue()
                end
            end
        },
    })
    
    -- Controls
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Group Finder Controls'
        },
    })
    
    table.insert(Layout.layout.rows, {
        openGroupFinder = {
            type = 'button',
            label = 'Open Group Finder',
            tooltip = 'Open the VUI enhanced group finder',
            column = 4,
            order = 1,
            callback = function()
                if module and module.OpenUI then
                    module:OpenUI()
                else
                    PVEFrame_ToggleFrame()
                end
            end
        },
        manageFilters = {
            type = 'button',
            label = 'Manage Filters',
            tooltip = 'Manage your saved filters',
            column = 4,
            order = 2,
            callback = function()
                if module and module.OpenFilterManager then
                    module:OpenFilterManager()
                end
            end
        },
        resetSettings = {
            type = 'button',
            label = 'Reset Settings',
            tooltip = 'Reset group finder settings to defaults',
            column = 4,
            order = 3,
            callback = function()
                if module and module.ResetSettings then
                    module:ResetSettings()
                end
            end
        },
    })
end

return Layout 