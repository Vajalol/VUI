local addonName, VUI = ...
local Auctionator = VUI.Auctionator

-- Create the Search module
Auctionator.Search = {
  -- Current search state
  currentSearchData = nil,
  
  -- Search queue
  searchQueue = {},
  
  -- Active searches
  activeSearches = {},
  
  -- Current search index
  currentSearchIndex = 0,
  
  -- Whether a search is in progress
  isSearching = false,
  
  -- Event constants
  Events = {
    SEARCH_STARTED = "search_started",
    SEARCH_COMPLETE = "search_complete",
    SEARCH_FAILED = "search_failed",
    SEARCH_PROGRESS = "search_progress"
  }
}

-- Start a search for an item
function Auctionator.Search:StartSearch(searchText, isExact, callback)
  if not Auctionator.AuctionHouse:IsOpen() then
    if callback then
      callback({
        success = false,
        error = Auctionator.L.ERR_AUCTION_HOUSE_CLOSED
      })
    end
    return
  end
  
  -- Create a new search ID
  self.currentSearchIndex = self.currentSearchIndex + 1
  local searchId = self.currentSearchIndex
  
  -- Set up the search data
  local searchData = {
    id = searchId,
    searchText = searchText,
    isExact = isExact,
    callback = callback,
    startTime = GetTime(),
    results = {},
    status = "queued"
  }
  
  -- Add to queue
  table.insert(self.searchQueue, searchData)
  
  -- Save in active searches
  self.activeSearches[searchId] = searchData
  
  -- Process queue
  self:ProcessQueue()
  
  -- Return the search ID
  return searchId
end

-- Process the search queue
function Auctionator.Search:ProcessQueue()
  if self.isSearching or #self.searchQueue == 0 then
    return
  end
  
  -- Get the next search
  local searchData = table.remove(self.searchQueue, 1)
  
  -- Mark as searching
  self.isSearching = true
  searchData.status = "searching"
  
  -- Store current search
  self.currentSearchData = searchData
  
  -- Fire event
  Auctionator.EventBus:Fire({}, self.Events.SEARCH_STARTED, searchData)
  
  -- Display searching message
  Auctionator.Utilities.Message.Info(string.format(Auctionator.L.MSG_SEARCHING, searchData.searchText))
  
  -- Start the search
  if Auctionator.Constants.Features.IsModernAH() then
    self:StartRetailSearch(searchData)
  else
    self:StartClassicSearch(searchData)
  end
end

-- Start a search in the retail AH
function Auctionator.Search:StartRetailSearch(searchData)
  if not C_AuctionHouse then
    self:FinishSearch(searchData, false, "Retail AuctionHouse API not available")
    return
  end
  
  -- Set up event handlers for this search
  local itemResultsEvent = Auctionator.EventBus:Register({}, Auctionator.AuctionHouse.Events.ITEM_SEARCH_RESULTS_UPDATED, function(itemKey)
    self:ProcessRetailItemResults(searchData, itemKey)
  end)
  
  local commodityResultsEvent = Auctionator.EventBus:Register({}, Auctionator.AuctionHouse.Events.COMMODITY_SEARCH_RESULTS_UPDATED, function(itemID)
    self:ProcessRetailCommodityResults(searchData, itemID)
  end)
  
  -- Create the browse query
  local query = {
    searchString = searchData.searchText,
    sorts = {},
    minLevel = 0,
    maxLevel = 0
  }
  
  -- Add sort by price
  if not Auctionator.Config.Get(Auctionator.Config.Options.LIFO_AUCTION_SORT) then
    table.insert(query.sorts, {sortOrder = 0, reverseSort = false}) -- Sort by price, lowest first
  else
    table.insert(query.sorts, {sortOrder = 4, reverseSort = true}) -- Sort by time, newest first
  end
  
  -- Set timeout to handle failures
  searchData.timeout = C_Timer.NewTimer(10, function()
    -- Unregister events
    Auctionator.EventBus:Unregister({}, Auctionator.AuctionHouse.Events.ITEM_SEARCH_RESULTS_UPDATED, itemResultsEvent)
    Auctionator.EventBus:Unregister({}, Auctionator.AuctionHouse.Events.COMMODITY_SEARCH_RESULTS_UPDATED, commodityResultsEvent)
    
    -- Check if we got any results
    if #searchData.results == 0 then
      self:FinishSearch(searchData, false, "Search timed out")
    else
      -- We had some results, consider it successful
      self:FinishSearch(searchData, true)
    end
  end)
  
  -- Send the query
  C_AuctionHouse.SendBrowseQuery(query)
end

-- Start a search in the classic AH
function Auctionator.Search:StartClassicSearch(searchData)
  -- Handle classic AH search
  -- This would be implemented based on the classic AH API
  
  -- For now, just report not implemented
  self:FinishSearch(searchData, false, "Classic AH search not implemented")
end

