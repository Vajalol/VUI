local addonName, VUI = ...
local Auctionator = VUI.Auctionator

-- Create the Selling module
Auctionator.Selling = {
  -- Current item being posted
  currentItem = nil,
  
  -- List of favorite items
  favoriteItems = {},
  
  -- List of ignored items
  ignoredItems = {},
  
  -- Event constants
  Events = {
    BAG_ITEM_CLICKED = "selling_bag_item_clicked",
    POST_ATTEMPT = "selling_post_attempt",
    POST_SUCCESS = "selling_post_success",
    POST_FAILURE = "selling_post_failure",
    ITEM_HISTORY_REQUEST = "selling_item_history_request",
    ITEM_HISTORY_RECEIVED = "selling_item_history_received",
    FAVORITE_ADDED = "selling_favorite_added",
    FAVORITE_REMOVED = "selling_favorite_removed",
    IGNORED_ADDED = "selling_ignored_added",
    IGNORED_REMOVED = "selling_ignored_removed"
  }
}

-- Initialize the selling module
function Auctionator.Selling:Initialize()
  -- Load saved favorites and ignored items
  self:LoadFavorites()
  self:LoadIgnored()
  
  -- Subscribe to events
  self:SetupEvents()
end

-- Set up event handlers
function Auctionator.Selling:SetupEvents()
  -- Listen for bag clicks to select items
  -- This will be connected to UI components later
  
  -- Listen for post attempts
  Auctionator.EventBus:Register({}, self.Events.POST_ATTEMPT, function(eventData)
    self:AttemptPost(eventData)
  end)
  
  -- Listen for auction house open/close
  Auctionator.EventBus:Register({}, Auctionator.AuctionHouse.Events.AUCTION_HOUSE_SHOW, function()
    -- Refresh favorites display when AH opens
    self:RefreshFavorites()
  end)
  
  -- Listen for multi-sell status
  if Auctionator.Constants.Features.IsModernAH() then
    Auctionator.EventBus:Register({}, Auctionator.AuctionHouse.Events.AUCTION_MULTISELL_START, function()
      -- Handle multi-sell start
    end)
    
    Auctionator.EventBus:Register({}, Auctionator.AuctionHouse.Events.AUCTION_MULTISELL_UPDATE, function(progress, total)
      -- Handle multi-sell progress
    end)
    
    Auctionator.EventBus:Register({}, Auctionator.AuctionHouse.Events.AUCTION_MULTISELL_FAILURE, function()
      Auctionator.Utilities.Message.Error(Auctionator.L.ERR_AUCTION_HOUSE_BUSY)
    end)
  end
end

-- Handle item selection from bags
function Auctionator.Selling:SelectItem(itemLocation)
  if not itemLocation then
    return
  end
  
  -- Get the item info
  local itemLink = C_Item.GetItemLink(itemLocation)
  
  if not itemLink then
    return
  end
  
  -- Check if item can be auctioned
  if not Auctionator.API.CanPostItem(itemLink) then
    Auctionator.Utilities.Message.Error(Auctionator.L.ERR_CANNOT_AUCTION)
    return
  end
  
  -- Set as current item
  self.currentItem = {
    itemLink = itemLink,
    itemLocation = itemLocation,
    quantity = C_Item.GetStackCount(itemLocation),
    maxStackSize = Auctionator.Utilities.ItemInfo.GetItemStackSize(itemLink)
  }
  
  -- Update price suggestions
  self:UpdatePriceSuggestions()
  
  -- Fire event that item was selected
  Auctionator.EventBus:Fire({}, self.Events.BAG_ITEM_CLICKED, self.currentItem)
end

-- Update price suggestions for the current item
function Auctionator.Selling:UpdatePriceSuggestions()
  if not self.currentItem then
    return
  end
  
  -- Get price data for the item
  local marketValue = Auctionator.Database.GetMarketValue(self.currentItem.itemLink)
  local historicalValue = Auctionator.Database.GetHistoricalValue(self.currentItem.itemLink)
  local vendorPrice = Auctionator.API.GetVendorPrice(self.currentItem.itemLink)
  
  -- Calculate suggested price
  local suggestedPrice = Auctionator.API.CalculateSuggestedPrice(
    self.currentItem.itemLink, 
    "percentage" -- Use percentage-based undercutting
  )
  
  -- Set price data on the current item
  self.currentItem.marketValue = marketValue
  self.currentItem.historicalValue = historicalValue
  self.currentItem.vendorPrice = vendorPrice
  self.currentItem.suggestedPrice = suggestedPrice
end

