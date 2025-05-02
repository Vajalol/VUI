-------------------------------------------------------------------------------
-- Title: Mik's Scrolling Battle Text VUI Integration
-- Author: VortexQ8 (Original by Mikord)
-------------------------------------------------------------------------------

local addonName, VUI = ...

-- Create the module
local MSBT = {}
MSBT.name = "MSBT"
MSBT.version = "5.8.1"
MSBT.displayName = "Scrolling Battle Text"
MSBT.description = "Displays combat information as animated text around your character."
MSBT.author = "VortexQ8 (Original by Mikord)"
MSBT.category = "Combat"

-- Make MSBT available in VUI.modules
VUI.modules.MSBT = MSBT

-- Save original MikSBT namespace reference for compatibility
local originalMikSBT = _G["MikSBT"]
if not originalMikSBT then
    _G["MikSBT"] = {}
    originalMikSBT = _G["MikSBT"]
end

-- Initialize MSBT - This gets called by the VUI core when the module is loaded
function MSBT:Initialize()
    -- Load the main MSBT module (equivalent of MikSBT.lua)
    self:LoadCore()
    
    -- Initialize theme integration
    if self.ThemeIntegration then
        self.ThemeIntegration:Initialize()
        self.ThemeIntegration:RegisterDefaultScrollAreas()
    end
    
    -- Initialization message disabled in production release
end

-- Create a load function to properly initialize the original MSBT core
function MSBT:LoadCore()
    -- Create the core namespace
    MikSBT = originalMikSBT
    
    -- Set version information from TOC
    MikSBT.VERSION = 5.8
    MikSBT.VERSION_STRING = "v" .. self.version
    MikSBT.COMMAND = "/msbt"
    
    -- Import utility functions
    self:ImportUtilityFunctions()
    
    -- Load MSBT files in the correct order
    self:LoadLocalization()
    self:LoadProfiles()
    self:LoadParser()
    self:LoadMedia()
    self:LoadAnimations()
    self:LoadTriggers()
    self:LoadCooldowns()
    self:LoadLoot()
    self:LoadMain()
    self:LoadAnimationStyles()
    self:LoadThemeIntegration()
    
    -- Initialize the core modules
    if MikSBT.Profiles.IsInitialized and MikSBT.Profiles:IsInitialized() and MikSBT.Main and MikSBT.Main.Init then
        MikSBT.Main:Init()
    end
end

-- Import necessary utility functions for MSBT
function MSBT:ImportUtilityFunctions()
    -- Add utility functions
    MikSBT.EraseTable = function(t)
        for k in pairs(t) do
            t[k] = nil
        end
        return t
    end
    
    MikSBT.GetSkillName = function(spellId)
        return GetSpellInfo(spellId) or tostring(spellId)
    end
    
    MikSBT.ShortenNumber = function(number)
        if number >= 1000000 then
            return string.format("%.1fm", number / 1000000)
        elseif number >= 1000 then
            return string.format("%.1fk", number / 1000)
        end
        return tostring(number)
    end
end

-- Load localization files
function MSBT:LoadLocalization()
    -- Set up translations table
    MikSBT.translations = {}
    local L = MikSBT.translations
    
    -- Load the default English localization first
    local path = "Interface\\AddOns\\VUI\\modules\\msbt\\Localization\\localization.lua"
    local success, result = pcall(dofile, path)
    if not success then
        LoadAddOn("localization.lua")
    end
    
    -- Load localized file based on client locale
    local locale = GetLocale()
    if locale ~= "enUS" and locale ~= "enGB" then
        path = "Interface\\AddOns\\VUI\\modules\\msbt\\Localization\\localization." .. locale .. ".lua"
        success, result = pcall(dofile, path)
        if not success then
            LoadAddOn("localization." .. locale .. ".lua")
        end
    end
end

-- Load the additional MSBT modules in sequence
function MSBT:LoadProfiles()
    LoadAddOn("MSBTProfiles.lua")
end

function MSBT:LoadParser()
    LoadAddOn("MSBTParser.lua")
end

function MSBT:LoadMedia()
    LoadAddOn("MSBTMedia.lua")
end

function MSBT:LoadAnimations()
    LoadAddOn("MSBTAnimations.lua")
end

function MSBT:LoadTriggers()
    LoadAddOn("MSBTTriggers.lua")
end

function MSBT:LoadCooldowns()
    LoadAddOn("MSBTCooldowns.lua")
end

function MSBT:LoadLoot()
    LoadAddOn("MSBTLoot.lua")
end

function MSBT:LoadMain()
    LoadAddOn("MSBTMain.lua")
end

function MSBT:LoadAnimationStyles()
    LoadAddOn("MSBTAnimationStyles.lua")
end

