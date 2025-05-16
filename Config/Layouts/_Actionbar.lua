local Layout = VUI:NewModule('Config.Layout.Actionbar')

function Layout:OnEnable()
    -- Database
    local db = VUI.db

    -- Layout
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        database = db.profile.actionbar,
        rows = {
            -- SECTION 1: Main Settings
            {
                header = {
                    type = 'header',
                    label = 'Action Bars'
                },
            },
            
            -- SECTION 2: Button Settings
            {
                header = {
                    type = 'header',
                    label = 'Button Settings'
                },
            },
            {
                hotkeys = {
                    key = 'buttons.key',
                    type = 'checkbox',
                    label = 'Show Hotkeys',
                    tooltip = 'Display keybinding text on action buttons',
                    column = 4,
                    order = 1
                },
                macros = {
                    key = 'buttons.macro',
                    type = 'checkbox',
                    label = 'Show Macro Names',
                    tooltip = 'Display macro names on action buttons',
                    column = 4,
                    order = 2
                },
                flash = {
                    key = 'buttons.flash',
                    type = 'checkbox',
                    label = 'Flash Animation',
                    tooltip = 'Show flash animation when pressing action buttons',
                    column = 4,
                    order = 3
                }
            },
            {
                range = {
                    key = 'buttons.range',
                    type = 'checkbox',
                    label = 'Range Coloring',
                    tooltip = 'Show abilities in red when the target is out of range',
                    column = 6,
                    order = 1
                },
                size = {
                    key = 'buttons.size',
                    type = 'slider',
                    label = 'Text Size',
                    tooltip = 'Adjust the size of text on action buttons',
                    min = 5,
                    max = 20,
                    step = 1, 
                    column = 6,
                    order = 2
                },
            },
            
            -- SECTION 3: Visual Effects
            {
                header = {
                    type = 'header',
                    label = 'Visual Effects'
                },
            },
            {
                pulseEnabled = {
                    key = 'pulseEffects.enabled',
                    type = 'checkbox',
                    label = 'Enable Pulse Effects',
                    tooltip = 'Adds a subtle pulsing glow to action buttons using theme colors',
                    column = 6,
                    order = 1
                },
                pulseIntensity = {
                    key = 'pulseEffects.intensity',
                    type = 'slider',
                    label = 'Pulse Intensity',
                    tooltip = 'Adjust the intensity of the pulsing effect',
                    min = 0.01,
                    max = 0.15,
                    step = 0.01,
                    column = 6,
                    order = 2
                },
            },
            
            -- SECTION 4: Menu Settings
            {
                header = {
                    type = 'header',
                    label = 'Menu Settings'
                },
            },
            {
                bagbar = {
                    key = 'menu.bagbar',
                    type = 'dropdown',
                    label = 'Bag Buttons',
                    tooltip = 'Control the visibility of the bag buttons',
                    column = 6,
                    order = 1,
                    options = {
                        { value = 'show', text = 'Always Show' },
                        { value = 'mouse_over', text = 'Show on Mouseover' },
                        { value = 'hide', text = 'Hide Completely' }
                    }
                },
                micromenu = {
                    key = 'menu.micromenu',
                    type = 'dropdown',
                    label = 'Micro Menu',
                    tooltip = 'Control the visibility of the micro menu buttons',
                    column = 6,
                    order = 2,
                    options = {
                        { value = 'show', text = 'Always Show' },
                        { value = 'mouse_over', text = 'Show on Mouseover' },
                        { value = 'hide', text = 'Hide Completely' }
                    },
                }
            },
            
            -- SECTION 5: Mouseover Settings
            {
                header = {
                    type = 'header',
                    label = 'Show on Mouseover'
                },
            },
            {
                mouseoverLabel = {
                    type = 'label',
                    label = 'Enable mouseover visibility for specific action bars',
                    column = 12,
                    order = 1
                },
            },
            {
                actionbar1 = {
                    key = 'bars.bar1',
                    type = 'checkbox',
                    label = 'Bar 1',
                    tooltip = 'Only show Bar 1 when mouse is over it',
                    column = 3,
                    order = 1
                },
                actionbar2 = {
                    key = 'bars.bar2',
                    type = 'checkbox',
                    label = 'Bar 2',
                    tooltip = 'Only show Bar 2 when mouse is over it',
                    column = 3,
                    order = 2
                },
                actionbar3 = {
                    key = 'bars.bar3',
                    type = 'checkbox',
                    label = 'Bar 3',
                    tooltip = 'Only show Bar 3 when mouse is over it',
                    column = 3,
                    order = 3
                },
                actionbar4 = {
                    key = 'bars.bar4',
                    type = 'checkbox',
                    label = 'Bar 4',
                    tooltip = 'Only show Bar 4 when mouse is over it',
                    column = 3,
                    order = 4
                }
            },
            {
                actionbar5 = {
                    key = 'bars.bar5',
                    type = 'checkbox',
                    label = 'Bar 5',
                    tooltip = 'Only show Bar 5 when mouse is over it',
                    column = 3,
                    order = 1
                },
                actionbar6 = {
                    key = 'bars.bar6',
                    type = 'checkbox',
                    label = 'Bar 6',
                    tooltip = 'Only show Bar 6 when mouse is over it',
                    column = 3,
                    order = 2
                },
                actionbar7 = {
                    key = 'bars.bar7',
                    type = 'checkbox',
                    label = 'Bar 7',
                    tooltip = 'Only show Bar 7 when mouse is over it',
                    column = 3,
                    order = 3
                },
                actionbar8 = {
                    key = 'bars.bar8',
                    type = 'checkbox',
                    label = 'Bar 8',
                    tooltip = 'Only show Bar 8 when mouse is over it',
                    column = 3,
                    order = 4
                }
            },
            {
                petbar = {
                    key = 'bars.petbar',
                    type = 'checkbox',
                    label = 'Pet Bar',
                    tooltip = 'Only show Pet Bar when mouse is over it',
                    column = 4,
                    order = 1
                },
                stancebar = {
                    key = 'bars.stancebar',
                    type = 'checkbox',
                    label = 'Stance Bar',
                    tooltip = 'Only show Stance Bar when mouse is over it',
                    column = 4,
                    order = 2
                },
            }
        }
    }
end
