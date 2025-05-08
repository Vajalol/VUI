-- VUIPlater Module
-- A standalone nameplate module for VUI
-- Based on Whiiskeyz Plater profile (https://wago.io/whiiskeyzplater)

local AddonName, VUI = ...
local MODNAME = "VUIPlater"
local M = VUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0", "AceHook-3.0")

-- Localization
local L = LibStub("AceLocale-3.0"):GetLocale("VUI")

-- Module Constants
M.NAME = MODNAME
M.TITLE = "VUI Plater"
M.DESCRIPTION = "Custom nameplate styling based on Whiiskeyz Plater profile"
M.VERSION = "1.0"

-- Libraries
local LSM = LibStub("LibSharedMedia-3.0")

-- Default settings
M.defaults = {
    profile = {
        enabled = true,
        -- Enemy Nameplate Settings
        enemy = {
            enabled = true,
            width = 140,
            height = 10,
            castBarHeight = 10,
            scale = 1.0,
            healthBarTexture = "VUI Gradient",
            castBarTexture = "VUI Gradient",
            borderStyle = "VUI_BORDER_1PX",
            borderSize = 1,
            fontName = "Arial Narrow",
            fontSize = 10,
            fontOutline = "OUTLINE",
            useClassColors = true,
            healthBarColor = {r = 0.85, g = 0.2, b = 0.2, a = 1},
            healthBgColor = {r = 0.1, g = 0.1, b = 0.1, a = 0.8},
            borderColor = {r = 0, g = 0, b = 0, a = 1},
            castBarColor = {r = 0.4, g = 0.6, b = 0.8, a = 1},
            castBarBgColor = {r = 0.1, g = 0.1, b = 0.1, a = 0.8},
            interruptedCastColor = {r = 0.3, g = 0.3, b = 0.3, a = 1},
            nonInterruptibleCastColor = {r = 0.7, g = 0.4, b = 0, a = 1},
            targetHighlightColor = {r = 1, g = 1, b = 1, a = 0.3},
            eliteBorderColor = {r = 1, g = 0.85, b = 0, a = 1},
            executionIndicator = true,
            executionThreshold = 35,
            showEliteBorder = true,
            showTargetBorder = true,
            showLevel = true,
            showName = true,
            showHealthPercent = true,
            showHealthValue = false,
            showEnemyClassIcon = true,
            showCastTarget = true,
            showInterruptShield = true,
            flashOnAggro = true,
            fadeNonTargets = true,
            fadeAmount = 0.6,
            scaleTarget = true,
            targetScale = 1.2,
            threatWarning = true,
            showWarningGlow = true,
            showThreatPercent = true,
            highThreatColor = {r = 1, g = 0.3, b = 0.3, a = 1},
            tankMode = false,
            nameLength = 20,
            -- Buffs and Debuffs
            showBuffs = true,
            showDebuffs = true,
            buffSize = 20,
            debuffSize = 24,
            filterBuffs = true,
            filterDebuffs = false,
            showOnlyMyDebuffs = true,
            showOnlyImportantBuffs = true,
            buffRows = 1,
            debuffRows = 2,
            buffColumns = 3,
            debuffColumns = 3,
            showBuffDuration = true,
            showDebuffDuration = true,
            showBuffStacks = true,
            showDebuffStacks = true,
            buffPosition = "TOP",
            debuffPosition = "BOTTOM",
        },
        -- Friendly Nameplate Settings
        friendly = {
            enabled = true,
            width = 140,
            height = 10,
            castBarHeight = 10,
            scale = 1.0,
            healthBarTexture = "VUI Gradient",
            castBarTexture = "VUI Gradient",
            borderStyle = "VUI_BORDER_1PX",
            borderSize = 1,
            fontName = "Arial Narrow",
            fontSize = 10,
            fontOutline = "OUTLINE",
            useClassColors = true,
            healthBarColor = {r = 0.2, g = 0.8, b = 0.2, a = 1},
            healthBgColor = {r = 0.1, g = 0.1, b = 0.1, a = 0.8},
            borderColor = {r = 0, g = 0, b = 0, a = 1},
            castBarColor = {r = 0.4, g = 0.6, b = 0.8, a = 1},
            castBarBgColor = {r = 0.1, g = 0.1, b = 0.1, a = 0.8},
            targetHighlightColor = {r = 1, g = 1, b = 1, a = 0.3},
            showTargetBorder = true,
            showLevel = true,
            showName = true,
            showHealthPercent = true,
            showHealthValue = false,
            showFriendlyClassIcon = true,
            fadeNonTargets = true,
            fadeAmount = 0.6,
            scaleTarget = true,
            targetScale = 1.2,
            nameLength = 20,
            -- Buffs and Debuffs
            showBuffs = false,
            showDebuffs = true,
            buffSize = 20,
            debuffSize = 24,
            filterBuffs = true,
            filterDebuffs = false,
            showOnlyMyDebuffs = true,
            showOnlyImportantBuffs = true,
            buffRows = 1,
            debuffRows = 1,
            buffColumns = 3,
            debuffColumns = 3,
            showBuffDuration = true,
            showDebuffDuration = true,
            showBuffStacks = true,
            showDebuffStacks = true,
            buffPosition = "TOP",
            debuffPosition = "BOTTOM",
        },
        -- Player Nameplate Settings
        player = {
            enabled = true,
            width = 140,
            height = 10,
            scale = 1.0,
            healthBarTexture = "VUI Gradient",
            castBarTexture = "VUI Gradient",
            castBarHeight = 10,
            borderStyle = "VUI_BORDER_1PX",
            borderSize = 1,
            fontName = "Arial Narrow",
            fontSize = 10,
            fontOutline = "OUTLINE",
            useClassColors = true,
            healthBarColor = {r = 0.2, g = 0.6, b = 1.0, a = 1},
            healthBgColor = {r = 0.1, g = 0.1, b = 0.1, a = 0.8},
            borderColor = {r = 0, g = 0, b = 0, a = 1},
            castBarColor = {r = 0.4, g = 0.6, b = 0.8, a = 1},
            castBarBgColor = {r = 0.1, g = 0.1, b = 0.1, a = 0.8},
            showLevel = false,
            showName = true,
            showHealthPercent = true,
            showHealthValue = false,
            showClassIcon = false,
            nameLength = 20,
            -- Buffs and Debuffs
            showBuffs = false,
            showDebuffs = true,
            buffSize = 20,
            debuffSize = 24,
            filterDebuffs = false,
            showOnlyImportantDebuffs = true,
            debuffRows = 1,
            debuffColumns = 3,
            showDebuffDuration = true,
            showDebuffStacks = true,
            debuffPosition = "BOTTOM",
        },
        -- Performance Settings
        performance = {
            nameplateRange = 40,
            maxDisplayed = 40,
            clampToScreen = true,
            stackingNameplates = true,
            overlapProtection = true,
        },
        -- Misc Settings
        misc = {
            lockNameplates = true,
            showFriendlyNameplates = true,
            showEnemyNameplates = true,
            showPlayerNameplate = true,
            showNPCTitles = false,
            clickThroughProtection = true,
            hideNonCastingNameplates = false,
        },
        -- Presets
        currentPreset = "WHIISKEYZ",
    }
}

-- Important Aura Lists
M.importantBuffs = {
    -- Power Infusion
    [10060] = true,
    -- Bloodlust/Heroism and equivalents
    [2825] = true,   -- Bloodlust
    [32182] = true,  -- Heroism
    [80353] = true,  -- Time Warp
    [90355] = true,  -- Ancient Hysteria
    [160452] = true, -- Netherwinds
    -- Defensive abilities
    [1022] = true,   -- Blessing of Protection
    [33206] = true,  -- Pain Suppression
    [47788] = true,  -- Guardian Spirit
    [31224] = true,  -- Cloak of Shadows
    [45438] = true,  -- Ice Block
    [642] = true,    -- Divine Shield
    [186265] = true, -- Aspect of the Turtle
    [196555] = true, -- Netherwalk
    -- Other important buffs
    [8178] = true,   -- Grounding Totem
    [23920] = true,  -- Spell Reflection
}

M.importantDebuffs = {
    -- Crowd control
    [118] = true,    -- Polymorph
    [853] = true,    -- Hammer of Justice
    [6770] = true,   -- Sap
    [2094] = true,   -- Blind
    [20066] = true,  -- Repentance
    [339] = true,    -- Entangling Roots
    [3355] = true,   -- Freezing Trap
    [51514] = true,  -- Hex
    [8122] = true,   -- Psychic Scream
    [5782] = true,   -- Fear
    [6358] = true,   -- Seduction
    [605] = true,    -- Mind Control
    -- Offensive debuffs
    [1943] = true,   -- Rupture
    [772] = true,    -- Rend
    [12654] = true,  -- Ignite
    [34914] = true,  -- Vampiric Touch
    -- Important encounter debuffs
    [209858] = true, -- Necrotic Wound
    [240559] = true, -- Grievous Wound
}

-- Border textures
M.borderTextures = {
    ["VUI_BORDER_1PX"] = "Interface\\AddOns\\VUI\\Media\\modules\\VUIPlater\\textures\\border_1px.tga",
    ["VUI_BORDER_2PX"] = "Interface\\AddOns\\VUI\\Media\\modules\\VUIPlater\\textures\\border_2px.tga",
    ["VUI_BORDER_GLOW"] = "Interface\\AddOns\\VUI\\Media\\modules\\VUIPlater\\textures\\border_glow.tga",
}

-- Aura whitelist/blacklist
M.auraWhitelist = {}
M.auraBlacklist = {}

-- Nameplate cache
M.nameplates = {}
M.createdNameplates = {}

-- Initialize module
function M:OnInitialize()
    -- Register module with VUI
    self.db = VUI.db:RegisterNamespace(MODNAME, self.defaults)
    
    -- Register settings with VUI Config
    VUI.Config:RegisterModuleOptions(MODNAME, self:GetOptions(), self.TITLE)
    
    -- Create custom border textures
    self:CreateBorderTextures()
    
    -- Cache addon font media for LibSharedMedia
    self:RegisterFontMedia()
    
    -- Setup statusbar textures
    self:RegisterStatusBarTextures()
    
    -- Initialize counters
    self.plateCount = 0
    
    self:Debug("VUIPlater module initialized")
end

function M:OnEnable()
    -- Register events
    self:RegisterEvent("NAME_PLATE_CREATED", "OnNamePlateCreated")
    self:RegisterEvent("NAME_PLATE_UNIT_ADDED", "OnNamePlateAdded")
    self:RegisterEvent("NAME_PLATE_UNIT_REMOVED", "OnNamePlateRemoved")
    self:RegisterEvent("PLAYER_TARGET_CHANGED", "OnTargetChanged")
    self:RegisterEvent("UNIT_HEALTH", "OnUnitHealthChanged")
    self:RegisterEvent("UNIT_MAXHEALTH", "OnUnitHealthChanged")
    self:RegisterEvent("UNIT_POWER_UPDATE", "OnUnitPowerChanged")
    self:RegisterEvent("UNIT_DISPLAYPOWER", "OnUnitPowerChanged")
    self:RegisterEvent("UNIT_FACTION", "OnUnitFactionChanged")
    self:RegisterEvent("UNIT_NAME_UPDATE", "OnUnitNameUpdated")
    self:RegisterEvent("UNIT_LEVEL", "OnUnitLevelUpdated")
    self:RegisterEvent("UNIT_CLASSIFICATION_CHANGED", "OnUnitClassificationChanged")
    self:RegisterEvent("UNIT_AURA", "OnUnitAurasChanged")
    self:RegisterEvent("UNIT_SPELLCAST_START", "OnUnitCastStart")
    self:RegisterEvent("UNIT_SPELLCAST_STOP", "OnUnitCastStop")
    self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED", "OnUnitCastInterrupted")
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", "OnUnitCastSucceeded")
    self:RegisterEvent("UNIT_SPELLCAST_DELAYED", "OnUnitCastDelayed")
    self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE", "OnUnitCastInterruptible")
    self:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", "OnUnitCastNotInterruptible")
    self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", "OnUnitThreatSituationChanged")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "OnCombatLogEvent")
    
    -- Hook functions
    if CompactUnitFrame_UpdateName then
        self:SecureHook("CompactUnitFrame_UpdateName")
        self:SecureHook("CompactUnitFrame_UpdateHealthColor")
        self:SecureHook("CompactUnitFrame_UpdateSelectionHighlight")
        self:SecureHook("CompactUnitFrame_UpdateAggroHighlight")
    end
    
    -- Configure nameplates
    self:ConfigureNamePlateSettings()
    
    -- Process existing nameplates
    self:ProcessExistingNameplates()
    
    -- Start update timer
    self.updateTimer = self:ScheduleRepeatingTimer("UpdateAllNameplates", 0.1)
    
    self:Debug("VUIPlater module enabled")
end

function M:OnDisable()
    -- Unregister events
    self:UnregisterAllEvents()
    
    -- Cancel timers
    if self.updateTimer then
        self:CancelTimer(self.updateTimer)
        self.updateTimer = nil
    end
    
    -- Unhook functions
    self:UnhookAll()
    
    -- Reset nameplates to default appearance
    self:ResetAllNameplates()
    
    -- Clear caches
    wipe(self.nameplates)
    
    self:Debug("VUIPlater module disabled")
end

-- Debug and logging functions
function M:Debug(...)
    VUI:Debug(MODNAME, ...)
end

function M:Print(...)
    VUI:Print("|cFF4499CCVUI Plater:|r", ...)
end

-- Create border textures if they don't exist
function M:CreateBorderTextures()
    -- These would usually be actual files in the media directory,
    -- but for now, we'll create them programmatically
    -- In a real addon, these would be actual image files
end

-- Register fonts with LibSharedMedia
function M:RegisterFontMedia()
    -- Register fonts if they don't exist
    if not LSM:IsValid("font", "Arial Narrow") then
        LSM:Register("font", "Arial Narrow", "Fonts\\ARIALN.TTF")
    end
    
    if not LSM:IsValid("font", "Expressway") then
        if LSM:IsValid("font", "Expressway") then
            -- If another addon registered it, use that
        else
            -- Fallback to a standard font
            LSM:Register("font", "Expressway", "Fonts\\FRIZQT__.TTF")
        end
    end
    
    -- Register our statusbar textures
    if not LSM:IsValid("statusbar", "VUI Gradient") then
        LSM:Register("statusbar", "VUI Gradient", "Interface\\AddOns\\VUI\\Media\\Textures\\Status\\gradient.tga")
    end
    
    if not LSM:IsValid("statusbar", "VUI Flat") then
        LSM:Register("statusbar", "VUI Flat", "Interface\\AddOns\\VUI\\Media\\Textures\\Status\\flat.tga")
    end
    
    if not LSM:IsValid("statusbar", "VUI Smooth") then
        LSM:Register("statusbar", "VUI Smooth", "Interface\\AddOns\\VUI\\Media\\Textures\\Status\\smooth.tga")
    end
end

-- Register statusbar textures with LibSharedMedia
function M:RegisterStatusBarTextures()
    -- Already done in RegisterFontMedia
end

-- Configure nameplate settings through the Blizzard API
function M:ConfigureNamePlateSettings()
    -- Load current profile settings
    local p = self.db.profile
    local perf = p.performance
    
    -- Set nameplate clamping
    SetCVar("nameplateOtherTopInset", perf.clampToScreen and -1 or 0.08)
    SetCVar("nameplateOtherBottomInset", perf.clampToScreen and -1 or 0.1)
    
    -- Set stacking nameplates
    SetCVar("nameplateMotion", perf.stackingNameplates and 1 or 0)
    
    -- Set nameplate range
    SetCVar("nameplateMaxDistance", perf.nameplateRange)
    
    -- Set max displayed nameplates
    SetCVar("nameplateMaximumNameplateDistance", perf.maxDisplayed)
    
    -- Set enemy nameplates visibility
    SetCVar("nameplateShowEnemies", p.misc.showEnemyNameplates and 1 or 0)
    
    -- Set friendly nameplates visibility
    SetCVar("nameplateShowFriends", p.misc.showFriendlyNameplates and 1 or 0)
    
    -- Set player nameplate visibility
    SetCVar("nameplateShowSelf", p.misc.showPlayerNameplate and 1 or 0)
    
    -- Set NPC titles visibility
    SetCVar("UnitNameNPC", p.misc.showNPCTitles and 1 or 0)
    
    -- Set nameplate overlap
    SetCVar("nameplateOverlapV", perf.overlapProtection and 1.1 or 0.7)
end

-- Process existing nameplates when the module is enabled
function M:ProcessExistingNameplates()
    -- Process any existing nameplates
    for _, plate in pairs(C_NamePlate.GetNamePlates()) do
        self:OnNamePlateCreated(nil, plate)
        local unitID = plate.namePlateUnitToken
        if unitID then
            self:OnNamePlateAdded(nil, unitID)
        end
    end
end

-- Reset all nameplates to default appearance
function M:ResetAllNameplates()
    for plate, _ in pairs(self.createdNameplates) do
        self:ResetNameplateToDefault(plate)
    end
end

-- Reset a specific nameplate to default appearance
function M:ResetNameplateToDefault(plate)
    -- Check if we have created VUI elements for this plate
    if not plate or not plate.VUI then return end
    
    -- Hide our custom elements
    plate.VUI.healthBar:Hide()
    plate.VUI.castBar:Hide()
    plate.VUI.border:Hide()
    plate.VUI.highlight:Hide()
    plate.VUI.eliteBorder:Hide()
    plate.VUI.threatIndicator:Hide()
    plate.VUI.executeIndicator:Hide()
    
    -- Hide text elements
    plate.VUI.name:Hide()
    plate.VUI.level:Hide()
    plate.VUI.health:Hide()
    
    -- Hide aura containers
    plate.VUI.buffContainer:Hide()
    plate.VUI.debuffContainer:Hide()
    
    -- Hide class icon
    plate.VUI.classIcon:Hide()
    
    -- Show original Blizzard elements
    local blizzFrame = plate.UnitFrame
    if blizzFrame then
        blizzFrame.healthBar:Show()
        blizzFrame.castBar:Show()
        blizzFrame.name:Show()
        blizzFrame.selectionHighlight:Show()
        blizzFrame.aggroHighlight:Show()
        blizzFrame.ClassificationFrame:Show()
        
        -- Restore original size
        blizzFrame:SetSize(blizzFrame.defaultWidth or 110, blizzFrame.defaultHeight or 45)
    end
end

-- Called when a nameplate is created
function M:OnNamePlateCreated(event, plate)
    if not plate then return end
    
    -- Skip if already processed
    if self.createdNameplates[plate] then return end
    
    -- Mark as processed
    self.createdNameplates[plate] = true
    
    -- Create VUI elements for the nameplate
    self:CreateNameplateElements(plate)
end

-- Called when a unit is added to a nameplate
function M:OnNamePlateAdded(event, unitID)
    if not unitID then return end
    
    local plate = C_NamePlate.GetNamePlateForUnit(unitID)
    if not plate then return end
    
    -- Skip if not fully created yet
    if not plate.VUI then
        self:OnNamePlateCreated(nil, plate)
    end
    
    -- Store reference to plate by unit ID
    self.nameplates[unitID] = plate
    plate.unitID = unitID
    
    -- Initial update
    self:UpdateNameplate(plate, unitID)
end

-- Called when a unit is removed from a nameplate
function M:OnNamePlateRemoved(event, unitID)
    if not unitID then return end
    
    -- Remove from cache
    self.nameplates[unitID] = nil
end

-- Called when the player's target changes
function M:OnTargetChanged()
    -- Update all nameplates for target-specific styling
    self:UpdateAllNameplates()
end

-- Called when a unit's health changes
function M:OnUnitHealthChanged(event, unitID)
    if not unitID or not self.nameplates[unitID] then return end
    
    self:UpdateHealth(self.nameplates[unitID], unitID)
end

-- Called when a unit's power changes
function M:OnUnitPowerChanged(event, unitID)
    -- Not needed for current implementation but could be used for power bars
end

-- Called when a unit's faction changes
function M:OnUnitFactionChanged(event, unitID)
    if not unitID or not self.nameplates[unitID] then return end
    
    self:UpdateNameplate(self.nameplates[unitID], unitID)
end

-- Called when a unit's name is updated
function M:OnUnitNameUpdated(event, unitID)
    if not unitID or not self.nameplates[unitID] then return end
    
    self:UpdateName(self.nameplates[unitID], unitID)
end

-- Called when a unit's level is updated
function M:OnUnitLevelUpdated(event, unitID)
    if not unitID or not self.nameplates[unitID] then return end
    
    self:UpdateLevel(self.nameplates[unitID], unitID)
end

-- Called when a unit's classification changes (e.g. elite/rare status)
function M:OnUnitClassificationChanged(event, unitID)
    if not unitID or not self.nameplates[unitID] then return end
    
    self:UpdateBorder(self.nameplates[unitID], unitID)
    self:UpdateLevel(self.nameplates[unitID], unitID)
end

-- Called when a unit's auras change
function M:OnUnitAurasChanged(event, unitID)
    if not unitID or not self.nameplates[unitID] then return end
    
    self:UpdateAuras(self.nameplates[unitID], unitID)
end

-- Called when a unit starts casting
function M:OnUnitCastStart(event, unitID, castGUID, spellID)
    if not unitID or not self.nameplates[unitID] then return end
    
    self:UpdateCastBar(self.nameplates[unitID], unitID, "start")
end

-- Called when a unit's cast stops
function M:OnUnitCastStop(event, unitID, castGUID, spellID)
    if not unitID or not self.nameplates[unitID] then return end
    
    self:UpdateCastBar(self.nameplates[unitID], unitID, "stop")
end

-- Called when a unit's cast is interrupted
function M:OnUnitCastInterrupted(event, unitID, castGUID, spellID)
    if not unitID or not self.nameplates[unitID] then return end
    
    self:UpdateCastBar(self.nameplates[unitID], unitID, "interrupted")
end

-- Called when a unit's cast succeeds
function M:OnUnitCastSucceeded(event, unitID, castGUID, spellID)
    if not unitID or not self.nameplates[unitID] then return end
    
    self:UpdateCastBar(self.nameplates[unitID], unitID, "succeeded")
end

-- Called when a unit's cast is delayed
function M:OnUnitCastDelayed(event, unitID, castGUID, spellID)
    if not unitID or not self.nameplates[unitID] then return end
    
    self:UpdateCastBar(self.nameplates[unitID], unitID, "delayed")
end

-- Called when a unit's cast becomes interruptible
function M:OnUnitCastInterruptible(event, unitID)
    if not unitID or not self.nameplates[unitID] then return end
    
    self:UpdateCastBar(self.nameplates[unitID], unitID, "interruptible")
end

-- Called when a unit's cast becomes non-interruptible
function M:OnUnitCastNotInterruptible(event, unitID)
    if not unitID or not self.nameplates[unitID] then return end
    
    self:UpdateCastBar(self.nameplates[unitID], unitID, "notinterruptible")
end

-- Called when a unit's threat situation changes
function M:OnUnitThreatSituationChanged(event, unitID)
    if not unitID or not self.nameplates[unitID] then return end
    
    self:UpdateThreat(self.nameplates[unitID], unitID)
end

-- Combat log event processing
function M:OnCombatLogEvent(event)
    local timestamp, subEvent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()
    
    -- Process combat events for specific functionality
    if subEvent == "SPELL_INTERRUPT" then
        -- Find the nameplate for the interrupted unit
        for unitID, plate in pairs(self.nameplates) do
            if UnitGUID(unitID) == destGUID then
                self:UpdateCastBar(plate, unitID, "interrupted")
                break
            end
        end
    elseif subEvent == "UNIT_DIED" then
        -- Process unit death for animation or cleanup
        for unitID, plate in pairs(self.nameplates) do
            if UnitGUID(unitID) == destGUID then
                -- Could add death animation here
                break
            end
        end
    end
end

-- Create custom elements for a nameplate
function M:CreateNameplateElements(plate)
    if not plate or plate.VUI then return end
    
    -- Create VUI container
    plate.VUI = {}
    
    -- Get the base frame
    local blizzFrame = plate.UnitFrame
    if not blizzFrame then return end
    
    -- Store original dimensions
    blizzFrame.defaultWidth = blizzFrame:GetWidth()
    blizzFrame.defaultHeight = blizzFrame:GetHeight()
    
    -- Create health bar
    plate.VUI.healthBar = CreateFrame("StatusBar", nil, blizzFrame)
    plate.VUI.healthBar:SetPoint("CENTER", blizzFrame, "CENTER")
    plate.VUI.healthBar:SetFrameLevel(blizzFrame:GetFrameLevel())
    
    -- Health bar background
    plate.VUI.healthBg = plate.VUI.healthBar:CreateTexture(nil, "BACKGROUND")
    plate.VUI.healthBg:SetAllPoints()
    plate.VUI.healthBg:SetTexture("Interface\\Buttons\\WHITE8x8")
    
    -- Create border
    plate.VUI.border = CreateFrame("Frame", nil, plate.VUI.healthBar, "BackdropTemplate")
    plate.VUI.border:SetPoint("TOPLEFT", plate.VUI.healthBar, "TOPLEFT", -1, 1)
    plate.VUI.border:SetPoint("BOTTOMRIGHT", plate.VUI.healthBar, "BOTTOMRIGHT", 1, -1)
    plate.VUI.border:SetFrameLevel(plate.VUI.healthBar:GetFrameLevel() - 1)
    
    -- Create highlight for target
    plate.VUI.highlight = plate.VUI.healthBar:CreateTexture(nil, "OVERLAY")
    plate.VUI.highlight:SetAllPoints()
    plate.VUI.highlight:SetTexture("Interface\\Buttons\\WHITE8x8")
    plate.VUI.highlight:SetBlendMode("ADD")
    plate.VUI.highlight:SetVertexColor(1, 1, 1, 0.3)
    plate.VUI.highlight:Hide()
    
    -- Create elite border
    plate.VUI.eliteBorder = CreateFrame("Frame", nil, plate.VUI.healthBar, "BackdropTemplate")
    plate.VUI.eliteBorder:SetPoint("TOPLEFT", plate.VUI.healthBar, "TOPLEFT", -1, 1)
    plate.VUI.eliteBorder:SetPoint("BOTTOMRIGHT", plate.VUI.healthBar, "BOTTOMRIGHT", 1, -1)
    plate.VUI.eliteBorder:SetFrameLevel(plate.VUI.border:GetFrameLevel() + 1)
    plate.VUI.eliteBorder:Hide()
    
    -- Create cast bar
    plate.VUI.castBar = CreateFrame("StatusBar", nil, blizzFrame)
    plate.VUI.castBar:SetPoint("TOP", plate.VUI.healthBar, "BOTTOM", 0, -1)
    plate.VUI.castBar:SetFrameLevel(blizzFrame:GetFrameLevel())
    plate.VUI.castBar:Hide()
    
    -- Cast bar background
    plate.VUI.castBg = plate.VUI.castBar:CreateTexture(nil, "BACKGROUND")
    plate.VUI.castBg:SetAllPoints()
    plate.VUI.castBg:SetTexture("Interface\\Buttons\\WHITE8x8")
    
    -- Cast bar border
    plate.VUI.castBorder = CreateFrame("Frame", nil, plate.VUI.castBar, "BackdropTemplate")
    plate.VUI.castBorder:SetPoint("TOPLEFT", plate.VUI.castBar, "TOPLEFT", -1, 1)
    plate.VUI.castBorder:SetPoint("BOTTOMRIGHT", plate.VUI.castBar, "BOTTOMRIGHT", 1, -1)
    plate.VUI.castBorder:SetFrameLevel(plate.VUI.castBar:GetFrameLevel() - 1)
    
    -- Cast bar spell icon
    plate.VUI.castIcon = plate.VUI.castBar:CreateTexture(nil, "OVERLAY")
    plate.VUI.castIcon:SetSize(16, 16)
    plate.VUI.castIcon:SetPoint("RIGHT", plate.VUI.castBar, "LEFT", -2, 0)
    
    -- Cast bar shield (for non-interruptible casts)
    plate.VUI.castShield = plate.VUI.castBar:CreateTexture(nil, "OVERLAY")
    plate.VUI.castShield:SetSize(16, 16)
    plate.VUI.castShield:SetPoint("CENTER", plate.VUI.castIcon, "CENTER")
    plate.VUI.castShield:SetTexture("Interface\\AddOns\\VUI\\Media\\modules\\VUIPlater\\textures\\shield.tga")
    plate.VUI.castShield:Hide()
    
    -- Cast bar text
    plate.VUI.castText = plate.VUI.castBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    plate.VUI.castText:SetPoint("LEFT", plate.VUI.castBar, "LEFT", 3, 0)
    plate.VUI.castText:SetPoint("RIGHT", plate.VUI.castBar, "RIGHT", -3, 0)
    plate.VUI.castText:SetJustifyH("LEFT")
    
    -- Cast bar timer
    plate.VUI.castTimer = plate.VUI.castBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    plate.VUI.castTimer:SetPoint("RIGHT", plate.VUI.castBar, "RIGHT", -3, 0)
    plate.VUI.castTimer:SetJustifyH("RIGHT")
    
    -- Cast target
    plate.VUI.castTarget = plate.VUI.castBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    plate.VUI.castTarget:SetPoint("TOPLEFT", plate.VUI.castBar, "BOTTOMLEFT", 0, -2)
    plate.VUI.castTarget:SetPoint("TOPRIGHT", plate.VUI.castBar, "BOTTOMRIGHT", 0, -2)
    plate.VUI.castTarget:SetJustifyH("LEFT")
    plate.VUI.castTarget:SetTextColor(1, 1, 1, 0.7)
    
    -- Create name text
    plate.VUI.name = blizzFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    plate.VUI.name:SetPoint("BOTTOM", plate.VUI.healthBar, "TOP", 0, 3)
    plate.VUI.name:SetJustifyH("CENTER")
    
    -- Create level text
    plate.VUI.level = blizzFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    plate.VUI.level:SetPoint("RIGHT", plate.VUI.healthBar, "LEFT", -2, 0)
    plate.VUI.level:SetJustifyH("RIGHT")
    
    -- Create health text
    plate.VUI.health = plate.VUI.healthBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    plate.VUI.health:SetPoint("CENTER", plate.VUI.healthBar, "CENTER")
    plate.VUI.health:SetJustifyH("CENTER")
    
    -- Create threat indicator
    plate.VUI.threatIndicator = blizzFrame:CreateTexture(nil, "OVERLAY")
    plate.VUI.threatIndicator:SetSize(16, 16)
    plate.VUI.threatIndicator:SetPoint("RIGHT", plate.VUI.healthBar, "LEFT", -2, 0)
    plate.VUI.threatIndicator:SetTexture("Interface\\AddOns\\VUI\\Media\\modules\\VUIPlater\\textures\\threat.tga")
    plate.VUI.threatIndicator:Hide()
    
    -- Create execution indicator
    plate.VUI.executeIndicator = plate.VUI.healthBar:CreateTexture(nil, "OVERLAY")
    plate.VUI.executeIndicator:SetAllPoints()
    plate.VUI.executeIndicator:SetTexture("Interface\\Buttons\\WHITE8x8")
    plate.VUI.executeIndicator:SetBlendMode("ADD")
    plate.VUI.executeIndicator:SetVertexColor(1, 0, 0, 0.3)
    plate.VUI.executeIndicator:Hide()
    
    -- Create class icon
    plate.VUI.classIcon = blizzFrame:CreateTexture(nil, "ARTWORK")
    plate.VUI.classIcon:SetSize(16, 16)
    plate.VUI.classIcon:SetPoint("LEFT", plate.VUI.healthBar, "RIGHT", 2, 0)
    plate.VUI.classIcon:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
    plate.VUI.classIcon:Hide()
    
    -- Create buff container
    plate.VUI.buffContainer = CreateFrame("Frame", nil, blizzFrame)
    plate.VUI.buffContainer:SetPoint("BOTTOM", plate.VUI.healthBar, "TOP", 0, 5)
    plate.VUI.buffContainer:SetSize(plate.VUI.healthBar:GetWidth(), 20)
    plate.VUI.buffContainer:Hide()
    
    -- Create debuff container
    plate.VUI.debuffContainer = CreateFrame("Frame", nil, blizzFrame)
    plate.VUI.debuffContainer:SetPoint("TOP", plate.VUI.castBar, "BOTTOM", 0, -5)
    plate.VUI.debuffContainer:SetSize(plate.VUI.healthBar:GetWidth(), 20)
    plate.VUI.debuffContainer:Hide()
    
    -- Store buff and debuff frames
    plate.VUI.buffFrames = {}
    plate.VUI.debuffFrames = {}
    
    -- Hide the Blizzard elements
    blizzFrame.healthBar:Hide()
    blizzFrame.castBar:Hide()
    blizzFrame.name:Hide()
    blizzFrame.selectionHighlight:Hide()
    blizzFrame.aggroHighlight:Hide()
    blizzFrame.ClassificationFrame:Hide()
    
    return plate.VUI
end

-- Update a nameplate with all elements
function M:UpdateNameplate(plate, unitID)
    if not plate or not plate.VUI or not unitID or not UnitExists(unitID) then return end
    
    -- Determine if enemy or friendly
    local reaction = UnitReaction("player", unitID) or 0
    local isPlayer = UnitIsPlayer(unitID)
    local isSelf = UnitIsUnit(unitID, "player")
    
    -- Get the appropriate settings
    local settings
    if isSelf then
        settings = self.db.profile.player
    elseif reaction <= 4 then -- enemy
        settings = self.db.profile.enemy
    else -- friendly
        settings = self.db.profile.friendly
    end
    
    -- Skip if disabled for this type
    if not settings.enabled then
        self:ResetNameplateToDefault(plate)
        return
    end
    
    -- Get the Blizzard frame
    local blizzFrame = plate.UnitFrame
    if not blizzFrame then return end
    
    -- Get target status
    local isTarget = UnitIsUnit(unitID, "target")
    
    -- Set health bar size and position
    plate.VUI.healthBar:SetSize(settings.width, settings.height)
    
    -- Set bar textures
    local healthTexture = LSM:Fetch("statusbar", settings.healthBarTexture) or "Interface\\Buttons\\WHITE8x8"
    local castTexture = LSM:Fetch("statusbar", settings.castBarTexture) or "Interface\\Buttons\\WHITE8x8"
    
    plate.VUI.healthBar:SetStatusBarTexture(healthTexture)
    plate.VUI.castBar:SetStatusBarTexture(castTexture)
    
    -- Set cast bar size
    plate.VUI.castBar:SetSize(settings.width, settings.castBarHeight)
    
    -- Set custom scale
    if isTarget and settings.scaleTarget then
        blizzFrame:SetScale(settings.targetScale)
    else
        blizzFrame:SetScale(settings.scale)
    end
    
    -- Set borders
    self:UpdateBorder(plate, unitID)
    
    -- Set alpha
    if isTarget then
        plate:SetAlpha(1)
    elseif settings.fadeNonTargets then
        plate:SetAlpha(settings.fadeAmount)
    else
        plate:SetAlpha(1)
    end
    
    -- Update target highlight
    plate.VUI.highlight:SetShown(isTarget and settings.showTargetBorder)
    
    -- Update fonts
    local font = LSM:Fetch("font", settings.fontName) or "Fonts\\FRIZQT__.TTF"
    plate.VUI.name:SetFont(font, settings.fontSize, settings.fontOutline)
    plate.VUI.level:SetFont(font, settings.fontSize, settings.fontOutline)
    plate.VUI.health:SetFont(font, settings.fontSize, settings.fontOutline)
    plate.VUI.castText:SetFont(font, settings.fontSize, settings.fontOutline)
    plate.VUI.castTimer:SetFont(font, settings.fontSize, settings.fontOutline)
    plate.VUI.castTarget:SetFont(font, settings.fontSize - 1, settings.fontOutline)
    
    -- Update health
    self:UpdateHealth(plate, unitID)
    
    -- Update name
    self:UpdateName(plate, unitID)
    
    -- Update level
    self:UpdateLevel(plate, unitID)
    
    -- Update class icon
    self:UpdateClassIcon(plate, unitID)
    
    -- Update cast bar
    self:UpdateCastBar(plate, unitID, "update")
    
    -- Update auras
    self:UpdateAuras(plate, unitID)
    
    -- Update threat
    self:UpdateThreat(plate, unitID)
    
    -- Show the plate elements
    plate.VUI.healthBar:Show()
end

-- Update health bar for a nameplate
function M:UpdateHealth(plate, unitID)
    if not plate or not plate.VUI or not unitID or not UnitExists(unitID) then return end
    
    -- Get health values
    local health = UnitHealth(unitID)
    local maxHealth = UnitHealthMax(unitID)
    local healthPercent = maxHealth > 0 and health / maxHealth * 100 or 0
    
    -- Determine if enemy or friendly
    local reaction = UnitReaction("player", unitID) or 0
    local isPlayer = UnitIsPlayer(unitID)
    local isSelf = UnitIsUnit(unitID, "player")
    
    -- Get the appropriate settings
    local settings
    if isSelf then
        settings = self.db.profile.player
    elseif reaction <= 4 then -- enemy
        settings = self.db.profile.enemy
    else -- friendly
        settings = self.db.profile.friendly
    end
    
    -- Set health bar value
    plate.VUI.healthBar:SetMinMaxValues(0, maxHealth)
    plate.VUI.healthBar:SetValue(health)
    
    -- Set colors
    if settings.useClassColors and isPlayer then
        local _, class = UnitClass(unitID)
        if class and RAID_CLASS_COLORS[class] then
            local color = RAID_CLASS_COLORS[class]
            plate.VUI.healthBar:SetStatusBarColor(color.r, color.g, color.b)
        else
            -- Use default color
            local color = settings.healthBarColor
            plate.VUI.healthBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
        end
    elseif reaction <= 4 then -- enemy
        local color = settings.healthBarColor
        plate.VUI.healthBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
    else -- friendly
        local color = settings.healthBarColor
        plate.VUI.healthBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
    end
    
    -- Set background color
    local bgColor = settings.healthBgColor
    plate.VUI.healthBg:SetVertexColor(bgColor.r, bgColor.g, bgColor.b, bgColor.a)
    
    -- Show execution indicator if health is below threshold for enemies
    if reaction <= 4 and settings.executionIndicator then
        plate.VUI.executeIndicator:SetShown(healthPercent <= settings.executionThreshold)
    else
        plate.VUI.executeIndicator:Hide()
    end
    
    -- Update health text
    if settings.showHealthPercent or settings.showHealthValue then
        local text = ""
        
        if settings.showHealthPercent then
            text = format("%.0f%%", healthPercent)
        end
        
        if settings.showHealthValue then
            if text ~= "" then text = text .. " " end
            if maxHealth > 999999 then
                text = text .. format("%.1fM", health / 1000000)
            elseif maxHealth > 9999 then
                text = text .. format("%.0fk", health / 1000)
            else
                text = text .. format("%d", health)
            end
        end
        
        plate.VUI.health:SetText(text)
        plate.VUI.health:Show()
    else
        plate.VUI.health:Hide()
    end
end

-- Update name text for a nameplate
function M:UpdateName(plate, unitID)
    if not plate or not plate.VUI or not unitID or not UnitExists(unitID) then return end
    
    -- Determine if enemy or friendly
    local reaction = UnitReaction("player", unitID) or 0
    local isPlayer = UnitIsPlayer(unitID)
    local isSelf = UnitIsUnit(unitID, "player")
    
    -- Get the appropriate settings
    local settings
    if isSelf then
        settings = self.db.profile.player
    elseif reaction <= 4 then -- enemy
        settings = self.db.profile.enemy
    else -- friendly
        settings = self.db.profile.friendly
    end
    
    -- Update name
    if settings.showName then
        local name = UnitName(unitID) or ""
        
        -- Limit name length
        if settings.nameLength > 0 and #name > settings.nameLength then
            name = name:sub(1, settings.nameLength) .. "..."
        end
        
        plate.VUI.name:SetText(name)
        plate.VUI.name:Show()
    else
        plate.VUI.name:Hide()
    end
end

-- Update level text for a nameplate
function M:UpdateLevel(plate, unitID)
    if not plate or not plate.VUI or not unitID or not UnitExists(unitID) then return end
    
    -- Determine if enemy or friendly
    local reaction = UnitReaction("player", unitID) or 0
    local isPlayer = UnitIsPlayer(unitID)
    local isSelf = UnitIsUnit(unitID, "player")
    
    -- Get the appropriate settings
    local settings
    if isSelf then
        settings = self.db.profile.player
    elseif reaction <= 4 then -- enemy
        settings = self.db.profile.enemy
    else -- friendly
        settings = self.db.profile.friendly
    end
    
    -- Update level
    if settings.showLevel then
        local level = UnitLevel(unitID) or 0
        local classification = UnitClassification(unitID)
        
        local levelStr
        if level <= 0 then
            levelStr = "??"
        else
            levelStr = tostring(level)
        end
        
        -- Add classification
        if classification == "elite" then
            levelStr = levelStr .. "+"
        elseif classification == "rare" then
            levelStr = levelStr .. "r"
        elseif classification == "rareelite" then
            levelStr = levelStr .. "r+"
        elseif classification == "worldboss" then
            levelStr = levelStr .. "b"
        end
        
        -- Color by difficulty
        local color = GetQuestDifficultyColor(level <= 0 and 999 or level)
        plate.VUI.level:SetTextColor(color.r, color.g, color.b)
        
        plate.VUI.level:SetText(levelStr)
        plate.VUI.level:Show()
    else
        plate.VUI.level:Hide()
    end
end

-- Update border appearance for a nameplate
function M:UpdateBorder(plate, unitID)
    if not plate or not plate.VUI or not unitID or not UnitExists(unitID) then return end
    
    -- Determine if enemy or friendly
    local reaction = UnitReaction("player", unitID) or 0
    local isPlayer = UnitIsPlayer(unitID)
    local isSelf = UnitIsUnit(unitID, "player")
    
    -- Get the appropriate settings
    local settings
    if isSelf then
        settings = self.db.profile.player
    elseif reaction <= 4 then -- enemy
        settings = self.db.profile.enemy
    else -- friendly
        settings = self.db.profile.friendly
    end
    
    -- Get classification for elite border
    local classification = UnitClassification(unitID)
    local isElite = (classification == "elite" or classification == "rareelite" or classification == "worldboss")
    
    -- Setup border backdrop
    plate.VUI.border:SetBackdrop({
        edgeFile = self.borderTextures[settings.borderStyle] or "Interface\\Buttons\\WHITE8x8",
        edgeSize = settings.borderSize,
    })
    
    -- Set border color
    local color = settings.borderColor
    plate.VUI.border:SetBackdropBorderColor(color.r, color.g, color.b, color.a)
    
    -- Setup elite border if needed
    if isElite and settings.showEliteBorder and reaction <= 4 then -- enemy only
        plate.VUI.eliteBorder:SetBackdrop({
            edgeFile = self.borderTextures[settings.borderStyle] or "Interface\\Buttons\\WHITE8x8",
            edgeSize = settings.borderSize * 2,
        })
        
        -- Set elite border color
        local eliteColor = settings.eliteBorderColor
        plate.VUI.eliteBorder:SetBackdropBorderColor(eliteColor.r, eliteColor.g, eliteColor.b, eliteColor.a)
        plate.VUI.eliteBorder:Show()
    else
        plate.VUI.eliteBorder:Hide()
    end
end

-- Update class icon for a nameplate
function M:UpdateClassIcon(plate, unitID)
    if not plate or not plate.VUI or not unitID or not UnitExists(unitID) then return end
    
    -- Determine if enemy or friendly
    local reaction = UnitReaction("player", unitID) or 0
    local isPlayer = UnitIsPlayer(unitID)
    local isSelf = UnitIsUnit(unitID, "player")
    
    -- Get the appropriate settings
    local settings
    if isSelf then
        settings = self.db.profile.player
    elseif reaction <= 4 then -- enemy
        settings = self.db.profile.enemy
    else -- friendly
        settings = self.db.profile.friendly
    end
    
    -- Show class icon for players if enabled
    if isPlayer then
        if (reaction <= 4 and settings.showEnemyClassIcon) or 
           (reaction > 4 and settings.showFriendlyClassIcon) or
           (isSelf and settings.showClassIcon) then
            local _, class = UnitClass(unitID)
            if class and CLASS_ICON_TCOORDS[class] then
                plate.VUI.classIcon:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
                plate.VUI.classIcon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]))
                plate.VUI.classIcon:Show()
            else
                plate.VUI.classIcon:Hide()
            end
        else
            plate.VUI.classIcon:Hide()
        end
    else
        plate.VUI.classIcon:Hide()
    end
