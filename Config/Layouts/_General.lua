local Layout = VUI:NewModule('Config.Layout.General')

function Layout:OnEnable()
    -- Database
    local db = VUI.db

    -- Data
    local Themes = VUI:GetModule("Data.Themes")
    local Fonts = VUI:GetModule("Data.Fonts")
    local Textures = VUI:GetModule("Data.Textures")

    -- Layout
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        database = db.profile.general,
        rows = {
            {
                header = {
                    type = 'header',
                    label = 'General'
                }
            },
            {
                theme = {
                    key = 'theme',
                    type = 'dropdown',
                    label = 'Theme',
                    options = Themes.data,
                    column = 5,
                    order = 1,
                    onChange = function(self, newTheme)
                        -- Notify modules about theme change
                        if VUI.SendCallback then
                            VUI:SendCallback("Theme_Changed", newTheme)
                        end
                        
                        -- Notify skin modules
                        if VUI.NotifySkinModules then
                            VUI:NotifySkinModules()
                        end
                        
                        -- Update UI
                        ReloadUI()
                    end
                },
                font = {
                    key = 'font',
                    type = 'dropdown',
                    label = 'Font',
                    options = Fonts.data,
                    column = 5,
                    order = 2
                },
                --[[texture = {
          key = 'texture',
          type = 'dropdown',
          label = 'Texture',
          options = Textures.data,
          column = 4,
          order = 3
        }]]
            },
            {
                color = {
                    key = 'color',
                    type = 'color',
                    label = 'Custom Color',
                    column = 3,
                    update = function() end,
                    cancel = function() end
                }
            },
            {
                header = {
                    type = 'header',
                    label = 'Automation'
                },
            },
            {
                sell    = {
                    key = 'automation.sell',
                    type = 'checkbox',
                    label = 'Sell',
                    tooltip = 'Sells grey items automatically',
                    column = 3,
                    order = 1
                },
                delete  = {
                    key = 'automation.delete',
                    type = 'checkbox',
                    label = 'Delete',
                    tooltip = 'Inserts "DELETE" when deleting Rare+ items',
                    column = 3,
                    order = 2
                },
                duel    = {
                    key = 'automation.decline',
                    type = 'checkbox',
                    label = 'Duel',
                    tooltip = 'Declines duels automatically',
                    column = 3,
                    order = 3
                },
                release = {
                    key = 'automation.release',
                    type = 'checkbox',
                    label = 'Release',
                    tooltip = 'Release automatically when you died',
                    column = 3,
                    order = 4
                }
            },
            {
                resurrect = {
                    key = 'automation.resurrect',
                    type = 'checkbox',
                    label = 'Resurrect',
                    tooltip = 'Accept ress automatically',
                    column = 3,
                    order = 1
                },
                invite = {
                    key = 'automation.invite',
                    type = 'checkbox',
                    label = 'Invite',
                    tooltip = 'Accept group invite automatically',
                    column = 3,
                    order = 2
                },
                cinematic = {
                    key = 'automation.cinematic',
                    type = 'checkbox',
                    label = 'Cinematic',
                    tooltip = 'Skip cinematics automatically',
                    column = 3,
                    order = 3
                },
            },
            {
                repair = {
                    key = 'automation.repair',
                    type = 'dropdown',
                    label = 'Repair',
                    options = {
                        { value = 'Default', text = 'Default' },
                        { value = 'Player', text = 'Repair automatically' },
                        { value = 'Guild', text = 'Repair automatically using guild bank' }
                    },
                    initialValue = 1,
                    column = 9,
                    order = 1
                }
            },
            {
                header = {
                    type = 'header',
                    label = 'Display'
                },
            },
            {
                items = {
                    key = 'display.ilvl',
                    type = 'checkbox',
                    label = 'Item Info',
                    tooltip = 'Display item information on items in bags/bank and character/inspect frame',
                    column = 3,
                    order = 1
                },
                fps = {
                    key = 'display.fps',
                    type = 'checkbox',
                    label = 'FPS',
                    tooltip = 'Show current FPS',
                    column = 2,
                    order = 2
                },
                ms = {
                    key = 'display.ms',
                    type = 'checkbox',
                    label = 'MS',
                    tooltip = 'Show current ping',
                    column = 2,
                    order = 3
                },
                movementSpeed = {
                    key = 'display.movementSpeed',
                    type = 'checkbox',
                    label = 'Movement Speed',
                    tooltip = 'Show current movement speed',
                    column = 3,
                    order = 4
                },
            },
            {
                header = {
                    type = 'header',
                    label = 'Player Stats'
                },
            },
            {
                playerStatsEnabled = {
                    key = 'playerstats.enabled',
                    type = 'checkbox',
                    label = 'Enable Player Stats',
                    tooltip = 'Show a frame with detailed player statistics like Crit, Haste, Mastery, etc.',
                    column = 3,
                    order = 1
                },
                playerStatsCombatOnly = {
                    key = 'playerstats.combatOnly',
                    type = 'checkbox',
                    label = 'Combat Only',
                    tooltip = 'Only show the Player Stats frame while in combat',
                    column = 3,
                    order = 2
                },
                playerStatsTransparency = {
                    key = 'playerstats.transparency',
                    type = 'slider',
                    label = 'Background Transparency',
                    tooltip = 'Adjust the background transparency of the Player Stats frame',
                    min = 0,
                    max = 1,
                    step = 0.05,
                    column = 4,
                    order = 3
                },
            },
            {
                afkscreen = {
                    key = 'cosmetic.afkscreen',
                    type = 'checkbox',
                    label = 'AFK Screen',
                    tooltip = 'Display a nice screen while you are AFK',
                    column = 3,
                    order = 1
                },
                talkhead = {
                    key = 'cosmetic.talkinghead',
                    type = 'checkbox',
                    label = 'Talkinghead',
                    tooltip = 'Show Talkinghead frame',
                    column = 3,
                    order = 2
                },
                Errors = {
                    key = 'cosmetic.errors',
                    type = 'checkbox',
                    label = 'Error Messages',
                    tooltip = 'Display Error Messages (Out of Range etc.)',
                    column = 3,
                    order = 3
                },
            }
        },
    }
end