local Module = VUI:NewModule("Skins.Alliedraces");

function Module:OnEnable()
    if (VUI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_AlliedRacesUI" then
                VUI:Skin(AlliedRacesFrame, true)
                VUI:Skin(AlliedRacesFrame.NineSlice, true)
                VUI:Skin(AlliedRacesFrameInset.NineSlice, true)
            end
        end)
    end
end
