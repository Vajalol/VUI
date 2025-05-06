-- TrufiGCD Core Implementation
-- This file contains the core logic for the TrufiGCD module
local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end
local TrufiGCD = VUI.modules.trufigcd

-- Utility Functions

-- Check if a spell should be tracked based on the user's configuration
function TrufiGCD:ShouldTrackSpell(spellID)
    if not spellID then return false end
    
    local config = VUI.db.profile.modules.trufigcd
    
    -- Check whitelist (if empty, all spells pass this check)
    local passedWhitelist = not next(config.whitelist) or config.whitelist[spellID]
    
    -- Check blacklist
    local passedBlacklist = not config.blacklist[spellID]
    
    return passedWhitelist and passedBlacklist
end

-- Add a spell to the whitelist
function TrufiGCD:AddToWhitelist(spellID)
    if not spellID then return end
    VUI.db.profile.modules.trufigcd.whitelist[spellID] = true
end

-- Remove a spell from the whitelist
function TrufiGCD:RemoveFromWhitelist(spellID)
    if not spellID then return end
    VUI.db.profile.modules.trufigcd.whitelist[spellID] = nil
end

-- Add a spell to the blacklist
function TrufiGCD:AddToBlacklist(spellID)
    if not spellID then return end
    VUI.db.profile.modules.trufigcd.blacklist[spellID] = true
end

-- Remove a spell from the blacklist
function TrufiGCD:RemoveFromBlacklist(spellID)
    if not spellID then return end
    VUI.db.profile.modules.trufigcd.blacklist[spellID] = nil
end

-- Clear all spells from the display
function TrufiGCD:ClearSpells()
    for _, frame in ipairs(self.frames) do
        frame:Hide()
    end
    
    -- Cancel fade timer if active
    if self.fadeTimer then
        self.fadeTimer:Cancel()
        self.fadeTimer = nil
    end
end

-- Handle interaction with other modules
function TrufiGCD:RegisterWithMoveAny()
    if not VUI:IsModuleEnabled("moveany") then return end
    
    local MoveAny = VUI.modules.moveany
    if MoveAny and MoveAny.RegisterFrame and self.container then
        MoveAny:RegisterFrame(self.container, "TrufiGCD", true)
    end
end

-- Function to check if a spell is on the GCD by testing with a known GCD spell
function TrufiGCD:IsSpellOnGCD(spellID)
    -- Some spells don't trigger the GCD, so we need to check
    -- This is a simplified approach and might not be 100% accurate
    
    local start, duration = GetSpellCooldown(61304) -- GCD spell check with an empty GCD spell
    if start > 0 and duration > 0 and duration <= 1.5 then -- 1.5s is the default GCD
        return true
    end
    
    -- Special cases for certain spell types
    if spellID then
        local _, _, _, _, _, _, spellID = GetSpellInfo(spellID)
        if spellID then
            -- Check for spell category to determine if it's off the GCD
            local category = select(4, GetSpellInfo(spellID))
            if category == 1 then -- Off-GCD category
                return false
            end
        end
    end
    
    return false
end

-- Filter function to determine if an event should be processed
function TrufiGCD:FilterEvent(eventType, spellID)
    -- Skip internal spellIDs (usually autoattacks and system spells)
    if spellID < 1000 then
        return false
    end
    
    -- If filtering by cast events
    if VUI.db.profile.modules.trufigcd.filterByCastEvents then
        if eventType ~= "SPELL_CAST_START" and eventType ~= "SPELL_CAST_SUCCESS" then
            return false
        end
    end
    
    -- Always track cast success if enabled
    if eventType == "SPELL_CAST_SUCCESS" and VUI.db.profile.modules.trufigcd.trackCastSuccess then
        return true
    end
    
    -- Always track cast start if enabled
    if eventType == "SPELL_CAST_START" and VUI.db.profile.modules.trufigcd.trackCastStart then
        return true
    end
    
    -- Track specific aura applications if enabled
    if VUI.db.profile.modules.trufigcd.trackAuraEvents then
        if eventType == "SPELL_AURA_APPLIED" or eventType == "SPELL_AURA_REFRESH" then
            return true
        end
    end
    
    return false
end

-- Function to handle spell casts from the action bar (more reliable than combat log in some cases)
function TrufiGCD:HandleActionBarCast(slot)
    local type, id = GetActionInfo(slot)
    
    if type == "spell" then
        local name, _, icon = GetSpellInfo(id)
        if name and icon and self:ShouldTrackSpell(id) then
            self:AddSpell(id, icon, name)
        end
    elseif type == "item" then
        local name, _, _, _, _, _, _, _, _, icon = GetItemInfo(id)
        if name and icon and not VUI.db.profile.modules.trufigcd.ignoreItems then
            self:AddSpell(id, icon, name)
        end
    end
end

