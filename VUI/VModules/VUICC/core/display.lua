-- VUICC: Display implementation
-- Adapted from OmniCC (https://github.com/tullamods/OmniCC)

local AddonName, Addon = "VUI", VUI
local Module = Addon:GetModule("VUICC")
local Display = Module.Display

-- Create a new display
function Display:New(cooldown)
    local display = CreateFrame('Frame', nil, cooldown)
    display:SetAllPoints(cooldown)
    display:SetFrameLevel(cooldown:GetFrameLevel() + 5)
    display:Hide()
    
    -- Text display
    local text = display:CreateFontString(nil, 'OVERLAY')
    display.text = text
    text:SetPoint('CENTER', 0, 0)
    
    -- Initialize defaults
    display.duration = 0
    display.waitingForEffect = nil
    display.nextUpdate = 0
    
    return display
end

-- Update module with Display methods
Module.Display = Display