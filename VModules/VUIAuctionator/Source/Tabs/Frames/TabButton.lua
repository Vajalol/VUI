local addonName, VUI = ...
local Auctionator = VUI.Auctionator

AuctionatorTabButtonMixin = {}

function AuctionatorTabButtonMixin:OnLoad()
  -- Create the selection highlight
  if not self.Selected then
    self.Selected = CreateFrame("Frame", nil, self, "AuctionatorTabSelectedTemplate")
    self.Selected:SetAllPoints()
    self.Selected:Hide()
  end
  
  -- Apply VUI theme colors if available
  if VUI.ApplyThemeColor then
    VUI:ApplyThemeColor(self.HighlightTexture)
    VUI:ApplyThemeColor(self.LeftCapTexture)
    VUI:ApplyThemeColor(self.RightCapTexture)
    VUI:ApplyThemeColor(self.TabardEmblemTexture)
    VUI:ApplyThemeColor(self.TabardBorderTexture)
  end
end

function AuctionatorTabButtonMixin:OnClick()
  -- Pass the click to the tab container for handling
  if self.Container and self:GetID() then
    self.Container:TabClicked(self:GetID())
    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
  end
end 

function AuctionatorTabButtonMixin:OnEnter()
  if self.tabHeader then
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText(self.tabHeader)
    GameTooltip:Show()
  end
end

function AuctionatorTabButtonMixin:OnLeave()
  GameTooltip:Hide()
end 