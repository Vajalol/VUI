-------------------------------------------------------------------------------
-- Title: PGFinder Module
-- Author: VortexQ8
-- Premade Group Finder module with enhanced features and theme integration
-------------------------------------------------------------------------------

local addonName, VUI = ...
local LSM = LibStub("LibSharedMedia-3.0")
local AceHook = LibStub("AceHook-3.0")

-- Create the module
local module = VUI:NewModule("pgfinder", "AceEvent-3.0", "AceHook-3.0")
VUI.modules.pgfinder = module

-- Default settings
local defaults = {
    profile = {
        enabled = true,
        
        -- Theme settings
        useVUITheme = true,
        customFrame = {
            background = "Interface\\Addons\\VUI\\media\\textures\\thunderstorm\\dark",
            border = "Interface\\Addons\\VUI\\media\\textures\\thunderstorm\\border",
            borderSize = 1,
            borderColor = {r = 0.129, g = 0.611, b = 0.901, a = 1.0},
            backgroundColor = {r = 0.05, g = 0.05, b = 0.1, a = 0.95},
        },
        customElements = {
            buttonStyle = true,
            customFont = true,
            customBarTexture = true,
            roundedCorners = true,
        },
        
        -- Advanced filtering
        advancedFiltering = {
            enabled = true,
            minLeaderScore = 0,
            minAvgScore = 0,
            requireMyRole = false,
            showFullGroups = true,
            hideIncompatibleDungeons = true,
            preferredDungeons = {},
            avoidedDungeons = {},
            maxGroupAge = 0,
            voiceOnly = false,
            guildGroupsOnly = false,
            hideBoostGroups = true,
            hideInProgressGroups = false,
            onlyShowFriendsGroups = false,
        },
        
        -- Group rating visualization
        ratingVisualization = {
            enabled = true,
            colorByScore = true,
            showScoreTooltips = true,
            showLeaderScore = true,
            showPredictedSuccess = true,
            thresholds = {
                low = 500,
                medium = 1000,
                high = 1500,
                exceptional = 2000
            },
            colors = {
                low = {r = 0.7, g = 0.3, b = 0.3},
                medium = {r = 0.9, g = 0.7, b = 0.0},
                high = {r = 0.0, g = 0.7, b = 0.0},
                exceptional = {r = 0.0, g = 0.8, b = 1.0}
            }
        },
        
        -- Role requirement display
        roleRequirements = {
            enabled = true,
            showMissingRoles = true,
            emphasisMyRole = true,
            iconsStyle = "theme", -- "theme" or "default"
            iconSize = 16,
            colorIndicators = true
        }
    }
}

-- Initialize module
function module:OnInitialize()
    -- Register the module's database
    self.db = VUI.db:RegisterNamespace("pgfinder", defaults)
    
    -- Create the config table
    self.Config = {}
end

-- Enable module
function module:OnEnable()
    if not self.db.profile.enabled then return end
    
    -- Load theme integration
    self:LoadThemeIntegration()
    
    -- Load submodules
    self:LoadSubModules()
    
    -- Register for events
    self:RegisterEvents()
    
    -- Hook into Premade Group Finder functions
    self:HookLFGFunctions()
    
    -- Register for theme changes
    VUI:RegisterCallback("ThemeChanged", function()
        if self.ThemeIntegration then
            self.ThemeIntegration:ApplyTheme()
        end
    end)
end

-- Register events
function module:RegisterEvents()
    -- Register for PGF-related events
    self:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED")
    self:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED")
    self:RegisterEvent("LFG_LIST_AVAILABILITY_UPDATE")
    
    -- Register for role changes
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    self:RegisterEvent("GROUP_ROSTER_UPDATE")
end

-- Load theme integration
function module:LoadThemeIntegration()
    -- Load the theme integration module
    if not self.ThemeIntegration then
        self:LoadModuleFile("ThemeIntegration")
        if self.ThemeIntegration and self.ThemeIntegration.Initialize then
            self.ThemeIntegration:Initialize()
        end
    end
end

-- Load submodules
function module:LoadSubModules()
    -- Advanced filtering
    if self.db.profile.advancedFiltering.enabled then
        self:LoadModuleFile("AdvancedFiltering")
        if self.AdvancedFiltering and self.AdvancedFiltering.Initialize then
            self.AdvancedFiltering:Initialize()
        end
    end
    
    -- Rating visualization
    if self.db.profile.ratingVisualization.enabled then
        self:LoadModuleFile("RatingVisualization")
        if self.RatingVisualization and self.RatingVisualization.Initialize then
            self.RatingVisualization:Initialize()
        end
    end
    
    -- Role requirement display
    if self.db.profile.roleRequirements.enabled then
        self:LoadModuleFile("RoleDisplay")
        if self.RoleDisplay and self.RoleDisplay.Initialize then
            self.RoleDisplay:Initialize()
        end
    end
end

-- Helper function to load module files
function module:LoadModuleFile(fileName)
    -- This would typically do something like:
    -- local func = VUI:GetModuleFunction("pgfinder", fileName)
    -- if func then func(self) end
    -- But we're simulating it by assuming the file has been loaded
end

