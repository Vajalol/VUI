-------------------------------------------------------------------------------
-- VUI Gfinder (based on Premade Groups Filter)
-- Module for VUI - Vortex UI Addon Suite
-------------------------------------------------------------------------------

local VUI = _G.VUI
local Module = VUI:GetModule("VUIGfinder")
if not Module then return end

local VUIGfinder = _G.VUIGfinder
local L = VUIGfinder.L

-- Create UI namespace
VUIGfinder.UI = {}
local UI = VUIGfinder.UI

-- UI colors
UI.COLORS = {
    PRIMARY = {r = 0.42, g = 0.73, b = 1.0},
    SECONDARY = {r = 0.31, g = 0.53, b = 0.8},
    SUCCESS = {r = 0.2, g = 0.8, b = 0.2},
    DANGER = {r = 0.9, g = 0.2, b = 0.2},
    WARNING = {r = 0.9, g = 0.7, b = 0.0},
    INFO = {r = 0.5, g = 0.5, b = 0.9},
    HEADER = {r = 1.0, g = 0.9, b = 0.0},
    TEXT = {r = 1.0, g = 1.0, b = 1.0},
    FADED = {r = 0.7, g = 0.7, b = 0.7},
    DARK = {r = 0.2, g = 0.2, b = 0.2},
}

-- Font sizes
UI.FONT_SIZE = {
    TINY = 9,
    SMALL = 10,
    NORMAL = 12,
    MEDIUM = 14,
    LARGE = 16,
    TITLE = 18,
}

-- Create a basic frame
function UI:CreateFrame(name, parent, width, height)
    local frame = CreateFrame("Frame", name, parent, "BackdropTemplate")
    frame:SetSize(width or 100, height or 100)
    
    -- Add backdrop
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = {left = 11, right = 12, top = 12, bottom = 11}
    })
    
    return frame
end

-- Create a simple button
function UI:CreateButton(name, parent, width, height, text)
    local button = CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
    button:SetSize(width or 100, height or 22)
    button:SetText(text or "Button")
    
    return button
end

-- Create a checkbox
function UI:CreateCheckbox(name, parent, text, tooltip)
    local checkbox = CreateFrame("CheckButton", name, parent, "UICheckButtonTemplate")
    checkbox.Text:SetText(text or "")
    
    if tooltip then
        checkbox.tooltipText = tooltip
        checkbox:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        checkbox:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end
    
    return checkbox
end

-- Create a slider
function UI:CreateSlider(name, parent, width, min, max, step)
    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    slider:SetWidth(width or 200)
    slider:SetMinMaxValues(min or 0, max or 100)
    slider:SetValueStep(step or 1)
    slider:SetObeyStepOnDrag(true)
    
    return slider
end

-- Create an editbox
function UI:CreateEditBox(name, parent, width, height, multiLine)
    local editBox
    
    if multiLine then
        editBox = CreateFrame("ScrollFrame", name, parent, "InputScrollFrameTemplate")
    else
        editBox = CreateFrame("EditBox", name, parent, "InputBoxTemplate")
    end
    
    editBox:SetSize(width or 200, height or 22)
    
    return editBox
end

-- Create a dropdown menu
function UI:CreateDropdown(name, parent, width)
    local dropdown = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
    UIDropDownMenu_SetWidth(dropdown, width or 150)
    
    return dropdown
end

-- Create a text label
function UI:CreateLabel(name, parent, text, fontSize, justifyH)
    local label = parent:CreateFontString(name, "OVERLAY", "GameFontNormal")
    label:SetText(text or "")
    label:SetJustifyH(justifyH or "LEFT")
    
    if fontSize then
        local font, _, flags = label:GetFont()
        label:SetFont(font, fontSize, flags)
    end
    
    return label
end

-- Apply a color to a fontstring
function UI:SetTextColor(fontString, colorType)
    local color = self.COLORS[colorType] or self.COLORS.TEXT
    fontString:SetTextColor(color.r, color.g, color.b)
end

-- Format a time string (e.g., "2 hours ago")
function UI:FormatTimeAgo(seconds)
    if not seconds or seconds <= 0 then
        return "just now"
    elseif seconds < 60 then
        return string.format("%d %s %s", seconds, seconds == 1 and "second" or "seconds", L["ago"])
    elseif seconds < 3600 then
        local minutes = math.floor(seconds / 60)
        return string.format("%d %s %s", minutes, minutes == 1 and "minute" or "minutes", L["ago"])
    else
        local hours = math.floor(seconds / 3600)
        return string.format("%d %s %s", hours, hours == 1 and "hour" or "hours", L["ago"])
    end
end