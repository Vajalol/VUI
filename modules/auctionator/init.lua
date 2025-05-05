local _, VUI = ...

-- Create the Auctionator module
local Auctionator = {
    name = "auctionator",
    title = "VUI Auctionator",
    desc = "Enhanced auction house functionality with improved buying and selling interfaces",
    version = "1.0.0", 
    author = "VortexQ8",
}
VUI:RegisterModule("auctionator", Auctionator)

-- Get configuration options for main UI integration
function Auctionator:GetConfig()
    local config = {
        name = "Auctionator",
        type = "group",
        args = {
            enabled = {
                type = "toggle",
                name = "Enable Auctionator",
                desc = "Enable or disable the Auctionator module",
                get = function() return VUI.db.profile.modules.auctionator.enabled end,
                set = function(_, value) 
                    VUI.db.profile.modules.auctionator.enabled = value
                    if value then
                        self:Enable()
                    else
                        self:Disable()
                    end
                end,
                order = 1
            },
            generalHeading = {
                type = "header",
                name = "General Settings",
                order = 2
            },
            useVUITheme = {
                type = "toggle",
                name = "Use VUI Theme",
                desc = "Apply the current VUI theme to Auctionator's interface",
                get = function() return VUI.db.profile.modules.auctionator.useVUITheme end,
                set = function(_, value) 
                    VUI.db.profile.modules.auctionator.useVUITheme = value
                    
                    -- Apply theme changes immediately if possible
                    if self.ThemeIntegration and self.ThemeIntegration.ApplyTheme then
                        self.ThemeIntegration:ApplyTheme()
                    end
                end,
                order = 3
            },
            defaultTab = {
                type = "select",
                name = "Default Tab",
                desc = "Which tab should be active when opening Auctionator",
                values = {
                    ["search"] = "Search",
                    ["sell"] = "Sell",
                    ["cancel"] = "Cancel",
                    ["more"] = "More",
                },
                get = function() return VUI.db.profile.modules.auctionator.defaultTab or "search" end,
                set = function(_, value) 
                    VUI.db.profile.modules.auctionator.defaultTab = value
                end,
                order = 4
            },
            scanHeading = {
                type = "header",
                name = "Scan Settings",
                order = 5
            },
            autoscan = {
                type = "toggle",
                name = "Auto-Scan AH",
                desc = "Automatically scan the auction house when opened",
                get = function() return VUI.db.profile.modules.auctionator.scanOptions.autoscan end,
                set = function(_, value) 
                    VUI.db.profile.modules.auctionator.scanOptions.autoscan = value
                end,
                order = 6
            },
            scanInterval = {
                type = "range",
                name = "Auto-Scan Interval",
                desc = "Minutes between automatic scans (if Auto-Scan enabled)",
                min = 15,
                max = 180,
                step = 5,
                get = function() return VUI.db.profile.modules.auctionator.scanOptions.scanInterval or 60 end,
                set = function(_, value) 
                    VUI.db.profile.modules.auctionator.scanOptions.scanInterval = value
                end,
                order = 7,
                disabled = function() return not VUI.db.profile.modules.auctionator.scanOptions.autoscan end,
            },
            scanSpeed = {
                type = "select",
                name = "Scan Speed",
                desc = "How quickly to scan the auction house",
                values = {
                    ["slow"] = "Slow (Less Resource Usage)",
                    ["medium"] = "Medium (Balanced)",
                    ["fast"] = "Fast (More Resource Usage)"
                },
                get = function() return VUI.db.profile.modules.auctionator.scanOptions.throttleRate or "medium" end,
                set = function(_, value) 
                    VUI.db.profile.modules.auctionator.scanOptions.throttleRate = value
                end,
                order = 8
            },
            saveHistory = {
                type = "toggle",
                name = "Save Price History",
                desc = "Save historical price data for items",
                get = function() return VUI.db.profile.modules.auctionator.saveHistory end,
                set = function(_, value) 
                    VUI.db.profile.modules.auctionator.saveHistory = value
                end,
                order = 9
            },
            sellingHeading = {
                type = "header",
                name = "Selling Settings",
                order = 10
            },
            undercut = {
                type = "range",
                name = "Default Undercut",
                desc = "Default percentage to undercut when listing items",
                min = 1,
                max = 100,
                step = 1,
                get = function() return VUI.db.profile.modules.auctionator.undercut or 5 end,
                set = function(_, value) 
                    VUI.db.profile.modules.auctionator.undercut = value
                end,
                order = 11
            },
            defaultDuration = {
                type = "select",
                name = "Default Duration",
                desc = "Default auction duration when listing items",
                values = {
                    [1] = "12 Hours",
                    [2] = "24 Hours",
                    [3] = "48 Hours",
                },
                get = function() return VUI.db.profile.modules.auctionator.defaultDuration or 2 end,
                set = function(_, value) 
                    VUI.db.profile.modules.auctionator.defaultDuration = value
                end,
                order = 12
            },
            rememberLastSellSettings = {
                type = "toggle",
                name = "Remember Last Sell Settings",
                desc = "Remember your last settings for each item when selling",
                get = function() return VUI.db.profile.modules.auctionator.rememberLastSellSettings end,
                set = function(_, value) 
                    VUI.db.profile.modules.auctionator.rememberLastSellSettings = value
                end,
                order = 13
            },
            bagViewHeading = {
                type = "header",
                name = "Bag View Settings",
                order = 14
            },
            showBagView = {
                type = "toggle",
                name = "Show Bag View",
                desc = "Show bag contents in the sell tab",
                get = function() return VUI.db.profile.modules.auctionator.showBagView end,
                set = function(_, value) 
                    VUI.db.profile.modules.auctionator.showBagView = value
                end,
                order = 15
            },
            bagViewScale = {
                type = "range",
                name = "Bag View Scale",
                desc = "Size of the bag icons in the sell tab",
                min = 0.5,
                max = 2,
                step = 0.1,
                get = function() return VUI.db.profile.modules.auctionator.bagViewScale or 1 end,
                set = function(_, value) 
                    VUI.db.profile.modules.auctionator.bagViewScale = value
                    -- Update scale if the bag frame exists
                    if self.bagFrame then
                        self.bagFrame:SetScale(value)
                    end
                end,
                order = 16,
                disabled = function() return not VUI.db.profile.modules.auctionator.showBagView end,
            },
            shoppingListHeading = {
                type = "header",
                name = "Shopping List Settings",
                order = 17
            },
            defaultShoppingList = {
                type = "select",
                name = "Default Shopping List",
                desc = "The default shopping list to use",
                values = function()
                    local lists = {}
                    for i, list in ipairs(self.shoppingLists) do
                        lists[list.name] = list.name
                    end
                    return lists
                end,
                get = function() return VUI.db.profile.modules.auctionator.shoppingListOptions.defaultList or "Default" end,
                set = function(_, value) 
                    VUI.db.profile.modules.auctionator.shoppingListOptions.defaultList = value
                    VUI.db.profile.modules.auctionator.shoppingListOptions.activeList = value
                end,
                order = 18
            },
            showEmptyLists = {
                type = "toggle",
                name = "Show Empty Lists",
                desc = "Show shopping lists with no items in the dropdown",
                get = function() return VUI.db.profile.modules.auctionator.shoppingListOptions.showEmptyLists end,
                set = function(_, value) 
                    VUI.db.profile.modules.auctionator.shoppingListOptions.showEmptyLists = value
                end,
                order = 19
            }
        }
    }
    
    return config
end

-- Register module config with the VUI ModuleAPI
VUI.ModuleAPI:RegisterModuleConfig("auctionator", Auctionator:GetConfig())

