local AddOnName, NS = ...
local VUICD, L, db = NS:unpack()
local P = VUICD.Party
local V = {}
P.Visibility = V

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
            self[event](self, ...)
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
    local settings = VUICD:GetPartySettings().visibility
    local shouldShow = false
    
    -- Check instance type
    if P.testMode and settings.inTest then
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
    self:UpdateDisplay()
end

-- Update display based on visibility
function V:UpdateDisplay()
    if isVisible and VUICD:GetPartySettings().enabled then
        P:Enable()
    else
        P:Disable()
    end
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