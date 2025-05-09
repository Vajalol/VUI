local addonName, ns = ...
local VUI = _G.VUI

local dropdown = VUI.Dropdown or {}
VUI.Dropdown = dropdown

function dropdown:Create(parent, label, items, initialValue, callback)
  local frame = CreateFrame("Frame", nil, parent)
  frame:SetSize(200, 40)
  
  frame.label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  frame.label:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
  frame.label:SetText(label or "Select Option:")
  
  frame.dropdown = LibStub("LibUIDropDownMenu-4.0"):Create_UIDropDownMenu(nil, frame)
  frame.dropdown:SetPoint("TOPLEFT", frame.label, "BOTTOMLEFT", 0, -5)
  frame.dropdown.items = items or {}
  frame.dropdown.selectedValue = initialValue or 1
  frame.dropdown.callback = callback
  
  LibStub("LibUIDropDownMenu-4.0"):UIDropDownMenu_SetWidth(frame.dropdown, 180)
  LibStub("LibUIDropDownMenu-4.0"):UIDropDownMenu_SetText(frame.dropdown, frame.dropdown.items[frame.dropdown.selectedValue] or "")
  
  LibStub("LibUIDropDownMenu-4.0"):UIDropDownMenu_Initialize(frame.dropdown, function(self, level)
    local info = LibStub("LibUIDropDownMenu-4.0"):UIDropDownMenu_CreateInfo()
    for key, value in pairs(frame.dropdown.items) do
      info.text = value
      info.value = key
      info.func = function()
        LibStub("LibUIDropDownMenu-4.0"):UIDropDownMenu_SetSelectedValue(frame.dropdown, key)
        LibStub("LibUIDropDownMenu-4.0"):UIDropDownMenu_SetText(frame.dropdown, value)
        frame.dropdown.selectedValue = key
        if frame.dropdown.callback then
          frame.dropdown.callback(key, value)
        end
      end
      if key == frame.dropdown.selectedValue then
        info.checked = true
      else
        info.checked = false
      end
      LibStub("LibUIDropDownMenu-4.0"):UIDropDownMenu_AddButton(info)
    end
  end)
  
  return frame
end