-- Initialize the module
function Auctionator:Initialize()
    -- Create tables for storing data
    self.scans = {}
    self.recentSearches = {}
    self.favorites = {}
    self.shoppingLists = {}
    self.scanData = {}
    self.itemPriceData = {}
    
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
        self.shoppingLists = VUI.charDB.profile.modules.auctionator.shoppingLists or {}
        self.itemPriceData = VUI.charDB.profile.modules.auctionator.itemPriceData or {}
    end
    
    -- Initialize hooks
    self:SetupHooks()
    
    -- Set default theme options if not set
    if VUI.db.profile.modules.auctionator.useVUITheme == nil then
        VUI.db.profile.modules.auctionator.useVUITheme = true
    end
    
    -- Set default scan options if not set
    if VUI.db.profile.modules.auctionator.scanOptions == nil then
        VUI.db.profile.modules.auctionator.scanOptions = {
            autoscan = false,
            scanInterval = 60, -- Minutes between auto-scans
            throttleRate = "medium" -- Scan speed (slow, medium, fast)
        }
    end
    
    -- Set default shopping list options if not set
    if VUI.db.profile.modules.auctionator.shoppingListOptions == nil then
        VUI.db.profile.modules.auctionator.shoppingListOptions = {
            activeList = "Default",
            defaultList = "Default"
        }
    end
    
    -- Create default shopping list if none exist
    if #self.shoppingLists == 0 then
        self.shoppingLists = {
            {
                name = "Default",
                items = {}
            }
        }
    end
    
    -- Load theme integration module
    self:LoadThemeIntegration()
    
    -- Module initialized
end

-- Load the theme integration module
function Auctionator:LoadThemeIntegration()
    -- Check if theme integration file exists and load it
    local loaded, reason = LoadAddOn("VUI_AuctionatorThemeIntegration")
    if not loaded and reason ~= "ADDON_LOADED" then
        -- Try to load the module directly
        local status, error = pcall(function()
            -- First try to load the file from our addon directory
            local file = "Interface\\AddOns\\VUI\\modules\\auctionator\\ThemeIntegration.lua"
            dofile(file)
        end)
        
        if not status then
            -- Failed to load Auctionator theme integration, using default styling
            return
        end
    end
    
    -- Initialize theme integration if available
    if self.ThemeIntegration and self.ThemeIntegration.Initialize then
        self.ThemeIntegration:Initialize()
    end
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
    
    -- Track frame references for theming
    self:TrackFrameReferences()
    
    -- Hook into the auction house tab system
    if AuctionHouseFrame and AuctionHouseFrame.SetDisplayMode then
        hooksecurefunc(AuctionHouseFrame, "SetDisplayMode", function(frame, displayMode)
            -- Check if our tab was clicked
            if displayMode == self.displayMode then
                -- Show our UI
                if self.mainFrame then
                    self.mainFrame:Show()
                    
                    -- Apply theme when the frame becomes visible
                    if self.ThemeIntegration and VUI.db.profile.modules.auctionator.useVUITheme then
                        self.ThemeIntegration:ApplyThemeToAuctionUI()
                    end
                end
            else
                -- Hide our UI
                if self.mainFrame then
                    self.mainFrame:Hide()
                end
            end
        end)
    end
    
    -- Register for theme change events
    if not self.themeChangeRegistered then
        VUI:RegisterCallback("ThemeChanged", function()
            -- Update the logo if it exists
            if self.logo then
                local currentTheme = VUI.db.profile.appearance.theme or "thunderstorm"
                local logoTexturePath = "Interface\\Addons\\VUI\\media\\textures\\" .. currentTheme .. "\\auctionator\\Logo.tga"
                self.logo:SetTexture(logoTexturePath)
            end
            
            -- Apply theme to all UI elements if visible and theme integration is enabled
            if self.mainFrame and self.mainFrame:IsShown() and 
               self.ThemeIntegration and VUI.db.profile.modules.auctionator.useVUITheme then
                self.ThemeIntegration:ApplyThemeToAuctionUI()
            end
        end)
        self.themeChangeRegistered = true
    end
    
    self.hooked = true
end

