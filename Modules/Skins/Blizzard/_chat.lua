local Module = VUI:NewModule("Skins.Chat");

function Module:OnEnable()
    if (VUI:Color()) then
        VUI:Skin(ChatFrame1EditBox, true)
        VUI:Skin(ChatFrame2EditBox, true)
        VUI:Skin(ChatFrame3EditBox, true)
        VUI:Skin(ChatFrame4EditBox, true)
        VUI:Skin(ChatFrame5EditBox, true)
        VUI:Skin(ChatFrame6EditBox, true)
        VUI:Skin(ChatFrame7EditBox, true)
        VUI:Skin(ChannelFrame, true)
        VUI:Skin(ChannelFrame.NineSlice, true)
        VUI:Skin(ChannelFrame.LeftInset.NineSlice, true)
        VUI:Skin(ChannelFrame.RightInset.NineSlice, true)
        VUI:Skin(ChannelFrameInset.NineSlice, true)
        VUI:Skin(ChatConfigFrame, true)
        VUI:Skin(ChatConfigFrame.Header, true)
        VUI:Skin(ChatConfigFrame.Border, true)
        VUI:Skin(ChatConfigBackgroundFrame, true)
        VUI:Skin(ChatConfigBackgroundFrame.NineSlice, true)
        VUI:Skin(ChatConfigCategoryFrame, true)
        VUI:Skin(ChatConfigCategoryFrame.NineSlice, true)
    end
end
