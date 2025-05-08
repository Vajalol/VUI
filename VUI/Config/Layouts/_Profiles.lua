local Layout = VUI:NewModule('Config.Layout.Profiles')

function Layout:OnEnable()
    -- Database
    local db = VUI.db

    -- Components
    local VUIConfig = LibStub('VUIConfig')
    local ProfileExport = VUI:GetModule("Config.Components.ProfileExport")
    local ProfileImport = VUI:GetModule("Config.Components.ProfileImport")

    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        rows = {
            {
                header = {
                    type = 'header',
                    label = 'Profile Sharing'
                },
            },
            {
                export = {
                    type = 'button',
                    text = 'Export',
                    onClick = function()
                        ProfileExport.Show(tostring(db))
                    end,
                    column = 3,
                    order = 1
                },
                import = {
                    type = 'button',
                    text = 'Import',
                    onClick = function()
                        ProfileImport.Show()
                    end,
                    column = 3,
                    order = 2
                },
                reset = {
                    type = 'button',
                    text = 'Reset UI',
                    onClick = function()
                        local buttons = {
                            ok = {
                                text    = 'Confirm',
                                onClick = function() db:ResetProfile() ReloadUI() end
                            },
                            cancel = {
                                text    = 'Cancel',
                                onClick = function(self) self:GetParent():Hide() end
                            }
                        }
                        VUIConfig:Confirm('Reset UI', 'This will reset all your VUI settings!', buttons)
                    end,
                    column = 3,
                    order = 3
                }
            }
        },
    }
end