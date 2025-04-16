local _, VUI = ...

-- Create the Auctionator module
local Auctionator = {}
VUI:RegisterModule("auctionator", Auctionator)

-- Initialize the module
function Auctionator:Initialize()
    -- Create tables for storing data
    self.scans = {}
    self.recentSearches = {}
    self.favorites = {}
    
    -- Register events
    self:RegisterEvent("AUCTION_HOUSE_SHOW")
    self:RegisterEvent("AUCTION_HOUSE_CLOSED")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_LOGOUT")
    
    -- Load character-specific data
    if VUI.charDB and VUI.charDB.profile.modules.auctionator then
        self.favorites = VUI.charDB.profile.modules.auctionator.favorites or {}
        self.recentSearches = VUI.charDB.profile.modules.auctionator.recentSearches or {}
        self.lastScan = VUI.charDB.profile.modules.auctionator.lastScan or 0
    end
    
    -- Initialize hooks
    self:SetupHooks()
end

-- Setup hooks into the auction house UI
function Auctionator:SetupHooks()
    -- Watch for the auction house addon to be loaded
    if IsAddOnLoaded("Blizzard_AuctionHouseUI") then
        self:HookAuctionHouse()
    else
        self:RegisterEvent("ADDON_LOADED", function(_, addonName)
            if addonName == "Blizzard_AuctionHouseUI" then
                self:HookAuctionHouse()
            end
        end)
    end
end

-- Hook into the auction house UI once it's loaded
function Auctionator:HookAuctionHouse()
    if self.hooked then return end
    
    -- Create our custom frame
    self:CreateAuctionHouseFrame()
    
    -- Hook into the auction house tab system
    if AuctionHouseFrame and AuctionHouseFrame.SetDisplayMode then
        hooksecurefunc(AuctionHouseFrame, "SetDisplayMode", function(frame, displayMode)
            -- Check if our tab was clicked
            if displayMode == self.displayMode then
                -- Show our UI
                if self.mainFrame then
                    self.mainFrame:Show()
                end
            else
                -- Hide our UI
                if self.mainFrame then
                    self.mainFrame:Hide()
                end
            end
        end)
    end
    
    self.hooked = true
end