-- Hook for action button presses
function TrufiGCD:HookActionButtons()
    for i = 1, 120 do -- Cover all possible action buttons
        local button = _G["ActionButton" .. i]
        if button and not button.__TrufiGCDHooked then
            button:HookScript("OnClick", function(self)
                if TrufiGCD:IsModuleEnabled() then
                    TrufiGCD:HandleActionBarCast(self.action)
                end
            end)
            button.__TrufiGCDHooked = true
        end
    end
    
    -- Also hook the pet action buttons
    for i = 1, 10 do
        local button = _G["PetActionButton" .. i]
        if button and not button.__TrufiGCDHooked then
            button:HookScript("OnClick", function(self)
                if TrufiGCD:IsModuleEnabled() and VUI.db.profile.modules.trufigcd.trackPetSpells then
                    local _, _, _, _, _, _, spellID = GetPetActionInfo(self.action)
                    if spellID then
                        local name, _, icon = GetSpellInfo(spellID)
                        if name and icon and TrufiGCD:ShouldTrackSpell(spellID) then
                            TrufiGCD:AddSpell(spellID, icon, name)
                        end
                    end
                end
            end)
            button.__TrufiGCDHooked = true
        end
    end
end

-- Function to monitor mouseover spell casts using pre-hooks
function TrufiGCD:SetupMouseoverTracking()
    if not self.hookedMouseover then
        -- Hook cast functions to track mouseover targets
        hooksecurefunc("CastSpellByName", function(spellName, onSelf)
            if not TrufiGCD:IsModuleEnabled() then return end
            if UnitExists("mouseover") and not onSelf then
                local spellID = select(7, GetSpellInfo(spellName))
                if spellID then
                    local name, _, icon = GetSpellInfo(spellID)
                    if name and icon and TrufiGCD:ShouldTrackSpell(spellID) then
                        TrufiGCD:AddSpell(spellID, icon, name)
                    end
                end
            end
        end)
        
        -- Hook the spell target button
        if SpellTargetButton and not SpellTargetButton.__TrufiGCDHooked then
            SpellTargetButton:HookScript("OnClick", function()
                if not TrufiGCD:IsModuleEnabled() then return end
                local slot = SpellBookSpellHandlers:GetCurrentImmobileTeleportMouseoverAbility()
                if slot then
                    local spellID = select(2, GetSpellBookItemInfo(slot, SpellBookFrame.bookType))
                    if spellID then
                        local name, _, icon = GetSpellInfo(spellID)
                        if name and icon and TrufiGCD:ShouldTrackSpell(spellID) then
                            TrufiGCD:AddSpell(spellID, icon, name)
                        end
                    end
                end
            end)
            SpellTargetButton.__TrufiGCDHooked = true
        end
        
        self.hookedMouseover = true
    end
end

-- Function to handle spell queuing for rapid casts
function TrufiGCD:QueueSpell(spellID, texture, name)
    -- Check if the spell is already in the queue
    for _, spell in ipairs(self.queue) do
        if spell.id == spellID then
            return
        end
    end
    
    -- Add to queue
    table.insert(self.queue, {
        id = spellID,
        texture = texture,
        name = name,
        time = GetTime()
    })
    
    -- Process queue after a short delay (to handle multiple rapid casts)
    if not self.queueTimer then
        self.queueTimer = C_Timer.NewTimer(0.1, function()
            -- Process the queue
            for _, spell in ipairs(self.queue) do
                TrufiGCD:AddSpell(spell.id, spell.texture, spell.name)
            end
            
            -- Clear the queue
            wipe(self.queue)
            self.queueTimer = nil
        end)
    end
end

-- Function to capture instant casts that might be missed in combat log
function TrufiGCD:SetupSpellWatcher()
    if not self.spellWatchFrame then
        self.spellWatchFrame = CreateFrame("Frame")
        self.spellWatchFrame:SetScript("OnUpdate", function(_, elapsed)
            if not TrufiGCD:IsModuleEnabled() then return end
            
            -- Throttle checks to avoid performance impact
            self.updateElapsed = (self.updateElapsed or 0) + elapsed
            if self.updateElapsed < 0.05 then return end
            self.updateElapsed = 0
            
            -- Check for current spell cast
            local spell, _, _, _, startTime, endTime = UnitCastingInfo("player")
            if spell then
                local spellID = select(7, GetSpellInfo(spell))
                if spellID and not self.lastTrackedSpell or self.lastTrackedSpell ~= spellID then
                    local name, _, icon = GetSpellInfo(spellID)
                    if name and icon and self:ShouldTrackSpell(spellID) then
                        self:QueueSpell(spellID, icon, name)
                        self.lastTrackedSpell = spellID
                    end
                end
                return
            end
            
            -- Check for channeled spell
            spell, _, _, _, startTime, endTime = UnitChannelInfo("player")
            if spell then
                local spellID = select(7, GetSpellInfo(spell))
                if spellID and not self.lastTrackedSpell or self.lastTrackedSpell ~= spellID then
                    local name, _, icon = GetSpellInfo(spellID)
                    if name and icon and self:ShouldTrackSpell(spellID) then
                        self:QueueSpell(spellID, icon, name)
                        self.lastTrackedSpell = spellID
                    end
                end
                return
            end
            
            -- Reset last tracked spell if no cast is happening
            self.lastTrackedSpell = nil
        end)
    end
end
