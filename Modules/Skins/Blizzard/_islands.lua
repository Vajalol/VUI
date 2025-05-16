local Module = VUI:NewModule("Skins.Islands");

function Module:OnEnable()
    if (VUI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_IslandsQueueUI" then
                VUI:Skin(IslandsQueueFrame, true)
                VUI:Skin(IslandsQueueFrame.NineSlice, true)
                VUI:Skin(IslandsQueueFrame.ArtOverlayFrame, true)
            end
        end)
    end
end