end

-- Update cast bar for a nameplate
function M:UpdateCastBar(plate, unitID, state)
    if not plate or not plate.VUI or not unitID or not UnitExists(unitID) then return end
    
    -- Determine if enemy or friendly
    local reaction = UnitReaction("player", unitID) or 0
    local isPlayer = UnitIsPlayer(unitID)
    local isSelf = UnitIsUnit(unitID, "player")
    
    -- Get the appropriate settings
    local settings
    if isSelf then
        settings = self.db.profile.player
    elseif reaction <= 4 then -- enemy
        settings = self.db.profile.enemy
    else -- friendly
        settings = self.db.profile.friendly
    end
    
    -- Check if unit is casting
    local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unitID)
    if not name then
        name, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo(unitID)
    end
    
    -- Show cast bar if casting
    if name and texture then
        plate.VUI.castBar:Show()
        
        -- Set cast bar texture
        plate.VUI.castIcon:SetTexture(texture)
        plate.VUI.castIcon:Show()
        
        -- Set cast bar colors
        if state == "interrupted" then
            local color = settings.interruptedCastColor
            plate.VUI.castBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
        elseif notInterruptible then
            local color = settings.nonInterruptibleCastColor
            plate.VUI.castBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
        else
            local color = settings.castBarColor
            plate.VUI.castBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
        end
        
        -- Set cast bar background color
        local bgColor = settings.castBarBgColor
        plate.VUI.castBg:SetVertexColor(bgColor.r, bgColor.g, bgColor.b, bgColor.a)
        
        -- Set cast border color
        local borderColor = settings.borderColor
        plate.VUI.castBorder:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
        
        -- Setup interruptible shield
        plate.VUI.castShield:SetShown(notInterruptible and settings.showInterruptShield)
        
        -- Set cast bar text
        plate.VUI.castText:SetText(text or name)
        
        -- Set cast times
        if startTime and endTime then
            local currentTime = GetTime() * 1000
            local castTimeTotal = (endTime - startTime) / 1000
            local castTimeRemaining = (endTime - currentTime) / 1000
            
            -- Update timer text
            plate.VUI.castTimer:SetText(format("%.1f", castTimeRemaining > 0 and castTimeRemaining or 0))
            
            -- Set cast bar progress
            plate.VUI.castBar:SetMinMaxValues(0, castTimeTotal)
            plate.VUI.castBar:SetValue(math.min(castTimeRemaining > 0 and (castTimeTotal - castTimeRemaining) or castTimeTotal, castTimeTotal))
        end
        
        -- Set cast target if available and enabled
        if settings.showCastTarget then
            local target = UnitExists(unitID .. "target") and UnitName(unitID .. "target")
            if target then
                plate.VUI.castTarget:SetText(L["Target: "] .. target)
                plate.VUI.castTarget:Show()
            else
                plate.VUI.castTarget:Hide()
            end
        else
            plate.VUI.castTarget:Hide()
        end
    else
        plate.VUI.castBar:Hide()
        plate.VUI.castTarget:Hide()
    end
