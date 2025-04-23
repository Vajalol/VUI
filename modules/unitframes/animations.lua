-- VUI UnitFrames Module - Animation Utilities
local _, VUI = ...
local UnitFrames = VUI.unitframes

-- Animation settings
local ANIMATION_DURATION = 0.3 -- Default animation duration in seconds
local TRANSITION_DURATION = 0.4 -- Default transition duration in seconds
local SMOOTH_THRESHOLD = 0.08 -- Threshold for using smooth animations (as percentage of max value)
local UPDATE_THROTTLE = 0.05 -- Minimum time between animation updates in seconds

-- Animation tracker
UnitFrames.animatedFrames = {}

-- Create a smooth value transition
function UnitFrames:CreateSmoothValueTransition(frame, valueType)
    if not frame then return end
    
    -- Initialize transition data if needed
    if not frame.transitions then
        frame.transitions = {}
    end
    
    -- Set up transition object
    if not frame.transitions[valueType] then
        frame.transitions[valueType] = {
            current = 0,
            target = 0,
            lastUpdate = 0,
            inProgress = false,
            speed = 0
        }
    end
    
    return frame.transitions[valueType]
end

-- Create animations for a unit frame
function UnitFrames:InitializeFrameAnimations(frame)
    if not frame then return end
    
    -- Skip if already initialized
    if frame.animationsInitialized then return end
    
    -- Create animation group for the frame if it doesn't exist
    if not frame.animationGroup then
        frame.animationGroup = frame:CreateAnimationGroup()
        frame.animationGroup:SetLooping("NONE")
    end
    
    -- Create health bar value transitions
    if frame.HealthBar then
        self:CreateSmoothValueTransition(frame, "health")
        
        -- Add glow animation for health loss
        if not frame.HealthBar.glowAnimation then
            local glowTexture = frame.HealthBar:CreateTexture(nil, "OVERLAY")
            glowTexture:SetAllPoints()
            glowTexture:SetTexture("Interface\\Buttons\\WHITE8x8")
            glowTexture:SetVertexColor(1, 0, 0, 0)
            glowTexture:SetBlendMode("ADD")
            frame.HealthBar.glowTexture = glowTexture
            
            local animGroup = frame.HealthBar:CreateAnimationGroup()
            local fadeIn = animGroup:CreateAnimation("Alpha")
            fadeIn:SetFromAlpha(0)
            fadeIn:SetToAlpha(0.3)
            fadeIn:SetDuration(0.15)
            fadeIn:SetOrder(1)
            
            local fadeOut = animGroup:CreateAnimation("Alpha")
            fadeOut:SetFromAlpha(0.3)
            fadeOut:SetToAlpha(0)
            fadeOut:SetDuration(0.3)
            fadeOut:SetOrder(2)
            
            frame.HealthBar.glowAnimation = animGroup
        end
    end
    
    -- Create power bar value transitions
    if frame.PowerBar then
        self:CreateSmoothValueTransition(frame, "power")
        
        -- Add pulse animation for power gains
        if not frame.PowerBar.pulseAnimation then
            local pulseTexture = frame.PowerBar:CreateTexture(nil, "OVERLAY")
            pulseTexture:SetAllPoints()
            pulseTexture:SetTexture("Interface\\Buttons\\WHITE8x8")
            pulseTexture:SetVertexColor(1, 1, 0, 0)
            pulseTexture:SetBlendMode("ADD")
            frame.PowerBar.pulseTexture = pulseTexture
            
            local animGroup = frame.PowerBar:CreateAnimationGroup()
            local fadeIn = animGroup:CreateAnimation("Alpha")
            fadeIn:SetFromAlpha(0)
            fadeIn:SetToAlpha(0.2)
            fadeIn:SetDuration(0.15)
            fadeIn:SetOrder(1)
            
            local fadeOut = animGroup:CreateAnimation("Alpha")
            fadeOut:SetFromAlpha(0.2)
            fadeOut:SetToAlpha(0)
            fadeOut:SetDuration(0.25)
            fadeOut:SetOrder(2)
            
            frame.PowerBar.pulseAnimation = animGroup
        end
    end
    
    -- Combat state transition
    if not frame.combatStateAnimation then
        -- Border glow for combat state
        local borderGlow = frame:CreateTexture(nil, "OVERLAY")
        borderGlow:SetPoint("TOPLEFT", frame, "TOPLEFT", -3, 3)
        borderGlow:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 3, -3)
        borderGlow:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\unitframe_border_glow")
        borderGlow:SetBlendMode("ADD")
        borderGlow:SetVertexColor(1, 0.3, 0.3, 0)
        frame.borderGlow = borderGlow
        
        -- Animation group for combat state
        local animGroup = frame:CreateAnimationGroup()
        animGroup:SetLooping("REPEAT")
        
        local fadeIn = animGroup:CreateAnimation("Alpha")
        fadeIn:SetFromAlpha(0)
        fadeIn:SetToAlpha(0.7)
        fadeIn:SetDuration(0.8)
        fadeIn:SetSmoothing("IN_OUT")
        fadeIn:SetTarget(borderGlow)
        fadeIn:SetOrder(1)
        
        local fadeOut = animGroup:CreateAnimation("Alpha")
        fadeOut:SetFromAlpha(0.7)
        fadeOut:SetToAlpha(0)
        fadeOut:SetDuration(0.8)
        fadeOut:SetSmoothing("IN_OUT")
        fadeOut:SetTarget(borderGlow)
        fadeOut:SetOrder(2)
        
        frame.combatStateAnimation = animGroup
    end
    
    -- Add enter/exit animations if supported
    if frame.SetAlpha then
        -- Alpha transition for appearing/disappearing
        frame.originalAlpha = frame:GetAlpha()
        
        local fadeInGroup = frame:CreateAnimationGroup()
        local fadeIn = fadeInGroup:CreateAnimation("Alpha")
        fadeIn:SetFromAlpha(0)
        fadeIn:SetToAlpha(frame.originalAlpha)
        fadeIn:SetDuration(TRANSITION_DURATION)
        fadeIn:SetSmoothing("OUT")
        fadeInGroup:SetScript("OnFinished", function()
            frame:SetAlpha(frame.originalAlpha)
        end)
        frame.fadeInAnimation = fadeInGroup
        
        local fadeOutGroup = frame:CreateAnimationGroup()
        local fadeOut = fadeOutGroup:CreateAnimation("Alpha")
        fadeOut:SetFromAlpha(frame.originalAlpha)
        fadeOut:SetToAlpha(0)
        fadeOut:SetDuration(TRANSITION_DURATION)
        fadeOut:SetSmoothing("IN")
        fadeOutGroup:SetScript("OnFinished", function()
            if not frame.keepVisible then
                frame:Hide()
            end
        end)
        frame.fadeOutAnimation = fadeOutGroup
    end
    
    -- Mark as initialized
    frame.animationsInitialized = true
    
    -- Add to tracking
    self.animatedFrames[frame] = true
