local addonName, VUI = ...
local Auctionator = VUI.Auctionator

-- Create the History Panel component
Auctionator.UI = Auctionator.UI or {}
Auctionator.UI.HistoryPanel = {}

-- Initialize the history panel
function Auctionator.UI.HistoryPanel:Initialize()
  -- Create the main frame
  self.frame = CreateFrame("Frame", "VUIAuctionatorHistoryPanel", nil)
  self.frame:SetSize(600, 520)
  self.frame:SetPoint("TOPLEFT", 0, 0)
  self.frame:Hide()
  
  -- Set up the panel
  self:CreatePanelStructure()
  
  -- Register events
  self:RegisterEvents()
end

-- Create the structure of the history panel
function Auctionator.UI.HistoryPanel:CreatePanelStructure()
  -- Header frame
  self.headerFrame = CreateFrame("Frame", self.frame:GetName() .. "Header", self.frame)
  self.headerFrame:SetSize(600, 40)
  self.headerFrame:SetPoint("TOPLEFT", 0, 0)
  
  -- Title
  self.title = self.headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  self.title:SetPoint("TOPLEFT", 14, -8)
  self.title:SetText(Auctionator.L.HISTORY)
  
  -- Tabs for sales/purchases
  self.tabs = {}
  
  -- Sales tab
  self.tabs[1] = CreateFrame("Button", self.headerFrame:GetName() .. "SalesTab", self.headerFrame, "VUIAuctionatorTabButtonTemplate")
  self.tabs[1]:SetPoint("BOTTOMLEFT", self.headerFrame, "BOTTOMLEFT", 20, 0)
  self.tabs[1]:SetText(Auctionator.L.AUCTIONS .. " " .. Auctionator.L.SOLD)
  
  -- Purchases tab
  self.tabs[2] = CreateFrame("Button", self.headerFrame:GetName() .. "PurchasesTab", self.headerFrame, "VUIAuctionatorTabButtonTemplate")
  self.tabs[2]:SetPoint("LEFT", self.tabs[1], "RIGHT", -10, 0)
  self.tabs[2]:SetText(Auctionator.L.AUCTIONS .. " " .. Auctionator.L.BUY)
  
  -- Tab click handlers
  for i, tab in ipairs(self.tabs) do
    tab:SetID(i)
    tab:SetScript("OnClick", function(self)
      Auctionator.UI.HistoryPanel:SelectTab(self:GetID())
    end)
  end
  
  -- Main content frame
  self.contentFrame = CreateFrame("Frame", self.frame:GetName() .. "Content", self.frame)
  self.contentFrame:SetSize(600, 480)
  self.contentFrame:SetPoint("TOP", self.headerFrame, "BOTTOM", 0, 0)
  
  -- Content panels
  self.panels = {}
  
  -- Sales panel
  self.panels[1] = CreateFrame("Frame", self.contentFrame:GetName() .. "SalesPanel", self.contentFrame)
  self.panels[1]:SetAllPoints()
  
  -- Purchases panel
  self.panels[2] = CreateFrame("Frame", self.contentFrame:GetName() .. "PurchasesPanel", self.contentFrame)
  self.panels[2]:SetAllPoints()
  self.panels[2]:Hide()
  
  -- Create content for each panel
  self:CreateSalesPanel(self.panels[1])
  self:CreatePurchasesPanel(self.panels[2])
  
  -- Set up search bar
  self.searchBox = CreateFrame("EditBox", self.contentFrame:GetName() .. "SearchBox", self.contentFrame, "VUIAuctionatorEditBoxTemplate")
  self.searchBox:SetSize(200, 22)
  self.searchBox:SetPoint("TOPRIGHT", -100, -10)
  self.searchBox:SetAutoFocus(false)
  
  -- Search label
  self.searchLabel = self.contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  self.searchLabel:SetPoint("RIGHT", self.searchBox, "LEFT", -8, 0)
  self.searchLabel:SetText(Auctionator.L.SEARCH)
  
  -- Search button
  self.searchButton = CreateFrame("Button", self.contentFrame:GetName() .. "SearchButton", self.contentFrame, "VUIAuctionatorButtonTemplate")
  self.searchButton:SetSize(80, 22)
  self.searchButton:SetPoint("LEFT", self.searchBox, "RIGHT", 8, 0)
  self.searchButton:SetText(Auctionator.L.SEARCH)
  
  -- Setup search functionality
  self.searchButton:SetScript("OnClick", function()
    self:PerformSearch()
  end)
  
  self.searchBox:SetScript("OnEnterPressed", function()
    self:PerformSearch()
  end)
  
  -- Initially select the sales tab
  self:SelectTab(1)
