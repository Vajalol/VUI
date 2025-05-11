local addonName, VUI = ...

-- Define sizes for notifications
-- Module reference
local M = VUI:GetModule("VUINotifications")

-- Ensure backward compatibility
VUI.Notifications = VUI.Notifications or {}

function VUI.Notifications.Sizes()
    return {
        ["SMALL"] = "small",
        ["LARGE"] = "large",
        ["BIG"] = "big"
    }
end