end

-- Update the auras shown on a nameplate
function M:UpdateAuras(plate, unitID)
    if not plate or not plate.VUI or not unitID or not UnitExists(unitID) then return end
    
    -- Determine if enemy or friendly
    local reaction = UnitReaction("player", unitID) or 0
    local isPlayer = UnitIsPlayer(unitID)
    local isSelf = UnitIsUnit(unitID, "player")
    
    -- Get the appropriate settings
    local settings
    if isSelf then
        settings = self.db.profile.player
    elseif reaction <= 4 then -- enemy
        settings = self.db.profile.enemy
    else -- friendly
        settings = self.db.profile.friendly
    end
    
    -- Process buffs if enabled
    if settings.showBuffs then
        -- Initialize buff container
        if not plate.VUI.buffFrames or #plate.VUI.buffFrames == 0 then
            self:CreateBuffFrames(plate, settings.buffSize, settings.buffRows, settings.buffColumns)
        end
        
        -- Update container size based on settings
        plate.VUI.buffContainer:SetSize(settings.width, settings.buffSize * settings.buffRows)
        
        -- Process buffs
        local buffCount = 0
        local maxBuffs = settings.buffRows * settings.buffColumns
        local i = 1
        
        while buffCount < maxBuffs do
            local name, icon, count, debuffType, duration, expirationTime, source, isStealable, 
                  nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer = UnitBuff(unitID, i)
            
            if not name then break end
            
            -- Filter buffs based on settings
            local showBuff = true
            
            if settings.filterBuffs then
                if settings.showOnlyImportantBuffs then
                    showBuff = self.importantBuffs[spellId] or false
                end
            end
            
            -- Show or update buff
            if showBuff then
                local frame = plate.VUI.buffFrames[buffCount + 1]
                if frame then
                    frame.icon:SetTexture(icon)
                    frame.count:SetText(count > 1 and count or "")
                    
                    -- Handle duration
                    if settings.showBuffDuration and duration and duration > 0 then
                        local timeLeft = expirationTime - GetTime()
                        if timeLeft < 60 then
                            frame.time:SetText(format("%.0f", timeLeft))
                        else
                            frame.time:SetText(format("%.0fm", timeLeft / 60))
                        end
                        frame.time:Show()
                    else
                        frame.time:Hide()
                    end
                    
                    -- Set border color by type
                    frame.border:SetBackdropBorderColor(1, 1, 1)
                    
                    frame:Show()
                    buffCount = buffCount + 1
                end
            end
            
            i = i + 1
        end
        
        -- Hide unused buff frames
        for i = buffCount + 1, #plate.VUI.buffFrames do
            plate.VUI.buffFrames[i]:Hide()
        end
        
        -- Show container if buffs found
        plate.VUI.buffContainer:SetShown(buffCount > 0)
    else
        plate.VUI.buffContainer:Hide()
    end
    
    -- Process debuffs if enabled
    if settings.showDebuffs then
        -- Initialize debuff container
        if not plate.VUI.debuffFrames or #plate.VUI.debuffFrames == 0 then
            self:CreateDebuffFrames(plate, settings.debuffSize, settings.debuffRows, settings.debuffColumns)
        end
        
        -- Update container size based on settings
        plate.VUI.debuffContainer:SetSize(settings.width, settings.debuffSize * settings.debuffRows)
        
        -- Process debuffs
        local debuffCount = 0
        local maxDebuffs = settings.debuffRows * settings.debuffColumns
        local i = 1
        
        while debuffCount < maxDebuffs do
            local name, icon, count, debuffType, duration, expirationTime, source, isStealable, 
                  nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer = UnitDebuff(unitID, i)
            
            if not name then break end
            
            -- Filter debuffs based on settings
            local showDebuff = true
            
            if settings.filterDebuffs then
                if settings.showOnlyMyDebuffs and source ~= "player" then
                    showDebuff = false
                end
            end
            
            -- Show or update debuff
            if showDebuff then
                local frame = plate.VUI.debuffFrames[debuffCount + 1]
                if frame then
                    frame.icon:SetTexture(icon)
                    frame.count:SetText(count > 1 and count or "")
                    
                    -- Handle duration
                    if settings.showDebuffDuration and duration and duration > 0 then
                        local timeLeft = expirationTime - GetTime()
                        if timeLeft < 60 then
                            frame.time:SetText(format("%.0f", timeLeft))
                        else
                            frame.time:SetText(format("%.0fm", timeLeft / 60))
                        end
                        frame.time:Show()
                    else
                        frame.time:Hide()
                    end
                    
                    -- Set border color by debuff type
                    if debuffType then
                        local color = DebuffTypeColor[debuffType]
                        frame.border:SetBackdropBorderColor(color.r, color.g, color.b)
                    else
                        frame.border:SetBackdropBorderColor(0.8, 0, 0)
                    end
                    
                    frame:Show()
                    debuffCount = debuffCount + 1
                end
            end
            
            i = i + 1
        end
        
        -- Hide unused debuff frames
        for i = debuffCount + 1, #plate.VUI.debuffFrames do
            plate.VUI.debuffFrames[i]:Hide()
        end
        
        -- Show container if debuffs found
        plate.VUI.debuffContainer:SetShown(debuffCount > 0)
    else
        plate.VUI.debuffContainer:Hide()
    end
