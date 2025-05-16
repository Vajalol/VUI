--[[
    VUI CC Module Configuration
    Advanced crowd control tracking for PvP and dungeons
]]

local Layout = VUI:NewModule('Config.Layout.VUICC')

-- Initialize with the standard layout helper
VUI.ConfigHelpers.CreateStandardLayout(Layout, "VUICC", "VUI Crowd Control", "vmodules.vuicc")

-- Define module-specific layout construction
function Layout:BuildModuleLayout(module, db)
    -- Extend the base layout with module-specific settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Display Settings'
        },
    })
    
    -- Add basic settings
    table.insert(Layout.layout.rows, {
        lockFrames = {
            key = 'vmodules.vuicc.lockFrames',
            type = 'checkbox',
            label = 'Lock Frames',
            tooltip = 'Lock or unlock VUI CC frames',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.general.lockFrames = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
        showIcons = {
            key = 'vmodules.vuicc.showIcons',
            type = 'checkbox',
            label = 'Show Icons',
            tooltip = 'Show spell icons in the CC display',
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
        showTimers = {
            key = 'vmodules.vuicc.showTimers',
            type = 'checkbox',
            label = 'Show Timers',
            tooltip = 'Show countdown timers for active CCs',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.showTimers = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
    })
    
    -- Size and position configuration
    table.insert(Layout.layout.rows, {
        iconSize = {
            key = 'vmodules.vuicc.iconSize',
            type = 'slider',
            label = 'Icon Size',
            tooltip = 'Set the size of CC spell icons',
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
        maxIcons = {
            key = 'vmodules.vuicc.maxIcons',
            type = 'slider',
            label = 'Maximum Icons',
            tooltip = 'Maximum number of CC icons to display',
            min = 3,
            max = 20,
            step = 1,
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.maxIcons = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
        growDirection = {
            key = 'vmodules.vuicc.growDirection',
            type = 'dropdown',
            label = 'Grow Direction',
            tooltip = 'Direction in which new icons are added',
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
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
    })
    
    -- Text and visual settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Text and Visuals'
        },
    })
    
    table.insert(Layout.layout.rows, {
        showSpellNames = {
            key = 'vmodules.vuicc.showSpellNames',
            type = 'checkbox',
            label = 'Show Spell Names',
            tooltip = 'Show the names of CC spells',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.showSpellNames = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
        showTargetNames = {
            key = 'vmodules.vuicc.showTargetNames',
            type = 'checkbox',
            label = 'Show Target Names',
            tooltip = 'Show the names of CC targets',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.showTargetNames = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
        textSize = {
            key = 'vmodules.vuicc.textSize',
            type = 'slider',
            label = 'Text Size',
            tooltip = 'Size of text displayed with CC icons',
            min = 8,
            max = 24,
            step = 1,
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.textSize = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
    })
    
    -- Icon appearance
    table.insert(Layout.layout.rows, {
        showBorders = {
            key = 'vmodules.vuicc.showBorders',
            type = 'checkbox',
            label = 'Show Icon Borders',
            tooltip = 'Show borders around CC icons',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.showBorders = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
        colorByType = {
            key = 'vmodules.vuicc.colorByType',
            type = 'checkbox',
            label = 'Color by CC Type',
            tooltip = 'Color borders based on CC type (stun, silence, etc.)',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.colorByType = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
        pulseOnEnd = {
            key = 'vmodules.vuicc.pulseOnEnd',
            type = 'checkbox',
            label = 'Pulse on End',
            tooltip = 'Make icons pulse when CC is about to end',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.pulseOnEnd = self:GetValue()
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
        trackPlayer = {
            key = 'vmodules.vuicc.trackPlayerCC',
            type = 'checkbox',
            label = 'Track Player CCs',
            tooltip = 'Track crowd control effects applied by you',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.filter.trackPlayerCC = self:GetValue()
                end
            end
        },
        trackParty = {
            key = 'vmodules.vuicc.trackPartyCC',
            type = 'checkbox',
            label = 'Track Party CCs',
            tooltip = 'Track crowd control effects applied by party members',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.filter.trackPartyCC = self:GetValue()
                end
            end
        },
        trackEnemy = {
            key = 'vmodules.vuicc.trackEnemyCC',
            type = 'checkbox',
            label = 'Track Enemy CCs',
            tooltip = 'Track crowd control effects applied by enemies',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.filter.trackEnemyCC = self:GetValue()
                end
            end
        },
    })
    
    -- CC Type filtering
    table.insert(Layout.layout.rows, {
        trackStuns = {
            key = 'vmodules.vuicc.trackStuns',
            type = 'checkbox',
            label = 'Track Stuns',
            tooltip = 'Track stun effects',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.filter.trackStuns = self:GetValue()
                end
            end
        },
        trackSilences = {
            key = 'vmodules.vuicc.trackSilences',
            type = 'checkbox',
            label = 'Track Silences',
            tooltip = 'Track silence effects',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.filter.trackSilences = self:GetValue()
                end
            end
        },
        trackIncapacitates = {
            key = 'vmodules.vuicc.trackIncapacitates',
            type = 'checkbox',
            label = 'Track Incapacitates',
            tooltip = 'Track incapacitate effects (sap, polymorph, etc.)',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.filter.trackIncapacitates = self:GetValue()
                end
            end
        },
    })
    
    table.insert(Layout.layout.rows, {
        trackRoots = {
            key = 'vmodules.vuicc.trackRoots',
            type = 'checkbox',
            label = 'Track Roots',
            tooltip = 'Track root effects',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.filter.trackRoots = self:GetValue()
                end
            end
        },
    })
    
    -- Duration filter
    table.insert(Layout.layout.rows, {
        minDuration = {
            key = 'vmodules.vuicc.minDuration',
            type = 'slider',
            label = 'Minimum Duration',
            tooltip = 'Minimum CC duration to track (in seconds)',
            min = 0,
            max = 10,
            step = 0.5,
            column = 6,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.filter.minDuration = self:GetValue()
                end
            end
        },
        maxTracked = {
            key = 'vmodules.vuicc.maxTracked',
            type = 'slider',
            label = 'Maximum Tracked',
            tooltip = 'Maximum number of CCs to track per target',
            min = 1,
            max = 5,
            step = 1,
            column = 6,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.filter.maxTracked = self:GetValue()
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
        enableSounds = {
            key = 'vmodules.vuicc.enableSounds',
            type = 'checkbox',
            label = 'Enable Sounds',
            tooltip = 'Play sounds for important CC events',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.notifications.enableSounds = self:GetValue()
                end
            end
        },
        announceBreaks = {
            key = 'vmodules.vuicc.announceBreaks',
            type = 'checkbox',
            label = 'Announce Breaks',
            tooltip = 'Announce when CC effects are broken early',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.notifications.announceBreaks = self:GetValue()
                end
            end
        },
        showCountdown = {
            key = 'vmodules.vuicc.showCountdown',
            type = 'checkbox',
            label = 'Show Countdown',
            tooltip = 'Show countdown for CC duration',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.notifications.showCountdown = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
    })
    
    -- Instance-specific settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Instance Settings'
        },
    })
    
    table.insert(Layout.layout.rows, {
        enableInWorld = {
            key = 'vmodules.vuicc.enableInWorld',
            type = 'checkbox',
            label = 'Enable in World',
            tooltip = 'Enable CC tracking in the open world',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.instances.enableInWorld = self:GetValue()
                end
            end
        },
        enableInArenas = {
            key = 'vmodules.vuicc.enableInArenas',
            type = 'checkbox',
            label = 'Enable in Arenas',
            tooltip = 'Enable CC tracking in arena PvP',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.instances.enableInArenas = self:GetValue()
                end
            end
        },
        enableInBattlegrounds = {
            key = 'vmodules.vuicc.enableInBattlegrounds',
            type = 'checkbox',
            label = 'Enable in Battlegrounds',
            tooltip = 'Enable CC tracking in battleground PvP',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.instances.enableInBattlegrounds = self:GetValue()
                end
            end
        },
    })
    
    table.insert(Layout.layout.rows, {
        enableInDungeons = {
            key = 'vmodules.vuicc.enableInDungeons',
            type = 'checkbox',
            label = 'Enable in Dungeons',
            tooltip = 'Enable CC tracking in dungeons',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.instances.enableInDungeons = self:GetValue()
                end
            end
        },
        enableInRaids = {
            key = 'vmodules.vuicc.enableInRaids',
            type = 'checkbox',
            label = 'Enable in Raids',
            tooltip = 'Enable CC tracking in raids',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.instances.enableInRaids = self:GetValue()
                end
            end
        },
        testMode = {
            type = 'button',
            label = 'Test Mode',
            tooltip = 'Toggle test mode to preview CC display',
            column = 4,
            order = 3,
            callback = function()
                if module and module.ToggleTestMode then
                    module:ToggleTestMode()
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
            label = 'Open Full Configuration',
            tooltip = 'Open the detailed VUICC configuration panel',
            column = 6,
            order = 1,
            callback = function()
                if module and module.OpenOptions then
                    module:OpenOptions()
                end
            end
        },
        resetPositions = {
            type = 'button',
            label = 'Reset Positions',
            tooltip = 'Reset the position of all frames',
            column = 6,
            order = 2,
            callback = function()
                if module and module.ResetPositions then
                    module:ResetPositions()
                end
            end
        },
    })
end

return Layout 