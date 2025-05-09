local Layout = VUI:NewModule('Config.Layout.Tooltip')

function Layout:OnEnable()
    -- Database
    local db = VUI.db

    -- Layout
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        database = db.profile.tooltip,
        rows = {
            {
                header = {
                    type = 'header',
                    label = 'Tooltip'
                }
            },
            {
                style = {
                    key = 'style',
                    label = 'Style',
                    type = 'dropdown',
                    options = {
                        { value = 'Default', text = 'Default' },
                        { value = 'Custom', text = 'Custom' }
                    },
                    initialValue = 1,
                    column = 5,
                    order = 1
                }
            },
            {
                header = {
                    type = 'header',
                    label = 'Appearance'
                },
            },
            {
                mouseanchor = {
                    key = 'mouseanchor',
                    type = 'checkbox',
                    label = 'Mouseanchor',
                    tooltip = 'Attach tooltip to mouse cursor',
                    column = 4,
                    order = 1
                },
                lifeontop = {
                    key = 'lifeontop',
                    type = 'checkbox',
                    label = 'Life on Top',
                    tooltip = 'Show HP bar in tooltip on top',
                    column = 4,
                    order = 2
                },
                hideincombat = {
                    key = 'hideincombat',
                    type = 'checkbox',
                    tooltip = 'Hide tooltips while in combat',
                    label = 'Hide in Combat',
                    column = 4,
                    order = 3
                }
            },
            {
                header = {
                    type = 'header',
                    label = 'Unit Info'
                },
            },
            {
                targetInfo = {
                    key = 'targetInfo',
                    type = 'checkbox',
                    label = 'Target Info',
                    tooltip = 'Show current target of the unit',
                    column = 4,
                    order = 1
                },
                targetedInfo = {
                    key = 'targetedInfo',
                    type = 'checkbox',
                    label = 'Targeted Info',
                    tooltip = 'When in a raid group display if anyone in your raid is targeting the current tooltip unit',
                    column = 8,
                    order = 2
                }
            },
            {
                playerTitles = {
                    key = 'playerTitles',
                    type = 'checkbox',
                    label = 'Player Titles',
                    tooltip = 'Display player titles',
                    column = 4,
                    order = 1
                },
                guildRanks = {
                    key = 'guildRanks',
                    type = 'checkbox',
                    label = 'Guild Ranks',
                    tooltip = 'Display guild ranks if a unit is guilded',
                    column = 4,
                    order = 2
                },
                roleIcon = {
                    key = 'roleIcon',
                    type = 'checkbox',
                    label = 'Role Info',
                    tooltip = 'Display the unit role and role icon (tank, dps, heal) in the tooltip',
                    column = 4,
                    order = 3
                }
            },
            {
                gender = {
                    key = 'gender',
                    type = 'checkbox',
                    label = 'Gender',
                    tooltip = 'Display the gender of players',
                    column = 4,
                    order = 1
                },
                mountInfo = {
                    key = 'mountInfo',
                    type = 'checkbox',
                    label = 'Current Mount',
                    tooltip = 'Display current mount the unit is riding',
                    column = 4,
                    order = 2
                },
                inspectInfo = {
                    key = 'inspectInfo',
                    type = 'checkbox',
                    label = 'Inspect Data',
                    tooltip = 'Display the item level of the unit',
                    column = 4,
                    order = 3
                }
            }
        },
    }
end
