-------------------------------------------------------------------------------
-- Title: AngryKeystones Enhanced Timers
-- Author: VortexQ8
-- Enhanced timer displays for Mythic+ dungeons
-------------------------------------------------------------------------------

local _, VUI = ...
local AK = VUI.modules.angrykeystones

-- Skip if AngryKeystones module is not available
if not AK then return end

-- Create the enhanced timers namespace
AK.EnhancedTimers = {}
local EnhancedTimers = AK.EnhancedTimers

-- Default settings
local defaults = {
    showMilliseconds = true,
    gradientColors = true,
    pulseOnLow = true,
    countdownStyle = "clock", -- "clock" or "timer"
    showTicks = true,
    tickInterval = 5, -- Minutes
    animateBackground = true,
    barWidth = 200,
    timerFontSize = 24,
    labelFontSize = 12,
    keyDetailsFontSize = 10,
}

-- Initialize enhanced timers
function EnhancedTimers:Initialize()
    self.keystoneInfo = nil
    self.startTime = nil
    self.isEnabled = AK.db.profile.enhancedTimers
    self.frames = {}
    
    -- Register events
    if self.isEnabled then
        self:RegisterEvents()
    end
end

-- Register necessary events
function EnhancedTimers:RegisterEvents()
    -- Hook into timer creation
    if AK.ChallengesModule and AK.ChallengesModule.CreateTimer then
        AK:RawHook(AK.ChallengesModule, "CreateTimer", function(...)
            local timerFrame = AK.hooks[AK.ChallengesModule].CreateTimer(...)
            
            if self.isEnabled then
                self:EnhanceTimerFrame(timerFrame)
            end
            
            return timerFrame
        end, true)
    end
    
    -- Hook into timer updates
    if AK.ChallengesModule and AK.ChallengesModule.UpdateTime then
        AK:SecureHook(AK.ChallengesModule, "UpdateTime", function(_, elapsedTime)
            if self.isEnabled then
                self:UpdateTimers(elapsedTime)
            end
        end)
    end
    
    -- Register for challenge mode start
    AK:RegisterEvent("CHALLENGE_MODE_START", function()
        if self.isEnabled then
            self:OnChallengeStart()
        end
    end)
    
    -- Register for challenge mode reset
    AK:RegisterEvent("CHALLENGE_MODE_RESET", function()
        if self.isEnabled then
            self:OnChallengeReset()
        end
    end)
    
    -- Register for challenge mode completed
    AK:RegisterEvent("CHALLENGE_MODE_COMPLETED", function()
        if self.isEnabled then
            self:OnChallengeComplete()
        end
    end)
    
    -- Enhance existing timer frames
    if AK.challengesFrames then
        for _, frame in ipairs(AK.challengesFrames) do
            self:EnhanceTimerFrame(frame)
        end
    end
end

-- Handle challenge start
function EnhancedTimers:OnChallengeStart()
    -- Get current keystone information
    local mapID = C_ChallengeMode.GetActiveChallengeMapID()
    if not mapID then return end
    
    local mapName = C_ChallengeMode.GetMapUIInfo(mapID)
    local level, affixes, energized = C_ChallengeMode.GetActiveKeystoneInfo()
    
    -- Store keystone info
    self.keystoneInfo = {
        mapID = mapID,
        mapName = mapName,
        level = level,
        affixes = affixes,
        energized = energized,
    }
    
    -- Store start time
    self.startTime = GetTime()
    
    -- Update all timer frames
    for _, frame in pairs(self.frames) do
        self:UpdateTimerDisplay(frame)
    end
end

-- Handle challenge reset
function EnhancedTimers:OnChallengeReset()
    -- Reset keystone info
    self.keystoneInfo = nil
    self.startTime = nil
    
    -- Update all timer frames
    for _, frame in pairs(self.frames) do
        self:ResetTimerDisplay(frame)
    end
end