function MSBT:LoadThemeIntegration()
    -- Load the VUI theme integration module
    local path = "Interface\\AddOns\\VUI\\modules\\msbt\\ThemeIntegration.lua"
    local success, result = pcall(dofile, path)
    if not success then
        LoadAddOn("ThemeIntegration.lua")
    end
end

-- Configuration getter for the options panel
function MSBT:GetConfig()
    -- Create a callback to show our themed config panel
    local openConfigPanel = function()
        if not self.configPanel then
            -- Create the themed config panel if it doesn't exist yet
            if self.ThemeIntegration and self.ThemeIntegration.CreateConfigPanel then
                self.configPanel = self.ThemeIntegration:CreateConfigPanel()
            end
        end
        
        -- Show the config panel if it exists
        if self.configPanel then
            self.configPanel:Show()
        else
            -- Fallback to simple AceConfig dialog if themed panel creation failed
            if not MikSBT or not MikSBT.Main or not MikSBT.Main.isInitialized then
                VUI:Print("MSBT needs to be enabled first.")
                return
            end
            
            -- Show original MSBT config
            self:ToggleOriginalConfig()
        end
    end

    -- Options table for VUI integration (used in the main VUI config panel)
    local options = {
        type = "group",
        name = self.displayName,
        desc = self.description,
        args = {
            header = {
                type = "header",
                name = self.displayName .. " " .. self.version,
                order = 1
            },
            desc = {
                type = "description",
                name = "Displays fight information such as damage, healing, and other useful information as animated text near your character.",
                order = 2
            },
            preview = {
                type = "execute",
                name = "",
                desc = "Preview of the Scrolling Battle Text module",
                image = "Interface\\AddOns\\VUI\\media\\textures\\config\\msbt_preview.svg",
                imageWidth = 240,
                imageHeight = 120,
                func = function() end,
                order = 3
            },
            enabled = {
                type = "toggle",
                name = "Enable " .. self.displayName,
                desc = "Enable or disable the Scrolling Battle Text module",
                get = function() return VUI.db.profile.modules.msbt.enabled end,
                set = function(_, val)
                    VUI.db.profile.modules.msbt.enabled = val
                    if val then
                        if not MikSBT.Main then
                            MSBT:Initialize()
                        end
                        if MikSBT.Main and MikSBT.Main.EnableMSBT then
                            MikSBT.Main:EnableMSBT()
                        end
                    else
                        if MikSBT.Main and MikSBT.Main.DisableMSBT then
                            MikSBT.Main:DisableMSBT()
                        end
                    end
                end,
                width = "full",
                order = 4
            },
            configBtn = {
                type = "execute",
                name = "Open MSBT Configuration",
                desc = "Open the VUI-styled MikScrollingBattleText configuration panel",
                func = openConfigPanel,
                width = "full",
                order = 5
            },
            themeHeader = {
                type = "header",
                name = "Theme Integration",
                order = 10
            },
            themeIntegration = {
                type = "toggle",
                name = "Use VUI Theme Colors",
                desc = "Apply the current VUI theme colors to the scrolling text",
                get = function() return VUI.db.profile.modules.msbt.useVUITheme end,
                set = function(_, val)
                    VUI.db.profile.modules.msbt.useVUITheme = val
                    
                    -- Update the settings
                    VUI.db.profile.modules.msbt.useVUITheme = val
                    
                    -- Apply to all scroll areas
                    if MikSBT and MikSBT.Profiles and MikSBT.Profiles.currentProfile then
                        for _, scrollArea in pairs(MikSBT.Profiles.currentProfile.scrollAreas) do
                            scrollArea.useVUITheme = val
                        end
                        
                        -- Apply the theme
                        if MSBT.ThemeIntegration then
                            MSBT.ThemeIntegration:ApplyTheme(VUI.db.profile.appearance.theme or "thunderstorm")
                        end
                    end
                end,
                width = "full",
                order = 11
            },
            themeColoredText = {
                type = "toggle",
                name = "Theme-Colored Text",
                desc = "Color damage and healing text based on the current theme",
                get = function() return VUI.db.profile.modules.msbt.themeColoredText end,
                set = function(_, val)
                    VUI.db.profile.modules.msbt.themeColoredText = val
                    
                    -- Apply the theme
                    if MSBT.ThemeIntegration then
                        MSBT.ThemeIntegration:ApplyTheme(VUI.db.profile.appearance.theme or "thunderstorm")
                    end
                end,
                width = "full",
                order = 12
            },
            enhancedFonts = {
                type = "toggle",
                name = "Use Enhanced Fonts",
                desc = "Use higher quality fonts for scrolling text",
                get = function() return VUI.db.profile.modules.msbt.enhancedFonts end,
                set = function(_, val)
                    VUI.db.profile.modules.msbt.enhancedFonts = val
                    
                    -- Apply font changes if MSBT is initialized
                    if MikSBT and MikSBT.Profiles and MikSBT.Profiles.currentProfile then
                        local currentProfile = MikSBT.Profiles.currentProfile
                        
                        -- Apply to all scroll areas
                        for _, scrollArea in pairs(currentProfile.scrollAreas) do
                            if val then
                                -- Set to a nicer font
                                scrollArea.normalFontName = "MSBT Porky"
                                scrollArea.critFontName = "MSBT Heroic"
                            else
                                -- Set to default fonts
                                scrollArea.normalFontName = "Friz Quadrata TT"
                                scrollArea.critFontName = "Friz Quadrata TT"
                            end
                        end
                        
                        -- Refresh the display
                        if MikSBT.Main and MikSBT.Main.ResetAnimations then
                            MikSBT.Main:ResetAnimations()
                        end
                    end
                end,
                width = "full",
                order = 13
            },
            soundsEnabled = {
                type = "toggle",
                name = "Enable Sound Effects",
                desc = "Play sound effects for notable combat events",
                get = function() return VUI.db.profile.modules.msbt.soundsEnabled end,
                set = function(_, val)
                    VUI.db.profile.modules.msbt.soundsEnabled = val
                    
                    -- Update the MSBT settings
                    if MikSBT and MikSBT.Profiles and MikSBT.Profiles.currentProfile then
                        -- Turn on/off sound for all notification events
                        local currentProfile = MikSBT.Profiles.currentProfile
                        if currentProfile.events then
                            for eventName, eventSettings in pairs(currentProfile.events) do
                                if string.find(eventName, "NOTIFICATION_") then
                                    eventSettings.soundName = val and "MSBT Cooldown" or ""
                                end
                            end
                        end
                    end
                end,
                width = "full",
                order = 14
            },
            configHeader = {
                type = "header",
                name = "Configuration",
                order = 20
            },
            openConfig = {
                type = "execute",
                name = "Open MSBT Configuration",
                desc = "Open the full MSBT configuration interface",
                func = function()
                    if MikSBT and MikSBT.Main and MikSBT.Main.ShowConfigurationMenu then
                        MikSBT.Main:ShowConfigurationMenu()
                    end
                end,
                width = "full",
                order = 21
            },
            resetSettings = {
                type = "execute",
                name = "Reset All Settings",
                desc = "Reset all MSBT settings to default values",
                func = function()
                    if MikSBT and MikSBT.Profiles and MikSBT.Profiles.ResetProfile then
                        MikSBT.Profiles:ResetProfile()
                        
                        -- Apply theme after reset
                        if MSBT.ThemeIntegration then
                            -- Register default scroll areas again
                            MSBT.ThemeIntegration:RegisterDefaultScrollAreas()
                            MSBT.ThemeIntegration:ApplyTheme(VUI.db.profile.appearance.theme or "thunderstorm")
                        end
                    end
                end,
                width = "full",
                order = 22
            },
            testHeader = {
                type = "header",
                name = "Testing",
                order = 30
            },
            testNormal = {
                type = "execute",
                name = "Test Normal Hits",
                desc = "Show test text for normal hits",
                func = function()
                    if MikSBT and MikSBT.Animations and MikSBT.Animations.DisplayEvent then
                        MikSBT.Animations:DisplayEvent("OUTGOING_DAMAGE", nil, 1000)
                        MikSBT.Animations:DisplayEvent("INCOMING_DAMAGE", nil, 800)
                        MikSBT.Animations:DisplayEvent("OUTGOING_HEAL", nil, 1500)
                    end
                end,
                width = "normal",
                order = 31
            },
            testCrit = {
                type = "execute",
                name = "Test Critical Hits",
                desc = "Show test text for critical hits",
                func = function()
                    if MikSBT and MikSBT.Animations and MikSBT.Animations.DisplayEvent then
                        MikSBT.Animations:DisplayEvent("OUTGOING_DAMAGE_CRIT", nil, 2000)
                        MikSBT.Animations:DisplayEvent("INCOMING_DAMAGE_CRIT", nil, 1600)
                        MikSBT.Animations:DisplayEvent("OUTGOING_HEAL_CRIT", nil, 3000)
                    end
                end,
                width = "normal",
                order = 32
            },
            testMiss = {
                type = "execute",
                name = "Test Misses",
                desc = "Show test text for misses",
                func = function()
                    if MikSBT and MikSBT.Animations and MikSBT.Animations.DisplayEvent then
                        MikSBT.Animations:DisplayEvent("OUTGOING_MISS", nil, "MISS")
                        MikSBT.Animations:DisplayEvent("INCOMING_MISS", nil, "DODGE")
                        MikSBT.Animations:DisplayEvent("NOTIFICATION_MISSING", nil, "LOW MANA")
                    end
                end,
                width = "normal",
                order = 33
            }
        }
    }
    
    return options
end

-- Register the module with the VUI core
VUI:RegisterModule("MSBT", MSBT)