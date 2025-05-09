local Module = VUI:NewModule("General.Delete");

function Module:OnEnable()
    local db = VUI.db.profile.general.automation.delete
    if (db) then
        hooksecurefunc(StaticPopupDialogs["DELETE_GOOD_ITEM"], "OnShow", function(s)
            s.editBox:SetText(DELETE_ITEM_CONFIRM_STRING)
        end)
    end
end
