local Module = VUI:NewModule("Skins.Azerit");

function Module:OnEnable()
    if (VUI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_AzeriteUI" then
                VUI:Skin(AzeriteEmpoweredItemUI.BorderFrame, true)
                VUI:Skin(AzeriteEmpoweredItemUI.BorderFrame.NineSlice, true)
            end

            if name == "Blizzard_AzeriteRespecUI" then
                VUI:Skin(AzeriteRespecFrame, true)
                VUI:Skin(AzeriteRespecFrame.NineSlice, true)
            end

            if name == "Blizzard_AzeriteEssenceUI" then
                VUI:Skin(AzeriteEssenceUI, true)
                VUI:Skin(AzeriteEssenceUI.NineSlice, true)
                VUI:Skin(AzeriteEssenceUI.LeftInset.NineSlice, true)
                VUI:Skin(AzeriteEssenceUI.RightInset.NineSlice, true)
                VUI:Skin(AzeriteEssenceUI.EssenceList.ScrollBar, true)
            end
        end)
    end
end
