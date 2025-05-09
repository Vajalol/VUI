local addonName, ns = ...
local VUI = _G.VUI

local slider = VUI.Slider or {}
VUI.Slider = slider

function slider:Create(parent, text, minVal, maxVal, step, initialVal, callback)
  local frame = CreateFrame("Frame", nil, parent)
  frame:SetSize(200, 50)
  
  frame.label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  frame.label:SetPoint("TOP", frame, "TOP", 0, 0)
  frame.label:SetText(text or "Slider")
  
  frame.slider = CreateFrame("Slider", nil, frame, "OptionsSliderTemplate")
  frame.slider:SetPoint("TOP", frame.label, "BOTTOM", 0, -10)
  frame.slider:SetMinMaxValues(minVal or 0, maxVal or 100)
  frame.slider:SetValueStep(step or 1)
  frame.slider:SetValue(initialVal or 50)
  frame.slider:SetWidth(180)
  frame.slider:SetObeyStepOnDrag(true)
  
  frame.slider.Low:SetText(minVal or 0)
  frame.slider.High:SetText(maxVal or 100)
  
  frame.slider.Text:SetText(initialVal or 50)
  
  frame.slider:SetScript("OnValueChanged", function(self, value)
    local displayValue = math.floor(value * 100) / 100
    self.Text:SetText(displayValue)
    if callback then
      callback(value)
    end
  end)
  
  return frame
end
