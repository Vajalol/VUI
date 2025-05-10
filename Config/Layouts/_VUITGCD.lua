local Layout = VUI:NewModule('Config.Layout.VUITGCD')

function Layout:OnEnable()
    -- Database
    local db = VUI.db
    
    -- Module reference
    local VUITGCD = VUI:GetModule("VUITGCD")
    
    -- Layout
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        database = db.profile,
        rows = {
            {
                header = {
                    type = 'header',
                    label = 'VUI Ability History',
                    description = 'Track and display recently used abilities'
                },
            },
            {
                enabled = {
                    key = 'vmodules.vuitgcd.enabled',
                    type = 'checkbox',
                    label = 'Enable Ability History',
                    tooltip = 'Show recently used abilities for various units',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        -- Update the saved variable
                        if VUITGCD and VUITGCD.db then
                            VUITGCD.db.profile.enabled = self:GetValue()
                            -- Update display based on new value
                            if self:GetValue() then
                                VUITGCD:Enable()
                            else
                                VUITGCD:Disable()
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
                showInWorld = {
                    key = 'vmodules.vuitgcd.showInWorld',
                    type = 'checkbox',
                    label = 'Show in World',
                    tooltip = 'Display ability icons when in the open world',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        if VUITGCD and VUITGCD.db then
                            VUITGCD.db.profile.showInWorld = self:GetValue()
                            if VUITGCD.UpdateVisibility then
                                VUITGCD:UpdateVisibility()
                            end
                        end
                    end
                },
                showInInstances = {
                    key = 'vmodules.vuitgcd.showInInstances',
                    type = 'checkbox',
                    label = 'Show In Instances',
                    tooltip = 'Display ability icons in dungeons and raids',
                    column = 4,
                    order = 2,
                    callback = function(self)
                        if VUITGCD and VUITGCD.db then
                            VUITGCD.db.profile.showInInstances = self:GetValue()
                            if VUITGCD.UpdateVisibility then
                                VUITGCD:UpdateVisibility()
                            end
                        end
                    end
                },
                showInPVP = {
                    key = 'vmodules.vuitgcd.showInPVP',
                    type = 'checkbox',
                    label = 'Show In PVP',
                    tooltip = 'Display ability icons in PVP zones',
                    column = 4,
                    order = 3,
                    callback = function(self)
                        if VUITGCD and VUITGCD.db then
                            VUITGCD.db.profile.showInPVP = self:GetValue()
                            if VUITGCD.UpdateVisibility then
                                VUITGCD:UpdateVisibility()
                            end
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
                iconSize = {
                    key = 'vmodules.vuitgcd.iconSize',
                    type = 'slider',
                    label = 'Icon Size',
                    tooltip = 'Size of the ability icons',
                    min = 16,
                    max = 64,
                    step = 1,
                    column = 6,
                    order = 1,
                    callback = function(self)
                        if VUITGCD and VUITGCD.db then
                            VUITGCD.db.profile.iconSize = self:GetValue()
                            if VUITGCD.UpdateAppearance then
                                VUITGCD:UpdateAppearance()
                            end
                        end
                    end
                },
                iconSpacing = {
                    key = 'vmodules.vuitgcd.iconSpacing',
                    type = 'slider',
                    label = 'Icon Spacing',
                    tooltip = 'Space between icons',
                    min = 0,
                    max = 20,
                    step = 1,
                    column = 6,
                    order = 2,
                    callback = function(self)
                        if VUITGCD and VUITGCD.db then
                            VUITGCD.db.profile.iconSpacing = self:GetValue()
                            if VUITGCD.UpdateAppearance then
                                VUITGCD:UpdateAppearance()
                            end
                        end
                    end
                },
            },
            {
                maxIcons = {
                    key = 'vmodules.vuitgcd.maxIcons',
                    type = 'slider',
                    label = 'Maximum Icons',
                    tooltip = 'Maximum number of icons to display',
                    min = 1,
                    max = 15,
                    step = 1,
                    column = 6,
                    order = 3,
                    callback = function(self)
                        if VUITGCD and VUITGCD.db then
                            VUITGCD.db.profile.maxIcons = self:GetValue()
                            if VUITGCD.UpdateAppearance then
                                VUITGCD:UpdateAppearance()
                            end
                        end
                    end
                },
                fadeTime = {
                    key = 'vmodules.vuitgcd.fadeTime',
                    type = 'slider',
                    label = 'Fade Time',
                    tooltip = 'Time in seconds before icons fade away',
                    min = 0.5,
                    max = 10,
                    step = 0.5,
                    column = 6,
                    order = 4,
                    callback = function(self)
                        if VUITGCD and VUITGCD.db then
                            VUITGCD.db.profile.fadeTime = self:GetValue()
                        end
                    end
                },
            },
            {
                header = {
                    type = 'header',
                    label = 'Unit Settings'
                },
            },
            {
                trackPlayer = {
                    key = 'vmodules.vuitgcd.trackPlayer',
                    type = 'checkbox',
                    label = 'Track Player',
                    tooltip = 'Show your own abilities',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        if VUITGCD and VUITGCD.db then
                            VUITGCD.db.profile.trackPlayer = self:GetValue()
                            if VUITGCD.UpdateUnits then
                                VUITGCD:UpdateUnits()
                            end
                        end
                    end
                },
                trackTarget = {
                    key = 'vmodules.vuitgcd.trackTarget',
                    type = 'checkbox',
                    label = 'Track Target',
                    tooltip = 'Show abilities used by your target',
                    column = 4,
                    order = 2,
                    callback = function(self)
                        if VUITGCD and VUITGCD.db then
                            VUITGCD.db.profile.trackTarget = self:GetValue()
                            if VUITGCD.UpdateUnits then
                                VUITGCD:UpdateUnits()
                            end
                        end
                    end
                },
                trackFocus = {
                    key = 'vmodules.vuitgcd.trackFocus',
                    type = 'checkbox',
                    label = 'Track Focus',
                    tooltip = 'Show abilities used by your focus target',
                    column = 4,
                    order = 3,
                    callback = function(self)
                        if VUITGCD and VUITGCD.db then
                            VUITGCD.db.profile.trackFocus = self:GetValue()
                            if VUITGCD.UpdateUnits then
                                VUITGCD:UpdateUnits()
                            end
                        end
                    end
                },
            },
            {
                trackParty = {
                    key = 'vmodules.vuitgcd.trackParty',
                    type = 'checkbox',
                    label = 'Track Party Members',
                    tooltip = 'Show abilities used by party members',
                    column = 4,
                    order = 4,
                    callback = function(self)
                        if VUITGCD and VUITGCD.db then
                            VUITGCD.db.profile.trackParty = self:GetValue()
                            if VUITGCD.UpdateUnits then
                                VUITGCD:UpdateUnits()
                            end
                        end
                    end
                },
                useThemeColors = {
                    key = 'vmodules.vuitgcd.useThemeColors',
                    type = 'checkbox',
                    label = 'Use VUI Theme Colors',
                    tooltip = 'Apply VUI theme colors to icon borders',
                    column = 4,
                    order = 5,
                    callback = function(self)
                        if VUITGCD and VUITGCD.db then
                            VUITGCD.db.profile.useThemeColors = self:GetValue()
                            if VUITGCD.UpdateAppearance then
                                VUITGCD:UpdateAppearance()
                            end
                        end
                    end
                }
            }
        }
    }
end