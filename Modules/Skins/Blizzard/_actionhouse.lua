local Module = VUI:NewModule("Skins.ActionHouse");

function Module:OnEnable()
    if (VUI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            -- Crafting Orders
            if name == "Blizzard_ProfessionsCustomerOrders" then
                VUI:Skin(ProfessionsCustomerOrdersFrame, true)
                VUI:Skin(ProfessionsCustomerOrdersFrame.NineSlice, true)
                VUI:Skin(ProfessionsCustomerOrdersFrame.BrowseOrders.CategoryList.NineSlice, true)
                VUI:Skin(ProfessionsCustomerOrdersFrame.MoneyFrameBorder, true)
                VUI:Skin(ProfessionsCustomerOrdersFrame.MoneyFrameInset.NineSlice, true)

                -- Tabs
                VUI:Skin(ProfessionsCustomerOrdersFrameBrowseTab, true)
                VUI:Skin(ProfessionsCustomerOrdersFrameOrdersTab, true)
            end

            -- Auction House
            if name == "Blizzard_AuctionHouseUI" then
                VUI:Skin(AuctionHouseFrame, true)
                VUI:Skin(AuctionHouseFrame.NineSlice, true)
                VUI:Skin(AuctionHouseFrame.NineSlice, true)
                VUI:Skin(AuctionHouseFrame.WoWTokenResults.GameTimeTutorial.NineSlice, true)
                VUI:Skin(AuctionHouseFrame.BuyDialog, true)
                VUI:Skin(AuctionHouseFrame.BuyDialog.Border, true)
                VUI:Skin(AuctionHouseFrame.MoneyFrameBorder, true)
                VUI:Skin(AuctionHouseFrame.MoneyFrameInset.NineSlice, true)
                VUI:Skin(AuctionHouseFrame.CategoriesList, true)

                -- Tabs
                VUI:Skin(AuctionHouseFrameBuyTab, true)
                VUI:Skin(AuctionHouseFrameSellTab, true)
                VUI:Skin(AuctionHouseFrameAuctionsTab, true)
                VUI:Skin(AuctionHouseFrameAuctionsFrameAuctionsTab, true)
                VUI:Skin(AuctionHouseFrameAuctionsFrameBidsTab, true)
            end
        end)
    end
end
