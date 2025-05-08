-- VUIKeystones - Progress Tracker functionality
local VUIKeystones = LibStub("AceAddon-3.0"):GetAddon("VUIKeystones")
local ProgressTracker = VUIKeystones:NewModule('ProgressTracker')
local L = VUIKeystones.L

-- Local variables
local isProgressHooked = false
local tooltipHooked = false
local lastUpdate = 0
local trackerFrame = nil
local progressText = nil
local timerText = nil
local timerBar = nil
local timerBarTexture = nil
local timerBarSpark = nil
local challengeMapID = 0
local startTime = nil
local deathCount = 0
local deathText = nil

-- Helper function to format progress values
local function FormatProgress(current, total, format)
    if not current or not total or total == 0 then
        return ""
    end
    
    local percent = current / total * 100
    
    if format == 1 then -- 24.19%
        return string.format("%.2f%%", percent)
    elseif format == 2 then -- 90/372
        return string.format("%d/%d", current, total)
    elseif format == 3 then -- 24.19% - 90/372
        return string.format("%.2f%% - %d/%d", percent, current, total)
    elseif format == 4 then -- 24.19% (75.81%)
        return string.format("%.2f%% (%.2f%%)", percent, 100 - percent)
    elseif format == 5 then -- 90/372 (282)
        return string.format("%d/%d (%d)", current, total, total - current)
    elseif format == 6 then -- 24.19% (75.81%) - 90/372 (282)
        return string.format("%.2f%% (%.2f%%) - %d/%d (%d)", percent, 100 - percent, current, total, total - current)
    else
        return string.format("%.2f%%", percent)
    end
end

-- Register for events
function ProgressTracker:OnInitialize()
    -- Create the tracking frame
    self:CreateTrackingFrame()
    
    -- Register for events
    VUIKeystones:RegisterEvent("SCENARIO_CRITERIA_UPDATE", self)
    VUIKeystones:RegisterEvent("CHALLENGE_MODE_START", self)
    VUIKeystones:RegisterEvent("CHALLENGE_MODE_RESET", self)
    VUIKeystones:RegisterEvent("PLAYER_DEAD", self)
    VUIKeystones:RegisterEvent("ENCOUNTER_END", self)
    
    -- Hook tooltips to show enemy forces info
    if not tooltipHooked and VUIKeystones:GetModule("Config"):Get("progressTooltip") then
        self:HookTooltips()
        tooltipHooked = true
    end
end

-- Create the UI elements for progress tracking
function ProgressTracker:CreateTrackingFrame()
    if trackerFrame then return end
    
    -- Create main frame
    trackerFrame = CreateFrame("Frame", "VUIKeystonesProgressTracker", UIParent)
    trackerFrame:SetSize(200, 24)
    trackerFrame:SetPoint("TOP", ObjectiveTrackerFrame, "BOTTOM", 0, -5)
    trackerFrame:SetFrameStrata("HIGH")
    trackerFrame:Hide() -- Hide initially
    
    -- Create progress text
    progressText = trackerFrame:CreateFontString(nil, "OVERLAY")
    progressText:SetFontObject("GameFontNormalSmall")
    progressText:SetPoint("TOPLEFT", trackerFrame, "TOPLEFT", 0, 0)
    progressText:SetText("")
    
    -- Create timer bar
    timerBar = CreateFrame("StatusBar", nil, trackerFrame)
    timerBar:SetSize(200, 16)
    timerBar:SetPoint("TOP", progressText, "BOTTOM", 0, -2)
    timerBar:SetStatusBarTexture(VUIKeystones:GetMediaPath("Bar"))
    timerBar:SetMinMaxValues(0, 1)
    timerBar:SetValue(1)
    timerBar:SetStatusBarColor(0, 1, 0)
    
    -- Create timer bar background
    local timerBarBG = timerBar:CreateTexture(nil, "BACKGROUND")
    timerBarBG:SetAllPoints()
    timerBarBG:SetTexture(VUIKeystones:GetMediaPath("Bar"))
    timerBarBG:SetVertexColor(0.2, 0.2, 0.2, 0.8)
    
    -- Create timer text
    timerText = timerBar:CreateFontString(nil, "OVERLAY")
    timerText:SetFontObject("GameFontNormalSmall")
    timerText:SetPoint("CENTER", timerBar, "CENTER", 0, 0)
    timerText:SetText("")
    
    -- Create death counter
    deathText = trackerFrame:CreateFontString(nil, "OVERLAY")
    deathText:SetFontObject("GameFontNormalSmall")
    deathText:SetPoint("TOP", timerBar, "BOTTOM", 0, -2)
    deathText:SetText("")
    
    -- Create spark effect for timer bar
    timerBarSpark = timerBar:CreateTexture(nil, "OVERLAY")
    timerBarSpark:SetSize(16, 16)
    timerBarSpark:SetBlendMode("ADD")
    timerBarSpark:SetPoint("CENTER", timerBar, "LEFT", 0, 0)
    
    -- Register for updates
    trackerFrame:SetScript("OnUpdate", function(self, elapsed)
        lastUpdate = lastUpdate + elapsed
        if lastUpdate >= 0.1 then -- Update 10 times per second
            lastUpdate = 0
            ProgressTracker:UpdateDisplay()
        end
    end)
    
    -- Start hidden
    trackerFrame:Hide()
end

