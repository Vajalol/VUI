--[[
    VUI - MultiNotification Animation Variations
    Version: 1.0.0
    Author: VortexQ8
    
    This file implements enhanced animation variations for the MultiNotification module:
    - Multiple animation styles (fade, slide, bounce, scale, etc.)
    - Animation sequence customization
    - Category-specific animation preferences
    - Performance-aware animation intensity
    - Attention-grabbing animations for critical notifications
]]

local addonName, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end

if not VUI.modules.multinotification then return end

-- Namespaces
local MultiNotification = VUI.modules.multinotification
MultiNotification.AnimationVariations = {}

-- Import frequently used globals into locals for performance
local CreateFrame = CreateFrame
local GetTime = GetTime
local min, max = math.min, math.max
local sin, cos, pi = math.sin, math.cos, math.pi
local format = string.format

-- Animation variation defaults
local animationDefaults = {
    enabled = true,
    style = "fade", -- fade, slide, scale, bounce, pulse, spin, flip, glide
    intensity = 2,  -- 1 = subtle, 2 = normal, 3 = intense
    duration = {
        fadeIn = 0.3,
        display = 3.0,
        fadeOut = 0.5
    },
    performance = {
        reduceInCombat = true,
        disableInRaid = false,
        disableOnLowFPS = true,
        lowFPSThreshold = 20,
        adaptiveDuration = true
    },
    categorySettings = {
        interrupt = {
            style = "bounce",
            intensity = 3
        },
        dispel = {
            style = "pulse",
            intensity = 2
        },
        important = {
            style = "scale",
            intensity = 3
        },
        spell_notification = {
            style = "slide",
            intensity = 2
        },
        buff = {
            style = "fade",
            intensity = 1
        },
        debuff = {
            style = "fade",
            intensity = 2
        },
        system = {
            style = "fade",
            intensity = 1
        }
    }
}

-- Animation timing adjustments by style and intensity
local animationTimingAdjustments = {
    fade = {
        [1] = {fadeIn = 0.5, display = 1.0, fadeOut = 0.5},
        [2] = {fadeIn = 0.3, display = 1.0, fadeOut = 0.3},
        [3] = {fadeIn = 0.15, display = 1.0, fadeOut = 0.15}
    },
    slide = {
        [1] = {fadeIn = 0.4, display = 1.0, fadeOut = 0.4},
        [2] = {fadeIn = 0.3, display = 1.0, fadeOut = 0.3},
        [3] = {fadeIn = 0.2, display = 1.0, fadeOut = 0.2}
    },
    scale = {
        [1] = {fadeIn = 0.4, display = 1.0, fadeOut = 0.4},
        [2] = {fadeIn = 0.3, display = 1.0, fadeOut = 0.3},
        [3] = {fadeIn = 0.2, display = 1.0, fadeOut = 0.2}
    },
    bounce = {
        [1] = {fadeIn = 0.5, display = 1.0, fadeOut = 0.4},
        [2] = {fadeIn = 0.4, display = 1.0, fadeOut = 0.3},
        [3] = {fadeIn = 0.3, display = 1.0, fadeOut = 0.2}
    },
    pulse = {
        [1] = {fadeIn = 0.3, display = 1.0, fadeOut = 0.3},
        [2] = {fadeIn = 0.2, display = 1.0, fadeOut = 0.2},
        [3] = {fadeIn = 0.1, display = 1.0, fadeOut = 0.1}
    },
    spin = {
        [1] = {fadeIn = 0.5, display = 1.0, fadeOut = 0.5},
        [2] = {fadeIn = 0.4, display = 1.0, fadeOut = 0.4},
        [3] = {fadeIn = 0.3, display = 1.0, fadeOut = 0.3}
    },
    flip = {
        [1] = {fadeIn = 0.6, display = 1.0, fadeOut = 0.5},
        [2] = {fadeIn = 0.5, display = 1.0, fadeOut = 0.4},
        [3] = {fadeIn = 0.4, display = 1.0, fadeOut = 0.3}
    },
    glide = {
        [1] = {fadeIn = 0.5, display = 1.0, fadeOut = 0.4},
        [2] = {fadeIn = 0.4, display = 1.0, fadeOut = 0.3},
        [3] = {fadeIn = 0.3, display = 1.0, fadeOut = 0.2}
    }
}

-- Keep track of animation performance
local performanceMetrics = {
    lastCheck = GetTime(),
    frameCount = 0,
    currentFPS = 60,
    inCombat = false,
    inRaid = false,
    adaptiveLevel = 2 -- 1 = low, 2 = normal, 3 = high
}