-- Create custom auction house UI frame
function Auctionator:CreateAuctionHouseFrame()
    -- Main container frame
    self.mainFrame = CreateFrame("Frame", "VUIAuctionatorFrame", AuctionHouseFrame)
    self.mainFrame:SetPoint("TOPLEFT", AuctionHouseFrame.Tabs[#AuctionHouseFrame.Tabs], "BOTTOMLEFT", 0, 0)
    self.mainFrame:SetPoint("BOTTOMRIGHT", AuctionHouseFrame, "BOTTOMRIGHT", -4, 4)
    self.mainFrame:Hide()
    
    -- Create tab for our UI
    self.displayMode = "VUIAuctionator"
    local numTabs = #AuctionHouseFrame.Tabs
    local tab = CreateFrame("Button", "AuctionHouseFrameTab" .. numTabs + 1, AuctionHouseFrame, "AuctionHouseFrameTabTemplate")
    tab:SetID(numTabs + 1)
    tab:SetText("VUI Auctionator")
    tab:SetPoint("LEFT", AuctionHouseFrame.Tabs[numTabs], "RIGHT", -15, 0)
    tab:Show()
    
    tab:SetScript("OnClick", function()
        AuctionHouseFrame:SetDisplayMode(self.displayMode)
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
    end)
    
    table.insert(AuctionHouseFrame.Tabs, tab)
    
    -- Setup UI components
    self:CreateSearchTab()
    self:CreateSellTab()
    self:CreateCancelTab()
    self:CreateMoreTab()
    
    -- Create tab buttons
    self:CreateTabButtons()
    
    -- Start with the tab from settings
    self:SwitchTab(VUI.db.profile.modules.auctionator.defaultTab or "search")
end

-- Create interface tab buttons
function Auctionator:CreateTabButtons()
    self.tabButtons = {}
    
    local buttonFrame = CreateFrame("Frame", nil, self.mainFrame)
    buttonFrame:SetPoint("TOPLEFT", self.mainFrame, "TOPLEFT", 5, -5)
    buttonFrame:SetPoint("BOTTOMLEFT", self.mainFrame, "BOTTOMLEFT", 5, 5)
    buttonFrame:SetWidth(100)
    
    -- Create tab buttons
    local tabs = {
        {name = "search", label = "Search"},
        {name = "sell", label = "Sell"},
        {name = "cancel", label = "Cancel"},
        {name = "more", label = "More"}
    }
    
    for i, tab in ipairs(tabs) do
        local button = CreateFrame("Button", nil, buttonFrame, "UIPanelButtonTemplate")
        button:SetPoint("TOPLEFT", buttonFrame, "TOPLEFT", 5, -5 - (i-1) * 30)
        button:SetSize(90, 25)
        button:SetText(tab.label)
        
        button:SetScript("OnClick", function()
            self:SwitchTab(tab.name)
        end)
        
        self.tabButtons[tab.name] = button
    end
end

-- Switch between tabs
function Auctionator:SwitchTab(tabName)
    -- Update button states
    for name, button in pairs(self.tabButtons) do
        if name == tabName then
            button:LockHighlight()
        else
            button:UnlockHighlight()
        end
    end
    
    -- Hide all tab frames
    if self.searchTabFrame then self.searchTabFrame:Hide() end
    if self.sellTabFrame then self.sellTabFrame:Hide() end
    if self.cancelTabFrame then self.cancelTabFrame:Hide() end
    if self.moreTabFrame then self.moreTabFrame:Hide() end
    
    -- Show the selected tab
    if tabName == "search" and self.searchTabFrame then
        self.searchTabFrame:Show()
    elseif tabName == "sell" and self.sellTabFrame then
        self.sellTabFrame:Show()
    elseif tabName == "cancel" and self.cancelTabFrame then
        self.cancelTabFrame:Show()
    elseif tabName == "more" and self.moreTabFrame then
        self.moreTabFrame:Show()
    end
    
    -- Save the current tab
    VUI.db.profile.modules.auctionator.currentTab = tabName
end

-- Create the Search tab UI
function Auctionator:CreateSearchTab()
    -- Create the search tab frame
    self.searchTabFrame = CreateFrame("Frame", nil, self.mainFrame)
    self.searchTabFrame:SetPoint("TOPLEFT", self.mainFrame, "TOPLEFT", 105, -5)
    self.searchTabFrame:SetPoint("BOTTOMRIGHT", self.mainFrame, "BOTTOMRIGHT", -5, 5)
    
    -- Create search box
    local searchBox = CreateFrame("EditBox", nil, self.searchTabFrame, "SearchBoxTemplate")
    searchBox:SetPoint("TOPLEFT", self.searchTabFrame, "TOPLEFT", 5, -5)
    searchBox:SetSize(250, 25)
    searchBox:SetAutoFocus(false)
    
    searchBox:SetScript("OnEnterPressed", function(self)
        local searchText = self:GetText()
        if searchText and searchText ~= "" then
            Auctionator:PerformSearch(searchText)
            -- Add to recent searches
            Auctionator:AddRecentSearch(searchText)
        end
    end)
    
    self.searchBox = searchBox
    
    -- Search button
    local searchButton = CreateFrame("Button", nil, self.searchTabFrame, "UIPanelButtonTemplate")
    searchButton:SetPoint("LEFT", searchBox, "RIGHT", 5, 0)
    searchButton:SetSize(80, 25)
    searchButton:SetText("Search")
    
    searchButton:SetScript("OnClick", function()
        local searchText = searchBox:GetText()
        if searchText and searchText ~= "" then
            Auctionator:PerformSearch(searchText)
            -- Add to recent searches
            Auctionator:AddRecentSearch(searchText)
        end
    end)
    
    -- Favorite button
    local favoriteButton = CreateFrame("Button", nil, self.searchTabFrame, "UIPanelButtonTemplate")
    favoriteButton:SetPoint("LEFT", searchButton, "RIGHT", 5, 0)
    favoriteButton:SetSize(80, 25)
    favoriteButton:SetText("Favorite")
    
    favoriteButton:SetScript("OnClick", function()
        local searchText = searchBox:GetText()
        if searchText and searchText ~= "" then
            Auctionator:ToggleFavorite(searchText)
        end
    end)
    
    -- Create tabs for recent searches and favorites
    local listTabs = {
        {name = "recent", label = "Recent Searches"},
        {name = "favorites", label = "Favorites"}
    }
    
    local listTabButtons = {}
    local listFrame = CreateFrame("Frame", nil, self.searchTabFrame)
    listFrame:SetPoint("TOPLEFT", searchBox, "BOTTOMLEFT", 0, -30)
    listFrame:SetSize(250, 25)
    
    for i, tab in ipairs(listTabs) do
        local tabButton = CreateFrame("Button", nil, listFrame)
        tabButton:SetPoint("TOPLEFT", listFrame, "TOPLEFT", (i-1) * 125, 0)
        tabButton:SetSize(125, 25)
        tabButton:SetText(tab.label)
        tabButton:SetNormalFontObject("GameFontNormal")
        
        -- Create background texture
        local bg = tabButton:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0.1, 0.1, 0.1, 0.5)
        
        tabButton:SetScript("OnClick", function()
            self:SwitchSearchListTab(tab.name)
        end)
        
        listTabButtons[tab.name] = tabButton
    end
    
    self.searchListTabButtons = listTabButtons
    
    -- Create list frame for searches/favorites
    self.searchListFrame = CreateFrame("Frame", nil, self.searchTabFrame)
    self.searchListFrame:SetPoint("TOPLEFT", listFrame, "BOTTOMLEFT", 0, -5)
    self.searchListFrame:SetPoint("BOTTOMRIGHT", self.searchTabFrame, "BOTTOMLEFT", 255, 5)
    
    -- Create scroll frame for the list
    local scrollFrame = CreateFrame("ScrollFrame", nil, self.searchListFrame, "HybridScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT")
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 0)
    
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollFrame:SetScrollChild(scrollChild)
    scrollChild:SetSize(scrollFrame:GetWidth(), 1) -- Height will be set dynamically
    
    local scrollBar = CreateFrame("Slider", nil, scrollFrame, "HybridScrollBarTemplate")
    scrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", 1, -16)
    scrollBar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", 1, 16)
    scrollFrame.scrollBar = scrollBar
    
    self.searchListScrollFrame = scrollFrame
    self.searchListScrollChild = scrollChild
    
    -- Create results frame
    self.searchResultsFrame = CreateFrame("Frame", nil, self.searchTabFrame)
    self.searchResultsFrame:SetPoint("TOPLEFT", self.searchListFrame, "TOPRIGHT", 5, 0)
    self.searchResultsFrame:SetPoint("BOTTOMRIGHT", self.searchTabFrame, "BOTTOMRIGHT", -5, 5)
    
    -- Create scroll frame for results
    local resultsScrollFrame = CreateFrame("ScrollFrame", nil, self.searchResultsFrame, "HybridScrollFrameTemplate")
    resultsScrollFrame:SetPoint("TOPLEFT")
    resultsScrollFrame:SetPoint("BOTTOMRIGHT", -30, 0)
    
    local resultsScrollChild = CreateFrame("Frame", nil, resultsScrollFrame)
    resultsScrollFrame:SetScrollChild(resultsScrollChild)
    resultsScrollChild:SetSize(resultsScrollFrame:GetWidth(), 1) -- Height will be set dynamically
    
    local resultsScrollBar = CreateFrame("Slider", nil, resultsScrollFrame, "HybridScrollBarTemplate")
    resultsScrollBar:SetPoint("TOPLEFT", resultsScrollFrame, "TOPRIGHT", 1, -16)
    resultsScrollBar:SetPoint("BOTTOMLEFT", resultsScrollFrame, "BOTTOMRIGHT", 1, 16)
    resultsScrollFrame.scrollBar = resultsScrollBar
    
    self.resultsScrollFrame = resultsScrollFrame
    self.resultsScrollChild = resultsScrollChild
    
    -- Start with recent searches tab
    self:SwitchSearchListTab("recent")
    
    -- Hide the tab by default
    self.searchTabFrame:Hide()
