local Module = VUI:NewModule("Skins.Inspect");

function Module:OnEnable()
    if (VUI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_InspectUI" then
                VUI:Skin(InspectFrame, true)
                VUI:Skin(InspectFrame.NineSlice, true)
                VUI:Skin(InspectFrameInset, true)
                VUI:Skin(InspectFrameInset.NineSlice, true)
                VUI:Skin(InspectPaperDollItemsFrame, true)
                VUI:Skin(InspectPaperDollItemsFrame.InspectTalents, true)
                VUI:Skin(InspectPVPFrame, true)
                VUI:Skin({
                    InspectModelFrameBorderLeft,
                    InspectModelFrameBorderRight,
                    InspectModelFrameBorderTop,
                    InspectModelFrameBorderTopLeft,
                    InspectModelFrameBorderTopRight,
                    InspectModelFrameBorderBottom,
                    InspectModelFrameBorderBottomLeft,
                    InspectModelFrameBorderBottomRight,
                    InspectModelFrameBorderBottom2,
                    InspectFeetSlotFrame,
                    InspectHandsSlotFrame,
                    InspectWaistSlotFrame,
                    InspectLegsSlotFrame,
                    InspectFinger0SlotFrame,
                    InspectFinger1SlotFrame,
                    InspectTrinket0SlotFrame,
                    InspectTrinket1SlotFrame,
                    InspectWristSlotFrame,
                    InspectTabardSlotFrame,
                    InspectShirtSlotFrame,
                    InspectChestSlotFrame,
                    InspectBackSlotFrame,
                    InspectShoulderSlotFrame,
                    InspectNeckSlotFrame,
                    InspectHeadSlotFrame,
                    InspectSecondaryHandSlotFrame,
                }, true, true)

                -- Tabs
                VUI:Skin(InspectFrameTab1, true)
                VUI:Skin(InspectFrameTab2, true)
                VUI:Skin(InspectFrameTab3, true)

                -- Hide
                InspectMainHandSlotFrame:Hide()
                _G.select(InspectMainHandSlot:GetNumRegions(), InspectMainHandSlot:GetRegions()):Hide()
                _G.select(InspectSecondaryHandSlot:GetNumRegions(), InspectSecondaryHandSlot:GetRegions()):Hide()
            end

            if name == "Blizzard_Professions" then
                VUI:Skin(InspectRecipeFrame, true)
                VUI:Skin(InspectRecipeFrame.NineSlice, true)
            end
        end)
    end
end
