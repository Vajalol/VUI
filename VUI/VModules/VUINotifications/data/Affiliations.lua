local addonName, VUI = ...

-- Define affiliations for combat log filtering
function VUI.Notifications.Affiliations()
    return {
        ["MINE"] = COMBATLOG_OBJECT_AFFILIATION_MINE,
        ["FRIENDLY"] = COMBATLOG_OBJECT_REACTION_FRIENDLY,
        ["PET"] = COMBATLOG_OBJECT_TYPE_PET
    }
end