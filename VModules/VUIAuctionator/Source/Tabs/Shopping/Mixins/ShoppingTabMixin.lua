local addonName, VUI = ...
local Auctionator = VUI.Auctionator

AuctionatorShoppingTabMixin = CreateFromMixins(AuctionatorTabMixin)

function AuctionatorShoppingTabMixin:OnLoad()
  -- Apply VUI theme if available
  if VUI.ApplyThemeColor then
    if self.Background then
      VUI:ApplyThemeColor(self.Background, 0.2)
    end
    
    if self.Border then
      VUI:ApplyThemeColor(self.Border)
    end
    
    -- Apply theme to buttons
    VUI:ApplyThemeColor(self.ShoppingLists.NewButton)
    VUI:ApplyThemeColor(self.ShoppingLists.RenameButton)
    VUI:ApplyThemeColor(self.ShoppingLists.DeleteButton)
    VUI:ApplyThemeColor(self.ShoppingLists.AddItemButton)
    VUI:ApplyThemeColor(self.ResultsListing.SearchButton)
    VUI:ApplyThemeColor(self.ResultsListing.BuyButton)
  end
  
  -- Setup shopping lists dropdown
  self:SetupListsDropdown()
  
  -- Initialize shopping list data
  self:InitializeShoppingLists()
  
  -- Setup the results listing
  self:SetupResultsListing()
  
  -- Register for events
  self:RegisterEvents()
  
  -- Set up button handlers
  self:SetupButtonHandlers()
end

function AuctionatorShoppingTabMixin:RegisterEvents()
  -- Register for auction events
  self:RegisterTabEvent("AUCTION_HOUSE_BROWSE_RESULTS_UPDATED")
  self:RegisterTabEvent("AUCTION_HOUSE_BROWSE_RESULTS_ADDED")
  self:RegisterTabEvent("AUCTION_HOUSE_BROWSE_FAILURE")
  self:RegisterTabEvent("ITEM_SEARCH_RESULTS_UPDATED")
  self:RegisterTabEvent("COMMODITY_SEARCH_RESULTS_UPDATED")
end

function AuctionatorShoppingTabMixin:OnShow()
  -- Load the saved shopping lists
  self:LoadShoppingLists()
  
  -- Update UI
  self:UpdateListDisplay()
end

function AuctionatorShoppingTabMixin:OnEvent(eventName, ...)
  if eventName == "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED" then
    self:OnBrowseResultsUpdated(...)
  elseif eventName == "AUCTION_HOUSE_BROWSE_RESULTS_ADDED" then
    self:OnBrowseResultsAdded(...)
  elseif eventName == "AUCTION_HOUSE_BROWSE_FAILURE" then
    self:OnBrowseFailure(...)
  elseif eventName == "ITEM_SEARCH_RESULTS_UPDATED" then
    self:OnItemSearchResultsUpdated(...)
  elseif eventName == "COMMODITY_SEARCH_RESULTS_UPDATED" then
    self:OnCommoditySearchResultsUpdated(...)
  end
end

function AuctionatorShoppingTabMixin:SetupButtonHandlers()
  -- Shopping list management buttons
  self.ShoppingLists.NewButton:SetScript("OnClick", function()
    self:OnNewListClicked()
  end)
  
  self.ShoppingLists.RenameButton:SetScript("OnClick", function()
    self:OnRenameListClicked()
  end)
  
  self.ShoppingLists.DeleteButton:SetScript("OnClick", function()
    self:OnDeleteListClicked()
  end)
  
  self.ShoppingLists.AddItemButton:SetScript("OnClick", function()
    self:OnAddItemClicked()
  end)
  
  -- Search box
  self.ShoppingLists.SearchBox:SetScript("OnEnterPressed", function()
    self:OnAddItemClicked()
  end)
  
  -- Search button
  self.ResultsListing.SearchButton:SetScript("OnClick", function()
    self:OnSearchClicked()
  end)
  
  -- Buy button
  self.ResultsListing.BuyButton:SetScript("OnClick", function()
    self:OnBuyButtonClicked()
  end)
end