-- Initialize the animation variations
function MultiNotification:InitializeAnimationVariations()
    -- Register defaults if not already registered
    if not self.db.profile.animations then
        self.db.profile.animations = animationDefaults
    else
        -- Update any missing fields (for version compatibility)
        for k, v in pairs(animationDefaults) do
            if self.db.profile.animations[k] == nil then
                self.db.profile.animations[k] = v
            end
            
            -- If it's a table, update any missing nested fields
            if type(v) == "table" and type(self.db.profile.animations[k]) == "table" then
                for nestedKey, nestedValue in pairs(v) do
                    if self.db.profile.animations[k][nestedKey] == nil then
                        self.db.profile.animations[k][nestedKey] = nestedValue
                    end
                    
                    -- If the nested value is also a table, update its fields too
                    if type(nestedValue) == "table" and type(self.db.profile.animations[k][nestedKey]) == "table" then
                        for deepKey, deepValue in pairs(nestedValue) do
                            if self.db.profile.animations[k][nestedKey][deepKey] == nil then
                                self.db.profile.animations[k][nestedKey][deepKey] = deepValue
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Register for events to update performance metrics
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "UpdateAnimationPerformanceState")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdateAnimationPerformanceState")
    self:RegisterEvent("GROUP_ROSTER_UPDATE", "UpdateAnimationPerformanceState")
    
    -- Set up a frame to track FPS for performance adaptation
    self.fpsTracker = CreateFrame("Frame")
    self.fpsTracker:SetScript("OnUpdate", function(_, elapsed)
        -- Update FPS tracking
        performanceMetrics.frameCount = performanceMetrics.frameCount + 1
        local currentTime = GetTime()
        local timePassed = currentTime - performanceMetrics.lastCheck
        
        if timePassed >= 1 then -- Update every second
            performanceMetrics.currentFPS = performanceMetrics.frameCount / timePassed
            performanceMetrics.frameCount = 0
            performanceMetrics.lastCheck = currentTime
            
            -- Update adaptive level based on FPS
            if self.db.profile.animations.performance.disableOnLowFPS then
                local fpsThreshold = self.db.profile.animations.performance.lowFPSThreshold
                
                if performanceMetrics.currentFPS < fpsThreshold then
                    performanceMetrics.adaptiveLevel = 1 -- Low
                elseif performanceMetrics.currentFPS < fpsThreshold * 2 then
                    performanceMetrics.adaptiveLevel = 2 -- Normal
                else
                    performanceMetrics.adaptiveLevel = 3 -- High
                end
            end
        end
    end)
    
    -- Force an initial update of the performance state
    self:UpdateAnimationPerformanceState()
    
    -- Register options for the configuration UI
    self:RegisterAnimationOptions()
    
    -- Log initialization

end

-- Update the animation performance state based on combat, group, etc.
function MultiNotification:UpdateAnimationPerformanceState()
    performanceMetrics.inCombat = UnitAffectingCombat("player")
    
    -- Check if player is in a raid
    local _, instanceType = IsInInstance()
    local numGroupMembers = GetNumGroupMembers()
    performanceMetrics.inRaid = (instanceType == "raid") or (not IsInRaid() and numGroupMembers > 5)
end

