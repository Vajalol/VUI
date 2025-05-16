--[[
    VUI Healer Mana Module Configuration
    Mana tracking and management for healers
]]

local Layout = VUI:NewModule('Config.Layout.VUIHealerMana')

-- Initialize with the standard layout helper
VUI.ConfigHelpers.CreateStandardLayout(Layout, "VUIHealerMana", "VUI Healer Mana", "vmodules.vuihealermana")

-- Define module-specific layout construction
function Layout:BuildModuleLayout(module, db)
    -- Extend the base layout with module-specific settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Healer Mana Tracking'
        },
    })
    
    -- Add basic settings
    table.insert(Layout.layout.rows, {
        enableModule = {
            key = 'vmodules.vuihealermana.enableModule',
            type = 'checkbox',
            label = 'Enable Healer Mana',
            tooltip = 'Enable healer mana tracking and alerts',
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
        onlyInGroups = {
            key = 'vmodules.vuihealermana.onlyInGroups',
            type = 'checkbox',
            label = 'Only in Groups',
            tooltip = 'Only enable when in a group or raid',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.general.onlyInGroups = self:GetValue()
                end
            end
        },
        includeYourself = {
            key = 'vmodules.vuihealermana.includeYourself',
            type = 'checkbox',
            label = 'Include Yourself',
            tooltip = 'Track your own mana if you are a healer',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.general.includeYourself = self:GetValue()
                    if module.UpdateTracking then
                        module:UpdateTracking()
                    end
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
        showBars = {
            key = 'vmodules.vuihealermana.showBars',
            type = 'checkbox',
            label = 'Show Mana Bars',
            tooltip = 'Show mana bars for healers',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.showBars = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
        lockFrames = {
            key = 'vmodules.vuihealermana.lockFrames',
            type = 'checkbox',
            label = 'Lock Frames',
            tooltip = 'Lock or unlock mana bar frames',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.lockFrames = self:GetValue()
                    if module.LockFrames then
                        module:LockFrames(self:GetValue())
                    end
                end
            end
        },
        showNames = {
            key = 'vmodules.vuihealermana.showNames',
            type = 'checkbox',
            label = 'Show Names',
            tooltip = 'Show healer names on mana bars',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.showNames = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
    })
    
    -- Bar appearance
    table.insert(Layout.layout.rows, {
        barWidth = {
            key = 'vmodules.vuihealermana.barWidth',
            type = 'slider',
            label = 'Bar Width',
            tooltip = 'Width of mana bars',
            min = 50,
            max = 300,
            step = 5,
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.barWidth = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
        barHeight = {
            key = 'vmodules.vuihealermana.barHeight',
            type = 'slider',
            label = 'Bar Height',
            tooltip = 'Height of mana bars',
            min = 5,
            max = 50,
            step = 1,
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.barHeight = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
        barSpacing = {
            key = 'vmodules.vuihealermana.barSpacing',
            type = 'slider',
            label = 'Bar Spacing',
            tooltip = 'Spacing between mana bars',
            min = 0,
            max = 20,
            step = 1,
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.barSpacing = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
    })
    
    -- Alert settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Alert Settings'
        },
    })
    
    table.insert(Layout.layout.rows, {
        enableAlerts = {
            key = 'vmodules.vuihealermana.enableAlerts',
            type = 'checkbox',
            label = 'Enable Alerts',
            tooltip = 'Enable low mana alerts',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.alerts.enableAlerts = self:GetValue()
                end
            end
        },
        alertSound = {
            key = 'vmodules.vuihealermana.alertSound',
            type = 'checkbox',
            label = 'Alert Sound',
            tooltip = 'Play sound on low mana alerts',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.alerts.alertSound = self:GetValue()
                end
            end
        },
        alertThreshold = {
            key = 'vmodules.vuihealermana.alertThreshold',
            type = 'slider',
            label = 'Alert Threshold',
            tooltip = 'Mana percentage to trigger alerts',
            min = 5,
            max = 50,
            step = 5,
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.alerts.threshold = self:GetValue()
                end
            end
        },
    })
    
    -- Healer types settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Healer Classes'
        },
    })
    
    table.insert(Layout.layout.rows, {
        trackPriests = {
            key = 'vmodules.vuihealermana.trackPriests',
            type = 'checkbox',
            label = 'Track Priests',
            tooltip = 'Track mana for Priest healers',
            column = 3,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.classes.priest = self:GetValue()
                    if module.UpdateTracking then
                        module:UpdateTracking()
                    end
                end
            end
        },
        trackDruids = {
            key = 'vmodules.vuihealermana.trackDruids',
            type = 'checkbox',
            label = 'Track Druids',
            tooltip = 'Track mana for Druid healers',
            column = 3,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.classes.druid = self:GetValue()
                    if module.UpdateTracking then
                        module:UpdateTracking()
                    end
                end
            end
        },
        trackShamans = {
            key = 'vmodules.vuihealermana.trackShamans',
            type = 'checkbox',
            label = 'Track Shamans',
            tooltip = 'Track mana for Shaman healers',
            column = 3,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.classes.shaman = self:GetValue()
                    if module.UpdateTracking then
                        module:UpdateTracking()
                    end
                end
            end
        },
        trackPaladins = {
            key = 'vmodules.vuihealermana.trackPaladins',
            type = 'checkbox',
            label = 'Track Paladins',
            tooltip = 'Track mana for Paladin healers',
            column = 3,
            order = 4,
            callback = function(self)
                if module and module.db then
                    module.db.profile.classes.paladin = self:GetValue()
                    if module.UpdateTracking then
                        module:UpdateTracking()
                    end
                end
            end
        },
    })
    
    -- Test button
    table.insert(Layout.layout.rows, {
        testButton = {
            type = 'button',
            label = 'Test Alert',
            tooltip = 'Trigger a test low mana alert',
            column = 12,
            order = 1,
            callback = function()
                if module and module.TestAlert then
                    module:TestAlert()
                end
            end
        },
    })
end

return Layout 