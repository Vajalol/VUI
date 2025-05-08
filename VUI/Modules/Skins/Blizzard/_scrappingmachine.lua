local Module = VUI:NewModule("Skins.ScrappingMachine");

function Module:OnEnable()
    if (VUI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_ScrappingMachineUI" then
                VUI:Skin(ScrappingMachineFrame, true)
                VUI:Skin(ScrappingMachineFrame.NineSlice, true)
            end
        end)
    end
end
