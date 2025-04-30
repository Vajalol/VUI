-------------------------------------------------------------------------------
-- Title: AngryKeystones Chest Timer Notifications
-- Author: VortexQ8
-- Enhanced chest timer notifications for AngryKeystones
-------------------------------------------------------------------------------

local _, VUI = ...
local AK = VUI.modules.angrykeystones

-- Skip if AngryKeystones module is not available
if not AK then return end

-- Create the chest timer notifications namespace
AK.ChestTimerNotifications = {}
local ChestNotify = AK.ChestTimerNotifications

-- Default settings
local defaults = {
    chestThresholds = {
        [1] = 0.9, -- 90% of time remaining for +3 chest
        [2] = 0.8, -- 80% of time remaining for +2 chest
        [3] = 0.6, -- 60% of time remaining for +1 chest
    },
    warningThresholds = {
        [1] = 0.15, -- 15% time remaining warning for +3
        [2] = 0.15, -- 15% time remaining warning for +2
        [3] = 0.15, -- 15% time remaining warning for +1
    },
    colors = {
        [1] = {0, 1, 0}, -- Green for +3
        [2] = {1, 1, 0}, -- Yellow for +2
        [3] = {1, 0.5, 0}, -- Orange for +1
    },
    soundEffects = {
        onTrack = "TimerOnTrack",
        warning = "TimerWarning",
        success = "TimerSuccess",
        failure = "TimerFailure",
    },
}

-- Initialize chest notifications
function ChestNotify:Initialize()
    self.isEnabled = AK.db.profile.chestTimerNotifications
    self.trackedKeystone = nil
    self.chestTimers = {}
    self.notifications = {}
    self.lastStatus = {}
    
    -- Register for events
    if self.isEnabled then
        self:RegisterEvents()
    end
end

-- Register for events
function ChestNotify:RegisterEvents()
    -- Hook into timer updates
    if AK.ChallengesModule and AK.ChallengesModule.UpdateTime then
        AK:SecureHook(AK.ChallengesModule, "UpdateTime", function(_, elapsedTime)
            if self.isEnabled then
                self:UpdateTimerStatus(elapsedTime)
            end
        end)
    end
    
    -- Hook into challenge start event
    AK:RegisterEvent("CHALLENGE_MODE_START", function()
        if self.isEnabled then
            self:OnChallengeStart()
        end
    end)
    
    -- Hook into challenge complete event
    AK:RegisterEvent("CHALLENGE_MODE_COMPLETED", function()
        if self.isEnabled then
            self:OnChallengeComplete()
        end
    end)
    
    -- Hook into challenge reset event
    AK:RegisterEvent("CHALLENGE_MODE_RESET", function()
        if self.isEnabled then
            self:OnChallengeReset()
        end
    end)
end

-- Handle challenge start
function ChestNotify:OnChallengeStart()
    -- Get current keystone information
    local mapID = C_ChallengeMode.GetActiveChallengeMapID()
    if not mapID then return end
    
    local mapName = C_ChallengeMode.GetMapUIInfo(mapID)
    local level = C_ChallengeMode.GetActiveKeystoneInfo()
    
    -- Store current keystone
    self.trackedKeystone = {
        mapID = mapID,
        mapName = mapName,
        level = level,
        startTime = GetTime(),
    }
    
    -- Reset notifications
    self.notifications = {}
    self.lastStatus = {}
    
    -- Get chest timers
    self:GetChestTimers()
    
    -- Notify keystone start
    self:ShowNotification(string.format("Tracking %s +%d", mapName or "Keystone", level or 0), {1, 1, 1})
end

-- Handle challenge complete
function ChestNotify:OnChallengeComplete()
    if not self.trackedKeystone then return end
    
    -- Check if we met any chest timer
    for i, timer in ipairs(self.chestTimers) do
        if timer.metTimer then
            local chestLevel = #self.chestTimers - i + 1
            self:ShowNotification(string.format("%s +%d complete! +%d chest earned!", 
                self.trackedKeystone.mapName or "Keystone", 
                self.trackedKeystone.level or 0,
                chestLevel), 
                defaults.colors[chestLevel])
            
            -- Play success sound
            self:PlaySound(defaults.soundEffects.success)
            break
        end
    end
    
    -- Reset tracked keystone
    self.trackedKeystone = nil
    self.chestTimers = {}
    self.notifications = {}
    self.lastStatus = {}
end

-- Handle challenge reset
function ChestNotify:OnChallengeReset()
    -- Reset tracked keystone
    self.trackedKeystone = nil
    self.chestTimers = {}
    self.notifications = {}
    self.lastStatus = {}
    
    -- Notify key reset
    self:ShowNotification("Keystone tracking stopped", {1, 0.5, 0})
end

