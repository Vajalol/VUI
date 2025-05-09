-- VUI Animation Utilities
-- Provides smooth transitions and animations for VUI modules
-- Author: VortexQ8

local AddonName, VUI = ...

-- Create the Animation namespace
VUI.Animations = VUI.Animations or {}

-- Constants
local DEFAULT_DURATION = 0.3      -- Default duration in seconds
local DEFAULT_SMOOTH_VALUE = 0.3  -- Default smoothing value (lower = sharper)

-- Animation presets
VUI.Animations.Presets = {
    FADE_IN = 1,
    FADE_OUT = 2,
    SLIDE_LEFT = 3,
    SLIDE_RIGHT = 4,
    SLIDE_UP = 5,
    SLIDE_DOWN = 6,
    SCALE_IN = 7,
    SCALE_OUT = 8,
    BOUNCE = 9,
    PULSE = 10,
}

-- Easing functions for different animation styles
VUI.Animations.EasingFunctions = {
    LINEAR = function(t) return t end,
    SMOOTH = function(t) return t*t*(3-2*t) end,
    EASE_IN = function(t) return t*t end,
    EASE_OUT = function(t) return t*(2-t) end,
    EASE_IN_OUT = function(t) return t<0.5 and 2*t*t or -1+(4-2*t)*t end,
    BACK = function(t) return t*t*(2.70158*t-1.70158) end,
    ELASTIC = function(t) 
        local p = 0.3
        return math.pow(2, -10*t) * math.sin((t-p/4)*(2*math.pi)/p) + 1 
    end,
    BOUNCE = function(t)
        if t < 1/2.75 then 
            return 7.5625*t*t
        elseif t < 2/2.75 then
            t = t - 1.5/2.75
            return 7.5625*t*t + 0.75
        elseif t < 2.5/2.75 then
            t = t - 2.25/2.75
            return 7.5625*t*t + 0.9375
        else
            t = t - 2.625/2.75
            return 7.5625*t*t + 0.984375
        end
    end,
}

-- Animation state table to keep track of all active animations
local animating = {}

-- Utility function to stop any existing animations on a frame
function VUI.Animations:StopAnimations(frame)
    if not frame then return end
    
    -- Stop any active animation groups
    if frame.VUIAnimationGroup then
        frame.VUIAnimationGroup:Stop()
    end
    
    -- Remove from tracking table
    animating[frame] = nil
    
    -- Reset any animation-specific attributes
    frame.isVUIAnimating = nil
end

-- Apply a preset animation to a frame
function VUI.Animations:ApplyPreset(frame, preset, onFinished, duration, customOptions)
    if not frame then return end
    
    -- Set defaults
    duration = duration or DEFAULT_DURATION
    customOptions = customOptions or {}
    
    -- Stop any existing animations
    self:StopAnimations(frame)
    
    -- Select animation based on preset
    if preset == self.Presets.FADE_IN then
        self:FadeIn(frame, duration, onFinished, customOptions)
    elseif preset == self.Presets.FADE_OUT then
        self:FadeOut(frame, duration, onFinished, customOptions)
    elseif preset == self.Presets.SLIDE_LEFT then
        self:SlideIn(frame, "LEFT", duration, onFinished, customOptions)
    elseif preset == self.Presets.SLIDE_RIGHT then
        self:SlideIn(frame, "RIGHT", duration, onFinished, customOptions)
    elseif preset == self.Presets.SLIDE_UP then
        self:SlideIn(frame, "UP", duration, onFinished, customOptions)
    elseif preset == self.Presets.SLIDE_DOWN then
        self:SlideIn(frame, "DOWN", duration, onFinished, customOptions)
    elseif preset == self.Presets.SCALE_IN then
        self:ScaleIn(frame, duration, onFinished, customOptions)
    elseif preset == self.Presets.SCALE_OUT then
        self:ScaleOut(frame, duration, onFinished, customOptions)
    elseif preset == self.Presets.BOUNCE then
        self:Bounce(frame, duration, onFinished, customOptions)
    elseif preset == self.Presets.PULSE then
        self:Pulse(frame, duration, onFinished, customOptions)
    end
end