-- Attempt to post the current item
function Auctionator.Selling:AttemptPost(postData)
  if not Auctionator.AuctionHouse:IsOpen() then
    Auctionator.Utilities.Message.Error(Auctionator.L.ERR_AUCTION_HOUSE_CLOSED)
    Auctionator.EventBus:Fire({}, self.Events.POST_FAILURE, "AH_CLOSED")
    return
  end
  
  if not self.currentItem then
    Auctionator.Utilities.Message.Error(Auctionator.L.ERR_NO_ITEM_SELECTED)
    Auctionator.EventBus:Fire({}, self.Events.POST_FAILURE, "NO_ITEM")
    return
  end
  
  -- Validate postData
  if not postData.quantity or not postData.price or not postData.duration then
    Auctionator.Utilities.Message.Error(Auctionator.L.ERR_INVALID_PARAMETERS)
    Auctionator.EventBus:Fire({}, self.Events.POST_FAILURE, "INVALID_PARAMS")
    return
  end
  
  -- Handle posting based on AH type
  if Auctionator.Constants.Features.IsModernAH() then
    self:PostRetailAuction(postData)
  else
    self:PostClassicAuction(postData)
  end
end

-- Post an auction in the retail AH
function Auctionator.Selling:PostRetailAuction(postData)
  if not C_AuctionHouse then
    Auctionator.Utilities.Message.Error(Auctionator.L.ERR_NOT_IMPLEMENTED)
    Auctionator.EventBus:Fire({}, self.Events.POST_FAILURE, "NOT_IMPLEMENTED")
    return
  end
  
  local item = self.currentItem
  local quantity = postData.quantity
  local price = postData.price
  local duration = postData.duration
  
  -- Check if the item is a commodity
  local isCommodity = Auctionator.Utilities.ItemInfo.IsCommodity(item.itemLink)
  
  -- Remember stack size for future use
  Auctionator.API.SetRecommendedStackSize(item.itemLink, quantity)
  
  -- Start the post
  if isCommodity then
    C_AuctionHouse.PostCommodity(item.itemLocation, quantity, price, duration)
  else
    C_AuctionHouse.PostItem(item.itemLocation, price, price, duration, quantity)
  end
  
  -- Record post attempt
  local itemName = Auctionator.Utilities.ItemInfo.GetItemName(item.itemLink)
  local totalPrice = price * quantity
  
  -- Show success message
  Auctionator.Utilities.Message.AuctionChat(string.format(
    Auctionator.L.MSG_AUCTION_POSTED,
    Auctionator.Utilities.ItemInfo.GetColoredItemName(item.itemLink),
    Auctionator.Utilities.FormatMoney(totalPrice)
  ))
  
  -- Fire success event
  Auctionator.EventBus:Fire({}, self.Events.POST_SUCCESS, {
    itemLink = item.itemLink,
    price = price,
    quantity = quantity,
    duration = duration,
    totalPrice = totalPrice
  })
  
  -- Auto-select next item if configured
  if Auctionator.Config.Get(Auctionator.Config.Options.SELLING_AUTO_SELECT_NEXT) then
    self:SelectNextItem()
  else
    -- Clear current item
    self.currentItem = nil
  end
end

-- Post an auction in the classic AH
function Auctionator.Selling:PostClassicAuction(postData)
  -- To be implemented for classic AH
  -- This is a placeholder since we don't have full classic AH implementation yet
  
  Auctionator.Utilities.Message.Error(Auctionator.L.ERR_NOT_IMPLEMENTED)
  Auctionator.EventBus:Fire({}, self.Events.POST_FAILURE, "NOT_IMPLEMENTED")
end

-- Select the next item in bags for posting
function Auctionator.Selling:SelectNextItem()
  -- To be implemented - this would iterate through bag items
  -- and find the next auctionable item
  
  -- For now, just clear current item
  self.currentItem = nil
  
  -- Fire event to update UI
  Auctionator.EventBus:Fire({}, self.Events.BAG_ITEM_CLICKED, nil)
end

-- Load saved favorite items
function Auctionator.Selling:LoadFavorites()
  -- Get from saved variables
  local savedFavorites = Auctionator.Config.Get(Auctionator.Config.Options.SELLING_FAVOURITE_KEYS) or {}
  self.favoriteItems = savedFavorites
end

-- Save favorite items
function Auctionator.Selling:SaveFavorites()
  -- Save to config
  Auctionator.Config.Set(Auctionator.Config.Options.SELLING_FAVOURITE_KEYS, self.favoriteItems)
end

