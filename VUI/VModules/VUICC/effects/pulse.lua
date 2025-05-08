-- VUICC: Pulse effect
-- Adapted from OmniCC (https://github.com/tullamods/OmniCC)

local AddonName, Addon = "VUI", VUI
local Module = Addon:GetModule("VUICC")

-- Animation functions
local function createPulseAnimation(icon)
    local group = icon:CreateAnimationGroup()
    group:SetLooping('NONE')
    
    -- Scale animation
    local grow = group:CreateAnimation('Scale')
    grow:SetOrder(1)
    grow:SetDuration(0.2)
    grow:SetFromScaleXY(1, 1)
    grow:SetToScaleXY(1.5, 1.5)
    grow:SetOrigin('CENTER', 0, 0)
    
    local shrink = group:CreateAnimation('Scale')
    shrink:SetOrder(2)
    shrink:SetDuration(0.3)
    shrink:SetFromScaleXY(1.5, 1.5)
    shrink:SetToScaleXY(1, 1)
    shrink:SetOrigin('CENTER', 0, 0)
    
    return group
end

-- Get the icon from a cooldown frame
local function getIcon(cooldown)
    local icon = Module:GetButtonIcon(cooldown:GetParent())
    if not icon then return end
    
    return icon
end

-- Register the pulse effect
Module.FX:Register('pulse', function(cooldown, options)
    options = options or {}
    
    -- Find the icon
    local icon = getIcon(cooldown)
    if not icon then return end
    
    -- Create or retrieve animation
    local animation = icon._occ_pulse
    if not animation then
        animation = createPulseAnimation(icon)
        icon._occ_pulse = animation
    end
    
    -- Prevent animation from showing during cooldown spiral
    if cooldown:GetDrawSwipe() and cooldown:GetDrawEdge() then
        local drawEdge = cooldown:GetDrawEdge()
        cooldown:SetDrawEdge(false)
        
        -- Restore original state after animation
        animation:SetScript('OnFinished', function()
            cooldown:SetDrawEdge(drawEdge)
        end)
    else
        animation:SetScript('OnFinished', nil)
    end
    
    animation:Stop()
    animation:Play()
end)