local addonName, VUI = ...
local Auctionator = VUI.Auctionator

-- Create the Cancelling module
Auctionator.Cancel = {
  -- List of owned auctions
  ownedAuctions = {},
  
  -- List of undercut auctions
  undercutAuctions = {},
  
  -- Flag to track if a scan is in progress
  isScanningUndercuts = false,
  
  -- Event constants
  Events = {
    CANCEL_SCAN_START = "cancel_scan_start",
    CANCEL_SCAN_COMPLETE = "cancel_scan_complete",
    CANCEL_SCAN_INTERRUPTED = "cancel_scan_interrupted",
    AUCTION_CANCELLED = "auction_cancelled",
    OWNED_AUCTIONS_UPDATED = "owned_auctions_updated",
    UNDERCUT_SCAN_SUCCESS = "undercut_scan_success",
    UNDERCUT_SCAN_FAILURE = "undercut_scan_failure"
  }
}

-- Initialize the cancelling module
function Auctionator.Cancel:Initialize()
  -- Set up events
  self:SetupEvents()
end

-- Set up event handlers
function Auctionator.Cancel:SetupEvents()
  -- Listen for owned auctions updated
  Auctionator.EventBus:Register({}, Auctionator.AuctionHouse.Events.OWNED_AUCTIONS_UPDATED, function()
    self:RefreshOwnedAuctions()
  end)
  
  -- Listen for auction house open
  Auctionator.EventBus:Register({}, Auctionator.AuctionHouse.Events.AUCTION_HOUSE_SHOW, function()
    -- Clear cached data when AH opens
    self.ownedAuctions = {}
    self.undercutAuctions = {}
  end)
  
  -- Listen for auction house close
  Auctionator.EventBus:Register({}, Auctionator.AuctionHouse.Events.AUCTION_HOUSE_CLOSE, function()
    -- Clear scan in progress if AH closed
    self.isScanningUndercuts = false
  end)
end

-- Refresh the list of owned auctions
function Auctionator.Cancel:RefreshOwnedAuctions()
  if not Auctionator.AuctionHouse:IsOpen() then
    return
  end
  
  -- Clear current list
  self.ownedAuctions = {}
  
  -- Handle based on AH type
  if Auctionator.Constants.Features.IsModernAH() then
    self:RefreshRetailOwnedAuctions()
  else
    self:RefreshClassicOwnedAuctions()
  end
  
  -- Fire event
  Auctionator.EventBus:Fire({}, self.Events.OWNED_AUCTIONS_UPDATED, self.ownedAuctions)
end

-- Refresh owned auctions in retail AH
function Auctionator.Cancel:RefreshRetailOwnedAuctions()
  if not C_AuctionHouse then
    return
  end
  
  -- Get owned auctions
  local ownedAuctions = C_AuctionHouse.GetOwnedAuctions()
  
  -- Process each auction
  for _, auction in ipairs(ownedAuctions) do
    local itemLink
    
    -- Get appropriate item info
    if auction.itemKey.itemID then
      local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(auction.itemKey)
      if itemKeyInfo then
        itemLink = itemKeyInfo.itemLink
      end
    end
    
    -- Create standardized auction data
    if itemLink then
      local auctionData = {
        auctionID = auction.auctionID,
        itemLink = itemLink,
        itemID = auction.itemKey.itemID,
        quantity = auction.quantity,
        timeLeft = auction.timeLeftSeconds or auction.timeLeft,
        buyoutAmount = auction.buyoutAmount,
        bidAmount = auction.bidAmount,
        unitPrice = auction.buyoutAmount / auction.quantity,
        itemKey = auction.itemKey,
        isSold = auction.status == 1, -- 1 is Enum.AuctionStatus.Sold
        isUndercut = false -- Will be determined during scan
      }
      
      -- Add to owned auctions
      table.insert(self.ownedAuctions, auctionData)
    end
  end
end

-- Refresh owned auctions in classic AH
function Auctionator.Cancel:RefreshClassicOwnedAuctions()
  -- To be implemented for classic AH
  -- This is a placeholder since we don't have full classic AH implementation yet
end

