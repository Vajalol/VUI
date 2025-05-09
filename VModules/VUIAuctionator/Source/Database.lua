local addonName, VUI = ...
local Auctionator = VUI.Auctionator

Auctionator.Database = {
  -- Reference to the saved price database
  PriceDB = nil,
  
  -- Reference to the history database
  HistoryDB = nil,
  
  -- Whether the database has been initialized
  initialized = false
}

-- Database events
Auctionator.Database.Events = {
  PRICE_UPDATED = "price_updated",
  DATABASE_RESET = "database_reset",
  DATABASE_SCAN_COMPLETE = "database_scan_complete",
  DATABASE_SCAN_START = "database_scan_start"
}

-- Initialize the database
function Auctionator.Database.Initialize()
  if Auctionator.Database.initialized then
    return
  end
  
  -- Ensure VUI_SavedVariables exists
  if VUI_SavedVariables == nil then
    VUI_SavedVariables = {}
  end
  
  -- Ensure VUIAuctionator database exists
  if VUI_SavedVariables.VUIAuctionatorDatabase == nil then
    VUI_SavedVariables.VUIAuctionatorDatabase = {}
  end
  
  -- Initialize price database
  if VUI_SavedVariables.VUIAuctionatorDatabase.Prices == nil then
    VUI_SavedVariables.VUIAuctionatorDatabase.Prices = {}
  end
  
  -- Initialize history database
  if VUI_SavedVariables.VUIAuctionatorDatabase.History == nil then
    VUI_SavedVariables.VUIAuctionatorDatabase.History = {}
  end
  
  -- Set references to the databases
  Auctionator.Database.PriceDB = VUI_SavedVariables.VUIAuctionatorDatabase.Prices
  Auctionator.Database.HistoryDB = VUI_SavedVariables.VUIAuctionatorDatabase.History
  
  -- Mark as initialized
  Auctionator.Database.initialized = true
  
  -- Purge old data if configured
  if Auctionator.Config.Get(Auctionator.Config.Options.AUTO_PURGE_OLD_PRICES) then
    Auctionator.Database.PurgeOldPrices()
  end
end

-- Reset the entire database
function Auctionator.Database.Reset()
  VUI_SavedVariables.VUIAuctionatorDatabase = {
    Prices = {},
    History = {}
  }
  
  -- Update references
  Auctionator.Database.PriceDB = VUI_SavedVariables.VUIAuctionatorDatabase.Prices
  Auctionator.Database.HistoryDB = VUI_SavedVariables.VUIAuctionatorDatabase.History
  
  -- Fire event
  Auctionator.EventBus:Fire({}, Auctionator.Database.Events.DATABASE_RESET)
end

-- Get price data for an item
function Auctionator.Database.GetPriceData(itemLink)
  if not Auctionator.Database.initialized then
    Auctionator.Database.Initialize()
  end
  
  -- Get the item ID
  local itemID = Auctionator.Utilities.ItemInfo.GetItemID(itemLink)
  
  if not itemID then
    return nil
  end
  
  -- Return the price data
  return Auctionator.Database.PriceDB[itemID]
end

-- Get history data for an item
function Auctionator.Database.GetHistoryData(itemLink)
  if not Auctionator.Database.initialized then
    Auctionator.Database.Initialize()
  end
  
  -- Get the item ID
  local itemID = Auctionator.Utilities.ItemInfo.GetItemID(itemLink)
  
  if not itemID then
    return nil
  end
  
  -- Return the history data
  return Auctionator.Database.HistoryDB[itemID]
end

-- Update price data for an item
function Auctionator.Database.UpdatePrice(itemLink, price, scanTime)
  if not Auctionator.Database.initialized then
    Auctionator.Database.Initialize()
  end
  
  -- Validate parameters
  if not itemLink or not price or price <= 0 then
    return
  end
  
  -- Get the item ID
  local itemID = Auctionator.Utilities.ItemInfo.GetItemID(itemLink)
  
  if not itemID then
    return
  end
  
  -- Get current time if not provided
  scanTime = scanTime or time()
  
  -- Get the current price data or create new
  if not Auctionator.Database.PriceDB[itemID] then
    Auctionator.Database.PriceDB[itemID] = {
      minSeen = price,
      maxSeen = price,
      lastScan = scanTime,
      scans = 1,
      prices = {price}
    }
  else
    local data = Auctionator.Database.PriceDB[itemID]
    
    -- Update min/max
    if price < data.minSeen then
      data.minSeen = price
    end
    
    if price > data.maxSeen then
      data.maxSeen = price
    end
    
    -- Update scan info
    data.lastScan = scanTime
    data.scans = data.scans + 1
    
    -- Add to price history, keeping only the most recent X entries
    table.insert(data.prices, price)
    
    if #data.prices > Auctionator.Constants.PRICE_HISTORY_LENGTH then
      table.remove(data.prices, 1)
    end
  end
  
  -- Update history
  Auctionator.Database.AddToHistory(itemID, price, scanTime)
  
  -- Fire event
  Auctionator.EventBus:Fire({}, Auctionator.Database.Events.PRICE_UPDATED, itemID, price)
