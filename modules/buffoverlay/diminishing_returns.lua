--[[
    VUI - BuffOverlay Diminishing Returns Tracking
    Version: 1.0.0
    Author: VortexQ8
    
    This file implements diminishing returns tracking for the BuffOverlay module:
    - PvP crowd control duration tracking
    - Visual indicators for diminishing returns status
    - Category-based DR classification
    - Duration calculations for subsequent DRs
    - Timers for DR reset tracking
    - Integration with BuffOverlay UI
]]

local addonName, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end

if not VUI.modules.buffoverlay then return end

-- Namespaces
local BuffOverlay = VUI.modules.buffoverlay
BuffOverlay.DiminishingReturns = {}
local DR = BuffOverlay.DiminishingReturns

-- Import commonly used globals into locals for performance
local GetTime = GetTime
local UnitGUID = UnitGUID
local string_match = string.match
local string_format = string.format
local math_floor = math.floor
local tinsert, tremove, pairs, ipairs = table.insert, table.remove, pairs, ipairs

-- DR settings defaults
local drDefaults = {
    enabled = true,
    showDRIcon = true,
    showDRText = true,
    drColors = {
        none = {1.0, 1.0, 1.0, 1.0},     -- 100%
        half = {1.0, 0.5, 0.0, 1.0},     -- 50%
        quarter = {1.0, 0.0, 0.0, 1.0},  -- 25%
        immune = {0.5, 0.1, 0.1, 1.0},   -- 0% (immune)
    },
    drIconSize = 16,
    drIconPosition = "TOPRIGHT",
    drIconOffset = {x = -3, y = -3},
    drTextSize = 10,
    drTextPosition = "BOTTOMRIGHT",
    drTextOffset = {x = 3, y = 3},
    trackNPCs = false,                      -- Track DRs on NPCs (off by default)
    drResetTime = 18.5,                     -- Time in seconds for DR to reset
    showRemainingTime = true,               -- Show time until reset
    showFullDuration = false,               -- Show remaining/full duration
    highlightImmuneTarget = true,           -- Highlight entire target when immune
    immuneHighlightColor = {1.0, 0.0, 0.0, 0.3}, -- Red tint for immune targets
    playSoundOnImmune = true,               -- Play sound when target becomes immune
    immuneSoundFile = "Sound\\Interface\\PVPFlagCaptured.ogg",
    autohideDR = true,                      -- Hide DR icons when DR resets
    separateTracking = true,                -- Track DRs separately for different targets
    categoryIconScale = {
        none = 1.0,       -- 100% normal scale
        half = 0.9,       -- 50% slightly smaller
        quarter = 0.8,    -- 25% even smaller 
        immune = 0.7,     -- 0% smallest
    },
    showDRAsOverlay = true,                 -- Show as overlay on buff icon vs. separate icon
    drOverlayStyle = "corner",              -- corner, border, number
    borderThickness = 2,                    -- For border style
}