-- Handle challenge complete
function EnhancedTimers:OnChallengeComplete()
    -- Update all timer frames to show completion
    for _, frame in pairs(self.frames) do
        self:ShowCompletionDisplay(frame)
    end
    
    -- Reset keystone info after a delay
    C_Timer.After(5, function()
        self.keystoneInfo = nil
        self.startTime = nil
    end)
end

-- Enhance a timer frame with additional features
function EnhancedTimers:EnhanceTimerFrame(frame)
    if not frame then return end
    
    -- Store frame reference
    table.insert(self.frames, frame)
    
    -- Set bar width
    if frame.TimerBar then
        frame.TimerBar:SetWidth(defaults.barWidth)
    end
    
    -- Add milliseconds display if not already present
    if defaults.showMilliseconds and not frame.MillisecondsText then
        frame.MillisecondsText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        frame.MillisecondsText:SetPoint("LEFT", frame.TimeText, "RIGHT", 1, 0)
        frame.MillisecondsText:SetFont(frame.TimeText:GetFont())
        frame.MillisecondsText:SetTextColor(1, 1, 1)
        frame.MillisecondsText:SetText(".000")
        frame.MillisecondsText:SetAlpha(0.7)
    end
    
    -- Add tick marks for timer intervals
    if defaults.showTicks and not frame.TickMarks then
        frame.TickMarks = {}
        
        if frame.TimerBar then
            local intervalInSeconds = defaults.tickInterval * 60
            local _, maxTime = frame.TimerBar:GetMinMaxValues()
            
            if maxTime then
                local numTicks = floor(maxTime / intervalInSeconds)
                local barWidth = frame.TimerBar:GetWidth()
                
                for i = 1, numTicks do
                    local tickTime = intervalInSeconds * i
                    local tickPos = tickTime / maxTime * barWidth
                    
                    local tick = frame:CreateTexture(nil, "OVERLAY")
                    tick.time = tickTime
                    tick:SetSize(2, frame.TimerBar:GetHeight() + 2)
                    tick:SetColorTexture(1, 1, 1, 0.4)
                    tick:SetPoint("LEFT", frame.TimerBar, "LEFT", tickPos, 0)
                    
                    -- Add tick label
                    local tickLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                    tickLabel:SetPoint("BOTTOM", tick, "TOP", 0, 1)
                    tickLabel:SetFont(AK.ThemeIntegration:GetFont(), defaults.keyDetailsFontSize)
                    tickLabel:SetTextColor(0.8, 0.8, 0.8)
                    tickLabel:SetText(string.format("%d:00", defaults.tickInterval * i))
                    
                    tick.label = tickLabel
                    table.insert(frame.TickMarks, tick)
                end
            end
        end
    end
    
    -- Add animated background if enabled
    if defaults.animateBackground and not frame.AnimatedBg then
        local LSM = LibStub("LibSharedMedia-3.0")
        local currentTheme = VUI.db.profile.appearance.theme or "thunderstorm"
        
        -- Create animated texture container
        frame.AnimatedBg = CreateFrame("Frame", nil, frame)
        frame.AnimatedBg:SetAllPoints(frame.TimerBar)
        frame.AnimatedBg:SetFrameLevel(frame.TimerBar:GetFrameLevel() - 1)
        
        -- Create animated textures based on theme
        local textures = {}
        
        if currentTheme == "phoenixflame" then
            -- Create fire effect
            local fire = frame.AnimatedBg:CreateTexture(nil, "BACKGROUND")
            fire:SetAllPoints()
            fire:SetColorTexture(1, 0.5, 0, 0.1)
            fire:SetBlendMode("ADD")
            
            -- Animate fire glow
            fire.ag = fire:CreateAnimationGroup()
            fire.ag:SetLooping("REPEAT")
            
            local alpha1 = fire.ag:CreateAnimation("Alpha")
            alpha1:SetFromAlpha(0.05)
            alpha1:SetToAlpha(0.2)
            alpha1:SetDuration(1.5)
            alpha1:SetOrder(1)
            
            local alpha2 = fire.ag:CreateAnimation("Alpha")
            alpha2:SetFromAlpha(0.2)
            alpha2:SetToAlpha(0.05)
            alpha2:SetDuration(1.5)
            alpha2:SetOrder(2)
            
            fire.ag:Play()
            table.insert(textures, fire)
            
        elseif currentTheme == "thunderstorm" then
            -- Create lightning effect
            local lightning = frame.AnimatedBg:CreateTexture(nil, "BACKGROUND")
            lightning:SetAllPoints()
            lightning:SetColorTexture(0.3, 0.6, 1, 0)
            lightning:SetBlendMode("ADD")
            
            -- Animate lightning flash
            lightning.ag = lightning:CreateAnimationGroup()
            lightning.ag:SetLooping("REPEAT")
            
            local flash1 = lightning.ag:CreateAnimation("Alpha")
            flash1:SetFromAlpha(0)
            flash1:SetToAlpha(0.3)
            flash1:SetDuration(0.1)
            flash1:SetOrder(1)
            
            local flash2 = lightning.ag:CreateAnimation("Alpha")
            flash2:SetFromAlpha(0.3)
            flash2:SetToAlpha(0)
            flash2:SetDuration(0.1)
            flash2:SetOrder(2)
            
            local wait = lightning.ag:CreateAnimation("Alpha")
            wait:SetFromAlpha(0)
            wait:SetToAlpha(0)
            wait:SetDuration(math.random(3, 8))
            wait:SetOrder(3)
            
            lightning.ag:Play()
            table.insert(textures, lightning)
            
        elseif currentTheme == "arcanemystic" then
            -- Create arcane pulse effect
            local arcane = frame.AnimatedBg:CreateTexture(nil, "BACKGROUND")
            arcane:SetAllPoints()
            arcane:SetColorTexture(0.8, 0.4, 1, 0.1)
            arcane:SetBlendMode("ADD")
            
            -- Animate arcane pulse
            arcane.ag = arcane:CreateAnimationGroup()
            arcane.ag:SetLooping("REPEAT")
            
            local alpha1 = arcane.ag:CreateAnimation("Alpha")
            alpha1:SetFromAlpha(0.05)
            alpha1:SetToAlpha(0.15)
            alpha1:SetDuration(2)
            alpha1:SetOrder(1)
            
            local alpha2 = arcane.ag:CreateAnimation("Alpha")
            alpha2:SetFromAlpha(0.15)
            alpha2:SetToAlpha(0.05)
            alpha2:SetDuration(2)
            alpha2:SetOrder(2)
            
            arcane.ag:Play()
            table.insert(textures, arcane)
            
        elseif currentTheme == "felenergy" then
            -- Create fel pulse effect
            local fel = frame.AnimatedBg:CreateTexture(nil, "BACKGROUND")
            fel:SetAllPoints()
            fel:SetColorTexture(0.4, 1, 0.4, 0.1)
            fel:SetBlendMode("ADD")
            
            -- Animate fel pulse
            fel.ag = fel:CreateAnimationGroup()
            fel.ag:SetLooping("REPEAT")
            
            local alpha1 = fel.ag:CreateAnimation("Alpha")
            alpha1:SetFromAlpha(0.05)
            alpha1:SetToAlpha(0.15)
            alpha1:SetDuration(3)
            alpha1:SetOrder(1)
            
            local alpha2 = fel.ag:CreateAnimation("Alpha")
            alpha2:SetFromAlpha(0.15)
            alpha2:SetToAlpha(0.05)
            alpha2:SetDuration(3)
            alpha2:SetOrder(2)
            
            fel.ag:Play()
            table.insert(textures, fel)
        end
        
        frame.AnimatedBg.textures = textures
    end
    
    -- Add keystone details if not already present
    if not frame.KeystoneDetails and self.keystoneInfo then
        frame.KeystoneDetails = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        frame.KeystoneDetails:SetPoint("BOTTOMLEFT", frame.KeystoneText, "BOTTOMLEFT", 0, -14)
        frame.KeystoneDetails:SetFont(AK.ThemeIntegration:GetFont(), defaults.keyDetailsFontSize)
        frame.KeystoneDetails:SetTextColor(0.8, 0.8, 0.8)
        
        -- Format affix list
        local affixInfo = ""
        if self.keystoneInfo.affixes then
            for i, affixID in ipairs(self.keystoneInfo.affixes) do
                local name = C_ChallengeMode.GetAffixInfo(affixID)
                if name then
                    if i > 1 then
                        affixInfo = affixInfo .. ", "
                    end
                    affixInfo = affixInfo .. name
                end
            end
        end
        
        frame.KeystoneDetails:SetText(affixInfo)
    end
    
    -- Apply initial settings
    self:UpdateTimerDisplay(frame)
