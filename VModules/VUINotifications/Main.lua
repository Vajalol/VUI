-- VUINotifications Module
-- Displays notifications for combat events
-- Based on SpellNotifications with VUI integration

local AddonName, _ = ...

-- Use global reference instead of local addon variable to fix load order issues
local VUI = _G["VUI"]

-- Ensure VUI exists
VUI = VUI or {}

-- Ensure the VUI.Notifications namespace exists early to prevent nil field errors
VUI.Notifications = VUI.Notifications or {}

-- Create the module if it doesn't exist through NewModule or directly
local MODNAME = "VUINotifications"
local M

-- Set the global reference to ensure consistent access across files
_G["VUINotifications"] = _G["VUINotifications"] or {}

if VUI.NewModule and type(VUI.NewModule) == "function" then
    M = VUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0")
    -- Update the global reference with the actual module
    _G["VUINotifications"] = M
else
    -- Create a minimal module if NewModule doesn't exist
    M = {}
    VUI[MODNAME] = M
    
    -- Update the global reference with our placeholder
    _G["VUINotifications"] = M
    
    -- Create minimal implementations of AceEvent and AceTimer methods
    M.RegisterEvent = function(self, event, callback) end
    M.UnregisterAllEvents = function(self) end
    M.RegisterChatCommand = function(self, cmd, callback) end
    
    -- Minimal Debug implementation
    M.Debug = function(self, msg)
        print(MODNAME .. ": " .. (msg or ""))
    end
end

-- Localization with error handling
local L
-- Use global reference pattern for localization tables
if VUI.L then
    L = VUI.L
else
    local success, result = pcall(function() return LibStub("AceLocale-3.0"):GetLocale("VUI") end)
    if success then
        L = result
    else
        -- If localization isn't available, create a minimal fallback
        L = {}
    end
end

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
    -- Create the database with consistent naming
    if VUI and VUI.db then
        -- Make sure namespaces exists to avoid nil indexing
        if not VUI.db.namespaces then
            VUI.db.namespaces = {}
        end
        
        -- Check if a namespace already exists with any of the possible names
        local namespace = VUI.db.namespaces["VUINotifications"] or VUI.db.namespaces["vuinotifications"]
        
        if namespace then
            -- Use existing namespace
            self.db = namespace
            
            -- Ensure both versions are synchronized
            VUI.db.namespaces["VUINotifications"] = namespace
            VUI.db.namespaces["vuinotifications"] = namespace
        else
            -- Create new namespace with proper case for consistency
            self.db = VUI.db:RegisterNamespace("VUINotifications", {
                profile = self.defaults.profile
            })
            
            -- Also create lowercase reference for compatibility
            VUI.db.namespaces["vuinotifications"] = self.db
        end
    else
        -- Fallback if VUI.db isn't available
        self.db = {profile = self.defaults.profile}
    end
    
    -- Initialize the configuration panel
    self:InitializeConfig()
    
    -- Create the notification frame
    self:CreateFrame()
    
    -- Register callback for theme changes
    if VUI and VUI.RegisterCallback and type(VUI.RegisterCallback) == "function" then
        -- Wrap in pcall to prevent errors if callback registration fails
        pcall(function()
            VUI:RegisterCallback("OnThemeChanged", function()
                if self and self.UpdateTheme and type(self.UpdateTheme) == "function" then
                    self:UpdateTheme()
                end
            end)
        end)
    end
    
    -- Register slash command
    if self.RegisterChatCommand and type(self.RegisterChatCommand) == "function" then
        self:RegisterChatCommand("vuinotify", "SlashCommand")
    else
        -- Fallback: Register with SlashCmdList
        _G.SLASH_VUINOTIFY1 = "/vuinotify"
        SlashCmdList["VUINOTIFY"] = function(input)
            self:SlashCommand(input)
        end
    end
    
    -- Initialize the notification service if it exists
    if VUI.Notifications and type(VUI.Notifications.Initialize) == "function" then
        pcall(VUI.Notifications.Initialize)
    end
    
    -- Debug message
    self:Debug("initialized")
end

-- Enable the module
function M:OnEnable()
    -- Register events with safety check
    if self.RegisterEvent and type(self.RegisterEvent) == "function" then
        pcall(function()
            self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        end)
    else
        -- Fallback for when RegisterEvent isn't available
        local frame = CreateFrame("Frame")
        frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        frame:SetScript("OnEvent", function(_, ...)
            if self and self.COMBAT_LOG_EVENT_UNFILTERED then
                self:COMBAT_LOG_EVENT_UNFILTERED(...)
            end
        end)
        -- Store the frame for later cleanup
        self.eventFrame = frame
    end
    
    -- Debug message
    self:Debug("enabled")
end

-- Disable the module
function M:OnDisable()
    -- Unregister events with safety check
    if self.UnregisterAllEvents and type(self.UnregisterAllEvents) == "function" then
        pcall(function()
            self:UnregisterAllEvents()
        end)
    end
    
    -- Clean up the event frame if we created one
    if self.eventFrame then
        self.eventFrame:SetScript("OnEvent", nil)
        self.eventFrame:UnregisterAllEvents()
    end
    
    -- Debug message
    self:Debug("disabled")
end

