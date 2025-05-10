local Layout = VUI:NewModule('Config.Layout.VUIMouseFireTrail')

function Layout:OnEnable()
    -- Database
    local db = VUI.db
    
    -- Module reference
    local VUIMouseFireTrail = VUI:GetModule("VUIMouseFireTrail")
    
    -- Layout
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        database = db.profile,
        rows = {
            {
                header = {
                    type = 'header',
                    label = 'VUI Mouse Cursor Effects',
                    description = 'Customize cursor trails and effects'
                },
            },
            {
                enabled = {
                    key = 'vmodules.vuimousefiretrail.enabled',
                    type = 'checkbox',
                    label = 'Enable Cursor Effects',
                    tooltip = 'Enable or disable the mouse cursor trail effects',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        -- Update the saved variable
                        if VUIMouseFireTrail and VUIMouseFireTrail.db then
                            VUIMouseFireTrail.db.profile.enabled = self:GetValue()
                            -- Update display based on new value
                            if self:GetValue() then
                                if VUIMouseFireTrail.OnEnable then VUIMouseFireTrail:OnEnable() end
                            else
                                if VUIMouseFireTrail.OnDisable then VUIMouseFireTrail:OnDisable() end
                            end
                        end
                    end
                },
            },
            {
                header = {
                    type = 'header',
                    label = 'Trail Settings'
                },
            },
            {
                trailType = {
                    key = 'vmodules.vuimousefiretrail.trailType',
                    type = 'dropdown',
                    label = 'Trail Type',
                    tooltip = 'Select the type of trail effect',
                    options = {
                        { text = 'Particle', value = 'PARTICLE' },
                        { text = 'Texture', value = 'TEXTURE' },
                        { text = 'Shape', value = 'SHAPE' },
                        { text = 'Glow', value = 'GLOW' }
                    },
                    column = 4,
                    order = 1,
                    callback = function(self)
                        if VUIMouseFireTrail and VUIMouseFireTrail.db then
                            VUIMouseFireTrail.db.profile.trailType = self:GetSelectedItem().value
                            if VUIMouseFireTrail.CreateTrailFrames then
                                VUIMouseFireTrail:CreateTrailFrames()
                            end
                        end
                    end
                },
                colorMode = {
                    key = 'vmodules.vuimousefiretrail.colorMode',
                    type = 'dropdown',
                    label = 'Color Mode',
                    tooltip = 'Select the coloring style for the trail',
                    options = {
                        { text = 'Fire', value = 'FIRE' },
                        { text = 'Arcane', value = 'ARCANE' },
                        { text = 'Frost', value = 'FROST' },
                        { text = 'Nature', value = 'NATURE' },
                        { text = 'Rainbow', value = 'RAINBOW' },
                        { text = 'Theme Color', value = 'THEME' },
                        { text = 'Custom Color', value = 'CUSTOM' }
                    },
                    column = 4,
                    order = 2,
                    callback = function(self)
                        if VUIMouseFireTrail and VUIMouseFireTrail.db then
                            VUIMouseFireTrail.db.profile.colorMode = self:GetSelectedItem().value
                            if VUIMouseFireTrail.UpdateTheme then
                                VUIMouseFireTrail:UpdateTheme()
                            end
                        end
                    end
                },
            },
            {
                trailCount = {
                    key = 'vmodules.vuimousefiretrail.trailCount',
                    type = 'slider',
                    label = 'Trail Count',
                    tooltip = 'Number of segments in the trail',
                    min = 5,
                    max = 50,
                    step = 1,
                    column = 6,
                    order = 1,
                    callback = function(self)
                        if VUIMouseFireTrail and VUIMouseFireTrail.db then
                            VUIMouseFireTrail.db.profile.trailCount = self:GetValue()
                            if VUIMouseFireTrail.CreateTrailFrames then
                                VUIMouseFireTrail:CreateTrailFrames()
                            end
                        end
                    end
                },
                trailSize = {
                    key = 'vmodules.vuimousefiretrail.trailSize',
                    type = 'slider',
                    label = 'Trail Size',
                    tooltip = 'Size of each trail segment',
                    min = 5,
                    max = 50,
                    step = 1,
                    column = 6,
                    order = 2,
                    callback = function(self)
                        if VUIMouseFireTrail and VUIMouseFireTrail.db then
                            VUIMouseFireTrail.db.profile.trailSize = self:GetValue()
                            if VUIMouseFireTrail.CreateTrailFrames then
                                VUIMouseFireTrail:CreateTrailFrames()
                            end
                        end
                    end
                },
            },
            {
                header = {
                    type = 'header',
                    label = 'Display Settings'
                },
            },
            {
                showInCombat = {
                    key = 'vmodules.vuimousefiretrail.showInCombat',
                    type = 'checkbox',
                    label = 'Show During Combat',
                    tooltip = 'Show the cursor trail during combat',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        if VUIMouseFireTrail and VUIMouseFireTrail.db then
                            VUIMouseFireTrail.db.profile.showInCombat = self:GetValue()
                        end
                    end
                },
                showInInstances = {
                    key = 'vmodules.vuimousefiretrail.showInInstances',
                    type = 'checkbox',
                    label = 'Show In Instances',
                    tooltip = 'Show the cursor trail in dungeons and raids',
                    column = 4,
                    order = 2,
                    callback = function(self)
                        if VUIMouseFireTrail and VUIMouseFireTrail.db then
                            VUIMouseFireTrail.db.profile.showInInstances = self:GetValue()
                        end
                    end
                },
                showInRestArea = {
                    key = 'vmodules.vuimousefiretrail.showInRestArea',
                    type = 'checkbox',
                    label = 'Show In Rest Areas',
                    tooltip = 'Show the cursor trail in cities and inns',
                    column = 4,
                    order = 3,
                    callback = function(self)
                        if VUIMouseFireTrail and VUIMouseFireTrail.db then
                            VUIMouseFireTrail.db.profile.showInRestArea = self:GetValue()
                            if VUIMouseFireTrail.UpdateVisibility then
                                VUIMouseFireTrail:UpdateVisibility()
                            end
                        end
                    end
                },
            },
            {
                enableInWorld = {
                    key = 'vmodules.vuimousefiretrail.enableInWorld',
                    type = 'checkbox',
                    label = 'Show In Open World',
                    tooltip = 'Show the fire trail in the open world',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        if VUIMouseFireTrail and VUIMouseFireTrail.db then
                            VUIMouseFireTrail.db.profile.enableInWorld = self:GetValue()
                            if VUIMouseFireTrail.UpdateVisibility then
                                VUIMouseFireTrail:UpdateVisibility()
                            end
                        end
                    end
                },
                hideWithUI = {
                    key = 'vmodules.vuimousefiretrail.hideWithUI',
                    type = 'checkbox',
                    label = 'Hide With UI',
                    tooltip = 'Hide the fire trail when the UI is hidden',
                    column = 4,
                    order = 2,
                    callback = function(self)
                        if VUIMouseFireTrail and VUIMouseFireTrail.db then
                            VUIMouseFireTrail.db.profile.hideWithUI = self:GetValue()
                            if VUIMouseFireTrail.UpdateVisibility then
                                VUIMouseFireTrail:UpdateVisibility()
                            end
                        end
                    end
                },
            },
            {
                header = {
                    type = 'header',
                    label = 'Appearance'
                },
            },
            {
                colorMode = {
                    key = 'vmodules.vuimousefiretrail.colorMode',
                    type = 'dropdown',
                    label = 'Particle Style',
                    tooltip = 'Choose the visual style of the trail particles',
                    options = {
                        { text = 'Fire', value = 'FIRE' },
                        { text = 'Arcane', value = 'ARCANE' },
                        { text = 'Frost', value = 'FROST' },
                        { text = 'Nature', value = 'NATURE' },
                        { text = 'Rainbow', value = 'RAINBOW' },
                        { text = 'Custom Color', value = 'CUSTOM' }
                    },
                    column = 4,
                    order = 1,
                    callback = function(self)
                        if VUIMouseFireTrail and VUIMouseFireTrail.db then
                            VUIMouseFireTrail.db.profile.colorMode = self:GetSelectedItem().value
                            if VUIMouseFireTrail.InitParticles then
                                VUIMouseFireTrail:InitParticles()
                            end
                        end
                    end
                },
                customColorPicker = {
                    key = 'vmodules.vuimousefiretrail.customColor',
                    type = 'color',
                    label = 'Custom Color',
                    tooltip = 'Choose a custom color for particles (only used with Custom Color style)',
                    column = 4,
                    order = 2,
                    callback = function(self, r, g, b)
                        if VUIMouseFireTrail and VUIMouseFireTrail.db then
                            VUIMouseFireTrail.db.profile.customColor = {r = r, g = g, b = b}
                            if VUIMouseFireTrail.InitParticles then
                                VUIMouseFireTrail:InitParticles()
                            end
                        end
                    end
                },
            },
            {
                particleSize = {
                    key = 'vmodules.vuimousefiretrail.particleSize',
                    type = 'slider',
                    label = 'Particle Size',
                    tooltip = 'Set the size of each particle',
                    min = 10,
                    max = 50,
                    step = 1,
                    column = 3,
                    order = 1,
                    callback = function(self)
                        if VUIMouseFireTrail and VUIMouseFireTrail.db then
                            VUIMouseFireTrail.db.profile.particleSize = self:GetValue()
                            if VUIMouseFireTrail.UpdateParticleSettings then
                                VUIMouseFireTrail:UpdateParticleSettings()
                            end
                        end
                    end
                },
                particleCount = {
                    key = 'vmodules.vuimousefiretrail.particleCount',
                    type = 'slider',
                    label = 'Particle Count',
                    tooltip = 'Set the number of particles in the trail',
                    min = 5,
                    max = 50,
                    step = 1,
                    column = 3,
                    order = 2,
                    callback = function(self)
                        if VUIMouseFireTrail and VUIMouseFireTrail.db then
                            VUIMouseFireTrail.db.profile.particleCount = self:GetValue()
                            if VUIMouseFireTrail.UpdateParticleSettings then
                                VUIMouseFireTrail:UpdateParticleSettings()
                            end
                        end
                    end
                },
                particleAlpha = {
                    key = 'vmodules.vuimousefiretrail.particleAlpha',
                    type = 'slider',
                    label = 'Particle Transparency',
                    tooltip = 'Set the transparency of particles',
                    min = 0.1,
                    max = 1.0,
                    step = 0.1,
                    column = 3,
                    order = 3,
                    callback = function(self)
                        if VUIMouseFireTrail and VUIMouseFireTrail.db then
                            VUIMouseFireTrail.db.profile.particleAlpha = self:GetValue()
                            if VUIMouseFireTrail.UpdateParticleSettings then
                                VUIMouseFireTrail:UpdateParticleSettings()
                            end
                        end
                    end
                },
            },
            {
                particleTrailLength = {
                    key = 'vmodules.vuimousefiretrail.particleTrailLength',
                    type = 'slider',
                    label = 'Trail Length',
                    tooltip = 'Set the length of the trail',
                    min = 0.1,
                    max = 1.0,
                    step = 0.1,
                    column = 3,
                    order = 1,
                    callback = function(self)
                        if VUIMouseFireTrail and VUIMouseFireTrail.db then
                            VUIMouseFireTrail.db.profile.particleTrailLength = self:GetValue()
                            if VUIMouseFireTrail.UpdateParticleSettings then
                                VUIMouseFireTrail:UpdateParticleSettings()
                            end
                        end
                    end
                },
                particleSpeed = {
                    key = 'vmodules.vuimousefiretrail.particleSpeed',
                    type = 'slider',
                    label = 'Particle Speed',
                    tooltip = 'Set how fast the particles move',
                    min = 0.5,
                    max = 3.0,
                    step = 0.1,
                    column = 3,
                    order = 2,
                    callback = function(self)
                        if VUIMouseFireTrail and VUIMouseFireTrail.db then
                            VUIMouseFireTrail.db.profile.particleSpeed = self:GetValue()
                            if VUIMouseFireTrail.UpdateParticleSettings then
                                VUIMouseFireTrail:UpdateParticleSettings()
                            end
                        end
                    end
                },
                particleDecay = {
                    key = 'vmodules.vuimousefiretrail.particleDecay',
                    type = 'slider',
                    label = 'Particle Fade Rate',
                    tooltip = 'Set how quickly particles fade out',
                    min = 0.8,
                    max = 0.98,
                    step = 0.01,
                    column = 3,
                    order = 3,
                    callback = function(self)
                        if VUIMouseFireTrail and VUIMouseFireTrail.db then
                            VUIMouseFireTrail.db.profile.particleDecay = self:GetValue()
                            if VUIMouseFireTrail.UpdateParticleSettings then
                                VUIMouseFireTrail:UpdateParticleSettings()
                            end
                        end
                    end
                },
                particleVariation = {
                    key = 'vmodules.vuimousefiretrail.particleVariation',
                    type = 'slider',
                    label = 'Size Variation',
                    tooltip = 'Random variation in particle size',
                    min = 0,
                    max = 1,
                    step = 0.05,
                    column = 3,
                    order = 4,
                    callback = function(self)
                        if VUIMouseFireTrail and VUIMouseFireTrail.db then
                            VUIMouseFireTrail.db.profile.particleVariation = self:GetValue()
                            if VUIMouseFireTrail.UpdateParticleSettings then
                                VUIMouseFireTrail:UpdateParticleSettings()
                            end
                        end
                    end
                },
            },
            {
                header = {
                    type = 'header',
                    label = 'Activation Options'
                },
            },
            {
                mouseButtonRequired = {
                    key = 'vmodules.vuimousefiretrail.mouseButtonRequired',
                    type = 'checkbox',
                    label = 'Require Mouse Button',
                    tooltip = 'Require holding a mouse button to show the trail',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        if VUIMouseFireTrail and VUIMouseFireTrail.db then
                            VUIMouseFireTrail.db.profile.mouseButtonRequired = self:GetValue()
                            if VUIMouseFireTrail.UpdateTriggerSettings then
                                VUIMouseFireTrail:UpdateTriggerSettings()
                            end
                        end
                    end
                },
                mouseButton = {
                    key = 'vmodules.vuimousefiretrail.mouseButton',
                    type = 'dropdown',
                    label = 'Mouse Button',
                    tooltip = 'Which mouse button to hold',
                    options = {
                        { text = 'Left Button', value = 'LEFT' },
                        { text = 'Right Button', value = 'RIGHT' },
                        { text = 'Middle Button', value = 'MIDDLE' }
                    },
                    column = 4,
                    order = 2,
                    callback = function(self)
                        if VUIMouseFireTrail and VUIMouseFireTrail.db then
                            VUIMouseFireTrail.db.profile.mouseButton = self:GetSelectedItem().value
                            if VUIMouseFireTrail.UpdateTriggerSettings then
                                VUIMouseFireTrail:UpdateTriggerSettings()
                            end
                        end
                    end
                },
            },
            {
                requireModifierKey = {
                    key = 'vmodules.vuimousefiretrail.requireModifierKey',
                    type = 'checkbox',
                    label = 'Require Key Modifier',
                    tooltip = 'Require holding a key modifier to show the trail',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        if VUIMouseFireTrail and VUIMouseFireTrail.db then
                            VUIMouseFireTrail.db.profile.requireModifierKey = self:GetValue()
                        end
                    end
                },
                useThemeColor = {
                    key = 'vmodules.vuimousefiretrail.useThemeColor',
                    type = 'checkbox',
                    label = 'Use VUI Theme Color',
                    tooltip = 'Use the current VUI theme color for trails',
                    column = 4,
                    order = 2,
                    callback = function(self)
                        if VUIMouseFireTrail and VUIMouseFireTrail.db then
                            VUIMouseFireTrail.db.profile.useThemeColor = self:GetValue()
                            if VUIMouseFireTrail.UpdateTheme then
                                VUIMouseFireTrail:UpdateTheme()
                            end
                        end
                    end
                },
            },
        },
    }
end