-- DR Categories based on spell type (PvP)
-- Values are based on WoW's DR system
local drCategories = {
    stun = {
        name = "Stuns",
        duration = 1.0, -- Base duration multiplier
        icon = 132298,  -- Icon texture for stun
        spells = {
            [5211] = true,     -- Mighty Bash (Druid)
            [853] = true,      -- Hammer of Justice (Paladin)
            [1833] = true,     -- Cheap Shot (Rogue)
            [408] = true,      -- Kidney Shot (Rogue)
            [163505] = true,   -- Rake Stun (Druid)
            [119381] = true,   -- Leg Sweep (Monk)
            [30283] = true,    -- Shadowfury (Warlock)
            [132169] = true,   -- Storm Bolt (Warrior)
            [118905] = true,   -- Static Charge (Shaman)
            [204437] = true,   -- Lightning Lasso (Shaman)
            [217832] = true,   -- Imprison (Demon Hunter)
            [211881] = true,   -- Fel Eruption (Demon Hunter)
            [205630] = true,   -- Illidan's Grasp (Demon Hunter)
            [221527] = true,   -- Imprison (Demon Hunter)
            [200166] = true,   -- Metamorphosis Stun (Demon Hunter)
            [24394] = true,    -- Intimidation (Hunter)
            [117526] = true,   -- Binding Shot (Hunter)
            [19577] = true,    -- Intimidation (Hunter)
            [334693] = true,   -- Absolute Zero (Death Knight)
            [64044] = true,    -- Psychic Horror (Priest)
            [200200] = true,   -- Holy Word: Chastise (Priest)
            [226943] = true,   -- Mind Bomb (Priest)
            [46968] = true,    -- Shockwave (Warrior)
            [107570] = true,   -- Storm Bolt (Warrior)
            [118345] = true,   -- Pulverize (Warrior)
            [305485] = true,   -- Lightning Lasso (Shaman)
            [118345] = true,   -- Pulverize (Warrior)
            [179057] = true,   -- Chaos Nova (Demon Hunter)
            [118345] = true,   -- Pulverize (Warrior)
            [305485] = true,   -- Lightning Lasso (Shaman)
            [305484] = true,   -- Lightning Lasso (Shaman)
            [255723] = true,   -- Bull Rush (Tauren Racial)
            [287712] = true,   -- Haymaker (Kul Tiran Racial)
        },
    },
    incapacitate = {
        name = "Incapacitates",
        duration = 1.0,
        icon = 136168,  -- Icon texture for incapacitate
        spells = {
            [6770] = true,     -- Sap (Rogue)
            [1776] = true,     -- Gouge (Rogue)
            [115078] = true,   -- Paralysis (Monk)
            [20066] = true,    -- Repentance (Paladin)
            [9484] = true,     -- Shackle Undead (Priest)
            [3355] = true,     -- Freezing Trap (Hunter)
            [203337] = true,   -- Freezing Trap (Hunter)
            [213691] = true,   -- Scatter Shot (Hunter)
            [118] = true,      -- Polymorph (Mage)
            [28272] = true,    -- Polymorph (Pig) (Mage)
            [28271] = true,    -- Polymorph (Turtle) (Mage)
            [61305] = true,    -- Polymorph (Black Cat) (Mage)
            [61025] = true,    -- Polymorph (Serpent) (Mage)
            [61721] = true,    -- Polymorph (Rabbit) (Mage)
            [61780] = true,    -- Polymorph (Turkey) (Mage)
            [161353] = true,   -- Polymorph (Polar Bear Cub) (Mage)
            [161354] = true,   -- Polymorph (Monkey) (Mage)
            [161355] = true,   -- Polymorph (Penguin) (Mage)
            [161372] = true,   -- Polymorph (Peacock) (Mage)
            [277792] = true,   -- Polymorph (Bumblebee) (Mage)
            [277787] = true,   -- Polymorph (Direhorn) (Mage)
            [51514] = true,    -- Hex (Shaman)
            [211004] = true,   -- Hex (Spider) (Shaman)
            [210873] = true,   -- Hex (Raptor) (Shaman)
            [211015] = true,   -- Hex (Cockroach) (Shaman)
            [211010] = true,   -- Hex (Snake) (Shaman)
            [269352] = true,   -- Hex (Skeletal Hatchling) (Shaman)
            [277778] = true,   -- Hex (Zandalari Tendonripper) (Shaman)
            [277784] = true,   -- Hex (Wicker Mongrel) (Shaman)
            [82691] = true,    -- Ring of Frost (Mage)
            [217832] = true,   -- Imprison (Demon Hunter)
            [221527] = true,   -- Imprison (Demon Hunter)
            [99] = true,       -- Psychic Scream (Priest)
            [8122] = true,     -- Psychic Scream (Priest)
            [2094] = true,     -- Blind (Rogue)
            [88625] = true,    -- Holy Word: Chastise (Priest)
            [375901] = true,   -- Mind Games (Priest)
            [200196] = true,   -- Holy Word: Chastise (Priest)
            [127465] = true,   -- Overcharged Wired Core (Miscellaneous)
        },
    },
    disorient = {
        name = "Disorients",
        duration = 1.0,
        icon = 136183, -- Icon texture for disorient
        spells = {
            [207167] = true,   -- Blinding Sleet (Death Knight)
            [31661] = true,    -- Dragon's Breath (Mage)
            [198909] = true,   -- Song of Chi-Ji (Monk)
            [202274] = true,   -- Incendiary Brew (Monk)
            [105421] = true,   -- Blinding Light (Paladin)
            [605] = true,      -- Mind Control (Priest)
            [8122] = true,     -- Psychic Scream (Priest)
            [226943] = true,   -- Mind Bomb (Priest)
            [2094] = true,     -- Blind (Rogue)
            [118699] = true,   -- Fear (Warlock)
            [6789] = true,     -- Mortal Coil (Warlock)
            [5246] = true,     -- Intimidating Shout (Warrior)
            [386997] = true,   -- Intimidating Shout (Warrior)
            [5484] = true,     -- Howl of Terror (Warlock)
            [115268] = true,   -- Mesmerize (Warlock)
            [6358] = true,     -- Seduction (Warlock)
            [171017] = true,   -- Meteor Strike (Miscellaneous)
            [46968] = true,    -- Shockwave (Warrior)
        },
    },
    silence = {
        name = "Silences",
        duration = 1.0,
        icon = 458230, -- Icon texture for silence
        spells = {
            [47476] = true,    -- Strangulate (Death Knight)
            [204490] = true,   -- Sigil of Silence (Demon Hunter)
            [78675] = true,    -- Solar Beam (Druid)
            [217824] = true,   -- Shield of Virtue (Paladin)
            [15487] = true,    -- Silence (Priest)
            [1330] = true,     -- Garrote (Rogue)
            [196364] = true,   -- Unstable Affliction Silence (Warlock)
        },
    },
    root = {
        name = "Roots",
        duration = 1.0,
        icon = 136100, -- Icon texture for root
        spells = {
            [339] = true,      -- Entangling Roots (Druid)
            [102359] = true,   -- Mass Entanglement (Druid)
            [45334] = true,    -- Immobilized (Druid)
            [122] = true,      -- Frost Nova (Mage)
            [33395] = true,    -- Freeze (Mage)
            [233582] = true,   -- Entrenched in Flame (Mage)
            [116706] = true,   -- Disable (Monk)
            [64695] = true,    -- Earthgrab (Shaman)
            [199042] = true,   -- Thunderstruck (Demon Hunter)
            [102359] = true,   -- Mass Entanglement (Druid)
            [136634] = true,   -- Narrowing Shadows (Priest)
            [135373] = true,   -- Entomb (Priest)
            [107566] = true,   -- Staggering Shout (Warrior)
            [198121] = true,   -- Frostbite (Mage)
            [204085] = true,   -- Deathchill (Death Knight)
            [233395] = true,   -- Deathchill (Death Knight)
            [115197] = true,   -- Partial Paralysis (Warlock)
            [117526] = true,   -- Binding Shot (Hunter)
            [162480] = true,   -- Steel Trap (Hunter)
            [190927] = true,   -- Harpoon (Hunter)
            [91807] = true,    -- Shambling Rush (Death Knight)
            [114404] = true,   -- Void Tendril's Grasp (Priest)
            [392361] = true,   -- Earthen Grasp (Shaman)
            [64695] = true,    -- Earthgrab Totem (Shaman)
        },
    },
    disarm = {
        name = "Disarms",
        duration = 1.0,
        icon = 135428, -- Icon texture for disarm
        spells = {
            [236077] = true,   -- Disarm (Warrior)
            [209749] = true,   -- Faerie Swarm (Druid)
            [233759] = true,   -- Grapple Weapon (Monk)
            [217668] = true,   -- Entangling Stars (Druid)
            [163505] = true,   -- Rake (Druid)
            [117952] = true,   -- Crackling Jade Shock (Monk)
            [25046] = true,    -- Arcane Torrent (Blood Elf Racial)
        },
    },
}

