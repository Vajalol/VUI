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
            -- SECTION 1: Theme & Visual Settings
            {
                header = {
                    type = 'header',
                    label = 'Theme Settings'
                }
            },
            {
                theme = {
                    key = 'theme',
                    type = 'dropdown',
                    label = 'Theme',
                    tooltip = 'Select the visual theme for VUI',
                    options = Themes.data,
                    column = 6,
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
                    tooltip = 'Select the font used throughout the UI',
                    options = Fonts.data,
                    column = 6,
                    order = 2
                }
            },
            {
                color = {
                    key = 'color',
                    type = 'color',
                    label = 'Custom Color',
                    tooltip = 'Set a custom color for theme elements',
                    column = 6,
                    order = 1,
                    update = function() end,
                    cancel = function() end
                },
                texture = {
                    key = 'texture',
                    type = 'dropdown',
                    label = 'Texture',
                    tooltip = 'Select the texture style used for bars and panels',
                    options = Textures.data,
                    column = 6,
                    order = 2
                }
            },
            
            -- SECTION 2: Automation Settings
            {
                header = {
                    type = 'header',
                    label = 'Automation'
                },
            },
            {
                sell = {
                    key = 'automation.sell',
                    type = 'checkbox',
                    label = 'Auto-Sell Grey Items',
                    tooltip = 'Automatically sell grey (poor quality) items when visiting a vendor',
                    column = 4,
                    order = 1
                },
                delete = {
                    key = 'automation.delete',
                    type = 'checkbox',
                    label = 'Confirm Deletions',
                    tooltip = 'Automatically insert "DELETE" when deleting Rare+ items',
                    column = 4,
                    order = 2
                },
                duel = {
                    key = 'automation.decline',
                    type = 'checkbox',
                    label = 'Decline Duels',
                    tooltip = 'Automatically decline duel requests',
                    column = 4,
                    order = 3
                }
            },
            {
                release = {
                    key = 'automation.release',
                    type = 'checkbox',
                    label = 'Auto-Release',
                    tooltip = 'Automatically release when you die',
                    column = 4,
                    order = 1
                },
                resurrect = {
                    key = 'automation.resurrect',
                    type = 'checkbox',
                    label = 'Accept Resurrections',
                    tooltip = 'Automatically accept resurrection requests',
                    column = 4,
                    order = 2
                },
                invite = {
                    key = 'automation.invite',
                    type = 'checkbox',
                    label = 'Accept Group Invites',
                    tooltip = 'Automatically accept group invitations',
                    column = 4,
                    order = 3
                }
            },
            {
                cinematic = {
                    key = 'automation.cinematic',
                    type = 'checkbox',
                    label = 'Skip Cinematics',
                    tooltip = 'Automatically skip game cinematics',
                    column = 6,
                    order = 1
                },
                repair = {
                    key = 'automation.repair',
                    type = 'dropdown',
                    label = 'Auto-Repair',
                    tooltip = 'Automatically repair equipment at vendors',
                    options = {
                        { value = 'Default', text = 'Disabled' },
                        { value = 'Player', text = 'Use Personal Funds' },
                        { value = 'Guild', text = 'Use Guild Bank Funds' }
                    },
                    column = 6,
                    order = 2
                }
            },
            
            -- SECTION 3: Display Settings
            {
                header = {
                    type = 'header',
                    label = 'Display Information'
                },
            },
            {
                items = {
                    key = 'display.ilvl',
                    type = 'checkbox',
                    label = 'Item Information',
                    tooltip = 'Display item level and other information on items in bags/bank and character/inspect frames',
                    column = 4,
                    order = 1
                },
                fps = {
                    key = 'display.fps',
                    type = 'checkbox',
                    label = 'Show FPS',
                    tooltip = 'Display your current frames per second',
                    column = 4,
                    order = 2
                },
                ms = {
                    key = 'display.ms',
                    type = 'checkbox',
                    label = 'Show Latency',
                    tooltip = 'Display your current network latency in milliseconds',
                    column = 4,
                    order = 3
                }
            },
            {
                movementSpeed = {
                    key = 'display.movementSpeed',
                    type = 'checkbox',
                    label = 'Show Movement Speed',
                    tooltip = 'Display your current movement speed percentage',
                    column = 4,
                    order = 1
                }
            },
            
            -- Continue with the rest of the file...
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
                    column = 4,
                    order = 1
                },
                playerStatsCombatOnly = {
                    key = 'playerstats.combatOnly',
                    type = 'checkbox',
                    label = 'Combat Only',
                    tooltip = 'Only show the Player Stats frame while in combat',
                    column = 4,
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
                    column = 4,
                    order = 1
                },
                talkhead = {
                    key = 'cosmetic.talkinghead',
                    type = 'checkbox',
                    label = 'Talkinghead',
                    tooltip = 'Show Talkinghead frame',
                    column = 4,
                    order = 2
                },
                Errors = {
                    key = 'cosmetic.errors',
                    type = 'checkbox',
                    label = 'Error Messages',
                    tooltip = 'Display Error Messages (Out of Range etc.)',
                    column = 4,
                    order = 3
                },
            }
        },
    }
end