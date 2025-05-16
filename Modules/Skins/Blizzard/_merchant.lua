local Module = VUI:NewModule("Skins.Merchant");

function Module:OnEnable()
    if (VUI:Color()) then
        VUI:Skin(MerchantFrame, true)
        VUI:Skin(MerchantFrame.NineSlice, true)
        VUI:Skin(MerchantFrameInset, true)
        VUI:Skin(MerchantFrameInset.NineSlice, true)
        VUI:Skin(StackSplitFrame, true)
        VUI:Skin(MerchantMoneyBg, true)
        VUI:Skin(MerchantMoneyInset, true)
        VUI:Skin(MerchantMoneyInset.NineSlice, true)
        VUI:Skin({
            MerchantBuyBackItemSlotTexture,
        }, true, true)

        -- Merchant Buttons
        select(1, select(1, MerchantRepairItemButton:GetRegions())):SetVertexColor(.15, .15, .15)
        select(1, select(1, MerchantRepairAllButton:GetRegions())):SetVertexColor(.15, .15, .15)
        select(1, select(1, MerchantGuildBankRepairButton:GetRegions())):SetVertexColor(.15, .15, .15)
        select(1, select(1, MerchantSellAllJunkButton:GetRegions())):SetVertexColor(.15, .15, .15)

        -- Tabs
        VUI:Skin(MerchantFrameTab1, true)
        VUI:Skin(MerchantFrameTab2, true)
    end
end
