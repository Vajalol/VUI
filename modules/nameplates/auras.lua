local _, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end
local Nameplates = VUI.nameplates

-- Auras management for VUI Plater
Nameplates.auras = {}
local Auras = Nameplates.auras

-- Initialize auras system
function Auras:Initialize()
    -- Create default important auras lists if they don't exist
    if not Nameplates.settings.whitelistedAuras then
        Nameplates.settings.whitelistedAuras = {}
    end
    
    if not Nameplates.settings.blacklistedAuras then
        Nameplates.settings.blacklistedAuras = {}
    end
    
    -- Setup default important auras for various content types
    self:SetupDefaultAuras()
end

-- Setup default important auras for various content types
function Auras:SetupDefaultAuras()
    -- Default whitelisted auras (always shown)
    local defaultWhitelist = {
        -- CC Effects
        [2094] = true,   -- Blind
        [118] = true,    -- Polymorph
        [853] = true,    -- Hammer of Justice
        [6770] = true,   -- Sap
        [1776] = true,   -- Gouge
        [5211] = true,   -- Mighty Bash
        [339] = true,    -- Entangling Roots
        [81261] = true,  -- Solar Beam
        [115078] = true, -- Paralysis
        [119381] = true, -- Leg Sweep
        [64695] = true,  -- Earthgrab
        [8122] = true,   -- Psychic Scream
        [9484] = true,   -- Shackle Undead
        [6789] = true,   -- Mortal Coil
        [5484] = true,   -- Howl of Terror
        [5246] = true,   -- Intimidating Shout
        
        -- Important Damage Reductions
        [45438] = true,  -- Ice Block
        [642] = true,    -- Divine Shield
        [871] = true,    -- Shield Wall
        [33206] = true,  -- Pain Suppression
        [47788] = true,  -- Guardian Spirit
        [1022] = true,   -- Blessing of Protection
        [116849] = true, -- Life Cocoon
        
        -- Healing Reductions
        [12294] = true,  -- Mortal Strike (Warrior)
        [115804] = true, -- Mortal Wounds (Monk)
        
        -- Offensive Cooldowns
        [190319] = true, -- Combustion
        [102560] = true, -- Incarnation
        [1719] = true,   -- Recklessness
        
        -- Important Dungeon Auras
        [209859] = true, -- Bolster
        [226510] = true, -- Sanguine
        [240443] = true, -- Bursting
        
        -- Enrage Effects (if setting enabled)
        [8599] = true,   -- Enrage
    }
    
    -- Apply default whitelist for any missing entries
    for spellId, value in pairs(defaultWhitelist) do
        if Nameplates.settings.whitelistedAuras[spellId] == nil then
            Nameplates.settings.whitelistedAuras[spellId] = value
        end
    end
    
    -- Default blacklisted auras (never shown)
    local defaultBlacklist = {
        -- Minor buffs that spam nameplate auras
        [186406] = true, -- Sign of the Skirmisher
        [58054] = true,  -- Shadow Mend (Periodic)
        [232698] = true, -- Shadow Form passive
        [15007] = true,  -- Resurrection Sickness
        
        -- Long-term auras that aren't relevant in combat
        [186401] = true, -- Well Fed
        [225788] = true, -- Sign of the Warrior
        [186403] = true, -- Sign of Battle
        
        -- Common buffs in dungeons that aren't critical to track
        [326419] = true, -- Winds of Wisdom
        [341559] = true, -- Demanding Presence (Tank passive)
    }
    
    -- Apply default blacklist for any missing entries
    for spellId, value in pairs(defaultBlacklist) do
        if Nameplates.settings.blacklistedAuras[spellId] == nil then
            Nameplates.settings.blacklistedAuras[spellId] = value
        end
    end
end

