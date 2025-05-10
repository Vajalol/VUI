local Layout = VUI:NewModule('Config.Layout.VUIScrollingText')

function Layout:OnEnable()
    -- Database
    local db = VUI.db
    
    -- Module reference - note that VUIScrollingText is directly accessed via VUI.ScrollingText
    local VUIScrollingText = VUI.ScrollingText
    
    -- Font options
    local fontValues = {
        { text = "Friz Quadrata TT", value = "Friz" },
        { text = "Arial Narrow", value = "Arial" },
        { text = "Skurri", value = "Skurri" },
        { text = "Morpheus", value = "Morpheus" },
        { text = "Adventure", value = "Adventure" }
    }
    
    -- Animation style options
    local animationStyles = {
        { text = "Scroll Up", value = "UP" },
        { text = "Scroll Down", value = "DOWN" },
        { text = "Scroll Left", value = "LEFT" },
        { text = "Scroll Right", value = "RIGHT" },
        { text = "Fade In/Out", value = "FADE" },
        { text = "Static", value = "STATIC" }
    }
    
    -- Layout
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        database = db.profile,
        rows = {
            {
                header = {
                    type = 'header',
                    label = 'VUI Scrolling Text'
                },
            },
            {
                enabled = {
                    key = 'vmodules.vuiscrollingtext.enabled',
                    type = 'checkbox',
                    label = 'Enable Scrolling Text',
                    tooltip = 'Show scrolling combat text around your character',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        -- Update the saved variable
                        local configPath = 'vmodules.vuiscrollingtext.enabled'
                        if db and db.profile then
                            db.profile[configPath] = self:GetValue()
                            
                            -- VUIScrollingText uses a different configuration approach, 
                            -- so we need to manually sync its settings
                            if VUIScrollingText then
                                if VUIScrollingText.config then
                                    VUIScrollingText.config.enabled = self:GetValue()
                                end
                                
                                -- Update display based on new value
                                if self:GetValue() then
                                    if VUIScrollingText.Enable then
                                        VUIScrollingText:Enable()
                                    end
                                else
                                    if VUIScrollingText.Disable then
                                        VUIScrollingText:Disable()
                                    end
                                end
                            end
                        end
                    end
                },
            },
            {
                header = {
                    type = 'header',
                    label = 'Font Settings'
                },
            },
            {
                fontFamily = {
                    key = 'vmodules.vuiscrollingtext.fontFamily',
                    type = 'dropdown',
                    label = 'Font Family',
                    tooltip = 'Select the font family for scrolling text',
                    options = fontValues,
                    column = 3,
                    order = 1,
                    callback = function(self)
                        if VUIScrollingText and VUIScrollingText.config then
                            VUIScrollingText.config.fontFamily = self:GetSelectedItem().value
                            if VUIScrollingText.UpdateFontSettings then
                                VUIScrollingText:UpdateFontSettings()
                            end
                        end
                    end
                },
                fontSize = {
                    key = 'vmodules.vuiscrollingtext.fontSize',
                    type = 'slider',
                    label = 'Font Size',
                    tooltip = 'Set the font size for scrolling text',
                    min = 8,
                    max = 32,
                    step = 1,
                    column = 3,
                    order = 2,
                    callback = function(self)
                        if VUIScrollingText and VUIScrollingText.config then
                            VUIScrollingText.config.fontSize = self:GetValue()
                            if VUIScrollingText.UpdateFontSettings then
                                VUIScrollingText:UpdateFontSettings()
                            end
                        end
                    end
                },
                fontOutline = {
                    key = 'vmodules.vuiscrollingtext.fontOutline',
                    type = 'dropdown',
                    label = 'Font Outline',
                    tooltip = 'Select the outline style for the font',
                    options = {
                        { text = "None", value = "NONE" },
                        { text = "Thin Outline", value = "OUTLINE" },
                        { text = "Thick Outline", value = "THICKOUTLINE" }
                    },
                    column = 3,
                    order = 3,
                    callback = function(self)
                        if VUIScrollingText and VUIScrollingText.config then
                            VUIScrollingText.config.fontOutline = self:GetSelectedItem().value
                            if VUIScrollingText.UpdateFontSettings then
                                VUIScrollingText:UpdateFontSettings()
                            end
                        end
                    end
                },
            },
            {
                header = {
                    type = 'header',
                    label = 'Animation Settings'
                },
            },
            {
                animationStyle = {
                    key = 'vmodules.vuiscrollingtext.animationStyle',
                    type = 'dropdown',
                    label = 'Animation Style',
                    tooltip = 'Select how text animates',
                    options = animationStyles,
                    column = 3,
                    order = 1,
                    callback = function(self)
                        if VUIScrollingText and VUIScrollingText.config then
                            VUIScrollingText.config.animationStyle = self:GetSelectedItem().value
                            if VUIScrollingText.UpdateAnimationSettings then
                                VUIScrollingText:UpdateAnimationSettings()
                            end
                        end
                    end
                },
                animationSpeed = {
                    key = 'vmodules.vuiscrollingtext.animationSpeed',
                    type = 'slider',
                    label = 'Animation Speed',
                    tooltip = 'Set how fast text moves',
                    min = 1,
                    max = 5,
                    step = 0.5,
                    column = 3,
                    order = 2,
                    callback = function(self)
                        if VUIScrollingText and VUIScrollingText.config then
                            VUIScrollingText.config.animationSpeed = self:GetValue()
                            if VUIScrollingText.UpdateAnimationSettings then
                                VUIScrollingText:UpdateAnimationSettings()
                            end
                        end
                    end
                },
                scrollDistance = {
                    key = 'vmodules.vuiscrollingtext.scrollDistance',
                    type = 'slider',
                    label = 'Scroll Distance',
                    tooltip = 'Set how far text travels',
                    min = 50,
                    max = 300,
                    step = 10,
                    column = 3,
                    order = 3,
                    callback = function(self)
                        if VUIScrollingText and VUIScrollingText.config then
                            VUIScrollingText.config.scrollDistance = self:GetValue()
                            if VUIScrollingText.UpdateAnimationSettings then
                                VUIScrollingText:UpdateAnimationSettings()
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
                showIcons = {
                    key = 'vmodules.vuiscrollingtext.showIcons',
                    type = 'checkbox',
                    label = 'Show Icons',
                    tooltip = 'Display ability icons next to text',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        if VUIScrollingText and VUIScrollingText.config then
                            VUIScrollingText.config.showIcons = self:GetValue()
                            if VUIScrollingText.UpdateDisplaySettings then
                                VUIScrollingText:UpdateDisplaySettings()
                            end
                        end
                    end
                },
                showCrits = {
                    key = 'vmodules.vuiscrollingtext.showCrits',
                    type = 'checkbox',
                    label = 'Emphasize Crits',
                    tooltip = 'Make critical hits more noticeable',
                    column = 4,
                    order = 2,
                    callback = function(self)
                        if VUIScrollingText and VUIScrollingText.config then
                            VUIScrollingText.config.showCrits = self:GetValue()
                            if VUIScrollingText.UpdateDisplaySettings then
                                VUIScrollingText:UpdateDisplaySettings()
                            end
                        end
                    end
                },
                mergeAOE = {
                    key = 'vmodules.vuiscrollingtext.mergeAOE',
                    type = 'checkbox',
                    label = 'Merge AOE Damage',
                    tooltip = 'Combine multiple hits from AOE abilities',
                    column = 4,
                    order = 3,
                    callback = function(self)
                        if VUIScrollingText and VUIScrollingText.config then
                            VUIScrollingText.config.mergeAOE = self:GetValue()
                            if VUIScrollingText.UpdateDisplaySettings then
                                VUIScrollingText:UpdateDisplaySettings()
                            end
                        end
                    end
                },
            },
            {
                showHealing = {
                    key = 'vmodules.vuiscrollingtext.showHealing',
                    type = 'checkbox',
                    label = 'Show Healing',
                    tooltip = 'Display healing numbers',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        if VUIScrollingText and VUIScrollingText.config then
                            VUIScrollingText.config.showHealing = self:GetValue()
                            if VUIScrollingText.UpdateEventSettings then
                                VUIScrollingText:UpdateEventSettings()
                            end
                        end
                    end
                },
                showDamage = {
                    key = 'vmodules.vuiscrollingtext.showDamage',
                    type = 'checkbox',
                    label = 'Show Damage',
                    tooltip = 'Display damage numbers',
                    column = 4,
                    order = 2,
                    callback = function(self)
                        if VUIScrollingText and VUIScrollingText.config then
                            VUIScrollingText.config.showDamage = self:GetValue()
                            if VUIScrollingText.UpdateEventSettings then
                                VUIScrollingText:UpdateEventSettings()
                            end
                        end
                    end
                },
                showProccs = {
                    key = 'vmodules.vuiscrollingtext.showProccs',
                    type = 'checkbox',
                    label = 'Show Procs',
                    tooltip = 'Display ability procs',
                    column = 4,
                    order = 3,
                    callback = function(self)
                        if VUIScrollingText and VUIScrollingText.config then
                            VUIScrollingText.config.showProccs = self:GetValue()
                            if VUIScrollingText.UpdateEventSettings then
                                VUIScrollingText:UpdateEventSettings()
                            end
                        end
                    end
                },
            },
            {
                header = {
                    type = 'header',
                    label = 'Scroll Areas'
                },
            },
            {
                incomingDamageArea = {
                    key = 'vmodules.vuiscrollingtext.incomingDamageArea',
                    type = 'dropdown',
                    label = 'Incoming Damage Area',
                    tooltip = 'Where to display damage you receive',
                    options = {
                        { text = "Top", value = "TOP" },
                        { text = "Bottom", value = "BOTTOM" },
                        { text = "Left", value = "LEFT" },
                        { text = "Right", value = "RIGHT" },
                        { text = "Center", value = "CENTER" },
                        { text = "Disabled", value = "NONE" }
                    },
                    column = 3,
                    order = 1,
                    callback = function(self)
                        if VUIScrollingText and VUIScrollingText.config then
                            VUIScrollingText.config.incomingDamageArea = self:GetSelectedItem().value
                            if VUIScrollingText.UpdateScrollAreas then
                                VUIScrollingText:UpdateScrollAreas()
                            end
                        end
                    end
                },
                outgoingDamageArea = {
                    key = 'vmodules.vuiscrollingtext.outgoingDamageArea',
                    type = 'dropdown',
                    label = 'Outgoing Damage Area',
                    tooltip = 'Where to display damage you deal',
                    options = {
                        { text = "Top", value = "TOP" },
                        { text = "Bottom", value = "BOTTOM" },
                        { text = "Left", value = "LEFT" },
                        { text = "Right", value = "RIGHT" },
                        { text = "Center", value = "CENTER" },
                        { text = "Disabled", value = "NONE" }
                    },
                    column = 3,
                    order = 2,
                    callback = function(self)
                        if VUIScrollingText and VUIScrollingText.config then
                            VUIScrollingText.config.outgoingDamageArea = self:GetSelectedItem().value
                            if VUIScrollingText.UpdateScrollAreas then
                                VUIScrollingText:UpdateScrollAreas()
                            end
                        end
                    end
                },
            },
            {
                incomingHealingArea = {
                    key = 'vmodules.vuiscrollingtext.incomingHealingArea',
                    type = 'dropdown',
                    label = 'Incoming Healing Area',
                    tooltip = 'Where to display healing you receive',
                    options = {
                        { text = "Top", value = "TOP" },
                        { text = "Bottom", value = "BOTTOM" },
                        { text = "Left", value = "LEFT" },
                        { text = "Right", value = "RIGHT" },
                        { text = "Center", value = "CENTER" },
                        { text = "Disabled", value = "NONE" }
                    },
                    column = 3,
                    order = 1,
                    callback = function(self)
                        if VUIScrollingText and VUIScrollingText.config then
                            VUIScrollingText.config.incomingHealingArea = self:GetSelectedItem().value
                            if VUIScrollingText.UpdateScrollAreas then
                                VUIScrollingText:UpdateScrollAreas()
                            end
                        end
                    end
                },
                outgoingHealingArea = {
                    key = 'vmodules.vuiscrollingtext.outgoingHealingArea',
                    type = 'dropdown',
                    label = 'Outgoing Healing Area',
                    tooltip = 'Where to display healing you cast',
                    options = {
                        { text = "Top", value = "TOP" },
                        { text = "Bottom", value = "BOTTOM" },
                        { text = "Left", value = "LEFT" },
                        { text = "Right", value = "RIGHT" },
                        { text = "Center", value = "CENTER" },
                        { text = "Disabled", value = "NONE" }
                    },
                    column = 3,
                    order = 2,
                    callback = function(self)
                        if VUIScrollingText and VUIScrollingText.config then
                            VUIScrollingText.config.outgoingHealingArea = self:GetSelectedItem().value
                            if VUIScrollingText.UpdateScrollAreas then
                                VUIScrollingText:UpdateScrollAreas()
                            end
                        end
                    end
                },
            },
            {
                header = {
                    type = 'header',
                    label = 'Performance Settings'
                },
            },
            {
                enableThrottling = {
                    key = 'vmodules.vuiscrollingtext.enableThrottling',
                    type = 'checkbox',
                    label = 'Enable Throttling',
                    tooltip = 'Limit how many text animations can appear at once for better performance',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        if VUIScrollingText and VUIScrollingText.config then
                            VUIScrollingText.config.enableThrottling = self:GetValue()
                            if VUIScrollingText.UpdateThrottlingSettings then
                                VUIScrollingText:UpdateThrottlingSettings()
                            end
                        end
                    end
                },
                throttlingAmount = {
                    key = 'vmodules.vuiscrollingtext.throttlingAmount',
                    type = 'slider',
                    label = 'Throttling Amount',
                    tooltip = 'Maximum animations to show at once',
                    min = 5,
                    max = 50,
                    step = 5,
                    column = 4,
                    order = 2,
                    callback = function(self)
                        if VUIScrollingText and VUIScrollingText.config then
                            VUIScrollingText.config.throttlingAmount = self:GetValue()
                            if VUIScrollingText.UpdateThrottlingSettings then
                                VUIScrollingText:UpdateThrottlingSettings()
                            end
                        end
                    end
                },
            },
            {
                header = {
                    type = 'header',
                    label = 'Advanced Options'
                },
            },
            {
                advancedOptions = {
                    type = 'button',
                    label = 'Open Advanced Options',
                    tooltip = 'Opens the advanced configuration panel with more detailed settings',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        if VUIScrollingText and VUIScrollingText.RegisterOptions then
                            VUIScrollingText:RegisterOptions()
                        end
                    end
                },
                themeIntegration = {
                    key = 'vmodules.vuiscrollingtext.themeIntegration',
                    type = 'checkbox',
                    label = 'Use VUI Theme Colors',
                    tooltip = 'Apply VUI theme colors to text where applicable',
                    column = 4,
                    order = 2,
                    callback = function(self)
                        if VUIScrollingText and VUIScrollingText.config then
                            VUIScrollingText.config.themeIntegration = self:GetValue()
                            -- Update theme integration
                            if VUIScrollingText.ApplyTheme then
                                VUIScrollingText:ApplyTheme()
                            end
                        end
                    end
                },
            },
        },
    }
end