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

-- Get theme color for animations
function UnitFrames:GetThemeColor(colorType)
    -- Get theme from VUI
    local theme = VUI.db.profile.appearance.theme or "phoenix"
    local themeColors = {
        phoenix = {
            border = {r = 0.9, g = 0.3, b = 0.1}, -- Phoenix Flame's fiery orange
            glow = {r = 1.0, g = 0.5, b = 0.1},   -- Amber glow
            highlight = {r = 1.0, g = 0.6, b = 0.2} -- Amber highlight
        },
        thunder = {
            border = {r = 0.1, g = 0.5, b = 0.9}, -- Thunder Storm's electric blue
            glow = {r = 0.3, g = 0.7, b = 1.0},   -- Blue glow
            highlight = {r = 0.4, g = 0.6, b = 1.0} -- Blue highlight
        },
        arcane = {
            border = {r = 0.6, g = 0.2, b = 0.9}, -- Arcane Mystic's purple
            glow = {r = 0.8, g = 0.4, b = 1.0},   -- Purple glow
            highlight = {r = 0.7, g = 0.3, b = 1.0} -- Purple highlight
        },
        fel = {
            border = {r = 0.3, g = 0.9, b = 0.3}, -- Fel Energy's green
            glow = {r = 0.5, g = 1.0, b = 0.5},   -- Green glow
            highlight = {r = 0.4, g = 0.8, b = 0.4} -- Green highlight
        },
        default = {
            border = {r = 0.7, g = 0.7, b = 0.7}, -- Default gray
            glow = {r = 0.9, g = 0.9, b = 0.9},   -- White glow
            highlight = {r = 0.9, g = 0.9, b = 0.9} -- White highlight
        }
    }
    
    -- Get the color for this theme
    local themeData = themeColors[theme] or themeColors.default
    local color = themeData[colorType] or themeData.border
    
    -- Add combat red variation for border
    if colorType == "combat" then
        return 1.0, 0.3, 0.3 -- Combat is always reddish
    end
    
    return color.r, color.g, color.b
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
    
    -- Get theme colors
    local borderR, borderG, borderB = self:GetThemeColor("border")
    local glowR, glowG, glowB = self:GetThemeColor("glow")
    local highlightR, highlightG, highlightB = self:GetThemeColor("highlight")
    
    -- Create health bar value transitions
    if frame.HealthBar then
        self:CreateSmoothValueTransition(frame, "health")
        
        -- Add glow animation for health loss
        if not frame.HealthBar.glowAnimation then
            local glowTexture = frame.HealthBar:CreateTexture(nil, "OVERLAY")
            glowTexture:SetAllPoints()
            glowTexture:SetTexture("Interface\\Buttons\\WHITE8x8")
            glowTexture:SetVertexColor(1, 0, 0, 0) -- Red for damage
            glowTexture:SetBlendMode("ADD")
            frame.HealthBar.glowTexture = glowTexture
            
            local animGroup = frame.HealthBar:CreateAnimationGroup()
            
            -- Flash animation
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
            
            -- Add the animation to the frame
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
            pulseTexture:SetVertexColor(highlightR, highlightG, highlightB, 0) -- Theme-based power gain color
            pulseTexture:SetBlendMode("ADD")
            frame.PowerBar.pulseTexture = pulseTexture
            
            local animGroup = frame.PowerBar:CreateAnimationGroup()
            
            -- Animation sequence with theme-based color
            local fadeIn = animGroup:CreateAnimation("Alpha")
            fadeIn:SetFromAlpha(0)
            fadeIn:SetToAlpha(0.3)
            fadeIn:SetDuration(0.15)
            fadeIn:SetOrder(1)
            
            local fadeOut = animGroup:CreateAnimation("Alpha")
            fadeOut:SetFromAlpha(0.3)
            fadeOut:SetToAlpha(0)
            fadeOut:SetDuration(0.25)
            fadeOut:SetOrder(2)
            
            frame.PowerBar.pulseAnimation = animGroup
        end
    end
    
    -- Combat state transition with theme integration
    if not frame.combatStateAnimation then
        -- Border glow for combat state
        local borderGlow = frame:CreateTexture(nil, "OVERLAY")
        borderGlow:SetPoint("TOPLEFT", frame, "TOPLEFT", -3, 3)
        borderGlow:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 3, -3)
        
        -- Check for custom theme textures
        local glowTexture = "Interface\\AddOns\\VUI\\media\\textures\\unitframe_border_glow"
        local themeTexture = "Interface\\AddOns\\VUI\\media\\textures\\" .. 
                           (VUI.db.profile.appearance.theme or "phoenix") .. 
                           "_border_glow"
                           
        -- Attempt to use theme-specific texture, fall back to default
        local textureFile = glowTexture
        if themeTexture and VUI.media.CheckFileExists and VUI.media:CheckFileExists(themeTexture) then
            textureFile = themeTexture
        end
        
        borderGlow:SetTexture(textureFile)
        borderGlow:SetBlendMode("ADD")
        
        -- Get combat color (red)
        local combatR, combatG, combatB = self:GetThemeColor("combat")
        borderGlow:SetVertexColor(combatR, combatG, combatB, 0)
        frame.borderGlow = borderGlow
        
        -- Animation group for combat state
        local animGroup = frame:CreateAnimationGroup()
        animGroup:SetLooping("REPEAT")
        
        -- The animation sequence
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
    
    -- Add portrait animations if enabled
    if frame.Portrait and self.settings.showPortraits then
        -- Portrait frame animation
        if not frame.Portrait.animationGroup then
            local portraitAnimGroup = frame.Portrait:CreateAnimationGroup()
            
            -- Create a subtle breathing animation for portrait
            local portraitScale = portraitAnimGroup:CreateAnimation("Scale")
            portraitScale:SetScale(1.05, 1.05)  -- 5% larger
            portraitScale:SetOrigin("CENTER", 0, 0)
            portraitScale:SetDuration(2.5)
            portraitScale:SetSmoothing("IN_OUT")
            portraitScale:SetOrder(1)
            
            local portraitScaleBack = portraitAnimGroup:CreateAnimation("Scale")
            portraitScaleBack:SetScale(0.95238, 0.95238)  -- Back to normal (1/1.05)
            portraitScaleBack:SetOrigin("CENTER", 0, 0)
            portraitScaleBack:SetDuration(2.5)
            portraitScaleBack:SetSmoothing("IN_OUT")
            portraitScaleBack:SetOrder(2)
            
            -- Set looping
            portraitAnimGroup:SetLooping("REPEAT")
            frame.Portrait.animationGroup = portraitAnimGroup
            
            -- Start the animation if not in combat
            if not UnitAffectingCombat("player") then
                portraitAnimGroup:Play()
            end
            
            -- Create highlight glow for portraits
            local portraitHighlight = frame.Portrait:CreateTexture(nil, "OVERLAY")
            portraitHighlight:SetAllPoints()
            portraitHighlight:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\portrait_highlight")
            
            -- Get the theme highlight color
            local r, g, b = self:GetThemeColor("highlight")
            portraitHighlight:SetVertexColor(r, g, b, 0)
            portraitHighlight:SetBlendMode("ADD")
            frame.Portrait.highlight = portraitHighlight
            
            -- Create a separate animation group for the highlight
            local highlightGroup = frame.Portrait:CreateAnimationGroup()
            highlightGroup:SetLooping("NONE")
            
            local highlightFadeIn = highlightGroup:CreateAnimation("Alpha")
            highlightFadeIn:SetTarget(portraitHighlight)
            highlightFadeIn:SetFromAlpha(0)
            highlightFadeIn:SetToAlpha(0.7)
            highlightFadeIn:SetDuration(0.3)
            highlightFadeIn:SetOrder(1)
            
            local highlightHold = highlightGroup:CreateAnimation("Alpha")
            highlightHold:SetTarget(portraitHighlight)
            highlightHold:SetFromAlpha(0.7)
            highlightHold:SetToAlpha(0.7)
            highlightHold:SetDuration(0.2)
            highlightHold:SetOrder(2)
            
            local highlightFadeOut = highlightGroup:CreateAnimation("Alpha")
            highlightFadeOut:SetTarget(portraitHighlight)
            highlightFadeOut:SetFromAlpha(0.7)
            highlightFadeOut:SetToAlpha(0)
            highlightFadeOut:SetDuration(0.5)
            highlightFadeOut:SetOrder(3)
            
            frame.Portrait.highlightAnimation = highlightGroup
        end
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

