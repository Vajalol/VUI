-- VUICC: No effect implementation
-- Adapted from OmniCC (https://github.com/tullamods/OmniCC)

local AddonName, Addon = "VUI", VUI
local Module = Addon:GetModule("VUICC")

-- Register the "none" effect (does nothing)
Module.FX:Register('none', function() end)