-- Track and store references to important AH UI frames
function Auctionator:TrackFrameReferences()
    -- Set up a post-hook for the AH frame creation
    hooksecurefunc("AuctionHouseFrame_OnLoad", function(frame)
        if not frame then return end
        
        -- Store the main frame reference
        self.mainFrame = frame
        
        -- Find and store header frame
        self.headerFrame = frame.TitleContainer or frame:GetChildren()[1]
        
        -- Track tab buttons
        self.tabButtons = {}
        for i = 1, frame.numTabs or 0 do
            local tab = _G["AuctionHouseFrameTab"..i]
            if tab then
                table.insert(self.tabButtons, tab)
            end
        end
        
        -- Track search UI
        if frame.SearchTab then
            self.searchTabFrame = frame.SearchTab
            self.searchBox = frame.SearchTab.SearchBox
            self.searchListFrame = frame.SearchTab.SearchList
            self.searchResultsFrame = frame.SearchTab.ItemList
            
            -- Track category headers
            self.categoryHeaders = {}
            if frame.SearchTab.FilterButton then
                table.insert(self.categoryHeaders, frame.SearchTab.FilterButton)
            end
            
            -- Track column headers
            self.columnHeaders = {}
            if frame.SearchTab.ItemList then
                for _, child in pairs({frame.SearchTab.ItemList:GetChildren()}) do
                    if child:IsObjectType("Button") and child.text then
                        table.insert(self.columnHeaders, child)
                    end
                end
            end
            
            -- Track item rows
            self.itemRows = {}
            if frame.SearchTab.ItemList and frame.SearchTab.ItemList.ScrollFrame then
                for _, child in pairs({frame.SearchTab.ItemList.ScrollFrame:GetChildren()}) do
                    if child:IsObjectType("Button") or child:IsObjectType("Frame") then
                        table.insert(self.itemRows, child)
                    end
                end
            end
        end
        
        -- Track sell UI
        if frame.SellTab then
            self.sellTabFrame = frame.SellTab
            self.priceInput = frame.SellTab.PriceInput
            self.quantityInput = frame.SellTab.QuantityInput
            self.postButton = frame.SellTab.PostButton
        end
        
        -- Track cancel UI
        if frame.CancelTab then
            self.cancelTabFrame = frame.CancelTab
            self.cancelButton = frame.CancelTab.CancelButton
        end
        
        -- Track more options UI
        if frame.MoreTab then
            self.moreTabFrame = frame.MoreTab
        end
        
        -- Track scrollframes for custom scrollbar styling
        self.scrollFrames = {}
        local function FindScrollFrames(f)
            if not f then return end
            
            if f:IsObjectType("ScrollFrame") then
                table.insert(self.scrollFrames, f)
            end
            
            for _, child in pairs({f:GetChildren()}) do
                FindScrollFrames(child)
            end
        end
        
        FindScrollFrames(frame)
        
        -- Apply theme once all references are captured
        if self.ThemeIntegration and self.ThemeIntegration.ApplyThemeToAuctionUI then
            self.ThemeIntegration:ApplyThemeToAuctionUI()
        end
    end)
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
    
    -- Add a logo to the interface
    self.logo = self.mainFrame:CreateTexture("VUIAuctionatorLogo", "ARTWORK")
    self.logo:SetSize(64, 64)
    self.logo:SetPoint("TOPLEFT", self.mainFrame, "TOPLEFT", 20, -20)
    
    -- First try to use a theme-specific logo
    local currentTheme = VUI.db.profile.appearance.theme or "thunderstorm"
    local logoTexturePath = "Interface\\Addons\\VUI\\media\\textures\\" .. currentTheme .. "\\auctionator\\Logo.tga"
    self.logo:SetTexture(logoTexturePath)
    
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
    
    -- Create category dropdown
    local categoryFrame = CreateFrame("Frame", nil, self.searchTabFrame)
    categoryFrame:SetPoint("TOPLEFT", self.searchTabFrame, "TOPLEFT", 5, -5)
    categoryFrame:SetSize(150, 25)
    
    local categoryLabel = categoryFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    categoryLabel:SetPoint("TOPLEFT", categoryFrame, "TOPLEFT", 0, 0)
    categoryLabel:SetText("Category:")
    
    local categoryDropdown = CreateFrame("Frame", nil, categoryFrame, "UIDropDownMenuTemplate")
    categoryDropdown:SetPoint("TOPLEFT", categoryLabel, "BOTTOMLEFT", -15, -2)
    
    UIDropDownMenu_SetWidth(categoryDropdown, 130)
    UIDropDownMenu_SetText(categoryDropdown, "All Categories")
    
    UIDropDownMenu_Initialize(categoryDropdown, function(self, level)
        local info = UIDropDownMenu_CreateInfo()
        
        info.func = function(self)
            UIDropDownMenu_SetText(categoryDropdown, self:GetText())
            Auctionator.selectedCategory = self.value
        end
        
        info.text = "All Categories"
        info.value = 0
        UIDropDownMenu_AddButton(info)
        
        -- Add predefined categories - would use real Enum.ItemClass in real implementation
        local categories = {
            {id = 1, name = "Weapons"},
            {id = 2, name = "Armor"},
            {id = 3, name = "Containers"},
            {id = 4, name = "Consumables"},
            {id = 5, name = "Trade Goods"},
            {id = 6, name = "Recipes"},
            {id = 7, name = "Miscellaneous"},
        }
        
        for _, category in ipairs(categories) do
            info.text = category.name
            info.value = category.id
            UIDropDownMenu_AddButton(info)
        end
    end)
    
    self.categoryDropdown = categoryDropdown
    
    -- Create search box
    local searchBox = CreateFrame("EditBox", nil, self.searchTabFrame, "SearchBoxTemplate")
    searchBox:SetPoint("TOPLEFT", categoryFrame, "BOTTOMLEFT", 0, -10)
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
    
    -- Advanced search options button
    local advancedButton = CreateFrame("Button", nil, self.searchTabFrame, "UIPanelButtonTemplate")
    advancedButton:SetPoint("LEFT", searchButton, "RIGHT", 5, 0)
    advancedButton:SetSize(80, 25)
    advancedButton:SetText("Advanced")
    
    advancedButton:SetScript("OnClick", function()
        -- Toggle advanced search options
        if self.advancedSearchFrame and self.advancedSearchFrame:IsShown() then
            self.advancedSearchFrame:Hide()
        else
            self:ShowAdvancedSearchOptions()
        end
    end)
    
    -- Create tabs for lists
    local listTabs = {
        {name = "recent", label = "Recent"},
        {name = "favorites", label = "Favorites"},
        {name = "shopping", label = "Shopping Lists"}
    }
    
    local listTabButtons = {}
    local listFrame = CreateFrame("Frame", nil, self.searchTabFrame)
    listFrame:SetPoint("TOPLEFT", searchBox, "BOTTOMLEFT", 0, -35)
    listFrame:SetSize(250, 25)
    
    for i, tab in ipairs(listTabs) do
        local tabButton = CreateFrame("Button", nil, listFrame)
        local tabWidth = 250 / #listTabs
        tabButton:SetPoint("TOPLEFT", listFrame, "TOPLEFT", (i-1) * tabWidth, 0)
        tabButton:SetSize(tabWidth, 25)
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
    
    -- Create list frame for searches/favorites/shopping lists
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
    
    -- Create shopping list management controls
    self:CreateShoppingListControls()
    
    -- Create results frame
    self.searchResultsFrame = CreateFrame("Frame", nil, self.searchTabFrame)
    self.searchResultsFrame:SetPoint("TOPLEFT", self.searchListFrame, "TOPRIGHT", 5, 0)
    self.searchResultsFrame:SetPoint("BOTTOMRIGHT", self.searchTabFrame, "BOTTOMRIGHT", -5, 5)
    
    -- Add column headers to results
    local headerFrame = CreateFrame("Frame", nil, self.searchResultsFrame)
    headerFrame:SetPoint("TOPLEFT", self.searchResultsFrame, "TOPLEFT", 0, 0)
    headerFrame:SetPoint("RIGHT", self.searchResultsFrame, "RIGHT", 0, 0)
    headerFrame:SetHeight(25)
    
    -- Create column headers
    local headers = {
        {text = "Item", width = 0.45},  -- 45% of width
        {text = "Quantity", width = 0.15}, -- 15% of width
        {text = "Price Each", width = 0.2}, -- 20% of width
        {text = "Total", width = 0.2} -- 20% of width
    }
    
    local prevHeader
    for i, header in ipairs(headers) do
        local headerText = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        
        if i == 1 then
            headerText:SetPoint("TOPLEFT", headerFrame, "TOPLEFT", 5, 0)
            headerText:SetWidth(headerFrame:GetWidth() * header.width - 5)
        else
            headerText:SetPoint("TOPLEFT", prevHeader, "TOPRIGHT", 5, 0)
            headerText:SetWidth(headerFrame:GetWidth() * header.width - 5)
        end
        
        headerText:SetText(header.text)
        headerText:SetJustifyH("LEFT")
        
        prevHeader = headerText
        headers[i].textObj = headerText
    end
    
    self.resultsHeaders = headers
    self.resultsHeaderFrame = headerFrame
    
    -- Create scroll frame for results
    local resultsScrollFrame = CreateFrame("ScrollFrame", nil, self.searchResultsFrame, "HybridScrollFrameTemplate")
    resultsScrollFrame:SetPoint("TOPLEFT", headerFrame, "BOTTOMLEFT", 0, -2)
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
    
    -- Create scan frame and progress bar
    local scanFrame = CreateFrame("Frame", nil, self.searchTabFrame)
    scanFrame:SetPoint("BOTTOMRIGHT", self.searchTabFrame, "BOTTOMRIGHT", -10, 10)
    scanFrame:SetSize(200, 30)
    
    local scanButton = CreateFrame("Button", nil, scanFrame, "UIPanelButtonTemplate")
    scanButton:SetPoint("BOTTOMRIGHT", scanFrame, "BOTTOMRIGHT", 0, 0)
    scanButton:SetSize(100, 25)
    scanButton:SetText("Full Scan")
    
    scanButton:SetScript("OnClick", function()
        self:StartFullScan()
    end)
    
    local scanProgressBar = CreateFrame("StatusBar", nil, scanFrame)
    scanProgressBar:SetPoint("RIGHT", scanButton, "LEFT", -5, 0)
    scanProgressBar:SetSize(95, 25)
    scanProgressBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    scanProgressBar:SetStatusBarColor(0, 0.7, 0)
    scanProgressBar:SetMinMaxValues(0, 100)
    scanProgressBar:SetValue(0)
    scanProgressBar:Hide()
    
    local scanProgressText = scanProgressBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    scanProgressText:SetPoint("CENTER")
    scanProgressText:SetText("0%")
    
    self.scanButton = scanButton
    self.scanProgressBar = scanProgressBar
    self.scanProgressText = scanProgressText
    
    -- Start with recent searches tab
    self:SwitchSearchListTab("recent")
    
    -- Hide the tab by default
    self.searchTabFrame:Hide()
end