end

-- Create buff frames for a nameplate
function M:CreateBuffFrames(plate, size, rows, columns)
    if not plate or not plate.VUI then return end
    
    plate.VUI.buffFrames = plate.VUI.buffFrames or {}
    
    local maxBuffs = rows * columns
    local spacing = 2
    
    for i = 1, maxBuffs do
        if not plate.VUI.buffFrames[i] then
            local frame = CreateFrame("Frame", nil, plate.VUI.buffContainer, "BackdropTemplate")
            frame:SetSize(size, size)
            
            -- Position based on row and column
            local row = math.ceil(i / columns) - 1
            local col = (i - 1) % columns
            
            frame:SetPoint("TOPLEFT", plate.VUI.buffContainer, "TOPLEFT", col * (size + spacing), -row * (size + spacing))
            
            -- Create icon
            frame.icon = frame:CreateTexture(nil, "ARTWORK")
            frame.icon:SetAllPoints()
            frame.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9) -- Crop icon edges
            
            -- Create border
            frame.border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
            frame.border:SetPoint("TOPLEFT", frame, "TOPLEFT", -1, 1)
            frame.border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 1, -1)
            frame.border:SetFrameLevel(frame:GetFrameLevel() - 1)
            frame.border:SetBackdrop({
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
            })
            frame.border:SetBackdropBorderColor(1, 1, 1)
            
            -- Create count text
            frame.count = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            frame.count:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 2)
            frame.count:SetTextColor(1, 1, 1)
            
            -- Create time text
            frame.time = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            frame.time:SetPoint("CENTER", frame, "CENTER")
            frame.time:SetTextColor(1, 1, 1)
            
            -- Add to collection
            plate.VUI.buffFrames[i] = frame
        end
    end
