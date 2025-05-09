local Layout = VUI:NewModule('Config.Layout.VUIMissingRaidBuffs')

function Layout:OnEnable()
    -- Database
    local db = VUI.db
    
    -- Module reference
    local VUIMissingRaidBuffs = VUI:GetModule("VUIMissingRaidBuffs")
    
    -- Layout
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        database = db.profile,
        rows = {
            {
                header = {
                    type = 'header',
                    label = 'VUI Missing Raid Buffs'
                },
            },
            {
                enabled = {
                    key = 'vmodules.vuimissingraidbuffs.enabled',
                    type = 'checkbox',
                    label = 'Enable Missing Raid Buffs',
                    tooltip = 'Enable or disable the Missing Raid Buffs module',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        -- Update the saved variable in VUIMissingRaidBuffs
                        if VUIMissingRaidBuffs and VUIMissingRaidBuffs.db then
                            VUIMissingRaidBuffs.db.profile.enabled = self:GetValue()
                            -- Update display based on new value
                            if self:GetValue() then
                                if VUIMissingRaidBuffs.OnEnable then VUIMissingRaidBuffs:OnEnable() end
                            else
                                if VUIMissingRaidBuffs.OnDisable then VUIMissingRaidBuffs:OnDisable() end
                            end
                        end
                    end
                },
            },
            {
                movable = {
                    key = 'vmodules.vuimissingraidbuffs.movable',
                    type = 'checkbox',
                    label = 'Unlock Frame',
                    tooltip = 'Unlock the frame to allow repositioning',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        -- Toggle movable frame
                        if VUIMissingRaidBuffs and VUIMissingRaidBuffs.ToggleMovable then
                            VUIMissingRaidBuffs:ToggleMovable(self:GetValue())
                        end
                    end
                },
                displayInGroupOnly = {
                    key = 'vmodules.vuimissingraidbuffs.displayInGroupOnly',
                    type = 'checkbox',
                    label = 'Display In Group Only',
                    tooltip = 'Only show missing buffs while in a group/raid',
                    column = 4,
                    order = 2,
                    callback = function(self)
                        if VUIMissingRaidBuffs and VUIMissingRaidBuffs.db then
                            VUIMissingRaidBuffs.db.profile.displayInGroupOnly = self:GetValue()
                            if VUIMissingRaidBuffs.UpdateVisibility then
                                VUIMissingRaidBuffs:UpdateVisibility()
                            end
                        end
                    end
                },
                displayInCombatOnly = {
                    key = 'vmodules.vuimissingraidbuffs.displayInCombatOnly',
                    type = 'checkbox',
                    label = 'Display In Combat Only',
                    tooltip = 'Only show missing buffs while in combat',
                    column = 4,
                    order = 3,
                    callback = function(self)
                        if VUIMissingRaidBuffs and VUIMissingRaidBuffs.db then
                            VUIMissingRaidBuffs.db.profile.displayInCombatOnly = self:GetValue()
                            if VUIMissingRaidBuffs.UpdateVisibility then
                                VUIMissingRaidBuffs:UpdateVisibility()
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
                    key = 'vmodules.vuimissingraidbuffs.scale',
                    type = 'slider',
                    label = 'Scale',
                    tooltip = 'Set the scale of the display',
                    min = 0.5,
                    max = 2.0,
                    step = 0.1,
                    column = 3,
                    order = 1,
                    callback = function(self)
                        if VUIMissingRaidBuffs and VUIMissingRaidBuffs.db then
                            VUIMissingRaidBuffs.db.profile.scale = self:GetValue()
                            if VUIMissingRaidBuffs.UpdateLayout then
                                VUIMissingRaidBuffs:UpdateLayout()
                            end
                        end
                    end
                },
                alpha = {
                    key = 'vmodules.vuimissingraidbuffs.alpha',
                    type = 'slider',
                    label = 'Transparency',
                    tooltip = 'Set the transparency of the display',
                    min = 0.1,
                    max = 1.0,
                    step = 0.1,
                    column = 3,
                    order = 2,
                    callback = function(self)
                        if VUIMissingRaidBuffs and VUIMissingRaidBuffs.db then
                            VUIMissingRaidBuffs.db.profile.alpha = self:GetValue()
                            if VUIMissingRaidBuffs.UpdateLayout then
                                VUIMissingRaidBuffs:UpdateLayout()
                            end
                        end
                    end
                },
                iconSize = {
                    key = 'vmodules.vuimissingraidbuffs.iconSize',
                    type = 'slider',
                    label = 'Icon Size',
                    tooltip = 'Set the size of the buff icons',
                    min = 16,
                    max = 64,
                    step = 2,
                    column = 3,
                    order = 3,
                    callback = function(self)
                        if VUIMissingRaidBuffs and VUIMissingRaidBuffs.db then
                            VUIMissingRaidBuffs.db.profile.iconSize = self:GetValue()
                            if VUIMissingRaidBuffs.UpdateLayout then
                                VUIMissingRaidBuffs:UpdateLayout()
                            end
                        end
                    end
                },
            },
            {
                showTooltip = {
                    key = 'vmodules.vuimissingraidbuffs.showTooltip',
                    type = 'checkbox',
                    label = 'Show Tooltips',
                    tooltip = 'Show tooltips for buff icons',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        if VUIMissingRaidBuffs and VUIMissingRaidBuffs.db then
                            VUIMissingRaidBuffs.db.profile.showTooltip = self:GetValue()
                        end
                    end
                },
                showStatus = {
                    key = 'vmodules.vuimissingraidbuffs.showStatus',
                    type = 'checkbox',
                    label = 'Show Status Text',
                    tooltip = 'Show status text below the icons',
                    column = 4,
                    order = 2,
                    callback = function(self)
                        if VUIMissingRaidBuffs and VUIMissingRaidBuffs.db then
                            VUIMissingRaidBuffs.db.profile.showStatus = self:GetValue()
                            if VUIMissingRaidBuffs.UpdateLayout then
                                VUIMissingRaidBuffs:UpdateLayout()
                            end
                        end
                    end
                },
                growthDirection = {
                    key = 'vmodules.vuimissingraidbuffs.growthDirection',
                    type = 'dropdown',
                    label = 'Growth Direction',
                    tooltip = 'Set the direction in which new icons appear',
                    options = {
                        { text = 'Right', value = 'RIGHT' },
                        { text = 'Left', value = 'LEFT' },
                        { text = 'Up', value = 'UP' },
                        { text = 'Down', value = 'DOWN' }
                    },
                    column = 4,
                    order = 3,
                    callback = function(self)
                        if VUIMissingRaidBuffs and VUIMissingRaidBuffs.db then
                            VUIMissingRaidBuffs.db.profile.growthDirection = self:GetSelectedItem().value
                            if VUIMissingRaidBuffs.UpdateLayout then
                                VUIMissingRaidBuffs:UpdateLayout()
                            end
                        end
                    end
                },
            },
            {
                header = {
                    type = 'header',
                    label = 'Warnings'
                },
            },
            {
                showWarning = {
                    key = 'vmodules.vuimissingraidbuffs.showWarning',
                    type = 'checkbox',
                    label = 'Show Warnings',
                    tooltip = 'Show warnings for missing buffs before pull',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        if VUIMissingRaidBuffs and VUIMissingRaidBuffs.db then
                            VUIMissingRaidBuffs.db.profile.showWarning = self:GetValue()
                        end
                    end
                },
                warningSound = {
                    key = 'vmodules.vuimissingraidbuffs.warningSound',
                    type = 'checkbox',
                    label = 'Play Warning Sound',
                    tooltip = 'Play sound for missing buff warnings',
                    column = 4,
                    order = 2,
                    callback = function(self)
                        if VUIMissingRaidBuffs and VUIMissingRaidBuffs.db then
                            VUIMissingRaidBuffs.db.profile.warningSound = self:GetValue()
                        end
                    end
                },
                warningMessage = {
                    key = 'vmodules.vuimissingraidbuffs.warningMessage',
                    type = 'checkbox',
                    label = 'Show Chat Message',
                    tooltip = 'Show warning messages in chat',
                    column = 4,
                    order = 3,
                    callback = function(self)
                        if VUIMissingRaidBuffs and VUIMissingRaidBuffs.db then
                            VUIMissingRaidBuffs.db.profile.warningMessage = self:GetValue()
                        end
                    end
                },
            },
            {
                header = {
                    type = 'header',
                    label = 'Buffs to Track'
                },
            },
            {
                trackIntellect = {
                    key = 'vmodules.vuimissingraidbuffs.trackIntellect',
                    type = 'checkbox',
                    label = 'Track Intellect',
                    tooltip = 'Track Intellect buffs',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        if VUIMissingRaidBuffs and VUIMissingRaidBuffs.db then
                            VUIMissingRaidBuffs.db.profile.trackIntellect = self:GetValue()
                            if VUIMissingRaidBuffs.UpdateBuffTracking then
                                VUIMissingRaidBuffs:UpdateBuffTracking()
                            end
                        end
                    end
                },
                trackStamina = {
                    key = 'vmodules.vuimissingraidbuffs.trackStamina',
                    type = 'checkbox',
                    label = 'Track Stamina',
                    tooltip = 'Track Stamina buffs',
                    column = 4,
                    order = 2,
                    callback = function(self)
                        if VUIMissingRaidBuffs and VUIMissingRaidBuffs.db then
                            VUIMissingRaidBuffs.db.profile.trackStamina = self:GetValue()
                            if VUIMissingRaidBuffs.UpdateBuffTracking then
                                VUIMissingRaidBuffs:UpdateBuffTracking()
                            end
                        end
                    end
                },
                trackAttackPower = {
                    key = 'vmodules.vuimissingraidbuffs.trackAttackPower',
                    type = 'checkbox',
                    label = 'Track Attack Power',
                    tooltip = 'Track Attack Power buffs',
                    column = 4,
                    order = 3,
                    callback = function(self)
                        if VUIMissingRaidBuffs and VUIMissingRaidBuffs.db then
                            VUIMissingRaidBuffs.db.profile.trackAttackPower = self:GetValue()
                            if VUIMissingRaidBuffs.UpdateBuffTracking then
                                VUIMissingRaidBuffs:UpdateBuffTracking()
                            end
                        end
                    end
                },
            },
            {
                trackHaste = {
                    key = 'vmodules.vuimissingraidbuffs.trackHaste',
                    type = 'checkbox',
                    label = 'Track Haste',
                    tooltip = 'Track Haste buffs',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        if VUIMissingRaidBuffs and VUIMissingRaidBuffs.db then
                            VUIMissingRaidBuffs.db.profile.trackHaste = self:GetValue()
                            if VUIMissingRaidBuffs.UpdateBuffTracking then
                                VUIMissingRaidBuffs:UpdateBuffTracking()
                            end
                        end
                    end
                },
                trackSpellPower = {
                    key = 'vmodules.vuimissingraidbuffs.trackSpellPower',
                    type = 'checkbox',
                    label = 'Track Spell Power',
                    tooltip = 'Track Spell Power buffs',
                    column = 4,
                    order = 2,
                    callback = function(self)
                        if VUIMissingRaidBuffs and VUIMissingRaidBuffs.db then
                            VUIMissingRaidBuffs.db.profile.trackSpellPower = self:GetValue()
                            if VUIMissingRaidBuffs.UpdateBuffTracking then
                                VUIMissingRaidBuffs:UpdateBuffTracking()
                            end
                        end
                    end
                },
                trackKings = {
                    key = 'vmodules.vuimissingraidbuffs.trackKings',
                    type = 'checkbox',
                    label = 'Track Kings',
                    tooltip = 'Track Blessing of Kings / Mark of the Wild',
                    column = 4,
                    order = 3,
                    callback = function(self)
                        if VUIMissingRaidBuffs and VUIMissingRaidBuffs.db then
                            VUIMissingRaidBuffs.db.profile.trackKings = self:GetValue()
                            if VUIMissingRaidBuffs.UpdateBuffTracking then
                                VUIMissingRaidBuffs:UpdateBuffTracking()
                            end
                        end
                    end
                },
            },
            {
                trackMight = {
                    key = 'vmodules.vuimissingraidbuffs.trackMight',
                    type = 'checkbox',
                    label = 'Track Might',
                    tooltip = 'Track Blessing of Might / Battle Shout',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        if VUIMissingRaidBuffs and VUIMissingRaidBuffs.db then
                            VUIMissingRaidBuffs.db.profile.trackMight = self:GetValue()
                            if VUIMissingRaidBuffs.UpdateBuffTracking then
                                VUIMissingRaidBuffs:UpdateBuffTracking()
                            end
                        end
                    end
                },
                trackHorn = {
                    key = 'vmodules.vuimissingraidbuffs.trackHorn',
                    type = 'checkbox',
                    label = 'Track Bloodlust/Heroism',
                    tooltip = 'Track Bloodlust/Heroism/Time Warp effects',
                    column = 4,
                    order = 2,
                    callback = function(self)
                        if VUIMissingRaidBuffs and VUIMissingRaidBuffs.db then
                            VUIMissingRaidBuffs.db.profile.trackHorn = self:GetValue()
                            if VUIMissingRaidBuffs.UpdateBuffTracking then
                                VUIMissingRaidBuffs:UpdateBuffTracking()
                            end
                        end
                    end
                },
            },
        },
    }
end