--[[
    VUI Cooldown Module Configuration
    Cooldown tracker for spells and items
]]

local Layout = VUI:NewModule('Config.Layout.VUICD')

-- Initialize with the standard layout helper
VUI.ConfigHelpers.CreateStandardLayout(Layout, "VUICD", "VUI Cooldowns", "vmodules.vuicd")

-- Define module-specific layout construction
function Layout:BuildModuleLayout(module, db)
    -- Extend the base layout with module-specific settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Cooldown Display Settings'
        },
    })
    
    -- Add basic settings
    table.insert(Layout.layout.rows, {
        enableSpellCD = {
            key = 'vmodules.vuicd.enableSpellCD',
            type = 'checkbox',
            label = 'Enable Spell Cooldowns',
            tooltip = 'Enable tracking of spell cooldowns',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.spellCD.enabled = self:GetValue()
                    if module.UpdateAllDisplays then
                        module:UpdateAllDisplays()
                    end
                end
            end
        },
        enableItemCD = {
            key = 'vmodules.vuicd.enableItemCD',
            type = 'checkbox',
            label = 'Enable Item Cooldowns',
            tooltip = 'Enable tracking of item cooldowns',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.itemCD.enabled = self:GetValue()
                    if module.UpdateAllDisplays then
                        module:UpdateAllDisplays()
                    end
                end
            end
        },
        lockFrames = {
            key = 'vmodules.vuicd.lockFrames',
            type = 'checkbox',
            label = 'Lock Frames',
            tooltip = 'Lock or unlock VUI Cooldown frames',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.general.lockFrames = self:GetValue()
                    if module.UpdateAllDisplays then
                        module:UpdateAllDisplays()
                    end
                end
            end
        },
    })
    
    -- Display configuration
    table.insert(Layout.layout.rows, {
        iconSize = {
            key = 'vmodules.vuicd.iconSize',
            type = 'slider',
            label = 'Icon Size',
            tooltip = 'Set the size of cooldown icons',
            min = 16,
            max = 64,
            step = 1,
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.iconSize = self:GetValue()
                    if module.UpdateAllDisplays then
                        module:UpdateAllDisplays()
                    end
                end
            end
        },
        padding = {
            key = 'vmodules.vuicd.padding',
            type = 'slider',
            label = 'Icon Padding',
            tooltip = 'Set the spacing between cooldown icons',
            min = 0,
            max = 20,
            step = 1,
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.padding = self:GetValue()
                    if module.UpdateAllDisplays then
                        module:UpdateAllDisplays()
                    end
                end
            end
        },
        growDirection = {
            key = 'vmodules.vuicd.growDirection',
            type = 'dropdown',
            label = 'Grow Direction',
            tooltip = 'Direction in which cooldown icons are displayed',
            options = {
                {value = "DOWN", text = "Down"},
                {value = "UP", text = "Up"},
                {value = "LEFT", text = "Left"},
                {value = "RIGHT", text = "Right"}
            },
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.growDirection = self:GetValue()
                    if module.UpdateAllDisplays then
                        module:UpdateAllDisplays()
                    end
                end
            end
        },
    })
    
    -- Visual style settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Visual Style'
        },
    })
    
    table.insert(Layout.layout.rows, {
        showCooldownSpiral = {
            key = 'vmodules.vuicd.showCooldownSpiral',
            type = 'checkbox',
            label = 'Show Cooldown Spiral',
            tooltip = 'Show the cooldown spiral animation on icons',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.showCooldownSpiral = self:GetValue()
                    if module.UpdateAllDisplays then
                        module:UpdateAllDisplays()
                    end
                end
            end
        },
        showCooldownText = {
            key = 'vmodules.vuicd.showCooldownText',
            type = 'checkbox',
            label = 'Show Cooldown Text',
            tooltip = 'Show the cooldown time text on icons',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.showCooldownText = self:GetValue()
                    if module.UpdateAllDisplays then
                        module:UpdateAllDisplays()
                    end
                end
            end
        },
        useDecimalPrecision = {
            key = 'vmodules.vuicd.useDecimalPrecision',
            type = 'checkbox',
            label = 'Use Decimal Precision',
            tooltip = 'Show decimal precision for cooldowns under 10 seconds',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.useDecimalPrecision = self:GetValue()
                    if module.UpdateAllDisplays then
                        module:UpdateAllDisplays()
                    end
                end
            end
        },
    })
    
    -- Icon appearance settings
    table.insert(Layout.layout.rows, {
        desaturateIcons = {
            key = 'vmodules.vuicd.desaturateIcons',
            type = 'checkbox',
            label = 'Desaturate Inactive Icons',
            tooltip = 'Desaturate (grayscale) icons that are on cooldown',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.desaturateIcons = self:GetValue()
                    if module.UpdateAllDisplays then
                        module:UpdateAllDisplays()
                    end
                end
            end
        },
        pulseFadeOut = {
            key = 'vmodules.vuicd.pulseFadeOut',
            type = 'checkbox',
            label = 'Pulse on Cooldown End',
            tooltip = 'Make icons pulse when cooldown ends',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.pulseFadeOut = self:GetValue()
                end
            end
        },
        textSize = {
            key = 'vmodules.vuicd.textSize',
            type = 'slider',
            label = 'Text Size',
            tooltip = 'Size of the cooldown text',
            min = 8,
            max = 24,
            step = 1,
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.textSize = self:GetValue()
                    if module.UpdateAllDisplays then
                        module:UpdateAllDisplays()
                    end
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
        minCooldownThreshold = {
            key = 'vmodules.vuicd.minCooldownThreshold',
            type = 'slider',
            label = 'Minimum Cooldown',
            tooltip = 'Minimum cooldown time to track (in seconds)',
            min = 1,
            max = 60,
            step = 1,
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.filter.minCooldownThreshold = self:GetValue()
                end
            end
        },
        maxCooldownThreshold = {
            key = 'vmodules.vuicd.maxCooldownThreshold',
            type = 'slider',
            label = 'Maximum Cooldown',
            tooltip = 'Maximum cooldown time to track (in minutes)',
            min = 1,
            max = 30,
            step = 1,
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.filter.maxCooldownThreshold = self:GetValue()
                end
            end
        },
        hideInCombat = {
            key = 'vmodules.vuicd.hideInCombat',
            type = 'checkbox',
            label = 'Hide In Combat',
            tooltip = 'Hide cooldowns while in combat',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.filter.hideInCombat = self:GetValue()
                end
            end
        },
    })
    
    -- Sort and grouping settings
    table.insert(Layout.layout.rows, {
        sortBy = {
            key = 'vmodules.vuicd.sortBy',
            type = 'dropdown',
            label = 'Sort By',
            tooltip = 'How to sort the cooldown icons',
            options = {
                {value = "TIME", text = "Remaining Time"},
                {value = "NAME", text = "Spell/Item Name"},
                {value = "PRIORITY", text = "Custom Priority"},
                {value = "CATEGORY", text = "Category"}
            },
            column = 6,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.sort.sortBy = self:GetValue()
                    if module.UpdateAllDisplays then
                        module:UpdateAllDisplays()
                    end
                end
            end
        },
        sortDirection = {
            key = 'vmodules.vuicd.sortDirection',
            type = 'dropdown',
            label = 'Sort Direction',
            tooltip = 'Sort ascending or descending',
            options = {
                {value = "ASC", text = "Ascending"},
                {value = "DESC", text = "Descending"}
            },
            column = 6,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.sort.sortDirection = self:GetValue()
                    if module.UpdateAllDisplays then
                        module:UpdateAllDisplays()
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
        enableAudio = {
            key = 'vmodules.vuicd.enableAudio',
            type = 'checkbox',
            label = 'Enable Audio Alerts',
            tooltip = 'Play sound when cooldowns finish',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.alerts.enableAudio = self:GetValue()
                end
            end
        },
        enableVisualAlert = {
            key = 'vmodules.vuicd.enableVisualAlert',
            type = 'checkbox',
            label = 'Enable Visual Alerts',
            tooltip = 'Show visual alert when cooldowns finish',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.alerts.enableVisualAlert = self:GetValue()
                end
            end
        },
        alertThreshold = {
            key = 'vmodules.vuicd.alertThreshold',
            type = 'slider',
            label = 'Alert Threshold',
            tooltip = 'Show alert when cooldown is under this many seconds',
            min = 0,
            max = 10,
            step = 1,
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.alerts.threshold = self:GetValue()
                end
            end
        },
    })
    
    -- Advanced options
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Advanced Options'
        },
    })
    
    table.insert(Layout.layout.rows, {
        openConfig = {
            type = 'button',
            label = 'Open Cooldown Editor',
            tooltip = 'Open the cooldown spell/item editor',
            column = 6,
            order = 1,
            callback = function()
                if module and module.OpenOptions then
                    module:OpenOptions()
                end
            end
        },
        testButton = {
            type = 'button',
            label = 'Test Alert',
            tooltip = 'Test the cooldown alert system',
            column = 6,
            order = 2,
            callback = function()
                if module and module.TestAlert then
                    module:TestAlert()
                end
            end
        },
    })
end

return Layout 