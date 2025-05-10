-- VUICD Module
-- Displays raid/party cooldowns
-- Based on OmniCD with VUI integration

local AddonName, VUI = ...
local MODNAME = "VUICD"
local M = VUI:NewModule(MODNAME, "AceEvent-3.0", "AceHook-3.0")

-- Localization
local L = LibStub("AceLocale-3.0"):GetLocale("VUI")

-- Module Constants
M.NAME = MODNAME
M.TITLE = "VUI Cooldown Tracker"
M.DESCRIPTION = "Displays party/raid member cooldowns in customizable layouts"
M.VERSION = "1.0"

-- Default settings
M.defaults = {
    profile = {
        enabled = true,
        modules = { ["Party"] = true },
        theme = {
            useThemeColors = true,
            useClassColors = true
        },
        party = {
            enabled = true,
            visibility = {
                arena = true,
                raid = true,
                party = true,
                scenario = true,
                none = false,
                outside = false,
                inTest = true
            },
            icons = {
                desaturate = true,
                showTooltip = true,
                tooltipScale = 1,
                showCounter = true,
                counterScale = 0.85,
                scale = 0.85,
                anchor = "TOPLEFT",
                relativePoint = "BOTTOMLEFT",
                padding = 1,
                columns = 10,
                statusBar = {
                    enabled = true,
                    position = "TOP",
                    width = 2,
                    height = 12,
                    showSpark = true,
                    statusBarTexture = "OmniCD-texture_flat",
                    useClassColor = true
                }
            },
            spells = {
                defensive = true,
                offensive = true,
                covenant = true,
                interrupt = true,
                utility = true,
                custom = false
            },
            highlight = {
                glowBuffs = true,
                glowType = "warcraft",
                notInterruptible = true
            },
            extraBars = {
                cooldown = {
                    enabled = false,
                    layout = 1,
                    anchor = "BOTTOMLEFT",
                    relativePoint = "BOTTOMLEFT",
                    offsetX = 0,
                    offsetY = 0,
                    manualPos = false,
                    showName = true,
                    nameOfs = 2,
                    nameAnchor = "BOTTOMLEFT",
                    nameRelPoint = "TOPLEFT",
                    sortDirection = "asc",
                    growUpward = false,
                    barColors = {
                        defensive = { r = 0.3, g = 0.6, b = 1.0 },
                        interrupt = { r = 0.85, g = 0.35, b = 0.35 },
                        offensive = { r = 1.0, g = 0.35, b = 0.35 },
                        utility = { r = 0.7, g = 0.28, b = 1.0 }
                    }
                }
            },
            position = {
                anchor = "TOPLEFT",
                relativePoint = "TOPLEFT",
                offsetX = 0,
                offsetY = -50
            }
        }
    }
}

-- Initialize the module
function M:OnInitialize()
    -- Create the database
    self.db = VUI.db:RegisterNamespace(self.NAME, {
        profile = self.defaults.profile
    })
    
    -- Initialize the configuration panel
    self:InitializeConfig()
    
    -- Register callback for theme changes
    VUI:RegisterCallback("OnThemeChanged", function()
        if self.UpdateTheme then
            self:UpdateTheme()
        end
    end)
    
    -- Initialize submodules
    self:InitializeModules()
    
    -- Register slash command
    self:RegisterChatCommand("vuicd", "SlashCommand")
    
    -- Legacy support
    self:RegisterChatCommand("omnicd", "SlashCommand")
    
    -- Debug message
    VUI:Debug(self.NAME .. " initialized")
end

-- Enable the module
function M:OnEnable()
    -- Register events
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("GROUP_ROSTER_UPDATE")
    
    -- Debug message
    VUI:Debug(self.NAME .. " enabled")
end

-- Disable the module
function M:OnDisable()
    -- Unregister events
    self:UnregisterAllEvents()
    
    -- Debug message
    VUI:Debug(self.NAME .. " disabled")
end

-- Initialize submodules
function M:InitializeModules()
    for moduleName, enabled in pairs(self.db.profile.modules) do
        if enabled and self[moduleName] then
            if self[moduleName].Initialize then
                self[moduleName]:Initialize()
            end
        end
    end
end

-- Configuration initialization
function M:InitializeConfig()
    -- Register with VUI's configuration system
    VUI.Config:RegisterModuleOptions("VUICD", function()
        -- Open the configuration panel
        if self.OpenConfig then
            self:OpenConfig()
        end
    end)
end

-- Slash command handler
function M:SlashCommand(input)
    if input == "toggle" then
        self.db.profile.enabled = not self.db.profile.enabled
        VUI:Print("|cffff9900" .. self.TITLE .. ":|r " .. (self.db.profile.enabled and "Enabled" or "Disabled"))
    else
        -- Open configuration
        if self.OpenConfig then
            self:OpenConfig()
        else
            VUI.Config:OpenToCategory(self.TITLE)
        end
    end
end

-- Theme update handler
function M:UpdateTheme()
    -- Update visuals based on current theme
    if not self.db.profile.theme.useThemeColors then return end
    
    local theme = VUI:GetActiveTheme()
    if not theme then return end
    
    -- Apply theme colors to cooldown bars
    if self.Party and self.Party.UpdateTheme then
        self.Party:UpdateTheme(theme)
    end
end

-- Debug helper
function M:Debug(...)
    VUI:Debug(self.NAME, ...)
end

-- API for other modules to use
M.API = {}

-- Export the module to the namespace
VUI.VUICD = M