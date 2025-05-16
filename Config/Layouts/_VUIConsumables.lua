--[[
    VUI Consumables Module Configuration
    Tracking for potions, flasks, food, and other consumables
]]

local Layout = VUI:NewModule('Config.Layout.VUIConsumables')

-- Initialize with the standard layout helper
VUI.ConfigHelpers.CreateStandardLayout(Layout, "VUIConsumables", "VUI Consumables", "vmodules.vuiconsumables")

-- Define module-specific layout construction
function Layout:BuildModuleLayout(module, db)
    -- Extend the base layout with module-specific settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Consumable Display Settings'
        },
    })
    
    -- Add basic settings
    table.insert(Layout.layout.rows, {
        enableTracking = {
            key = 'vmodules.vuiconsumables.enableTracking',
            type = 'checkbox',
            label = 'Enable Consumable Tracking',
            tooltip = 'Enable tracking of active consumables',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.general.enableTracking = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
        showReminder = {
            key = 'vmodules.vuiconsumables.showReminder',
            type = 'checkbox',
            label = 'Show Reminders',
            tooltip = 'Show reminders when consumables are missing or about to expire',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.reminder.enabled = self:GetValue()
                end
            end
        },
        lockFrames = {
            key = 'vmodules.vuiconsumables.lockFrames',
            type = 'checkbox',
            label = 'Lock Frames',
            tooltip = 'Lock or unlock VUI Consumables frames',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.general.lockFrames = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
    })
    
    -- Categories to track
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Categories to Track'
        },
    })
    
    table.insert(Layout.layout.rows, {
        trackFood = {
            key = 'vmodules.vuiconsumables.trackFood',
            type = 'checkbox',
            label = 'Track Food',
            tooltip = 'Track food buffs',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.categories.food = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
        trackFlasks = {
            key = 'vmodules.vuiconsumables.trackFlasks',
            type = 'checkbox',
            label = 'Track Flasks',
            tooltip = 'Track flask buffs',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.categories.flasks = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
        trackPotions = {
            key = 'vmodules.vuiconsumables.trackPotions',
            type = 'checkbox',
            label = 'Track Potions',
            tooltip = 'Track potion cooldowns',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.categories.potions = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
    })
    
    table.insert(Layout.layout.rows, {
        trackAugments = {
            key = 'vmodules.vuiconsumables.trackAugments',
            type = 'checkbox',
            label = 'Track Augments',
            tooltip = 'Track augment runes and other temporary enhancements',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.categories.augments = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
    })
    
    -- Display configuration
    table.insert(Layout.layout.rows, {
        iconSize = {
            key = 'vmodules.vuiconsumables.iconSize',
            type = 'slider',
            label = 'Icon Size',
            tooltip = 'Set the size of consumable icons',
            min = 16,
            max = 64,
            step = 1,
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.iconSize = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
        iconPadding = {
            key = 'vmodules.vuiconsumables.iconPadding',
            type = 'slider',
            label = 'Icon Padding',
            tooltip = 'Set the spacing between consumable icons',
            min = 0,
            max = 20,
            step = 1,
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.iconPadding = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
        growDirection = {
            key = 'vmodules.vuiconsumables.growDirection',
            type = 'dropdown',
            label = 'Grow Direction',
            tooltip = 'Direction in which consumable icons are displayed',
            options = {
                {value = "HORIZONTAL", text = "Horizontal"},
                {value = "VERTICAL", text = "Vertical"}
            },
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.growDirection = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
    })
    
    -- Reminder Settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Reminder Settings'
        },
    })
    
    table.insert(Layout.layout.rows, {
        reminderType = {
            key = 'vmodules.vuiconsumables.reminderType',
            type = 'dropdown',
            label = 'Reminder Type',
            tooltip = 'How to display reminders for missing consumables',
            options = {
                {value = "ICON", text = "Icon Only"},
                {value = "TEXT", text = "Text Only"},
                {value = "BOTH", text = "Icon & Text"}
            },
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.reminder.reminderType = self:GetValue()
                    if module.UpdateReminderDisplay then
                        module:UpdateReminderDisplay()
                    end
                end
            end
        },
        reminderThreshold = {
            key = 'vmodules.vuiconsumables.reminderThreshold',
            type = 'slider',
            label = 'Reminder Threshold',
            tooltip = 'How many minutes before expiry to show reminders',
            min = 1,
            max = 15,
            step = 1,
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.reminder.threshold = self:GetValue()
                end
            end
        },
        flashReminder = {
            key = 'vmodules.vuiconsumables.flashReminder',
            type = 'checkbox',
            label = 'Flash Reminders',
            tooltip = 'Make reminder icons/text flash when consumables are missing',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.reminder.flash = self:GetValue()
                    if module.UpdateReminderDisplay then
                        module:UpdateReminderDisplay()
                    end
                end
            end
        },
    })
    
    -- Inventory Tracking
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Inventory Tracking'
        },
    })
    
    table.insert(Layout.layout.rows, {
        trackInventory = {
            key = 'vmodules.vuiconsumables.trackInventory',
            type = 'checkbox',
            label = 'Track Inventory',
            tooltip = 'Track consumables in your inventory',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.inventory.trackInventory = self:GetValue()
                    if module.UpdateInventoryTracking then
                        module:UpdateInventoryTracking()
                    end
                end
            end
        },
        lowCountThreshold = {
            key = 'vmodules.vuiconsumables.lowCountThreshold',
            type = 'slider',
            label = 'Low Count Threshold',
            tooltip = 'Number of items considered "low" for warnings',
            min = 1,
            max = 20,
            step = 1,
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.inventory.lowCountThreshold = self:GetValue()
                end
            end
        },
        warnLowCount = {
            key = 'vmodules.vuiconsumables.warnLowCount',
            type = 'checkbox',
            label = 'Warn on Low Count',
            tooltip = 'Show warning when consumable count is low',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.inventory.warnLowCount = self:GetValue()
                end
            end
        },
    })
    
    -- Instance-specific Settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Instance Settings'
        },
    })
    
    table.insert(Layout.layout.rows, {
        enableInDungeons = {
            key = 'vmodules.vuiconsumables.enableInDungeons',
            type = 'checkbox',
            label = 'Enable in Dungeons',
            tooltip = 'Enable consumable tracking in dungeons',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.instances.enableInDungeons = self:GetValue()
                end
            end
        },
        enableInRaids = {
            key = 'vmodules.vuiconsumables.enableInRaids',
            type = 'checkbox',
            label = 'Enable in Raids',
            tooltip = 'Enable consumable tracking in raids',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.instances.enableInRaids = self:GetValue()
                end
            end
        },
        enableInBattlegrounds = {
            key = 'vmodules.vuiconsumables.enableInBattlegrounds',
            type = 'checkbox',
            label = 'Enable in Battlegrounds',
            tooltip = 'Enable consumable tracking in PvP battlegrounds',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.instances.enableInBattlegrounds = self:GetValue()
                end
            end
        },
    })
    
    -- Test Controls
    table.insert(Layout.layout.rows, {
        testButton = {
            type = 'button',
            label = 'Test Reminder',
            tooltip = 'Test the reminder display',
            column = 12,
            order = 1,
            callback = function()
                if module and module.TestReminder then
                    module:TestReminder()
                end
            end
        },
    })
end

return Layout 