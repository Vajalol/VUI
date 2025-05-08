local Module = VUI:NewModule("Skins.PvPUI");

function Module:OnEnable()
    if (VUI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_PVPUI" then
                VUI:Skin(HonorFrame, true)
                VUI:Skin(HonorFrame.ConquestFrame, true)
                VUI:Skin(HonorFrame.Inset, true)
                VUI:Skin(HonorFrame.Inset.NineSlice, true)
                VUI:Skin(HonorFrame.BonusFrame, true)
                VUI:Skin(ConquestFrame, true)
                VUI:Skin(ConquestFrame.ConquestBar, true)
                VUI:Skin(ConquestFrame.Inset, true)
                VUI:Skin(ConquestFrame.Inset.NineSlice, true)
                VUI:Skin(PVPQueueFrame, true)
                VUI:Skin(PVPQueueFrame.HonorInset, true)
                VUI:Skin(PVPQueueFrame.HonorInset.NineSlice, true)
                PVPQueueFrame.HonorInset:Hide();
            end
        end)
    end
end
