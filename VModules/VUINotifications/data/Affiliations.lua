local addonName, VUI = ...

-- Ensure namespace exists
VUI.Notifications = VUI.Notifications or {}

-- Define affiliations for combat log filtering
-- Module reference
-- Instead of trying to get the module with GetModule, we'll work directly with the namespace
-- local M = VUI:GetModule("VUINotifications") -- This line was causing the error

-- Ensure backward compatibility
VUI.Notifications = VUI.Notifications or {}

function VUI.Notifications.Affiliations()
    return {
        ["MINE"] = COMBATLOG_OBJECT_AFFILIATION_MINE,
        ["FRIENDLY"] = COMBATLOG_OBJECT_REACTION_FRIENDLY,
        ["PET"] = COMBATLOG_OBJECT_TYPE_PET
    }
end