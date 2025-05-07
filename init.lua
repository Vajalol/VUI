-- VUI - Unified World of Warcraft Addon Suite
-- Author: VortexQ8
-- Version: 1.0.0

-- Get addon environment
local addonName, addonTable = ...

-- Create global VUI table with proper initialization
_G.VUI = _G.VUI or {}
local VUI = _G.VUI

-- Initialize base attributes
VUI.name = "VUI"
VUI.version = "1.0.0"
VUI.author = "VortexQ8"

-- Add a reference to the addon table for XpcAll usage
VUI.addonTable = addonTable

-- Initialize hooks and callbacks tables
VUI.hooks = {}
VUI.callbacks = {}

-- Define global library references that will be used throughout the addon
local AceDBOptions = LibStub("AceDBOptions-3.0")

-- Add module tables
-- Original modules
VUI.BuffOverlay = {}
VUI.buffoverlay = VUI.BuffOverlay  -- Alias for backward compatibility
VUI.TrufiGCD = {}
VUI.trufigcd = VUI.TrufiGCD  -- Alias for backward compatibility
VUI.moveany = {}
VUI.auctionator = {}
VUI.angrykeystone = {}
VUI.omnicc = {}
VUI.omnicd = {}
VUI.idtip = {}
VUI.premadegroupfinder = {}
VUI.detailsskin = {}
VUI.msbt = {}
VUI.spellnotifications = {}
VUI.multinotification = {}

-- Enhanced UI modules (from Phoenix UI)
VUI.bags = {}
VUI.paperdoll = {}
VUI.actionbars = {}

-- Core UI & Functionality modules
VUI.unitframes = {}
VUI.skins = {}
VUI.profiles = {}
VUI.automation = {}
VUI.visualconfig = {}
VUI.Player = {}

-- Internal module tracking
VUI.modules = {
    -- Original modules
    "buffoverlay",
    "trufigcd",
    "moveany",
    "auctionator",
    "angrykeystone",
    "omnicc",
    "omnicd",
    "idtip",
    "premadegroupfinder",
    "spellnotifications",
    "detailsskin",
    "msbt",
    "multinotification",
    
    -- Enhanced UI modules (from Phoenix UI)
    "bags",
    "paperdoll",
    "actionbars",
    
    -- Core UI & Functionality modules
    "unitframes",
    "skins",
    "profiles",
    "automation",
    "visualconfig",
    "Player"
}

-- Module status tracking
VUI.enabledModules = {}
for _, module in ipairs(VUI.modules) do
    VUI.enabledModules[module] = true
end

-- Initialize the addon
function VUI:Initialize()
    -- First, ensure we have required tables
    if type(self.modules) ~= "table" then
        self.modules = {}
    end
    
    if type(self.modulesByName) ~= "table" then
        self.modulesByName = {}
    end
    
    if type(self.enabledModules) ~= "table" then
        self.enabledModules = {}
    end
    
    -- Initialize essential subsystems
    self:Debug("Initializing database...")
    self:InitializeDB()
    
    self:Debug("Loading media assets...")
    self:LoadMedia()
    
    -- Initialize core systems
    self:Debug("Initializing atlas system...")
    if self.Atlas and self.Atlas.Initialize then
        self.Atlas:Initialize()
    end
    
    -- Initialize event optimization system
    self:Debug("Initializing event optimization...")
    if self.EventOptimization and self.EventOptimization.Initialize then
        self.EventOptimization:Initialize()
    end
    
    -- Initialize performance optimization
    self:Debug("Initializing performance optimization...")
    if self.Performance and self.Performance.Initialize then
        self.Performance:Initialize()
    end
    
    -- Create theme integration system if not already available
    if not self.ThemeIntegration then
        self:Debug("Creating theme integration system...")
        self.ThemeIntegration = self.ThemeIntegration or {}
    end
    
    -- Create font integration system if not already available
    if not self.FontIntegration then
        self:Debug("Creating font integration system...")
        self.FontIntegration = self.FontIntegration or {}
        self.FontIntegration.defaultFont = "Friz Quadrata TT"
        self.FontIntegration.defaultSize = 12
        self.FontIntegration.GetFont = function(self, fontType)
            return self.defaultFont, self.defaultSize
        end
    end
    
    -- Initialize Dynamic Module Loading system
    self:Debug("Initializing dynamic module loading...")
    if self.DynamicModuleLoading then
        -- Register core modules
        self:Debug("Registering core modules...")
        -- Each module and its category
        local coreModules = {
            buffoverlay = "core",
            trufigcd = "combat",
            moveany = "core",
            auctionator = "social",
            angrykeystone = "pve",
            omnicc = "core",
            omnicd = "combat",
            idtip = "utility",
            premadegroupfinder = "social",
            detailsskin = "combat",
            msbt = "combat",
            spellnotifications = "combat",
            multinotification = "core",
            
            -- Enhanced UI modules
            bags = "ui",
            paperdoll = "ui",
            actionbars = "ui",
            unitframes = "ui",
            skins = "ui"
        }
        
        -- Register all core modules
        for moduleName, category in pairs(coreModules) do
            if self[moduleName] then
                self.DynamicModuleLoading:RegisterModule(moduleName, category, {})
            end
        end
    end
    
    -- Initialize Module Manager after Dynamic Module Loading
    self:Debug("Initializing module manager...")
    if self.ModuleManager and self.ModuleManager.Initialize then
        self.ModuleManager:Initialize()
    end
    
    -- Initialize Theme system components
    self:Debug("Initializing theme system...")
    if self.ThemeHelpers then
        self.ThemeHelpers:UpdateCurrentTheme()
    end
    
    -- Load all modules
    self:Debug("Initializing modules...")
    self:InitializeModules()
    
    -- Create config panel
    self:Debug("Creating config panel...")
    self:CreateConfigPanel()
    
    -- Register chat commands
    self:Debug("Registering chat commands...")
    self:RegisterChatCommands()
    
    -- Initialize the Player module
    if self.Player and self.Player.OnInitialize then
        self.Player:OnInitialize()
        self.Player:RegisterEvents()
    end
    
    -- Apply current theme
    local theme = self.db.profile.appearance.theme or "thunderstorm"
    self.ThemeIntegration:ApplyTheme(theme)
    
    -- Update all theme-based UI elements
    if self.ThemeHelpers then
        self.ThemeHelpers:UpdateAllThemes()
    end
    
    -- Apply theme helpers to all modules
    if self.ModuleThemeIntegration then
        self.ModuleThemeIntegration:ApplyToAllModules()
    end
    
    -- Print minimal initialization message with essential user guidance
    self:Print("v" .. self.version .. " loaded. Type |cff1784d1/vui|r for options.")
    
    -- Mark as initialized
    self.isInitialized = true
    
    -- Initialize Final Validation system
    if self.FinalValidation and self.FinalValidation.Initialize then
        self:Debug("Initializing final validation system...")
        self.FinalValidation:Initialize()
    end
    
    -- Trigger OnInitialize callbacks if registered
    if self.OnInitialize then
        self:OnInitialize()
    end
