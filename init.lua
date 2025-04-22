-- VUI - Unified World of Warcraft Addon Suite
-- Author: VortexQ8
-- Version: 0.0.1

-- Create global VUI table
VUI = {}
VUI.name = "VUI"
VUI.version = "0.0.1"
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

-- Core UI & Functionality modules
VUI.unitframes = {}
VUI.skins = {}
VUI.profiles = {}
VUI.automation = {}
VUI.visualconfig = {}
VUI.Castbar = {}

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
    
    -- Core UI & Functionality modules
    "unitframes",
    "skins",
    "profiles",
    "automation",
    "visualconfig",
    "Castbar"
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
    self:InitializeModules()
    self:CreateConfigPanel()
    self:RegisterChatCommands()
    
    -- Initialize the Castbar module
    if self.Castbar and self.Castbar.OnInitialize then
        self.Castbar:OnInitialize()
        self.Castbar:RegisterEvents()
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

-- Initialize all modules
function VUI:InitializeModules()
    for _, moduleName in ipairs(self.modules) do
        local module = self[moduleName]
        if self.enabledModules[moduleName] and module and module.Initialize then
            -- Register the module with core system if it's not already registered
            if VUI.RegisterModule and not VUI.modules[moduleName] then
                VUI:RegisterModule(moduleName, module)
            end
            
            -- Initialize the module
            module:Initialize()
        end
    end
end
