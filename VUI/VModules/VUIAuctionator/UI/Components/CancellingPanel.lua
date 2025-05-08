local addonName, VUI = ...
local Auctionator = VUI.Auctionator

-- Create the Cancelling Panel component
Auctionator.UI = Auctionator.UI or {}
Auctionator.UI.CancellingPanel = {}

-- Initialize the cancelling panel
function Auctionator.UI.CancellingPanel:Initialize()
  -- Create the main frame
  self.frame = CreateFrame("Frame", "VUIAuctionatorCancellingPanel", nil)
  self.frame:SetSize(600, 520)
  self.frame:SetPoint("TOPLEFT", 0, 0)
  self.frame:Hide()
  
  -- Set up the panel
  self:CreatePanelStructure()
  
  -- Register events
  self:RegisterEvents()
end

-- Create the structure of the cancelling panel
function Auctionator.UI.CancellingPanel:CreatePanelStructure()
  -- Header frame
  self.headerFrame = CreateFrame("Frame", self.frame:GetName() .. "Header", self.frame)
  self.headerFrame:SetSize(600, 40)
  self.headerFrame:SetPoint("TOPLEFT", 0, 0)
  
  -- Title
  self.title = self.headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  self.title:SetPoint("TOPLEFT", 14, -8)
  self.title:SetText(Auctionator.L.CANCEL)
  
  -- Refresh button
  self.refreshButton = CreateFrame("Button", self.headerFrame:GetName() .. "RefreshButton", self.headerFrame, "VUIAuctionatorButtonTemplate")
  self.refreshButton:SetSize(100, 22)
  self.refreshButton:SetPoint("TOPRIGHT", -14, -9)
  self.refreshButton:SetText(Auctionator.L.REFRESH)
  
  -- Undercut scan button
  self.undercutButton = CreateFrame("Button", self.headerFrame:GetName() .. "UndercutButton", self.headerFrame, "VUIAuctionatorButtonTemplate")
  self.undercutButton:SetSize(140, 22)
  self.undercutButton:SetPoint("RIGHT", self.refreshButton, "LEFT", -10, 0)
  self.undercutButton:SetText(Auctionator.L.UNDERCUT .. " " .. Auctionator.L.SCAN)
  
  -- Main content frame
  self.contentFrame = CreateFrame("Frame", self.frame:GetName() .. "Content", self.frame)
  self.contentFrame:SetSize(600, 480)
  self.contentFrame:SetPoint("TOP", self.headerFrame, "BOTTOM", 0, 0)
  
  -- Auction list header
  self.listHeader = CreateFrame("Frame", self.contentFrame:GetName() .. "ListHeader", self.contentFrame)
  self.listHeader:SetSize(600, 30)
  self.listHeader:SetPoint("TOPLEFT", 0, 0)
  
  -- Header background
  self.headerBackground = self.listHeader:CreateTexture(nil, "BACKGROUND")
  self.headerBackground:SetAllPoints()
  self.headerBackground:SetColorTexture(0.1, 0.1, 0.1, 0.8)
  
  -- Header columns
  self.columnLabels = {}
  local columns = {
    {text = Auctionator.L.ITEMS, width = 220, justifyH = "LEFT"},
    {text = Auctionator.L.QUANTITY, width = 70, justifyH = "RIGHT"},
    {text = Auctionator.L.TIME_LEFT, width = 80, justifyH = "RIGHT"},
    {text = Auctionator.L.PRICE, width = 100, justifyH = "RIGHT"},
    {text = Auctionator.L.STATUS, width = 120, justifyH = "CENTER"}
  }
  
  local offset = 10
  for i, col in ipairs(columns) do
    local label = self.listHeader:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetSize(col.width, 20)
    label:SetPoint("TOPLEFT", offset, -5)
    label:SetJustifyH(col.justifyH)
    label:SetText(ITEM_QUALITY_COLORS[1].hex .. col.text .. "|r")
    
    self.columnLabels[i] = label
    offset = offset + col.width + 5
  end
  
  -- Auction list
  self.listFrame = CreateFrame("Frame", self.contentFrame:GetName() .. "ListFrame", self.contentFrame)
  self.listFrame:SetSize(600, 400)
  self.listFrame:SetPoint("TOPLEFT", self.listHeader, "BOTTOMLEFT", 0, 0)
  
  -- Auction list scroll frame
  self.listScroll = CreateFrame("ScrollFrame", self.listFrame:GetName() .. "Scroll", self.listFrame, "FauxScrollFrameTemplate")
  self.listScroll:SetSize(574, 400)
  self.listScroll:SetPoint("TOPLEFT", 0, 0)
  
  -- Auction rows
  self.auctionRows = {}
  for i = 1, 10 do
    local row = CreateFrame("Button", self.listScroll:GetName() .. "Row" .. i, self.listScroll)
    row:SetSize(574, 30)
    row:SetPoint("TOPLEFT", 5, -(i-1) * 40)
    
    row.item = {}
    row.item.frame = CreateFrame("Frame", row:GetName() .. "Item", row)
    row.item.frame:SetSize(220, 30)
    row.item.frame:SetPoint("LEFT", 0, 0)
    
    row.item.icon = row.item.frame:CreateTexture(nil, "ARTWORK")
    row.item.icon:SetSize(30, 30)
    row.item.icon:SetPoint("LEFT", 0, 0)
    row.item.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Trim default border
    
    row.item.name = row.item.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.item.name:SetSize(180, 30)
    row.item.name:SetPoint("LEFT", row.item.icon, "RIGHT", 5, 0)
    row.item.name:SetJustifyH("LEFT")
    
    row.quantity = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.quantity:SetSize(70, 30)
    row.quantity:SetPoint("LEFT", row.item.frame, "RIGHT", 0, 0)
    row.quantity:SetJustifyH("RIGHT")
    
    row.timeLeft = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.timeLeft:SetSize(80, 30)
    row.timeLeft:SetPoint("LEFT", row.quantity, "RIGHT", 10, 0)
    row.timeLeft:SetJustifyH("RIGHT")
    
    row.price = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.price:SetSize(100, 30)
    row.price:SetPoint("LEFT", row.timeLeft, "RIGHT", 10, 0)
    row.price:SetJustifyH("RIGHT")
    
    row.status = CreateFrame("Frame", row:GetName() .. "Status", row)
    row.status:SetSize(120, 30)
    row.status:SetPoint("LEFT", row.price, "RIGHT", 10, 0)
    
    row.status.text = row.status:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.status.text:SetAllPoints()
    row.status.text:SetJustifyH("CENTER")
    
    row.cancelButton = CreateFrame("Button", row:GetName() .. "CancelButton", row.status, "VUIAuctionatorButtonTemplate")
    row.cancelButton:SetSize(80, 22)
    row.cancelButton:SetPoint("CENTER", 0, 0)
    row.cancelButton:SetText(Auctionator.L.CANCEL)
    row.cancelButton:Hide()
    
    row:SetScript("OnEnter", function(self)
      if self.itemLink then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink(self.itemLink)
        GameTooltip:Show()
      end
    end)
    
    row:SetScript("OnLeave", function()
      GameTooltip:Hide()
    end)
    
    -- Create highlighting effect
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
    row:SetBackdropColor(0, 0, 0, 0.4)
    
    self.auctionRows[i] = row
  end
  
  -- Footer frame
  self.footerFrame = CreateFrame("Frame", self.contentFrame:GetName() .. "Footer", self.contentFrame)
  self.footerFrame:SetSize(600, 50)
  self.footerFrame:SetPoint("BOTTOM", 0, 0)
  
  -- Status text
  self.statusText = self.footerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  self.statusText:SetPoint("LEFT", 14, 0)
  self.statusText:SetText("")
  
  -- Cancel all undercut button
  self.cancelAllButton = CreateFrame("Button", self.footerFrame:GetName() .. "CancelAllButton", self.footerFrame, "VUIAuctionatorButtonTemplate")
  self.cancelAllButton:SetSize(160, 22)
  self.cancelAllButton:SetPoint("RIGHT", -14, 0)
  self.cancelAllButton:SetText(Auctionator.L.CANCEL .. " " .. Auctionator.L.UNDERCUT)
  self.cancelAllButton:Disable() -- Disabled until undercuts are found
  
  -- Set up interaction
  self:SetupInteraction()
