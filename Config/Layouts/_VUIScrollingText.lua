--[[
    VUI Scrolling Text Module Configuration
    Enhanced combat text display
]]

local Layout = VUI:NewModule('Config.Layout.VUIScrollingText')

-- Initialize with the standard layout helper
VUI.ConfigHelpers.CreateStandardLayout(Layout, "VUIScrollingText", "VUI Scrolling Text", "vmodules.vuiscrollingtext")

-- Define module-specific layout construction
function Layout:BuildModuleLayout(module, db)
    -- Extend the base layout with module-specific settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Scrolling Text Settings'
        },
    })
    
    -- Add basic settings
    table.insert(Layout.layout.rows, {
        enableScrollingText = {
            key = 'vmodules.vuiscrollingtext.enabled',
            type = 'checkbox',
            label = 'Enable Scrolling Text',
            tooltip = 'Enable enhanced scrolling combat text',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.general.enabled = self:GetValue()
                    if module.UpdateSettings then
                        module:UpdateSettings()
                    end
                end
            end
        },
        replaceBlizzardText = {
            key = 'vmodules.vuiscrollingtext.replaceBlizzard',
            type = 'checkbox',
            label = 'Replace Blizzard Text',
            tooltip = 'Replace default Blizzard floating combat text',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.general.replaceBlizzard = self:GetValue()
                    if self:GetValue() then
                        SetCVar("floatingCombatTextCombatDamage", 0)
                        SetCVar("floatingCombatTextCombatHealing", 0)
                    else
                        SetCVar("floatingCombatTextCombatDamage", 1)
                        SetCVar("floatingCombatTextCombatHealing", 1)
                    end
                end
            end
        },
        animationStyle = {
            key = 'vmodules.vuiscrollingtext.animationStyle',
            type = 'dropdown',
            label = 'Animation Style',
            tooltip = 'Select the animation style for scrolling text',
            options = {
                {value = "VERTICAL", text = "Vertical"},
                {value = "HORIZONTAL", text = "Horizontal"},
                {value = "FOUNTAIN", text = "Fountain"},
                {value = "CASCADE", text = "Cascade"}
            },
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.animation.style = self:GetValue()
                    if module.UpdateSettings then
                        module:UpdateSettings()
                    end
                end
            end
        },
    })
    
    -- Display configuration
    table.insert(Layout.layout.rows, {
        textSize = {
            key = 'vmodules.vuiscrollingtext.textSize',
            type = 'slider',
            label = 'Text Size',
            tooltip = 'Size of scrolling combat text',
            min = 8,
            max = 32,
            step = 1,
            column = 4,
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
        fadeTime = {
            key = 'vmodules.vuiscrollingtext.fadeTime',
            type = 'slider',
            label = 'Fade Time',
            tooltip = 'How long text remains visible (seconds)',
            min = 0.5,
            max = 5.0,
            step = 0.1,
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.animation.fadeTime = self:GetValue()
                end
            end
        },
        showIcons = {
            key = 'vmodules.vuiscrollingtext.showIcons',
            type = 'checkbox',
            label = 'Show Icons',
            tooltip = 'Show spell/ability icons with text',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.showIcons = self:GetValue()
                    if module.UpdateDisplay then
                        module:UpdateDisplay()
                    end
                end
            end
        },
    })
    
    -- Text categories
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Text Categories'
        },
    })
    
    table.insert(Layout.layout.rows, {
        showDamage = {
            key = 'vmodules.vuiscrollingtext.showDamage',
            type = 'checkbox',
            label = 'Show Damage',
            tooltip = 'Show outgoing damage text',
            column = 3,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.categories.damage = self:GetValue()
                end
            end
        },
        showHealing = {
            key = 'vmodules.vuiscrollingtext.showHealing',
            type = 'checkbox',
            label = 'Show Healing',
            tooltip = 'Show healing text',
            column = 3,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.categories.healing = self:GetValue()
                end
            end
        },
        showMisses = {
            key = 'vmodules.vuiscrollingtext.showMisses',
            type = 'checkbox',
            label = 'Show Misses',
            tooltip = 'Show miss/dodge/parry text',
            column = 3,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.categories.misses = self:GetValue()
                end
            end
        },
        showPet = {
            key = 'vmodules.vuiscrollingtext.showPet',
            type = 'checkbox',
            label = 'Show Pet Actions',
            tooltip = 'Show pet damage and abilities',
            column = 3,
            order = 4,
            callback = function(self)
                if module and module.db then
                    module.db.profile.categories.pet = self:GetValue()
                end
            end
        },
    })
    
    -- Color settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Color Settings'
        },
    })
    
    table.insert(Layout.layout.rows, {
        damageColor = {
            key = 'vmodules.vuiscrollingtext.damageColor',
            type = 'color',
            label = 'Damage Color',
            tooltip = 'Color for damage text',
            column = 3,
            order = 1,
            callback = function(self)
                if module and module.db then
                    local r, g, b = self:GetRGB()
                    module.db.profile.colors.damage = {r, g, b}
                end
            end
        },
        critColor = {
            key = 'vmodules.vuiscrollingtext.critColor',
            type = 'color',
            label = 'Critical Color',
            tooltip = 'Color for critical hit text',
            hasAlpha = true,
            column = 3,
            order = 2,
            callback = function(self)
                if module and module.db then
                    local r, g, b = self:GetRGB()
                    module.db.profile.colors.critical = {r, g, b}
                end
            end
        },
        healingColor = {
            key = 'vmodules.vuiscrollingtext.healingColor',
            type = 'color',
            label = 'Healing Color',
            tooltip = 'Color for healing text',
            column = 3,
            order = 3,
            callback = function(self)
                if module and module.db then
                    local r, g, b = self:GetRGB()
                    module.db.profile.colors.healing = {r, g, b}
                end
            end
        },
        missColor = {
            key = 'vmodules.vuiscrollingtext.missColor',
            type = 'color',
            label = 'Miss Color',
            tooltip = 'Color for miss/dodge/parry text',
            hasAlpha = true,
            column = 3,
            order = 4,
            callback = function(self)
                if module and module.db then
                    local r, g, b = self:GetRGB()
                    module.db.profile.colors.miss = {r, g, b}
                end
            end
        },
    })
end

return Layout 