-- Animate portraits
function UnitFrames:AnimatePortrait(frame, unit)
    if not frame or not frame.Portrait or not frame.animationsInitialized then return end
    if not self.settings.showPortraits then return end
    
    -- Play highlight animation when portrait changes
    if frame.Portrait.highlightAnimation and not frame.Portrait.highlightAnimation:IsPlaying() then
        frame.Portrait.highlightAnimation:Play()
    end
    
    -- Toggle breathing animation based on combat state
    if UnitAffectingCombat("player") then
        -- Stop subtle animations during combat to improve performance
        if frame.Portrait.animationGroup and frame.Portrait.animationGroup:IsPlaying() then
            frame.Portrait.animationGroup:Stop()
        end
    else
        -- Start the breathing animation when not in combat
        if frame.Portrait.animationGroup and not frame.Portrait.animationGroup:IsPlaying() then
            frame.Portrait.animationGroup:Play()
        end
    end
end

-- Update portrait animations when combat state changes
function UnitFrames:UpdatePortraitAnimations(inCombat)
    if not self.settings.showPortraits then return end
    
    -- Process each frame with a portrait
    for frame in pairs(self.animatedFrames or {}) do
        if frame.Portrait and frame.Portrait.animationGroup then
            if inCombat then
                -- Stop portrait animations in combat
                if frame.Portrait.animationGroup:IsPlaying() then
                    frame.Portrait.animationGroup:Stop()
                end
            else
                -- Start portrait animations when leaving combat
                if not frame.Portrait.animationGroup:IsPlaying() then
                    frame.Portrait.animationGroup:Play()
                end
            end
        end
    end
