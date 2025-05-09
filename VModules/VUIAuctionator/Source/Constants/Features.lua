local addonName, VUI = ...
local Auctionator = VUI.Auctionator

-- This file contains constants related to feature availability
-- Some features are only available in certain WoW versions
Auctionator.Constants.Features = {
  -- Check if we're using the modern Auction House UI (available in retail)
  IsModernAH = function()
    return WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
  end,
  
  -- Check if we should use Classic AH code
  IsClassicAH = function()
    return not Auctionator.Constants.Features.IsModernAH()
  end,
  
  -- Check if full scanning is available
  IsFullScanAvailable = function()
    return C_AuctionHouse ~= nil and C_AuctionHouse.GetNumReplicateItems ~= nil
  end,
  
  -- Check if reagent bank is available (retail feature)
  HasReagentBank = function()
    return WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
  end,
  
  -- Check if pet caging is available (retail feature)
  HasPetCaging = function()
    return WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
  end,
  
  -- Check if commodity purchases are available (retail feature)
  HasCommodityPurchase = function()
    return C_AuctionHouse ~= nil and C_AuctionHouse.StartCommoditiesPurchase ~= nil
  end,
  
  -- Check if multi-search is available (retail feature)
  HasMultiSearch = function()
    return C_AuctionHouse ~= nil and C_AuctionHouse.SendMultiSearchQuery ~= nil
  end,
  
  -- Check if guild bank tracking is available
  HasGuildBank = function()
    return CanViewGuildBankTab ~= nil
  end,
  
  -- Check if crafting UI is advanced enough for our features
  HasAdvancedCrafting = function()
    return C_TradeSkillUI ~= nil and C_TradeSkillUI.GetRecipeReagentItemLink ~= nil
  end,
  
  -- Crafting class IDs available on retail
  IsEnchanter = function()
    local _, _, classID = UnitClass("player")
    return classID == 2 -- This is for compatibility, actual logic would check profession
  end,
  
  -- Are auction durations available (values differ by game version)
  GetAuctionDurations = function()
    if Auctionator.Constants.Features.IsModernAH() then
      return {
        [12] = AUCTION_DURATION_ONE,
        [24] = AUCTION_DURATION_TWO,
        [48] = AUCTION_DURATION_THREE,
      }
    else
      return {
        [1] = AUCTION_DURATION_ONE,
        [2] = AUCTION_DURATION_TWO,
        [3] = AUCTION_DURATION_THREE,
      }
    end
  end,
  
  -- Default auction duration value
  GetDefaultAuctionDuration = function()
    if Auctionator.Constants.Features.IsModernAH() then
      return 24
    else
      return 2
    end
  end,
}