-- Apply the animation style to a notification frame
function MultiNotification:ApplyAnimationStyle(frame, animStyle, intensity, category, duration)
    if not frame or not self.db.profile.animations.enabled then return end
    
    -- Determine animation style and intensity to use
    local style = animStyle or self.db.profile.animations.style
    local animIntensity = intensity or self.db.profile.animations.intensity
    
    -- Apply category-specific settings if available
    if category and self.db.profile.animations.categorySettings[category] then
        style = self.db.profile.animations.categorySettings[category].style or style
        animIntensity = self.db.profile.animations.categorySettings[category].intensity or animIntensity
    end
    
    -- Apply performance adaptations
    if self.db.profile.animations.performance.reduceInCombat and performanceMetrics.inCombat then
        animIntensity = math.max(1, animIntensity - 1)
    end
    
    if self.db.profile.animations.performance.disableInRaid and performanceMetrics.inRaid then
        style = "fade" -- Default to simple fade in raids
        animIntensity = 1
    end
    
    if self.db.profile.animations.performance.adaptiveDuration then
        animIntensity = math.min(animIntensity, performanceMetrics.adaptiveLevel)
    end
    
    -- Set animation durations
    local durationSettings = duration or {
        fadeIn = self.db.profile.animations.duration.fadeIn,
        display = self.db.profile.animations.duration.display,
        fadeOut = self.db.profile.animations.duration.fadeOut
    }
    
    -- Apply animation style timing adjustments
    if animationTimingAdjustments[style] and animationTimingAdjustments[style][animIntensity] then
        local timingAdjust = animationTimingAdjustments[style][animIntensity]
        durationSettings.fadeIn = durationSettings.fadeIn * timingAdjust.fadeIn
        durationSettings.display = durationSettings.display * timingAdjust.display
        durationSettings.fadeOut = durationSettings.fadeOut * timingAdjust.fadeOut
    end
    
    -- Stop any existing animations
    if frame.animGroup then
        frame.animGroup:Stop()
    else
        frame.animGroup = frame:CreateAnimationGroup()
        frame.animGroup:SetScript("OnFinished", function()
            frame:Hide()
            MultiNotification:ArrangeNotificationFrames()
            MultiNotification:ProcessNotificationQueue()
        end)
    end
    
    -- Clear existing animations
    if frame.fadeIn then frame.fadeIn:SetParent(nil) end
    if frame.fadeOut then frame.fadeOut:SetParent(nil) end
    if frame.moveIn then frame.moveIn:SetParent(nil) end
    if frame.moveOut then frame.moveOut:SetParent(nil) end
    if frame.scaleIn then frame.scaleIn:SetParent(nil) end
    if frame.scaleOut then frame.scaleOut:SetParent(nil) end
    if frame.rotation then frame.rotation:SetParent(nil) end
    
    -- Create new animations based on style
    if style == "fade" then
        self:ApplyFadeAnimation(frame, animIntensity, durationSettings)
    elseif style == "slide" then
        self:ApplySlideAnimation(frame, animIntensity, durationSettings)
    elseif style == "scale" then
        self:ApplyScaleAnimation(frame, animIntensity, durationSettings)
    elseif style == "bounce" then
        self:ApplyBounceAnimation(frame, animIntensity, durationSettings)
    elseif style == "pulse" then
        self:ApplyPulseAnimation(frame, animIntensity, durationSettings)
    elseif style == "spin" then
        self:ApplySpinAnimation(frame, animIntensity, durationSettings)
    elseif style == "flip" then
        self:ApplyFlipAnimation(frame, animIntensity, durationSettings)
    elseif style == "glide" then
        self:ApplyGlideAnimation(frame, animIntensity, durationSettings)
    else
        -- Default to fade if style is not recognized
        self:ApplyFadeAnimation(frame, animIntensity, durationSettings)
    end
    
    -- Save animation data on the frame
    frame.animationData = {
        style = style,
        intensity = animIntensity,
        duration = durationSettings
    }
    
    return durationSettings
end

-- Apply fade animation (simple fade in/out)
function MultiNotification:ApplyFadeAnimation(frame, intensity, duration)
    -- Fade in animation
    frame.fadeIn = frame.animGroup:CreateAnimation("Alpha")
    frame.fadeIn:SetFromAlpha(0)
    frame.fadeIn:SetToAlpha(1)
    frame.fadeIn:SetDuration(duration.fadeIn)
    frame.fadeIn:SetOrder(1)
    
    -- Fade out animation
    frame.fadeOut = frame.animGroup:CreateAnimation("Alpha")
    frame.fadeOut:SetFromAlpha(1)
    frame.fadeOut:SetToAlpha(0)
    frame.fadeOut:SetDuration(duration.fadeOut)
    frame.fadeOut:SetStartDelay(duration.display)
    frame.fadeOut:SetOrder(2)
end

-- Apply slide animation (slide in from a direction, slide out)
function MultiNotification:ApplySlideAnimation(frame, intensity, duration)
    -- Determine slide distance based on intensity
    local distance = 50 * intensity
    local direction = frame.direction or "DOWN" -- Use notification's direction or default
    
    -- Calculate offset based on direction
    local xFrom, yFrom, xTo, yTo = 0, 0, 0, 0
    if direction == "UP" then
        yFrom = -distance
    elseif direction == "DOWN" then
        yFrom = distance
    elseif direction == "LEFT" then
        xFrom = distance
    elseif direction == "RIGHT" then
        xFrom = -distance
    end
    
    -- Slide in animation
    frame.moveIn = frame.animGroup:CreateAnimation("Translation")
    frame.moveIn:SetOffset(xFrom, yFrom)
    frame.moveIn:SetDuration(0)
    frame.moveIn:SetOrder(1)
    
    frame.moveOut = frame.animGroup:CreateAnimation("Translation")
    frame.moveOut:SetOffset(xTo, yTo)
    frame.moveOut:SetDuration(duration.fadeIn)
    frame.moveOut:SetSmoothing("OUT")
    frame.moveOut:SetOrder(2)
    
    -- Fade in animation
    frame.fadeIn = frame.animGroup:CreateAnimation("Alpha")
    frame.fadeIn:SetFromAlpha(0)
    frame.fadeIn:SetToAlpha(1)
    frame.fadeIn:SetDuration(duration.fadeIn)
    frame.fadeIn:SetOrder(2)
    
    -- Fade out animation with slide
    frame.fadeOut = frame.animGroup:CreateAnimation("Alpha")
    frame.fadeOut:SetFromAlpha(1)
    frame.fadeOut:SetToAlpha(0)
    frame.fadeOut:SetDuration(duration.fadeOut)
    frame.fadeOut:SetStartDelay(duration.display)
    frame.fadeOut:SetOrder(3)
    
    -- Slide out animation
    frame.slideOut = frame.animGroup:CreateAnimation("Translation")
    frame.slideOut:SetOffset(-xFrom, -yFrom)
    frame.slideOut:SetDuration(duration.fadeOut)
    frame.slideOut:SetStartDelay(duration.display)
    frame.slideOut:SetSmoothing("IN")
    frame.slideOut:SetOrder(3)
