-------------------------------------------------------------------------------
-- Title: AngryKeystones Progress Tracker
-- Author: VortexQ8
-- Enhanced progress tracking for Mythic+ dungeons
-------------------------------------------------------------------------------

local _, VUI = ...
local AK = VUI.modules.angrykeystones

-- Skip if AngryKeystones module is not available
if not AK then return end

-- Create the progress tracker namespace
AK.ProgressTracker = {}
local ProgressTracker = AK.ProgressTracker

-- Default settings
local defaults = {
    showTooltips = true,
    showDeathPenalty = true,
    showTotalCount = true,
    showPullValue = true,
    highlightCurrentPull = true,
    calculationMethod = "precise", -- "precise" or "approximate"
}

-- Initialize progress tracker
function ProgressTracker:Initialize()
    self.mobPoints = {}
    self.totalRequired = 100
    self.currentProgress = 0
    self.currentPull = {}
    self.deaths = 0
    self.deathPenalty = 0
    self.isEnabled = true
    
    -- Register events
    self:RegisterEvents()
end

-- Register necessary events
function ProgressTracker:RegisterEvents()
    -- Hook into AngryKeystones progress updates
    if AK.ProgressModule and AK.ProgressModule.UpdateProgress then
        AK:SecureHook(AK.ProgressModule, "UpdateProgress", function(_, current, total)
            if self.isEnabled then
                self:OnProgressUpdate(current, total)
            end
        end)
    end
    
    -- Register for combat log events to track mob deaths
    AK:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", function()
        if self.isEnabled then
            self:ProcessCombatLogEvent(CombatLogGetCurrentEventInfo())
        end
    end)
    
    -- Register for deaths to calculate penalty
    AK:RegisterEvent("PLAYER_DEAD", function()
        if self.isEnabled then
            self:OnPlayerDeath()
        end
    end)
    
    -- Register for target changes to track current pull
    AK:RegisterEvent("PLAYER_TARGET_CHANGED", function()
        if self.isEnabled then
            self:OnTargetChanged()
        end
    end)
    
    -- Register for nameplate tracking
    AK:RegisterEvent("NAME_PLATE_UNIT_ADDED", function(_, unit)
        if self.isEnabled then
            self:OnNamePlateAdded(unit)
        end
    end)
    
    -- Track mob tooltips for progress information
    if defaults.showTooltips then
        GameTooltip:HookScript("OnTooltipSetUnit", function()
            if self.isEnabled then
                self:OnTooltipSetUnit()
            end
        end)
    end
    
    -- Register for challenge mode start
    AK:RegisterEvent("CHALLENGE_MODE_START", function()
        if self.isEnabled then
            self:Reset()
        end
    end)
    
    -- Register for challenge mode reset
    AK:RegisterEvent("CHALLENGE_MODE_RESET", function()
        if self.isEnabled then
            self:Reset()
        end
    end)
end

-- Handle progress updates
function ProgressTracker:OnProgressUpdate(current, total)
    self.currentProgress = current or 0
    self.totalRequired = total or 100
    
    -- Update progress display with our enhanced precision
    if AK.progressFrames then
        for _, frame in ipairs(AK.progressFrames) do
            self:UpdateProgressDisplay(frame)
        end
    end
end

-- Process combat log events to track mob deaths
function ProgressTracker:ProcessCombatLogEvent(...)
    local timestamp, event, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
    
    -- Track mob deaths
    if event == "UNIT_DIED" and destGUID and bit.band(destFlags, COMBATLOG_OBJECT_TYPE_NPC) > 0 then
        -- Check if mob was in current pull
        for i, mobInfo in ipairs(self.currentPull) do
            if mobInfo.guid == destGUID then
                -- Remove from current pull
                table.remove(self.currentPull, i)
                break
            end
        end
    end
    
    -- Track damage to add mobs to current pull
    if (event == "SWING_DAMAGE" or event:match("SPELL_DAMAGE") or event:match("RANGE_DAMAGE")) and 
       destGUID and bit.band(destFlags, COMBATLOG_OBJECT_TYPE_NPC) > 0 and 
       (sourceGUID == UnitGUID("player") or bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_PARTY) > 0) then
        
        -- Check if mob is already in current pull
        local found = false
        for _, mobInfo in ipairs(self.currentPull) do
            if mobInfo.guid == destGUID then
                found = true
                break
            end
        end
        
        -- Add to current pull if not already there
        if not found then
            local mobName = destName or "Unknown"
            local mobPoints = self:GetMobPoints(destGUID, mobName)
            
            table.insert(self.currentPull, {
                guid = destGUID,
                name = mobName,
                points = mobPoints,
            })
        end
    end
