local _, VUI = ...
local SN = VUI.SpellNotifications

-- Event handler for COMBAT_LOG_EVENT_UNFILTERED
function SN:COMBAT_LOG_EVENT_UNFILTERED()
    local timestamp, event, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool, missType, amount = CombatLogGetCurrentEventInfo()
    
    if not self:GetSettings().enabled then return end
    
    -- Get various data tables
    local affiliations = self:Affiliations()
    local missTypes = self:MissTypes()
    local spellSchools = self:SpellSchools()
    local colors = self:Colors()
    local sizes = self:Sizes()
    
    -- Check for source being player or pet
    local isSourceMine = bit.band(sourceFlags, affiliations.MINE) > 0
    local isSourceMyPet = bit.band(sourceFlags, affiliations.PET) > 0 and isSourceMine
    local isSourceFriendly = bit.band(sourceFlags, affiliations.FRIENDLY) > 0
    
    -- Check for dest being player or pet
    local isDestMine = bit.band(destFlags or 0, affiliations.MINE) > 0
    local isDestMyPet = bit.band(destFlags or 0, affiliations.PET) > 0 and isDestMine
    local isDestFriendly = bit.band(destFlags or 0, affiliations.FRIENDLY) > 0
    
    -- Process SPELL_MISSED events
    if event == "SPELL_MISSED" and spellName then
        self:HandleSpellMissed(isSourceMine, isSourceMyPet, isDestMine, isDestMyPet, missType, spellName, missTypes)
    end
    
    -- Process SPELL_INTERRUPT events
    if event == "SPELL_INTERRUPT" and spellName then
        self:HandleSpellInterrupt(isSourceMine, isSourceMyPet, isDestMine, isDestMyPet, destName, spellName)
    end
    
    -- Process SPELL_STOLEN events
    if event == "SPELL_STOLEN" and spellName then
        self:HandleSpellStolen(isSourceMine, isSourceMyPet, isDestMine, isDestMyPet, destName, spellName)
    end
    
    -- Process SPELL_DISPEL events
    if event == "SPELL_DISPEL" and spellName then
        self:HandleSpellDispel(isSourceMine, isSourceMyPet, isDestMine, isDestMyPet, destName, spellName)
    end
    
    -- Process damage events
    if event == "SPELL_DAMAGE" or event == "RANGE_DAMAGE" or event == "SPELL_PERIODIC_DAMAGE" then
        self:HandleSpellDamage(isSourceMine, isSourceMyPet, isDestMine, isDestMyPet, spellName, amount, spellSchool, spellSchools)
    end
    
    -- Process healing events
    if event == "SPELL_HEAL" or event == "SPELL_PERIODIC_HEAL" then
        self:HandleSpellHeal(isSourceMine, isSourceMyPet, isDestMine, isDestMyPet, spellName, amount)
    end
end

-- Handle spell missed events
function SN:HandleSpellMissed(isSourceMine, isSourceMyPet, isDestMine, isDestMyPet, missType, spellName, missTypes)
    local settings = self:GetSettings()
    
    -- Player's spell was resisted/dodged/etc
    if isSourceMine and settings.playerMisses and missTypes[missType] then
        local msg = spellName .. " " .. missTypes[missType]
        self:Print(msg, self:Colors().RED, self:Sizes().SMALL)
        self:PlaySound(settings.playerMissesSound)
    end
    
    -- Pet's spell was resisted/dodged/etc
    if isSourceMyPet and settings.petMisses and missTypes[missType] then
        local msg = "Pet " .. spellName .. " " .. missTypes[missType]
        self:Print(msg, self:Colors().RED, self:Sizes().SMALL)
        self:PlaySound(settings.petMissesSound)
    end
end