end

-- Apply scale animation (zoom in/out)
function MultiNotification:ApplyScaleAnimation(frame, intensity, duration)
    -- Scale factors based on intensity
    local scaleFrom = 0.5 + (intensity * 0.5) -- 1.0, 1.5, 2.0
    
    -- Scale in animation
    frame.scaleIn1 = frame.animGroup:CreateAnimation("Scale")
    frame.scaleIn1:SetFromScale(0.1, 0.1)
    frame.scaleIn1:SetToScale(scaleFrom, scaleFrom)
    frame.scaleIn1:SetDuration(duration.fadeIn * 0.7)
    frame.scaleIn1:SetOrder(1)
    
    -- Scale adjustment
    frame.scaleIn2 = frame.animGroup:CreateAnimation("Scale")
    frame.scaleIn2:SetFromScale(scaleFrom, scaleFrom)
    frame.scaleIn2:SetToScale(1, 1)
    frame.scaleIn2:SetDuration(duration.fadeIn * 0.3)
    frame.scaleIn2:SetOrder(2)
    
    -- Fade in animation
    frame.fadeIn = frame.animGroup:CreateAnimation("Alpha")
    frame.fadeIn:SetFromAlpha(0)
    frame.fadeIn:SetToAlpha(1)
    frame.fadeIn:SetDuration(duration.fadeIn)
    frame.fadeIn:SetOrder(1)
    
    -- Fade out animation
    frame.fadeOut = frame.animGroup:CreateAnimation("Alpha")
    frame.fadeOut:SetFromAlpha(1)
    frame.fadeOut:SetToAlpha(0)
    frame.fadeOut:SetDuration(duration.fadeOut)
    frame.fadeOut:SetStartDelay(duration.display)
    frame.fadeOut:SetOrder(3)
    
    -- Scale out animation
    frame.scaleOut = frame.animGroup:CreateAnimation("Scale")
    frame.scaleOut:SetFromScale(1, 1)
    frame.scaleOut:SetToScale(0.1, 0.1)
    frame.scaleOut:SetDuration(duration.fadeOut)
    frame.scaleOut:SetStartDelay(duration.display)
    frame.scaleOut:SetOrder(3)
end

-- Apply bounce animation (bounce in/out)
function MultiNotification:ApplyBounceAnimation(frame, intensity, duration)
    -- Bounce parameters based on intensity
    local bounceHeight = 20 * intensity
    local bounceDuration = duration.fadeIn / 3
    
    -- Initial drop position
    frame.moveIn = frame.animGroup:CreateAnimation("Translation")
    frame.moveIn:SetOffset(0, -bounceHeight)
    frame.moveIn:SetDuration(0)
    frame.moveIn:SetOrder(1)
    
    -- First bounce up
    frame.bounce1 = frame.animGroup:CreateAnimation("Translation")
    frame.bounce1:SetOffset(0, bounceHeight * 0.8)
    frame.bounce1:SetDuration(bounceDuration)
    frame.bounce1:SetSmoothing("OUT")
    frame.bounce1:SetOrder(2)
    
    -- Bounce down
    frame.bounce2 = frame.animGroup:CreateAnimation("Translation")
    frame.bounce2:SetOffset(0, -bounceHeight * 0.5)
    frame.bounce2:SetDuration(bounceDuration)
    frame.bounce2:SetSmoothing("IN_OUT")
    frame.bounce2:SetOrder(3)
    
    -- Final settle
    frame.bounce3 = frame.animGroup:CreateAnimation("Translation")
    frame.bounce3:SetOffset(0, bounceHeight * 0.7)
    frame.bounce3:SetDuration(bounceDuration)
    frame.bounce3:SetSmoothing("IN")
    frame.bounce3:SetOrder(4)
    
    -- Fade in animation
    frame.fadeIn = frame.animGroup:CreateAnimation("Alpha")
    frame.fadeIn:SetFromAlpha(0)
    frame.fadeIn:SetToAlpha(1)
    frame.fadeIn:SetDuration(duration.fadeIn * 0.5)
    frame.fadeIn:SetOrder(1)
    
    -- Fade out animation
    frame.fadeOut = frame.animGroup:CreateAnimation("Alpha")
    frame.fadeOut:SetFromAlpha(1)
    frame.fadeOut:SetToAlpha(0)
    frame.fadeOut:SetDuration(duration.fadeOut)
    frame.fadeOut:SetStartDelay(duration.display)
    frame.fadeOut:SetOrder(5)
    
    -- Bounce out
    frame.bounceOut = frame.animGroup:CreateAnimation("Translation")
    frame.bounceOut:SetOffset(0, -bounceHeight * 2)
    frame.bounceOut:SetDuration(duration.fadeOut)
    frame.bounceOut:SetStartDelay(duration.display)
    frame.bounceOut:SetSmoothing("IN")
    frame.bounceOut:SetOrder(5)
