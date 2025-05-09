local AddOnName, NS = ...
local VUICD, L, db = NS:unpack()
local P = VUICD.Party
local I = {}
P.Inspect = I

-- Local variables
local inspectQueue = {}
local inspecting = false
local lastInspect = 0
local inspectResults = {}

-- Initialize the inspection system
function I:Initialize()
    -- Register events
    self.frame = CreateFrame("Frame")
    self.frame:SetScript("OnEvent", function(_, event, ...)
        if self[event] then
            self[event](self, ...)
        end
    end)
    
    self.frame:RegisterEvent("INSPECT_READY")
    self.frame:RegisterEvent("GROUP_ROSTER_UPDATE")
    self.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    
    -- Initialize inspectResults table for player
    local playerGUID = UnitGUID("player")
    if playerGUID then
        -- Get player info
        local _, playerClass = UnitClass("player")
        local playerSpec = GetSpecialization()
        local playerSpecID = playerSpec and GetSpecializationInfo(playerSpec) or 0
        
        inspectResults[playerGUID] = {
            name = UnitName("player"),
            class = playerClass,
            spec = playerSpecID,
            talents = self:GetUnitTalents("player"),
            lastUpdate = GetTime()
        }
    end
end

-- Queue a unit for inspection
function I:QueueInspect(unit)
    if not unit or not UnitExists(unit) or not CanInspect(unit) then return end
    
    local guid = UnitGUID(unit)
    if not guid then return end
    
    -- Skip if we already inspected recently
    if inspectResults[guid] and inspectResults[guid].lastUpdate and (GetTime() - inspectResults[guid].lastUpdate) < 300 then
        return
    end
    
    -- Add to queue
    for i = 1, #inspectQueue do
        if inspectQueue[i] == unit then
            return -- Already queued
        end
    end
    
    table.insert(inspectQueue, unit)
    
    -- Start processing queue if not already
    if not inspecting then
        self:ProcessInspectQueue()
    end
end

-- Process the inspect queue
function I:ProcessInspectQueue()
    if #inspectQueue == 0 or inspecting then return end
    
    -- Throttle inspects
    if GetTime() - lastInspect < 1.5 then
        C_Timer.After(1.5, function() self:ProcessInspectQueue() end)
        return
    end
    
    -- Get next unit
    local unit = table.remove(inspectQueue, 1)
    if not unit or not UnitExists(unit) or not CanInspect(unit) then
        inspecting = false
        self:ProcessInspectQueue()
        return
    end
    
    -- Inspect unit
    inspecting = true
    lastInspect = GetTime()
    NotifyInspect(unit)
    
    -- Set timeout
    C_Timer.After(5, function()
        -- If we're still inspecting the same unit after 5 seconds, something went wrong
        inspecting = false
        self:ProcessInspectQueue()
    end)
end

-- Get unit talents
function I:GetUnitTalents(unit)
    if not unit or not UnitExists(unit) then return {} end
    
    local talents = {}
    
    -- Get active talents
    for i = 1, 7 do
        local _, _, _, selected, _, id = GetTalentInfo(i, 1, 1)
        if id and selected then
            talents[id] = true
        end
        
        local _, _, _, selected, _, id = GetTalentInfo(i, 2, 1)
        if id and selected then
            talents[id] = true
        end
        
        local _, _, _, selected, _, id = GetTalentInfo(i, 3, 1)
        if id and selected then
            talents[id] = true
        end
    end
    
    return talents
end

-- Get unit specialization
function I:GetUnitSpec(unit)
    if not unit or not UnitExists(unit) then return 0 end
    
    local guid = UnitGUID(unit)
    if not guid then return 0 end
    
    -- Return cached result if available
    if inspectResults[guid] and inspectResults[guid].spec then
        return inspectResults[guid].spec
    end
    
    -- For player, get current spec
    if UnitIsUnit(unit, "player") then
        local specIndex = GetSpecialization()
        if specIndex then
            local specID = GetSpecializationInfo(specIndex)
            return specID or 0
        end
    end
    
    -- Queue inspect for this unit
    self:QueueInspect(unit)
    return 0
end

-- Get unit talents
function I:HasTalent(unit, talentID)
    if not unit or not UnitExists(unit) or not talentID then return false end
    
    local guid = UnitGUID(unit)
    if not guid then return false end
    
    -- Return cached result if available
    if inspectResults[guid] and inspectResults[guid].talents and inspectResults[guid].talents[talentID] then
        return true
    end
    
    -- For player, check current talents
    if UnitIsUnit(unit, "player") then
        return self:GetUnitTalents("player")[talentID] or false
    end
    
    -- Queue inspect for this unit
    self:QueueInspect(unit)
    return false
end

-- Event handlers
function I:INSPECT_READY(guid)
    inspecting = false
    
    -- Get inspected unit
    local unit = nil
    for i = 1, 4 do
        local u = "party" .. i
        if UnitExists(u) and UnitGUID(u) == guid then
            unit = u
            break
        end
    end
    
    if not unit and UnitGUID("target") == guid then
        unit = "target"
    end
    
    if not unit then
        self:ProcessInspectQueue()
        return
    end
    
    -- Get unit info
    local name = UnitName(unit)
    local _, class = UnitClass(unit)
    local specID = 0
    
    -- Get specialization
    local currentSpec = GetInspectSpecialization(unit)
    if currentSpec and currentSpec > 0 then
        specID = currentSpec
    end
    
    -- Cache results
    inspectResults[guid] = {
        name = name,
        class = class,
        spec = specID,
        talents = self:GetUnitTalents(unit),
        lastUpdate = GetTime()
    }
    
    -- Process next unit
    self:ProcessInspectQueue()
end

function I:GROUP_ROSTER_UPDATE()
    -- Queue inspect for all party members
    if IsInGroup() then
        for i = 1, GetNumGroupMembers() do
            local unit = IsInRaid() and "raid" .. i or "party" .. i
            if UnitExists(unit) then
                self:QueueInspect(unit)
            end
        end
    end
end

function I:PLAYER_ENTERING_WORLD()
    -- Update player info
    local playerGUID = UnitGUID("player")
    if playerGUID then
        -- Get player info
        local _, playerClass = UnitClass("player")
        local playerSpec = GetSpecialization()
        local playerSpecID = playerSpec and GetSpecializationInfo(playerSpec) or 0
        
        inspectResults[playerGUID] = {
            name = UnitName("player"),
            class = playerClass,
            spec = playerSpecID,
            talents = self:GetUnitTalents("player"),
            lastUpdate = GetTime()
        }
    end
    
    -- Queue inspect for group members
    self:GROUP_ROSTER_UPDATE()
end