function AuctionatorShoppingTabMixin:SetupListsDropdown()
  if not self.ShoppingLists.ListDropDown then return end
  
  UIDropDownMenu_Initialize(self.ShoppingLists.ListDropDown, function(dropdown, level)
    local lists = Auctionator.Database.GetShoppingLists() or {}
    
    for i, listName in ipairs(lists) do
      local info = UIDropDownMenu_CreateInfo()
      info.text = listName
      info.value = i
      info.func = function(self)
        UIDropDownMenu_SetSelectedValue(dropdown, self.value)
        -- Update displayed items
        AuctionatorShoppingTabMixin:LoadListItems(self.value)
      end
      UIDropDownMenu_AddButton(info, level)
    end
  end)
  
  UIDropDownMenu_SetWidth(self.ShoppingLists.ListDropDown, 170)
  UIDropDownMenu_JustifyText(self.ShoppingLists.ListDropDown, "LEFT")
end

function AuctionatorShoppingTabMixin:InitializeShoppingLists()
  -- Initialize the shopping lists DB if needed
  if Auctionator.Database and not Auctionator.Database.ShoppingListsInitialized then
    if not Auctionator.Database.GetShoppingLists or not Auctionator.Database.SaveShoppingLists then
      -- Set up shopping list storage functions
      Auctionator.Database.GetShoppingLists = function()
        if not VUI.db.global.auctionator then
          VUI.db.global.auctionator = {}
        end
        if not VUI.db.global.auctionator.shoppingLists then
          VUI.db.global.auctionator.shoppingLists = {
            ["Default"] = {}
          }
        end
        
        local lists = {}
        for listName, _ in pairs(VUI.db.global.auctionator.shoppingLists) do
          table.insert(lists, listName)
        end
        
        return lists
      end
      
      Auctionator.Database.GetShoppingListItems = function(listName)
        if not VUI.db.global.auctionator or not VUI.db.global.auctionator.shoppingLists or not VUI.db.global.auctionator.shoppingLists[listName] then
          return {}
        end
        
        return VUI.db.global.auctionator.shoppingLists[listName]
      end
      
      Auctionator.Database.SaveShoppingList = function(listName, items)
        if not VUI.db.global.auctionator then
          VUI.db.global.auctionator = {}
        end
        if not VUI.db.global.auctionator.shoppingLists then
          VUI.db.global.auctionator.shoppingLists = {}
        end
        
        VUI.db.global.auctionator.shoppingLists[listName] = items
      end
      
      Auctionator.Database.DeleteShoppingList = function(listName)
        if not VUI.db.global.auctionator or not VUI.db.global.auctionator.shoppingLists then
          return
        end
        
        VUI.db.global.auctionator.shoppingLists[listName] = nil
      end
      
      Auctionator.Database.RenameShoppingList = function(oldName, newName)
        if not VUI.db.global.auctionator or not VUI.db.global.auctionator.shoppingLists or not VUI.db.global.auctionator.shoppingLists[oldName] then
          return false
        end
        
        if VUI.db.global.auctionator.shoppingLists[newName] then
          -- List with new name already exists
          return false
        end
        
        VUI.db.global.auctionator.shoppingLists[newName] = VUI.db.global.auctionator.shoppingLists[oldName]
        VUI.db.global.auctionator.shoppingLists[oldName] = nil
        
        return true
      end
    end
    
    Auctionator.Database.ShoppingListsInitialized = true
  end
  
  -- Create default list if no lists exist
  local lists = Auctionator.Database.GetShoppingLists() or {}
  if #lists == 0 then
    Auctionator.Database.SaveShoppingList("Default", {})
  end
end

function AuctionatorShoppingTabMixin:LoadShoppingLists()
  -- Load lists into dropdown
  UIDropDownMenu_Initialize(self.ShoppingLists.ListDropDown, function(dropdown, level)
    local lists = Auctionator.Database.GetShoppingLists() or {}
    
    for i, listName in ipairs(lists) do
      local info = UIDropDownMenu_CreateInfo()
      info.text = listName
      info.value = listName
      info.func = function(self)
        UIDropDownMenu_SetSelectedValue(dropdown, self.value)
        -- Update displayed items
        AuctionatorShoppingTabMixin:LoadListItems(self.value)
      end
      UIDropDownMenu_AddButton(info, level)
    end
  end)
  
  -- Select first list
  local lists = Auctionator.Database.GetShoppingLists() or {}
  if #lists > 0 then
    UIDropDownMenu_SetSelectedValue(self.ShoppingLists.ListDropDown, lists[1])
    self:LoadListItems(lists[1])
  end
end

function AuctionatorShoppingTabMixin:LoadListItems(listName)
  if not listName then return end
  
  -- Clear current items
  self.currentListItems = {}
  
  -- Load items from DB
  local items = Auctionator.Database.GetShoppingListItems(listName) or {}
  self.currentListItems = items
  
  -- Update display
  self:UpdateListDisplay()
