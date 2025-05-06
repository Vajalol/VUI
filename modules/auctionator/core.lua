-- Auctionator Core Implementation
-- This file contains the core logic for the Auctionator module
local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end
local Auctionator = VUI.modules.auctionator

-- Utility Functions

-- Convert copper amount to a formatted gold/silver/copper string
function Auctionator:FormatMoney(copper)
    if not copper then return "0g 0s 0c" end
    
    local gold = math.floor(copper / 10000)
    local silver = math.floor((copper % 10000) / 100)
    local bronze = copper % 100
    
    if gold > 0 then
        return string.format("%dg %ds %dc", gold, silver, bronze)
    elseif silver > 0 then
        return string.format("%ds %dc", silver, bronze)
    else
        return string.format("%dc", bronze)
    end
end

-- Parse a money string into copper
function Auctionator:ParseMoney(str)
    local gold = str:match("(%d+)g") or 0
    local silver = str:match("(%d+)s") or 0
    local copper = str:match("(%d+)c") or 0
    
    return (tonumber(gold) * 10000) + (tonumber(silver) * 100) + tonumber(copper)
end

-- Get current money from the gold/silver/copper inputs
function Auctionator:GetCurrentMoney()
    local gold = tonumber(self.goldInput:GetText()) or 0
    local silver = tonumber(self.silverInput:GetText()) or 0
    local copper = tonumber(self.copperInput:GetText()) or 0
    
    return (gold * 10000) + (silver * 100) + copper
end

-- Set the gold/silver/copper inputs to a copper amount
function Auctionator:SetMoneyInputs(copper)
    local gold = math.floor(copper / 10000)
    local silver = math.floor((copper % 10000) / 100)
    local bronze = copper % 100
    
    self.goldInput:SetText(gold)
    self.silverInput:SetText(silver)
    self.copperInput:SetText(bronze)
end

-- Perform a search for an item
function Auctionator:PerformSearch(searchText)
    if not searchText or searchText == "" then return end
    
    VUI:Print("Searching for: " .. searchText)
    
    -- Use the Blizzard auction house API to perform the search
    AuctionHouseFrame.SearchBar.SearchBox:SetText(searchText)
    AuctionHouseFrame.SearchBar.SearchButton:Click()
    
    -- Process results when they come back
    C_Timer.After(0.5, function() self:ProcessSearchResults() end)
end

-- Process the search results
function Auctionator:ProcessSearchResults()
    -- Clear the results frame
    if self.resultsScrollChild then
        self.resultsScrollChild:SetHeight(1) -- Reset height
        
        -- Remove existing entries
        for i = self.resultsScrollChild:GetNumChildren(), 1, -1 do
            local child = select(i, self.resultsScrollChild:GetChildren())
            child:Hide()
            child:SetParent(nil)
        end
    end
    
    -- Get the results from the Blizzard UI
    local numResults = C_AuctionHouse.GetNumCommoditySearchResults() + C_AuctionHouse.GetNumItemSearchResults()
    
    if numResults == 0 then
        -- No results found
        self:ShowNoResultsMessage()
        return
    end
    
    -- Process and display results
    local yOffset = 0
    
    -- Process commodity results
    for i = 1, C_AuctionHouse.GetNumCommoditySearchResults() do
        local result = C_AuctionHouse.GetCommoditySearchResultInfo(i)
        if result then
            local entry = self:CreateResultEntry(result, "commodity")
            entry:SetPoint("TOPLEFT", self.resultsScrollChild, "TOPLEFT", 0, -yOffset)
            entry:SetPoint("TOPRIGHT", self.resultsScrollChild, "TOPRIGHT", 0, -yOffset)
            entry:Show()
            
            yOffset = yOffset + entry:GetHeight()
        end
    end
    
    -- Process item results
    for i = 1, C_AuctionHouse.GetNumItemSearchResults() do
        local result = C_AuctionHouse.GetItemSearchResultInfo(i)
        if result then
            local entry = self:CreateResultEntry(result, "item")
            entry:SetPoint("TOPLEFT", self.resultsScrollChild, "TOPLEFT", 0, -yOffset)
            entry:SetPoint("TOPRIGHT", self.resultsScrollChild, "TOPRIGHT", 0, -yOffset)
            entry:Show()
            
            yOffset = yOffset + entry:GetHeight()
        end
    end
    
    -- Update the scroll frame height
    self.resultsScrollChild:SetHeight(yOffset)
end

