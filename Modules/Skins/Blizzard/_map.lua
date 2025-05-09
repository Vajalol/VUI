local Module = VUI:NewModule("Skins.Map");

function Module:OnEnable()
    if (VUI:Color()) then
        VUI:Skin(WorldMapFrame, true)
        VUI:Skin(WorldMapFrame.BorderFrame, true)
        VUI:Skin(WorldMapFrame.BorderFrame.NineSlice, true)
        VUI:Skin(WorldMapFrame.NavBar, true)
        VUI:Skin(WorldMapFrame.NavBar.overlay, true)
    end
end
