--[[
    VUI Standard Layout Template
    
    This is a comprehensive template for creating new module layout files.
    When creating a new module, copy this file, rename it to _YourModuleName.lua,
    and modify it to suit your module's specific needs.
    
    Best practices:
    1. Use the centralized helper for finding VModules
    2. Organize settings into logical sections with clear headers
    3. Ensure column allocation per row doesn't exceed 12
    4. Group related settings together
    5. Use consistent naming and descriptive tooltips
    6. Maintain consistent column widths (4, 6, or 12 columns)
    7. Include callback functions for settings that need immediate updates
]]

local Layout = VUI:NewModule('Config.Layout.ModuleName')

-- Use the centralized helper for finding VModules
local SafeGetVModule = _G.SafeGetVModule or VUI.ConfigHelpers.SafeGetVModule

function Layout:OnEnable()
    -- Database
    local db = VUI.db
    
    -- Find VModule if needed
    local module = SafeGetVModule("ModuleName")
    
    if not module then 
        -- Use the retry mechanism with proper callback
        VUI.ConfigHelpers.FindVModule("ModuleName", function(foundModule)
            module = foundModule
            if module then 
                self:OnEnable() 
            end
        end)
        return 
    end
    
    -- Data module references (if needed)
    local Textures = VUI:GetModule("Data.Textures", true)
    local Fonts = VUI:GetModule("Data.Fonts", true)
    
    -- Layout
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        database = db.profile.modulename, -- Replace with actual path
        rows = {
            -- SECTION 1: Main Settings
            {
                header = {
                    type = 'header',
                    label = 'Main Settings'
                }
            },
            {
                enabled = {
                    key = 'enabled',
                    type = 'checkbox',
                    label = 'Enable Feature',
                    tooltip = 'Turn this feature on or off',
                    column = 6,
                    order = 1,
                    callback = function(self)
                        if module then
                            module.db.profile.enabled = self:GetValue()
                            module:RefreshConfig()
                        end
                    end
                },
                testMode = {
                    key = 'testMode',
                    type = 'checkbox',
                    label = 'Test Mode',
                    tooltip = 'Enable test mode to see how this feature works',
                    column = 6,
                    order = 2,
                    callback = function(self)
                        if module then
                            module.db.profile.testMode = self:GetValue()
                            module:RefreshConfig()
                        end
                    end
                }
            },
            
            -- SECTION 2: Appearance Settings
            {
                header = {
                    type = 'header',
                    label = 'Appearance Settings'
                }
            },
            {
                scale = {
                    key = 'scale',
                    type = 'slider',
                    label = 'Scale',
                    tooltip = 'Adjust the scale of the display',
                    min = 0.5,
                    max = 2.0,
                    step = 0.1,
                    column = 6,
                    order = 1,
                    callback = function(self)
                        if module then
                            module.db.profile.scale = self:GetValue()
                            module:RefreshConfig()
                        end
                    end
                },
                alpha = {
                    key = 'alpha',
                    type = 'slider',
                    label = 'Transparency',
                    tooltip = 'Adjust the transparency of the display (0 = invisible, 1 = fully visible)',
                    min = 0.1,
                    max = 1.0,
                    step = 0.1,
                    column = 6,
                    order = 2,
                    callback = function(self)
                        if module then
                            module.db.profile.alpha = self:GetValue()
                            module:RefreshConfig()
                        end
                    end
                }
            },
            
            -- SECTION 3: Color Settings Example
            {
                header = {
                    type = 'header',
                    label = 'Color Settings'
                }
            },
            {
                useCustomColors = {
                    key = 'useCustomColors',
                    type = 'checkbox',
                    label = 'Use Custom Colors',
                    tooltip = 'Use custom colors instead of default theme colors',
                    column = 6,
                    order = 1,
                    callback = function(self)
                        if module then
                            module.db.profile.useCustomColors = self:GetValue()
                            module:RefreshConfig()
                        end
                    end
                },
                primaryColor = {
                    key = 'primaryColor',
                    type = 'color',
                    label = 'Primary Color',
                    tooltip = 'Set the primary color for this feature',
                    hasAlpha = true,
                    column = 6,
                    order = 2,
                    callback = function(self, r, g, b, a)
                        if module then
                            module.db.profile.primaryColor = {r = r, g = g, b = b, a = a}
                            module:RefreshConfig()
                        end
                    end
                }
            },
            
            -- SECTION 4: Text Settings Example
            {
                header = {
                    type = 'header',
                    label = 'Text Settings'
                }
            },
            {
                showText = {
                    key = 'showText',
                    type = 'checkbox',
                    label = 'Show Text',
                    tooltip = 'Display text labels',
                    column = 6,
                    order = 1,
                    callback = function(self)
                        if module then
                            module.db.profile.showText = self:GetValue()
                            module:RefreshConfig()
                        end
                    end
                },
                fontSize = {
                    key = 'fontSize',
                    type = 'slider',
                    label = 'Font Size',
                    tooltip = 'Adjust the size of text',
                    min = 8,
                    max = 24,
                    step = 1,
                    column = 6,
                    order = 2,
                    callback = function(self)
                        if module then
                            module.db.profile.fontSize = self:GetValue()
                            module:RefreshConfig()
                        end
                    end
                }
            },
            
            -- SECTION 5: Position Settings Example
            {
                header = {
                    type = 'header',
                    label = 'Position Settings'
                }
            },
            {
                anchorPoint = {
                    key = 'anchorPoint',
                    type = 'dropdown',
                    label = 'Anchor Point',
                    tooltip = 'Set where the frame should be anchored',
                    column = 6,
                    order = 1,
                    options = {
                        { value = "CENTER", text = "Center" },
                        { value = "TOP", text = "Top" },
                        { value = "BOTTOM", text = "Bottom" },
                        { value = "LEFT", text = "Left" },
                        { value = "RIGHT", text = "Right" },
                        { value = "TOPLEFT", text = "Top Left" },
                        { value = "TOPRIGHT", text = "Top Right" },
                        { value = "BOTTOMLEFT", text = "Bottom Left" },
                        { value = "BOTTOMRIGHT", text = "Bottom Right" }
                    },
                    callback = function(self)
                        if module then
                            module.db.profile.anchorPoint = self:GetValue()
                            module:RefreshConfig()
                        end
                    end
                },
                lockFrame = {
                    key = 'lockFrame',
                    type = 'checkbox',
                    label = 'Lock Position',
                    tooltip = 'Lock the frame position so it cannot be moved',
                    column = 6,
                    order = 2,
                    callback = function(self)
                        if module then
                            module.db.profile.lockFrame = self:GetValue()
                            module:RefreshConfig()
                        end
                    end
                }
            },
            
            -- SECTION 6: Advanced Settings Example
            {
                header = {
                    type = 'header',
                    label = 'Advanced Settings'
                }
            },
            {
                advancedOption1 = {
                    key = 'advancedOption1',
                    type = 'checkbox',
                    label = 'Advanced Option 1',
                    tooltip = 'Enable advanced option 1',
                    column = 4,
                    order = 1,
                    callback = function(self)
                        if module then
                            module.db.profile.advancedOption1 = self:GetValue()
                            module:RefreshConfig()
                        end
                    end
                },
                advancedOption2 = {
                    key = 'advancedOption2',
                    type = 'checkbox',
                    label = 'Advanced Option 2',
                    tooltip = 'Enable advanced option 2',
                    column = 4,
                    order = 2,
                    callback = function(self)
                        if module then
                            module.db.profile.advancedOption2 = self:GetValue()
                            module:RefreshConfig()
                        end
                    end
                },
                advancedOption3 = {
                    key = 'advancedOption3',
                    type = 'checkbox',
                    label = 'Advanced Option 3',
                    tooltip = 'Enable advanced option 3',
                    column = 4,
                    order = 3,
                    callback = function(self)
                        if module then
                            module.db.profile.advancedOption3 = self:GetValue()
                            module:RefreshConfig()
                        end
                    end
                }
            }
        }
    }
end 