end

-- Set up interaction handlers
function Auctionator.UI.CancellingPanel:SetupInteraction()
  -- Refresh button
  self.refreshButton:SetScript("OnClick", function()
    self:RefreshAuctions()
  end)
  
  -- Undercut scan button
  self.undercutButton:SetScript("OnClick", function()
    self:ScanForUndercuts()
  end)
  
  -- Cancel all undercut button
  self.cancelAllButton:SetScript("OnClick", function()
    self:CancelAllUndercuts()
  end)
  
  -- List scroll
  self.listScroll:SetScript("OnVerticalScroll", function(self, offset)
    FauxScrollFrame_OnVerticalScroll(self, offset, 40, function()
      Auctionator.UI.CancellingPanel:UpdateAuctionList()
    end)
  end)
end

-- Register for events
function Auctionator.UI.CancellingPanel:RegisterEvents()
  -- Register for owned auctions update
  Auctionator.EventBus:Register({}, Auctionator.Cancel.Events.OWNED_AUCTIONS_UPDATED, function()
    self:UpdateAuctionList()
  end)
  
  -- Register for undercut scan events
  Auctionator.EventBus:Register({}, Auctionator.Cancel.Events.UNDERCUT_SCAN_SUCCESS, function(_, undercutAuctions)
    self:HandleUndercutScanComplete(undercutAuctions)
  end)
  
  Auctionator.EventBus:Register({}, Auctionator.Cancel.Events.UNDERCUT_SCAN_FAILURE, function(_, message)
    self:SetStatus(Auctionator.L.ERROR .. ": " .. (message or Auctionator.L.ERR_UNKNOWN))
    self.undercutButton:Enable()
  end)
  
  -- Register for auction cancelled event
  Auctionator.EventBus:Register({}, Auctionator.Cancel.Events.AUCTION_CANCELLED, function(_, auctionData)
    -- Mark this auction as being cancelled - will be reflected in the UI
    if not self.cancelledAuctions then
      self.cancelledAuctions = {}
    end
    
    self.cancelledAuctions[auctionData.auctionID] = true
    
    -- Update the list display
    self:UpdateAuctionList()
  end)
  
  -- Listen for auction house events
  Auctionator.EventBus:Register({}, Auctionator.AuctionHouse.Events.AUCTION_HOUSE_SHOW, function()
    -- Refresh auctions when AH opens
    C_Timer.After(0.5, function()
      self:RefreshAuctions()
    end)
  end)
