--[[
    VUI Target GCD Module Configuration
    GCD tracker for target casting and abilities
]]

local Layout = VUI:NewModule('Config.Layout.VUITGCD')

-- Initialize with the standard layout helper
VUI.ConfigHelpers.CreateStandardLayout(Layout, "VUITGCD", "VUI Target GCD", "vmodules.vuitgcd")

-- Function to ensure module database is properly accessible
local function ensureModuleDB(module, db)
    if not module then return nil end
    
    -- Create necessary paths in database
    if not db.profile.vmodules then db.profile.vmodules = {} end
    if not db.profile.vmodules.vuitgcd then db.profile.vmodules.vuitgcd = {} end
    
    -- If module has display settings, create them if not present
    if not module.db or not module.db.profile then
        module.db = module.db or {}
        module.db.profile = module.db.profile or {}
    end
    
    if not module.db.profile.display then
        module.db.profile.display = {}
    end
    
    if not module.db.profile.general then
        module.db.profile.general = {}
    end
    
    if not module.db.profile.tracking then
        module.db.profile.tracking = {}
    end
    
    if not module.db.profile.filter then
        module.db.profile.filter = {}
    end
    
    if not module.db.profile.instances then
        module.db.profile.instances = {}
    end
    
    -- Sync with vmodules path for UI
    db.profile.vmodules.vuitgcd.display = module.db.profile.display
    db.profile.vmodules.vuitgcd.general = module.db.profile.general
    db.profile.vmodules.vuitgcd.tracking = module.db.profile.tracking
    db.profile.vmodules.vuitgcd.filter = module.db.profile.filter
    db.profile.vmodules.vuitgcd.instances = module.db.profile.instances
    
    return module.db
end

