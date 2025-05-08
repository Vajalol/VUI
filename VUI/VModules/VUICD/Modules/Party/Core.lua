local AddOnName, NS = ...
local VUICD, L, db = NS:unpack()
local P = VUICD.Party

-- Local variables
local partyFrames = {}
local activeMembers = {}
local activeSpells = {}
local isEnabled = false
local testMode = false

-- Initialize the Party module
function P:Initialize()
    -- Create main container frame
    self.container = CreateFrame("Frame", "VUICD_PartyContainer", UIParent)
    self.container:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    self.container:SetSize(200, 100)
    self.container:Hide()
    
    -- Initialize settings
    self.db = VUICD:GetPartySettings()
    
    -- Initialize spells
    if VUICD.Cooldowns and VUICD.Cooldowns.Initialize then
        VUICD.Cooldowns:Initialize()
    end
    
    -- Register events
    self.container:SetScript("OnEvent", function(_, event, ...)
        if self[event] then
            self[event](self, ...)
        end
    end)
    
    self.container:RegisterEvent("GROUP_ROSTER_UPDATE")
    self.container:RegisterEvent("PLAYER_ENTERING_WORLD")
    
    -- Initialize visibility
    self:UpdateVisibility(VUICD.instanceType)
end

-- Enable the Party module
function P:Enable()
    if isEnabled then return end
    isEnabled = true
    
    self.container:Show()
    self:UpdateRoster()
end

-- Disable the Party module
function P:Disable()
    if not isEnabled then return end
    isEnabled = false
    
    self.container:Hide()
    self:ClearFrames()
end

-- Update module visibility based on instance type
function P:UpdateVisibility(instanceType)
    local shouldShow = false
    
    if testMode and self.db.visibility.inTest then
        shouldShow = true
    elseif instanceType == "arena" then
        shouldShow = self.db.visibility.arena
    elseif instanceType == "raid" then
        shouldShow = self.db.visibility.raid
    elseif instanceType == "party" then
        shouldShow = self.db.visibility.party
    elseif instanceType == "scenario" then
        shouldShow = self.db.visibility.scenario
    elseif instanceType == "none" then
        shouldShow = self.db.visibility.none
    else
        shouldShow = self.db.visibility.outside
    end
    
    if shouldShow and self.db.enabled then
        self:Enable()
    else
        self:Disable()
    end
end

-- Update the roster when group composition changes
function P:UpdateRoster()
    if not isEnabled then return end
    
    -- Clear current frames
    self:ClearFrames()
    
    -- Check if we're in a group
    if not IsInGroup() and not testMode then
        return
    end
    
    -- Build active member list
    self:BuildMemberList()
    
    -- Create frames for each member
    self:CreateMemberFrames()
    
    -- Update cooldown data
    self:UpdateCooldowns()
end

-- Build list of active group members
function P:BuildMemberList()
    wipe(activeMembers)
    
    if testMode then
        -- Add test players
        table.insert(activeMembers, {name = "TestWarrior", class = "WARRIOR", unit = "player"})
        table.insert(activeMembers, {name = "TestPaladin", class = "PALADIN", unit = "player"})
        table.insert(activeMembers, {name = "TestHunter", class = "HUNTER", unit = "player"})
        table.insert(activeMembers, {name = "TestRogue", class = "ROGUE", unit = "player"})
        table.insert(activeMembers, {name = "TestPriest", class = "PRIEST", unit = "player"})
    else
        -- Add actual group members
        local prefix = IsInRaid() and "raid" or "party"
        local numMembers = IsInRaid() and GetNumGroupMembers() or GetNumGroupMembers() - 1
        
        -- Add player
        local playerName = UnitName("player")
        local _, playerClass = UnitClass("player")
        table.insert(activeMembers, {name = playerName, class = playerClass, unit = "player"})
        
        -- Add group members
        for i = 1, numMembers do
            local unit = prefix .. i
            if UnitExists(unit) then
                local name = UnitName(unit)
                local _, class = UnitClass(unit)
                table.insert(activeMembers, {name = name, class = class, unit = unit})
            end
        end
    end
end

-- Create frames for each member
function P:CreateMemberFrames()
    -- Implementation will be expanded
end

-- Clear existing frames
function P:ClearFrames()
    for _, frame in pairs(partyFrames) do
        frame:Hide()
    end
    wipe(partyFrames)
end

-- Update cooldown data
function P:UpdateCooldowns()
    -- Implementation will be expanded
end

-- Toggle test mode
function P:Test()
    testMode = not testMode
    self:UpdateVisibility(VUICD.instanceType)
    
    if testMode then
        print("|cff33ff99VUICD|r: Test mode |cff00ff00enabled|r")
    else
        print("|cff33ff99VUICD|r: Test mode |cffff0000disabled|r")
    end
end