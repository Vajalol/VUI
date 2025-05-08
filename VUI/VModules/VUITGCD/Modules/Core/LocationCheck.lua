-- VUITGCD LocationCheck.lua
-- Handles logic for when and where ability tracking should be active

local _, ns = ...
local VUITGCD = _G.VUI and _G.VUI.TGCD or {}

-- Define namespace
if not ns.locationCheck then ns.locationCheck = {} end

-- Current state
ns.locationCheck.inInstance = false
ns.locationCheck.instanceType = nil
ns.locationCheck.inCombat = false
ns.locationCheck.isPvP = false
ns.locationCheck.isEnabled = true

-- Frame for event handling
ns.locationCheck.frame = CreateFrame("Frame")

-- Initialize location checking
function ns.locationCheck.Initialize()
    local frame = ns.locationCheck.frame
    
    -- Register necessary events
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    
    -- Set event handler
    frame:SetScript("OnEvent", ns.locationCheck.OnEvent)
    
    -- Initial check
    ns.locationCheck.CheckLocation()
end

-- Event handler
function ns.locationCheck.OnEvent(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
        ns.locationCheck.CheckLocation()
    elseif event == "PLAYER_REGEN_DISABLED" then
        ns.locationCheck.inCombat = true
        ns.locationCheck.UpdateState()
    elseif event == "PLAYER_REGEN_ENABLED" then
        ns.locationCheck.inCombat = false
        ns.locationCheck.UpdateState()
    end
end

-- Check current location
function ns.locationCheck.CheckLocation()
    -- Check if in instance
    local inInstance, instanceType = IsInInstance()
    ns.locationCheck.inInstance = inInstance
    ns.locationCheck.instanceType = instanceType
    
    -- Check if in PvP
    ns.locationCheck.isPvP = (instanceType == "pvp" or instanceType == "arena")
    
    -- Update state
    ns.locationCheck.UpdateState()
end

-- Update tracking state based on location and settings
function ns.locationCheck.UpdateState()
    if not ns.settings or not ns.settings.activeProfile then
        return
    end
    
    local profile = ns.settings.activeProfile
    local shouldEnable = false
    
    -- Default to enabled
    shouldEnable = true
    
    -- Check conditions for disabling
    if profile.disableOutOfCombat and not ns.locationCheck.inCombat then
        shouldEnable = false
    end
    
    if profile.disableInCities and (ns.locationCheck.instanceType == "none" and select(2, IsInInstance()) == "city") then
        shouldEnable = false
    end
    
    -- Check instance-specific settings
    if ns.locationCheck.inInstance then
        if ns.locationCheck.instanceType == "party" and not profile.enableInDungeons then
            shouldEnable = false
        elseif ns.locationCheck.instanceType == "raid" and not profile.enableInRaids then
            shouldEnable = false
        elseif ns.locationCheck.isPvP and not profile.enableInPvP then
            shouldEnable = false
        end
    else
        -- Open world
        if not profile.enableInWorld then
            shouldEnable = false
        end
    end
    
    -- Apply the state
    ns.locationCheck.isEnabled = shouldEnable
    ns.locationCheck.ApplyState()
end

-- Apply the current state to all units
function ns.locationCheck.ApplyState()
    if not ns.units then
        return
    end
    
    for _, unit in pairs(ns.units) do
        if unit and unit.container then
            if ns.locationCheck.isEnabled and unit.enabled then
                unit.container:Show()
            else
                unit.container:Hide()
            end
        end
    end
end

-- Called when settings change
function ns.locationCheck.settingsChanged()
    ns.locationCheck.UpdateState()
end

-- Export to global if needed
if _G.VUI then
    _G.VUI.TGCD.LocationCheck = ns.locationCheck
end

-- Initialize on load
ns.locationCheck.Initialize()