-- Create shopping list controls
function Auctionator:CreateShoppingListControls()
    -- Shopping list management frame
    local listControlsFrame = CreateFrame("Frame", nil, self.searchListFrame)
    listControlsFrame:SetPoint("BOTTOMLEFT", self.searchListFrame, "BOTTOMLEFT", 0, 0)
    listControlsFrame:SetPoint("BOTTOMRIGHT", self.searchListFrame, "BOTTOMRIGHT", 0, 0)
    listControlsFrame:SetHeight(60)
    listControlsFrame:Hide()
    
    -- Create shopping list dropdown
    local listLabel = listControlsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    listLabel:SetPoint("TOPLEFT", listControlsFrame, "TOPLEFT", 5, 0)
    listLabel:SetText("Shopping List:")
    
    local listDropdown = CreateFrame("Frame", nil, listControlsFrame, "UIDropDownMenuTemplate")
    listDropdown:SetPoint("TOPLEFT", listLabel, "BOTTOMLEFT", -15, -2)
    
    UIDropDownMenu_SetWidth(listDropdown, 150)
    
    UIDropDownMenu_Initialize(listDropdown, function(frame, level)
        local info = UIDropDownMenu_CreateInfo()
        
        info.func = function(self)
            UIDropDownMenu_SetText(listDropdown, self:GetText())
            local listName = self:GetText()
            Auctionator:SelectShoppingList(listName)
        end
        
        -- Add all shopping lists
        for i, list in ipairs(Auctionator.shoppingLists) do
            local showList = true
            if not VUI.db.profile.modules.auctionator.shoppingListOptions.showEmptyLists and #list.items == 0 then
                showList = false
            end
            
            if showList then
                info.text = list.name
                info.checked = (list.name == Auctionator.currentShoppingList)
                UIDropDownMenu_AddButton(info)
            end
        end
    end)
    
    -- Set initial text
    local defaultList = VUI.db.profile.modules.auctionator.shoppingListOptions.defaultList or "Default"
    UIDropDownMenu_SetText(listDropdown, defaultList)
    self.currentShoppingList = defaultList
    
    self.shoppingListDropdown = listDropdown
    
    -- Create new list button
    local newListButton = CreateFrame("Button", nil, listControlsFrame, "UIPanelButtonTemplate")
    newListButton:SetPoint("TOPLEFT", listDropdown, "BOTTOMLEFT", 16, -5)
    newListButton:SetSize(60, 22)
    newListButton:SetText("New")
    
    newListButton:SetScript("OnClick", function()
        self:CreateNewShoppingList()
    end)
    
    -- Create add item button
    local addItemButton = CreateFrame("Button", nil, listControlsFrame, "UIPanelButtonTemplate")
    addItemButton:SetPoint("LEFT", newListButton, "RIGHT", 5, 0)
    addItemButton:SetSize(60, 22)
    addItemButton:SetText("Add")
    
    addItemButton:SetScript("OnClick", function()
        self:AddItemToShoppingList()
    end)
    
    -- Create delete list button
    local deleteListButton = CreateFrame("Button", nil, listControlsFrame, "UIPanelButtonTemplate")
    deleteListButton:SetPoint("LEFT", addItemButton, "RIGHT", 5, 0)
    deleteListButton:SetSize(60, 22)
    deleteListButton:SetText("Delete")
    
    deleteListButton:SetScript("OnClick", function()
        self:DeleteShoppingList()
    end)
    
    self.shoppingListControls = listControlsFrame
    self.shoppingListControls.newListButton = newListButton
    self.shoppingListControls.addItemButton = addItemButton
    self.shoppingListControls.deleteListButton = deleteListButton
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
    
    -- Clear the list
    self.searchListScrollChild:SetHeight(1)
    for i, child in ipairs({self.searchListScrollChild:GetChildren()}) do
        child:Hide()
        child:SetParent(nil)
    end
    
    -- Show/hide shopping list controls
    if tabName == "shopping" then
        if self.shoppingListControls then
            self.shoppingListControls:Show()
        end
    else
        if self.shoppingListControls then
            self.shoppingListControls:Hide()
        end
    end
    
    -- Update the list based on the selected tab
    if tabName == "recent" then
        self:UpdateRecentSearchesList()
    elseif tabName == "favorites" then
        self:UpdateFavoritesList()
    elseif tabName == "shopping" then
        self:UpdateShoppingList()
    end
    
    self.currentSearchListTab = tabName
end

-- Select a shopping list
function Auctionator:SelectShoppingList(listName)
    -- Find the list
    local foundList = false
    for i, list in ipairs(self.shoppingLists) do
        if list.name == listName then
            foundList = true
            break
        end
    end
    
    -- Create the list if it doesn't exist
    if not foundList then
        table.insert(self.shoppingLists, {
            name = listName,
            items = {}
        })
    end
    
    -- Set as current list
    self.currentShoppingList = listName
    VUI.db.profile.modules.auctionator.shoppingListOptions.activeList = listName
    
    -- Update the display
    self:UpdateShoppingList()
end

-- Create a new shopping list
function Auctionator:CreateNewShoppingList()
    -- Create popup dialog
    StaticPopupDialogs["VUI_AUCTIONATOR_NEW_LIST"] = {
        text = "Enter name for new shopping list:",
        button1 = "Create",
        button2 = "Cancel",
        OnAccept = function(self)
            local listName = self.editBox:GetText()
            if listName and listName ~= "" then
                -- Check if a list with this name already exists
                local listExists = false
                for i, list in ipairs(Auctionator.shoppingLists) do
                    if list.name == listName then
                        listExists = true
                        break
                    end
                end
                
                if not listExists then
                    -- Create the new list
                    table.insert(Auctionator.shoppingLists, {
                        name = listName,
                        items = {}
                    })
                    
                    -- Select the new list
                    Auctionator:SelectShoppingList(listName)
                    UIDropDownMenu_SetText(Auctionator.shoppingListDropdown, listName)
                else
                    -- Show error message
                    Auctionator:Print("A shopping list with that name already exists.")
                end
            end
        end,
        hasEditBox = true,
        editBoxWidth = 150,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3
    }
    
    StaticPopup_Show("VUI_AUCTIONATOR_NEW_LIST")
end

-- Add an item to the shopping list
function Auctionator:AddItemToShoppingList()
    -- Create popup dialog
    StaticPopupDialogs["VUI_AUCTIONATOR_ADD_ITEM"] = {
        text = "Enter item to add to shopping list:",
        button1 = "Add",
        button2 = "Cancel",
        OnAccept = function(self)
            local itemText = self.editBox:GetText()
            if itemText and itemText ~= "" then
                Auctionator:AddItemToCurrentList(itemText)
            end
        end,
        hasEditBox = true,
        editBoxWidth = 150,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3
    }
    
    StaticPopup_Show("VUI_AUCTIONATOR_ADD_ITEM")
end

-- Add an item to the current shopping list
function Auctionator:AddItemToCurrentList(itemText)
    if not self.currentShoppingList then
        self:Print("No shopping list selected.")
        return
    end
    
    -- Find the list
    for i, list in ipairs(self.shoppingLists) do
        if list.name == self.currentShoppingList then
            -- Check if item already exists
            local itemExists = false
            for j, item in ipairs(list.items) do
                if item.text == itemText then
                    itemExists = true
                    break
                end
            end
            
            if not itemExists then
                -- Add the item
                table.insert(list.items, {
                    text = itemText,
                    added = time()
                })
                
                -- Update the display
                self:UpdateShoppingList()
            else
                self:Print("Item already exists in the list.")
            end
            
            break
        end
    end
end

-- Remove an item from a shopping list
function Auctionator:RemoveItemFromList(listName, itemIndex)
    -- Find the list
    for i, list in ipairs(self.shoppingLists) do
        if list.name == listName then
            -- Remove the item
            table.remove(list.items, itemIndex)
            
            -- Update the display
            self:UpdateShoppingList()
            break
        end
    end
end

-- Update the shopping list display
function Auctionator:UpdateShoppingList()
    -- Clear the list
    self.searchListScrollChild:SetHeight(1)
    for i, child in ipairs({self.searchListScrollChild:GetChildren()}) do
        child:Hide()
        child:SetParent(nil)
    end
    
    -- Find the current list
    local currentList = nil
    for i, list in ipairs(self.shoppingLists) do
        if list.name == self.currentShoppingList then
            currentList = list
            break
        end
    end
    
    if not currentList then
        -- No list selected or list doesn't exist
        return
    end
    
    -- Create list items
    local yOffset = -5
    local itemHeight = 25
    
    for i, item in ipairs(currentList.items) do
        -- Create item frame
        local itemFrame = CreateFrame("Frame", nil, self.searchListScrollChild)
        itemFrame:SetPoint("TOPLEFT", self.searchListScrollChild, "TOPLEFT", 5, yOffset)
        itemFrame:SetPoint("RIGHT", self.searchListScrollChild, "RIGHT", -5, 0)
        itemFrame:SetHeight(itemHeight)
        
        -- Item background
        local bg = itemFrame:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        
        -- Alternate row colors
        if i % 2 == 0 then
            bg:SetColorTexture(0.1, 0.1, 0.1, 0.3)
        else
            bg:SetColorTexture(0.15, 0.15, 0.15, 0.3)
        end
        
        -- Item text
        local itemText = itemFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        itemText:SetPoint("LEFT", itemFrame, "LEFT", 5, 0)
        itemText:SetPoint("RIGHT", itemFrame, "RIGHT", -25, 0)
        itemText:SetJustifyH("LEFT")
        itemText:SetText(item.text)
        
        -- Search button
        local searchButton = CreateFrame("Button", nil, itemFrame)
        searchButton:SetPoint("RIGHT", itemFrame, "RIGHT", -5, 0)
        searchButton:SetSize(16, 16)
        searchButton:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Check")
        
        searchButton:SetScript("OnClick", function()
            -- Search for this item
            if Auctionator.searchBox then
                Auctionator.searchBox:SetText(item.text)
                Auctionator:PerformSearch(item.text)
            end
        end)
        
        -- Delete button
        local deleteButton = CreateFrame("Button", nil, itemFrame)
        deleteButton:SetPoint("RIGHT", searchButton, "LEFT", -2, 0)
        deleteButton:SetSize(16, 16)
        deleteButton:SetNormalTexture("Interface\\Buttons\\UI-StopButton")
        
        deleteButton:SetScript("OnClick", function()
            -- Remove this item
            Auctionator:RemoveItemFromList(currentList.name, i)
        end)
        
        -- Make the whole row clickable to search
        itemFrame:EnableMouse(true)
        itemFrame:SetScript("OnMouseUp", function(self, button)
            if button == "LeftButton" then
                -- Search for this item
                if Auctionator.searchBox then
                    Auctionator.searchBox:SetText(item.text)
                    Auctionator:PerformSearch(item.text)
                end
            end
        end)
        
        -- Hover highlight
        itemFrame:SetScript("OnEnter", function()
            bg:SetColorTexture(0.3, 0.3, 0.3, 0.4)
        end)
        
        itemFrame:SetScript("OnLeave", function()
            if i % 2 == 0 then
                bg:SetColorTexture(0.1, 0.1, 0.1, 0.3)
            else
                bg:SetColorTexture(0.15, 0.15, 0.15, 0.3)
            end
        end)
        
        yOffset = yOffset - itemHeight
    end
    
    -- Adjust the scroll child height
    local totalHeight = math.abs(yOffset)
    self.searchListScrollChild:SetHeight(math.max(totalHeight, self.searchListScrollFrame:GetHeight()))