end

-- Apply pulse animation (pulsate size and opacity)
function MultiNotification:ApplyPulseAnimation(frame, intensity, duration)
    -- Pulse parameters based on intensity
    local pulseScale = 1 + (intensity * 0.15) -- 1.15, 1.30, 1.45
    local pulseDuration = 0.4
    local numPulses = math.floor(duration.display / pulseDuration)
    
    -- Initial fade in
    frame.fadeIn = frame.animGroup:CreateAnimation("Alpha")
    frame.fadeIn:SetFromAlpha(0)
    frame.fadeIn:SetToAlpha(1)
    frame.fadeIn:SetDuration(duration.fadeIn)
    frame.fadeIn:SetOrder(1)
    
    -- Create pulse group
    frame.pulseGroup = frame.animGroup:CreateAnimation("Animation")
    frame.pulseGroup:SetDuration(0)
    frame.pulseGroup:SetOrder(2)
    
    -- Create the pulse animation(s)
    local pulseCount = math.min(numPulses, 5) -- Limit to reasonable number of pulses
    
    for i = 1, pulseCount do
        -- Scale up
        local scaleUp = frame.pulseGroup:CreateAnimation("Scale")
        scaleUp:SetChildKey("pulse_scale_up_" .. i)
        scaleUp:SetFromScale(1, 1)
        scaleUp:SetToScale(pulseScale, pulseScale)
        scaleUp:SetDuration(pulseDuration / 2)
        scaleUp:SetStartDelay((i-1) * pulseDuration)
        scaleUp:SetSmoothing("IN_OUT")
        scaleUp:SetOrder(1)
        
        -- Scale down
        local scaleDown = frame.pulseGroup:CreateAnimation("Scale")
        scaleDown:SetChildKey("pulse_scale_down_" .. i)
        scaleDown:SetFromScale(pulseScale, pulseScale)
        scaleDown:SetToScale(1, 1)
        scaleDown:SetDuration(pulseDuration / 2)
        scaleDown:SetStartDelay((i-1) * pulseDuration + (pulseDuration / 2))
        scaleDown:SetSmoothing("IN_OUT")
        scaleDown:SetOrder(2)
    end
    
    -- Fade out animation
    frame.fadeOut = frame.animGroup:CreateAnimation("Alpha")
    frame.fadeOut:SetFromAlpha(1)
    frame.fadeOut:SetToAlpha(0)
    frame.fadeOut:SetDuration(duration.fadeOut)
    frame.fadeOut:SetStartDelay(duration.display)
    frame.fadeOut:SetOrder(3)
end

-- Apply spin animation (rotate in/out)
function MultiNotification:ApplySpinAnimation(frame, intensity, duration)
    -- Spin parameters based on intensity
    local spinAmount = 360 * intensity -- Full rotations based on intensity
    
    -- Initial state
    frame.rotationIn1 = frame.animGroup:CreateAnimation("Rotation")
    frame.rotationIn1:SetDegrees(-spinAmount)
    frame.rotationIn1:SetDuration(0)
    frame.rotationIn1:SetOrder(1)
    
    -- Spin in
    frame.rotationIn2 = frame.animGroup:CreateAnimation("Rotation")
    frame.rotationIn2:SetDegrees(spinAmount)
    frame.rotationIn2:SetDuration(duration.fadeIn)
    frame.rotationIn2:SetSmoothing("OUT")
    frame.rotationIn2:SetOrder(2)
    
    -- Fade in animation
    frame.fadeIn = frame.animGroup:CreateAnimation("Alpha")
    frame.fadeIn:SetFromAlpha(0)
    frame.fadeIn:SetToAlpha(1)
    frame.fadeIn:SetDuration(duration.fadeIn)
    frame.fadeIn:SetOrder(2)
    
    -- Fade out animation
    frame.fadeOut = frame.animGroup:CreateAnimation("Alpha")
    frame.fadeOut:SetFromAlpha(1)
    frame.fadeOut:SetToAlpha(0)
    frame.fadeOut:SetDuration(duration.fadeOut)
    frame.fadeOut:SetStartDelay(duration.display)
    frame.fadeOut:SetOrder(3)
    
    -- Spin out
    frame.rotationOut = frame.animGroup:CreateAnimation("Rotation")
    frame.rotationOut:SetDegrees(spinAmount)
    frame.rotationOut:SetDuration(duration.fadeOut)
    frame.rotationOut:SetStartDelay(duration.display)
    frame.rotationOut:SetSmoothing("IN")
    frame.rotationOut:SetOrder(3)
