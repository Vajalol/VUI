local _, VUI = ...
local SN = VUI.SpellNotifications

function SN:MissTypes()
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