end

-- Delete a shopping list
function Auctionator:DeleteShoppingList()
    if not self.currentShoppingList or self.currentShoppingList == "Default" then
        self:Print("Cannot delete the default shopping list.")
        return
    end
    
    -- Create popup dialog
    StaticPopupDialogs["VUI_AUCTIONATOR_DELETE_LIST"] = {
        text = "Are you sure you want to delete shopping list '" .. self.currentShoppingList .. "'?",
        button1 = "Delete",
        button2 = "Cancel",
        OnAccept = function()
            local listIndex = nil
            for i, list in ipairs(Auctionator.shoppingLists) do
                if list.name == Auctionator.currentShoppingList then
                    listIndex = i
                    break
                end
            end
            
            if listIndex then
                -- Remove the list
                table.remove(Auctionator.shoppingLists, listIndex)
                
                -- Select the default list
                Auctionator:SelectShoppingList("Default")
                UIDropDownMenu_SetText(Auctionator.shoppingListDropdown, "Default")
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3
    }
    
    StaticPopup_Show("VUI_AUCTIONATOR_DELETE_LIST")
end

-- Start a full auction house scan
function Auctionator:StartFullScan()
    -- Show progress elements
    self.scanProgressBar:Show()
    self.scanProgressBar:SetValue(0)
    self.scanProgressText:SetText("0%")
    
    -- Set scan in progress state
    self.scanInProgress = true
    self.scanStartTime = GetTime()
    self.scanItems = {}
    self.scanProgress = 0
    
    self:Print("Starting full auction house scan...")
    
    -- Use C_Timer to simulate the scan process
    -- In a real implementation, this would use the Blizzard auction house API
    C_Timer.After(0.1, function() self:ProcessScanBatch(1) end)
end

-- Process a batch of the scan
function Auctionator:ProcessScanBatch(batchNumber)
    -- Update progress
    local progress = math.min(batchNumber * 5, 100)
    self.scanProgressBar:SetValue(progress)
    self.scanProgressText:SetText(progress .. "%")
    self.scanProgress = progress
    
    if progress < 100 then
        -- Continue scanning
        local throttleRate = VUI.db.profile.modules.auctionator.scanOptions.throttleRate or "medium"
        local delay = 0.1
        
        if throttleRate == "slow" then
            delay = 0.2
        elseif throttleRate == "fast" then
            delay = 0.05
        end
        
        C_Timer.After(delay, function() self:ProcessScanBatch(batchNumber + 1) end)
    else
        -- Finish scan
        self.scanInProgress = false
        self.scanProgressText:SetText("Scan Complete")
        
        -- Save scan time
        self.lastScan = GetTime()
        VUI.charDB.profile.modules.auctionator.lastScan = self.lastScan
        
        self:Print("Auction house scan complete!")
        
        C_Timer.After(2, function() 
            self.scanProgressBar:Hide() 
        end)
    end
end

-- Create the Sell tab UI
function Auctionator:CreateSellTab()
    -- Create the sell tab frame
    self.sellTabFrame = CreateFrame("Frame", nil, self.mainFrame)
    self.sellTabFrame:SetPoint("TOPLEFT", self.mainFrame, "TOPLEFT", 105, -5)
    self.sellTabFrame:SetPoint("BOTTOMRIGHT", self.mainFrame, "BOTTOMRIGHT", -5, 5)
    
    -- Left side - Item details and posting options
    local sellOptionsFrame = CreateFrame("Frame", nil, self.sellTabFrame)
    sellOptionsFrame:SetPoint("TOPLEFT", self.sellTabFrame, "TOPLEFT", 5, -5)
    sellOptionsFrame:SetPoint("BOTTOMRIGHT", self.sellTabFrame, "BOTTOMRIGHT", -270, 5)
    
    -- Create item selection header
    local itemSelectHeader = sellOptionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    itemSelectHeader:SetPoint("TOPLEFT", sellOptionsFrame, "TOPLEFT", 5, -5)
    itemSelectHeader:SetText("Post an Item")
    
    -- Create item frame
    local itemFrame = CreateFrame("Frame", nil, sellOptionsFrame)
    itemFrame:SetPoint("TOPLEFT", itemSelectHeader, "BOTTOMLEFT", 0, -10)
    itemFrame:SetSize(250, 50)
    
    -- Create item texture frame
    local itemTexture = CreateFrame("Button", nil, itemFrame)
    itemTexture:SetPoint("TOPLEFT", itemFrame, "TOPLEFT", 5, -5)
    itemTexture:SetSize(40, 40)
    itemTexture:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
    
    -- Add item border
    local itemBorder = itemTexture:CreateTexture(nil, "OVERLAY")
    itemBorder:SetPoint("TOPLEFT", itemTexture, "TOPLEFT", -2, 2)
    itemBorder:SetPoint("BOTTOMRIGHT", itemTexture, "BOTTOMRIGHT", 2, -2)
    itemBorder:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    itemBorder:SetBlendMode("ADD")
    itemBorder:SetAlpha(0.8)
    
    -- Item icon texture
    local itemIcon = itemTexture:CreateTexture(nil, "ARTWORK")
    itemIcon:SetAllPoints()
    itemIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    
    -- Add tooltip to item icon
    itemTexture:SetScript("OnEnter", function(self)
        if Auctionator.currentSellItem then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink(Auctionator.currentSellItem.link)
            GameTooltip:Show()
        end
    end)
    
    itemTexture:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    
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
    
    -- Create the bag view
    self:CreateBagView()
    
    -- Hide the tab by default
    self.sellTabFrame:Hide()
end