-- Create an entry for a search result
function Auctionator:CreateResultEntry(result, resultType)
    local entry = CreateFrame("Button", nil, self.resultsScrollChild)
    entry:SetHeight(40)
    
    -- Item icon
    local icon = entry:CreateTexture(nil, "ARTWORK")
    icon:SetSize(32, 32)
    icon:SetPoint("TOPLEFT", entry, "TOPLEFT", 5, -4)
    icon:SetTexture(result.iconFileID or "Interface\\Icons\\INV_Misc_QuestionMark")
    
    -- Item name
    local name = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    name:SetPoint("TOPLEFT", icon, "TOPRIGHT", 5, 0)
    name:SetPoint("RIGHT", entry, "RIGHT", -100, 0)
    name:SetJustifyH("LEFT")
    name:SetText(result.itemLink or result.itemKey.itemName or "Unknown Item")
    
    -- Price
    local price = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    price:SetPoint("TOPRIGHT", entry, "TOPRIGHT", -5, -5)
    price:SetText(self:FormatMoney(result.minPrice))
    
    -- Quantity
    local quantity = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    quantity:SetPoint("BOTTOMRIGHT", entry, "BOTTOMRIGHT", -5, 5)
    quantity:SetText("Qty: " .. (result.quantity or 1))
    
    -- Store result data
    entry.result = result
    entry.resultType = resultType
    
    -- Click handler
    entry:SetScript("OnClick", function(self)
        -- Handle click on this result
        Auctionator:SelectSearchResult(self.result, self.resultType)
    end)
    
    -- Highlight on hover
    entry:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight", "ADD")
    
    return entry
end

-- Select a search result
function Auctionator:SelectSearchResult(result, resultType)
    -- Store the selected result
    self.selectedResult = result
    self.selectedResultType = resultType
    
    -- If we're in the sell tab, use this result for pricing
    if self.sellTabFrame:IsShown() and result then
        -- Set the price to undercut this result
        local price = result.minPrice or 0
        
        -- Apply undercut if configured
        local undercutPercent = VUI.db.profile.modules.auctionator.undercutPercent or 0
        if undercutPercent > 0 then
            price = math.floor(price * (1 - (undercutPercent / 100)))
        end
        
        -- Set the price inputs
        self:SetMoneyInputs(price)
    end
end

-- Show a message when no results are found
function Auctionator:ShowNoResultsMessage()
    -- Create a message in the results area
    local message = self.resultsScrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    message:SetPoint("CENTER", self.resultsScrollChild, "CENTER")
    message:SetText("No results found")
end

-- Add an item to the recent searches list
function Auctionator:AddRecentSearch(searchText)
    -- Check if already in the list
    for i, search in ipairs(self.recentSearches) do
        if search == searchText then
            -- Move to the top of the list
            table.remove(self.recentSearches, i)
            table.insert(self.recentSearches, 1, searchText)
            return
        end
    end
    
    -- Add to the top of the list
    table.insert(self.recentSearches, 1, searchText)
    
    -- Limit to 10 recent searches
    while #self.recentSearches > 10 do
        table.remove(self.recentSearches)
    end
    
    -- Update the list if it's currently shown
    if self.currentSearchListTab == "recent" then
        self:UpdateRecentSearchesList()
    end
end

-- Toggle a search term as a favorite
function Auctionator:ToggleFavorite(searchText)
    if self.favorites[searchText] then
        -- Remove from favorites
        self.favorites[searchText] = nil
        VUI:Print("Removed from favorites: " .. searchText)
    else
        -- Add to favorites
        self.favorites[searchText] = true
        VUI:Print("Added to favorites: " .. searchText)
    end
    
    -- Update the list if it's currently shown
    if self.currentSearchListTab == "favorites" then
        self:UpdateFavoritesList()
    end
end