end

-- Apply flip animation (3D-like flip effect)
function MultiNotification:ApplyFlipAnimation(frame, intensity, duration)
    -- Adapt scale based on intensity
    local scaleFactor = 0.3 + (intensity * 0.2) -- 0.5, 0.7, 0.9
    
    -- Initial state
    frame.scaleIn1 = frame.animGroup:CreateAnimation("Scale")
    frame.scaleIn1:SetFromScale(scaleFactor, 1)
    frame.scaleIn1:SetToScale(1, 1)
    frame.scaleIn1:SetDuration(duration.fadeIn)
    frame.scaleIn1:SetSmoothing("OUT")
    frame.scaleIn1:SetOrder(1)
    
    -- Fade in animation
    frame.fadeIn = frame.animGroup:CreateAnimation("Alpha")
    frame.fadeIn:SetFromAlpha(0)
    frame.fadeIn:SetToAlpha(1)
    frame.fadeIn:SetDuration(duration.fadeIn)
    frame.fadeIn:SetOrder(1)
    
    -- Fade out animation
    frame.fadeOut = frame.animGroup:CreateAnimation("Alpha")
    frame.fadeOut:SetFromAlpha(1)
    frame.fadeOut:SetToAlpha(0)
    frame.fadeOut:SetDuration(duration.fadeOut)
    frame.fadeOut:SetStartDelay(duration.display)
    frame.fadeOut:SetOrder(2)
    
    -- Scale out (flip back)
    frame.scaleOut = frame.animGroup:CreateAnimation("Scale")
    frame.scaleOut:SetFromScale(1, 1)
    frame.scaleOut:SetToScale(scaleFactor, 1)
    frame.scaleOut:SetDuration(duration.fadeOut)
    frame.scaleOut:SetStartDelay(duration.display)
    frame.scaleOut:SetSmoothing("IN")
    frame.scaleOut:SetOrder(2)
end

-- Apply glide animation (smooth movement with path)
function MultiNotification:ApplyGlideAnimation(frame, intensity, duration)
    -- Glide parameters based on intensity
    local glideDistance = 40 * intensity
    local direction = frame.direction or "DOWN"
    
    -- Calculate path based on direction
    local xFrom, yFrom, xMid, yMid, xTo, yTo = 0, 0, 0, 0, 0, 0
    
    if direction == "UP" then
        yFrom = -glideDistance
        xMid = glideDistance * 0.3
        yMid = -glideDistance * 0.5
    elseif direction == "DOWN" then
        yFrom = glideDistance
        xMid = -glideDistance * 0.3
        yMid = glideDistance * 0.5
    elseif direction == "LEFT" then
        xFrom = glideDistance
        xMid = glideDistance * 0.5
        yMid = glideDistance * 0.3
    elseif direction == "RIGHT" then
        xFrom = -glideDistance
        xMid = -glideDistance * 0.5
        yMid = -glideDistance * 0.3
    end
    
    -- Initial position
    frame.moveIn = frame.animGroup:CreateAnimation("Translation")
    frame.moveIn:SetOffset(xFrom, yFrom)
    frame.moveIn:SetDuration(0)
    frame.moveIn:SetOrder(1)
    
    -- First leg of movement
    frame.moveFirst = frame.animGroup:CreateAnimation("Translation")
    frame.moveFirst:SetOffset(xMid - xFrom, yMid - yFrom)
    frame.moveFirst:SetDuration(duration.fadeIn * 0.6)
    frame.moveFirst:SetSmoothing("OUT")
    frame.moveFirst:SetOrder(2)
    
    -- Second leg of movement
    frame.moveSecond = frame.animGroup:CreateAnimation("Translation")
    frame.moveSecond:SetOffset(xTo - xMid, yTo - yMid)
    frame.moveSecond:SetDuration(duration.fadeIn * 0.4)
    frame.moveSecond:SetSmoothing("IN")
    frame.moveSecond:SetOrder(3)
    
    -- Fade in animation
    frame.fadeIn = frame.animGroup:CreateAnimation("Alpha")
    frame.fadeIn:SetFromAlpha(0)
    frame.fadeIn:SetToAlpha(1)
    frame.fadeIn:SetDuration(duration.fadeIn)
    frame.fadeIn:SetOrder(2)
    
    -- Fade out animation
    frame.fadeOut = frame.animGroup:CreateAnimation("Alpha")
    frame.fadeOut:SetFromAlpha(1)
    frame.fadeOut:SetToAlpha(0)
    frame.fadeOut:SetDuration(duration.fadeOut)
    frame.fadeOut:SetStartDelay(duration.display)
    frame.fadeOut:SetOrder(4)
    
    -- Exit movement
    frame.moveOut = frame.animGroup:CreateAnimation("Translation")
    frame.moveOut:SetOffset(-xFrom, -yFrom)
    frame.moveOut:SetDuration(duration.fadeOut)
    frame.moveOut:SetStartDelay(duration.display)
    frame.moveOut:SetSmoothing("IN")
    frame.moveOut:SetOrder(4)
