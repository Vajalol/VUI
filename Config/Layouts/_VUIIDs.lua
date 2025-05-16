--[[
    VUI Interrupts and Dispels Module Configuration
    Tracking for interrupts and dispels in group content
]]

local Layout = VUI:NewModule('Config.Layout.VUIIDs')

-- Initialize with the standard layout helper
VUI.ConfigHelpers.CreateStandardLayout(Layout, "VUIIDs", "VUI Interrupts & Dispels", "vmodules.vuiids")

-- Define module-specific layout construction
function Layout:BuildModuleLayout(module, db)
    -- Extend the base layout with module-specific settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Interrupt & Dispel Tracking'
        },
    })
    
    -- Add basic settings
    table.insert(Layout.layout.rows, {
        enableModule = {
            key = 'vmodules.vuiids.enableModule',
            type = 'checkbox',
            label = 'Enable Tracking',
            tooltip = 'Enable interrupt and dispel tracking',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.general.enableModule = self:GetValue()
                    if module.UpdateModule then
                        module:UpdateModule()
                    end
                end
            end
        },
        onlyInGroups = {
            key = 'vmodules.vuiids.onlyInGroups',
            type = 'checkbox',
            label = 'Only in Groups',
            tooltip = 'Only track when in a group or raid',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.general.onlyInGroups = self:GetValue()
                end
            end
        },
        announceChat = {
            key = 'vmodules.vuiids.announceChat',
            type = 'checkbox',
            label = 'Announce to Chat',
            tooltip = 'Announce interrupts and dispels to group chat',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.announce.chat = self:GetValue()
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
        showDisplay = {
            key = 'vmodules.vuiids.showDisplay',
            type = 'checkbox',
            label = 'Show Display',
            tooltip = 'Show interrupt and dispel display frame',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.showDisplay = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
        lockFrame = {
            key = 'vmodules.vuiids.lockFrame',
            type = 'checkbox',
            label = 'Lock Frame',
            tooltip = 'Lock or unlock the display frame',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.lockFrame = self:GetValue()
                    if module.LockFrame then
                        module:LockFrame(self:GetValue())
                    end
                end
            end
        },
        showIcons = {
            key = 'vmodules.vuiids.showIcons',
            type = 'checkbox',
            label = 'Show Icons',
            tooltip = 'Show spell icons in the display',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.showIcons = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
    })
    
    -- Frame appearance
    table.insert(Layout.layout.rows, {
        maxEntries = {
            key = 'vmodules.vuiids.maxEntries',
            type = 'slider',
            label = 'Maximum Entries',
            tooltip = 'Maximum number of entries to show',
            min = 3,
            max = 15,
            step = 1,
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.maxEntries = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
        fontScale = {
            key = 'vmodules.vuiids.fontScale',
            type = 'slider',
            label = 'Font Scale',
            tooltip = 'Scale of the text in the display',
            min = 0.5,
            max = 2.0,
            step = 0.1,
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.fontScale = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
        frameAlpha = {
            key = 'vmodules.vuiids.frameAlpha',
            type = 'slider',
            label = 'Frame Alpha',
            tooltip = 'Transparency of the display frame',
            min = 0.1,
            max = 1.0,
            step = 0.1,
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.frameAlpha = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
    })
    
    -- Tracking options
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Tracking Options'
        },
    })
    
    table.insert(Layout.layout.rows, {
        trackInterrupts = {
            key = 'vmodules.vuiids.trackInterrupts',
            type = 'checkbox',
            label = 'Track Interrupts',
            tooltip = 'Track spell interrupts',
            column = 3,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.tracking.interrupts = self:GetValue()
                end
            end
        },
        trackDispels = {
            key = 'vmodules.vuiids.trackDispels',
            type = 'checkbox',
            label = 'Track Dispels',
            tooltip = 'Track dispels and purges',
            column = 3,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.tracking.dispels = self:GetValue()
                end
            end
        },
        trackStuns = {
            key = 'vmodules.vuiids.trackStuns',
            type = 'checkbox',
            label = 'Track Stuns',
            tooltip = 'Track stun effects',
            column = 3,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.tracking.stuns = self:GetValue()
                end
            end
        },
        trackSilences = {
            key = 'vmodules.vuiids.trackSilences',
            type = 'checkbox',
            label = 'Track Silences',
            tooltip = 'Track silence effects',
            column = 3,
            order = 4,
            callback = function(self)
                if module and module.db then
                    module.db.profile.tracking.silences = self:GetValue()
                end
            end
        },
    })
    
    -- Announcements
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Announcement Options'
        },
    })
    
    table.insert(Layout.layout.rows, {
        announceChannel = {
            key = 'vmodules.vuiids.announceChannel',
            type = 'dropdown',
            label = 'Announce Channel',
            tooltip = 'Channel to announce interrupts and dispels',
            options = {
                {value = "AUTO", text = "Auto (Group/Raid)"},
                {value = "PARTY", text = "Party"},
                {value = "RAID", text = "Raid"},
                {value = "INSTANCE_CHAT", text = "Instance"},
                {value = "SAY", text = "Say"}
            },
            column = 6,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.announce.channel = self:GetValue()
                end
            end
        },
        announceSelf = {
            key = 'vmodules.vuiids.announceSelf',
            type = 'checkbox',
            label = 'Announce Self',
            tooltip = 'Include your own interrupts and dispels',
            column = 6,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.announce.self = self:GetValue()
                end
            end
        },
    })
    
    -- Test button
    table.insert(Layout.layout.rows, {
        testButton = {
            type = 'button',
            label = 'Test Display',
            tooltip = 'Add a test entry to the display',
            column = 12,
            order = 1,
            callback = function()
                if module and module.TestDisplay then
                    module:TestDisplay()
                end
            end
        },
    })
end

return Layout 