-- Add an item to favorites
function Auctionator.Selling:AddToFavorites(itemLink)
  if not itemLink then
    return false
  end
  
  local itemID = Auctionator.Utilities.ItemInfo.GetItemID(itemLink)
  
  if not itemID then
    return false
  end
  
  -- Add to favorites if not already present
  if not self.favoriteItems[itemID] then
    self.favoriteItems[itemID] = true
    self:SaveFavorites()
    
    -- Notify
    local itemName = Auctionator.Utilities.ItemInfo.GetItemName(itemLink)
    Auctionator.Utilities.Message.Info(string.format(Auctionator.L.MSG_FAVOURITE_ADDED, itemName))
    
    -- Fire event
    Auctionator.EventBus:Fire({}, self.Events.FAVORITE_ADDED, itemID)
    
    return true
  end
  
  return false
end

-- Remove an item from favorites
function Auctionator.Selling:RemoveFromFavorites(itemLink)
  if not itemLink then
    return false
  end
  
  local itemID = Auctionator.Utilities.ItemInfo.GetItemID(itemLink)
  
  if not itemID then
    return false
  end
  
  -- Remove from favorites if present
  if self.favoriteItems[itemID] then
    self.favoriteItems[itemID] = nil
    self:SaveFavorites()
    
    -- Notify
    local itemName = Auctionator.Utilities.ItemInfo.GetItemName(itemLink)
    Auctionator.Utilities.Message.Info(string.format(Auctionator.L.MSG_FAVOURITE_REMOVED, itemName))
    
    -- Fire event
    Auctionator.EventBus:Fire({}, self.Events.FAVORITE_REMOVED, itemID)
    
    return true
  end
  
  return false
end

-- Check if an item is a favorite
function Auctionator.Selling:IsFavorite(itemLink)
  if not itemLink then
    return false
  end
  
  local itemID = Auctionator.Utilities.ItemInfo.GetItemID(itemLink)
  
  if not itemID then
    return false
  end
  
  return self.favoriteItems[itemID] ~= nil
end

-- Load saved ignored items
function Auctionator.Selling:LoadIgnored()
  -- Get from saved variables
  local savedIgnored = Auctionator.Config.Get(Auctionator.Config.Options.SELLING_IGNORED_KEYS) or {}
  self.ignoredItems = savedIgnored
end

-- Save ignored items
function Auctionator.Selling:SaveIgnored()
  -- Save to config
  Auctionator.Config.Set(Auctionator.Config.Options.SELLING_IGNORED_KEYS, self.ignoredItems)
end

-- Add an item to ignored list
function Auctionator.Selling:AddToIgnored(itemLink)
  if not itemLink then
    return false
  end
  
  local itemID = Auctionator.Utilities.ItemInfo.GetItemID(itemLink)
  
  if not itemID then
    return false
  end
  
  -- Add to ignored if not already present
  if not self.ignoredItems[itemID] then
    self.ignoredItems[itemID] = true
    self:SaveIgnored()
    
    -- Notify
    local itemName = Auctionator.Utilities.ItemInfo.GetItemName(itemLink)
    Auctionator.Utilities.Message.Info(string.format(Auctionator.L.MSG_IGNORED_ADDED, itemName))
    
    -- Fire event
    Auctionator.EventBus:Fire({}, self.Events.IGNORED_ADDED, itemID)
    
    return true
  end
  
  return false
end

-- Remove an item from ignored list
function Auctionator.Selling:RemoveFromIgnored(itemLink)
  if not itemLink then
    return false
  end
  
  local itemID = Auctionator.Utilities.ItemInfo.GetItemID(itemLink)
  
  if not itemID then
    return false
  end
  
  -- Remove from ignored if present
  if self.ignoredItems[itemID] then
    self.ignoredItems[itemID] = nil
    self:SaveIgnored()
    
    -- Notify
    local itemName = Auctionator.Utilities.ItemInfo.GetItemName(itemLink)
    Auctionator.Utilities.Message.Info(string.format(Auctionator.L.MSG_IGNORED_REMOVED, itemName))
    
    -- Fire event
    Auctionator.EventBus:Fire({}, self.Events.IGNORED_REMOVED, itemID)
    
    return true
  end
  
  return false
end

-- Check if an item is ignored
function Auctionator.Selling:IsIgnored(itemLink)
  if not itemLink then
    return false
  end
  
  local itemID = Auctionator.Utilities.ItemInfo.GetItemID(itemLink)
  
  if not itemID then
    return false
  end
  
  return self.ignoredItems[itemID] ~= nil
end

-- Refresh favorites display
function Auctionator.Selling:RefreshFavorites()
  -- This would update the favorites display in the UI
  -- UI implementation will be added later
end