end

-- Debug function that can be called safely even if debugging is off
function VUI:Debug(msg)
    if self.db and self.db.profile and self.db.profile.debugging then
        if msg then
            print("|cff00aaff[VUI Debug]|r " .. tostring(msg))
        end
    end
end

-- Callback system for VUI events
function VUI:RegisterCallback(event, callback)
    if not event or not callback then return end
    
    if not self.callbacks[event] then
        self.callbacks[event] = {}
    end
    
    table.insert(self.callbacks[event], callback)
    return true
end

-- Trigger callbacks for an event
function VUI:TriggerCallback(event, ...)
    if not event or not self.callbacks[event] then return end
    
    for _, callback in ipairs(self.callbacks[event]) do
        local success, err = pcall(callback, ...)
        if not success then
            self:Debug("Error in callback for " .. event .. ": " .. tostring(err))
        end
    end
end

-- Create EventManager if it doesn't exist (for theme change events etc.)
VUI.EventManager = VUI.EventManager or {}

-- Register a callback with the EventManager
function VUI.EventManager:RegisterCallback(event, callback)
    return VUI:RegisterCallback(event, callback)
end

-- Trigger an event through the EventManager
function VUI.EventManager:TriggerCallback(event, ...)
    return VUI:TriggerCallback(event, ...)
end

-- Print function to provide user feedback
function VUI:Print(msg)
    if msg then
        print("|cff00aaff[VUI]|r " .. tostring(msg))
    end
end

-- Initialize the database
function VUI:InitializeDB()
    -- If we have AceDB available, use it
    local AceDB = LibStub and LibStub("AceDB-3.0", true)
    if AceDB then
        -- Create the database with our defaults
        self.db = AceDB:New("VUIDB", self.defaults)
        
        -- Setup profile handling if AceDBOptions is available
        local AceDBOptions = LibStub and LibStub("AceDBOptions-3.0", true)
        if AceDBOptions then
            self.profileOptions = AceDBOptions:GetOptionsTable(self.db)
        end
        
        -- Register profile change callbacks
        if self.db.RegisterCallback then
            self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
            self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
            self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
        end
        
        -- Trigger database initialized callback
        self:TriggerCallback("OnDatabaseInitialized", self.db)
        
        -- Create a character database if needed
        self.charDB = AceDB:New("VUICharacterDB", {
            char = {
                -- Character-specific settings
                positions = {},
                settings = {}
            }
        })
    else
        -- No AceDB, use our simple DB
        VUIDB = VUIDB or {profile = {}}
        VUICharacterDB = VUICharacterDB or {char = {}}
        
        -- Copy defaults to DB if keys don't exist
        if self.defaults and self.defaults.profile then
            for k, v in pairs(self.defaults.profile) do
                if VUIDB.profile[k] == nil then
                    VUIDB.profile[k] = v
                end
            end
        end
        
        -- Set up a simple structure
        self.db = {
            profile = VUIDB.profile
        }
        
        self.charDB = {
            char = VUICharacterDB.char or {}
        }
        
        -- Initialize if needed
        self.db.profile.appearance = self.db.profile.appearance or {}
        self.db.profile.appearance.theme = self.db.profile.appearance.theme or "thunderstorm"
    end
    
    -- Check first run
    if self.db.profile.firstRun then
        self:PerformFirstRunSetup()
        self.db.profile.firstRun = false
    end
end

-- Perform first-time setup with comprehensive wizard
function VUI:PerformFirstRunSetup()
    -- Only run this for first-time users
    if not self.db.profile.firstRun then return end
    
    -- 1. Determine player's class and role for defaults
    local _, playerClass = UnitClass("player")
    local playerRole = self:DetectPlayerRole()
    local playerSpec = self:GetPlayerSpecialization()
    
    -- 2. Set appropriate theme based on class
    local classToTheme = {
        MAGE = "arcanemystic",
        WARLOCK = "felenergy",
        WARRIOR = "thunderstorm",
        PALADIN = "phoenixflame",
        DEATHKNIGHT = "thunderstorm",
        DRUID = "felenergy",
        HUNTER = "phoenixflame",
        PRIEST = "arcanemystic",
        ROGUE = "thunderstorm",
        SHAMAN = "thunderstorm",
        MONK = "arcanemystic",
        DEMONHUNTER = "felenergy",
        EVOKER = "phoenixflame"
    }
    
    self.db.profile.appearance.theme = classToTheme[playerClass] or "thunderstorm"
    
    -- 3. Apply role-based configuration templates
    self:ApplyRoleTemplate(playerRole, playerClass, playerSpec)
    
    -- 4. Create the Setup Wizard frame
    self:CreateSetupWizard(playerRole, playerClass)
    
    -- Mark first run as complete (will be set to false after wizard completes)
    self.db.profile.setupWizardStage = 1
end

-- Detect player's role based on specialization
function VUI:DetectPlayerRole()
    local role = "DPS" -- Default role
    
    -- Get specialization and role
    local specIndex = GetSpecialization()
    if specIndex then
        local specID, _, _, _, _, specRole = GetSpecializationInfo(specIndex)
        if specRole then
            if specRole == "TANK" then
                role = "Tank"
            elseif specRole == "HEALER" then
                role = "Healer"
            else
                -- For DPS, determine if ranged or melee
                local classToRole = {
                    MAGE = "RangedDPS",
                    WARLOCK = "RangedDPS",
                    HUNTER = "RangedDPS",
                    PRIEST = "RangedDPS",
                    WARRIOR = "MeleeDPS",
                    PALADIN = "MeleeDPS",
                    DEATHKNIGHT = "MeleeDPS",
                    ROGUE = "MeleeDPS",
                    MONK = "MeleeDPS",
                    DEMONHUNTER = "MeleeDPS",
                    SHAMAN = function(spec) return spec == 2 and "MeleeDPS" or "RangedDPS" end,
                    DRUID = function(spec) return spec == 2 and "MeleeDPS" or "RangedDPS" end,
                    EVOKER = "RangedDPS"
                }
                
                local _, playerClass = UnitClass("player")
                local roleFunc = classToRole[playerClass]
                
                if type(roleFunc) == "function" then
                    role = roleFunc(specIndex)
                elseif roleFunc then
                    role = roleFunc
                end
            end
        end
    end
    
    return role
