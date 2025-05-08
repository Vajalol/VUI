-- VUITGCD SettingsFrame.lua
-- Implementation of the main settings UI frame

local _, ns = ...
local VUITGCD = _G.VUI and _G.VUI.TGCD or {}

-- Define namespace
if not ns.settingsFrame then ns.settingsFrame = {} end

-- Frame reference
ns.settingsFrame.frame = nil

-- Initialize the settings frame
function ns.settingsFrame.Initialize()
    -- Settings will be primarily handled through the VUI config system
    -- This module just provides sync capabilities
end

-- Sync UI with current settings
function ns.settingsFrame.syncWithSettings()
    -- Settings are primarily managed through the VUI config system
    -- This function exists for compatibility with the original TrufiGCD code structure
end

-- Show the settings frame
function ns.settingsFrame.Show()
    -- Open the VUI config panel at the TGCD section
    if _G.VUI and _G.VUI.Config then
        _G.VUI.Config:Open("VUITGCD")
    end
end

-- Hide the settings frame
function ns.settingsFrame.Hide()
    -- Close the VUI config panel
    if _G.VUI and _G.VUI.Config then
        _G.VUI.Config:Close()
    end
end

-- Export to global if needed
if _G.VUI then
    _G.VUI.TGCD.SettingsFrame = ns.settingsFrame
end

-- Initialize
ns.settingsFrame.Initialize()