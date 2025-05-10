local Layout = VUI:NewModule('Config.Layout.VUIGfinder')

function Layout:OnEnable()
    -- Database
    local db = VUI.db
    
    -- Module reference
    local VUIGfinder = VUI:GetModule("VUIGfinder")
    
    -- Layout
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        database = db.profile,
        rows = {
            {
                header = {
                    type = 'header',
                    label = 'Premade Group Finder',
                    description = 'Enhances the Group Finder with advanced filtering'
                },
            },
            {
                enabled = {
                    key = 'vmodules.vuigfinder.enabled',
                    type = 'checkbox',
                    label = 'Enable VUI Gfinder',
                    tooltip = 'Enable enhanced group finder functionality',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        if VUIGfinder and VUIGfinder.db then
                            VUIGfinder.db.profile.enabled = self:GetValue()
                            if self:GetValue() then
                                VUIGfinder:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED")
                                VUIGfinder:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED")
                                VUIGfinder:HookSearchResults()
                            else
                                VUIGfinder:UnregisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED")
                                VUIGfinder:UnregisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED")
                            end
                        end
                    end
                },
                useThemeColors = {
                    key = 'vmodules.vuigfinder.useThemeColors',
                    type = 'checkbox',
                    label = 'Use VUI Theme Colors',
                    tooltip = 'Apply the current VUI theme colors to interface elements',
                    column = 4,
                    order = 2,
                    callback = function(self)
                        if VUIGfinder and VUIGfinder.db then
                            VUIGfinder.db.profile.useThemeColors = self:GetValue()
                            if VUIGfinder.UpdateTheme then
                                VUIGfinder:UpdateTheme()
                            end
                        end
                    end
                },
            },
            {
                header = {
                    type = 'header',
                    label = 'Filter Settings'
                },
            },
            {
                minScore = {
                    key = 'vmodules.vuigfinder.minScore',
                    type = 'slider',
                    label = 'Minimum Score',
                    tooltip = 'Filter groups with leader score below this value',
                    min = 0,
                    max = 3000,
                    step = 100,
                    column = 6,
                    order = 1,
                    callback = function(self)
                        if VUIGfinder and VUIGfinder.db then
                            VUIGfinder.db.profile.minScore = self:GetValue()
                            if VUIGfinder.UpdateFilters then
                                VUIGfinder:UpdateFilters()
                            end
                        end
                    end
                },
                minIlvl = {
                    key = 'vmodules.vuigfinder.minIlvl',
                    type = 'slider',
                    label = 'Minimum Item Level',
                    tooltip = 'Filter groups with leader item level below this value',
                    min = 0,
                    max = 500,
                    step = 5,
                    column = 6,
                    order = 2,
                    callback = function(self)
                        if VUIGfinder and VUIGfinder.db then
                            VUIGfinder.db.profile.minIlvl = self:GetValue()
                            if VUIGfinder.UpdateFilters then
                                VUIGfinder:UpdateFilters()
                            end
                        end
                    end
                },
            },
            {
                filterType = {
                    key = 'vmodules.vuigfinder.filterType',
                    type = 'dropdown',
                    label = 'Filter Mode',
                    tooltip = 'Choose how to handle filtered groups',
                    options = {
                        { text = 'Hide Filtered Groups', value = 'HIDE' },
                        { text = 'Show But Highlight', value = 'HIGHLIGHT' },
                        { text = 'Show All Groups', value = 'SHOW_ALL' }
                    },
                    column = 4,
                    order = 1,
                    callback = function(self)
                        if VUIGfinder and VUIGfinder.db then
                            VUIGfinder.db.profile.filterType = self:GetSelectedItem().value
                            if VUIGfinder.UpdateFilters then
                                VUIGfinder:UpdateFilters()
                            end
                        end
                    end
                },
                showLeaderTooltip = {
                    key = 'vmodules.vuigfinder.showLeaderTooltip',
                    type = 'checkbox',
                    label = 'Show Leader Details',
                    tooltip = 'Show detailed leader information in tooltips',
                    column = 4, 
                    order = 2,
                    callback = function(self)
                        if VUIGfinder and VUIGfinder.db then
                            VUIGfinder.db.profile.showLeaderTooltip = self:GetValue()
                        end
                    end
                },
            },
            {
                header = {
                    type = 'header',
                    label = 'Filter Options'
                },
            },
            {
                filterNoVoice = {
                    key = 'vmodules.vuigfinder.filterNoVoice',
                    type = 'checkbox',
                    label = 'Filter No Voice Chat',
                    tooltip = 'Apply filter to groups without voice chat',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        if VUIGfinder and VUIGfinder.db then
                            VUIGfinder.db.profile.filterNoVoice = self:GetValue()
                            if VUIGfinder.UpdateFilters then
                                VUIGfinder:UpdateFilters()
                            end
                        end
                    end
                },
                filterLowRating = {
                    key = 'vmodules.vuigfinder.filterLowRating',
                    type = 'checkbox',
                    label = 'Filter Low Rating',
                    tooltip = 'Apply filter to groups with low PVP rating',
                    column = 4,
                    order = 2,
                    callback = function(self)
                        if VUIGfinder and VUIGfinder.db then
                            VUIGfinder.db.profile.filterLowRating = self:GetValue()
                            if VUIGfinder.UpdateFilters then
                                VUIGfinder:UpdateFilters()
                            end
                        end
                    end
                }
            }
        }
    }
end