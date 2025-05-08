local addonName, VUI = ...
local Auctionator = VUI.Auctionator

-- Create the Browse Panel component
Auctionator.UI = Auctionator.UI or {}
Auctionator.UI.BrowsePanel = {}

-- Initialize the browse panel
function Auctionator.UI.BrowsePanel:Initialize()
  -- Create the main frame
  self.frame = CreateFrame("Frame", "VUIAuctionatorBrowsePanel", nil)
  self.frame:SetSize(600, 520)
  self.frame:SetPoint("TOPLEFT", 0, 0)
  self.frame:Hide()
  
  -- Set up the panel
  self:CreatePanelStructure()
  
  -- Register events
  self:RegisterEvents()
end

-- Create the structure of the browse panel
function Auctionator.UI.BrowsePanel:CreatePanelStructure()
  -- Header frame
  self.headerFrame = CreateFrame("Frame", self.frame:GetName() .. "Header", self.frame)
  self.headerFrame:SetSize(600, 40)
  self.headerFrame:SetPoint("TOPLEFT", 0, 0)
  
  -- Title
  self.title = self.headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  self.title:SetPoint("TOPLEFT", 14, -8)
  self.title:SetText(Auctionator.L.AUCTIONATOR)
  
  -- Search box
  self.searchBox = CreateFrame("EditBox", self.headerFrame:GetName() .. "SearchBox", self.headerFrame, "VUIAuctionatorEditBoxTemplate")
  self.searchBox:SetSize(300, 22)
  self.searchBox:SetPoint("TOPRIGHT", -100, -9)
  self.searchBox:SetAutoFocus(false)
  
  -- Search label
  self.searchLabel = self.headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  self.searchLabel:SetPoint("RIGHT", self.searchBox, "LEFT", -8, 0)
  self.searchLabel:SetText(Auctionator.L.SEARCH)
  
  -- Search button
  self.searchButton = CreateFrame("Button", self.headerFrame:GetName() .. "SearchButton", self.headerFrame, "VUIAuctionatorButtonTemplate")
  self.searchButton:SetSize(80, 22)
  self.searchButton:SetPoint("LEFT", self.searchBox, "RIGHT", 8, 0)
  self.searchButton:SetText(Auctionator.L.SEARCH)
  
  -- Main content frame
  self.contentFrame = CreateFrame("Frame", self.frame:GetName() .. "Content", self.frame)
  self.contentFrame:SetSize(600, 480)
  self.contentFrame:SetPoint("TOP", self.headerFrame, "BOTTOM", 0, 0)
  
  -- Results frame
  self.resultsFrame = CreateFrame("Frame", self.contentFrame:GetName() .. "Results", self.contentFrame)
  self.resultsFrame:SetSize(600, 420)
  self.resultsFrame:SetPoint("TOP", 0, 0)
  
  -- Results headers
  self:CreateResultsHeaders()
  
  -- Results scrolling list
  self.resultsList = CreateFrame("ScrollFrame", self.resultsFrame:GetName() .. "List", self.resultsFrame, "FauxScrollFrameTemplate")
  self.resultsList:SetSize(560, 390)
  self.resultsList:SetPoint("TOPLEFT", 0, -30)
  
  -- Create result row templates
  self.resultRows = {}
  for i = 1, 10 do
    local row = CreateFrame("Button", self.resultsList:GetName() .. "Row" .. i, self.resultsList)
    row:SetSize(560, 30)
    row:SetPoint("TOPLEFT", 0, -30 * (i-1) - 2)
    
    row.item = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.item:SetJustifyH("LEFT")
    row.item:SetSize(200, 30)
    row.item:SetPoint("LEFT", 5, 0)
    
    row.quantity = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.quantity:SetJustifyH("RIGHT")
    row.quantity:SetSize(60, 30)
    row.quantity:SetPoint("LEFT", row.item, "RIGHT", 5, 0)
    
    row.bid = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.bid:SetJustifyH("RIGHT")
    row.bid:SetSize(80, 30)
    row.bid:SetPoint("LEFT", row.quantity, "RIGHT", 5, 0)
    
    row.buyout = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.buyout:SetJustifyH("RIGHT")
    row.buyout:SetSize(80, 30)
    row.buyout:SetPoint("LEFT", row.bid, "RIGHT", 5, 0)
    
    row.unitPrice = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.unitPrice:SetJustifyH("RIGHT")
    row.unitPrice:SetSize(80, 30)
    row.unitPrice:SetPoint("LEFT", row.buyout, "RIGHT", 5, 0)
    
    row:SetScript("OnEnter", function(self)
      self:SetBackdropColor(0.3, 0.3, 0.3, 0.3)
      
      -- Show item tooltip
      if self.itemLink then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink(self.itemLink)
        GameTooltip:Show()
      end
    end)
    
    row:SetScript("OnLeave", function(self)
      self:SetBackdropColor(0, 0, 0, 0)
      GameTooltip:Hide()
    end)
    
    row:SetScript("OnClick", function(self)
      -- Handle row click
      if self.auctionData then
        -- Select the auction
        Auctionator.UI.BrowsePanel:SelectAuction(self.auctionData)
      end
    end)
    
    -- Create highlight effect
    row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    
    -- Background
    row:SetBackdrop({
      bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
      edgeFile = nil,
      tile = true,
      tileSize = 16,
      edgeSize = 0,
      insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    row:SetBackdropColor(0, 0, 0, 0)
    
    self.resultRows[i] = row
  end
  
  -- Status frame
  self.statusFrame = CreateFrame("Frame", self.contentFrame:GetName() .. "Status", self.contentFrame)
  self.statusFrame:SetSize(600, 60)
  self.statusFrame:SetPoint("BOTTOM", 0, 0)
  
  -- Status text
  self.statusText = self.statusFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  self.statusText:SetPoint("LEFT", 14, 0)
  self.statusText:SetText("")
  
  -- Full scan button
  self.fullScanButton = CreateFrame("Button", self.statusFrame:GetName() .. "FullScanButton", self.statusFrame, "VUIAuctionatorButtonTemplate")
  self.fullScanButton:SetSize(100, 22)
  self.fullScanButton:SetPoint("RIGHT", -14, 0)
  self.fullScanButton:SetText(Auctionator.L.FULL_SCAN)
  
  -- Refresh button
  self.refreshButton = CreateFrame("Button", self.statusFrame:GetName() .. "RefreshButton", self.statusFrame, "VUIAuctionatorButtonTemplate")
  self.refreshButton:SetSize(100, 22)
  self.refreshButton:SetPoint("RIGHT", self.fullScanButton, "LEFT", -10, 0)
  self.refreshButton:SetText(Auctionator.L.REFRESH)
  
  -- Set up button handlers
  self:SetupInteraction()
end

-- Create headers for the results listing
function Auctionator.UI.BrowsePanel:CreateResultsHeaders()
  -- Header background
  self.headerBackground = self.resultsFrame:CreateTexture(nil, "BACKGROUND")
  self.headerBackground:SetPoint("TOPLEFT", 0, 0)
  self.headerBackground:SetPoint("TOPRIGHT", 0, 0)
  self.headerBackground:SetHeight(30)
  self.headerBackground:SetColorTexture(0.1, 0.1, 0.1, 0.8)
  
  -- Header labels
  self.itemHeader = self.resultsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  self.itemHeader:SetPoint("TOPLEFT", 5, -8)
  self.itemHeader:SetSize(200, 18)
  self.itemHeader:SetJustifyH("LEFT")
  self.itemHeader:SetText(ITEM_QUALITY_COLORS[1].hex .. Auctionator.L.ITEMS .. "|r")
  
  self.quantityHeader = self.resultsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  self.quantityHeader:SetPoint("LEFT", self.itemHeader, "RIGHT", 5, 0)
  self.quantityHeader:SetSize(60, 18)
  self.quantityHeader:SetJustifyH("RIGHT")
  self.quantityHeader:SetText(ITEM_QUALITY_COLORS[1].hex .. Auctionator.L.QUANTITY .. "|r")
  
  self.bidHeader = self.resultsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  self.bidHeader:SetPoint("LEFT", self.quantityHeader, "RIGHT", 5, 0)
  self.bidHeader:SetSize(80, 18)
  self.bidHeader:SetJustifyH("RIGHT")
  self.bidHeader:SetText(ITEM_QUALITY_COLORS[1].hex .. Auctionator.L.BID .. "|r")
  
  self.buyoutHeader = self.resultsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  self.buyoutHeader:SetPoint("LEFT", self.bidHeader, "RIGHT", 5, 0)
  self.buyoutHeader:SetSize(80, 18)
  self.buyoutHeader:SetJustifyH("RIGHT")
  self.buyoutHeader:SetText(ITEM_QUALITY_COLORS[1].hex .. Auctionator.L.BUYOUT .. "|r")
  
  self.unitPriceHeader = self.resultsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  self.unitPriceHeader:SetPoint("LEFT", self.buyoutHeader, "RIGHT", 5, 0)
  self.unitPriceHeader:SetSize(80, 18)
  self.unitPriceHeader:SetJustifyH("RIGHT")
  self.unitPriceHeader:SetText(ITEM_QUALITY_COLORS[1].hex .. Auctionator.L.UNIT_PRICE .. "|r")
end

-- Set up interaction handlers
function Auctionator.UI.BrowsePanel:SetupInteraction()
  -- Search button
  self.searchButton:SetScript("OnClick", function()
    self:PerformSearch()
  end)
  
  -- Search box enter press
  self.searchBox:SetScript("OnEnterPressed", function()
    self:PerformSearch()
  end)
  
  -- Full scan button
  self.fullScanButton:SetScript("OnClick", function()
    self:PerformFullScan()
  end)
  
  -- Refresh button
  self.refreshButton:SetScript("OnClick", function()
    self:RefreshResults()
  end)
  
  -- Results list scroll
  self.resultsList:SetScript("OnVerticalScroll", function(self, offset)
    FauxScrollFrame_OnVerticalScroll(self, offset, 30, function()
      Auctionator.UI.BrowsePanel:UpdateResults()
    end)
  end)
end

-- Register for events
function Auctionator.UI.BrowsePanel:RegisterEvents()
  -- Register for search events
  Auctionator.EventBus:Register({}, Auctionator.Search.Events.SEARCH_STARTED, function()
    self:SetStatus(Auctionator.L.SEARCHING)
    self.searchButton:Disable()
    self.fullScanButton:Disable()
    self.refreshButton:Disable()
  end)
  
  Auctionator.EventBus:Register({}, Auctionator.Search.Events.SEARCH_COMPLETE, function(_, searchData)
    self:SetStatus(Auctionator.L.MSG_SCAN_COMPLETE)
    self.searchButton:Enable()
    self.fullScanButton:Enable()
    self.refreshButton:Enable()
    
    -- Update results display
    self:SetResults(searchData.results)
  end)
  
  Auctionator.EventBus:Register({}, Auctionator.Search.Events.SEARCH_FAILED, function(_, searchData)
    self:SetStatus(string.format(Auctionator.L.MSG_SCAN_FAILED, searchData.error or ""))
    self.searchButton:Enable()
    self.fullScanButton:Enable()
    self.refreshButton:Enable()
  end)
end

-- Perform a search
function Auctionator.UI.BrowsePanel:PerformSearch()
  local searchText = self.searchBox:GetText()
  
  if searchText and searchText ~= "" then
    -- Clear previous results
    self:SetResults({})
    
    -- Start search
    Auctionator.Search:StartSearch(searchText, false)
  end
end

-- Perform a full scan
function Auctionator.UI.BrowsePanel:PerformFullScan()
  -- Clear previous results
  self:SetResults({})
  
  -- This would be implemented with more advanced scanning logic
  -- For now, just do a simple broad search
  Auctionator.Search:StartSearch("", false)
end

-- Refresh current results
function Auctionator.UI.BrowsePanel:RefreshResults()
  local searchText = self.searchBox:GetText()
  
  if searchText and searchText ~= "" then
    self:PerformSearch()
  else
    self:PerformFullScan()
  end
end

-- Set status text
function Auctionator.UI.BrowsePanel:SetStatus(text)
  self.statusText:SetText(text)
end

-- Current search results
Auctionator.UI.BrowsePanel.currentResults = {}

-- Set search results
function Auctionator.UI.BrowsePanel:SetResults(results)
  self.currentResults = results or {}
  
  -- Update the display
  self:UpdateResults()
end

-- Update results display
function Auctionator.UI.BrowsePanel:UpdateResults()
  -- Get scroll info
  local offset = FauxScrollFrame_GetOffset(self.resultsList)
  local numResults = #self.currentResults
  
  -- Update scroll frame
  FauxScrollFrame_Update(self.resultsList, numResults, 10, 30)
  
  -- Update status
  self:SetStatus(string.format(Auctionator.L.RESULTS .. ": %d", numResults))
  
  -- Update row display
  for i = 1, 10 do
    local row = self.resultRows[i]
    local dataIndex = i + offset
    
    if dataIndex <= numResults then
      local auctionData = self.currentResults[dataIndex]
      
      -- Set row data
      row.item:SetText(auctionData.itemLink or "[Unknown Item]")
      row.quantity:SetText(auctionData.quantity)
      row.bid:SetText(Auctionator.Utilities.FormatMoney(auctionData.bidAmount or 0))
      row.buyout:SetText(Auctionator.Utilities.FormatMoney(auctionData.buyoutAmount or 0))
      row.unitPrice:SetText(Auctionator.Utilities.FormatMoney(auctionData.unitPrice or 0))
      
      -- Store auction data reference
      row.auctionData = auctionData
      row.itemLink = auctionData.itemLink
      
      -- Color based on item quality
      if auctionData.itemLink then
        local quality = Auctionator.Utilities.ItemInfo.GetItemRarity(auctionData.itemLink)
        if quality and ITEM_QUALITY_COLORS[quality] then
          local color = ITEM_QUALITY_COLORS[quality]
          row.item:SetTextColor(color.r, color.g, color.b)
        else
          row.item:SetTextColor(1, 1, 1)
        end
      else
        row.item:SetTextColor(1, 1, 1)
      end
      
      -- Show the row
      row:Show()
    else
      -- Hide unused rows
      row.auctionData = nil
      row.itemLink = nil
      row:Hide()
    end
  end
end

-- Select an auction
function Auctionator.UI.BrowsePanel:SelectAuction(auctionData)
  -- This would be implemented to show auction details and buying options
  -- For now, just announce the selection
  self:SetStatus(Auctionator.L.SELECTED .. ": " .. 
    (Auctionator.Utilities.ItemInfo.GetItemName(auctionData.itemLink) or "Unknown Item"))
  
  -- Dispatch selection event
  Auctionator.EventBus:Fire({}, "AUCTION_SELECTED", auctionData)
end

-- Show the browse panel
function Auctionator.UI.BrowsePanel:Show()
  self.frame:Show()
end

-- Hide the browse panel
function Auctionator.UI.BrowsePanel:Hide()
  self.frame:Hide()
end