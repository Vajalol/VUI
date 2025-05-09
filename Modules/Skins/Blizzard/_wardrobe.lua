local Module = VUI:NewModule("Skins.Wardrobe");

function Module:OnEnable()
    if (VUI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_Collections" or name == "Blizzard_Wardrobe" then
                VUI:Skin(WardrobeFrame, true)
                VUI:Skin(WardrobeFrame.NineSlice, true)
                VUI:Skin(WardrobeCollectionFrame, true)
                VUI:Skin(WardrobeCollectionFrame.ItemsCollectionFrame, true)
                VUI:Skin(WardrobeCollectionFrame.ItemsCollectionFrame.NineSlice, true)
                VUI:Skin(WardrobeCollectionFrame.SetsCollectionFrame, true)
                VUI:Skin(WardrobeCollectionFrame.SetsCollectionFrame.LeftInset, true)
                VUI:Skin(WardrobeCollectionFrame.SetsCollectionFrame.LeftInset.NineSlice, true)
                VUI:Skin(WardrobeCollectionFrame.SetsCollectionFrame.RightInset, true)
                VUI:Skin(WardrobeCollectionFrame.SetsCollectionFrame.RightInset.NineSlice, true)
                VUI:Skin({
                    WardrobeCollectionFrameScrollFrameScrollBarBottom,
                    WardrobeCollectionFrameScrollFrameScrollBarMiddle,
                    WardrobeCollectionFrameScrollFrameScrollBarTop,
                    WardrobeCollectionFrameScrollFrameScrollBarThumbTexture
                }, true, true)
            end
        end)
    end
end