-- Should this aura be shown on nameplates?
function Auras:ShouldShowAura(spellId, isBuff, caster, duration)
    -- Always show whitelisted auras
    if Nameplates.settings.whitelistedAuras[spellId] then
        return true
    end
    
    -- Never show blacklisted auras
    if Nameplates.settings.blacklistedAuras[spellId] then
        return false
    end
    
    -- If aura filtering is disabled, show all auras
    if not Nameplates.settings.filterAuras then
        return true
    end
    
    -- Special handling for enrage effects
    local spellInfo = GetSpellInfo(spellId)
    if Nameplates.settings.showEnrageEffects then
        -- Detect enrage effects by checking for dispellable buffs with Enrage type
        local dispelType = select(5, UnitAura("target", spellInfo, nil, "HELPFUL"))
        if dispelType == "Enrage" then
            return true
        end
    end
    
    -- Only show short-to-medium duration auras (< 5 minutes)
    if duration and duration > 300 then
        return false
    end
    
    -- Prioritize debuffs if setting enabled
    if Nameplates.settings.prioritizeDebuffs and not isBuff then
        return true
    end
    
    -- Only show player-cast auras by default
    if caster and UnitIsUnit(caster, "player") then
        return true
    end
    
    -- Default filtering behavior
    return false
end

-- Create an aura icon for a nameplate
function Auras:CreateAuraIcon(unitFrame, auraIndex)
    if not unitFrame.VUIAuras then
        unitFrame.VUIAuras = {}
    end
    
    if unitFrame.VUIAuras[auraIndex] then
        return unitFrame.VUIAuras[auraIndex]
    end
    
    -- Create the aura frame
    local aura = CreateFrame("Frame", nil, unitFrame)
    aura:SetSize(Nameplates.settings.auraSize, Nameplates.settings.auraSize)
    
    -- Create the icon texture
    aura.icon = aura:CreateTexture(nil, "ARTWORK")
    aura.icon:SetAllPoints(aura)
    aura.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Trim the borders
    
    -- Create the border
    aura.border = aura:CreateTexture(nil, "OVERLAY")
    aura.border:SetPoint("TOPLEFT", aura.icon, "TOPLEFT", -1, 1)
    aura.border:SetPoint("BOTTOMRIGHT", aura.icon, "BOTTOMRIGHT", 1, -1)
    aura.border:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
    aura.border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
    
    -- Create the cooldown frame
    aura.cooldown = CreateFrame("Cooldown", nil, aura, "CooldownFrameTemplate")
    aura.cooldown:SetAllPoints(aura.icon)
    aura.cooldown:SetReverse(true)
    aura.cooldown:SetHideCountdownNumbers(true)
    
    -- Create the count text
    aura.count = aura:CreateFontString(nil, "OVERLAY")
    aura.count:SetPoint("BOTTOMRIGHT", aura, "BOTTOMRIGHT", 0, 0)
    aura.count:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
    
    -- Store in the unit frame
    unitFrame.VUIAuras[auraIndex] = aura
    
    return aura
end