end

-- Switch between recent searches and favorites list
function Auctionator:SwitchSearchListTab(tabName)
    -- Update button states
    for name, button in pairs(self.searchListTabButtons) do
        if name == tabName then
            button:SetNormalFontObject("GameFontHighlight")
            local bg = button:GetRegions()
            bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
        else
            button:SetNormalFontObject("GameFontNormal")
            local bg = button:GetRegions()
            bg:SetColorTexture(0.1, 0.1, 0.1, 0.5)
        end
    end
    
    -- Update the list based on the selected tab
    if tabName == "recent" then
        self:UpdateRecentSearchesList()
    elseif tabName == "favorites" then
        self:UpdateFavoritesList()
    end
    
    self.currentSearchListTab = tabName
end

-- Create the Sell tab UI
function Auctionator:CreateSellTab()
    -- Create the sell tab frame
    self.sellTabFrame = CreateFrame("Frame", nil, self.mainFrame)
    self.sellTabFrame:SetPoint("TOPLEFT", self.mainFrame, "TOPLEFT", 105, -5)
    self.sellTabFrame:SetPoint("BOTTOMRIGHT", self.mainFrame, "BOTTOMRIGHT", -5, 5)
    
    -- Create item frame
    local itemFrame = CreateFrame("Frame", nil, self.sellTabFrame)
    itemFrame:SetPoint("TOPLEFT", self.sellTabFrame, "TOPLEFT", 5, -5)
    itemFrame:SetSize(250, 50)
    
    -- Create item texture frame
    local itemTexture = CreateFrame("Button", nil, itemFrame)
    itemTexture:SetPoint("TOPLEFT", itemFrame, "TOPLEFT", 5, -5)
    itemTexture:SetSize(40, 40)
    
    -- Item icon texture
    local itemIcon = itemTexture:CreateTexture(nil, "ARTWORK")
    itemIcon:SetAllPoints()
    itemIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    
    self.itemIcon = itemIcon
    
    -- Item name text
    local itemName = itemFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    itemName:SetPoint("TOPLEFT", itemTexture, "TOPRIGHT", 5, 0)
    itemName:SetPoint("RIGHT", itemFrame, "RIGHT", -5, 0)
    itemName:SetJustifyH("LEFT")
    
    self.itemName = itemName
    
    -- Function to pick an item
    itemTexture:SetScript("OnClick", function()
        self:PickItem()
    end)
    
    -- Price input
    local priceFrame = CreateFrame("Frame", nil, self.sellTabFrame)
    priceFrame:SetPoint("TOPLEFT", itemFrame, "BOTTOMLEFT", 0, -10)
    priceFrame:SetSize(250, 30)
    
    local priceLabel = priceFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    priceLabel:SetPoint("TOPLEFT", priceFrame, "TOPLEFT", 5, 0)
    priceLabel:SetText("Price:")
    
    local goldInput = CreateFrame("EditBox", nil, priceFrame, "InputBoxTemplate")
    goldInput:SetPoint("TOPLEFT", priceLabel, "TOPRIGHT", 5, 0)
    goldInput:SetSize(60, 20)
    goldInput:SetAutoFocus(false)
    goldInput:SetNumeric(true)
    
    local goldText = priceFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    goldText:SetPoint("LEFT", goldInput, "RIGHT", 2, 0)
    goldText:SetText("g")
    
    local silverInput = CreateFrame("EditBox", nil, priceFrame, "InputBoxTemplate")
    silverInput:SetPoint("LEFT", goldText, "RIGHT", 5, 0)
    silverInput:SetSize(30, 20)
    silverInput:SetAutoFocus(false)
    silverInput:SetNumeric(true)
    silverInput:SetMaxLetters(2)
    
    local silverText = priceFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    silverText:SetPoint("LEFT", silverInput, "RIGHT", 2, 0)
    silverText:SetText("s")
    
    local copperInput = CreateFrame("EditBox", nil, priceFrame, "InputBoxTemplate")
    copperInput:SetPoint("LEFT", silverText, "RIGHT", 5, 0)
    copperInput:SetSize(30, 20)
    copperInput:SetAutoFocus(false)
    copperInput:SetNumeric(true)
    copperInput:SetMaxLetters(2)
    
    local copperText = priceFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    copperText:SetPoint("LEFT", copperInput, "RIGHT", 2, 0)
    copperText:SetText("c")
    
    self.goldInput = goldInput
    self.silverInput = silverInput
    self.copperInput = copperInput
    
    -- Stack size and quantity
    local stackFrame = CreateFrame("Frame", nil, self.sellTabFrame)
    stackFrame:SetPoint("TOPLEFT", priceFrame, "BOTTOMLEFT", 0, -10)
    stackFrame:SetSize(250, 30)
    
    local stackLabel = stackFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    stackLabel:SetPoint("TOPLEFT", stackFrame, "TOPLEFT", 5, 0)
    stackLabel:SetText("Stack Size:")
    
    local stackInput = CreateFrame("EditBox", nil, stackFrame, "InputBoxTemplate")
    stackInput:SetPoint("TOPLEFT", stackLabel, "TOPRIGHT", 5, 0)
    stackInput:SetSize(40, 20)
    stackInput:SetAutoFocus(false)
    stackInput:SetNumeric(true)
    
    local quantityLabel = stackFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    quantityLabel:SetPoint("LEFT", stackInput, "RIGHT", 10, 0)
    quantityLabel:SetText("Quantity:")
    
    local quantityInput = CreateFrame("EditBox", nil, stackFrame, "InputBoxTemplate")
    quantityInput:SetPoint("LEFT", quantityLabel, "RIGHT", 5, 0)
    quantityInput:SetSize(40, 20)
    quantityInput:SetAutoFocus(false)
    quantityInput:SetNumeric(true)
    
    self.stackInput = stackInput
    self.quantityInput = quantityInput
    
    -- Duration dropdown
    local durationFrame = CreateFrame("Frame", nil, self.sellTabFrame)
    durationFrame:SetPoint("TOPLEFT", stackFrame, "BOTTOMLEFT", 0, -10)
    durationFrame:SetSize(250, 30)
    
    local durationLabel = durationFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    durationLabel:SetPoint("TOPLEFT", durationFrame, "TOPLEFT", 5, 0)
    durationLabel:SetText("Duration:")
    
    local durationDropdown = CreateFrame("Frame", nil, durationFrame, "UIDropDownMenuTemplate")
    durationDropdown:SetPoint("TOPLEFT", durationLabel, "TOPRIGHT", -5, -3)
    
    UIDropDownMenu_SetWidth(durationDropdown, 100)
    UIDropDownMenu_SetText(durationDropdown, "24 Hours")
    
    UIDropDownMenu_Initialize(durationDropdown, function(self, level)
        local info = UIDropDownMenu_CreateInfo()
        
        info.func = function(self)
            UIDropDownMenu_SetText(durationDropdown, self:GetText())
            Auctionator.selectedDuration = self.value
        end
        
        info.text = "12 Hours"
        info.value = 1
        UIDropDownMenu_AddButton(info)
        
        info.text = "24 Hours"
        info.value = 2
        UIDropDownMenu_AddButton(info)
        
        info.text = "48 Hours"
        info.value = 3
        UIDropDownMenu_AddButton(info)
    end)
    
    self.durationDropdown = durationDropdown
    self.selectedDuration = 2 -- Default to 24 hours
    
    -- Create post button
    local postButton = CreateFrame("Button", nil, self.sellTabFrame, "UIPanelButtonTemplate")
    postButton:SetPoint("TOPLEFT", durationFrame, "BOTTOMLEFT", 0, -20)
    postButton:SetSize(230, 30)
    postButton:SetText("Post Auction")
    
    postButton:SetScript("OnClick", function()
        self:PostAuction()
    end)
    
    -- Create the scan section
    local scanFrame = CreateFrame("Frame", nil, self.sellTabFrame)
    scanFrame:SetPoint("TOPLEFT", postButton, "BOTTOMLEFT", 0, -20)
    scanFrame:SetPoint("BOTTOMRIGHT", self.sellTabFrame, "BOTTOMRIGHT", -5, 5)
    
    local scanHeading = scanFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    scanHeading:SetPoint("TOPLEFT", scanFrame, "TOPLEFT", 5, 0)
    scanHeading:SetText("Current Auctions")
    
    -- Create scroll frame for item listings
    local scanScrollFrame = CreateFrame("ScrollFrame", nil, scanFrame, "HybridScrollFrameTemplate")
    scanScrollFrame:SetPoint("TOPLEFT", scanHeading, "BOTTOMLEFT", 0, -10)
    scanScrollFrame:SetPoint("BOTTOMRIGHT", scanFrame, "BOTTOMRIGHT", -30, 0)
    
    local scanScrollChild = CreateFrame("Frame", nil, scanScrollFrame)
    scanScrollFrame:SetScrollChild(scanScrollChild)
    scanScrollChild:SetSize(scanScrollFrame:GetWidth(), 1) -- Height will be set dynamically
    
    local scanScrollBar = CreateFrame("Slider", nil, scanScrollFrame, "HybridScrollBarTemplate")
    scanScrollBar:SetPoint("TOPLEFT", scanScrollFrame, "TOPRIGHT", 1, -16)
    scanScrollBar:SetPoint("BOTTOMLEFT", scanScrollFrame, "BOTTOMRIGHT", 1, 16)
    scanScrollFrame.scrollBar = scanScrollBar
    
    self.scanScrollFrame = scanScrollFrame
    self.scanScrollChild = scanScrollChild
    
    -- Hide the tab by default
    self.sellTabFrame:Hide()
}

