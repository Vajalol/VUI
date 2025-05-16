local addonName, VUI = ...
local Auctionator = VUI.Auctionator

-- Define TabFrame mixin
AuctionatorTabFrameMixin = {}

function AuctionatorTabFrameMixin:OnLoad()
  -- Setup default properties
  self.tabIndex = nil
  self.tabData = nil
  self.frameData = nil
  
  -- Apply VUI theme if available
  if VUI.ApplyThemeColor then
    if self.Background then
      VUI:ApplyThemeColor(self.Background, 0.2)
    end
    
    if self.Border then
      VUI:ApplyThemeColor(self.Border)
    end
  end
end

function AuctionatorTabFrameMixin:OnShow()
  -- Notify frame data that we're showing
  if self.frameData and self.frameData.OnShow then
    self.frameData:OnShow()
  end
end

function AuctionatorTabFrameMixin:OnHide()
  -- Notify frame data that we're hiding
  if self.frameData and self.frameData.OnHide then
    self.frameData:OnHide()
  end
end 