end

function AuctionatorShoppingTabMixin:UpdateListDisplay()
  -- Create scroll list of items if it doesn't exist
  if not self.listItemFrames then
    self.listItemFrames = {}
  end
  
  -- Clear existing frames
  for _, frame in ipairs(self.listItemFrames) do
    frame:Hide()
    frame:ClearAllPoints()
  end
  
  -- Create frames for each item
  local previousFrame = nil
  local scrollChild = self.ShoppingLists.ScrollFrame.scrollChild
  
  for i, item in ipairs(self.currentListItems) do
    local frame = self.listItemFrames[i]
    if not frame then
      frame = CreateFrame("Button", nil, scrollChild)
      frame:SetSize(170, 20)
      
      frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
      frame.text:SetPoint("LEFT", 5, 0)
      frame.text:SetPoint("RIGHT", -5, 0)
      frame.text:SetJustifyH("LEFT")
      
      frame:SetScript("OnClick", function()
        self:SelectListItem(i)
      end)
      
      frame:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
      
      self.listItemFrames[i] = frame
    end
    
    frame.text:SetText(item.searchTerm or item.itemLink or "Unknown")
    
    if previousFrame then
      frame:SetPoint("TOPLEFT", previousFrame, "BOTTOMLEFT", 0, -2)
    else
      frame:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 5, -5)
    end
    
    frame:Show()
    previousFrame = frame
  end
  
  -- Update content height
  scrollChild:SetSize(170, #self.currentListItems * 22 + 10)
end

function AuctionatorShoppingTabMixin:SetupResultsListing()
  -- Initialize the results list
  self.resultFrames = {}
  self.searchResults = {}
  
  -- Disable buy button until an item is selected
  self.ResultsListing.BuyButton:Disable()
end

function AuctionatorShoppingTabMixin:OnSearchClicked()
  -- Get currently selected list item
  if not self.selectedItemIndex or not self.currentListItems or not self.currentListItems[self.selectedItemIndex] then
    return
  end
  
  local item = self.currentListItems[self.selectedItemIndex]
  local searchTerm = item.searchTerm or ""
  
  -- Clear previous results
  self.searchResults = {}
  self:UpdateResultsDisplay()
  
  -- Show searching indicator
  self.ResultsListing.Title:SetText("Searching...")
  
  -- Start the search
  if item.itemLink then
    -- Search for specific item
    C_AuctionHouse.SearchForItem(item.itemLink)
  else
    -- Search by text
    C_AuctionHouse.SendBrowseQuery({
      searchString = searchTerm,
      minLevel = 0,
      maxLevel = 0,
    })
  end
end

function AuctionatorShoppingTabMixin:OnBrowseResultsUpdated()
  local numResults = C_AuctionHouse.GetNumBrowseResults()
  self.searchResults = {}
  
  for i = 1, numResults do
    local result = C_AuctionHouse.GetBrowseResultInfo(i)
    if result then
      table.insert(self.searchResults, result)
    end
  end
  
  self.ResultsListing.Title:SetText(string.format("Search Results (%d)", #self.searchResults))
  self:UpdateResultsDisplay()
end

function AuctionatorShoppingTabMixin:OnBrowseResultsAdded()
  local numResults = C_AuctionHouse.GetNumBrowseResults()
  
  for i = #self.searchResults + 1, numResults do
    local result = C_AuctionHouse.GetBrowseResultInfo(i)
    if result then
      table.insert(self.searchResults, result)
    end
  end
  
  self.ResultsListing.Title:SetText(string.format("Search Results (%d)", #self.searchResults))
  self:UpdateResultsDisplay()
end

function AuctionatorShoppingTabMixin:OnBrowseFailure()
  self.ResultsListing.Title:SetText("Search Failed")
end

function AuctionatorShoppingTabMixin:OnItemSearchResultsUpdated(itemKey)
  -- Get specific item results
  local numResults = C_AuctionHouse.GetNumItemSearchResults(itemKey)
  self.searchResults = {}
  
  for i = 1, numResults do
    local result = C_AuctionHouse.GetItemSearchResultInfo(itemKey, i)
    if result then
      result.itemKey = itemKey
      result.isItem = true
      table.insert(self.searchResults, result)
    end
  end
  
  self.ResultsListing.Title:SetText(string.format("Search Results (%d)", #self.searchResults))
  self:UpdateResultsDisplay()
end

function AuctionatorShoppingTabMixin:OnCommoditySearchResultsUpdated(itemID)
  -- Get commodity results
  local numResults = C_AuctionHouse.GetNumCommoditySearchResults(itemID)
  self.searchResults = {}
  
  for i = 1, numResults do
    local result = C_AuctionHouse.GetCommoditySearchResultInfo(itemID, i)
    if result then
      result.itemID = itemID
      result.isCommodity = true
      table.insert(self.searchResults, result)
    end
  end
  
  self.ResultsListing.Title:SetText(string.format("Search Results (%d)", #self.searchResults))
  self:UpdateResultsDisplay()
end

function AuctionatorShoppingTabMixin:UpdateResultsDisplay()
  -- Create frames if needed
  if not self.resultFrames then
    self.resultFrames = {}
  end
  
  -- Clear existing frames
  for _, frame in ipairs(self.resultFrames) do
    frame:Hide()
    frame:ClearAllPoints()
  end
  
  -- Create frames for each result
  local previousFrame = nil
  local scrollChild = self.ResultsListing.ScrollFrame.scrollChild
  
  for i, result in ipairs(self.searchResults) do
    local frame = self.resultFrames[i]
    if not frame then
      frame = CreateFrame("Button", nil, scrollChild)
      frame:SetSize(290, 20)
      
      -- Item name text
      frame.nameText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
      frame.nameText:SetPoint("LEFT", 5, 0)
      frame.nameText:SetSize(140, 20)
      frame.nameText:SetJustifyH("LEFT")
      
      -- Quantity text
      frame.quantityText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
      frame.quantityText:SetPoint("LEFT", frame.nameText, "RIGHT", 10, 0)
      frame.quantityText:SetSize(30, 20)
      frame.quantityText:SetJustifyH("RIGHT")
      
      -- Price text
      frame.priceText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
      frame.priceText:SetPoint("LEFT", frame.quantityText, "RIGHT", 10, 0)
      frame.priceText:SetPoint("RIGHT", frame, "RIGHT", -5, 0)
      frame.priceText:SetJustifyH("RIGHT")
      
      frame:SetScript("OnClick", function()
        self:SelectResult(i)
      end)
      
      frame:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
      
      self.resultFrames[i] = frame
    end
    
    -- Set item name
    local itemName = result.itemLink or "Unknown Item"
    if result.itemKey then
      itemName = C_AuctionHouse.GetItemKeyInfo(result.itemKey).itemName or "Unknown Item"
    elseif result.itemID then
      local itemInfo = C_Item.GetItemInfo(result.itemID)
      itemName = itemInfo and itemInfo.name or "Unknown Item"
    end
    frame.nameText:SetText(itemName)
    
    -- Set quantity
    frame.quantityText:SetText(result.quantity or 1)
    
    -- Set price
    local price = result.minPrice or result.unitPrice or 0
    frame.priceText:SetText(Auctionator.Utilities.FormatMoney(price))
    
    -- Position the frame
    if previousFrame then
      frame:SetPoint("TOPLEFT", previousFrame, "BOTTOMLEFT", 0, -2)
    else
      frame:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 5, -5)
    end
    
    frame:Show()
    previousFrame = frame
  end
  
  -- Update content height
  scrollChild:SetSize(290, #self.searchResults * 22 + 10)
end

function AuctionatorShoppingTabMixin:SelectListItem(index)
  -- Clear previous selection
  if self.selectedItemIndex and self.listItemFrames[self.selectedItemIndex] then
    local frame = self.listItemFrames[self.selectedItemIndex]
    frame:UnlockHighlight()
  end
  
  -- Set new selection
  self.selectedItemIndex = index
  
  if self.listItemFrames[index] then
    local frame = self.listItemFrames[index]
    frame:LockHighlight()
  end
end

function AuctionatorShoppingTabMixin:SelectResult(index)
  -- Clear previous selection
  if self.selectedResultIndex and self.resultFrames[self.selectedResultIndex] then
    local frame = self.resultFrames[self.selectedResultIndex]
    frame:UnlockHighlight()
  end
  
  -- Set new selection
  self.selectedResultIndex = index
  
  if self.resultFrames[index] then
    local frame = self.resultFrames[index]
    frame:LockHighlight()
    
    -- Enable buy button
    self.ResultsListing.BuyButton:Enable()
  end
end

function AuctionatorShoppingTabMixin:OnBuyButtonClicked()
  if not self.selectedResultIndex or not self.searchResults[self.selectedResultIndex] then
    return
  end
  
  local result = self.searchResults[self.selectedResultIndex]
  
  if result.isCommodity then
    -- Buy commodity
    C_AuctionHouse.StartCommodityPurchase(result.itemID, result.quantity)
  elseif result.isItem then
    -- Buy item
    C_AuctionHouse.PlaceBid(result.itemKey, result.auctionID, result.minPrice)
  end
end

function AuctionatorShoppingTabMixin:OnNewListClicked()
  -- Show prompt for new list name
  StaticPopupDialogs["NEW_SHOPPING_LIST"] = StaticPopupDialogs["NEW_SHOPPING_LIST"] or {
    text = "Enter a name for the new shopping list:",
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = true,
    maxLetters = 32,
    OnAccept = function(self)
      local listName = self.editBox:GetText()
      if listName and listName ~= "" then
        -- Create new list
        Auctionator.Database.SaveShoppingList(listName, {})
        -- Refresh lists
        AuctionatorShoppingTabMixin:LoadShoppingLists()
        -- Select the new list
        UIDropDownMenu_SetSelectedValue(AuctionatorShoppingTabMixin.ShoppingLists.ListDropDown, listName)
        AuctionatorShoppingTabMixin:LoadListItems(listName)
      end
    end,
    OnShow = function(self)
      self.editBox:SetFocus()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
  }
  
  StaticPopup_Show("NEW_SHOPPING_LIST")
end

function AuctionatorShoppingTabMixin:OnRenameListClicked()
  local currentList = UIDropDownMenu_GetSelectedValue(self.ShoppingLists.ListDropDown)
  if not currentList then return end
  
  -- Show prompt for new list name
  StaticPopupDialogs["RENAME_SHOPPING_LIST"] = StaticPopupDialogs["RENAME_SHOPPING_LIST"] or {
    text = "Enter a new name for '%s':",
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = true,
    maxLetters = 32,
    OnAccept = function(self)
      local newName = self.editBox:GetText()
      if newName and newName ~= "" then
        -- Rename list
        Auctionator.Database.RenameShoppingList(currentList, newName)
        -- Refresh lists
        AuctionatorShoppingTabMixin:LoadShoppingLists()
        -- Select the renamed list
        UIDropDownMenu_SetSelectedValue(AuctionatorShoppingTabMixin.ShoppingLists.ListDropDown, newName)
        AuctionatorShoppingTabMixin:LoadListItems(newName)
      end
    end,
    OnShow = function(self)
      self.editBox:SetFocus()
      self.editBox:SetText(currentList)
      self.editBox:HighlightText()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
  }
  
  StaticPopup_Show("RENAME_SHOPPING_LIST", currentList)
end

function AuctionatorShoppingTabMixin:OnDeleteListClicked()
  local currentList = UIDropDownMenu_GetSelectedValue(self.ShoppingLists.ListDropDown)
  if not currentList then return end
  
  -- Show confirmation dialog
  StaticPopupDialogs["DELETE_SHOPPING_LIST"] = StaticPopupDialogs["DELETE_SHOPPING_LIST"] or {
    text = "Are you sure you want to delete the shopping list '%s'?",
    button1 = ACCEPT,
    button2 = CANCEL,
    OnAccept = function()
      -- Delete list
      Auctionator.Database.DeleteShoppingList(currentList)
      -- Refresh lists
      AuctionatorShoppingTabMixin:LoadShoppingLists()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
  }
  
  StaticPopup_Show("DELETE_SHOPPING_LIST", currentList)
end

function AuctionatorShoppingTabMixin:OnAddItemClicked()
  local currentList = UIDropDownMenu_GetSelectedValue(self.ShoppingLists.ListDropDown)
  if not currentList then return end
  
  local searchText = self.ShoppingLists.SearchBox:GetText()
  if not searchText or searchText == "" then return end
  
  -- Add item to list
  local items = Auctionator.Database.GetShoppingListItems(currentList) or {}
  table.insert(items, {searchTerm = searchText})
  Auctionator.Database.SaveShoppingList(currentList, items)
  
  -- Clear search box
  self.ShoppingLists.SearchBox:SetText("")
  
  -- Refresh list
  self:LoadListItems(currentList)
end

-- Expose the mixin globally for XML template use
Auctionator.Tabs.Shopping = {
  Mixin = AuctionatorShoppingTabMixin,
  Template = "AuctionatorShoppingTabFrameTemplate",
} 