local addonName, VUI = ...
local Auctionator = VUI.Auctionator

-- Define TabSelected mixin
AuctionatorTabSelectedMixin = {}

function AuctionatorTabSelectedMixin:OnLoad()
  -- Apply VUI theme colors if available
  if VUI.ApplyThemeColor then
    VUI:ApplyThemeColor(self.SelectedTexture)
    VUI:ApplyThemeColor(self.HighlightTexture, 0.3)
    VUI:ApplyThemeColor(self.LeftSelectedTexture)
    VUI:ApplyThemeColor(self.RightSelectedTexture)
  end
  
  -- Create show/hide animations if needed
  if not self.showAnim then
    self.showAnim = self:CreateAnimationGroup()
    local fadeIn = self.showAnim:CreateAnimation("Alpha")
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(1)
    fadeIn:SetDuration(0.2)
    fadeIn:SetSmoothing("OUT")
  end
  
  if not self.hideAnim then
    self.hideAnim = self:CreateAnimationGroup()
    local fadeOut = self.hideAnim:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(0.2)
    fadeOut:SetSmoothing("IN")
    self.hideAnim:SetScript("OnFinished", function() 
      AuctionatorTabSelectedMixin.OnHideAnimFinished(self) 
    end)
  end
end

function AuctionatorTabSelectedMixin:OnShow()
  self:SetAlpha(0)
  self.showAnim:Play()
end

function AuctionatorTabSelectedMixin:OnHide()
  if self:IsVisible() then
    self.hideAnim:Play()
  else
    self:SetAlpha(0)
  end
end

function AuctionatorTabSelectedMixin:OnHideAnimFinished()
  self:SetAlpha(0)
  AuctionatorTabSelectedMixin.OnHideBase(self)
end

-- Keep reference to original OnHide
AuctionatorTabSelectedMixin.OnHideBase = AuctionatorTabSelectedMixin.OnHide 