-- Update the recent searches list
function Auctionator:UpdateRecentSearchesList()
    -- Clear the list
    if self.searchListScrollChild then
        self.searchListScrollChild:SetHeight(1) -- Reset height
        
        -- Remove existing entries
        for i = self.searchListScrollChild:GetNumChildren(), 1, -1 do
            local child = select(i, self.searchListScrollChild:GetChildren())
            child:Hide()
            child:SetParent(nil)
        end
    end
    
    -- Add recent searches
    local yOffset = 0
    
    if #self.recentSearches == 0 then
        -- No recent searches
        local message = self.searchListScrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        message:SetPoint("CENTER", self.searchListScrollChild, "CENTER")
        message:SetText("No recent searches")
        
        self.searchListScrollChild:SetHeight(message:GetHeight())
        return
    end
    
    for i, searchText in ipairs(self.recentSearches) do
        local entry = CreateFrame("Button", nil, self.searchListScrollChild)
        entry:SetHeight(30)
        entry:SetPoint("TOPLEFT", self.searchListScrollChild, "TOPLEFT", 0, -yOffset)
        entry:SetPoint("TOPRIGHT", self.searchListScrollChild, "TOPRIGHT", 0, -yOffset)
        
        -- Search text
        local text = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("LEFT", entry, "LEFT", 5, 0)
        text:SetPoint("RIGHT", entry, "RIGHT", -30, 0)
        text:SetJustifyH("LEFT")
        text:SetText(searchText)
        
        -- Favorite indicator
        local favorite = entry:CreateTexture(nil, "ARTWORK")
        favorite:SetSize(16, 16)
        favorite:SetPoint("RIGHT", entry, "RIGHT", -5, 0)
        
        if self.favorites[searchText] then
            favorite:SetTexture("Interface\\Common\\FavoritesIcon")
        else
            favorite:SetTexture(nil)
        end
        
        -- Click handler
        entry:SetScript("OnClick", function()
            -- Set the search box text
            self.searchBox:SetText(searchText)
            -- Perform the search
            self:PerformSearch(searchText)
        end)
        
        -- Right-click handler for context menu
        entry:SetScript("OnMouseDown", function(self, button)
            if button == "RightButton" then
                -- Create context menu
                local menu = {
                    { text = searchText, isTitle = true },
                    { text = Auctionator.favorites[searchText] and "Remove from Favorites" or "Add to Favorites", 
                      func = function() Auctionator:ToggleFavorite(searchText) end },
                    { text = "Remove from History", 
                      func = function() 
                          for i, search in ipairs(Auctionator.recentSearches) do
                              if search == searchText then
                                  table.remove(Auctionator.recentSearches, i)
                                  break
                              end
                          end
                          Auctionator:UpdateRecentSearchesList()
                      end },
                    { text = "Cancel", func = function() end }
                }
                EasyMenu(menu, CreateFrame("Frame", "VUIAuctionatorMenu", UIParent, "UIDropDownMenuTemplate"), "cursor", 0, 0, "MENU")
            end
        end)
        
        -- Highlight on hover
        entry:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight", "ADD")
        
        yOffset = yOffset + entry:GetHeight()
    end
    
    -- Update the scroll frame height
    self.searchListScrollChild:SetHeight(yOffset)
end

-- Update the favorites list
function Auctionator:UpdateFavoritesList()
    -- Clear the list
    if self.searchListScrollChild then
        self.searchListScrollChild:SetHeight(1) -- Reset height
        
        -- Remove existing entries
        for i = self.searchListScrollChild:GetNumChildren(), 1, -1 do
            local child = select(i, self.searchListScrollChild:GetChildren())
            child:Hide()
            child:SetParent(nil)
        end
    end
    
    -- Check if we have any favorites
    local hasFavorites = false
    for _ in pairs(self.favorites) do
        hasFavorites = true
        break
    end
    
    if not hasFavorites then
        -- No favorites
        local message = self.searchListScrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        message:SetPoint("CENTER", self.searchListScrollChild, "CENTER")
        message:SetText("No favorites")
        
        self.searchListScrollChild:SetHeight(message:GetHeight())
        return
    end
    
    -- Add favorites
    local yOffset = 0
    local favoritesList = {}
    
    -- Convert favorites table to list for sorting
    for searchText in pairs(self.favorites) do
        table.insert(favoritesList, searchText)
    end
    
    -- Sort alphabetically
    table.sort(favoritesList)
    
    for _, searchText in ipairs(favoritesList) do
        local entry = CreateFrame("Button", nil, self.searchListScrollChild)
        entry:SetHeight(30)
        entry:SetPoint("TOPLEFT", self.searchListScrollChild, "TOPLEFT", 0, -yOffset)
        entry:SetPoint("TOPRIGHT", self.searchListScrollChild, "TOPRIGHT", 0, -yOffset)
        
        -- Search text
        local text = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("LEFT", entry, "LEFT", 5, 0)
        text:SetPoint("RIGHT", entry, "RIGHT", -30, 0)
        text:SetJustifyH("LEFT")
        text:SetText(searchText)
        
        -- Favorite indicator
        local favorite = entry:CreateTexture(nil, "ARTWORK")
        favorite:SetSize(16, 16)
        favorite:SetPoint("RIGHT", entry, "RIGHT", -5, 0)
        favorite:SetTexture("Interface\\Common\\FavoritesIcon")
        
        -- Click handler
        entry:SetScript("OnClick", function()
            -- Set the search box text
            self.searchBox:SetText(searchText)
            -- Perform the search
            self:PerformSearch(searchText)
        end)
        
        -- Right-click handler for context menu
        entry:SetScript("OnMouseDown", function(self, button)
            if button == "RightButton" then
                -- Create context menu
                local menu = {
                    { text = searchText, isTitle = true },
                    { text = "Remove from Favorites", 
                      func = function() 
                          Auctionator:ToggleFavorite(searchText)
                      end },
                    { text = "Cancel", func = function() end }
                }
                EasyMenu(menu, CreateFrame("Frame", "VUIAuctionatorMenu", UIParent, "UIDropDownMenuTemplate"), "cursor", 0, 0, "MENU")
            end
        end)
        
        -- Highlight on hover
        entry:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight", "ADD")
        
        yOffset = yOffset + entry:GetHeight()
    end
    
    -- Update the scroll frame height
    self.searchListScrollChild:SetHeight(yOffset)
