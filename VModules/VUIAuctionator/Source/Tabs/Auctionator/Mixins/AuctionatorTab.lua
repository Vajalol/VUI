local addonName, VUI = ...
local Auctionator = VUI.Auctionator

AuctionatorAuctionatorTabMixin = CreateFromMixins(AuctionatorTabMixin)

function AuctionatorAuctionatorTabMixin:OnLoad()
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
  self:SetTitle("Auctionator")
  
  -- Set up config sections
  self:SetupConfigPanel()
  self:SetupSummaryPanel()
  
  -- Register events
  self:RegisterTabEvent("AUCTION_HOUSE_THROTTLED_SYSTEM_READY")
  self:RegisterTabEvent("AUCTION_HOUSE_THROTTLED_MESSAGE_SENT")
  self:RegisterTabEvent("AUCTION_HOUSE_THROTTLED_MESSAGE_DROPPED")
end

function AuctionatorAuctionatorTabMixin:SetTitle(title)
  if self.TitleText then
    self.TitleText:SetText(title)
  end
end

function AuctionatorAuctionatorTabMixin:SetupConfigPanel()
  -- Create config panel frame
  self.Config = CreateFrame("Frame", nil, self, "AuctionatorConfigTemplate")
  self.Config:SetPoint("TOPLEFT", 0, -30)
  self.Config:SetPoint("BOTTOMRIGHT", 0, 0)
  self.Config:Show()
end

function AuctionatorAuctionatorTabMixin:SetupSummaryPanel()
  -- Create summary panel frame
  self.Summary = CreateFrame("Frame", nil, self, "AuctionatorSummaryTemplate")
  self.Summary:SetPoint("TOPLEFT", self.Config, "TOPRIGHT", 20, 0)
  self.Summary:SetPoint("BOTTOMRIGHT", 0, 0)
  self.Summary:Show()
end

function AuctionatorAuctionatorTabMixin:OnEvent(eventName, ...)
  if eventName == "AUCTION_HOUSE_THROTTLED_SYSTEM_READY" then
    -- Update throttle status display
    if self.Summary and self.Summary.UpdateThrottleStatus then
      self.Summary:UpdateThrottleStatus(true)
    end
  elseif eventName == "AUCTION_HOUSE_THROTTLED_MESSAGE_SENT" then
    -- Update message count
    if self.Summary and self.Summary.IncrementMessageCount then
      self.Summary:IncrementMessageCount()
    end
  elseif eventName == "AUCTION_HOUSE_THROTTLED_MESSAGE_DROPPED" then
    -- Update dropped message count
    if self.Summary and self.Summary.IncrementDroppedCount then
      self.Summary:IncrementDroppedCount()
    end
  end
end

function AuctionatorAuctionatorTabMixin:OnShow()
  -- Refresh data when shown
  if self.Summary and self.Summary.RefreshData then
    self.Summary:RefreshData()
  end
end

-- Expose the mixin globally for XML template use
Auctionator.Tabs.Auctionator = {
  Mixin = AuctionatorAuctionatorTabMixin,
  Template = "AuctionatorTabTemplate",
} 