local AddOnName, NS = ...

-- Use global reference pattern to avoid load order issues
_G["VUICD"] = _G["VUICD"] or {}
local VUICD = _G["VUICD"]

-- Get localization through global reference or fallback
local L = VUICD.L or {}

-- Get database reference
local db = VUICD.db or {}

-- Initialize spells module
local Spells = {}
VUICD.Spells = Spells

-- Cache commonly used globals
local GetSpellInfo = GetSpellInfo
local GetSpellBaseCooldown = GetSpellBaseCooldown
local GetSpellCharges = GetSpellCharges
local C_Timer = C_Timer

-- Spell info cache
local spellCache = {}
local spellCharges = {}
local spellByName = {}
local classSpells = {}

-- Initialize spells
function Spells:Initialize()
    -- Initialize spell data for all classes
    for className, spells in pairs(VUICD.SpellData) do
        self:ProcessClassSpells(className, spells)
    end
    
    -- Register events
    self.frame = CreateFrame("Frame")
    self.frame:SetScript("OnEvent", function(_, event, ...)
        if self[event] then
            self[event](self, ...)
        end
    end)
    
    self.frame:RegisterEvent("SPELL_DATA_LOAD_RESULT")
    self.frame:RegisterEvent("PLAYER_TALENT_UPDATE")
    self.frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
end

-- Process spells for a specific class
function Spells:ProcessClassSpells(className, spells)
    classSpells[className] = classSpells[className] or {}
    
    for i, spell in ipairs(spells) do
        local spellID = spell.id
        if spellID then
            -- Get spell info with safety check
            local success, name, _, icon = pcall(function() 
                local name, _, icon = GetSpellInfo(spellID)
                return name, _, icon 
            end)
            
            if success and name then
                -- Store spell info
                spellCache[spellID] = {
                    id = spellID,
                    name = name,
                    icon = icon or spell.icon or "Interface\\Icons\\INV_Misc_QuestionMark",
                    duration = spell.duration or 0,
                    cooldown = spell.cooldown or 0,
                    offensive = spell.offensive or false,
                    defensive = spell.defensive or false,
                    utility = spell.utility or false,
                    interrupt = spell.interrupt or false,
                    covenant = spell.covenant or false,
                    custom = spell.custom or false
                }
                
                classSpells[className][spellID] = spellCache[spellID]
            else
                -- Fallback to provided data if GetSpellInfo fails
                spellCache[spellID] = {
                    id = spellID,
                    name = spell.name or "Unknown Spell",
                    icon = spell.icon or "Interface\\Icons\\INV_Misc_QuestionMark",
                    duration = spell.duration or 0,
                    cooldown = spell.cooldown or 0,
                    offensive = spell.offensive or false,
                    defensive = spell.defensive or false,
                    utility = spell.utility or false,
                    interrupt = spell.interrupt or false,
                    covenant = spell.covenant or false,
                    custom = spell.custom or false
                }
                
                classSpells[className][spellID] = spellCache[spellID]
                
                -- Log error for debugging
                if VUICD.debug then
                    VUICD:Debug("Failed to get spell info for ID: " .. spellID)
                end
            end
        end
    end
end

-- Get spell info from cache or directly from API
function Spells:GetSpellInfo(spellID)
    if not spellID then return nil end
    
    -- Try to get from cache first
    if spellCache[spellID] then
        return spellCache[spellID]
    end
    
    -- Not in cache, try to get directly
    local success, name, _, icon = pcall(function() 
        local name, _, icon = GetSpellInfo(spellID)
        return name, _, icon 
    end)
    
    if success and name then
        -- Create new entry
        spellCache[spellID] = {
            id = spellID,
            name = name,
            icon = icon or "Interface\\Icons\\INV_Misc_QuestionMark",
            duration = 0,
            cooldown = 0
        }
        
        return spellCache[spellID]
    end
    
    -- Return nil if spell not found
    return nil
end

-- Get spell by name
function Spells:GetSpellByName(name)
    if not name then return end
    
    -- Check cache
    if spellByName[name] then
        return self:GetSpellInfo(spellByName[name])
    end
    
    return nil
end

-- Get spells for a class
function Spells:GetClassSpells(className, category)
    if not className then return {} end
    
    local result = {}
    
    if classSpells[className] then
        for _, spellID in ipairs(classSpells[className]) do
            local spellInfo = self:GetSpellInfo(spellID)
            if spellInfo and (not category or spellInfo[category]) then
                table.insert(result, spellInfo)
            end
        end
    end
    
    return result
end

-- Update spell charges
function Spells:UpdateSpellCharges(spellID)
    if not spellID then return 0, 0 end
    
    local charges, maxCharges, chargeStart, chargeDuration = GetSpellCharges(spellID)
    if charges and maxCharges then
        spellCharges[spellID] = {
            charges = charges,
            maxCharges = maxCharges,
            chargeStart = chargeStart,
            chargeDuration = chargeDuration
        }
        
        return charges, maxCharges
    end
    
    return 0, 0
end

-- Get spell charges
function Spells:GetSpellCharges(spellID)
    if not spellID then return 0, 0 end
    
    -- Update charges
    return self:UpdateSpellCharges(spellID)
end

-- Get spell cooldown
function Spells:GetSpellCooldown(spellID)
    if not spellID then return 0, 0, 0 end
    
    local start, duration, enabled = GetSpellCooldown(spellID)
    if start and duration then
        return start, duration, enabled
    end
    
    return 0, 0, 0
end

-- Event handlers
function Spells:SPELL_DATA_LOAD_RESULT(spellID, success)
    if success and spellCache[spellID] then
        self:GetSpellInfo(spellID) -- Refresh cache
    end
end

function Spells:PLAYER_TALENT_UPDATE()
    -- Refresh class spells
    local playerClass = select(2, UnitClass("player"))
    if playerClass then
        self:ProcessClassSpells(playerClass, VUICD.SpellData[playerClass])
    end
end

function Spells:PLAYER_SPECIALIZATION_CHANGED(unit)
    if unit == "player" then
        self:PLAYER_TALENT_UPDATE()
    end
end