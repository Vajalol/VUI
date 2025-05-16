--[[
    VUI Any Frame Module Configuration
    Framework for moving and scaling any UI frame
]]

local Layout = VUI:NewModule('Config.Layout.VUIAnyFrame')

-- Initialize with the standard layout helper
VUI.ConfigHelpers.CreateStandardLayout(Layout, "VUIAnyFrame", "VUI Any Frame", "vmodules.vuianyframe")

-- Define module-specific layout construction
function Layout:BuildModuleLayout(module, db)
    -- Extend the base layout with module-specific settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Frame Movement'
        },
    })
    
    -- Add basic settings
    table.insert(Layout.layout.rows, {
        enableFrames = {
            key = 'vmodules.vuianyframe.enabled',
            type = 'checkbox',
            label = 'Enable Frame Movement',
            tooltip = 'Enable frame movement and scaling',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.enabled = self:GetValue()
                    if self:GetValue() then
                        if module.OnEnable then
                            module:OnEnable()
                        end
                    else
                        if module.OnDisable then
                            module:OnDisable()
                        end
                    end
                end
            end
        },
        lockFrames = {
            key = 'vmodules.vuianyframe.lockFrames',
            type = 'checkbox',
            label = 'Lock Frames',
            tooltip = 'Lock all frames to prevent movement',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.SetSetting then
                    module:SetSetting("lockFrames", self:GetValue())
                end
            end
        },
        combatLock = {
            key = 'vmodules.vuianyframe.combatLock',
            type = 'checkbox',
            label = 'Lock in Combat',
            tooltip = 'Automatically lock frames when entering combat',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.SetSetting then
                    module:SetSetting("combatLock", self:GetValue())
                end
            end
        },
    })
    
    -- Add grid and scale settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Grid & Scaling'
        },
    })
    
    table.insert(Layout.layout.rows, {
        allowScaling = {
            key = 'vmodules.vuianyframe.allowScaling',
            type = 'checkbox',
            label = 'Allow Frame Scaling',
            tooltip = 'Enable scaling frames with right-click + drag',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.SetSetting then
                    module:SetSetting("allowScaling", self:GetValue())
                end
            end
        },
        showGrid = {
            key = 'vmodules.vuianyframe.showGrid',
            type = 'checkbox',
            label = 'Show Grid',
            tooltip = 'Show a grid when moving frames',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.SetSetting then
                    module:SetSetting("showGrid", self:GetValue())
                end
            end
        },
        snapToGrid = {
            key = 'vmodules.vuianyframe.snapToGrid',
            type = 'checkbox',
            label = 'Snap to Grid',
            tooltip = 'Snap frames to grid when moving',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.SetSetting then
                    module:SetSetting("snapToGrid", self:GetValue())
                end
            end
        },
    })
    
    table.insert(Layout.layout.rows, {
        gridSize = {
            key = 'vmodules.vuianyframe.gridSize',
            type = 'slider',
            label = 'Grid Size',
            tooltip = 'Set the size of the grid',
            min = 5,
            max = 50,
            step = 1,
            width = "full",
            column = 12,
            order = 4,
            callback = function(self)
                if module and module.SetSetting then
                    module:SetSetting("grid", self:GetValue())
                end
            end
        },
    })
    
    -- Actions
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Actions'
        },
    })
    
    table.insert(Layout.layout.rows, {
        resetAllFrames = {
            type = 'button',
            label = 'Reset All Frames',
            tooltip = 'Reset all frame positions and scales to default',
            column = 6,
            order = 1,
            callback = function()
                if module and module.ResetAllFrameSettings then
                    module:ResetAllFrameSettings()
                end
            end
        },
        toggleLockState = {
            type = 'button',
            label = 'Toggle Lock State',
            tooltip = 'Toggle between locked and unlocked state',
            column = 6,
            order = 2,
            callback = function()
                if module and module.ToggleFrameLock then
                    module:ToggleFrameLock()
                end
            end
        },
    })
    
    -- Information
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Information'
        },
    })
    
    -- Only show this if the module is loaded
    if module then
        local frameCount = 0
        if module.db and module.db.profile and module.db.profile.frames then
            for _ in pairs(module.db.profile.frames) do
                frameCount = frameCount + 1
            end
        end
        
        table.insert(Layout.layout.rows, {
            frameInfo = {
                type = 'label',
                label = "Active moved frames: " .. frameCount,
                column = 12,
                order = 1,
            }
        })
    else
        table.insert(Layout.layout.rows, {
            frameInfo = {
                type = 'label',
                label = "Frame information will be available when the module is loaded",
                column = 12,
                order = 1,
            }
        })
    end
    
    -- Examples
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Example Usage'
        },
    })
    
    table.insert(Layout.layout.rows, {
        usageExample = {
            type = 'label',
            label = "Use /va unlock to unlock frames for moving",
            column = 6,
            order = 1,
        },
        usageExample2 = {
            type = 'label',
            label = "Use middle-click to reset a frame to default position",
            column = 6,
            order = 2,
        }
    })
    
    table.insert(Layout.layout.rows, {
        usageExample3 = {
            type = 'label',
            label = "Use right-click + drag up/down to scale a frame",
            column = 6,
            order = 3,
        },
        usageExample4 = {
            type = 'label',
            label = "Use /va help to see all available commands",
            column = 6,
            order = 4,
        }
    })
end

return Layout 