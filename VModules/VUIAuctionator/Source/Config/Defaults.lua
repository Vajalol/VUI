local addonName, VUI = ...
local Auctionator = VUI.Auctionator

Auctionator.Config = Auctionator.Config or {}

-- Define configuration option keys
Auctionator.Config.Options = {
  -- General settings
  AUTOSCAN_ON_OPEN = "autoscan_on_open",
  OPEN_FIRST_AUCTION_WHEN_SEARCHING = "open_first_auction_when_searching",
  DEFAULT_TAB = "default_tab",
  AUCTION_CHAT_LOG = "auction_chat_log",
  SHOW_SELLING_PRICE_HISTORY = "show_selling_price_history",
  SELLING_BAG_COLLAPSED = "selling_bag_collapsed",
  SELLING_BAG_SELECT_SHORTCUT = "selling_bag_select_shortcut",
  SELLING_ICON_SIZE = "selling_icon_size",
  SELLING_IGNORED_KEYS = "selling_ignored_keys",
  SELLING_FAVOURITE_KEYS = "selling_favourite_keys",
  SELLING_AUTO_SELECT_NEXT = "selling_auto_select_next",
  SELLING_MISSING_FAVOURITES = "selling_missing_favourites",
  SELLING_POST_SHORTCUT = "selling_post_shortcut",
  LIFO_AUCTION_SORT = "lifo_auction_sort", 
  
  -- Cancelling tab
  CANCEL_UNDERCUT_SHORTCUT = "cancel_undercut_shortcut",
  NO_PRICE_DATABASE = "no_price_database",
  PRICE_HISTORY_DAYS = "price_history_days",
  FEATURE_SELLING_1 = "feature_selling_1",
  
  -- Tooltip settings
  TOOLTIP_MARKET_VALUE = "tooltip_market_value",
  TOOLTIP_HISTORICAL_PRICE = "tooltip_historical_price",
  TOOLTIP_VENDOR_PRICE = "tooltip_vendor_price",
  HIDE_VENDOR_TIPS = "hide_vendor_tips",
  
  -- Price settings
  UNDERCUT_PERCENTAGE = "undercut_percentage",
  UNDERCUT_STATIC_VALUE = "undercut_static_value",
  
  -- Database settings
  AUTO_PURGE_OLD_PRICES = "auto_purge_old_prices",
  CLEAR_CURSOR_ON_CLICK = "clear_cursor",
  STACK_SIZE_MEMORY = "stack_size_memory",
}

-- Default settings
Auctionator.Config.Defaults = {
  -- General
  [Auctionator.Config.Options.AUTOSCAN_ON_OPEN] = true,
  [Auctionator.Config.Options.OPEN_FIRST_AUCTION_WHEN_SEARCHING] = true,
  [Auctionator.Config.Options.DEFAULT_TAB] = 0,
  [Auctionator.Config.Options.AUCTION_CHAT_LOG] = true,
  [Auctionator.Config.Options.SELLING_BAG_COLLAPSED] = false,
  [Auctionator.Config.Options.SELLING_BAG_SELECT_SHORTCUT] = "alt-click",
  [Auctionator.Config.Options.SELLING_ICON_SIZE] = 42,
  [Auctionator.Config.Options.SELLING_IGNORED_KEYS] = {},
  [Auctionator.Config.Options.SELLING_FAVOURITE_KEYS] = {},
  [Auctionator.Config.Options.SELLING_AUTO_SELECT_NEXT] = true,
  [Auctionator.Config.Options.SELLING_MISSING_FAVOURITES] = true,
  [Auctionator.Config.Options.SELLING_POST_SHORTCUT] = "enter",
  [Auctionator.Config.Options.LIFO_AUCTION_SORT] = false,
  
  -- Cancelling tab
  [Auctionator.Config.Options.CANCEL_UNDERCUT_SHORTCUT] = "alt-right-click",
  [Auctionator.Config.Options.NO_PRICE_DATABASE] = false,
  [Auctionator.Config.Options.PRICE_HISTORY_DAYS] = 21,
  [Auctionator.Config.Options.FEATURE_SELLING_1] = true,
  
  -- Tooltip
  [Auctionator.Config.Options.TOOLTIP_MARKET_VALUE] = true,
  [Auctionator.Config.Options.TOOLTIP_HISTORICAL_PRICE] = true,
  [Auctionator.Config.Options.TOOLTIP_VENDOR_PRICE] = true,
  [Auctionator.Config.Options.HIDE_VENDOR_TIPS] = true,
  
  -- Price settings
  [Auctionator.Config.Options.UNDERCUT_PERCENTAGE] = 0,
  [Auctionator.Config.Options.UNDERCUT_STATIC_VALUE] = 1,
  
  -- Database settings
  [Auctionator.Config.Options.AUTO_PURGE_OLD_PRICES] = true,
  [Auctionator.Config.Options.CLEAR_CURSOR_ON_CLICK] = false,
  [Auctionator.Config.Options.STACK_SIZE_MEMORY] = {},
}

-- Get a configuration value
function Auctionator.Config.Get(option)
  if VUI_SavedVariables.VUIAuctionator == nil then
    VUI_SavedVariables.VUIAuctionator = {}
  end
  
  -- Check if the option exists in the saved variables
  if VUI_SavedVariables.VUIAuctionator[option] ~= nil then
    return VUI_SavedVariables.VUIAuctionator[option]
  end
  
  -- Return the default value
  return Auctionator.Config.Defaults[option]
end

-- Set a configuration value
function Auctionator.Config.Set(option, value)
  if VUI_SavedVariables.VUIAuctionator == nil then
    VUI_SavedVariables.VUIAuctionator = {}
  end
  
  VUI_SavedVariables.VUIAuctionator[option] = value
  
  -- Trigger a configuration changed event
  if Auctionator.EventBus then
    Auctionator.EventBus:Fire({}, Auctionator.Config.Events.CONFIG_CHANGED, option, value)
  end
end

-- Reset a configuration option to default
function Auctionator.Config.Reset(option)
  Auctionator.Config.Set(option, Auctionator.Config.Defaults[option])
end

-- Reset all configuration options to defaults
function Auctionator.Config.ResetAll()
  VUI_SavedVariables.VUIAuctionator = {}
  
  -- Copy all defaults
  for option, value in pairs(Auctionator.Config.Defaults) do
    VUI_SavedVariables.VUIAuctionator[option] = value
  end
  
  -- Trigger a full config reset event
  if Auctionator.EventBus then
    Auctionator.EventBus:Fire({}, Auctionator.Config.Events.CONFIG_RESET)
  end
end

-- Configuration events
Auctionator.Config.Events = {
  CONFIG_CHANGED = "config_changed",
  CONFIG_RESET = "config_reset",
}

-- Initialize the config when the addon loads
function Auctionator.Config.Initialize()
  -- Ensure VUI_SavedVariables exists
  if VUI_SavedVariables == nil then
    VUI_SavedVariables = {}
  end
  
  -- Ensure VUIAuctionator config exists
  if VUI_SavedVariables.VUIAuctionator == nil then
    VUI_SavedVariables.VUIAuctionator = {}
  end
  
  -- Migrate any existing Auctionator settings if necessary
  -- (This would be implemented if migrating from original Auctionator)
  
  -- Apply any missing defaults
  for option, defaultValue in pairs(Auctionator.Config.Defaults) do
    if VUI_SavedVariables.VUIAuctionator[option] == nil then
      VUI_SavedVariables.VUIAuctionator[option] = defaultValue
    end
  end
end