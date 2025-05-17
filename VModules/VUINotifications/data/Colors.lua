local addonName, VUI = ...

-- Ensure VUI global exists to prevent nil errors
if not VUI then VUI = {} end

-- Ensure namespace exists
VUI.Notifications = VUI.Notifications or {}

-- Define colors used for notifications
-- Module reference
-- Instead of trying to get the module with GetModule, we'll work directly with the namespace
-- local M = VUI:GetModule("VUINotifications") -- This line was causing the error

-- Ensure backward compatibility
VUI.Notifications = VUI.Notifications or {}

function VUI.Notifications.Colors()
    return {
        ["BLUE"] = {
            ["R"] = 0,
            ["G"] = .75,
            ["B"] = 1
        },
        ["GREEN"] = {
            ["R"] = .5,
            ["G"] = 1,
            ["B"] = 0
        },
        ["YELLOW"] = {
            ["R"] = 1,
            ["G"] = 1,
            ["B"] = 0
        },
        ["ORANGE"] = {
            ["R"] = 1,
            ["G"] = .65,
            ["B"] = 0
        },
        ["RED"] = {
            ["R"] = 1,
            ["G"] = 0,
            ["B"] = 0
        },
        ["PURPLE"] = {
            ["R"] = .93,
            ["G"] = .51,
            ["B"] = .93
        },
        ["BLACK"] = {
            ["R"] = 0,
            ["G"] = 0,
            ["B"] = 0
        },
        ["WHITE"] = {
            ["R"] = 1,
            ["G"] = 1,
            ["B"] = 1
        }
    }
end

-- Create a global accessor for compatibility with older code
_G.VUINotificationColors = VUI.Notifications.Colors