end

-- Create debuff frames for a nameplate
function M:CreateDebuffFrames(plate, size, rows, columns)
    if not plate or not plate.VUI then return end
    
    plate.VUI.debuffFrames = plate.VUI.debuffFrames or {}
    
    local maxDebuffs = rows * columns
    local spacing = 2
    
    for i = 1, maxDebuffs do
        if not plate.VUI.debuffFrames[i] then
            local frame = CreateFrame("Frame", nil, plate.VUI.debuffContainer, "BackdropTemplate")
            frame:SetSize(size, size)
            
            -- Position based on row and column
            local row = math.ceil(i / columns) - 1
            local col = (i - 1) % columns
            
            frame:SetPoint("TOPLEFT", plate.VUI.debuffContainer, "TOPLEFT", col * (size + spacing), -row * (size + spacing))
            
            -- Create icon
            frame.icon = frame:CreateTexture(nil, "ARTWORK")
            frame.icon:SetAllPoints()
            frame.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9) -- Crop icon edges
            
            -- Create border
            frame.border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
            frame.border:SetPoint("TOPLEFT", frame, "TOPLEFT", -1, 1)
            frame.border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 1, -1)
            frame.border:SetFrameLevel(frame:GetFrameLevel() - 1)
            frame.border:SetBackdrop({
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
            })
            frame.border:SetBackdropBorderColor(1, 0, 0)
            
            -- Create count text
            frame.count = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            frame.count:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 2)
            frame.count:SetTextColor(1, 1, 1)
            
            -- Create time text
            frame.time = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            frame.time:SetPoint("CENTER", frame, "CENTER")
            frame.time:SetTextColor(1, 1, 1)
            
            -- Add to collection
            plate.VUI.debuffFrames[i] = frame
        end
    end
