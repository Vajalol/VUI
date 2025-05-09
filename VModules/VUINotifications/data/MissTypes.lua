local addonName, VUI = ...

-- Define miss types for combat log filtering
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