local Module = VUI:NewModule("Skins.ClassTrainer");

function Module:OnEnable()
    if (VUI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_TrainerUI" then
                VUI:Skin(ClassTrainerFrame, true)
                VUI:Skin(ClassTrainerFrame.NineSlice, true)
                VUI:Skin(ClassTrainerFrameBottomInset.NineSlice, true)
                VUI:Skin(ClassTrainerFrameInset.NineSlice, true)
            end
        end)
    end
end
