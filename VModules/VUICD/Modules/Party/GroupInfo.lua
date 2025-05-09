local AddOnName, NS = ...
local VUICD, L, db = NS:unpack()
local P = VUICD.Party
local GI = {}
P.GroupInfo = GI

-- Local variables
local groupMembers = {}
local groupGUIDs = {}
local playerClass = select(2, UnitClass("player"))
local playerName = UnitName("player")

-- Initialize group info
function GI:Initialize()
    -- Register events
    self.frame = CreateFrame("Frame")
    self.frame:SetScript("OnEvent", function(_, event, ...)
        if self[event] then
            self[event](self, ...)
        end
    end)
    
    self.frame:RegisterEvent("GROUP_ROSTER_UPDATE")
    self.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    
    -- Initial update
    self:UpdateGroupInfo()
end

-- Update group information
function GI:UpdateGroupInfo()
    wipe(groupMembers)
    wipe(groupGUIDs)
    
    -- Add player
    local playerGUID = UnitGUID("player")
    if playerGUID then
        groupMembers[playerGUID] = {
            name = playerName,
            class = playerClass,
            unit = "player",
            guid = playerGUID,
            isPlayer = true
        }
        groupGUIDs[playerName] = playerGUID
    end
    
    -- Add group members
    if IsInGroup() then
        local prefix = IsInRaid() and "raid" or "party"
        local numMembers = IsInRaid() and GetNumGroupMembers() or GetNumGroupMembers()
        
        for i = 1, numMembers do
            local unit = prefix .. i
            if UnitExists(unit) and not UnitIsUnit(unit, "player") then
                local name = UnitName(unit)
                local _, class = UnitClass(unit)
                local guid = UnitGUID(unit)
                
                if guid and name and class then
                    groupMembers[guid] = {
                        name = name,
                        class = class,
                        unit = unit,
                        guid = guid,
                        isPlayer = false
                    }
                    groupGUIDs[name] = guid
                end
            end
        end
    end
    
    -- Update inspector
    if P.Inspect then
        for guid, info in pairs(groupMembers) do
            P.Inspect:QueueInspect(info.unit)
        end
    end
    
    -- Update cooldown tracker
    if P.CD then
        P.CD:InitializeSpells()
    end
    
    -- Update roster
    P:UpdateRoster()
end

-- Get all group members
function GI:GetGroupMembers()
    return groupMembers
end

-- Get member info by GUID
function GI:GetMemberInfo(guid)
    return groupMembers[guid]
end

-- Get member info by name
function GI:GetMemberInfoByName(name)
    local guid = groupGUIDs[name]
    if guid then
        return groupMembers[guid]
    end
    return nil
end

-- Get player info
function GI:GetPlayerInfo()
    local playerGUID = UnitGUID("player")
    return groupMembers[playerGUID]
end

-- Event handlers
function GI:GROUP_ROSTER_UPDATE()
    self:UpdateGroupInfo()
end

function GI:PLAYER_ENTERING_WORLD()
    self:UpdateGroupInfo()
end