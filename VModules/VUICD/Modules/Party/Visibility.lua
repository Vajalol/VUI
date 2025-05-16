local AddOnName, NS = ...

-- Use global reference pattern to avoid load order issues
_G["VUICD"] = _G["VUICD"] or {}
local VUICD = _G["VUICD"]

-- Ensure Party module is initialized
VUICD.Party = VUICD.Party or {}

-- Get localization through global reference or fallback
local L = VUICD.L or {}

-- Get database reference with safety check
local db = VUICD.db or {}
local P = VUICD.Party or {}
P.Visibility = P.Visibility or {}
local V = P.Visibility

-- Local variables
local currentInstanceType = "none"
local currentZoneType = "none"
local isVisible = false
local inCombat = false

-- Initialize visibility
function V:Initialize()
    -- Register events
    self.frame = CreateFrame("Frame")
    self.frame:SetScript("OnEvent", function(_, event, ...)
        if self[event] then
            local args = {...}
            pcall(function() 
                if #args > 0 then
                    self[event](self, unpack(args))
                else
                    self[event](self)
                end
            end)
        end
    end)
    
    self.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    self.frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    self.frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    
    -- Initial update
    self:Update()
end

-- Update visibility based on current conditions
function V:Update()
    -- Safety check - ensure VUICD is properly initialized
    if not VUICD then
        return
    end
    
    -- Safely get party settings with fallbacks
    local settings = {}
    if VUICD and VUICD.GetPartySettings and type(VUICD.GetPartySettings) == "function" then
        local success, result = pcall(function() return VUICD.GetPartySettings() end)
        if success and result and result.visibility then
            settings = result.visibility
        else
            -- Fallback default settings
            settings = {
                arena = true,
                raid = true,
                party = true,
                scenario = true,
                none = false,
                outside = false,
                inTest = true
            }
        end
    else
        -- Fallback default settings if GetPartySettings doesn't exist
        settings = {
            arena = true,
            raid = true,
            party = true,
            scenario = true,
            none = false,
            outside = false,
            inTest = true
        }
    end
    
    local shouldShow = false
    
    -- Check if P exists before accessing its properties
    local testMode = P and P.testMode
    
    -- Check instance type
    if testMode and settings.inTest then
        shouldShow = true
    elseif currentInstanceType == "arena" then
        shouldShow = settings.arena
    elseif currentInstanceType == "pvp" then
        shouldShow = settings.raid
    elseif currentInstanceType == "raid" then
        shouldShow = settings.raid
    elseif currentInstanceType == "party" then
        shouldShow = settings.party
    elseif currentInstanceType == "scenario" then
        shouldShow = settings.scenario
    elseif currentInstanceType == "none" then
        shouldShow = settings.none
    else
        shouldShow = settings.outside
    end
    
    -- Update visibility
    isVisible = shouldShow
    
    -- Update display
    pcall(function() self:UpdateDisplay() end)
end

-- Update display based on visibility
function V:UpdateDisplay()
    -- Safety check - ensure P module exists before calling methods
    if not P then
        return
    end
    
    -- Check if Enable/Disable methods exist before calling them
    local canEnable = P.Enable and type(P.Enable) == "function"
    local canDisable = P.Disable and type(P.Disable) == "function"
    
    -- Get party settings safely
    local isEnabled = false
    if VUICD and VUICD.GetPartySettings and type(VUICD.GetPartySettings) == "function" then
        local success, settings = pcall(function() return VUICD.GetPartySettings() end)
        if success and settings then
            isEnabled = settings.enabled
        end
    end
    
    -- More explicit safety check to prevent nil index errors
    if not isVisible or not isEnabled or not canEnable then
        if canDisable then
            pcall(function() P:Disable() end)
        end
        return
    end
    
    -- Safe enable with pcall
    pcall(function() P:Enable() end)
end

-- Check if the module should be visible
function V:IsVisible()
    return isVisible
end

-- Update instance information
function V:UpdateInstanceInfo()
    local _, instanceType, difficultyID, _, _, _, _, instanceID = GetInstanceInfo()
    
    -- Set instance type
    currentInstanceType = instanceType
    
    -- Check if we're in a Mythic+ dungeon
    local isMythicPlus = false
    if difficultyID == 8 then -- Mythic Keystone
        isMythicPlus = true
    end
    
    -- Check specific zones (like cities)
    local zoneText = GetRealZoneText()
    if zoneText == "Orgrimmar" or 
       zoneText == "Stormwind City" or 
       zoneText == "Dalaran" or 
       zoneText == "Oribos" or 
       zoneText == "Valdrakken" then
        currentZoneType = "city"
    else
        currentZoneType = "none"
    end
    
    -- Update visibility
    self:Update()
end

-- Event handlers
function V:PLAYER_ENTERING_WORLD()
    self:UpdateInstanceInfo()
end

function V:ZONE_CHANGED_NEW_AREA()
    self:UpdateInstanceInfo()
end

function V:PLAYER_REGEN_DISABLED()
    inCombat = true
    self:Update()
end

function V:PLAYER_REGEN_ENABLED()
    inCombat = false
    self:Update()
end