-- Create the notification frame
function M:CreateFrame()
    -- Create the main frame
    self.frame = CreateFrame("Frame", "VUINotificationsFrame", UIParent)
    self.frame:SetSize(400, 50)
    self.frame:SetPoint(unpack(self.db.profile.position))
    self.frame:SetScale(self.db.profile.notificationScale)
    self.frame:SetFrameStrata("HIGH")
    self.frame:Hide()
    
    -- Create text display
    self.text = self.frame:CreateFontString(nil, "OVERLAY")
    self.text:SetFont(self.db.profile.font, self.db.profile.fontSize, self.db.profile.fontOutline)
    self.text:SetPoint("CENTER", self.frame, "CENTER")
    
    -- Make frame movable
    self.frame:SetMovable(true)
    self.frame:EnableMouse(true)
    self.frame:RegisterForDrag("LeftButton")
    self.frame:SetScript("OnDragStart", function(frame) frame:StartMoving() end)
    self.frame:SetScript("OnDragStop", function(frame)
        frame:StopMovingOrSizing()
        -- Save position
        local point, _, relativePoint, xOfs, yOfs = frame:GetPoint()
        self.db.profile.position = {point, UIParent, relativePoint, xOfs, yOfs}
    end)
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
        -- Use pcall to handle missing sound
        pcall(function() PlaySound(SOUNDKIT.ALARM_WARNING_SOUND) end)
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
            enabled = {
                type = "toggle",
                name = L["Enable"] or "Enable",
                desc = L["Enable_Notifications_Desc"] or "Enable notification display",
                width = "full",
                order = 1,
                get = function() return self.db.profile.enabled end,
                set = function(_, val) self.db.profile.enabled = val end,
            },
            soundsEnabled = {
                type = "toggle",
                name = L["Enable Sounds"] or "Enable Sounds",
                desc = L["Enable_Sounds_Desc"] or "Play sounds for notifications",
                width = "full",
                order = 2,
                get = function() return self.db.profile.soundsEnabled end,
                set = function(_, val) self.db.profile.soundsEnabled = val end,
            },
            notificationScale = {
                type = "range",
                name = L["Scale"] or "Scale",
                desc = L["Scale_Desc"] or "Adjust the size of notifications",
                min = 0.5,
                max = 2.0,
                step = 0.1,
                width = "full",
                order = 3,
                get = function() return self.db.profile.notificationScale end,
                set = function(_, val) 
                    self.db.profile.notificationScale = val
                    self.frame:SetScale(val)
                end,
            },
            notificationDuration = {
                type = "range",
                name = L["Duration"] or "Duration",
                desc = L["Duration_Desc"] or "How long notifications remain on screen",
                min = 1.0,
                max = 10.0,
                step = 0.5,
                width = "full",
                order = 4,
                get = function() return self.db.profile.notificationDuration end,
                set = function(_, val) self.db.profile.notificationDuration = val end,
            },
            showInterrupts = {
                type = "toggle",
                name = L["Show Interrupts"] or "Show Interrupts",
                desc = L["Show_Interrupts_Desc"] or "Show notifications for spell interrupts",
                width = "full",
                order = 5,
                get = function() return self.db.profile.showInterrupts end,
                set = function(_, val) self.db.profile.showInterrupts = val end,
            },
            showDispels = {
                type = "toggle",
                name = L["Show Dispels"] or "Show Dispels",
                desc = L["Show_Dispels_Desc"] or "Show notifications for dispels",
                width = "full",
                order = 6,
                get = function() return self.db.profile.showDispels end,
                set = function(_, val) self.db.profile.showDispels = val end,
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
    if VUI.Config and VUI.Config.RegisterModuleOptions then
        pcall(function() VUI.Config:RegisterModuleOptions(self.NAME, options, self.TITLE) end)
    end
end

-- Slash command handler
function M:SlashCommand(input)
    if input == "toggle" then
        self.db.profile.enabled = not self.db.profile.enabled
        VUI:Print("|cffff9900" .. self.TITLE .. ":|r " .. (self.db.profile.enabled and "Enabled" or "Disabled"))
    else
        -- Open configuration
        if VUI.Config and VUI.Config.OpenToCategory then
            VUI.Config:OpenToCategory(self.TITLE)
        else
            VUI:Print("Configuration UI not available")
        end
    end
end

-- Theme update handler
function M:UpdateTheme()
    -- Update visuals based on current theme
    if not self.db.profile.useThemeColors then return end
    
    local theme
    if VUI.GetActiveTheme then
        local success, result = pcall(function() return VUI:GetActiveTheme() end)
        if success and result then
            theme = result
        end
    end
    
    if not theme or not theme.colors then return end
    
    -- Apply theme colors to notification types with error handling
    pcall(function()
        self.db.profile.colors.interrupt = {r = theme.colors.primary.r, g = theme.colors.primary.g, b = theme.colors.primary.b, a = 1.0}
        self.db.profile.colors.dispel = {r = theme.colors.secondary.r, g = theme.colors.secondary.g, b = theme.colors.secondary.b, a = 1.0}
    end)
end

-- Debug helper
function M:Debug(...)
    if VUI.Debug then
        VUI:Debug(self.NAME, ...)
    end
end

-- Event handler
function M:COMBAT_LOG_EVENT_UNFILTERED()
    -- This function would process combat log events and trigger notifications
    -- Implementation would go here
end