--[[
    VUI Mouse Fire Trail Module Configuration
    Visual effects for mouse cursor movement
]]

local Layout = VUI:NewModule('Config.Layout.VUIMouseFireTrail')

-- Initialize with the standard layout helper
VUI.ConfigHelpers.CreateStandardLayout(Layout, "VUIMouseFireTrail", "VUI Mouse Effects", "vmodules.vuimousefiretrail")

-- Define module-specific layout construction
function Layout:BuildModuleLayout(module, db)
    -- Ensure module database is properly accessible
    if not module then return end
    
    -- Create necessary paths in database
    if not db.profile.vmodules then db.profile.vmodules = {} end
    if not db.profile.vmodules.vuimousefiretrail then 
        db.profile.vmodules.vuimousefiretrail = {}
    end
    
    -- Sync with vmodules path for UI
    if module.db and module.db.profile then
        db.profile.vmodules.vuimousefiretrail = module.db.profile
    end
    
    -- Extend the base layout with module-specific settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Mouse Trail Settings'
        },
    })
    
    -- Add basic settings
    table.insert(Layout.layout.rows, {
        enableTrail = {
            key = 'vmodules.vuimousefiretrail.enabled',
            type = 'checkbox',
            label = 'Enable Mouse Trail',
            tooltip = 'Enable trail effect for the mouse cursor',
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
        trailSize = {
            key = 'vmodules.vuimousefiretrail.trailSize',
            type = 'slider',
            label = 'Trail Size',
            tooltip = 'Set the size of each trail segment',
            min = 5,
            max = 100,
            step = 1,
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.trailSize = self:GetValue()
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
            max = 100,
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
    
    -- Trail Type Settings
    table.insert(Layout.layout.rows, {
        trailType = {
            key = 'vmodules.vuimousefiretrail.trailType',
            type = 'dropdown',
            label = 'Trail Type',
            tooltip = 'Select the type of trail effect',
            options = {
                {value = "PARTICLE", text = "Particle"},
                {value = "TEXTURE", text = "Texture"},
                {value = "SHAPE", text = "Shape"},
                {value = "GLOW", text = "Glow"}
            },
            column = 6,
            order = 1,
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
            tooltip = 'Select the shape for shape trail type',
            options = {
                {value = "V_SHAPE", text = "V Shape"},
                {value = "ARROW", text = "Arrow"},
                {value = "U_SHAPE", text = "U Shape"},
                {value = "ELLIPSE", text = "Ellipse"},
                {value = "SPIRAL", text = "Spiral"}
            },
            column = 6,
            order = 2,
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
    
    -- Color Settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Appearance Settings'
        },
    })
    
    table.insert(Layout.layout.rows, {
        colorMode = {
            key = 'vmodules.vuimousefiretrail.colorMode',
            type = 'dropdown',
            label = 'Color Mode',
            tooltip = 'Select the color scheme for the trail',
            options = {
                {value = "FIRE", text = "Fire"},
                {value = "ARCANE", text = "Arcane"},
                {value = "FROST", text = "Frost"},
                {value = "NATURE", text = "Nature"},
                {value = "RAINBOW", text = "Rainbow"},
                {value = "THEME", text = "Use Theme Color"},
                {value = "CUSTOM", text = "Custom Color"}
            },
            column = 6,
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
        trailAlpha = {
            key = 'vmodules.vuimousefiretrail.trailAlpha',
            type = 'slider',
            label = 'Trail Opacity',
            tooltip = 'Set the transparency of the trail',
            min = 0.1,
            max = 1.0,
            step = 0.05,
            column = 6,
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
    })
    
    -- Advanced Settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Advanced Settings'
        },
    })
    
    table.insert(Layout.layout.rows, {
        trailDecay = {
            key = 'vmodules.vuimousefiretrail.trailDecay',
            type = 'slider',
            label = 'Trail Decay',
            tooltip = 'How quickly the trail fades (higher = lasts longer)',
            min = 0.8,
            max = 0.98,
            step = 0.01,
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.trailDecay = self:GetValue()
                    if module.UpdateSettings then
                        module:UpdateSettings()
                    end
                end
            end
        },
        trailVariation = {
            key = 'vmodules.vuimousefiretrail.trailVariation',
            type = 'slider',
            label = 'Size Variation',
            tooltip = 'Random variation in the size of trail segments (0 = uniform size)',
            min = 0,
            max = 0.5,
            step = 0.05,
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.trailVariation = self:GetValue()
                    if module.UpdateSettings then
                        module:UpdateSettings()
                    end
                end
            end
        },
        trailSmoothing = {
            key = 'vmodules.vuimousefiretrail.trailSmoothing',
            type = 'slider',
            label = 'Frame Rate',
            tooltip = 'How frequently the trail updates (higher = smoother but more CPU)',
            min = 20,
            max = 120,
            step = 5,
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.trailSmoothing = self:GetValue()
                    if module.UpdateSettings then
                        module:UpdateSettings()
                    end
                end
            end
        },
    })
    
    -- Special Effects
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Special Effects'
        },
    })
    
    table.insert(Layout.layout.rows, {
        connectSegments = {
            key = 'vmodules.vuimousefiretrail.connectSegments',
            type = 'checkbox',
            label = 'Connect Segments',
            tooltip = 'Draw lines between trail segments',
            column = 4,
            order = 1,
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
            tooltip = 'Add a glow effect to the trail',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.enableGlow = self:GetValue()
                    if module.UpdateSettings then
                        module:UpdateSettings()
                    end
                end
            end
        },
        pulsingGlow = {
            key = 'vmodules.vuimousefiretrail.pulsingGlow',
            type = 'checkbox',
            label = 'Pulsing Glow',
            tooltip = 'Make the glow pulse in size and intensity',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.pulsingGlow = self:GetValue()
                    if module.UpdateSettings then
                        module:UpdateSettings()
                    end
                end
            end
        },
    })
    
    -- Display Conditions
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
            label = 'Show In Combat',
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
        showInRestArea = {
            key = 'vmodules.vuimousefiretrail.showInRestArea',
            type = 'checkbox',
            label = 'Show In Rest Areas',
            tooltip = 'Show trail effects in cities and inns',
            column = 4,
            order = 4,
            callback = function(self)
                if module and module.db then
                    module.db.profile.showInRestArea = self:GetValue()
                end
            end
        },
    })
    
    -- Trigger settings
    table.insert(Layout.layout.rows, {
        requireMouseButton = {
            key = 'vmodules.vuimousefiretrail.requireMouseButton',
            type = 'checkbox',
            label = 'Require Mouse Button',
            tooltip = 'Only show when a mouse button is held down',
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
            tooltip = 'Only show when a modifier key is held (Shift, Ctrl, Alt)',
            column = 6,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.requireModifierKey = self:GetValue()
                end
            end
        },
    })
end

-- Return the module
return Layout 