end

-- Get player's current specialization
function VUI:GetPlayerSpecialization()
    local specIndex = GetSpecialization()
    if specIndex then
        local specID, specName = GetSpecializationInfo(specIndex)
        return {
            index = specIndex,
            id = specID,
            name = specName
        }
    end
    return nil
end

-- Apply role-based configuration template
function VUI:ApplyRoleTemplate(role, class, spec)
    -- Load base template for all roles
    local template = self:GetBaseTemplate()
    
    -- Apply role-specific settings
    if role == "Tank" then
        template = self:ApplyTankTemplate(template, class, spec)
    elseif role == "Healer" then
        template = self:ApplyHealerTemplate(template, class, spec)
    elseif role == "MeleeDPS" then
        template = self:ApplyMeleeDPSTemplate(template, class, spec)
    elseif role == "RangedDPS" then
        template = self:ApplyRangedDPSTemplate(template, class, spec)
    end
    
    -- Apply template to current profile
    self:ApplyTemplateToProfile(template)
    
    -- Store the selected role for future reference
    self.db.profile.playerRole = role
    self.db.profile.roleTemplateApplied = true
end

-- Get base template for all roles
function VUI:GetBaseTemplate()
    return {
        unitframes = {
            enabled = true,
            showPortraits = true,
            classColoredBars = true,
            frames = {
                player = { enabled = true },
                target = { enabled = true },
                targettarget = { enabled = true },
                focus = { enabled = true },
                pet = { enabled = true },
                party = { enabled = true },
                boss = { enabled = true },
                arena = { enabled = true }
            }
        },
        buffoverlay = {
            enabled = true,
            size = 32,
            spacing = 2,
            growthDirection = "UP"
        },
        castbar = {
            enabled = true,
            showIcon = true,
            showTimer = true
        },
        actionbars = {
            enabled = true,
            showHotkeys = true,
            showMacroNames = true
        },
        nameplates = {
            enabled = true,
            showClassColors = true,
            showCastBars = true
        },
        performance = {
            frameLimiter = false,
            reducedEffects = false
        }
    }
end

-- Apply Tank template customizations
function VUI:ApplyTankTemplate(template, class, spec)
    -- Enhanced unit frames with threat indicators
    template.unitframes.showTargetHighlight = true
    template.unitframes.frames.player.showThreatIndicator = true
    template.unitframes.frames.player.largerHealthBar = true
    template.unitframes.frames.player.moveHealthText = "center"
    
    -- Enhanced nameplates for threat management
    template.nameplates.showThreatIndicator = true
    template.nameplates.showAggroWarning = true
    template.nameplates.colorByThreat = true
    template.nameplates.largerScale = 1.2
    
    -- Defensive cooldown tracking
    template.buffoverlay.highlightDefensives = true
    template.trufigcd = template.trufigcd or {}
    template.trufigcd.enabled = true
    template.trufigcd.trackTaunts = true
    template.trufigcd.highlightDefensives = true
    
    -- Class-specific adjustments
    if class == "WARRIOR" or class == "PALADIN" or class == "DEATHKNIGHT" then
        template.unitframes.frames.player.showResourceBar = true
        template.unitframes.frames.player.resourceBarSize = 1.2
    end
    
    return template
end

-- Apply Healer template customizations
function VUI:ApplyHealerTemplate(template, class, spec)
    -- Enhanced party frames
    template.unitframes.frames.party.larger = true
    template.unitframes.frames.party.showResourceBars = true
    template.unitframes.frames.party.showDispellableDebuffs = true
    template.unitframes.frames.party.highlightDispellable = true
    template.unitframes.frames.party.showRaidIcons = true
    
    -- Raid frames if available
    template.unitframes.frames.raid = template.unitframes.frames.raid or {}
    template.unitframes.frames.raid.enabled = true
    template.unitframes.frames.raid.showDispellableDebuffs = true
    
    -- Enhanced buff tracking
    template.buffoverlay.trackHealingBuffs = true
    template.buffoverlay.showHealPrediction = true
    
    -- Cooldown tracking
    template.omnicd = template.omnicd or {}
    template.omnicd.enabled = true
    template.omnicd.showHealingCooldowns = true
    
    -- Extra functionality for healers
    template.msbt = template.msbt or {}
    template.msbt.enabled = true
    template.msbt.showHealingEvents = true
    
    return template
end

-- Apply Melee DPS template customizations
function VUI:ApplyMeleeDPSTemplate(template, class, spec)
    -- Enhanced actionbars for melee
    template.actionbars.showCooldownText = true
    template.actionbars.enhancedCooldowns = true
    
    -- Buff tracking focused on melee
    template.buffoverlay.trackMeleeBuffs = true
    template.buffoverlay.trackProcEffects = true
    
    -- Enhanced nameplates for melee targeting
    template.nameplates.customMeleeRange = true
    template.nameplates.highlightNameplatesInRange = true
    
    -- Enable melee-specific modules
    template.trufigcd = template.trufigcd or {}
    template.trufigcd.enabled = true
    template.trufigcd.trackMeleeAbilities = true
    
    -- Class-specific adjustments (Examples)
    if class == "ROGUE" or class == "DRUID" then
        -- Energy/Combo point tracking
        template.unitframes.showComboPoints = true
        template.unitframes.largeComboPoints = true
    elseif class == "DEATHKNIGHT" then
        -- Rune tracking
        template.unitframes.showDetailedRunes = true
    end
    
    return template
end

