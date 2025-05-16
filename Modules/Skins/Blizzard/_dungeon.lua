local Module = VUI:NewModule("Skins.Dungeon");

function Module:OnEnable()
    if (VUI:Color()) then
        VUI:Skin(GameMenuFrame, true)
        VUI:Skin(GameMenuFrame.Border, true)
        VUI:Skin(StaticPopup1, true)
        VUI:Skin(StaticPopup1.Border, true)
        VUI:Skin(StaticPopup2, true)
        VUI:Skin(StaticPopup2.Border, true)
        VUI:Skin(StaticPopup3, true)
        VUI:Skin(StaticPopup3.Border, true)
    end
end