end

-- Text scaling animation for important info
function UnitFrames:AnimateText(fontString, startScale, endScale, duration, holdTime)
    if not fontString then return end
    
    -- Create animation group if needed
    if not fontString.scaleAnimGroup then
        fontString.scaleAnimGroup = fontString:GetParent():CreateAnimationGroup()
        fontString.scaleAnimGroup:SetLooping("NONE")
        
        -- Create a scale animation
        local scaleUp = fontString.scaleAnimGroup:CreateAnimation("Scale")
        scaleUp:SetScaleFrom(1, 1)
        scaleUp:SetScaleTo(1.2, 1.2)  -- 20% larger 
        scaleUp:SetDuration(0.2)
        scaleUp:SetSmoothing("OUT")
        scaleUp:SetOrder(1)
        
        -- Hold at larger size briefly
        local holdScale = fontString.scaleAnimGroup:CreateAnimation("Scale")
        holdScale:SetScaleFrom(1.2, 1.2)
        holdScale:SetScaleTo(1.2, 1.2)
        holdScale:SetDuration(0.3)
        holdScale:SetOrder(2)
        
        -- Scale back down
        local scaleDown = fontString.scaleAnimGroup:CreateAnimation("Scale")
        scaleDown:SetScaleFrom(1.2, 1.2)
        scaleDown:SetScaleTo(1, 1)
        scaleDown:SetDuration(0.2)
        scaleDown:SetSmoothing("IN")
        scaleDown:SetOrder(3)
        
        -- Update parameters based on input
        fontString.scaleAnimations = {
            scaleUp = scaleUp,
            holdScale = holdScale,
            scaleDown = scaleDown
        }
    end
    
    -- Update animation parameters if provided
    if startScale and endScale and duration then
        if fontString.scaleAnimations then
            fontString.scaleAnimations.scaleUp:SetScaleFrom(startScale, startScale)
            fontString.scaleAnimations.scaleUp:SetScaleTo(endScale, endScale)
            fontString.scaleAnimations.scaleUp:SetDuration(duration / 3)
            
            fontString.scaleAnimations.holdScale:SetScaleFrom(endScale, endScale)
            fontString.scaleAnimations.holdScale:SetScaleTo(endScale, endScale)
            fontString.scaleAnimations.holdScale:SetDuration(holdTime or (duration / 3))
            
            fontString.scaleAnimations.scaleDown:SetScaleFrom(endScale, endScale)
            fontString.scaleAnimations.scaleDown:SetScaleTo(startScale, startScale)
            fontString.scaleAnimations.scaleDown:SetDuration(duration / 3)
        end
    end
    
    -- Play the animation if it's not already playing
    if fontString.scaleAnimGroup and not fontString.scaleAnimGroup:IsPlaying() then
        fontString.scaleAnimGroup:Play()
    end
end

-- On Animation finished callbacks
function UnitFrames:OnAnimationFinished(animation, requested)
    -- Implement callback logic for specific types of animations
end