local Hide = VUI:NewModule("ActionBars.Hide");

function Hide:OnEnable()
    local db = VUI.db.profile.misc

    if db.repbar then
        StatusTrackingBarManager:HookScript("OnEvent", function()
            StatusTrackingBarManager:Hide()
        end)
    end
end
