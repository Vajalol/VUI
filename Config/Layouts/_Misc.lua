local Layout = VUI:NewModule('Config.Layout.Misc')

function Layout:OnEnable()
    -- Database
    local db = VUI.db

    -- Components
    local CvarsBrowser = VUI:GetModule("Config.Components.CvarsBrowser")

    -- Layout
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        database = db.profile.misc,
        rows = {
            {
                header = {
                    type = 'header',
                    label = 'Misc'
                }
            },
            {
                cvars = {
                    type = 'button',
                    text = 'CVars Browser',
                    onClick = function()
                        CvarsBrowser.Show()
                    end,
                    column = 3,
                    order = 3
                }
            },
            {
                header = {
                    type = 'header',
                    label = 'General'
                }
            },
            {
                interrupt = {
                    key = 'interrupt',
                    type = 'checkbox',
                    label = 'Interrupt',
                    tooltip = 'Announce successful interrupts party',
                    column = 3,
                    order = 1
                },
                menubutton = {
                    key = 'menubutton',
                    type = 'checkbox',
                    label = 'Menu Button',
                    tooltip = 'Show VUI Button on ESC-Menu',
                    column = 3,
                    order = 2
                }
            },
            {
                header = {
                    type = 'header',
                    label = 'PvP'
                }
            },
            {
                safequeue = {
                    key = 'safequeue',
                    type = 'checkbox',
                    label = 'SafeQueue',
                    tooltip = 'Show time left to join and remove leave-button on queuepop-window',
                    column = 3,
                    order = 1
                },
                tabbinder = {
                    key = 'tabbinder',
                    type = 'checkbox',
                    label = 'Tab Binder',
                    tooltip = 'Only target players with TAB in PVP-Combat',
                    column = 3,
                    order = 1
                },
                dampening = {
                    key = 'dampening',
                    type = 'checkbox',
                    label = 'Dampening',
                    tooltip = 'Shows dampening right below the arena timer',
                    column = 3,
                    order = 1
                },
                surrender = {
                    key = 'surrender',
                    type = 'checkbox',
                    label = 'Surrender',
                    tooltip = 'Allows you to surrender by typing /gg',
                    column = 3,
                    order = 1
                },
            },
            {
                losecontrol = {
                    key = 'losecontrol',
                    type = 'checkbox',
                    label = 'LoseControl',
                    tooltip = 'More transparent Loss of Control Alert frame',
                    column = 3,
                    order = 1
                },
            },
            {
                header = {
                    type = 'header',
                    label = 'Hide Frames'
                },
            },
            {
                repbar = {
                    key = 'repbar',
                    type = 'checkbox',
                    label = 'XP/Rep/Honor Bar',
                    tooltip = 'Hide the XP/Rep/Honor Bar',
                    column = 4,
                    order = 1
                },
                dragonflying = {
                    key = 'dragonflying',
                    type = 'checkbox',
                    label = 'Dragonflying Wings',
                    tooltip = 'Hide the Dragonflying Bar Wings',
                    column = 4,
                    order = 2
                },
            },
            {
                header = {
                    type = 'header',
                    label = 'UI Scale'
                },
            },
            {
                uiscaleEnabled = {
                    key = 'uiscale.enabled',
                    type = 'checkbox',
                    label = 'Enable UI Scale',
                    tooltip = 'Enable UI Scale adjustment to optimize your interface for your screen resolution',
                    column = 4,
                    order = 1
                },
            },
            {
                uiscaleValue = {
                    key = 'uiscale.scale',
                    type = 'slider',
                    label = 'UI Scale',
                    tooltip = 'Adjust the UI Scale (between 0.5 and 1.0)',
                    min = 0.5,
                    max = 1.0,
                    step = 0.01,
                    column = 6,
                    order = 1,
                    disabled = function() return not db.profile.misc.uiscale.enabled end,
                    onChange = function(self, value)
                        local UIScaleModule = VUI:GetModule("Misc.UIScale")
                        if UIScaleModule then
                            UIScaleModule:ApplyScale(value)
                        end
                    end
                },
                uiscaleAuto = {
                    type = 'button',
                    text = 'Auto Scale',
                    tooltip = 'Automatically calculate optimal UI scale based on your screen resolution',
                    column = 3,
                    order = 2,
                    disabled = function() return not db.profile.misc.uiscale.enabled end,
                    onClick = function()
                        local UIScaleModule = VUI:GetModule("Misc.UIScale")
                        if UIScaleModule then
                            local autoScale = UIScaleModule:CalculateAutoScale()
                            UIScaleModule:ApplyScale(autoScale)
                            -- Refresh the slider value
                            VUI:GetModule("Config.Gui"):Refresh()
                        end
                    end
                },
                uiscaleReset = {
                    type = 'button',
                    text = 'Reset Scale',
                    tooltip = 'Reset to default UI scale (1.0)',
                    column = 3,
                    order = 3,
                    disabled = function() return not db.profile.misc.uiscale.enabled end,
                    onClick = function()
                        local UIScaleModule = VUI:GetModule("Misc.UIScale")
                        if UIScaleModule then
                            UIScaleModule:ResetScale()
                            -- Refresh the slider value
                            VUI:GetModule("Config.Gui"):Refresh()
                        end
                    end
                },
            }
        },
    }
end
