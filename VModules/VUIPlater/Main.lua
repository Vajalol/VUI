-- VUIPlater Module
-- A standalone nameplate module for VUI
-- Based on Whiiskeyz Plater profile (https://wago.io/whiiskeyzplater)

local AddonName = ...
local VUI = _G["VUI"]
local MODNAME = "VUIPlater"

-- Set up global reference early to prevent nil errors
_G["VUIPlater"] = _G["VUIPlater"] or {}

-- Create minimal fallback if VUI doesn't exist
if not VUI then
    VUI = {}
    VUI.NewModule = function() return {} end
    _G["VUI"] = VUI
end

-- Try to create the module with error handling
local M

if VUI.NewModule then
    M = VUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0", "AceHook-3.0")
    -- Update the global reference with the actual module
    _G["VUIPlater"] = M
else
    -- Create minimal module object to prevent errors
    M = {
        NAME = MODNAME,
        TITLE = "VUI Plater",
        DESCRIPTION = "Custom nameplate styling based on Whiiskeyz Plater profile",
        VERSION = "1.0",
        OnEnable = function() end,
        OnDisable = function() end
    }
    
    -- Register in VUI namespace
    VUI[MODNAME] = M
    
    -- Update the global reference with our placeholder
    _G["VUIPlater"] = M
    
    -- Try initialization again after delay
    C_Timer.After(0.5, function()
        if VUI and VUI.NewModule then
            local RealModule = VUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0", "AceHook-3.0")
            
            -- Transfer any properties from temporary module
            for k, v in pairs(M) do
                if k ~= "NAME" and k ~= "TITLE" and type(v) ~= "function" then
                    RealModule[k] = v
                end
            end
            
            -- Replace with real module
            VUI[MODNAME] = RealModule
            
            -- Update the global reference with the actual module
            _G["VUIPlater"] = RealModule
            
            -- Initialize the module
            if RealModule.OnInitialize then RealModule:OnInitialize() end
            if RealModule.OnEnable then RealModule:OnEnable() end
        end
    end)
end

-- Set global namespace for other files to access
VUI.VUIPlater = M

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
        },
        -- Friendly Nameplate Settings
        friendly = {
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
            healthBarTexture = "VUI Whiiskeyz",
            castBarTexture = "VUI Flat",
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
    ["VUI_BORDER_1PX"] = "Interface\\AddOns\\VUI\\VModules\\VUIPlater\\media\\textures\\border_1px.tga",
    ["VUI_BORDER_2PX"] = "Interface\\AddOns\\VUI\\VModules\\VUIPlater\\media\\textures\\border_2px.tga",
    ["VUI_BORDER_GLOW"] = "Interface\\AddOns\\VUI\\VModules\\VUIPlater\\media\\textures\\border_glow.tga",
}

-- Aura whitelist/blacklist
M.auraWhitelist = {}
M.auraBlacklist = {}

-- Nameplate cache
M.nameplates = {}
M.createdNameplates = {}

-- Initialize module
function M:OnInitialize()
    -- Create the database with consistent naming
    if VUI and VUI.db then
        -- Check if a namespace already exists with any of the possible names
        local namespace = VUI.db.namespaces["VUIPlater"] or VUI.db.namespaces["vuiplater"]
        
        if namespace then
            -- Use existing namespace
            self.db = namespace
            
            -- Ensure both versions are synchronized
            VUI.db.namespaces["VUIPlater"] = namespace
            VUI.db.namespaces["vuiplater"] = namespace
        else
            -- Create new namespace with proper case for consistency
            self.db = VUI.db:RegisterNamespace("VUIPlater", {
                profile = self.defaults.profile
            })
            
            -- Also create lowercase reference for compatibility
            VUI.db.namespaces["vuiplater"] = self.db
            
            -- Apply the Whiiskeyz preset by default for new installations
            self:ApplyWhiiskeyzPreset()
        end
    else
        -- Fallback if VUI.db isn't available
        self.db = {profile = self.defaults.profile}
    end
    
    -- Register settings with VUI Config
    if VUI and VUI.Config and type(VUI.Config.RegisterModuleOptions) == "function" then
        VUI.Config:RegisterModuleOptions(self.NAME, self:GetOptions(), self.TITLE)
    end
    
    -- Create custom border textures
    self:CreateBorderTextures()
    
    -- Cache addon font media for LibSharedMedia
    self:RegisterFontMedia()
    
    -- Setup statusbar textures
    self:RegisterStatusBarTextures()
    
    -- Initialize counters
    self.plateCount = 0
    
    self:Debug("VUIPlater module initialized")
    
    -- If this is a new installation or no preset is set, apply the Whiiskeyz preset
    if not self.db.profile.currentPreset then
        self:ApplyWhiiskeyzPreset()
    end
