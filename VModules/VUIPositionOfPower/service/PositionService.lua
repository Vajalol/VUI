-- VUIPositionOfPower PositionService
-- Tracks and manages position of power displays
-- Based on source: https://wago.io/MTSDyaGz9

local AddonName, VUI = ...
local M = VUI:GetModule("VUIPositionOfPower")
local PositionService = {}
M.PositionService = PositionService

-- List of position of power spell IDs by class
local PositionSpells = {
    WARRIOR = {
        -- Position of Power spells for Warriors
        [12975] = true, -- Last Stand
        [871] = true,   -- Shield Wall
        [1719] = true,  -- Recklessness
        [107574] = true, -- Avatar
        [118038] = true, -- Die by the Sword
    },
    PALADIN = {
        -- Position of Power spells for Paladins
        [31884] = true, -- Avenging Wrath
        [86659] = true, -- Guardian of Ancient Kings
        [31850] = true, -- Ardent Defender
        [105809] = true, -- Holy Avenger
        [184662] = true, -- Shield of the Righteous
    },
    HUNTER = {
        -- Position of Power spells for Hunters
        [193526] = true, -- Trueshot
        [19574] = true,  -- Bestial Wrath
        [186289] = true, -- Aspect of the Eagle
        [186265] = true, -- Aspect of the Turtle
        [288613] = true, -- Trueshot
    },
    ROGUE = {
        -- Position of Power spells for Rogues
        [13750] = true, -- Adrenaline Rush
        [121471] = true, -- Shadow Blades
        [1966] = true,  -- Feint
        [5277] = true,  -- Evasion
        [185311] = true, -- Crimson Vial
    },
    PRIEST = {
        -- Position of Power spells for Priests
        [10060] = true, -- Power Infusion
        [47536] = true, -- Rapture
        [33206] = true, -- Pain Suppression
        [47788] = true, -- Guardian Spirit
        [64843] = true, -- Divine Hymn
    },
    DEATHKNIGHT = {
        -- Position of Power spells for Death Knights
        [49028] = true, -- Dancing Rune Weapon
        [55233] = true, -- Vampiric Blood
        [48792] = true, -- Icebound Fortitude
        [51271] = true, -- Pillar of Frost
        [42650] = true, -- Army of the Dead
    },
    SHAMAN = {
        -- Position of Power spells for Shamans
        [108271] = true, -- Astral Shift
        [114052] = true, -- Ascendance
        [108281] = true, -- Ancestral Guidance
        [98008] = true,  -- Spirit Link Totem
        [192249] = true, -- Storm Elemental
    },
    MAGE = {
        -- Position of Power spells for Mages
        [12472] = true, -- Icy Veins
        [12042] = true, -- Arcane Power
        [190319] = true, -- Combustion
        [45438] = true, -- Ice Block
        [110909] = true, -- Alter Time
    },
    WARLOCK = {
        -- Position of Power spells for Warlocks
        [196098] = true, -- Soul Harvest
        [113860] = true, -- Dark Soul: Misery
        [104773] = true, -- Unending Resolve
        [113858] = true, -- Dark Soul: Instability
        [191427] = true, -- Darkglare
    },
    MONK = {
        -- Position of Power spells for Monks
        [115080] = true, -- Touch of Death
        [115203] = true, -- Fortifying Brew
        [122278] = true, -- Dampen Harm
        [115176] = true, -- Zen Meditation
        [137639] = true, -- Storm, Earth, and Fire
    },
    DRUID = {
        -- Position of Power spells for Druids
        [194223] = true, -- Celestial Alignment
        [102558] = true, -- Incarnation: Guardian of Ursoc
        [102543] = true, -- Incarnation: King of the Jungle
        [33891] = true,  -- Incarnation: Tree of Life
        [102560] = true, -- Incarnation: Chosen of Elune
    },
    DEMONHUNTER = {
        -- Position of Power spells for Demon Hunters
        [191427] = true, -- Metamorphosis
        [212084] = true, -- Fel Devastation
        [196555] = true, -- Netherwalk
        [187827] = true, -- Metamorphosis
        [203720] = true, -- Demon Spikes
    },
    EVOKER = {
        -- Position of Power spells for Evokers
        [375087] = true, -- Dragonrage
        [370553] = true, -- Tip the Scales
        [359816] = true, -- Dreamflight
        [363916] = true, -- Obsidian Scales
        [374227] = true, -- Zephyr
    },
}

-- Active position of power auras
local activePositions = {}

-- Initialize the position service
function PositionService:Initialize()
    -- Register for combat log events to track auras
    M:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    M:RegisterEvent("PLAYER_ENTERING_WORLD")
    M:RegisterEvent("UNIT_AURA", "CheckAuras")
    
    -- Initial aura check
    self:CheckAuras("player")
    
    M:Debug("PositionService initialized")
end

-- Check unit for position of power auras
function PositionService:CheckAuras(unit)
    if not unit or not UnitExists(unit) then return end
    
    -- Only track player and party/raid members
    if unit ~= "player" and not UnitInParty(unit) and not UnitInRaid(unit) then return end
    
    -- Get unit class for spell list
    local _, class = UnitClass(unit)
    if not class or not PositionSpells[class] then return end
    
    -- Reset tracking for this unit
    activePositions[unit] = activePositions[unit] or {}
    
    -- Scan buffs
    local i = 1
    while true do
        local name, icon, count, debuffType, duration, expirationTime, source, isStealable, 
              nameplateShowPersonal, spellId = UnitBuff(unit, i)
        
        if not name then break end
        
        -- Check if this is a position of power
        if PositionSpells[class][spellId] then
            activePositions[unit][spellId] = {
                name = name,
                icon = icon,
                duration = duration,
                expires = expirationTime,
                count = count or 0
            }
        end
        
        i = i + 1
    end
end

-- Process combat log events for aura tracking
function PositionService:ProcessCombatLogEvent(...)
    local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
          destGUID, destName, destFlags, destRaidFlags, spellId, spellName = ...
    
    -- Track aura applications and removals
    if event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REMOVED" then
        local unit = self:GetUnitFromGUID(destGUID)
        if unit then
            self:CheckAuras(unit)
        end
    end
end

-- Get unit ID from GUID
function PositionService:GetUnitFromGUID(guid)
    if UnitGUID("player") == guid then
        return "player"
    end
    
    -- Check party members
    for i = 1, 4 do
        local unit = "party"..i
        if UnitExists(unit) and UnitGUID(unit) == guid then
            return unit
        end
    end
    
    -- Check raid members
    for i = 1, 40 do
        local unit = "raid"..i
        if UnitExists(unit) and UnitGUID(unit) == guid then
            return unit
        end
    end
    
    return nil
end

-- Get all active positions of power
function PositionService:GetActivePositions()
    return activePositions
end

-- Get positions of power for a specific unit
function PositionService:GetUnitPositions(unit)
    return activePositions[unit] or {}
end

-- Check if unit has a specific position of power active
function PositionService:HasPosition(unit, spellId)
    return activePositions[unit] and activePositions[unit][spellId] ~= nil
end

-- Return the service object
return PositionService