end

-- Pick an item for selling
function Auctionator:PickItem()
    -- Clear the item first
    self.selectedItem = nil
    self.itemIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    self.itemName:SetText("")
    
    -- Use the container frame as the parent for the dialog
    ClearCursor()
    
    -- Create a simple dialog to tell the user to click an item
    StaticPopupDialogs["VUI_AUCTIONATOR_PICK_ITEM"] = {
        text = "Click an item in your bags to select it for auction.",
        button1 = "Cancel",
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
        OnShow = function()
            -- Hook into the ContainerFrameItemButton_OnClick function
            Auctionator.originalOnClick = ContainerFrameItemButton_OnClick
            
            ContainerFrameItemButton_OnClick = function(self, button)
                if button == "LeftButton" then
                    local itemID = self:GetParent():GetID()
                    local itemButton = self:GetID()
                    local item = Item:CreateFromBagAndSlot(itemID, itemButton)
                    
                    if item then
                        local itemLink = item:GetItemLink()
                        Auctionator:SetSellItem(itemLink, item:GetItemIcon())
                        StaticPopup_Hide("VUI_AUCTIONATOR_PICK_ITEM")
                    end
                end
                
                -- Call the original function
                Auctionator.originalOnClick(self, button)
            end
        end,
        OnHide = function()
            -- Restore the original click function
            if Auctionator.originalOnClick then
                ContainerFrameItemButton_OnClick = Auctionator.originalOnClick
                Auctionator.originalOnClick = nil
            end
        end,
    }
    
    StaticPopup_Show("VUI_AUCTIONATOR_PICK_ITEM")
end

-- Set the item to sell
function Auctionator:SetSellItem(itemLink, itemTexture)
    if not itemLink then return end
    
    -- Store the item
    self.selectedItem = itemLink
    
    -- Update the UI
    self.itemIcon:SetTexture(itemTexture or GetItemIcon(itemLink))
    self.itemName:SetText(itemLink)
    
    -- Get the default stack size
    local stackSize = VUI.db.profile.modules.auctionator.stackSize or 0
    if stackSize > 0 then
        self.stackInput:SetText(stackSize)
    else
        self.stackInput:SetText("1")
    end
    
    -- Get quantity available
    self.quantityInput:SetText("1")
    
    -- Set default duration
    local duration = VUI.db.profile.modules.auctionator.defaultDuration or 24
    UIDropDownMenu_SetText(self.durationDropdown, duration .. " Hours")
    if duration == 12 then
        self.selectedDuration = 1
    elseif duration == 24 then
        self.selectedDuration = 2
    else
        self.selectedDuration = 3
    end
    
    -- Check price of existing auctions
    self:ScanItemPrice(itemLink)
end

-- Scan for the current price of an item
function Auctionator:ScanItemPrice(itemLink)
    if not itemLink then return end
    
    -- Use the Blizzard auction house API to search for this item
    local itemKey = C_AuctionHouse.GetItemKeyFromLink(itemLink)
    if not itemKey then return end
    
    -- Start a search for this item
    C_AuctionHouse.SendSearchQuery(itemKey, {}, false)
    
    -- Process results when they come back
    C_Timer.After(0.5, function() self:ProcessSellItemResults() end)
end

-- Process the results for the sell item
function Auctionator:ProcessSellItemResults()
    -- Clear the scan results
    if self.scanScrollChild then
        self.scanScrollChild:SetHeight(1) -- Reset height
        
        -- Remove existing entries
        for i = self.scanScrollChild:GetNumChildren(), 1, -1 do
            local child = select(i, self.scanScrollChild:GetChildren())
            child:Hide()
            child:SetParent(nil)
        end
    end
    
    -- Get the results from the Blizzard UI
    local numResults = C_AuctionHouse.GetNumCommoditySearchResults() + C_AuctionHouse.GetNumItemSearchResults()
    
    if numResults == 0 then
        -- No results, suggest vendor price or minimum bid
        self:SuggestDefaultPrice()
        return
    end
    
    -- Process and display results
    local yOffset = 0
    local lowestPrice = nil
    
    -- Process item results
    for i = 1, C_AuctionHouse.GetNumItemSearchResults() do
        local result = C_AuctionHouse.GetItemSearchResultInfo(i)
        if result then
            -- Track lowest price
            if not lowestPrice or result.minPrice < lowestPrice then
                lowestPrice = result.minPrice
            end
            
            -- Create an entry in the list
            local entry = self:CreateScanResultEntry(result)
            entry:SetPoint("TOPLEFT", self.scanScrollChild, "TOPLEFT", 0, -yOffset)
            entry:SetPoint("TOPRIGHT", self.scanScrollChild, "TOPRIGHT", 0, -yOffset)
            entry:Show()
            
            yOffset = yOffset + entry:GetHeight()
        end
    end
    
    -- Process commodity results
    for i = 1, C_AuctionHouse.GetNumCommoditySearchResults() do
        local result = C_AuctionHouse.GetCommoditySearchResultInfo(i)
        if result then
            -- Track lowest price
            if not lowestPrice or result.unitPrice < lowestPrice then
                lowestPrice = result.unitPrice
            end
            
            -- Create an entry in the list
            local entry = self:CreateScanResultEntry(result, true)
            entry:SetPoint("TOPLEFT", self.scanScrollChild, "TOPLEFT", 0, -yOffset)
            entry:SetPoint("TOPRIGHT", self.scanScrollChild, "TOPRIGHT", 0, -yOffset)
            entry:Show()
            
            yOffset = yOffset + entry:GetHeight()
        end
    end
    
    -- Update the scroll frame height
    self.scanScrollChild:SetHeight(yOffset)
    
    -- Set default price based on lowest price
    if lowestPrice then
        -- Apply undercut if configured
        local undercutPercent = VUI.db.profile.modules.auctionator.undercutPercent or 0
        if undercutPercent > 0 then
            lowestPrice = math.floor(lowestPrice * (1 - (undercutPercent / 100)))
        end
        
        -- Set the price inputs
        self:SetMoneyInputs(lowestPrice)
    else
        -- No lowest price found, use default
        self:SuggestDefaultPrice()
    end
