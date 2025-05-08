local Module = VUI:NewModule("Skins.Character");

function Module:OnEnable()
    if (VUI:Color()) then
        VUI:Skin(CharacterFrame, true)
        VUI:Skin(CharacterFrame.NineSlice, true)
        VUI:Skin(CharacterFrameInset, true)
        VUI:Skin(CharacterFrameInset.NineSlice, true)
        VUI:Skin(CharacterFrameInsetRight, true)
        VUI:Skin(CharacterFrameInsetRight.NineSlice, true)
        VUI:Skin(TokenFramePopup, true)
        VUI:Skin(TokenFramePopup.Border, true)
        VUI:Skin(CharacterStatsPane, true)
        VUI:Skin(ReputationFrame.ReputationDetailFrame, true)
        VUI:Skin(ReputationFrame.ReputationDetailFrame.Border, true)
        VUI:Skin(CurrencyTransferLog, true)
        VUI:Skin(CurrencyTransferLog.TitleContainer, true)
        VUI:Skin(CurrencyTransferLog.NineSlice, true)
        VUI:Skin(CurrencyTransferLogInset.NineSlice, true)
        VUI:Skin({
            CharacterFeetSlotFrame,
            CharacterHandsSlotFrame,
            CharacterWaistSlotFrame,
            CharacterLegsSlotFrame,
            CharacterFinger0SlotFrame,
            CharacterFinger1SlotFrame,
            CharacterTrinket0SlotFrame,
            CharacterTrinket1SlotFrame,
            CharacterWristSlotFrame,
            CharacterTabardSlotFrame,
            CharacterShirtSlotFrame,
            CharacterChestSlotFrame,
            CharacterBackSlotFrame,
            CharacterShoulderSlotFrame,
            CharacterNeckSlotFrame,
            CharacterHeadSlotFrame,
            CharacterMainHandSlotFrame,
            CharacterSecondaryHandSlotFrame,
            _G.select(CharacterMainHandSlot:GetNumRegions(), CharacterMainHandSlot:GetRegions()),
            _G.select(CharacterSecondaryHandSlot:GetNumRegions(), CharacterSecondaryHandSlot:GetRegions()),
            PaperDollInnerBorderLeft,
            PaperDollInnerBorderRight,
            PaperDollInnerBorderTop,
            PaperDollInnerBorderTopLeft,
            PaperDollInnerBorderTopRight,
            PaperDollInnerBorderBottom,
            PaperDollInnerBorderBottomLeft,
            PaperDollInnerBorderBottomRight,
            PaperDollInnerBorderBottom2
        }, true, true)

        -- Tabs
        VUI:Skin(CharacterFrameTab1, true)
        VUI:Skin(CharacterFrameTab2, true)
        VUI:Skin(CharacterFrameTab3, true)

        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_ItemSocketingUI" then
                VUI:Skin(ItemSocketingFrame, true)
                VUI:Skin(ItemSocketingFrame.NineSlice, true)
            end
        end)
    end
end
