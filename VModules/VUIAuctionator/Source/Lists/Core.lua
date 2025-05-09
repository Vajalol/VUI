local addonName, VUI = ...
local Auctionator = VUI.Auctionator

-- Create the Lists module
Auctionator.Lists = {
  -- All shopping lists
  shoppingLists = {},
  
  -- Currently selected list
  currentList = nil,
  
  -- Event constants
  Events = {
    LIST_CREATED = "list_created",
    LIST_DELETED = "list_deleted",
    LIST_UPDATED = "list_updated",
    LIST_SELECTED = "list_selected",
    ITEM_ADDED = "list_item_added",
    ITEM_REMOVED = "list_item_removed",
    ITEM_SELECTED = "list_item_selected",
    SEARCH_REQUESTED = "list_search_requested"
  }
}

-- Initialize the lists module
function Auctionator.Lists:Initialize()
  -- Load saved lists
  self:LoadLists()
  
  -- Setup events
  self:SetupEvents()
end

-- Set up event handlers
function Auctionator.Lists:SetupEvents()
  -- Additional event handlers would be added here as needed
  -- They would connect this module to UI events and other modules
end

-- Load saved shopping lists
function Auctionator.Lists:LoadLists()
  -- Ensure VUI_SavedVariables.VUIAuctionatorLists exists
  if not VUI_SavedVariables.VUIAuctionatorLists then
    VUI_SavedVariables.VUIAuctionatorLists = {}
  end
  
  -- Load from SavedVariables
  self.shoppingLists = VUI_SavedVariables.VUIAuctionatorLists
  
  -- If no lists exist, create a default one
  if #self.shoppingLists == 0 then
    self:CreateList(Auctionator.L.DEFAULT_LIST_NAME)
  end
  
  -- Set current list to first list
  self.currentList = self.shoppingLists[1]
end

-- Save shopping lists
function Auctionator.Lists:SaveLists()
  VUI_SavedVariables.VUIAuctionatorLists = self.shoppingLists
end

-- Create a new shopping list
function Auctionator.Lists:CreateList(name)
  if not name or name == "" then
    name = Auctionator.L.DEFAULT_LIST_NAME
  end
  
  -- Create the list
  local list = {
    name = name,
    items = {},
    itemIDs = {}, -- For quick lookups
    createdAt = time(),
    lastModified = time()
  }
  
  -- Add to lists
  table.insert(self.shoppingLists, list)
  
  -- Save
  self:SaveLists()
  
  -- Fire event
  Auctionator.EventBus:Fire({}, self.Events.LIST_CREATED, list)
  
  return list
end

-- Delete a shopping list
function Auctionator.Lists:DeleteList(listIndex)
  if not listIndex or listIndex <= 0 or listIndex > #self.shoppingLists then
    return false
  end
  
  -- Get the list being deleted
  local list = self.shoppingLists[listIndex]
  
  -- Remove the list
  table.remove(self.shoppingLists, listIndex)
  
  -- If the deleted list was the current one, select a different one
  if self.currentList == list then
    if #self.shoppingLists > 0 then
      self.currentList = self.shoppingLists[1]
    else
      self.currentList = nil
    end
  end
  
  -- Save
  self:SaveLists()
  
  -- Fire events
  Auctionator.EventBus:Fire({}, self.Events.LIST_DELETED, list)
  
  if self.currentList then
    Auctionator.EventBus:Fire({}, self.Events.LIST_SELECTED, self.currentList)
  end
  
  return true
end

-- Select a list
function Auctionator.Lists:SelectList(listIndex)
  if not listIndex or listIndex <= 0 or listIndex > #self.shoppingLists then
    return false
  end
  
  -- Set as current list
  self.currentList = self.shoppingLists[listIndex]
  
  -- Fire event
  Auctionator.EventBus:Fire({}, self.Events.LIST_SELECTED, self.currentList)
  
  return true
end

-- Add an item to a list
function Auctionator.Lists:AddItem(listIndex, itemInfo)
  if not listIndex or listIndex <= 0 or listIndex > #self.shoppingLists then
    return false
  end
  
  local list = self.shoppingLists[listIndex]
  
  -- Extract item info
  local itemID, itemLink, searchTerm
  
  if type(itemInfo) == "string" then
    -- Could be an item link or a search term
    if itemInfo:match("|H") then
      -- It's an item link
      itemLink = itemInfo
      itemID = Auctionator.Utilities.ItemInfo.GetItemID(itemLink)
      searchTerm = Auctionator.Utilities.ItemInfo.GetItemName(itemLink)
    else
      -- It's a search term
      searchTerm = itemInfo
    end
  elseif type(itemInfo) == "number" then
    -- It's an itemID
    itemID = itemInfo
    itemLink = Auctionator.Utilities.GetItemLinkFromID(itemID)
    
    if itemLink then
      searchTerm = Auctionator.Utilities.ItemInfo.GetItemName(itemLink)
    else
      searchTerm = tostring(itemID)
    end
  end
  
  -- If the item is already in the list, don't add it again
  if itemID and list.itemIDs[itemID] then
    return false
  end
  
  -- Create the item entry
  local item = {
    id = itemID,
    link = itemLink,
    searchTerm = searchTerm,
    addedAt = time(),
    notes = ""
  }
  
  -- Add to the list
  table.insert(list.items, item)
  
  -- Add to ID lookup if we have an ID
  if itemID then
    list.itemIDs[itemID] = true
  end
  
  -- Update modification time
  list.lastModified = time()
  
  -- Save
  self:SaveLists()
  
  -- Fire event
  Auctionator.EventBus:Fire({}, self.Events.ITEM_ADDED, list, item)
  Auctionator.EventBus:Fire({}, self.Events.LIST_UPDATED, list)
  
  return true
