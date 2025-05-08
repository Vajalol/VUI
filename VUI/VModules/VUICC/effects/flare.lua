-- VUICC: Flare effect
-- Adapted from OmniCC (https://github.com/tullamods/OmniCC)

local AddonName, Addon = "VUI", VUI
local Module = Addon:GetModule("VUICC")

-- Create a flare animation for an icon
local function createFlareAnimation(frame)
    local flare = CreateFrame('Frame', nil, frame)
    flare:SetPoint('CENTER')
    flare:SetSize(frame:GetWidth(), frame:GetHeight())
    flare:SetAlpha(0)
    flare:Hide()
    
    -- Flare texture
    local texture = flare:CreateTexture(nil, 'OVERLAY')
    texture:SetPoint('CENTER')
    texture:SetAllPoints(flare)
    texture:SetTexture("Interface\\AddOns\\VUI\\Media\\modules\\VUICC\\flare")
    texture:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)
    texture:SetBlendMode('ADD')
    
    -- Animation group
    local animGroup = flare:CreateAnimationGroup()
    animGroup:SetLooping('NONE')
    
    -- Fade in and scale up
    local fadeIn = animGroup:CreateAnimation('Alpha')
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(1)
    fadeIn:SetDuration(0.3)
    fadeIn:SetOrder(1)
    
    local scaleIn = animGroup:CreateAnimation('Scale')
    scaleIn:SetFromScale(0.5, 0.5)
    scaleIn:SetToScale(1.5, 1.5)
    scaleIn:SetDuration(0.3)
    scaleIn:SetOrder(1)
    
    -- Fade out
    local fadeOut = animGroup:CreateAnimation('Alpha')
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(0.3)
    fadeOut:SetOrder(2)
    
    -- Reset on finish
    animGroup:SetScript('OnFinished', function()
        flare:Hide()
    end)
    
    -- Play function
    flare.Play = function()
        flare:Show()
        animGroup:Play()
    end
    
    return flare
end

-- Get the icon from a cooldown frame
local function getIcon(cooldown)
    local icon = Module:GetButtonIcon(cooldown:GetParent())
    if not icon then return end
    
    return icon
end

-- Register the flare effect
Module.FX:Register('flare', function(cooldown, options)
    options = options or {}
    
    -- Find the icon
    local icon = getIcon(cooldown)
    if not icon then return end
    
    -- Create or retrieve flare animation
    local flare = icon._occ_flare
    if not flare then
        flare = createFlareAnimation(icon)
        icon._occ_flare = flare
    end
    
    -- Play the animation
    flare:Play()
end)