end

-- Create an entry for a scan result
function Auctionator:CreateScanResultEntry(result, isCommodity)
    local entry = CreateFrame("Button", nil, self.scanScrollChild)
    entry:SetHeight(30)
    
    -- Price
    local price = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    price:SetPoint("LEFT", entry, "LEFT", 5, 0)
    price:SetWidth(150)
    price:SetJustifyH("LEFT")
    
    if isCommodity then
        price:SetText(self:FormatMoney(result.unitPrice) .. " each")
    else
        price:SetText(self:FormatMoney(result.minPrice))
    end
    
    -- Quantity
    local quantity = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    quantity:SetPoint("LEFT", price, "RIGHT", 10, 0)
    quantity:SetWidth(60)
    quantity:SetJustifyH("LEFT")
    quantity:SetText("Qty: " .. (result.quantity or 1))
    
    -- Owner (if available)
    if result.owner then
        local owner = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        owner:SetPoint("LEFT", quantity, "RIGHT", 10, 0)
        owner:SetPoint("RIGHT", entry, "RIGHT", -5, 0)
        owner:SetJustifyH("LEFT")
        owner:SetText("Seller: " .. result.owner)
    end
    
    -- Click handler to use this price
    entry:SetScript("OnClick", function()
        local priceValue = isCommodity and result.unitPrice or result.minPrice
        
        -- Apply undercut if configured
        local undercutPercent = VUI.db.profile.modules.auctionator.undercutPercent or 0
        if undercutPercent > 0 then
            priceValue = math.floor(priceValue * (1 - (undercutPercent / 100)))
        end
        
        -- Set the price inputs
        Auctionator:SetMoneyInputs(priceValue)
    end)
    
    -- Highlight on hover
    entry:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight", "ADD")
    
    return entry
end

-- Suggest a default price when no auctions exist
function Auctionator:SuggestDefaultPrice()
    -- Create a message in the scan area
    local message = self.scanScrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    message:SetPoint("TOP", self.scanScrollChild, "TOP", 0, -10)
    message:SetText("No current auctions found for this item.")
    
    -- Add a suggestion to check vendor price or disenchant value
    local suggestion = self.scanScrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    suggestion:SetPoint("TOP", message, "BOTTOM", 0, -10)
    suggestion:SetText("Suggested starting price: 1g 0s 0c")
    
    -- Set a default price
    self:SetMoneyInputs(10000) -- 1 gold
    
    self.scanScrollChild:SetHeight(50)
end

-- Post an auction with the current item
function Auctionator:PostAuction()
    if not self.selectedItem then
        VUI:Print("No item selected for auction")
        return
    end
    
    -- Get the price
    local price = self:GetCurrentMoney()
    if price <= 0 then
        VUI:Print("Please enter a valid price")
        return
    end
    
    -- Get stack size and quantity
    local stackSize = tonumber(self.stackInput:GetText()) or 1
    local quantity = tonumber(self.quantityInput:GetText()) or 1
    
    -- Get duration
    local duration = 24 -- Default to 24 hours
    if self.selectedDuration == 1 then
        duration = 12
    elseif self.selectedDuration == 2 then
        duration = 24
    elseif self.selectedDuration == 3 then
        duration = 48
    end
    
    -- Use the Blizzard auction house API to post the auction
    -- This is simplified as the actual implementation would need to handle
    -- the various auction house API states and callbacks
    VUI:Print("Posting auction: " .. self.selectedItem .. " x" .. stackSize .. 
                " (Qty: " .. quantity .. ") for " .. self:FormatMoney(price) .. 
                " (" .. duration .. " hours)")
                
    -- In a real addon, we would use something like:
    -- C_AuctionHouse.PostItem(self.selectedItem, stackSize, price, quantity, duration)
    
    -- Clear the inputs after posting
    self.selectedItem = nil
    self.itemIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    self.itemName:SetText("")
    self.goldInput:SetText("")
    self.silverInput:SetText("")
    self.copperInput:SetText("")
    self.stackInput:SetText("")
    self.quantityInput:SetText("")
