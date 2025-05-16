-- VUIAuctionator Item Categories
local addonName, VUI = ...
local Auctionator = VUI.Auctionator

Auctionator.Constants.Categories = {
  -- Main categories
  WEAPONS = "Weapons",
  ARMOR = "Armor",
  CONTAINERS = "Containers",
  CONSUMABLES = "Consumables",
  TRADE_GOODS = "Trade Goods",
  PROJECTILES = "Projectiles", -- For classic compatibility
  ITEM_ENHANCEMENTS = "Item Enhancements",
  RECIPES = "Recipes",
  GEMS = "Gems",
  GLYPHS = "Glyphs", -- For older expansion compatibility
  BATTLE_PETS = "Battle Pets",
  QUEST_ITEMS = "Quest Items",
  MISCELLANEOUS = "Miscellaneous",
  
  -- Sub-categories can be added as needed
  
  -- Helper function to get localized category name
  GetLocalizedName = function(category)
    -- This would ideally use localization
    return category
  end
} 