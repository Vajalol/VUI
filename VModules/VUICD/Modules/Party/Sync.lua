local AddOnName, NS = ...
local VUICD, L, db = NS:unpack()
local P = VUICD.Party
local Sync = {}
P.Sync = Sync

-- Local variables
local syncEnabled = false
local syncPrefix = "VUICD"
local syncThrottle = 1.0 -- Minimum seconds between syncs
local lastSendTime = 0
local receivedData = {}

-- Initialize sync
function Sync:Initialize()
    if not syncEnabled then return end
    
    -- Register addon channel
    RegisterAddonMessagePrefix(syncPrefix)
    
    -- Register events
    self.frame = CreateFrame("Frame")
    self.frame:SetScript("OnEvent", function(_, event, ...)
        if self[event] then
            self[event](self, ...)
        end
    end)
    
    self.frame:RegisterEvent("CHAT_MSG_ADDON")
    self.frame:RegisterEvent("GROUP_ROSTER_UPDATE")
    self.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    
    -- Initial update
    C_Timer.After(2, function() self:SendCooldownSync() end)
end

-- Send cooldown sync data
function Sync:SendCooldownSync()
    if not syncEnabled or not IsInGroup() or not P.CD then return end
    
    -- Throttle sync messages
    local now = GetTime()
    if now - lastSendTime < syncThrottle then
        return
    end
    
    lastSendTime = now
    
    -- Get player cooldowns
    local playerGUID = UnitGUID("player")
    local playerSpells = P.CD:GetActiveSpells(playerGUID)
    
    if not playerSpells then return end
    
    -- Create sync data
    local syncData = {}
    
    for spellID, spellInfo in pairs(playerSpells) do
        if spellInfo.onCooldown then
            syncData[spellID] = math.ceil(spellInfo.remaining)
        end
    end
    
    -- Send data if we have any cooldowns
    if next(syncData) then
        local message = self:SerializeData(syncData)
        if message then
            local channel = IsInRaid() and "RAID" or "PARTY"
            SendAddonMessage(syncPrefix, message, channel)
        end
    end
end

-- Receive cooldown sync data
function Sync:ReceiveCooldownSync(sender, message)
    if not syncEnabled or not P.CD or sender == playerName then return end
    
    -- Get player info
    local playerInfo = P.GroupInfo and P.GroupInfo:GetMemberInfoByName(sender)
    if not playerInfo then return end
    
    -- Deserialize data
    local syncData = self:DeserializeData(message)
    if not syncData then return end
    
    -- Store data
    receivedData[playerInfo.guid] = {
        spells = syncData,
        time = GetTime()
    }
end

-- Update cooldowns from sync data
function Sync:UpdateCooldownsFromSync()
    if not syncEnabled or not P.CD then return end
    
    local now = GetTime()
    
    for guid, data in pairs(receivedData) do
        -- Skip if data is too old (more than 30 seconds)
        if now - data.time > 30 then
            receivedData[guid] = nil
        else
            -- Update cooldowns
            for spellID, remaining in pairs(data.spells) do
                -- Get elapsed time since we received the data
                local elapsed = now - data.time
                local adjustedRemaining = math.max(0, remaining - elapsed)
                
                -- Apply to the cooldown tracker
                -- This would integrate with the CD module's data
                -- For now, we just store the data
            end
        end
    end
end

-- Serialize data for transmission
function Sync:SerializeData(data)
    if not data then return nil end
    
    local result = ""
    for spellID, remaining in pairs(data) do
        if result ~= "" then
            result = result .. ";"
        end
        result = result .. spellID .. ":" .. remaining
    end
    
    return result
end

-- Deserialize received data
function Sync:DeserializeData(message)
    if not message or message == "" then return nil end
    
    local result = {}
    
    for pair in string.gmatch(message, "[^;]+") do
        local spellID, remaining = string.match(pair, "(%d+):(%d+)")
        if spellID and remaining then
            result[tonumber(spellID)] = tonumber(remaining)
        end
    end
    
    return result
end

-- Event handlers
function Sync:CHAT_MSG_ADDON(prefix, message, channel, sender)
    if prefix == syncPrefix and (channel == "PARTY" or channel == "RAID") then
        self:ReceiveCooldownSync(sender, message)
    end
end

function Sync:GROUP_ROSTER_UPDATE()
    C_Timer.After(2, function() self:SendCooldownSync() end)
end

function Sync:PLAYER_ENTERING_WORLD()
    C_Timer.After(2, function() self:SendCooldownSync() end)
end

-- Enable or disable sync
function Sync:SetEnabled(enabled)
    syncEnabled = enabled
    
    if enabled and not self.initialized then
        self:Initialize()
        self.initialized = true
    end
end