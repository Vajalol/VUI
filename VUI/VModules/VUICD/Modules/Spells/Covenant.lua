local AddOnName, NS = ...
local VUICD, L, db = NS:unpack()

-- Cache references
local Spells = VUICD.Spells

-- Covenant Abilities for The War Within Season 2
local covenantSpells = {
    -- Class-specific covenant abilities
    DEATHKNIGHT = {
        -- Covenant abilities for Death Knights
        {id = 312202, name = "Shackle the Unworthy", icon = 3578228, duration = 60, covenant = true},
        {id = 315443, name = "Abomination Limb", icon = 3578227, duration = 120, covenant = true},
    },
    
    DEMONHUNTER = {
        -- Covenant abilities for Demon Hunters
        {id = 323639, name = "The Hunt", icon = 3636840, duration = 90, covenant = true},
        {id = 306830, name = "Elysian Decree", icon = 3565719, duration = 60, covenant = true},
    },
    
    DRUID = {
        -- Covenant abilities for Druids
        {id = 323764, name = "Convoke the Spirits", icon = 3636837, duration = 120, covenant = true},
        {id = 325727, name = "Adaptive Swarm", icon = 3636839, duration = 25, covenant = true},
    },
    
    HUNTER = {
        -- Covenant abilities for Hunters
        {id = 324149, name = "Flayed Shot", icon = 3578227, duration = 30, covenant = true},
        {id = 308491, name = "Resonating Arrow", icon = 3636836, duration = 60, covenant = true},
    },
    
    MAGE = {
        -- Covenant abilities for Mages
        {id = 307443, name = "Radiant Spark", icon = 3636838, duration = 30, covenant = true},
        {id = 314791, name = "Shifting Power", icon = 3636835, duration = 60, covenant = true},
    },
    
    MONK = {
        -- Covenant abilities for Monks
        {id = 310454, name = "Weapons of Order", icon = 3636838, duration = 120, covenant = true},
        {id = 327104, name = "Faeline Stomp", icon = 3636837, duration = 30, covenant = true},
    },
    
    PALADIN = {
        -- Covenant abilities for Paladins
        {id = 304971, name = "Divine Toll", icon = 3636838, duration = 60, covenant = true},
        {id = 316958, name = "Ashen Hallow", icon = 3578227, duration = 240, covenant = true},
    },
    
    PRIEST = {
        -- Covenant abilities for Priests
        {id = 325013, name = "Boon of the Ascended", icon = 3636838, duration = 180, covenant = true},
        {id = 324724, name = "Unholy Nova", icon = 3578227, duration = 60, covenant = true},
    },
    
    ROGUE = {
        -- Covenant abilities for Rogues
        {id = 323547, name = "Echoing Reprimand", icon = 3636838, duration = 45, covenant = true},
        {id = 328547, name = "Serrated Bone Spike", icon = 3578227, duration = 30, covenant = true},
    },
    
    SHAMAN = {
        -- Covenant abilities for Shamans
        {id = 320674, name = "Chain Harvest", icon = 3578227, duration = 90, covenant = true},
        {id = 324386, name = "Vesper Totem", icon = 3636835, duration = 60, covenant = true},
    },
    
    WARLOCK = {
        -- Covenant abilities for Warlocks
        {id = 321792, name = "Impending Catastrophe", icon = 3578227, duration = 60, covenant = true},
        {id = 312321, name = "Scouring Tithe", icon = 3636838, duration = 40, covenant = true},
    },
    
    WARRIOR = {
        -- Covenant abilities for Warriors
        {id = 307865, name = "Spear of Bastion", icon = 3636838, duration = 60, covenant = true},
        {id = 325886, name = "Ancient Aftershock", icon = 3636837, duration = 90, covenant = true},
    },
    
    EVOKER = {
        -- Covenant abilities for Evokers
        {id = 368847, name = "Firestorm", icon = 4622464, duration = 30, covenant = true},
        {id = 370665, name = "Eternity Surge", icon = 4630435, duration = 30, covenant = true},
    }
}

-- Register covenant spells with the main spell database
for className, spells in pairs(covenantSpells) do
    if VUICD.SpellData[className] then
        for _, spell in ipairs(spells) do
            -- Add to spell database
            table.insert(VUICD.SpellData[className], spell)
        end
    end
end

-- Get covenant spell for unit
function Spells:GetCovenantSpellsForUnit(unit)
    if not unit then return {} end
    
    local className = select(2, UnitClass(unit))
    if not className or not covenantSpells[className] then return {} end
    
    return covenantSpells[className]
end

-- Check if a spell is a covenant ability
function Spells:IsCovenantSpell(spellID)
    if not spellID then return false end
    
    local spellInfo = self:GetSpellInfo(spellID)
    return spellInfo and spellInfo.covenant or false
end