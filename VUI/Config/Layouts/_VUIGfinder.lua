local VUI = select(2, ...)
if not VUI.Config then return end

local Module = VUI:GetModule("VUIGfinder")
if not Module then return end

-- Create the options table - simplified for main VUI GUI integration
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
        defaults = {
            name = "Default Filters",
            type = "group",
            order = 30,
            args = {
                header = {
                    name = "Default Filter Settings",
                    type = "header",
                    order = 1,
                },
                desc = {
                    name = "Configure default behavior. Detailed filtering options available in the Group Finder interface.",
                    type = "description",
                    order = 2,
                },
                remembersLastFilters = {
                    name = "Remember Last Filters",
                    desc = "Remember the last used filters between sessions",
                    type = "toggle",
                    width = "full",
                    order = 3,
                    get = function() return Module.db.profile.rememberFilters end,
                    set = function(info, val)
                        Module.db.profile.rememberFilters = val
                    end,
                },
                resetButton = {
                    name = "Reset All Filters",
                    desc = "Reset all filters to default values",
                    type = "execute",
                    order = 4,
                    func = function()
                        Module:ResetAllFilters()
                        VUI:Print("VUI Gfinder: All filters have been reset to default values.")
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
                    name = "Configure advanced options. Full filtering expression support is available in the Group Finder interface.",
                    type = "description",
                    order = 2,
                },
                defaultExpressionMode = {
                    name = "Default to Expression Mode",
                    desc = "Start in advanced expression mode instead of UI mode",
                    type = "toggle",
                    width = "full",
                    order = 3,
                    get = function() return Module.db.profile.advanced.enabled end,
                    set = function(info, val)
                        Module.db.profile.advanced.enabled = val
                    end,
                },
                enableSorting = {
                    name = "Enable Result Sorting",
                    desc = "Enable sorting of search results (can be configured in filter dialog)",
                    type = "toggle",
                    width = "full",
                    order = 4,
                    get = function() return Module.db.profile.sorting.enabled end,
                    set = function(info, val)
                        Module.db.profile.sorting.enabled = val
                    end,
                },
                advFilteringHelp = {
                    name = "Advanced filtering expressions are available directly in the Group Finder dialog. Click the VUI Gfinder button in the LFG interface to access all filtering options.",
                    type = "description",
                    order = 5,
                    fontSize = "medium",
                },
            },
        },
    },
}

-- Register with VUI Config
VUI.Config:Register("VUIGfinder", VUI.Config.Layout["VUIGfinder"])