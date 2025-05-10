local Layout = VUI:NewModule('Config.Layout.VUICD')

function Layout:OnEnable()
    -- Database
    local db = VUI.db
    
    -- Module reference
    local VUICD = VUI:GetModule("VUICD")
    
    -- Layout
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        database = db.profile,
        rows = {
            {
                header = {
                    type = 'header',
                    label = 'VUI Party Cooldown Tracker',
                    description = 'Track and display party member cooldowns'
                },
            },
            {
                enabled = {
                    key = 'vmodules.vuicd.enabled',
                    type = 'checkbox',
                    label = 'Enable Cooldown Tracker',
                    tooltip = 'Enable or disable the party cooldown tracker',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        if VUICD and VUICD.db then
                            VUICD.db.enable = self:GetValue()
                            VUICD:ToggleModule()
                        end
                    end
                },
                configButton = {
                    type = 'button',
                    text = 'Open Detailed Settings',
                    onClick = function()
                        if VUICD and VUICD.RegisterOptions then
                            VUICD:RegisterOptions()
                            if LibStub("AceConfigDialog-3.0") then
                                LibStub("AceConfigDialog-3.0"):Open("VUICD")
                            end
                        end
                    end,
                    disabled = function() 
                        return not VUICD or not VUICD.db or not VUICD.db.enable
                    end,
                    column = 4,
                    order = 2
                },
            },
            {
                header = {
                    type = 'header',
                    label = 'Appearance Settings'
                },
            },
            {
                useThemeColors = {
                    key = 'vmodules.vuicd.useThemeColors',
                    type = 'checkbox',
                    label = 'Use VUI Theme Colors',
                    tooltip = 'Apply the current VUI theme colors to all elements',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        if VUICD and VUICD.DB then
                            VUICD.DB.profile.useThemeColors = self:GetValue()
                            if VUICD.UpdateAppearance then
                                VUICD:UpdateAppearance()
                            end
                        end
                    end
                },
                iconSize = {
                    key = 'vmodules.vuicd.iconSize',
                    type = 'slider',
                    label = 'Icon Size',
                    tooltip = 'Size of cooldown icons',
                    min = 16,
                    max = 64,
                    step = 1,
                    column = 4,
                    order = 2,
                    callback = function(self)
                        if VUICD and VUICD.DB then
                            VUICD.DB.profile.iconSize = self:GetValue()
                            if VUICD.UpdateAppearance then
                                VUICD:UpdateAppearance()
                            end
                        end
                    end
                },
            },
            {
                information = {
                    type = 'description',
                    text = "The party cooldown tracker provides detailed information about your party members' cooldowns.\n\n" ..
                           "You can view cooldowns as bars, icons, or text, with customizable filters for each spell type.\n\n" ..
                           "Use the 'Open Detailed Settings' button above for advanced configuration options.",
                    column = 6,
                    order = 1
                }
            }
        }
    }
end