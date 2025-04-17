-- VUI Angry Keystones Core Implementation
local _, VUI = ...
local AngryKeystones = VUI.angrykeystone

-- Module functionality
function AngryKeystones:SetupModule()
    -- Hook into Mythic+ UI elements
    self:HookChallengeMode()
    self:SetupProgressTracker()
    self:SetupObjectiveTracker()
    self:SetupKeystoneInfo()
    self:SetupScheduleInfo()
    self:SetupTimerDisplay()
end

-- Hook into Challenge Mode UI
function AngryKeystones:HookChallengeMode()
    -- Watch for challenge mode start
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("CHALLENGE_MODE_START")
    frame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
    frame:RegisterEvent("CHALLENGE_MODE_RESET")
    
    frame:SetScript("OnEvent", function(_, event, ...)
        if event == "CHALLENGE_MODE_START" then
            self:OnChallengeStart(...)
        elseif event == "CHALLENGE_MODE_COMPLETED" then
            self:OnChallengeComplete(...)
        elseif event == "CHALLENGE_MODE_RESET" then
            self:OnChallengeReset(...)
        end
    end)
end

-- Setup the progress tracker
function AngryKeystones:SetupProgressTracker()
    -- Implement the enemy forces tracker
    if not self.progressFrame then
        self.progressFrame = CreateFrame("Frame", "VUIKeystonesProgressFrame", UIParent)
        self.progressFrame:SetSize(180, 40)
        self.progressFrame:SetPoint("TOPRIGHT", ObjectiveTrackerFrame, "TOPRIGHT", -10, -25)
        
        -- Progress text
        self.progressFrame.text = self.progressFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        self.progressFrame.text:SetPoint("TOPRIGHT", self.progressFrame, "TOPRIGHT", 0, 0)
        self.progressFrame.text:SetJustifyH("RIGHT")
        
        -- Forces text
        self.progressFrame.forces = self.progressFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        self.progressFrame.forces:SetPoint("TOPRIGHT", self.progressFrame.text, "BOTTOMRIGHT", 0, -2)
        self.progressFrame.forces:SetJustifyH("RIGHT")
        
        -- Timer text
        self.progressFrame.timer = self.progressFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        self.progressFrame.timer:SetPoint("TOPRIGHT", self.progressFrame.forces, "BOTTOMRIGHT", 0, -2)
        self.progressFrame.timer:SetJustifyH("RIGHT")
        
        -- Only show in Mythic+
        self.progressFrame:SetScript("OnUpdate", function()
            local inChallenge = C_ChallengeMode.IsChallengeModeActive()
            if inChallenge and not self.progressFrame:IsShown() then
                self.progressFrame:Show()
                self:UpdateProgressTracker()
            elseif not inChallenge and self.progressFrame:IsShown() then
                self.progressFrame:Hide()
            end
            
            -- Update timer if needed
            if inChallenge and self.progressFrame:IsShown() then
                self:UpdateTimer()
            end
        end)
    end
end

-- Setup the objective tracker modifications
function AngryKeystones:SetupObjectiveTracker()
    -- Hook the objective tracker to add completion time estimates
    -- Implementation will integrate with the WoW objective tracker
end

-- Setup the keystone information display
function AngryKeystones:SetupKeystoneInfo()
    -- Show more detailed keystone info when viewing a keystone
    hooksecurefunc("GameTooltip_AddQuestRewardsToTooltip", function(tooltip, questID)
        if not questID then return end
        local itemLink = GetQuestLogItemLink("reward", 1, questID)
        if itemLink and itemLink:match("keystone:") then
            -- This is a keystone reward - enhance the tooltip
            self:EnhanceKeystoneTooltip(tooltip, itemLink)
        end
    end)
    
    -- Also hook the item tooltip
    hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
        local itemLink = select(2, tooltip:GetItem())
        if itemLink and itemLink:match("keystone:") then
            self:EnhanceKeystoneTooltip(tooltip, itemLink)
        end
    end)
end

-- Enhance keystone tooltips with extra information
function AngryKeystones:EnhanceKeystoneTooltip(tooltip, itemLink)
    if not tooltip or not itemLink then return end
    
    -- Parse the keystone information
    local dungeon, level = itemLink:match("keystone:(%d+):(%d+):")
    if not dungeon or not level then return end
    
    -- Convert to numbers
    dungeon, level = tonumber(dungeon), tonumber(level)
    
    -- Add weekly affix information
    local affixes = C_MythicPlus.GetCurrentAffixes()
    if affixes then
        tooltip:AddLine(" ")
        tooltip:AddLine("Weekly Affixes:", 1, 0.85, 0)
        
        for i, affixInfo in ipairs(affixes) do
            local name, description = C_ChallengeMode.GetAffixInfo(affixInfo.id)
            tooltip:AddDoubleLine(name, "+" .. affixInfo.startLevel, 1, 1, 1, 1, 0.5, 0)
        end
    end
    
    -- Add time estimates based on historical data if we have it
    if self.db.timeData and self.db.timeData[dungeon] then
        local averageTime = self.db.timeData[dungeon].average or 0
        if averageTime > 0 then
            local minutes = math.floor(averageTime / 60)
            local seconds = math.floor(averageTime % 60)
            tooltip:AddLine(" ")
            tooltip:AddLine("Estimated Time: " .. minutes .. ":" .. string.format("%02d", seconds), 0, 1, 0)
        end
    end
    
    tooltip:Show()