end

-- Refresh the list of player auctions
function Auctionator:RefreshAuctions()
    -- Clear the cancel list
    if self.cancelScrollChild then
        self.cancelScrollChild:SetHeight(1) -- Reset height
        
        -- Remove existing entries
        for i = self.cancelScrollChild:GetNumChildren(), 1, -1 do
            local child = select(i, self.cancelScrollChild:GetChildren())
            child:Hide()
            child:SetParent(nil)
        end
    end
    
    -- Use the Blizzard auction house API to get the player's auctions
    C_AuctionHouse.QueryOwnedAuctions({})
    
    -- Process results when they come back
    C_Timer.After(0.5, function() self:ProcessOwnedAuctions() end)
end

-- Process the player's owned auctions
function Auctionator:ProcessOwnedAuctions()
    -- Get the number of owned auctions
    local numAuctions = C_AuctionHouse.GetNumOwnedAuctions()
    
    if numAuctions == 0 then
        -- No auctions found
        local message = self.cancelScrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        message:SetPoint("CENTER", self.cancelScrollChild, "CENTER")
        message:SetText("You have no active auctions")
        
        self.cancelScrollChild:SetHeight(message:GetHeight())
        return
    end
    
    -- Process and display auctions
    local yOffset = 0
    
    for i = 1, numAuctions do
        local auction = C_AuctionHouse.GetOwnedAuctionInfo(i)
        if auction then
            local entry = self:CreateOwnedAuctionEntry(auction)
            entry:SetPoint("TOPLEFT", self.cancelScrollChild, "TOPLEFT", 0, -yOffset)
            entry:SetPoint("TOPRIGHT", self.cancelScrollChild, "TOPRIGHT", 0, -yOffset)
            entry:Show()
            
            yOffset = yOffset + entry:GetHeight()
        end
    end
    
    -- Update the scroll frame height
    self.cancelScrollChild:SetHeight(yOffset)
end

-- Create an entry for an owned auction
function Auctionator:CreateOwnedAuctionEntry(auction)
    local entry = CreateFrame("Button", nil, self.cancelScrollChild)
    entry:SetHeight(50)
    
    -- Item icon
    local icon = entry:CreateTexture(nil, "ARTWORK")
    icon:SetSize(32, 32)
    icon:SetPoint("TOPLEFT", entry, "TOPLEFT", 5, -4)
    icon:SetTexture(auction.itemTexture or "Interface\\Icons\\INV_Misc_QuestionMark")
    
    -- Item name
    local name = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    name:SetPoint("TOPLEFT", icon, "TOPRIGHT", 5, 0)
    name:SetPoint("RIGHT", entry, "RIGHT", -100, 0)
    name:SetJustifyH("LEFT")
    name:SetText(auction.itemLink or auction.itemName or "Unknown Item")
    
    -- Price
    local price = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    price:SetPoint("TOPRIGHT", entry, "TOPRIGHT", -5, -5)
    price:SetText(self:FormatMoney(auction.buyoutPrice or auction.bidPrice))
    
    -- Quantity
    local quantity = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    quantity:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -2)
    quantity:SetText("Qty: " .. (auction.quantity or 1))
    
    -- Time left
    local timeLeft = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    timeLeft:SetPoint("BOTTOMRIGHT", entry, "BOTTOMRIGHT", -5, 5)
    
    local timeLeftText = "Unknown"
    if auction.timeLeft == Enum.AuctionHouseTimeLeftBand.Short then
        timeLeftText = "< 30 minutes"
    elseif auction.timeLeft == Enum.AuctionHouseTimeLeftBand.Medium then
        timeLeftText = "30m - 2h"
    elseif auction.timeLeft == Enum.AuctionHouseTimeLeftBand.Long then
        timeLeftText = "2h - 12h"
    elseif auction.timeLeft == Enum.AuctionHouseTimeLeftBand.VeryLong then
        timeLeftText = "> 12 hours"
    end
    
    timeLeft:SetText("Time: " .. timeLeftText)
    
    -- Cancel button
    local cancelButton = CreateFrame("Button", nil, entry, "UIPanelButtonTemplate")
    cancelButton:SetSize(80, 22)
    cancelButton:SetPoint("RIGHT", entry, "RIGHT", -5, 0)
    cancelButton:SetText("Cancel")
    
    cancelButton:SetScript("OnClick", function()
        -- Use the Blizzard auction house API to cancel the auction
        C_AuctionHouse.CancelAuction(auction.auctionID)
        
        -- Update the UI
        entry:SetAlpha(0.5)
        cancelButton:Disable()
    end)
    
    -- Store auction data
    entry.auction = auction
    
    -- Highlight on hover
    entry:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight", "ADD")
    
    return entry