end

-- Create the sales history panel
function Auctionator.UI.HistoryPanel:CreateSalesPanel(panel)
  -- List header
  panel.listHeader = CreateFrame("Frame", panel:GetName() .. "ListHeader", panel)
  panel.listHeader:SetSize(600, 30)
  panel.listHeader:SetPoint("TOPLEFT", 0, -40)
  
  -- Header background
  panel.headerBackground = panel.listHeader:CreateTexture(nil, "BACKGROUND")
  panel.headerBackground:SetAllPoints()
  panel.headerBackground:SetColorTexture(0.1, 0.1, 0.1, 0.8)
  
  -- Header columns
  panel.columnLabels = {}
  local columns = {
    {text = Auctionator.L.ITEMS, width = 220, justifyH = "LEFT"},
    {text = Auctionator.L.QUANTITY, width = 70, justifyH = "RIGHT"},
    {text = Auctionator.L.PRICE, width = 100, justifyH = "RIGHT"},
    {text = Auctionator.L.DATE, width = 120, justifyH = "RIGHT"},
    {text = Auctionator.L.BUYER, width = 80, justifyH = "LEFT"}
  }
  
  local offset = 10
  for i, col in ipairs(columns) do
    local label = panel.listHeader:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetSize(col.width, 20)
    label:SetPoint("TOPLEFT", offset, -5)
    label:SetJustifyH(col.justifyH)
    label:SetText(ITEM_QUALITY_COLORS[1].hex .. col.text .. "|r")
    
    panel.columnLabels[i] = label
    offset = offset + col.width + 5
  end
  
  -- Sales list scroll frame
  panel.scrollFrame = CreateFrame("ScrollFrame", panel:GetName() .. "ScrollFrame", panel, "FauxScrollFrameTemplate")
  panel.scrollFrame:SetSize(574, 380)
  panel.scrollFrame:SetPoint("TOPLEFT", panel.listHeader, "BOTTOMLEFT", 0, 0)
  
  -- Sales entries
  panel.entries = {}
  for i = 1, 15 do
    local entry = CreateFrame("Button", panel.scrollFrame:GetName() .. "Entry" .. i, panel.scrollFrame)
    entry:SetSize(574, 24)
    entry:SetPoint("TOPLEFT", 5, -(i-1) * 26)
    
    -- Columns
    entry.icon = entry:CreateTexture(nil, "ARTWORK")
    entry.icon:SetSize(20, 20)
    entry.icon:SetPoint("LEFT", 5, 0)
    entry.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Trim default border
    
    entry.item = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    entry.item:SetSize(190, 24)
    entry.item:SetPoint("LEFT", entry.icon, "RIGHT", 5, 0)
    entry.item:SetJustifyH("LEFT")
    
    entry.quantity = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    entry.quantity:SetSize(70, 24)
    entry.quantity:SetPoint("LEFT", entry.item, "RIGHT", 5, 0)
    entry.quantity:SetJustifyH("RIGHT")
    
    entry.price = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    entry.price:SetSize(100, 24)
    entry.price:SetPoint("LEFT", entry.quantity, "RIGHT", 5, 0)
    entry.price:SetJustifyH("RIGHT")
    
    entry.date = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    entry.date:SetSize(120, 24)
    entry.date:SetPoint("LEFT", entry.price, "RIGHT", 5, 0)
    entry.date:SetJustifyH("RIGHT")
    
    entry.buyer = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    entry.buyer:SetSize(80, 24)
    entry.buyer:SetPoint("LEFT", entry.date, "RIGHT", 5, 0)
    entry.buyer:SetJustifyH("LEFT")
    
    entry:SetScript("OnEnter", function(self)
      -- Show tooltip
      if self.sale and self.sale.itemLink then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink(self.sale.itemLink)
        
        -- Add sale info to tooltip
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(Auctionator.L.SOLD .. ": " .. Auctionator.Utilities.FormatMoney(self.sale.price))
        if self.sale.quantity > 1 then
          GameTooltip:AddLine(Auctionator.L.UNIT_PRICE .. ": " .. Auctionator.Utilities.FormatMoney(self.sale.unitPrice))
        end
        GameTooltip:Show()
      end
      
      -- Highlight row
      self:SetBackdropColor(0.3, 0.3, 0.3, 0.3)
    end)
    
    entry:SetScript("OnLeave", function(self)
      GameTooltip:Hide()
      self:SetBackdropColor(0, 0, 0, 0)
    end)
    
    -- Highlight effect
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
    
    panel.entries[i] = entry
  end
  
  -- Update scroll handler
  panel.scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
    FauxScrollFrame_OnVerticalScroll(self, offset, 26, function()
      Auctionator.UI.HistoryPanel:UpdateSalesDisplay()
    end)
  end)
  
  -- Status footer
  panel.statusFrame = CreateFrame("Frame", panel:GetName() .. "StatusFrame", panel)
  panel.statusFrame:SetSize(600, 30)
  panel.statusFrame:SetPoint("BOTTOM", 0, 0)
  
  panel.statusText = panel.statusFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  panel.statusText:SetPoint("LEFT", 14, 0)
  panel.statusText:SetText("")
  
  -- Purge button
  panel.purgeButton = CreateFrame("Button", panel.statusFrame:GetName() .. "PurgeButton", panel.statusFrame, "VUIAuctionatorButtonTemplate")
  panel.purgeButton:SetSize(120, 22)
  panel.purgeButton:SetPoint("RIGHT", -14, 0)
  panel.purgeButton:SetText(Auctionator.L.RESET)
  
  panel.purgeButton:SetScript("OnClick", function()
    self:PurgeHistory()
  end)
