-------------------------------------------------------------------------------
-- VUIAuctionator Module
-- Enhanced auction house interface with VUI integration
-- Based on Auctionator with VUI theming
-------------------------------------------------------------------------------

local AddonName, VUI = ...
local MODNAME = "VUIAuctionator"
local M = VUI:NewModule(MODNAME, "AceEvent-3.0", "AceConsole-3.0")

-- Module Constants
M.NAME = MODNAME
M.TITLE = "VUI Auctionator"
M.DESCRIPTION = "Enhanced auction house interface with VUI theming"
M.VERSION = "1.0"

-- Create namespace in VUI for legacy compatibility
VUI.Auctionator = VUI.Auctionator or {}
local Auctionator = VUI.Auctionator

-- Default settings
M.defaults = {
    profile = {
        -- General
        autoscan_on_open = true,
        open_first_auction_when_searching = true,
        default_tab = 0,
        auction_chat_log = true,
        selling_bag_collapsed = false,
        selling_bag_select_shortcut = "alt-click",
        selling_icon_size = 42,
        selling_ignored_keys = {},
        selling_favourite_keys = {},
        selling_auto_select_next = true,
        selling_missing_favourites = true,
        selling_post_shortcut = "enter",
        lifo_auction_sort = false,
        
        -- Cancelling tab
        cancel_undercut_shortcut = "alt-right-click",
        no_price_database = false,
        price_history_days = 21,
        feature_selling_1 = true,
        
        -- Tooltip
        tooltip_market_value = true,
        tooltip_historical_price = true,
        tooltip_vendor_price = true,
        hide_vendor_tips = true,
        
        -- Price settings
        undercut_percentage = 0,
        undercut_static_value = 1,
        
        -- Database settings
        auto_purge_old_prices = true,
        clear_cursor_on_click = false,
        stack_size_memory = {},
    }
}

-- Initialize the module
function M:OnInitialize()
    -- Create the database using AceDB
    self.db = VUI.db:RegisterNamespace(self.NAME, {
        profile = self.defaults.profile
    })
    
    -- Connect the new DB to the Auctionator config system
    Auctionator.db = self.db
    
    -- Initialize the configuration panel
    self:InitializeConfig()
    
    -- Register callback for theme changes
    VUI:RegisterCallback("OnThemeChanged", function()
        if self.UpdateTheme then
            self:UpdateTheme()
        end
    end)
    
    -- Initialize Auctionator components
    self:InitializeComponents()
    
    -- Register slash command
    self:RegisterChatCommand("vuiah", "SlashCommand")
    
    -- Legacy support
    self:RegisterChatCommand("auc", "SlashCommand")
    
    -- Debug message
    VUI:Debug(self.NAME .. " initialized")
end

-- Enable the module
function M:OnEnable()
    -- Register core events
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("AUCTION_HOUSE_SHOW")
    self:RegisterEvent("AUCTION_HOUSE_CLOSED")
    
    -- Debug message
    VUI:Debug(self.NAME .. " enabled")
end

-- Disable the module
function M:OnDisable()
    -- Unregister all events
    self:UnregisterAllEvents()
    
    -- Debug message
    VUI:Debug(self.NAME .. " disabled")
end

-- Initialize components
function M:InitializeComponents()
    -- Create event bus first
    if Auctionator.CreateEventBuses then
        Auctionator.CreateEventBuses()
    end
    
    -- Initialize config system (will use our AceDB now)
    if Auctionator.Config and Auctionator.Config.InitializeFromAceDB then
        Auctionator.Config.InitializeFromAceDB(self.db.profile)
    elseif Auctionator.Config and Auctionator.Config.Initialize then
        -- Legacy method (will be updated to use AceDB)
        Auctionator.Config.Initialize()
    end
    
    -- Initialize AH system
    if Auctionator.AH and Auctionator.AH.Initialize then
        Auctionator.AH.Initialize()
    end
end

-- Configuration initialization
function M:InitializeConfig()
    -- Register with VUI's configuration system
    VUI.Config:RegisterModuleOptions(self.NAME, function()
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

-- Debug helper
function M:Debug(...)
    VUI:Debug(self.NAME, ...)
end

-- Export the module to the namespace
VUI.VUIAuctionator = M