-- Scan for undercut auctions
function Auctionator.Cancel:ScanForUndercuts()
  if not Auctionator.AuctionHouse:IsOpen() then
    Auctionator.Utilities.Message.Error(Auctionator.L.ERR_AUCTION_HOUSE_CLOSED)
    return
  end
  
  if self.isScanningUndercuts then
    Auctionator.Utilities.Message.Warning(Auctionator.L.WARNING_SCAN_IN_PROGRESS)
    return
  end
  
  -- Make sure we have owned auctions
  if #self.ownedAuctions == 0 then
    self:RefreshOwnedAuctions()
    
    if #self.ownedAuctions == 0 then
      Auctionator.Utilities.Message.Info(Auctionator.L.INFO_NO_OWNED_AUCTIONS)
      return
    end
  end
  
  -- Start the scan
  self.isScanningUndercuts = true
  self.undercutAuctions = {}
  
  -- Fire scan start event
  Auctionator.EventBus:Fire({}, self.Events.CANCEL_SCAN_START)
  
  -- Based on AH type
  if Auctionator.Constants.Features.IsModernAH() then
    self:ScanRetailUndercuts()
  else
    self:ScanClassicUndercuts()
  end
end

-- Scan for undercuts in retail AH
function Auctionator.Cancel:ScanRetailUndercuts()
  if not C_AuctionHouse then
    self:FinishUndercutScan(false, "Retail AuctionHouse API not available")
    return
  end
  
  -- Group auctions by item to minimize searches
  local itemGroups = {}
  
  for _, auction in ipairs(self.ownedAuctions) do
    -- Skip sold auctions
    if not auction.isSold then
      local key
      
      if auction.itemKey then
        key = auction.itemKey.itemID
      elseif auction.itemID then
        key = auction.itemID
      end
      
      if key then
        itemGroups[key] = itemGroups[key] or {}
        table.insert(itemGroups[key], auction)
      end
    end
  end
  
  -- Count items to scan
  local totalItems = 0
  for _ in pairs(itemGroups) do
    totalItems = totalItems + 1
  end
  
  if totalItems == 0 then
    self:FinishUndercutScan(true)
    return
  end
  
  -- Keep track of progress
  local scannedItems = 0
  
  -- Process each item group
  for itemID, auctions in pairs(itemGroups) do
    -- Setup search handlers
    local function ProcessResults()
      scannedItems = scannedItems + 1
      
      -- Get the lowest price from results
      local lowestPrice = nil
      
      -- Check if it's a commodity
      local isCommodity = false
      if auctions[1].itemKey and auctions[1].itemKey.itemID then
        isCommodity = Auctionator.Utilities.ItemInfo.IsCommodity(auctions[1].itemLink)
      end
      
      if isCommodity then
        -- Get commodity results
        local results = C_AuctionHouse.GetCommoditySearchResults(itemID)
        if results and #results > 0 then
          lowestPrice = results[1].unitPrice
        end
      else
        -- Get item results
        local itemKey = auctions[1].itemKey
        if itemKey then
          local results = C_AuctionHouse.GetItemSearchResults(itemKey)
          if results and #results > 0 then
            lowestPrice = results[1].buyoutAmount / results[1].quantity
          end
        end
      end
      
      -- Mark auctions as undercut
      if lowestPrice then
        for _, auction in ipairs(auctions) do
          if auction.unitPrice and auction.unitPrice > lowestPrice then
            auction.isUndercut = true
            table.insert(self.undercutAuctions, auction)
          end
        end
      end
      
      -- If all items scanned, finish
      if scannedItems >= totalItems then
        self:FinishUndercutScan(true)
      end
    end
    
    -- Search for the item
    if auctions[1].itemKey then
      -- Get results for this item
      if Auctionator.Utilities.ItemInfo.IsCommodity(auctions[1].itemLink) then
        -- Setup event handler for commodity search
        local commodityResultsEvent = Auctionator.EventBus:Register({}, 
          Auctionator.AuctionHouse.Events.COMMODITY_SEARCH_RESULTS_UPDATED, 
          function(resultItemID)
            if resultItemID == itemID then
              -- Unregister to prevent duplicate processing
              Auctionator.EventBus:Unregister({}, 
                Auctionator.AuctionHouse.Events.COMMODITY_SEARCH_RESULTS_UPDATED, 
                commodityResultsEvent)
                
              ProcessResults()
            end
          end
        )
        
        -- Send commodity search query
        C_AuctionHouse.SearchForItemID(itemID)
      else
        -- Setup event handler for item search
        local itemResultsEvent = Auctionator.EventBus:Register({}, 
          Auctionator.AuctionHouse.Events.ITEM_SEARCH_RESULTS_UPDATED, 
          function(resultItemKey)
            if resultItemKey.itemID == auctions[1].itemKey.itemID then
              -- Unregister to prevent duplicate processing
              Auctionator.EventBus:Unregister({}, 
                Auctionator.AuctionHouse.Events.ITEM_SEARCH_RESULTS_UPDATED, 
                itemResultsEvent)
                
              ProcessResults()
            end
          end
        )
        
        -- Send item search query
        C_AuctionHouse.SearchForItem(auctions[1].itemKey)
      end
    else
      -- Skip this item and increment counter
      scannedItems = scannedItems + 1
      
      -- If all items scanned, finish
      if scannedItems >= totalItems then
        self:FinishUndercutScan(true)
      end
    end
    
    -- Add a small delay between searches to avoid throttling
    C_Timer.After(0.25, function() end)
  end
  
  -- Set a backup timeout in case some searches don't complete
  C_Timer.After(10, function()
    if self.isScanningUndercuts then
      self:FinishUndercutScan(true, "Some searches timed out")
    end
  end)
