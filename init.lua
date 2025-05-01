-- VUI - Unified World of Warcraft Addon Suite
-- Author: VortexQ8
-- Version: 0.2.0

-- Create global VUI table
VUI = {}
VUI.name = "VUI"
VUI.version = "0.2.0"
VUI.author = "VortexQ8"

-- Define global library references that will be used throughout the addon
local AceDBOptions = LibStub("AceDBOptions-3.0")

-- Add module tables
-- Original modules
VUI.buffoverlay = {}
VUI.trufigcd = {}
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
    self:InitializeDB()
    self:LoadMedia()
    
    -- Initialize the Atlas system (for texture optimization)
    if self.Atlas and self.Atlas.Initialize then
        self.Atlas:Initialize()
    end
    
    self:InitializeThemeIntegration()
    self:InitializeFontIntegration()
    
    -- Initialize ThemeHelpers after theme integration but before modules
    if self.ThemeHelpers then
        self.ThemeHelpers:UpdateCurrentTheme()
    end
    
    self:InitializeModules()
    self:CreateConfigPanel()
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
    
    -- Print initialization message
    print("|cff1784d1VUI|r v" .. self.version .. " initialized. Type |cff1784d1/vui|r for options.")
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
function VUI:GetModule(name)
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
    
    return nil
end

-- Initialize all modules
function VUI:InitializeModules()
    for _, moduleName in ipairs(self.modules) do
        local module = self[moduleName]
        if self.enabledModules[moduleName] and module then
            -- Apply performance optimizations
            if self.Performance then
                module = self.Performance:OptimizeModule(module)
            end
            
            -- Register the module with core system if it's not already registered
            if VUI.RegisterModule and not VUI.modules[moduleName] then
                VUI:RegisterModule(moduleName, module)
            end
            
            -- Initialize the module
            if module.Initialize then
                module:Initialize()
            end
        end
    end
    
    -- Special handling for high-performance modules
    -- Apply throttling to frequently updated UI elements
    if self.bags and self.bags.UpdateAllBags then
        self.bags.UpdateAllBags = self.Performance:Throttle(self.bags.UpdateAllBags, 0.2, true)
    end
    
    if self.actionbars and self.actionbars.UpdateCooldownText then
        self.actionbars.UpdateCooldownText = self.Performance:Throttle(self.actionbars.UpdateCooldownText, 0.05, false)
    end
    
    if self.paperdoll and self.paperdoll.UpdateCharacterFrame then
        self.paperdoll.UpdateCharacterFrame = self.Performance:Throttle(self.paperdoll.UpdateCharacterFrame, 0.1, true)
    end
end
