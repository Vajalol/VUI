-------------------------------------------------------------------------------
-- VUITGCD Module
-- Displays global cooldown icons and ability usage
-- Based on TrufiGCD with VUI integration
-------------------------------------------------------------------------------

local AddonName = ...
local VUI = _G["VUI"]
local MODNAME = "VUITGCD"
local M

-- Create module with safety checks
if VUI and VUI.NewModule then
    M = VUI:NewModule(MODNAME, "AceEvent-3.0")
else
    -- Fallback if VUI isn't available
    M = {}
    M.NAME = MODNAME
    M.Debug = function(self, msg) print("[VUITGCD] " .. tostring(msg)) end
    M.OnInitialize = function() end
    M.OnEnable = function() end
end

-- Initialize namespace
if not _G.VUI then _G.VUI = {} end
if not _G.VUI.TGCD then _G.VUI.TGCD = {} end
local TGCD = _G.VUI.TGCD

-- Initialize other needed globals to prevent nil errors
_G.VUITGCD = _G.VUITGCD or {}
_G.VUITGCD.settings = _G.VUITGCD.settings or {}
_G.VUITGCD.units = _G.VUITGCD.units or {}
_G.VUITGCD.constants = _G.VUITGCD.constants or {unitTypes = {}}

-- Connect VUITGCD and VUI.TGCD namespaces
VUI.VUITGCD = M

-- Ensure TGCD has the required sub-tables for basic functionality
TGCD.Utils = TGCD.Utils or {}
TGCD.Settings = TGCD.Settings or {}
TGCD.UI = TGCD.UI or {}
TGCD.Icons = TGCD.Icons or {}

-- Add essential utility functions if they don't exist
if not TGCD.Utils.size then
    TGCD.Utils.size = function(tbl)
        if type(tbl) ~= "table" then return 0 end
        local count = 0
        for _ in pairs(tbl) do
            count = count + 1
        end
        return count
    end
end

-- Add essential settings functions if they don't exist
if not TGCD.Settings.Load then
    TGCD.Settings.Load = function() 
        -- Minimal implementation to avoid errors
        return {
            enabled = true,
            iconSize = 30,
            maxIcons = 10,
            direction = "DOWN"
        }
    end
end

-- Localization with fallback
local L = LibStub and LibStub("AceLocale-3.0", true) and LibStub("AceLocale-3.0"):GetLocale("VUI", true) or {}

-- Module Constants
M.NAME = MODNAME
M.TITLE = "VUI Global Cooldowns"
M.DESCRIPTION = "Displays ability usage with animated icons"
M.VERSION = "1.0"