-- Store active DR timers
local activeDRs = {}

-- Store DR states for each target/category
local drStates = {}

-- Current DR state tracking (for internal use)
local currentDR = {
    guid = nil,
    category = nil,
    state = nil,
    expires = nil,
}

-- Track when events fired last (for performance)
local lastEventTime = {
    UNIT_AURA = 0,
    COMBAT_LOG_EVENT_UNFILTERED = 0,
}

-- Initialize the diminishing returns system
function DR:Initialize()
    -- Register DB defaults
    if not BuffOverlay.db.profile.diminishingReturns then
        BuffOverlay.db.profile.diminishingReturns = drDefaults
    else
        -- Update any missing fields for version compatibility
        for k, v in pairs(drDefaults) do
            if BuffOverlay.db.profile.diminishingReturns[k] == nil then
                BuffOverlay.db.profile.diminishingReturns[k] = v
            end
            
            -- Handle nested tables
            if type(v) == "table" and type(BuffOverlay.db.profile.diminishingReturns[k]) == "table" then
                for innerKey, innerValue in pairs(v) do
                    if BuffOverlay.db.profile.diminishingReturns[k][innerKey] == nil then
                        BuffOverlay.db.profile.diminishingReturns[k][innerKey] = innerValue
                    end
                end
            end
        end
    end
    
    -- Register events for tracking DR
    BuffOverlay:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", DR.COMBAT_LOG_EVENT_UNFILTERED)
    BuffOverlay:RegisterEvent("PLAYER_ENTERING_WORLD", DR.Reset)
    
    -- Hook into frame creation
    self:HookFrameCreation()
    
    -- Hook into aura display
    self:HookAuraDisplay()
    
    -- Initialize textures
    self:LoadDRTextures()
    
    -- Register configuration options
    self:RegisterDROptions()
    
    -- Create a timer to manage DR states
    self.timer = C_Timer.NewTicker(0.1, function() DR:UpdateDRStates() end)
    
    -- Diminishing returns tracking initialized
end

-- Load DR status textures
function DR:LoadDRTextures()
    self.textures = {
        half = "Interface\\AddOns\\VUI\\media\\textures\\dr\\dr_half.tga",
        quarter = "Interface\\AddOns\\VUI\\media\\textures\\dr\\dr_quarter.tga",
        immune = "Interface\\AddOns\\VUI\\media\\textures\\dr\\dr_immune.tga",
    }
    
    -- Check if we're using the atlas system
    if VUI.Atlas then
        for key, path in pairs(self.textures) do
            local atlasTextureInfo = VUI:GetTextureCached(path)
            if atlasTextureInfo and atlasTextureInfo.isAtlas then
                self.textures[key] = {
                    path = atlasTextureInfo.path,
                    coords = atlasTextureInfo.coords,
                    isAtlas = true
                }
            end
        end
    end
end

-- Hook into frame creation to add DR elements
function DR:HookFrameCreation()
    local originalCreateBuffFrame = BuffOverlay.CreateBuffFrame
    
    if originalCreateBuffFrame then
        BuffOverlay.CreateBuffFrame = function(self, index)
            local frame = originalCreateBuffFrame(self, index)
            
            -- Add DR icon
            if not frame.drIcon then
                frame.drIcon = frame:CreateTexture(nil, "OVERLAY")
                frame.drIcon:SetSize(BuffOverlay.db.profile.diminishingReturns.drIconSize, 
                                     BuffOverlay.db.profile.diminishingReturns.drIconSize)
                
                -- Position based on settings
                local position = BuffOverlay.db.profile.diminishingReturns.drIconPosition
                local xOffset = BuffOverlay.db.profile.diminishingReturns.drIconOffset.x
                local yOffset = BuffOverlay.db.profile.diminishingReturns.drIconOffset.y
                
                frame.drIcon:SetPoint(position, frame, position, xOffset, yOffset)
                frame.drIcon:Hide()
            end
            
            -- Add DR text
            if not frame.drText then
                frame.drText = frame:CreateFontString(nil, "OVERLAY")
                frame.drText:SetFont(VUI:GetFont(VUI.db.profile.appearance.font), 
                                     BuffOverlay.db.profile.diminishingReturns.drTextSize, 
                                     "OUTLINE")
                
                -- Position based on settings
                local position = BuffOverlay.db.profile.diminishingReturns.drTextPosition
                local xOffset = BuffOverlay.db.profile.diminishingReturns.drTextOffset.x
                local yOffset = BuffOverlay.db.profile.diminishingReturns.drTextOffset.y
                
                frame.drText:SetPoint(position, frame, position, xOffset, yOffset)
                frame.drText:Hide()
            end
            
            -- Add DR border overlay
            if not frame.drBorder then
                frame.drBorder = frame:CreateTexture(nil, "OVERLAY")
                frame.drBorder:SetPoint("TOPLEFT", frame, "TOPLEFT", -2, 2)
                frame.drBorder:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 2, -2)
                frame.drBorder:Hide()
            end
            
            return frame
        end
    end
    
    -- Also hook into FramePool if it exists
    if BuffOverlay.FramePool and BuffOverlay.FramePool.CreateBuffFrame then
        local originalPoolCreateBuffFrame = BuffOverlay.FramePool.CreateBuffFrame
        
        BuffOverlay.FramePool.CreateBuffFrame = function(self, index)
            local frame = originalPoolCreateBuffFrame(self, index)
            
            -- Add DR icon
            if not frame.drIcon then
                frame.drIcon = frame:CreateTexture(nil, "OVERLAY")
                frame.drIcon:SetSize(BuffOverlay.db.profile.diminishingReturns.drIconSize, 
                                     BuffOverlay.db.profile.diminishingReturns.drIconSize)
                
                -- Position based on settings
                local position = BuffOverlay.db.profile.diminishingReturns.drIconPosition
                local xOffset = BuffOverlay.db.profile.diminishingReturns.drIconOffset.x
                local yOffset = BuffOverlay.db.profile.diminishingReturns.drIconOffset.y
                
                frame.drIcon:SetPoint(position, frame, position, xOffset, yOffset)
                frame.drIcon:Hide()
            end
            
            -- Add DR text
            if not frame.drText then
                frame.drText = frame:CreateFontString(nil, "OVERLAY")
                frame.drText:SetFont(VUI:GetFont(VUI.db.profile.appearance.font), 
                                     BuffOverlay.db.profile.diminishingReturns.drTextSize, 
                                     "OUTLINE")
                
                -- Position based on settings
                local position = BuffOverlay.db.profile.diminishingReturns.drTextPosition
                local xOffset = BuffOverlay.db.profile.diminishingReturns.drTextOffset.x
                local yOffset = BuffOverlay.db.profile.diminishingReturns.drTextOffset.y
                
                frame.drText:SetPoint(position, frame, position, xOffset, yOffset)
                frame.drText:Hide()
            end
            
            -- Add DR border overlay
            if not frame.drBorder then
                frame.drBorder = frame:CreateTexture(nil, "OVERLAY")
                frame.drBorder:SetPoint("TOPLEFT", frame, "TOPLEFT", -2, 2)
                frame.drBorder:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 2, -2)
                frame.drBorder:Hide()
            end
            
            return frame
        end
    end
