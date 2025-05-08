local Layout = VUI:NewModule('Config.Layout.VUIAnyFrame')

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
                    label = 'VUI AnyFrame'
                },
            },
            {
                enabled = {
                    key = 'vmodules.vuianyframe.enabled',
                    type = 'checkbox',
                    label = 'Enable VUI AnyFrame',
                    tooltip = 'Enable or disable the VUI AnyFrame module',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        -- Update the saved variable in VUIAnyFrame
                        if VUIAnyFrame and VUIAnyFrame.db then
                            VUIAnyFrame.db.profile.general.enabled = self:GetValue()
                            if VUIAnyFrame.UpdateAllFrames then
                                VUIAnyFrame:UpdateAllFrames()
                            end
                        end
                    end
                },
            },
            {
                lockFrames = {
                    key = 'vmodules.vuianyframe.lockFrames',
                    type = 'checkbox',
                    label = 'Lock Frames',
                    tooltip = 'Lock or unlock VUI AnyFrame frames',
                    column = 4,
                    order = 2,
                    callback = function(self)
                        -- Update the saved variable in VUIAnyFrame
                        if VUIAnyFrame and VUIAnyFrame.db then
                            VUIAnyFrame.db.profile.general.lockFrames = self:GetValue()
                            if self:GetValue() then
                                VUIAnyFrame:LockFrames()
                            else
                                VUIAnyFrame:UnlockFrames()
                            end
                        end
                    end
                },
            },
            {
                resetAll = {
                    type = 'button',
                    label = 'Reset All Frames',
                    tooltip = 'Reset all frame positions to default',
                    column = 4,
                    order = 3,
                    callback = function()
                        if VUIAnyFrame and VUIAnyFrame.ResetAllFrames then
                            VUIAnyFrame:ResetAllFrames()
                        end
                    end
                },
            },
            {
                openConfig = {
                    type = 'button',
                    label = 'Open VUI AnyFrame Config',
                    tooltip = 'Open the full VUI AnyFrame configuration panel',
                    column = 4,
                    order = 4,
                    callback = function()
                        if VUIAnyFrame and VUIAnyFrame.OpenOptions then
                            VUIAnyFrame:OpenOptions()
                        end
                    end
                },
            },
            {
                desc = {
                    type = 'description',
                    text = 'VUI AnyFrame allows you to move and resize nearly any frame in the World of Warcraft interface. Use the slash command /va or /vuianyframe to access more options.',
                    column = 8,
                    order = 5,
                },
            },
            {
                header2 = {
                    type = 'header',
                    label = 'Common Frames'
                },
            },
            {
                unlockFrames = {
                    type = 'button',
                    label = 'Unlock Frames',
                    tooltip = 'Unlock all frames for movement',
                    column = 4,
                    order = 6,
                    callback = function()
                        if VUIAnyFrame and VUIAnyFrame.UnlockFrames then
                            VUIAnyFrame:UnlockFrames()
                        end
                    end
                },
            },
            {
                lockFramesButton = {
                    type = 'button',
                    label = 'Lock Frames',
                    tooltip = 'Lock all frames after moving',
                    column = 4,
                    order = 7,
                    callback = function()
                        if VUIAnyFrame and VUIAnyFrame.LockFrames then
                            VUIAnyFrame:LockFrames()
                        end
                    end
                },
            },
        },
    }
end