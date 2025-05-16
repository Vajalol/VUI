local addonName, VUI = ...
local Auctionator = VUI.Auctionator

AuctionatorCancellingTabMixin = CreateFromMixins(AuctionatorTabMixin)

function AuctionatorCancellingTabMixin:OnLoad()
  -- Apply VUI theme if available
  if VUI.ApplyThemeColor then
    if self.Background then
      VUI:ApplyThemeColor(self.Background, 0.2)
    end
    
    if self.Border then
      VUI:ApplyThemeColor(self.Border)
    end
    
    -- Apply theme to buttons
    VUI:ApplyThemeColor(self.RefreshButton)
    VUI:ApplyThemeColor(self.CancelButton)
    VUI:ApplyThemeColor(self.CancelAllButton)
  end
  
  -- Set up the results frame
  self:SetupResultsListing()
  
  -- Register for events
  self:RegisterEvents()
  
  -- Set up button handlers
  self:SetupButtonHandlers()
end

function AuctionatorCancellingTabMixin:RegisterEvents()
  -- Register for auction events
  self:RegisterTabEvent("AUCTION_OWNED_LIST_UPDATE")
  self:RegisterTabEvent("AUCTION_HOUSE_AUCTION_CREATED")
  self:RegisterTabEvent("AUCTION_CANCELLED")
end

function AuctionatorCancellingTabMixin:OnShow()
  -- Get auction data when shown
  self:RefreshAuctions()
end

function AuctionatorCancellingTabMixin:OnEvent(eventName, ...)
  if eventName == "AUCTION_OWNED_LIST_UPDATE" then
    self:RefreshAuctions()
  elseif eventName == "AUCTION_HOUSE_AUCTION_CREATED" then
    -- New auction has been created, refresh after a short delay
    C_Timer.After(0.5, function() self:RefreshAuctions() end)
  elseif eventName == "AUCTION_CANCELLED" then
    -- Auction has been cancelled, refresh after a short delay
    C_Timer.After(0.5, function() self:RefreshAuctions() end)
  end
end

function AuctionatorCancellingTabMixin:SetupButtonHandlers()
  -- Refresh button
  self.RefreshButton:SetScript("OnClick", function()
    self:RefreshAuctions()
  end)
  
  -- Cancel button
  self.CancelButton:SetScript("OnClick", function()
    self:CancelSelectedAuction()
  end)
  
  -- Cancel All button
  self.CancelAllButton:SetScript("OnClick", function()
    self:CancelAllUndercutAuctions()
  end)
end

function AuctionatorCancellingTabMixin:SetupResultsListing()
  -- Initialize tables to hold auction data and frames
  self.auctions = {}
  self.undercutAuctions = {}
  self.auctionFrames = {}
  
  -- Disable cancel buttons until an auction is selected
  self.CancelButton:Disable()
  self.CancelAllButton:Disable()
end

function AuctionatorCancellingTabMixin:RefreshAuctions()
  -- Show loading text
  self.Title:SetText("Loading Auctions...")
  
  -- Clear current data
  self.auctions = {}
  self.undercutAuctions = {}
  self.selectedAuctionIndex = nil
  
  -- Get owned auctions
  C_AuctionHouse.QueryOwnedAuctions({})
  
  -- Process results after a short delay
  C_Timer.After(0.5, function()
    self:ProcessOwnedAuctions()
  end)
end

function AuctionatorCancellingTabMixin:ProcessOwnedAuctions()
  local numAuctions = C_AuctionHouse.GetNumOwnedAuctions()
  
  if numAuctions == 0 then
    self.Title:SetText("No Active Auctions")
    self:UpdateDisplay()
    return
  end
  
  -- Process all owned auctions
  for i = 1, numAuctions do
    local info = C_AuctionHouse.GetOwnedAuctionInfo(i)
    if info then
      table.insert(self.auctions, info)
    end
  end
  
  -- Find undercut auctions
  self:FindUndercutAuctions()
end

