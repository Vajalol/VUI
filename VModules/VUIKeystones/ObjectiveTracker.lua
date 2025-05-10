--[[
    ObjectiveTracker.lua
    Part of VUIKeystones
    Handles modifications to the objective tracker for Mythic+ dungeons
    Based on AngryKeystones by Ermad (https://github.com/Ermad/angry-keystones)
]]

local ADDON, Addon = ...
local Mod = Addon:NewModule('ObjectiveTracker')
local L = Addon.L

-- Blizzard APIs
local C_Scenario = C_Scenario
local C_ChallengeMode = C_ChallengeMode
local SCENARIO_CONTENT_TRACKER_MODULE = SCENARIO_CONTENT_TRACKER_MODULE
local ObjectiveTrackerFrame = ObjectiveTrackerFrame

-- Local variables
local timerFrame, timeElapsed
local objectiveBlocks = {}
local wasInChallengeMode = false

-- Settings
local objectiveTheme = {
    ["timerHeight"] = 18,
    ["headerHeight"] = 25,
    ["lineHeight"] = 22,
    ["barHeight"] = 10,
    ["completeColor"] = {r = 0.18, g = 0.8, b = 0.2, a = 1},
    ["incompleteColor"] = {r = 0.6, g = 0.6, b = 0.6, a = 1},
    ["backgroundColor"] = {r = 0.1, g = 0.1, b = 0.1, a = 0.8}
}

-- Initialize module
function Mod:OnInitialize()
    self:RegisterConfig()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("CHALLENGE_MODE_START")
    self:RegisterEvent("CHALLENGE_MODE_COMPLETED")
    self:RegisterEvent("CHALLENGE_MODE_RESET")
    
    self:RegisterEvent("SCENARIO_POI_UPDATE")
    self:RegisterEvent("SCENARIO_CRITERIA_UPDATE")
    
    self:HookObjectiveTracker()
end

function Mod:OnEnable()
    self:Debug("ObjectiveTracker module enabled")
end

function Mod:OnDisable()
    self:Debug("ObjectiveTracker module disabled")
end

-- Register configuration options
function Mod:RegisterConfig()
    local defaults = {
        profile = {
            enabled = true,
            showPercentage = true,
            showCriteria = true,
            showWhen = "CHALLENGE_MODE"
        }
    }
    
    Addon.Config:RegisterModuleDefaults("ObjectiveTracker", defaults)
    
    local options = {
        enabled = {
            type = "toggle",
            name = L["Enhanced Objective Tracker"],
            desc = L["Enhance the objective tracker with additional information for Mythic+ dungeons"],
            width = "full",
            order = 1,
            get = function() return Addon.db.profile.ObjectiveTracker.enabled end,
            set = function(_, value) 
                Addon.db.profile.ObjectiveTracker.enabled = value
                if value then
                    Mod:OnEnable()
                else
                    Mod:OnDisable()
                end
            end
        },
        showPercentage = {
            type = "toggle",
            name = L["Show Enemy Forces Percentage"],
            desc = L["Show percentage of enemy forces defeated in objective tracker"],
            width = "full",
            order = 2,
            get = function() return Addon.db.profile.ObjectiveTracker.showPercentage end,
            set = function(_, value) 
                Addon.db.profile.ObjectiveTracker.showPercentage = value
                Mod:UpdateObjectiveTracker()
            end
        },
        showCriteria = {
            type = "toggle",
            name = L["Show Completion Criteria"],
            desc = L["Show additional objective completion criteria"],
            width = "full",
            order = 3,
            get = function() return Addon.db.profile.ObjectiveTracker.showCriteria end,
            set = function(_, value) 
                Addon.db.profile.ObjectiveTracker.showCriteria = value
                Mod:UpdateObjectiveTracker()
            end
        },
        showWhen = {
            type = "select",
            name = L["Show Enhanced Tracker"],
            desc = L["When to show the enhanced objective tracker"],
            width = "double",
            order = 4,
            values = {
                ["ALWAYS"] = L["Always"],
                ["CHALLENGE_MODE"] = L["In Mythic+ Only"],
                ["NEVER"] = L["Never"]
            },
            get = function() return Addon.db.profile.ObjectiveTracker.showWhen end,
            set = function(_, value) 
                Addon.db.profile.ObjectiveTracker.showWhen = value
                Mod:UpdateObjectiveTracker()
            end
        }
    }
    
    Addon.Config:RegisterModuleOptions("ObjectiveTracker", options, L["Objective Tracker"])
end

-- Event handling
function Mod:PLAYER_ENTERING_WORLD()
    self:CheckForChallengeMode()
end

function Mod:CHALLENGE_MODE_START()
    wasInChallengeMode = true
    self:UpdateObjectiveTracker()
end

function Mod:CHALLENGE_MODE_COMPLETED()
    wasInChallengeMode = false
    self:UpdateObjectiveTracker()
end

function Mod:CHALLENGE_MODE_RESET()
    wasInChallengeMode = false
    self:UpdateObjectiveTracker()
end

function Mod:SCENARIO_POI_UPDATE()
    self:UpdateObjectiveTracker()
end

function Mod:SCENARIO_CRITERIA_UPDATE()
    self:UpdateObjectiveTracker()
end

-- Check if we're in a challenge mode
function Mod:CheckForChallengeMode()
    local inChallengeMode = C_ChallengeMode.IsChallengeModeActive()
    if inChallengeMode ~= wasInChallengeMode then
        wasInChallengeMode = inChallengeMode
        self:UpdateObjectiveTracker()
    end
end

-- Hook into the objective tracker
function Mod:HookObjectiveTracker()
    hooksecurefunc(SCENARIO_CONTENT_TRACKER_MODULE, "Update", function()
        self:UpdateObjectiveTracker()
    end)
    
    hooksecurefunc("ScenarioTrackerProgressBar_SetValue", function(progressBar, percent)
        if not Addon.db.profile.ObjectiveTracker.enabled then return end
        if not wasInChallengeMode then return end
        
        if progressBar.criteriaIndex then
            local block = progressBar:GetParent():GetParent()
            if block.module == SCENARIO_CONTENT_TRACKER_MODULE then
                self:UpdateProgressBar(progressBar, percent)
            end
        end
    end)
end

-- Update the objective tracker display
function Mod:UpdateObjectiveTracker()
    if not Addon.db.profile.ObjectiveTracker.enabled then return end
    
    local showWhen = Addon.db.profile.ObjectiveTracker.showWhen
    if showWhen == "NEVER" then return end
    if showWhen == "CHALLENGE_MODE" and not wasInChallengeMode then return end
    
    local scenarioName, _, numObjectives = C_Scenario.GetInfo()
    if not scenarioName or numObjectives == 0 then return end
    
    for i = 1, numObjectives do
        local name, _, completed, _, _, _, _, _, criteriaCount = C_Scenario.GetCriteriaInfo(i)
        if name and criteriaCount > 0 then
            local block = SCENARIO_CONTENT_TRACKER_MODULE:GetBlock(i)
            if block then
                self:UpdateBlock(block, i, completed, criteriaCount)
            end
        end
    end
end

-- Update a specific objective block
function Mod:UpdateBlock(block, objectiveIndex, completed, criteriaCount)
    if not block.lines then return end
    
    -- Store block for later reference
    objectiveBlocks[objectiveIndex] = block
    
    -- Update criteria lines if enabled
    if Addon.db.profile.ObjectiveTracker.showCriteria then
        for lineIndex = 1, criteriaCount do
            local line = block.lines[lineIndex]
            if line then
                local criteriaName, _, criteriaCompleted, quantity, totalQuantity = C_Scenario.GetCriteriaInfoByStep(objectiveIndex, lineIndex)
                if criteriaName then
                    -- Add percentage to enemy forces
                    if totalQuantity > 0 and Addon.db.profile.ObjectiveTracker.showPercentage and criteriaName:find(L["Enemy Forces"]) then
                        local percent = math.floor((quantity / totalQuantity) * 100)
                        line.Text:SetText(criteriaName.." - "..percent.."%")
                    end
                    
                    -- Customize completion status
                    if criteriaCompleted then
                        line.Check:Show()
                        line.Text:SetTextColor(0.6, 0.8, 0.6)
                    else
                        line.Check:Hide()
                        line.Text:SetTextColor(0.8, 0.8, 0.8)
                    end
                end
            end
        end
    end
    
    -- Update visuals after block was modified
    block:SetHeight(block.height)
end

-- Update a progress bar
function Mod:UpdateProgressBar(progressBar, percent)
    if not progressBar or not percent then return end
    
    -- Apply custom styling to progress bars
    progressBar:SetStatusBarColor(0.28, 0.71, 0.31)
    
    -- Add percentage text to the bar if it doesn't already exist
    if not progressBar.percentageText and Addon.db.profile.ObjectiveTracker.showPercentage then
        progressBar.percentageText = progressBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        progressBar.percentageText:SetPoint("CENTER", progressBar, "CENTER", 0, 0)
    end
    
    if progressBar.percentageText then
        progressBar.percentageText:SetText(math.floor(percent * 100).."%")
    end
end

-- Debug function
function Mod:Debug(...)
    if Addon.debug then
        Addon:Print("ObjectiveTracker:", ...)
    end
end