-- VUI OmniCC Animation System
local _, VUI = ...
local OmniCC = VUI.omnicc

-- Animation helper functions
local function CreateAnimationGroup(parent, onFinished)
    local group = parent:CreateAnimationGroup()
    if onFinished then
        group:SetScript("OnFinished", onFinished)
    end
    return group
end

local function CreateAlpha(group, fromAlpha, toAlpha, duration, order, smoothType)
    local anim = group:CreateAnimation("Alpha")
    anim:SetFromAlpha(fromAlpha)
    anim:SetToAlpha(toAlpha)
    anim:SetDuration(duration)
    if order then anim:SetOrder(order) end
    if smoothType then anim:SetSmoothing(smoothType) end
    return anim
end

local function CreateScale(group, fromScaleX, fromScaleY, toScaleX, toScaleY, duration, order, smoothType)
    local anim = group:CreateAnimation("Scale")
    anim:SetFromScale(fromScaleX, fromScaleY)
    anim:SetToScale(toScaleX, toScaleY)
    anim:SetDuration(duration)
    if order then anim:SetOrder(order) end
    if smoothType then anim:SetSmoothing(smoothType) end
    return anim
end

local function CreateRotation(group, degrees, duration, order, smoothType)
    local anim = group:CreateAnimation("Rotation")
    anim:SetDegrees(degrees)
    anim:SetDuration(duration)
    if order then anim:SetOrder(order) end
    if smoothType then anim:SetSmoothing(smoothType) end
    return anim
end

-- Animation Effect Library
OmniCC.animationEffects = {}

-- Pulse effect
function OmniCC.animationEffects:CreatePulseEffect(parent, size)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetPoint("CENTER", parent, "CENTER", 0, 0)
    frame:SetSize(size, size)
    
    local texture = frame:CreateTexture(nil, "OVERLAY")
    texture:SetAllPoints()
    texture:SetTexture(OmniCC:GetThemeTexture("pulse"))
    texture:SetBlendMode("ADD")
    
    -- Store parent relationship and texture
    frame.parent = parent
    frame.texture = texture
    
    -- Create animation group
    local group = CreateAnimationGroup(frame, function()
        frame:Hide()
    end)
    
    -- Create animations
    local scale = CreateScale(group, 0.1, 0.1, 2.0, 2.0, 0.5, 1, "OUT")
    local alpha1 = CreateAlpha(group, 0, 0.7, 0.25, 1, "OUT")
    local alpha2 = CreateAlpha(group, 0.7, 0, 0.25, 2, "IN")
    
    -- Set up effect control functions
    frame.Play = function(self)
        local theme = OmniCC:GetCurrentTheme()
        local duration = theme and theme.effects and theme.effects.pulseDuration or 0.5
        
        scale:SetDuration(duration)
        alpha1:SetDuration(duration / 2)
        alpha2:SetDuration(duration / 2)
        
        local color = theme and theme.effects and theme.effects.finishColor or {r = 0.0, g = 0.6, b = 1.0, a = 0.7}
        texture:SetVertexColor(color.r, color.g, color.b, color.a)
        
        self:Show()
        group:Play()
    end
    
    return frame
end

-- Shine effect
function OmniCC.animationEffects:CreateShineEffect(parent, size)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetPoint("CENTER", parent, "CENTER", 0, 0)
    frame:SetSize(size, size)
    
    local texture = frame:CreateTexture(nil, "OVERLAY")
    texture:SetAllPoints()
    texture:SetTexture(OmniCC:GetThemeTexture("shine"))
    texture:SetBlendMode("ADD")
    
    -- Store parent relationship and texture
    frame.parent = parent
    frame.texture = texture
    
    -- Create animation group
    local group = CreateAnimationGroup(frame, function()
        frame:Hide()
    end)
    
    -- Create animations
    local rotation = CreateRotation(group, 360, 0.6, 1, "OUT")
    local alpha1 = CreateAlpha(group, 0, 1.0, 0.3, 1, "OUT")
    local alpha2 = CreateAlpha(group, 1.0, 0, 0.3, 2, "IN")
    
    -- Set up effect control functions
    frame.Play = function(self)
        local theme = OmniCC:GetCurrentTheme()
        local duration = theme and theme.effects and theme.effects.shineDuration or 0.6
        
        rotation:SetDuration(duration)
        alpha1:SetDuration(duration / 2)
        alpha2:SetDuration(duration / 2)
        
        local color = theme and theme.effects and theme.effects.finishColor or {r = 0.0, g = 0.6, b = 1.0, a = 0.7}
        texture:SetVertexColor(color.r, color.g, color.b, color.a)
        
        self:Show()
        group:Play()
    end
    
    return frame
