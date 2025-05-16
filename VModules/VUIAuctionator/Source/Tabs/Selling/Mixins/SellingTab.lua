local addonName, VUI = ...
local Auctionator = VUI.Auctionator

AuctionatorSellingTabMixin = CreateFromMixins(AuctionatorTabMixin)

function AuctionatorSellingTabMixin:OnLoad()
  -- Apply VUI theme if available
  if VUI.ApplyThemeColor then
    if self.Background then
      VUI:ApplyThemeColor(self.Background, 0.2)
    end
    
    if self.Border then
      VUI:ApplyThemeColor(self.Border)
    end
  end
  
  -- Initialize the tab
  self:SetTitle("Selling")
  self:SetupSaleItem()
  self:SetupItemHistory()
  self:SetupBagItems()
  
  -- Register for events
  self:RegisterEvents()
end

function AuctionatorSellingTabMixin:SetTitle(title)
  if self.TitleText then
    self.TitleText:SetText(title)
  end
end

function AuctionatorSellingTabMixin:RegisterEvents()
  -- Register for auction events
  self:RegisterTabEvent("AUCTION_HOUSE_AUCTION_CREATED")
  self:RegisterTabEvent("COMMODITY_SEARCH_RESULTS_UPDATED")
  self:RegisterTabEvent("ITEM_SEARCH_RESULTS_UPDATED")
  self:RegisterTabEvent("INVENTORY_ITEM_UNLOCKED")
end

function AuctionatorSellingTabMixin:OnShow()
  -- Refresh bag items
  if self.BagItemContainer and self.BagItemContainer.RefreshItems then
    self.BagItemContainer:RefreshItems()
  end
  
  -- Set initial focus
  if Auctionator.Config.Get(Auctionator.Config.Options.SELLING_AUTO_FOCUS_SEARCH) then
    self:SetSearchFieldFocus()
  end
end

function AuctionatorSellingTabMixin:OnEvent(eventName, ...)
  if eventName == "AUCTION_HOUSE_AUCTION_CREATED" then
    -- Handle auction created
    self:AuctionCreated(...)
  elseif eventName == "COMMODITY_SEARCH_RESULTS_UPDATED" then
    -- Handle commodity results
    self:CommodityResultsUpdated(...)
  elseif eventName == "ITEM_SEARCH_RESULTS_UPDATED" then
    -- Handle item results
    self:ItemResultsUpdated(...)
  elseif eventName == "INVENTORY_ITEM_UNLOCKED" then
    -- Refresh bag items when inventory unlocks
    self:RefreshBagItems()
  end
end

function AuctionatorSellingTabMixin:SetupSaleItem()
  -- Create the sale item UI components
  self.SaleItem = CreateFrame("Frame", nil, self, "AuctionatorSaleItemTemplate")
  self.SaleItem:SetPoint("TOP", 0, -30)
  -- Additional setup for sale item
end

function AuctionatorSellingTabMixin:SetupItemHistory()
  -- Create the price history UI components
  self.PriceHistory = CreateFrame("Frame", nil, self, "AuctionatorPriceHistoryTemplate")
  self.PriceHistory:SetPoint("TOPLEFT", self.SaleItem, "BOTTOMLEFT", 0, -15)
  -- Additional setup for price history
end

function AuctionatorSellingTabMixin:SetupBagItems()
  -- Create the bag items UI components
  self.BagItemContainer = CreateFrame("Frame", nil, self, "AuctionatorBagItemsTemplate")
  self.BagItemContainer:SetPoint("TOPLEFT", self.PriceHistory, "BOTTOMLEFT", 0, -15)
  -- Additional setup for bag items
end

function AuctionatorSellingTabMixin:RefreshBagItems()
  if self.BagItemContainer and self.BagItemContainer.RefreshItems then
    self.BagItemContainer:RefreshItems()
  end
end

function AuctionatorSellingTabMixin:SetSearchFieldFocus()
  if self.SaleItem and self.SaleItem.SearchBox then
    self.SaleItem.SearchBox:SetFocus()
  end
end

function AuctionatorSellingTabMixin:AuctionCreated(...)
  -- Handle auction creation
  -- Refresh items, update history, etc.
  self:RefreshBagItems()
end

function AuctionatorSellingTabMixin:CommodityResultsUpdated(...)
  -- Update commodity pricing UI
end

function AuctionatorSellingTabMixin:ItemResultsUpdated(...)
  -- Update item pricing UI
end

-- Expose the mixin globally for XML template use
Auctionator.Tabs.Selling = {
  Mixin = AuctionatorSellingTabMixin,
  Template = "AuctionatorSellingTabFrameTemplate",
} 