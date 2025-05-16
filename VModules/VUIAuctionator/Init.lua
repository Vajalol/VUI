-------------------------------------------------------------------------------
-- VUIAuctionator Module
-- Enhanced Auction House Interface for WoW
-------------------------------------------------------------------------------

local AddonName, _ = ...
local MODNAME = "VUIAuctionator"

-- Use global reference instead of local addon variable to fix load order issues
local VUI = _G["VUI"]

-- Set up global reference early to prevent nil errors
_G["VUIAuctionator"] = _G["VUIAuctionator"] or {}

local M

-- Create module with safety checks
if VUI and VUI.NewModule then
    M = VUI:NewModule(MODNAME, "AceEvent-3.0", "AceHook-3.0")
    -- Update the global reference with the actual module
    _G["VUIAuctionator"] = M
else
    -- Fallback if VUI isn't available
    M = {}
    M.NAME = MODNAME
    M.Debug = function(self, msg) print("[VUIAuctionator] " .. tostring(msg)) end
    M.OnInitialize = function() end
    M.OnEnable = function() end
    
    -- Update the global reference with our placeholder
    _G["VUIAuctionator"] = M
end

-- Module Constants
M.NAME = MODNAME
M.TITLE = "VUI Auctionator"
M.DESCRIPTION = "Enhanced auction house interface"
M.VERSION = "1.0"

-- Initialize namespace early to prevent errors
VUI.Auctionator = VUI.Auctionator or {}
local Auctionator = VUI.Auctionator

-- Initialize all required namespaces
Auctionator.Constants = Auctionator.Constants or {}
Auctionator.Database = Auctionator.Database or {}
Auctionator.Locales = Auctionator.Locales or {}
Auctionator.Utilities = Auctionator.Utilities or {}
Auctionator.Config = Auctionator.Config or {}
Auctionator.Selling = Auctionator.Selling or {}
Auctionator.Buying = Auctionator.Buying or {}
Auctionator.Cancelling = Auctionator.Cancelling or {}
Auctionator.Shopping = Auctionator.Shopping or {}
Auctionator.FullScan = Auctionator.FullScan or {}
Auctionator.Tabs = Auctionator.Tabs or {}
Auctionator.API = Auctionator.API or {}

-- Default settings
M.defaults = {
    profile = {
        enabled = true,
        defaultTab = "Selling",
        
        minimap = {
            hide = false,
            position = 45
        },
        
        appearance = {
            showTooltips = true,
            defaultListSortOrder = "name_asc",
            colorHighlights = true
        },
        
        selling = {
            showOwnAuctions = true,
            defaultDuration = 24,
            autoSellPrices = {},
            defaultStackSize = 0  -- 0 means max
        },
        
        shopping = {
            defaultListName = "My Shopping List"
        }
    }
}

-- Initialize the module
function M:OnInitialize()
    -- Create the database with consistent naming
    if VUI and VUI.db then
        -- Check if a namespace already exists with any of the possible names
        local namespace = VUI.db.namespaces["VUIAuctionator"] or VUI.db.namespaces["vuiauctionator"]
        
        if namespace then
            -- Use existing namespace
            self.db = namespace
            
            -- Ensure both versions are synchronized
            VUI.db.namespaces["VUIAuctionator"] = namespace
            VUI.db.namespaces["vuiauctionator"] = namespace
        else
            -- Create new namespace with proper case for consistency
            self.db = VUI.db:RegisterNamespace("VUIAuctionator", {
                profile = self.defaults.profile
            })
            
            -- Also create lowercase reference for compatibility
            VUI.db.namespaces["vuiauctionator"] = self.db
        end
    else
        -- Fallback if VUI.db isn't available
        self.db = {profile = self.defaults.profile}
    end
    
    -- Initialize the configuration panel
    self:InitializeConfig()
    
    -- Register callback for theme changes
    if VUI and VUI.RegisterCallback then
        VUI:RegisterCallback("OnThemeChanged", function()
            if self.UpdateTheme then
                self:UpdateTheme()
            end
        end)
    end
    
    -- Debug message
    if VUI and VUI.Debug then
        VUI:Debug(self.NAME .. " initialized")
    else
        print("[VUIAuctionator] initialized")
    end
end

-- Enable the module
function M:OnEnable()
    -- Register core events
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    
    -- Debug message
    if VUI and VUI.Debug then
        VUI:Debug(self.NAME .. " enabled")
    else
        print("[VUIAuctionator] enabled")
    end
end

-- Disable the module
function M:OnDisable()
    -- Unregister all events
    self:UnregisterAllEvents()
    
    -- Debug message
    if VUI and VUI.Debug then
        VUI:Debug(self.NAME .. " disabled")
    else
        print("[VUIAuctionator] disabled")
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
VUI.VUIAuctionator = M