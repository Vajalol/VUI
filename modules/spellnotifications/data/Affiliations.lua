local _, VUI = ...
local SN = VUI.SpellNotifications

function SN:Affiliations()
    return {
        ["MINE"] = COMBATLOG_OBJECT_AFFILIATION_MINE,
        ["FRIENDLY"] = COMBATLOG_OBJECT_REACTION_FRIENDLY,
        ["PET"] = COMBATLOG_OBJECT_TYPE_PET
    }
end