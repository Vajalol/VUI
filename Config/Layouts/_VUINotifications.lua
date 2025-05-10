local Layout = VUI:NewModule('Config.Layout.VUINotifications')

function Layout:OnEnable()
    -- Database
    local db = VUI.db
    
    -- Module reference
    local VUINotifications = VUI:GetModule("VUINotifications")
    
    -- Layout
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        database = db.profile,
        rows = {
            {
                header = {
                    type = 'header',
                    label = 'VUI Notifications'
                },
            },
            {
                enabled = {
                    key = 'vmodules.vuinotifications.enabled',
                    type = 'checkbox',
                    label = 'Enable Notifications',
                    tooltip = 'Show notifications for combat events like interrupts, dispels, and misses',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        local module = VUI:GetModule("VUINotifications")
                        if module and module.db then
                            module.db.profile.enabled = self:GetValue()
                        end
                    end
                },
            },
            {
                soundsEnabled = {
                    key = 'vmodules.vuinotifications.soundsEnabled',
                    type = 'checkbox',
                    label = 'Enable Sounds',
                    tooltip = 'Play sounds for important notifications',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        local module = VUI:GetModule("VUINotifications")
                        if module and module.db then
                            module.db.profile.soundsEnabled = self:GetValue()
                        end
                    end
                },
                suppressErrors = {
                    key = 'vmodules.vuinotifications.suppressErrors',
                    type = 'checkbox',
                    label = 'Suppress Common Errors',
                    tooltip = 'Hide common combat error messages like "Not enough energy", "Out of range", etc.',
                    column = 4,
                    order = 2,
                    callback = function(self)
                        local module = VUI:GetModule("VUINotifications")
                        if module and module.db then
                            module.db.profile.suppressErrors = self:GetValue()
                        end
                    end
                },
            },
            {
                header = {
                    type = 'header',
                    label = 'Notification Types'
                },
            },
            {
                showInterrupts = {
                    key = 'vmodules.vuinotifications.showInterrupts',
                    type = 'checkbox',
                    label = 'Show Interrupts',
                    tooltip = 'Show notifications when you successfully interrupt a spell',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        local module = VUI:GetModule("VUINotifications")
                        if module and module.db then
                            module.db.profile.showInterrupts = self:GetValue()
                        end
                    end
                },
                showDispels = {
                    key = 'vmodules.vuinotifications.showDispels',
                    type = 'checkbox',
                    label = 'Show Dispels',
                    tooltip = 'Show notifications when you successfully dispel a buff or debuff',
                    column = 4,
                    order = 2,
                    callback = function(self)
                        local module = VUI:GetModule("VUINotifications")
                        if module and module.db then
                            module.db.profile.showDispels = self:GetValue()
                        end
                    end
                },
            },
            {
                showMisses = {
                    key = 'vmodules.vuinotifications.showMisses',
                    type = 'checkbox',
                    label = 'Show Misses',
                    tooltip = 'Show notifications when your abilities miss, are dodged, parried, etc.',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        local module = VUI:GetModule("VUINotifications")
                        if module and module.db then
                            module.db.profile.showMisses = self:GetValue()
                        end
                    end
                },
                showReflects = {
                    key = 'vmodules.vuinotifications.showReflects',
                    type = 'checkbox',
                    label = 'Show Reflects',
                    tooltip = 'Show notifications when spells are reflected',
                    column = 4,
                    order = 2,
                    callback = function(self)
                        local module = VUI:GetModule("VUINotifications")
                        if module and module.db then
                            module.db.profile.showReflects = self:GetValue()
                        end
                    end
                },
            },
            {
                showPetStatus = {
                    key = 'vmodules.vuinotifications.showPetStatus',
                    type = 'checkbox',
                    label = 'Show Pet Status',
                    tooltip = 'Show notifications when your pet dies',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        local module = VUI:GetModule("VUINotifications")
                        if module and module.db then
                            module.db.profile.showPetStatus = self:GetValue()
                        end
                    end
                },
            },
            {
                header = {
                    type = 'header',
                    label = 'Visual Settings'
                },
            },
            {
                notificationScale = {
                    key = 'vmodules.vuinotifications.notificationScale',
                    type = 'slider',
                    label = 'Notification Scale',
                    tooltip = 'Set the scale of on-screen notifications',
                    min = 0.5,
                    max = 2.0,
                    step = 0.1,
                    column = 3,
                    order = 1,
                    callback = function(self)
                        local module = VUI:GetModule("VUINotifications")
                        if module and module.db then
                            module.db.profile.notificationScale = self:GetValue()
                        end
                    end
                },
                notificationDuration = {
                    key = 'vmodules.vuinotifications.notificationDuration',
                    type = 'slider',
                    label = 'Notification Duration',
                    tooltip = 'How long notifications remain on screen (in seconds)',
                    min = 1,
                    max = 10,
                    step = 0.5,
                    column = 3,
                    order = 2,
                    callback = function(self)
                        local module = VUI:GetModule("VUINotifications")
                        if module and module.db then
                            module.db.profile.notificationDuration = self:GetValue()
                        end
                    end
                },
            },
        },
    }
end