-- Apply Ranged DPS template customizations
function VUI:ApplyRangedDPSTemplate(template, class, spec)
    -- Enhanced UI for ranged
    template.actionbars.showCooldownText = true
    template.actionbars.enhancedCooldowns = true
    
    -- Buff tracking focused on ranged DPS
    template.buffoverlay.trackRangedBuffs = true
    template.buffoverlay.trackDotTimers = true
    template.buffoverlay.trackProcEffects = true
    
    -- Enhanced nameplates for ranged targeting
    template.nameplates.showCastInfo = true
    template.nameplates.showRaidTargetIcon = true
    
    -- Enable ranged-specific modules
    template.trufigcd = template.trufigcd or {}
    template.trufigcd.enabled = true
    template.trufigcd.trackRangedAbilities = true
    
    -- Class-specific adjustments
    if class == "MAGE" or class == "WARLOCK" then
        -- Mana/resource tracking
        template.unitframes.detailedManaBar = true
        template.unitframes.showManaPercentage = true
    elseif class == "HUNTER" then
        -- Focus tracking
        template.unitframes.enhancedFocusDisplay = true
    end
    
    return template
end

-- Apply template to current profile
function VUI:ApplyTemplateToProfile(template)
    -- This function intelligently merges the template with existing settings
    for module, settings in pairs(template) do
        if type(settings) == "table" and self.db.profile.modules[module] then
            -- Module exists, merge settings
            for key, value in pairs(settings) do
                if type(value) == "table" and type(self.db.profile.modules[module][key]) == "table" then
                    -- Recursively merge nested tables
                    self:MergeSettings(self.db.profile.modules[module][key], value)
                else
                    -- Direct value assignment
                    self.db.profile.modules[module][key] = value
                end
            end
        else
            -- Module doesn't exist or isn't a table, assign directly
            self.db.profile.modules[module] = settings
        end
    end
    
    -- Enable appropriate modules based on template
    for moduleName, settings in pairs(template) do
        if type(settings) == "table" and settings.enabled ~= nil then
            self.enabledModules[moduleName] = settings.enabled
        end
    end
end

-- Helper function to merge settings tables
function VUI:MergeSettings(target, source)
    for k, v in pairs(source) do
        if type(v) == "table" and type(target[k]) == "table" then
            self:MergeSettings(target[k], v)
        else
            target[k] = v
        end
    end
    return target
end

-- Create the setup wizard interface
function VUI:CreateSetupWizard(playerRole, playerClass)
    -- Store the wizard and configuration data
    self.setupWizard = {
        currentStep = 1,
        playerRole = playerRole,
        playerClass = playerClass,
        steps = {
            "welcome",
            "role",
            "performance",
            "UI",
            "modules",
            "complete"
        },
        choices = {
            role = playerRole,
            performanceLevel = "balanced",
            UIStyle = "modern",
            enabledModules = {}
        }
    }
    
    -- Schedule the wizard to appear after a short delay
    C_Timer.After(1, function()
        self:ShowSetupWizardStep(1)
    end)
end

-- Show a specific step of the setup wizard
function VUI:ShowSetupWizardStep(step)
    -- This will be called by the frame when navigation happens
    -- Implementation uses existing UI components in the addon
    
    -- Store the current step
    self.setupWizard.currentStep = step
    
    -- When wizard completes (step > number of steps)
    if step > #self.setupWizard.steps then
        self:CompleteSetupWizard()
        return
    end
    
    -- Otherwise display current step
    local stepName = self.setupWizard.steps[step]
    self:DisplayWizardStep(stepName)
end

-- Display a particular wizard step
function VUI:DisplayWizardStep(stepName)
    -- This would create the actual UI for each step
    -- Implementation would use the VUI.ConfigUI system already in place
    
    if self.ConfigUI and self.ConfigUI.ShowWizardStep then
        self.ConfigUI:ShowWizardStep(stepName, self.setupWizard)
    else
        -- Wizard can't be displayed yet, perhaps config UI isn't loaded
        -- Mark that wizard should be shown when possible
        self.db.profile.showWizardOnUILoad = true
    end
end

-- Complete the setup wizard
function VUI:CompleteSetupWizard()
    -- Apply final configuration based on wizard choices
    self:ApplyWizardChoices(self.setupWizard.choices)
    
    -- Mark setup as complete
    self.db.profile.firstRun = false
    self.db.profile.setupWizardStage = nil
    self.db.profile.setupComplete = true
    self.db.profile.setupCompletedDate = time()
    
    -- Show completion message
    self:Print("Setup complete! Type /vui to access settings anytime.")
    
    -- Reload UI if needed
    if self.setupWizard.choices.reloadUI then
        C_Timer.After(2, ReloadUI)
    end
end

-- Apply all wizard choices to the profile
function VUI:ApplyWizardChoices(choices)
    -- 1. Apply role template again if it was changed
    if choices.role ~= self.db.profile.playerRole then
        self:ApplyRoleTemplate(choices.role, self.setupWizard.playerClass)
    end
    
    -- 2. Apply performance settings
    self:ApplyPerformanceSettings(choices.performanceLevel)
    
    -- 3. Apply UI style settings
    self:ApplyUIStyleSettings(choices.UIStyle)
    
    -- 4. Enable/disable modules based on choices
    for module, enabled in pairs(choices.enabledModules) do
        self.enabledModules[module] = enabled
        if self.db.profile.modules[module] then
            self.db.profile.modules[module].enabled = enabled
        end
    end
end

-- Apply performance settings based on wizard choice
function VUI:ApplyPerformanceSettings(performanceLevel)
    local settings = self.db.profile
    
    if performanceLevel == "maximum" then
        -- Maximum quality settings
        settings.performance = {
            frameLimiter = false,
            highQualityTextures = true,
            enhancedAnimations = true,
            advancedEffects = true,
            detailedTooltips = true
        }
    elseif performanceLevel == "balanced" then
        -- Balanced settings
        settings.performance = {
            frameLimiter = true,
            highQualityTextures = true,
            enhancedAnimations = true,
            advancedEffects = false,
            detailedTooltips = true
        }
    elseif performanceLevel == "minimal" then
        -- Performance-focused settings
        settings.performance = {
            frameLimiter = true,
            highQualityTextures = false,
            enhancedAnimations = false,
            advancedEffects = false,
            detailedTooltips = false
        }
    end
    
    -- Apply these settings to relevant systems
    if self.FrameRateThrottling then
        self.FrameRateThrottling.config.enabled = settings.performance.frameLimiter
    end
    
    if self.CombatPerformance then
        self.CombatPerformance.config.reduceLODInCombat = not settings.performance.advancedEffects
        self.CombatPerformance.config.disableAnimationsInCombat = not settings.performance.enhancedAnimations
    end
end