end

-- Hook into aura display functions
function DR:HookAuraDisplay()
    -- Hook into UpdateAura to apply DR information
    local originalUpdateAura = BuffOverlay.UpdateAura
    
    if originalUpdateAura then
        BuffOverlay.UpdateAura = function(self, frame, auraInfo)
            -- Call the original function
            originalUpdateAura(self, frame, auraInfo)
            
            -- Skip if auraInfo is missing or DR is disabled
            if not auraInfo or not BuffOverlay.db.profile.diminishingReturns.enabled then
                DR:HideDRIndicators(frame)
                return
            end
            
            -- Check if this spell is affected by DR
            local drCategory = DR:GetDRCategory(auraInfo.spellId)
            if not drCategory then
                DR:HideDRIndicators(frame)
                return
            end
            
            -- Get target GUID
            local targetGUID = auraInfo.unitGUID or UnitGUID(auraInfo.unit)
            if not targetGUID then
                DR:HideDRIndicators(frame)
                return
            end
            
            -- Get DR state for this target and category
            local drState = DR:GetDRState(targetGUID, drCategory)
            if not drState or drState == "none" then
                DR:HideDRIndicators(frame)
                return
            end
            
            -- Apply DR information to the frame
            DR:ApplyDRToFrame(frame, drState, auraInfo.duration, auraInfo.expirationTime)
        end
    end
end

-- Apply DR indicators to a frame
function DR:ApplyDRToFrame(frame, drState, duration, expirationTime)
    if not frame or not drState then return end
    
    local settings = BuffOverlay.db.profile.diminishingReturns
    
    -- Skip if disabled
    if not settings.enabled then
        self:HideDRIndicators(frame)
        return
    end
    
    -- Get DR reset time
    local now = GetTime()
    local resetTime = expirationTime + settings.drResetTime
    local timeLeft = resetTime - now
    
    -- Calculate remaining DR time
    local drTimeText = ""
    if settings.showRemainingTime and timeLeft > 0 then
        if timeLeft < 60 then
            drTimeText = string_format("%.0f", timeLeft)
        else
            drTimeText = string_format("%d:%02d", math_floor(timeLeft / 60), math_floor(timeLeft % 60))
        end
    end
    
    -- Choose the DR display style based on settings
    if settings.showDRAsOverlay then
        -- Display as an overlay on the buff itself
        self:ApplyDROverlay(frame, drState, drTimeText)
    else
        -- Display as separate icon
        self:ApplyDRIcon(frame, drState, drTimeText)
    end
    
    -- Scale the icon based on DR level
    if settings.categoryIconScale[drState] then
        frame:SetScale(settings.categoryIconScale[drState])
    end
    
    -- Apply additional highlighting for immune state
    if drState == "immune" and settings.highlightImmuneTarget then
        -- Create highlight overlay if it doesn't exist
        if not frame.immuneHighlight then
            frame.immuneHighlight = frame:CreateTexture(nil, "OVERLAY")
            frame.immuneHighlight:SetAllPoints(frame)
            frame.immuneHighlight:SetColorTexture(
                settings.immuneHighlightColor[1],
                settings.immuneHighlightColor[2],
                settings.immuneHighlightColor[3],
                settings.immuneHighlightColor[4]
            )
            frame.immuneHighlight:SetBlendMode("ADD")
        end
        
        frame.immuneHighlight:Show()
        
        -- Play sound for immune status if not played recently
        if settings.playSoundOnImmune and (not self.lastImmuneSound or now - self.lastImmuneSound > 2) then
            PlaySoundFile(settings.immuneSoundFile, "Master")
            self.lastImmuneSound = now
        end
    elseif frame.immuneHighlight then
        frame.immuneHighlight:Hide()
    end
