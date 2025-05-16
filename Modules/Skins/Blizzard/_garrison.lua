local Module = VUI:NewModule("Skins.Garrison");

function Module:OnEnable()
    if (VUI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_GarrisonUI" then
                VUI:Skin(GarrisonCapacitiveDisplayFrame, true)
                VUI:Skin(GarrisonCapacitiveDisplayFrame.NineSlice, true)
                VUI:Skin(GarrisonCapacitiveDisplayFrameInset, true)
                VUI:Skin(GarrisonCapacitiveDisplayFrameInset.NineSlice, true)
            end
        end)
    end
end