-- Creates or reuses animation group for a frame
function VUI.Animations:GetAnimationGroup(frame)
    if not frame.VUIAnimationGroup then
        frame.VUIAnimationGroup = frame:CreateAnimationGroup()
        frame.VUIAnimationGroup:SetScript("OnFinished", function(self)
            local onFinished = frame.VUIAnimationOnFinished
            
            -- Clear animation state
            frame.isVUIAnimating = nil
            animating[frame] = nil
            
            -- Call the onFinished callback if provided
            if onFinished then
                onFinished(frame)
            end
        end)
    else
        frame.VUIAnimationGroup:Stop()
        frame.VUIAnimationGroup:Clear()
    end
    
    return frame.VUIAnimationGroup
end

-- Create an alpha animation
function VUI.Animations:CreateAlphaAnimation(group, fromAlpha, toAlpha, duration, order, smoothing)
    local alpha = group:CreateAnimation("Alpha")
    alpha:SetFromAlpha(fromAlpha)
    alpha:SetToAlpha(toAlpha)
    alpha:SetDuration(duration)
    alpha:SetOrder(order or 1)
    alpha:SetSmoothing(smoothing or "NONE")
    return alpha
end

-- Create a translation animation
function VUI.Animations:CreateTranslationAnimation(group, offsetX, offsetY, duration, order, smoothing)
    local translate = group:CreateAnimation("Translation")
    translate:SetOffset(offsetX, offsetY)
    translate:SetDuration(duration)
    translate:SetOrder(order or 1)
    translate:SetSmoothing(smoothing or "NONE")
    return translate
end

-- Create a scale animation
function VUI.Animations:CreateScaleAnimation(group, fromScaleX, fromScaleY, toScaleX, toScaleY, duration, order, smoothing)
    local scale = group:CreateAnimation("Scale")
    scale:SetFromScale(fromScaleX, fromScaleY)
    scale:SetToScale(toScaleX, toScaleY)
    scale:SetDuration(duration)
    scale:SetOrder(order or 1)
    scale:SetSmoothing(smoothing or "NONE")
    return scale
end

-- Create a rotation animation
function VUI.Animations:CreateRotationAnimation(group, degrees, duration, order, smoothing)
    local rotation = group:CreateAnimation("Rotation")
    rotation:SetDegrees(degrees)
    rotation:SetDuration(duration)
    rotation:SetOrder(order or 1)
    rotation:SetSmoothing(smoothing or "NONE")
    return rotation
end

-- Fade In animation
function VUI.Animations:FadeIn(frame, duration, onFinished, options)
    if not frame then return end
    
    duration = duration or DEFAULT_DURATION
    options = options or {}
    local smoothing = options.smoothing or "IN_OUT"
    local fromAlpha = options.fromAlpha or 0
    local toAlpha = options.toAlpha or 1
    
    -- Store the current state
    frame.VUIOriginalAlpha = frame:GetAlpha()
    
    -- Setup the animation
    local group = self:GetAnimationGroup(frame)
    self:CreateAlphaAnimation(group, fromAlpha, toAlpha, duration, 1, smoothing)
    
    -- Store the onFinished callback
    frame.VUIAnimationOnFinished = onFinished
    
    -- Show the frame and start animation
    frame:Show()
    frame:SetAlpha(fromAlpha)
    group:Play()
    
    -- Track this animation
    frame.isVUIAnimating = true
    animating[frame] = "FADE_IN"
    
    return group
end

-- Fade Out animation
function VUI.Animations:FadeOut(frame, duration, onFinished, options)
    if not frame then return end
    
    duration = duration or DEFAULT_DURATION
    options = options or {}
    local smoothing = options.smoothing or "IN_OUT"
    local fromAlpha = options.fromAlpha or frame:GetAlpha()
    local toAlpha = options.toAlpha or 0
    
    -- Store the current state
    frame.VUIOriginalAlpha = frame:GetAlpha()
    
    -- Set up hide on finish if not explicitly disabled
    local hideOnFinish = options.hideOnFinish
    if hideOnFinish == nil then
        hideOnFinish = true
    end
    
    -- Setup the animation
    local group = self:GetAnimationGroup(frame)
    self:CreateAlphaAnimation(group, fromAlpha, toAlpha, duration, 1, smoothing)
    
    -- Store the original callback and add frame hiding if needed
    local originalOnFinished = onFinished
    frame.VUIAnimationOnFinished = function(f)
        if hideOnFinish then
            f:Hide()
            f:SetAlpha(frame.VUIOriginalAlpha or 1)
        end
        if originalOnFinished then
            originalOnFinished(f)
        end
    end
    
    -- Start animation
    group:Play()
    
    -- Track this animation
    frame.isVUIAnimating = true
    animating[frame] = "FADE_OUT"
    
    return group
