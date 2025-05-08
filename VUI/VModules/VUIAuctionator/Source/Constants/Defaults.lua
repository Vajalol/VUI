local addonName, VUI = ...
local Auctionator = VUI.Auctionator

Auctionator.Constants.Defaults = {
  -- Profile defaults
  PROFILE = {
    -- Minimap icon
    MINIMAP = {
      hide = false,
      minimapPos = 220,
    },
    
    -- Config panel
    CONFIG = {
      AUCTION_CHAT_LOG = true,
      AUCTION_SALES_PREFERENCE = "static",
      DEFAULT_LIST = Auctionator.L("AUCTIONATOR"),
      DEFAULT_QUANTITIES = { 
        [1] = 1, 
        [5] = 10, 
        [10] = 20 
      },
      DEFAULT_TAB = 0,
      ENCHANT_TOOLTIPS = true,
      SELLING_BAG_COLLAPSED = false,
      SELLING_BAG_SELECT_SHORTCUT = true,
      SELLING_CANCEL_SHORTCUT = true,
      SELLING_CONFIRM_LOW_PRICE = true,
      SELLING_DEFAULT_QUANTITY_PREFERENCE = "last",
      SELLING_FAVOURITE_KEYS_SHORTCUT = true,
      SELLING_GREY_POST_BUTTON = true,
      SELLING_ICON_SIZE = 42,
      SELLING_MISSING_FAVOURITES = false,
      SELLING_POST_SHORTCUT = true,
      SELLING_PREVIOUS_BAG_POSITION = 1,
      SELLING_SKIP_SHORTCUT = true,
      SHOW_SELLING_PRICE_HISTORY = true,
      LIFO_UNDERCUT_STATIC_VALUE = 0,
      UNDERCUT_PERCENTAGE = 0,
      UNDERCUT_SCAN_NOT_LIFO = true,
      UNDERCUT_STATIC_VALUE = 1,
    },
    
    -- Tooltip settings
    TOOLTIP = {
      SHOW_SALE_PRICE = true,
      SHOW_VENDOR_PRICE = true,
      VENDOR_PRICE_DAYS = 7,
      TIPS_MODIFIER = false,
      TIPS_FADE = true,
      TOOLTIP_SHOPPING_PRICE = "max",
      TOOLTIP_ANCHOR_TO_CURSOR = false,
      TOOLTIP_ANCHOR_PREFERENCE = Auctionator.Constants.TOOLTIP_ANCHOR.RIGHT,
    },
    
    -- Shopping settings
    SHOPPING = {
      FULL_SCAN_STEP = 250,
      FULL_SCAN_ENABLED = true,
      AUTO_LIST_SEARCH = true,
      LIST_BROWSE_SEARCH = true,
      SHOPPING_LIST_MISSING_TERMS = false,
      SHOPPING_LIST_RECENT_SEARCHES = 25,
    },
    
    -- Selling settings
    SELLING = {
      GEAR_PRICE_MULTIPLIER = 0,
      AUTO_SELECT_NEXT = false,
      SHOW_SECOND_PRICE = false,
      SORT_FAVOURITES_FIRST = true,
      HISTORICAL_PRICES = 20,
      STACK_SIZE_MEMORY = {}, -- Per item stack memory
      DURATION_MEMORY = {}, -- Per item duration memory
    },
    
    -- Cancelling settings
    CANCELLING = {
      CANCEL_UNDERCUT = true,
      CALCULATE_POST_PRICE = true,
      INCLUDE_SHOPPING_LISTS = true,
    },
    
    -- Crafting info settings
    CRAFTING_INFO = {
      SHOW_COST = true,
      SHOW_PROFIT = true,
    },
    
    -- Database settings
    DATABASE = {
      AUTO_PURGE_TIME = Auctionator.Constants.TIME.MONTH * 3, -- Purge prices older than 3 months
      DEPOSIT_ALERT_FREQUENCY = Auctionator.Constants.TIME.DAY,
      COLUMNS = {
        { ["sortOrder"] = 0, ["column"] = "price", ["ascending"] = true },
        { ["sortOrder"] = 1, ["column"] = "per_item", ["ascending"] = true },
        { ["sortOrder"] = 2, ["column"] = "stackSize", ["ascending"] = true },
        { ["sortOrder"] = 3, ["column"] = "name", ["ascending"] = true },
        { ["sortOrder"] = 4, ["column"] = "quantity", ["ascending"] = true },
        { ["sortOrder"] = 5, ["column"] = "otherTime", ["ascending"] = true },
        { ["sortOrder"] = 6, ["column"] = "owner", ["ascending"] = true },
      },
    }
  }
}