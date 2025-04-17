-- VUI - Unified World of Warcraft Addon Suite
-- Author: VortexQ8
-- Version: 0.0.1

-- Create global VUI table
VUI = {}
VUI.name = "VUI"
VUI.version = "0.0.1"
VUI.author = "VortexQ8"

-- Add module tables
-- Original modules
VUI.BuffOverlay = {}
VUI.TrufiGCD = {}
VUI.MoveAny = {}
VUI.Auctionator = {}
VUI.AngryKeystones = {}
VUI.OmniCC = {}
VUI.OmniCD = {}
VUI.idTip = {}
VUI.premadegroupfinder = {}

-- Core UI & Functionality modules
VUI.unitframes = {}
VUI.skins = {}
VUI.profiles = {}
VUI.automation = {}
VUI.visualconfig = {}

-- Internal module tracking
VUI.modules = {
    -- Original modules
    "BuffOverlay",
    "TrufiGCD",
    "MoveAny",
    "Auctionator",
    "AngryKeystones",
    "OmniCC",
    "OmniCD",
    "idTip",
    "premadegroupfinder",
    
    -- Core UI & Functionality modules
    "unitframes",
    "skins",
    "profiles",
    "automation",
    "visualconfig"
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
        if self.enabledModules[moduleName] and self[moduleName] and self[moduleName].Initialize then
            self[moduleName]:Initialize()
        end
    end
end
