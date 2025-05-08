local Layout = VUI:NewModule('Config.Layout.VUIKeystones')

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
                    label = 'VUI Keystones'
                },
            },
            {
                enabled = {
                    key = 'vmodules.vuikeystones.enabled',
                    type = 'checkbox',
                    label = 'Enable VUI Keystones',
                    tooltip = 'Enable or disable the VUI Keystones module',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        -- Update the saved variable in VUIKeystones
                        if VUIKeystones and VUIKeystones.db then
                            VUIKeystones.db.profile.general.enabled = self:GetValue()
                            -- Update any displays
                            if VUIKeystones.GetModule then
                                local Config = VUIKeystones:GetModule("Config")
                                if Config and Config.NotifyUpdate then
                                    Config:NotifyUpdate()
                                end
                            end
                        end
                    end
                },
            },
            {
                progressTooltip = {
                    key = 'vmodules.vuikeystones.progressTooltip',
                    type = 'checkbox',
                    label = 'Show Enemy Forces in Tooltips',
                    tooltip = 'Show progress each enemy gives on their tooltip',
                    column = 4,
                    order = 2,
                    callback = function(self)
                        -- Update the saved variable in VUIKeystones
                        if VUIKeystones and VUIKeystones.db then
                            VUIKeystones.db.profile.progressTooltip = self:GetValue()
                            -- Update any displays
                            if VUIKeystones.GetModule then
                                local Config = VUIKeystones:GetModule("Config")
                                if Config and Config.NotifyUpdate then
                                    Config:NotifyUpdate()
                                end
                            end
                        end
                    end
                },
            },
            {
                autoGossip = {
                    key = 'vmodules.vuikeystones.autoGossip',
                    type = 'checkbox',
                    label = 'Auto-select Gossip Options',
                    tooltip = 'Automatically select gossip entries during Mythic Keystone dungeons',
                    column = 4,
                    order = 3,
                    callback = function(self)
                        -- Update the saved variable in VUIKeystones
                        if VUIKeystones and VUIKeystones.db then
                            VUIKeystones.db.profile.autoGossip = self:GetValue()
                            -- Update any displays
                            if VUIKeystones.GetModule then
                                local Config = VUIKeystones:GetModule("Config")
                                if Config and Config.NotifyUpdate then
                                    Config:NotifyUpdate()
                                end
                            end
                        end
                    end
                },
            },
            {
                silverGoldTimer = {
                    key = 'vmodules.vuikeystones.silverGoldTimer',
                    type = 'checkbox',
                    label = 'Show Multiple Timer Thresholds',
                    tooltip = 'Show timer for both 2 and 3 bonus chests at same time',
                    column = 4,
                    order = 4,
                    callback = function(self)
                        -- Update the saved variable in VUIKeystones
                        if VUIKeystones and VUIKeystones.db then
                            VUIKeystones.db.profile.silverGoldTimer = self:GetValue()
                            -- Update any displays
                            if VUIKeystones.GetModule then
                                local Config = VUIKeystones:GetModule("Config")
                                if Config and Config.NotifyUpdate then
                                    Config:NotifyUpdate()
                                end
                            end
                        end
                    end
                },
            },
            {
                completionMessage = {
                    key = 'vmodules.vuikeystones.completionMessage',
                    type = 'checkbox',
                    label = 'Show Completion Messages',
                    tooltip = 'Show message with final times on completion of a Mythic Keystone dungeon',
                    column = 4,
                    order = 5,
                    callback = function(self)
                        -- Update the saved variable in VUIKeystones
                        if VUIKeystones and VUIKeystones.db then
                            VUIKeystones.db.profile.completionMessage = self:GetValue()
                            -- Update any displays
                            if VUIKeystones.GetModule then
                                local Config = VUIKeystones:GetModule("Config")
                                if Config and Config.NotifyUpdate then
                                    Config:NotifyUpdate()
                                end
                            end
                        end
                    end
                },
            },
            {
                smallAffixes = {
                    key = 'vmodules.vuikeystones.smallAffixes',
                    type = 'checkbox',
                    label = 'Small Affix Icons',
                    tooltip = 'Show smaller affix icons on the keystone and objectives tracker',
                    column = 4,
                    order = 6,
                    callback = function(self)
                        -- Update the saved variable in VUIKeystones
                        if VUIKeystones and VUIKeystones.db then
                            VUIKeystones.db.profile.smallAffixes = self:GetValue()
                            -- Update any displays
                            if VUIKeystones.GetModule then
                                local Config = VUIKeystones:GetModule("Config")
                                if Config and Config.NotifyUpdate then
                                    Config:NotifyUpdate()
                                end
                            end
                        end
                    end
                },
            },
            {
                deathTracker = {
                    key = 'vmodules.vuikeystones.deathTracker',
                    type = 'checkbox',
                    label = 'Death Counter',
                    tooltip = 'Show death counter under objective tracker',
                    column = 4,
                    order = 7,
                    callback = function(self)
                        -- Update the saved variable in VUIKeystones
                        if VUIKeystones and VUIKeystones.db then
                            VUIKeystones.db.profile.deathTracker = self:GetValue()
                            -- Update any displays
                            if VUIKeystones.GetModule then
                                local Config = VUIKeystones:GetModule("Config")
                                if Config and Config.NotifyUpdate then
                                    Config:NotifyUpdate()
                                end
                            end
                        end
                    end
                },
            },
            {
                openConfig = {
                    type = 'button',
                    label = 'More Options',
                    tooltip = 'Open the full VUI Keystones configuration panel',
                    column = 4,
                    order = 8,
                    callback = function()
                        if VUIKeystones and VUIKeystones.OpenOptions then
                            VUIKeystones:OpenOptions()
                        end
                    end
                },
            },
        },
    }
end