end

-- Update smooth value transitions
function UnitFrames:UpdateSmoothValue(frame, valueType, target, forceInstant)
    if not frame or not frame.transitions or not frame.transitions[valueType] then
        return target
    end
    
    local transition = frame.transitions[valueType]
    local now = GetTime()
    
    -- Initialize if this is the first update
    if not transition.inProgress then
        transition.current = target
        transition.target = target
        transition.inProgress = true
        return target
    end
    
    -- Update target value
    transition.target = target
    
    -- Force instant update if specified or target is close enough
    if forceInstant or math.abs(transition.current - target) / target < SMOOTH_THRESHOLD then
        transition.current = target
        transition.inProgress = false
        return target
    end
    
    -- Calculate time delta and throttle updates if needed
    local deltaTime = now - transition.lastUpdate
    if deltaTime < UPDATE_THROTTLE then
        return transition.current
    end
    
    -- Calculate smooth transition
    transition.lastUpdate = now
    local direction = target > transition.current and 1 or -1
    local change = math.abs(target - transition.current)
    
    -- Adjust speed based on difference
    transition.speed = math.max(change * 3, math.abs(transition.speed or 0))
    local step = direction * transition.speed * deltaTime
    
    -- Apply smoothing based on how close we are to the target
    local proximity = 1 - (math.abs(target - transition.current) / math.abs(target - transition.current + step))
    local dampening = math.min(proximity * 2, 0.8)
    step = step * (1 - dampening)
    
    transition.current = transition.current + step
    
    -- Check if we're at or passed the target
    if (direction > 0 and transition.current >= target) or
       (direction < 0 and transition.current <= target) then
        transition.current = target
        transition.inProgress = false
    end
    
    return transition.current