end

-- Scan for undercuts in classic AH
function Auctionator.Cancel:ScanClassicUndercuts()
  -- To be implemented for classic AH
  -- This is a placeholder since we don't have full classic AH implementation yet
  
  self:FinishUndercutScan(false, "Classic AH undercut scan not implemented")
end

-- Finish the undercut scan
function Auctionator.Cancel:FinishUndercutScan(success, message)
  if not self.isScanningUndercuts then
    return
  end
  
  -- Mark scan as complete
  self.isScanningUndercuts = false
  
  -- Fire appropriate event
  if success then
    Auctionator.EventBus:Fire({}, self.Events.UNDERCUT_SCAN_SUCCESS, self.undercutAuctions)
    
    -- Show completion message
    if #self.undercutAuctions > 0 then
      Auctionator.Utilities.Message.Warning(string.format(
        Auctionator.L.WARNING_UNDERCUT_SCAN_COMPLETED,
        #self.undercutAuctions
      ))
    else
      Auctionator.Utilities.Message.Success(Auctionator.L.SUCCESS_NO_UNDERCUTS)
    end
  else
    Auctionator.EventBus:Fire({}, self.Events.UNDERCUT_SCAN_FAILURE, message)
    
    -- Show error message
    Auctionator.Utilities.Message.Error(message or Auctionator.L.ERR_UNKNOWN)
  end
  
  -- Fire scan complete event
  Auctionator.EventBus:Fire({}, self.Events.CANCEL_SCAN_COMPLETE, {
    undercutAuctions = self.undercutAuctions,
    success = success,
    message = message
  })
end

-- Cancel an auction
function Auctionator.Cancel:CancelAuction(auctionID)
  if not Auctionator.AuctionHouse:IsOpen() then
    Auctionator.Utilities.Message.Error(Auctionator.L.ERR_AUCTION_HOUSE_CLOSED)
    return false
  end
  
  -- Find the auction data
  local auction = nil
  for _, ownedAuction in ipairs(self.ownedAuctions) do
    if ownedAuction.auctionID == auctionID then
      auction = ownedAuction
      break
    end
  end
  
  if not auction then
    Auctionator.Utilities.Message.Error(Auctionator.L.ERR_AUCTION_NOT_FOUND)
    return false
  end
  
  -- Cancel based on AH type
  if Auctionator.Constants.Features.IsModernAH() then
    if C_AuctionHouse.CancelAuction then
      C_AuctionHouse.CancelAuction(auctionID)
      
      -- Show cancellation message
      Auctionator.Utilities.Message.AuctionChat(string.format(
        Auctionator.L.MSG_AUCTION_CANCELLED,
        Auctionator.Utilities.ItemInfo.GetColoredItemName(auction.itemLink)
      ))
      
      -- Fire event
      Auctionator.EventBus:Fire({}, self.Events.AUCTION_CANCELLED, auction)
      
      return true
    end
  else
    -- Classic AH cancellation would be implemented here
    return false
  end
  
  return false
end

-- Cancel all undercut auctions
function Auctionator.Cancel:CancelAllUndercuts()
  if not Auctionator.AuctionHouse:IsOpen() then
    Auctionator.Utilities.Message.Error(Auctionator.L.ERR_AUCTION_HOUSE_CLOSED)
    return
  end
  
  if #self.undercutAuctions == 0 then
    Auctionator.Utilities.Message.Info(Auctionator.L.INFO_NO_UNDERCUTS)
    return
  end
  
  -- Count cancellations
  local cancelCount = 0
  
  -- Process each undercut auction
  for _, auction in ipairs(self.undercutAuctions) do
    if self:CancelAuction(auction.auctionID) then
      cancelCount = cancelCount + 1
    end
    
    -- Add a small delay between cancellations
    C_Timer.After(0.2, function() end)
  end
  
  -- Show final message
  if cancelCount > 0 then
    Auctionator.Utilities.Message.Success(string.format(
      Auctionator.L.MSG_AUCTIONS_CANCELLED,
      cancelCount
    ))
  end
end