-- Create the Cancel tab UI
function Auctionator:CreateCancelTab()
    -- Create the cancel tab frame
    self.cancelTabFrame = CreateFrame("Frame", nil, self.mainFrame)
    self.cancelTabFrame:SetPoint("TOPLEFT", self.mainFrame, "TOPLEFT", 105, -5)
    self.cancelTabFrame:SetPoint("BOTTOMRIGHT", self.mainFrame, "BOTTOMRIGHT", -5, 5)
    
    -- Create heading
    local heading = self.cancelTabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    heading:SetPoint("TOPLEFT", self.cancelTabFrame, "TOPLEFT", 5, -5)
    heading:SetText("Your Auctions")
    
    -- Create refresh button
    local refreshButton = CreateFrame("Button", nil, self.cancelTabFrame, "UIPanelButtonTemplate")
    refreshButton:SetPoint("TOPRIGHT", self.cancelTabFrame, "TOPRIGHT", -5, -5)
    refreshButton:SetSize(100, 25)
    refreshButton:SetText("Refresh")
    
    refreshButton:SetScript("OnClick", function()
        self:RefreshAuctions()
    end)
    
    -- Create cancel all button
    local cancelAllButton = CreateFrame("Button", nil, self.cancelTabFrame, "UIPanelButtonTemplate")
    cancelAllButton:SetPoint("RIGHT", refreshButton, "LEFT", -5, 0)
    cancelAllButton:SetSize(100, 25)
    cancelAllButton:SetText("Cancel All")
    
    cancelAllButton:SetScript("OnClick", function()
        StaticPopupDialogs["VUI_AUCTIONATOR_CANCEL_ALL"] = {
            text = "Are you sure you want to cancel all auctions?",
            button1 = "Yes",
            button2 = "No",
            OnAccept = function()
                self:CancelAllAuctions()
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
        StaticPopup_Show("VUI_AUCTIONATOR_CANCEL_ALL")
    end)
    
    -- Create scroll frame for auction listings
    local scrollFrame = CreateFrame("ScrollFrame", nil, self.cancelTabFrame, "HybridScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", heading, "BOTTOMLEFT", 0, -10)
    scrollFrame:SetPoint("BOTTOMRIGHT", self.cancelTabFrame, "BOTTOMRIGHT", -30, 5)
    
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollFrame:SetScrollChild(scrollChild)
    scrollChild:SetSize(scrollFrame:GetWidth(), 1) -- Height will be set dynamically
    
    local scrollBar = CreateFrame("Slider", nil, scrollFrame, "HybridScrollBarTemplate")
    scrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", 1, -16)
    scrollBar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", 1, 16)
    scrollFrame.scrollBar = scrollBar
    
    self.cancelScrollFrame = scrollFrame
    self.cancelScrollChild = scrollChild
    
    -- Hide the tab by default
    self.cancelTabFrame:Hide()
}