end

-- Slide animation
function VUI.Animations:SlideIn(frame, direction, duration, onFinished, options)
    if not frame then return end
    
    duration = duration or DEFAULT_DURATION
    options = options or {}
    local smoothing = options.smoothing or "OUT"
    local distance = options.distance or 100
    local fade = options.fade
    if fade == nil then fade = true end
    
    -- Default offsets based on direction
    local offsetX, offsetY = 0, 0
    
    if direction == "LEFT" then
        offsetX = -distance
    elseif direction == "RIGHT" then
        offsetX = distance
    elseif direction == "UP" then
        offsetY = distance
    elseif direction == "DOWN" then
        offsetY = -distance
    end
    
    -- Custom offsets if provided
    if options.offsetX then offsetX = options.offsetX end
    if options.offsetY then offsetY = options.offsetY end
    
    -- Store the original position
    frame.VUIOriginalPoint = {frame:GetPoint(1)}
    
    -- Setup the animation
    local group = self:GetAnimationGroup(frame)
    
    -- Add translation animation
    self:CreateTranslationAnimation(group, offsetX, offsetY, duration, 1, smoothing)
    
    -- Add fade animation if enabled
    if fade then
        self:CreateAlphaAnimation(group, 0, 1, duration, 1, smoothing)
    end
    
    -- Store the onFinished callback
    frame.VUIAnimationOnFinished = onFinished
    
    -- Show the frame and start animation
    if fade then frame:SetAlpha(0) end
    frame:Show()
    group:Play()
    
    -- Track this animation
    frame.isVUIAnimating = true
    animating[frame] = "SLIDE_IN_" .. direction
    
    return group
end

-- Slide Out animation
function VUI.Animations:SlideOut(frame, direction, duration, onFinished, options)
    if not frame then return end
    
    duration = duration or DEFAULT_DURATION
    options = options or {}
    local smoothing = options.smoothing or "IN"
    local distance = options.distance or 100
    local fade = options.fade
    if fade == nil then fade = true end
    
    -- Default offsets based on direction
    local offsetX, offsetY = 0, 0
    
    if direction == "LEFT" then
        offsetX = -distance
    elseif direction == "RIGHT" then
        offsetX = distance
    elseif direction == "UP" then
        offsetY = distance
    elseif direction == "DOWN" then
        offsetY = -distance
    end
    
    -- Custom offsets if provided
    if options.offsetX then offsetX = options.offsetX end
    if options.offsetY then offsetY = options.offsetY end
    
    -- Set up hide on finish if not explicitly disabled
    local hideOnFinish = options.hideOnFinish
    if hideOnFinish == nil then
        hideOnFinish = true
    end
    
    -- Setup the animation
    local group = self:GetAnimationGroup(frame)
    
    -- Add translation animation
    self:CreateTranslationAnimation(group, offsetX, offsetY, duration, 1, smoothing)
    
    -- Add fade animation if enabled
    if fade then
        self:CreateAlphaAnimation(group, 1, 0, duration, 1, smoothing)
    end
    
    -- Store the original callback and add frame hiding if needed
    local originalOnFinished = onFinished
    frame.VUIAnimationOnFinished = function(f)
        if hideOnFinish then
            f:Hide()
            if fade then f:SetAlpha(1) end
        end
        if originalOnFinished then
            originalOnFinished(f)
        end
    end
    
    -- Start animation
    group:Play()
    
    -- Track this animation
    frame.isVUIAnimating = true
    animating[frame] = "SLIDE_OUT_" .. direction
    
    return group
end

