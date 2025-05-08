local Module = VUI:NewModule("Skins.AddonList");

function Module:OnEnable()
    if (VUI:Color()) then
        VUI:Skin(AddonList.NineSlice, true)
        VUI:Skin(AddonList, true)
        VUI:Skin({ AddonListBg }, true, true)
    end
end