end

-- Get mob progress points (approximate based on known values)
function ProgressTracker:GetMobPoints(guid, name)
    -- Check if we already know this mob's points
    if self.mobPoints[guid] then
        return self.mobPoints[guid]
    end
    
    -- Get approximate value based on mob classification
    local unit = self:FindUnitByGUID(guid)
    if unit then
        local classification = UnitClassification(unit)
        local health = UnitHealthMax(unit)
        local level = UnitLevel(unit)
        
        -- Estimate points based on classification
        local points = 0
        if classification == "worldboss" then
            points = 20 -- Major boss
        elseif classification == "rareelite" then
            points = 8 -- Rare elite
        elseif classification == "elite" then
            points = 4 -- Regular elite
        elseif classification == "rare" then
            points = 3 -- Rare mob
        else
            -- Regular mob, base on health and level
            points = math.max(1, math.floor(health / 10000)) -- Approximate based on health
        end
        
        -- Store for future reference
        self.mobPoints[guid] = points
        
        return points
    end
    
    -- Default value if we couldn't determine
    return 1
end

-- Find a unit by GUID
function ProgressTracker:FindUnitByGUID(guid)
    -- Check player target
    if UnitGUID("target") == guid then
        return "target"
    end
    
    -- Check focus
    if UnitGUID("focus") == guid then
        return "focus"
    end
    
    -- Check party members' targets
    for i = 1, 5 do
        local unit = "party" .. i .. "target"
        if UnitExists(unit) and UnitGUID(unit) == guid then
            return unit
        end
    end
    
    -- Check nameplates
    for i = 1, 40 do
        local unit = "nameplate" .. i
        if UnitExists(unit) and UnitGUID(unit) == guid then
            return unit
        end
    end
    
    return nil
end

-- Handle player death
function ProgressTracker:OnPlayerDeath()
    self.deaths = self.deaths + 1
    
    -- Calculate death penalty (typically 5 seconds per death)
    self.deathPenalty = self.deaths * 5
    
    -- Update progress displays
    if AK.progressFrames then
        for _, frame in ipairs(AK.progressFrames) do
            self:UpdateProgressDisplay(frame)
        end
    end
end

-- Handle target changes
function ProgressTracker:OnTargetChanged()
    if UnitExists("target") and not UnitIsPlayer("target") and UnitCanAttack("player", "target") then
        local guid = UnitGUID("target")
        local name = UnitName("target")
        
        -- Check if already in current pull
        local found = false
        for _, mobInfo in ipairs(self.currentPull) do
            if mobInfo.guid == guid then
                found = true
                break
            end
        end
        
        -- Add to current pull if not already there
        if not found then
            local mobPoints = self:GetMobPoints(guid, name)
            
            table.insert(self.currentPull, {
                guid = guid,
                name = name,
                points = mobPoints,
            })
        end
    end
end

-- Handle nameplate added
function ProgressTracker:OnNamePlateAdded(unit)
    if UnitCanAttack("player", unit) then
        local guid = UnitGUID(unit)
        local name = UnitName(unit)
        
        -- Store mob info for potential progress tracking
        local mobPoints = self:GetMobPoints(guid, name)
        self.mobPoints[guid] = mobPoints
    end
end