-- Scale In animation
function VUI.Animations:ScaleIn(frame, duration, onFinished, options)
    if not frame then return end
    
    duration = duration or DEFAULT_DURATION
    options = options or {}
    local smoothing = options.smoothing or "OUT"
    local fromScale = options.fromScale or 0.5
    local toScale = options.toScale or 1.0
    local fade = options.fade
    if fade == nil then fade = true end
    
    -- Setup the animation
    local group = self:GetAnimationGroup(frame)
    
    -- Add scale animation
    self:CreateScaleAnimation(group, fromScale, fromScale, toScale, toScale, duration, 1, smoothing)
    
    -- Add fade animation if enabled
    if fade then
        self:CreateAlphaAnimation(group, 0, 1, duration, 1, smoothing)
    end
    
    -- Store the onFinished callback
    frame.VUIAnimationOnFinished = onFinished
    
    -- Show the frame and start animation
    if fade then frame:SetAlpha(0) end
    frame:Show()
    group:Play()
    
    -- Track this animation
    frame.isVUIAnimating = true
    animating[frame] = "SCALE_IN"
    
    return group
end

-- Scale Out animation
function VUI.Animations:ScaleOut(frame, duration, onFinished, options)
    if not frame then return end
    
    duration = duration or DEFAULT_DURATION
    options = options or {}
    local smoothing = options.smoothing or "IN"
    local fromScale = options.fromScale or 1.0
    local toScale = options.toScale or 0.5
    local fade = options.fade
    if fade == nil then fade = true end
    
    -- Set up hide on finish if not explicitly disabled
    local hideOnFinish = options.hideOnFinish
    if hideOnFinish == nil then
        hideOnFinish = true
    end
    
    -- Setup the animation
    local group = self:GetAnimationGroup(frame)
    
    -- Add scale animation
    self:CreateScaleAnimation(group, fromScale, fromScale, toScale, toScale, duration, 1, smoothing)
    
    -- Add fade animation if enabled
    if fade then
        self:CreateAlphaAnimation(group, 1, 0, duration, 1, smoothing)
    end
    
    -- Store the original callback and add frame hiding if needed
    local originalOnFinished = onFinished
    frame.VUIAnimationOnFinished = function(f)
        if hideOnFinish then
            f:Hide()
            if fade then f:SetAlpha(1) end
        end
        if originalOnFinished then
            originalOnFinished(f)
        end
    end
    
    -- Start animation
    group:Play()
    
    -- Track this animation
    frame.isVUIAnimating = true
    animating[frame] = "SCALE_OUT"
    
    return group
end

-- Bounce animation
function VUI.Animations:Bounce(frame, duration, onFinished, options)
    if not frame then return end
    
    duration = duration or 0.6
    options = options or {}
    local height = options.height or 20
    local bounces = options.bounces or 3
    
    -- Setup the animation
    local group = self:GetAnimationGroup(frame)
    
    -- Create multiple bounce translations
    local segment = duration / (bounces * 2)
    local dampen = 1.0
    
    for i = 1, bounces do
        -- Up
        local up = self:CreateTranslationAnimation(group, 0, height * dampen, segment, i * 2 - 1, "OUT")
        -- Down
        local down = self:CreateTranslationAnimation(group, 0, -height * dampen, segment, i * 2, "IN")
        
        -- Reduce height for each bounce
        dampen = dampen * 0.6
    end
    
    -- Store the onFinished callback
    frame.VUIAnimationOnFinished = onFinished
    
    -- Show the frame and start animation
    frame:Show()
    group:Play()
    
    -- Track this animation
    frame.isVUIAnimating = true
    animating[frame] = "BOUNCE"
    
    return group
end

-- Pulse animation
function VUI.Animations:Pulse(frame, duration, onFinished, options)
    if not frame then return end
    
    duration = duration or 0.5
    options = options or {}
    local pulseAmount = options.pulseAmount or 0.2
    local repeat_count = options.repeat_count or 1
    
    -- Setup the animation
    local group = self:GetAnimationGroup(frame)
    
    -- Scale up
    self:CreateScaleAnimation(group, 1, 1, 1 + pulseAmount, 1 + pulseAmount, duration / 2, 1, "OUT")
    
    -- Scale down
    self:CreateScaleAnimation(group, 1 + pulseAmount, 1 + pulseAmount, 1, 1, duration / 2, 2, "IN")
    
    -- Set repeat count
    if repeat_count > 1 then
        group:SetLooping("REPEAT")
        group:SetMaxLoops(repeat_count)
    end
    
    -- Store the onFinished callback
    frame.VUIAnimationOnFinished = onFinished
    
    -- Show the frame and start animation
    frame:Show()
    group:Play()
    
    -- Track this animation
    frame.isVUIAnimating = true
    animating[frame] = "PULSE"
    
    return group
