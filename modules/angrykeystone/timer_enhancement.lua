-------------------------------------------------------------------------------
-- Title: AngryKeystones Timer Enhancement
-- Author: VortexQ8
-- Enhanced timer tracking and visualization for Mythic+ dungeons
-------------------------------------------------------------------------------

local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end
local AngryKeystones = VUI.angrykeystone
if not AngryKeystones then return end

-- Create the timer enhancement namespace
AngryKeystones.TimerEnhancement = {}
local TimerEnhancement = AngryKeystones.TimerEnhancement

-- Constants
local TIMER_WARNING_THRESHOLD = 0.6  -- 60% of timer left - Green
local TIMER_DANGER_THRESHOLD = 0.2   -- 20% of timer left - Red

-- Cache references to frequently used functions
local GetTime = GetTime
local math_floor = math.floor
local math_ceil = math.ceil
local string_format = string.format

-- Get config from saved variables
local function GetConfig(option)
    return VUI.db.profile.modules.angrykeystone[option]
end

-- Format the timer based on user preferences
local function FormatTime(seconds)
    if seconds <= 0 then
        return "00:00"
    end
    
    local format = GetConfig("timerFormat") or "mm:ss"
    
    if format == "mm:ss" then
        local minutes = math_floor(seconds / 60)
        local secs = math_floor(seconds % 60)
        return string_format("%02d:%02d", minutes, secs)
    elseif format == "mmss" then
        local minutes = math_floor(seconds / 60)
        local secs = math_floor(seconds % 60)
        return string_format("%02d%02d", minutes, secs)
    else -- full
        local hours = math_floor(seconds / 3600)
        local minutes = math_floor((seconds % 3600) / 60)
        local secs = math_floor(seconds % 60)
        
        if hours > 0 then
            return string_format("%d:%02d:%02d", hours, minutes, secs)
        else
            return string_format("%d:%02d", minutes, secs)
        end
    end
end

-- Get chest tier description based on time
local function GetChestTierDescription(timeLeft, timeLimit)
    if timeLeft <= 0 then
        return "No Key Upgrade", "FFFFFF" -- White
    end
    
    local percentage = timeLeft / timeLimit
    
    if percentage >= 0.8 then
        return "3 Key Levels", "00FF00" -- Green
    elseif percentage >= 0.6 then
        return "2 Key Levels", "66FF66" -- Light Green
    elseif percentage >= 0.4 then
        return "1 Key Level", "FFFF00" -- Yellow
    else
        return "No Key Upgrade", "FF6666" -- Red
    end
end

-- Create pulsing animation for urgent timers
local function CreatePulsingAnimation(frame, speed, minAlpha, maxAlpha)
    -- Create animation group if it doesn't exist
    if not frame.pulseAnimation then
        local animGroup = frame:CreateAnimationGroup()
        animGroup:SetLooping("REPEAT")
        
        local fadeOut = animGroup:CreateAnimation("Alpha")
        fadeOut:SetFromAlpha(maxAlpha)
        fadeOut:SetToAlpha(minAlpha)
        fadeOut:SetDuration(speed)
        fadeOut:SetOrder(1)
        
        local fadeIn = animGroup:CreateAnimation("Alpha")
        fadeIn:SetFromAlpha(minAlpha)
        fadeIn:SetToAlpha(maxAlpha)
        fadeIn:SetDuration(speed)
        fadeIn:SetOrder(2)
        
        frame.pulseAnimation = animGroup
    end
    
    return frame.pulseAnimation
end

