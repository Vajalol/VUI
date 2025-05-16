local Module = VUI:NewModule("Skins.Bank");

function Module:OnEnable()
    if (VUI:Color()) then
        VUI:Skin(BankFrame, true)
        VUI:Skin(BankFrame.NineSlice, true)
        VUI:Skin(BankSlotsFrame.NineSlice, true)
        VUI:Skin(BankFrameMoneyFrameBorder, true)
        VUI:Skin(AccountBankPanel.NineSlice, true)
        VUI:Skin(AccountBankPanel.MoneyFrame.Border, true)

        ReagentBankFrame:HookScript("OnShow", function()
            VUI:Skin(ReagentBankFrame, true)
            VUI:Skin(ReagentBankFrame.NineSlice, true)
        end)

        -- Tabs
        VUI:Skin(BankFrameTab1, true)
        VUI:Skin(BankFrameTab2, true)
        VUI:Skin(BankFrameTab3, true)
    end
end