end

-- Frame shake animation
function VUI.Animations:Shake(frame, duration, onFinished, options)
    if not frame then return end
    
    duration = duration or 0.3
    options = options or {}
    local intensity = options.intensity or 5
    local frequency = options.frequency or 5
    
    -- Setup the animation
    local group = self:GetAnimationGroup(frame)
    
    -- Create multiple translation animations for shaking effect
    local step = duration / frequency
    for i = 1, frequency do
        local direction = (i % 2 == 0) and 1 or -1
        local offset = direction * intensity
        
        -- Adjust intensity to create a dampening effect
        intensity = intensity * 0.9
        
        -- Random offset for a more natural shake
        local randomOffset = math.random(-2, 2)
        
        -- Side to side shake
        self:CreateTranslationAnimation(group, offset + randomOffset, 0, step, i, "IN_OUT")
    end
    
    -- Final animation to return to original position
    self:CreateTranslationAnimation(group, 0, 0, step, frequency + 1, "IN_OUT")
    
    -- Store the onFinished callback
    frame.VUIAnimationOnFinished = onFinished
    
    -- Show the frame and start animation
    frame:Show()
    group:Play()
    
    -- Track this animation
    frame.isVUIAnimating = true
    animating[frame] = "SHAKE"
    
    return group
end

-- Create a panning zoom effect (good for frame emphasis)
function VUI.Animations:PanAndZoom(frame, duration, onFinished, options)
    if not frame then return end
    
    duration = duration or 1.0
    options = options or {}
    local zoomFactor = options.zoomFactor or 1.1
    local panX = options.panX or 10
    local panY = options.panY or 0
    
    -- Setup the animation
    local group = self:GetAnimationGroup(frame)
    
    -- Create zoom in and pan
    self:CreateScaleAnimation(group, 1, 1, zoomFactor, zoomFactor, duration/2, 1, "OUT")
    self:CreateTranslationAnimation(group, panX, panY, duration/2, 1, "OUT")
    
    -- Create zoom out and pan back
    self:CreateScaleAnimation(group, zoomFactor, zoomFactor, 1, 1, duration/2, 2, "IN")
    self:CreateTranslationAnimation(group, -panX, -panY, duration/2, 2, "IN")
    
    -- Store the onFinished callback
    frame.VUIAnimationOnFinished = onFinished
    
    -- Show the frame and start animation
    frame:Show()
    group:Play()
    
    -- Track this animation
    frame.isVUIAnimating = true
    animating[frame] = "PAN_AND_ZOOM"
    
    return group
end

-- Flash animation - useful for alerts or highlights
function VUI.Animations:Flash(frame, duration, onFinished, options)
    if not frame then return end
    
    duration = duration or 0.5
    options = options or {}
    local flashes = options.flashes or 3
    local color = options.color or {1, 0, 0, 1} -- Default red flash
    
    -- Ensure the frame has a texture to flash
    local texture = frame.flashTexture
    if not texture then
        texture = frame:CreateTexture(nil, "OVERLAY")
        texture:SetAllPoints()
        texture:SetTexture("Interface\\Buttons\\WHITE8x8")
        texture:SetBlendMode("ADD")
        texture:SetVertexColor(unpack(color))
        texture:SetAlpha(0)
        frame.flashTexture = texture
    end
    
    -- Setup the animation
    local group = self:GetAnimationGroup(frame)
    
    -- Create flash animations
    local flashDuration = duration / (flashes * 2)
    for i = 1, flashes do
        -- Flash in
        local fadeIn = group:CreateAnimation("Alpha")
        fadeIn:SetTarget(texture)
        fadeIn:SetFromAlpha(0)
        fadeIn:SetToAlpha(0.5)
        fadeIn:SetDuration(flashDuration)
        fadeIn:SetOrder(i * 2 - 1)
        fadeIn:SetSmoothing("IN")
        
        -- Flash out
        local fadeOut = group:CreateAnimation("Alpha")
        fadeOut:SetTarget(texture)
        fadeOut:SetFromAlpha(0.5)
        fadeOut:SetToAlpha(0)
        fadeOut:SetDuration(flashDuration)
        fadeOut:SetOrder(i * 2)
        fadeOut:SetSmoothing("OUT")
    end
    
    -- Store the onFinished callback
    frame.VUIAnimationOnFinished = onFinished
    
    -- Show the frame and start animation
    frame:Show()
    group:Play()
    
    -- Track this animation
    frame.isVUIAnimating = true
    animating[frame] = "FLASH"
    
    return group
