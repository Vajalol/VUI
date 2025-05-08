local addonName, VUI = ...

-- Combat Parser service for VUIScrollingText
-- This handles parsing combat log events and extracting relevant information

-- Local references
local bit_band = bit.band
local string_find = string.find
local string_match = string.match
local string_format = string.format
local select = select

-- Access the localization system
local L = VUI.ScrollingText.L or {}

-- Constants
local AFFILIATION_MINE = COMBATLOG_OBJECT_AFFILIATION_MINE
local REACTION_FRIENDLY = COMBATLOG_OBJECT_REACTION_FRIENDLY
local REACTION_HOSTILE = COMBATLOG_OBJECT_REACTION_HOSTILE
local CONTROL_PLAYER = COMBATLOG_OBJECT_CONTROL_PLAYER
local TYPE_PLAYER = COMBATLOG_OBJECT_TYPE_PLAYER
local TYPE_PET = COMBATLOG_OBJECT_TYPE_PET
local TYPE_NPC = COMBATLOG_OBJECT_TYPE_NPC

-- Spell school colors
local SPELL_SCHOOL_COLORS = {
    [1] = {r = 1.00, g = 1.00, b = 0.00}, -- Physical (yellow)
    [2] = {r = 1.00, g = 0.90, b = 0.50}, -- Holy (light gold)
    [4] = {r = 1.00, g = 0.50, b = 0.00}, -- Fire (orange)
    [8] = {r = 0.30, g = 1.00, b = 0.30}, -- Nature (green)
    [16] = {r = 0.50, g = 0.50, b = 1.00}, -- Frost (light blue)
    [32] = {r = 0.60, g = 0.00, b = 1.00}, -- Shadow (purple)
    [64] = {r = 0.00, g = 0.80, b = 1.00}, -- Arcane (cyan)
}

-- Event processing helper functions
local function IsMine(flags)
    return bit_band(flags or 0, AFFILIATION_MINE) ~= 0
end

local function IsPlayer(flags)
    return bit_band(flags or 0, TYPE_PLAYER) ~= 0
end

local function IsPet(flags)
    return bit_band(flags or 0, TYPE_PET) ~= 0
end

local function IsFriendly(flags)
    return bit_band(flags or 0, REACTION_FRIENDLY) ~= 0
end

local function IsHostile(flags)
    return bit_band(flags or 0, REACTION_HOSTILE) ~= 0
end

-- Get color for spell school
function VUI.ScrollingText:GetSchoolColor(spellSchool)
    return SPELL_SCHOOL_COLORS[spellSchool] or {r = 1, g = 1, b = 1}
end

-- Format numbers based on user settings
function VUI.ScrollingText:FormatNumber(number)
    if not number then return "0" end
    
    -- Apply abbreviation if enabled
    if self:GetConfigValue("abbreviateNumbers", true) then
        return self.ShortenNumber(number, 1)
    end
    
    -- Otherwise just return the number
    return tostring(number)
end

-- Format percentage values
function VUI.ScrollingText:FormatPercent(value)
    if not value then return "0%" end
    return string_format("%.1f%%", value)
end