end

-- Apply DR as an overlay on the buff icon
function DR:ApplyDROverlay(frame, drState, timeText)
    local settings = BuffOverlay.db.profile.diminishingReturns
    
    -- Hide the separate indicators first
    if frame.drIcon then frame.drIcon:Hide() end
    
    -- Apply border style
    if settings.drOverlayStyle == "border" and frame.drBorder then
        -- Get color for this DR state
        local color = settings.drColors[drState] or settings.drColors.none
        
        -- Set border thickness
        frame.drBorder:SetPoint("TOPLEFT", frame, "TOPLEFT", -settings.borderThickness, settings.borderThickness)
        frame.drBorder:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", settings.borderThickness, -settings.borderThickness)
        
        -- Set border color
        frame.drBorder:SetColorTexture(color[1], color[2], color[3], color[4])
        frame.drBorder:Show()
    elseif settings.drOverlayStyle == "corner" then
        -- Use corner indicator
        if frame.drText then
            frame.drText:SetText(timeText)
            
            if timeText ~= "" then
                frame.drText:Show()
            else
                frame.drText:Hide()
            end
        end
        
        if drState == "half" then
            frame.icon:SetVertexColor(1.0, 0.5, 0.0, 1.0)
        elseif drState == "quarter" then
            frame.icon:SetVertexColor(1.0, 0.0, 0.0, 1.0)
        elseif drState == "immune" then
            frame.icon:SetVertexColor(0.5, 0.1, 0.1, 1.0)
        end
    elseif settings.drOverlayStyle == "number" then
        -- Show numerical indicator
        if frame.drText then
            local drPercentage = "100%"
            if drState == "half" then drPercentage = "50%"
            elseif drState == "quarter" then drPercentage = "25%"
            elseif drState == "immune" then drPercentage = "0%"
            end
            
            frame.drText:SetText(drPercentage)
            frame.drText:Show()
        end
    end
end

-- Apply DR as a separate icon
function DR:ApplyDRIcon(frame, drState, timeText)
    if not frame.drIcon then return end
    
    local settings = BuffOverlay.db.profile.diminishingReturns
    
    -- Hide the overlay first
    if frame.drBorder then frame.drBorder:Hide() end
    
    -- Set DR icon based on state
    if drState == "half" then
        if type(self.textures.half) == "table" and self.textures.half.isAtlas then
            frame.drIcon:SetTexture(self.textures.half.path)
            frame.drIcon:SetTexCoord(
                self.textures.half.coords.left,
                self.textures.half.coords.right,
                self.textures.half.coords.top,
                self.textures.half.coords.bottom
            )
        else
            frame.drIcon:SetTexture(self.textures.half)
        end
        frame.drIcon:Show()
    elseif drState == "quarter" then
        if type(self.textures.quarter) == "table" and self.textures.quarter.isAtlas then
            frame.drIcon:SetTexture(self.textures.quarter.path)
            frame.drIcon:SetTexCoord(
                self.textures.quarter.coords.left,
                self.textures.quarter.coords.right,
                self.textures.quarter.coords.top,
                self.textures.quarter.coords.bottom
            )
        else
            frame.drIcon:SetTexture(self.textures.quarter)
        end
        frame.drIcon:Show()
    elseif drState == "immune" then
        if type(self.textures.immune) == "table" and self.textures.immune.isAtlas then
            frame.drIcon:SetTexture(self.textures.immune.path)
            frame.drIcon:SetTexCoord(
                self.textures.immune.coords.left,
                self.textures.immune.coords.right,
                self.textures.immune.coords.top,
                self.textures.immune.coords.bottom
            )
        else
            frame.drIcon:SetTexture(self.textures.immune)
        end
        frame.drIcon:Show()
    else
        frame.drIcon:Hide()
    end
    
    -- Set DR text if needed
    if frame.drText and settings.showDRText and timeText ~= "" then
        frame.drText:SetText(timeText)
        frame.drText:Show()
    elseif frame.drText then
        frame.drText:Hide()
    end
end

-- Hide all DR indicators on a frame
function DR:HideDRIndicators(frame)
    if not frame then return end
    
    -- Hide DR icon
    if frame.drIcon then
        frame.drIcon:Hide()
    end
    
    -- Hide DR text
    if frame.drText then
        frame.drText:Hide()
    end
    
    -- Hide DR border
    if frame.drBorder then
        frame.drBorder:Hide()
    end
    
    -- Hide immune highlight
    if frame.immuneHighlight then
        frame.immuneHighlight:Hide()
    end
    
    -- Reset vertex color
    if frame.icon then
        frame.icon:SetVertexColor(1, 1, 1, 1)
    end
    
    -- Reset scale
    frame:SetScale(1)
end

-- Get the DR category for a spell
function DR:GetDRCategory(spellId)
    if not spellId then return nil end
    
    -- Check each category
    for category, data in pairs(drCategories) do
        if data.spells[spellId] then
            return category
        end
    end
    
    return nil
end

-- Get the DR state for a target and category
function DR:GetDRState(guid, category)
    if not guid or not category then return "none" end
    
    -- Initialize GUID structure if it doesn't exist
    if not drStates[guid] then
        drStates[guid] = {}
    end
    
    -- Return current state or "none" as default
    return drStates[guid][category] or "none"
end