end

-- Slide transition - For switching between visible frames
function VUI.Animations:SlideTransition(oldFrame, newFrame, direction, duration, onFinished, options)
    if not oldFrame or not newFrame then return end
    
    duration = duration or 0.4
    options = options or {}
    local distance = options.distance or (oldFrame:GetWidth() + 20)
    
    -- Determine offsets based on direction
    local oldOffsetX, oldOffsetY = 0, 0
    local newOffsetX, newOffsetY = 0, 0
    
    if direction == "LEFT" then
        oldOffsetX = -distance
        newOffsetX = distance
    elseif direction == "RIGHT" then
        oldOffsetX = distance
        newOffsetX = -distance
    elseif direction == "UP" then
        oldOffsetY = distance
        newOffsetY = -distance
    elseif direction == "DOWN" then
        oldOffsetY = -distance
        newOffsetY = distance
    end
    
    -- Position the new frame
    newFrame:ClearAllPoints()
    newFrame:SetPoint(oldFrame:GetPoint(1))
    newFrame:SetAlpha(0)
    newFrame:Show()
    
    -- Slide out the old frame
    self:SlideOut(oldFrame, direction, duration, nil, {
        offsetX = oldOffsetX,
        offsetY = oldOffsetY,
        hideOnFinish = true
    })
    
    -- Slide in the new frame
    self:SlideIn(newFrame, (direction == "LEFT" and "RIGHT") or
                          (direction == "RIGHT" and "LEFT") or
                          (direction == "UP" and "DOWN") or
                          (direction == "DOWN" and "UP"), 
                 duration, onFinished, {
        offsetX = newOffsetX,
        offsetY = newOffsetY
    })
end

-- Check if a frame is currently being animated
function VUI.Animations:IsAnimating(frame)
    return frame and frame.isVUIAnimating or false
end

-- Get the type of animation currently running on a frame
function VUI.Animations:GetAnimationType(frame)
    return frame and animating[frame]
end

-- Register a frame for showing/hiding with animations
function VUI.Animations:RegisterFrame(frame, showPreset, hidePreset, showOptions, hideOptions)
    if not frame then return end
    
    -- Default presets if not provided
    showPreset = showPreset or self.Presets.FADE_IN
    hidePreset = hidePreset or self.Presets.FADE_OUT
    
    -- Default options
    showOptions = showOptions or {}
    hideOptions = hideOptions or {}
    
    -- Store original Show/Hide methods
    frame.VUIOriginalShow = frame.VUIOriginalShow or frame.Show
    frame.VUIOriginalHide = frame.VUIOriginalHide or frame.Hide
    
    -- Override Show method
    frame.Show = function(self, ...)
        if self:IsShown() and not self.isVUIAnimating then return end
        
        -- Stop any existing animations
        VUI.Animations:StopAnimations(self)
        
        -- Apply show animation
        if showPreset then
            VUI.Animations:ApplyPreset(self, showPreset, nil, showOptions.duration, showOptions)
        else
            -- Call original show if no animation
            self:VUIOriginalShow(...)
        end
    end
    
    -- Override Hide method
    frame.Hide = function(self, ...)
        if not self:IsShown() then return end
        
        -- Apply hide animation
        if hidePreset and self:IsVisible() then
            VUI.Animations:ApplyPreset(self, hidePreset, function()
                self:VUIOriginalHide(...)
            end, hideOptions.duration, hideOptions)
        else
            -- Call original hide if no animation
            self:VUIOriginalHide(...)
        end
    end
    
    return frame
end

-- Restore original Show/Hide methods for a frame
function VUI.Animations:UnregisterFrame(frame)
    if not frame then return end
    
    -- Restore original methods if they exist
    if frame.VUIOriginalShow then
        frame.Show = frame.VUIOriginalShow
        frame.VUIOriginalShow = nil
    end
    
    if frame.VUIOriginalHide then
        frame.Hide = frame.VUIOriginalHide
        frame.VUIOriginalHide = nil
    end
    
    return frame
end