end

-- Update threat indicator for a nameplate
function M:UpdateThreat(plate, unitID)
    if not plate or not plate.VUI or not unitID or not UnitExists(unitID) then return end
    
    -- Determine if enemy or friendly
    local reaction = UnitReaction("player", unitID) or 0
    
    -- Skip if not an enemy
    if reaction > 4 then
        plate.VUI.threatIndicator:Hide()
        return
    end
    
    -- Get enemy settings
    local settings = self.db.profile.enemy
    
    -- Skip if threat warning disabled
    if not settings.threatWarning then
        plate.VUI.threatIndicator:Hide()
        return
    end
    
    -- Get threat status
    local status = UnitThreatSituation("player", unitID)
    
    -- For tank mode, we want to show warning when we're NOT tanking
    local isTank = (GetSpecializationRole(GetSpecialization()) == "TANK")
    local showWarning = false
    
    if isTank and settings.tankMode then
        -- In tank mode, worry if we're not tanking
        showWarning = status and status < 3
    elseif not isTank or (isTank and not settings.tankMode) then
        -- In DPS mode, worry if we're pulling aggro
        showWarning = status and status > 1
    end
    
    -- Show threat warning
    if showWarning and settings.showWarningGlow then
        plate.VUI.threatIndicator:Show()
        
        -- Set threat color on health bar
        if settings.threatWarning then
            local healthColor = settings.healthBarColor
            local threatColor = settings.highThreatColor
            
            -- Only color if not using class colors
            if not settings.useClassColors or not UnitIsPlayer(unitID) then
                plate.VUI.healthBar:SetStatusBarColor(threatColor.r, threatColor.g, threatColor.b, threatColor.a)
            end
        end
    else
        plate.VUI.threatIndicator:Hide()
        
        -- Reset health bar color (done in UpdateHealth)
        self:UpdateHealth(plate, unitID)
    end
end

-- Update all nameplates at once
function M:UpdateAllNameplates()
    for unitID, plate in pairs(self.nameplates) do
        if UnitExists(unitID) then
            self:UpdateNameplate(plate, unitID)
        end
    end
end