end

-- Create the purchases history panel
function Auctionator.UI.HistoryPanel:CreatePurchasesPanel(panel)
  -- Copy the sales panel structure for the purchases panel
  -- (Same structure but different data will be displayed)
  
  -- List header
  panel.listHeader = CreateFrame("Frame", panel:GetName() .. "ListHeader", panel)
  panel.listHeader:SetSize(600, 30)
  panel.listHeader:SetPoint("TOPLEFT", 0, -40)
  
  -- Header background
  panel.headerBackground = panel.listHeader:CreateTexture(nil, "BACKGROUND")
  panel.headerBackground:SetAllPoints()
  panel.headerBackground:SetColorTexture(0.1, 0.1, 0.1, 0.8)
  
  -- Header columns
  panel.columnLabels = {}
  local columns = {
    {text = Auctionator.L.ITEMS, width = 220, justifyH = "LEFT"},
    {text = Auctionator.L.QUANTITY, width = 70, justifyH = "RIGHT"},
    {text = Auctionator.L.PRICE, width = 100, justifyH = "RIGHT"},
    {text = Auctionator.L.DATE, width = 120, justifyH = "RIGHT"},
    {text = Auctionator.L.SELLER, width = 80, justifyH = "LEFT"}
  }
  
  local offset = 10
  for i, col in ipairs(columns) do
    local label = panel.listHeader:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetSize(col.width, 20)
    label:SetPoint("TOPLEFT", offset, -5)
    label:SetJustifyH(col.justifyH)
    label:SetText(ITEM_QUALITY_COLORS[1].hex .. col.text .. "|r")
    
    panel.columnLabels[i] = label
    offset = offset + col.width + 5
  end
  
  -- Purchases list scroll frame
  panel.scrollFrame = CreateFrame("ScrollFrame", panel:GetName() .. "ScrollFrame", panel, "FauxScrollFrameTemplate")
  panel.scrollFrame:SetSize(574, 380)
  panel.scrollFrame:SetPoint("TOPLEFT", panel.listHeader, "BOTTOMLEFT", 0, 0)
  
  -- Purchases entries
  panel.entries = {}
  for i = 1, 15 do
    local entry = CreateFrame("Button", panel.scrollFrame:GetName() .. "Entry" .. i, panel.scrollFrame)
    entry:SetSize(574, 24)
    entry:SetPoint("TOPLEFT", 5, -(i-1) * 26)
    
    -- Columns
    entry.icon = entry:CreateTexture(nil, "ARTWORK")
    entry.icon:SetSize(20, 20)
    entry.icon:SetPoint("LEFT", 5, 0)
    entry.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Trim default border
    
    entry.item = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    entry.item:SetSize(190, 24)
    entry.item:SetPoint("LEFT", entry.icon, "RIGHT", 5, 0)
    entry.item:SetJustifyH("LEFT")
    
    entry.quantity = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    entry.quantity:SetSize(70, 24)
    entry.quantity:SetPoint("LEFT", entry.item, "RIGHT", 5, 0)
    entry.quantity:SetJustifyH("RIGHT")
    
    entry.price = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    entry.price:SetSize(100, 24)
    entry.price:SetPoint("LEFT", entry.quantity, "RIGHT", 5, 0)
    entry.price:SetJustifyH("RIGHT")
    
    entry.date = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    entry.date:SetSize(120, 24)
    entry.date:SetPoint("LEFT", entry.price, "RIGHT", 5, 0)
    entry.date:SetJustifyH("RIGHT")
    
    entry.seller = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    entry.seller:SetSize(80, 24)
    entry.seller:SetPoint("LEFT", entry.date, "RIGHT", 5, 0)
    entry.seller:SetJustifyH("LEFT")
    
    entry:SetScript("OnEnter", function(self)
      -- Show tooltip
      if self.purchase and self.purchase.itemLink then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink(self.purchase.itemLink)
        
        -- Add purchase info to tooltip
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(Auctionator.L.BUY .. ": " .. Auctionator.Utilities.FormatMoney(self.purchase.price))
        if self.purchase.quantity > 1 then
          GameTooltip:AddLine(Auctionator.L.UNIT_PRICE .. ": " .. Auctionator.Utilities.FormatMoney(self.purchase.unitPrice))
        end
        GameTooltip:Show()
      end
      
      -- Highlight row
      self:SetBackdropColor(0.3, 0.3, 0.3, 0.3)
    end)
    
    entry:SetScript("OnLeave", function(self)
      GameTooltip:Hide()
      self:SetBackdropColor(0, 0, 0, 0)
    end)
    
    -- Highlight effect
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
    
    panel.entries[i] = entry
  end
  
  -- Update scroll handler
  panel.scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
    FauxScrollFrame_OnVerticalScroll(self, offset, 26, function()
      Auctionator.UI.HistoryPanel:UpdatePurchasesDisplay()
    end)
  end)
  
  -- Status footer
  panel.statusFrame = CreateFrame("Frame", panel:GetName() .. "StatusFrame", panel)
  panel.statusFrame:SetSize(600, 30)
  panel.statusFrame:SetPoint("BOTTOM", 0, 0)
  
  panel.statusText = panel.statusFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  panel.statusText:SetPoint("LEFT", 14, 0)
  panel.statusText:SetText("")
  
  -- Purge button
  panel.purgeButton = CreateFrame("Button", panel.statusFrame:GetName() .. "PurgeButton", panel.statusFrame, "VUIAuctionatorButtonTemplate")
  panel.purgeButton:SetSize(120, 22)
  panel.purgeButton:SetPoint("RIGHT", -14, 0)
  panel.purgeButton:SetText(Auctionator.L.RESET)
  
  panel.purgeButton:SetScript("OnClick", function()
    self:PurgeHistory()
  end)
