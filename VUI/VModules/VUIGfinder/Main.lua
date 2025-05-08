-------------------------------------------------------------------------------
-- VUI Gfinder (based on Premade Groups Filter)
-- Module for VUI - Vortex UI Addon Suite
-------------------------------------------------------------------------------

local VUI = _G.VUI
local Module = VUI:GetModule("VUIGfinder")
if not Module then return end

local VUIGfinder = _G.VUIGfinder
local L = VUIGfinder.L
local C = VUIGfinder.C

-- Helper functions
function VUIGfinder.ResetSearchEntries()
    -- Make sure to wait at least some time between two resets
    if time() - VUIGfinder.lastSearchEntryReset > C.SEARCH_ENTRY_RESET_WAIT then
        VUIGfinder.previousSearchGroupKeys = VUIGfinder.Table_Copy_Shallow(VUIGfinder.currentSearchGroupKeys)
        VUIGfinder.currentSearchGroupKeys = {}
        VUIGfinder.previousSearchExpression = VUIGfinder.currentSearchExpression
        VUIGfinder.lastSearchEntryReset = time()
        VUIGfinder.searchResultIDInfo = {}
        VUIGfinder.numResultsBeforeFilter = 0
        VUIGfinder.numResultsAfterFilter = 0
    end
end

function VUIGfinder.GetUserSortingTable()
    local sorting = VUIGfinder.Dialog:GetSortingExpression()
    if VUIGfinder.Empty(sorting) then return {} end
    local sortingError = VUIGfinder.Expression:Validate(sorting, false)
    if sortingError then return {} end
    return VUIGfinder.Expression:ToTable(sorting, false, true)
end

-- Define user filtering function
function VUIGfinder.DoFilterSearchResults(searchResultInfo)
    -- Reset the search results
    VUIGfinder.ResetSearchEntries()
    
    -- If the feature isn't enabled, just return the original results
    if not Module.db.profile.enabled then
        C_LFGList.RequestAvailableActivities()
        return searchResultInfo
    end
    
    -- Get the user's expression from the dialog
    local expression = ""
    
    -- Check which filter type is active and get the expression
    if Module.db.profile.advanced.enabled then
        expression = Module.db.profile.advanced.expression
    else
        -- Build expression from UI panels based on which tab is active
        local activePanel = VUIGfinder.Dialog:GetActivePanel()
        if activePanel then
            expression = activePanel:GetExpression()
        end
    end
    
    -- Validate the expression
    VUIGfinder.currentSearchExpression = expression
    local expressionError = VUIGfinder.Empty(expression) and "empty" or VUIGfinder.Expression:Validate(expression)
    
    -- Store search result count before filtering
    VUIGfinder.numResultsBeforeFilter = #searchResultInfo
    
    -- If the expression has an error, just use the original results
    if expressionError then
        C_LFGList.RequestAvailableActivities()
        return searchResultInfo
    end
    
    -- Convert expression to a table of criteria
    local exprTable = VUIGfinder.Expression:ToTable(expression)
    if not exprTable then
        C_LFGList.RequestAvailableActivities()
        return searchResultInfo
    end
    
    -- Get sorting criteria if enabled
    local sortingActive = Module.db.profile.sorting.enabled and not VUIGfinder.Empty(Module.db.profile.sorting.expression) 
    local sortingTable = sortingActive and VUIGfinder.GetUserSortingTable() or {}
    local sortingExp = sortingActive and Module.db.profile.sorting.expression or ""
    
    -- Filter groups based on criteria
    local filteredGroups = {}
    local groupInfo = {}
    
    for i = 1, #searchResultInfo do
        -- Get all the info we need about this group
        local searchResultID = searchResultInfo[i]
        local activityInfo = C_LFGList.GetSearchResultInfo(searchResultID)
        if activityInfo and not activityInfo.isDelisted then
            VUIGfinder.currentSearchGroupKeys[searchResultID] = true
            VUIGfinder.searchResultIDInfo[searchResultID] = activityInfo
            
            -- Prepare group data for filtering
            groupInfo.searchResultID = searchResultID
            groupInfo.activityID = activityInfo.activityID
            groupInfo.name = activityInfo.name
            groupInfo.comment = activityInfo.comment
            groupInfo.voiceChat = activityInfo.voiceChat
            groupInfo.leaderName = activityInfo.leaderName
            groupInfo.numMembers = activityInfo.numMembers
            groupInfo.autoAccept = activityInfo.autoAccept
            groupInfo.age = time() - activityInfo.creationTime
            -- Add more group info fields for advanced filtering
            
            -- Evaluate expression for this group
            if VUIGfinder.Expression:Evaluate(exprTable, groupInfo) then
                table.insert(filteredGroups, searchResultID)
            end
        end
    end
    
    -- Sort if needed
    if next(sortingTable) then
        table.sort(filteredGroups, function(a, b)
            return VUIGfinder.Expression:EvaluateSorting(sortingTable, sortingExp, a, b)
        end)
    end
    
    -- Store results count after filtering
    VUIGfinder.numResultsAfterFilter = #filteredGroups
    VUIGfinder.currentSearchResults = filteredGroups
    
    -- Request data for available activities to ensure tooltips work
    C_LFGList.RequestAvailableActivities()
    
    return filteredGroups