-- Process damage events
function VUI.ScrollingText:ParseDamageEvent(event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags)
    -- Get spellID, spellName, spellSchool from combat log
    local spellId, spellName, spellSchool
    local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand
    
    if event == "SWING_DAMAGE" then
        amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, CombatLogGetCurrentEventInfo())
        spellName = MELEE
        spellSchool = 1 -- Physical
    else
        spellId, spellName, spellSchool = select(12, CombatLogGetCurrentEventInfo())
        amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(15, CombatLogGetCurrentEventInfo())
    end
    
    -- Skip if amount is not available
    if not amount then return end
    
    local text = self:FormatNumber(amount)
    local color = self:GetSchoolColor(spellSchool)
    
    -- Handle critical hits
    if critical then
        -- Add crit styling based on settings
        local prefix = self:GetConfigValue("critPrefix", "")
        local suffix = self:GetConfigValue("critSuffix", "")
        
        if prefix and prefix ~= "" then
            text = prefix .. " " .. text
        end
        
        if suffix and suffix ~= "" then
            text = text .. " " .. suffix
        end
        
        -- Increase size for crits if enabled
        local fontSize = self:GetConfigValue("fontSize", 18)
        if self:GetConfigValue("showCritsLarger", true) then
            fontSize = fontSize * 1.5
        end
        
        -- Determine scroll area
        local scrollArea
        if IsMine(sourceFlags) then
            if IsPet(sourceFlags) then
                scrollArea = "outgoingPet"
            else
                scrollArea = "outgoing"
            end
        else
            scrollArea = "incoming"
        end
        
        -- Display the critical hit
        self:DisplayScrollingText(text, scrollArea, color, fontSize, nil, nil, "pow")
    else
        -- Handle normal damage
        -- Determine scroll area
        local scrollArea
        if IsMine(sourceFlags) then
            if IsPet(sourceFlags) then
                scrollArea = "outgoingPet"
            else
                scrollArea = "outgoing"
            end
        else
            scrollArea = "incoming"
        end
        
        -- Display the damage
        self:DisplayScrollingText(text, scrollArea, color)
    end
    
    -- Handle partial effects (resist, block, absorb)
    if resisted and resisted > 0 then
        local resistText = string_format("(%s %s)", self:FormatNumber(resisted), RESIST)
        self:DisplayScrollingText(resistText, scrollArea, {r = 0.5, g = 0.5, b = 0.5})
    end
    
    if blocked and blocked > 0 then
        local blockText = string_format("(%s %s)", self:FormatNumber(blocked), BLOCK)
        self:DisplayScrollingText(blockText, scrollArea, {r = 0.5, g = 0.5, b = 0.5})
    end
    
    if absorbed and absorbed > 0 then
        local absorbText = string_format("(%s %s)", self:FormatNumber(absorbed), ABSORB)
        self:DisplayScrollingText(absorbText, scrollArea, {r = 0.5, g = 0.5, b = 0.5})
    end
end

-- Process healing events
function VUI.ScrollingText:ParseHealEvent(event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags)
    -- Get spellID, spellName from combat log
    local spellId, spellName, spellSchool, amount, overhealing, absorbed, critical = select(12, CombatLogGetCurrentEventInfo())
    
    -- Skip if amount is not available
    if not amount then return end
    
    -- Format the healing text
    local text = self:FormatNumber(amount)
    local color = {r = 0.0, g = 1.0, b = 0.0} -- Green for healing
    
    -- Handle critical heals
    if critical then
        -- Add crit styling based on settings
        local prefix = self:GetConfigValue("critPrefix", "")
        local suffix = self:GetConfigValue("critSuffix", "")
        
        if prefix and prefix ~= "" then
            text = prefix .. " " .. text
        end
        
        if suffix and suffix ~= "" then
            text = text .. " " .. suffix
        end
        
        -- Increase size for crits if enabled
        local fontSize = self:GetConfigValue("fontSize", 18)
        if self:GetConfigValue("showCritsLarger", true) then
            fontSize = fontSize * 1.5
        end
        
        -- Determine scroll area
        local scrollArea
        if IsMine(sourceFlags) then
            scrollArea = "outgoingHeal"
        else
            scrollArea = "incomingHeal"
        end
        
        -- Display the critical heal
        self:DisplayScrollingText(text, scrollArea, color, fontSize, nil, nil, "pow")
    else
        -- Determine scroll area
        local scrollArea
        if IsMine(sourceFlags) then
            scrollArea = "outgoingHeal"
        else
            scrollArea = "incomingHeal"
        end
        
        -- Display the healing
        self:DisplayScrollingText(text, scrollArea, color)
    end
    
    -- Handle overhealing if enabled
    if overhealing and overhealing > 0 and self:GetConfigValue("showOverhealing", true) then
        local overhealText = string_format("(%s %s)", self:FormatNumber(overhealing), OVERHEALING or "overheal")
        self:DisplayScrollingText(overhealText, scrollArea, {r = 0.5, g = 0.5, b = 0.5})
    end
end