-- Handle spell interrupt events
function SN:HandleSpellInterrupt(isSourceMine, isSourceMyPet, isDestMine, isDestMyPet, destName, spellName)
    local settings = self:GetSettings()
    
    -- Player interrupted a spell
    if isSourceMine and settings.playerInterrupts and not isDestFriendly then
        local msg = "Interrupted " .. (destName or "Unknown") .. " - " .. spellName
        self:Print(msg, self:Colors().BLUE, self:Sizes().BIG)
        self:PlaySound(settings.playerInterruptsSound)
    end
    
    -- Pet interrupted a spell
    if isSourceMyPet and settings.petInterrupts and not isDestFriendly then
        local msg = "Pet interrupted " .. (destName or "Unknown") .. " - " .. spellName
        self:Print(msg, self:Colors().BLUE, self:Sizes().SMALL)
        self:PlaySound(settings.petInterruptsSound)
    end
end

-- Handle spell stolen events
function SN:HandleSpellStolen(isSourceMine, isSourceMyPet, isDestMine, isDestMyPet, destName, spellName)
    local settings = self:GetSettings()
    
    -- Player stole a spell
    if isSourceMine and settings.playerStolen and not isDestFriendly then
        local msg = "Stole " .. spellName .. " from " .. (destName or "Unknown")
        self:Print(msg, self:Colors().PURPLE, self:Sizes().BIG)
        self:PlaySound(settings.playerStolenSound)
    end
end

-- Handle spell dispel events
function SN:HandleSpellDispel(isSourceMine, isSourceMyPet, isDestMine, isDestMyPet, destName, spellName)
    local settings = self:GetSettings()
    
    -- Player dispelled a spell
    if isSourceMine and settings.playerDispels and not isDestFriendly then
        local msg = "Dispelled " .. spellName .. " from " .. (destName or "Unknown")
        self:Print(msg, self:Colors().GREEN, self:Sizes().BIG)
        self:PlaySound(settings.playerDispelsSound)
    end
    
    -- Pet dispelled a spell
    if isSourceMyPet and settings.petDispels and not isDestFriendly then
        local msg = "Pet dispelled " .. spellName .. " from " .. (destName or "Unknown")
        self:Print(msg, self:Colors().GREEN, self:Sizes().SMALL)
        self:PlaySound(settings.petDispelsSound)
    end
end

-- Handle spell damage events
function SN:HandleSpellDamage(isSourceMine, isSourceMyPet, isDestMine, isDestMyPet, spellName, amount, spellSchool, spellSchools)
    local settings = self:GetSettings()
    
    -- Player critical hits
    if isSourceMine and settings.playerCrits and amount > (settings.playerCritsMinHit or 0) and amount > (UnitHealthMax("player") * (settings.playerCritsHealthPct or 0) / 100) then
        local msg = spellName .. " " .. amount .. " (" .. (spellSchools[spellSchool] or "Unknown") .. ")"
        self:Print(msg, self:Colors().ORANGE, self:Sizes().BIG)
        self:PlaySound(settings.playerCritsSound)
    end
    
    -- Pet critical hits
    if isSourceMyPet and settings.petCrits and amount > (settings.petCritsMinHit or 0) then
        local msg = "Pet " .. spellName .. " " .. amount
        self:Print(msg, self:Colors().ORANGE, self:Sizes().SMALL)
        self:PlaySound(settings.petCritsSound)
    end
end

-- Handle spell healing events
function SN:HandleSpellHeal(isSourceMine, isSourceMyPet, isDestMine, isDestMyPet, spellName, amount)
    local settings = self:GetSettings()
    
    -- Player critical heals
    if isSourceMine and settings.playerHeals and amount > (settings.playerHealsMinHit or 0) and amount > (UnitHealthMax("player") * (settings.playerHealsHealthPct or 0) / 100) then
        local msg = spellName .. " heals for " .. amount
        self:Print(msg, self:Colors().GREEN, self:Sizes().BIG)
        self:PlaySound(settings.playerHealsSound)
    end
end

-- Initialize event handling
function SN:InitializeEvents()
    -- Register events
    if not self.frame then
        self.frame = CreateFrame("Frame")
    end
    
    self.frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    
    -- Set up event handler
    self.frame:SetScript("OnEvent", function(frame, event, ...)
        if event == "COMBAT_LOG_EVENT_UNFILTERED" then
            self:COMBAT_LOG_EVENT_UNFILTERED()
        end
    end)
    
    -- Hook into error frame for filtering standard error messages
    self:HookErrorsFrame()
end