end

-- Refresh owned auctions
function Auctionator.UI.CancellingPanel:RefreshAuctions()
  -- Set status
  self:SetStatus(Auctionator.L.LOADING)
  
  -- Disable buttons during refresh
  self.refreshButton:Disable()
  self.undercutButton:Disable()
  self.cancelAllButton:Disable()
  
  -- Clear any previous state
  self.cancelledAuctions = {}
  
  -- Refresh owned auctions
  if Auctionator.Cancel and Auctionator.Cancel.RefreshOwnedAuctions then
    Auctionator.Cancel:RefreshOwnedAuctions()
  end
  
  -- Re-enable buttons
  C_Timer.After(0.5, function()
    self.refreshButton:Enable()
    self.undercutButton:Enable()
  end)
end

-- Scan for undercuts
function Auctionator.UI.CancellingPanel:ScanForUndercuts()
  -- Set status
  self:SetStatus(Auctionator.L.SEARCHING)
  
  -- Disable buttons during scan
  self.refreshButton:Disable()
  self.undercutButton:Disable()
  self.cancelAllButton:Disable()
  
  -- Start undercut scan
  if Auctionator.Cancel and Auctionator.Cancel.ScanForUndercuts then
    Auctionator.Cancel:ScanForUndercuts()
  end
end