-- Default settings
M.defaults = {
    profile = {
        enabled = false,
        
        -- Icon settings
        iconSize = 30,
        iconAlpha = 1.0,
        fadeTime = 0.3,
        
        -- Layout settings
        direction = "DOWN",
        maxIcons = 10,
        
        -- Filter settings
        showGCDOnly = false,
        hideMacroText = true,
        
        -- Visual settings
        showBorder = true,
        showCooldownSwipe = true,
        colorBySpellType = true,
        useThemeColors = true,
        
        -- Position settings
        position = {"CENTER", "CENTER", 0, 0},
        
        -- Location settings
        showInWorld = true,
        showInInstances = true,
        showInPVP = true,
        
        -- Unit tracking settings
        trackPlayer = true,
        trackTarget = false,
        trackFocus = false,
        trackParty = false
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
        local namespace = VUI.db.namespaces["VUITGCD"] or VUI.db.namespaces["vuitgcd"]
        
        if namespace then
            -- Use existing namespace
            self.db = namespace
            
            -- Ensure both upper and lowercase versions are synchronized
            VUI.db.namespaces["VUITGCD"] = namespace
            VUI.db.namespaces["vuitgcd"] = namespace
        else
            -- Create new namespace with uppercase name for consistency
            self.db = VUI.db:RegisterNamespace("VUITGCD", {
                profile = self.defaults.profile
            })
            
            -- Also create lowercase reference for compatibility
            VUI.db.namespaces["vuitgcd"] = self.db
        end
        
        -- Ensure vmodules path exists in profile for settings UI
        if not VUI.db.profile.vmodules then
            VUI.db.profile.vmodules = {}
        end
        
        if not VUI.db.profile.vmodules.vuitgcd then
            VUI.db.profile.vmodules.vuitgcd = {}
        end
        
        -- Sync module settings between namespaces and the vmodules path
        for key, value in pairs(self.defaults.profile) do
            if VUI.db.profile.vmodules.vuitgcd[key] == nil then
                VUI.db.profile.vmodules.vuitgcd[key] = value
            end
            
            if self.db.profile[key] == nil then
                self.db.profile[key] = VUI.db.profile.vmodules.vuitgcd[key]
            end
        end
        
        -- Set up metatable to sync properties
        setmetatable(VUI.db.profile.vmodules.vuitgcd, {
            __index = function(t, k)
                return self.db.profile[k]
            end,
            __newindex = function(t, k, v)
                self.db.profile[k] = v
                rawset(t, k, v)
            end
        })
    else
        -- Fallback if VUI.db isn't available
        self.db = {
            profile = self.defaults.profile
        }
    end
    
    -- Initialize the configuration panel
    self:InitializeConfig()
    
    -- Register callback for theme changes with safety checks
    if VUI and VUI.RegisterCallback and type(VUI.RegisterCallback) == "function" then
        pcall(function()
            VUI:RegisterCallback("OnThemeChanged", function()
                if self and self.UpdateTheme and type(self.UpdateTheme) == "function" then
                    -- Use pcall with explicit self reference
                    pcall(function()
                        self:UpdateTheme()
                    end)
                end
            end)
        end)
    end
    
    -- Register slash commands with enhanced safety checks
    if self.RegisterChatCommand and type(self.RegisterChatCommand) == "function" then
        -- Wrap command registration in pcall to prevent errors
        pcall(function()
            self:RegisterChatCommand("vuitgcd", "SlashCommand")
        end)
        pcall(function()
            self:RegisterChatCommand("tgcd", "SlashCommand")
        end)
    else
        -- Fallback: Register with SlashCmdList
        _G.SLASH_VUITGCD1 = "/vuitgcd"
        _G.SLASH_VUITGCD2 = "/tgcd"
        SlashCmdList["VUITGCD"] = function(input)
            -- Safety check for self reference
            if not self then return end
            
            if self.SlashCommand and type(self.SlashCommand) == "function" then
                -- Use pcall with explicit function reference to maintain self
                pcall(function() 
                    M:SlashCommand(input)
                end)
            else
                -- Minimal fallback implementation
                if input == "toggle" then
                    -- Ensure db and profile exist
                    if self.db and self.db.profile then
                        self.db.profile.enabled = not self.db.profile.enabled
                        print("[VUITGCD] " .. (self.db.profile.enabled and "Enabled" or "Disabled"))
                    else
                        print("[VUITGCD] Error: Settings database not available")
                    end
                else
                    print("[VUITGCD] Available commands: toggle")
                end
            end
        end
    end
    
    -- Set up namespace sharing between VUI module and TrufiGCD code
    _G.VUITGCD = _G.VUITGCD or {}
    _G.VUITGCD.settings = _G.VUITGCD.settings or {}
    _G.VUITGCD.units = _G.VUITGCD.units or {}
    _G.VUITGCD.constants = _G.VUITGCD.constants or {unitTypes = {}}
    
    -- Create essential methods for the VUITGCD settings
    _G.VUITGCD.settings.Load = _G.VUITGCD.settings.Load or function()
        -- Use self.db.profile to get settings 
        return {
            enabled = self.db.profile.enabled,
            iconSize = self.db.profile.iconSize,
            maxIcons = self.db.profile.maxIcons,
            direction = self.db.profile.direction,
            useThemeColors = self.db.profile.useThemeColors
        }
    end
    
    -- Connect module settings with TrufiGCD namespace
    _G.VUI.TGCD.Settings = _G.VUITGCD.settings
    
    -- Debug message
    if VUI and VUI.Debug then
        VUI:Debug(self.NAME .. " initialized")
    else
        print("[VUITGCD] initialized")
    end
end

-- Enable the module
function M:OnEnable()
    -- Register core events with safety check
    if self.RegisterEvent and type(self.RegisterEvent) == "function" then
        pcall(function()
            -- Store reference to self for the event handler
            local moduleSelf = self
            self:RegisterEvent("PLAYER_ENTERING_WORLD", function(_, ...)
                if moduleSelf and moduleSelf.UpdateVisibility then
                    moduleSelf:UpdateVisibility(...)
                end
            end)
        end)
    else
        -- Fallback for when RegisterEvent isn't available
        local frame = CreateFrame("Frame")
        frame:RegisterEvent("PLAYER_ENTERING_WORLD")
        -- Store reference to the module for the event handler
        local moduleSelf = self
        frame:SetScript("OnEvent", function(_, event, ...)
            if event == "PLAYER_ENTERING_WORLD" and moduleSelf and moduleSelf.UpdateVisibility then
                moduleSelf:UpdateVisibility(...)
            end
        end)
        -- Store the frame for later cleanup
        self.eventFrame = frame
    end
    
    -- Update module with settings (with safety checks)
    if self.UpdateAppearance and type(self.UpdateAppearance) == "function" then
        pcall(function() self:UpdateAppearance() end)
    end
    
    if self.UpdateUnits and type(self.UpdateUnits) == "function" then
        pcall(function() self:UpdateUnits() end)
    end
    
    -- Debug message with safety check
    if VUI and VUI.Debug and type(VUI.Debug) == "function" then
        pcall(function() VUI:Debug(self.NAME .. " enabled") end)
    else
        print("[VUITGCD] enabled")
    end
end

-- Disable the module
function M:OnDisable()
    -- Unregister all events with safety check
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
    else
        print("[VUITGCD] disabled")
    end
end

-- Update appearance when settings change
function M:UpdateAppearance()
    if _G.VUITGCD and _G.VUITGCD.units then
        for _, unit in pairs(_G.VUITGCD.units) do
            if unit and unit.iconQueue and unit.iconQueue.Resize then
                unit.iconQueue:Resize()
            end
        end
    end
end

-- Update unit settings when settings change
function M:UpdateUnits()
    if _G.VUITGCD and _G.VUITGCD.units then
        -- Enable/disable units based on settings
        local settings = self.db.profile
        
        -- Apply settings to units
        -- Implement as needed
    end
end

-- Update visibility based on location
function M:UpdateVisibility()
    -- Safe access to locationCheck with proper namespace
    local locationCheck = _G.VUITGCD and _G.VUITGCD.locationCheck
    
    -- Call settingsChanged if available
    if locationCheck and type(locationCheck.settingsChanged) == "function" then
        pcall(function()
            locationCheck.settingsChanged()
        end)
    end
    
    -- Handle location-specific settings
    local instanceType = select(2, IsInInstance())
    local settings = self.db and self.db.profile or {}
    
    -- Safe access to visibility settings
    local showInWorld = settings.showInWorld
    local showInInstances = settings.showInInstances
    local showInPVP = settings.showInPVP
    
    -- Default to showing if settings are nil
    if showInWorld == nil then showInWorld = true end
    if showInInstances == nil then showInInstances = true end
    if showInPVP == nil then showInPVP = true end
    
    local shouldShow = true
    
    if (instanceType == "none" and not showInWorld) or
       (instanceType == "party" and not showInInstances) or
       (instanceType == "raid" and not showInInstances) or
       ((instanceType == "pvp" or instanceType == "arena") and not showInPVP) then
        shouldShow = false
    end
    
    -- Implement show/hide logic (placeholder)
    -- This should be implemented based on how the module actually shows/hides elements
    if shouldShow then
        -- Show icons (placeholder)
        VUI:Debug("VUITGCD", "Showing icons in " .. (instanceType or "unknown") .. " instance")
    else
        -- Hide icons (placeholder)
        VUI:Debug("VUITGCD", "Hiding icons in " .. (instanceType or "unknown") .. " instance")
    end
end

-- Configuration initialization
function M:InitializeConfig()
    -- Register with VUI's configuration system
    if VUI and VUI.Config and VUI.Config.RegisterModuleOptions then
        VUI.Config:RegisterModuleOptions(self.NAME, function()
            -- Open the configuration panel
            if self.OpenConfig then
                self:OpenConfig()
            end
        end)
    end
end

-- Export the module to the namespace
VUI.VUITGCD = M

-- Slash command handler
function M:SlashCommand(input)
    if input == "toggle" then
        self.db.profile.enabled = not self.db.profile.enabled
        if VUI and type(VUI.Print) == "function" then
            VUI:Print("|cff33bbff[VUITGCD]|r " .. (self.db.profile.enabled and "Enabled" or "Disabled"))
        else
            print("|cff33bbff[VUITGCD]|r " .. (self.db.profile.enabled and "Enabled" or "Disabled"))
        end
    elseif input == "config" or input == "options" then
        -- Open configuration
        if VUI and VUI.Config and type(VUI.Config.OpenToCategory) == "function" then
            VUI.Config:OpenToCategory(self.TITLE)
        end
    else
        -- Help text
        print("|cff33bbff[VUITGCD]|r Available commands:")
        print("  toggle - Enable or disable the addon")
        print("  config - Open configuration panel")
    end
end