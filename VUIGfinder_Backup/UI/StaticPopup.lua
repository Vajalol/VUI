-------------------------------------------------------------------------------
-- VUI Gfinder (based on Premade Groups Filter)
-- Module for VUI - Vortex UI Addon Suite
-------------------------------------------------------------------------------

local VUI = _G.VUI
local Module = VUI:GetModule("VUIGfinder")
if not Module then return end

local VUIGfinder = _G.VUIGfinder
local L = VUIGfinder.L

-- Create a template for static popup dialogs that the module will use
StaticPopupDialogs["VUIGFINDER_CONFIRM_ACTION"] = {
    text = "%s",
    button1 = ACCEPT,
    button2 = CANCEL,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["VUIGFINDER_MESSAGE"] = {
    text = "%s",
    button1 = OKAY,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["VUIGFINDER_CONFIRM_RESET"] = {
    text = L["Are you sure you want to reset all VUI Gfinder settings to defaults?"],
    button1 = ACCEPT,
    button2 = CANCEL,
    OnAccept = function()
        if VUIGfinder.Settings then
            VUIGfinder.Settings:Reset()
            VUIGfinder:Print(L["All settings have been reset to defaults."])
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["VUIGFINDER_CONFIRM_RESET_CATEGORY"] = {
    text = L["Are you sure you want to reset %s settings to defaults?"],
    button1 = ACCEPT,
    button2 = CANCEL,
    OnAccept = function(self, data)
        if VUIGfinder.Settings and data then
            VUIGfinder.Settings:Reset(data)
            VUIGfinder:Print(string.format(L["%s settings have been reset to defaults."], data))
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}