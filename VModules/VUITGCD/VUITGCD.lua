-- VUITGCD.lua
-- VUI adaptation of TrufiGCD by stevemyz@gmail.com
-- Displays recent ability history by capturing combat/ability events

local addonName, VUI = ...
local VUITGCD = {}
VUI.TGCD = VUITGCD

-- Local variables
local IS_RETAIL = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local _, ns = ...
local DEFAULT_ICON_SIZE = 30

-- Initialize namespace if necessary
if not ns then
    ns = {}
    ns.constants = {}
    ns.units = {}
end

-- Function to check if units are equal
local function areUnitsEqual(unitA, unitB)
    local nameA = UnitName(unitA)
    return nameA and nameA == UnitName(unitB) and UnitHealth(unitA) == UnitHealth(unitB)
end

-- Function to check if unit is already being tracked
local function checkIfUnitAlreadyInUse(unitType)
    for _, existedUnitType in ipairs(ns.constants.unitTypes) do
        if areUnitsEqual(unitType, existedUnitType) then
            ns.units[unitType]:Copy(ns.units[existedUnitType])
            return
        end
    end
end

-- Module initialization function
function VUITGCD:Initialize()
    -- Print initialization message
    VUI:Print("VUITGCD module initialized")
    
    -- Create frames
    local loadFrame = CreateFrame("Frame", nil, UIParent)
    loadFrame:RegisterEvent("ADDON_LOADED")
    loadFrame:SetScript("OnEvent", function(_, event, name)
        if name ~= "VUI" or event ~= "ADDON_LOADED" then
            return
        end

        -- Load settings
        if ns.settings then
            ns.settings:Load()
            
            -- Sync with settings frames if they exist
            if ns.settingsFrame and ns.settingsFrame.syncWithSettings then
                ns.settingsFrame.syncWithSettings()
            end
            
            if ns.blocklistFrame and ns.blocklistFrame.syncWithSettings then
                ns.blocklistFrame.syncWithSettings()
            end
            
            if ns.profileFrame and ns.profileFrame.syncWithSettings then
                ns.profileFrame.syncWithSettings()
            end
            
            -- Update location check if it exists
            if ns.locationCheck and ns.locationCheck.settingsChanged then
                ns.locationCheck.settingsChanged()
            end
        end

        -- Create frame for tracking target/focus changes
        local targetFocusChangeFrame = CreateFrame("Frame", nil, UIParent)
        targetFocusChangeFrame:RegisterEvent('PLAYER_TARGET_CHANGED')
        targetFocusChangeFrame:RegisterEvent('PLAYER_FOCUS_CHANGED')
        targetFocusChangeFrame:SetScript("OnEvent", function(_, changeEvent)
            if not ns.settings or not ns.units then return end
            
            if changeEvent == "PLAYER_TARGET_CHANGED" then
                if ns.units.target then ns.units.target:Clear() end
                if ns.settings.activeProfile and ns.settings.activeProfile.layoutSettings and 
                   ns.settings.activeProfile.layoutSettings.target and 
                   ns.settings.activeProfile.layoutSettings.target.enable then
                    checkIfUnitAlreadyInUse("target")
                end
            elseif changeEvent == "PLAYER_FOCUS_CHANGED" then
                if ns.units.focus then ns.units.focus:Clear() end
                if ns.settings.activeProfile and ns.settings.activeProfile.layoutSettings and 
                   ns.settings.activeProfile.layoutSettings.focus and 
                   ns.settings.activeProfile.layoutSettings.focus.enable then
                    checkIfUnitAlreadyInUse("focus")
                end
            end
        end)

        -- Setup combat event tracking
        local combatFrame = CreateFrame("Frame", nil, UIParent)
        combatFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        combatFrame:SetScript("OnEvent", function()
            if not ns.settings then return end
            
            local timestamp, event, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName = CombatLogGetCurrentEventInfo()
            
            -- Process combat events here for ability tracking
            -- Implementation to be expanded once other modules are in place
        end)
    end)
    
    -- Register with VUI config system
    VUI:RegisterModule("VUITGCD", VUITGCD, "Ability History")
end

-- Configuration function
function VUITGCD:SetupConfig()
    -- This will be integrated with the main VUI config system
    -- To be implemented
end

-- Create and register config panel
function VUITGCD:CreateConfigPanel(parent)
    local configFrame = CreateFrame("Frame", nil, parent)
    configFrame.name = "Ability History"
    
    -- Add control elements here
    -- Will be expanded later
    
    return configFrame
end

-- Setup commands
function VUITGCD:SetupCommands()
    -- Register any necessary slash commands
    -- To be implemented
end

VUI.Config:RegisterModule({
    name = "VUITGCD",
    title = "Ability History",
    desc = "Tracks and displays recently used abilities in combat",
    icon = "Interface\\Icons\\Ability_warrior_innerrage",
    notCheckable = false,
    configTable = VUITGCD
})

-- Initialize the module
VUITGCD:Initialize()