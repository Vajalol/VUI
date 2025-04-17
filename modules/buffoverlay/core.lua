-- BuffOverlay Core Implementation
-- This file contains the core logic for the BuffOverlay module
local _, VUI = ...
local BuffOverlay = VUI.modules.buffoverlay

-- Utility Functions

-- Check if a spell should be tracked based on the user's configuration
function BuffOverlay:ShouldTrackSpell(spellID, isDebuff)
    if not spellID then return false end
    
    local config = VUI.db.profile.modules.buffoverlay
    
    -- Check if it's a healer spell we want to track in mythic+ regardless of other settings
    if config.trackHealerSpells and self.HealerSpells and self.HealerSpells[spellID] then
        return true
    end
    
    -- Check whitelist (if empty, all spells pass this check)
    local passedWhitelist = not next(config.whitelist) or config.whitelist[spellID]
    
    -- Check blacklist
    local passedBlacklist = not config.blacklist[spellID]
    
    -- Check type filters
    local passedTypeFilter = true
    if isDebuff and config.filterDebuffs then
        passedTypeFilter = false
    elseif not isDebuff and config.filterBuffs then
        passedTypeFilter = false
    end
    
    return passedWhitelist and passedBlacklist and passedTypeFilter
end

-- Add a spell to the whitelist
function BuffOverlay:AddToWhitelist(spellID)
    if not spellID then return end
    VUI.db.profile.modules.buffoverlay.whitelist[spellID] = true
    self:UpdateAuras("player")
    self:UpdateAuras("target")
    self:UpdateAuras("focus")
end

-- Remove a spell from the whitelist
function BuffOverlay:RemoveFromWhitelist(spellID)
    if not spellID then return end
    VUI.db.profile.modules.buffoverlay.whitelist[spellID] = nil
    self:UpdateAuras("player")
    self:UpdateAuras("target")
    self:UpdateAuras("focus")
end

-- Add a spell to the blacklist
function BuffOverlay:AddToBlacklist(spellID)
    if not spellID then return end
    VUI.db.profile.modules.buffoverlay.blacklist[spellID] = true
    self:UpdateAuras("player")
    self:UpdateAuras("target")
    self:UpdateAuras("focus")
end

-- Remove a spell from the blacklist
function BuffOverlay:RemoveFromBlacklist(spellID)
    if not spellID then return end
    VUI.db.profile.modules.buffoverlay.blacklist[spellID] = nil
    self:UpdateAuras("player")
    self:UpdateAuras("target")
    self:UpdateAuras("focus")
end

-- Get a list of all currently tracked buffs
function BuffOverlay:GetTrackedBuffs()
    local result = {}
    
    -- Add buffs from whitelist
    for spellID in pairs(VUI.db.profile.modules.buffoverlay.whitelist) do
        local name, _, icon = GetSpellInfo(spellID)
        if name then
            table.insert(result, {
                spellID = spellID,
                name = name,
                icon = icon,
                inWhitelist = true,
                inBlacklist = VUI.db.profile.modules.buffoverlay.blacklist[spellID] or false
            })
        end
    end
    
    -- Add buffs from blacklist that aren't already in the result
    for spellID in pairs(VUI.db.profile.modules.buffoverlay.blacklist) do
        local alreadyAdded = false
        for _, buff in ipairs(result) do
            if buff.spellID == spellID then
                alreadyAdded = true
                break
            end
        end
        
        if not alreadyAdded then
            local name, _, icon = GetSpellInfo(spellID)
            if name then
                table.insert(result, {
                    spellID = spellID,
                    name = name,
                    icon = icon,
                    inWhitelist = false,
                    inBlacklist = true
                })
            end
        end
    end
    
    -- Sort by name
    table.sort(result, function(a, b) return a.name < b.name end)
    
    return result
end