-- Process miss events
function VUI.ScrollingText:ParseMissEvent(event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags)
    -- Get spell and miss type information
    local spellId, spellName, spellSchool, missType, isOffHand, amountMissed
    
    if event == "SWING_MISSED" then
        missType, isOffHand, amountMissed = select(12, CombatLogGetCurrentEventInfo())
        spellName = MELEE or "Melee"
    else
        spellId, spellName, spellSchool, missType, isOffHand, amountMissed = select(12, CombatLogGetCurrentEventInfo())
    end
    
    -- Format miss text based on type
    local text
    if missType == "ABSORB" then
        text = string_format("%s %s", spellName, ABSORB or "absorbed")
        if amountMissed and amountMissed > 0 then
            text = text .. " (" .. self:FormatNumber(amountMissed) .. ")"
        end
    elseif missType == "BLOCK" then
        text = string_format("%s %s", spellName, BLOCK or "blocked")
        if amountMissed and amountMissed > 0 then
            text = text .. " (" .. self:FormatNumber(amountMissed) .. ")"
        end
    elseif missType == "DEFLECT" then
        text = string_format("%s %s", spellName, DEFLECT or "deflected")
    elseif missType == "DODGE" then
        text = string_format("%s %s", spellName, DODGE or "dodged")
    elseif missType == "EVADE" then
        text = string_format("%s %s", spellName, EVADE or "evaded")
    elseif missType == "IMMUNE" then
        text = string_format("%s %s", spellName, IMMUNE or "immune")
    elseif missType == "MISS" then
        text = string_format("%s %s", spellName, MISS or "missed")
    elseif missType == "PARRY" then
        text = string_format("%s %s", spellName, PARRY or "parried")
    elseif missType == "REFLECT" then
        text = string_format("%s %s", spellName, REFLECT or "reflected")
    elseif missType == "RESIST" then
        text = string_format("%s %s", spellName, RESIST or "resisted")
        if amountMissed and amountMissed > 0 then
            text = text .. " (" .. self:FormatNumber(amountMissed) .. ")"
        end
    end
    
    -- Skip if no text was generated
    if not text then return end
    
    -- Set color based on miss type
    local color = {r = 0.5, g = 0.5, b = 0.5} -- Gray for misses
    
    -- Determine scroll area
    local scrollArea
    if IsMine(sourceFlags) then
        scrollArea = "outgoing"
    else
        scrollArea = "incoming"
    end
    
    -- Display the miss
    self:DisplayScrollingText(text, scrollArea, color)
end

-- Process special events (interrupts, dispels, etc)
function VUI.ScrollingText:ParseSpecialEvent(event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags)
    local text, color, scrollArea
    
    if event == "SPELL_INTERRUPT" then
        -- Get spell info for interrupted spell
        local spellId, spellName = select(12, CombatLogGetCurrentEventInfo())
        local extraSpellId, extraSpellName, extraSpellSchool = select(15, CombatLogGetCurrentEventInfo())
        
        if IsMine(sourceFlags) then
            text = string_format(INTERRUPT or "Interrupted %s", extraSpellName)
            color = {r = 1.0, g = 0.5, b = 0.0} -- Orange for interrupts
            scrollArea = "notification"
        end
    elseif event == "SPELL_DISPEL" then
        -- Get spell info for dispelled effect
        local spellId, spellName = select(12, CombatLogGetCurrentEventInfo())
        local extraSpellId, extraSpellName, extraSpellSchool = select(15, CombatLogGetCurrentEventInfo())
        
        if IsMine(sourceFlags) then
            text = string_format(DISPEL or "Dispelled %s", extraSpellName)
            color = {r = 0.0, g = 1.0, b = 1.0} -- Cyan for dispels
            scrollArea = "notification"
        end
    elseif event == "SPELL_STOLEN" then
        -- Get spell info for stolen buff
        local spellId, spellName = select(12, CombatLogGetCurrentEventInfo())
        local extraSpellId, extraSpellName, extraSpellSchool = select(15, CombatLogGetCurrentEventInfo())
        
        if IsMine(sourceFlags) then
            text = string_format(SPELLSTEAL or "Stole %s", extraSpellName)
            color = {r = 0.0, g = 0.5, b = 1.0} -- Blue for spell steal
            scrollArea = "notification"
        end
    end
    
    -- Display the special event
    if text then
        self:DisplayScrollingText(text, scrollArea, color)
    end
end

-- Process environmental damage
function VUI.ScrollingText:ParseEnvironmentalEvent(event, environmentalType, amount)
    if not amount or amount <= 0 then return end
    
    local text = string_format("%s %s", environmentalType, self:FormatNumber(amount))
    local color = {r = 1.0, g = 0.3, b = 0.3} -- Red for environmental damage
    
    self:DisplayScrollingText(text, "incoming", color)
end

