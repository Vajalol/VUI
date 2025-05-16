-- VUICC Module
-- Provides cooldown text on action buttons and items
-- Based on OmniCC with VUI integration

-- Create a global placeholder to ensure references work even during initialization
_G["VUICC"] = _G["VUICC"] or {}

-- Add FX namespace to global VUICC reference which is used by effect files
_G["VUICC"].FX = _G["VUICC"].FX or {
    -- Add Create method used by effect files
    Create = function(self, id, name, tip)
        local effect = {}
        return effect
    end
}

-- Also create a global placeholder for second argument in module files (_, Addon = ...)
-- This ensures that even files using the Addon variable directly will work
_G["VUI_ADDON"] = _G["VUI_ADDON"] or {}

-- Add necessary functions to the global addon reference for submodules
if not _G["VUI_ADDON"].CreateHiddenFrame then
    _G["VUI_ADDON"].CreateHiddenFrame = function(self, frameType, name, parent, ...)
        return CreateFrame(frameType or "Frame", name, parent or UIParent, ...)
    end
end

-- Add FX namespace which is used by effect files
_G["VUI_ADDON"].FX = _G["VUI_ADDON"].FX or {
    -- Add Create method used by effect files
    Create = function(self, id, name, tip)
        local effect = {}
        return effect
    end
}

-- Add GetButtonIcon method used by effects
_G["VUI_ADDON"].GetButtonIcon = function(self, button)
    if not button then return end
    
    local icon = button.icon
    if not icon then
        local children = {button:GetChildren()}
        for i = 1, #children do
            local child = children[i]
            if child:GetObjectType() == "Texture" and child:GetTexture() then
                icon = child
                break
            end
        end
    end
    
    return icon
end

-- Now attempt to initialize the module properly
local AddonName, _ = ...
local MODNAME = "VUICC"

-- Use global reference instead of local addon variable to fix load order issues
local VUI = _G["VUI"]

