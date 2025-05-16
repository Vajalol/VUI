local addonName, VUI = ...
if not VUI then return end

-- Only create the module if NewModule is available
if not VUI.NewModule then
    -- Register a callback to try again when VUI is fully initialized
    C_Timer.After(0.5, function()
        if VUI and VUI.NewModule then
            local Module = VUI:NewModule("NamePlates.ArenaNumbers")
            -- Re-run the OnEnable function
            if Module and Module.OnEnable then
                Module:OnEnable()
            end
        end
    end)
    return
end

local Module = VUI:NewModule("NamePlates.ArenaNumbers");

function Module:OnEnable()
    -- Check for external nameplate addons OR VUIPlater being enabled
    if C_AddOns.IsAddOnLoaded('Plater') or 
       C_AddOns.IsAddOnLoaded('TidyPlates_ThreatPlates') or 
       C_AddOns.IsAddOnLoaded('TidyPlates') or 
       C_AddOns.IsAddOnLoaded('Kui_Nameplates') or
       (VUI.VUIPlater and VUI.VUIPlater.db and VUI.VUIPlater.db.profile and 
       VUI.VUIPlater.db.profile.enabled) then 
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
