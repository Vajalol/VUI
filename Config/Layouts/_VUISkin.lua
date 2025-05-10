local Layout = VUI:NewModule('Config.Layout.VUISkin')

function Layout:OnEnable()
    -- Database
    local db = VUI.db.namespaces.VUISkin

    -- Layout
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        database = db and db.profile,
        rows = {
            {
                header = {
                    type = 'header',
                    label = 'Details! Skin',
                },
            },
            {
                enabled = {
                    key = 'enabled',
                    type = 'checkbox',
                    label = 'Enable VUI Skin',
                    tooltip = 'Apply the VUI theme to Details! damage meter',
                    column = 3,
                    order = 1
                },
                autoApply = {
                    key = 'autoApply',
                    type = 'checkbox',
                    label = 'Auto Apply',
                    tooltip = 'Automatically apply the skin when Details! is loaded',
                    column = 3,
                    order = 2
                }
            },
            {
                header2 = {
                    type = 'header',
                    label = 'Actions',
                },
            },
            {
                applyNow = {
                    type = 'button',
                    text = 'Apply Skin Now',
                    onClick = function()
                        local VUISkin = VUI:GetModule("VUISkin")
                        if VUISkin then
                            VUISkin:ApplySkin()
                            VUI:Print("VUI skin applied to Details!")
                        end
                    end,
                    disabled = function() 
                        local VUISkin = VUI:GetModule("VUISkin")
                        return not VUISkin or not db.profile.enabled
                    end,
                    column = 3,
                    order = 1
                },
                removeSkin = {
                    type = 'button',
                    text = 'Remove Skin',
                    onClick = function()
                        local VUISkin = VUI:GetModule("VUISkin")
                        if VUISkin then
                            VUISkin:RemoveSkin()
                            VUI:Print("VUI skin removed from Details!")
                        end
                    end,
                    disabled = function() 
                        local VUISkin = VUI:GetModule("VUISkin")
                        return not VUISkin or not db.profile.enabled
                    end,
                    column = 3,
                    order = 2
                }
            },
            {
                header3 = {
                    type = 'header',
                    label = 'Information',
                },
            },
            {
                info = {
                    type = 'description',
                    text = "This module applies the VUI theme to Details! Damage Meter windows.\n\n" ..
                           "The skin will automatically update when you change the VUI theme color.\n\n" ..
                           "Note: Details! must be installed for this module to work.",
                    column = 3,
                    order = 1
                }
            }
        }
    }
end