end

-- Hook into the search results function
function Module:HookSearchResults()
    if not Module:IsHooked("LFGListUtil_SortSearchResults") then
        Module:RawHook("LFGListUtil_SortSearchResults", function(results)
            return VUIGfinder.DoFilterSearchResults(results)
        end, true)
    end
end

-- Enhance tooltips with additional information
function VUIGfinder.OnLFGListSearchEntryOnEnter(self)
    if not Module.db.profile.ui.tooltipEnhancement then return end
    
    local resultID = self.resultID
    local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
    if not searchResultInfo then return end
    
    -- Add custom tooltip info
    if GameTooltip:IsShown() then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(L["Group Details"], 1, 1, 1)
        
        -- Add activity name
        local activityInfo = C_LFGList.GetActivityInfoTable(searchResultInfo.activityID)
        if activityInfo then
            GameTooltip:AddLine(L["Activity"] .. ": " .. activityInfo.fullName, 1, 0.85, 0)
        end
        
        -- Add difficulty
        if activityInfo and activityInfo.difficultyID and C.DIFFICULTY_MAP[activityInfo.difficultyID] then
            local difficultyName = VUIGfinder.GetDifficultyNameByID(activityInfo.difficultyID)
            if difficultyName then
                GameTooltip:AddLine(L["Difficulty"] .. ": " .. difficultyName, 1, 0.85, 0)
            end
        end
        
        -- Add mythic plus level if applicable
        if searchResultInfo.activityID and VUIGfinder.IsMythicPlusActivity(searchResultInfo.activityID) then
            local leaderScore, _, _, _ = VUIGfinder.GetRatingInfoForSearchResult(resultID) 
            if leaderScore then
                GameTooltip:AddLine(L["Leader Score"] .. ": " .. leaderScore, 1, 0.85, 0)
            end
        end
        
        -- Add group composition information
        local membersText = L["Members"] .. ": " .. searchResultInfo.numMembers
        GameTooltip:AddLine(membersText, 1, 0.85, 0)
        
        -- Add creation time
        local age = time() - searchResultInfo.creationTime
        local formattedTime = VUIGfinder.FormatTime(age)
        GameTooltip:AddLine(L["Created"] .. ": " .. formattedTime .. " " .. L["ago"], 1, 0.85, 0)
        
        GameTooltip:Show()
    end
end

-- Initialize the full module
function Module:InitializeUI()
    -- Initialize all the module components
    VUIGfinder.Expression:Initialize()
    VUIGfinder.Dialog:Initialize()
    
    -- Hook into tooltips
    if LFGListSearchEntry_OnEnter and not Module:IsHooked("LFGListSearchEntry_OnEnter") then
        Module:RawHook("LFGListSearchEntry_OnEnter", VUIGfinder.OnLFGListSearchEntryOnEnter, true)
    end
    
    -- Hook into search results
    self:HookSearchResults()
    
    -- Additional UI initialization code
    if Module.db.profile.ui.oneClickSignUp then
        VUIGfinder.OneClickSignUp:Initialize()
    end
    
    if Module.db.profile.ui.persistSignUpNote then
        VUIGfinder.PersistSignUpNote:Initialize()
    end
    
    if Module.db.profile.ui.signUpOnEnter then
        VUIGfinder.SignUpOnEnter:Initialize()
    end
    
    -- Update the "Use VUIGfinder" button
    if Module.db.profile.ui.usePGFButton then
        VUIGfinder.UsePGFButton:Create()
    end
    
    -- Add slash command
    SLASH_VUIGFINDER1 = "/vuigfinder"
    SLASH_VUIGFINDER2 = "/vgf"
    SlashCmdList["VUIGFINDER"] = function(msg)
        VUIGfinder.Dialog:Toggle()
    end
end

-- Register with VUI Config
VUI.Config:Register("VUIGfinder", {
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
                        if VUIGfinder.Dialog then
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
                        if VUIGfinder.Dialog and VUIGfinder.Dialog.frame then
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
                        if val and VUIGfinder.OneClickSignUp then
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
                        if val and VUIGfinder.PersistSignUpNote then
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
                        if val and VUIGfinder.SignUpOnEnter then
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
                        if val and VUIGfinder.UsePGFButton then
                            VUIGfinder.UsePGFButton:Create()
                        elseif VUIGfinder.UsePGFButton then
                            VUIGfinder.UsePGFButton:Remove()
                        end
                    end,
                },
            },
        },
        advanced = {
            name = "Advanced",
            type = "group",
            order = 30,
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
})

-- Initialize module when player enters world
function Module:PLAYER_ENTERING_WORLD()
    Module:InitializeUI()
end