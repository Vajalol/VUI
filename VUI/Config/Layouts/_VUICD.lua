local VUI = select(2, ...)
if not VUI.Config then return end

local Module = VUI:GetModule("VUICD")
if not Module then return end

-- Create the options table
VUI.Config.Layout["VUICD"] = {
    name = "VUI CD",
    desc = "Party Cooldown Tracker",
    type = "group",
    order = 50,
    args = {
        general = {
            name = "General",
            type = "group",
            order = 10,
            args = {
                header = {
                    name = "Party Cooldown Tracker",
                    type = "header",
                    order = 1,
                },
                desc = {
                    name = "Tracks and displays party member cooldowns in various formats.",
                    type = "description",
                    order = 2,
                },
                enabled = {
                    name = "Enable",
                    desc = "Enable the party cooldown tracker",
                    type = "toggle",
                    width = "full",
                    order = 3,
                    get = function() return Module.db.party.enabled end,
                    set = function(info, val)
                        Module.db.party.enabled = val
                        if Module.Party then
                            if val then
                                Module.Party:Enable()
                            else
                                Module.Party:Disable()
                            end
                        end
                    end,
                },
                spacer1 = {
                    name = "",
                    type = "description",
                    order = 4,
                },
                testButton = {
                    name = "Test Mode",
                    desc = "Toggle test mode to view how the tracker would appear in a group",
                    type = "execute",
                    order = 5,
                    func = function()
                        if Module.Party and Module.Party.Test then
                            Module.Party:Test()
                        end
                    end,
                },
            },
        },
        visibility = {
            name = "Visibility",
            type = "group",
            order = 20,
            args = {
                header = {
                    name = "Visibility Settings",
                    type = "header",
                    order = 1,
                },
                desc = {
                    name = "Control where the cooldown tracker is displayed.",
                    type = "description",
                    order = 2,
                },
                arena = {
                    name = "Arena",
                    desc = "Show in arena",
                    type = "toggle",
                    order = 3,
                    get = function() return Module.db.party.visibility.arena end,
                    set = function(info, val)
                        Module.db.party.visibility.arena = val
                        Module:CheckInstanceType()
                    end,
                },
                raid = {
                    name = "Raid",
                    desc = "Show in raid",
                    type = "toggle",
                    order = 4,
                    get = function() return Module.db.party.visibility.raid end,
                    set = function(info, val)
                        Module.db.party.visibility.raid = val
                        Module:CheckInstanceType()
                    end,
                },
                party = {
                    name = "Party",
                    desc = "Show in 5-player party",
                    type = "toggle",
                    order = 5,
                    get = function() return Module.db.party.visibility.party end,
                    set = function(info, val)
                        Module.db.party.visibility.party = val
                        Module:CheckInstanceType()
                    end,
                },
                scenario = {
                    name = "Scenario",
                    desc = "Show in scenario",
                    type = "toggle",
                    order = 6,
                    get = function() return Module.db.party.visibility.scenario end,
                    set = function(info, val)
                        Module.db.party.visibility.scenario = val
                        Module:CheckInstanceType()
                    end,
                },
                outside = {
                    name = "Outside",
                    desc = "Show outside of instances",
                    type = "toggle",
                    order = 7,
                    get = function() return Module.db.party.visibility.outside end,
                    set = function(info, val)
                        Module.db.party.visibility.outside = val
                        Module:CheckInstanceType()
                    end,
                },
            },
        },
        icons = {
            name = "Icons",
            type = "group",
            order = 30,
            args = {
                header = {
                    name = "Icon Settings",
                    type = "header",
                    order = 1,
                },
                desc = {
                    name = "Customize how cooldown icons are displayed.",
                    type = "description",
                    order = 2,
                },
                scale = {
                    name = "Size Scale",
                    desc = "Adjust the size of cooldown icons",
                    type = "range",
                    min = 0.5,
                    max = 2.0,
                    step = 0.05,
                    order = 3,
                    get = function() return Module.db.party.icons.scale end,
                    set = function(info, val)
                        Module.db.party.icons.scale = val
                        Module:UpdateRoster() -- Refresh icons with new size
                    end,
                },
                padding = {
                    name = "Padding",
                    desc = "Space between icons",
                    type = "range",
                    min = 0,
                    max = 10,
                    step = 1,
                    order = 4,
                    get = function() return Module.db.party.icons.padding end,
                    set = function(info, val)
                        Module.db.party.icons.padding = val
                        Module:UpdateRoster() -- Refresh icons with new padding
                    end,
                },
                columns = {
                    name = "Columns",
                    desc = "Number of icons per row",
                    type = "range",
                    min = 1,
                    max = 20,
                    step = 1,
                    order = 5,
                    get = function() return Module.db.party.icons.columns end,
                    set = function(info, val)
                        Module.db.party.icons.columns = val
                        Module:UpdateRoster() -- Refresh icon layout
                    end,
                },
                showTooltip = {
                    name = "Show Tooltip",
                    desc = "Show spell tooltips on mouseover",
                    type = "toggle",
                    order = 6,
                    get = function() return Module.db.party.icons.showTooltip end,
                    set = function(info, val)
                        Module.db.party.icons.showTooltip = val
                    end,
                },
                showCounter = {
                    name = "Show Counter",
                    desc = "Show cooldown time remaining",
                    type = "toggle",
                    order = 7,
                    get = function() return Module.db.party.icons.showCounter end,
                    set = function(info, val)
                        Module.db.party.icons.showCounter = val
                    end,
                },
                desaturate = {
                    name = "Desaturate Icons",
                    desc = "Desaturate icons when on cooldown",
                    type = "toggle",
                    order = 8,
                    get = function() return Module.db.party.icons.desaturate end,
                    set = function(info, val)
                        Module.db.party.icons.desaturate = val
                    end,
                },
            },
        },
        spells = {
            name = "Spells",
            type = "group",
            order = 40,
            args = {
                header = {
                    name = "Spell Categories",
                    type = "header",
                    order = 1,
                },
                desc = {
                    name = "Choose which types of spells to track.",
                    type = "description",
                    order = 2,
                },
                defensive = {
                    name = "Defensive",
                    desc = "Track defensive cooldowns (damage reduction, etc.)",
                    type = "toggle",
                    order = 3,
                    get = function() return Module.db.party.spells.defensive end,
                    set = function(info, val)
                        Module.db.party.spells.defensive = val
                        Module:UpdateRoster() -- Refresh with new spell filter
                    end,
                },
                offensive = {
                    name = "Offensive",
                    desc = "Track offensive cooldowns (damage increase, etc.)",
                    type = "toggle",
                    order = 4,
                    get = function() return Module.db.party.spells.offensive end,
                    set = function(info, val)
                        Module.db.party.spells.offensive = val
                        Module:UpdateRoster() -- Refresh with new spell filter
                    end,
                },
                interrupt = {
                    name = "Interrupts",
                    desc = "Track interrupt spells",
                    type = "toggle",
                    order = 5,
                    get = function() return Module.db.party.spells.interrupt end,
                    set = function(info, val)
                        Module.db.party.spells.interrupt = val
                        Module:UpdateRoster() -- Refresh with new spell filter
                    end,
                },
                utility = {
                    name = "Utility",
                    desc = "Track utility spells (CC, dispels, etc.)",
                    type = "toggle",
                    order = 6,
                    get = function() return Module.db.party.spells.utility end,
                    set = function(info, val)
                        Module.db.party.spells.utility = val
                        Module:UpdateRoster() -- Refresh with new spell filter
                    end,
                },
                covenant = {
                    name = "Covenant",
                    desc = "Track covenant abilities",
                    type = "toggle",
                    order = 7,
                    get = function() return Module.db.party.spells.covenant end,
                    set = function(info, val)
                        Module.db.party.spells.covenant = val
                        Module:UpdateRoster() -- Refresh with new spell filter
                    end,
                },
            },
        },
    },
}

-- Register with VUI Config
VUI.Config:Register("VUICD", VUI.Config.Layout["VUICD"])