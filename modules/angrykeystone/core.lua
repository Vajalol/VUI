-------------------------------------------------------------------------------
-- Title: AngryKeystones Core
-- Author: VortexQ8
-- Core functionality for the AngryKeystones module
-------------------------------------------------------------------------------

local _, VUI = ...
local AngryKeystones = VUI.angrykeystone
if not AngryKeystones then return end

-- Constants
local TIMER_WARNING_THRESHOLD = 0.6  -- 60% of timer left (green)
local TIMER_DANGER_THRESHOLD = 0.2   -- 20% of timer left (red)

-- Track important UI frames
AngryKeystones.timerFrame = nil
AngryKeystones.enemyForcesFrame = nil
AngryKeystones.keystoneInfoFrame = nil
AngryKeystones.scheduleFrame = nil
AngryKeystones.objectiveTracker = nil

-- Get config from saved variables
local function GetConfig(option)
    return VUI.db.profile.modules.angrykeystone[option]
end

-- Hook the Blizzard Challenge Mode UI
function AngryKeystones:HookChallengeMode()
    if not self.enabled then return end
    
    -- Hook ScenarioChallengeModeBlock to apply our styling
    if ScenarioChallengeModeBlock then
        if not self.challengeHooked then
            hooksecurefunc("Scenario_ChallengeMode_UpdateTime", function()
                -- Apply theme to timer if we have it
                if self.ThemeIntegration and GetConfig("useVUITheme") then
                    -- Store reference to the timer frame
                    self.timerFrame = ScenarioChallengeModeBlock.TimerBar
                    
                    -- Apply theme to the timer
                    self.ThemeIntegration:ApplyThemeToTimerDisplay(ScenarioChallengeModeBlock)
                end
            end)
            
            -- Hook objective tracker updates
            hooksecurefunc("Scenario_ChallengeMode_UpdateDeaths", function()
                if self.ThemeIntegration and GetConfig("useVUITheme") then
                    -- Apply theme to objective tracker
                    self.ThemeIntegration:ApplyThemeToObjectiveTracker()
                end
            end)
            
            self.challengeHooked = true
        end
    end
    
    -- Hook ScenarioObjectiveBlock to apply our styling to enemy forces
    if ScenarioObjectiveBlock_UpdateProgressBar then
        if not self.objectiveHooked then
            hooksecurefunc("ScenarioObjectiveBlock_UpdateProgressBar", function(block)
                if self.ThemeIntegration and GetConfig("useVUITheme") and block and block.ProgressBar then
                    -- Store reference to enemy forces block
                    local blockType = block.questLogIndex and C_QuestLog.GetQuestType(block.questLogIndex)
                    
                    -- If this is an enemy forces progress bar
                    if blockType == Enum.QuestType.Monster then
                        self.enemyForcesFrame = block
                        self.ThemeIntegration:ApplyThemeToEnemyForces(block)
                    end
                end
            end)
            
            self.objectiveHooked = true
        end
    end
end

-- Update timer coloring based on remaining time
function AngryKeystones:UpdateTimerColor()
    if not self.enabled or not self.timerFrame then return end
    
    -- If we're using VUI theme
    if GetConfig("useVUITheme") and self.ThemeIntegration then
        local bar = self.timerFrame
        local timeLeft = bar:GetValue()
        local timeLimit = bar:GetMinMaxValues()
        timeLimit = timeLimit > 0 and timeLimit or 1
        
        local percentage = timeLeft / timeLimit
        
        -- Get the appropriate color based on the timer percentage
        local colors = self.ThemeIntegration:GetTimerColor(percentage)
        
        -- Apply color to bar
        bar:SetStatusBarColor(colors[1], colors[2], colors[3])
    end
end

-- Play completion sound when dungeon is completed
function AngryKeystones:PlayCompletionSound()
    if not self.enabled then return end
    
    local theme = GetConfig("useVUITheme") and VUI.db.profile.appearance.theme or GetConfig("customStyle")
    theme = theme or "thunderstorm"
    
    -- Play the appropriate completion sound
    local soundFile = "Interface\\AddOns\\VUI\\media\\sounds\\" .. theme .. "\\angrykeystone\\completion"
    
    -- In a real addon, you would play the sound like this:
    -- PlaySoundFile(soundFile, "Master")
    
    -- Debug disabled in production release
end

-- Hook keystone slotting to capture keystone level info
function AngryKeystones:HookKeystoneSlotting()
    if not self.enabled then return end
    
    -- Hook C_ChallengeMode.SlotKeystone
    hooksecurefunc(C_ChallengeMode, "SlotKeystone", function()
        -- Show keystone info if enabled
        if GetConfig("showKeystoneInfo") then
            self:ShowKeystoneInfo()
        end
    end)
