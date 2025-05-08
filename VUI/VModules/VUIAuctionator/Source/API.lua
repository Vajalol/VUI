local addonName, VUI = ...
local Auctionator = VUI.Auctionator

Auctionator.API = {}

-- Get the current market value for an item
-- Returns: The current market value (in copper) or nil if no data
function Auctionator.API.GetMarketValue(itemLink)
  return Auctionator.Database.GetMarketValue(itemLink)
end

-- Get the historical value for an item
-- Returns: The historical average value (in copper) or nil if no data
function Auctionator.API.GetHistoricalValue(itemLink)
  return Auctionator.Database.GetHistoricalValue(itemLink)
end

-- Get the minimum price seen for an item
-- Returns: The minimum price seen (in copper) or nil if no data
function Auctionator.API.GetMinPrice(itemLink)
  return Auctionator.Database.GetMinPrice(itemLink)
end

-- Get the vendor sell price for an item
-- Returns: The vendor sell price (in copper) or nil if not available
function Auctionator.API.GetVendorPrice(itemLink)
  if not itemLink then
    return nil
  end
  
  local _, _, _, _, _, _, _, _, _, _, sellPrice = GetItemInfo(itemLink)
  
  return sellPrice
end

-- Check if an item can be posted on the auction house
-- Returns: Boolean indicating whether the item can be posted
function Auctionator.API.CanPostItem(itemLink)
  if not itemLink then
    return false
  end
  
  -- Check if the item is bound
  local isBound = C_Item.IsBound(itemLink)
  if isBound then
    return false
  end
  
  -- Check if it's a quest item
  local _, _, _, _, _, _, _, _, _, _, _, _, _, bindType = GetItemInfo(itemLink)
  if bindType == 4 then -- 4 is LE_ITEM_BIND_QUEST
    return false
  end
  
  return true
end

-- Get the recommended stack size for an item
-- Returns: The recommended stack size (number)
function Auctionator.API.GetRecommendedStackSize(itemLink)
  if not itemLink then
    return 1
  end
  
  local itemID = Auctionator.Utilities.ItemInfo.GetItemID(itemLink)
  
  if not itemID then
    return 1
  end
  
  -- Get stack size memory
  local stackSizeMemory = Auctionator.Config.Get(Auctionator.Config.Options.STACK_SIZE_MEMORY)
  
  if stackSizeMemory and stackSizeMemory[itemID] then
    return stackSizeMemory[itemID]
  end
  
  -- If no memory, use the maximum stack size
  local maxStack = Auctionator.Utilities.ItemInfo.GetItemStackSize(itemLink)
  
  return maxStack or 1
end

-- Set the recommended stack size for an item
function Auctionator.API.SetRecommendedStackSize(itemLink, stackSize)
  if not itemLink then
    return
  end
  
  local itemID = Auctionator.Utilities.ItemInfo.GetItemID(itemLink)
  
  if not itemID then
    return
  end
  
  -- Get stack size memory
  local stackSizeMemory = Auctionator.Config.Get(Auctionator.Config.Options.STACK_SIZE_MEMORY) or {}
  
  -- Update memory
  stackSizeMemory[itemID] = stackSize
  
  -- Save updated memory
  Auctionator.Config.Set(Auctionator.Config.Options.STACK_SIZE_MEMORY, stackSizeMemory)
end

-- Calculate the suggested sale price for an item
-- undercutPolicy: "percentage" or "static"
-- Returns: The suggested sale price (in copper)
function Auctionator.API.CalculateSuggestedPrice(itemLink, undercutPolicy)
  if not itemLink then
    return nil
  end
  
  -- Get current market value
  local marketValue = Auctionator.API.GetMarketValue(itemLink)
  
  if not marketValue or marketValue <= 0 then
    -- If no market value, try historical
    marketValue = Auctionator.API.GetHistoricalValue(itemLink)
    
    if not marketValue or marketValue <= 0 then
      -- If no historical, try vendor price * multiplier
      local vendorPrice = Auctionator.API.GetVendorPrice(itemLink)
      
      if vendorPrice and vendorPrice > 0 then
        return vendorPrice * 3 -- Simple vendor price multiplier
      end
      
      return nil
    end
  end
  
  -- Apply undercut based on policy
  if undercutPolicy == "percentage" then
    local undercutPercentage = Auctionator.Config.Get(Auctionator.Config.Options.UNDERCUT_PERCENTAGE)
    return math.floor(marketValue * (1 - (undercutPercentage / 100)))
  else
    local undercutValue = Auctionator.Config.Get(Auctionator.Config.Options.UNDERCUT_STATIC_VALUE)
    return math.max(1, marketValue - undercutValue)
  end
end

-- Register an item search
-- This function is used by other addons to register searches with Auctionator
function Auctionator.API.RegisterItemSearch(callback, searchText, isExact)
  if not Auctionator.Search then
    C_Timer.After(0.5, function()
      Auctionator.API.RegisterItemSearch(callback, searchText, isExact)
    end)
    return
  end
  
  Auctionator.Search.RegisterItemSearch(callback, searchText, isExact)
end

-- Check if the Auction House is open
function Auctionator.API.IsAuctionHouseOpen()
  if Auctionator.Constants.Features.IsModernAH() then
    return AuctionHouseFrame and AuctionHouseFrame:IsVisible()
  else
    return AuctionFrame and AuctionFrame:IsVisible()
  end
end

-- Subscribe to VUIAuctionator events
-- eventName: The name of the event to subscribe to
-- callback: The function to call when the event occurs
function Auctionator.API.Subscribe(eventName, callback)
  Auctionator.EventBus:Register({}, eventName, callback)
end

-- Unsubscribe from VUIAuctionator events
-- eventName: The name of the event to unsubscribe from
-- callback: The function that was previously registered
function Auctionator.API.Unsubscribe(eventName, callback)
  Auctionator.EventBus:Unregister({}, eventName, callback)
end