-- Create the bag view interface for selling
function Auctionator:CreateBagView()
    -- Right side - Bag items
    local bagViewFrame = CreateFrame("Frame", nil, self.sellTabFrame)
    bagViewFrame:SetPoint("TOPLEFT", self.sellTabFrame, "TOPRIGHT", -265, -5)
    bagViewFrame:SetPoint("BOTTOMRIGHT", self.sellTabFrame, "BOTTOMRIGHT", -5, 5)
    
    -- Bag view heading
    local bagViewHeading = bagViewFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    bagViewHeading:SetPoint("TOPLEFT", bagViewFrame, "TOPLEFT", 5, -5)
    bagViewHeading:SetText("Items in Bags")
    
    -- Create filter row
    local filterFrame = CreateFrame("Frame", nil, bagViewFrame)
    filterFrame:SetPoint("TOPLEFT", bagViewHeading, "BOTTOMLEFT", 0, -10)
    filterFrame:SetPoint("RIGHT", bagViewFrame, "RIGHT", -5, 0)
    filterFrame:SetHeight(25)
    
    local filterLabel = filterFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    filterLabel:SetPoint("TOPLEFT", filterFrame, "TOPLEFT", 5, 0)
    filterLabel:SetText("Filter:")
    
    local filterBox = CreateFrame("EditBox", nil, filterFrame, "SearchBoxTemplate")
    filterBox:SetPoint("LEFT", filterLabel, "RIGHT", 5, 0)
    filterBox:SetPoint("RIGHT", filterFrame, "RIGHT", -5, 0)
    filterBox:SetHeight(20)
    filterBox:SetAutoFocus(false)
    
    filterBox:SetScript("OnTextChanged", function(self)
        Auctionator:UpdateBagView(self:GetText())
    end)
    
    self.bagFilterBox = filterBox
    
    -- Create category filter buttons
    local categoryFrame = CreateFrame("Frame", nil, bagViewFrame)
    categoryFrame:SetPoint("TOPLEFT", filterFrame, "BOTTOMLEFT", 0, -5)
    categoryFrame:SetPoint("RIGHT", bagViewFrame, "RIGHT", -5, 0)
    categoryFrame:SetHeight(25)
    
    local categoryButtons = {}
    local categories = {
        {id = 0, name = "All"},
        {id = 1, name = "Weapons"},
        {id = 2, name = "Armor"},
        {id = 3, name = "Trade Goods"},
        {id = 4, name = "Consumables"}
    }
    
    local buttonWidth = (categoryFrame:GetWidth() / #categories) - 5
    for i, category in ipairs(categories) do
        local button = CreateFrame("Button", nil, categoryFrame)
        button:SetPoint("TOPLEFT", categoryFrame, "TOPLEFT", (i-1) * (buttonWidth + 5), 0)
        button:SetSize(buttonWidth, 20)
        button:SetText(category.name)
        button:SetNormalFontObject("GameFontNormalSmall")
        
        -- Create background
        local bg = button:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0.1, 0.1, 0.1, 0.5)
        
        button.categoryId = category.id
        button.bg = bg
        
        button:SetScript("OnClick", function(self)
            -- Update selected category filter
            Auctionator.selectedBagCategory = self.categoryId
            
            -- Update button visuals
            for _, btn in ipairs(categoryButtons) do
                if btn == self then
                    btn.bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
                    btn:SetNormalFontObject("GameFontHighlightSmall")
                else
                    btn.bg:SetColorTexture(0.1, 0.1, 0.1, 0.5)
                    btn:SetNormalFontObject("GameFontNormalSmall")
                end
            end
            
            -- Update bag display with filter
            Auctionator:UpdateBagView(Auctionator.bagFilterBox:GetText())
        end)
        
        table.insert(categoryButtons, button)
    end
    
    -- Set default selected category
    categoryButtons[1].bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
    categoryButtons[1]:SetNormalFontObject("GameFontHighlightSmall")
    self.selectedBagCategory = 0
    self.categoryButtons = categoryButtons
    
    -- Create scroll frame for bag items
    local scrollFrame = CreateFrame("ScrollFrame", nil, bagViewFrame, "HybridScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", categoryFrame, "BOTTOMLEFT", 0, -5)
    scrollFrame:SetPoint("BOTTOMRIGHT", bagViewFrame, "BOTTOMRIGHT", -30, 5)
    
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollFrame:SetScrollChild(scrollChild)
    scrollChild:SetSize(scrollFrame:GetWidth(), 1) -- Height will be set dynamically
    
    local scrollBar = CreateFrame("Slider", nil, scrollFrame, "HybridScrollBarTemplate")
    scrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", 1, -16)
    scrollBar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", 1, 16)
    scrollFrame.scrollBar = scrollBar
    
    self.bagScrollFrame = scrollFrame
    self.bagScrollChild = scrollChild
    self.bagItemButtons = {}
    
    self.bagViewFrame = bagViewFrame
    
    -- Store bag data for reference
    self.bagItems = {}
    
    -- Allow hiding the bag view
    local toggleBagViewButton = CreateFrame("Button", nil, bagViewFrame, "UIPanelButtonTemplate")
    toggleBagViewButton:SetPoint("BOTTOMRIGHT", bagViewFrame, "BOTTOMRIGHT", -5, 5)
    toggleBagViewButton:SetSize(24, 24)
    toggleBagViewButton:SetText("<")
    
    toggleBagViewButton:SetScript("OnClick", function()
        if bagViewFrame:IsVisible() then
            bagViewFrame:Hide()
            toggleBagViewButton:SetText(">")
            toggleBagViewButton:SetPoint("BOTTOMRIGHT", self.sellTabFrame, "BOTTOMRIGHT", -5, 5)
        else
            bagViewFrame:Show()
            toggleBagViewButton:SetText("<")
            toggleBagViewButton:SetPoint("BOTTOMRIGHT", bagViewFrame, "BOTTOMRIGHT", -5, 5)
        end
    end)
    
    self.toggleBagViewButton = toggleBagViewButton
end

-- Update the bag view with current bag contents
function Auctionator:UpdateBagView(filterText)
    if not self.bagScrollChild then return end
    
    -- Clear the current items in the bag view
    for i, button in ipairs(self.bagItemButtons) do
        button:Hide()
        button:SetParent(nil)
    end
    
    -- Refresh bag content data
    self:ScanBagContents()
    
    -- Filter and display items
    local yOffset = -5
    local itemHeight = 40
    local itemPadding = 5
    local itemsPerRow = 5
    local buttonSize = ((self.bagScrollChild:GetWidth() - (itemsPerRow + 1) * itemPadding) / itemsPerRow)
    
    local filteredItems = {}
    
    -- Apply filters (category and text)
    for i, item in ipairs(self.bagItems) do
        -- Check category filter
        local categoryMatch = (self.selectedBagCategory == 0) or (item.categoryId == self.selectedBagCategory)
        
        -- Check text filter
        local textMatch = true
        if filterText and filterText ~= "" then
            textMatch = item.name:lower():find(filterText:lower()) ~= nil
        end
        
        if categoryMatch and textMatch then
            table.insert(filteredItems, item)
        end
    end
    
    -- Create/update buttons for the filtered items
    local itemCount = #filteredItems
    local xOffset = itemPadding
    local row = 0
    local column = 0
    
    for i, item in ipairs(filteredItems) do
        -- Calculate position
        local x = xOffset + column * (buttonSize + itemPadding)
        local y = yOffset - row * (buttonSize + itemPadding)
        
        -- Get or create button
        local button
        if i <= #self.bagItemButtons then
            button = self.bagItemButtons[i]
        else
            button = CreateFrame("Button", nil, self.bagScrollChild)
            button:SetSize(buttonSize, buttonSize)
            
            -- Create item border
            local border = button:CreateTexture(nil, "OVERLAY")
            border:SetPoint("TOPLEFT", button, "TOPLEFT", -2, 2)
            border:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)
            border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
            border:SetBlendMode("ADD")
            border:SetAlpha(0.8)
            border:Hide()
            
            -- Create item icon
            local icon = button:CreateTexture(nil, "ARTWORK")
            icon:SetAllPoints()
            
            -- Create item count text
            local count = button:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
            count:SetPoint("BOTTOMRIGHT", -2, 2)
            count:SetJustifyH("RIGHT")
            
            -- Create quality overlay
            local quality = button:CreateTexture(nil, "OVERLAY")
            quality:SetPoint("TOPLEFT", button, "TOPLEFT", -1, 1)
            quality:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 1, -1)
            quality:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
            quality:SetBlendMode("ADD")
            quality:SetAlpha(0.5)
            
            button.icon = icon
            button.count = count
            button.border = border
            button.quality = quality
            
            -- Add tooltip
            button:SetScript("OnEnter", function(self)
                if self.link then
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetHyperlink(self.link)
                    GameTooltip:Show()
                end
            end)
            
            button:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)
            
            -- Add click handler to select item
            button:SetScript("OnClick", function(self)
                Auctionator:SelectBagItem(self.bagID, self.slotID)
            end)
            
            table.insert(self.bagItemButtons, button)
        end
        
        -- Update button with item data
        button:SetParent(self.bagScrollChild)
        button:ClearAllPoints()
        button:SetPoint("TOPLEFT", self.bagScrollChild, "TOPLEFT", x, y)
        button:Show()
        
        button.icon:SetTexture(item.texture)
        button.count:SetText(item.count > 1 and item.count or "")
        button.bagID = item.bagID
        button.slotID = item.slotID
        button.link = item.link
        
        -- Color based on quality
        if item.quality and item.quality > 1 then
            local r, g, b = GetItemQualityColor(item.quality)
            button.quality:SetVertexColor(r, g, b)
            button.quality:Show()
        else
            button.quality:Hide()
        end
        
        -- Increment position counters
        column = column + 1
        if column >= itemsPerRow then
            column = 0
            row = row + 1
        end
    end
    
    -- Calculate total height
    local totalRows = math.ceil(itemCount / itemsPerRow)
    local totalHeight = totalRows * (buttonSize + itemPadding) + itemPadding
    
    -- Adjust scroll child height
    self.bagScrollChild:SetHeight(math.max(totalHeight, self.bagScrollFrame:GetHeight()))
