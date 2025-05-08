local Module = VUI:NewModule("Skins.Collections");

function Module:OnEnable()
    if (VUI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_Collections" then
                -- Collections Frame
                VUI:Skin(CollectionsJournal, true)
                VUI:Skin(CollectionsJournal.NineSlice, true)

                -- Mount Journal
                VUI:Skin(MountJournal, true)
                VUI:Skin(MountJournal.MountDisplay, true)
                VUI:Skin(MountJournal.LeftInset.NineSlice, true)
                VUI:Skin(MountJournal.BottomLeftInset, true)
                VUI:Skin(MountJournal.BottomLeftInset.NineSlice, true)
                VUI:Skin(MountJournal.RightInset.NineSlice, true)
                VUI:Skin(MountJournal.BottomLeftInset.SlotButton, true)
                select(2, MountJournal.BottomLeftInset.SlotButton:GetRegions()):SetVertexColor(1, 1, 1)

                -- ToyBox
                VUI:Skin(ToyBox, true)
                VUI:Skin(ToyBox.iconsFrame, true)
                VUI:Skin(ToyBox.iconsFrame.NineSlice, true)

                -- Heirlooms Journal
                VUI:Skin(HeirloomsJournal, true)
                VUI:Skin(HeirloomsJournal.iconsFrame, true)
                VUI:Skin(HeirloomsJournal.iconsFrame.NineSlice, true)

                -- Pet Journal
                VUI:Skin(PetJournalLeftInset, true)
                VUI:Skin(PetJournalLeftInset.NineSlice, true)
                VUI:Skin(PetJournalPetCardInset, true)
                VUI:Skin(PetJournalPetCardInset.NineSlice, true)
                VUI:Skin(PetJournalPetCard, true)
                VUI:Skin(PetJournalLoadoutPet1, true)
                VUI:Skin(PetJournalLoadoutPet2, true)
                VUI:Skin(PetJournalLoadoutPet3, true)
                VUI:Skin(PetJournalLoadoutBorder, true)
                VUI:Skin(PetJournalRightInset.NineSlice, true)

                -- Wardrobe
                VUI:Skin(WardrobeCollectionFrame.ItemsCollectionFrame, true)

                -- Specific Frames
                VUI:Skin({
                    CollectionsJournalBg,
                    MountJournalListScrollFrameScrollBarThumbTexture,
                    MountJournalListScrollFrameScrollBarTop,
                    MountJournalListScrollFrameScrollBarMiddle,
                    MountJournalListScrollFrameScrollBarBottom,
                    PetJournalListScrollFrameScrollBarThumbTexture,
                    PetJournalListScrollFrameScrollBarTop,
                    PetJournalListScrollFrameScrollBarMiddle,
                    PetJournalListScrollFrameScrollBarBottom
                }, true, true)

                -- Tabs
                VUI:Skin(CollectionsJournalTab1, true)
                VUI:Skin(CollectionsJournalTab2, true)
                VUI:Skin(CollectionsJournalTab3, true)
                VUI:Skin(CollectionsJournalTab4, true)
                VUI:Skin(CollectionsJournalTab5, true)
                VUI:Skin(WardrobeCollectionFrameTab1, true)
                VUI:Skin(WardrobeCollectionFrameTab2, true)
            end
        end)
    end
end