-- Handle undercut scan completion
function Auctionator.UI.CancellingPanel:HandleUndercutScanComplete(undercutAuctions)
  -- Re-enable buttons
  self.refreshButton:Enable()
  self.undercutButton:Enable()
  
  -- Update the listed auctions to highlight undercuts
  self:UpdateAuctionList()
  
  -- Enable cancel all button if there are undercuts
  if undercutAuctions and #undercutAuctions > 0 then
    self.cancelAllButton:Enable()
    self:SetStatus(string.format(Auctionator.L.WARNING_UNDERCUT_SCAN_COMPLETED, #undercutAuctions))
  else
    self.cancelAllButton:Disable()
    self:SetStatus(Auctionator.L.SUCCESS_NO_UNDERCUTS)
  end
end

-- Cancel all undercut auctions
function Auctionator.UI.CancellingPanel:CancelAllUndercuts()
  -- Disable button during operation
  self.cancelAllButton:Disable()
  
  -- Call the Cancel module's function
  if Auctionator.Cancel and Auctionator.Cancel.CancelAllUndercuts then
    Auctionator.Cancel:CancelAllUndercuts()
  end
end

-- Update auction list display
function Auctionator.UI.CancellingPanel:UpdateAuctionList()
  -- Get owned auctions
  local auctions = {}
  
  if Auctionator.Cancel and Auctionator.Cancel.ownedAuctions then
    auctions = Auctionator.Cancel.ownedAuctions
  end
  
  -- Get scroll frame offset
  local offset = FauxScrollFrame_GetOffset(self.listScroll)
  local numAuctions = #auctions
  
  -- Update scroll frame
  FauxScrollFrame_Update(self.listScroll, numAuctions, 10, 40)
  
  -- Update status text
  self:SetStatus(string.format(Auctionator.L.AUCTIONS .. ": %d", numAuctions))
  
  -- Update auction rows
  for i = 1, 10 do
    local row = self.auctionRows[i]
    local index = i + offset
    
    if index <= numAuctions then
      local auction = auctions[index]
      
      -- Set auction data
      row.itemLink = auction.itemLink
      row.auctionID = auction.auctionID
      
      -- Set item info
      row.item.icon:SetTexture(Auctionator.Utilities.ItemInfo.GetItemIconTexture(auction.itemLink) or "Interface\\Icons\\INV_Misc_QuestionMark")
      
      local itemName = Auctionator.Utilities.ItemInfo.GetItemName(auction.itemLink) or "Unknown Item"
      local quality = Auctionator.Utilities.ItemInfo.GetItemRarity(auction.itemLink)
      
      if quality and ITEM_QUALITY_COLORS[quality] then
        local color = ITEM_QUALITY_COLORS[quality]
        row.item.name:SetTextColor(color.r, color.g, color.b)
      else
        row.item.name:SetTextColor(1, 1, 1)
      end
      
      row.item.name:SetText(itemName)
      row.quantity:SetText(auction.quantity)
      
      -- Time left formatting
      local timeLeftText = Auctionator.Utilities.FormatTimeLeft(auction.timeLeft)
      row.timeLeft:SetText(timeLeftText)
      
      -- Price formatting
      row.price:SetText(Auctionator.Utilities.FormatMoney(auction.buyoutAmount))
      
      -- Status and cancel button
      if self.cancelledAuctions and self.cancelledAuctions[auction.auctionID] then
        -- This auction is being cancelled
        row.status.text:SetText(Auctionator.L.CANCEL .. "ing...")
        row.status.text:SetTextColor(1, 0.5, 0)
        row.cancelButton:Hide()
      elseif auction.isSold then
        -- Auction has been sold
        row.status.text:SetText(Auctionator.L.SUCCESS)
        row.status.text:SetTextColor(0, 1, 0)
        row.cancelButton:Hide()
      elseif auction.isUndercut then
        -- Auction is undercut
        row.status.text:SetText("")
        row.status.text:SetTextColor(1, 0, 0)
        
        -- Show and setup the cancel button
        row.cancelButton:Show()
        row.cancelButton:SetScript("OnClick", function()
          self:CancelAuction(auction.auctionID)
        end)
      else
        -- Normal auction
        row.status.text:SetText("")
        row.status.text:SetTextColor(1, 1, 1)
        
        -- Show and setup the cancel button
        row.cancelButton:Show()
        row.cancelButton:SetScript("OnClick", function()
          self:CancelAuction(auction.auctionID)
        end)
      end
      
      row:Show()
    else
      -- Hide unused rows
      row.itemLink = nil
      row.auctionID = nil
      row:Hide()
    end
  end
end

-- Cancel a specific auction
function Auctionator.UI.CancellingPanel:CancelAuction(auctionID)
  if Auctionator.Cancel and Auctionator.Cancel.CancelAuction then
    Auctionator.Cancel:CancelAuction(auctionID)
  end
end

-- Set status text
function Auctionator.UI.CancellingPanel:SetStatus(text)
  self.statusText:SetText(text)
end

-- Show the cancelling panel
function Auctionator.UI.CancellingPanel:Show()
  self.frame:Show()
  
  -- Refresh the auctions when shown
  self:RefreshAuctions()
end

-- Hide the cancelling panel
function Auctionator.UI.CancellingPanel:Hide()
  self.frame:Hide()
end