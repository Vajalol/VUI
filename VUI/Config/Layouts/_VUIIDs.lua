local VUI = select(2, ...)
if not VUI.Config then return end

local Module = VUI:GetModule("VUIIDs")
if not Module then return end

-- Create the options table
VUI.Config.Layout["VUIIDs"] = {
    name = "VUI IDs",
    desc = "Adds IDs to tooltips",
    type = "group",
    order = 60,
    args = {
        general = {
            name = "General",
            type = "group",
            order = 10,
            args = {
                header = {
                    name = "Tooltip ID Display",
                    type = "header",
                    order = 1,
                },
                desc = {
                    name = "Shows various IDs in tooltips - helps with addon development and debugging.",
                    type = "description",
                    order = 2,
                },
                enabled = {
                    name = "Enable",
                    desc = "Enable tooltip ID display",
                    type = "toggle",
                    width = "full",
                    order = 3,
                    get = function() return Module.db.enabled end,
                    set = function(info, val)
                        Module.db.enabled = val
                        if val then
                            Module:Enable()
                        else
                            Module:Disable()
                        end
                    end,
                },
                spacer1 = {
                    name = "",
                    type = "description",
                    order = 4,
                },
            },
        },
        displayOptions = {
            name = "Display Options",
            type = "group",
            order = 20,
            args = {
                header = {
                    name = "ID Types to Display",
                    type = "header",
                    order = 1,
                },
                desc = {
                    name = "Choose which types of IDs to show in tooltips.",
                    type = "description",
                    order = 2,
                },
                showSpellID = {
                    name = "Spell IDs",
                    desc = "Show spell IDs in tooltips",
                    type = "toggle",
                    order = 3,
                    get = function() return Module.db.showSpellID end,
                    set = function(info, val)
                        Module.db.showSpellID = val
                    end,
                },
                showItemID = {
                    name = "Item IDs",
                    desc = "Show item IDs in tooltips",
                    type = "toggle",
                    order = 4,
                    get = function() return Module.db.showItemID end,
                    set = function(info, val)
                        Module.db.showItemID = val
                    end,
                },
                showQuestID = {
                    name = "Quest IDs",
                    desc = "Show quest IDs in tooltips",
                    type = "toggle",
                    order = 5,
                    get = function() return Module.db.showQuestID end,
                    set = function(info, val)
                        Module.db.showQuestID = val
                    end,
                },
                showTalentID = {
                    name = "Talent IDs",
                    desc = "Show talent IDs in tooltips",
                    type = "toggle",
                    order = 6,
                    get = function() return Module.db.showTalentID end,
                    set = function(info, val)
                        Module.db.showTalentID = val
                    end,
                },
                showAchievementID = {
                    name = "Achievement IDs",
                    desc = "Show achievement IDs in tooltips",
                    type = "toggle",
                    order = 7,
                    get = function() return Module.db.showAchievementID end,
                    set = function(info, val)
                        Module.db.showAchievementID = val
                    end,
                },
                showCriteriaID = {
                    name = "Criteria IDs",
                    desc = "Show criteria IDs in tooltips",
                    type = "toggle",
                    order = 8,
                    get = function() return Module.db.showCriteriaID end,
                    set = function(info, val)
                        Module.db.showCriteriaID = val
                    end,
                },
                showAbilityID = {
                    name = "Ability IDs",
                    desc = "Show ability IDs in tooltips",
                    type = "toggle",
                    order = 9,
                    get = function() return Module.db.showAbilityID end,
                    set = function(info, val)
                        Module.db.showAbilityID = val
                    end,
                },
                showCurrencyID = {
                    name = "Currency IDs",
                    desc = "Show currency IDs in tooltips",
                    type = "toggle",
                    order = 10,
                    get = function() return Module.db.showCurrencyID end,
                    set = function(info, val)
                        Module.db.showCurrencyID = val
                    end,
                },
                showEnchantID = {
                    name = "Enchant IDs",
                    desc = "Show enchant IDs in tooltips",
                    type = "toggle",
                    order = 11,
                    get = function() return Module.db.showEnchantID end,
                    set = function(info, val)
                        Module.db.showEnchantID = val
                    end,
                },
                showMountID = {
                    name = "Mount IDs",
                    desc = "Show mount IDs in tooltips",
                    type = "toggle",
                    order = 12,
                    get = function() return Module.db.showMountID end,
                    set = function(info, val)
                        Module.db.showMountID = val
                    end,
                },
            },
        },
        appearance = {
            name = "Appearance",
            type = "group",
            order = 30,
            args = {
                header = {
                    name = "Visual Settings",
                    type = "header",
                    order = 1,
                },
                desc = {
                    name = "Customize how IDs appear in tooltips.",
                    type = "description",
                    order = 2,
                },
                colorHighlight = {
                    name = "Highlight IDs",
                    desc = "Use a different color for ID values to make them stand out",
                    type = "toggle",
                    order = 3,
                    get = function() return Module.db.colorHighlight end,
                    set = function(info, val)
                        Module.db.colorHighlight = val
                    end,
                },
                highlightColor = {
                    name = "Highlight Color",
                    desc = "Select a color for ID values",
                    type = "color",
                    order = 4,
                    disabled = function() return not Module.db.colorHighlight end,
                    get = function()
                        local c = Module.db.highlightColor or {r=1, g=1, b=0} -- Default to yellow
                        return c.r, c.g, c.b, 1
                    end,
                    set = function(info, r, g, b)
                        Module.db.highlightColor = {r=r, g=g, b=b}
                    end,
                },
                idPrefix = {
                    name = "ID Prefix",
                    desc = "Text to display before the ID value (e.g., 'ID: ')",
                    type = "input",
                    order = 5,
                    get = function() return Module.db.idPrefix or "ID: " end,
                    set = function(info, val)
                        Module.db.idPrefix = val
                    end,
                },
            },
        },
    },
}

-- Register with VUI Config
VUI.Config:Register("VUIIDs", VUI.Config.Layout["VUIIDs"])