end

-- Scan current bag contents
function Auctionator:ScanBagContents()
    self.bagItems = {}
    
    -- Loop through all bags
    for bagID = 0, 4 do
        local slots = GetContainerNumSlots(bagID)
        for slotID = 1, slots do
            local texture, count, locked, quality, readable, lootable, link = GetContainerItemInfo(bagID, slotID)
            
            if texture then
                local name, _, itemQuality, itemLevel, _, itemType, itemSubType, _, equipLoc, _, vendorPrice = GetItemInfo(link)
                
                if name then
                    -- Determine category
                    local categoryId = 0
                    if itemType == "Weapon" then
                        categoryId = 1
                    elseif itemType == "Armor" then
                        categoryId = 2
                    elseif itemType == "Trade Goods" then
                        categoryId = 3
                    elseif itemType == "Consumable" then
                        categoryId = 4
                    end
                    
                    -- Add item to list
                    table.insert(self.bagItems, {
                        name = name,
                        texture = texture,
                        count = count,
                        quality = itemQuality,
                        level = itemLevel,
                        type = itemType,
                        subType = itemSubType,
                        link = link,
                        bagID = bagID,
                        slotID = slotID,
                        categoryId = categoryId
                    })
                end
            end
        end
    end
    
    -- Sort by quality and name
    table.sort(self.bagItems, function(a, b)
        if a.quality == b.quality then
            return a.name < b.name
        else
            return a.quality > b.quality
        end
    end)
end

-- Select an item from bags
function Auctionator:SelectBagItem(bagID, slotID)
    if not bagID or not slotID then return end
    
    local texture, count, locked, quality, readable, lootable, link = GetContainerItemInfo(bagID, slotID)
    
    if not link then return end
    
    local name, _, _, _, _, _, _, stackCount = GetItemInfo(link)
    
    if not name then return end
    
    -- Set the sell item
    self.currentSellItem = {
        name = name,
        texture = texture,
        count = count,
        link = link,
        bagID = bagID,
        slotID = slotID,
        stackCount = stackCount
    }
    
    -- Update the UI
    self.itemIcon:SetTexture(texture)
    self.itemName:SetText(name)
    
    -- Set default stack size (full stack or count if less)
    stackCount = stackCount or 1
    self.stackInput:SetText(math.min(count, stackCount))
    self.quantityInput:SetText("1")
    
    -- Get price data if available
    self:GetPriceData(link)
end

-- Get price data for an item
function Auctionator:GetPriceData(itemLink)
    if not itemLink then return end
    
    local itemID = GetItemInfoInstant(itemLink)
    if not itemID then return end
    
    -- Check if we have price data for this item
    if self.itemPriceData[itemID] then
        local priceData = self.itemPriceData[itemID]
        
        -- Set price suggestion
        if priceData.minBuyout then
            local gold = math.floor(priceData.minBuyout / 10000)
            local silver = math.floor((priceData.minBuyout % 10000) / 100)
            local copper = priceData.minBuyout % 100
            
            -- Apply undercut
            local undercut = VUI.db.profile.modules.auctionator.undercut or 5
            local undercutAmount = math.floor(priceData.minBuyout * (undercut / 100))
            local suggestedPrice = priceData.minBuyout - undercutAmount
            
            -- Format gold/silver/copper
            local sugGold = math.floor(suggestedPrice / 10000)
            local sugSilver = math.floor((suggestedPrice % 10000) / 100)
            local sugCopper = suggestedPrice % 100
            
            -- Set price input fields
            self.goldInput:SetText(sugGold)
            self.silverInput:SetText(sugSilver)
            self.copperInput:SetText(sugCopper)
            
            -- Show price data in the scan section
            self:UpdatePriceScan(itemLink)
        end
    else
        -- No price data, clear the scan section
        self:UpdatePriceScan(itemLink)
    end
end

