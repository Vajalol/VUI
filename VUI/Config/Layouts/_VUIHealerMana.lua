local Layout = VUI:NewModule('Config.Layout.VUIHealerMana')

function Layout:OnEnable()
    -- Database
    local db = VUI.db
    
    -- Module reference
    local VUIHealerMana = VUI:GetModule("VUIHealerMana")
    
    -- Data
    local Textures = VUI:GetModule("Data.Textures")
    local Fonts = VUI:GetModule("Data.Fonts")
    
    -- Layout
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        database = db.profile,
        rows = {
            {
                header = {
                    type = 'header',
                    label = 'VUI Healer Mana'
                },
            },
            {
                enabled = {
                    key = 'vmodules.vuihealermana.enabled',
                    type = 'checkbox',
                    label = 'Enable Healer Mana',
                    tooltip = 'Enable or disable the Healer Mana display',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        -- Update the saved variable
                        if VUIHealerMana and VUIHealerMana.db then
                            VUIHealerMana.db.profile.enabled = self:GetValue()
                            -- Update display based on new value
                            if self:GetValue() then
                                if VUIHealerMana.OnEnable then VUIHealerMana:OnEnable() end
                            else
                                if VUIHealerMana.OnDisable then VUIHealerMana:OnDisable() end
                            end
                        end
                    end
                },
            },
            {
                movable = {
                    key = 'vmodules.vuihealermana.movable',
                    type = 'checkbox',
                    label = 'Unlock Frame',
                    tooltip = 'Unlock the frame to allow repositioning',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        -- Toggle movable frame
                        if VUIHealerMana and VUIHealerMana.ToggleMovable then
                            VUIHealerMana:ToggleMovable(self:GetValue())
                        end
                    end
                },
                scale = {
                    key = 'vmodules.vuihealermana.scale',
                    type = 'slider',
                    label = 'Scale',
                    tooltip = 'Overall scale of the display',
                    min = 0.5,
                    max = 2.0,
                    step = 0.05,
                    column = 4,
                    order = 2,
                    callback = function(self)
                        if VUIHealerMana and VUIHealerMana.db then
                            VUIHealerMana.db.profile.scale = self:GetValue()
                            if VUIHealerMana.UpdateDisplay then
                                VUIHealerMana:UpdateDisplay()
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
                showSelf = {
                    key = 'vmodules.vuihealermana.showSelf',
                    type = 'checkbox',
                    label = 'Show Self',
                    tooltip = 'Show your own mana bar (if you are a healer)',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        if VUIHealerMana and VUIHealerMana.db then
                            VUIHealerMana.db.profile.showSelf = self:GetValue()
                            if VUIHealerMana.UpdateDisplay then
                                VUIHealerMana:UpdateDisplay()
                            end
                        end
                    end
                },
                showParty = {
                    key = 'vmodules.vuihealermana.showParty',
                    type = 'checkbox',
                    label = 'Show Party',
                    tooltip = 'Show mana bars for healers in your party',
                    column = 4,
                    order = 2,
                    callback = function(self)
                        if VUIHealerMana and VUIHealerMana.db then
                            VUIHealerMana.db.profile.showParty = self:GetValue()
                            if VUIHealerMana.UpdateDisplay then
                                VUIHealerMana:UpdateDisplay()
                            end
                        end
                    end
                },
                showRaid = {
                    key = 'vmodules.vuihealermana.showRaid',
                    type = 'checkbox',
                    label = 'Show Raid',
                    tooltip = 'Show mana bars for healers in your raid',
                    column = 4,
                    order = 3,
                    callback = function(self)
                        if VUIHealerMana and VUIHealerMana.db then
                            VUIHealerMana.db.profile.showRaid = self:GetValue()
                            if VUIHealerMana.UpdateDisplay then
                                VUIHealerMana:UpdateDisplay()
                            end
                        end
                    end
                },
            },
            {
                width = {
                    key = 'vmodules.vuihealermana.width',
                    type = 'slider',
                    label = 'Bar Width',
                    tooltip = 'Width of the mana bars',
                    min = 100,
                    max = 400,
                    step = 10,
                    column = 3,
                    order = 1,
                    callback = function(self)
                        if VUIHealerMana and VUIHealerMana.db then
                            VUIHealerMana.db.profile.width = self:GetValue()
                            if VUIHealerMana.UpdateDisplay then
                                VUIHealerMana:UpdateDisplay()
                            end
                        end
                    end
                },
                height = {
                    key = 'vmodules.vuihealermana.height',
                    type = 'slider',
                    label = 'Bar Height',
                    tooltip = 'Height of the mana bars',
                    min = 10,
                    max = 50,
                    step = 2,
                    column = 3,
                    order = 2,
                    callback = function(self)
                        if VUIHealerMana and VUIHealerMana.db then
                            VUIHealerMana.db.profile.height = self:GetValue()
                            if VUIHealerMana.UpdateDisplay then
                                VUIHealerMana:UpdateDisplay()
                            end
                        end
                    end
                },
                spacing = {
                    key = 'vmodules.vuihealermana.spacing',
                    type = 'slider',
                    label = 'Bar Spacing',
                    tooltip = 'Space between mana bars',
                    min = 0,
                    max = 10,
                    step = 1,
                    column = 3,
                    order = 3,
                    callback = function(self)
                        if VUIHealerMana and VUIHealerMana.db then
                            VUIHealerMana.db.profile.spacing = self:GetValue()
                            if VUIHealerMana.UpdateDisplay then
                                VUIHealerMana:UpdateDisplay()
                            end
                        end
                    end
                },
            },
            {
                barTexture = {
                    key = 'vmodules.vuihealermana.barTexture',
                    type = 'dropdown',
                    label = 'Bar Texture',
                    tooltip = 'Texture used for the mana bars',
                    options = Textures.data,
                    column = 3,
                    order = 1,
                    callback = function(self)
                        if VUIHealerMana and VUIHealerMana.db then
                            VUIHealerMana.db.profile.barTexture = self:GetSelectedItem().value
                            if VUIHealerMana.UpdateDisplay then
                                VUIHealerMana:UpdateDisplay()
                            end
                        end
                    end
                },
                growDirection = {
                    key = 'vmodules.vuihealermana.growDirection',
                    type = 'dropdown',
                    label = 'Growth Direction',
                    tooltip = 'Direction in which bars are added',
                    options = {
                        { text = 'Up', value = 'UP' },
                        { text = 'Down', value = 'DOWN' }
                    },
                    column = 3,
                    order = 2,
                    callback = function(self)
                        if VUIHealerMana and VUIHealerMana.db then
                            VUIHealerMana.db.profile.growDirection = self:GetSelectedItem().value
                            if VUIHealerMana.UpdateDisplay then
                                VUIHealerMana:UpdateDisplay()
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
                showName = {
                    key = 'vmodules.vuihealermana.showName',
                    type = 'checkbox',
                    label = 'Show Names',
                    tooltip = 'Show healer names on the bars',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        if VUIHealerMana and VUIHealerMana.db then
                            VUIHealerMana.db.profile.showName = self:GetValue()
                            if VUIHealerMana.UpdateDisplay then
                                VUIHealerMana:UpdateDisplay()
                            end
                        end
                    end
                },
                showIcon = {
                    key = 'vmodules.vuihealermana.showIcon',
                    type = 'checkbox',
                    label = 'Show Class Icons',
                    tooltip = 'Show class icons next to the bars',
                    column = 4,
                    order = 2,
                    callback = function(self)
                        if VUIHealerMana and VUIHealerMana.db then
                            VUIHealerMana.db.profile.showIcon = self:GetValue()
                            if VUIHealerMana.UpdateDisplay then
                                VUIHealerMana:UpdateDisplay()
                            end
                        end
                    end
                },
            },
            {
                showPercent = {
                    key = 'vmodules.vuihealermana.showPercent',
                    type = 'checkbox',
                    label = 'Show Percentage',
                    tooltip = 'Show mana percentage on the bars',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        if VUIHealerMana and VUIHealerMana.db then
                            VUIHealerMana.db.profile.showPercent = self:GetValue()
                            if VUIHealerMana.UpdateDisplay then
                                VUIHealerMana:UpdateDisplay()
                            end
                        end
                    end
                },
                showValue = {
                    key = 'vmodules.vuihealermana.showValue',
                    type = 'checkbox',
                    label = 'Show Mana Value',
                    tooltip = 'Show numeric mana values on the bars',
                    column = 4,
                    order = 2,
                    callback = function(self)
                        if VUIHealerMana and VUIHealerMana.db then
                            VUIHealerMana.db.profile.showValue = self:GetValue()
                            if VUIHealerMana.UpdateDisplay then
                                VUIHealerMana:UpdateDisplay()
                            end
                        end
                    end
                },
            },
            {
                fontName = {
                    key = 'vmodules.vuihealermana.fontName',
                    type = 'dropdown',
                    label = 'Font',
                    tooltip = 'Font used for text on bars',
                    options = Fonts.data,
                    column = 3,
                    order = 1,
                    callback = function(self)
                        if VUIHealerMana and VUIHealerMana.db then
                            VUIHealerMana.db.profile.fontName = self:GetSelectedItem().value
                            if VUIHealerMana.UpdateDisplay then
                                VUIHealerMana:UpdateDisplay()
                            end
                        end
                    end
                },
                fontSize = {
                    key = 'vmodules.vuihealermana.fontSize',
                    type = 'slider',
                    label = 'Font Size',
                    tooltip = 'Size of text on bars',
                    min = 8,
                    max = 18,
                    step = 1,
                    column = 3,
                    order = 2,
                    callback = function(self)
                        if VUIHealerMana and VUIHealerMana.db then
                            VUIHealerMana.db.profile.fontSize = self:GetValue()
                            if VUIHealerMana.UpdateDisplay then
                                VUIHealerMana:UpdateDisplay()
                            end
                        end
                    end
                },
                textPosition = {
                    key = 'vmodules.vuihealermana.textPosition',
                    type = 'dropdown',
                    label = 'Text Position',
                    tooltip = 'Position of text on the bars',
                    options = {
                        { text = 'Left', value = 'LEFT' },
                        { text = 'Center', value = 'CENTER' },
                        { text = 'Right', value = 'RIGHT' }
                    },
                    column = 3,
                    order = 3,
                    callback = function(self)
                        if VUIHealerMana and VUIHealerMana.db then
                            VUIHealerMana.db.profile.textPosition = self:GetSelectedItem().value
                            if VUIHealerMana.UpdateDisplay then
                                VUIHealerMana:UpdateDisplay()
                            end
                        end
                    end
                },
            },
            {
                outlineMode = {
                    key = 'vmodules.vuihealermana.outlineMode',
                    type = 'dropdown',
                    label = 'Text Outline',
                    tooltip = 'Outline style for text',
                    options = {
                        { text = 'None', value = 'NONE' },
                        { text = 'Outline', value = 'OUTLINE' },
                        { text = 'Thick Outline', value = 'THICKOUTLINE' }
                    },
                    column = 3,
                    order = 1,
                    callback = function(self)
                        if VUIHealerMana and VUIHealerMana.db then
                            VUIHealerMana.db.profile.outlineMode = self:GetSelectedItem().value
                            if VUIHealerMana.UpdateDisplay then
                                VUIHealerMana:UpdateDisplay()
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
                useClassColors = {
                    key = 'vmodules.vuihealermana.useClassColors',
                    type = 'checkbox',
                    label = 'Use Class Colors',
                    tooltip = 'Color mana bars according to player class',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        if VUIHealerMana and VUIHealerMana.db then
                            VUIHealerMana.db.profile.useClassColors = self:GetValue()
                            if VUIHealerMana.UpdateDisplay then
                                VUIHealerMana:UpdateDisplay()
                            end
                        end
                    end
                },
            },
            {
                customBarColor = {
                    key = 'vmodules.vuihealermana.customBarColor',
                    type = 'color',
                    label = 'Bar Color',
                    tooltip = 'Color for mana bars (when not using class colors)',
                    hasAlpha = true,
                    column = 4,
                    order = 1,
                    callback = function(self, r, g, b, a)
                        if VUIHealerMana and VUIHealerMana.db then
                            VUIHealerMana.db.profile.customBarColor = {r = r, g = g, b = b, a = a}
                            if VUIHealerMana.UpdateDisplay then
                                VUIHealerMana:UpdateDisplay()
                            end
                        end
                    end
                },
                textColor = {
                    key = 'vmodules.vuihealermana.textColor',
                    type = 'color',
                    label = 'Text Color',
                    tooltip = 'Color for text on bars',
                    hasAlpha = true,
                    column = 4,
                    order = 2,
                    callback = function(self, r, g, b, a)
                        if VUIHealerMana and VUIHealerMana.db then
                            VUIHealerMana.db.profile.textColor = {r = r, g = g, b = b, a = a}
                            if VUIHealerMana.UpdateDisplay then
                                VUIHealerMana:UpdateDisplay()
                            end
                        end
                    end
                },
            },
            {
                backgroundColor = {
                    key = 'vmodules.vuihealermana.backgroundColor',
                    type = 'color',
                    label = 'Background Color',
                    tooltip = 'Color for bar backgrounds',
                    hasAlpha = true,
                    column = 4,
                    order = 1,
                    callback = function(self, r, g, b, a)
                        if VUIHealerMana and VUIHealerMana.db then
                            VUIHealerMana.db.profile.backgroundColor = {r = r, g = g, b = b, a = a}
                            if VUIHealerMana.UpdateDisplay then
                                VUIHealerMana:UpdateDisplay()
                            end
                        end
                    end
                },
                borderColor = {
                    key = 'vmodules.vuihealermana.borderColor',
                    type = 'color',
                    label = 'Border Color',
                    tooltip = 'Color for bar borders',
                    hasAlpha = true,
                    column = 4,
                    order = 2,
                    callback = function(self, r, g, b, a)
                        if VUIHealerMana and VUIHealerMana.db then
                            VUIHealerMana.db.profile.borderColor = {r = r, g = g, b = b, a = a}
                            if VUIHealerMana.UpdateDisplay then
                                VUIHealerMana:UpdateDisplay()
                            end
                        end
                    end
                },
            },
        },
    }
end