end

-- Display keystone information
function AngryKeystones:ShowKeystoneInfo()
    if not self.enabled then return end
    
    -- Create or get the keystone info frame
    if not self.keystoneInfoFrame then
        self.keystoneInfoFrame = CreateFrame("Frame", "VUIAngryKeystonesInfo", UIParent)
        -- Set up frame properties (in a real addon)
    end
    
    -- Apply theme if using VUI theme
    if GetConfig("useVUITheme") and self.ThemeIntegration then
        self.ThemeIntegration:ApplyThemeToKeystoneInfo(self.keystoneInfoFrame)
    end
    
    -- Show the frame
    self.keystoneInfoFrame:Show()
end

-- Show mythic+ schedule
function AngryKeystones:ShowSchedule()
    if not self.enabled then return end
    
    -- Create or get the schedule frame
    if not self.scheduleFrame then
        self.scheduleFrame = CreateFrame("Frame", "VUIAngryKeystonesSchedule", UIParent)
        -- Set up frame properties (in a real addon)
    end
    
    -- Apply theme if using VUI theme
    if GetConfig("useVUITheme") and self.ThemeIntegration then
        self.ThemeIntegration:ApplyThemeToScheduleInfo(self.scheduleFrame)
    end
    
    -- Show the frame
    self.scheduleFrame:Show()
end

-- Update all module displays
function AngryKeystones:UpdateDisplays()
    if not self.enabled then return end
    
    -- Update timer if it exists
    if self.timerFrame then
        self:UpdateTimerColor()
    end
    
    -- Apply theme to all elements if using VUI theme
    if GetConfig("useVUITheme") and self.ThemeIntegration then
        self.ThemeIntegration:ApplyTheme()
    end
end

-- Set up all hooks
function AngryKeystones:SetupHooks()
    -- Hook challenge mode UI
    self:HookChallengeMode()
    
    -- Hook keystone slotting
    self:HookKeystoneSlotting()
    
    -- Set up event handlers
    self:SetupEvents()
end

-- Set up event handlers
function AngryKeystones:SetupEvents()
    -- Create event frame if it doesn't exist
    if not self.eventFrame then
        self.eventFrame = CreateFrame("Frame")
        self.eventFrame:SetScript("OnEvent", function(_, event, ...)
            if self[event] then
                self[event](self, ...)
            end
        end)
    end
    
    -- Register events
    self.eventFrame:RegisterEvent("CHALLENGE_MODE_START")
    self.eventFrame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
    self.eventFrame:RegisterEvent("CHALLENGE_MODE_RESET")
    self.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
end

-- Event: CHALLENGE_MODE_START
function AngryKeystones:CHALLENGE_MODE_START()
    if not self.enabled then return end
    
    -- Update displays
    self:UpdateDisplays()
    
    -- Debug disabled in production release
end

-- Event: CHALLENGE_MODE_COMPLETED
function AngryKeystones:CHALLENGE_MODE_COMPLETED()
    if not self.enabled then return end
    
    -- Play completion sound
    self:PlayCompletionSound()
    
    -- Debug disabled in production release
end

-- Event: CHALLENGE_MODE_RESET
function AngryKeystones:CHALLENGE_MODE_RESET()
    if not self.enabled then return end
    
    -- Update displays
    self:UpdateDisplays()
    
    -- Debug disabled in production release
end

-- Event: PLAYER_ENTERING_WORLD
function AngryKeystones:PLAYER_ENTERING_WORLD()
    if not self.enabled then return end
    
    -- Update displays
    self:UpdateDisplays()
end

-- Event: ZONE_CHANGED_NEW_AREA
function AngryKeystones:ZONE_CHANGED_NEW_AREA()
    if not self.enabled then return end
    
    -- Update displays
    self:UpdateDisplays()
end

-- Apply hooks
function AngryKeystones:ApplyHooks()
    if not self.enabled then return end
    
    -- Apply the hooks defined in SetupHooks
    self:HookChallengeMode()
    
    -- Apply theme if using VUI theme
    if GetConfig("useVUITheme") and self.ThemeIntegration then
        self.ThemeIntegration:ApplyTheme()
    end
    
    -- Debug disabled in production release
end

-- Remove hooks
function AngryKeystones:RemoveHooks()
    -- In a real addon, we would unhook functions here if possible
    
    -- Debug disabled in production release
end

-- Refresh settings based on configuration changes
function AngryKeystones:RefreshSettings()
    if not self.enabled then return end
    
    -- Update displays
    self:UpdateDisplays()
    
    -- Debug disabled in production release
end