end

-- Register for events
function Auctionator.UI.HistoryPanel:RegisterEvents()
  -- History events
  Auctionator.EventBus:Register({}, Auctionator.History.Events.SALE_ADDED, function(_, sale)
    if self.currentTab == 1 then
      self:UpdateSalesDisplay()
    end
  end)
  
  Auctionator.EventBus:Register({}, Auctionator.History.Events.PURCHASE_ADDED, function(_, purchase)
    if self.currentTab == 2 then
      self:UpdatePurchasesDisplay()
    end
  end)
  
  Auctionator.EventBus:Register({}, Auctionator.History.Events.HISTORY_PURGED, function()
    if self.currentTab == 1 then
      self:UpdateSalesDisplay()
    else
      self:UpdatePurchasesDisplay()
    end
  end)
  
  -- AH events
  Auctionator.EventBus:Register({}, Auctionator.AuctionHouse.Events.AUCTION_HOUSE_SHOW, function()
    -- Update the display when AH opens
    if self.currentTab == 1 then
      self:UpdateSalesDisplay()
    else
      self:UpdatePurchasesDisplay()
    end
  end)
end

-- Select a tab
function Auctionator.UI.HistoryPanel:SelectTab(tabIndex)
  -- Hide all panels
  for i, panel in ipairs(self.panels) do
    panel:Hide()
    
    -- Update tab appearance
    for _, region in ipairs({self.tabs[i]:GetRegions()}) do
      if region:GetName() and region:GetName():find("Disabled") then
        region:Hide()
      end
    end
    
    self.tabs[i]:SetNormalFontObject("GameFontNormalSmall")
  end
  
  -- Show selected panel
  self.panels[tabIndex]:Show()
  
  -- Update selected tab appearance
  for _, region in ipairs({self.tabs[tabIndex]:GetRegions()}) do
    if region:GetName() and region:GetName():find("Disabled") then
      region:Show()
    end
  end
  
  self.tabs[tabIndex]:SetNormalFontObject("GameFontHighlightSmall")
  
  -- Store current tab
  self.currentTab = tabIndex
  
  -- Update the appropriate display
  if tabIndex == 1 then
    self:UpdateSalesDisplay()
  else
    self:UpdatePurchasesDisplay()
  end