end

-- Remove an item from a list
function Auctionator.Lists:RemoveItem(listIndex, itemIndex)
  if not listIndex or listIndex <= 0 or listIndex > #self.shoppingLists then
    return false
  end
  
  local list = self.shoppingLists[listIndex]
  
  if not itemIndex or itemIndex <= 0 or itemIndex > #list.items then
    return false
  end
  
  -- Get the item being removed
  local item = list.items[itemIndex]
  
  -- Remove from ID lookup if we have an ID
  if item.id then
    list.itemIDs[item.id] = nil
  end
  
  -- Remove the item
  table.remove(list.items, itemIndex)
  
  -- Update modification time
  list.lastModified = time()
  
  -- Save
  self:SaveLists()
  
  -- Fire event
  Auctionator.EventBus:Fire({}, self.Events.ITEM_REMOVED, list, item)
  Auctionator.EventBus:Fire({}, self.Events.LIST_UPDATED, list)
  
  return true
end

-- Search for an item from a list
function Auctionator.Lists:SearchForItem(listIndex, itemIndex, callback)
  if not listIndex or listIndex <= 0 or listIndex > #self.shoppingLists then
    return false
  end
  
  local list = self.shoppingLists[listIndex]
  
  if not itemIndex or itemIndex <= 0 or itemIndex > #list.items then
    return false
  end
  
  -- Get the item
  local item = list.items[itemIndex]
  
  -- Fire event
  Auctionator.EventBus:Fire({}, self.Events.ITEM_SELECTED, list, item)
  Auctionator.EventBus:Fire({}, self.Events.SEARCH_REQUESTED, list, item)
  
  -- Start the search if the auction house is open
  if Auctionator.AuctionHouse:IsOpen() then
    if Auctionator.Search then
      local searchText = item.searchTerm
      
      Auctionator.Search:StartSearch(searchText, true, function(results)
        -- Call the original callback if provided
        if callback then
          callback(results)
        end
      end)
    end
  else
    Auctionator.Utilities.Message.Error(Auctionator.L.ERR_AUCTION_HOUSE_CLOSED)
    
    -- Call the callback with an error if provided
    if callback then
      callback({
        success = false,
        error = Auctionator.L.ERR_AUCTION_HOUSE_CLOSED
      })
    end
  end
  
  return true
end

-- Rename a list
function Auctionator.Lists:RenameList(listIndex, newName)
  if not listIndex or listIndex <= 0 or listIndex > #self.shoppingLists then
    return false
  end
  
  if not newName or newName == "" then
    return false
  end
  
  -- Update the name
  self.shoppingLists[listIndex].name = newName
  self.shoppingLists[listIndex].lastModified = time()
  
  -- Save
  self:SaveLists()
  
  -- Fire event
  Auctionator.EventBus:Fire({}, self.Events.LIST_UPDATED, self.shoppingLists[listIndex])
  
  return true
end

-- Get a list by index
function Auctionator.Lists:GetList(listIndex)
  if not listIndex or listIndex <= 0 or listIndex > #self.shoppingLists then
    return nil
  end
  
  return self.shoppingLists[listIndex]
end

-- Get current list
function Auctionator.Lists:GetCurrentList()
  return self.currentList
end

-- Get all lists
function Auctionator.Lists:GetAllLists()
  return self.shoppingLists
end

-- Import a list from a formatted string
function Auctionator.Lists:ImportList(importString, listName)
  if not importString or importString == "" then
    return false
  end
  
  if not listName or listName == "" then
    listName = Auctionator.L.IMPORTED_LIST_NAME
  end
  
  -- Create a new list
  local list = self:CreateList(listName)
  local listIndex = #self.shoppingLists
  
  -- Split the import string by lines
  local lines = {}
  for line in importString:gmatch("[^\r\n]+") do
    table.insert(lines, line)
  end
  
  -- Process each line
  local itemsAdded = 0
  for _, line in ipairs(lines) do
    -- Clean up the line
    line = line:trim()
    
    if line ~= "" then
      -- Try to add the item (could be a link or a search term)
      if self:AddItem(listIndex, line) then
        itemsAdded = itemsAdded + 1
      end
    end
  end
  
  -- If no items were added, delete the list
  if itemsAdded == 0 then
    self:DeleteList(listIndex)
    return false
  end
  
  -- Select the new list
  self:SelectList(listIndex)
  
  return true, itemsAdded
end

-- Export a list to a formatted string
function Auctionator.Lists:ExportList(listIndex)
  if not listIndex or listIndex <= 0 or listIndex > #self.shoppingLists then
    return nil
  end
  
  local list = self.shoppingLists[listIndex]
  local exportLines = {}
  
  -- Add list name as comment
  table.insert(exportLines, "-- " .. list.name)
  
  -- Add each item
  for _, item in ipairs(list.items) do
    if item.link then
      table.insert(exportLines, item.link)
    elseif item.searchTerm then
      table.insert(exportLines, item.searchTerm)
    end
  end
  
  -- Join with newlines
  return table.concat(exportLines, "\n")
end