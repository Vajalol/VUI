local Module = VUI:NewModule("Skins.RaidFrame");

function Module:OnEnable()
    if (VUI:Color()) then
        VUI:Skin(CompactRaidFrameManager, true)
    end
end
