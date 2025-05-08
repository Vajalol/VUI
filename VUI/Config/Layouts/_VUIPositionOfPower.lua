local Layout = VUI:NewModule('Config.Layout.VUIPositionOfPower')

function Layout:OnEnable()
    -- Database
    local db = VUI.db
    
    -- Module reference
    local VUIPositionOfPower = VUI:GetModule("VUIPositionOfPower")
    
    -- Layout
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        database = db.profile,
        rows = {
            {
                header = {
                    type = 'header',
                    label = 'VUI Position of Power'
                },
            },
            {
                enabled = {
                    key = 'vmodules.vuipositionofpower.enabled',
                    type = 'checkbox',
                    label = 'Enable Position of Power',
                    tooltip = 'Enable or disable the Position of Power tracking',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        -- Update the saved variable
                        if VUIPositionOfPower and VUIPositionOfPower.db then
                            VUIPositionOfPower.db.profile.enabled = self:GetValue()
                            -- Update display based on new value
                            if self:GetValue() then
                                if VUIPositionOfPower.OnEnable then VUIPositionOfPower:OnEnable() end
                            else
                                if VUIPositionOfPower.OnDisable then VUIPositionOfPower:OnDisable() end
                            end
                        end
                    end
                },
            },
            {
                movable = {
                    key = 'vmodules.vuipositionofpower.movable',
                    type = 'checkbox',
                    label = 'Unlock Frame',
                    tooltip = 'Unlock the frame to allow repositioning',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        -- Toggle movable frame
                        if VUIPositionOfPower and VUIPositionOfPower.ToggleMovable then
                            VUIPositionOfPower:ToggleMovable(self:GetValue())
                        end
                    end
                },
                displayInCombatOnly = {
                    key = 'vmodules.vuipositionofpower.displayInCombatOnly',
                    type = 'checkbox',
                    label = 'Display In Combat Only',
                    tooltip = 'Only show position buffs while in combat',
                    column = 4,
                    order = 2,
                    callback = function(self)
                        if VUIPositionOfPower and VUIPositionOfPower.db then
                            VUIPositionOfPower.db.profile.displayInCombatOnly = self:GetValue()
                            if VUIPositionOfPower.UpdateVisibility then
                                VUIPositionOfPower:UpdateVisibility()
                            end
                        end
                    end
                },
            },
            {
                header = {
                    type = 'header',
                    label = 'Appearance'
                },
            },
            {
                scale = {
                    key = 'vmodules.vuipositionofpower.scale',
                    type = 'slider',
                    label = 'Scale',
                    tooltip = 'Set the scale of the display',
                    min = 0.5,
                    max = 2.0,
                    step = 0.1,
                    column = 3,
                    order = 1,
                    callback = function(self)
                        if VUIPositionOfPower and VUIPositionOfPower.db then
                            VUIPositionOfPower.db.profile.scale = self:GetValue()
                            if VUIPositionOfPower.UpdateLayout then
                                VUIPositionOfPower:UpdateLayout()
                            end
                        end
                    end
                },
                alpha = {
                    key = 'vmodules.vuipositionofpower.alpha',
                    type = 'slider',
                    label = 'Transparency',
                    tooltip = 'Set the transparency of the display',
                    min = 0.1,
                    max = 1.0,
                    step = 0.1,
                    column = 3,
                    order = 2,
                    callback = function(self)
                        if VUIPositionOfPower and VUIPositionOfPower.db then
                            VUIPositionOfPower.db.profile.alpha = self:GetValue()
                            if VUIPositionOfPower.UpdateLayout then
                                VUIPositionOfPower:UpdateLayout()
                            end
                        end
                    end
                },
                iconSize = {
                    key = 'vmodules.vuipositionofpower.iconSize',
                    type = 'slider',
                    label = 'Icon Size',
                    tooltip = 'Set the size of the buff icons',
                    min = 20,
                    max = 80,
                    step = 5,
                    column = 3,
                    order = 3,
                    callback = function(self)
                        if VUIPositionOfPower and VUIPositionOfPower.db then
                            VUIPositionOfPower.db.profile.iconSize = self:GetValue()
                            if VUIPositionOfPower.UpdateLayout then
                                VUIPositionOfPower:UpdateLayout()
                            end
                        end
                    end
                },
            },
            {
                iconSpacing = {
                    key = 'vmodules.vuipositionofpower.iconSpacing',
                    type = 'slider',
                    label = 'Icon Spacing',
                    tooltip = 'Set the spacing between icons',
                    min = 0,
                    max = 20,
                    step = 1,
                    column = 3,
                    order = 1,
                    callback = function(self)
                        if VUIPositionOfPower and VUIPositionOfPower.db then
                            VUIPositionOfPower.db.profile.iconSpacing = self:GetValue()
                            if VUIPositionOfPower.UpdateLayout then
                                VUIPositionOfPower:UpdateLayout()
                            end
                        end
                    end
                },
                growthDirection = {
                    key = 'vmodules.vuipositionofpower.growthDirection',
                    type = 'dropdown',
                    label = 'Growth Direction',
                    tooltip = 'Set the direction in which new icons appear',
                    options = {
                        { text = 'Right', value = 'RIGHT' },
                        { text = 'Left', value = 'LEFT' },
                        { text = 'Up', value = 'UP' },
                        { text = 'Down', value = 'DOWN' }
                    },
                    column = 3,
                    order = 2,
                    callback = function(self)
                        if VUIPositionOfPower and VUIPositionOfPower.db then
                            VUIPositionOfPower.db.profile.growthDirection = self:GetSelectedItem().value
                            if VUIPositionOfPower.UpdateLayout then
                                VUIPositionOfPower:UpdateLayout()
                            end
                        end
                    end
                },
            },
            {
                showGlow = {
                    key = 'vmodules.vuipositionofpower.showGlow',
                    type = 'checkbox',
                    label = 'Show Glow Effect',
                    tooltip = 'Show a glow effect around active buff icons',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        if VUIPositionOfPower and VUIPositionOfPower.db then
                            VUIPositionOfPower.db.profile.showGlow = self:GetValue()
                            if VUIPositionOfPower.UpdateIcons then
                                VUIPositionOfPower:UpdateIcons()
                            end
                        end
                    end
                },
                useClassColor = {
                    key = 'vmodules.vuipositionofpower.useClassColor',
                    type = 'checkbox',
                    label = 'Use Class Colors',
                    tooltip = 'Use class colors for borders',
                    column = 4,
                    order = 2,
                    callback = function(self)
                        if VUIPositionOfPower and VUIPositionOfPower.db then
                            VUIPositionOfPower.db.profile.useClassColor = self:GetValue()
                            if VUIPositionOfPower.UpdateIcons then
                                VUIPositionOfPower:UpdateIcons()
                            end
                        end
                    end
                },
            },
            {
                header = {
                    type = 'header',
                    label = 'Text Settings'
                },
            },
            {
                showDuration = {
                    key = 'vmodules.vuipositionofpower.showDuration',
                    type = 'checkbox',
                    label = 'Show Duration',
                    tooltip = 'Show remaining duration on buffs',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        if VUIPositionOfPower and VUIPositionOfPower.db then
                            VUIPositionOfPower.db.profile.showDuration = self:GetValue()
                            if VUIPositionOfPower.UpdateIcons then
                                VUIPositionOfPower:UpdateIcons()
                            end
                        end
                    end
                },
                showStackText = {
                    key = 'vmodules.vuipositionofpower.showStackText',
                    type = 'checkbox',
                    label = 'Show Stack Count',
                    tooltip = 'Show stack count on buffs',
                    column = 4,
                    order = 2,
                    callback = function(self)
                        if VUIPositionOfPower and VUIPositionOfPower.db then
                            VUIPositionOfPower.db.profile.showStackText = self:GetValue()
                            if VUIPositionOfPower.UpdateIcons then
                                VUIPositionOfPower:UpdateIcons()
                            end
                        end
                    end
                },
            },
            {
                durationFontSize = {
                    key = 'vmodules.vuipositionofpower.durationFontSize',
                    type = 'slider',
                    label = 'Duration Font Size',
                    tooltip = 'Set the font size for duration text',
                    min = 8,
                    max = 24,
                    step = 1,
                    column = 3,
                    order = 1,
                    callback = function(self)
                        if VUIPositionOfPower and VUIPositionOfPower.db then
                            VUIPositionOfPower.db.profile.durationFontSize = self:GetValue()
                            if VUIPositionOfPower.UpdateIcons then
                                VUIPositionOfPower:UpdateIcons()
                            end
                        end
                    end
                },
                stackFontSize = {
                    key = 'vmodules.vuipositionofpower.stackFontSize',
                    type = 'slider',
                    label = 'Stack Font Size',
                    tooltip = 'Set the font size for stack count',
                    min = 8,
                    max = 24,
                    step = 1,
                    column = 3,
                    order = 2,
                    callback = function(self)
                        if VUIPositionOfPower and VUIPositionOfPower.db then
                            VUIPositionOfPower.db.profile.stackFontSize = self:GetValue()
                            if VUIPositionOfPower.UpdateIcons then
                                VUIPositionOfPower:UpdateIcons()
                            end
                        end
                    end
                },
            },
            {
                header = {
                    type = 'header',
                    label = 'Color Settings'
                },
            },
            {
                durationFontColor = {
                    key = 'vmodules.vuipositionofpower.durationFontColor',
                    type = 'color',
                    label = 'Duration Text Color',
                    tooltip = 'Set the color for duration text',
                    hasAlpha = true,
                    column = 4,
                    order = 1,
                    callback = function(self, r, g, b, a)
                        if VUIPositionOfPower and VUIPositionOfPower.db then
                            VUIPositionOfPower.db.profile.durationFontColor = {r = r, g = g, b = b, a = a}
                            if VUIPositionOfPower.UpdateIcons then
                                VUIPositionOfPower:UpdateIcons()
                            end
                        end
                    end
                },
                stackFontColor = {
                    key = 'vmodules.vuipositionofpower.stackFontColor',
                    type = 'color',
                    label = 'Stack Text Color',
                    tooltip = 'Set the color for stack count text',
                    hasAlpha = true,
                    column = 4,
                    order = 2,
                    callback = function(self, r, g, b, a)
                        if VUIPositionOfPower and VUIPositionOfPower.db then
                            VUIPositionOfPower.db.profile.stackFontColor = {r = r, g = g, b = b, a = a}
                            if VUIPositionOfPower.UpdateIcons then
                                VUIPositionOfPower:UpdateIcons()
                            end
                        end
                    end
                },
            },
            {
                borderColor = {
                    key = 'vmodules.vuipositionofpower.borderColor',
                    type = 'color',
                    label = 'Border Color',
                    tooltip = 'Set the color for icon borders (when not using class color)',
                    hasAlpha = true,
                    column = 4,
                    order = 1,
                    callback = function(self, r, g, b, a)
                        if VUIPositionOfPower and VUIPositionOfPower.db then
                            VUIPositionOfPower.db.profile.borderColor = {r = r, g = g, b = b, a = a}
                            if VUIPositionOfPower.UpdateIcons then
                                VUIPositionOfPower:UpdateIcons()
                            end
                        end
                    end
                },
                backgroundColor = {
                    key = 'vmodules.vuipositionofpower.backgroundColor',
                    type = 'color',
                    label = 'Background Color',
                    tooltip = 'Set the background color for the icons',
                    hasAlpha = true,
                    column = 4,
                    order = 2,
                    callback = function(self, r, g, b, a)
                        if VUIPositionOfPower and VUIPositionOfPower.db then
                            VUIPositionOfPower.db.profile.backgroundColor = {r = r, g = g, b = b, a = a}
                            if VUIPositionOfPower.UpdateIcons then
                                VUIPositionOfPower:UpdateIcons()
                            end
                        end
                    end
                },
            },
        },
    }
end