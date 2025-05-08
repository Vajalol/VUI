local VUI = select(2, ...)
if not VUI.Config then return end

local Module = VUI:GetModule("VUIGfinder")
if not Module then return end

-- Create the options table
VUI.Config.Layout["VUIGfinder"] = {
    name = "VUI Gfinder",
    desc = "Enhances the Group Finder with advanced filtering",
    type = "group",
    order = 70,
    args = {
        general = {
            name = "General",
            type = "group",
            order = 10,
            args = {
                header = {
                    name = "Premade Group Finder",
                    type = "header",
                    order = 1,
                },
                desc = {
                    name = "Enhances the Group Finder with advanced filtering and sorting capabilities.",
                    type = "description",
                    order = 2,
                },
                enabled = {
                    name = "Enable",
                    desc = "Enable VUI Gfinder functionality",
                    type = "toggle",
                    width = "full",
                    order = 3,
                    get = function() return Module.db.profile.enabled end,
                    set = function(info, val)
                        Module.db.profile.enabled = val
                        if val then
                            Module:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED")
                            Module:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED")
                            Module:HookSearchResults()
                        else
                            Module:UnregisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED")
                            Module:UnregisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED")
                        end
                    end,
                },
                spacer1 = {
                    name = "",
                    type = "description",
                    order = 4,
                },
                openDialog = {
                    name = "Open Filter Dialog",
                    desc = "Open the VUI Gfinder filtering dialog",
                    type = "execute",
                    order = 5,
                    func = function()
                        if VUIGfinder and VUIGfinder.Dialog then
                            VUIGfinder.Dialog:Toggle()
                        end
                    end,
                },
            },
        },
        ui = {
            name = "User Interface",
            type = "group",
            order = 20,
            args = {
                header = {
                    name = "UI Settings",
                    type = "header",
                    order = 1,
                },
                desc = {
                    name = "Configure how the VUI Gfinder interface behaves.",
                    type = "description",
                    order = 2,
                },
                dialogScale = {
                    name = "Dialog Scale",
                    desc = "Scale of the filtering dialog",
                    type = "range",
                    min = 0.5,
                    max = 2.0,
                    step = 0.05,
                    order = 3,
                    get = function() return Module.db.profile.ui.dialogScale end,
                    set = function(info, val)
                        Module.db.profile.ui.dialogScale = val
                        if VUIGfinder and VUIGfinder.Dialog and VUIGfinder.Dialog.frame then
                            VUIGfinder.Dialog.frame:SetScale(val)
                        end
                    end,
                },
                tooltipEnhancement = {
                    name = "Enhanced Tooltips",
                    desc = "Show additional information in group tooltips",
                    type = "toggle",
                    order = 4,
                    get = function() return Module.db.profile.ui.tooltipEnhancement end,
                    set = function(info, val)
                        Module.db.profile.ui.tooltipEnhancement = val
                    end,
                },
                oneClickSignUp = {
                    name = "One-Click Sign Up",
                    desc = "Enable signing up for groups with a single click",
                    type = "toggle",
                    order = 5,
                    get = function() return Module.db.profile.ui.oneClickSignUp end,
                    set = function(info, val)
                        Module.db.profile.ui.oneClickSignUp = val
                        if val and VUIGfinder and VUIGfinder.OneClickSignUp then
                            VUIGfinder.OneClickSignUp:Initialize()
                        end
                    end,
                },
                persistSignUpNote = {
                    name = "Remember Sign Up Notes",
                    desc = "Remember your last used sign up note",
                    type = "toggle",
                    order = 6,
                    get = function() return Module.db.profile.ui.persistSignUpNote end,
                    set = function(info, val)
                        Module.db.profile.ui.persistSignUpNote = val
                        if val and VUIGfinder and VUIGfinder.PersistSignUpNote then
                            VUIGfinder.PersistSignUpNote:Initialize()
                        end
                    end,
                },
                signUpOnEnter = {
                    name = "Sign Up on Enter",
                    desc = "Press Enter to sign up after typing a note",
                    type = "toggle",
                    order = 7,
                    get = function() return Module.db.profile.ui.signUpOnEnter end,
                    set = function(info, val)
                        Module.db.profile.ui.signUpOnEnter = val
                        if val and VUIGfinder and VUIGfinder.SignUpOnEnter then
                            VUIGfinder.SignUpOnEnter:Initialize()
                        end
                    end,
                },
                usePGFButton = {
                    name = "Show Filter Button",
                    desc = "Show a button on the Group Finder to quickly access filters",
                    type = "toggle",
                    order = 8,
                    get = function() return Module.db.profile.ui.usePGFButton end,
                    set = function(info, val)
                        Module.db.profile.ui.usePGFButton = val
                        if val and VUIGfinder and VUIGfinder.UsePGFButton then
                            VUIGfinder.UsePGFButton:Create()
                        elseif VUIGfinder and VUIGfinder.UsePGFButton then
                            VUIGfinder.UsePGFButton:Remove()
                        end
                    end,
                },
            },
        },
        filtering = {
            name = "Filtering",
            type = "group",
            order = 30,
            args = {
                header = {
                    name = "Filter Settings",
                    type = "header",
                    order = 1,
                },
                desc = {
                    name = "Configure default filtering options for different activity types.",
                    type = "description",
                    order = 2,
                },
                dungeonHeader = {
                    name = "Dungeon Filter Defaults",
                    type = "header",
                    order = 10,
                },
                dungeonEnabled = {
                    name = "Enable Dungeon Filtering",
                    desc = "Apply filtering to dungeon groups",
                    type = "toggle",
                    order = 11,
                    get = function() return Module.db.profile.dungeon.enabled end,
                    set = function(info, val)
                        Module.db.profile.dungeon.enabled = val
                    end,
                },
                minDungeonDifficulty = {
                    name = "Minimum Difficulty",
                    desc = "Minimum dungeon difficulty to show",
                    type = "select",
                    order = 12,
                    values = {
                        [1] = "Normal",
                        [2] = "Heroic",
                        [3] = "Mythic",
                        [4] = "Mythic+"
                    },
                    get = function() return Module.db.profile.dungeon.minimumDifficulty end,
                    set = function(info, val)
                        Module.db.profile.dungeon.minimumDifficulty = val
                    end,
                },
                maxDungeonDifficulty = {
                    name = "Maximum Difficulty",
                    desc = "Maximum dungeon difficulty to show",
                    type = "select",
                    order = 13,
                    values = {
                        [1] = "Normal",
                        [2] = "Heroic",
                        [3] = "Mythic",
                        [4] = "Mythic+"
                    },
                    get = function() return Module.db.profile.dungeon.maximumDifficulty end,
                    set = function(info, val)
                        Module.db.profile.dungeon.maximumDifficulty = val
                    end,
                },
                minMythicLevel = {
                    name = "Min Mythic+ Level",
                    desc = "Minimum Mythic+ level to display",
                    type = "range",
                    min = 2,
                    max = 30,
                    step = 1,
                    order = 14,
                    get = function() return Module.db.profile.dungeon.minMythicPlusLevel end,
                    set = function(info, val)
                        Module.db.profile.dungeon.minMythicPlusLevel = val
                    end,
                },
                maxMythicLevel = {
                    name = "Max Mythic+ Level",
                    desc = "Maximum Mythic+ level to display",
                    type = "range",
                    min = 2,
                    max = 30,
                    step = 1,
                    order = 15,
                    get = function() return Module.db.profile.dungeon.maxMythicPlusLevel end,
                    set = function(info, val)
                        Module.db.profile.dungeon.maxMythicPlusLevel = val
                    end,
                },
                raidHeader = {
                    name = "Raid Filter Defaults",
                    type = "header",
                    order = 20,
                },
                raidEnabled = {
                    name = "Enable Raid Filtering",
                    desc = "Apply filtering to raid groups",
                    type = "toggle",
                    order = 21,
                    get = function() return Module.db.profile.raid.enabled end,
                    set = function(info, val)
                        Module.db.profile.raid.enabled = val
                    end,
                },
                minRaidDifficulty = {
                    name = "Minimum Difficulty",
                    desc = "Minimum raid difficulty to show",
                    type = "select",
                    order = 22,
                    values = {
                        [1] = "Normal",
                        [2] = "Heroic",
                        [3] = "Mythic"
                    },
                    get = function() return Module.db.profile.raid.minimumDifficulty end,
                    set = function(info, val)
                        Module.db.profile.raid.minimumDifficulty = val
                    end,
                },
                maxRaidDifficulty = {
                    name = "Maximum Difficulty",
                    desc = "Maximum raid difficulty to show",
                    type = "select",
                    order = 23,
                    values = {
                        [1] = "Normal",
                        [2] = "Heroic",
                        [3] = "Mythic"
                    },
                    get = function() return Module.db.profile.raid.maximumDifficulty end,
                    set = function(info, val)
                        Module.db.profile.raid.maximumDifficulty = val
                    end,
                },
            },
        },
        advanced = {
            name = "Advanced",
            type = "group",
            order = 40,
            args = {
                header = {
                    name = "Advanced Settings",
                    type = "header",
                    order = 1,
                },
                desc = {
                    name = "Configure advanced filtering expressions.",
                    type = "description",
                    order = 2,
                },
                enabled = {
                    name = "Enable Advanced Mode",
                    desc = "Use custom filter expressions instead of the UI",
                    type = "toggle",
                    width = "full",
                    order = 3,
                    get = function() return Module.db.profile.advanced.enabled end,
                    set = function(info, val)
                        Module.db.profile.advanced.enabled = val
                    end,
                },
                expression = {
                    name = "Filter Expression",
                    desc = "Advanced filter expression (e.g., 'mythicplus >= 10 and members < 4')",
                    type = "input",
                    width = "full",
                    order = 4,
                    multiline = 3,
                    get = function() return Module.db.profile.advanced.expression end,
                    set = function(info, val)
                        Module.db.profile.advanced.expression = val
                    end,
                    disabled = function() return not Module.db.profile.advanced.enabled end,
                },
                spacer1 = {
                    name = "",
                    type = "description",
                    order = 5,
                },
                sortingHeader = {
                    name = "Sorting",
                    type = "header",
                    order = 6,
                },
                sortingEnabled = {
                    name = "Enable Custom Sorting",
                    desc = "Sort results with a custom expression",
                    type = "toggle",
                    width = "full",
                    order = 7,
                    get = function() return Module.db.profile.sorting.enabled end,
                    set = function(info, val)
                        Module.db.profile.sorting.enabled = val
                    end,
                },
                sortingExpression = {
                    name = "Sorting Expression",
                    desc = "Expression to sort by (e.g., 'mythicplus desc, age asc')",
                    type = "input",
                    width = "full",
                    order = 8,
                    get = function() return Module.db.profile.sorting.expression end,
                    set = function(info, val)
                        Module.db.profile.sorting.expression = val
                    end,
                    disabled = function() return not Module.db.profile.sorting.enabled end,
                },
            },
        },
    },
}

-- Register with VUI Config
VUI.Config:Register("VUIGfinder", VUI.Config.Layout["VUIGfinder"])