-- Enhance the chest timer display
function TimerEnhancement:EnhanceTimerDisplay(timerFrame)
    if not timerFrame then return end
    
    -- Apply theme if needed
    if GetConfig("useVUITheme") and AngryKeystones.ThemeIntegration then
        AngryKeystones.ThemeIntegration:ApplyThemeToTimerDisplay(timerFrame)
    end
    
    -- Get timer information
    local bar = timerFrame.TimerBar or timerFrame.Bar or timerFrame -- Different addons might use different names
    if not bar then return end
    
    local timeLeft = bar:GetValue()
    local _, timeLimit = bar:GetMinMaxValues()
    timeLimit = timeLimit or 1 -- Prevent division by zero
    
    -- Create or update the enhanced timer display
    if not timerFrame.EnhancedTimerFrame then
        -- Create new frame for enhanced timer
        timerFrame.EnhancedTimerFrame = CreateFrame("Frame", nil, timerFrame)
        timerFrame.EnhancedTimerFrame:SetPoint("TOPLEFT", timerFrame, "BOTTOMLEFT", 0, -5)
        timerFrame.EnhancedTimerFrame:SetPoint("TOPRIGHT", timerFrame, "BOTTOMRIGHT", 0, -5)
        timerFrame.EnhancedTimerFrame:SetHeight(65)
        
        -- Theme the frame
        if GetConfig("useVUITheme") and AngryKeystones.ThemeIntegration then
            AngryKeystones.ThemeIntegration:ApplyThemeToFrame(timerFrame.EnhancedTimerFrame)
        end
        
        -- Main time display
        timerFrame.EnhancedTimerFrame.TimeLeft = timerFrame.EnhancedTimerFrame:CreateFontString(nil, "OVERLAY")
        timerFrame.EnhancedTimerFrame.TimeLeft:SetPoint("TOP", timerFrame.EnhancedTimerFrame, "TOP", 0, -5)
        local font = VUI:GetFont("expressway")
        timerFrame.EnhancedTimerFrame.TimeLeft:SetFont(font, 18, "OUTLINE")
        
        -- Create chest tier indicators
        timerFrame.EnhancedTimerFrame.ChestTierText = timerFrame.EnhancedTimerFrame:CreateFontString(nil, "OVERLAY")
        timerFrame.EnhancedTimerFrame.ChestTierText:SetPoint("TOP", timerFrame.EnhancedTimerFrame.TimeLeft, "BOTTOM", 0, -5)
        timerFrame.EnhancedTimerFrame.ChestTierText:SetFont(font, 12, "OUTLINE")
        
        -- Key level upgrade indicator
        timerFrame.EnhancedTimerFrame.KeyUpgrade = timerFrame.EnhancedTimerFrame:CreateFontString(nil, "OVERLAY")
        timerFrame.EnhancedTimerFrame.KeyUpgrade:SetPoint("TOP", timerFrame.EnhancedTimerFrame.ChestTierText, "BOTTOM", 0, -5)
        timerFrame.EnhancedTimerFrame.KeyUpgrade:SetFont(font, 14, "OUTLINE")
        
        -- Create chest icons
        timerFrame.EnhancedTimerFrame.ChestIcons = {}
        for i = 1, 3 do
            local chest = timerFrame.EnhancedTimerFrame:CreateTexture(nil, "OVERLAY")
            chest:SetSize(20, 20)
            
            -- Set texture based on current theme
            local theme = VUI.db.profile.appearance.theme or "thunderstorm"
            local texturePath = "Interface\\AddOns\\VUI\\media\\textures\\" .. theme .. "\\angrykeystone\\ChestIcon"
            chest:SetTexture(texturePath)
            
            -- Position chests
            if i == 1 then
                chest:SetPoint("BOTTOMLEFT", timerFrame.EnhancedTimerFrame, "BOTTOMLEFT", 5, 5)
            else
                chest:SetPoint("LEFT", timerFrame.EnhancedTimerFrame.ChestIcons[i-1], "RIGHT", 5, 0)
            end
            
            timerFrame.EnhancedTimerFrame.ChestIcons[i] = chest
        end
        
        -- Add OnUpdate handler for smooth timer updates
        timerFrame.EnhancedTimerFrame:SetScript("OnUpdate", function(self, elapsed)
            self.updateThrottle = (self.updateThrottle or 0) + elapsed
            if self.updateThrottle < 0.1 then return end
            self.updateThrottle = 0
            
            -- Update the display
            TimerEnhancement:UpdateTimerDisplay(timerFrame)
        end)
        
        -- Apply text color
        if GetConfig("useVUITheme") and AngryKeystones.ThemeIntegration then
            local colors = AngryKeystones.ThemeIntegration:GetThemeColors()
            timerFrame.EnhancedTimerFrame.TimeLeft:SetTextColor(colors.text[1], colors.text[2], colors.text[3], 1)
            timerFrame.EnhancedTimerFrame.ChestTierText:SetTextColor(colors.text[1], colors.text[2], colors.text[3], 1)
        end
    end
    
    -- Initial update
    self:UpdateTimerDisplay(timerFrame)
    
    -- Show or hide based on settings
    if GetConfig("showChestTimer") then
        timerFrame.EnhancedTimerFrame:Show()
    else
        timerFrame.EnhancedTimerFrame:Hide()
    end
end

