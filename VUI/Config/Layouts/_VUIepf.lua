local Layout = VUI:NewModule('Config.Layout.VUIepf')

function Layout:OnEnable()
    -- Database
    local db = VUI.db
    
    -- Module reference
    local VUIepf = VUI:GetModule("VUIepf")
    
    -- Gather custom frame modes
    local customFrameOptions = {}
    if VUIepf and VUIepf.CUSTOM_FRAME_MODES then
        for i, mode in ipairs(VUIepf.CUSTOM_FRAME_MODES) do
            table.insert(customFrameOptions, { text = mode[1], value = i })
        end
    end
    
    -- If no custom frames are found, provide a default option
    if #customFrameOptions == 0 then
        table.insert(customFrameOptions, { text = "Default", value = 1 })
    end
    
    -- Layout
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        database = db.profile,
        rows = {
            {
                header = {
                    type = 'header',
                    label = 'VUI Enhanced Player Frame'
                },
            },
            {
                enabled = {
                    key = 'vmodules.vuiepf.enabled',
                    type = 'checkbox',
                    label = 'Enable Enhanced Player Frame',
                    tooltip = 'Enable or disable the enhanced player frame appearance',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        -- Update the saved variable
                        if VUIepf and VUIepf.db then
                            VUIepf.db.profile.enabled = self:GetValue()
                            -- Update display based on new value
                            if self:GetValue() then
                                if VUIepf.OnEnable then VUIepf:OnEnable() end
                            else
                                if VUIepf.OnDisable then VUIepf:OnDisable() end
                            end
                        end
                    end
                },
            },
            {
                header = {
                    type = 'header',
                    label = 'Frame Appearance'
                },
            },
            {
                frameMode = {
                    key = 'vmodules.vuiepf.frameMode',
                    type = 'dropdown',
                    label = 'Frame Mode',
                    tooltip = 'Select the player frame appearance',
                    options = {
                        { text = 'Default', value = 0 },
                        { text = 'Elite (Dragon)', value = 1 },
                        { text = 'Rare (Silver)', value = 2 },
                        { text = 'Rare Elite (Silver Dragon)', value = 3 },
                        { text = 'Custom', value = 4 }
                    },
                    column = 4,
                    order = 1,
                    callback = function(self)
                        if VUIepf and VUIepf.db then
                            VUIepf.db.profile.frameMode = self:GetSelectedItem().value
                            if VUIepf.ApplyFrameMode then
                                VUIepf:ApplyFrameMode(VUIepf.db.profile.frameMode, VUIepf.db.profile.customFrameMode)
                            end
                        end
                    end
                },
            },
            {
                customFrameMode = {
                    key = 'vmodules.vuiepf.customFrameMode',
                    type = 'dropdown',
                    label = 'Custom Frame Style',
                    tooltip = 'Select the custom frame style to use (only when Frame Mode is set to Custom)',
                    options = customFrameOptions,
                    column = 4,
                    order = 1,
                    callback = function(self)
                        if VUIepf and VUIepf.db then
                            VUIepf.db.profile.customFrameMode = self:GetSelectedItem().value
                            if VUIepf.db.profile.frameMode == 4 and VUIepf.ApplyCustomFrame then
                                VUIepf:ApplyCustomFrame(VUIepf.db.profile.customFrameMode)
                            end
                        end
                    end
                },
                classSelection = {
                    key = 'vmodules.vuiepf.classSelection',
                    type = 'checkbox',
                    label = 'Use Class-Specific Frames',
                    tooltip = 'Automatically select frame based on character class',
                    column = 4,
                    order = 2,
                    callback = function(self)
                        if VUIepf and VUIepf.db then
                            VUIepf.db.profile.classSelection = self:GetValue()
                            if VUIepf.ApplyFrameMode then
                                VUIepf:ApplyFrameMode(VUIepf.db.profile.frameMode, VUIepf.db.profile.customFrameMode)
                            end
                        end
                    end
                },
            },
            {
                header = {
                    type = 'header',
                    label = 'Advanced Settings'
                },
            },
            {
                showFrameLevel = {
                    key = 'vmodules.vuiepf.showFrameLevel',
                    type = 'checkbox',
                    label = 'Show Frame Level',
                    tooltip = 'Display frame level information for debugging',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        if VUIepf and VUIepf.db then
                            VUIepf.db.profile.showFrameLevel = self:GetValue()
                            -- Trigger update if needed
                        end
                    end
                },
                observeFrameLevel = {
                    key = 'vmodules.vuiepf.observeFrameLevel',
                    type = 'checkbox',
                    label = 'Observe Frame Level Changes',
                    tooltip = 'Monitor frame level changes for debugging',
                    column = 4,
                    order = 2,
                    callback = function(self)
                        if VUIepf and VUIepf.db then
                            VUIepf.db.profile.observeFrameLevel = self:GetValue()
                            -- Trigger update if needed
                        end
                    end
                },
                showAddonCompartment = {
                    key = 'vmodules.vuiepf.showAddonCompartment',
                    type = 'checkbox',
                    label = 'Show in Addon Compartment',
                    tooltip = 'Show this addon in the addon compartment button',
                    column = 4,
                    order = 3,
                    callback = function(self)
                        if VUIepf and VUIepf.db then
                            VUIepf.db.profile.showAddonCompartment = self:GetValue()
                            -- Trigger update if needed
                        end
                    end
                },
            },
            {
                outputLevel = {
                    key = 'vmodules.vuiepf.outputLevel',
                    type = 'dropdown',
                    label = 'Message Output Level',
                    tooltip = 'Set the verbosity level for addon messages',
                    options = {
                        { text = 'Critical Errors Only', value = 0 },
                        { text = 'Errors', value = 1 },
                        { text = 'Warnings', value = 2 },
                        { text = 'Notices', value = 3 },
                        { text = 'Debug', value = 4 }
                    },
                    column = 4,
                    order = 1,
                    callback = function(self)
                        if VUIepf and VUIepf.db then
                            VUIepf.db.profile.outputLevel = self:GetSelectedItem().value
                        end
                    end
                },
            },
        },
    }
end