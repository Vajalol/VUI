local Layout = VUI:NewModule('Config.Layout.VUIBuffs')

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
                    label = 'VUI Buffs'
                },
            },
            {
                enabled = {
                    key = 'vmodules.vuibuffs.enabled',
                    type = 'checkbox',
                    label = 'Enable VUI Buffs',
                    tooltip = 'Enable or disable the VUI Buffs module',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        -- Update the saved variable in VUIBuffs
                        if VUIBuffs and VUIBuffs.db then
                            VUIBuffs.db.profile.general.enabled = self:GetValue()
                            if VUIBuffs.UpdateAllDisplays then
                                VUIBuffs:UpdateAllDisplays()
                            end
                        end
                    end
                },
            },
            {
                lockFrames = {
                    key = 'vmodules.vuibuffs.lockFrames',
                    type = 'checkbox',
                    label = 'Lock Frames',
                    tooltip = 'Lock or unlock VUI Buffs frames',
                    column = 4,
                    order = 2,
                    callback = function(self)
                        -- Update the saved variable in VUIBuffs
                        if VUIBuffs and VUIBuffs.db then
                            VUIBuffs.db.profile.general.lockFrames = self:GetValue()
                            if VUIBuffs.UpdateAllDisplays then
                                VUIBuffs:UpdateAllDisplays()
                            end
                        end
                    end
                },
            },
            {
                openConfig = {
                    type = 'button',
                    label = 'Open VUI Buffs Config',
                    tooltip = 'Open the full VUI Buffs configuration panel',
                    column = 4,
                    order = 3,
                    callback = function()
                        if VUIBuffs and VUIBuffs.OpenOptions then
                            VUIBuffs:OpenOptions()
                        end
                    end
                },
            },
            {
                header2 = {
                    type = 'header',
                    label = 'Bar Display Settings'
                },
            },
            {
                barEnabled = {
                    key = 'vmodules.vuibuffs.barDisplayEnabled',
                    type = 'checkbox',
                    label = 'Enable Bar Display',
                    tooltip = 'Enable or disable the buff/debuff bar display',
                    column = 4,
                    order = 5,
                    callback = function(self)
                        -- Update the saved variable in VUIBuffs
                        if VUIBuffs and VUIBuffs.db then
                            VUIBuffs.db.profile.barDisplays.global.enabled = self:GetValue()
                            if VUIBuffs.UpdateAllDisplays then
                                VUIBuffs:UpdateAllDisplays()
                            end
                        end
                    end
                },
            },
            {
                barHeight = {
                    key = 'vmodules.vuibuffs.barHeight',
                    type = 'slider',
                    label = 'Bar Height',
                    tooltip = 'Set the height of buff/debuff bars',
                    min = 1,
                    max = 50,
                    step = 1,
                    column = 4,
                    order = 6,
                    callback = function(self)
                        -- Update the saved variable in VUIBuffs
                        if VUIBuffs and VUIBuffs.db then
                            VUIBuffs.db.profile.barDisplays.global.barHeight = self:GetValue()
                            if VUIBuffs.UpdateAllDisplays then
                                VUIBuffs:UpdateAllDisplays()
                            end
                        end
                    end
                },
            },
            {
                barWidth = {
                    key = 'vmodules.vuibuffs.barWidth',
                    type = 'slider',
                    label = 'Bar Width',
                    tooltip = 'Set the width of buff/debuff bars',
                    min = 50,
                    max = 300,
                    step = 1,
                    column = 4,
                    order = 7,
                    callback = function(self)
                        -- Update the saved variable in VUIBuffs
                        if VUIBuffs and VUIBuffs.db then
                            VUIBuffs.db.profile.barDisplays.global.barWidth = self:GetValue()
                            if VUIBuffs.UpdateAllDisplays then
                                VUIBuffs:UpdateAllDisplays()
                            end
                        end
                    end
                },
            },
            {
                barPadding = {
                    key = 'vmodules.vuibuffs.barPadding',
                    type = 'slider',
                    label = 'Bar Padding',
                    tooltip = 'Set the padding between buff/debuff bars',
                    min = 0,
                    max = 20,
                    step = 1,
                    column = 4,
                    order = 8,
                    callback = function(self)
                        -- Update the saved variable in VUIBuffs
                        if VUIBuffs and VUIBuffs.db then
                            VUIBuffs.db.profile.barDisplays.global.barPadding = self:GetValue()
                            if VUIBuffs.UpdateAllDisplays then
                                VUIBuffs:UpdateAllDisplays()
                            end
                        end
                    end
                },
            },
        },
    }
end