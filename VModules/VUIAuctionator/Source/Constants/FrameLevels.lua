local addonName, VUI = ...
local Auctionator = VUI.Auctionator

Auctionator.Constants.FrameLevels = {
  -- Base frame level for Auction House
  BASE = 100,
  
  -- Tab frame levels
  TAB = 200,
  TAB_CONTENT = 201,
  
  -- Dialog frame levels
  DIALOG = 500,
  DIALOG_BACKDROP = 499,
  
  -- Shopping frame levels
  SHOPPING_LIST = 250,
  SHOPPING_RESULTS = 260,
  
  -- Selling frame levels
  SELLING_BAG = 300,
  SELLING_ITEM_DISPLAY = 310,
  SELLING_HISTORY = 320,
  
  -- Cancelling frame levels
  CANCELLING_LIST = 350,
  
  -- Tooltip frame levels
  TOOLTIP = 800,
  
  -- Splash screen
  SPLASH = 1000,
}