-- Create the More tab UI
function Auctionator:CreateMoreTab()
    -- Create the more tab frame
    self.moreTabFrame = CreateFrame("Frame", nil, self.mainFrame)
    self.moreTabFrame:SetPoint("TOPLEFT", self.mainFrame, "TOPLEFT", 105, -5)
    self.moreTabFrame:SetPoint("BOTTOMRIGHT", self.mainFrame, "BOTTOMRIGHT", -5, 5)
    
    -- Create heading
    local heading = self.moreTabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    heading:SetPoint("TOPLEFT", self.moreTabFrame, "TOPLEFT", 5, -5)
    heading:SetText("Auctionator Tools")
    
    -- Create buttons for various tools
    local buttons = {
        {name = "fullScan", label = "Full Scan", desc = "Scan the entire auction house for pricing data"},
        {name = "priceHistory", label = "Price History", desc = "View price history for items"},
        {name = "shopping", label = "Shopping Lists", desc = "Create and manage shopping lists"},
        {name = "settings", label = "Settings", desc = "Configure Auctionator settings"}
    }
    
    for i, button in ipairs(buttons) do
        local btn = CreateFrame("Button", nil, self.moreTabFrame, "UIPanelButtonTemplate")
        btn:SetPoint("TOPLEFT", heading, "BOTTOMLEFT", 0, -10 - (i-1) * 40)
        btn:SetSize(150, 30)
        btn:SetText(button.label)
        
        local desc = self.moreTabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        desc:SetPoint("TOPLEFT", btn, "TOPRIGHT", 10, -5)
        desc:SetText(button.desc)
        
        btn:SetScript("OnClick", function()
            self["Handle" .. button.name:sub(1,1):upper() .. button.name:sub(2) .. "Tool"](self)
        end)
    end
    
    -- Hide the tab by default
    self.moreTabFrame:Hide()
}