end

-- Cancel all player auctions
function Auctionator:CancelAllAuctions()
    -- Get the number of owned auctions
    local numAuctions = C_AuctionHouse.GetNumOwnedAuctions()
    
    if numAuctions == 0 then
        VUI:Print("You have no active auctions")
        return
    end
    
    -- Cancel all auctions
    for i = 1, numAuctions do
        local auction = C_AuctionHouse.GetOwnedAuctionInfo(i)
        if auction then
            C_AuctionHouse.CancelAuction(auction.auctionID)
        end
    end
    
    VUI:Print("Cancelling all auctions...")
    
    -- Refresh the list after a short delay
    C_Timer.After(1, function() self:RefreshAuctions() end)
end

-- Handle the full scan tool
function Auctionator:HandleFullScanTool()
    -- Create a frame for the full scan
    local frame = CreateFrame("Frame", nil, self.moreTabFrame)
    frame:SetPoint("TOPLEFT", self.moreTabFrame, "TOPLEFT", 0, -40)
    frame:SetPoint("BOTTOMRIGHT", self.moreTabFrame, "BOTTOMRIGHT", 0, 0)
    
    -- Create heading
    local heading = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    heading:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -5)
    heading:SetText("Full Auction House Scan")
    
    -- Create description
    local desc = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    desc:SetPoint("TOPLEFT", heading, "BOTTOMLEFT", 0, -10)
    desc:SetPoint("RIGHT", frame, "RIGHT", -5, 0)
    desc:SetJustifyH("LEFT")
    desc:SetText("A full scan will gather pricing data for all items currently available on the auction house. This data is used for price suggestions when selling items and for tooltips.\n\nWarning: This can take several minutes and may cause temporary lag.")
    
    -- Create last scan info
    local lastScan = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    lastScan:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -20)
    
    if self.lastScan > 0 then
        local timeSince = time() - self.lastScan
        local timeStr = ""
        
        if timeSince < 60 then
            timeStr = timeSince .. " seconds ago"
        elseif timeSince < 3600 then
            timeStr = math.floor(timeSince / 60) .. " minutes ago"
        elseif timeSince < 86400 then
            timeStr = math.floor(timeSince / 3600) .. " hours ago"
        else
            timeStr = math.floor(timeSince / 86400) .. " days ago"
        end
        
        lastScan:SetText("Last scan: " .. timeStr)
    else
        lastScan:SetText("Last scan: Never")
    end
    
    -- Create scan button
    local scanButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    scanButton:SetSize(150, 30)
    scanButton:SetPoint("TOP", lastScan, "BOTTOM", 0, -20)
    scanButton:SetText("Start Full Scan")
    
    scanButton:SetScript("OnClick", function()
        self:PerformFullScan()
    end)
    
    -- Hide the More tab and show this frame
    self.moreTabFrame:Hide()
    frame:Show()
    
    -- Add back button
    local backButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    backButton:SetSize(100, 30)
    backButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 5, 5)
    backButton:SetText("Back")
    
    backButton:SetScript("OnClick", function()
        frame:Hide()
        self.moreTabFrame:Show()
    end)
end

