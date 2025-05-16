--[[
    VUI Keystones Module Configuration
    Mythic+ keystone tracking and management
]]

local Layout = VUI:NewModule('Config.Layout.VUIKeystones')

-- Initialize with the standard layout helper
VUI.ConfigHelpers.CreateStandardLayout(Layout, "VUIKeystones", "VUI Keystones", "vmodules.vuikeystones")

-- Define module-specific layout construction
function Layout:BuildModuleLayout(module, db)
    -- Extend the base layout with module-specific settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Keystone Tracking'
        },
    })
    
    -- Add basic settings
    table.insert(Layout.layout.rows, {
        enableTracking = {
            key = 'vmodules.vuikeystones.enableTracking',
            type = 'checkbox',
            label = 'Enable Tracking',
            tooltip = 'Enable keystone tracking',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.general.enableTracking = self:GetValue()
                    if module.UpdateSettings then
                        module:UpdateSettings()
                    end
                end
            end
        },
        announceKeystones = {
            key = 'vmodules.vuikeystones.announceKeystones',
            type = 'checkbox',
            label = 'Announce Keystones',
            tooltip = 'Announce keystones to party chat',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.announce.enabled = self:GetValue()
                end
            end
        },
        trackPartyKeystones = {
            key = 'vmodules.vuikeystones.trackPartyKeystones',
            type = 'checkbox',
            label = 'Track Party Keystones',
            tooltip = 'Track keystones for party members',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.tracking.party = self:GetValue()
                end
            end
        },
    })
    
    -- Weekly affixes
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Weekly Affixes'
        },
    })
    
    table.insert(Layout.layout.rows, {
        showWeeklyAffixes = {
            key = 'vmodules.vuikeystones.showWeeklyAffixes',
            type = 'checkbox',
            label = 'Show Weekly Affixes',
            tooltip = 'Show the current week\'s affixes',
            column = 6,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.affixes.showWeekly = self:GetValue()
                    if module.UpdateAffixDisplay then
                        module:UpdateAffixDisplay()
                    end
                end
            end
        },
        showNextWeek = {
            key = 'vmodules.vuikeystones.showNextWeek',
            type = 'checkbox',
            label = 'Show Next Week',
            tooltip = 'Show next week\'s affixes',
            column = 6,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.affixes.showNextWeek = self:GetValue()
                    if module.UpdateAffixDisplay then
                        module:UpdateAffixDisplay()
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
        showMinimap = {
            key = 'vmodules.vuikeystones.showMinimap',
            type = 'checkbox',
            label = 'Show Minimap Button',
            tooltip = 'Show keystone information on the minimap',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.showMinimap = self:GetValue()
                    if module.UpdateMinimapButton then
                        module:UpdateMinimapButton()
                    end
                end
            end
        },
        lockFrames = {
            key = 'vmodules.vuikeystones.lockFrames',
            type = 'checkbox',
            label = 'Lock Frames',
            tooltip = 'Lock or unlock keystone display frames',
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
        showTooltips = {
            key = 'vmodules.vuikeystones.showTooltips',
            type = 'checkbox',
            label = 'Show Tooltips',
            tooltip = 'Show detailed tooltips for keystones',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.showTooltips = self:GetValue()
                end
            end
        },
    })
    
    -- Main display settings
    table.insert(Layout.layout.rows, {
        frameScale = {
            key = 'vmodules.vuikeystones.frameScale',
            type = 'slider',
            label = 'Frame Scale',
            tooltip = 'Scale of the keystone display frame',
            min = 0.5,
            max = 2.0,
            step = 0.1,
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.frameScale = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
        iconSize = {
            key = 'vmodules.vuikeystones.iconSize',
            type = 'slider',
            label = 'Icon Size',
            tooltip = 'Size of dungeon and affix icons',
            min = 16,
            max = 64,
            step = 1,
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.iconSize = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
        minimapSize = {
            key = 'vmodules.vuikeystones.minimapSize',
            type = 'slider',
            label = 'Minimap Button Size',
            tooltip = 'Size of the minimap button',
            min = 16,
            max = 48,
            step = 1,
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.minimapSize = self:GetValue()
                    if module.UpdateMinimapButton then
                        module:UpdateMinimapButton()
                    end
                end
            end
        },
    })
    
    -- Dungeon timing
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Dungeon Timing'
        },
    })
    
    table.insert(Layout.layout.rows, {
        showTimer = {
            key = 'vmodules.vuikeystones.showTimer',
            type = 'checkbox',
            label = 'Show Timer',
            tooltip = 'Show dungeon timer when in a Mythic+ dungeon',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.timer.showTimer = self:GetValue()
                    if module.UpdateTimerDisplay then
                        module:UpdateTimerDisplay()
                    end
                end
            end
        },
        showObjectives = {
            key = 'vmodules.vuikeystones.showObjectives',
            type = 'checkbox',
            label = 'Show Objectives',
            tooltip = 'Show dungeon objectives and progress',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.timer.showObjectives = self:GetValue()
                    if module.UpdateTimerDisplay then
                        module:UpdateTimerDisplay()
                    end
                end
            end
        },
        showDeathCounter = {
            key = 'vmodules.vuikeystones.showDeathCounter',
            type = 'checkbox',
            label = 'Show Death Counter',
            tooltip = 'Show death counter during Mythic+ dungeons',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.timer.showDeathCounter = self:GetValue()
                    if module.UpdateTimerDisplay then
                        module:UpdateTimerDisplay()
                    end
                end
            end
        },
    })
    
    -- Commands
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Keystone Commands'
        },
    })
    
    table.insert(Layout.layout.rows, {
        showKeystones = {
            type = 'button',
            label = 'Show My Keystones',
            tooltip = 'Show your keystones on all characters',
            column = 6,
            order = 1,
            callback = function()
                if module and module.ShowKeystones then
                    module:ShowKeystones()
                end
            end
        },
        announceKey = {
            type = 'button',
            label = 'Announce Keystone',
            tooltip = 'Announce your current keystone to the party',
            column = 6,
            order = 2,
            callback = function()
                if module and module.AnnounceKeystone then
                    module:AnnounceKeystone()
                end
            end
        },
    })
end

return Layout 