-- Get options for configuration panel
function M:GetOptions()
    local options = {
        name = self.TITLE,
        type = "group",
        childGroups = "tab",
        args = {
            general = {
                name = L["General Settings"],
                type = "group",
                order = 1,
                args = {
                    enabled = {
                        name = L["Enable"],
                        desc = L["Enable/disable this module"],
                        type = "toggle",
                        order = 1,
                        width = "full",
                        get = function() return self.db.profile.enabled end,
                        set = function(info, value) 
                            self.db.profile.enabled = value
                            if value then self:OnEnable() else self:OnDisable() end
                        end,
                    },
                    presets = {
                        name = L["Whiiskeyz Plater Profile"],
                        desc = L["Based on Whiiskeyz Plater profile settings"],
                        type = "toggle",
                        order = 2,
                        width = "full",
                        get = function() return self.db.profile.currentPreset == "WHIISKEYZ" end,
                        set = function(info, value)
                            if value then
                                self.db.profile.currentPreset = "WHIISKEYZ"
                                -- Reset to default settings
                                self.db:ResetProfile()
                                -- Update all nameplates
                                self:OnDisable()
                                self:OnEnable()
                            end
                        end,
                    },
                    misc = {
                        name = L["Nameplate Visibility"],
                        type = "group",
                        order = 3,
                        inline = true,
                        args = {
                            showEnemyNameplates = {
                                name = L["Show Enemy Nameplates"],
                                type = "toggle",
                                order = 1,
                                get = function() return self.db.profile.misc.showEnemyNameplates end,
                                set = function(info, value)
                                    self.db.profile.misc.showEnemyNameplates = value
                                    SetCVar("nameplateShowEnemies", value and 1 or 0)
                                end,
                            },
                            showFriendlyNameplates = {
                                name = L["Show Friendly Nameplates"],
                                type = "toggle",
                                order = 2,
                                get = function() return self.db.profile.misc.showFriendlyNameplates end,
                                set = function(info, value)
                                    self.db.profile.misc.showFriendlyNameplates = value
                                    SetCVar("nameplateShowFriends", value and 1 or 0)
                                end,
                            },
                            showPlayerNameplate = {
                                name = L["Show Player Nameplate"],
                                type = "toggle",
                                order = 3,
                                get = function() return self.db.profile.misc.showPlayerNameplate end,
                                set = function(info, value)
                                    self.db.profile.misc.showPlayerNameplate = value
                                    SetCVar("nameplateShowSelf", value and 1 or 0)
                                end,
                            },
                            showNPCTitles = {
                                name = L["Show NPC Titles"],
                                type = "toggle",
                                order = 4,
                                get = function() return self.db.profile.misc.showNPCTitles end,
                                set = function(info, value)
                                    self.db.profile.misc.showNPCTitles = value
                                    SetCVar("UnitNameNPC", value and 1 or 0)
                                end,
                            },
                        },
                    },
                    performance = {
                        name = L["Performance Settings"],
                        type = "group",
                        order = 4,
                        inline = true,
                        args = {
                            nameplateRange = {
                                name = L["Nameplate Range"],
                                desc = L["Maximum distance to show nameplates"],
                                type = "range",
                                order = 1,
                                min = 20,
                                max = 100,
                                step = 5,
                                get = function() return self.db.profile.performance.nameplateRange end,
                                set = function(info, value)
                                    self.db.profile.performance.nameplateRange = value
                                    SetCVar("nameplateMaxDistance", value)
                                end,
                            },
                            maxDisplayed = {
                                name = L["Max Displayed Nameplates"],
                                desc = L["Maximum number of nameplates shown at once"],
                                type = "range",
                                order = 2,
                                min = 10,
                                max = 60,
                                step = 5,
                                get = function() return self.db.profile.performance.maxDisplayed end,
                                set = function(info, value)
                                    self.db.profile.performance.maxDisplayed = value
                                    SetCVar("nameplateMaximumNameplateDistance", value)
                                end,
                            },
                            clampToScreen = {
                                name = L["Clamp to Screen"],
                                desc = L["Keep nameplates from going off screen"],
                                type = "toggle",
                                order = 3,
                                get = function() return self.db.profile.performance.clampToScreen end,
                                set = function(info, value)
                                    self.db.profile.performance.clampToScreen = value
                                    SetCVar("nameplateOtherTopInset", value and -1 or 0.08)
                                    SetCVar("nameplateOtherBottomInset", value and -1 or 0.1)
                                end,
                            },
                            stackingNameplates = {
                                name = L["Stacking Nameplates"],
                                desc = L["Stack nameplates vertically instead of overlapping"],
                                type = "toggle",
                                order = 4,
                                get = function() return self.db.profile.performance.stackingNameplates end,
                                set = function(info, value)
                                    self.db.profile.performance.stackingNameplates = value
                                    SetCVar("nameplateMotion", value and 1 or 0)
                                end,
                            },
                            overlapProtection = {
                                name = L["Overlap Protection"],
                                desc = L["Increase spacing between stacked nameplates"],
                                type = "toggle",
                                order = 5,
                                get = function() return self.db.profile.performance.overlapProtection end,
                                set = function(info, value)
                                    self.db.profile.performance.overlapProtection = value
                                    SetCVar("nameplateOverlapV", value and 1.1 or 0.7)
                                end,
                            },
                        },
                    },
                },
            },
            enemy = {
                name = L["Enemy Nameplates"],
                type = "group",
                order = 2,
                args = {
                    enabled = {
                        name = L["Enable Enemy Nameplates"],
                        type = "toggle",
                        order = 1,
                        width = "full",
                        get = function() return self.db.profile.enemy.enabled end,
                        set = function(info, value)
                            self.db.profile.enemy.enabled = value
                            self:UpdateAllNameplates()
                        end,
                    },
                    dimensions = {
                        name = L["Size and Position"],
                        type = "group",
                        order = 2,
                        inline = true,
                        args = {
                            width = {
                                name = L["Width"],
                                desc = L["Width of the health bar"],
                                type = "range",
                                order = 1,
                                min = 50,
                                max = 250,
                                step = 5,
                                get = function() return self.db.profile.enemy.width end,
                                set = function(info, value)
                                    self.db.profile.enemy.width = value
                                    self:UpdateAllNameplates()
                                end,
                            },
                            height = {
                                name = L["Height"],
                                desc = L["Height of the health bar"],
                                type = "range",
                                order = 2,
                                min = 4,
                                max = 30,
                                step = 1,
                                get = function() return self.db.profile.enemy.height end,
                                set = function(info, value)
                                    self.db.profile.enemy.height = value
                                    self:UpdateAllNameplates()
                                end,
                            },
                            castBarHeight = {
                                name = L["Cast Bar Height"],
                                desc = L["Height of the cast bar"],
                                type = "range",
                                order = 3,
                                min = 4,
                                max = 30,
                                step = 1,
                                get = function() return self.db.profile.enemy.castBarHeight end,
                                set = function(info, value)
                                    self.db.profile.enemy.castBarHeight = value
                                    self:UpdateAllNameplates()
                                end,
                            },
                            scale = {
                                name = L["Scale"],
                                desc = L["Overall scale of the nameplate"],
                                type = "range",
                                order = 4,
                                min = 0.5,
                                max = 2.0,
                                step = 0.05,
                                get = function() return self.db.profile.enemy.scale end,
                                set = function(info, value)
                                    self.db.profile.enemy.scale = value
                                    self:UpdateAllNameplates()
                                end,
                            },
                        },
                    },
                    colors = {
                        name = L["Colors"],
                        type = "group",
                        order = 3,
                        inline = true,
                        args = {
                            useClassColors = {
                                name = L["Use Class Colors"],
                                desc = L["Color health bars by player class"],
                                type = "toggle",
                                order = 1,
                                get = function() return self.db.profile.enemy.useClassColors end,
                                set = function(info, value)
                                    self.db.profile.enemy.useClassColors = value
                                    self:UpdateAllNameplates()
                                end,
                            },
                            healthBarColor = {
                                name = L["Health Bar Color"],
                                desc = L["Color for health bars"],
                                type = "color",
                                order = 2,
                                hasAlpha = true,
                                get = function()
                                    local c = self.db.profile.enemy.healthBarColor
                                    return c.r, c.g, c.b, c.a
                                end,
                                set = function(info, r, g, b, a)
                                    self.db.profile.enemy.healthBarColor = {r=r, g=g, b=b, a=a}
                                    self:UpdateAllNameplates()
                                end,
                                disabled = function() return self.db.profile.enemy.useClassColors end,
                            },
                            castBarColor = {
                                name = L["Cast Bar Color"],
                                desc = L["Color for cast bars"],
                                type = "color",
                                order = 3,
                                hasAlpha = true,
                                get = function()
                                    local c = self.db.profile.enemy.castBarColor
                                    return c.r, c.g, c.b, c.a
                                end,
                                set = function(info, r, g, b, a)
                                    self.db.profile.enemy.castBarColor = {r=r, g=g, b=b, a=a}
                                    self:UpdateAllNameplates()
                                end,
                            },
                            eliteBorderColor = {
                                name = L["Elite Border Color"],
                                desc = L["Color for the elite unit border"],
                                type = "color",
                                order = 4,
                                hasAlpha = true,
                                get = function()
                                    local c = self.db.profile.enemy.eliteBorderColor
                                    return c.r, c.g, c.b, c.a
                                end,
                                set = function(info, r, g, b, a)
                                    self.db.profile.enemy.eliteBorderColor = {r=r, g=g, b=b, a=a}
                                    self:UpdateAllNameplates()
                                end,
                            },
                        },
                    },
                    texts = {
                        name = L["Text Display"],
                        type = "group",
                        order = 4,
                        inline = true,
                        args = {
                            showName = {
                                name = L["Show Name"],
                                desc = L["Show unit names on nameplates"],
                                type = "toggle",
                                order = 1,
                                get = function() return self.db.profile.enemy.showName end,
                                set = function(info, value)
                                    self.db.profile.enemy.showName = value
                                    self:UpdateAllNameplates()
                                end,
                            },
                            showLevel = {
                                name = L["Show Level"],
                                desc = L["Show unit levels on nameplates"],
                                type = "toggle",
                                order = 2,
                                get = function() return self.db.profile.enemy.showLevel end,
                                set = function(info, value)
                                    self.db.profile.enemy.showLevel = value
                                    self:UpdateAllNameplates()
                                end,
                            },
                            showHealthPercent = {
                                name = L["Show Health Percent"],
                                desc = L["Show health percentage on nameplates"],
                                type = "toggle",
                                order = 3,
                                get = function() return self.db.profile.enemy.showHealthPercent end,
                                set = function(info, value)
                                    self.db.profile.enemy.showHealthPercent = value
                                    self:UpdateAllNameplates()
                                end,
                            },
                            showHealthValue = {
                                name = L["Show Health Value"],
                                desc = L["Show actual health values on nameplates"],
                                type = "toggle",
                                order = 4,
                                get = function() return self.db.profile.enemy.showHealthValue end,
                                set = function(info, value)
                                    self.db.profile.enemy.showHealthValue = value
                                    self:UpdateAllNameplates()
                                end,
                            },
                            nameLength = {
                                name = L["Max Name Length"],
                                desc = L["Maximum number of characters to show in names"],
                                type = "range",
                                order = 5,
                                min = 0,
                                max = 40,
                                step = 1,
                                get = function() return self.db.profile.enemy.nameLength end,
                                set = function(info, value)
                                    self.db.profile.enemy.nameLength = value
                                    self:UpdateAllNameplates()
                                end,
                            },
                        },
                    },
                    features = {
                        name = L["Features"],
                        type = "group",
                        order = 5,
                        inline = true,
                        args = {
                            executionIndicator = {
                                name = L["Show Execution Indicator"],
                                desc = L["Highlight nameplates of low health enemies"],
                                type = "toggle",
                                order = 1,
                                get = function() return self.db.profile.enemy.executionIndicator end,
                                set = function(info, value)
                                    self.db.profile.enemy.executionIndicator = value
                                    self:UpdateAllNameplates()
                                end,
                            },
                            executionThreshold = {
                                name = L["Execution Threshold"],
                                desc = L["Health percentage to trigger the execution indicator"],
                                type = "range",
                                order = 2,
                                min = 5,
                                max = 50,
                                step = 5,
                                get = function() return self.db.profile.enemy.executionThreshold end,
                                set = function(info, value)
                                    self.db.profile.enemy.executionThreshold = value
                                    self:UpdateAllNameplates()
                                end,
                                disabled = function() return not self.db.profile.enemy.executionIndicator end,
                            },
                            showEliteBorder = {
                                name = L["Show Elite Border"],
                                desc = L["Show special border for elite units"],
                                type = "toggle",
                                order = 3,
                                get = function() return self.db.profile.enemy.showEliteBorder end,
                                set = function(info, value)
                                    self.db.profile.enemy.showEliteBorder = value
                                    self:UpdateAllNameplates()
                                end,
                            },
                            showCastTarget = {
                                name = L["Show Cast Target"],
                                desc = L["Show the target of spells being cast"],
                                type = "toggle",
                                order = 4,
                                get = function() return self.db.profile.enemy.showCastTarget end,
                                set = function(info, value)
                                    self.db.profile.enemy.showCastTarget = value
                                    self:UpdateAllNameplates()
                                end,
                            },
                            showInterruptShield = {
                                name = L["Show Interrupt Shield"],
                                desc = L["Show shield icon for non-interruptible casts"],
                                type = "toggle",
                                order = 5,
                                get = function() return self.db.profile.enemy.showInterruptShield end,
                                set = function(info, value)
                                    self.db.profile.enemy.showInterruptShield = value
                                    self:UpdateAllNameplates()
                                end,
                            },
                        },
                    },
                    auras = {
                        name = L["Buffs and Debuffs"],
                        type = "group",
                        order = 6,
                        inline = true,
                        args = {
                            showBuffs = {
                                name = L["Show Buffs"],
                                desc = L["Show buffs on enemy nameplates"],
                                type = "toggle",
                                order = 1,
                                get = function() return self.db.profile.enemy.showBuffs end,
                                set = function(info, value)
                                    self.db.profile.enemy.showBuffs = value
                                    self:UpdateAllNameplates()
                                end,
                            },
                            showDebuffs = {
                                name = L["Show Debuffs"],
                                desc = L["Show debuffs on enemy nameplates"],
                                type = "toggle",
                                order = 2,
                                get = function() return self.db.profile.enemy.showDebuffs end,
                                set = function(info, value)
                                    self.db.profile.enemy.showDebuffs = value
                                    self:UpdateAllNameplates()
                                end,
                            },
                            showOnlyMyDebuffs = {
                                name = L["Show Only My Debuffs"],
                                desc = L["Only show debuffs cast by you"],
                                type = "toggle",
                                order = 3,
                                get = function() return self.db.profile.enemy.showOnlyMyDebuffs end,
                                set = function(info, value)
                                    self.db.profile.enemy.showOnlyMyDebuffs = value
                                    self:UpdateAllNameplates()
                                end,
                                disabled = function() return not self.db.profile.enemy.showDebuffs end,
                            },
                            showOnlyImportantBuffs = {
                                name = L["Show Only Important Buffs"],
                                desc = L["Only show buffs from the important auras list"],
                                type = "toggle",
                                order = 4,
                                get = function() return self.db.profile.enemy.showOnlyImportantBuffs end,
                                set = function(info, value)
                                    self.db.profile.enemy.showOnlyImportantBuffs = value
                                    self:UpdateAllNameplates()
                                end,
                                disabled = function() return not self.db.profile.enemy.showBuffs end,
                            },
                        },
                    },
                },
            },
            friendly = {
                name = L["Friendly Nameplates"],
                type = "group",
                order = 3,
                args = {
                    enabled = {
                        name = L["Enable Friendly Nameplates"],
                        type = "toggle",
                        order = 1,
                        width = "full",
                        get = function() return self.db.profile.friendly.enabled end,
                        set = function(info, value)
                            self.db.profile.friendly.enabled = value
                            self:UpdateAllNameplates()
                        end,
                    },
                    dimensions = {
                        name = L["Size and Position"],
                        type = "group",
                        order = 2,
                        inline = true,
                        args = {
                            width = {
                                name = L["Width"],
                                desc = L["Width of the health bar"],
                                type = "range",
                                order = 1,
                                min = 50,
                                max = 250,
                                step = 5,
                                get = function() return self.db.profile.friendly.width end,
                                set = function(info, value)
                                    self.db.profile.friendly.width = value
                                    self:UpdateAllNameplates()
                                end,
                            },
                            height = {
                                name = L["Height"],
                                desc = L["Height of the health bar"],
                                type = "range",
                                order = 2,
                                min = 4,
                                max = 30,
                                step = 1,
                                get = function() return self.db.profile.friendly.height end,
                                set = function(info, value)
                                    self.db.profile.friendly.height = value
                                    self:UpdateAllNameplates()
                                end,
                            },
                            scale = {
                                name = L["Scale"],
                                desc = L["Overall scale of the nameplate"],
                                type = "range",
                                order = 3,
                                min = 0.5,
                                max = 2.0,
                                step = 0.05,
                                get = function() return self.db.profile.friendly.scale end,
                                set = function(info, value)
                                    self.db.profile.friendly.scale = value
                                    self:UpdateAllNameplates()
                                end,
                            },
                        },
                    },
                    appearance = {
                        name = L["Appearance"],
                        type = "group",
                        order = 3,
                        inline = true,
                        args = {
                            useClassColors = {
                                name = L["Use Class Colors"],
                                desc = L["Color health bars by player class"],
                                type = "toggle",
                                order = 1,
                                get = function() return self.db.profile.friendly.useClassColors end,
                                set = function(info, value)
                                    self.db.profile.friendly.useClassColors = value
                                    self:UpdateAllNameplates()
                                end,
                            },
                            showFriendlyClassIcon = {
                                name = L["Show Class Icon"],
                                desc = L["Show class icon for friendly players"],
                                type = "toggle",
                                order = 2,
                                get = function() return self.db.profile.friendly.showFriendlyClassIcon end,
                                set = function(info, value)
                                    self.db.profile.friendly.showFriendlyClassIcon = value
                                    self:UpdateAllNameplates()
                                end,
                            },
                        },
                    },
                },
            },
            player = {
                name = L["Player Nameplate"],
                type = "group",
                order = 4,
                args = {
                    enabled = {
                        name = L["Enable Player Nameplate"],
                        type = "toggle",
                        order = 1,
                        width = "full",
                        get = function() return self.db.profile.player.enabled end,
                        set = function(info, value)
                            self.db.profile.player.enabled = value
                            self:UpdateAllNameplates()
                        end,
                    },
                    dimensions = {
                        name = L["Size and Position"],
                        type = "group",
                        order = 2,
                        inline = true,
                        args = {
                            width = {
                                name = L["Width"],
                                desc = L["Width of the health bar"],
                                type = "range",
                                order = 1,
                                min = 50,
                                max = 250,
                                step = 5,
                                get = function() return self.db.profile.player.width end,
                                set = function(info, value)
                                    self.db.profile.player.width = value
                                    self:UpdateAllNameplates()
                                end,
                            },
                            height = {
                                name = L["Height"],
                                desc = L["Height of the health bar"],
                                type = "range",
                                order = 2,
                                min = 4,
                                max = 30,
                                step = 1,
                                get = function() return self.db.profile.player.height end,
                                set = function(info, value)
                                    self.db.profile.player.height = value
                                    self:UpdateAllNameplates()
                                end,
                            },
                            scale = {
                                name = L["Scale"],
                                desc = L["Overall scale of the nameplate"],
                                type = "range",
                                order = 3,
                                min = 0.5,
                                max = 2.0,
                                step = 0.05,
                                get = function() return self.db.profile.player.scale end,
                                set = function(info, value)
                                    self.db.profile.player.scale = value
                                    self:UpdateAllNameplates()
                                end,
                            },
                        },
                    },
                    features = {
                        name = L["Features"],
                        type = "group",
                        order = 3,
                        inline = true,
                        args = {
                            useClassColors = {
                                name = L["Use Class Colors"],
                                desc = L["Color health bar by your class"],
                                type = "toggle",
                                order = 1,
                                get = function() return self.db.profile.player.useClassColors end,
                                set = function(info, value)
                                    self.db.profile.player.useClassColors = value
                                    self:UpdateAllNameplates()
                                end,
                            },
                            showName = {
                                name = L["Show Name"],
                                desc = L["Show your name on the nameplate"],
                                type = "toggle",
                                order = 2,
                                get = function() return self.db.profile.player.showName end,
                                set = function(info, value)
                                    self.db.profile.player.showName = value
                                    self:UpdateAllNameplates()
                                end,
                            },
                            showHealthPercent = {
                                name = L["Show Health Percent"],
                                desc = L["Show health percentage on the nameplate"],
                                type = "toggle",
                                order = 3,
                                get = function() return self.db.profile.player.showHealthPercent end,
                                set = function(info, value)
                                    self.db.profile.player.showHealthPercent = value
                                    self:UpdateAllNameplates()
                                end,
                            },
                        },
                    },
                },
            },
        },
    }
    
    return options
end

-- Register the module
VUI:RegisterModule(MODNAME, M)