-- Event handlers
function Auctionator:AUCTION_HOUSE_SHOW()
    -- Auction house opened
    if VUI.db.profile.modules.auctionator.autoscan then
        self:PerformFullScan()
    end
}

function Auctionator:AUCTION_HOUSE_CLOSED()
    -- Auction house closed, save any data if needed
    self:SaveAuctionData()
}

function Auctionator:PLAYER_ENTERING_WORLD()
    -- Load saved data
    if VUI.charDB and VUI.charDB.profile.modules.auctionator then
        self.favorites = VUI.charDB.profile.modules.auctionator.favorites or {}
        self.recentSearches = VUI.charDB.profile.modules.auctionator.recentSearches or {}
        self.lastScan = VUI.charDB.profile.modules.auctionator.lastScan or 0
    end
}

function Auctionator:PLAYER_LOGOUT()
    -- Save data before logout
    if VUI.charDB and VUI.charDB.profile.modules.auctionator then
        VUI.charDB.profile.modules.auctionator.favorites = self.favorites
        VUI.charDB.profile.modules.auctionator.recentSearches = self.recentSearches
        VUI.charDB.profile.modules.auctionator.lastScan = self.lastScan
    end
}

-- Module enable/disable functions
function Auctionator:Enable()
    -- Enable event processing
    self:RegisterEvent("AUCTION_HOUSE_SHOW", self.AUCTION_HOUSE_SHOW)
    self:RegisterEvent("AUCTION_HOUSE_CLOSED", self.AUCTION_HOUSE_CLOSED)
    self:RegisterEvent("PLAYER_ENTERING_WORLD", self.PLAYER_ENTERING_WORLD)
    self:RegisterEvent("PLAYER_LOGOUT", self.PLAYER_LOGOUT)
    
    VUI:Print("Auctionator module enabled")
}

