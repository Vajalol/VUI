--[[
    VUIIDs Module Configuration
    Shows IDs in tooltips for spells, items, NPCs, etc.
    Based on the original idTip addon
]]

local Layout = VUI:NewModule('Config.Layout.VUIIDs')

-- Initialize with the standard layout helper
VUI.ConfigHelpers.CreateStandardLayout(Layout, "VUIIDs", "VUI IDs", "vmodules.vuiids")

-- Define module-specific layout construction
function Layout:BuildModuleLayout(module, db)
    -- Extend the base layout with module-specific settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Tooltip ID Display'
        },
    })
    
    -- Add basic settings
    table.insert(Layout.layout.rows, {
        enabledDesc = {
            type = 'label',
            label = 'Show various IDs in tooltips - helps with addon development, sharing info, and identifying game objects.',
            column = 12,
            order = 1,
        },
        enabled = {
            key = 'vmodules.vuiids.enabled',
            type = 'checkbox',
            label = 'Enable Tooltip IDs',
            tooltip = 'Show IDs in your tooltips',
            column = 12,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.enabled = self:GetValue()
                    if self:GetValue() then
                        module:Enable()
                    else
                        module:Disable()
                    end
                end
            end
        },
    })
    
    -- General ID types section
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'General IDs'
        },
    })
    
    table.insert(Layout.layout.rows, {
        showSpellID = {
            key = 'vmodules.vuiids.showSpellID',
            type = 'checkbox',
            label = 'Spell IDs',
            tooltip = 'Show spell IDs in tooltips',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.showSpellID = self:GetValue()
                end
            end
        },
        showItemID = {
            key = 'vmodules.vuiids.showItemID',
            type = 'checkbox',
            label = 'Item IDs',
            tooltip = 'Show item IDs in tooltips',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.showItemID = self:GetValue()
                end
            end
        },
        showNPCID = {
            key = 'vmodules.vuiids.showNPCID',
            type = 'checkbox',
            label = 'NPC IDs',
            tooltip = 'Show NPC IDs in tooltips',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.showNPCID = self:GetValue()
                end
            end
        },
        showQuestID = {
            key = 'vmodules.vuiids.showQuestID',
            type = 'checkbox',
            label = 'Quest IDs',
            tooltip = 'Show quest IDs in tooltips',
            column = 4,
            order = 4,
            callback = function(self)
                if module and module.db then
                    module.db.profile.showQuestID = self:GetValue()
                end
            end
        },
        showCurrencyID = {
            key = 'vmodules.vuiids.showCurrencyID',
            type = 'checkbox',
            label = 'Currency IDs',
            tooltip = 'Show currency IDs in tooltips',
            column = 4,
            order = 5,
            callback = function(self)
                if module and module.db then
                    module.db.profile.showCurrencyID = self:GetValue()
                end
            end
        },
        showAchievementID = {
            key = 'vmodules.vuiids.showAchievementID',
            type = 'checkbox',
            label = 'Achievement IDs',
            tooltip = 'Show achievement IDs in tooltips',
            column = 4,
            order = 6,
            callback = function(self)
                if module and module.db then
                    module.db.profile.showAchievementID = self:GetValue()
                end
            end
        },
    })
    
    -- Item Related IDs
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Item Related IDs'
        },
    })
    
    table.insert(Layout.layout.rows, {
        showEnchantID = {
            key = 'vmodules.vuiids.showEnchantID',
            type = 'checkbox',
            label = 'Enchant IDs',
            tooltip = 'Show enchant IDs in tooltips',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.showEnchantID = self:GetValue()
                end
            end
        },
        showBonusID = {
            key = 'vmodules.vuiids.showBonusID',
            type = 'checkbox',
            label = 'Bonus IDs',
            tooltip = 'Show item bonus IDs in tooltips',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.showBonusID = self:GetValue()
                end
            end
        },
        showGemID = {
            key = 'vmodules.vuiids.showGemID',
            type = 'checkbox',
            label = 'Gem IDs',
            tooltip = 'Show gem IDs in tooltips',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.showGemID = self:GetValue()
                end
            end
        },
        showSetID = {
            key = 'vmodules.vuiids.showSetID',
            type = 'checkbox',
            label = 'Set IDs',
            tooltip = 'Show equipment set IDs in tooltips',
            column = 4,
            order = 4,
            callback = function(self)
                if module and module.db then
                    module.db.profile.showSetID = self:GetValue()
                end
            end
        },
        showIconID = {
            key = 'vmodules.vuiids.showIconID',
            type = 'checkbox',
            label = 'Icon IDs',
            tooltip = 'Show icon IDs in tooltips',
            column = 4,
            order = 5,
            callback = function(self)
                if module and module.db then
                    module.db.profile.showIconID = self:GetValue()
                end
            end
        },
        showExpansionID = {
            key = 'vmodules.vuiids.showExpansionID',
            type = 'checkbox',
            label = 'Expansion IDs',
            tooltip = 'Show expansion IDs in tooltips',
            column = 4,
            order = 6,
            callback = function(self)
                if module and module.db then
                    module.db.profile.showExpansionID = self:GetValue()
                end
            end
        },
    })
    
    -- Character & World IDs
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Character & World IDs'
        },
    })
    
    table.insert(Layout.layout.rows, {
        showTalentID = {
            key = 'vmodules.vuiids.showTalentID',
            type = 'checkbox',
            label = 'Talent IDs',
            tooltip = 'Show talent IDs in tooltips',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.showTalentID = self:GetValue()
                end
            end
        },
        showMountID = {
            key = 'vmodules.vuiids.showMountID',
            type = 'checkbox',
            label = 'Mount IDs',
            tooltip = 'Show mount IDs in tooltips',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.showMountID = self:GetValue()
                end
            end
        },
        showCompanionID = {
            key = 'vmodules.vuiids.showCompanionID',
            type = 'checkbox',
            label = 'Companion IDs',
            tooltip = 'Show companion pet IDs in tooltips',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.showCompanionID = self:GetValue()
                end
            end
        },
        showSpeciesID = {
            key = 'vmodules.vuiids.showSpeciesID',
            type = 'checkbox',
            label = 'Species IDs',
            tooltip = 'Show pet species IDs in tooltips',
            column = 4,
            order = 4,
            callback = function(self)
                if module and module.db then
                    module.db.profile.showSpeciesID = self:GetValue()
                end
            end
        },
        showAreaPoiID = {
            key = 'vmodules.vuiids.showAreaPoiID',
            type = 'checkbox',
            label = 'Area POI IDs',
            tooltip = 'Show area point of interest IDs in tooltips',
            column = 4,
            order = 5,
            callback = function(self)
                if module and module.db then
                    module.db.profile.showAreaPoiID = self:GetValue()
                end
            end
        },
        showVignetteID = {
            key = 'vmodules.vuiids.showVignetteID',
            type = 'checkbox',
            label = 'Vignette IDs',
            tooltip = 'Show vignette IDs in tooltips',
            column = 4,
            order = 6,
            callback = function(self)
                if module and module.db then
                    module.db.profile.showVignetteID = self:GetValue()
                end
            end
        },
    })
    
    -- Transmogrification & Visual IDs
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Transmogrification & Visual IDs'
        },
    })
    
    table.insert(Layout.layout.rows, {
        showVisualID = {
            key = 'vmodules.vuiids.showVisualID',
            type = 'checkbox',
            label = 'Visual IDs',
            tooltip = 'Show visual IDs for transmogrified items',
            column = 6,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.showVisualID = self:GetValue()
                end
            end
        },
        showSourceID = {
            key = 'vmodules.vuiids.showSourceID',
            type = 'checkbox',
            label = 'Source IDs',
            tooltip = 'Show source IDs for transmogrified items',
            column = 6,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.showSourceID = self:GetValue()
                end
            end
        },
    })
    
    -- Advanced IDs
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Advanced IDs'
        },
    })
    
    table.insert(Layout.layout.rows, {
        advancedDesc = {
            type = 'label',
            label = 'These advanced IDs are disabled by default to reduce tooltip clutter',
            column = 12,
            order = 1,
        },
        showTraitNodeID = {
            key = 'vmodules.vuiids.showTraitNodeID',
            type = 'checkbox',
            label = 'Trait Node IDs',
            tooltip = 'Show trait node IDs in tooltips (Dragonflight talent system)',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.showTraitNodeID = self:GetValue()
                end
            end
        },
        showTraitEntryID = {
            key = 'vmodules.vuiids.showTraitEntryID',
            type = 'checkbox',
            label = 'Trait Entry IDs',
            tooltip = 'Show trait entry IDs in tooltips (Dragonflight talent system)',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.showTraitEntryID = self:GetValue()
                end
            end
        },
        showTraitDefID = {
            key = 'vmodules.vuiids.showTraitDefID',
            type = 'checkbox',
            label = 'Trait Definition IDs',
            tooltip = 'Show trait definition IDs in tooltips (Dragonflight talent system)',
            column = 4,
            order = 4,
            callback = function(self)
                if module and module.db then
                    module.db.profile.showTraitDefID = self:GetValue()
                end
            end
        },
    })
end

return Layout 