end

-- Set the animation style for a specific category
function MultiNotification:SetCategoryAnimationStyle(category, style, intensity)
    if not category or not style then return end
    
    self.db.profile.animations.categorySettings[category] = self.db.profile.animations.categorySettings[category] or {}
    self.db.profile.animations.categorySettings[category].style = style
    if intensity then
        self.db.profile.animations.categorySettings[category].intensity = intensity
    end
end

-- Register animation options in the configuration UI
function MultiNotification:RegisterAnimationOptions()
    -- Hook into the MultiNotification GetOptions function
    local originalGetOptions = self.GetOptions
    if not originalGetOptions then return end
    
    self.GetOptions = function(self)
        local options = originalGetOptions(self)
        
        -- Add animation options
        options.args.animationHeader = {
            type = "header",
            name = "Animation Settings",
            order = 400
        }
        
        options.args.animationEnabled = {
            type = "toggle",
            name = "Enable Advanced Animations",
            desc = "Enable or disable enhanced animation variations",
            get = function() return self.db.profile.animations.enabled end,
            set = function(_, value)
                self.db.profile.animations.enabled = value
            end,
            width = "full",
            order = 401
        }
        
        options.args.animationStyle = {
            type = "select",
            name = "Default Animation Style",
            desc = "Choose the default animation style for notifications",
            values = {
                fade = "Fade",
                slide = "Slide",
                scale = "Scale",
                bounce = "Bounce",
                pulse = "Pulse",
                spin = "Spin",
                flip = "Flip",
                glide = "Glide"
            },
            get = function() return self.db.profile.animations.style end,
            set = function(_, value)
                self.db.profile.animations.style = value
            end,
            disabled = function() return not self.db.profile.animations.enabled end,
            width = "full",
            order = 402
        }
        
        options.args.animationIntensity = {
            type = "select",
            name = "Animation Intensity",
            desc = "Set how intense/noticeable the animations should be",
            values = {
                [1] = "Subtle",
                [2] = "Normal",
                [3] = "Intense"
            },
            get = function() return self.db.profile.animations.intensity end,
            set = function(_, value)
                self.db.profile.animations.intensity = value
            end,
            disabled = function() return not self.db.profile.animations.enabled end,
            width = "full",
            order = 403
        }
        
        -- Animation duration settings
        options.args.animationDurationGroup = {
            type = "group",
            name = "Animation Timing",
            inline = true,
            order = 404,
            disabled = function() return not self.db.profile.animations.enabled end,
            args = {
                fadeInDuration = {
                    type = "range",
                    name = "Fade In Duration",
                    desc = "How long the fade in animation takes (seconds)",
                    min = 0.1,
                    max = 1.0,
                    step = 0.05,
                    get = function() return self.db.profile.animations.duration.fadeIn end,
                    set = function(_, value)
                        self.db.profile.animations.duration.fadeIn = value
                    end,
                    width = "full",
                    order = 1
                },
                displayDuration = {
                    type = "range",
                    name = "Display Duration",
                    desc = "How long notifications remain visible (seconds)",
                    min = 1.0,
                    max = 10.0,
                    step = 0.5,
                    get = function() return self.db.profile.animations.duration.display end,
                    set = function(_, value)
                        self.db.profile.animations.duration.display = value
                    end,
                    width = "full",
                    order = 2
                },
                fadeOutDuration = {
                    type = "range",
                    name = "Fade Out Duration",
                    desc = "How long the fade out animation takes (seconds)",
                    min = 0.1,
                    max = 1.0,
                    step = 0.05,
                    get = function() return self.db.profile.animations.duration.fadeOut end,
                    set = function(_, value)
                        self.db.profile.animations.duration.fadeOut = value
                    end,
                    width = "full",
                    order = 3
                }
            }
        }
        
        -- Performance settings
        options.args.animationPerformanceGroup = {
            type = "group",
            name = "Performance Settings",
            inline = true,
            order = 405,
            disabled = function() return not self.db.profile.animations.enabled end,
            args = {
                reduceInCombat = {
                    type = "toggle",
                    name = "Reduce Animations in Combat",
                    desc = "Reduce animation intensity during combat to improve performance",
                    get = function() return self.db.profile.animations.performance.reduceInCombat end,
                    set = function(_, value)
                        self.db.profile.animations.performance.reduceInCombat = value
                    end,
                    width = "full",
                    order = 1
                },
                disableInRaid = {
                    type = "toggle",
                    name = "Simplify Animations in Raids",
                    desc = "Use simpler animations in raid environments",
                    get = function() return self.db.profile.animations.performance.disableInRaid end,
                    set = function(_, value)
                        self.db.profile.animations.performance.disableInRaid = value
                    end,
                    width = "full",
                    order = 2
                },
                disableOnLowFPS = {
                    type = "toggle",
                    name = "Adjust for Low FPS",
                    desc = "Automatically reduce animation complexity when FPS drops",
                    get = function() return self.db.profile.animations.performance.disableOnLowFPS end,
                    set = function(_, value)
                        self.db.profile.animations.performance.disableOnLowFPS = value
                    end,
                    width = "full",
                    order = 3
                },
                lowFPSThreshold = {
                    type = "range",
                    name = "Low FPS Threshold",
                    desc = "FPS value below which animations will be simplified",
                    min = 10,
                    max = 60,
                    step = 5,
                    get = function() return self.db.profile.animations.performance.lowFPSThreshold end,
                    set = function(_, value)
                        self.db.profile.animations.performance.lowFPSThreshold = value
                    end,
                    disabled = function() return not self.db.profile.animations.enabled or not self.db.profile.animations.performance.disableOnLowFPS end,
                    width = "full",
                    order = 4
                }
            }
        }
        
        -- Category-specific options
        options.args.animationCategoryHeader = {
            type = "header",
            name = "Category Animation Settings",
            order = 406
        }
        
        local categoryOrder = 407
        for category, settings in pairs(self.db.profile.animations.categorySettings) do
            options.args["animation_" .. category] = {
                type = "group",
                name = category:gsub("^%l", string.upper):gsub("_", " ") .. " Animations",
                inline = true,
                order = categoryOrder,
                disabled = function() return not self.db.profile.animations.enabled end,
                args = {
                    style = {
                        type = "select",
                        name = "Animation Style",
                        desc = "Choose animation style for " .. category .. " notifications",
                        values = {
                            fade = "Fade",
                            slide = "Slide",
                            scale = "Scale",
                            bounce = "Bounce",
                            pulse = "Pulse",
                            spin = "Spin",
                            flip = "Flip",
                            glide = "Glide"
                        },
                        get = function() return self.db.profile.animations.categorySettings[category].style end,
                        set = function(_, value)
                            self.db.profile.animations.categorySettings[category].style = value
                        end,
                        width = "full",
                        order = 1
                    },
                    intensity = {
                        type = "select",
                        name = "Animation Intensity",
                        desc = "Set animation intensity for " .. category .. " notifications",
                        values = {
                            [1] = "Subtle",
                            [2] = "Normal",
                            [3] = "Intense"
                        },
                        get = function() return self.db.profile.animations.categorySettings[category].intensity end,
                        set = function(_, value)
                            self.db.profile.animations.categorySettings[category].intensity = value
                        end,
                        width = "full",
                        order = 2
                    }
                }
            }
            categoryOrder = categoryOrder + 1
        end
        
        return options
    end