end

-- Setup the schedule information display
function AngryKeystones:SetupScheduleInfo()
    -- Show the weekly affix schedule for future weeks
    hooksecurefunc("ChallengesFrame_Update", function(frame)
        if not self.scheduleFrame then
            self.scheduleFrame = CreateFrame("Frame", "VUIKeystonesScheduleFrame", frame)
            self.scheduleFrame:SetSize(150, 20)
            self.scheduleFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
            
            self.scheduleFrame.text = self.scheduleFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            self.scheduleFrame.text:SetPoint("RIGHT", self.scheduleFrame, "RIGHT")
            self.scheduleFrame.text:SetText("Schedule")
            
            self.scheduleFrame:SetScript("OnMouseDown", function()
                if self.schedulePopup and self.schedulePopup:IsShown() then
                    self.schedulePopup:Hide()
                else
                    self:ShowSchedulePopup()
                end
            end)
        end
    end)
end

-- Show the affix schedule popup
function AngryKeystones:ShowSchedulePopup()
    if not self.schedulePopup then
        self.schedulePopup = CreateFrame("Frame", "VUIKeystonesSchedulePopup", UIParent, "BackdropTemplate")
        self.schedulePopup:SetSize(250, 200)
        self.schedulePopup:SetPoint("CENTER")
        self.schedulePopup:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 32,
            edgeSize = 32,
            insets = { left = 11, right = 12, top = 12, bottom = 11 }
        })
        
        -- Title
        self.schedulePopup.title = self.schedulePopup:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        self.schedulePopup.title:SetPoint("TOP", self.schedulePopup, "TOP", 0, -15)
        self.schedulePopup.title:SetText("Affix Schedule")
        
        -- Close button
        self.schedulePopup.closeButton = CreateFrame("Button", nil, self.schedulePopup, "UIPanelCloseButton")
        self.schedulePopup.closeButton:SetPoint("TOPRIGHT", self.schedulePopup, "TOPRIGHT", -5, -5)
        
        -- Schedule content will be populated in UpdateSchedulePopup
    end
    
    self:UpdateSchedulePopup()
    self.schedulePopup:Show()
end

-- Update the schedule popup with current data
function AngryKeystones:UpdateSchedulePopup()
    if not self.schedulePopup then return end
    
    -- Clear existing schedule entries
    if self.schedulePopup.entries then
        for _, entry in ipairs(self.schedulePopup.entries) do
            entry:Hide()
        end
    end
    
    self.schedulePopup.entries = {}
    
    -- Get the current affixes
    local currentAffixes = C_MythicPlus.GetCurrentAffixes()
    if not currentAffixes then return end
    
    -- Get the rotation position based on current affixes
    local rotationIndex = 1 -- Default if we can't determine
    
    -- Create schedule entries for the next 10 weeks
    for i = 0, 9 do
        local weekIndex = (rotationIndex + i - 1) % 12 + 1
        local week = "Week " .. weekIndex
        
        local entry = CreateFrame("Frame", nil, self.schedulePopup)
        entry:SetSize(230, 20)
        entry:SetPoint("TOP", self.schedulePopup, "TOP", 0, -40 - (i * 20))
        
        -- Week name
        entry.weekName = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        entry.weekName:SetPoint("LEFT", entry, "LEFT", 10, 0)
        entry.weekName:SetText(i == 0 and "Current" or ("+" .. i))
        
        -- Affix names
        entry.affixNames = entry:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        entry.affixNames:SetPoint("RIGHT", entry, "RIGHT", -10, 0)
        
        -- Get the affixes for this week
        local weeklyAffixes = self:GetAffixesForRotation(weekIndex)
        local affixText = ""
        for j, affixID in ipairs(weeklyAffixes) do
            local name = select(1, C_ChallengeMode.GetAffixInfo(affixID))
            affixText = affixText .. name
            if j < #weeklyAffixes then
                affixText = affixText .. ", "
            end
        end
        entry.affixNames:SetText(affixText)
        
        table.insert(self.schedulePopup.entries, entry)
    end
end

