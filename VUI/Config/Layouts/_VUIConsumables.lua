local Layout = VUI:NewModule('Config.Layout.VUIConsumables')

function Layout:OnEnable()
    -- Database
    local db = VUI.db
    
    -- Layout
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        database = db.profile,
        rows = {
            {
                header = {
                    type = 'header',
                    label = 'VUI Consumables'
                },
            },
            {
                enabled = {
                    key = 'vmodules.vuiconsumables.enabled',
                    type = 'checkbox',
                    label = 'Enable VUI Consumables',
                    tooltip = 'Enable or disable the VUI Consumables module',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        -- Update the saved variable in VUIConsumables
                        if VUIConsumables and VUIConsumables.db then
                            VUIConsumables.db.profile.enabled = self:GetValue()
                            -- Update display based on new value
                            if self:GetValue() then
                                if VUIConsumables.OnEnable then VUIConsumables:OnEnable() end
                            else
                                if VUIConsumables.OnDisable then VUIConsumables:OnDisable() end
                            end
                        end
                    end
                },
            },
            {
                movable = {
                    key = 'vmodules.vuiconsumables.movable',
                    type = 'checkbox',
                    label = 'Unlock Frame',
                    tooltip = 'Unlock the frame to allow repositioning',
                    column = 4,
                    order = 2,
                    callback = function(self)
                        -- Toggle movable frame
                        if VUIConsumables and VUIConsumables.ToggleMovable then
                            VUIConsumables:ToggleMovable(self:GetValue())
                        end
                    end
                },
            },
            {
                header2 = {
                    type = 'header',
                    label = 'Display Settings'
                },
            },
            {
                scale = {
                    key = 'vmodules.vuiconsumables.scale',
                    type = 'slider',
                    label = 'Scale',
                    tooltip = 'Adjust the size of the consumables display',
                    min = 0.5,
                    max = 2.0,
                    step = 0.05,
                    column = 4,
                    order = 3,
                    callback = function(self)
                        -- Update the saved variable
                        if VUIConsumables and VUIConsumables.db then
                            VUIConsumables.db.profile.scale = self:GetValue()
                            -- Update display
                            if VUIConsumables.containerFrame then
                                VUIConsumables.containerFrame:SetScale(self:GetValue())
                            end
                        end
                    end
                },
            },
            {
                alpha = {
                    key = 'vmodules.vuiconsumables.alpha',
                    type = 'slider',
                    label = 'Alpha',
                    tooltip = 'Adjust the transparency of the consumables display',
                    min = 0.1,
                    max = 1.0,
                    step = 0.05,
                    column = 4,
                    order = 4,
                    callback = function(self)
                        -- Update the saved variable
                        if VUIConsumables and VUIConsumables.db then
                            VUIConsumables.db.profile.alpha = self:GetValue()
                            -- Update display
                            if VUIConsumables.containerFrame then
                                VUIConsumables.containerFrame:SetAlpha(self:GetValue())
                            end
                        end
                    end
                },
            },
            {
                activeOnly = {
                    key = 'vmodules.vuiconsumables.activeOnly',
                    type = 'checkbox',
                    label = 'Show Active Only',
                    tooltip = 'Only show icons for active consumables',
                    column = 4,
                    order = 5,
                    callback = function(self)
                        -- Update the saved variable
                        if VUIConsumables and VUIConsumables.db then
                            VUIConsumables.db.profile.activeOnly = self:GetValue()
                            -- Update display
                            if VUIConsumables.UpdateIconFrames then
                                VUIConsumables:UpdateIconFrames()
                            end
                        end
                    end
                },
            },
            {
                header3 = {
                    type = 'header',
                    label = 'Tracking Options'
                },
            },
            {
                showFlasks = {
                    key = 'vmodules.vuiconsumables.showFlasks',
                    type = 'checkbox',
                    label = 'Show Flasks',
                    tooltip = 'Show flask tracking icon',
                    column = 2,
                    order = 6,
                    callback = function(self)
                        -- Update the saved variable
                        if VUIConsumables and VUIConsumables.db then
                            VUIConsumables.db.profile.showFlasks = self:GetValue()
                            -- Recreate frames
                            if VUIConsumables.CreateIconFrames then
                                VUIConsumables:CreateIconFrames()
                            end
                        end
                    end
                },
                showFood = {
                    key = 'vmodules.vuiconsumables.showFood',
                    type = 'checkbox',
                    label = 'Show Food',
                    tooltip = 'Show food buff tracking icon',
                    column = 2,
                    order = 7,
                    callback = function(self)
                        -- Update the saved variable
                        if VUIConsumables and VUIConsumables.db then
                            VUIConsumables.db.profile.showFood = self:GetValue()
                            -- Recreate frames
                            if VUIConsumables.CreateIconFrames then
                                VUIConsumables:CreateIconFrames()
                            end
                        end
                    end
                },
            },
            {
                showPotions = {
                    key = 'vmodules.vuiconsumables.showPotions',
                    type = 'checkbox',
                    label = 'Show Potions',
                    tooltip = 'Show potion tracking icon',
                    column = 2,
                    order = 8,
                    callback = function(self)
                        -- Update the saved variable
                        if VUIConsumables and VUIConsumables.db then
                            VUIConsumables.db.profile.showPotions = self:GetValue()
                            -- Recreate frames
                            if VUIConsumables.CreateIconFrames then
                                VUIConsumables:CreateIconFrames()
                            end
                        end
                    end
                },
                showRunes = {
                    key = 'vmodules.vuiconsumables.showRunes',
                    type = 'checkbox',
                    label = 'Show Runes',
                    tooltip = 'Show augment rune tracking icon',
                    column = 2,
                    order = 9,
                    callback = function(self)
                        -- Update the saved variable
                        if VUIConsumables and VUIConsumables.db then
                            VUIConsumables.db.profile.showRunes = self:GetValue()
                            -- Recreate frames
                            if VUIConsumables.CreateIconFrames then
                                VUIConsumables:CreateIconFrames()
                            end
                        end
                    end
                },
            },
            {
                openConfig = {
                    type = 'button',
                    label = 'Open Full Configuration',
                    tooltip = 'Open detailed configuration panel for VUI Consumables',
                    column = 4,
                    order = 10,
                    callback = function()
                        -- Open the AceConfig panel
                        if VUIConsumables then
                            VUI.Config:OpenConfig(VUIConsumables.NAME)
                        end
                    end
                },
            },
        },
    }
end