function AuctionatorCancellingTabMixin:FindUndercutAuctions()
  self.undercutAuctions = {}
  
  -- Group auctions by item
  local auctionsByItem = {}
  
  -- First pass: organize auctions by item ID
  for _, auction in ipairs(self.auctions) do
    local itemID = auction.itemKey.itemID
    if not auctionsByItem[itemID] then
      auctionsByItem[itemID] = {}
    end
    table.insert(auctionsByItem[itemID], auction)
  end
  
  -- Check if this item is being undercut in the AH
  local checkItemForUndercutting = function(itemID, ownAuctions)
    -- Only do this for items that we currently have listed
    if #ownAuctions == 0 then return end
    
    -- Find lowest own price
    local lowestOwnPrice = math.huge
    for _, auction in ipairs(ownAuctions) do
      local unitPrice = auction.buyoutAmount / auction.quantity
      if unitPrice < lowestOwnPrice then
        lowestOwnPrice = unitPrice
      end
    end
    
    -- Search for this item in the AH to find if undercut
    local searchKey = C_AuctionHouse.MakeItemKey(itemID)
    
    -- This is a callback because AH searches are asynchronous
    local function ProcessItemSearchResults()
      local numResults = C_AuctionHouse.GetNumItemSearchResults(searchKey)
      if numResults > 0 then
        local lowestAHPrice = math.huge
        local lowestAHIndex = 0
        
        -- Find the lowest price on the AH
        for i = 1, numResults do
          local result = C_AuctionHouse.GetItemSearchResultInfo(searchKey, i)
          if result then
            local unitPrice = result.buyoutAmount / result.quantity
            if unitPrice < lowestAHPrice then
              lowestAHPrice = unitPrice
              lowestAHIndex = i
            end
          end
        end
        
        -- If the lowest AH price is lower than our price, we've been undercut
        if lowestAHPrice < lowestOwnPrice then
          for _, auction in ipairs(ownAuctions) do
            auction.undercut = true
            auction.undercutAmount = lowestOwnPrice - lowestAHPrice
            auction.undercutPercentage = (auction.undercutAmount / lowestOwnPrice) * 100
            table.insert(self.undercutAuctions, auction)
          end
        end
      end
      
      -- Update the display
      self:UpdateDisplay()
    end
    
    -- Register for the search result event for this item
    local searchResultCallback = function(itemKey)
      if itemKey.itemID == itemID then
        C_Timer.After(0.1, ProcessItemSearchResults)
      end
    end
    
    -- Register the callback only once
    if not self.itemSearchCallback then
      self.RegisterCallback = self.RegisterCallback or function(self, event, callback)
        if not self.callbacks then
          self.callbacks = {}
        end
        self.callbacks[event] = callback
      end
      
      self:RegisterCallback("ITEM_SEARCH_RESULTS_UPDATED", searchResultCallback)
      
      -- Hook into the event
      self:RegisterTabEvent("ITEM_SEARCH_RESULTS_UPDATED")
      local oldOnEvent = self.OnEvent
      self.OnEvent = function(self, eventName, ...)
        if eventName == "ITEM_SEARCH_RESULTS_UPDATED" and self.callbacks and self.callbacks[eventName] then
          self.callbacks[eventName](...)
        end
        return oldOnEvent(self, eventName, ...)
      end
      
      self.itemSearchCallback = true
    end
    
    -- Start the search
    C_AuctionHouse.SearchForItem(itemID)
  end
  
  -- Process each item to find undercutting
  for itemID, ownAuctions in pairs(auctionsByItem) do
    checkItemForUndercutting(itemID, ownAuctions)
  end
  
  -- If we found undercuts, enable the cancel all button
  if #self.undercutAuctions > 0 then
    self.CancelAllButton:Enable()
  else
    self.CancelAllButton:Disable()
  end
  
  -- Update title
  self.Title:SetText(string.format("Active Auctions (%d total, %d undercut)", 
    #self.auctions, #self.undercutAuctions))
  
  -- Update the display
  self:UpdateDisplay()
end

function AuctionatorCancellingTabMixin:UpdateDisplay()
  -- Create frames if needed
  if not self.auctionFrames then
    self.auctionFrames = {}
  end
  
  -- Clear existing frames
  for _, frame in ipairs(self.auctionFrames) do
    frame:Hide()
    frame:ClearAllPoints()
  end
  
  -- Create frames for each auction
  local previousFrame = nil
  local scrollChild = self.ResultsListing.ScrollFrame.scrollChild
  local displayAuctions = #self.undercutAuctions > 0 and self.undercutAuctions or self.auctions
  
  for i, auction in ipairs(displayAuctions) do
    local frame = self.auctionFrames[i]
    if not frame then
      frame = CreateFrame("Button", nil, scrollChild)
      frame:SetSize(550, 20)
      
      -- Item name text
      frame.nameText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
      frame.nameText:SetPoint("LEFT", 5, 0)
      frame.nameText:SetSize(250, 20)
      frame.nameText:SetJustifyH("LEFT")
      
      -- Bid/Buyout text
      frame.priceText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
      frame.priceText:SetPoint("LEFT", frame.nameText, "RIGHT", 10, 0)
      frame.priceText:SetSize(100, 20)
      frame.priceText:SetJustifyH("RIGHT")
      
      -- Time left text
      frame.timeLeftText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
      frame.timeLeftText:SetPoint("LEFT", frame.priceText, "RIGHT", 10, 0)
      frame.timeLeftText:SetSize(80, 20)
      frame.timeLeftText:SetJustifyH("RIGHT")
      
      -- Status text
      frame.statusText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
      frame.statusText:SetPoint("LEFT", frame.timeLeftText, "RIGHT", 10, 0)
      frame.statusText:SetPoint("RIGHT", frame, "RIGHT", -5, 0)
      frame.statusText:SetJustifyH("RIGHT")
      
      frame:SetScript("OnClick", function()
        self:SelectAuction(i)
      end)
      
      frame:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
      
      self.auctionFrames[i] = frame
    end
    
    -- Get item info
    local itemLink = auction.itemLink
    local itemName = itemLink or "Unknown Item"
    
    -- Set item name
    frame.nameText:SetText(itemName)
    
    -- Set price 
    local price = auction.buyoutAmount
    frame.priceText:SetText(Auctionator.Utilities.FormatMoney(price))
    
    -- Set time left
    local timeLeftText = self:GetTimeLeftText(auction.timeLeftSeconds or auction.timeLeft)
    frame.timeLeftText:SetText(timeLeftText)
    
    -- Set status
    if auction.undercut then
      frame.statusText:SetText("Undercut!")
      frame.statusText:SetTextColor(1, 0.3, 0.3)
    else
      frame.statusText:SetText("")
    end
    
    -- Position the frame
    if previousFrame then
      frame:SetPoint("TOPLEFT", previousFrame, "BOTTOMLEFT", 0, -2)
    else
      frame:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 5, -5)
    end
    
    frame:Show()
    previousFrame = frame
  end
  
  -- Update content height
  scrollChild:SetSize(550, #displayAuctions * 22 + 10)
end

function AuctionatorCancellingTabMixin:GetTimeLeftText(timeLeft)
  if not timeLeft then return "Unknown" end
  
  -- Handle both timeLeft enum and timeLeftSeconds
  if type(timeLeft) == "number" and timeLeft > 10000 then
    -- We have seconds
    local hours = math.floor(timeLeft / 3600)
    local minutes = math.floor((timeLeft % 3600) / 60)
    
    if hours > 0 then
      return string.format("%dh %dm", hours, minutes)
    else
      return string.format("%dm", minutes)
    end
  else
    -- We have enum
    if timeLeft == Enum.AuctionHouseTimeLeftBand.Short then
      return "< 30m"
    elseif timeLeft == Enum.AuctionHouseTimeLeftBand.Medium then
      return "30m - 2h"
    elseif timeLeft == Enum.AuctionHouseTimeLeftBand.Long then
      return "2h - 12h"
    elseif timeLeft == Enum.AuctionHouseTimeLeftBand.VeryLong then
      return "> 12h"
    else
      return "Unknown"
    end
  end
end

function AuctionatorCancellingTabMixin:SelectAuction(index)
  -- Clear previous selection
  if self.selectedAuctionIndex and self.auctionFrames[self.selectedAuctionIndex] then
    local frame = self.auctionFrames[self.selectedAuctionIndex]
    frame:UnlockHighlight()
  end
  
  -- Set new selection
  self.selectedAuctionIndex = index
  
  if self.auctionFrames[index] then
    local frame = self.auctionFrames[index]
    frame:LockHighlight()
    
    -- Enable cancel button
    self.CancelButton:Enable()
  end
end

function AuctionatorCancellingTabMixin:CancelSelectedAuction()
  if not self.selectedAuctionIndex then return end
  
  local displayAuctions = #self.undercutAuctions > 0 and self.undercutAuctions or self.auctions
  local auction = displayAuctions[self.selectedAuctionIndex]
  
  if auction then
    C_AuctionHouse.CancelAuction(auction.auctionID)
    
    -- Show cancelling status
    self.Title:SetText("Cancelling auction...")
    
    -- Disable cancel button until next selection
    self.CancelButton:Disable()
  end
end

function AuctionatorCancellingTabMixin:CancelAllUndercutAuctions()
  if #self.undercutAuctions == 0 then return end
  
  -- Confirm before cancelling all
  StaticPopupDialogs["CONFIRM_CANCEL_ALL_UNDERCUT"] = StaticPopupDialogs["CONFIRM_CANCEL_ALL_UNDERCUT"] or {
    text = "Are you sure you want to cancel all undercut auctions (%d)?",
    button1 = ACCEPT,
    button2 = CANCEL,
    OnAccept = function()
      -- Proceed with cancellation
      self:ProcessCancelAllUndercut()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
  }
  
  StaticPopup_Show("CONFIRM_CANCEL_ALL_UNDERCUT", #self.undercutAuctions)
end

function AuctionatorCancellingTabMixin:ProcessCancelAllUndercut()
  -- Create a queue of auctions to cancel
  self.cancelQueue = {}
  for _, auction in ipairs(self.undercutAuctions) do
    table.insert(self.cancelQueue, auction.auctionID)
  end
  
  -- Process the queue with a delay between each cancellation
  self:CancelNextInQueue()
end

function AuctionatorCancellingTabMixin:CancelNextInQueue()
  if not self.cancelQueue or #self.cancelQueue == 0 then
    -- Queue is empty, update display
    self.Title:SetText("Cancellation complete")
    return
  end
  
  -- Get next auction to cancel
  local auctionID = table.remove(self.cancelQueue, 1)
  
  -- Cancel the auction
  C_AuctionHouse.CancelAuction(auctionID)
  
  -- Update status
  self.Title:SetText(string.format("Cancelling auctions... (%d remaining)", #self.cancelQueue))
  
  -- Process next auction after a short delay
  C_Timer.After(0.5, function()
    self:CancelNextInQueue()
  end)
end

-- Expose the mixin globally for XML template use
Auctionator.Tabs.Cancelling = {
  Mixin = AuctionatorCancellingTabMixin,
  Template = "AuctionatorCancellingTabFrameTemplate",
} 