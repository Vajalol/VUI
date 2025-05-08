local addonName, VUI = ...
local Auctionator = VUI.Auctionator

-- API v1 functions
local APIv1 = {
  -- Return the database price for an item (nil if not found)
  GetAuctionPriceByItemID = function(itemID)
    if Auctionator.Database and Auctionator.Database.GetPrice then
      return Auctionator.Database.GetPrice(itemID)
    end
    return nil
  end,
  
  -- Return the database price for an item by link
  GetAuctionPriceByItemLink = function(itemLink)
    local itemID = GetItemInfoInstant(itemLink)
    if itemID then
      return APIv1.GetAuctionPriceByItemID(itemID)
    end
    return nil
  end,
  
  -- Add an item to a shopping list
  AddToShoppingList = function(listName, searchTerm)
    if Auctionator.Shopping and Auctionator.Shopping.Lists then
      return Auctionator.Shopping.Lists.AddItem(listName, searchTerm)
    end
    return false
  end,
  
  -- Create a shopping list
  CreateShoppingList = function(listName)
    if Auctionator.Shopping and Auctionator.Shopping.Lists then
      return Auctionator.Shopping.Lists.Create(listName)
    end
    return false
  end,
  
  -- Check if AH is ready
  IsAuctionHouseReady = function()
    if Auctionator.AH and Auctionator.AH.Events then
      return Auctionator.AH.Events.IsReady
    end
    return false
  end,
  
  -- Format money into a readable string
  FormatMoney = function(amount)
    if Auctionator.Utilities and Auctionator.Utilities.FormatMoney then
      return Auctionator.Utilities.FormatMoney(amount)
    end
    
    -- Fallback if utility function not available
    local gold = math.floor(amount / 10000)
    local silver = math.floor((amount % 10000) / 100)
    local copper = amount % 100
    
    if gold > 0 then
      return string.format("%dg %ds %dc", gold, silver, copper)
    elseif silver > 0 then
      return string.format("%ds %dc", silver, copper)
    else
      return string.format("%dc", copper)
    end
  end,
  
  -- Parse a money string into amount
  ParseMoney = function(moneyString)
    if Auctionator.Utilities and Auctionator.Utilities.ParseMoney then
      return Auctionator.Utilities.ParseMoney(moneyString)
    end
    return nil
  end,
  
  -- Get addon version
  GetVersion = function()
    return Auctionator.Constants.CURRENT_VERSION
  end,
  
  -- Register a callback for when AH is ready
  RegisterForAuctionHouseReady = function(callback)
    if Auctionator.AH and Auctionator.AH.Events then
      Auctionator.AH.Events.RegisterCallback(callback)
      return true
    end
    return false
  end,
  
  -- Check if an item is in the vendor price database
  HasVendorPrice = function(itemID)
    if Auctionator.Utilities and Auctionator.Utilities.HasVendorPrice then
      return Auctionator.Utilities.HasVendorPrice(itemID)
    end
    return false
  end,
  
  -- Get all shopping lists
  GetShoppingLists = function()
    if Auctionator.Shopping and Auctionator.Shopping.Lists then
      return Auctionator.Shopping.Lists.GetAll()
    end
    return {}
  end,
}

-- Register all API functions in the Auctionator.API.v1 namespace
for name, func in pairs(APIv1) do
  Auctionator.API.v1[name] = func
end