-- Get chest timers from AngryKeystones
function ChestNotify:GetChestTimers()
    if not AK.ChallengesModule or not AK.ChallengesModule.timers then return end
    
    -- Store chest timers
    self.chestTimers = {}
    
    for i, timer in ipairs(AK.ChallengesModule.timers) do
        if timer.time then
            table.insert(self.chestTimers, {
                level = #AK.ChallengesModule.timers - i + 1, -- +1, +2, or +3
                time = timer.time,
                metTimer = false,
                notifiedOnTrack = false,
                notifiedWarning = false,
            })
        end
    end
end

-- Update timer status
function ChestNotify:UpdateTimerStatus(elapsedTime)
    if not self.trackedKeystone or #self.chestTimers == 0 then return end
    
    -- Update timer status for each chest level
    for i, timer in ipairs(self.chestTimers) do
        -- Calculate percentage of time remaining
        local timeRemaining = timer.time - elapsedTime
        local percentRemaining = timeRemaining / timer.time
        
        -- Get chest level
        local chestLevel = timer.level
        
        -- Check if still on track for this chest
        local onTrack = percentRemaining > 0
        
        -- Check if previously was on track
        local wasOnTrack = self.lastStatus[chestLevel] and self.lastStatus[chestLevel].onTrack
        
        -- Check if threshold reached
        local thresholdReached = percentRemaining <= defaults.chestThresholds[chestLevel] and not timer.notifiedOnTrack
        
        -- Check if warning threshold reached
        local warningReached = percentRemaining <= defaults.warningThresholds[chestLevel] and percentRemaining > 0 and not timer.notifiedWarning
        
        -- Check if timer just expired
        local justExpired = wasOnTrack and not onTrack
        
        -- Handle on-track notification
        if onTrack and thresholdReached then
            timer.notifiedOnTrack = true
            
            -- Show on-track notification
            local message = string.format("On track for +%d chest! %.1f%% of time remaining", 
                chestLevel, percentRemaining * 100)
            self:ShowNotification(message, defaults.colors[chestLevel])
            
            -- Play on-track sound
            self:PlaySound(defaults.soundEffects.onTrack)
        end
        
        -- Handle warning notification
        if onTrack and warningReached then
            timer.notifiedWarning = true
            
            -- Show warning notification
            local message = string.format("+%d chest timer running low! %.1f seconds left", 
                chestLevel, timeRemaining)
            self:ShowNotification(message, defaults.colors[chestLevel])
            
            -- Play warning sound
            self:PlaySound(defaults.soundEffects.warning)
        end
        
        -- Handle just expired
        if justExpired then
            -- Show expired notification
            local message = string.format("+%d chest timer expired", chestLevel)
            self:ShowNotification(message, {1, 0, 0})
            
            -- Play failure sound
            self:PlaySound(defaults.soundEffects.failure)
        end
        
        -- Check if met timer (for completion)
        if elapsedTime <= timer.time then
            timer.metTimer = true
        end
        
        -- Update last status
        self.lastStatus[chestLevel] = {
            onTrack = onTrack,
            percentRemaining = percentRemaining,
        }
    end
end

-- Show notification
function ChestNotify:ShowNotification(message, colorTable)
    -- If VUI has a notification system, use it
    if VUI.Notify and VUI.Notify.AddNotification then
        VUI.Notify:AddNotification({
            text = message,
            icon = "Interface\\Icons\\INV_Relics_Hourglass",
            r = colorTable[1],
            g = colorTable[2],
            b = colorTable[3],
            duration = 3,
        })
    else
        -- Fallback to plain print
        print(string.format("|cffffcc00[VUI:AK]|r %s", message))
    end
end

-- Play sound effect
function ChestNotify:PlaySound(soundName)
    local LSM = LibStub("LibSharedMedia-3.0")
    if not LSM then return end
    
    -- Get current theme
    local currentTheme = VUI.db.profile.appearance.theme or "thunderstorm"
    
    -- Try to get theme-specific sound
    local soundFile = nil
    
    -- Try theme-specific version first
    local themeSpecificName = "VUI:AngryKeystones:" .. currentTheme .. ":" .. soundName
    if LSM:IsValid(LSM.MediaType.SOUND, themeSpecificName) then
        soundFile = LSM:Fetch(LSM.MediaType.SOUND, themeSpecificName)
    end
    
    -- Try generic version
    if not soundFile then
        local genericName = "VUI:AngryKeystones:" .. soundName
        if LSM:IsValid(LSM.MediaType.SOUND, genericName) then
            soundFile = LSM:Fetch(LSM.MediaType.SOUND, genericName)
        end
    end
    
    -- If we got a sound file, play it
    if soundFile then
        PlaySoundFile(soundFile, "Master")
    end
end

-- Enable chest timer notifications
function ChestNotify:Enable()
    self.isEnabled = true
    self:RegisterEvents()
end

-- Disable chest timer notifications
function ChestNotify:Disable()
    self.isEnabled = false
    self.trackedKeystone = nil
    self.chestTimers = {}
    self.notifications = {}
    self.lastStatus = {}
end