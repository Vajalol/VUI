local AddonName, VUI = ...
local MODNAME = "VUIPositionOfPower"

-- Check if VUI exists before proceeding
if not VUI then return end

local M = VUI and VUI:GetModule(MODNAME)
if not M then return end 