-- Ensure our global reference is populated with the actual Addon from this file
-- This is critical because Core/*.lua files use the Addon variable directly
_G["VUI_ADDON"] = _G["VUI_ADDON"] or {}

-- Safety check to ensure VUI is available before calling NewModule
local M
if VUI and VUI.NewModule then
    M = VUI:NewModule(MODNAME, "AceEvent-3.0", "AceHook-3.0")
    -- Update the global references with the actual module
    _G["VUICC"] = M
    
    -- This is critical: update VUI_ADDON to be the same as the second argument from "..."
    -- which is used by Core/*.lua files
    for key, value in pairs(_G["VUI_ADDON"]) do
        if not M[key] then
            M[key] = value
        end
    end
    _G["VUI_ADDON"] = M
else
    -- If VUI isn't ready, use the placeholder as a fallback
    M = _G["VUICC"]
    
    -- Add minimal Ace library functionality to the placeholder
    if not M.RegisterEvent then
        M.RegisterEvent = function(self, ...) end
    end
    if not M.RegisterChatCommand then
        M.RegisterChatCommand = function(self, ...) end
    end
    if not M.UnregisterEvent then
        M.UnregisterEvent = function(self, ...) end
    end
    if not M.UnregisterAllEvents then
        M.UnregisterAllEvents = function(self, ...) end
    end
    if not M.RegisterMessage then
        M.RegisterMessage = function(self, ...) end
    end
    -- Add the missing CreateHiddenFrame method that's used in cooldown.lua
    if not M.CreateHiddenFrame then
        M.CreateHiddenFrame = function(self, frameType, name, parent, ...)
            return CreateFrame(frameType or "Frame", name, parent or UIParent, ...)
        end
    end
    -- Check if the method to hook scripts needs to be added
    if not M.SecureHook then
        M.SecureHook = function(self, ...) end
    end
    if not M.SecureHookScript then
        M.SecureHookScript = function(self, ...) end
    end
end

-- Localization with fallback mechanism
local L
-- Use global reference pattern for localization tables
if VUI and VUI.L then
    L = VUI.L
else
    -- Try to get the locale safely, with a pcall to catch errors
    local success, result = pcall(function() return LibStub("AceLocale-3.0"):GetLocale("VUI") end)
    if success then
        L = result
    else
        -- If the locale isn't registered yet, create a fallback table with common strings
        L = {
        -- Common UI strings
        Enable = "Enable",
        Enable_Desc = "Enable or disable this module",
        DISABLE_BLIZZARD_COOLDOWN = "Disable Blizzard cooldown text",
        DISABLE_BLIZZARD_COOLDOWN_DESC = "Hide Blizzard's built-in cooldown text (requires UI reload)",
        
        -- Timer formats (used in Core/timer.lua)
        TenthsFormat = "%.1f",
        SecondsFormat = "%d",
        MMSSFormat = "%d:%02d",
        MinutesFormat = "%dm",
        HoursFormat = "%dh",
        DaysFormat = "%dd",
        
        -- Alert effect strings (used in Effects/*.lua)
        Alert = "Alert",
        AlertTip = "Flashes the icon in the center of the screen when the cooldown completes",
        Pulse = "Pulse",
        PulseTip = "Pulses the cooldown's icon when the cooldown completes",
        Shine = "Shine",
        ShineTip = "Shines the cooldown's icon when the cooldown completes",
        None = "None",
        NoneTip = "No finish effect",
        Flare = "Flare",
        FlareTip = "Flares the cooldown's icon when the cooldown completes"
        }
    end
    
    -- Make this available to the entire addon to prevent duplicate fallbacks
    _G["VUICC"].L = L
end

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
    -- Create the database with consistent naming and ensure we have fallbacks
    -- for when VUI.db or VUI.db.namespaces isn't available
    if VUI and VUI.db then
        -- Make sure namespaces exists to avoid nil indexing
        if not VUI.db.namespaces then
            VUI.db.namespaces = {}
        end
        
        -- Check if a namespace already exists with any of the possible names
        local namespace = VUI.db.namespaces["VUICC"] or VUI.db.namespaces["vuicc"]
        
        if namespace then
            -- Use existing namespace
            self.db = namespace
            
            -- Ensure both versions are synchronized
            VUI.db.namespaces["VUICC"] = namespace
            VUI.db.namespaces["vuicc"] = namespace
        else
            -- Create new namespace with proper case for consistency
            self.db = VUI.db:RegisterNamespace("VUICC", {
                profile = self.defaults.profile
            })
            
            -- Also create lowercase reference for compatibility
            VUI.db.namespaces["vuicc"] = self.db
        end
    else
        -- Fallback if VUI.db isn't available
        self.db = {profile = self.defaults.profile}
    end
    
    -- Initialize the configuration panel
    self:InitializeConfig()
    
    -- Register callback for theme changes with safety checks
    if VUI and VUI.RegisterCallback and type(VUI.RegisterCallback) == "function" then
        pcall(function()
            VUI:RegisterCallback("OnThemeChanged", function()
                if self and self.UpdateTheme and type(self.UpdateTheme) == "function" then
                    self:UpdateTheme()
                end
            end)
        end)
    end
    
    -- Setup cooldown hooks
    self:SetupHooks()
    
    -- Register slash command
    if self.RegisterChatCommand and type(self.RegisterChatCommand) == "function" then
        self:RegisterChatCommand("vuicc", "SlashCommand")
        
        -- Legacy support
        self:RegisterChatCommand("omnicc", "SlashCommand")
        self:RegisterChatCommand("occ", "SlashCommand")
    else
        -- Fallback: Register with SlashCmdList
        _G.SLASH_VUICC1 = "/vuicc"
        _G.SLASH_VUICC2 = "/omnicc" 
        _G.SLASH_VUICC3 = "/occ"
        SlashCmdList["VUICC"] = function(input)
            self:SlashCommand(input)
        end
    end
    
    -- Debug message
    if VUI and VUI.Debug then
        VUI:Debug(self.NAME .. " initialized")
    end
end

-- Enable the module
function M:OnEnable()
    -- Register events with safety check
    if self.RegisterEvent and type(self.RegisterEvent) == "function" then
        pcall(function()
            self:RegisterEvent("PLAYER_ENTERING_WORLD")
        end)
    else
        -- Fallback for when RegisterEvent isn't available
        local frame = CreateFrame("Frame")
        frame:RegisterEvent("PLAYER_ENTERING_WORLD")
        frame:SetScript("OnEvent", function(_, event, ...)
            if event == "PLAYER_ENTERING_WORLD" and self and self.PLAYER_ENTERING_WORLD then
                self:PLAYER_ENTERING_WORLD(...)
            end
        end)
        -- Store the frame for later cleanup
        self.eventFrame = frame
    end
    
    -- Debug message with safety check
    if VUI and VUI.Debug and type(VUI.Debug) == "function" then
        pcall(function() VUI:Debug(self.NAME .. " enabled") end)
    end
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
        self.eventFrame = nil
    end
    
    -- Debug message with safety check
    if VUI and VUI.Debug and type(VUI.Debug) == "function" then
        pcall(function() VUI:Debug(self.NAME .. " disabled") end)
    end
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
    if VUI and VUI.Config and type(VUI.Config.RegisterModuleOptions) == "function" then
        VUI.Config:RegisterModuleOptions(self.NAME, options, self.TITLE)
    end
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