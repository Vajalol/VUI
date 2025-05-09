local addonName, VUI = ...
local Auctionator = VUI.Auctionator

-- Create the History module
Auctionator.History = {
  -- Sale history
  salesHistory = {},
  
  -- Purchase history
  purchaseHistory = {},
  
  -- Event constants
  Events = {
    HISTORY_LOADED = "history_loaded",
    SALE_ADDED = "sale_history_added",
    PURCHASE_ADDED = "purchase_history_added",
    HISTORY_PURGED = "history_purged"
  }
}

-- Initialize the history module
function Auctionator.History:Initialize()
  -- Load saved history
  self:LoadHistory()
  
  -- Setup events
  self:SetupEvents()
end

-- Set up event handlers
function Auctionator.History:SetupEvents()
  -- Listen for auction house events
  if Auctionator.Constants.Features.IsModernAH() then
    -- In retail, hook into C_AuctionHouse events
    hooksecurefunc(C_AuctionHouse, "PlaceBid", function(auctionID, bidAmount)
      self:OnAuctionBidPlaced(auctionID, bidAmount)
    end)
  else
    -- In classic, hook into auction frame scripts
    -- (This would be implemented as needed)
  end
  
  -- Register with PLAYER_INTERACTION_MANAGER_FRAME_SHOW event to detect mailbox
  local eventFrame = CreateFrame("Frame")
  eventFrame:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW")
  eventFrame:SetScript("OnEvent", function(_, event, interactionType)
    if event == "PLAYER_INTERACTION_MANAGER_FRAME_SHOW" and interactionType == 17 then -- 17 = Enum.PlayerInteractionType.Mailbox
      -- Mailbox opened, scan for auction results
      self:ScanMailboxForAuctionResults()
    end
  end)
end

-- Load saved history
function Auctionator.History:LoadHistory()
  -- Ensure VUI_SavedVariables.VUIAuctionatorHistory exists
  if not VUI_SavedVariables.VUIAuctionatorHistory then
    VUI_SavedVariables.VUIAuctionatorHistory = {
      sales = {},
      purchases = {}
    }
  end
  
  -- Load from SavedVariables
  self.salesHistory = VUI_SavedVariables.VUIAuctionatorHistory.sales
  self.purchaseHistory = VUI_SavedVariables.VUIAuctionatorHistory.purchases
  
  -- Purge old history if needed
  self:PurgeOldHistory()
  
  -- Fire event
  Auctionator.EventBus:Fire({}, self.Events.HISTORY_LOADED, {
    sales = self.salesHistory,
    purchases = self.purchaseHistory
  })
end

-- Save history
function Auctionator.History:SaveHistory()
  VUI_SavedVariables.VUIAuctionatorHistory = {
    sales = self.salesHistory,
    purchases = self.purchaseHistory
  }
end

-- Handle auction bid placed
function Auctionator.History:OnAuctionBidPlaced(auctionID, bidAmount)
  if not C_AuctionHouse or not auctionID or not bidAmount then
    return
  end
  
  -- Get the auction info
  local results
  local itemKey
  
  -- Need to look up browse results to find the auction
  local allResults = C_AuctionHouse.GetAllAuctions()
  
  if allResults then
    for _, result in ipairs(allResults) do
      if result.auctionID == auctionID then
        results = result
        itemKey = result.itemKey
        break
      end
    end
  end
  
  if not results then
    return
  end
  
  -- Create purchase record
  local purchase = {
    itemID = itemKey.itemID,
    itemLink = C_AuctionHouse.GetItemKeyInfo(itemKey).itemLink,
    price = bidAmount,
    quantity = results.quantity,
    unitPrice = bidAmount / results.quantity,
    seller = results.owners and results.owners[1] or nil,
    timestamp = time(),
    auctionType = "bid" -- bid or buyout
  }
  
  -- Add to history
  self:AddPurchase(purchase)
end

-- Add a purchase to history
function Auctionator.History:AddPurchase(purchase)
  if not purchase or not purchase.itemLink or not purchase.price then
    return
  end
  
  -- Add to purchase history
  table.insert(self.purchaseHistory, purchase)
  
  -- Keep history at a reasonable size
  while #self.purchaseHistory > 1000 do
    table.remove(self.purchaseHistory, 1)
  end
  
  -- Save
  self:SaveHistory()
  
  -- Fire event
  Auctionator.EventBus:Fire({}, self.Events.PURCHASE_ADDED, purchase)
  
  -- Record in price database
  Auctionator.Database.UpdatePrice(purchase.itemLink, purchase.unitPrice)
end

-- Add a sale to history
function Auctionator.History:AddSale(sale)
  if not sale or not sale.itemLink or not sale.price then
    return
  end
  
  -- Add to sales history
  table.insert(self.salesHistory, sale)
  
  -- Keep history at a reasonable size
  while #self.salesHistory > 1000 do
    table.remove(self.salesHistory, 1)
  end
  
  -- Save
  self:SaveHistory()
  
  -- Fire event
  Auctionator.EventBus:Fire({}, self.Events.SALE_ADDED, sale)
end

