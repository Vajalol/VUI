-- VUITGCD BlocklistFrame.lua
-- Implementation of the blocklist UI frame

local _, ns = ...
local VUITGCD = _G.VUI and _G.VUI.TGCD or {}

-- Define namespace
if not ns.blocklistFrame then ns.blocklistFrame = {} end

-- Frame reference
ns.blocklistFrame.frame = nil

-- Initialize the blocklist frame
function ns.blocklistFrame.Initialize()
    -- Blocklist UI will be integrated with the VUI config system
    -- This module just provides sync capabilities
end

-- Sync UI with current settings
function ns.blocklistFrame.syncWithSettings()
    -- Settings are primarily managed through the VUI config system
    -- This function exists for compatibility with the original TrufiGCD code structure
end

-- Show the blocklist frame
function ns.blocklistFrame.Show()
    -- Open the VUI config panel at the TGCD section, Blocklist tab
    if _G.VUI and _G.VUI.Config then
        _G.VUI.Config:Open("VUITGCD")
        -- TODO: Open specific blocklist tab once implemented
    end
end

-- Hide the blocklist frame
function ns.blocklistFrame.Hide()
    -- Close the VUI config panel
    if _G.VUI and _G.VUI.Config then
        _G.VUI.Config:Close()
    end
end

-- Export to global if needed
if _G.VUI then
    _G.VUI.TGCD.BlocklistFrame = ns.blocklistFrame
end

-- Initialize
ns.blocklistFrame.Initialize()