-- Process power gains (mana, rage, energy, etc.)
function VUI.ScrollingText:ParsePowerEvent(event, sourceName, sourceFlags, destName, destFlags, spellName, powerType, amount)
    if not amount or amount <= 0 then return end
    
    -- Skip if not showing power gains
    if not self:GetConfigValue("showPowerGains", true) then return end
    
    -- Format the text based on power type
    local text, color
    
    if powerType == Enum.PowerType.Mana then
        text = string_format("+%s %s", self:FormatNumber(amount), MANA)
        color = {r = 0.0, g = 0.0, b = 1.0} -- Blue for mana
    elseif powerType == Enum.PowerType.Rage then
        text = string_format("+%s %s", self:FormatNumber(amount), RAGE)
        color = {r = 1.0, g = 0.0, b = 0.0} -- Red for rage
    elseif powerType == Enum.PowerType.Energy then
        text = string_format("+%s %s", self:FormatNumber(amount), ENERGY)
        color = {r = 1.0, g = 1.0, b = 0.0} -- Yellow for energy
    elseif powerType == Enum.PowerType.ComboPoints then
        text = string_format("+%s %s", amount, COMBO_POINTS)
        color = {r = 1.0, g = 0.5, b = 0.0} -- Orange for combo points
    else
        text = string_format("+%s", self:FormatNumber(amount))
        color = {r = 0.5, g = 0.5, b = 0.5} -- Gray for other power types
    end
    
    -- Determine scroll area
    local scrollArea = "power"
    
    -- Display the power gain
    self:DisplayScrollingText(text, scrollArea, color)
end

-- Process experience gains
function VUI.ScrollingText:ParseExperienceGain(amount, unitType)
    if not amount or amount <= 0 then return end
    
    -- Skip if not showing experience gains
    if not self:GetConfigValue("showExperience", true) then return end
    
    local text, color
    
    if unitType and unitType ~= "" then
        text = string_format("+%s %s (%s)", self:FormatNumber(amount), XP, unitType)
    else
        text = string_format("+%s %s", self:FormatNumber(amount), XP)
    end
    
    color = {r = 0.6, g = 0.0, b = 0.6} -- Purple for experience
    
    -- Display the experience gain
    self:DisplayScrollingText(text, "notification", color)
end

-- Process reputation gains
function VUI.ScrollingText:ParseReputationGain(factionName, amount)
    if not amount then return end
    
    -- Skip if not showing reputation changes
    if not self:GetConfigValue("showReputation", true) then return end
    
    local text, color
    
    if amount > 0 then
        text = string_format("+%s %s: %s", amount, REPUTATION, factionName)
        color = {r = 0.0, g = 0.6, b = 0.1} -- Green for reputation gains
    else
        text = string_format("%s %s: %s", amount, REPUTATION, factionName)
        color = {r = 0.6, g = 0.1, b = 0.0} -- Red for reputation losses
    end
    
    -- Display the reputation change
    self:DisplayScrollingText(text, "notification", color)
end

-- Process honor gains
function VUI.ScrollingText:ParseHonorGain(amount)
    if not amount or amount <= 0 then return end
    
    -- Skip if not showing honor gains
    if not self:GetConfigValue("showHonor", true) then return end
    
    local text = string_format("+%s %s", amount, HONOR)
    local color = {r = 0.6, g = 0.0, b = 0.0} -- Red for honor
    
    -- Display the honor gain
    self:DisplayScrollingText(text, "notification", color)
end

-- Process skill gains
function VUI.ScrollingText:ParseSkillGain(skillName, amount)
    if not amount or amount <= 0 then return end
    
    -- Skip if not showing skill gains
    if not self:GetConfigValue("showSkillGains", true) then return end
    
    local text = string_format("+%s %s: %s", amount, SKILL, skillName)
    local color = {r = 0.3, g = 0.3, b = 1.0} -- Blue for skill gains
    
    -- Display the skill gain
    self:DisplayScrollingText(text, "notification", color)
end

-- Process loot messages
function VUI.ScrollingText:ParseLootGain(itemLink, amount)
    if not itemLink then return end
    
    -- Skip if not showing loot
    if not self:GetConfigValue("showLoot", true) then return end
    
    local text
    if amount and amount > 1 then
        text = string_format("%s x%d", itemLink, amount)
    else
        text = itemLink
    end
    
    local color = {r = 1.0, g = 0.8, b = 0.0} -- Gold for items
    
    -- Display the loot
    self:DisplayScrollingText(text, "notification", color)
end

-- Process money gains
function VUI.ScrollingText:ParseMoneyGain(copper)
    if not copper or copper <= 0 then return end
    
    -- Skip if not showing money
    if not self:GetConfigValue("showMoney", true) then return end
    
    -- Format the money text
    local gold = math.floor(copper / 10000)
    copper = copper % 10000
    local silver = math.floor(copper / 100)
    copper = copper % 100
    
    local text = ""
    if gold > 0 then
        text = text .. gold .. "g "
    end
    if silver > 0 or gold > 0 then
        text = text .. silver .. "s "
    end
    text = text .. copper .. "c"
    
    local color = {r = 1.0, g = 0.8, b = 0.0} -- Gold for money
    
    -- Display the money gain
    self:DisplayScrollingText(text, "notification", color)
end