local Module = VUI:NewModule("Skins.Loot");

function Module:OnEnable()
    if (VUI:Color()) then
        VUI:Skin(LootFrame, true)
        VUI:Skin(LootFrame.NineSlice, true)
    end
end
