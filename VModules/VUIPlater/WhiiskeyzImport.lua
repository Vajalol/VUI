-- VUIPlater WhiiskeyzImport
-- Provides functions to import Whiiskeyz Plater profile

local AddonName, VUI = ...
local M = VUI and VUI.VUIPlater or {}
if not M then return end

-- WhiiskeyzPlater compatibility module
local WhiiskeyzImport = {}
M.WhiiskeyzImport = WhiiskeyzImport

-- Apply the Whiiskeyz preset to VUIPlater
function WhiiskeyzImport.ApplyWhiiskeyzPreset(platerModule)
    -- Module validation
    if not platerModule or not platerModule.db or not platerModule.db.profile then
        return false
    end
    
    -- Set the preset flag
    platerModule.db.profile.currentPreset = "WHIISKEYZ"
    
    -- Apply performance CVars for optimal nameplate experience
    WhiiskeyzImport.SetupOptimalCVars()
    
    -- Set up enemy nameplate settings
    platerModule.db.profile.enemy = WhiiskeyzImport.GetEnemySettings()
    
    -- Set up friendly nameplate settings
    platerModule.db.profile.friendly = WhiiskeyzImport.GetFriendlySettings()
    
    -- Set up player nameplate settings
    platerModule.db.profile.player = WhiiskeyzImport.GetPlayerSettings()
    
    -- Set up misc settings
    platerModule.db.profile.misc = WhiiskeyzImport.GetMiscSettings()
    
    -- Set up performance settings
    platerModule.db.profile.performance = WhiiskeyzImport.GetPerformanceSettings()
    
    -- Set up The War Within specific settings
    if platerModule.PlaterService and platerModule.PlaterService.IsWarWithinOrLater and 
       platerModule.PlaterService:IsWarWithinOrLater() then
        platerModule.db.profile.warwithin = WhiiskeyzImport.GetWarWithinSettings()
    end
    
    -- Set up aura filter lists
    platerModule.importantBuffs = WhiiskeyzImport.GetImportantBuffs()
    platerModule.importantDebuffs = WhiiskeyzImport.GetImportantDebuffs()
    
    -- Report success
    return true
end

-- Set up optimal nameplate CVars
function WhiiskeyzImport.SetupOptimalCVars()
    -- Enemy nameplates
    SetCVar("nameplateShowEnemies", 1)
    
    -- Friendly nameplates
    SetCVar("nameplateShowFriends", 1)
    
    -- Personal nameplate
    SetCVar("nameplateShowSelf", 0)
    
    -- Nameplate distance
    SetCVar("nameplateMaxDistance", 60)
    
    -- Nameplate overlap
    SetCVar("nameplateOverlapV", 1.1)
    SetCVar("nameplateOverlapH", 0.8)
    
    -- Nameplate motion type (1 = stacking, 0 = overlapping)
    SetCVar("nameplateMotion", 1)
    
    -- Keep nameplates on screen
    SetCVar("nameplateOtherTopInset", -1)
    SetCVar("nameplateOtherBottomInset", -1)
    
    -- Nameplate scale
    SetCVar("NamePlateHorizontalScale", 1.0)
    SetCVar("NamePlateVerticalScale", 1.0)
    
    -- Nameplate selection scale
    SetCVar("nameplateSelectedScale", 1.2)
    
    -- The War Within specific CVars
    local _, _, _, tocversion = GetBuildInfo()
    if tocversion >= 100200 then  -- The War Within
        -- Modern nameplates
        SetCVar("nameplateShowDebuffsOnFriendly", 1)
        SetCVar("nameplateResourceOnTarget", 1)
        SetCVar("nameplateTargetRadialPosition", 1)
        SetCVar("nameplateTargetBehindMaxDistance", 30)
    end
end

-- Get enemy nameplate settings
function WhiiskeyzImport.GetEnemySettings()
    return {
        enabled = true,
        width = 140,
        height = 10,
        castBarHeight = 10,
        scale = 1.0,
        healthBarTexture = "VUI Smooth",
        castBarTexture = "VUI Flat",
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
    }
end

-- Get friendly nameplate settings
function WhiiskeyzImport.GetFriendlySettings()
    return {
        enabled = true,
        width = 140,
        height = 10,
        castBarHeight = 10,
        scale = 1.0,
        healthBarTexture = "VUI Smooth",
        castBarTexture = "VUI Flat",
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
        nameOnlyMode = true,
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
    }
end

-- Get player nameplate settings
function WhiiskeyzImport.GetPlayerSettings()
    return {
        enabled = true,
        width = 140,
        height = 10,
        castBarHeight = 10,
        scale = 1.0,
        healthBarTexture = "VUI Smooth",
        castBarTexture = "VUI Flat",
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
        showCastTarget = true,
        showInterruptShield = true,
    }
end

-- Get misc settings
function WhiiskeyzImport.GetMiscSettings()
    return {
        showEnemyNameplates = true,
        showFriendlyNameplates = true,
        showPlayerNameplate = true,
        showNPCTitles = false,
    }
end

-- Get performance settings
function WhiiskeyzImport.GetPerformanceSettings()
    return {
        nameplateRange = 60,
        maxDisplayed = 40,
        clampToScreen = true,
        stackingNameplates = true,
        overlapProtection = true,
    }
end

-- Get The War Within specific settings
function WhiiskeyzImport.GetWarWithinSettings()
    return {
        useNewStackingSystem = true,
        useResourceDisplay = true,
        useModernHealthBar = true,
        newTargetGlow = true,
        enhancedVisibility = true,
    }
end

-- Get list of important buffs to track
function WhiiskeyzImport.GetImportantBuffs()
    return {
        -- Defensive buffs
        [642] = true,    -- Divine Shield
        [1022] = true,   -- Blessing of Protection
        [45438] = true,  -- Ice Block
        [186265] = true, -- Aspect of the Turtle
        [33206] = true,  -- Pain Suppression
        
        -- Offensive buffs
        [1719] = true,   -- Recklessness
        [31884] = true,  -- Avenging Wrath
        [51271] = true,  -- Pillar of Frost
        [12472] = true,  -- Icy Veins
        [190319] = true, -- Combustion
        
        -- Important dungeon buffs
        [226510] = true, -- Mythic+ Fortified
        [226489] = true, -- Mythic+ Tyrannical
    }
end

-- Get list of important debuffs to track
function WhiiskeyzImport.GetImportantDebuffs()
    return {
        -- CC debuffs
        [122] = true,    -- Frost Nova
        [339] = true,    -- Entangling Roots
        [2094] = true,   -- Blind
        [6770] = true,   -- Sap
        [9484] = true,   -- Shackle Undead
        [20066] = true,  -- Repentance
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
        
        -- Important dungeon debuffs
        [209858] = true, -- Necrotic Wound
        [240559] = true, -- Grievous Wound
        [342494] = true, -- Belligerent Boast (Pride affix)
    }
end

-- Export the module
return WhiiskeyzImport 