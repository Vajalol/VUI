local addonName, VUI = ...

-- Ensure namespace exists
VUI.Notifications = VUI.Notifications or {}

-- Define miss types for combat log filtering
-- Module reference
local M = VUI:GetModule("VUINotifications")

-- Ensure backward compatibility
VUI.Notifications = VUI.Notifications or {}

function VUI.Notifications.MissTypes()
    return {
        ["REFLECT"] = "reflected",
        ["IMMUNE"] = "immune",
        ["EVADE"] = "evaded",
        ["PARRY"] = "parried",
        ["DODGE"] = "dodged",
        ["BLOCK"] = "blocked",
        ["DEFLECT"] = "deflected",
        ["RESIST"] = "resisted"
    }
end