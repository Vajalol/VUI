-- VUINotifications Module
-- Displays notifications for combat events
-- Based on SpellNotifications with VUI integration

local AddonName, VUI = ...
local MODNAME = "VUINotifications"
local M = VUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0")

-- Localization
local L = LibStub("AceLocale-3.0"):GetLocale("VUI")

-- Module Constants
M.NAME = MODNAME
M.TITLE = "VUI Notifications"
M.DESCRIPTION = "Simple spell notifications for combat events"
M.VERSION = "1.0"

-- Private variables
local reflected = {}
local duration
local warnOP
local warnCS

-- Default settings
M.defaults = {
    profile = {
        enabled = true,
        soundsEnabled = true,
        suppressErrors = true,
        
        -- Notification types
        showInterrupts = true,
        showDispels = true,
        showMisses = true,
        showReflects = true,
        showPetStatus = true,
        
        -- Visual settings
        notificationScale = 1.0,
        notificationDuration = 3.0,
        
        -- Position
        position = {"TOP", UIParent, "TOP", 0, -120},
        
        -- Font settings
        font = "Fonts\\FRIZQT__.TTF",
        fontSize = 18,
        fontOutline = "OUTLINE",
        
        -- Theme
        useThemeColors = true,
        colors = {
            interrupt = {r = 0.41, g = 0.8, b = 0.94, a = 1.0},
            dispel = {r = 0.84, g = 0.43, b = 1.0, a = 1.0},
            reflect = {r = 1.0, g = 0.5, b = 0.0, a = 1.0},
            miss = {r = 0.82, g = 0.82, b = 0.82, a = 1.0},
            pet = {r = 0.94, g = 0.41, b = 0.45, a = 1.0}
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
    
    -- Create frames
    self:CreateFrames()
    
    -- Register slash command
    self:RegisterChatCommand("vuin", "SlashCommand")
    
    -- Debug message
    VUI:Debug(self.NAME .. " initialized")
end

-- Enable the module
function M:OnEnable()
    -- Register events
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:RegisterEvent("UNIT_HEALTH")
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
    self:RegisterEvent("PLAYER_REGEN_DISABLED") -- enter combat
    self:RegisterEvent("PLAYER_REGEN_ENABLED") -- leave combat
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("ACTIONBAR_UPDATE_STATE")
    
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

-- Process combat log events
function M:COMBAT_LOG_EVENT_UNFILTERED()
    if not self.db.profile.enabled then return end
    
    local timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, _, extraSpellID, extraSpellName = CombatLogGetCurrentEventInfo()
    
    -- This would be where we process the combat log events
    -- For demonstration, we're just including placeholders
    
    if eventType == "SPELL_INTERRUPT" and self.db.profile.showInterrupts then
        self:ShowNotification("Interrupted " .. destName .. ": " .. extraSpellName, "interrupt")
    elseif eventType == "SPELL_DISPEL" and self.db.profile.showDispels then
        self:ShowNotification("Dispelled " .. destName .. ": " .. extraSpellName, "dispel")
    elseif eventType == "SPELL_REFLECT" and self.db.profile.showReflects then
        self:ShowNotification("Reflected " .. spellName, "reflect")
    elseif eventType:match("MISSED$") and self.db.profile.showMisses then
        local missType = extraSpellID
        self:ShowNotification(spellName .. " " .. missType, "miss")
    end
end

-- Create frames for notifications
function M:CreateFrames()
    -- Create the main frame
    self.frame = CreateFrame("Frame", "VUINotificationsFrame", UIParent)
    self.frame:SetSize(400, 100)
    self.frame:SetPoint(unpack(self.db.profile.position))
    
    -- Create the text frame
    self.text = self.frame:CreateFontString(nil, "OVERLAY")
    self.text:SetFont(self.db.profile.font, self.db.profile.fontSize, self.db.profile.fontOutline)
    self.text:SetPoint("CENTER", self.frame, "CENTER", 0, 0)
    
    -- Hide initially
    self.frame:Hide()
end

-- Show a notification
function M:ShowNotification(message, notificationType)
    if not self.db.profile.enabled then return end
    
    -- Set the text color based on notification type
    local color = self.db.profile.colors[notificationType] or {r = 1, g = 1, b = 1, a = 1}
    self.text:SetTextColor(color.r, color.g, color.b, color.a)
    
    -- Set the text and show the frame
    self.text:SetText(message)
    self.frame:Show()
    
    -- Play sound if enabled
    if self.db.profile.soundsEnabled then
        PlaySound(SOUNDKIT.ALARM_WARNING_SOUND)
    end
    
    -- Hide after duration
    C_Timer.After(self.db.profile.notificationDuration, function()
        self.frame:Hide()
    end)
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
                desc = L["Enable_Desc"] or "Enable or disable combat notifications",
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
            soundsEnabled = {
                type = "toggle",
                name = L["Enable Sounds"] or "Enable Sounds",
                desc = L["Enable_Sounds_Desc"] or "Play sounds with notifications",
                width = "full",
                order = 6,
                get = function() return self.db.profile.soundsEnabled end,
                set = function(_, val) self.db.profile.soundsEnabled = val end,
            },
            suppressErrors = {
                type = "toggle",
                name = L["Suppress Error Messages"] or "Suppress Error Messages",
                desc = L["Suppress_Errors_Desc"] or "Hide common error messages",
                width = "full",
                order = 7,
                get = function() return self.db.profile.suppressErrors end,
                set = function(_, val) self.db.profile.suppressErrors = val end,
            },
            -- Additional options would go here
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
    if not self.db.profile.useThemeColors then return end
    
    local theme = VUI:GetActiveTheme()
    if not theme then return end
    
    -- Apply theme colors to notification types
    self.db.profile.colors.interrupt = {r = theme.colors.primary.r, g = theme.colors.primary.g, b = theme.colors.primary.b, a = 1.0}
    self.db.profile.colors.dispel = {r = theme.colors.secondary.r, g = theme.colors.secondary.g, b = theme.colors.secondary.b, a = 1.0}
end

-- Debug helper
function M:Debug(...)
    VUI:Debug(self.NAME, ...)
end