local Module = VUI:NewModule("Skins.Petition");

function Module:OnEnable()
    if (VUI:Color()) then
        VUI:Skin(PetitionFrame, true)
        VUI:Skin(PetitionFrame.NineSlice, true)
        VUI:Skin(PetitionFrameInset, true)
    end
end