end

-- Apply frame animations when showing/hiding
function UnitFrames:AnimateFrameShow(frame)
    if not frame or not frame.animationsInitialized then return end
    
    if frame.fadeOutAnimation and frame.fadeOutAnimation:IsPlaying() then
        frame.fadeOutAnimation:Stop()
    end
    
    frame:Show()
    
    if frame.fadeInAnimation then
        frame.fadeInAnimation:Play()
    end
end

function UnitFrames:AnimateFrameHide(frame)
    if not frame or not frame.animationsInitialized then return end
    
    if frame.fadeInAnimation and frame.fadeInAnimation:IsPlaying() then
        frame.fadeInAnimation:Stop()
    end
    
    if frame.fadeOutAnimation then
        frame.fadeOutAnimation:Play()
    else
        frame:Hide()
    end
end

-- Toggle combat state animation
function UnitFrames:SetCombatState(frame, inCombat)
    if not frame or not frame.animationsInitialized then return end
    
    if inCombat then
        if frame.combatStateAnimation and not frame.combatStateAnimation:IsPlaying() then
            frame.combatStateAnimation:Play()
        end
    else
        if frame.combatStateAnimation and frame.combatStateAnimation:IsPlaying() then
            frame.combatStateAnimation:Stop()
            if frame.borderGlow then
                frame.borderGlow:SetAlpha(0)
            end
        end
    end
end

-- Show health change animation
function UnitFrames:AnimateHealthChange(frame, oldValue, newValue)
    if not frame or not frame.HealthBar or not frame.animationsInitialized then return end
    
    -- Only animate health loss
    if newValue < oldValue and newValue > 0 then
        -- Play the glow animation
        if frame.HealthBar.glowAnimation and not frame.HealthBar.glowAnimation:IsPlaying() then
            frame.HealthBar.glowAnimation:Play()
        end
    end
end

-- Show power change animation
function UnitFrames:AnimatePowerChange(frame, oldValue, newValue)
    if not frame or not frame.PowerBar or not frame.animationsInitialized then return end
    
    -- Only animate power gains
    if newValue > oldValue then
        -- Play the pulse animation
        if frame.PowerBar.pulseAnimation and not frame.PowerBar.pulseAnimation:IsPlaying() then
            frame.PowerBar.pulseAnimation:Play()
        end
    end
end

-- Health and power update throttling
local nextHealthUpdate = 0
local nextPowerUpdate = 0

function UnitFrames:ShouldUpdateHealth()
    local now = GetTime()
    if now > nextHealthUpdate then
        nextHealthUpdate = now + UPDATE_THROTTLE
        return true
    end
    return false
end

function UnitFrames:ShouldUpdatePower()
    local now = GetTime()
    if now > nextPowerUpdate then
        nextPowerUpdate = now + UPDATE_THROTTLE
        return true
    end
    return false
end

-- On Animation finished callbacks
function UnitFrames:OnAnimationFinished(animation, requested)
    -- Implement callback logic for specific types of animations
end