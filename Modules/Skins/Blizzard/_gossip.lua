local Module = VUI:NewModule("Skins.Gossip");

function Module:OnEnable()
    if (VUI:Color()) then
        VUI:Skin(GossipFrame, true)
        VUI:Skin(GossipFrame.NineSlice, true)
        VUI:Skin(GossipFrameInset, true)
        VUI:Skin(GossipFrameInset.NineSlice, true)
    end
end