-- Apply UI style settings
function VUI:ApplyUIStyleSettings(uiStyle)
    -- Set the style preference in all UI modules
    local modules = {"unitframes", "actionbars", "nameplates", "castbar"}
    
    for _, module in ipairs(modules) do
        if self.db.profile.modules[module] then
            self.db.profile.modules[module].style = uiStyle
        end
    end
    
    -- Apply the change immediately if modules are loaded
    for _, module in ipairs(modules) do
        if self[module] and self[module].ApplyStyle then
            self[module]:ApplyStyle()
        end
    end
end

-- Handler for refresh after profile changes
function VUI:RefreshConfig()
    -- Reload all modules with new settings
    if self.ThemeIntegration then
        local theme = self.db.profile.appearance.theme or "thunderstorm"
        self.ThemeIntegration:ApplyTheme(theme)
    end
    
    -- Update theme helpers
    if self.ThemeHelpers then
        self.ThemeHelpers:UpdateAllThemes()
    end
    
    -- Reload configuration panel
    if self.ConfigUI and self.ConfigUI.Refresh then
        self.ConfigUI:Refresh()
    end
    
    -- Notify user
    self:Print("Profile changed. Settings updated.")
end

-- Create config panel - placeholder until config.lua loads
function VUI:CreateConfigPanel()
    if not self.OpenConfigPanel then
        self.OpenConfigPanel = function(self)
            if self.ConfigUI and self.ConfigUI.Open then
                self.ConfigUI:Open()
            else
                self:Print("Configuration UI not loaded yet.")
            end
        end
    end
end

-- Framework for hooking into WoW events
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and ... == "VUI" then
        -- Addon loaded, initialize basics
        VUI:PreInitialize()
    elseif event == "PLAYER_LOGIN" then
        -- Player logged in, load the full addon
        VUI:Initialize()
    end
end)

-- Pre-initialize function
function VUI:PreInitialize()
    -- Any setup that needs to happen before player login
    self:LoadDefaults()
    
    -- Initialize a basic db structure if it doesn't exist yet
    -- This will be replaced by the proper AceDB initialization later
    if not self.db then
        self.db = {
            profile = {
                modules = {},
                appearance = {
                    theme = "thunderstorm"
                },
                debugging = false
            }
        }
    end
end

-- NewModule function (AceAddon compatibility)
function VUI:NewModule(name, ...)
    if not name then
        error("Usage: NewModule(name[, prototype, ...]): 'name' - module name is required")
        return nil
    end
    
    -- Create the module
    local module = {}
    
    -- Copy prototype methods (embedded libraries from AceAddon like AceEvent-3.0)
    local libCount = select("#", ...)
    if libCount > 0 then
        -- Process each library prototype
        for i = 1, libCount do
            local lib = select(i, ...)
            if type(lib) == "string" then
                -- This is a library that needs to be embedded (AceEvent-3.0, etc.)
                if LibStub then
                    local prototype = LibStub(lib, true)
                    if prototype and prototype.Embed then
                        prototype:Embed(module)
                    else
                        VUI:Debug("Library " .. lib .. " not found or missing Embed method")
                    end
                end
            elseif type(lib) == "table" then
                -- This is a table of methods to be copied
                for k, v in pairs(lib) do
                    module[k] = v
                end
            end
        end
    end
    
    -- Set basic properties
    module.name = name
    
    -- Initialize module database
    if VUI.ModuleAPI and VUI.ModuleAPI.CreateModuleSettings then
        module.db = VUI.ModuleAPI:CreateModuleSettings(name, {})
    elseif VUI.db and VUI.db.profile and VUI.db.profile.modules then
        -- Fallback if ModuleAPI isn't initialized yet
        if not VUI.db.profile.modules[name] then
            VUI.db.profile.modules[name] = {}
        end
        module.db = VUI.db.profile.modules[name]
    end
    
    -- Store the module in the VUI namespace
    VUI[name] = module
    
    -- Register the module with ModuleAPI if available
    if VUI.ModuleAPI and VUI.ModuleAPI.RegisterModule then
        VUI.ModuleAPI:RegisterModule(name, module)
    end
    
    return module
end