function Auctionator:Disable()
    -- Unregister events
    self:UnregisterEvent("AUCTION_HOUSE_SHOW")
    self:UnregisterEvent("AUCTION_HOUSE_CLOSED")
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    self:UnregisterEvent("PLAYER_LOGOUT")
    
    VUI:Print("Auctionator module disabled")
}

-- Helper functions
function Auctionator:RegisterEvent(event, handler)
    if not self.eventFrame then
        self.eventFrame = CreateFrame("Frame")
        self.eventFrame.events = {}
        self.eventFrame:SetScript("OnEvent", function(_, event, ...)
            local handler = self.eventFrame.events[event]
            if handler then
                handler(self, event, ...)
            end
        end)
    end
    
    self.eventFrame.events[event] = handler or self[event]
    self.eventFrame:RegisterEvent(event)
}

function Auctionator:UnregisterEvent(event)
    if self.eventFrame and self.eventFrame.events[event] then
        self.eventFrame:UnregisterEvent(event)
        self.eventFrame.events[event] = nil
    end
}

-- Update settings
function Auctionator:UpdateSettings()
    -- Apply settings
    if self.currentTab and self.tabButtons then
        self:SwitchTab(VUI.db.profile.modules.auctionator.defaultTab or "search")
    end
}

-- Get options for the config panel
function Auctionator:GetOptions()
    return {
        type = "group",
        name = "Auctionator",
        args = {
            enable = {
                type = "toggle",
                name = "Enable",
                desc = "Enable or disable the Auctionator module",
                order = 1,
                get = function() return VUI:IsModuleEnabled("auctionator") end,
                set = function(_, value)
                    if value then
                        VUI:EnableModule("auctionator")
                    else
                        VUI:DisableModule("auctionator")
                    end
                end,
            },
            general = {
                type = "group",
                name = "General Settings",
                order = 2,
                inline = true,
                disabled = function() return not VUI:IsModuleEnabled("auctionator") end,
                args = {
                    autoscan = {
                        type = "toggle",
                        name = "Auto Scan",
                        desc = "Automatically scan the auction house when it opens",
                        order = 1,
                        get = function() return VUI.db.profile.modules.auctionator.autoscan end,
                        set = function(_, value)
                            VUI.db.profile.modules.auctionator.autoscan = value
                        end,
                    },
                    defaultTab = {
                        type = "select",
                        name = "Default Tab",
                        desc = "Select the default tab to show when opening Auctionator",
                        order = 2,
                        values = {
                            ["search"] = "Search",
                            ["sell"] = "Sell",
                            ["cancel"] = "Cancel",
                            ["more"] = "More",
                        },
                        get = function() return VUI.db.profile.modules.auctionator.defaultTab end,
                        set = function(_, value)
                            VUI.db.profile.modules.auctionator.defaultTab = value
                            Auctionator:UpdateSettings()
                        end,
                    },
                    scanSpeed = {
                        type = "select",
                        name = "Scan Speed",
                        desc = "Set the speed for auction house scanning",
                        order = 3,
                        values = {
                            ["slow"] = "Slow (Less CPU Usage)",
                            ["normal"] = "Normal",
                            ["fast"] = "Fast (More CPU Usage)",
                        },
                        get = function() return VUI.db.profile.modules.auctionator.scanSpeed end,
                        set = function(_, value)
                            VUI.db.profile.modules.auctionator.scanSpeed = value
                        end,
                    },
                }
            },
            selling = {
                type = "group",
                name = "Selling Options",
                order = 3,
                inline = true,
                disabled = function() return not VUI:IsModuleEnabled("auctionator") end,
                args = {
                    undercutPercent = {
                        type = "range",
                        name = "Undercut Percentage",
                        desc = "Percentage to undercut the lowest auction by (0 for no undercut)",
                        min = 0,
                        max = 20,
                        step = 1,
                        order = 1,
                        get = function() return VUI.db.profile.modules.auctionator.undercutPercent end,
                        set = function(_, value)
                            VUI.db.profile.modules.auctionator.undercutPercent = value
                        end,
                    },
                    defaultDuration = {
                        type = "select",
                        name = "Default Duration",
                        desc = "Default auction duration",
                        order = 2,
                        values = {
                            [12] = "12 Hours",
                            [24] = "24 Hours",
                            [48] = "48 Hours",
                        },
                        get = function() return VUI.db.profile.modules.auctionator.defaultDuration end,
                        set = function(_, value)
                            VUI.db.profile.modules.auctionator.defaultDuration = value
                        end,
                    },
                    stackSize = {
                        type = "range",
                        name = "Default Stack Size",
                        desc = "Default stack size for auctions (0 for maximum)",
                        min = 0,
                        max = 200,
                        step = 1,
                        order = 3,
                        get = function() return VUI.db.profile.modules.auctionator.stackSize end,
                        set = function(_, value)
                            VUI.db.profile.modules.auctionator.stackSize = value
                        end,
                    },
                }
            },
            display = {
                type = "group",
                name = "Display Options",
                order = 4,
                inline = true,
                disabled = function() return not VUI:IsModuleEnabled("auctionator") end,
                args = {
                    showLinkBrackets = {
                        type = "toggle",
                        name = "Show Link Brackets",
                        desc = "Show brackets around item links",
                        order = 1,
                        get = function() return VUI.db.profile.modules.auctionator.showLinkBrackets end,
                        set = function(_, value)
                            VUI.db.profile.modules.auctionator.showLinkBrackets = value
                        end,
                    },
                    useCompactUI = {
                        type = "toggle",
                        name = "Use Compact UI",
                        desc = "Use a more compact UI for auction listings",
                        order = 2,
                        get = function() return VUI.db.profile.modules.auctionator.useCompactUI end,
                        set = function(_, value)
                            VUI.db.profile.modules.auctionator.useCompactUI = value
                            Auctionator:UpdateSettings()
                        end,
                    },
                    historyDays = {
                        type = "range",
                        name = "History Days",
                        desc = "Number of days to keep price history",
                        min = 1,
                        max = 60,
                        step = 1,
                        order = 3,
                        get = function() return VUI.db.profile.modules.auctionator.historyDays end,
                        set = function(_, value)
                            VUI.db.profile.modules.auctionator.historyDays = value
                        end,
                    },
                }
            },
            tooltips = {
                type = "group",
                name = "Tooltip Options",
                order = 5,
                inline = true,
                disabled = function() return not VUI:IsModuleEnabled("auctionator") end,
                args = {
                    showMarketValue = {
                        type = "toggle",
                        name = "Show Market Value",
                        desc = "Show market value in item tooltips",
                        order = 1,
                        get = function() return VUI.db.profile.modules.auctionator.tooltipConfig.showMarketValue end,
                        set = function(_, value)
                            VUI.db.profile.modules.auctionator.tooltipConfig.showMarketValue = value
                        end,
                    },
                    showHistoricalPrice = {
                        type = "toggle",
                        name = "Show Historical Price",
                        desc = "Show historical price data in item tooltips",
                        order = 2,
                        get = function() return VUI.db.profile.modules.auctionator.tooltipConfig.showHistoricalPrice end,
                        set = function(_, value)
                            VUI.db.profile.modules.auctionator.tooltipConfig.showHistoricalPrice = value
                        end,
                    },
                    showDisenchantValue = {
                        type = "toggle",
                        name = "Show Disenchant Value",
                        desc = "Show disenchant value in item tooltips",
                        order = 3,
                        get = function() return VUI.db.profile.modules.auctionator.tooltipConfig.showDisenchantValue end,
                        set = function(_, value)
                            VUI.db.profile.modules.auctionator.tooltipConfig.showDisenchantValue = value
                        end,
                    },
                    showVendorPrice = {
                        type = "toggle",
                        name = "Show Vendor Price",
                        desc = "Show vendor sell price in item tooltips",
                        order = 4,
                        get = function() return VUI.db.profile.modules.auctionator.tooltipConfig.showVendorPrice end,
                        set = function(_, value)
                            VUI.db.profile.modules.auctionator.tooltipConfig.showVendorPrice = value
                        end,
                    },
                }
            },
        }
    }
}