-- Hook into LFG list functions
function module:HookLFGFunctions()
    -- Hook into search result display
    self:SecureHook("LFGListSearchPanel_UpdateResults", function(panel)
        self:UpdateSearchResults(panel)
    end)
    
    -- Hook into search entry creation
    self:SecureHook("LFGListSearchEntry_Update", function(button)
        self:UpdateSearchEntry(button)
    end)
    
    -- Hook into application listing
    self:SecureHook("LFGListApplicationViewer_UpdateApplicantMember", function(member, applicantInfo, memberIdx)
        self:UpdateApplicantMember(member, applicantInfo, memberIdx)
    end)
    
    -- Hook into tooltip functions
    self:SecureHook("LFGListUtil_SetSearchEntryTooltip", function(tooltip, resultID)
        self:SetSearchEntryTooltip(tooltip, resultID)
    end)
end

-- Handle the search results received event
function module:LFG_LIST_SEARCH_RESULTS_RECEIVED(event)
    -- If AdvancedFiltering is enabled, handle the event there
    if self.AdvancedFiltering and self.AdvancedFiltering.isEnabled then
        -- Refresh search results display
        if PVEFrame and PVEFrame:IsShown() and LFGListFrame.SearchPanel then
            LFGListSearchPanel_UpdateResults(LFGListFrame.SearchPanel)
        end
    end
end

-- Handle search result updates
function module:LFG_LIST_SEARCH_RESULT_UPDATED(event, resultID)
    -- If RatingVisualization is enabled, update the visualization
    if self.RatingVisualization and self.RatingVisualization.isEnabled then
        -- Find and update the corresponding search entry
        if LFGListFrame.SearchPanel and LFGListFrame.SearchPanel.ScrollFrame then
            local buttons = LFGListFrame.SearchPanel.ScrollFrame.buttons
            if buttons then
                for i = 1, #buttons do
                    if buttons[i].resultID == resultID then
                        LFGListSearchEntry_Update(buttons[i])
                        break
                    end
                end
            end
        end
    end
end

-- Handle availability updates
function module:LFG_LIST_AVAILABILITY_UPDATE(event)
    -- If RoleDisplay is enabled, update role icons
    if self.RoleDisplay and self.RoleDisplay.isEnabled then
        -- Update role display
        if PVEFrame and PVEFrame:IsShown() and LFGListFrame.SearchPanel then
            LFGListSearchPanel_UpdateResults(LFGListFrame.SearchPanel)
        end
    end
end

-- Handle player specialization changes
function module:PLAYER_SPECIALIZATION_CHANGED(event, unit)
    if unit == "player" and self.AdvancedFiltering and self.AdvancedFiltering.isEnabled then
        -- Refresh search results with new role filter
        if PVEFrame and PVEFrame:IsShown() and LFGListFrame.SearchPanel then
            LFGListSearchPanel_UpdateResults(LFGListFrame.SearchPanel)
        end
    end
end

-- Update search results panel
function module:UpdateSearchResults(panel)
    -- Apply theme to the search panel
    if self.ThemeIntegration and self.ThemeIntegration.ApplySearchPanelTheme then
        self.ThemeIntegration:ApplySearchPanelTheme(panel)
    end
    
    -- If we have advanced filtering, update filter UI
    if self.AdvancedFiltering and self.AdvancedFiltering.UpdateFilterUI then
        self.AdvancedFiltering:UpdateFilterUI(panel)
    end
end

-- Update a search entry
function module:UpdateSearchEntry(button)
    -- Apply theme to the search entry
    if self.ThemeIntegration and self.ThemeIntegration.ApplySearchEntryTheme then
        self.ThemeIntegration:ApplySearchEntryTheme(button)
    end
    
    -- If we have rating visualization, apply it
    if self.RatingVisualization and self.RatingVisualization.ApplyRatingVisualization then
        self.RatingVisualization:ApplyRatingVisualization(button)
    end
    
    -- If we have role display enhancement, apply it
    if self.RoleDisplay and self.RoleDisplay.ApplyRoleDisplay then
        self.RoleDisplay:ApplyRoleDisplay(button)
    end
end

-- Update an applicant member display
function module:UpdateApplicantMember(member, applicantInfo, memberIdx)
    -- Apply theme to the applicant member
    if self.ThemeIntegration and self.ThemeIntegration.ApplyApplicantTheme then
        self.ThemeIntegration:ApplyApplicantTheme(member)
    end
    
    -- If we have rating visualization, apply it to applicants
    if self.RatingVisualization and self.RatingVisualization.ApplyApplicantRating then
        self.RatingVisualization:ApplyApplicantRating(member, applicantInfo, memberIdx)
    end
end

-- Modify the search entry tooltip
function module:SetSearchEntryTooltip(tooltip, resultID)
    -- If we have rating visualization, add score info to tooltip
    if self.RatingVisualization and self.RatingVisualization.AddScoreToTooltip then
        self.RatingVisualization:AddScoreToTooltip(tooltip, resultID)
    end
    
    -- If we have role display, add role info to tooltip
    if self.RoleDisplay and self.RoleDisplay.AddRolesToTooltip then
        self.RoleDisplay:AddRolesToTooltip(tooltip, resultID)
    end
end

-- Disable module
function module:OnDisable()
    -- Unregister all events
    self:UnregisterAllEvents()
    
    -- Unhook all hooks
    self:UnhookAll()
    
    -- Disable submodules
    if self.AdvancedFiltering and self.AdvancedFiltering.Disable then
        self.AdvancedFiltering:Disable()
    end
    
    if self.RatingVisualization and self.RatingVisualization.Disable then
        self.RatingVisualization:Disable()
    end
    
    if self.RoleDisplay and self.RoleDisplay.Disable then
        self.RoleDisplay:Disable()
    end
end