-- Set the DR state for a target and category
function DR:SetDRState(guid, category, state, duration, expires)
    if not guid or not category or not state then return end
    
    -- Initialize GUID structure if it doesn't exist
    if not drStates[guid] then
        drStates[guid] = {}
    end
    
    -- Set the state
    drStates[guid][category] = state
    
    -- Store in active DRs for tracking reset
    activeDRs[guid..category] = {
        guid = guid,
        category = category,
        state = state,
        duration = duration,
        expires = expires,
        resetTime = expires + BuffOverlay.db.profile.diminishingReturns.drResetTime
    }
    
    -- Update current DR state tracking
    currentDR = {
        guid = guid,
        category = category,
        state = state,
        expires = expires
    }
    
    -- DR state tracked in memory
end

-- Update all DR states (check for expired timers)
function DR:UpdateDRStates()
    local now = GetTime()
    local updated = false
    
    -- Check each active DR
    for key, dr in pairs(activeDRs) do
        if dr.resetTime and now > dr.resetTime then
            -- DR has reset
            if drStates[dr.guid] and drStates[dr.guid][dr.category] then
                drStates[dr.guid][dr.category] = "none"
                updated = true
                
                -- Remove from active DRs
                activeDRs[key] = nil
                
                -- DR state reset
            end
        end
    end
    
    -- Update displayed auras if any DR states changed
    if updated then
        BuffOverlay:UpdateAuras("player")
        if UnitExists("target") then BuffOverlay:UpdateAuras("target") end
        if UnitExists("focus") then BuffOverlay:UpdateAuras("focus") end
    end
end

-- Process a new CC effect and update DR state
function DR:ProcessCCEffect(guid, spellId, duration, expirationTime)
    if not guid or not spellId or not duration then return end
    
    -- Skip if DR tracking is disabled
    if not BuffOverlay.db.profile.diminishingReturns.enabled then return end
    
    -- Skip NPCs if option to track them is disabled
    if not BuffOverlay.db.profile.diminishingReturns.trackNPCs and not string_match(guid, "^Player") then
        return
    end
    
    -- Get DR category for this spell
    local category = self:GetDRCategory(spellId)
    if not category then return end
    
    -- Get current DR state
    local currentState = self:GetDRState(guid, category)
    local newState, newDuration
    
    -- Calculate new DR state based on current state
    if currentState == "none" then
        newState = "half"  -- First DR: 50% duration
        newDuration = duration * 0.5
    elseif currentState == "half" then
        newState = "quarter"  -- Second DR: 25% duration
        newDuration = duration * 0.25
    elseif currentState == "quarter" then
        newState = "immune"  -- Third DR: immune (0% duration)
        newDuration = 0
    else
        -- Should never reach here, but just to be safe
        newState = "immune"
        newDuration = 0
    end
    
    -- Set the new DR state
    self:SetDRState(guid, category, newState, newDuration, expirationTime)
end

