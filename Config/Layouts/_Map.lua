local Layout = VUI:NewModule('Config.Layout.Map')

function Layout:OnEnable()
    -- Database
    local db = VUI.db

    -- Layout
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        database = db.profile.maps,
        rows = {
            -- SECTION 1: Main Map Settings
            {
                header = {
                    type = 'header',
                    label = 'World Map Settings'
                }
            },
            {
                opacity = {
                    key = 'opacity',
                    type = 'slider',
                    label = 'Map Opacity',
                    tooltip = 'Adjust the opacity of the world map',
                    min = 0,
                    max = 1,
                    step = 0.05, 
                    column = 6,
                    order = 1
                },
                scale = {
                    key = 'scale',
                    type = 'slider',
                    label = 'Map Scale',
                    tooltip = 'Adjust the scale of the world map',
                    min = 0.5,
                    max = 2,
                    step = 0.05,
                    column = 6,
                    order = 2
                }
            },
            
            -- SECTION 2: Minimap Settings
            {
                header = {
                    type = 'header',
                    label = 'Minimap Settings'
                }
            },
            {
                enableMinimap = {
                    key = 'minimap.enabled',
                    type = 'checkbox',
                    label = 'Enable VUI Minimap',
                    tooltip = 'Use the enhanced VUI minimap instead of the default one',
                    column = 4,
                    order = 1
                },
                clock = {
                    key = 'minimap.clock',
                    type = 'checkbox',
                    label = 'Show Clock',
                    tooltip = 'Display the time clock on the minimap',
                    column = 4,
                    order = 2
                },
                coords = {
                    key = 'minimap.coords',
                    type = 'checkbox',
                    label = 'Show Coordinates',
                    tooltip = 'Display your current coordinates on the minimap',
                    column = 4,
                    order = 3
                }
            },
            {
                zone = {
                    key = 'minimap.zone',
                    type = 'checkbox',
                    label = 'Show Zone Text',
                    tooltip = 'Display the name of your current zone on the minimap',
                    column = 4,
                    order = 1
                },
                difficulty = {
                    key = 'minimap.difficulty',
                    type = 'checkbox',
                    label = 'Show Instance Difficulty',
                    tooltip = 'Display the current instance difficulty indicator on the minimap',
                    column = 4,
                    order = 2
                },
                calendar = {
                    key = 'minimap.calendar',
                    type = 'checkbox',
                    label = 'Show Calendar Button',
                    tooltip = 'Display the calendar button on the minimap',
                    column = 4,
                    order = 3
                }
            },
            
            -- SECTION 3: Visual Effects
            {
                header = {
                    type = 'header',
                    label = 'Visual Effects'
                }
            },
            {
                pulse = {
                    key = 'pulsingBorder',
                    type = 'checkbox',
                    label = 'Enable Pulsing Border',
                    tooltip = 'Add a subtle pulsing glow border around the minimap using theme colors',
                    column = 6,
                    order = 1
                },
                round = {
                    key = 'minimap.round',
                    type = 'checkbox',
                    label = 'Round Minimap',
                    tooltip = 'Make the minimap perfectly round instead of square',
                    column = 6,
                    order = 2
                }
            },
            
            -- SECTION 4: Advanced Settings
            {
                header = {
                    type = 'header',
                    label = 'Advanced Settings'
                }
            },
            {
                buttonSize = {
                    key = 'minimap.buttonSize',
                    type = 'slider',
                    label = 'Button Size',
                    tooltip = 'Adjust the size of buttons attached to the minimap',
                    min = 16,
                    max = 40,
                    step = 1,
                    column = 8,
                    order = 1
                }
            }
        }
    }
end