end

-- Update timers with elapsed time
function EnhancedTimers:UpdateTimers(elapsedTime)
    for _, frame in pairs(self.frames) do
        -- Get time remaining from the timer bar
        local timeRemaining = nil
        if frame.TimerBar then
            -- Get time remaining from the timer bar
            local value = frame.TimerBar:GetValue()
            local _, maxValue = frame.TimerBar:GetMinMaxValues()
            timeRemaining = maxValue - value
        end
        
        self:UpdateTimerDisplay(frame, elapsedTime, timeRemaining)
    end
end

-- Update timer display with enhanced features
function EnhancedTimers:UpdateTimerDisplay(frame, elapsedTime, timeRemaining)
    if not frame then return end
    
    -- Update main time text with optional milliseconds
    if frame.TimeText and defaults.showMilliseconds and elapsedTime then
        -- Extract whole seconds and milliseconds
        local wholeSeconds = math.floor(elapsedTime)
        local milliseconds = math.floor((elapsedTime - wholeSeconds) * 1000)
        
        -- Format whole seconds based on countdown style
        local timeText = ""
        
        if defaults.countdownStyle == "clock" then
            -- Format as HH:MM:SS
            local hours = math.floor(wholeSeconds / 3600)
            local minutes = math.floor((wholeSeconds % 3600) / 60)
            local seconds = wholeSeconds % 60
            
            if hours > 0 then
                timeText = string.format("%d:%02d:%02d", hours, minutes, seconds)
            else
                timeText = string.format("%d:%02d", minutes, seconds)
            end
        else
            -- Format as total seconds
            timeText = tostring(wholeSeconds)
        end
        
        -- Set main time text
        frame.TimeText:SetText(timeText)
        
        -- Update milliseconds display
        if frame.MillisecondsText then
            frame.MillisecondsText:SetText(string.format(".%03d", milliseconds))
        end
    end
    
    -- Update coloring based on gradient if enabled
    if defaults.gradientColors and frame.TimerBar and timeRemaining then
        -- Get total time from min/max values
        local _, totalTime = frame.TimerBar:GetMinMaxValues()
        
        -- Calculate percentage of time remaining
        local percentRemaining = timeRemaining / totalTime
        
        -- Get color based on percentage
        if AK.ThemeIntegration and percentRemaining then
            local r, g, b = AK.ThemeIntegration:GetTimerColor(percentRemaining)
            
            -- Apply color to timer bar
            frame.TimerBar:SetStatusBarColor(r, g, b)
            
            -- Apply color to time text
            frame.TimeText:SetTextColor(r, g, b)
            
            -- Apply color to milliseconds text
            if frame.MillisecondsText then
                frame.MillisecondsText:SetTextColor(r, g, b)
            end
            
            -- Apply pulse animation when time is running low
            if defaults.pulseOnLow and percentRemaining < 0.2 and not frame.isPulsing then
                frame.isPulsing = true
                
                -- Create pulse animation if it doesn't exist
                if not frame.pulseAnim then
                    frame.pulseAnim = frame:CreateAnimationGroup()
                    frame.pulseAnim:SetLooping("REPEAT")
                    
                    local grow = frame.pulseAnim:CreateAnimation("Scale")
                    grow:SetOrder(1)
                    grow:SetDuration(0.4)
                    grow:SetFromScale(1, 1)
                    grow:SetToScale(1.05, 1.05)
                    
                    local shrink = frame.pulseAnim:CreateAnimation("Scale")
                    shrink:SetOrder(2)
                    shrink:SetDuration(0.4)
                    shrink:SetFromScale(1.05, 1.05)
                    shrink:SetToScale(1, 1)
                end
                
                frame.pulseAnim:Play()
            elseif percentRemaining >= 0.2 and frame.isPulsing then
                frame.isPulsing = false
                if frame.pulseAnim then
                    frame.pulseAnim:Stop()
                end
                frame:SetScale(1)
            end
        end
    end
    
    -- Update tick visibility based on elapsed time
    if frame.TickMarks and elapsedTime then
        for _, tick in ipairs(frame.TickMarks) do
            -- Show tick if we haven't passed it yet
            if tick.time > elapsedTime then
                tick:Show()
                if tick.label then tick.label:Show() end
            else
                tick:Hide()
                if tick.label then tick.label:Hide() end
            end
        end
    end
