local AddOnName, NS = ...
local VUICD, L, db = NS:unpack()
local P = VUICD.Party
local CD = VUICD.Cooldowns

-- Local variables
local spellCache = {}
local activeSpells = {}
local playerClass = select(2, UnitClass("player"))

-- Initialize cooldown tracking
function CD:Initialize()
    -- Register events
    self.frame = CreateFrame("Frame")
    self.frame:SetScript("OnEvent", function(_, event, ...)
        if self[event] then
            self[event](self, ...)
        end
    end)
    
    self.frame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    self.frame:RegisterEvent("SPELL_UPDATE_CHARGES")
    self.frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    
    -- Load spell data
    self:LoadSpellData()
end

-- Load spell data for all classes
function CD:LoadSpellData()
    -- This would normally load from the Spells_Mainline.lua file
    -- For now, we'll add some example spells for testing
    
    spellCache = {
        WARRIOR = {
            -- Defensive
            {id = 871, type = "defensive", name = "Shield Wall", icon = 134951},
            {id = 12975, type = "defensive", name = "Last Stand", icon = 135871},
            -- Offensive
            {id = 1719, type = "offensive", name = "Recklessness", icon = 237513},
            -- Interrupt
            {id = 6552, type = "interrupt", name = "Pummel", icon = 132938},
        },
        PALADIN = {
            -- Defensive
            {id = 642, type = "defensive", name = "Divine Shield", icon = 524353},
            {id = 86659, type = "defensive", name = "Guardian of Ancient Kings", icon = 135919},
            -- Offensive
            {id = 31884, type = "offensive", name = "Avenging Wrath", icon = 135875},
            -- Utility
            {id = 1022, type = "utility", name = "Blessing of Protection", icon = 135964},
        },
        PRIEST = {
            -- Defensive
            {id = 47788, type = "defensive", name = "Guardian Spirit", icon = 237542},
            {id = 33206, type = "defensive", name = "Pain Suppression", icon = 135936},
            -- Offensive
            {id = 10060, type = "offensive", name = "Power Infusion", icon = 135939},
            -- Utility
            {id = 73325, type = "utility", name = "Leap of Faith", icon = 463835},
        },
        MAGE = {
            -- Defensive
            {id = 45438, type = "defensive", name = "Ice Block", icon = 135841},
            -- Offensive
            {id = 12472, type = "offensive", name = "Icy Veins", icon = 135838},
            -- Utility
            {id = 80353, type = "utility", name = "Time Warp", icon = 458224},
        },
        WARLOCK = {
            -- Defensive
            {id = 104773, type = "defensive", name = "Unending Resolve", icon = 136150},
            -- Offensive
            {id = 113858, type = "offensive", name = "Dark Soul: Instability", icon = 537079},
            -- Utility
            {id = 20707, type = "utility", name = "Soulstone", icon = 136210},
        }
    }
    
    -- Add other classes as needed
    for className, spells in pairs(spellCache) do
        if not spellCache[className] then
            spellCache[className] = {}
        end
    end
end

-- Get spells for a specific class and types
function CD:GetSpells(className, types)
    if not className or not spellCache[className] then return {} end
    
    local result = {}
    local settings = VUICD:GetPartySettings().spells
    
    for _, spell in pairs(spellCache[className]) do
        if settings[spell.type] and (not types or types[spell.type]) then
            table.insert(result, spell)
        end
    end
    
    return result
end

-- Update cooldowns for a specific unit
function CD:UpdateCooldowns(unit, frame)
    if not unit or not frame then return end
    
    local className = select(2, UnitClass(unit))
    if not className or not spellCache[className] then return end
    
    local spells = self:GetSpells(className)
    for _, spell in pairs(spells) do
        local start, duration, enabled = GetSpellCooldown(spell.id)
        if start and duration then
            -- Update cooldown display
            -- This would normally update the frame
        end
    end
end

-- Check if a spell is on cooldown
function CD:IsOnCooldown(spellID, unit)
    if not spellID or not unit then return false end
    
    local start, duration, enabled = GetSpellCooldown(spellID)
    if start and duration and start > 0 and duration > 0 then
        return true, start, duration
    end
    return false
end

-- Event handlers
function CD:SPELL_UPDATE_COOLDOWN()
    P:UpdateCooldowns()
end

function CD:SPELL_UPDATE_CHARGES()
    P:UpdateCooldowns()
end

function CD:UNIT_SPELLCAST_SUCCEEDED(unit, _, spellID)
    -- Track spell usage to handle cooldowns that don't automatically update
    P:UpdateCooldowns()
end