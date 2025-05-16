--[[
    VUI Extra Player Frames Module Configuration
    Additional unit frame displays for the player
]]

local Layout = VUI:NewModule('Config.Layout.VUIepf')

-- Initialize with the standard layout helper
VUI.ConfigHelpers.CreateStandardLayout(Layout, "VUIepf", "VUI Extra Player Frames", "vmodules.vuiepf")

-- Define module-specific layout construction
function Layout:BuildModuleLayout(module, db)
    -- Extend the base layout with module-specific settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Extra Player Frames'
        },
    })
    
    -- Add basic settings
    table.insert(Layout.layout.rows, {
        enableModule = {
            key = 'vmodules.vuiepf.enableModule',
            type = 'checkbox',
            label = 'Enable Extra Frames',
            tooltip = 'Enable extra player frame displays',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.general.enableModule = self:GetValue()
                    if module.UpdateAllFrames then
                        module:UpdateAllFrames()
                    end
                end
            end
        },
        lockFrames = {
            key = 'vmodules.vuiepf.lockFrames',
            type = 'checkbox',
            label = 'Lock Frames',
            tooltip = 'Lock or unlock extra player frames',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.general.lockFrames = self:GetValue()
                    if module.LockFrames then
                        module:LockFrames(self:GetValue())
                    end
                end
            end
        },
        showBorders = {
            key = 'vmodules.vuiepf.showBorders',
            type = 'checkbox',
            label = 'Show Borders',
            tooltip = 'Show borders around extra player frames',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.showBorders = self:GetValue()
                    if module.UpdateAllFrames then
                        module:UpdateAllFrames()
                    end
                end
            end
        },
    })
    
    -- Display settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Display Settings'
        },
    })
    
    table.insert(Layout.layout.rows, {
        frameScale = {
            key = 'vmodules.vuiepf.frameScale',
            type = 'slider',
            label = 'Frame Scale',
            tooltip = 'Scale of the extra player frames',
            min = 0.5,
            max = 2.0,
            step = 0.1,
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.frameScale = self:GetValue()
                    if module.UpdateAllFrames then
                        module:UpdateAllFrames()
                    end
                end
            end
        },
        frameAlpha = {
            key = 'vmodules.vuiepf.frameAlpha',
            type = 'slider',
            label = 'Frame Alpha',
            tooltip = 'Transparency of the extra player frames',
            min = 0.1,
            max = 1.0,
            step = 0.1,
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.frameAlpha = self:GetValue()
                    if module.UpdateAllFrames then
                        module:UpdateAllFrames()
                    end
                end
            end
        },
        combatAlpha = {
            key = 'vmodules.vuiepf.combatAlpha',
            type = 'slider',
            label = 'Combat Alpha',
            tooltip = 'Transparency of frames during combat',
            min = 0.1,
            max = 1.0,
            step = 0.1,
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.combatAlpha = self:GetValue()
                end
            end
        },
    })
    
    -- Frame types
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Frame Types'
        },
    })
    
    table.insert(Layout.layout.rows, {
        showHealthBar = {
            key = 'vmodules.vuiepf.showHealthBar',
            type = 'checkbox',
            label = 'Health Bar',
            tooltip = 'Show a health bar frame',
            column = 3,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.frames.health = self:GetValue()
                    if module.UpdateFrameVisibility then
                        module:UpdateFrameVisibility()
                    end
                end
            end
        },
        showPowerBar = {
            key = 'vmodules.vuiepf.showPowerBar',
            type = 'checkbox',
            label = 'Power Bar',
            tooltip = 'Show a power (mana/energy/rage) bar frame',
            column = 3,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.frames.power = self:GetValue()
                    if module.UpdateFrameVisibility then
                        module:UpdateFrameVisibility()
                    end
                end
            end
        },
        showCastBar = {
            key = 'vmodules.vuiepf.showCastBar',
            type = 'checkbox',
            label = 'Cast Bar',
            tooltip = 'Show a casting bar frame',
            column = 3,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.frames.cast = self:GetValue()
                    if module.UpdateFrameVisibility then
                        module:UpdateFrameVisibility()
                    end
                end
            end
        },
        showPortrait = {
            key = 'vmodules.vuiepf.showPortrait',
            type = 'checkbox',
            label = 'Portrait',
            tooltip = 'Show a player portrait frame',
            column = 3,
            order = 4,
            callback = function(self)
                if module and module.db then
                    module.db.profile.frames.portrait = self:GetValue()
                    if module.UpdateFrameVisibility then
                        module:UpdateFrameVisibility()
                    end
                end
            end
        },
    })
    
    -- Class specific
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Class-Specific Frames'
        },
    })
    
    -- This section would ideally be populated with class-specific frame options
    -- For demonstration, we'll add a simple placeholder
    table.insert(Layout.layout.rows, {
        showClassResource = {
            key = 'vmodules.vuiepf.showClassResource',
            type = 'checkbox',
            label = 'Class Resource',
            tooltip = 'Show class-specific resource tracker (combo points, runes, etc)',
            column = 6,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.frames.classResource = self:GetValue()
                    if module.UpdateFrameVisibility then
                        module:UpdateFrameVisibility()
                    end
                end
            end
        },
        showProcs = {
            key = 'vmodules.vuiepf.showProcs',
            type = 'checkbox',
            label = 'Class Procs',
            tooltip = 'Show important class proc trackers',
            column = 6,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.frames.procs = self:GetValue()
                    if module.UpdateFrameVisibility then
                        module:UpdateFrameVisibility()
                    end
                end
            end
        },
    })
end

return Layout 