-- Update the display with current progress and timer
function ProgressTracker:UpdateDisplay()
    if not trackerFrame:IsVisible() then return end
    
    -- Update progress text
    local _, _, _, _, totalQuantity, _, _, quantityString = C_Scenario.GetCriteriaInfo(1)
    if quantityString then
        local current, total = strmatch(quantityString, "(%d+)/(%d+)")
        current, total = tonumber(current), tonumber(total)
        
        if current and total and total > 0 then
            local format = VUIKeystones:GetModule("Config"):Get("progressFormat") or 1
            progressText:SetText("Enemy Forces: " .. FormatProgress(current, total, format))
        end
    end
    
    -- Update timer display
    if startTime then
        local currentTime = GetTime()
        local elapsed = currentTime - startTime
        
        local timeLimit = self:GetTimeLimit(challengeMapID)
        if timeLimit then
            local remaining = timeLimit - elapsed
            local percent = remaining / timeLimit
            
            -- Update timer bar
            timerBar:SetValue(percent > 0 and percent or 0)
            
            -- Update color based on time left
            if percent > 0.6 then
                timerBar:SetStatusBarColor(0, 1, 0) -- Green
            elseif percent > 0.3 then
                timerBar:SetStatusBarColor(1, 1, 0) -- Yellow
            else
                timerBar:SetStatusBarColor(1, 0, 0) -- Red
            end
            
            -- Update spark position
            timerBarSpark:SetPoint("CENTER", timerBar, "LEFT", timerBar:GetWidth() * percent, 0)
            
            -- Update timer text
            timerText:SetText(string.format("Time: %s", VUIKeystones:FormatTime(remaining)))
        end
    end
    
    -- Update death counter if enabled
    if VUIKeystones:GetModule("Config"):Get("deathTracker") and deathCount > 0 then
        deathText:SetText(string.format("Deaths: %d", deathCount))
        deathText:Show()
    else
        deathText:Hide()
    end
end

-- Hook tooltips to show enemy forces info
function ProgressTracker:HookTooltips()
    -- Hook tooltip functions to display progress contribution
    -- This would hook GameTooltip:SetUnit to show enemy forces
end

-- Get the time limit for a specific map
function ProgressTracker:GetTimeLimit(mapID)
    -- Updated with The War Within Season 2 dungeons and timers (started April 30, 2024)
    local timers = {
        -- The War Within Season 2 Dungeons
        [1247] = 1800, -- Doom's Howl (new in Season 2)
        [1248] = 1800, -- Vortex Pinnacle (new in Season 2)
        [406] = 1800,  -- Ruby Life Pools
        [405] = 1800,  -- The Azure Vault
        [404] = 1800,  -- The Nokhud Offensive
        [1196] = 1800, -- Darkheart Thicket
        [1207] = 1800, -- The Everbloom
        [1208] = 1800, -- Throne of the Tides

        -- Older dungeons kept for compatibility
        [375] = 1800, -- Mists of Tirna Scithe
        [376] = 1500, -- The Necrotic Wake
        [377] = 1800, -- De Other Side
        [378] = 1440, -- Halls of Atonement
        [379] = 1800, -- Plaguefall
        [380] = 1440, -- Sanguine Depths
        [381] = 2160, -- Spires of Ascension
        [382] = 1440, -- Theater of Pain
        [2] = 1500,   -- Temple of the Jade Serpent
        [165] = 1320, -- Neltharion's Lair
        [197] = 1800, -- Eye of Azshara
        [199] = 1800, -- Vault of the Wardens
        [244] = 1800, -- Atal'Dazar
        [245] = 1800, -- Freehold
        [246] = 1560, -- Tol Dagor
        [247] = 1800, -- The MOTHERLODE!!
        [248] = 2160, -- Waycrest Manor
        [249] = 1800, -- Kings' Rest
        [250] = 2160, -- Temple of Sethraliss
        [252] = 2160, -- Shrine of the Storm
        [353] = 1800, -- Mists of Tirna Scithe
        [369] = 1800, -- Operation: Mechagon - Junkyard
        [370] = 1800, -- Operation: Mechagon - Workshop
        [391] = 1920, -- Tazavesh: Streets of Wonder
        [392] = 1320, -- Tazavesh: So'leah's Gambit
    }
    
    return timers[mapID]
end

-- Event handlers
function ProgressTracker:CHALLENGE_MODE_START()
    -- A challenge has started, show our tracker
    challengeMapID = C_ChallengeMode.GetActiveChallengeMapID()
    startTime = GetTime()
    deathCount = 0
    
    -- Show the tracker
    trackerFrame:Show()
    
    -- Update display
    self:UpdateDisplay()
end

function ProgressTracker:CHALLENGE_MODE_RESET()
    -- Challenge was reset, hide our tracker
    trackerFrame:Hide()
    startTime = nil
    deathCount = 0
end

function ProgressTracker:SCENARIO_CRITERIA_UPDATE()
    -- Criteria updated (progress), update our display
    self:UpdateDisplay()
end

function ProgressTracker:PLAYER_DEAD()
    -- Player died, increment death counter
    if trackerFrame:IsVisible() and C_ChallengeMode.GetActiveChallengeMapID() > 0 then
        deathCount = deathCount + 1
        self:UpdateDisplay()
    end
end

function ProgressTracker:ENCOUNTER_END()
    -- Boss was defeated, update the display to reflect this
    self:UpdateDisplay()
end

-- Register callback for config updates
function ProgressTracker:UpdateConfig()
    -- Update display based on new config settings
    if VUIKeystones:GetModule("Config"):Get("progressTooltip") and not tooltipHooked then
        self:HookTooltips()
        tooltipHooked = true
    end
    
    -- Update visibility based on settings
    if trackerFrame then
        if VUIKeystones.db.profile.general.enabled and C_ChallengeMode.GetActiveChallengeMapID() > 0 then
            trackerFrame:Show()
        else
            trackerFrame:Hide()
        end
    end
end