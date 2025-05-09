local Module = VUI:NewModule("Skins.Guild");

function Module:OnEnable()
    if (VUI:Color()) then
        VUI:Skin(GuildRegistrarFrame, true)
        VUI:Skin(GuildRegistrarFrame.NineSlice, true)
        VUI:Skin(TabardFrame, true)
        VUI:Skin(TabardFrame.NineSlice, true)

        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_GuildBankUI" then
                VUI:Skin(GuildBankFrameTab1, true)
                VUI:Skin(GuildBankFrameTab2, true)
                VUI:Skin(GuildBankFrameTab3, true)
                VUI:Skin(GuildBankFrameTab4, true)
                VUI:Skin(GuildBankFrame, true)
                VUI:Skin({
                    GuildBankFrameLeft,
                    GuildBankFrameMiddle,
                    GuildBankFrameRight
                }, true, true)
                VUI:Skin(GuildBankFrame.MoneyFrameBG, true)
                VUI:Skin(GuildBankFrame.Column1, true)
                VUI:Skin(GuildBankFrame.Column2, true)
                VUI:Skin(GuildBankFrame.Column3, true)
                VUI:Skin(GuildBankFrame.Column4, true)
                VUI:Skin(GuildBankFrame.Column5, true)
                VUI:Skin(GuildBankFrame.Column6, true)
                VUI:Skin(GuildBankFrame.Column7, true)
            end
        end)
    end
end
