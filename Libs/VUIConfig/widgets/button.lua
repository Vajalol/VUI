local addonName, ns = ...
local VUI = _G.VUI

local button = VUI.Button or {}
VUI.Button = button

function button:Create(parent, text, width, height)
  local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
  btn:SetSize(width or 150, height or 24)
  btn:SetText(text or "Button")
  btn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(self.tooltip or "")
    GameTooltip:Show()
  end)
  btn:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end)
  
  return btn
end

function button:SetTooltip(btn, text)
  btn.tooltip = text
end
