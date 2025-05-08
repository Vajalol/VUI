local Module = VUI:NewModule("Skins.Mail");

function Module:OnEnable()
    if (VUI:Color()) then
        VUI:Skin(MailFrame, true)
        VUI:Skin(MailFrame.NineSlice, true)
        VUI:Skin(OpenMailFrame, true)
        VUI:Skin(OpenMailFrame.NineSlice, true)
        VUI:Skin(MailFrameInset, true)
        VUI:Skin(MailFrameInset.NineSlice, true)
        VUI:Skin(OpenMailFrameInset, true)
        VUI:Skin(OpenMailFrameInset.NineSlice, true)
        VUI:Skin(SendMailMoneyInset, true)
        VUI:Skin(SendMailMoneyInset.NineSlice, true)
        VUI:Skin(SendMailMoneyBg, true)
        VUI:Skin(SendMailFrame, true)

        -- Tabs
        VUI:Skin(MailFrameTab1, true)
        VUI:Skin(MailFrameTab2, true)
    end
end
