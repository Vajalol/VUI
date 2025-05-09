local addonName, VUI = ...
local Auctionator = VUI.Auctionator

-- General constants
Auctionator.Constants = {
  -- Current version
  CURRENT_VERSION = "1.0.0",
  
  -- DB keys
  DB_KEYS = {
    PRICE_DB = "AUCTIONATOR_PRICE_DATABASE",
    POSTING_HISTORY = "AUCTIONATOR_POSTING_HISTORY",
    VENDOR_PRICE_CACHE = "AUCTIONATOR_VENDOR_PRICE_CACHE",
    CONFIG = "AUCTIONATOR_CONFIG",
    CHARACTER_CONFIG = "AUCTIONATOR_CHARACTER_CONFIG",
    SHOPPING_LISTS = "AUCTIONATOR_SHOPPING_LISTS",
    SAVED_VARS = "AUCTIONATOR_SAVEDVARS",
    RECENT_SEARCHES = "AUCTIONATOR_RECENT_SEARCHES",
    SELLING_GROUPS = "AUCTIONATOR_SELLING_GROUPS"
  },
  
  -- Max search results
  MAX_SEARCH_RESULTS = 100,
  
  -- Max scan duration
  MAX_SCAN_DURATION = 60,
  
  -- Debounce interval (seconds)
  DEBOUNCE_INTERVAL = 0.5,
  
  -- Events
  EVENTS = {
    -- AH
    AH_READY = "AUCTIONATOR_AH_READY",
    -- DB
    DB_SCAN_COMPLETE = "AUCTIONATOR_DB_SCAN_COMPLETE",
    -- Scan
    FULL_SCAN_START = "AUCTIONATOR_FULL_SCAN_START",
    FULL_SCAN_COMPLETE = "AUCTIONATOR_FULL_SCAN_COMPLETE",
    -- Buying
    BUY_ITEM = "AUCTIONATOR_BUY_ITEM",
    BUY_ITEM_SUCCEEDED = "AUCTIONATOR_BUY_ITEM_SUCCEEDED",
    BUY_ITEM_FAILED = "AUCTIONATOR_BUY_ITEM_FAILED",
    -- Selling
    SELLING_BAG_ITEM_CLICKED = "AUCTIONATOR_SELLING_BAG_ITEM_CLICKED",
    SELLING_BAG_SHOW = "AUCTIONATOR_SELLING_BAG_SHOW",
    SELLING_POST_ATTEMPT = "AUCTIONATOR_SELLING_POST_ATTEMPT",
    SELLING_POST_SUCCESS = "AUCTIONATOR_SELLING_POST_SUCCESS",
    -- Cancelling
    CANCELLING_LIST_UPDATE = "AUCTIONATOR_CANCELLING_LIST_UPDATE",
    CANCEL_AUCTION = "AUCTIONATOR_CANCEL_AUCTION",
  },
  
  -- Item quality IDs
  ITEM_QUALITY_IDS = {
    Poor = 0,
    Common = 1,
    Uncommon = 2,
    Rare = 3,
    Epic = 4,
    Legendary = 5,
    Artifact = 6,
    Heirloom = 7,
  },
  
  -- Item quality colors
  ITEM_QUALITY_COLORS = {
    [0] = "9d9d9d", -- Poor (gray)
    [1] = "ffffff", -- Common (white)
    [2] = "1eff00", -- Uncommon (green)
    [3] = "0070dd", -- Rare (blue)
    [4] = "a335ee", -- Epic (purple)
    [5] = "ff8000", -- Legendary (orange)
    [6] = "e6cc80", -- Artifact (light gold)
    [7] = "00ccff", -- Heirloom (light blue)
  },
  
  -- Tooltip anchor positions
  TOOLTIP_ANCHOR = {
    LEFT = 1,
    RIGHT = 2,
    TOP = 3,
    BOTTOM = 4,
  },
  
  -- Media path function
  MEDIA_PATH = function(file)
    return "Interface\\AddOns\\VUI\\Media\\modules\\VUIAuctionator\\" .. file
  end,
  
  -- Time constants
  TIME = {
    MINUTE = 60,
    HOUR = 60 * 60,
    DAY = 60 * 60 * 24,
    MONTH = 60 * 60 * 24 * 30,
    YEAR = 60 * 60 * 24 * 365,
  },
  
  -- Sort directions
  SORT = {
    ASCENDING = 1,
    DESCENDING = 2,
  },
  
  -- Pages
  PAGES = {
    DEFAULT_PAGE_SIZE = 50,
  },
}