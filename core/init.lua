-- VUI Core Initialization
-- Author: VortexQ8
-- Version: 0.0.1

local addonName, VUI = ...
_G["VUI"] = VUI

-- Initialize the main addon using AceAddon-3.0 framework
VUI = LibStub("AceAddon-3.0"):NewAddon(VUI, addonName, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")

-- Global constants
VUI.NAME = "VUI"
VUI.VERSION = "0.0.1"
VUI.AUTHOR = "VortexQ8"
VUI.CLASSCOLOR = RAID_CLASS_COLORS[select(2, UnitClass("player"))]

-- Initialize modules table to store all the sub-addons
VUI.modules = {}

-- Module registration function
function VUI:RegisterModule(name, module)
    if not name or not module then return end
    
    self.modules[name] = module
    module.moduleName = name
    
    -- Initialize module options
    if not VUI.options.args.modules then
        VUI.options.args.modules = {
            type = "group",
            name = "Modules",
            order = 2,
            args = {}
        }
    end
    
    -- Add module to options panel if it has a config
    if module.GetOptions then
        VUI.options.args.modules.args[name] = module:GetOptions()
    end
    
    return module
end

-- Function to check if a module exists and is enabled
function VUI:IsModuleEnabled(name)
    if not self.modules[name] then return false end
    return self.db.profile.modules[name].enabled
end

-- Function to enable a module
function VUI:EnableModule(name)
    if not self.modules[name] then return end
    if self:IsModuleEnabled(name) then return end
    
    self.db.profile.modules[name].enabled = true
    if self.modules[name].Enable then
        self.modules[name]:Enable()
    end
    
    self:Print(name .. " module enabled")
end

-- Function to disable a module
function VUI:DisableModule(name)
    if not self.modules[name] then return end
    if not self:IsModuleEnabled(name) then return end
    
    self.db.profile.modules[name].enabled = false
    if self.modules[name].Disable then
        self.modules[name]:Disable()
    end
    
    self:Print(name .. " module disabled")
end

-- Main initialization function
function VUI:OnInitialize()
    -- Load saved variables using AceDB
    self.db = LibStub("AceDB-3.0"):New("VUIDB", VUI.defaults, true)
    self.charDB = LibStub("AceDB-3.0"):New("VUICharacterDB", VUI.charDefaults, true)
    
    -- Register options table
    LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, self.options)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, VUI.NAME)
    
    -- Set up slash commands
    self:RegisterChatCommand("vui", "SlashCommand")
    
    -- Load media files
    self:InitializeMedia()
    
    -- Initialize modules
    for name, module in pairs(self.modules) do
        if module.Initialize then
            module:Initialize()
        end
        
        -- Enable module if it's enabled in the settings
        if self:IsModuleEnabled(name) and module.Enable then
            module:Enable()
        end
    end
    
    self:Print("VUI v" .. self.VERSION .. " initialized. Type /vui for options.")
end

-- Event handling when addon is fully loaded
function VUI:OnEnable()
    -- Register events
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_LOGOUT")
    
    -- Hook into the game's interface options
    self:HookScript(GameMenuFrame, "OnShow", "GameMenuFrame_OnShow")
end

-- PLAYER_ENTERING_WORLD event handler
function VUI:PLAYER_ENTERING_WORLD()
    local inInstance, instanceType = IsInInstance()
    for name, module in pairs(self.modules) do
        if self:IsModuleEnabled(name) and module.OnEnterWorld then
            module:OnEnterWorld(inInstance, instanceType)
        end
    end
end

-- PLAYER_LOGOUT event handler
function VUI:PLAYER_LOGOUT()
    for name, module in pairs(self.modules) do
        if module.OnLogout then
            module:OnLogout()
        end
    end
end

-- Slash command handler
function VUI:SlashCommand(input)
    if not input or input:trim() == "" then
        -- Open main configuration panel
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
    else
        -- Parse the command
        local command, arg = input:match("^(%S+)%s*(.*)$")
        
        if command == "enable" and arg ~= "" then
            self:EnableModule(arg)
        elseif command == "disable" and arg ~= "" then
            self:DisableModule(arg)
        elseif command == "toggle" and arg ~= "" then
            if self:IsModuleEnabled(arg) then
                self:DisableModule(arg)
            else
                self:EnableModule(arg)
            end
        elseif command == "version" then
            self:Print("Version: " .. self.VERSION)
        elseif command == "list" then
            self:Print("Available modules:")
            for name, _ in pairs(self.modules) do
                local status = self:IsModuleEnabled(name) and "|cFF00FF00Enabled|r" or "|cFFFF0000Disabled|r"
                self:Print("  " .. name .. ": " .. status)
            end
        else
            self:Print("Usage:")
            self:Print("  /vui - Opens the configuration panel")
            self:Print("  /vui enable <module> - Enables a module")
            self:Print("  /vui disable <module> - Disables a module")
            self:Print("  /vui toggle <module> - Toggles a module")
            self:Print("  /vui version - Displays the addon version")
            self:Print("  /vui list - Lists all available modules")
        end
    end
end

-- Add Interface Options button to Game Menu
function VUI:GameMenuFrame_OnShow()
    if not GameMenuButtonVUI then
        local button = CreateFrame("Button", "GameMenuButtonVUI", GameMenuFrame, "GameMenuButtonTemplate")
        button:SetText(VUI.NAME .. " Options")
        
        -- Position the button
        local lastButton = GameMenuButtonAddons
        button:SetPoint("TOP", lastButton, "BOTTOM", 0, -1)
        
        -- Adjust other buttons
        GameMenuButtonLogout:SetPoint("TOP", button, "BOTTOM", 0, -16)
        
        -- Adjust the height of the Game Menu frame
        GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + button:GetHeight() + 1)
        
        button:SetScript("OnClick", function()
            HideUIPanel(GameMenuFrame)
            InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
            InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
        end)
    end
end

-- Print a message with addon prefix
function VUI:Print(msg)
    print("|cff1784d1" .. VUI.NAME .. "|r: " .. tostring(msg))
end