end

function M:OnEnable()
    -- Register WhiiskeyzPlater textures
    self:RegisterWhiiskeyzTextures()
    
    -- Ensure AddAddOnsLoaded exists globally to prevent errors
    if not _G.AddAddOnsLoaded then
        _G.AddAddOnsLoaded = function(addon, callback)
            if not addon or not callback then return end
            
            -- Check if the addon is already loaded
            if IsAddOnLoaded(addon) then
                callback()
                return
            end
            
            -- Create event frame to wait for addon to load
            local frame = CreateFrame("Frame")
            frame:RegisterEvent("ADDON_LOADED")
            frame:SetScript("OnEvent", function(self, event, loadedAddon)
                if event == "ADDON_LOADED" and loadedAddon == addon then
                    callback()
                    self:UnregisterAllEvents()
                end
            end)
        end
    end
    
    -- Safe function to check if an addon is loaded
    local function SafeIsAddOnLoaded(addon)
        if IsAddOnLoaded and type(IsAddOnLoaded) == "function" then
            return IsAddOnLoaded(addon)
        else
            -- Fallback method using GetAddOnInfo if available
            if GetAddOnInfo and type(GetAddOnInfo) == "function" then
                local _, _, _, enabled, loadable, reason, _ = GetAddOnInfo(addon)
                return enabled and loadable and reason == "LOADED"
            end
            return false -- Default to not loaded if we can't check
        end
    end
    
    -- Initialize PlaterService if it exists
    if self.PlaterService and type(self.PlaterService.Initialize) == "function" then
        self.PlaterService:Initialize()
    end
    
    -- Load the PlaterProfileImport module if it exists (for profile importing)
    if self.PlaterProfileImport and type(self.PlaterProfileImport.ImportPlaterProfile) == "function" then
        self:Debug("PlaterProfileImport module loaded")
    end
    
    if not SafeIsAddOnLoaded("Plater") then
        self:RegisterEvent("ADDON_LOADED", "OnAddonLoaded")
        self:Debug("Plater not loaded, waiting for ADDON_LOADED event")
    else
        -- Call our safe hook method
        self:HookPlater()
    end
    
    -- Start retry timer if hooks failed
    if not self.isHooked then
        self.retryTimer = self:ScheduleTimer(function()
            -- Try to hook Plater again
            if self:HookPlater() and self.retryTimer then
                self:CancelTimer(self.retryTimer)
                self.retryTimer = nil
            end
        end, 3)
    end
    
    -- Register key events for nameplate updates
    self:RegisterEvent("NAME_PLATE_UNIT_ADDED", "OnNamePlateAdded")
    self:RegisterEvent("NAME_PLATE_UNIT_REMOVED", "OnNamePlateRemoved")
    self:RegisterEvent("UNIT_THREAT_LIST_UPDATE", "OnThreatUpdated")
    self:RegisterEvent("PLAYER_TARGET_CHANGED", "OnTargetChanged")
    self:RegisterEvent("PLAYER_FOCUS_CHANGED", "OnFocusChanged")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "OnCombatLogEvent")
    
    -- If we have a current preset, apply its settings
    if self.db.profile.currentPreset == "WHIISKEYZ" then
        self:ApplyWhiiskeyzPreset()
    end
    
    -- Schedule a timer to update all nameplates after everything is loaded
    self:ScheduleTimer(function()
        self:UpdateAllNameplates()
        self:Debug("Initial nameplate update completed")
    end, 1)
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
    
    -- Re-enable core nameplate modules if they're not already enabled
    local nameplateModules = {
        "NamePlates.Core",
        "NamePlates.TotemIcons",
        "NamePlates.HealthText",
        "NamePlates.CastTime"
    }
    
    -- Check VUI profile to see if nameplates are enabled
    local db = VUI and VUI.db and VUI.db.profile and VUI.db.profile.nameplates
    if db then
        for _, moduleName in ipairs(nameplateModules) do
            -- Add safety check for GetModule method
            if VUI and VUI.GetModule and type(VUI.GetModule) == "function" then
                -- Use pcall to catch errors if module doesn't exist
                local success, module = pcall(function() return VUI:GetModule(moduleName, true) end)
                
                -- Only try to enable if the module was found and has an IsEnabled method
                if success and module and module.IsEnabled and type(module.IsEnabled) == "function" then
                    -- Check if not enabled and has an Enable method
                    if not module:IsEnabled() and module.Enable and type(module.Enable) == "function" then
                        pcall(function() module:Enable() end)
                        self:Debug("Re-enabled core module: " .. moduleName)
                    end
                end
            end
        end
    end
    
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
    
    -- Register Expressway font if it doesn't exist
    if not LSM:IsValid("font", "Expressway") then
        -- Check if VUI addon is loaded and try to use its Expressway font
        if VUI and VUI.Media and VUI.Media.Fonts and VUI.Media.Fonts.Expressway then
            -- Use VUI's Expressway font
            LSM:Register("font", "Expressway", VUI.Media.Fonts.Expressway)
        else
            -- Try to register with a direct path
            local expresswayPath = "Interface\\AddOns\\VUI\\Media\\Fonts\\expressway.ttf"
            LSM:Register("font", "Expressway", expresswayPath)
            -- Note: LSM will fall back to default if file doesn't exist
        end
    end
    
    -- Register our statusbar textures for nameplates with high-quality textures
    -- Each of these is selected to closely match the Whiiskeyz Plater profile
    
    -- VUI Gradient - for smooth health bars with slight gradient
    if not LSM:IsValid("statusbar", "VUI Gradient") then
        LSM:Register("statusbar", "VUI Gradient", "Interface\\AddOns\\VUI\\Media\\Textures\\Status\\Smooth.blp")
    end
    
    -- VUI Flat - for cast bars with minimal design
    if not LSM:IsValid("statusbar", "VUI Flat") then
        LSM:Register("statusbar", "VUI Flat", "Interface\\AddOns\\VUI\\Media\\Textures\\Status\\Flat.blp")
    end
    
    -- VUI Smooth - for high-quality smooth bars
    if not LSM:IsValid("statusbar", "VUI Smooth") then
        LSM:Register("statusbar", "VUI Smooth", "Interface\\AddOns\\VUI\\Media\\Textures\\Status\\Smoothv2.tga")
    end
    
    -- VUI Whiiskeyz - specifically named for the Whiiskeyz Plater profile style
    if not LSM:IsValid("statusbar", "VUI Whiiskeyz") then
        LSM:Register("statusbar", "VUI Whiiskeyz", "Interface\\AddOns\\VUI\\Media\\Textures\\Status\\Glaze.tga")
    end
    
    -- VUI Glossy - for more polished looking bars
    if not LSM:IsValid("statusbar", "VUI Glossy") then
        LSM:Register("statusbar", "VUI Glossy", "Interface\\AddOns\\VUI\\Media\\Textures\\Status\\Otravi.tga")
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
    plate.VUI.castShield:SetTexture("Interface\\AddOns\\VUI\\VModules\\VUIPlater\\media\\textures\\shield.tga")
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
    plate.VUI.threatIndicator:SetTexture("Interface\\AddOns\\VUI\\VModules\\VUIPlater\\media\\textures\\threat.tga")
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
    local isBoss = UnitClassification(unitID) == "worldboss" or UnitClassification(unitID) == "rareelite"
    local isRare = UnitClassification(unitID) == "rare"
    local isElite = UnitClassification(unitID) == "elite"
    
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
                                self:ApplyPresetSettings("WHIISKEYZ")
                            end
                        end,
                    },
                    platerImport = {
                        name = L["Import to Plater"],
                        desc = L["Import VUIPlater profile to Plater addon if installed"],
                        type = "execute",
                        order = 2.5,
                        width = "full",
                        func = function()
                            if not IsAddOnLoaded("Plater") then
                                print("|cFFFF0000[VUIPlater]|r Plater addon is not installed or enabled.")
                                return
                            end
                            
                            if self.PlaterProfileImport and self.PlaterProfileImport.ImportPlaterProfile then
                                local success, message = self.PlaterProfileImport.ImportPlaterProfile(self)
                                if success then
                                    print("|cFF00FF00[VUIPlater]|r Profile imported to Plater successfully!")
                                else
                                    print("|cFFFF0000[VUIPlater]|r Error importing profile: " .. (message or "Unknown error"))
                                end
                            else
                                print("|cFFFF0000[VUIPlater]|r PlaterProfileImport module not available.")
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
if VUI.RegisterModule then
    VUI:RegisterModule(MODNAME, M)
end

-- Register hooks for Plater
function M:HookPlater()
    -- Check if Plater is loaded
    if not Plater then
        self:Debug("Plater not found, trying again later")
        return false
    end
    
    -- Don't hook twice
    if self.isHooked then
        return true
    end
    
    -- Create a safe waiting function instead of using AddAddOnsLoaded
    local function SafeWaitForAddon(addonName, callback)
        if not addonName or not callback then return end
        
        -- Check if the addon is already loaded
        if IsAddOnLoaded(addonName) then
            callback()
            return
        end
        
        -- Set up a frame to listen for the addon loaded event
        local frame = CreateFrame("Frame")
        frame:RegisterEvent("ADDON_LOADED")
        frame:SetScript("OnEvent", function(self, event, loadedAddon)
            if event == "ADDON_LOADED" and loadedAddon == addonName then
                callback()
                self:UnregisterAllEvents()
            end
        end)
    end
    
    -- Apply hooks to Plater
    local success = pcall(function()
        -- Hook Plater's nameplate creation functions
        self:SecureHook(Plater, "OnRetailNamePlateCreated", "OnNamePlateCreated")
        self:SecureHook(Plater, "UpdatePlateFrame", "OnNamePlateUpdated")
        
        -- Hook Plater's aura functions
        self:SecureHook(Plater, "AddAura", "OnPlaterAddAura")
        self:SecureHook(Plater, "RemoveAura", "OnPlaterRemoveAura")
        
        -- Hook Plater's cast functions
        self:SecureHook(Plater, "StartCastBarOnNameplate", "OnCastStart")
        self:SecureHook(Plater, "StopCastBarOnNameplate", "OnCastStop")
        
        -- Hook various Plater update events
        self:SecureHook(Plater, "UpdateHealthAmount", "OnHealthUpdate")
        self:SecureHook(Plater, "UpdateNameplateThread", "OnThreatUpdate")
        
        -- Wait for Details to load if needed
        if self.db.profile.useSomeAddon then
            SafeWaitForAddon("Details", function()
                -- Hook into Details here
                self:Debug("Details loaded, hooking...")
                -- Additional hooks would go here
            end)
        end
        
        self:Debug("Successfully hooked Plater functions")
    end)
    
    if not success then
        self:Debug("Failed to hook Plater functions")
        return false
    end
    
    -- Process existing nameplates
    self:ProcessExistingNameplates()
    
    -- Start update timer
    self.updateTimer = self:ScheduleRepeatingTimer("UpdateNameplates", 0.1)
    
    -- Set hooked flag
    self.isHooked = true
    
    return true
end

-- Handle addon loaded event
function M:OnAddonLoaded(event, addon)
    if addon == "Plater" then
        self:UnregisterEvent("ADDON_LOADED")
        self:HookPlater()
    end
end

-- Around line 1440, add a wrapper function for buff/debuff API compatibility

-- Wrapper function for UnitBuff/UnitDebuff API compatibility with The War Within
function M:GetAuraInfo(unitID, index, filter, isDebuff)
    -- Use C_UnitAuras if available (for The War Within and newer)
    if C_UnitAuras then
        local auraData
        if isDebuff then
            auraData = C_UnitAuras.GetDebuffByIndex(unitID, index, filter)
        else
            auraData = C_UnitAuras.GetBuffByIndex(unitID, index, filter)
        end
        
        if auraData then
            return auraData.name, 
                   auraData.icon,
                   auraData.applications,
                   auraData.dispelName,
                   auraData.duration,
                   auraData.expirationTime,
                   auraData.sourceUnit,
                   auraData.isStealable,
                   auraData.nameplateShowPersonal,
                   auraData.spellId,
                   auraData.canApplyAura,
                   auraData.isBossDebuff,
                   auraData.isCastByPlayer
        end
        return nil
    else
        -- Fallback to traditional API for older WoW versions
        if isDebuff then
            return UnitDebuff(unitID, index, filter)
        else
            return UnitBuff(unitID, index, filter)
        end
    end
end

-- Update the UpdateBuffs function around line 1430
function M:UpdateBuffs(plate, unitID)
    if not plate or not unitID or not plate.VUIElements then return end
    
    local buffFrame = plate.VUIElements.BuffFrame
    if not buffFrame then return end
    
    -- Clear all existing buffs
    for i = 1, #buffFrame.buffIcons do
        buffFrame.buffIcons[i]:Hide()
    end
    
    -- Check if we should display buffs
    local settings = self:GetUnitSettings(unitID)
    if not settings.showBuffs then return end
    
    -- Get filter strings
    local filterString = ""
    if settings.showOnlyImportantBuffs then
        filterString = "HELPFUL PLAYER"
    else
        filterString = "HELPFUL"
    end
    
    -- Get number of buffs
    local numBuffs = 0
    
    -- If using C_UnitAuras (The War Within and newer)
    if C_UnitAuras then
        local auraData = C_UnitAuras.GetAuraDataByUnit(unitID, filterString)
        numBuffs = auraData and #auraData or 0
    else
        -- For older versions, count manually
        local i = 1
        while UnitBuff(unitID, i, filterString) do
            numBuffs = numBuffs + 1
            i = i + 1
        end
    end
    
    -- Display buffs
    local buffCount = 0
    local maxBuffs = settings.buffRows * settings.buffColumns
    
    for i = 1, numBuffs do
        if buffCount >= maxBuffs then break end
        
        local name, icon, count, debuffType, duration, expirationTime, caster, 
              isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer = self:GetAuraInfo(unitID, i, filterString, false)
        
        -- Skip buffs from other players if filtering enabled
        if name and (not settings.filterBuffs or (settings.filterBuffs and castByPlayer)) then
            buffCount = buffCount + 1
            
            local buffIcon = buffFrame.buffIcons[buffCount]
            if not buffIcon then
                -- Create buff icon if it doesn't exist
                buffIcon = self:CreateAuraIcon(buffFrame)
                table.insert(buffFrame.buffIcons, buffIcon)
            end
            
            -- Set icon texture
            buffIcon.Icon:SetTexture(icon)
            
            -- Set size
            buffIcon:SetSize(settings.buffSize, settings.buffSize)
            buffIcon.Icon:SetSize(settings.buffSize - 2, settings.buffSize - 2)
            
            -- Set count
            if settings.showBuffStacks and count and count > 1 then
                buffIcon.Count:SetText(count)
                buffIcon.Count:Show()
            else
                buffIcon.Count:Hide()
            end
            
            -- Set duration
            if settings.showBuffDuration and duration and duration > 0 then
                buffIcon.Cooldown:SetCooldown(expirationTime - duration, duration)
                buffIcon.Cooldown:Show()
            else
                buffIcon.Cooldown:Hide()
            end
            
            -- Position based on index
            local row = math.floor((buffCount - 1) / settings.buffColumns)
            local col = (buffCount - 1) % settings.buffColumns
            
            buffIcon:ClearAllPoints()
            buffIcon:SetPoint("TOPLEFT", buffFrame, "TOPLEFT", col * (settings.buffSize + 2), -row * (settings.buffSize + 2))
            buffIcon:Show()
        end
    end
end

-- Update the UpdateDebuffs function around line 1510
function M:UpdateDebuffs(plate, unitID)
    if not plate or not unitID or not plate.VUIElements then return end
    
    local debuffFrame = plate.VUIElements.DebuffFrame
    if not debuffFrame then return end
    
    -- Clear all existing debuffs
    for i = 1, #debuffFrame.debuffIcons do
        debuffFrame.debuffIcons[i]:Hide()
    end
    
    -- Check if we should display debuffs
    local settings = self:GetUnitSettings(unitID)
    if not settings.showDebuffs then return end
    
    -- Get filter strings
    local filterString = ""
    if settings.showOnlyMyDebuffs then
        filterString = "HARMFUL PLAYER"
    else
        filterString = "HARMFUL"
    end
    
    -- Get number of debuffs
    local numDebuffs = 0
    
    -- If using C_UnitAuras (The War Within and newer)
    if C_UnitAuras then
        local auraData = C_UnitAuras.GetAuraDataByUnit(unitID, filterString)
        numDebuffs = auraData and #auraData or 0
    else
        -- For older versions, count manually
        local i = 1
        while UnitDebuff(unitID, i, filterString) do
            numDebuffs = numDebuffs + 1
            i = i + 1
        end
    end
    
    -- Display debuffs
    local debuffCount = 0
    local maxDebuffs = settings.debuffRows * settings.debuffColumns
    
    for i = 1, numDebuffs do
        if debuffCount >= maxDebuffs then break end
        
        local name, icon, count, debuffType, duration, expirationTime, source, isStealable, 
              nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer = self:GetAuraInfo(unitID, i, filterString, true)
        
        -- Skip debuffs from other players if filtering enabled
        if name and (not settings.filterDebuffs or (settings.filterDebuffs and castByPlayer)) then
            debuffCount = debuffCount + 1
            
            local debuffIcon = debuffFrame.debuffIcons[debuffCount]
            if not debuffIcon then
                -- Create debuff icon if it doesn't exist
                debuffIcon = self:CreateAuraIcon(debuffFrame)
                table.insert(debuffFrame.debuffIcons, debuffIcon)
            end
            
            -- Set icon texture
            debuffIcon.Icon:SetTexture(icon)
            
            -- Set size
            debuffIcon:SetSize(settings.debuffSize, settings.debuffSize)
            debuffIcon.Icon:SetSize(settings.debuffSize - 2, settings.debuffSize - 2)
            
            -- Set count
            if settings.showDebuffStacks and count and count > 1 then
                debuffIcon.Count:SetText(count)
                debuffIcon.Count:Show()
            else
                debuffIcon.Count:Hide()
            end
            
            -- Set duration
            if settings.showDebuffDuration and duration and duration > 0 then
                debuffIcon.Cooldown:SetCooldown(expirationTime - duration, duration)
                debuffIcon.Cooldown:Show()
            else
                debuffIcon.Cooldown:Hide()
            end
            
            -- Set border color based on debuff type
            if debuffType then
                local color = DebuffTypeColor[debuffType]
                if color then
                    debuffIcon.Border:SetVertexColor(color.r, color.g, color.b)
                else
                    debuffIcon.Border:SetVertexColor(1, 0, 0) -- Default to red
                end
                debuffIcon.Border:Show()
            else
                debuffIcon.Border:Hide()
            end
            
            -- Position based on index
            local row = math.floor((debuffCount - 1) / settings.debuffColumns)
            local col = (debuffCount - 1) % settings.debuffColumns
            
            debuffIcon:ClearAllPoints()
            debuffIcon:SetPoint("TOPLEFT", debuffFrame, "TOPLEFT", col * (settings.debuffSize + 2), -row * (settings.debuffSize + 2))
            debuffIcon:Show()
        end
    end
end

-- Create Whiiskeyz Plater preset
function M:ApplyWhiiskeyzPreset()
    if self.WhiiskeyzImport and type(self.WhiiskeyzImport.ApplyWhiiskeyzPreset) == "function" then
        -- Use the WhiiskeyzImport module to apply the preset
        local success = self.WhiiskeyzImport.ApplyWhiiskeyzPreset(self)
        if success then
            self:Print("Successfully applied Whiiskeyz Plater preset")
        else
            self:Print("Failed to apply Whiiskeyz Plater preset")
        end
    else
        -- Set the preset flag
        self.db.profile.currentPreset = "WHIISKEYZ"
        
        -- Set up CVars for WhiiskeyzPlater compatibility
        self:SetupWhiiskeyzCVars()
        
        -- Enemy nameplate settings based on Whiiskeyz profile
        self.db.profile.enemy = {
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
        
        -- Friendly nameplate settings
        self.db.profile.friendly = {
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
        
        -- Player nameplate settings
        self.db.profile.player = {
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
        
        -- Performance settings
        self.db.profile.performance = {
            nameplateRange = 60,
            maxDisplayed = 40,
            clampToScreen = true,
            stackingNameplates = true,
            overlapProtection = true,
        }
        
        -- Misc settings
        self.db.profile.misc = {
            showEnemyNameplates = true,
            showFriendlyNameplates = true,
            showPlayerNameplate = true,
            showNPCTitles = false,
        }
        
        -- WhiiskeyzPlater specific features
        self.db.profile.features = {
            -- Combat feedback
            animateCombatFeedback = true,
            showDamageText = true,
            classColoredDamage = true,
            
            -- Status effects
            highlightInterruptibleCasts = true,
            flashAggroGain = true,
            pulseExecuteRange = true,
            
            -- Advanced targeting
            targetGlow = true,
            targetGlowColor = {r = 1, g = 0.9, b = 0.4, a = 0.8},
            mouseoverGlow = true,
            mouseoverGlowColor = {r = 0.8, g = 0.8, b = 1, a = 0.5},
            
            -- Unit classification
            bossModifications = true,
            rareModifications = true,
            
            -- Visual elements
            cleanerNameplates = true,
            improvedTextVisibility = true,
            smoothBarUpdates = true,
            
            -- The War Within features
            useModernHealthBar = true,
            useNewStackingSystem = true,
            useResourceDisplay = true,
        }
        
        -- Font settings
        self.db.profile.fonts = {
            primaryFont = "Arial Narrow",
            damageFont = "Arial Narrow",
            combatFont = "Arial Narrow",
        }
        
        -- Handle WhiiskeyzPlater script mods
        self.db.profile.scripts = {
            enableTargetHighlight = true,
            enableCastTargetDisplay = true,
            enableThreatWarning = true,
            enableAffix = true,
            enableCastbarLatency = true,
            enableExecuteIndicator = true,
            enableCombatIndicator = true,
            enableInterruptAlert = true,
            enableBossModsDebuffs = true,
        }
    end
    
    -- Update all nameplates with new settings
    self:UpdateAllNameplates()
end

-- Function to apply the correct preset settings
function M:ApplyPresetSettings(presetName)
    if presetName == "WHIISKEYZ" then
        self:ApplyWhiiskeyzPreset()
        self:Print("Applied Whiiskeyz Plater profile preset")
    else
        -- Default VUI preset or other presets could be added here
    end
    
    -- Update all nameplates with new settings
    self:UpdateAllNameplates()
end

-- Register WhiiskeyzPlater textures to ensure they're available
function M:RegisterWhiiskeyzTextures()
    -- Register core textures
    local LSM = LibStub("LibSharedMedia-3.0")
    
    -- Register status bar textures if not already registered
    if not LSM:IsValid("statusbar", "VUI Smooth") then
        LSM:Register("statusbar", "VUI Smooth", "Interface\\AddOns\\VUI\\Media\\Textures\\Status\\Smooth.blp")
    end
    
    if not LSM:IsValid("statusbar", "VUI Flat") then
        LSM:Register("statusbar", "VUI Flat", "Interface\\AddOns\\VUI\\Media\\Textures\\Status\\Flat.blp")
    end
    
    if not LSM:IsValid("statusbar", "VUI Gradient") then
        LSM:Register("statusbar", "VUI Gradient", "Interface\\AddOns\\VUI\\Media\\Textures\\Status\\Gradient.tga")
    end
    
    if not LSM:IsValid("statusbar", "VUI Minimalist") then
        LSM:Register("statusbar", "VUI Minimalist", "Interface\\AddOns\\VUI\\Media\\Textures\\Status\\Minimalist.tga")
    end
    
    if not LSM:IsValid("statusbar", "VUI Glaze") then
        LSM:Register("statusbar", "VUI Glaze", "Interface\\AddOns\\VUI\\Media\\Textures\\Status\\Glaze.tga")
    end
    
    -- Register WhiiskeyzPlater specific textures
    if not LSM:IsValid("border", "VUI_BORDER_1PX") then
        LSM:Register("border", "VUI_BORDER_1PX", "Interface\\AddOns\\VUI\\VModules\\VUIPlater\\media\\textures\\border_1px.tga")
    end
    
    if not LSM:IsValid("border", "VUI_BORDER_2PX") then
        LSM:Register("border", "VUI_BORDER_2PX", "Interface\\AddOns\\VUI\\VModules\\VUIPlater\\media\\textures\\border_2px.tga")
    end
    
    if not LSM:IsValid("border", "VUI_BORDER_GLOW") then
        LSM:Register("border", "VUI_BORDER_GLOW", "Interface\\AddOns\\VUI\\VModules\\VUIPlater\\media\\textures\\border_glow.tga")
    end
    
    -- Register fonts required by WhiiskeyzPlater
    if not LSM:IsValid("font", "Arial Narrow") then
        LSM:Register("font", "Arial Narrow", "Fonts\\ARIALN.TTF")
    end
    
    self:Debug("Registered WhiiskeyzPlater textures")
end

-- Set up CVars for WhiiskeyzPlater compatibility
function M:SetupWhiiskeyzCVars()
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
        
        -- Resource display on target
        SetCVar("nameplateResourceOnTarget", 1)
    end
    
    self:Debug("Set up WhiiskeyzPlater compatible CVars")
end