local Module = VUI:NewModule("Skins.FlightMap");

function Module:OnEnable()
    if (VUI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_FlightMap" then
                VUI:Skin(FlightMapFrame, true)
                VUI:Skin(FlightMapFrame.BorderFrame, true)
                VUI:Skin(FlightMapFrame.BorderFrame.NineSlice, true)
            end
        end)
    end
end