-- Load default settings - this function is referenced but was missing
function VUI:LoadDefaults()
    -- Default settings for the addon
    self.defaults = {
        profile = {
            modules = {},
            appearance = {
                theme = "thunderstorm",
                fonts = {
                    global = "Friz Quadrata TT",
                    size = 12
                },
                colors = {
                    custom = false,
                    main = {0.4, 0.4, 0.95, 1},
                    highlight = {0.6, 0.6, 1, 1}
                }
            },
            debugging = false,
            firstRun = true,
            showTutorials = true
        }
    }
    
    -- Default enabled modules
    for _, module in ipairs(self.modules) do
        self.defaults.profile.modules[module] = true
    end
    
    -- Theme-specific defaults
    self.themeDefaults = {
        thunderstorm = {
            background = {0.05, 0.05, 0.2, 0.9},
            border = {0.1, 0.4, 0.9, 1},
            highlight = {0.2, 0.5, 1, 1},
            text = {0.9, 0.9, 1, 1}
        },
        phoenixflame = {
            background = {0.15, 0.05, 0.02, 0.9},
            border = {0.9, 0.3, 0.1, 1},
            highlight = {1, 0.5, 0.2, 1},
            text = {1, 0.9, 0.8, 1}
        },
        arcanemystic = {
            background = {0.1, 0.05, 0.15, 0.9},
            border = {0.7, 0.1, 0.9, 1},
            highlight = {0.9, 0.4, 1, 1},
            text = {0.95, 0.85, 1, 1}
        },
        felenergy = {
            background = {0.05, 0.1, 0.05, 0.9},
            border = {0.1, 0.8, 0.1, 1},
            highlight = {0.4, 1, 0.4, 1},
            text = {0.8, 1, 0.8, 1}
        },
        classcolor = {
            -- Will be set dynamically based on player class
            background = {0.1, 0.1, 0.1, 0.9},
            border = {0.5, 0.5, 0.5, 1},
            highlight = {0.7, 0.7, 0.7, 1},
            text = {0.9, 0.9, 0.9, 1}
        }
    }
    
    -- Create a comprehensive startup error prevention system
    self.ErrorPrevention = {
        initialized = false,
        errorCount = 0,
        maxErrors = 50,
        errors = {},
        recoveryAttempts = {},
        criticalPaths = {
            "VUI.db",
            "VUI.modules",
            "VUI.ThemeIntegration",
            "VUI.ModuleAPI",
            "VUI.EventManager"
        },
        protectedMethods = {},
        backupData = {}
    }
    
    -- Initialize the error prevention system
    function self.ErrorPrevention:Initialize()
        if self.initialized then return end
        
        -- Create a recovery frame for deferred operations
        self.recoveryFrame = CreateFrame("Frame")
        self.recoveryFrame:Hide()
        
        -- Register for addon loading to perform verification
        self.recoveryFrame:RegisterEvent("ADDON_LOADED")
        self.recoveryFrame:SetScript("OnEvent", function(_, event, addonName)
            if addonName == "VUI" then
                self:VerifyCriticalPaths()
            end
        end)
        
        -- Set up a timer for retrying failed operations
        self.recoveryFrame:SetScript("OnUpdate", function(_, elapsed)
            self:ProcessRecoveryQueue(elapsed)
        end)
        
        -- Mark as initialized
        self.initialized = true
    end
    
    -- Verify that all critical paths exist and create fallbacks if needed
    function self.ErrorPrevention:VerifyCriticalPaths()
        for _, path in ipairs(self.criticalPaths) do
            local current = _G
            local valid = true
            
            -- Split path into components
            for segment in path:gmatch("[^%.]+") do
                if current[segment] == nil then
                    valid = false
                    -- Create empty table as fallback
                    current[segment] = {}
                    -- Log the issue
                    self:LogError("Created fallback for missing path: " .. path)
                end
                current = current[segment]
            end
        end
    end
    
    -- Process recovery queue for any deferred operations
    function self.ErrorPrevention:ProcessRecoveryQueue(elapsed)
        for moduleName, attempts in pairs(self.recoveryAttempts) do
            if attempts.delay then
                attempts.delay = attempts.delay - elapsed
                if attempts.delay <= 0 then
                    attempts.delay = nil
                    -- Attempt recovery
                    if attempts.count < 3 and type(attempts.func) == "function" then
                        attempts.count = attempts.count + 1
                        local success, errorMsg = pcall(attempts.func)
                        if success then
                            -- Recovery succeeded, remove from queue
                            self.recoveryAttempts[moduleName] = nil
                        else
                            -- Failed again, log and delay further
                            self:LogError("Recovery attempt failed for " .. moduleName .. ": " .. tostring(errorMsg))
                            attempts.delay = 1 * attempts.count -- Increasing delay for each attempt
                        end
                    else
                        -- Too many attempts, give up
                        self:LogError("Giving up recovery for " .. moduleName .. " after multiple attempts")
                        self.recoveryAttempts[moduleName] = nil
                    end
                end
            end
        end
    end
    
    -- Log an error for tracking
    function self.ErrorPrevention:LogError(errorMsg)
        -- Prevent too many errors
        if self.errorCount >= self.maxErrors then return end
        
        -- Add error info
        table.insert(self.errors, {
            message = errorMsg,
            time = GetTime(),
            trace = debugstack(3)
        })
        
        self.errorCount = self.errorCount + 1
        
        -- Log to VUI debug if available
        if VUI and VUI.Debug then
            VUI:Debug("ERROR: " .. errorMsg)
        end
    end
    
    -- Create a safe wrapper for a method that might fail
    function self.ErrorPrevention:ProtectMethod(objectPath, methodName, fallbackFunc)
        -- Find the object and method
        local current = _G
        local pathParts = {}
        
        -- Split the path
        for segment in objectPath:gmatch("[^%.]+") do
            table.insert(pathParts, segment)
            if current[segment] == nil then
                self:LogError("Cannot protect method - path not found: " .. objectPath)
                return false
            end
            current = current[segment]
        end
        
        -- If the method doesn't exist, we can't wrap it
        if type(current[methodName]) ~= "function" then
            if type(fallbackFunc) == "function" then
                -- Create the method using the fallback
                current[methodName] = fallbackFunc
                self:LogError("Created missing method " .. objectPath .. "." .. methodName .. " using fallback")
                return true
            else
                self:LogError("Cannot protect method - not a function: " .. objectPath .. "." .. methodName)
                return false
            end
        end
        
        -- Save original method
        local originalMethod = current[methodName]
        
        -- Create a protected version
        current[methodName] = function(...)
            local success, result = pcall(originalMethod, ...)
            if success then
                return result
            else
                self:LogError("Protected method failed: " .. objectPath .. "." .. methodName .. " - " .. tostring(result))
                
                -- Use fallback if provided
                if type(fallbackFunc) == "function" then
                    local fbSuccess, fbResult = pcall(fallbackFunc, ...)
                    if fbSuccess then
                        return fbResult
                    end
                end
                
                -- Return nil if both original and fallback failed
                return nil
            end
        end
        
        -- Store in protected methods
        local key = objectPath .. "." .. methodName
        self.protectedMethods[key] = {
            object = current,
            method = methodName,
            original = originalMethod
        }
        
        return true
    end
    
    -- Schedule a recovery attempt for a module
    function self.ErrorPrevention:ScheduleRecovery(moduleName, recoveryFunc)
        if not self.recoveryAttempts[moduleName] then
            self.recoveryAttempts[moduleName] = {
                count = 0,
                func = recoveryFunc,
                delay = 0.5 -- Initial delay
            }
        end
    end
    
    -- Create a backup of important data
    function self.ErrorPrevention:BackupData(category, data)
        self.backupData[category] = CopyTable(data)
    end
    
    -- Restore from backup
    function self.ErrorPrevention:RestoreData(category)
        if self.backupData[category] then
            return CopyTable(self.backupData[category])
        end
        return nil
    end
    
    -- Initialize the error prevention system immediately
    self.ErrorPrevention:Initialize()
    
    -- Add a safe method for addon initialization errors
    self.safeInitFrames = {}
end

-- Load media files
function VUI:LoadMedia()
    -- Register media files with LibSharedMedia if available
    local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
    if not LSM then return end
    
    -- Register our custom icons
    LSM:Register("statusbar", "VUI Vortex", [[Interface\AddOns\VUI\media\icons\vui_icon.tga]])
    
    -- Additional media will be loaded through media/RegisterMediaLSM.lua
end

-- Register chat commands
function VUI:RegisterChatCommands()
    SLASH_VUI1 = "/vui"
    SlashCmdList["VUI"] = function(msg)
        VUI:ToggleConfig()
    end
end