-- Create a notification when important buffs/debuffs appear or expire
function BuffOverlay:CreateNotification(aura, action)
    local config = VUI.db.profile.modules.buffoverlay
    
    -- Only create notifications if enabled
    if not config.showNotifications then
        return
    end
    
    -- Check if it's a healer spell notification
    local isHealerSpell = self.HealerSpells and self.HealerSpells[aura.spellID]
    if isHealerSpell and not config.showHealerSpellNotifications then
        return
    end
    
    local color
    if aura.isDebuff then
        color = DebuffTypeColor[aura.debuffType or "none"]
    else
        color = {r = 0.1, g = 0.7, b = 0.1}
    end
    
    -- Special color for healer spells
    if isHealerSpell then
        color = {r = 0.0, g = 0.6, b = 1.0} -- Blue color for healer spells
    end
    
    local message
    if action == "gained" then
        message = "Gained " .. aura.name
        
        -- Add extra indicator for healer spells
        if isHealerSpell then
            message = "✓ " .. message .. " (Healer)"
        end
    elseif action == "faded" then
        message = aura.name .. " faded"
        
        -- Add extra indicator for healer spells
        if isHealerSpell then
            message = "⚠ " .. message .. " (Healer)"
        end
    end
    
    -- Create and show notification (using a custom function in VUI that would need to be implemented)
    if message and VUI.ShowNotification then
        VUI:ShowNotification(message, 3, color, aura.icon)
    end
end

-- Track significant auras for notifications
function BuffOverlay:TrackAuraChanges(unit)
    if not unit or not UnitExists(unit) then return end
    
    -- Only track player auras for notifications
    if unit ~= "player" then return end
    
    -- Get current auras
    local currentAuras = {}
    
    -- Process buffs
    for i = 1, 40 do
        local name, icon, count, debuffType, duration, expirationTime, source, _, _, spellID = UnitBuff(unit, i)
        if not name then break end
        
        if self:ShouldTrackSpell(spellID, false) then
            currentAuras[spellID] = {
                name = name,
                icon = icon,
                count = count,
                duration = duration,
                expirationTime = expirationTime,
                isDebuff = false,
                debuffType = nil,
                source = source,
                spellID = spellID
            }
        end
    end
    
    -- Process debuffs
    for i = 1, 40 do
        local name, icon, count, debuffType, duration, expirationTime, source, _, _, spellID = UnitDebuff(unit, i)
        if not name then break end
        
        if self:ShouldTrackSpell(spellID, true) then
            currentAuras[spellID] = {
                name = name,
                icon = icon,
                count = count,
                duration = duration,
                expirationTime = expirationTime,
                isDebuff = true,
                debuffType = debuffType,
                source = source,
                spellID = spellID
            }
        end
    end
    
    -- Compare with previous auras
    if not self.previousAuras then
        self.previousAuras = currentAuras
        return
    end
    
    -- Find gained auras
    for spellID, aura in pairs(currentAuras) do
        if not self.previousAuras[spellID] then
            self:CreateNotification(aura, "gained")
        end
    end
    
    -- Find lost auras
    for spellID, aura in pairs(self.previousAuras) do
        if not currentAuras[spellID] then
            self:CreateNotification(aura, "faded")
        end
    end
    
    -- Update previous auras
    self.previousAuras = currentAuras
end

-- Functions to interact with OmniCC module if it's enabled
function BuffOverlay:SetupWithOmniCC()
    if not VUI:IsModuleEnabled("omnicc") then return end
    
    local config = VUI.db.profile.modules.buffoverlay
    
    -- If OmniCC is handling timers, we can hide our own
    if config.useOmniCCTimers then
        config.showTimer = false
        
        -- Update all the cooldown frames to use OmniCC
        for _, frame in pairs(self.frames) do
            if frame.cooldown then
                frame.cooldown.noCooldownCount = nil
            end
        end
    else
        -- Make sure our cooldown frames don't use OmniCC
        for _, frame in pairs(self.frames) do
            if frame.cooldown then
                frame.cooldown.noCooldownCount = true
            end
        end
    end
    
    self:UpdateSettings()
end

-- Handle interaction with the MoveAny module
function BuffOverlay:RegisterWithMoveAny()
    if not VUI:IsModuleEnabled("moveany") then return end
    
    local MoveAny = VUI.modules.moveany
    if MoveAny and MoveAny.RegisterFrame and self.container then
        MoveAny:RegisterFrame(self.container, "BuffOverlay", true)
    end
end
