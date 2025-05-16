local Module = VUI:NewModule("Skins.Item");

function Module:OnEnable()
    if (VUI:Color()) then
        VUI:Skin(ItemTextFrame, true)
        VUI:Skin(ItemTextFrame.NineSlice, true)
    end
end
