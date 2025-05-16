local addonName, VUI = ...
local Auctionator = VUI.Auctionator

-- Define the search provider mixin
AuctionatorSearchProviderMixin = CreateFromMixins(AuctionHouseSearchProviderMixin)

function AuctionatorSearchProviderMixin:OnLoad()
  AuctionHouseSearchProviderMixin.OnLoad(self)
  
  -- Set up default values
  self.currentFilter = nil
  self.sorts = {}
  self.searchCallback = nil
  self.extraFilters = {}
  
  -- Create event frame
  self.searchEventFrame = CreateFrame("Frame")
  self.searchEventFrame.provider = self
  self.searchEventFrame:SetScript("OnEvent", function(frame, event, ...)
    frame.provider:HandleEvent(event, ...)
  end)
end

function AuctionatorSearchProviderMixin:RegisterEvents()
  self.searchEventFrame:RegisterEvent("COMMODITY_SEARCH_RESULTS_UPDATED")
  self.searchEventFrame:RegisterEvent("ITEM_SEARCH_RESULTS_UPDATED")
  self.searchEventFrame:RegisterEvent("AUCTION_HOUSE_BROWSE_RESULTS_UPDATED")
  self.searchEventFrame:RegisterEvent("AUCTION_HOUSE_BROWSE_RESULTS_ADDED")
  self.searchEventFrame:RegisterEvent("AUCTION_HOUSE_BROWSE_FAILURE")
end

function AuctionatorSearchProviderMixin:UnregisterEvents()
  self.searchEventFrame:UnregisterAllEvents()
end

function AuctionatorSearchProviderMixin:HandleEvent(event, ...)
  -- Process different events
  if event == "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED" then
    self:ProcessSearchResults(...)
  elseif event == "AUCTION_HOUSE_BROWSE_RESULTS_ADDED" then
    self:ProcessSearchResultsAdded(...)
  elseif event == "AUCTION_HOUSE_BROWSE_FAILURE" then
    self:ProcessSearchFailure(...)
  elseif event == "COMMODITY_SEARCH_RESULTS_UPDATED" then
    self:ProcessCommodityResults(...)
  elseif event == "ITEM_SEARCH_RESULTS_UPDATED" then
    self:ProcessItemResults(...)
  end
end

function AuctionatorSearchProviderMixin:ProcessSearchResults(...)
  local results = C_AuctionHouse.GetBrowseResults()
  self:ProcessSearchData(results)
end

function AuctionatorSearchProviderMixin:ProcessSearchResultsAdded(...)
  local addedResults = C_AuctionHouse.GetBrowseResults()
  self:ProcessSearchData(addedResults, true)
end

function AuctionatorSearchProviderMixin:ProcessSearchFailure(...)
  if self.searchCallback then
    self.searchCallback(self, nil, "search_failed")
  end
end

function AuctionatorSearchProviderMixin:ProcessCommodityResults(itemID)
  local results = C_AuctionHouse.GetCommoditySearchResults(itemID)
  self:ProcessSearchData(results)
end

function AuctionatorSearchProviderMixin:ProcessItemResults(itemKey)
  local results = C_AuctionHouse.GetItemSearchResults(itemKey)
  self:ProcessSearchData(results)
end

function AuctionatorSearchProviderMixin:ProcessSearchData(results, isAdditional)
  -- Skip if no callback
  if not self.searchCallback then return end
  
  -- Apply filters
  local filteredResults = self:ApplyFilters(results)
  
  -- Apply sorts
  self:SortResults(filteredResults)
  
  -- Call the search callback
  self.searchCallback(self, filteredResults, isAdditional and "search_added" or "search_complete")
end

function AuctionatorSearchProviderMixin:ApplyFilters(results)
  local filtered = {}
  
  -- Copy all first
  for _, result in ipairs(results) do
    table.insert(filtered, result)
  end
  
  -- Apply current filter
  if self.currentFilter and #filtered > 0 then
    local newFiltered = {}
    for _, result in ipairs(filtered) do
      if self.currentFilter(result) then
        table.insert(newFiltered, result)
      end
    end
    filtered = newFiltered
  end
  
  -- Apply extra filters
  for _, filter in ipairs(self.extraFilters) do
    if filter.filter and #filtered > 0 then
      local newFiltered = {}
      for _, result in ipairs(filtered) do
        if filter.filter(result) then
          table.insert(newFiltered, result)
        end
      end
      filtered = newFiltered
    end
  end
  
  return filtered
end

function AuctionatorSearchProviderMixin:SortResults(results)
  if #self.sorts > 0 and #results > 0 then
    -- Sort based on current sorts
    table.sort(results, function(a, b)
      for _, sort in ipairs(self.sorts) do
        local comparison = sort.sorter(a, b)
        if comparison ~= 0 then
          return sort.ascending and comparison < 0 or comparison > 0
        end
      end
      return false
    end)
  end
  
  return results
end

function AuctionatorSearchProviderMixin:SetSearchCallback(callback)
  self.searchCallback = callback
end

function AuctionatorSearchProviderMixin:Search(searchString, filter, sorts)
  -- Set up search parameters
  self.currentFilter = filter
  self.sorts = sorts or {}
  
  -- Make sure events are registered
  self:RegisterEvents()
  
  -- Start the search
  C_AuctionHouse.SendBrowseQuery({
    searchString = searchString or "",
    sorts = {},
    minLevel = 0,
    maxLevel = 0,
  })
end

function AuctionatorSearchProviderMixin:SearchItem(itemKey, sorts)
  -- Set up search parameters
  self.sorts = sorts or {}
  
  -- Make sure events are registered
  self:RegisterEvents()
  
  -- Start the search
  C_AuctionHouse.SendSearchQuery(itemKey, {}, false)
end

function AuctionatorSearchProviderMixin:SearchCommodity(itemID, sorts)
  -- Set up search parameters
  self.sorts = sorts or {}
  
  -- Make sure events are registered
  self:RegisterEvents()
  
  -- Start the search
  C_AuctionHouse.SendSearchQuery(nil, {itemID}, true)
end

function AuctionatorSearchProviderMixin:AddFilter(filter)
  if filter then
    table.insert(self.extraFilters, {filter = filter})
  end
end

function AuctionatorSearchProviderMixin:RemoveFilter(filter)
  for i, existingFilter in ipairs(self.extraFilters) do
    if existingFilter.filter == filter then
      table.remove(self.extraFilters, i)
      break
    end
  end
end

function AuctionatorSearchProviderMixin:ClearFilters()
  self.extraFilters = {}
end 