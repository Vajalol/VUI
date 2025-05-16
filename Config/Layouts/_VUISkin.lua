--[[
    VUI Skin Module Configuration
    UI skinning and customization for Blizzard frames
]]

local Layout = VUI:NewModule('Config.Layout.VUISkin')

-- Initialize with the standard layout helper
VUI.ConfigHelpers.CreateStandardLayout(Layout, "VUISkin", "VUI Skin", "vmodules.vuiskin")

-- Define module-specific layout construction
function Layout:BuildModuleLayout(module, db)
    -- Extend the base layout with module-specific settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Skin Settings'
        },
    })
    
    -- Add basic settings
    table.insert(Layout.layout.rows, {
        enableSkins = {
            key = 'vmodules.vuiskin.enableSkins',
            type = 'checkbox',
            label = 'Enable UI Skinning',
            tooltip = 'Enable the skinning of Blizzard UI elements',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.general.enableSkins = self:GetValue()
                    if module.RefreshAllSkins and self:GetValue() then
                        module:RefreshAllSkins()
                    end
                end
            end
        },
        forceFonts = {
            key = 'vmodules.vuiskin.forceFonts',
            type = 'checkbox',
            label = 'Force UI Fonts',
            tooltip = 'Force VUI fonts throughout the UI',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.fonts.enable = self:GetValue()
                    if module.ApplyFonts and self:GetValue() then
                        module:ApplyFonts()
                    end
                end
            end
        },
        applyShadows = {
            key = 'vmodules.vuiskin.applyShadows',
            type = 'checkbox',
            label = 'Apply Shadows',
            tooltip = 'Apply shadow effects to UI elements',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.general.applyShadows = self:GetValue()
                    if module.RefreshAllSkins then
                        module:RefreshAllSkins()
                    end
                end
            end
        },
    })
    
    -- Theme settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Theme Settings'
        },
    })
    
    table.insert(Layout.layout.rows, {
        primaryColor = {
            key = 'vmodules.vuiskin.primaryColor',
            type = 'color',
            label = 'Primary Color',
            tooltip = 'Set the primary color for UI elements',
            hasAlpha = true,
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    local r, g, b, a = self:GetRGBA()
                    module.db.profile.colors.primary = {r, g, b, a}
                    if module.RefreshAllSkins then
                        module:RefreshAllSkins()
                    end
                end
            end
        },
        accentColor = {
            key = 'vmodules.vuiskin.accentColor',
            type = 'color',
            label = 'Accent Color',
            tooltip = 'Set the accent color for UI highlights',
            hasAlpha = true,
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    local r, g, b, a = self:GetRGBA()
                    module.db.profile.colors.accent = {r, g, b, a}
                    if module.RefreshAllSkins then
                        module:RefreshAllSkins()
                    end
                end
            end
        },
        borderColor = {
            key = 'vmodules.vuiskin.borderColor',
            type = 'color',
            label = 'Border Color',
            tooltip = 'Set the border color for UI frames',
            hasAlpha = true,
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    local r, g, b, a = self:GetRGBA()
                    module.db.profile.colors.border = {r, g, b, a}
                    if module.RefreshAllSkins then
                        module:RefreshAllSkins()
                    end
                end
            end
        },
    })
    
    -- UI elements to skin
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'UI Elements to Skin'
        },
    })
    
    table.insert(Layout.layout.rows, {
        skinActionBars = {
            key = 'vmodules.vuiskin.skinActionBars',
            type = 'checkbox',
            label = 'Action Bars',
            tooltip = 'Apply skin to action bars',
            column = 3,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.elements.actionBars = self:GetValue()
                    if module.RefreshActionBarSkins and self:GetValue() then
                        module:RefreshActionBarSkins()
                    end
                end
            end
        },
        skinUnitFrames = {
            key = 'vmodules.vuiskin.skinUnitFrames',
            type = 'checkbox',
            label = 'Unit Frames',
            tooltip = 'Apply skin to unit frames',
            column = 3,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.elements.unitFrames = self:GetValue()
                    if module.RefreshUnitFrameSkins and self:GetValue() then
                        module:RefreshUnitFrameSkins()
                    end
                end
            end
        },
        skinChat = {
            key = 'vmodules.vuiskin.skinChat',
            type = 'checkbox',
            label = 'Chat Frames',
            tooltip = 'Apply skin to chat frames',
            column = 3,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.elements.chat = self:GetValue()
                    if module.RefreshChatSkins and self:GetValue() then
                        module:RefreshChatSkins()
                    end
                end
            end
        },
        skinBags = {
            key = 'vmodules.vuiskin.skinBags',
            type = 'checkbox',
            label = 'Bags',
            tooltip = 'Apply skin to bags and inventory',
            column = 3,
            order = 4,
            callback = function(self)
                if module and module.db then
                    module.db.profile.elements.bags = self:GetValue()
                    if module.RefreshBagSkins and self:GetValue() then
                        module:RefreshBagSkins()
                    end
                end
            end
        },
    })
end

return Layout 