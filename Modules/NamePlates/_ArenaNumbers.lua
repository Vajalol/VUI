local Module = VUI:NewModule("NamePlates.ArenaNumbers");

function Module:OnEnable()
    -- Check for external nameplate addons OR VUIPlater being enabled
    if C_AddOns.IsAddOnLoaded('Plater') or 
       C_AddOns.IsAddOnLoaded('TidyPlates_ThreatPlates') or 
       C_AddOns.IsAddOnLoaded('TidyPlates') or 
       C_AddOns.IsAddOnLoaded('Kui_Nameplates') or
       (VUI:GetModule("VUIPlater") and VUI:GetModule("VUIPlater").db and 
       VUI:GetModule("VUIPlater").db.profile.enabled) then 
        return 
    end
    local db = VUI.db.profile.nameplates.arenanumber
    if (db) then
        local frame = CreateFrame("Frame")
        frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        frame:HookScript("OnEvent", function()
            local U = UnitIsUnit
            hooksecurefunc(
                "CompactUnitFrame_UpdateName",
                function(F)
                    if IsActiveBattlefieldArena() and F.unit:find("nameplate") then
                        for i = 1, 5 do
                            if U(F.unit, "arena" .. i) then
                                F.name:SetText(i)
                                F.name:SetTextColor(1, 1, 0)
                                break
                            end
                        end
                    end
                end)
        end)
    end
end