end

-- Reset timer display
function EnhancedTimers:ResetTimerDisplay(frame)
    if not frame then return end
    
    -- Reset time text
    if frame.TimeText then
        frame.TimeText:SetText("0:00")
        frame.TimeText:SetTextColor(1, 1, 1)
    end
    
    -- Reset milliseconds
    if frame.MillisecondsText then
        frame.MillisecondsText:SetText(".000")
        frame.MillisecondsText:SetTextColor(1, 1, 1)
    end
    
    -- Reset timer bar
    if frame.TimerBar then
        frame.TimerBar:SetValue(0)
        frame.TimerBar:SetStatusBarColor(0.7, 0.7, 0.7)
    end
    
    -- Show all ticks
    if frame.TickMarks then
        for _, tick in ipairs(frame.TickMarks) do
            tick:Show()
            if tick.label then tick.label:Show() end
        end
    end
    
    -- Stop pulsing
    if frame.isPulsing and frame.pulseAnim then
        frame.isPulsing = false
        frame.pulseAnim:Stop()
        frame:SetScale(1)
    end
    
    -- Hide keystone details
    if frame.KeystoneDetails then
        frame.KeystoneDetails:SetText("")
    end
end

-- Show completion display
function EnhancedTimers:ShowCompletionDisplay(frame)
    if not frame then return end
    
    -- Set time text color to indicate completion
    if frame.TimeText then
        frame.TimeText:SetTextColor(0, 1, 0)
    end
    
    -- Set milliseconds color
    if frame.MillisecondsText then
        frame.MillisecondsText:SetTextColor(0, 1, 0)
    end
    
    -- Set timer bar color
    if frame.TimerBar then
        frame.TimerBar:SetStatusBarColor(0, 1, 0)
    end
    
    -- Stop pulsing
    if frame.isPulsing and frame.pulseAnim then
        frame.isPulsing = false
        frame.pulseAnim:Stop()
        frame:SetScale(1)
    end
    
    -- Update keystone details to show completion
    if frame.KeystoneDetails then
        frame.KeystoneDetails:SetText("Completed!")
        frame.KeystoneDetails:SetTextColor(0, 1, 0)
    end
end

-- Enable enhanced timers
function EnhancedTimers:Enable()
    self.isEnabled = true
    self:RegisterEvents()
end

-- Disable enhanced timers
function EnhancedTimers:Disable()
    self.isEnabled = false
    
    -- Reset frames to default state
    for _, frame in pairs(self.frames) do
        self:ResetTimerDisplay(frame)
    end
end