-- Perform a full auction house scan
function Auctionator:PerformFullScan()
    VUI:Print("Starting full auction house scan...")
    
    -- In a real addon, this would use a series of API calls to scan all categories
    -- For simplicity, we'll just simulate the scan here
    
    -- Create a progress frame
    local progressFrame = CreateFrame("Frame", nil, UIParent)
    progressFrame:SetSize(300, 100)
    progressFrame:SetPoint("CENTER")
    progressFrame:SetFrameStrata("DIALOG")
    
    -- Add background
    local bg = progressFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0, 0, 0, 0.8)
    
    -- Add border
    progressFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = {left = 11, right = 12, top = 12, bottom = 11}
    })
    
    -- Add title
    local title = progressFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", progressFrame, "TOP", 0, -15)
    title:SetText("Scanning Auction House...")
    
    -- Add progress bar
    local progressBar = CreateFrame("StatusBar", nil, progressFrame)
    progressBar:SetSize(250, 20)
    progressBar:SetPoint("TOP", title, "BOTTOM", 0, -10)
    progressBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    progressBar:SetStatusBarColor(0, 0.7, 0)
    progressBar:SetMinMaxValues(0, 100)
    progressBar:SetValue(0)
    
    -- Add progress text
    local progressText = progressBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    progressText:SetPoint("CENTER", progressBar, "CENTER")
    progressText:SetText("0%")
    
    -- Add cancel button
    local cancelButton = CreateFrame("Button", nil, progressFrame, "UIPanelButtonTemplate")
    cancelButton:SetSize(100, 25)
    cancelButton:SetPoint("BOTTOM", progressFrame, "BOTTOM", 0, 15)
    cancelButton:SetText("Cancel")
    
    cancelButton:SetScript("OnClick", function()
        progressFrame:Hide()
    end)
    
    -- Start the simulated scan
    local progress = 0
    local scanTimer = C_Timer.NewTicker(0.1, function()
        progress = progress + 0.5
        progressBar:SetValue(progress)
        progressText:SetText(math.floor(progress) .. "%")
        
        if progress >= 100 then
            -- Scan complete
            progressFrame:Hide()
            self.lastScan = time()
            VUI:Print("Full auction house scan complete")
            
            -- Save the scan time to character data
            if VUI.charDB and VUI.charDB.profile.modules.auctionator then
                VUI.charDB.profile.modules.auctionator.lastScan = self.lastScan
            end
            
            -- Update the last scan text if visible
            if frame and frame:IsShown() and lastScan then
                lastScan:SetText("Last scan: Just now")
            end
            
            scanTimer:Cancel()
        end
    end)
end

-- Handle the price history tool
function Auctionator:HandlePriceHistoryTool()
    -- Placeholder function
    VUI:Print("Price History tool not implemented in this version")
end

-- Handle the shopping lists tool
function Auctionator:HandleShoppingTool()
    -- Placeholder function
    VUI:Print("Shopping Lists tool not implemented in this version")
end

-- Handle the settings tool
function Auctionator:HandleSettingsTool()
    -- Open the VUI configuration panel to the Auctionator section
    InterfaceOptionsFrame_OpenToCategory(VUI.NAME)
    InterfaceOptionsFrame_OpenToCategory(VUI.modulesFrame)
end

-- Save auction data before logout
function Auctionator:SaveAuctionData()
    if not VUI.charDB or not VUI.charDB.profile.modules.auctionator then return end
    
    -- Save favorites
    VUI.charDB.profile.modules.auctionator.favorites = self.favorites
    
    -- Save recent searches
    VUI.charDB.profile.modules.auctionator.recentSearches = self.recentSearches
    
    -- Save last scan time
    VUI.charDB.profile.modules.auctionator.lastScan = self.lastScan
end

-- Hook into game tooltips to add auction info
function Auctionator:SetupTooltipHooks()
    -- Hook the GameTooltip's OnTooltipSetItem script
    GameTooltip:HookScript("OnTooltipSetItem", function(tooltip)
        if not VUI:IsModuleEnabled("auctionator") then return end
        
        local name, link = tooltip:GetItem()
        if not name or not link then return end
        
        -- Add auction information to the tooltip
        self:AddAuctionInfoToTooltip(tooltip, link)
    end)
    
    -- Hook the ItemRefTooltip as well for linked items
    ItemRefTooltip:HookScript("OnTooltipSetItem", function(tooltip)
        if not VUI:IsModuleEnabled("auctionator") then return end
        
        local name, link = tooltip:GetItem()
        if not name or not link then return end
        
        -- Add auction information to the tooltip
        self:AddAuctionInfoToTooltip(tooltip, link)
    end)
end

-- Add auction information to an item tooltip
function Auctionator:AddAuctionInfoToTooltip(tooltip, itemLink)
    if not itemLink then return end
    
    local config = VUI.db.profile.modules.auctionator.tooltipConfig
    if not config then return end
    
    -- Add header
    tooltip:AddLine(" ")
    tooltip:AddLine("VUI Auctionator", 0.3, 0.7, 1)
    
    -- Add market value if enabled
    if config.showMarketValue then
        -- In a real addon, we would lookup the market value from our database
        tooltip:AddLine("Market Value: " .. self:FormatMoney(0), 1, 1, 1)
    end
    
    -- Add historical price if enabled
    if config.showHistoricalPrice then
        -- In a real addon, we would lookup the historical price from our database
        tooltip:AddLine("Historical Price: " .. self:FormatMoney(0), 1, 1, 1)
    end
    
    -- Add vendor price if enabled
    if config.showVendorPrice then
        local _, _, _, _, _, _, _, _, _, _, sellPrice = GetItemInfo(itemLink)
        if sellPrice and sellPrice > 0 then
            tooltip:AddLine("Vendor Price: " .. self:FormatMoney(sellPrice), 1, 1, 1)
        end
    end
    
    -- Add disenchant value if enabled
    if config.showDisenchantValue then
        -- In a real addon, we would compute the disenchant value
        tooltip:AddLine("Disenchant Value: " .. self:FormatMoney(0), 1, 1, 1)
    end
end
