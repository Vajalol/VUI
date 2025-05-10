--[[
    Splits.lua
    Part of VUIKeystones
    Handles time splits and checkpoint tracking for Mythic+ dungeons
    Based on AngryKeystones by Ermad (https://github.com/Ermad/angry-keystones)
]]

local ADDON, Addon = ...
local Mod = Addon:NewModule('Splits')
local L = Addon.L

-- Blizzard APIs
local C_ChallengeMode = C_ChallengeMode
local C_Scenario = C_Scenario
local GetTime = GetTime

-- Module variables
local splitsFrame
local currentRun = {}
local timerStarted = false
local checkpointTimes = {}
local CHECKPOINT_CRITERIA_PATTERN = L["Defeat %s"]
local inChallenge = false

-- Initialize module
function Mod:OnInitialize()
    self:RegisterConfig()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("CHALLENGE_MODE_START")
    self:RegisterEvent("CHALLENGE_MODE_RESET")
    self:RegisterEvent("CHALLENGE_MODE_COMPLETED")
    self:RegisterEvent("SCENARIO_CRITERIA_UPDATE")
    
    self:CreateSplitsFrame()
end

function Mod:OnEnable()
    if splitsFrame then
        splitsFrame:RegisterEvent("SCENARIO_CRITERIA_UPDATE")
    end
    self:Debug("Splits module enabled")
end

function Mod:OnDisable()
    if splitsFrame then
        splitsFrame:UnregisterAllEvents()
    end
    self:Debug("Splits module disabled")
end

-- Register configuration options
function Mod:RegisterConfig()
    local defaults = {
        profile = {
            enabled = true,
            showSplits = true,
            splitsFormat = "RELATIVE", -- RELATIVE, ABSOLUTE
            splitsAnchor = "TOP",     -- TOP, BOTTOM
            splitsPosition = {
                point = "TOPRIGHT",
                relativePoint = "TOPRIGHT",
                xOffset = -280,
                yOffset = -200
            }
        }
    }
    
    Addon.Config:RegisterModuleDefaults("Splits", defaults)
    
    local options = {
        enabled = {
            type = "toggle",
            name = L["Enable Timer Splits"],
            desc = L["Show objective completion times during a Mythic+ run"],
            width = "full",
            order = 1,
            get = function() return Addon.db.profile.Splits.enabled end,
            set = function(_, value) 
                Addon.db.profile.Splits.enabled = value
                if value then
                    Mod:OnEnable()
                else
                    Mod:OnDisable()
                end
                self:UpdateSplitsFrame()
            end
        },
        showSplits = {
            type = "toggle",
            name = L["Show Splits"],
            desc = L["Show objective completion time splits"],
            width = "full",
            order = 2,
            get = function() return Addon.db.profile.Splits.showSplits end,
            set = function(_, value) 
                Addon.db.profile.Splits.showSplits = value
                self:UpdateSplitsFrame()
            end
        },
        splitsFormat = {
            type = "select",
            name = L["Splits Format"],
            desc = L["Choose how to display time splits"],
            width = "double",
            order = 3,
            values = {
                ["RELATIVE"] = L["Relative to Last Split"],
                ["ABSOLUTE"] = L["Absolute Time"]
            },
            get = function() return Addon.db.profile.Splits.splitsFormat end,
            set = function(_, value) 
                Addon.db.profile.Splits.splitsFormat = value
                self:UpdateSplitsFrame()
            end
        },
        splitsAnchor = {
            type = "select",
            name = L["Splits Anchor"],
            desc = L["Position of new splits"],
            width = "double",
            order = 4,
            values = {
                ["TOP"] = L["Top (Newest First)"],
                ["BOTTOM"] = L["Bottom (Newest Last)"]
            },
            get = function() return Addon.db.profile.Splits.splitsAnchor end,
            set = function(_, value) 
                Addon.db.profile.Splits.splitsAnchor = value
                self:UpdateSplitsFrame()
            end
        },
        resetPosition = {
            type = "execute",
            name = L["Reset Position"],
            desc = L["Reset the position of the splits frame"],
            order = 5,
            func = function() 
                Addon.db.profile.Splits.splitsPosition = defaults.profile.splitsPosition
                self:UpdateSplitsFramePosition()
            end
        }
    }
    
    Addon.Config:RegisterModuleOptions("Splits", options, L["Timer Splits"])
end

-- Event handlers
function Mod:PLAYER_ENTERING_WORLD()
    inChallenge = C_ChallengeMode.IsChallengeModeActive()
    if not inChallenge then
        currentRun = {}
        timerStarted = false
        self:HideSplitsFrame()
    end
end

function Mod:CHALLENGE_MODE_START()
    inChallenge = true
    currentRun = {
        startTime = GetTime(),
        checkpoints = {},
        mapID = C_ChallengeMode.GetActiveChallengeMapID()
    }
    timerStarted = true
    wipe(checkpointTimes)
    self:ShowSplitsFrame()
end

function Mod:CHALLENGE_MODE_RESET()
    inChallenge = false
    timerStarted = false
    currentRun = {}
    wipe(checkpointTimes)
    self:HideSplitsFrame()
end

function Mod:CHALLENGE_MODE_COMPLETED()
    inChallenge = false
    timerStarted = false
    
    -- Record final time
    if currentRun.startTime then
        currentRun.endTime = GetTime()
        currentRun.totalTime = currentRun.endTime - currentRun.startTime
        self:Debug("Challenge completed in", Addon:FormatTime(currentRun.totalTime))
    end
    
    -- Keep splits frame visible for a little while after completion
    C_Timer.After(10, function()
        if not inChallenge then
            self:HideSplitsFrame()
        end
    end)
end

function Mod:SCENARIO_CRITERIA_UPDATE()
    if not inChallenge or not timerStarted or not currentRun.startTime then return end
    
    local _, _, numCriteria = C_Scenario.GetInfo()
    if not numCriteria or numCriteria == 0 then return end
    
    for criteriaIndex = 1, numCriteria do
        local criteriaString, _, completed, _, _, _, _, _, criteriaType = C_Scenario.GetCriteriaInfo(criteriaIndex)
        
        -- Handle boss or checkpoint criteria
        if criteriaString and completed and not checkpointTimes[criteriaIndex] then
            local bossName = criteriaString:match(CHECKPOINT_CRITERIA_PATTERN)
            if bossName then
                local currentTime = GetTime() - currentRun.startTime
                checkpointTimes[criteriaIndex] = currentTime
                
                table.insert(currentRun.checkpoints, {
                    index = criteriaIndex,
                    name = bossName,
                    time = currentTime
                })
                
                self:Debug("Checkpoint reached:", bossName, "Time:", Addon:FormatTime(currentTime))
                self:UpdateSplitsFrame()
            end
        end
    end
end

-- Create the splits frame
function Mod:CreateSplitsFrame()
    if splitsFrame then return splitsFrame end
    
    splitsFrame = CreateFrame("Frame", "VUIKeystonesSplitsFrame", UIParent, "BackdropTemplate")
    splitsFrame:SetSize(250, 100)
    splitsFrame:SetPoint(
        Addon.db.profile.Splits.splitsPosition.point,
        UIParent,
        Addon.db.profile.Splits.splitsPosition.relativePoint,
        Addon.db.profile.Splits.splitsPosition.xOffset,
        Addon.db.profile.Splits.splitsPosition.yOffset
    )
    splitsFrame:SetFrameStrata("MEDIUM")
    splitsFrame:SetClampedToScreen(true)
    splitsFrame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
        tile = true, tileSize = 16, edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    splitsFrame:SetBackdropColor(0, 0, 0, 0.7)
    splitsFrame:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)
    
    -- Title text
    splitsFrame.title = splitsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    splitsFrame.title:SetPoint("TOPLEFT", splitsFrame, "TOPLEFT", 10, -8)
    splitsFrame.title:SetText(L["Objective Splits"])
    
    -- Make frame movable
    splitsFrame:SetMovable(true)
    splitsFrame:EnableMouse(true)
    splitsFrame:RegisterForDrag("LeftButton")
    splitsFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    splitsFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relativePoint, xOffset, yOffset = self:GetPoint()
        Addon.db.profile.Splits.splitsPosition.point = point
        Addon.db.profile.Splits.splitsPosition.relativePoint = relativePoint
        Addon.db.profile.Splits.splitsPosition.xOffset = xOffset
        Addon.db.profile.Splits.splitsPosition.yOffset = yOffset
    end)
    
    -- Splits container
    splitsFrame.container = CreateFrame("Frame", nil, splitsFrame)
    splitsFrame.container:SetPoint("TOPLEFT", splitsFrame, "TOPLEFT", 10, -25)
    splitsFrame.container:SetPoint("BOTTOMRIGHT", splitsFrame, "BOTTOMRIGHT", -10, 10)
    
    -- Initialize with no splits
    splitsFrame.splits = {}
    
    -- Hide by default
    splitsFrame:Hide()
    
    return splitsFrame