-- Update auras for a nameplate
function Auras:UpdateAuras(unitFrame)
    if not Nameplates.settings.showAuras then
        return
    end
    
    local unit = unitFrame.namePlateUnitToken
    if not unit then
        return
    end
    
    -- Initialize auras container if needed
    if not unitFrame.VUIAuras then
        unitFrame.VUIAuras = {}
    end
    
    -- Get all auras
    local auras = {}
    local auraCount = 0
    local maxAuras = Nameplates.settings.maxAuras or 6
    
    -- Process buffs
    for i = 1, 40 do
        local name, icon, count, debuffType, duration, expirationTime, caster, _, _, spellId = UnitBuff(unit, i)
        if not name then break end
        
        if self:ShouldShowAura(spellId, true, caster, duration) then
            auraCount = auraCount + 1
            auras[auraCount] = {
                name = name,
                icon = icon,
                count = count,
                dispelType = debuffType,
                duration = duration,
                expirationTime = expirationTime,
                caster = caster,
                spellId = spellId,
                isBuff = true
            }
            
            if auraCount >= maxAuras then break end
        end
    end
    
    -- Process debuffs
    for i = 1, 40 do
        local name, icon, count, debuffType, duration, expirationTime, caster, _, _, spellId = UnitDebuff(unit, i)
        if not name then break end
        
        if self:ShouldShowAura(spellId, false, caster, duration) then
            auraCount = auraCount + 1
            auras[auraCount] = {
                name = name,
                icon = icon,
                count = count,
                dispelType = debuffType,
                duration = duration,
                expirationTime = expirationTime,
                caster = caster,
                spellId = spellId,
                isBuff = false
            }
            
            if auraCount >= maxAuras then break end
        end
    end
    
    -- Sort auras if we have any
    if auraCount > 0 then
        if Nameplates.settings.auraSortMode == "duration" then
            table.sort(auras, function(a, b)
                -- Sort by duration, shortest first
                if a.duration == 0 and b.duration == 0 then
                    return a.name < b.name -- Alphabetical if both are permanent
                elseif a.duration == 0 then
                    return false -- Permanent auras go last
                elseif b.duration == 0 then
                    return true -- Permanent auras go last
                else
                    return a.duration < b.duration
                end
            end)
        elseif Nameplates.settings.auraSortMode == "name" then
            table.sort(auras, function(a, b)
                return a.name < b.name
            end)
        end
    end
    
    -- Position auras
    local startX, startY, xMod, yMod = 0, 0, 0, 0
    local size = Nameplates.settings.auraSize or 22
    local spacing = Nameplates.settings.auraSpacing or 1
    local totalWidth = (size + spacing) * maxAuras - spacing
    
    -- Determine aura anchoring based on auraPosition
    if Nameplates.settings.auraPosition == "top" then
        startX = -totalWidth / 2
        startY = unitFrame:GetHeight() + spacing
        xMod = size + spacing
        yMod = 0
    elseif Nameplates.settings.auraPosition == "bottom" then
        startX = -totalWidth / 2
        startY = -size - spacing
        xMod = size + spacing
        yMod = 0
    elseif Nameplates.settings.auraPosition == "left" then
        startX = -size - spacing
        startY = -unitFrame:GetHeight() / 2
        xMod = 0
        yMod = -(size + spacing)
    elseif Nameplates.settings.auraPosition == "right" then
        startX = unitFrame:GetWidth() + spacing
        startY = -unitFrame:GetHeight() / 2
        xMod = 0
        yMod = -(size + spacing)
    end
    
    -- Update aura icons
    for i = 1, maxAuras do
        local auraIcon = self:CreateAuraIcon(unitFrame, i)
        
        if i <= auraCount then
            local aura = auras[i]
            
            -- Set icon texture
            auraIcon.icon:SetTexture(aura.icon)
            
            -- Set border color based on aura type
            if aura.isBuff then
                auraIcon.border:SetVertexColor(0, 1, 0, 1) -- Green for buffs
            elseif aura.dispelType then
                local color = DebuffTypeColor[aura.dispelType]
                if color then
                    auraIcon.border:SetVertexColor(color.r, color.g, color.b, 1)
                else
                    auraIcon.border:SetVertexColor(0.8, 0, 0, 1) -- Red for debuffs
                end
            else
                auraIcon.border:SetVertexColor(0.8, 0, 0, 1) -- Red for debuffs
            end
            
            -- Set cooldown if needed
            if Nameplates.settings.showAuraCooldown and aura.duration and aura.duration > 0 then
                auraIcon.cooldown:SetCooldown(aura.expirationTime - aura.duration, aura.duration)
                auraIcon.cooldown:Show()
            else
                auraIcon.cooldown:Hide()
            end
            
            -- Set count if needed
            if Nameplates.settings.showAuraStacks and aura.count and aura.count > 1 then
                auraIcon.count:SetText(aura.count)
                auraIcon.count:Show()
            else
                auraIcon.count:Hide()
            end
            
            -- Position the aura
            auraIcon:ClearAllPoints()
            auraIcon:SetPoint("TOPLEFT", unitFrame, "CENTER", startX + (i-1) * xMod, startY + (i-1) * yMod)
            auraIcon:Show()
        else
            auraIcon:Hide()
        end
    end
end