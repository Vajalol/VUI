local Layout = VUI:NewModule('Config.Layout.Buffs')

function Layout:OnEnable()
    -- Database
    local db = VUI.db

    -- Layout
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        database = db.profile,
        rows = {
            -- SECTION 1: Main Settings
            {
                header = {
                    type = 'header',
                    label = 'Buff & Debuff Settings'
                },
            },
            {
                collapse = {
                    key = 'unitframes.buffs.collapse',
                    type = 'checkbox',
                    label = 'Show Collapse Button',
                    tooltip = 'Display the collapse button on the player buff frame to minimize it',
                    column = 6,
                    order = 1
                },
                -- Space for additional main settings if needed
            },
            
            -- SECTION 2: Size Settings
            {
                header = {
                    type = 'header',
                    label = 'Size Settings'
                },
            },
            {
                buffsize = {
                    key = 'unitframes.buffs.size',
                    type = 'slider',
                    label = 'Buff Icon Size',
                    tooltip = 'Adjust the size of buff icons on unitframes',
                    min = 10,
                    max = 50,
                    step = 1,
                    column = 6,
                    order = 1
                },
                debuffsize = {
                    key = 'unitframes.debuffs.size',
                    type = 'slider',
                    label = 'Debuff Icon Size',
                    tooltip = 'Adjust the size of debuff icons on unitframes',
                    min = 10,
                    max = 50,
                    step = 1,
                    column = 6,
                    order = 2
                }
            }
        },
    }
end