-- Process retail item search results
function Auctionator.Search:ProcessRetailItemResults(searchData, itemKey)
  -- Get the results
  local results = C_AuctionHouse.GetItemSearchResults(itemKey)
  
  if not results or #results == 0 then
    return
  end
  
  -- Process each result
  for _, result in ipairs(results) do
    -- Create a standardized result object
    local itemLink = C_AuctionHouse.GetItemKeyInfo(result.itemKey).itemLink
    
    local standardResult = {
      itemID = result.itemKey.itemID,
      itemLink = itemLink,
      quantity = result.quantity,
      unitPrice = result.buyoutAmount / result.quantity,
      bidAmount = result.bidAmount,
      buyoutAmount = result.buyoutAmount,
      timeLeft = result.timeLeft,
      owner = result.owners and result.owners[1] or nil,
      ownerFullName = result.ownerFullName,
      itemKey = result.itemKey,
      itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(result.itemKey),
      isCommodity = false
    }
    
    -- Add to results
    table.insert(searchData.results, standardResult)
    
    -- Update the price database
    Auctionator.Database.UpdatePrice(itemLink, standardResult.unitPrice)
  end
  
  -- Report progress
  Auctionator.EventBus:Fire({}, self.Events.SEARCH_PROGRESS, searchData)
  
  -- If this was an exact match for the search and we're supposed to auto open,
  -- fire the AUCTION_HOUSE_SHOW_NOTIFICATION event
  local info = C_AuctionHouse.GetItemKeyInfo(itemKey)
  if info and info.itemName and 
     searchData.isExact and 
     info.itemName:lower() == searchData.searchText:lower() and
     Auctionator.Config.Get(Auctionator.Config.Options.OPEN_FIRST_AUCTION_WHEN_SEARCHING) then
    C_Timer.After(0.1, function()
      if #results > 0 then
        -- TODO: Open the first auction based on AH type
        -- (Not fully implementing this feature here)
      end
    end)
  end
end

-- Process retail commodity search results
function Auctionator.Search:ProcessRetailCommodityResults(searchData, itemID)
  -- Get the results
  local results = C_AuctionHouse.GetCommoditySearchResults(itemID)
  
  if not results or #results == 0 then
    return
  end
  
  -- Create a mock item link for price db
  local itemLink = Auctionator.Utilities.GetItemLinkFromID(itemID)
  
  if not itemLink then
    return
  end
  
  -- Process each result
  for _, result in ipairs(results) do
    -- Create a standardized result object
    local standardResult = {
      itemID = itemID,
      itemLink = itemLink,
      quantity = result.quantity,
      unitPrice = result.unitPrice,
      bidAmount = nil, -- Commodities don't have bids
      buyoutAmount = result.unitPrice * result.quantity,
      timeLeft = result.timeLeft,
      owner = nil, -- Commodities don't have owner info
      isCommodity = true
    }
    
    -- Add to results
    table.insert(searchData.results, standardResult)
    
    -- Update the price database
    Auctionator.Database.UpdatePrice(itemLink, standardResult.unitPrice)
  end
  
  -- Report progress
  Auctionator.EventBus:Fire({}, self.Events.SEARCH_PROGRESS, searchData)
end

-- Finish a search and clean up
function Auctionator.Search:FinishSearch(searchData, success, errorMessage)
  -- Cancel timeout if it exists
  if searchData.timeout then
    searchData.timeout:Cancel()
    searchData.timeout = nil
  end
  
  -- Mark search as complete
  searchData.endTime = GetTime()
  searchData.status = success and "complete" or "failed"
  searchData.error = errorMessage
  
  -- Fire appropriate event
  if success then
    Auctionator.EventBus:Fire({}, self.Events.SEARCH_COMPLETE, searchData)
    
    -- Show completion message
    Auctionator.Utilities.Message.Success(Auctionator.L.MSG_SCAN_COMPLETE)
  else
    Auctionator.EventBus:Fire({}, self.Events.SEARCH_FAILED, searchData)
    
    -- Show error message
    Auctionator.Utilities.Message.Error(string.format(Auctionator.L.MSG_SCAN_FAILED, errorMessage or "Unknown error"))
  end
  
  -- Call the callback if provided
  if searchData.callback then
    searchData.callback({
      success = success,
      error = errorMessage,
      results = searchData.results,
      searchId = searchData.id
    })
  end
  
  -- Mark as no longer searching
  self.isSearching = false
  self.currentSearchData = nil
  
  -- Process next in queue if any
  if #self.searchQueue > 0 then
    C_Timer.After(0.5, function()
      self:ProcessQueue()
    end)
  end
end

-- Cancel a search by ID
function Auctionator.Search:CancelSearch(searchId)
  -- Find in queue
  for i, search in ipairs(self.searchQueue) do
    if search.id == searchId then
      table.remove(self.searchQueue, i)
      self.activeSearches[searchId] = nil
      return true
    end
  end
  
  -- Check if it's the current search
  if self.currentSearchData and self.currentSearchData.id == searchId then
    -- Cancel timeout
    if self.currentSearchData.timeout then
      self.currentSearchData.timeout:Cancel()
      self.currentSearchData.timeout = nil
    end
    
    -- Mark as cancelled
    self.currentSearchData.status = "cancelled"
    self.activeSearches[searchId] = nil
    
    -- Mark as no longer searching
    self.isSearching = false
    self.currentSearchData = nil
    
    -- Process next in queue
    if #self.searchQueue > 0 then
      C_Timer.After(0.5, function()
        self:ProcessQueue()
      end)
    end
    
    return true
  end
  
  return false
end

-- Register an item search from external addons
function Auctionator.Search:RegisterItemSearch(callback, searchText, isExact)
  return self:StartSearch(searchText, isExact, callback)
end