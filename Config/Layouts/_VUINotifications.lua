--[[
    VUI Notifications Module Configuration
    Enhanced notification system for game events
]]

local Layout = VUI:NewModule('Config.Layout.VUINotifications')

-- Initialize with the standard layout helper
VUI.ConfigHelpers.CreateStandardLayout(Layout, "VUINotifications", "VUI Notifications", "vmodules.vuinotifications")

-- Define module-specific layout construction
function Layout:BuildModuleLayout(module, db)
    -- Extend the base layout with module-specific settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Notification Settings'
        },
    })
    
    -- Add basic settings
    table.insert(Layout.layout.rows, {
        enableNotifications = {
            key = 'vmodules.vuinotifications.enabled',
            type = 'checkbox',
            label = 'Enable Notifications',
            tooltip = 'Enable custom VUI notifications',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.general.enabled = self:GetValue()
                    if module.UpdateSettings then
                        module:UpdateSettings()
                    end
                end
            end
        },
        includeSound = {
            key = 'vmodules.vuinotifications.includeSound',
            type = 'checkbox',
            label = 'Play Sounds',
            tooltip = 'Play sound effects with notifications',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.general.includeSound = self:GetValue()
                end
            end
        },
        persistentDisplay = {
            key = 'vmodules.vuinotifications.persistentDisplay',
            type = 'checkbox',
            label = 'Persistent Display',
            tooltip = 'Keep notifications visible until manually dismissed',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.persistent = self:GetValue()
                end
            end
        },
    })
    
    -- Additional general settings
    table.insert(Layout.layout.rows, {
        suppressInCombat = {
            key = 'vmodules.vuinotifications.suppressInCombat',
            type = 'checkbox',
            label = 'Suppress in Combat',
            tooltip = 'Suppress non-critical notifications during combat',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.general.suppressInCombat = self:GetValue()
                end
            end
        },
        queueNotifications = {
            key = 'vmodules.vuinotifications.queueNotifications',
            type = 'checkbox',
            label = 'Queue Notifications',
            tooltip = 'Queue multiple notifications instead of showing all at once',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.general.queueNotifications = self:GetValue()
                end
            end
        },
        saveHistory = {
            key = 'vmodules.vuinotifications.saveHistory',
            type = 'checkbox',
            label = 'Save History',
            tooltip = 'Save notification history between sessions',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.general.saveHistory = self:GetValue()
                end
            end
        },
    })
    
    -- Display configuration
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Display Settings'
        },
    })
    
    table.insert(Layout.layout.rows, {
        displayPosition = {
            key = 'vmodules.vuinotifications.displayPosition',
            type = 'dropdown',
            label = 'Display Position',
            tooltip = 'Where to show notifications on screen',
            options = {
                {value = "TOP", text = "Top"},
                {value = "BOTTOM", text = "Bottom"},
                {value = "LEFT", text = "Left"},
                {value = "RIGHT", text = "Right"},
                {value = "CENTER", text = "Center"},
                {value = "TOP_LEFT", text = "Top Left"},
                {value = "TOP_RIGHT", text = "Top Right"},
                {value = "BOTTOM_LEFT", text = "Bottom Left"},
                {value = "BOTTOM_RIGHT", text = "Bottom Right"}
            },
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.position = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
        notificationWidth = {
            key = 'vmodules.vuinotifications.width',
            type = 'slider',
            label = 'Notification Width',
            tooltip = 'Width of notification frames',
            min = 100,
            max = 500,
            step = 10,
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.width = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
        displayTime = {
            key = 'vmodules.vuinotifications.displayTime',
            type = 'slider',
            label = 'Display Time',
            tooltip = 'How long notifications stay visible (seconds)',
            min = 1,
            max = 30,
            step = 1,
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.time = self:GetValue()
                end
            end
        },
    })
    
    -- Visual style settings
    table.insert(Layout.layout.rows, {
        displayStyle = {
            key = 'vmodules.vuinotifications.displayStyle',
            type = 'dropdown',
            label = 'Display Style',
            tooltip = 'Visual style for notifications',
            options = {
                {value = "STANDARD", text = "Standard"},
                {value = "COMPACT", text = "Compact"},
                {value = "MINIMALIST", text = "Minimalist"},
                {value = "DETAILED", text = "Detailed"}
            },
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.style = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
        showIcons = {
            key = 'vmodules.vuinotifications.showIcons',
            type = 'checkbox',
            label = 'Show Icons',
            tooltip = 'Show icons with notifications',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.showIcons = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
        customFontSize = {
            key = 'vmodules.vuinotifications.fontSize',
            type = 'slider',
            label = 'Font Size',
            tooltip = 'Text size for notifications',
            min = 8,
            max = 24,
            step = 1,
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.fontSize = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
    })
    
    -- Animation settings
    table.insert(Layout.layout.rows, {
        enableAnimations = {
            key = 'vmodules.vuinotifications.enableAnimations',
            type = 'checkbox',
            label = 'Enable Animations',
            tooltip = 'Show animations for notifications',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.enableAnimations = self:GetValue()
                end
            end
        },
        fadeEffect = {
            key = 'vmodules.vuinotifications.fadeEffect',
            type = 'checkbox',
            label = 'Fade Effect',
            tooltip = 'Enable fade in/out effect for notifications',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.fadeEffect = self:GetValue()
                end
            end
        },
        animationSpeed = {
            key = 'vmodules.vuinotifications.animationSpeed',
            type = 'slider',
            label = 'Animation Speed',
            tooltip = 'Speed of notification animations',
            min = 0.5,
            max = 2.0,
            step = 0.1,
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.animationSpeed = self:GetValue()
                end
            end
        },
    })
    
    -- Notification categories
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Notification Categories'
        },
    })
    
    table.insert(Layout.layout.rows, {
        notifyCombat = {
            key = 'vmodules.vuinotifications.notifyCombat',
            type = 'checkbox',
            label = 'Combat Events',
            tooltip = 'Show notifications for combat events',
            column = 3,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.categories.combat = self:GetValue()
                end
            end
        },
        notifyLoot = {
            key = 'vmodules.vuinotifications.notifyLoot',
            type = 'checkbox',
            label = 'Loot Notifications',
            tooltip = 'Show notifications for valuable loot',
            column = 3,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.categories.loot = self:GetValue()
                end
            end
        },
        notifyAchievements = {
            key = 'vmodules.vuinotifications.notifyAchievements',
            type = 'checkbox',
            label = 'Achievements',
            tooltip = 'Show notifications for achievements',
            column = 3,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.categories.achievements = self:GetValue()
                end
            end
        },
        notifySocial = {
            key = 'vmodules.vuinotifications.notifySocial',
            type = 'checkbox',
            label = 'Social Events',
            tooltip = 'Show notifications for guild/friends events',
            column = 3,
            order = 4,
            callback = function(self)
                if module and module.db then
                    module.db.profile.categories.social = self:GetValue()
                end
            end
        },
    })
    
    -- Additional categories
    table.insert(Layout.layout.rows, {
        notifySystem = {
            key = 'vmodules.vuinotifications.notifySystem',
            type = 'checkbox',
            label = 'System Messages',
            tooltip = 'Show notifications for system messages',
            column = 3,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.categories.system = self:GetValue()
                end
            end
        },
        notifyCalendar = {
            key = 'vmodules.vuinotifications.notifyCalendar',
            type = 'checkbox',
            label = 'Calendar Events',
            tooltip = 'Show notifications for calendar events',
            column = 3,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.categories.calendar = self:GetValue()
                end
            end
        },
        notifyQuests = {
            key = 'vmodules.vuinotifications.notifyQuests',
            type = 'checkbox',
            label = 'Quest Updates',
            tooltip = 'Show notifications for quest updates',
            column = 3,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.categories.quests = self:GetValue()
                end
            end
        },
        notifyProfessions = {
            key = 'vmodules.vuinotifications.notifyProfessions',
            type = 'checkbox',
            label = 'Profession Updates',
            tooltip = 'Show notifications for profession updates',
            column = 3,
            order = 4,
            callback = function(self)
                if module and module.db then
                    module.db.profile.categories.professions = self:GetValue()
                end
            end
        },
    })
    
    -- Priority settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Priority Settings'
        },
    })
    
    table.insert(Layout.layout.rows, {
        prioritizeCombat = {
            key = 'vmodules.vuinotifications.prioritizeCombat',
            type = 'checkbox',
            label = 'Prioritize Combat',
            tooltip = 'Show combat notifications with higher priority',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.priority.combat = self:GetValue()
                end
            end
        },
        prioritizeLoot = {
            key = 'vmodules.vuinotifications.prioritizeLoot',
            type = 'checkbox',
            label = 'Prioritize Loot',
            tooltip = 'Show loot notifications with higher priority',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.priority.loot = self:GetValue()
                end
            end
        },
        maxQueuedNotifications = {
            key = 'vmodules.vuinotifications.maxQueuedNotifications',
            type = 'slider',
            label = 'Max Queued',
            tooltip = 'Maximum number of notifications to queue',
            min = 5,
            max = 50,
            step = 5,
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.priority.maxQueued = self:GetValue()
                end
            end
        },
    })
    
    -- Sound settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Sound Settings'
        },
    })
    
    table.insert(Layout.layout.rows, {
        combatSound = {
            key = 'vmodules.vuinotifications.combatSound',
            type = 'dropdown',
            label = 'Combat Sound',
            tooltip = 'Sound to play for combat notifications',
            options = {
                {value = "ALARM", text = "Alarm"},
                {value = "ALERT", text = "Alert"},
                {value = "INFO", text = "Info"},
                {value = "NONE", text = "None"}
            },
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.sounds.combat = self:GetValue()
                end
            end
        },
        lootSound = {
            key = 'vmodules.vuinotifications.lootSound',
            type = 'dropdown',
            label = 'Loot Sound',
            tooltip = 'Sound to play for loot notifications',
            options = {
                {value = "LOOT", text = "Loot"},
                {value = "MONEY", text = "Money"},
                {value = "ALERT", text = "Alert"},
                {value = "NONE", text = "None"}
            },
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.sounds.loot = self:GetValue()
                end
            end
        },
        achievementSound = {
            key = 'vmodules.vuinotifications.achievementSound',
            type = 'dropdown',
            label = 'Achievement Sound',
            tooltip = 'Sound to play for achievement notifications',
            options = {
                {value = "ACHIEVEMENT", text = "Achievement"},
                {value = "FANFARE", text = "Fanfare"},
                {value = "ALERT", text = "Alert"},
                {value = "NONE", text = "None"}
            },
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.sounds.achievement = self:GetValue()
                end
            end
        },
    })
    
    -- History settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'History Settings'
        },
    })
    
    table.insert(Layout.layout.rows, {
        historySize = {
            key = 'vmodules.vuinotifications.historySize',
            type = 'slider',
            label = 'History Size',
            tooltip = 'Number of notifications to keep in history',
            min = 10,
            max = 200,
            step = 10,
            column = 6,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.history.size = self:GetValue()
                    if module.UpdateHistorySettings then
                        module:UpdateHistorySettings()
                    end
                end
            end
        },
        purgeOnLogout = {
            key = 'vmodules.vuinotifications.purgeOnLogout',
            type = 'checkbox',
            label = 'Purge on Logout',
            tooltip = 'Clear notification history when logging out',
            column = 6,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.history.purgeOnLogout = self:GetValue()
                end
            end
        },
    })
    
    -- Controls
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Controls'
        },
    })
    
    table.insert(Layout.layout.rows, {
        testNotification = {
            type = 'button',
            label = 'Test Notification',
            tooltip = 'Display a test notification',
            column = 4,
            order = 1,
            callback = function()
                if module and module.ShowNotification then
                    module:ShowNotification("Test Notification", "This is a test notification from VUI", "Interface\\Icons\\INV_Misc_Note_02")
                end
            end
        },
        openHistory = {
            type = 'button',
            label = 'Notification History',
            tooltip = 'View notification history',
            column = 4,
            order = 2,
            callback = function()
                if module and module.ShowHistory then
                    module:ShowHistory()
                end
            end
        },
        clearAllNotifications = {
            type = 'button',
            label = 'Clear All Notifications',
            tooltip = 'Clear all active notifications',
            column = 4,
            order = 3,
            callback = function()
                if module and module.ClearAllNotifications then
                    module:ClearAllNotifications()
                end
            end
        },
    })
end

return Layout 