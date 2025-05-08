local AddOnName, NS = ...
local VUICD, L, db = NS:unpack()
local P = VUICD.Party
local CD = {}
P.CD = CD

-- Local variables
local activeSpells = {}
local activeCooldowns = {}
local updateFrame = nil
local updateInterval = 0.1
local lastUpdate = 0

-- Initialize cooldown tracking
function CD:Initialize()
    -- Create update frame
    updateFrame = CreateFrame("Frame")
    updateFrame:SetScript("OnUpdate", function(_, elapsed)
        lastUpdate = lastUpdate + elapsed
        if lastUpdate > updateInterval then
            self:OnUpdate(lastUpdate)
            lastUpdate = 0
        end
    end)
    
    -- Register events
    updateFrame:SetScript("OnEvent", function(_, event, ...)
        if self[event] then
            self[event](self, ...)
        end
    end)
    
    updateFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    updateFrame:RegisterEvent("SPELL_UPDATE_CHARGES")
    updateFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    updateFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    updateFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
    updateFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    
    -- Start update
    updateFrame:Show()
    
    -- Initialize spell tracking
    self:InitializeSpells()
end

-- Initialize spell tracking
function CD:InitializeSpells()
    wipe(activeSpells)
    wipe(activeCooldowns)
    
    -- Add player spells
    local playerClass = select(2, UnitClass("player"))
    if playerClass and VUICD.SpellData[playerClass] then
        self:AddClassSpells("player", playerClass)
    end
    
    -- Add party member spells
    if IsInGroup() then
        for i = 1, GetNumGroupMembers() do
            local unit = IsInRaid() and "raid" .. i or "party" .. i
            if UnitExists(unit) then
                local _, class = UnitClass(unit)
                if class and VUICD.SpellData[class] then
                    self:AddClassSpells(unit, class)
                end
            end
        end
    end
    
    -- Initialize test spells if in test mode
    if P.testMode then
        for className in pairs(VUICD.SpellData) do
            self:AddClassSpells("player", className, true)
        end
    end
end

-- Add spells for a class
function CD:AddClassSpells(unit, class, isTest)
    if not unit or not class or not VUICD.SpellData[class] then return end
    
    local guid = UnitGUID(unit)
    if not guid then return end
    
    -- Create unit entry if it doesn't exist
    if not activeSpells[guid] then
        activeSpells[guid] = {}
    end
    
    -- Get spell types to track
    local settings = VUICD:GetPartySettings().spells
    local spellTypes = {
        defensive = settings.defensive,
        offensive = settings.offensive,
        covenant = settings.covenant,
        interrupt = settings.interrupt,
        utility = settings.utility,
        custom = settings.custom
    }
    
    -- Add spells of enabled types
    for _, spell in pairs(VUICD.SpellData[class]) do
        local include = false
        
        -- Check if any of the spell's types are enabled
        for spellType, enabled in pairs(spellTypes) do
            if enabled and spell[spellType] then
                include = true
                break
            end
        end
        
        if include then
            local spellID = spell.id
            if spellID and not activeSpells[guid][spellID] then
                activeSpells[guid][spellID] = {
                    id = spellID,
                    name = spell.name,
                    icon = spell.icon,
                    class = class,
                    unit = unit,
                    duration = spell.duration or 0,
                    lastUpdate = 0,
                    onCooldown = false,
                    start = 0,
                    remaining = 0,
                    isTest = isTest
                }
                
                -- Initial cooldown check
                if not isTest then
                    self:UpdateSpellCooldown(guid, spellID)
                end
            end
        end
    end
end

-- Update spell cooldown
function CD:UpdateSpellCooldown(guid, spellID)
    if not guid or not spellID or not activeSpells[guid] or not activeSpells[guid][spellID] then return end
    
    local spell = activeSpells[guid][spellID]
    
    -- Skip test spells
    if spell.isTest then return end
    
    -- Get cooldown info
    local start, duration, enable = GetSpellCooldown(spellID)
    if start and duration then
        local now = GetTime()
        spell.start = start
        spell.duration = duration
        spell.enable = enable
        spell.remaining = (start + duration) - now
        spell.onCooldown = (start > 0 and duration > 0)
        spell.lastUpdate = now
        
        -- Update active cooldowns list
        if spell.onCooldown then
            activeCooldowns[guid .. "-" .. spellID] = spell
        else
            activeCooldowns[guid .. "-" .. spellID] = nil
        end
    end
end

-- Update cooldowns
function CD:UpdateCooldowns()
    local now = GetTime()
    
    -- Update active cooldowns
    for key, spell in pairs(activeCooldowns) do
        if spell.isTest then
            -- For test spells, simulate cooldown
            spell.remaining = math.max(0, spell.remaining - updateInterval)
            if spell.remaining <= 0 then
                spell.onCooldown = false
                activeCooldowns[key] = nil
            end
        else
            -- Real cooldowns
            spell.remaining = (spell.start + spell.duration) - now
            if spell.remaining <= 0 then
                spell.onCooldown = false
                activeCooldowns[key] = nil
            end
        end
    end
    
    -- Update UI
    P:UpdateCooldowns()
end

-- Check if a spell is on cooldown
function CD:IsOnCooldown(guid, spellID)
    if not guid or not spellID or not activeSpells[guid] or not activeSpells[guid][spellID] then
        return false, 0, 0
    end
    
    local spell = activeSpells[guid][spellID]
    
    -- For test spells, simulate random cooldowns
    if spell.isTest and not spell.onCooldown and P.testMode then
        -- 20% chance to start a test cooldown
        if math.random(1, 100) <= 20 then
            spell.onCooldown = true
            spell.start = GetTime()
            spell.duration = math.random(10, 60)
            spell.remaining = spell.duration
            activeCooldowns[guid .. "-" .. spellID] = spell
        end
    end
    
    return spell.onCooldown, spell.start, spell.duration
end

-- Get active spells for a unit
function CD:GetActiveSpells(guid)
    return activeSpells[guid] or {}
end

-- Update handler
function CD:OnUpdate(elapsed)
    self:UpdateCooldowns()
end

-- Event handlers
function CD:SPELL_UPDATE_COOLDOWN()
    -- Update all tracked cooldowns
    for guid, spells in pairs(activeSpells) do
        for spellID in pairs(spells) do
            self:UpdateSpellCooldown(guid, spellID)
        end
    end
end

function CD:SPELL_UPDATE_CHARGES()
    -- Update charges for abilities with charges
    self:SPELL_UPDATE_COOLDOWN()
end

function CD:UNIT_SPELLCAST_SUCCEEDED(unit, _, spellID)
    -- Update specific spell
    local guid = UnitGUID(unit)
    if guid and activeSpells[guid] and activeSpells[guid][spellID] then
        self:UpdateSpellCooldown(guid, spellID)
    end
end

function CD:PLAYER_SPECIALIZATION_CHANGED(unit)
    -- Reset spell tracking for the unit
    local guid = UnitGUID(unit)
    if guid and activeSpells[guid] then
        local _, class = UnitClass(unit)
        if class then
            wipe(activeSpells[guid])
            self:AddClassSpells(unit, class)
        end
    end
end

function CD:PLAYER_TALENT_UPDATE()
    -- Reset player spell tracking
    local guid = UnitGUID("player")
    if guid and activeSpells[guid] then
        local _, class = UnitClass("player")
        if class then
            wipe(activeSpells[guid])
            self:AddClassSpells("player", class)
        end
    end
end

function CD:GROUP_ROSTER_UPDATE()
    -- Reset and reinitialize all spell tracking
    self:InitializeSpells()
end