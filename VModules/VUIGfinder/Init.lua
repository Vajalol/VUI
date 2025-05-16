-------------------------------------------------------------------------------
-- VUI Gfinder (based on PGFinder)
-- Module for VUI - Vortex UI Addon Suite
-------------------------------------------------------------------------------

-- Initialize the module safely with graceful fallback if VUI is not available
local AddonName, _ = ...
-- Use global reference instead of local addon variable to fix load order issues
local VUI = _G["VUI"]

-- Set up global reference early to prevent nil errors
_G["VUIGfinder"] = _G["VUIGfinder"] or {}
-- Create alias for backward compatibility
_G["VUIFinder"] = _G["VUIGfinder"]

local Module 

-- Setup fallback and make sure we can integrate with VUI if it exists
if VUI and VUI.NewModule then
    Module = VUI:NewModule("VUIGfinder", "AceEvent-3.0", "AceHook-3.0")
    -- Update the global reference with the actual module
    _G["VUIGfinder"] = Module
else
    -- Create a basic module structure if VUI isn't available or doesn't have NewModule
    Module = {}
    Module.NAME = "VUIGfinder"
    Module.Debug = function(self, msg) print("[VUIGfinder] " .. tostring(msg)) end
    Module.OnInitialize = function() end
    Module.OnEnable = function() end
    Module.RegisterEvent = function() end
    Module.UnregisterEvent = function() end
    
    -- If VUI exists but NewModule doesn't, try to create an integrated namespace
    if VUI then
        VUI.VUIGfinder = Module
    end
    
    -- Update the global reference with our placeholder
    _G["VUIGfinder"] = Module
end

-- Ensure module has a valid NAME property for namespace registration
Module.NAME = Module.NAME or "VUIGfinder"

-- Store additional properties in the global namespace for backward compatibility
VUIGfinder = _G["VUIGfinder"]
VUIGfinder.Module = Module
Module.Debug = VUIGfinder.Debug or function(self, msg) print("[VUIGfinder] " .. tostring(msg)) end

-- Localization
PGFinderLocals = PGFinderLocals or {} -- This will be filled by localization files
VUIGfinder.L = PGFinderLocals
local L = VUIGfinder.L or {}

-- Module configuration defaults
local defaults = {
    profile = {
        enabled = true,
        autoEnable = true,
        minimap = {
            hide = false,
        },
        theme = {
            useVUITheme = true,
        },
        filter = {
            dungeon = true,
            raid = true,
            arena = true,
            custom = true,
            other = true,
        },
        advanced = {
            minimumWaitTime = 3,
            oneClickSignup = true,
            useDefaultRole = true,
            showRoleFilterButtons = true,
            autoRefresh = true,
            autoRefreshTime = 5,
            keepUnmodified = false,
            playSoundOnRefresh = true,
            playSoundFile = "ui_pveframe_playerenter",
        },
        defaultFilters = {
            remember = true,
            minMythicPlusLevel = 2,
            maxMythicPlusLevel = 30,
            minRating = 0,
            maxRating = 3000,
        },
        ui = {
            dialogScale = 1.0,
        },
    }
}

-- Create fallback database if VUI database functions aren't available
local function CreateFallbackDB()
    return {
        profile = defaults.profile,
        RegisterNamespace = function() return {profile = defaults.profile} end
    }
end

-- Module initialization
function Module:OnInitialize()
    -- Register database
    if VUI and VUI.db then
        -- Ensure namespaces table exists to avoid nil indexing
        if not VUI.db.namespaces then
            VUI.db.namespaces = {}
        end
        
        -- Check if a namespace already exists
        if VUI.db.namespaces[self.NAME] then
            self.db = VUI.db.namespaces[self.NAME]
        else
            -- Create new namespace
            self.db = VUI.db:RegisterNamespace(self.NAME, {
                profile = defaults.profile
            })
        end
    else
        -- Create a local fallback database if VUI.db isn't available
        self.db = {profile = defaults.profile}
    end
    
    -- Set up theme color access
    VUIGfinder.GetThemeColor = function()
        if Module.db and Module.db.profile and Module.db.profile.theme and Module.db.profile.theme.useVUITheme then
            if VUI and VUI.GetThemeColor then
                local color = VUI:GetThemeColor()
                return color.r, color.g, color.b
            end
        end
        return 0.0, 0.44, 0.87 -- Default PGFinder blue
    end
    
    -- Debug message
    if VUI and VUI.Debug then
        VUI:Debug("VUIGfinder initialized")
    else
        print("[VUIGfinder] initialized")
    end