-- Update the timer display
function TimerEnhancement:UpdateTimerDisplay(timerFrame)
    if not timerFrame or not timerFrame.EnhancedTimerFrame then return end
    
    -- Get timer information
    local bar = timerFrame.TimerBar or timerFrame.Bar or timerFrame
    if not bar then return end
    
    local timeLeft = bar:GetValue()
    local _, timeLimit = bar:GetMinMaxValues()
    timeLimit = timeLimit or 1 -- Prevent division by zero
    
    -- Update timer color based on percentage
    local percentage = timeLeft / timeLimit
    
    -- Get the appropriate color based on the timer percentage
    if GetConfig("useVUITheme") and AngryKeystones.ThemeIntegration then
        local colors = AngryKeystones.ThemeIntegration:GetTimerColor(percentage)
        
        -- Apply color to bar
        bar:SetStatusBarColor(colors[1], colors[2], colors[3])
    else
        -- Default coloring
        if percentage >= TIMER_WARNING_THRESHOLD then
            bar:SetStatusBarColor(0, 1, 0) -- Green
        elseif percentage >= TIMER_DANGER_THRESHOLD then
            bar:SetStatusBarColor(1, 0.5, 0) -- Orange
        else
            bar:SetStatusBarColor(1, 0, 0) -- Red
        end
    end
    
    -- Update time text
    timerFrame.EnhancedTimerFrame.TimeLeft:SetText(FormatTime(timeLeft))
    
    -- Update chest tier text
    local chestTier, colorHex = GetChestTierDescription(timeLeft, timeLimit)
    timerFrame.EnhancedTimerFrame.ChestTierText:SetText("Tier: " .. chestTier)
    
    -- Update key upgrade text with color
    timerFrame.EnhancedTimerFrame.KeyUpgrade:SetText("|cFF" .. colorHex .. chestTier .. "|r")
    
    -- Update chest icons based on current tier
    for i = 1, 3 do
        local chest = timerFrame.EnhancedTimerFrame.ChestIcons[i]
        if not chest then break end
        
        -- Determine if this chest should be active
        local isActive = false
        if i == 1 and percentage >= 0.4 then
            isActive = true
        elseif i == 2 and percentage >= 0.6 then
            isActive = true
        elseif i == 3 and percentage >= 0.8 then
            isActive = true
        end
        
        -- Set alpha based on active state
        if isActive then
            chest:SetAlpha(1.0)
            
            -- Apply theme-specific color
            if GetConfig("useVUITheme") and AngryKeystones.ThemeIntegration then
                local colors = AngryKeystones.ThemeIntegration:GetThemeColors()
                chest:SetVertexColor(colors.highlight[1], colors.highlight[2], colors.highlight[3])
            else
                chest:SetVertexColor(1, 1, 1) -- White
            end
        else
            chest:SetAlpha(0.3)
            chest:SetVertexColor(0.5, 0.5, 0.5) -- Gray
        end
    end
    
    -- Add pulsing animation for low time
    if percentage < TIMER_DANGER_THRESHOLD then
        -- Create pulsing animation if it doesn't exist
        local pulseAnim = CreatePulsingAnimation(timerFrame.EnhancedTimerFrame.TimeLeft, 0.5, 0.5, 1.0)
        
        -- Start the animation if not playing
        if not pulseAnim:IsPlaying() then
            pulseAnim:Play()
        end
    else
        -- Stop animation if it's playing
        if timerFrame.EnhancedTimerFrame.TimeLeft.pulseAnimation and 
           timerFrame.EnhancedTimerFrame.TimeLeft.pulseAnimation:IsPlaying() then
            timerFrame.EnhancedTimerFrame.TimeLeft.pulseAnimation:Stop()
            timerFrame.EnhancedTimerFrame.TimeLeft:SetAlpha(1.0) -- Reset alpha
        end
    end
end

-- Hook the challenge mode UI to update our enhanced display
function TimerEnhancement:SetupHooks()
    -- Only set up once
    if self.hooked then return end
    
    -- Hook the Scenario_ChallengeMode_UpdateTime function
    if Scenario_ChallengeMode_UpdateTime then
        hooksecurefunc("Scenario_ChallengeMode_UpdateTime", function()
            if not AngryKeystones.enabled then return end
            
            -- Find the timer frame
            local timerFrame = ScenarioChallengeModeBlock
            if timerFrame then
                AngryKeystones.timerFrame = timerFrame
                self:EnhanceTimerDisplay(timerFrame)
            end
        end)
    end
    
    self.hooked = true
end

-- Play completion sound when dungeon is completed
function TimerEnhancement:PlayCompletionSound()
    if not AngryKeystones.enabled then return end
    
    local theme = GetConfig("useVUITheme") and VUI.db.profile.appearance.theme or GetConfig("customStyle")
    theme = theme or "thunderstorm"
    
    -- Play the appropriate completion sound
    local soundFile = "Interface\\AddOns\\VUI\\media\\sounds\\" .. theme .. "\\angrykeystone\\completion"
    
    -- In a real addon, you would play the sound like this:
    PlaySoundFile(soundFile, "Master")
end

-- Initialize the timer enhancement
function TimerEnhancement:Initialize()
    self:SetupHooks()
    
    -- Register for theme changes
    VUI:RegisterCallback("ThemeChanged", function()
        if AngryKeystones.enabled and AngryKeystones.timerFrame then
            self:EnhanceTimerDisplay(AngryKeystones.timerFrame)
        end
    end)
    
    -- Register for CHALLENGE_MODE_COMPLETED event
    VUI:RegisterEvent("CHALLENGE_MODE_COMPLETED", function()
        if AngryKeystones.enabled then
            self:PlayCompletionSound()
        end
    end)
    

end