-- Define module-specific layout construction
function Layout:BuildModuleLayout(module, db)
    -- Initialize module DB
    ensureModuleDB(module, db)
    
    -- Extend the base layout with module-specific settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'GCD Display Settings'
        },
    })
    
    -- Add basic settings
    table.insert(Layout.layout.rows, {
        showBar = {
            key = 'vmodules.vuitgcd.showBar',
            type = 'checkbox',
            label = 'Show GCD Bar',
            tooltip = 'Show the GCD tracking bar',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.showBar = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
        showIcon = {
            key = 'vmodules.vuitgcd.showIcon',
            type = 'checkbox',
            label = 'Show Spell Icon',
            tooltip = 'Show spell icon on the GCD bar',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.showIcon = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
        lockFrames = {
            key = 'vmodules.vuitgcd.lockFrames',
            type = 'checkbox',
            label = 'Lock Frames',
            tooltip = 'Lock or unlock the GCD tracker frame',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.general.lockFrames = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
    })
    
    -- Bar configuration
    table.insert(Layout.layout.rows, {
        barWidth = {
            key = 'vmodules.vuitgcd.barWidth',
            type = 'slider',
            label = 'Bar Width',
            tooltip = 'Set the width of the GCD bar',
            min = 50,
            max = 300,
            step = 1,
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.barWidth = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
        barHeight = {
            key = 'vmodules.vuitgcd.barHeight',
            type = 'slider',
            label = 'Bar Height',
            tooltip = 'Set the height of the GCD bar',
            min = 1,
            max = 50,
            step = 1,
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.barHeight = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
        iconSize = {
            key = 'vmodules.vuitgcd.iconSize',
            type = 'slider',
            label = 'Icon Size',
            tooltip = 'Set the size of spell icons',
            min = 16,
            max = 64,
            step = 1,
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.iconSize = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
    })
    
    -- Tracking settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Target Tracking Settings'
        },
    })
    
    table.insert(Layout.layout.rows, {
        trackTarget = {
            key = 'vmodules.vuitgcd.trackTarget',
            type = 'checkbox',
            label = 'Track Current Target',
            tooltip = 'Track GCD for your current target',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.tracking.trackTarget = self:GetValue()
                end
            end
        },
        trackFocus = {
            key = 'vmodules.vuitgcd.trackFocus',
            type = 'checkbox',
            label = 'Track Focus Target',
            tooltip = 'Track GCD for your focus target',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.tracking.trackFocus = self:GetValue()
                end
            end
        },
        trackAllPlayers = {
            key = 'vmodules.vuitgcd.trackAllPlayers',
            type = 'checkbox',
            label = 'Track All Players',
            tooltip = 'Track GCD for all players (can impact performance)',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.tracking.trackAllPlayers = self:GetValue()
                end
            end
        },
    })
    
    -- Advanced appearance settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Appearance Settings'
        },
    })
    
    table.insert(Layout.layout.rows, {
        showSpellName = {
            key = 'vmodules.vuitgcd.showSpellName',
            type = 'checkbox',
            label = 'Show Spell Name',
            tooltip = 'Show the name of the spell being cast',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.showSpellName = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
        showCasterName = {
            key = 'vmodules.vuitgcd.showCasterName',
            type = 'checkbox',
            label = 'Show Caster Name',
            tooltip = 'Show the name of the spell caster',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.showCasterName = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
        showPing = {
            key = 'vmodules.vuitgcd.showPing',
            type = 'checkbox',
            label = 'Show Ping Indicator',
            tooltip = 'Show network latency indicator on the GCD bar',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.showPing = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
    })
    
    -- Font settings
    table.insert(Layout.layout.rows, {
        textSize = {
            key = 'vmodules.vuitgcd.textSize',
            type = 'slider',
            label = 'Text Size',
            tooltip = 'Size of text displayed on the GCD bar',
            min = 8,
            max = 24,
            step = 1,
            column = 6,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.textSize = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
        textOutline = {
            key = 'vmodules.vuitgcd.textOutline',
            type = 'dropdown',
            label = 'Text Outline',
            tooltip = 'Style of text outline to use',
            options = {
                {value = "NONE", text = "None"},
                {value = "OUTLINE", text = "Outline"},
                {value = "THICKOUTLINE", text = "Thick Outline"}
            },
            column = 6,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.textOutline = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
    })
    
    -- Advanced options
    table.insert(Layout.layout.rows, {
        barColor = {
            key = 'vmodules.vuitgcd.barColor',
            type = 'color',
            label = 'Bar Color',
            tooltip = 'Set the color of the GCD bar',
            hasAlpha = true,
            column = 6,
            order = 1,
            callback = function(self)
                if module and module.db then
                    local r, g, b, a = self:GetRGBA()
                    module.db.profile.display.barColor = {r, g, b, a}
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
        castColor = {
            key = 'vmodules.vuitgcd.castColor',
            type = 'color',
            label = 'Cast Color',
            tooltip = 'Set the color for casting spells',
            hasAlpha = true,
            column = 6,
            order = 2,
            callback = function(self)
                if module and module.db then
                    local r, g, b, a = self:GetRGBA()
                    module.db.profile.display.castColor = {r, g, b, a}
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
    })
    
    -- Spell filtering
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Spell Filtering'
        },
    })
    
    table.insert(Layout.layout.rows, {
        enableFiltering = {
            key = 'vmodules.vuitgcd.enableFiltering',
            type = 'checkbox',
            label = 'Enable Spell Filtering',
            tooltip = 'Enable filtering of which spells to track',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.filter.enableFiltering = self:GetValue()
                end
            end
        },
        showDamageSpells = {
            key = 'vmodules.vuitgcd.showDamageSpells',
            type = 'checkbox',
            label = 'Show Damage Spells',
            tooltip = 'Show damage-dealing spells in the tracker',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.filter.showDamageSpells = self:GetValue()
                end
            end
        },
        showHealingSpells = {
            key = 'vmodules.vuitgcd.showHealingSpells',
            type = 'checkbox',
            label = 'Show Healing Spells',
            tooltip = 'Show healing spells in the tracker',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.filter.showHealingSpells = self:GetValue()
                end
            end
        },
    })
    
    table.insert(Layout.layout.rows, {
        showCooldowns = {
            key = 'vmodules.vuitgcd.showCooldowns',
            type = 'checkbox',
            label = 'Show Cooldowns',
            tooltip = 'Show cooldown abilities in the tracker',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.filter.showCooldowns = self:GetValue()
                end
            end
        },
        showInterrupts = {
            key = 'vmodules.vuitgcd.showInterrupts',
            type = 'checkbox',
            label = 'Show Interrupts',
            tooltip = 'Show interrupt abilities in the tracker',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.filter.showInterrupts = self:GetValue()
                end
            end
        },
        showUtility = {
            key = 'vmodules.vuitgcd.showUtility',
            type = 'checkbox',
            label = 'Show Utility Spells',
            tooltip = 'Show utility spells in the tracker',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.filter.showUtility = self:GetValue()
                end
            end
        },
    })
    
    -- Instance-specific settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Instance Settings'
        },
    })
    
    table.insert(Layout.layout.rows, {
        enableInWorld = {
            key = 'vmodules.vuitgcd.enableInWorld',
            type = 'checkbox',
            label = 'Enable in World',
            tooltip = 'Enable the GCD tracker in the open world',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.instances.enableInWorld = self:GetValue()
                end
            end
        },
        enableInDungeons = {
            key = 'vmodules.vuitgcd.enableInDungeons',
            type = 'checkbox',
            label = 'Enable in Dungeons',
            tooltip = 'Enable the GCD tracker in dungeons',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.instances.enableInDungeons = self:GetValue()
                end
            end
        },
        enableInRaids = {
            key = 'vmodules.vuitgcd.enableInRaids',
            type = 'checkbox',
            label = 'Enable in Raids',
            tooltip = 'Enable the GCD tracker in raids',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.instances.enableInRaids = self:GetValue()
                end
            end
        },
    })
    
    -- Control buttons
    table.insert(Layout.layout.rows, {
        resetPositions = {
            type = 'button',
            label = 'Reset Positions',
            tooltip = 'Reset all frame positions to default',
            column = 6,
            order = 1,
            callback = function()
                if module and module.ResetPositions then
                    module:ResetPositions()
                end
            end
        },
        toggleAnchors = {
            type = 'button',
            label = 'Toggle Anchors',
            tooltip = 'Show or hide frame anchors for moving',
            column = 6,
            order = 2,
            callback = function()
                if module and module.ToggleAnchors then
                    module:ToggleAnchors()
                end
            end
        },
    })
end

return Layout 