end

-- Add a price point to the history database
function Auctionator.Database.AddToHistory(itemID, price, scanTime)
  if not Auctionator.Database.initialized then
    Auctionator.Database.Initialize()
  end
  
  -- Validate parameters
  if not itemID or not price or price <= 0 then
    return
  end
  
  -- Get current time if not provided
  scanTime = scanTime or time()
  
  -- Create history entry if it doesn't exist
  if not Auctionator.Database.HistoryDB[itemID] then
    Auctionator.Database.HistoryDB[itemID] = {}
  end
  
  -- Add the data point
  table.insert(Auctionator.Database.HistoryDB[itemID], {
    price = price,
    time = scanTime
  })
  
  -- Limit the number of history entries by days to keep
  Auctionator.Database.PruneHistory(itemID)
end

-- Prune history data for an item based on age
function Auctionator.Database.PruneHistory(itemID)
  if not Auctionator.Database.initialized or not Auctionator.Database.HistoryDB[itemID] then
    return
  end
  
  local historyDays = Auctionator.Config.Get(Auctionator.Config.Options.PRICE_HISTORY_DAYS)
  local cutoffTime = time() - (historyDays * 24 * 60 * 60)
  local history = Auctionator.Database.HistoryDB[itemID]
  
  -- Remove entries older than the cutoff
  local i = 1
  while i <= #history do
    if history[i].time < cutoffTime then
      table.remove(history, i)
    else
      i = i + 1
    end
  end
end

-- Purge old prices from the database
function Auctionator.Database.PurgeOldPrices()
  if not Auctionator.Database.initialized then
    Auctionator.Database.Initialize()
  end
  
  local historyDays = Auctionator.Config.Get(Auctionator.Config.Options.PRICE_HISTORY_DAYS)
  local cutoffTime = time() - (historyDays * 24 * 60 * 60)
  
  -- Scan through price database
  for itemID, data in pairs(Auctionator.Database.PriceDB) do
    -- Remove entries that haven't been seen since the cutoff
    if data.lastScan < cutoffTime then
      Auctionator.Database.PriceDB[itemID] = nil
    end
  end
  
  -- Prune history database
  for itemID in pairs(Auctionator.Database.HistoryDB) do
    Auctionator.Database.PruneHistory(itemID)
    
    -- Remove empty histories
    if #Auctionator.Database.HistoryDB[itemID] == 0 then
      Auctionator.Database.HistoryDB[itemID] = nil
    end
  end
end

-- Get the market value for an item
function Auctionator.Database.GetMarketValue(itemLink)
  if not Auctionator.Database.initialized then
    Auctionator.Database.Initialize()
  end
  
  local priceData = Auctionator.Database.GetPriceData(itemLink)
  
  if not priceData or not priceData.prices or #priceData.prices == 0 then
    return nil
  end
  
  -- Use median of recent prices as market value
  local prices = Auctionator.Utilities.Table.Copy(priceData.prices)
  table.sort(prices)
  
  local median
  if #prices % 2 == 0 then
    -- Even number of prices, average the middle two
    local middle1 = prices[#prices / 2]
    local middle2 = prices[(#prices / 2) + 1]
    median = (middle1 + middle2) / 2
  else
    -- Odd number of prices, take the middle one
    median = prices[math.ceil(#prices / 2)]
  end
  
  return median
end

-- Get the historical value for an item (average over time)
function Auctionator.Database.GetHistoricalValue(itemLink)
  if not Auctionator.Database.initialized then
    Auctionator.Database.Initialize()
  end
  
  local historyData = Auctionator.Database.GetHistoryData(itemLink)
  
  if not historyData or #historyData == 0 then
    return nil
  end
  
  -- Calculate the average price from history
  local sum = 0
  for _, entry in ipairs(historyData) do
    sum = sum + entry.price
  end
  
  return math.floor(sum / #historyData)
end

-- Get the minimum price seen for an item
function Auctionator.Database.GetMinPrice(itemLink)
  if not Auctionator.Database.initialized then
    Auctionator.Database.Initialize()
  end
  
  local priceData = Auctionator.Database.GetPriceData(itemLink)
  
  if not priceData then
    return nil
  end
  
  return priceData.minSeen
end

-- Get the maximum price seen for an item
function Auctionator.Database.GetMaxPrice(itemLink)
  if not Auctionator.Database.initialized then
    Auctionator.Database.Initialize()
  end
  
  local priceData = Auctionator.Database.GetPriceData(itemLink)
  
  if not priceData then
    return nil
  end
  
  return priceData.maxSeen
end