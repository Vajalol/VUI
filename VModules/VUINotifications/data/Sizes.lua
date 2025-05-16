local addonName, VUI = ...

-- Ensure VUI global exists to prevent nil errors
if not VUI then VUI = {} end

-- Ensure namespace exists
VUI.Notifications = VUI.Notifications or {}

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

-- Create a global accessor for compatibility with older code
_G.VUINotificationSizes = VUI.Notifications.Sizes