end

-- Perform a search on history
function Auctionator.UI.HistoryPanel:PerformSearch()
  local searchText = self.searchBox:GetText():lower():trim()
  
  if searchText == "" then
    -- Clear search filter
    self.searchFilter = nil
  else
    -- Set search filter
    self.searchFilter = searchText
  end
  
  -- Update display
  if self.currentTab == 1 then
    self:UpdateSalesDisplay()
  else
    self:UpdatePurchasesDisplay()
  end
end

-- Update sales history display
function Auctionator.UI.HistoryPanel:UpdateSalesDisplay()
  local panel = self.panels[1]
  
  -- Get sales history
  local sales = {}
  
  if Auctionator.History and Auctionator.History.salesHistory then
    -- Create a copy so we can sort it
    for _, sale in ipairs(Auctionator.History.salesHistory) do
      -- Apply search filter if active
      if not self.searchFilter or (sale.itemLink and 
         Auctionator.Utilities.ItemInfo.GetItemName(sale.itemLink):lower():find(self.searchFilter)) then
        table.insert(sales, sale)
      end
    end
    
    -- Sort by timestamp, newest first
    table.sort(sales, function(a, b)
      return (a.timestamp or 0) > (b.timestamp or 0)
    end)
  end
  
  -- Update status
  panel.statusText:SetText(string.format(Auctionator.L.RESULTS .. ": %d", #sales))
  
  -- Update scroll frame
  FauxScrollFrame_Update(panel.scrollFrame, #sales, 15, 26)
  local offset = FauxScrollFrame_GetOffset(panel.scrollFrame)
  
  -- Update entries
  for i = 1, 15 do
    local entry = panel.entries[i]
    local index = i + offset
    
    if index <= #sales then
      local sale = sales[index]
      
      -- Set data
      entry.sale = sale
      
      -- Set visual elements
      entry.icon:SetTexture(Auctionator.Utilities.ItemInfo.GetItemIconTexture(sale.itemLink) or "Interface\\Icons\\INV_Misc_QuestionMark")
      
      local itemName = Auctionator.Utilities.ItemInfo.GetItemName(sale.itemLink) or "Unknown Item"
      local quality = Auctionator.Utilities.ItemInfo.GetItemRarity(sale.itemLink)
      
      if quality and ITEM_QUALITY_COLORS[quality] then
        local color = ITEM_QUALITY_COLORS[quality]
        entry.item:SetText(color.hex .. itemName .. "|r")
      else
        entry.item:SetText(itemName)
      end
      
      entry.quantity:SetText(sale.quantity)
      entry.price:SetText(Auctionator.Utilities.FormatMoney(sale.price))
      
      -- Format date
      local dateText
      if sale.timestamp then
        dateText = Auctionator.Utilities.RelativeTime(sale.timestamp)
      else
        dateText = "Unknown"
      end
      entry.date:SetText(dateText)
      
      -- Buyer (often unknown in WoW's auction system)
      entry.buyer:SetText(sale.buyer or "")
      
      entry:Show()
    else
      entry.sale = nil
      entry:Hide()
    end
  end
end

-- Update purchases history display
function Auctionator.UI.HistoryPanel:UpdatePurchasesDisplay()
  local panel = self.panels[2]
  
  -- Get purchase history
  local purchases = {}
  
  if Auctionator.History and Auctionator.History.purchaseHistory then
    -- Create a copy so we can sort it
    for _, purchase in ipairs(Auctionator.History.purchaseHistory) do
      -- Apply search filter if active
      if not self.searchFilter or (purchase.itemLink and 
         Auctionator.Utilities.ItemInfo.GetItemName(purchase.itemLink):lower():find(self.searchFilter)) then
        table.insert(purchases, purchase)
      end
    end
    
    -- Sort by timestamp, newest first
    table.sort(purchases, function(a, b)
      return (a.timestamp or 0) > (b.timestamp or 0)
    end)
  end
  
  -- Update status
  panel.statusText:SetText(string.format(Auctionator.L.RESULTS .. ": %d", #purchases))
  
  -- Update scroll frame
  FauxScrollFrame_Update(panel.scrollFrame, #purchases, 15, 26)
  local offset = FauxScrollFrame_GetOffset(panel.scrollFrame)
  
  -- Update entries
  for i = 1, 15 do
    local entry = panel.entries[i]
    local index = i + offset
    
    if index <= #purchases then
      local purchase = purchases[index]
      
      -- Set data
      entry.purchase = purchase
      
      -- Set visual elements
      entry.icon:SetTexture(Auctionator.Utilities.ItemInfo.GetItemIconTexture(purchase.itemLink) or "Interface\\Icons\\INV_Misc_QuestionMark")
      
      local itemName = Auctionator.Utilities.ItemInfo.GetItemName(purchase.itemLink) or "Unknown Item"
      local quality = Auctionator.Utilities.ItemInfo.GetItemRarity(purchase.itemLink)
      
      if quality and ITEM_QUALITY_COLORS[quality] then
        local color = ITEM_QUALITY_COLORS[quality]
        entry.item:SetText(color.hex .. itemName .. "|r")
      else
        entry.item:SetText(itemName)
      end
      
      entry.quantity:SetText(purchase.quantity)
      entry.price:SetText(Auctionator.Utilities.FormatMoney(purchase.price))
      
      -- Format date
      local dateText
      if purchase.timestamp then
        dateText = Auctionator.Utilities.RelativeTime(purchase.timestamp)
      else
        dateText = "Unknown"
      end
      entry.date:SetText(dateText)
      
      -- Seller
      entry.seller:SetText(purchase.seller or "")
      
      entry:Show()
    else
      entry.purchase = nil
      entry:Hide()
    end
  end
end

-- Purge history data
function Auctionator.UI.HistoryPanel:PurgeHistory()
  StaticPopupDialogs["VUIAUCTIONATOR_PURGE_HISTORY"] = {
    text = "Are you sure you want to delete all history data?",
    button1 = Auctionator.L.DELETE,
    button2 = Auctionator.L.CANCEL,
    OnAccept = function()
      -- Call the purge function
      if Auctionator.History and Auctionator.History.PurgeOldHistory then
        Auctionator.History:PurgeOldHistory()
      end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
  }
  
  StaticPopup_Show("VUIAUCTIONATOR_PURGE_HISTORY")
end

-- Show the history panel
function Auctionator.UI.HistoryPanel:Show()
  self.frame:Show()
  
  -- Update the current display
  if self.currentTab == 1 then
    self:UpdateSalesDisplay()
  else
    self:UpdatePurchasesDisplay()
  end
end

-- Hide the history panel
function Auctionator.UI.HistoryPanel:Hide()
  self.frame:Hide()
end