end

-- Override the ShowNotification function to use animation variations
local originalShowNotification = MultiNotification.ShowNotification
if originalShowNotification then
    MultiNotification.ShowNotification = function(self, notificationInfo)
        -- Call original function if animations are disabled
        if not self.db.profile.animations or not self.db.profile.animations.enabled then
            return originalShowNotification(self, notificationInfo)
        end
        
        -- If no frame is provided and frame pooling is enabled, get a frame from the pool
        local frame
        if self.db.profile.globalSettings.useFramePooling and self.FramePool then
            frame = self.FramePool:AcquireFrame("notification")
            if not frame then

                return
            end
        else
            -- Legacy frame acquisition
            frame = self:GetAvailableNotificationFrame()
            if not frame then

                return
            end
        end
        
        -- Configure the frame with notification info
        self:ConfigureNotificationFrame(frame, notificationInfo)
        
        -- Apply the animation style based on category
        local duration = self:ApplyAnimationStyle(
            frame, 
            nil, -- Use default style from settings
            nil, -- Use default intensity from settings
            notificationInfo.category,
            {
                fadeIn = self.db.profile.animations.duration.fadeIn,
                display = notificationInfo.duration or self.db.profile.animations.duration.display,
                fadeOut = self.db.profile.animations.duration.fadeOut
            }
        )
        
        -- Show frame and start animation
        frame:Show()
        frame.animGroup:Play()
        
        -- Add to active notifications
        table.insert(activeNotifications, {
            frame = frame,
            info = notificationInfo,
            expiryTime = GetTime() + duration.fadeIn + duration.display + duration.fadeOut
        })
        
        -- Update notification layout
        self:ArrangeNotificationFrames()
        
        return frame
    end
end

-- Hook the OnInitialize function to initialize animation variations
local originalOnInitialize = MultiNotification.OnInitialize
if originalOnInitialize then
    MultiNotification.OnInitialize = function(self)
        -- Call original initialization
        originalOnInitialize(self)
        
        -- Initialize animation variations
        self:InitializeAnimationVariations()
    end
end