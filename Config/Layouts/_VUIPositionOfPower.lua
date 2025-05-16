--[[
    VUI Position of Power Module Configuration
    Position tracking for important abilities and procs
]]

local Layout = VUI:NewModule('Config.Layout.VUIPositionOfPower')

-- Initialize with the standard layout helper
VUI.ConfigHelpers.CreateStandardLayout(Layout, "VUIPositionOfPower", "VUI Position of Power", "vmodules.vuipositionofpower")

-- Define module-specific layout construction
function Layout:BuildModuleLayout(module, db)
    -- Extend the base layout with module-specific settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Position of Power Settings'
        },
    })
    
    -- Add basic settings
    table.insert(Layout.layout.rows, {
        enableTracking = {
            key = 'vmodules.vuipositionofpower.enableTracking',
            type = 'checkbox',
            label = 'Enable Tracking',
            tooltip = 'Enable tracking of position-based procs and abilities',
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
        lockFrames = {
            key = 'vmodules.vuipositionofpower.lockFrames',
            type = 'checkbox',
            label = 'Lock Frames',
            tooltip = 'Lock or unlock VUI Position of Power frames',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.general.lockFrames = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
        soundAlerts = {
            key = 'vmodules.vuipositionofpower.soundAlerts',
            type = 'checkbox',
            label = 'Sound Alerts',
            tooltip = 'Play sound alerts for position-based procs',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.alerts.soundEnabled = self:GetValue()
                end
            end
        },
    })
    
    -- Display configuration
    table.insert(Layout.layout.rows, {
        iconSize = {
            key = 'vmodules.vuipositionofpower.iconSize',
            type = 'slider',
            label = 'Icon Size',
            tooltip = 'Set the size of position indicator icons',
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
        showText = {
            key = 'vmodules.vuipositionofpower.showText',
            type = 'checkbox',
            label = 'Show Text',
            tooltip = 'Show text information with position indicators',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.showText = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
        flashEffect = {
            key = 'vmodules.vuipositionofpower.flashEffect',
            type = 'checkbox',
            label = 'Flash Effect',
            tooltip = 'Enable flashing effects for new procs',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.flashEffect = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
    })
    
    -- Visual customization
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Visual Customization'
        },
    })
    
    table.insert(Layout.layout.rows, {
        showGlow = {
            key = 'vmodules.vuipositionofpower.showGlow',
            type = 'checkbox',
            label = 'Show Glow Effect',
            tooltip = 'Show a glow effect around active position indicators',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.showGlow = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
        showTimer = {
            key = 'vmodules.vuipositionofpower.showTimer',
            type = 'checkbox',
            label = 'Show Timer',
            tooltip = 'Show remaining time for position effects',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.showTimer = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
        showCooldownSpiral = {
            key = 'vmodules.vuipositionofpower.showCooldownSpiral',
            type = 'checkbox',
            label = 'Show Cooldown Spiral',
            tooltip = 'Show cooldown spiral animation on position indicators',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.showCooldownSpiral = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
    })
    
    table.insert(Layout.layout.rows, {
        positionStyle = {
            key = 'vmodules.vuipositionofpower.positionStyle',
            type = 'dropdown',
            label = 'Position Style',
            tooltip = 'Visual style for position indicators',
            options = {
                {value = "ICON", text = "Icon Only"},
                {value = "BAR", text = "Bar"},
                {value = "ICON_AND_BAR", text = "Icon and Bar"},
                {value = "AURA", text = "Aura Style"}
            },
            column = 6,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.positionStyle = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
        barLength = {
            key = 'vmodules.vuipositionofpower.barLength',
            type = 'slider',
            label = 'Bar Length',
            tooltip = 'Length of position indicator bars (if using bar style)',
            min = 50,
            max = 300,
            step = 10,
            column = 6,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.barLength = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
    })
    
    -- Position tracking options
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Position Tracking Options'
        },
    })
    
    table.insert(Layout.layout.rows, {
        trackPlayerPosition = {
            key = 'vmodules.vuipositionofpower.trackPlayerPosition',
            type = 'checkbox',
            label = 'Track Player Position',
            tooltip = 'Track player\'s current position for abilities',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.tracking.trackPlayerPosition = self:GetValue()
                    if module.UpdateTracking then
                        module:UpdateTracking()
                    end
                end
            end
        },
        trackTargetPosition = {
            key = 'vmodules.vuipositionofpower.trackTargetPosition',
            type = 'checkbox',
            label = 'Track Target Position',
            tooltip = 'Track current target\'s position',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.tracking.trackTargetPosition = self:GetValue()
                    if module.UpdateTracking then
                        module:UpdateTracking()
                    end
                end
            end
        },
        trackMovement = {
            key = 'vmodules.vuipositionofpower.trackMovement',
            type = 'checkbox',
            label = 'Track Movement',
            tooltip = 'Track movement status for position effects',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.tracking.trackMovement = self:GetValue()
                    if module.UpdateTracking then
                        module:UpdateTracking()
                    end
                end
            end
        },
    })
    
    table.insert(Layout.layout.rows, {
        updateFrequency = {
            key = 'vmodules.vuipositionofpower.updateFrequency',
            type = 'slider',
            label = 'Update Frequency',
            tooltip = 'How often to update position tracking (seconds)',
            min = 0.1,
            max = 1.0,
            step = 0.1,
            column = 6,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.tracking.updateFrequency = self:GetValue()
                    if module.UpdateTracking then
                        module:UpdateTracking()
                    end
                end
            end
        },
        positionThreshold = {
            key = 'vmodules.vuipositionofpower.positionThreshold',
            type = 'slider',
            label = 'Position Threshold',
            tooltip = 'Minimum distance change to register as position change',
            min = 1,
            max = 10,
            step = 0.5,
            column = 6,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.tracking.positionThreshold = self:GetValue()
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
        alertOnPositionChange = {
            key = 'vmodules.vuipositionofpower.alertOnPositionChange',
            type = 'checkbox',
            label = 'Alert on Position Change',
            tooltip = 'Alert when your position changes significantly',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.alerts.alertOnPositionChange = self:GetValue()
                end
            end
        },
        alertOnProc = {
            key = 'vmodules.vuipositionofpower.alertOnProc',
            type = 'checkbox',
            label = 'Alert on Proc',
            tooltip = 'Alert when a position-based ability procs',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.alerts.alertOnProc = self:GetValue()
                end
            end
        },
        screenFlash = {
            key = 'vmodules.vuipositionofpower.screenFlash',
            type = 'checkbox',
            label = 'Screen Flash',
            tooltip = 'Flash the screen on important position effects',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.alerts.screenFlash = self:GetValue()
                end
            end
        },
    })
    
    -- Instance settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Instance Settings'
        },
    })
    
    table.insert(Layout.layout.rows, {
        enableInWorld = {
            key = 'vmodules.vuipositionofpower.enableInWorld',
            type = 'checkbox',
            label = 'Enable in World',
            tooltip = 'Enable position tracking in the open world',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.instances.enableInWorld = self:GetValue()
                end
            end
        },
        enableInDungeons = {
            key = 'vmodules.vuipositionofpower.enableInDungeons',
            type = 'checkbox',
            label = 'Enable in Dungeons',
            tooltip = 'Enable position tracking in dungeons',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.instances.enableInDungeons = self:GetValue()
                end
            end
        },
        enableInRaids = {
            key = 'vmodules.vuipositionofpower.enableInRaids',
            type = 'checkbox',
            label = 'Enable in Raids',
            tooltip = 'Enable position tracking in raids',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.instances.enableInRaids = self:GetValue()
                end
            end
        },
    })
    
    -- Class-specific settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Class-Specific Settings'
        },
    })
    
    -- Add dynamic class-specific settings
    local playerClass, _ = UnitClass("player")
    if playerClass then
        if playerClass == "MAGE" then
            table.insert(Layout.layout.rows, {
                trackFrostNova = {
                    key = 'vmodules.vuipositionofpower.class.trackFrostNova',
                    type = 'checkbox',
                    label = 'Track Frost Nova',
                    tooltip = 'Track Frost Nova positioning',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        if module and module.db then
                            module.db.profile.class.trackFrostNova = self:GetValue()
                        end
                    end
                },
                trackBlizzard = {
                    key = 'vmodules.vuipositionofpower.class.trackBlizzard',
                    type = 'checkbox',
                    label = 'Track Blizzard',
                    tooltip = 'Track Blizzard positioning',
                    column = 4,
                    order = 2,
                    callback = function(self)
                        if module and module.db then
                            module.db.profile.class.trackBlizzard = self:GetValue()
                        end
                    end
                },
                trackMeteor = {
                    key = 'vmodules.vuipositionofpower.class.trackMeteor',
                    type = 'checkbox',
                    label = 'Track Meteor',
                    tooltip = 'Track Meteor positioning',
                    column = 4,
                    order = 3,
                    callback = function(self)
                        if module and module.db then
                            module.db.profile.class.trackMeteor = self:GetValue()
                        end
                    end
                },
            })
        elseif playerClass == "HUNTER" then
            table.insert(Layout.layout.rows, {
                trackFreezeTraps = {
                    key = 'vmodules.vuipositionofpower.class.trackFreezeTraps',
                    type = 'checkbox',
                    label = 'Track Freeze Traps',
                    tooltip = 'Track Freeze Trap positioning',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        if module and module.db then
                            module.db.profile.class.trackFreezeTraps = self:GetValue()
                        end
                    end
                },
                trackExplosiveTraps = {
                    key = 'vmodules.vuipositionofpower.class.trackExplosiveTraps',
                    type = 'checkbox',
                    label = 'Track Explosive Traps',
                    tooltip = 'Track Explosive Trap positioning',
                    column = 4,
                    order = 2,
                    callback = function(self)
                        if module and module.db then
                            module.db.profile.class.trackExplosiveTraps = self:GetValue()
                        end
                    end
                },
                trackBindingShot = {
                    key = 'vmodules.vuipositionofpower.class.trackBindingShot',
                    type = 'checkbox',
                    label = 'Track Binding Shot',
                    tooltip = 'Track Binding Shot positioning',
                    column = 4,
                    order = 3,
                    callback = function(self)
                        if module and module.db then
                            module.db.profile.class.trackBindingShot = self:GetValue()
                        end
                    end
                },
            })
        else
            -- Generic class settings for other classes
            table.insert(Layout.layout.rows, {
                classSettings = {
                    type = 'label',
                    label = module and "Class-specific settings for " .. playerClass .. " will be loaded when available" or "Class-specific settings will be available when the module is loaded",
                    column = 12,
                    order = 1,
                }
            })
        end
    else
        -- Fallback if class detection fails
        table.insert(Layout.layout.rows, {
            classSettings = {
                type = 'label',
                label = module and "Class-specific settings are available when the module is loaded" or "Class-specific settings will be available when the module is loaded",
                column = 12,
                order = 1,
            }
        })
    end
    
    -- Controls
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Controls'
        },
    })
    
    table.insert(Layout.layout.rows, {
        openConfig = {
            type = 'button',
            label = 'Configure Positions',
            tooltip = 'Open the position configuration panel',
            column = 6,
            order = 1,
            callback = function()
                if module and module.OpenOptions then
                    module:OpenOptions()
                end
            end
        },
        testMode = {
            type = 'button',
            label = 'Test Mode',
            tooltip = 'Toggle test mode to preview position indicators',
            column = 6,
            order = 2,
            callback = function()
                if module and module.ToggleTestMode then
                    module:ToggleTestMode()
                end
            end
        },
    })
end

return Layout 