-- VUICC Module
-- Provides cooldown text on action buttons and items
-- Based on OmniCC with VUI integration

local AddonName, VUI = ...
local MODNAME = "VUICC"
local M = VUI:NewModule(MODNAME, "AceEvent-3.0", "AceHook-3.0")

-- Localization
local L = LibStub("AceLocale-3.0"):GetLocale("VUI")

-- Module Constants
M.NAME = MODNAME
M.TITLE = "VUI Cooldown Count"
M.DESCRIPTION = "Adds text to cooldowns to indicate when they'll be ready to use"
M.VERSION = "1.0"

-- Legacy support for OmniCC compatibility
_G.OmniCC = M

-- Default settings
M.defaults = {
    profile = {
        enabled = true,
        disableBlizzardCooldownText = true,
        fontSize = 18,
        fontFace = "Fonts\\FRIZQT__.TTF",
        fontOutline = "OUTLINE",
        minScale = 0.5,
        minDuration = 2,
        mmssThreshold = 90,
        tenthsThreshold = 5,
        effect = "PULSE",
        useThemeColors = true,
        useClassColors = false,
        styles = {
            soon = {r = 1, g = 0.2, b = 0.2},
            seconds = {r = 1, g = 1, b = 0.2},
            minutes = {r = 0.8, g = 0.8, b = 0.8},
            hours = {r = 0.6, g = 0.6, b = 0.6},
            days = {r = 0.4, g = 0.4, b = 0.4}
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
    
    -- Setup cooldown hooks
    self:SetupHooks()
    
    -- Register slash command
    self:RegisterChatCommand("vuicc", "SlashCommand")
    
    -- Legacy support
    self:RegisterChatCommand("omnicc", "SlashCommand")
    self:RegisterChatCommand("occ", "SlashCommand")
    
    -- Debug message
    VUI:Debug(self.NAME .. " initialized")
end

-- Enable the module
function M:OnEnable()
    -- Register events
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    
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

-- Configuration initialization
function M:InitializeConfig()
    -- Create config options table
    local options = {
        name = self.TITLE,
        desc = self.DESCRIPTION,
        type = "group",
        args = {
            header = {
                type = "header",
                name = self.TITLE,
                order = 1,
            },
            version = {
                type = "description",
                name = "|cffff9900Version:|r " .. self.VERSION,
                order = 2,
            },
            desc = {
                type = "description",
                name = self.DESCRIPTION,
                order = 3,
            },
            spacer = {
                type = "description",
                name = " ",
                order = 4,
            },
            enabled = {
                type = "toggle",
                name = L["Enable"],
                desc = L["Enable_Desc"] or "Enable or disable cooldown text",
                width = "full",
                order = 5,
                get = function() return self.db.profile.enabled end,
                set = function(_, val) 
                    self.db.profile.enabled = val
                    if val then
                        self:Enable()
                    else
                        self:Disable()
                    end
                end,
            },
            disableBlizzardCooldownText = {
                type = "toggle",
                name = L["DISABLE_BLIZZARD_COOLDOWN"] or "Disable Blizzard cooldown text",
                desc = L["DISABLE_BLIZZARD_COOLDOWN_DESC"] or "Hide Blizzard's built-in cooldown text (requires UI reload)",
                width = "full",
                order = 6,
                get = function() return self.db.profile.disableBlizzardCooldownText end,
                set = function(_, val) 
                    self.db.profile.disableBlizzardCooldownText = val
                    StaticPopup_Show("VUI_RELOAD_UI")
                end,
            },
            -- Additional options would be defined here
        }
    }
    
    -- Register with VUI's configuration system
    VUI.Config:RegisterModuleOptions(self.NAME, options, self.TITLE)
end

-- PLAYER_ENTERING_WORLD event handler
function M:PLAYER_ENTERING_WORLD()
    self:ForActive('Update')
end

-- Setup cooldown hooks
function M:SetupHooks()
    -- This would be implemented with the actual cooldown hooking code
    -- For demonstration, we're just including a placeholder
end

-- ForActive helper
function M:ForActive(method)
    -- This would be implemented with the actual cooldown processing logic
    -- For demonstration, we're just including a placeholder
end

-- Slash command handler
function M:SlashCommand(input)
    if input == "toggle" then
        self.db.profile.enabled = not self.db.profile.enabled
        VUI:Print("|cffff9900" .. self.TITLE .. ":|r " .. (self.db.profile.enabled and "Enabled" or "Disabled"))
    elseif input == "blizzard" then
        self.db.profile.disableBlizzardCooldownText = not self.db.profile.disableBlizzardCooldownText
        StaticPopup_Show("VUI_RELOAD_UI")
    else
        -- Open configuration
        VUI.Config:OpenToCategory(self.TITLE)
    end
end

-- Theme update handler
function M:UpdateTheme()
    -- Update visuals based on current theme
    if not self.db.profile.useThemeColors then return end
    
    local theme = VUI:GetActiveTheme()
    if not theme then return end
    
    -- Apply theme colors to cooldown text
    self.db.profile.styles.soon = {r = theme.colors.primary.r, g = theme.colors.primary.g, b = theme.colors.primary.b}
    self.db.profile.styles.seconds = {r = theme.colors.secondary.r, g = theme.colors.secondary.g, b = theme.colors.secondary.b}
    
    -- Additional theme handling would go here
end

-- Debug helper
function M:Debug(...)
    VUI:Debug(self.NAME, ...)
end