-- Toggle config panel
function VUI:ToggleConfig()
    -- Will be implemented in config.lua
    if self.configFrame and self.configFrame:IsShown() then
        self.configFrame:Hide()
    else
        self:OpenConfigPanel()
    end
end

-- Get module by name
function VUI:GetModule(name, silent)
    -- Simple module lookup
    if not name then return nil end
    
    -- Try exact match
    if self[name] and type(self[name]) == "table" then
        return self[name]
    end
    
    -- Try case-insensitive match
    local lowerName = name:lower()
    for moduleName, module in pairs(self) do
        if type(module) == "table" and type(moduleName) == "string" and moduleName:lower() == lowerName then
            return module
        end
    end
    
    -- Not found
    if not silent then
        self:Debug("Module not found: " .. tostring(name))
    end
    
    return nil
end

-- Register a module with the system
function VUI:RegisterModule(name, module)
    if not name or not module then
        return false
    end
    
    -- Ensure we have module tracking tables initialized
    if type(self.modules) ~= "table" then
        self.modules = {}
    end
    
    if type(self.modulesByName) ~= "table" then
        self.modulesByName = {}
    end
    
    if type(self.enabledModules) ~= "table" then
        self.enabledModules = {}
    end
    
    -- Normalize the module name to lowercase for consistency
    local lowerName = tostring(name):lower()
    
    -- Add to modules if not already added
    if not self.modulesByName[lowerName] then
        table.insert(self.modules, lowerName)
        self.modulesByName[lowerName] = module  -- Store actual module reference
    else
        -- Update existing module reference
        self.modulesByName[lowerName] = module
    end
    
    -- Store or update module object in the addon namespace
    self[lowerName] = module
    
    -- Set enabled state if not already set
    if self.enabledModules[lowerName] == nil then
        self.enabledModules[lowerName] = true
    end
    
    -- Add some standard functions to module if they don't exist
    if type(module) == "table" then
        -- Add debug function
        if not module.Debug then
            module.Debug = function(self, msg)
                if VUI.db and VUI.db.profile and VUI.db.profile.debugging then
                    VUI:Debug((lowerName or "Unknown") .. ": " .. tostring(msg))
                end
            end
        end
        
        -- Add print function
        if not module.Print then
            module.Print = function(self, msg)
                VUI:Print((lowerName or "Unknown") .. ": " .. tostring(msg))
            end
        end
        
        -- Store module name in the module itself for reference
        module.moduleName = lowerName
    end
    
    -- Log the registration
    self:Debug("Registered module: " .. lowerName)
    
    -- Trigger callback for other systems to respond
    self:TriggerCallback("MODULE_REGISTERED", lowerName, module)
    
    return true
end