end

-- Update the splits frame
function Mod:UpdateSplitsFrame()
    if not splitsFrame then self:CreateSplitsFrame() end
    
    -- Clear existing splits
    for _, splitLine in ipairs(splitsFrame.splits) do
        splitLine:Hide()
    end
    
    -- Hide if not enabled or no splits to show
    if not Addon.db.profile.Splits.enabled or not Addon.db.profile.Splits.showSplits or 
       not currentRun.checkpoints or #currentRun.checkpoints == 0 then
        splitsFrame:Hide()
        return
    end
    
    -- Create or update split lines
    local lastTime = 0
    for i, checkpoint in ipairs(currentRun.checkpoints) do
        local splitLine = splitsFrame.splits[i]
        if not splitLine then
            splitLine = self:CreateSplitLine(i)
            splitsFrame.splits[i] = splitLine
        end
        
        -- Format time display based on settings
        local timeText
        if Addon.db.profile.Splits.splitsFormat == "ABSOLUTE" then
            timeText = Addon:FormatTime(checkpoint.time)
        else -- RELATIVE
            local relativeTime = checkpoint.time - lastTime
            timeText = "+" .. Addon:FormatTime(relativeTime)
        end
        lastTime = checkpoint.time
        
        -- Update split line
        splitLine.name:SetText(checkpoint.name)
        splitLine.time:SetText(timeText)
        splitLine:Show()
    end
    
    -- Adjust frame height based on number of splits
    local splitHeight = 20
    local headerHeight = 25
    local padding = 10
    local totalHeight = headerHeight + (#currentRun.checkpoints * splitHeight) + padding
    splitsFrame:SetHeight(totalHeight)
    
    -- Show frame
    splitsFrame:Show()
end

-- Create a single split line
function Mod:CreateSplitLine(index)
    local container = splitsFrame.container
    local splitLine = CreateFrame("Frame", nil, container)
    
    local anchor = Addon.db.profile.Splits.splitsAnchor
    local yOffset = (index - 1) * -20
    if anchor == "BOTTOM" then
        yOffset = (index - 1) * 20
        splitLine:SetPoint("BOTTOMLEFT", container, "BOTTOMLEFT", 0, yOffset)
    else -- TOP
        splitLine:SetPoint("TOPLEFT", container, "TOPLEFT", 0, yOffset)
    end
    
    splitLine:SetSize(230, 20)
    
    splitLine.name = splitLine:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    splitLine.name:SetPoint("LEFT", splitLine, "LEFT", 5, 0)
    splitLine.name:SetJustifyH("LEFT")
    splitLine.name:SetWidth(150)
    
    splitLine.time = splitLine:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    splitLine.time:SetPoint("RIGHT", splitLine, "RIGHT", -5, 0)
    splitLine.time:SetJustifyH("RIGHT")
    splitLine.time:SetWidth(70)
    
    return splitLine
end

-- Show/hide frame functions
function Mod:ShowSplitsFrame()
    if Addon.db.profile.Splits.enabled and splitsFrame then
        self:UpdateSplitsFramePosition()
        self:UpdateSplitsFrame()
    end
end

function Mod:HideSplitsFrame()
    if splitsFrame then
        splitsFrame:Hide()
    end
end

function Mod:UpdateSplitsFramePosition()
    if splitsFrame then
        splitsFrame:ClearAllPoints()
        splitsFrame:SetPoint(
            Addon.db.profile.Splits.splitsPosition.point,
            UIParent,
            Addon.db.profile.Splits.splitsPosition.relativePoint,
            Addon.db.profile.Splits.splitsPosition.xOffset,
            Addon.db.profile.Splits.splitsPosition.yOffset
        )
    end
end

-- Debug function
function Mod:Debug(...)
    if Addon.debug then
        Addon:Print("Splits:", ...)
    end
end