local addonName, VUI = ...
local Auctionator = VUI.Auctionator

-- Mixins for Auction House components
Auctionator.AH.Mixins = {}

-- Mixin for basic tab functionality
Auctionator.AH.Mixins.TabMixin = {
  -- Initialize tab
  Init = function(self, tabTemplate, displayMode, tabHeader, onSelected)
    self.displayMode = displayMode
    self.tabHeader = tabHeader
    self.onSelected = onSelected
    
    self:SetTemplate(tabTemplate)
    self:Show()
  end,
  
  -- Set up the tab
  OnLoad = function(self)
    -- No default behavior
  end,
  
  -- Called when tab is selected
  OnSelected = function(self)
    if self.onSelected then
      self.onSelected(self)
    end
  end,
  
  -- Called when tab is deselected
  OnDeselected = function(self)
    -- No default behavior
  end,
  
  -- Check if tab is selected
  IsSelected = function(self)
    return self:IsVisible()
  end,
  
  -- Get the tab's header
  GetTabHeader = function(self)
    return self.tabHeader
  end,
  
  -- Get the tab's display mode
  GetDisplayMode = function(self)
    return self.displayMode
  end,
}

-- Mixin for auction listing item
Auctionator.AH.Mixins.ListingMixin = {
  -- Initialize listing
  Init = function(self, itemLink, quantity, timeLeft, owner, buyoutAmount, currentBid, bidAmount)
    self.itemLink = itemLink
    self.quantity = quantity
    self.timeLeft = timeLeft
    self.owner = owner
    self.buyoutAmount = buyoutAmount
    self.currentBid = currentBid
    self.bidAmount = bidAmount
    
    -- Parse item info
    self.itemName, self.itemRarity, self.itemLevel, _, _, self.itemType, self.itemSubType, _, _, self.itemTexture = GetItemInfo(itemLink)
    
    -- Calculate per-item price
    if self.buyoutAmount and self.buyoutAmount > 0 and self.quantity and self.quantity > 0 then
      self.perItem = math.floor(self.buyoutAmount / self.quantity)
    else
      self.perItem = nil
    end
    
    -- Set texture and name
    if self.icon then
      self.icon:SetTexture(self.itemTexture)
    end
    
    if self.name then
      self.name:SetText(self.itemName)
      
      -- Set color based on rarity
      if self.itemRarity and Auctionator.Constants.ITEM_QUALITY_COLORS[self.itemRarity] then
        local colorHex = Auctionator.Constants.ITEM_QUALITY_COLORS[self.itemRarity]
        self.name:SetText("|cff" .. colorHex .. self.itemName .. "|r")
      end
    end
    
    -- Set quantity
    if self.quantity and self.countText then
      self.countText:SetText(self.quantity)
      
      if self.quantity > 1 then
        self.countText:Show()
      else
        self.countText:Hide()
      end
    end
    
    -- Set prices
    if self.buyoutAmount and self.buyoutPrice then
      local formatted = Auctionator.Utilities.FormatMoney(self.buyoutAmount)
      self.buyoutPrice:SetText(formatted)
    end
    
    if self.perItem and self.itemPrice then
      local formatted = Auctionator.Utilities.FormatMoney(self.perItem)
      self.itemPrice:SetText(formatted)
    end
  end,
  
  -- Get listing info
  GetItemLink = function(self)
    return self.itemLink
  end,
  
  GetQuantity = function(self)
    return self.quantity
  end,
  
  GetPerItemPrice = function(self)
    return self.perItem
  end,
  
  GetBuyoutAmount = function(self)
    return self.buyoutAmount
  end,
  
  GetBidAmount = function(self)
    return self.bidAmount
  end,
  
  GetTimeLeft = function(self)
    return self.timeLeft
  end,
  
  GetOwner = function(self)
    return self.owner
  end,
}

-- Mixin for search result row
Auctionator.AH.Mixins.SearchResultRowMixin = {
  -- Initialize search result row
  Init = function(self, searchResult)
    self.searchResult = searchResult
    
    -- Initialize listing mixin
    Auctionator.AH.Mixins.ListingMixin.Init(
      self,
      searchResult.itemLink,
      searchResult.quantity,
      searchResult.timeLeft,
      searchResult.owner,
      searchResult.buyoutAmount,
      searchResult.bidAmount,
      searchResult.bidAmount
    )
  end,
  
  -- On click handler
  OnClick = function(self, button)
    if button == "LeftButton" then
      if IsModifiedClick("CHATLINK") then
        if self.itemLink then
          ChatEdit_InsertLink(self.itemLink)
        end
      elseif IsModifiedClick("DRESSUP") then
        if self.itemLink then
          DressUpLink(self.itemLink)
        end
      elseif self.onClick then
        self.onClick(self)
      end
    end
  end,
  
  -- On enter handler (for tooltip)
  OnEnter = function(self)
    if self.itemLink then
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      GameTooltip:SetHyperlink(self.itemLink)
      GameTooltip:Show()
    end
  end,
  
  -- On leave handler
  OnLeave = function(self)
    GameTooltip:Hide()
  end,
}