-- Get the affixes for a given rotation
function AngryKeystones:GetAffixesForRotation(rotationIndex)
    -- Affix rotation data - this would need to be updated for each patch
    local rotations = {
        {10, 11, 3}, -- Fortified, Bursting, Volcanic
        {9, 7, 13},  -- Tyrannical, Bolstering, Explosive
        {10, 123, 12}, -- Fortified, Spiteful, Grievous
        {9, 122, 4},   -- Tyrannical, Inspiring, Necrotic
        {10, 7, 2},    -- Fortified, Bolstering, Quaking
        {9, 11, 3},    -- Tyrannical, Bursting, Volcanic
        {10, 122, 13}, -- Fortified, Inspiring, Explosive
        {9, 123, 12},  -- Tyrannical, Spiteful, Grievous
        {10, 6, 4},    -- Fortified, Raging, Necrotic
        {9, 5, 2},     -- Tyrannical, Sanguine, Quaking
        {10, 8, 14},   -- Fortified, Storming, Afflicted
        {9, 6, 124},   -- Tyrannical, Raging, Entangling
    }
    
    return rotations[rotationIndex]
end

-- Event handlers
function AngryKeystones:OnChallengeStart()
    -- Save the start time
    self.startTime = GetTime()
    self.deathCount = 0
    self:UpdateProgressTracker()
end

function AngryKeystones:OnChallengeComplete(mapID, level, time, onTime, keystoneUpgrades)
    -- Record the completion for statistics
    if not self.db.completions then self.db.completions = {} end
    if not self.db.completions[mapID] then self.db.completions[mapID] = {} end
    
    table.insert(self.db.completions[mapID], {
        level = level,
        time = time / 1000, -- Convert to seconds
        onTime = onTime,
        upgrades = keystoneUpgrades,
        date = time()
    })
    
    -- Update average time
    if not self.db.timeData then self.db.timeData = {} end
    if not self.db.timeData[mapID] then 
        self.db.timeData[mapID] = { 
            runs = 0,
            totalTime = 0
        }
    end
    
    self.db.timeData[mapID].runs = self.db.timeData[mapID].runs + 1
    self.db.timeData[mapID].totalTime = self.db.timeData[mapID].totalTime + (time / 1000)
    self.db.timeData[mapID].average = self.db.timeData[mapID].totalTime / self.db.timeData[mapID].runs
end

function AngryKeystones:OnChallengeReset()
    -- Reset all challenge related variables
    self.startTime = nil
    self.deathCount = nil
    
    if self.progressFrame then
        self.progressFrame:Hide()
    end
end

-- Update the progress tracker display
function AngryKeystones:UpdateProgressTracker()
    if not self.progressFrame or not C_ChallengeMode.IsChallengeModeActive() then return end
    
    -- Get current progress
    local _, totalProgress = C_Scenario.GetCriteriaInfo(1)
    local currentProgress = C_Scenario.GetCriteriaProgress(1)
    local percentProgress = math.floor((currentProgress / totalProgress) * 100)
    
    -- Update the display
    self.progressFrame.text:SetText("Progress")
    self.progressFrame.forces:SetText(currentProgress .. " / " .. totalProgress .. " (" .. percentProgress .. "%)")
    
    -- Update time display
    self:UpdateTimer()
    
    self.progressFrame:Show()
end

-- Update the timer display
function AngryKeystones:UpdateTimer()
    if not self.progressFrame or not self.startTime then return end
    
    local now = GetTime()
    local elapsed = now - self.startTime
    
    -- Get time limit
    local mapID = C_ChallengeMode.GetActiveChallengeMapID()
    local _, timeLimit = C_ChallengeMode.GetMapUIInfo(mapID)
    
    -- Calculate time remaining
    local remaining = timeLimit - elapsed
    
    -- Format time
    local minutes, seconds = math.floor(remaining / 60), math.floor(remaining % 60)
    local timeText = string.format("%d:%02d", minutes, seconds)
    
    -- Colorize based on time remaining
    local r, g, b = 1, 1, 1
    if remaining < 60 then -- Less than 1 minute
        r, g, b = 1, 0, 0
    elseif remaining < 180 then -- Less than 3 minutes
        r, g, b = 1, 0.5, 0
    end
    
    self.progressFrame.timer:SetText(timeText)
    self.progressFrame.timer:SetTextColor(r, g, b)
end

-- Initialize the module
function AngryKeystones:Initialize()
    -- Create database
    if not VUI.db.profile.modules.angrykeystone then
        VUI.db.profile.modules.angrykeystone = {
            enabled = true,
            showObjectiveTracker = true,
            showProgressTracker = true,
            showKeystoneInfo = true,
            showScheduleInfo = true,
            timeEstimates = true,
            completions = {},
            timeData = {}
        }
    end
    
    self.db = VUI.db.profile.modules.angrykeystone
    
    -- Initialize the module
    if self.db.enabled then
        self:SetupModule()
        VUI:Print("Angry Keystones module initialized")
    end
end
