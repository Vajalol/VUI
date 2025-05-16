local Module = VUI:NewModule("Skins.Dressup")

function Module:OnEnable()
    if (VUI:Color()) then
        VUI:Skin(DressUpFrame, true)
        VUI:Skin(DressUpFrame.NineSlice, true)
        VUI:Skin(DressUpFrame.OutfitDetailsPanel, true)
        VUI:Skin(DressUpFrameInset, true)
        VUI:Skin(DressUpFrameInset.NineSlice, true)
    end
end