-- Initialize all modules
function VUI:InitializeModules()
    if not self.modules or type(self.modules) ~= "table" then
        self:Debug("No modules table found during initialization")
        self.modules = {}
        return
    end
    
    -- Activate error prevention system
    if self.ErrorPrevention then
        self:Debug("Activating startup error prevention system...")
        
        -- Protect critical initialization methods
        self.ErrorPrevention:ProtectMethod("VUI", "Debug", function(self, msg)
            -- Silent fallback for debug method
        end)
        
        self.ErrorPrevention:ProtectMethod("VUI", "RegisterModule", function(self, name, module)
            -- Emergency fallback for module registration
            if not name or not module then return false end
            if not self.modules then self.modules = {} end
            if not self.modulesByName then self.modulesByName = {} end
            if not self.enabledModules then self.enabledModules = {} end
            
            local lowerName = tostring(name):lower()
            self.modulesByName[lowerName] = module
            self[lowerName] = module
            self.enabledModules[lowerName] = true
            
            return true
        end)
        
        self.ErrorPrevention:ProtectMethod("VUI", "GetModule", function(self, name, silent)
            -- Fallback to direct table access
            if not name then return nil end
            return self[name] or self[name:lower()]
        end)
        
        -- Back up important data structures before initialization
        self.ErrorPrevention:BackupData("modules", self.modules)
        self.ErrorPrevention:BackupData("enabledModules", self.enabledModules)
        
        -- Set up recovery paths for circular dependencies
        self.ErrorPrevention:VerifyCriticalPaths()
    end
    
    -- Performance timing
    local startTime = debugprofilestop()
    
    -- Phase 1: Register all modules with the ModuleAPI system
    self:Debug("Phase 1: Registering all modules...")
    
    -- Use enhanced ModuleAPI if available
    if self.ModuleAPI and type(self.ModuleAPI.RegisterModule) == "function" then
        self:Debug("Using enhanced ModuleAPI for module registration")
        
        for _, moduleName in ipairs(self.modules) do
            local module = self[moduleName]
            if not module then
                self:Debug("Module not found during initialization: " .. tostring(moduleName))
                goto continue
            end
            
            -- Determine module type based on name/category
            local moduleType = "addon"  -- Default
            if moduleName:match("unit") then
                moduleType = "unitframes"
            elseif moduleName:match("action") then
                moduleType = "actionbars"
            elseif moduleName == "buffoverlay" or moduleName == "trufigcd" or moduleName == "omnicd" then
                moduleType = "combat"
            elseif moduleName == "moveany" or moduleName == "visualconfig" then
                moduleType = "utility"
            elseif moduleName == "auctionator" or moduleName == "premadegroupfinder" then
                moduleType = "social"
            end
            
            -- Determine version
            local version = module.version or "1.0.0"
            
            -- Register with ModuleAPI
            self:Debug("Registering module with ModuleAPI: " .. tostring(moduleName))
            self.ModuleAPI:RegisterModule(moduleName, module, moduleType, version)
            
            -- Register module defaults if needed
            if module.defaults and self.ModuleAPI.RegisterDefaults then
                self.ModuleAPI:RegisterDefaults(moduleName, module.defaults)
            end
            
            -- Register module dependencies if needed
            if module.dependencies and self.ModuleAPI.RegisterDependencies then
                self.ModuleAPI:RegisterDependencies(moduleName, module.dependencies)
            end
            
            ::continue::
        end
        
        -- Use ModuleAPI to initialize all modules in proper dependency order
        self:Debug("Phase 2: Initializing modules through ModuleAPI...")
        
        -- If ModuleAPI has its own initialization function, use it
        if self.ModuleAPI.InitializeAllModules then
            self.ModuleAPI:InitializeAllModules()
        end
    else
        -- Fall back to classic initialization if ModuleAPI is not available
        self:Debug("Using classic initialization (ModuleAPI not available)")
        
        -- Track modules we've already processed to avoid duplicates
        local processed = {}
        
        -- Phase 1: Register all modules
        for _, moduleName in ipairs(self.modules) do
            if processed[moduleName] then
                self:Debug("Skipping duplicate module: " .. tostring(moduleName))
                goto continue_classic
            end
            
            local module = self[moduleName]
            if not module then
                self:Debug("Module not found during initialization: " .. tostring(moduleName))
                goto continue_classic
            end
            
            -- Mark as processed
            processed[moduleName] = true
            
            -- Register the module with the Module Manager if available
            if self.ModuleManager and type(self.ModuleManager.RegisterModule) == "function" then
                self:Debug("Registering with ModuleManager: " .. tostring(moduleName))
                self.ModuleManager:RegisterModule(moduleName, module)
            end
            
            ::continue_classic::
        end
        
        -- Phase 2: Initialize modules in dependency order
        self:Debug("Phase 2: Initializing modules in dependency order...")
        -- Reset processed tracking
        processed = {}
        
        -- Helper function to initialize a module and its dependencies
        local function initModuleWithDependencies(moduleName)
            -- Skip if already processed
            if processed[moduleName] then return true end
            
            local module = self[moduleName]
            if not module then
                self:Debug("Module not found in dependency chain: " .. tostring(moduleName))
                return false
            end
            
            -- Process dependencies first
            if module.dependencies and type(module.dependencies) == "table" then
                for _, depName in ipairs(module.dependencies) do
                    if not processed[depName] then
                        local success = initModuleWithDependencies(depName)
                        if not success then
                            self:Debug("Failed to initialize dependency " .. tostring(depName) .. " for " .. tostring(moduleName))
                        end
                    end
                end
            end
            
            -- Now initialize this module
            if self.enabledModules[moduleName] then
                -- Apply performance optimizations if available
                if self.Performance and type(self.Performance.OptimizeModule) == "function" then
                    self:Debug("Applying performance optimizations to: " .. tostring(moduleName))
                    module = self.Performance:OptimizeModule(module)
                    self[moduleName] = module  -- Update reference with optimized version
                end
                
                -- Call the module's own initialization if it has one
                if type(module.Initialize) == "function" then
                    self:Debug("Initializing module: " .. tostring(moduleName))
                    local success, err = pcall(module.Initialize, module)
                    if not success then
                        self:Debug("Error initializing module " .. tostring(moduleName) .. ": " .. tostring(err))
                        
                        -- Add recovery attempt through error prevention system
                        if self.ErrorPrevention then
                            self:Debug("Scheduling recovery for module: " .. tostring(moduleName))
                            self.ErrorPrevention:ScheduleRecovery(moduleName, function()
                                if type(module.Initialize) == "function" then
                                    return module:Initialize()
                                end
                                return true
                            end)
                        end
                        
                        return false
                    end
                elseif type(module.OnInitialize) == "function" then
                    self:Debug("OnInitializing module: " .. tostring(moduleName))
                    local success, err = pcall(module.OnInitialize, module)
                    if not success then
                        self:Debug("Error in OnInitialize for module " .. tostring(moduleName) .. ": " .. tostring(err))
                        return false
                    end
                end
                
                -- Apply theme if theme integration exists
                if self.ThemeIntegration and module.ApplyTheme then
                    local theme = self.db.profile.appearance.theme or "thunderstorm"
                    self:Debug("Applying theme " .. tostring(theme) .. " to module: " .. tostring(moduleName))
                    module:ApplyTheme(theme)
                end
            else
                self:Debug("Skipping disabled module: " .. tostring(moduleName))
            end
            
            -- Mark as processed
            processed[moduleName] = true
            return true
        end
        
        -- Initialize all modules with their dependencies
        for _, moduleName in ipairs(self.modules) do
            if not processed[moduleName] then
                initModuleWithDependencies(moduleName)
            end
        end
        
        -- Phase 3: Post-initialization hooks
        self:Debug("Phase 3: Running post-initialization hooks...")
        for moduleName, module in pairs(processed) do
            if module and type(module.PostInitialize) == "function" and self.enabledModules[moduleName] then
                self:Debug("Running post-initialization for: " .. tostring(moduleName))
                local success, err = pcall(module.PostInitialize, module)
                if not success then
                    self:Debug("Error in PostInitialize for module " .. tostring(moduleName) .. ": " .. tostring(err))
                end
            end
        end
    end
    
    -- Phase 4: Apply additional optimizations (regardless of which init path was used)
    self:Debug("Phase 4: Applying additional optimizations...")
    
    -- Dynamic Module Loading system integration
    if self.DynamicModuleLoading and self.DynamicModuleLoading.LoadModules then
        self:Debug("Loading modules through Dynamic Module Loading system...")
        self.DynamicModuleLoading:LoadModules()
    end
    
    -- Apply theme using ThemeIntegration if available
    if self.ThemeIntegration and self.ThemeIntegration.ApplyTheme then
        local theme = self.db.profile.appearance.theme or "thunderstorm"
        self:Debug("Applying theme to all modules: " .. theme)
        self.ThemeIntegration:ApplyTheme(theme)
    end
    
    -- Apply performance optimizations to specific high-frequency UI modules
    if self.Performance and type(self.Performance.Throttle) == "function" then
        self:Debug("Applying throttling to high-performance UI elements...")
        
        -- Bags module
        if self.bags and self.bags.UpdateAllBags then
            self.bags.UpdateAllBags = self.Performance:Throttle(self.bags.UpdateAllBags, 0.2, true)
        end
        
        -- Action bars module
        if self.actionbars and self.actionbars.UpdateCooldownText then
            self.actionbars.UpdateCooldownText = self.Performance:Throttle(self.actionbars.UpdateCooldownText, 0.05, false)
        end
        
        -- Paperdoll module
        if self.paperdoll and self.paperdoll.UpdateCharacterFrame then
            self.paperdoll.UpdateCharacterFrame = self.Performance:Throttle(self.paperdoll.UpdateCharacterFrame, 0.1, true)
        end
    end
    
    -- Trigger post-initialization callback
    self:TriggerCallback("OnModulesInitialized")
    
    -- Log performance timing if in debug mode
    local totalTime = debugprofilestop() - startTime
    self:Debug(string.format("Module initialization completed in %.2fms", totalTime))
end
