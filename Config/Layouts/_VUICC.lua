local Layout = VUI:NewModule('Config.Layout.VUICC')

function Layout:OnEnable()
    -- Database
    local db = VUI.db
    
    -- Module reference
    local VUICC = VUI:GetModule("VUICC")
    
    -- Layout
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        database = db.profile,
        rows = {
            {
                header = {
                    type = 'header',
                    label = 'VUI Cooldown Count',
                    description = 'Cooldown timer display settings'
                },
            },
            {
                enabled = {
                    key = 'vmodules.vuicc.enabled',
                    type = 'checkbox',
                    label = 'Enable Cooldown Count',
                    tooltip = 'Enable cooldown text on action buttons and items',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        if VUICC and VUICC.db then
                            VUICC.db.enabled = self:GetValue()
                            -- Apply changes
                            if VUICC.UpdateSettings then
                                VUICC:UpdateSettings()
                            end
                        end
                    end
                },
                disableBlizzardCooldownText = {
                    key = 'vmodules.vuicc.disableBlizzardCooldownText',
                    type = 'checkbox',
                    label = 'Disable Blizzard Cooldown Text',
                    tooltip = "Hide Blizzard's built-in cooldown text to avoid conflicts (requires UI reload)",
                    column = 4,
                    order = 2,
                    callback = function(self)
                        if VUICC and VUICC.db then
                            VUICC.db.disableBlizzardCooldownText = self:GetValue()
                            StaticPopup_Show("VUI_RELOAD_UI")
                        end
                    end
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
                    key = 'vmodules.vuicc.useThemeColors',
                    type = 'checkbox',
                    label = 'Use VUI Theme Colors',
                    tooltip = 'Apply the current VUI theme colors to cooldown text',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        if VUICC and VUICC.db then
                            VUICC.db.useThemeColors = self:GetValue()
                            if VUICC.UpdateSettings then
                                VUICC:UpdateSettings()
                            end
                        end
                    end
                },
                useClassColors = {
                    key = 'vmodules.vuicc.useClassColors',
                    type = 'checkbox',
                    label = 'Use Class Colors',
                    tooltip = 'Color cooldown text based on your class color',
                    column = 4,
                    order = 2,
                    callback = function(self)
                        if VUICC and VUICC.db then
                            VUICC.db.useClassColors = self:GetValue()
                            if VUICC.UpdateSettings then
                                VUICC:UpdateSettings()
                            end
                        end
                    end
                },
            },
            {
                fontSize = {
                    key = 'vmodules.vuicc.fontSize',
                    type = 'slider',
                    label = 'Font Size',
                    tooltip = 'Size of the cooldown text',
                    min = 8,
                    max = 24,
                    step = 1,
                    column = 6,
                    order = 1,
                    callback = function(self)
                        if VUICC and VUICC.db then
                            VUICC.db.fontSize = self:GetValue()
                            if VUICC.UpdateSettings then
                                VUICC:UpdateSettings()
                            end
                        end
                    end
                },
                minScale = {
                    key = 'vmodules.vuicc.minScale',
                    type = 'slider',
                    label = 'Minimum Scale',
                    tooltip = 'Minimum scale for cooldown text on small icons',
                    min = 0.1,
                    max = 1.0,
                    step = 0.05,
                    column = 6,
                    order = 2,
                    callback = function(self)
                        if VUICC and VUICC.db then
                            VUICC.db.minScale = self:GetValue()
                            if VUICC.UpdateSettings then
                                VUICC:UpdateSettings()
                            end
                        end
                    end
                },
            },
            {
                header = {
                    type = 'header',
                    label = 'Display Settings'
                },
            },
            {
                minDuration = {
                    key = 'vmodules.vuicc.minDuration',
                    type = 'slider',
                    label = 'Minimum Duration',
                    tooltip = 'Minimum cooldown duration to show text (in seconds)',
                    min = 0,
                    max = 10,
                    step = 0.5,
                    column = 6,
                    order = 1,
                    callback = function(self)
                        if VUICC and VUICC.db then
                            VUICC.db.minDuration = self:GetValue()
                            if VUICC.UpdateSettings then
                                VUICC:UpdateSettings()
                            end
                        end
                    end
                },
                mmssThreshold = {
                    key = 'vmodules.vuicc.mmssThreshold',
                    type = 'slider',
                    label = 'MM:SS Threshold',
                    tooltip = 'Show minutes and seconds when cooldown exceeds this value (in seconds)',
                    min = 60,
                    max = 300,
                    step = 10,
                    column = 6,
                    order = 2,
                    callback = function(self)
                        if VUICC and VUICC.db then
                            VUICC.db.mmssThreshold = self:GetValue()
                            if VUICC.UpdateSettings then
                                VUICC:UpdateSettings()
                            end
                        end
                    end
                },
            },
            {
                effect = {
                    key = 'vmodules.vuicc.effect',
                    type = 'dropdown',
                    label = 'Finish Effect',
                    tooltip = 'Visual effect when cooldown completes',
                    options = {
                        { text = 'None', value = 'NONE' },
                        { text = 'Pulse', value = 'PULSE' },
                        { text = 'Shine', value = 'SHINE' },
                        { text = 'Flare', value = 'FLARE' },
                        { text = 'Alert', value = 'ALERT' }
                    },
                    column = 4,
                    order = 1,
                    callback = function(self)
                        if VUICC and VUICC.db then
                            VUICC.db.effect = self:GetSelectedItem().value
                            if VUICC.UpdateSettings then
                                VUICC:UpdateSettings()
                            end
                        end
                    end
                },
                tenthsThreshold = {
                    key = 'vmodules.vuicc.tenthsThreshold',
                    type = 'slider',
                    label = 'Tenths Threshold',
                    tooltip = 'Show tenths of seconds when cooldown is below this value (in seconds)',
                    min = 0,
                    max = 10,
                    step = 0.5,
                    column = 6,
                    order = 3,
                    callback = function(self)
                        if VUICC and VUICC.db then
                            VUICC.db.tenthsThreshold = self:GetValue()
                            if VUICC.UpdateSettings then
                                VUICC:UpdateSettings()
                            end
                        end
                    end
                },
            }
        }
    }
end