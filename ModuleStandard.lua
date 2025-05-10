-- Template for standardized VUI module structure
-- Replace ModuleName with actual module name

local AddonName, VUI = ...
local MODNAME = "ModuleName"
local M = VUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0", "AceConsole-3.0") -- Add needed Ace3 mixins

-- Localization
local L = LibStub("AceLocale-3.0"):GetLocale("VUI")

-- Module Constants
M.NAME = MODNAME
M.TITLE = "Module Display Name"
M.DESCRIPTION = "Module description text"
M.VERSION = "1.0"

-- Default settings
M.defaults = {
    profile = {
        enabled = true,
        -- Add module-specific defaults here
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
    
    -- Debug message
    VUI:Debug(self.NAME .. " initialized")
end

-- Enable the module
function M:OnEnable()
    -- Module-specific initialization
    
    -- Register events
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    
    -- Register slash command if needed
    self:RegisterChatCommand("slash", "SlashCommand")
    
    -- Debug message
    VUI:Debug(self.NAME .. " enabled")
end

-- Disable the module
function M:OnDisable()
    -- Clean up
    
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
                desc = L["Enable_Desc"] or "Enable or disable this module",
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
            -- Add module-specific options here
        }
    }
    
    -- Register with VUI's configuration system
    VUI.Config:RegisterModuleOptions(self.NAME, options, self.TITLE)
end

-- Slash command handler
function M:SlashCommand(input)
    if input == "toggle" then
        self.db.profile.enabled = not self.db.profile.enabled
        VUI:Print("|cffff9900" .. self.TITLE .. ":|r " .. (self.db.profile.enabled and "Enabled" or "Disabled"))
    else
        -- Open configuration
        VUI.Config:OpenToCategory(self.TITLE)
    end
end

-- Theme update handler
function M:UpdateTheme()
    -- Update visuals based on current theme
    local theme = VUI:GetActiveTheme()
    -- Apply theme colors to module elements
end

-- Debug helper
function M:Debug(...)
    VUI:Debug(self.NAME, ...)
end