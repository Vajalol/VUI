-- VUICC: Shine effect
-- Adapted from OmniCC (https://github.com/tullamods/OmniCC)

local AddonName, Addon = "VUI", VUI
local Module = Addon:GetModule("VUICC")

-- Create a shine animation for an icon
local function createShineAnimation(frame)
    local shine = CreateFrame('Frame', nil, frame)
    shine:SetPoint('TOPLEFT', -16, 8)
    shine:SetPoint('BOTTOMRIGHT', 16, -8)
    shine:SetAlpha(0)

    -- Shine texture
    local texture = shine:CreateTexture(nil, 'OVERLAY')
    texture:SetPoint('CENTER')
    texture:SetWidth(frame:GetWidth() * 2)
    texture:SetHeight(frame:GetHeight() * 2)
    texture:SetTexture("Interface\\Cooldown\\star4")
    texture:SetBlendMode('ADD')

    -- Animation group
    local animGroup = shine:CreateAnimationGroup()
    animGroup:SetLooping('NONE')

    -- Fade-in
    local fadeIn = animGroup:CreateAnimation('Alpha')
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(1)
    fadeIn:SetDuration(0.2)
    fadeIn:SetOrder(1)

    -- Rotation
    local rotation = animGroup:CreateAnimation('Rotation')
    rotation:SetDegrees(-90)
    rotation:SetDuration(0.3)
    rotation:SetOrder(1)

    -- Fade-out
    local fadeOut = animGroup:CreateAnimation('Alpha')
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(0.3)
    fadeOut:SetOrder(2)

    -- Reset on finish
    animGroup:SetScript('OnFinished', function()
        shine:Hide()
    end)

    -- Play function
    shine.Play = function()
        shine:Show()
        animGroup:Play()
    end

    return shine
end

-- Get the icon from a cooldown frame
local function getIcon(cooldown)
    local icon = Module:GetButtonIcon(cooldown:GetParent())
    if not icon then return end
    
    return icon
end

-- Register the shine effect
Module.FX:Register('shine', function(cooldown, options)
    options = options or {}

    -- Find the icon
    local icon = getIcon(cooldown)
    if not icon then return end

    -- Create or retrieve shine animation
    local shine = icon._occ_shine
    if not shine then
        shine = createShineAnimation(icon)
        icon._occ_shine = shine
    end

    -- Play the animation
    shine:Play()
end)