local addonName, VUI = ...
local Auctionator = VUI.Auctionator

-- Create the Shopping List Panel component
Auctionator.UI = Auctionator.UI or {}
Auctionator.UI.ShoppingListPanel = {}

-- Initialize the shopping list panel
function Auctionator.UI.ShoppingListPanel:Initialize()
  -- Create the main frame
  self.frame = CreateFrame("Frame", "VUIAuctionatorShoppingListPanel", nil)
  self.frame:SetSize(600, 520)
  self.frame:SetPoint("TOPLEFT", 0, 0)
  self.frame:Hide()
  
  -- Set up the panel
  self:CreatePanelStructure()
  
  -- Register events
  self:RegisterEvents()
end

-- Create the structure of the shopping list panel
function Auctionator.UI.ShoppingListPanel:CreatePanelStructure()
  -- Header frame
  self.headerFrame = CreateFrame("Frame", self.frame:GetName() .. "Header", self.frame)
  self.headerFrame:SetSize(600, 40)
  self.headerFrame:SetPoint("TOPLEFT", 0, 0)
  
  -- Title
  self.title = self.headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  self.title:SetPoint("TOPLEFT", 14, -8)
  self.title:SetText(Auctionator.L.FAVORITES)
  
  -- New list button
  self.newListButton = CreateFrame("Button", self.headerFrame:GetName() .. "NewListButton", self.headerFrame, "VUIAuctionatorButtonTemplate")
  self.newListButton:SetSize(100, 22)
  self.newListButton:SetPoint("TOPRIGHT", -14, -9)
  self.newListButton:SetText(Auctionator.L.DEFAULT_LIST_NAME)
  
  -- Import/Export button
  self.importExportButton = CreateFrame("Button", self.headerFrame:GetName() .. "ImportExportButton", self.headerFrame, "VUIAuctionatorButtonTemplate")
  self.importExportButton:SetSize(100, 22)
  self.importExportButton:SetPoint("RIGHT", self.newListButton, "LEFT", -10, 0)
  self.importExportButton:SetText(Auctionator.L.IMPORT)
  
  -- Content frame (split view)
  self.contentFrame = CreateFrame("Frame", self.frame:GetName() .. "Content", self.frame)
  self.contentFrame:SetSize(600, 480)
  self.contentFrame:SetPoint("TOP", self.headerFrame, "BOTTOM", 0, 0)
  
  -- Left side (lists)
  self.listsFrame = CreateFrame("Frame", self.contentFrame:GetName() .. "Lists", self.contentFrame)
  self.listsFrame:SetSize(180, 480)
  self.listsFrame:SetPoint("TOPLEFT", 0, 0)
  
  -- Lists label
  self.listsLabel = self.listsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  self.listsLabel:SetPoint("TOPLEFT", 14, -8)
  self.listsLabel:SetText(Auctionator.L.FAVORITES)
  
  -- Lists scroll frame
  self.listsScroll = CreateFrame("ScrollFrame", self.listsFrame:GetName() .. "Scroll", self.listsFrame, "FauxScrollFrameTemplate")
  self.listsScroll:SetSize(160, 420)
  self.listsScroll:SetPoint("TOPLEFT", 10, -30)
  
  -- Lists entries
  self.listEntries = {}
  for i = 1, 15 do
    local entry = CreateFrame("Button", self.listsScroll:GetName() .. "Entry" .. i, self.listsScroll)
    entry:SetSize(160, 24)
    entry:SetPoint("TOPLEFT", 0, -(i-1) * 26)
    
    entry.text = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    entry.text:SetPoint("LEFT", 5, 0)
    entry.text:SetSize(135, 24)
    entry.text:SetJustifyH("LEFT")
    
    entry.deleteButton = CreateFrame("Button", entry:GetName() .. "DeleteButton", entry)
    entry.deleteButton:SetSize(16, 16)
    entry.deleteButton:SetPoint("RIGHT", -5, 0)
    entry.deleteButton:SetNormalTexture("Interface\\Buttons\\UI-StopButton")
    entry.deleteButton:SetHighlightTexture("Interface\\Buttons\\UI-StopButton", "ADD")
    entry.deleteButton:Hide() -- Only show on hover
    
    entry:SetScript("OnClick", function()
      self:SelectList(entry.listIndex)
    end)
    
    entry:SetScript("OnEnter", function()
      entry.deleteButton:Show()
      entry:SetBackdropColor(0.3, 0.3, 0.3, 0.3)
    end)
    
    entry:SetScript("OnLeave", function()
      entry.deleteButton:Hide()
      entry:SetBackdropColor(0, 0, 0, 0)
    end)
    
    entry.deleteButton:SetScript("OnClick", function()
      self:DeleteList(entry.listIndex)
    end)
    
    -- Create highlight effect
    entry:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    
    -- Background
    entry:SetBackdrop({
      bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
      edgeFile = nil,
      tile = true,
      tileSize = 16,
      edgeSize = 0,
      insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    entry:SetBackdropColor(0, 0, 0, 0)
    
    self.listEntries[i] = entry
  end
  
  -- Right side (list items)
  self.itemsFrame = CreateFrame("Frame", self.contentFrame:GetName() .. "Items", self.contentFrame)
  self.itemsFrame:SetSize(420, 480)
  self.itemsFrame:SetPoint("TOPRIGHT", 0, 0)
  
  -- Items header
  self.itemsHeader = CreateFrame("Frame", self.itemsFrame:GetName() .. "Header", self.itemsFrame)
  self.itemsHeader:SetSize(420, 30)
  self.itemsHeader:SetPoint("TOPLEFT", 0, 0)
  
  -- Header background
  local headerBg = self.itemsHeader:CreateTexture(nil, "BACKGROUND")
  headerBg:SetAllPoints()
  headerBg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
  
  -- List name label
  self.listNameLabel = self.itemsHeader:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  self.listNameLabel:SetPoint("LEFT", 14, 0)
  self.listNameLabel:SetText("")
  
  -- Add item button
  self.addItemButton = CreateFrame("Button", self.itemsHeader:GetName() .. "AddButton", self.itemsHeader, "VUIAuctionatorButtonTemplate")
  self.addItemButton:SetSize(80, 22)
  self.addItemButton:SetPoint("RIGHT", -14, 0)
  self.addItemButton:SetText(Auctionator.L.ITEMS)
  
  -- Rename button
  self.renameButton = CreateFrame("Button", self.itemsHeader:GetName() .. "RenameButton", self.itemsHeader, "VUIAuctionatorIconButtonTemplate")
  self.renameButton:SetSize(16, 16)
  self.renameButton:SetPoint("RIGHT", self.addItemButton, "LEFT", -10, 0)
  self.renameButton:SetNormalTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-RenameButton")
  self.renameButton:SetHighlightTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-RenameButton", "ADD")
  
  -- Search all button
  self.searchAllButton = CreateFrame("Button", self.itemsHeader:GetName() .. "SearchAllButton", self.itemsHeader, "VUIAuctionatorButtonTemplate")
  self.searchAllButton:SetSize(80, 22)
  self.searchAllButton:SetPoint("RIGHT", self.renameButton, "LEFT", -10, 0)
  self.searchAllButton:SetText(Auctionator.L.SEARCH)
  
  -- Items list
  self.itemsList = CreateFrame("Frame", self.itemsFrame:GetName() .. "List", self.itemsFrame)
  self.itemsList:SetSize(420, 450)
  self.itemsList:SetPoint("TOP", self.itemsHeader, "BOTTOM", 0, 0)
  
  -- Items scroll frame
  self.itemsScroll = CreateFrame("ScrollFrame", self.itemsList:GetName() .. "Scroll", self.itemsList, "FauxScrollFrameTemplate")
  self.itemsScroll:SetSize(394, 450)
  self.itemsScroll:SetPoint("TOPLEFT", 0, 0)
  
  -- Items entries
  self.itemEntries = {}
  for i = 1, 15 do
    local entry = CreateFrame("Button", self.itemsScroll:GetName() .. "Entry" .. i, self.itemsScroll)
    entry:SetSize(394, 24)
    entry:SetPoint("TOPLEFT", 0, -(i-1) * 26)
    
    entry.icon = entry:CreateTexture(nil, "ARTWORK")
    entry.icon:SetSize(20, 20)
    entry.icon:SetPoint("LEFT", 5, 0)
    entry.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Trim default border
    
    entry.text = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    entry.text:SetPoint("LEFT", entry.icon, "RIGHT", 5, 0)
    entry.text:SetSize(280, 24)
    entry.text:SetJustifyH("LEFT")
    
    entry.deleteButton = CreateFrame("Button", entry:GetName() .. "DeleteButton", entry)
    entry.deleteButton:SetSize(16, 16)
    entry.deleteButton:SetPoint("RIGHT", -5, 0)
    entry.deleteButton:SetNormalTexture("Interface\\Buttons\\UI-StopButton")
    entry.deleteButton:SetHighlightTexture("Interface\\Buttons\\UI-StopButton", "ADD")
    entry.deleteButton:Hide() -- Only show on hover
    
    entry.searchButton = CreateFrame("Button", entry:GetName() .. "SearchButton", entry)
    entry.searchButton:SetSize(16, 16)
    entry.searchButton:SetPoint("RIGHT", entry.deleteButton, "LEFT", -5, 0)
    entry.searchButton:SetNormalTexture("Interface\\Icons\\INV_Misc_Spyglass_02")
    entry.searchButton:SetHighlightTexture("Interface\\Icons\\INV_Misc_Spyglass_02", "ADD")
    entry.searchButton:Hide() -- Only show on hover
    
    entry:SetScript("OnClick", function()
      self:SelectItem(entry.itemIndex)
    end)
    
    entry:SetScript("OnEnter", function()
      entry.deleteButton:Show()
      entry.searchButton:Show()
      entry:SetBackdropColor(0.3, 0.3, 0.3, 0.3)
      
      -- Show item tooltip if we have an item link
      if entry.itemLink then
        GameTooltip:SetOwner(entry, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink(entry.itemLink)
        GameTooltip:Show()
      end
    end)
    
    entry:SetScript("OnLeave", function()
      entry.deleteButton:Hide()
      entry.searchButton:Hide()
      entry:SetBackdropColor(0, 0, 0, 0)
      GameTooltip:Hide()
    end)
    
    entry.deleteButton:SetScript("OnClick", function()
      self:DeleteItem(entry.itemIndex)
    end)
    
    entry.searchButton:SetScript("OnClick", function()
      self:SearchForItem(entry.itemIndex)
    end)
    
    -- Create highlight effect
    entry:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    
    -- Background
    entry:SetBackdrop({
      bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
      edgeFile = nil,
      tile = true,
      tileSize = 16,
      edgeSize = 0,
      insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    entry:SetBackdropColor(0, 0, 0, 0)
    
    self.itemEntries[i] = entry
  end
  
  -- Setup UI interaction
  self:SetupInteraction()
end

-- Set up interaction handlers
function Auctionator.UI.ShoppingListPanel:SetupInteraction()
  -- New list button
  self.newListButton:SetScript("OnClick", function()
    self:CreateNewList()
  end)
  
  -- Import/Export button
  self.importExportButton:SetScript("OnClick", function()
    self:ShowImportExportDialog()
  end)
  
  -- Add item button
  self.addItemButton:SetScript("OnClick", function()
    self:ShowAddItemDialog()
  end)
  
  -- Rename button
  self.renameButton:SetScript("OnClick", function()
    self:ShowRenameDialog()
  end)
  
  -- Search all button
  self.searchAllButton:SetScript("OnClick", function()
    self:SearchEntireList()
  end)
  
  -- Lists scroll
  self.listsScroll:SetScript("OnVerticalScroll", function(self, offset)
    FauxScrollFrame_OnVerticalScroll(self, offset, 26, function()
      Auctionator.UI.ShoppingListPanel:UpdateListsDisplay()
    end)
  end)
  
  -- Items scroll
  self.itemsScroll:SetScript("OnVerticalScroll", function(self, offset)
    FauxScrollFrame_OnVerticalScroll(self, offset, 26, function()
      Auctionator.UI.ShoppingListPanel:UpdateItemsDisplay()
    end)
  end)
end

-- Register for events
function Auctionator.UI.ShoppingListPanel:RegisterEvents()
  -- List events
  Auctionator.EventBus:Register({}, Auctionator.Lists.Events.LIST_CREATED, function(_, list)
    self:UpdateListsDisplay()
    self:SelectList(#Auctionator.Lists:GetAllLists())
  end)
  
  Auctionator.EventBus:Register({}, Auctionator.Lists.Events.LIST_DELETED, function(_, list)
    self:UpdateListsDisplay()
    self:SelectList(1)
  end)
  
  Auctionator.EventBus:Register({}, Auctionator.Lists.Events.LIST_UPDATED, function(_, list)
    self:UpdateListsDisplay()
    self:UpdateItemsDisplay()
  end)
  
  -- Item events
  Auctionator.EventBus:Register({}, Auctionator.Lists.Events.ITEM_ADDED, function(_, list, item)
    if self.currentList and self.currentList.name == list.name then
      self:UpdateItemsDisplay()
    end
  end)
  
  Auctionator.EventBus:Register({}, Auctionator.Lists.Events.ITEM_REMOVED, function(_, list, item)
    if self.currentList and self.currentList.name == list.name then
      self:UpdateItemsDisplay()
    end
  end)
  
  -- AH events
  Auctionator.EventBus:Register({}, Auctionator.AuctionHouse.Events.AUCTION_HOUSE_SHOW, function()
    -- Update the display when AH opens
    self:UpdateListsDisplay()
    self:UpdateItemsDisplay()
  end)
end

-- Create a new shopping list
function Auctionator.UI.ShoppingListPanel:CreateNewList()
  StaticPopupDialogs["VUIAUCTIONATOR_NEW_LIST"] = {
    text = "Enter a name for the new list:",
    button1 = Auctionator.L.CREATE,
    button2 = Auctionator.L.CANCEL,
    hasEditBox = true,
    maxLetters = 32,
    OnAccept = function(self)
      local listName = self.editBox:GetText()
      if listName and listName ~= "" then
        Auctionator.Lists:CreateList(listName)
      end
    end,
    EditBoxOnEnterPressed = function(self)
      local parent = self:GetParent()
      local listName = parent.editBox:GetText()
      if listName and listName ~= "" then
        Auctionator.Lists:CreateList(listName)
      end
      parent:Hide()
    end,
    OnShow = function(self)
      self.editBox:SetText(Auctionator.L.DEFAULT_LIST_NAME)
      self.editBox:HighlightText()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
  }
  
  StaticPopup_Show("VUIAUCTIONATOR_NEW_LIST")
end

-- Delete a shopping list
function Auctionator.UI.ShoppingListPanel:DeleteList(listIndex)
  local list = Auctionator.Lists:GetList(listIndex)
  
  if not list then
    return
  end
  
  StaticPopupDialogs["VUIAUCTIONATOR_DELETE_LIST"] = {
    text = "Are you sure you want to delete the list '" .. list.name .. "'?",
    button1 = Auctionator.L.DELETE,
    button2 = Auctionator.L.CANCEL,
    OnAccept = function()
      Auctionator.Lists:DeleteList(listIndex)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
  }
  
  StaticPopup_Show("VUIAUCTIONATOR_DELETE_LIST")
end

-- Show rename dialog
function Auctionator.UI.ShoppingListPanel:ShowRenameDialog()
  if not self.currentList then
    return
  end
  
  StaticPopupDialogs["VUIAUCTIONATOR_RENAME_LIST"] = {
    text = "Enter a new name for the list:",
    button1 = Auctionator.L.SAVE,
    button2 = Auctionator.L.CANCEL,
    hasEditBox = true,
    maxLetters = 32,
    OnAccept = function(self)
      local listName = self.editBox:GetText()
      if listName and listName ~= "" then
        Auctionator.Lists:RenameList(self.listIndex, listName)
      end
    end,
    EditBoxOnEnterPressed = function(self)
      local parent = self:GetParent()
      local listName = parent.editBox:GetText()
      if listName and listName ~= "" then
        Auctionator.Lists:RenameList(parent.listIndex, listName)
      end
      parent:Hide()
    end,
    OnShow = function(self)
      self.editBox:SetText(Auctionator.UI.ShoppingListPanel.currentList.name)
      self.editBox:HighlightText()
      self.listIndex = Auctionator.UI.ShoppingListPanel.currentListIndex
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
  }
  
  StaticPopup_Show("VUIAUCTIONATOR_RENAME_LIST")
end

-- Show import/export dialog
function Auctionator.UI.ShoppingListPanel:ShowImportExportDialog()
  if not self.importExportDialog then
    -- Create the import/export dialog
    local dialog = CreateFrame("Frame", "VUIAuctionatorImportExportDialog", UIParent, "VUIAuctionatorPanelTemplate")
    dialog:SetSize(500, 400)
    dialog:SetPoint("CENTER")
    dialog:SetFrameStrata("DIALOG")
    dialog:EnableMouse(true)
    dialog:SetMovable(true)
    dialog:RegisterForDrag("LeftButton")
    dialog:SetScript("OnDragStart", dialog.StartMoving)
    dialog:SetScript("OnDragStop", dialog.StopMovingOrSizing)
    dialog:Hide()
    
    -- Title
    dialog.title = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dialog.title:SetPoint("TOPLEFT", 16, -16)
    dialog.title:SetText("Import/Export Shopping List")
    
    -- Mode selector
    dialog.importButton = CreateFrame("CheckButton", dialog:GetName() .. "ImportButton", dialog, "UIRadioButtonTemplate")
    dialog.importButton:SetPoint("TOPLEFT", dialog.title, "BOTTOMLEFT", 0, -10)
    dialog.importButton:SetChecked(true)
    _G[dialog.importButton:GetName() .. "Text"]:SetText(Auctionator.L.IMPORT)
    
    dialog.exportButton = CreateFrame("CheckButton", dialog:GetName() .. "ExportButton", dialog, "UIRadioButtonTemplate")
    dialog.exportButton:SetPoint("LEFT", dialog.importButton, "RIGHT", 100, 0)
    dialog.exportButton:SetChecked(false)
    _G[dialog.exportButton:GetName() .. "Text"]:SetText(Auctionator.L.EXPORT)
    
    -- Mode selector handlers
    dialog.importButton:SetScript("OnClick", function(self)
      self:SetChecked(true)
      dialog.exportButton:SetChecked(false)
      dialog.importControls:Show()
      dialog.exportControls:Hide()
    end)
    
    dialog.exportButton:SetScript("OnClick", function(self)
      self:SetChecked(true)
      dialog.importButton:SetChecked(false)
      dialog.importControls:Hide()
      dialog.exportControls:Show()
    end)
    
    -- Import controls
    dialog.importControls = CreateFrame("Frame", dialog:GetName() .. "ImportControls", dialog)
    dialog.importControls:SetSize(468, 300)
    dialog.importControls:SetPoint("TOP", dialog.importButton, "BOTTOM", 50, -10)
    
    dialog.importControls.label = dialog.importControls:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dialog.importControls.label:SetPoint("TOPLEFT", 0, 0)
    dialog.importControls.label:SetText("Paste the list data below:")
    
    dialog.importControls.editBox = CreateFrame("EditBox", dialog.importControls:GetName() .. "EditBox", dialog.importControls)
    dialog.importControls.editBox:SetMultiLine(true)
    dialog.importControls.editBox:SetSize(450, 250)
    dialog.importControls.editBox:SetPoint("TOPLEFT", dialog.importControls.label, "BOTTOMLEFT", 0, -10)
    dialog.importControls.editBox:SetFontObject("ChatFontNormal")
    dialog.importControls.editBox:SetAutoFocus(false)
    dialog.importControls.editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    
    -- Add a scroll frame for the import edit box
    dialog.importControls.scrollFrame = CreateFrame("ScrollFrame", dialog.importControls.editBox:GetName() .. "ScrollFrame", dialog.importControls, "UIPanelScrollFrameTemplate")
    dialog.importControls.scrollFrame:SetSize(450, 250)
    dialog.importControls.scrollFrame:SetPoint("TOPLEFT", dialog.importControls.label, "BOTTOMLEFT", 0, -10)
    dialog.importControls.scrollFrame:SetScrollChild(dialog.importControls.editBox)
    
    -- Create backdrop for the edit box
    dialog.importControls.backdrop = CreateFrame("Frame", dialog.importControls.editBox:GetName() .. "Backdrop", dialog.importControls)
    dialog.importControls.backdrop:SetPoint("TOPLEFT", dialog.importControls.scrollFrame, "TOPLEFT", -5, 5)
    dialog.importControls.backdrop:SetPoint("BOTTOMRIGHT", dialog.importControls.scrollFrame, "BOTTOMRIGHT", 5, -5)
    dialog.importControls.backdrop:SetBackdrop({
      bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
      edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
      tile = true,
      tileSize = 32,
      edgeSize = 16,
      insets = { left = 5, right = 5, top = 5, bottom = 5 }
    })
    
    -- Export controls
    dialog.exportControls = CreateFrame("Frame", dialog:GetName() .. "ExportControls", dialog)
    dialog.exportControls:SetSize(468, 300)
    dialog.exportControls:SetPoint("TOP", dialog.exportButton, "BOTTOM", -50, -10)
    dialog.exportControls:Hide()
    
    dialog.exportControls.label = dialog.exportControls:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dialog.exportControls.label:SetPoint("TOPLEFT", 0, 0)
    dialog.exportControls.label:SetText("Copy the list data below:")
    
    dialog.exportControls.listDropdown = CreateFrame("Frame", dialog.exportControls:GetName() .. "ListDropdown", dialog.exportControls, "UIDropDownMenuTemplate")
    dialog.exportControls.listDropdown:SetPoint("TOPLEFT", dialog.exportControls.label, "BOTTOMLEFT", -20, -10)
    
    dialog.exportControls.editBox = CreateFrame("EditBox", dialog.exportControls:GetName() .. "EditBox", dialog.exportControls)
    dialog.exportControls.editBox:SetMultiLine(true)
    dialog.exportControls.editBox:SetSize(450, 220)
    dialog.exportControls.editBox:SetPoint("TOPLEFT", dialog.exportControls.listDropdown, "BOTTOMLEFT", 20, -10)
    dialog.exportControls.editBox:SetFontObject("ChatFontNormal")
    dialog.exportControls.editBox:SetAutoFocus(false)
    dialog.exportControls.editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    
    -- Make export read-only
    dialog.exportControls.editBox:SetScript("OnChar", function() return false end)
    dialog.exportControls.editBox:SetScript("OnKeyDown", function() return false end)
    
    -- Add a scroll frame for the export edit box
    dialog.exportControls.scrollFrame = CreateFrame("ScrollFrame", dialog.exportControls.editBox:GetName() .. "ScrollFrame", dialog.exportControls, "UIPanelScrollFrameTemplate")
    dialog.exportControls.scrollFrame:SetSize(450, 220)
    dialog.exportControls.scrollFrame:SetPoint("TOPLEFT", dialog.exportControls.listDropdown, "BOTTOMLEFT", 20, -10)
    dialog.exportControls.scrollFrame:SetScrollChild(dialog.exportControls.editBox)
    
    -- Create backdrop for the edit box
    dialog.exportControls.backdrop = CreateFrame("Frame", dialog.exportControls.editBox:GetName() .. "Backdrop", dialog.exportControls)
    dialog.exportControls.backdrop:SetPoint("TOPLEFT", dialog.exportControls.scrollFrame, "TOPLEFT", -5, 5)
    dialog.exportControls.backdrop:SetPoint("BOTTOMRIGHT", dialog.exportControls.scrollFrame, "BOTTOMRIGHT", 5, -5)
    dialog.exportControls.backdrop:SetBackdrop({
      bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
      edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
      tile = true,
      tileSize = 32,
      edgeSize = 16,
      insets = { left = 5, right = 5, top = 5, bottom = 5 }
    })
    
    -- Initialize export dropdown
    UIDropDownMenu_Initialize(dialog.exportControls.listDropdown, function(self, level)
      local info = UIDropDownMenu_CreateInfo()
      local lists = Auctionator.Lists:GetAllLists()
      
      for i, list in ipairs(lists) do
        info.text = list.name
        info.value = i
        info.func = function()
          UIDropDownMenu_SetText(dialog.exportControls.listDropdown, list.name)
          local exportString = Auctionator.Lists:ExportList(i)
          dialog.exportControls.editBox:SetText(exportString or "")
          dialog.exportControls.editBox:HighlightText()
        end
        UIDropDownMenu_AddButton(info, level)
      end
    end)
    
    -- Buttons
    dialog.acceptButton = CreateFrame("Button", dialog:GetName() .. "AcceptButton", dialog, "VUIAuctionatorButtonTemplate")
    dialog.acceptButton:SetSize(100, 22)
    dialog.acceptButton:SetPoint("BOTTOMRIGHT", -16, 16)
    dialog.acceptButton:SetText(Auctionator.L.SAVE)
    
    dialog.cancelButton = CreateFrame("Button", dialog:GetName() .. "CancelButton", dialog, "VUIAuctionatorButtonTemplate")
    dialog.cancelButton:SetSize(100, 22)
    dialog.cancelButton:SetPoint("RIGHT", dialog.acceptButton, "LEFT", -10, 0)
    dialog.cancelButton:SetText(Auctionator.L.CANCEL)
    
    -- Button handlers
    dialog.acceptButton:SetScript("OnClick", function()
      if dialog.importButton:GetChecked() then
        -- Import
        local importString = dialog.importControls.editBox:GetText()
        local success, itemsAdded = Auctionator.Lists:ImportList(importString)
        
        if success then
          dialog:Hide()
        else
          Auctionator.Utilities.Message.Error(Auctionator.L.ERR_IMPORT_FAILED)
        end
      else
        -- Export does not need to save anything
        dialog:Hide()
      end
    end)
    
    dialog.cancelButton:SetScript("OnClick", function()
      dialog:Hide()
    end)
    
    self.importExportDialog = dialog
  end
  
  -- Initialize export dropdown if exporting
  if self.currentList then
    UIDropDownMenu_SetText(self.importExportDialog.exportControls.listDropdown, self.currentList.name)
    local exportString = Auctionator.Lists:ExportList(self.currentListIndex)
    self.importExportDialog.exportControls.editBox:SetText(exportString or "")
  end
  
  -- Show the dialog
  self.importExportDialog:Show()
end

-- Show add item dialog
function Auctionator.UI.ShoppingListPanel:ShowAddItemDialog()
  if not self.currentList then
    return
  end
  
  StaticPopupDialogs["VUIAUCTIONATOR_ADD_ITEM"] = {
    text = "Enter an item name, link, or search term:",
    button1 = Auctionator.L.ITEMS,
    button2 = Auctionator.L.CANCEL,
    hasEditBox = true,
    maxLetters = 255,
    OnAccept = function(self)
      local itemInfo = self.editBox:GetText()
      if itemInfo and itemInfo ~= "" then
        Auctionator.Lists:AddItem(Auctionator.UI.ShoppingListPanel.currentListIndex, itemInfo)
      end
    end,
    EditBoxOnEnterPressed = function(self)
      local parent = self:GetParent()
      local itemInfo = parent.editBox:GetText()
      if itemInfo and itemInfo ~= "" then
        Auctionator.Lists:AddItem(Auctionator.UI.ShoppingListPanel.currentListIndex, itemInfo)
      end
      parent:Hide()
    end,
    OnShow = function(self)
      self.editBox:SetText("")
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
  }
  
  StaticPopup_Show("VUIAUCTIONATOR_ADD_ITEM")
end

-- Update lists display
function Auctionator.UI.ShoppingListPanel:UpdateListsDisplay()
  -- Get all shopping lists
  local lists = Auctionator.Lists:GetAllLists()
  
  -- Update scroll frame
  FauxScrollFrame_Update(self.listsScroll, #lists, 15, 26)
  local offset = FauxScrollFrame_GetOffset(self.listsScroll)
  
  -- Update list entries
  for i = 1, 15 do
    local entry = self.listEntries[i]
    local listIndex = i + offset
    
    if listIndex <= #lists then
      local list = lists[listIndex]
      
      entry.text:SetText(list.name)
      entry.listIndex = listIndex
      
      -- Highlight if this is the selected list
      if self.currentListIndex and self.currentListIndex == listIndex then
        entry:LockHighlight()
      else
        entry:UnlockHighlight()
      end
      
      entry:Show()
    else
      entry.text:SetText("")
      entry.listIndex = nil
      entry:UnlockHighlight()
      entry:Hide()
    end
  end
end

-- Update items display
function Auctionator.UI.ShoppingListPanel:UpdateItemsDisplay()
  if not self.currentList then
    return
  end
  
  -- Get items from the current list
  local items = self.currentList.items or {}
  
  -- Update list name
  self.listNameLabel:SetText(self.currentList.name)
  
  -- Update scroll frame
  FauxScrollFrame_Update(self.itemsScroll, #items, 15, 26)
  local offset = FauxScrollFrame_GetOffset(self.itemsScroll)
  
  -- Update item entries
  for i = 1, 15 do
    local entry = self.itemEntries[i]
    local itemIndex = i + offset
    
    if itemIndex <= #items then
      local item = items[itemIndex]
      
      -- Set item info
      if item.link then
        -- It's an item
        entry.icon:SetTexture(Auctionator.Utilities.ItemInfo.GetItemIconTexture(item.link) or "Interface\\Icons\\INV_Misc_QuestionMark")
        
        local quality = Auctionator.Utilities.ItemInfo.GetItemRarity(item.link)
        if quality and ITEM_QUALITY_COLORS[quality] then
          local color = ITEM_QUALITY_COLORS[quality]
          entry.text:SetTextColor(color.r, color.g, color.b)
        else
          entry.text:SetTextColor(1, 1, 1)
        end
        
        entry.text:SetText(Auctionator.Utilities.ItemInfo.GetItemName(item.link) or item.searchTerm)
        entry.itemLink = item.link
      else
        -- It's a search term
        entry.icon:SetTexture("Interface\\Icons\\INV_Misc_Spyglass_02")
        entry.text:SetTextColor(1, 1, 1)
        entry.text:SetText(item.searchTerm)
        entry.itemLink = nil
      end
      
      entry.itemIndex = itemIndex
      entry:Show()
    else
      entry.text:SetText("")
      entry.icon:SetTexture(nil)
      entry.itemIndex = nil
      entry.itemLink = nil
      entry:Hide()
    end
  end
end

-- Select a list
function Auctionator.UI.ShoppingListPanel:SelectList(listIndex)
  -- Get the list
  local list = Auctionator.Lists:GetList(listIndex)
  
  if not list then
    self.currentList = nil
    self.currentListIndex = nil
    self.listNameLabel:SetText("")
    return
  end
  
  -- Update current list
  self.currentList = list
  self.currentListIndex = listIndex
  
  -- Update displays
  self:UpdateListsDisplay()
  self:UpdateItemsDisplay()
  
  -- Notify list selection
  Auctionator.Lists:SelectList(listIndex)
end

-- Select an item from a list
function Auctionator.UI.ShoppingListPanel:SelectItem(itemIndex)
  -- Nothing to do here in the basic implementation
end

-- Delete an item from a list
function Auctionator.UI.ShoppingListPanel:DeleteItem(itemIndex)
  if not self.currentList or not itemIndex then
    return
  end
  
  Auctionator.Lists:RemoveItem(self.currentListIndex, itemIndex)
end

-- Search for an item from a list
function Auctionator.UI.ShoppingListPanel:SearchForItem(itemIndex)
  if not self.currentList or not itemIndex then
    return
  end
  
  -- Need the AH to be open
  if not Auctionator.AuctionHouse:IsOpen() then
    Auctionator.Utilities.Message.Error(Auctionator.L.ERR_AUCTION_HOUSE_CLOSED)
    return
  end
  
  -- Start a search for this item
  Auctionator.Lists:SearchForItem(self.currentListIndex, itemIndex)
end

-- Search the entire list
function Auctionator.UI.ShoppingListPanel:SearchEntireList()
  if not self.currentList then
    return
  end
  
  -- Need the AH to be open
  if not Auctionator.AuctionHouse:IsOpen() then
    Auctionator.Utilities.Message.Error(Auctionator.L.ERR_AUCTION_HOUSE_CLOSED)
    return
  end
  
  -- This would typically start a scan of all items in the list
  -- For simplicity, just search the first item for now
  if #self.currentList.items > 0 then
    self:SearchForItem(1)
  end
end

-- Show the shopping list panel
function Auctionator.UI.ShoppingListPanel:Show()
  self.frame:Show()
  
  -- Update the display
  self:UpdateListsDisplay()
  self:UpdateItemsDisplay()
end

-- Hide the shopping list panel
function Auctionator.UI.ShoppingListPanel:Hide()
  self.frame:Hide()
end