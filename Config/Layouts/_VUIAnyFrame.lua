--[[
    VUI Any Frame Module Configuration
    Based on MoveAny by D4KiR with VUI integration
]]

local Layout = VUI:NewModule('Config.Layout.VUIAnyFrame')

-- Initialize with the standard layout helper
VUI.ConfigHelpers.CreateStandardLayout(Layout, "VUIAnyFrame", "VUI Any Frame", "vmodules.vuianyframe")

-- Define module-specific layout construction
function Layout:BuildModuleLayout(module, db)
    -- Ensure our module is loaded
    if not module then
        table.insert(Layout.layout.rows, {
            errorLabel = {
                type = 'label',
                label = "Module not loaded. Try reloading the UI.",
                column = 12,
                order = 1,
            }
        })
        return
    end

    -- Main Settings Section
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
            key = 'vmodules.vuianyframe.global.lockFrames',
            type = 'checkbox',
            label = 'Lock Frames',
            tooltip = 'Lock all frames to prevent movement',
            column = 4,
            order = 2,
            callback = function(self)
                if module then
                    module.db.profile.global.lockFrames = self:GetValue()
                    if self:GetValue() then
                        module:Lock()
                    else
                        module:Unlock()
                    end
                end
            end
        },
        toggleLockState = {
            type = 'button',
            label = 'Toggle Lock',
            tooltip = 'Toggle between locked and unlocked frames',
            column = 4,
            order = 3,
            callback = function()
                if module and module.ToggleLock then
                    module:ToggleLock()
                end
            end
        }
    })
    
    -- Grid Settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Grid Settings'
        },
    })
    
    table.insert(Layout.layout.rows, {
        snapToGrid = {
            key = 'vmodules.vuianyframe.global.snapToGrid',
            type = 'checkbox',
            label = 'Snap to Grid',
            tooltip = 'Snap frames to grid when moving',
            column = 6,
            order = 1,
            callback = function(self)
                if module then
                    module.db.profile.global.snapToGrid = self:GetValue()
                end
            end
        },
        showGrid = {
            type = 'button',
            label = 'Show Grid',
            tooltip = 'Toggle grid visibility',
            column = 6,
            order = 2,
            callback = function()
                if module and module.GridFrame then
                    if module.GridFrame:IsShown() then
                        module.GridFrame:Hide()
                    else
                        module:UpdateGrid()
                        module.GridFrame:Show()
                    end
                end
            end
        },
    })
    
    table.insert(Layout.layout.rows, {
        gridSize = {
            key = 'vmodules.vuianyframe.global.grid',
            type = 'slider',
            label = 'Grid Size',
            tooltip = 'Size of the grid (in pixels)',
            min = 1,
            max = 64,
            step = 1,
            width = "full",
            column = 12,
            order = 3,
            callback = function(self)
                if module then
                    module.db.profile.global.grid = self:GetValue()
                    module:UpdateGrid()
                end
            end
        },
    })
    
    -- Minimap Button
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Minimap Button'
        },
    })
    
    table.insert(Layout.layout.rows, {
        minimapButton = {
            key = 'vmodules.vuianyframe.minimap.hide',
            type = 'checkbox',
            label = 'Hide Minimap Button',
            tooltip = 'Show or hide the minimap button',
            column = 12,
            order = 1,
            callback = function(self)
                if module then
                    module.db.profile.minimap.hide = self:GetValue()
                    if LibStub and LibStub("LibDBIcon-1.0", true) then
                        local LDBIcon = LibStub("LibDBIcon-1.0")
                        if self:GetValue() then
                            LDBIcon:Hide("VUIAnyFrame")
                        else
                            LDBIcon:Show("VUIAnyFrame")
                        end
                    end
                end
            end
        }
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
                    -- Show confirmation dialog
                    StaticPopupDialogs["VUIANYFRAME_RESET_ALL"] = {
                        text = "Are you sure you want to reset all frames to their default positions?",
                        button1 = "Yes",
                        button2 = "No",
                        OnAccept = function()
                            module:ResetAllFrameSettings()
                            module:Print("All frames reset to default positions")
                        end,
                        timeout = 0,
                        whileDead = true,
                        hideOnEscape = true,
                        preferredIndex = 3
                    }
                    StaticPopup_Show("VUIANYFRAME_RESET_ALL")
                end
            end
        },
        applySettings = {
            type = 'button',
            label = 'Apply Settings',
            tooltip = 'Apply all saved frame settings',
            column = 6,
            order = 2,
            callback = function()
                if module and module.ApplySettings then
                    module:ApplySettings()
                end
            end
        }
    })
    
    -- Frame Categories - Only if we have registered widgets
    if module.GetRegisteredWidgets and type(module.GetRegisteredWidgets) == "function" then
        local widgets = module:GetRegisteredWidgets()
        
        if widgets and next(widgets) then
            table.insert(Layout.layout.rows, {
                header = {
                    type = 'header',
                    label = 'Frame Categories'
                },
            })
            
            -- Create entries for each category
            for category, frames in pairs(widgets) do
                -- Skip empty categories
                if #frames > 0 then
                    table.insert(Layout.layout.rows, {
                        [category .. "Label"] = {
                            type = 'label',
                            label = category .. " (" .. #frames .. " frames)",
                            column = 4,
                            order = 1,
                        },
                        [category .. "Button"] = {
                            type = 'button',
                            label = 'Configure',
                            tooltip = 'Configure ' .. category .. ' frames',
                            column = 8,
                            order = 2,
                            callback = function()
                                -- Expand the category in the options
                                if module.OpenOptions then
                                    module:OpenOptions()
                                end
                            end
                        }
                    })
                end
            end
        end
    end
    
    -- Information
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Information'
        },
    })
    
    -- Count how many frames are currently managed
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
    
    -- Help Section
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Help'
        },
    })
    
    table.insert(Layout.layout.rows, {
        help1 = {
            type = 'label',
            label = "• Use /va or /vuianyframe to toggle lock/unlock",
            column = 6,
            order = 1,
        },
        help2 = {
            type = 'label',
            label = "• Right-click on a frame when unlocked for more options",
            column = 6,
            order = 2,
        }
    })
    
    table.insert(Layout.layout.rows, {
        help3 = {
            type = 'label',
            label = "• Left-click and drag to move",
            column = 6,
            order = 3,
        },
        help4 = {
            type = 'label',
            label = "• Frames auto-lock when entering combat",
            column = 6,
            order = 4,
        }
    })
end

return Layout 