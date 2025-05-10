-------------------------------------------------------------------------------
-- VUI Gfinder (based on PGFinder)
-- Module for VUI - Vortex UI Addon Suite
-------------------------------------------------------------------------------

-- Initialize the module and integrate with VUI
local AddonName, VUI = ...
local Module = VUI:NewModule("VUIGfinder", "AceEvent-3.0", "AceHook-3.0")

-- Set up global namespace for the module (useful for debugging)
_G.VUIGfinder = {}
VUIGfinder.Module = Module
Module.Debug = VUIGfinder

-- Localization
PGFinderLocals = {} -- This will be filled by localization files
VUIGfinder.L = PGFinderLocals
local L = VUIGfinder.L

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

-- Module initialization
function Module:OnInitialize()
    -- Register database
    self.db = VUI.db:RegisterNamespace("VUIGfinder", defaults)
    
    -- Set up theme color access
    VUIGfinder.GetThemeColor = function()
        if Module.db.profile.theme.useVUITheme then
            local color = VUI:GetThemeColor()
            return color.r, color.g, color.b
        else
            return 0.0, 0.44, 0.87 -- Default PGFinder blue
        end
    end
    
    -- Debug message
    VUI:Debug("VUIGfinder initialized")
end

-- Enable module
function Module:OnEnable()
    -- Will continue the setup
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    
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
    if self.db.profile.enabled then
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
        self:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED")
        
        -- Hook into search panel update
        hooksecurefunc("LFGListSearchPanel_UpdateResults", function(panel)
            if VUIGfinder.FilterSearchResults then
                VUIGfinder.FilterSearchResults(panel)
            end
        end)
        
        -- Register with VUI theme system
        VUI:RegisterCallback("OnThemeChanged", function()
            if Module.db.profile.theme.useVUITheme then
                if VUIGfinder.ApplyUITheme then
                    VUIGfinder.ApplyUITheme()
                end
            end
        end)
    end
    
    -- Unregister this event as we only need it once
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

-- Handle search results event
function Module:LFG_LIST_SEARCH_RESULTS_RECEIVED()
    -- Apply our filtering when results are received
    if self.db.profile.enabled and VUIGfinder.FilterSearchResults then
        VUIGfinder.FilterSearchResults(LFGListFrame.SearchPanel)
    end
end

-- Debug function for module
function Module:Debug(msg)
    if VUI.Debug then
        VUI:Debug("[VUIGfinder] " .. tostring(msg))
    end
end