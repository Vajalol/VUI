local addonName, VUI = ...

-- Ensure namespace exists
VUI.Notifications = VUI.Notifications or {}

-- Define miss types for combat log filtering
-- Module reference
-- Instead of trying to get the module with GetModule, we'll work directly with the namespace
-- local M = VUI:GetModule("VUINotifications") -- This line was causing the error

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