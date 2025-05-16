--[[
    VUI Missing Raid Buffs Module Configuration
    Tracking for missing raid/party buffs
]]

local Layout = VUI:NewModule('Config.Layout.VUIMissingRaidBuffs')

-- Initialize with the standard layout helper
VUI.ConfigHelpers.CreateStandardLayout(Layout, "VUIMissingRaidBuffs", "VUI Missing Raid Buffs", "vmodules.vuimissingraidbuffs")

-- Define module-specific layout construction
function Layout:BuildModuleLayout(module, db)
    -- Extend the base layout with module-specific settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Missing Buff Tracking'
        },
    })
    
    -- Add basic settings
    table.insert(Layout.layout.rows, {
        enableTracking = {
            key = 'vmodules.vuimissingraidbuffs.enableTracking',
            type = 'checkbox',
            label = 'Enable Tracking',
            tooltip = 'Enable missing raid buff tracking',
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
        onlyInGroup = {
            key = 'vmodules.vuimissingraidbuffs.onlyInGroup',
            type = 'checkbox',
            label = 'Only in Group',
            tooltip = 'Only track when in a group or raid',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.general.onlyInGroup = self:GetValue()
                end
            end
        },
        announceChat = {
            key = 'vmodules.vuimissingraidbuffs.announceChat',
            type = 'checkbox',
            label = 'Announce to Chat',
            tooltip = 'Announce missing buffs to group chat',
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
            key = 'vmodules.vuimissingraidbuffs.showDisplay',
            type = 'checkbox',
            label = 'Show Display',
            tooltip = 'Show missing buff display frame',
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
            key = 'vmodules.vuimissingraidbuffs.lockFrame',
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
            key = 'vmodules.vuimissingraidbuffs.showIcons',
            type = 'checkbox',
            label = 'Show Icons',
            tooltip = 'Show buff icons in the display',
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
        frameScale = {
            key = 'vmodules.vuimissingraidbuffs.frameScale',
            type = 'slider',
            label = 'Frame Scale',
            tooltip = 'Scale of the display frame',
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
            key = 'vmodules.vuimissingraidbuffs.iconSize',
            type = 'slider',
            label = 'Icon Size',
            tooltip = 'Size of buff icons',
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
        frameAlpha = {
            key = 'vmodules.vuimissingraidbuffs.frameAlpha',
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
    
    -- Buff tracking options
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Buff Categories'
        },
    })
    
    table.insert(Layout.layout.rows, {
        trackStats = {
            key = 'vmodules.vuimissingraidbuffs.trackStats',
            type = 'checkbox',
            label = 'Stat Buffs',
            tooltip = 'Track missing stat buffs (intellect, stamina, etc.)',
            column = 3,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.buffs.stats = self:GetValue()
                    if module.UpdateBuffsList then
                        module:UpdateBuffsList()
                    end
                end
            end
        },
        trackAttack = {
            key = 'vmodules.vuimissingraidbuffs.trackAttack',
            type = 'checkbox',
            label = 'Attack Buffs',
            tooltip = 'Track attack power and crit buffs',
            column = 3,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.buffs.attack = self:GetValue()
                    if module.UpdateBuffsList then
                        module:UpdateBuffsList()
                    end
                end
            end
        },
        trackHaste = {
            key = 'vmodules.vuimissingraidbuffs.trackHaste',
            type = 'checkbox',
            label = 'Haste Buffs',
            tooltip = 'Track haste and spell haste buffs',
            column = 3,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.buffs.haste = self:GetValue()
                    if module.UpdateBuffsList then
                        module:UpdateBuffsList()
                    end
                end
            end
        },
        trackVersatility = {
            key = 'vmodules.vuimissingraidbuffs.trackVersatility',
            type = 'checkbox',
            label = 'Versatility Buffs',
            tooltip = 'Track versatility buffs',
            column = 3,
            order = 4,
            callback = function(self)
                if module and module.db then
                    module.db.profile.buffs.versatility = self:GetValue()
                    if module.UpdateBuffsList then
                        module:UpdateBuffsList()
                    end
                end
            end
        },
    })
    
    -- Class buff tracking
    table.insert(Layout.layout.rows, {
        trackWarrior = {
            key = 'vmodules.vuimissingraidbuffs.trackWarrior',
            type = 'checkbox',
            label = 'Warrior Buffs',
            tooltip = 'Track Warrior buffs (Battle Shout)',
            column = 3,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.classes.warrior = self:GetValue()
                    if module.UpdateBuffsList then
                        module:UpdateBuffsList()
                    end
                end
            end
        },
        trackPriest = {
            key = 'vmodules.vuimissingraidbuffs.trackPriest',
            type = 'checkbox',
            label = 'Priest Buffs',
            tooltip = 'Track Priest buffs (Power Word: Fortitude)',
            column = 3,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.classes.priest = self:GetValue()
                    if module.UpdateBuffsList then
                        module:UpdateBuffsList()
                    end
                end
            end
        },
        trackDruid = {
            key = 'vmodules.vuimissingraidbuffs.trackDruid',
            type = 'checkbox',
            label = 'Druid Buffs',
            tooltip = 'Track Druid buffs (Mark of the Wild)',
            column = 3,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.classes.druid = self:GetValue()
                    if module.UpdateBuffsList then
                        module:UpdateBuffsList()
                    end
                end
            end
        },
        trackMage = {
            key = 'vmodules.vuimissingraidbuffs.trackMage',
            type = 'checkbox',
            label = 'Mage Buffs',
            tooltip = 'Track Mage buffs (Arcane Intellect)',
            column = 3,
            order = 4,
            callback = function(self)
                if module and module.db then
                    module.db.profile.classes.mage = self:GetValue()
                    if module.UpdateBuffsList then
                        module:UpdateBuffsList()
                    end
                end
            end
        },
    })
    
    -- Alerts section
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Alert Settings'
        },
    })
    
    table.insert(Layout.layout.rows, {
        alertCombatStart = {
            key = 'vmodules.vuimissingraidbuffs.alertCombatStart',
            type = 'checkbox',
            label = 'Alert at Combat Start',
            tooltip = 'Alert about missing buffs when combat starts',
            column = 6,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.alerts.combatStart = self:GetValue()
                end
            end
        },
        alertReadyCheck = {
            key = 'vmodules.vuimissingraidbuffs.alertReadyCheck',
            type = 'checkbox',
            label = 'Alert at Ready Check',
            tooltip = 'Alert about missing buffs during ready check',
            column = 6,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.alerts.readyCheck = self:GetValue()
                end
            end
        },
    })
    
    -- Announcement channel
    table.insert(Layout.layout.rows, {
        announceChannel = {
            key = 'vmodules.vuimissingraidbuffs.announceChannel',
            type = 'dropdown',
            label = 'Announce Channel',
            tooltip = 'Channel to announce missing buffs',
            options = {
                {value = "AUTO", text = "Auto (Group/Raid)"},
                {value = "PARTY", text = "Party"},
                {value = "RAID", text = "Raid"},
                {value = "RAID_WARNING", text = "Raid Warning"},
                {value = "INSTANCE_CHAT", text = "Instance"}
            },
            column = 6,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.announce.channel = self:GetValue()
                end
            end
        },
        announceCooldown = {
            key = 'vmodules.vuimissingraidbuffs.announceCooldown',
            type = 'slider',
            label = 'Announce Cooldown',
            tooltip = 'Cooldown between announcements (seconds)',
            min = 10,
            max = 300,
            step = 10,
            column = 6,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.announce.cooldown = self:GetValue()
                end
            end
        },
    })
    
    -- Test button
    table.insert(Layout.layout.rows, {
        checkBuffs = {
            type = 'button',
            label = 'Check Missing Buffs',
            tooltip = 'Check for missing buffs now',
            column = 12,
            order = 1,
            callback = function()
                if module and module.CheckBuffs then
                    module:CheckBuffs(true)
                end
            end
        },
    })
end

return Layout 