-- Handle tooltip display
function ProgressTracker:OnTooltipSetUnit()
    local _, unit = GameTooltip:GetUnit()
    if not unit or UnitIsPlayer(unit) or not UnitCanAttack("player", unit) then return end
    
    local guid = UnitGUID(unit)
    local name = UnitName(unit)
    
    -- Calculate mob points
    local mobPoints = self:GetMobPoints(guid, name)
    
    -- Add to tooltip
    if mobPoints > 0 then
        local progressPercent = mobPoints / self.totalRequired * 100
        local currentPercent = self.currentProgress / self.totalRequired * 100
        local afterKillPercent = math.min(100, currentPercent + progressPercent)
        
        -- Format precision based on settings
        local precision = AK.db.profile.progressPrecision or 2
        local formatStr = "%." .. precision .. "f%%"
        
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Enemy Forces:")
        GameTooltip:AddDoubleLine("Worth:", string.format(formatStr, progressPercent), 1, 1, 0, 1, 1, 1)
        GameTooltip:AddDoubleLine("Progress After:", string.format(formatStr, afterKillPercent), 1, 1, 0, 1, 1, 1)
        GameTooltip:Show()
    end
end

-- Update progress display with enhanced information
function ProgressTracker:UpdateProgressDisplay(frame)
    if not frame or not frame.ProgressText then return end
    
    -- Calculate current percentage with high precision
    local precision = AK.db.profile.progressPrecision or 2
    local currentPercent = self.currentProgress / self.totalRequired * 100
    
    -- Calculate percentage from current pull
    local pullValue = 0
    for _, mobInfo in ipairs(self.currentPull) do
        pullValue = pullValue + (mobInfo.points or 0)
    end
    local pullPercent = pullValue / self.totalRequired * 100
    
    -- Format current progress text with precision
    local progressText = string.format("%." .. precision .. "f%%", currentPercent)
    
    -- Add pull value if enabled and pull is active
    if defaults.showPullValue and pullValue > 0 then
        progressText = progressText .. string.format(" (+%." .. precision .. "f%%)", pullPercent)
    end
    
    -- Add death penalty if enabled and there are deaths
    if defaults.showDeathPenalty and self.deaths > 0 then
        progressText = progressText .. string.format(" | -%ds", self.deathPenalty)
    end
    
    -- Add total count if enabled
    if defaults.showTotalCount then
        progressText = progressText .. string.format(" | %d/%d", self.currentProgress, self.totalRequired)
    end
    
    -- Update the progress text
    frame.ProgressText:SetText(progressText)
    
    -- Update progress bar if there is one
    if frame.Bar then
        -- Set progress bar value
        frame.Bar:SetValue(self.currentProgress / self.totalRequired)
        
        -- Highlight current pull if enabled
        if defaults.highlightCurrentPull and pullValue > 0 then
            -- Create or update pull indicator if it doesn't exist
            if not frame.PullIndicator then
                frame.PullIndicator = frame:CreateTexture(nil, "OVERLAY")
                frame.PullIndicator:SetHeight(frame.Bar:GetHeight())
                frame.PullIndicator:SetColorTexture(1, 1, 1, 0.3)
            end
            
            -- Position and size pull indicator based on current progress and pull value
            local barWidth = frame.Bar:GetWidth()
            local progressWidth = (self.currentProgress / self.totalRequired) * barWidth
            local pullWidth = (pullValue / self.totalRequired) * barWidth
            
            frame.PullIndicator:SetWidth(pullWidth)
            frame.PullIndicator:SetPoint("LEFT", frame.Bar, "LEFT", progressWidth, 0)
            frame.PullIndicator:Show()
        elseif frame.PullIndicator then
            frame.PullIndicator:Hide()
        end
    end
end

-- Reset progress tracking
function ProgressTracker:Reset()
    self.mobPoints = {}
    self.currentProgress = 0
    self.totalRequired = 100
    self.currentPull = {}
    self.deaths = 0
    self.deathPenalty = 0
    
    -- Update displays
    if AK.progressFrames then
        for _, frame in ipairs(AK.progressFrames) do
            self:UpdateProgressDisplay(frame)
        end
    end
end

-- Enable progress tracker
function ProgressTracker:Enable()
    self.isEnabled = true
end

-- Disable progress tracker
function ProgressTracker:Disable()
    self.isEnabled = false
end