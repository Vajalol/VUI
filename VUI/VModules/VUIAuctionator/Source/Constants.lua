local addonName, VUI = ...
local Auctionator = VUI.Auctionator

Auctionator.Constants = {
  -- Addon information
  ADDON_NAME = "VUIAuctionator",
  ADDON_DESCRIPTION = "Advanced auction house tools for managing auctions, sales, and economy",
  ADDON_VERSION = "1.0.0", -- Initial version
  
  -- Item quality colors
  ITEM_QUALITY_COLORS = {
    [0] = "9d9d9d", -- Poor (Gray)
    [1] = "ffffff", -- Common (White)
    [2] = "1eff00", -- Uncommon (Green)
    [3] = "0070dd", -- Rare (Blue)
    [4] = "a335ee", -- Epic (Purple)
    [5] = "ff8000", -- Legendary (Orange)
    [6] = "e6cc80", -- Artifact (Light Gold)
    [7] = "00ccff", -- Heirloom (Light Blue)
    [8] = "00ccff"  -- WoW Token (Light Blue)
  },
  
  -- Auction durations
  AUCTION_DURATIONS = {
    [1] = {"Short", 12},
    [2] = {"Medium", 24},
    [3] = {"Long", 48}
  },
  
  -- Time left constants
  TIME_LEFT = {
    SHORT = 1,   -- Less than 30m
    MEDIUM = 2,  -- Less than 2h
    LONG = 3,    -- Less than 12h in retail, 8h in classic
    VERY_LONG = 4 -- Less than 48h in retail, 24h in classic
  },
  
  -- Maximum number of prices to keep in price history
  PRICE_HISTORY_LENGTH = 100,
  
  -- Default undercut percentage
  DEFAULT_UNDERCUT_PERCENTAGE = 5,
  
  -- Default stack sizes
  DEFAULT_STACK_SIZES = {5, 10, 20, 100, 200},
  
  -- Days to keep auction history
  AUCTION_HISTORY_DAYS_TO_KEEP = 30,
  
  -- Tooltip configuration
  TOOLTIP = {
    -- Which lines to include in the tooltip
    SHOW_MEDIAN = true,
    SHOW_MEAN = true,
    SHOW_MIN = true,
    SHOW_MARKET_VALUE = true,
    SHOW_HISTORICAL = true,
    
    -- Position of the tooltip lines
    POSITION = "default", -- Can be "default", "top", or "bottom"
    
    -- Left/Right tooltip formats
    LEFT_TEXT = "VUIAuct:",
    RIGHT_TEXT_MARKET = "Market:",
    RIGHT_TEXT_HISTORICAL = "Historical:",
    RIGHT_TEXT_VENDOR = "Vendor:",
  },
  
  -- Auction scan settings
  SCAN = {
    DEFAULT_PAGE_SIZE = 50,
    MAX_RESULTS_PER_SEARCH = 1000,
    MAX_RETRIES = 3,
    RETRY_DELAY = 0.5, -- seconds
  },
  
  -- Auction house tabs
  TABS = {
    SELL = 1,
    BUY = 2,
    AUCTIONS = 3,
    MORE = 4,
  },
  
  -- Background colors for tab panel
  TAB_COLORS = {
    [1] = "424242", -- Sell tab
    [2] = "424242", -- Buy tab
    [3] = "424242", -- Auctions tab
    [4] = "424242", -- More tab
  },
  
  -- UI constants
  UI = {
    -- Standard colors
    FRAME_BG_COLOR = {0.1, 0.1, 0.1, 0.8},
    FRAME_BORDER_COLOR = {0.2, 0.2, 0.2, 1.0},
    
    -- Standard sizes
    SMALL_BUTTON_WIDTH = 80,
    MEDIUM_BUTTON_WIDTH = 120,
    LARGE_BUTTON_WIDTH = 160,
    
    STANDARD_BUTTON_HEIGHT = 22,
    
    -- Font constants
    FONT_NORMAL = "GameFontNormal",
    FONT_HIGHLIGHT = "GameFontHighlight",
    FONT_SMALL = "GameFontNormalSmall",
    
    -- Frame strata levels
    STRATA_DIALOG = "DIALOG",
    STRATA_HIGH = "HIGH",
    STRATA_MEDIUM = "MEDIUM",
    STRATA_LOW = "LOW",
  },
  
  -- Feature detection
  Features = {}
}

-- Feature detection function to determine what AH version we're using
function Auctionator.Constants.Features.DetectAHVersion()
  -- Check if C_AuctionHouse exists (indicating retail AH)
  if C_AuctionHouse then
    return "retail"
  -- Check if AuctionFrame and AuctionFrame.numTabs exist (indicating classic AH)
  elseif AuctionFrame and AuctionFrame.numTabs then
    return "classic"
  else
    return "unknown"
  end
end

-- Check if the modern auction house is available
function Auctionator.Constants.Features.IsModernAH()
  return Auctionator.Constants.Features.DetectAHVersion() == "retail"
end

-- Check if the classic auction house is available
function Auctionator.Constants.Features.IsClassicAH()
  return Auctionator.Constants.Features.DetectAHVersion() == "classic"
end