-- Event handler for COMBAT_LOG_EVENT_UNFILTERED
function DR:COMBAT_LOG_EVENT_UNFILTERED()
    -- Throttle processing for performance
    local now = GetTime()
    if now - lastEventTime.COMBAT_LOG_EVENT_UNFILTERED < 0.1 then return end
    lastEventTime.COMBAT_LOG_EVENT_UNFILTERED = now
    
    -- Skip if DR tracking is disabled
    if not BuffOverlay.db.profile.diminishingReturns.enabled then return end
    
    -- Parse combat log
    local timestamp, event, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool, auraType, amount = CombatLogGetCurrentEventInfo()
    
    -- We only care about CC application events
    if event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH" then
        -- Check if this is a DR-affected spell
        local category = self:GetDRCategory(spellId)
        if not category then return end
        
        -- Only process if this is a player (or if we're tracking NPCs)
        local isPlayer = bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0
        if not isPlayer and not BuffOverlay.db.profile.diminishingReturns.trackNPCs then return end
        
        -- Get aura info for duration
        local duration, expirationTime
        
        -- Try to find on target first (most accurate)
        local unit = self:GetUnitFromGUID(destGUID)
        if unit then
            -- Find the aura on the unit
            local i = 1
            local name, _, _, _, _, _, expires, _, _, id = UnitAura(unit, i, "HARMFUL")
            
            while name do
                if id == spellId then
                    duration = expires - now
                    expirationTime = expires
                    break
                end
                i = i + 1
                name, _, _, _, _, _, expires, _, _, id = UnitAura(unit, i, "HARMFUL")
            end
        end
        
        -- If we couldn't find it, use a default duration based on spell
        if not duration or not expirationTime then
            -- Get base duration from spell data or use a default
            duration = self:GetSpellBaseDuration(spellId) or 10
            expirationTime = now + duration
        end
        
        -- Process the CC application
        self:ProcessCCEffect(destGUID, spellId, duration, expirationTime)
    elseif event == "UNIT_DIED" or event == "UNIT_DESTROYED" or event == "UNIT_DISSIPATES" then
        -- Clear DR states for this unit
        if drStates[destGUID] then
            drStates[destGUID] = nil
            
            -- Also remove from active DRs
            for key, dr in pairs(activeDRs) do
                if dr.guid == destGUID then
                    activeDRs[key] = nil
                end
            end
            
            -- Clear DR states when unit dies
        end
    end
end

-- Get a unit ID from a GUID
function DR:GetUnitFromGUID(guid)
    if not guid then return nil end
    
    -- Check common unit IDs
    if UnitGUID("target") == guid then return "target" end
    if UnitGUID("focus") == guid then return "focus" end
    if UnitGUID("player") == guid then return "player" end
    
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
    
    -- Check arena enemies
    for i = 1, 5 do
        local unit = "arena"..i
        if UnitExists(unit) and UnitGUID(unit) == guid then
            return unit
        end
    end
    
    return nil
end

-- Get the base duration of a spell
function DR:GetSpellBaseDuration(spellId)
    -- This would ideally use a comprehensive spell duration database
    -- For now, use some common durations for DR categories
    local category = self:GetDRCategory(spellId)
    if not category then return nil end
    
    -- Default durations by category (could be expanded for specific spells)
    local categoryDurations = {
        stun = 5,
        incapacitate = 8,
        disorient = 6,
        silence = 4,
        root = 8,
        disarm = 5,
    }
    
    return categoryDurations[category]
end

-- Reset all DR states (called when entering world)
function DR:Reset()
    wipe(drStates)
    wipe(activeDRs)
    
    -- All DR states reset
end

-- Register configuration options
function DR:RegisterDROptions()
    -- Hook into the BuffOverlay GetOptions function
    local originalGetOptions = BuffOverlay.GetOptions
    
    if not originalGetOptions then return end
    
    BuffOverlay.GetOptions = function(self)
        local options = originalGetOptions(self)
        
        -- Add DR options
        options.args.drHeader = {
            type = "header",
            name = "Diminishing Returns Tracking",
            order = 500
        }
        
        options.args.drEnabled = {
            type = "toggle",
            name = "Enable DR Tracking",
            desc = "Enable PvP diminishing returns tracking for crowd control effects",
            get = function() return self.db.profile.diminishingReturns.enabled end,
            set = function(_, value)
                self.db.profile.diminishingReturns.enabled = value
                self:UpdateAuras("player")
                if UnitExists("target") then self:UpdateAuras("target") end
                if UnitExists("focus") then self:UpdateAuras("focus") end
            end,
            width = "full",
            order = 501
        }
        
        options.args.drDisplayGroup = {
            type = "group",
            name = "Display Options",
            inline = true,
            order = 502,
            disabled = function() return not self.db.profile.diminishingReturns.enabled end,
            args = {
                showDRAsOverlay = {
                    type = "toggle",
                    name = "Show as Overlay",
                    desc = "Display DR status as an overlay on the buff icon instead of a separate icon",
                    get = function() return self.db.profile.diminishingReturns.showDRAsOverlay end,
                    set = function(_, value)
                        self.db.profile.diminishingReturns.showDRAsOverlay = value
                        self:UpdateAuras("player")
                        if UnitExists("target") then self:UpdateAuras("target") end
                        if UnitExists("focus") then self:UpdateAuras("focus") end
                    end,
                    width = "full",
                    order = 1
                },
                
                drOverlayStyle = {
                    type = "select",
                    name = "Overlay Style",
                    desc = "Choose how to display DR status when using overlay mode",
                    values = {
                        corner = "Color Tint",
                        border = "Colored Border",
                        number = "Percentage Text"
                    },
                    get = function() return self.db.profile.diminishingReturns.drOverlayStyle end,
                    set = function(_, value)
                        self.db.profile.diminishingReturns.drOverlayStyle = value
                        self:UpdateAuras("player")
                        if UnitExists("target") then self:UpdateAuras("target") end
                        if UnitExists("focus") then self:UpdateAuras("focus") end
                    end,
                    disabled = function() return not self.db.profile.diminishingReturns.enabled or not self.db.profile.diminishingReturns.showDRAsOverlay end,
                    width = "full",
                    order = 2
                },
                
                borderThickness = {
                    type = "range",
                    name = "Border Thickness",
                    desc = "Thickness of the DR border when using border style",
                    min = 1,
                    max = 5,
                    step = 1,
                    get = function() return self.db.profile.diminishingReturns.borderThickness end,
                    set = function(_, value)
                        self.db.profile.diminishingReturns.borderThickness = value
                        self:UpdateAuras("player")
                        if UnitExists("target") then self:UpdateAuras("target") end
                        if UnitExists("focus") then self:UpdateAuras("focus") end
                    end,
                    disabled = function() 
                        return not self.db.profile.diminishingReturns.enabled or 
                               not self.db.profile.diminishingReturns.showDRAsOverlay or
                               self.db.profile.diminishingReturns.drOverlayStyle ~= "border"
                    end,
                    width = "full",
                    order = 3
                },
                
                showDRIcon = {
                    type = "toggle",
                    name = "Show DR Icon",
                    desc = "Show an icon indicating the DR state",
                    get = function() return self.db.profile.diminishingReturns.showDRIcon end,
                    set = function(_, value)
                        self.db.profile.diminishingReturns.showDRIcon = value
                        self:UpdateAuras("player")
                        if UnitExists("target") then self:UpdateAuras("target") end
                        if UnitExists("focus") then self:UpdateAuras("focus") end
                    end,
                    disabled = function() return not self.db.profile.diminishingReturns.enabled or self.db.profile.diminishingReturns.showDRAsOverlay end,
                    width = "full",
                    order = 4
                },
                
                drIconSize = {
                    type = "range",
                    name = "DR Icon Size",
                    desc = "Size of the DR state icon",
                    min = 8,
                    max = 32,
                    step = 1,
                    get = function() return self.db.profile.diminishingReturns.drIconSize end,
                    set = function(_, value)
                        self.db.profile.diminishingReturns.drIconSize = value
                        self:UpdateAuras("player")
                        if UnitExists("target") then self:UpdateAuras("target") end
                        if UnitExists("focus") then self:UpdateAuras("focus") end
                    end,
                    disabled = function() return not self.db.profile.diminishingReturns.enabled or not self.db.profile.diminishingReturns.showDRIcon or self.db.profile.diminishingReturns.showDRAsOverlay end,
                    width = "full",
                    order = 5
                },
                
                drIconPosition = {
                    type = "select",
                    name = "DR Icon Position",
                    desc = "Position of the DR icon relative to the buff icon",
                    values = {
                        TOPLEFT = "Top Left",
                        TOPRIGHT = "Top Right",
                        BOTTOMLEFT = "Bottom Left",
                        BOTTOMRIGHT = "Bottom Right"
                    },
                    get = function() return self.db.profile.diminishingReturns.drIconPosition end,
                    set = function(_, value)
                        self.db.profile.diminishingReturns.drIconPosition = value
                        self:UpdateAuras("player")
                        if UnitExists("target") then self:UpdateAuras("target") end
                        if UnitExists("focus") then self:UpdateAuras("focus") end
                    end,
                    disabled = function() return not self.db.profile.diminishingReturns.enabled or not self.db.profile.diminishingReturns.showDRIcon or self.db.profile.diminishingReturns.showDRAsOverlay end,
                    width = "full",
                    order = 6
                },
                
                showDRText = {
                    type = "toggle",
                    name = "Show DR Timer Text",
                    desc = "Show remaining time until DR resets",
                    get = function() return self.db.profile.diminishingReturns.showDRText end,
                    set = function(_, value)
                        self.db.profile.diminishingReturns.showDRText = value
                        self:UpdateAuras("player")
                        if UnitExists("target") then self:UpdateAuras("target") end
                        if UnitExists("focus") then self:UpdateAuras("focus") end
                    end,
                    disabled = function() return not self.db.profile.diminishingReturns.enabled end,
                    width = "full",
                    order = 7
                },
                
                drTextSize = {
                    type = "range",
                    name = "DR Text Size",
                    desc = "Font size for DR timer text",
                    min = 6,
                    max = 16,
                    step = 1,
                    get = function() return self.db.profile.diminishingReturns.drTextSize end,
                    set = function(_, value)
                        self.db.profile.diminishingReturns.drTextSize = value
                        self:UpdateAuras("player")
                        if UnitExists("target") then self:UpdateAuras("target") end
                        if UnitExists("focus") then self:UpdateAuras("focus") end
                    end,
                    disabled = function() return not self.db.profile.diminishingReturns.enabled or not self.db.profile.diminishingReturns.showDRText end,
                    width = "full",
                    order = 8
                },
                
                showRemainingTime = {
                    type = "toggle",
                    name = "Show Remaining Time",
                    desc = "Show time remaining until DR resets",
                    get = function() return self.db.profile.diminishingReturns.showRemainingTime end,
                    set = function(_, value)
                        self.db.profile.diminishingReturns.showRemainingTime = value
                        self:UpdateAuras("player")
                        if UnitExists("target") then self:UpdateAuras("target") end
                        if UnitExists("focus") then self:UpdateAuras("focus") end
                    end,
                    disabled = function() return not self.db.profile.diminishingReturns.enabled or not self.db.profile.diminishingReturns.showDRText end,
                    width = "full",
                    order = 9
                },
            }
        }
        
        options.args.drBehaviorGroup = {
            type = "group",
            name = "Behavior Options",
            inline = true,
            order = 503,
            disabled = function() return not self.db.profile.diminishingReturns.enabled end,
            args = {
                trackNPCs = {
                    type = "toggle",
                    name = "Track NPCs",
                    desc = "Track diminishing returns on NPCs (e.g., dungeon and raid bosses)",
                    get = function() return self.db.profile.diminishingReturns.trackNPCs end,
                    set = function(_, value)
                        self.db.profile.diminishingReturns.trackNPCs = value
                    end,
                    width = "full",
                    order = 1
                },
                
                drResetTime = {
                    type = "range",
                    name = "DR Reset Time",
                    desc = "Time in seconds for diminishing returns to reset (default: 18.5)",
                    min = 10,
                    max = 30,
                    step = 0.5,
                    get = function() return self.db.profile.diminishingReturns.drResetTime end,
                    set = function(_, value)
                        self.db.profile.diminishingReturns.drResetTime = value
                    end,
                    width = "full",
                    order = 2
                },
                
                highlightImmuneTarget = {
                    type = "toggle",
                    name = "Highlight Immune Targets",
                    desc = "Add a color tint to targets that are immune to a CC effect",
                    get = function() return self.db.profile.diminishingReturns.highlightImmuneTarget end,
                    set = function(_, value)
                        self.db.profile.diminishingReturns.highlightImmuneTarget = value
                        self:UpdateAuras("player")
                        if UnitExists("target") then self:UpdateAuras("target") end
                        if UnitExists("focus") then self:UpdateAuras("focus") end
                    end,
                    width = "full",
                    order = 3
                },
                
                playSoundOnImmune = {
                    type = "toggle",
                    name = "Play Sound on Immune",
                    desc = "Play a sound when a target becomes immune to a CC effect",
                    get = function() return self.db.profile.diminishingReturns.playSoundOnImmune end,
                    set = function(_, value)
                        self.db.profile.diminishingReturns.playSoundOnImmune = value
                    end,
                    width = "full",
                    order = 4
                },
                
                separateTracking = {
                    type = "toggle",
                    name = "Track DRs Separately",
                    desc = "Track diminishing returns separately for different targets",
                    get = function() return self.db.profile.diminishingReturns.separateTracking end,
                    set = function(_, value)
                        self.db.profile.diminishingReturns.separateTracking = value
                        -- Reset all DR states when changing this option
                        DR:Reset()
                    end,
                    width = "full",
                    order = 5
                },
                
                autohideDR = {
                    type = "toggle",
                    name = "Auto-hide DR Icons",
                    desc = "Automatically hide DR indicators when DR resets",
                    get = function() return self.db.profile.diminishingReturns.autohideDR end,
                    set = function(_, value)
                        self.db.profile.diminishingReturns.autohideDR = value
                    end,
                    width = "full",
                    order = 6
                },
            }
        }
        
        return options
    end
end

-- Initialize the module
DR:Initialize()