end

-- Flare effect
function OmniCC.animationEffects:CreateFlareEffect(parent, size)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetPoint("CENTER", parent, "CENTER", 0, 0)
    frame:SetSize(size * 1.5, size * 1.5)
    
    local texture = frame:CreateTexture(nil, "OVERLAY")
    texture:SetAllPoints()
    texture:SetTexture(OmniCC:GetThemeTexture("flare"))
    texture:SetBlendMode("ADD")
    
    -- Store parent relationship and texture
    frame.parent = parent
    frame.texture = texture
    
    -- Create animation group
    local group = CreateAnimationGroup(frame, function()
        frame:Hide()
    end)
    
    -- Create animations
    local scale1 = CreateScale(group, 0.1, 0.1, 1.5, 1.5, 0.3, 1, "OUT")
    local scale2 = CreateScale(group, 1.5, 1.5, 0.5, 0.5, 0.3, 2, "IN")
    local alpha1 = CreateAlpha(group, 0, 0.8, 0.2, 1, "OUT")
    local alpha2 = CreateAlpha(group, 0.8, 0, 0.4, 2, "IN")
    
    -- Set up effect control functions
    frame.Play = function(self)
        local theme = OmniCC:GetCurrentTheme()
        local duration = 0.6 -- Base duration
        
        local color = theme and theme.effects and theme.effects.finishColor or {r = 0.0, g = 0.6, b = 1.0, a = 0.7}
        texture:SetVertexColor(color.r, color.g, color.b, color.a)
        
        self:Show()
        group:Play()
    end
    
    return frame
end

-- Sparkle effect
function OmniCC.animationEffects:CreateSparkleEffect(parent, size)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetPoint("CENTER", parent, "CENTER", 0, 0)
    frame:SetSize(size, size)
    
    local texture = frame:CreateTexture(nil, "OVERLAY")
    texture:SetAllPoints()
    texture:SetTexture(OmniCC:GetThemeTexture("sparkle"))
    texture:SetBlendMode("ADD")
    
    -- Store parent relationship and texture
    frame.parent = parent
    frame.texture = texture
    
    -- Create animation group
    local group = CreateAnimationGroup(frame, function()
        frame:Hide()
    end)
    
    -- Create animations
    local scale = CreateScale(group, 0.1, 0.1, 1.0, 1.0, 0.3, 1, "OUT")
    local rotation = CreateRotation(group, 90, 0.7, 1, "IN_OUT")
    local alpha1 = CreateAlpha(group, 0, 1.0, 0.2, 1, "OUT")
    local alpha2 = CreateAlpha(group, 1.0, 0, 0.5, 2, "IN")
    
    -- Set up effect control functions
    frame.Play = function(self)
        local theme = OmniCC:GetCurrentTheme()
        local duration = 0.7 -- Base duration
        
        local color = theme and theme.effects and theme.effects.finishColor or {r = 0.0, g = 0.6, b = 1.0, a = 0.7}
        texture:SetVertexColor(color.r, color.g, color.b, color.a)
        
        self:Show()
        group:Play()
    end
    
    return frame
end

-- Play finish animation for a cooldown
function OmniCC:PlayFinishAnimation(cooldown)
    if not cooldown or not self.db.animateFinish then return end
    
    local effect = self.db.effectType or "pulse"
    local size = cooldown:GetWidth()
    
    if not cooldown.finishAnimations then
        cooldown.finishAnimations = {}
    end
    
    if not cooldown.finishAnimations[effect] then
        if effect == "pulse" then
            cooldown.finishAnimations[effect] = self.animationEffects:CreatePulseEffect(cooldown, size)
        elseif effect == "shine" then
            cooldown.finishAnimations[effect] = self.animationEffects:CreateShineEffect(cooldown, size)
        elseif effect == "flare" then
            cooldown.finishAnimations[effect] = self.animationEffects:CreateFlareEffect(cooldown, size)
        elseif effect == "sparkle" then
            cooldown.finishAnimations[effect] = self.animationEffects:CreateSparkleEffect(cooldown, size)
        end
    end
    
    if cooldown.finishAnimations[effect] then
        cooldown.finishAnimations[effect]:Play()
    end
end

-- Initialize animations
function OmniCC:InitializeAnimations()
    -- This will be called when the module is initialized
    -- Any global animation setup can be done here
end