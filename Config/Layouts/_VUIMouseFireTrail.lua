--[[
    VUI Mouse Fire Trail Module Configuration
    Visual effects for mouse cursor movement
]]

local Layout = VUI:NewModule('Config.Layout.VUIMouseFireTrail')

-- Initialize with the standard layout helper
VUI.ConfigHelpers.CreateStandardLayout(Layout, "VUIMouseFireTrail", "VUI Mouse Effects", "vmodules.vuimousefiretrail")

-- Define module-specific layout construction
function Layout:BuildModuleLayout(module, db)
    -- Extend the base layout with module-specific settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Mouse Effect Settings'
        },
    })
    
    -- Add basic settings
    table.insert(Layout.layout.rows, {
        enableTrail = {
            key = 'vmodules.vuimousefiretrail.enabled',
            type = 'checkbox',
            label = 'Enable Fire Trail',
            tooltip = 'Enable fire trail effect for the mouse cursor',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.enabled = self:GetValue()
                    if module.UpdateSettings then
                        module:UpdateSettings()
                    end
                end
            end
        },
        connectSegments = {
            key = 'vmodules.vuimousefiretrail.connectSegments',
            type = 'checkbox',
            label = 'Connect Segments',
            tooltip = 'Connect trail segments with lines',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.connectSegments = self:GetValue()
                    if module.UpdateSettings then
                        module:UpdateSettings()
                    end
                end
            end
        },
        enableGlow = {
            key = 'vmodules.vuimousefiretrail.enableGlow',
            type = 'checkbox',
            label = 'Enable Glow',
            tooltip = 'Add glow effect to the trail',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.enableGlow = self:GetValue()
                    if module.UpdateSettings then
                        module:UpdateSettings()
                    end
                end
            end
        },
    })
    
    -- Display conditions
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Display Conditions'
        },
    })
    
    table.insert(Layout.layout.rows, {
        showInCombat = {
            key = 'vmodules.vuimousefiretrail.showInCombat',
            type = 'checkbox',
            label = 'Show During Combat',
            tooltip = 'Show trail effects during combat',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.showInCombat = self:GetValue()
                end
            end
        },
        showInInstances = {
            key = 'vmodules.vuimousefiretrail.showInInstances',
            type = 'checkbox',
            label = 'Show In Instances',
            tooltip = 'Show trail effects in dungeons and raids',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.showInInstances = self:GetValue()
                end
            end
        },
        showInWorld = {
            key = 'vmodules.vuimousefiretrail.showInWorld',
            type = 'checkbox',
            label = 'Show In World',
            tooltip = 'Show trail effects in the open world',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.showInWorld = self:GetValue()
                end
            end
        },
    })
    
    table.insert(Layout.layout.rows, {
        requireMouseButton = {
            key = 'vmodules.vuimousefiretrail.requireMouseButton',
            type = 'checkbox',
            label = 'Require Mouse Button',
            tooltip = 'Only show effects when a mouse button is held',
            column = 6,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.requireMouseButton = self:GetValue()
                end
            end
        },
        requireModifierKey = {
            key = 'vmodules.vuimousefiretrail.requireModifierKey',
            type = 'checkbox',
            label = 'Require Modifier Key',
            tooltip = 'Only show effects when a modifier key is held (Shift, Ctrl, Alt)',
            column = 6,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.requireModifierKey = self:GetValue()
                end
            end
        },
    })
    
    -- Effect configuration
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Effect Configuration'
        },
    })
    
    table.insert(Layout.layout.rows, {
        effectType = {
            key = 'vmodules.vuimousefiretrail.colorMode',
            type = 'dropdown',
            label = 'Effect Type',
            tooltip = 'Select the type of visual effect',
            options = {
                {value = "FIRE", text = "Fire"},
                {value = "ARCANE", text = "Arcane"},
                {value = "FROST", text = "Frost"},
                {value = "NATURE", text = "Nature"},
                {value = "RAINBOW", text = "Rainbow"},
                {value = "THEME", text = "Theme Color"},
                {value = "CUSTOM", text = "Custom Color"}
            },
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.colorMode = self:GetValue()
                    if module.UpdateSettings then
                        module:UpdateSettings()
                    end
                end
            end
        },
        trailType = {
            key = 'vmodules.vuimousefiretrail.trailType',
            type = 'dropdown',
            label = 'Trail Type',
            tooltip = 'Select the type of trail',
            options = {
                {value = "PARTICLE", text = "Particle"},
                {value = "TEXTURE", text = "Texture"},
                {value = "GLOW", text = "Glow"},
                {value = "SHAPE", text = "Shape"}
            },
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.trailType = self:GetValue()
                    if module.UpdateSettings then
                        module:UpdateSettings()
                    end
                end
            end
        },
        trailShape = {
            key = 'vmodules.vuimousefiretrail.trailShape',
            type = 'dropdown',
            label = 'Trail Shape',
            tooltip = 'Select the shape of the trail',
            options = {
                {value = "V_SHAPE", text = "V Shape"},
                {value = "ARROW", text = "Arrow"},
                {value = "U_SHAPE", text = "U Shape"},
                {value = "ELLIPSE", text = "Ellipse"},
                {value = "SPIRAL", text = "Spiral"}
            },
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.trailShape = self:GetValue()
                    if module.UpdateSettings then
                        module:UpdateSettings()
                    end
                end
            end
        },
    })
    
    -- Advanced settings
    table.insert(Layout.layout.rows, {
        effectSize = {
            key = 'vmodules.vuimousefiretrail.trailSize',
            type = 'slider',
            label = 'Effect Size',
            tooltip = 'Set the size of each trail segment',
            min = 5,
            max = 100,
            step = 1,
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.trailSize = self:GetValue()
                    if module.UpdateSettings then
                        module:UpdateSettings()
                    end
                end
            end
        },
        effectOpacity = {
            key = 'vmodules.vuimousefiretrail.trailAlpha',
            type = 'slider',
            label = 'Effect Opacity',
            tooltip = 'Set the opacity of the trail effect',
            min = 0.1,
            max = 1.0,
            step = 0.1,
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.trailAlpha = self:GetValue()
                    if module.UpdateSettings then
                        module:UpdateSettings()
                    end
                end
            end
        },
        trailCount = {
            key = 'vmodules.vuimousefiretrail.trailCount',
            type = 'slider',
            label = 'Trail Length',
            tooltip = 'Set the number of segments in the trail',
            min = 5,
            max = 50,
            step = 1, 
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.trailCount = self:GetValue()
                    if module.UpdateSettings then
                        module:UpdateSettings()
                    end
                end
            end
        },
    })
    
    -- Theme integration
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Theme Integration'
        },
    })
    
    table.insert(Layout.layout.rows, {
        useThemeColor = {
            key = 'vmodules.vuimousefiretrail.useThemeColor',
            type = 'checkbox',
            label = 'Use Theme Color',
            tooltip = 'Use the VUI theme color for trail effects',
            column = 12,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.useThemeColor = self:GetValue()
                    if module.UpdateSettings then
                        module:UpdateSettings()
                    end
                end
            end
        },
    })
end

return Layout 