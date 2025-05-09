local addonName, ns = ...
local VUI = _G.VUI

local checkbox = VUI.Checkbox or {}
VUI.Checkbox = checkbox

function checkbox:Create(parent, text, initialValue, callback)
  local cb = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
  cb.Text:SetText(text or "Option")
  cb:SetChecked(initialValue or false)
  cb:SetScript("OnClick", function(self)
    local checked = self:GetChecked()
    if callback then
      callback(checked)
    end
  end)
  cb:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(self.tooltip or "")
    GameTooltip:Show()
  end)
  cb:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end)
  
  return cb
end

function checkbox:SetTooltip(cb, text)
  cb.tooltip = text
end
