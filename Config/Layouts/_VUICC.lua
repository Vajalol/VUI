--[[
    VUI Cooldown Counter Module Configuration
    Adds text to cooldowns to indicate when they'll be ready (OmniCC equivalent)
]]

local Layout = VUI:NewModule('Config.Layout.VUICC')

-- Initialize with the standard layout helper
VUI.ConfigHelpers.CreateStandardLayout(Layout, "VUICC", "VUI Cooldown Counter", "vmodules.vuicc")

-- Define module-specific layout construction
function Layout:BuildModuleLayout(module, db)
    -- Extend the base layout with module-specific settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Cooldown Text Settings'
        },
    })
    
    -- Add basic settings
    table.insert(Layout.layout.rows, {
        enabled = {
            key = 'vmodules.vuicc.enabled',
            type = 'checkbox',
            label = 'Enable Cooldown Text',
            tooltip = 'Enable text on cooldowns to indicate when they\'ll be ready',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.enabled = self:GetValue()
                    if module.RefreshConfig then
                        module:RefreshConfig()
                    end
                end
            end
        },
        disableBlizzardCooldownText = {
            key = 'vmodules.vuicc.disableBlizzardCooldownText',
            type = 'checkbox',
            label = 'Disable Blizzard Cooldown Text',
            tooltip = 'Hide Blizzard\'s built-in cooldown text (requires UI reload)',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.disableBlizzardCooldownText = self:GetValue()
                    StaticPopup_Show("VUI_RELOAD_UI")
                end
            end
        },
        cooldownOpacity = {
            key = 'vmodules.vuicc.cooldownOpacity',
            type = 'slider',
            label = 'Cooldown Opacity',
            tooltip = 'Set the opacity of the cooldown spiral animation',
            min = 0,
            max = 1,
            step = 0.05,
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.cooldownOpacity = self:GetValue()
                    if module.RefreshConfig then
                        module:RefreshConfig()
                    end
                end
            end
        },
    })
    
    -- Font settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Font Settings'
        },
    })
    
    table.insert(Layout.layout.rows, {
        fontSize = {
            key = 'vmodules.vuicc.fontSize',
            type = 'slider',
            label = 'Font Size',
            tooltip = 'Set the size of the cooldown text font',
            min = 8,
            max = 36,
            step = 1,
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.fontSize = self:GetValue()
                    if module.RefreshConfig then
                        module:RefreshConfig()
                    end
                end
            end
        },
        fontOutline = {
            key = 'vmodules.vuicc.fontOutline',
            type = 'dropdown',
            label = 'Font Outline',
            tooltip = 'Select the type of outline for cooldown text',
            options = {
                {value = "NONE", text = "None"},
                {value = "OUTLINE", text = "Outline"},
                {value = "THICKOUTLINE", text = "Thick Outline"},
                {value = "MONOCHROME", text = "Monochrome"}
            },
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.fontOutline = self:GetValue()
                    if module.RefreshConfig then
                        module:RefreshConfig()
                    end
                end
            end
        },
        scaleText = {
            key = 'vmodules.vuicc.scaleText',
            type = 'checkbox',
            label = 'Scale Text With Icon',
            tooltip = 'Scale the cooldown text based on the icon size',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.scaleText = self:GetValue()
                    if module.RefreshConfig then
                        module:RefreshConfig()
                    end
                end
            end
        },
    })
    
    -- Duration thresholds
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Display Thresholds'
        },
    })
    
    table.insert(Layout.layout.rows, {
        minDuration = {
            key = 'vmodules.vuicc.minDuration',
            type = 'slider',
            label = 'Minimum Duration',
            tooltip = 'Minimum cooldown duration to display text (in seconds)',
            min = 0,
            max = 30,
            step = 0.5,
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.minDuration = self:GetValue()
                    if module.RefreshConfig then
                        module:RefreshConfig()
                    end
                end
            end
        },
        minScale = {
            key = 'vmodules.vuicc.minScale',
            type = 'slider',
            label = 'Minimum Scale',
            tooltip = 'Minimum scale of an icon to show cooldown text (relative to action button size)',
            min = 0.1,
            max = 1,
            step = 0.05,
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.minScale = self:GetValue()
                    if module.RefreshConfig then
                        module:RefreshConfig()
                    end
                end
            end
        },
        mmssThreshold = {
            key = 'vmodules.vuicc.mmssThreshold',
            type = 'slider',
            label = 'MM:SS Format Threshold',
            tooltip = 'Show MM:SS format when cooldown is greater than this value (in seconds)',
            min = 0,
            max = 300,
            step = 10,
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.mmssThreshold = self:GetValue()
                    if module.RefreshConfig then
                        module:RefreshConfig()
                    end
                end
            end
        },
    })
    
    table.insert(Layout.layout.rows, {
        tenthsThreshold = {
            key = 'vmodules.vuicc.tenthsThreshold',
            type = 'slider',
            label = 'Tenths Format Threshold',
            tooltip = 'Show tenths of seconds when cooldown is less than this value (in seconds)',
            min = 0,
            max = 10,
            step = 0.5,
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.tenthsThreshold = self:GetValue()
                    if module.RefreshConfig then
                        module:RefreshConfig()
                    end
                end
            end
        },
    })
    
    -- Color settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Color Settings'
        },
    })
    
    table.insert(Layout.layout.rows, {
        useThemeColors = {
            key = 'vmodules.vuicc.useThemeColors',
            type = 'checkbox',
            label = 'Use Theme Colors',
            tooltip = 'Use the VUI theme colors for cooldown text',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.useThemeColors = self:GetValue()
                    if module.RefreshConfig then
                        module:RefreshConfig()
                    end
                end
            end
        },
        useClassColors = {
            key = 'vmodules.vuicc.useClassColors',
            type = 'checkbox',
            label = 'Use Class Colors',
            tooltip = 'Use class colors for cooldown text',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.useClassColors = self:GetValue()
                    if module.RefreshConfig then
                        module:RefreshConfig()
                    end
                end
            end
        },
    })
    
    -- Finish effect
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Finish Effects'
        },
    })
    
    table.insert(Layout.layout.rows, {
        effect = {
            key = 'vmodules.vuicc.effect',
            type = 'dropdown',
            label = 'Finish Effect',
            tooltip = 'Effect to show when a cooldown completes',
            options = {
                {value = "NONE", text = "None"},
                {value = "PULSE", text = "Pulse"},
                {value = "SHINE", text = "Shine"},
                {value = "ALERT", text = "Alert"},
                {value = "FLARE", text = "Flare"}
            },
            column = 6,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.effect = self:GetValue()
                    if module.RefreshConfig then
                        module:RefreshConfig()
                    end
                end
            end
        },
    })
    
    -- Advanced options
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Advanced Options'
        },
    })
    
    table.insert(Layout.layout.rows, {
        openOptions = {
            type = 'button',
            label = 'Open Full Configuration',
            tooltip = 'Open the detailed cooldown counter configuration panel',
            column = 6,
            order = 1,
            callback = function()
                if module and module.SlashCommand then
                    module:SlashCommand("")
                end
            end
        }
    })
end

return Layout 