local Module = VUI:NewModule("Skins.Trade");

function Module:OnEnable()
    if (VUI:Color()) then
        VUI:Skin(TradeFrame, true)
        VUI:Skin(TradeFrame.NineSlice, true)
        VUI:Skin(TradeFrame.RecipientOverlay, true)
        VUI:Skin(TradeFrameInset.NineSlice, true)
        VUI:Skin(TradePlayerEnchantInset, true)
        VUI:Skin(TradePlayerEnchantInset.NineSlice, true)
        VUI:Skin(TradePlayerItemsInset.NineSlice, true)
        VUI:Skin(TradeRecipientItemsInset.NineSlice, true)
        VUI:Skin(TradeRecipientMoneyBg, true)
        VUI:Skin(TradeRecipientMoneyInset.NineSlice, true)
        VUI:Skin(TradeRecipientEnchantInset, true)
        VUI:Skin(TradeRecipientEnchantInset.NineSlice, true)
    end
end