end

-- Enable module
function Module:OnEnable()
    -- Will continue the setup
    if self.RegisterEvent then
        self:RegisterEvent("PLAYER_ENTERING_WORLD")
    else
        -- Fallback if RegisterEvent isn't available
        local frame = CreateFrame("Frame")
        frame:RegisterEvent("PLAYER_ENTERING_WORLD")
        frame:SetScript("OnEvent", function(_, event)
            if event == "PLAYER_ENTERING_WORLD" then
                Module:PLAYER_ENTERING_WORLD()
            end
        end)
    end
    
    -- Register slash commands
    SLASH_VUIGFINDER1 = "/vuigfinder"
    SLASH_VUIGFINDER2 = "/vgf"
    SlashCmdList["VUIGFINDER"] = function(msg)
        if VUIGfinder.ToggleUI then
            VUIGfinder.ToggleUI()
        end
    end
    
    -- For compatibility with original PGFinder
    SLASH_PREMADEGROUPFINDER1 = "/pgf"
    SLASH_PREMADEGROUPFINDER2 = "/premadefinder"
    SLASH_PREMADEGROUPFINDER3 = "/premadegroupfinder"
    SlashCmdList["PREMADEGROUPFINDER"] = function(msg)
        if VUIGfinder.ToggleUI then
            VUIGfinder.ToggleUI()
        end
    end
end

-- Continue initialization when player enters world
function Module:PLAYER_ENTERING_WORLD()
    if self.db and self.db.profile and self.db.profile.enabled then
        -- Initialize filter system
        if VUIGfinder.InitializeFilter then
            VUIGfinder.InitializeFilter()
        end
        
        -- Initialize UI
        if VUIGfinder.InitializeUI then
            VUIGfinder.InitializeUI()
        end
        
        -- Initialize minimap button
        if VUIGfinder.InitializeMinimapButton then
            VUIGfinder.InitializeMinimapButton()
        end
        
        -- Register with LFG system - hook search results
        if self.RegisterEvent then
            self:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED")
        else
            -- Fallback for event registration
            local frame = CreateFrame("Frame")
            frame:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED")
            frame:SetScript("OnEvent", function()
                Module:LFG_LIST_SEARCH_RESULTS_RECEIVED()
            end)
        end
        
        -- Hook into search panel update
        if hooksecurefunc then
            hooksecurefunc("LFGListSearchPanel_UpdateResults", function(panel)
                if VUIGfinder.FilterSearchResults then
                    VUIGfinder.FilterSearchResults(panel)
                end
            end)
        end
        
        -- Register with VUI theme system
        if VUI and VUI.RegisterCallback then
            VUI:RegisterCallback("OnThemeChanged", function()
                if Module.db and Module.db.profile and Module.db.profile.theme and Module.db.profile.theme.useVUITheme then
                    if VUIGfinder.ApplyUITheme then
                        VUIGfinder.ApplyUITheme()
                    end
                end
            end)
        end
    end
    
    -- Unregister this event as we only need it once
    if self.UnregisterEvent then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end

-- Handle search results event
function Module:LFG_LIST_SEARCH_RESULTS_RECEIVED()
    -- Apply our filtering when results are received
    if self.db and self.db.profile and self.db.profile.enabled and VUIGfinder.FilterSearchResults then
        VUIGfinder.FilterSearchResults(LFGListFrame.SearchPanel)
    end
end

-- Debug function for module
function Module:Debug(msg)
    if VUI and VUI.Debug then
        VUI:Debug("[VUIGfinder] " .. tostring(msg))
    else
        print("[VUIGfinder] " .. tostring(msg))
    end
end