-- Scan mailbox for auction results
function Auctionator.History:ScanMailboxForAuctionResults()
  -- Get number of mail items
  local numItems = GetInboxNumItems()
  
  -- Process each mail
  for i = 1, numItems do
    -- Check if it's an auction mail
    local _, _, sender, subject, money, _, daysLeft, _, wasRead, _, _, _ = GetInboxHeaderInfo(i)
    
    -- Look for auction house mails
    if sender and (sender:find(AUCTION_HOUSE_MAIL_SUBJECT_SOLD) or sender:find("Auction House")) then
      -- Auction sale
      if subject:find(AUCTION_HOUSE_MAIL_SUBJECT_SOLD) then
        -- Extract item info from attachment
        local hasItem = false
        local itemLink
        local quantity = 1
        
        for j = 1, ATTACHMENTS_MAX_RECEIVE do
          local name, itemID, texture, count, quality, canUse = GetInboxItem(i, j)
          
          if name and itemID then
            hasItem = true
            itemLink = GetInboxItemLink(i, j)
            quantity = count or 1
            break
          end
        end
        
        -- If we have an item and money, record the sale
        if hasItem and itemLink and money and money > 0 then
          -- Create sale record
          local sale = {
            itemLink = itemLink,
            price = money,
            quantity = quantity,
            unitPrice = money / quantity,
            buyer = nil, -- Can't get buyer info
            timestamp = time() - (30 - daysLeft) * 24 * 60 * 60, -- Estimate when sale occurred
            mailIndex = i
          }
          
          -- Add to history
          self:AddSale(sale)
        end
      end
    end
  end
end

-- Purge old history
function Auctionator.History:PurgeOldHistory()
  local historyDays = Auctionator.Config.Get(Auctionator.Config.Options.PRICE_HISTORY_DAYS)
  local cutoffTime = time() - (historyDays * 24 * 60 * 60)
  
  -- Purge old sales
  local i = 1
  while i <= #self.salesHistory do
    if self.salesHistory[i].timestamp < cutoffTime then
      table.remove(self.salesHistory, i)
    else
      i = i + 1
    end
  end
  
  -- Purge old purchases
  i = 1
  while i <= #self.purchaseHistory do
    if self.purchaseHistory[i].timestamp < cutoffTime then
      table.remove(self.purchaseHistory, i)
    else
      i = i + 1
    end
  end
  
  -- Save
  self:SaveHistory()
  
  -- Fire event
  Auctionator.EventBus:Fire({}, self.Events.HISTORY_PURGED)
end

-- Get sales history for an item
function Auctionator.History:GetItemSaleHistory(itemLink)
  if not itemLink then
    return {}
  end
  
  local itemID = Auctionator.Utilities.ItemInfo.GetItemID(itemLink)
  
  if not itemID then
    return {}
  end
  
  -- Find all sales for this item
  local sales = {}
  
  for _, sale in ipairs(self.salesHistory) do
    local saleItemID = Auctionator.Utilities.ItemInfo.GetItemID(sale.itemLink)
    
    if saleItemID and saleItemID == itemID then
      table.insert(sales, sale)
    end
  end
  
  -- Sort by timestamp, newest first
  table.sort(sales, function(a, b)
    return a.timestamp > b.timestamp
  end)
  
  return sales
end

-- Get purchase history for an item
function Auctionator.History:GetItemPurchaseHistory(itemLink)
  if not itemLink then
    return {}
  end
  
  local itemID = Auctionator.Utilities.ItemInfo.GetItemID(itemLink)
  
  if not itemID then
    return {}
  end
  
  -- Find all purchases for this item
  local purchases = {}
  
  for _, purchase in ipairs(self.purchaseHistory) do
    local purchaseItemID = Auctionator.Utilities.ItemInfo.GetItemID(purchase.itemLink)
    
    if purchaseItemID and purchaseItemID == itemID then
      table.insert(purchases, purchase)
    end
  end
  
  -- Sort by timestamp, newest first
  table.sort(purchases, function(a, b)
    return a.timestamp > b.timestamp
  end)
  
  return purchases
end

-- Get average sale price for an item
function Auctionator.History:GetAverageSalePrice(itemLink)
  local sales = self:GetItemSaleHistory(itemLink)
  
  if #sales == 0 then
    return nil
  end
  
  -- Calculate average price
  local totalPrice = 0
  local totalQuantity = 0
  
  for _, sale in ipairs(sales) do
    totalPrice = totalPrice + sale.price
    totalQuantity = totalQuantity + sale.quantity
  end
  
  return totalPrice / totalQuantity
end

-- Get average purchase price for an item
function Auctionator.History:GetAveragePurchasePrice(itemLink)
  local purchases = self:GetItemPurchaseHistory(itemLink)
  
  if #purchases == 0 then
    return nil
  end
  
  -- Calculate average price
  local totalPrice = 0
  local totalQuantity = 0
  
  for _, purchase in ipairs(purchases) do
    totalPrice = totalPrice + purchase.price
    totalQuantity = totalQuantity + purchase.quantity
  end
  
  return totalPrice / totalQuantity
end