-- Update the price scan section with current auctions
function Auctionator:UpdatePriceScan(itemLink)
    if not self.scanScrollChild then return end
    
    -- Clear existing entries
    self.scanScrollChild:SetHeight(1)
    for i, child in ipairs({self.scanScrollChild:GetChildren()}) do
        child:Hide()
        child:SetParent(nil)
    end
    
    -- Skip if no item link
    if not itemLink then return end
    
    -- In a real implementation, this would query the auction house API
    -- For now, we'll show a "Loading..." message
    local loadingText = self.scanScrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    loadingText:SetPoint("TOPLEFT", self.scanScrollChild, "TOPLEFT", 10, -10)
    loadingText:SetText("Searching for auctions...")
    
    -- Simulate loading auction data
    C_Timer.After(1.5, function()
        loadingText:Hide()
        
        -- Get item info
        local name, _, quality, iLevel, _, _, subtype, _, _, _, _ = GetItemInfo(itemLink)
        if not name then return end
        
        -- Generate some sample auction data
        local auctions = {}
        local numAuctions = math.random(3, 8)
        local basePrice = 10000 + math.random(1, 5000) -- 1g+ base price
        
        for i = 1, numAuctions do
            -- Random price variation
            local variation = math.random(-1000, 1000)
            local price = basePrice + variation
            
            -- Random stack size
            local stackSize = math.random(1, 5)
            
            -- Random seller name
            local sellers = {"Auctioneer", "Merchant", "Trader", "Goblin", "Vendor", "Broker", "Dealer"}
            local seller = sellers[math.random(1, #sellers)] .. math.random(1, 999)
            
            -- Add auction
            table.insert(auctions, {
                seller = seller,
                stackSize = stackSize,
                buyout = price,
                buyoutPer = math.floor(price / stackSize)
            })
        end
        
        -- Sort by price per item
        table.sort(auctions, function(a, b) return a.buyoutPer < b.buyoutPer end)
        
        -- Display the auctions
        local yOffset = -5
        local itemHeight = 25
        
        -- Add column headers
        local headerFrame = CreateFrame("Frame", nil, self.scanScrollChild)
        headerFrame:SetPoint("TOPLEFT", self.scanScrollChild, "TOPLEFT", 5, yOffset)
        headerFrame:SetPoint("RIGHT", self.scanScrollChild, "RIGHT", -5, 0)
        headerFrame:SetHeight(itemHeight)
        
        local sellerHeader = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        sellerHeader:SetPoint("LEFT", headerFrame, "LEFT", 5, 0)
        sellerHeader:SetWidth(100)
        sellerHeader:SetText("Seller")
        sellerHeader:SetJustifyH("LEFT")
        
        local stackHeader = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        stackHeader:SetPoint("LEFT", sellerHeader, "RIGHT", 5, 0)
        stackHeader:SetWidth(50)
        stackHeader:SetText("Stack")
        stackHeader:SetJustifyH("CENTER")
        
        local buyoutHeader = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        buyoutHeader:SetPoint("LEFT", stackHeader, "RIGHT", 5, 0)
        buyoutHeader:SetWidth(100)
        buyoutHeader:SetText("Buyout")
        buyoutHeader:SetJustifyH("RIGHT")
        
        local perItemHeader = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        perItemHeader:SetPoint("LEFT", buyoutHeader, "RIGHT", 5, 0)
        perItemHeader:SetWidth(100)
        perItemHeader:SetText("Per Item")
        perItemHeader:SetJustifyH("RIGHT")
        
        yOffset = yOffset - itemHeight - 5
        
        -- Create auction listings
        for i, auction in ipairs(auctions) do
            local itemFrame = CreateFrame("Frame", nil, self.scanScrollChild)
            itemFrame:SetPoint("TOPLEFT", self.scanScrollChild, "TOPLEFT", 5, yOffset)
            itemFrame:SetPoint("RIGHT", self.scanScrollChild, "RIGHT", -5, 0)
            itemFrame:SetHeight(itemHeight)
            
            -- Item background
            local bg = itemFrame:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints()
            
            -- Alternate row colors
            if i % 2 == 0 then
                bg:SetColorTexture(0.1, 0.1, 0.1, 0.3)
            else
                bg:SetColorTexture(0.15, 0.15, 0.15, 0.3)
            end
            
            -- Seller text
            local sellerText = itemFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            sellerText:SetPoint("LEFT", itemFrame, "LEFT", 5, 0)
            sellerText:SetWidth(100)
            sellerText:SetText(auction.seller)
            sellerText:SetJustifyH("LEFT")
            
            -- Stack text
            local stackText = itemFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            stackText:SetPoint("LEFT", sellerText, "RIGHT", 5, 0)
            stackText:SetWidth(50)
            stackText:SetText(auction.stackSize)
            stackText:SetJustifyH("CENTER")
            
            -- Buyout text
            local buyoutText = itemFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            buyoutText:SetPoint("LEFT", stackText, "RIGHT", 5, 0)
            buyoutText:SetWidth(100)
            buyoutText:SetText(GetCoinTextureString(auction.buyout))
            buyoutText:SetJustifyH("RIGHT")
            
            -- Per item text
            local perItemText = itemFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            perItemText:SetPoint("LEFT", buyoutText, "RIGHT", 5, 0)
            perItemText:SetWidth(100)
            perItemText:SetText(GetCoinTextureString(auction.buyoutPer))
            perItemText:SetJustifyH("RIGHT")
            
            -- Undercut button (for the lowest price only)
            if i == 1 then
                local undercutButton = CreateFrame("Button", nil, itemFrame, "UIPanelButtonTemplate")
                undercutButton:SetPoint("RIGHT", itemFrame, "RIGHT", -5, 0)
                undercutButton:SetSize(70, 20)
                undercutButton:SetText("Undercut")
                
                undercutButton:SetScript("OnClick", function()
                    -- Apply undercut
                    local undercut = VUI.db.profile.modules.auctionator.undercut or 5
                    local undercutAmount = math.floor(auction.buyoutPer * (undercut / 100))
                    local suggestedPrice = auction.buyoutPer - undercutAmount
                    
                    -- Format gold/silver/copper
                    local sugGold = math.floor(suggestedPrice / 10000)
                    local sugSilver = math.floor((suggestedPrice % 10000) / 100)
                    local sugCopper = suggestedPrice % 100
                    
                    -- Set price input fields
                    Auctionator.goldInput:SetText(sugGold)
                    Auctionator.silverInput:SetText(sugSilver)
                    Auctionator.copperInput:SetText(sugCopper)
                end)
            end
            
            yOffset = yOffset - itemHeight
        end
        
        -- Save minimum price data
        if #auctions > 0 then
            local itemID = GetItemInfoInstant(itemLink)
            if itemID then
                -- Store price data
                Auctionator.itemPriceData[itemID] = {
                    minBuyout = auctions[1].buyoutPer,
                    lastSeen = time(),
                    numAuctions = #auctions
                }
            end
        end
        
        -- Adjust scroll child height
        local totalHeight = math.abs(yOffset) + 5
        Auctionator.scanScrollChild:SetHeight(math.max(totalHeight, Auctionator.scanScrollFrame:GetHeight()))
    end)
end

-- Post an auction to the auction house
function Auctionator:PostAuction()
    if not self.currentSellItem then
        self:Print("No item selected.")
        return
    end
    
    -- Get price
    local gold = tonumber(self.goldInput:GetText()) or 0
    local silver = tonumber(self.silverInput:GetText()) or 0
    local copper = tonumber(self.copperInput:GetText()) or 0
    
    local price = gold * 10000 + silver * 100 + copper
    
    if price <= 0 then
        self:Print("Please enter a valid price.")
        return
    end
    
    -- Get stack size and quantity
    local stackSize = tonumber(self.stackInput:GetText()) or 1
    local quantity = tonumber(self.quantityInput:GetText()) or 1
    
    if stackSize <= 0 or quantity <= 0 then
        self:Print("Please enter valid stack size and quantity.")
        return
    end
    
    -- In a real implementation, this would use AuctionHouseFrame API
    -- For now, just show a message
    self:Print("Posting " .. quantity .. " stack(s) of " .. stackSize .. " " .. self.currentSellItem.name .. " for " .. GetCoinTextureString(price) .. " each.")
    
    -- Remember item settings if enabled
    if VUI.db.profile.modules.auctionator.rememberLastSellSettings then
        local itemID = GetItemInfoInstant(self.currentSellItem.link)
        if itemID then
            if not self.lastSellSettings then self.lastSellSettings = {} end
            self.lastSellSettings[itemID] = {
                stackSize = stackSize,
                price = price,
                duration = self.selectedDuration
            }
        end
    end
end

-- Print a message
function Auctionator:Print(msg)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF33FF99VUI Auctionator|r: " .. (msg or ""))
    end
end

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
end

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
end

-- Event handlers
function Auctionator:AUCTION_HOUSE_SHOW()
    -- Auction house opened
    if VUI.db.profile.modules.auctionator.autoscan then
        self:PerformFullScan()
    end
end

function Auctionator:AUCTION_HOUSE_CLOSED()
    -- Auction house closed, save any data if needed
    self:SaveAuctionData()
end

function Auctionator:PLAYER_ENTERING_WORLD()
    -- Load saved data
    if VUI.charDB and VUI.charDB.profile.modules.auctionator then
        self.favorites = VUI.charDB.profile.modules.auctionator.favorites or {}
        self.recentSearches = VUI.charDB.profile.modules.auctionator.recentSearches or {}
        self.lastScan = VUI.charDB.profile.modules.auctionator.lastScan or 0
    end
end

function Auctionator:PLAYER_LOGOUT()
    -- Save data before logout
    if VUI.charDB then
        VUI.charDB.profile.modules.auctionator = VUI.charDB.profile.modules.auctionator or {}
        
        -- Save basic search data
        VUI.charDB.profile.modules.auctionator.favorites = self.favorites or {}
        VUI.charDB.profile.modules.auctionator.recentSearches = self.recentSearches or {}
        VUI.charDB.profile.modules.auctionator.lastScan = self.lastScan or 0
        
        -- Save shopping lists
        VUI.charDB.profile.modules.auctionator.shoppingLists = self.shoppingLists or {}
        
        -- Save price data (limit to recent and reasonable size)
        local prunedPriceData = {}
        local currentTime = time()
        local maxAge = 60 * 60 * 24 * 30 -- 30 days
        local count = 0
        local maxItems = 1000 -- Limit to 1000 items to prevent database bloat
        
        for itemID, data in pairs(self.itemPriceData or {}) do
            if currentTime - (data.lastSeen or 0) < maxAge and count < maxItems then
                prunedPriceData[itemID] = data
                count = count + 1
            end
        end
        
        VUI.charDB.profile.modules.auctionator.itemPriceData = prunedPriceData
        
        -- Save last sell settings
        VUI.charDB.profile.modules.auctionator.lastSellSettings = self.lastSellSettings or {}
    end
end

-- Module enable/disable functions
function Auctionator:Enable()
    -- Enable event processing
    self:RegisterEvent("AUCTION_HOUSE_SHOW", self.AUCTION_HOUSE_SHOW)
    self:RegisterEvent("AUCTION_HOUSE_CLOSED", self.AUCTION_HOUSE_CLOSED)
    self:RegisterEvent("PLAYER_ENTERING_WORLD", self.PLAYER_ENTERING_WORLD)
    self:RegisterEvent("PLAYER_LOGOUT", self.PLAYER_LOGOUT)
    
    -- Module enabled
end

function Auctionator:Disable()
    -- Unregister events
    self:UnregisterEvent("AUCTION_HOUSE_SHOW")
    self:UnregisterEvent("AUCTION_HOUSE_CLOSED")
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    self:UnregisterEvent("PLAYER_LOGOUT")
    
    -- Module disabled
end

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
end

function Auctionator:UnregisterEvent(event)
    if self.eventFrame and self.eventFrame.events[event] then
        self.eventFrame:UnregisterEvent(event)
        self.eventFrame.events[event] = nil
    end
end

-- Update settings
function Auctionator:UpdateSettings()
    -- Apply settings
    if self.currentTab and self.tabButtons then
        self:SwitchTab(VUI.db.profile.modules.auctionator.defaultTab or "search")
    end
end

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
end
