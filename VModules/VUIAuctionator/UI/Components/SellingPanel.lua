local addonName, VUI = ...
local Auctionator = VUI.Auctionator

-- Create the Selling Panel component
Auctionator.UI = Auctionator.UI or {}
Auctionator.UI.SellingPanel = {}

-- Initialize the selling panel
function Auctionator.UI.SellingPanel:Initialize()
  -- Create the main frame
  self.frame = CreateFrame("Frame", "VUIAuctionatorSellingPanel", nil)
  self.frame:SetSize(600, 520)
  self.frame:SetPoint("TOPLEFT", 0, 0)
  self.frame:Hide()
  
  -- Set up the panel
  self:CreatePanelStructure()
  
  -- Register events
  self:RegisterEvents()
end

-- Create the structure of the selling panel
function Auctionator.UI.SellingPanel:CreatePanelStructure()
  -- Header frame
  self.headerFrame = CreateFrame("Frame", self.frame:GetName() .. "Header", self.frame)
  self.headerFrame:SetSize(600, 40)
  self.headerFrame:SetPoint("TOPLEFT", 0, 0)
  
  -- Title
  self.title = self.headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  self.title:SetPoint("TOPLEFT", 14, -8)
  self.title:SetText(Auctionator.L.SELL)
  
  -- Main content frame
  self.contentFrame = CreateFrame("Frame", self.frame:GetName() .. "Content", self.frame)
  self.contentFrame:SetSize(600, 480)
  self.contentFrame:SetPoint("TOP", self.headerFrame, "BOTTOM", 0, 0)
  
  -- Left side (item selection)
  self.bagFrame = CreateFrame("Frame", self.contentFrame:GetName() .. "BagFrame", self.contentFrame)
  self.bagFrame:SetSize(280, 480)
  self.bagFrame:SetPoint("TOPLEFT", 0, 0)
  
  -- Bag frame header
  self.bagHeader = self.bagFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  self.bagHeader:SetPoint("TOPLEFT", 14, -8)
  self.bagHeader:SetText(Auctionator.L.ITEMS)
  
  -- Bag item scroll frame
  self.bagScroll = CreateFrame("ScrollFrame", self.bagFrame:GetName() .. "Scroll", self.bagFrame, "FauxScrollFrameTemplate")
  self.bagScroll:SetSize(260, 400)
  self.bagScroll:SetPoint("TOPLEFT", 10, -30)
  
  -- Create bag item buttons
  self.bagItems = {}
  local numBagRows = 10
  local numBagCols = 6
  local iconSize = Auctionator.Config.Get(Auctionator.Config.Options.SELLING_ICON_SIZE) or 42
  
  for i = 1, numBagRows do
    self.bagItems[i] = {}
    
    for j = 1, numBagCols do
      local index = (i-1) * numBagCols + j
      local button = CreateFrame("Button", self.bagScroll:GetName() .. "Item" .. index, self.bagScroll)
      button:SetSize(iconSize, iconSize)
      button:SetPoint("TOPLEFT", (j-1) * (iconSize + 2), -(i-1) * (iconSize + 2))
      
      button.icon = button:CreateTexture(nil, "BACKGROUND")
      button.icon:SetAllPoints()
      button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Trim default border
      
      button.count = button:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
      button.count:SetPoint("BOTTOMRIGHT", -2, 2)
      
      button.quality = button:CreateTexture(nil, "OVERLAY")
      button.quality:SetPoint("TOPLEFT", -1, 1)
      button.quality:SetPoint("BOTTOMRIGHT", 1, -1)
      button.quality:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
      button.quality:SetBlendMode("ADD")
      button.quality:Hide()
      
      button:SetScript("OnEnter", function(self)
        if self.itemLink then
          GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
          GameTooltip:SetHyperlink(self.itemLink)
          GameTooltip:Show()
        end
      end)
      
      button:SetScript("OnLeave", function()
        GameTooltip:Hide()
      end)
      
      button:SetScript("OnClick", function(self)
        if self.itemLocation then
          -- Select this item for selling
          Auctionator.UI.SellingPanel:SelectItem(self.itemLocation)
        end
      end)
      
      -- Create highlight effect
      button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
      
      self.bagItems[i][j] = button
    end
  end
  
  -- Bag scroll update
  self.bagScroll:SetScript("OnVerticalScroll", function(self, offset)
    FauxScrollFrame_OnVerticalScroll(self, offset, 44, function()
      Auctionator.UI.SellingPanel:UpdateBagDisplay()
    end)
  end)
  
  -- Tabs for different views
  self.viewTabs = {}
  local tabNames = {Auctionator.L.ITEMS, Auctionator.L.FAVORITES}
  
  for i, name in ipairs(tabNames) do
    local tab = CreateFrame("Button", self.bagFrame:GetName() .. "Tab" .. i, self.bagFrame, "VUIAuctionatorTabButtonTemplate")
    tab:SetID(i)
    tab:SetText(name)
    tab:SetSize(120, 22)
    
    if i == 1 then
      tab:SetPoint("BOTTOMLEFT", self.bagFrame, "BOTTOMLEFT", 10, 10)
    else
      tab:SetPoint("LEFT", self.viewTabs[i-1], "RIGHT", 5, 0)
    end
    
    tab:SetScript("OnClick", function()
      Auctionator.UI.SellingPanel:SelectBagTab(i)
    end)
    
    self.viewTabs[i] = tab
  end
  
  -- Right side (auction form)
  self.formFrame = CreateFrame("Frame", self.contentFrame:GetName() .. "FormFrame", self.contentFrame)
  self.formFrame:SetSize(320, 480)
  self.formFrame:SetPoint("TOPRIGHT", 0, 0)
  
  -- Item preview frame
  self.itemPreview = CreateFrame("Frame", self.formFrame:GetName() .. "ItemPreview", self.formFrame)
  self.itemPreview:SetSize(290, 60)
  self.itemPreview:SetPoint("TOPLEFT", 15, -15)
  
  -- Item icon
  self.itemIcon = self.itemPreview:CreateTexture(nil, "ARTWORK")
  self.itemIcon:SetSize(40, 40)
  self.itemIcon:SetPoint("TOPLEFT", 5, -5)
  self.itemIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Trim default border
  
  -- Item name
  self.itemName = self.itemPreview:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  self.itemName:SetSize(230, 40)
  self.itemName:SetPoint("TOPLEFT", self.itemIcon, "TOPRIGHT", 10, 0)
  self.itemName:SetJustifyH("LEFT")
  self.itemName:SetJustifyV("TOP")
  
  -- Form fields
  self.form = {}
  
  -- Quantity
  self.form.quantityLabel = self.formFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  self.form.quantityLabel:SetPoint("TOPLEFT", self.itemPreview, "BOTTOMLEFT", 0, -15)
  self.form.quantityLabel:SetText(Auctionator.L.QUANTITY)
  
  self.form.quantity = CreateFrame("EditBox", self.formFrame:GetName() .. "Quantity", self.formFrame, "VUIAuctionatorEditBoxTemplate")
  self.form.quantity:SetSize(100, 22)
  self.form.quantity:SetPoint("TOPRIGHT", self.itemPreview, "BOTTOMRIGHT", 0, -15)
  self.form.quantity:SetAutoFocus(false)
  self.form.quantity:SetNumeric(true)
  self.form.quantity:SetMaxLetters(5)
  
  -- Price
  self.form.priceLabel = self.formFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  self.form.priceLabel:SetPoint("TOPLEFT", self.form.quantityLabel, "BOTTOMLEFT", 0, -15)
  self.form.priceLabel:SetText(Auctionator.L.PRICE)
  
  self.form.price = CreateFrame("EditBox", self.formFrame:GetName() .. "Price", self.formFrame, "VUIAuctionatorEditBoxTemplate")
  self.form.price:SetSize(100, 22)
  self.form.price:SetPoint("TOPRIGHT", self.form.quantity, "BOTTOMRIGHT", 0, -15)
  self.form.price:SetAutoFocus(false)
  
  -- Deposit
  self.form.depositLabel = self.formFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  self.form.depositLabel:SetPoint("TOPLEFT", self.form.priceLabel, "BOTTOMLEFT", 0, -15)
  self.form.depositLabel:SetText(Auctionator.L.DEPOSIT)
  
  self.form.deposit = self.formFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  self.form.deposit:SetSize(100, 22)
  self.form.deposit:SetPoint("TOPRIGHT", self.form.price, "BOTTOMRIGHT", 0, -15)
  self.form.deposit:SetJustifyH("RIGHT")
  self.form.deposit:SetText("--")
  
  -- Duration
  self.form.durationLabel = self.formFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  self.form.durationLabel:SetPoint("TOPLEFT", self.form.depositLabel, "BOTTOMLEFT", 0, -15)
  self.form.durationLabel:SetText(Auctionator.L.DURATION)
  
  -- Duration radio buttons
  self.form.duration = {}
  local durations = {
    {id = 1, text = Auctionator.L.DURATION_SHORT},
    {id = 2, text = Auctionator.L.DURATION_MEDIUM},
    {id = 3, text = Auctionator.L.DURATION_LONG}
  }
  
  for i, duration in ipairs(durations) do
    local radio = CreateFrame("CheckButton", self.formFrame:GetName() .. "Duration" .. i, self.formFrame, "UIRadioButtonTemplate")
    radio:SetPoint("TOPLEFT", self.form.durationLabel, "BOTTOMLEFT", 15, -10 - (i-1) * 20)
    radio:SetChecked(i == 3) -- Default to long duration
    radio.duration = duration.id
    
    _G[radio:GetName() .. "Text"]:SetText(duration.text)
    
    radio:SetScript("OnClick", function(self)
      -- Uncheck all others
      for _, btn in ipairs(Auctionator.UI.SellingPanel.form.duration) do
        btn:SetChecked(btn == self)
      end
      
      -- Update deposit
      Auctionator.UI.SellingPanel:CalculateDeposit()
    end)
    
    self.form.duration[i] = radio
  end
  
  -- Total price
  self.form.totalLabel = self.formFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  self.form.totalLabel:SetPoint("TOPLEFT", self.form.duration[#self.form.duration], "BOTTOMLEFT", -15, -20)
  self.form.totalLabel:SetText(Auctionator.L.TOTAL_PRICE)
  
  self.form.total = self.formFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  self.form.total:SetSize(100, 22)
  self.form.total:SetPoint("TOPRIGHT", self.form.totalLabel, "BOTTOMRIGHT", 235, 0)
  self.form.total:SetJustifyH("RIGHT")
  self.form.total:SetText("--")
  
  -- Price options
  self.form.priceOptions = {}
  
  -- Undercut button
  self.form.priceOptions.undercut = CreateFrame("Button", self.formFrame:GetName() .. "UndercutButton", self.formFrame, "VUIAuctionatorButtonTemplate")
  self.form.priceOptions.undercut:SetSize(120, 22)
  self.form.priceOptions.undercut:SetPoint("TOPLEFT", self.form.totalLabel, "BOTTOMLEFT", 0, -20)
  self.form.priceOptions.undercut:SetText(Auctionator.L.UNDERCUT)
  
  -- Post button
  self.form.post = CreateFrame("Button", self.formFrame:GetName() .. "PostButton", self.formFrame, "VUIAuctionatorButtonTemplate")
  self.form.post:SetSize(200, 30)
  self.form.post:SetPoint("BOTTOM", self.formFrame, "BOTTOM", 0, 20)
  self.form.post:SetText(Auctionator.L.POSTING)
  self.form.post:Disable() -- Disabled until an item is selected
  
  -- Price history (if enabled)
  if Auctionator.Config.Get(Auctionator.Config.Options.SHOW_SELLING_PRICE_HISTORY) then
    self.priceHistory = CreateFrame("Frame", self.formFrame:GetName() .. "PriceHistory", self.formFrame)
    self.priceHistory:SetSize(290, 100)
    self.priceHistory:SetPoint("BOTTOM", self.form.post, "TOP", 0, 10)
    
    -- Price history title
    self.priceHistoryTitle = self.priceHistory:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.priceHistoryTitle:SetPoint("TOPLEFT", 5, -5)
    self.priceHistoryTitle:SetText(Auctionator.L.HISTORICAL_PRICE)
    
    -- Price history content
    self.priceHistoryContent = self.priceHistory:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    self.priceHistoryContent:SetPoint("TOPLEFT", self.priceHistoryTitle, "BOTTOMLEFT", 5, -5)
    self.priceHistoryContent:SetSize(280, 80)
    self.priceHistoryContent:SetJustifyH("LEFT")
    self.priceHistoryContent:SetJustifyV("TOP")
    self.priceHistoryContent:SetText("")
  end
  
  -- Set up interaction
  self:SetupInteraction()
  
  -- Initial tab selection
  self:SelectBagTab(1)
end

-- Set up interaction handlers
function Auctionator.UI.SellingPanel:SetupInteraction()
  -- Price change handlers
  self.form.price:SetScript("OnTextChanged", function()
    self:CalculateTotal()
  end)
  
  self.form.quantity:SetScript("OnTextChanged", function()
    self:CalculateTotal()
    self:CalculateDeposit()
  end)
  
  -- Undercut button
  self.form.priceOptions.undercut:SetScript("OnClick", function()
    self:CalculateUndercutPrice()
  end)
  
  -- Post button
  self.form.post:SetScript("OnClick", function()
    self:PostAuction()
  end)
  
  -- Price box special handling for money input
  self.form.price:SetScript("OnChar", function(self, text)
    if text == "." or text == "," then
      -- Handle decimal points specially
      local existing = self:GetText()
      
      -- If there's already a decimal, don't add another
      if existing:find("%.") then
        return
      end
      
      -- Convert to copper (assuming gold)
      self:SetText(existing .. ".")
    end
  end)
end

-- Register for events
function Auctionator.UI.SellingPanel:RegisterEvents()
  -- Item selection events
  Auctionator.EventBus:Register({}, Auctionator.Selling.Events.BAG_ITEM_CLICKED, function(_, itemData)
    -- Update the item preview
    self:UpdateItemPreview(itemData)
  end)
  
  -- Posting events
  Auctionator.EventBus:Register({}, Auctionator.Selling.Events.POST_SUCCESS, function(_, postData)
    -- Clear the form after successful post
    self:ClearForm()
    
    -- Enable the post button since we're ready for another auction
    self.form.post:Enable()
  end)
  
  Auctionator.EventBus:Register({}, Auctionator.Selling.Events.POST_FAILURE, function(_, reason)
    -- Re-enable the post button
    self.form.post:Enable()
  end)
  
  -- AH open/close events
  Auctionator.EventBus:Register({}, Auctionator.AuctionHouse.Events.AUCTION_HOUSE_SHOW, function()
    -- Refresh bag display when AH opens
    self:UpdateBagDisplay()
  end)
end

-- Select a bag tab
function Auctionator.UI.SellingPanel:SelectBagTab(tabIndex)
  -- Update tab appearance
  for i, tab in ipairs(self.viewTabs) do
    if i == tabIndex then
      tab:SetNormalFontObject("GameFontHighlight")
    else
      tab:SetNormalFontObject("GameFontNormal")
    end
  end
  
  -- Store current tab
  self.currentBagTab = tabIndex
  
  -- Update display based on the selected tab
  self:UpdateBagDisplay()
end

-- Update the bag item display
function Auctionator.UI.SellingPanel:UpdateBagDisplay()
  -- Get bag contents
  local bagItems = {}
  
  if self.currentBagTab == 1 then
    -- All items
    bagItems = self:GetBagItems()
  else
    -- Favorites
    bagItems = self:GetFavoriteItems()
  end
  
  -- Calculate scroll position
  local numBagCols = 6
  local numVisibleRows = 10
  local numItems = #bagItems
  local numRows = math.ceil(numItems / numBagCols)
  
  -- Update scroll frame
  FauxScrollFrame_Update(self.bagScroll, numRows, numVisibleRows, 44)
  local offset = FauxScrollFrame_GetOffset(self.bagScroll)
  
  -- Update bag buttons
  for row = 1, numVisibleRows do
    for col = 1, numBagCols do
      local rowIndex = row + offset
      local index = (rowIndex - 1) * numBagCols + col
      local button = self.bagItems[row][col]
      
      if index <= numItems then
        local itemData = bagItems[index]
        
        -- Set item info
        button.icon:SetTexture(itemData.iconTexture)
        button.count:SetText(itemData.count > 1 and itemData.count or "")
        button.itemLink = itemData.itemLink
        button.itemLocation = itemData.itemLocation
        
        -- Set quality color
        if itemData.quality and ITEM_QUALITY_COLORS[itemData.quality] then
          local color = ITEM_QUALITY_COLORS[itemData.quality]
          button.quality:SetVertexColor(color.r, color.g, color.b)
          button.quality:Show()
        else
          button.quality:Hide()
        end
        
        button:Show()
      else
        -- Hide unused buttons
        button.icon:SetTexture(nil)
        button.count:SetText("")
        button.itemLink = nil
        button.itemLocation = nil
        button.quality:Hide()
        button:Hide()
      end
    end
  end
end

-- Get all sellable items from bags
function Auctionator.UI.SellingPanel:GetBagItems()
  local items = {}
  
  -- Iterate through bags
  for bagID = 0, NUM_BAG_SLOTS do
    local numSlots = C_Container.GetContainerNumSlots(bagID)
    
    for slotID = 1, numSlots do
      local itemLocation = ItemLocation:CreateFromBagAndSlot(bagID, slotID)
      
      if C_Item.DoesItemExist(itemLocation) then
        local itemLink = C_Item.GetItemLink(itemLocation)
        
        if itemLink and Auctionator.API.CanPostItem(itemLink) then
          local texture, count, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID = C_Container.GetContainerItemInfo(bagID, slotID)
          
          if texture then
            table.insert(items, {
              itemLink = itemLink,
              iconTexture = texture,
              count = count,
              quality = quality,
              itemLocation = itemLocation
            })
          end
        end
      end
    end
  end
  
  -- Filter ignored items
  items = self:FilterIgnoredItems(items)
  
  return items
end

-- Get favorite items from bags
function Auctionator.UI.SellingPanel:GetFavoriteItems()
  local allItems = self:GetBagItems()
  local favorites = {}
  
  -- Filter to only show favorites
  for _, item in ipairs(allItems) do
    if Auctionator.Selling:IsFavorite(item.itemLink) then
      table.insert(favorites, item)
    end
  end
  
  -- Add missing favorites if configured
  if Auctionator.Config.Get(Auctionator.Config.Options.SELLING_MISSING_FAVOURITES) then
    self:AddMissingFavorites(favorites)
  end
  
  return favorites
end

-- Filter out ignored items
function Auctionator.UI.SellingPanel:FilterIgnoredItems(items)
  local filtered = {}
  
  for _, item in ipairs(items) do
    if not Auctionator.Selling:IsIgnored(item.itemLink) then
      table.insert(filtered, item)
    end
  end
  
  return filtered
end

-- Add missing favorites
function Auctionator.UI.SellingPanel:AddMissingFavorites(favorites)
  -- This would need to be implemented to show favorites not currently in bags
  -- Would require tracking previous item details
end

-- Select an item for posting
function Auctionator.UI.SellingPanel:SelectItem(itemLocation)
  -- Use the Selling module to handle the selection
  Auctionator.Selling:SelectItem(itemLocation)
end

-- Update the item preview when an item is selected
function Auctionator.UI.SellingPanel:UpdateItemPreview(itemData)
  if not itemData then
    -- Clear preview
    self.itemIcon:SetTexture(nil)
    self.itemName:SetText("")
    
    -- Disable post button
    self.form.post:Disable()
    
    -- Clear form
    self:ClearForm()
    
    -- Clear price history
    if self.priceHistoryContent then
      self.priceHistoryContent:SetText("")
    end
    
    return
  end
  
  -- Set icon and name
  local texture = Auctionator.Utilities.ItemInfo.GetItemIconTexture(itemData.itemLink)
  self.itemIcon:SetTexture(texture or "Interface\\Icons\\INV_Misc_QuestionMark")
  
  local name = Auctionator.Utilities.ItemInfo.GetItemName(itemData.itemLink)
  local quality = Auctionator.Utilities.ItemInfo.GetItemRarity(itemData.itemLink)
  
  if quality and ITEM_QUALITY_COLORS[quality] then
    local color = ITEM_QUALITY_COLORS[quality]
    self.itemName:SetText(color.hex .. (name or "Unknown Item") .. "|r")
  else
    self.itemName:SetText(name or "Unknown Item")
  end
  
  -- Set quantity
  local maxStackSize = Auctionator.Utilities.ItemInfo.GetItemStackSize(itemData.itemLink)
  local recommendedStack = Auctionator.API.GetRecommendedStackSize(itemData.itemLink)
  
  -- Use the smaller of count, recommended stack, or max stack
  local quantity = math.min(itemData.quantity, recommendedStack, maxStackSize)
  self.form.quantity:SetText(quantity)
  
  -- Set suggested price
  self:CalculateUndercutPrice()
  
  -- Calculate deposit
  self:CalculateDeposit()
  
  -- Calculate total
  self:CalculateTotal()
  
  -- Update price history if enabled
  if self.priceHistoryContent then
    self:UpdatePriceHistory(itemData.itemLink)
  end
  
  -- Enable post button
  self.form.post:Enable()
end

-- Calculate undercut price
function Auctionator.UI.SellingPanel:CalculateUndercutPrice()
  local itemData = Auctionator.Selling.currentItem
  
  if not itemData then
    return
  end
  
  -- Get suggested price
  local suggestedPrice = Auctionator.API.CalculateSuggestedPrice(
    itemData.itemLink, 
    "percentage" -- Use percentage-based undercutting
  )
  
  if suggestedPrice then
    -- Convert to gold format for display
    local priceText = Auctionator.Utilities.FormatMoney(suggestedPrice, "TOTAL", false)
    self.form.price:SetText(priceText)
  else
    self.form.price:SetText("")
  end
end

-- Calculate deposit cost
function Auctionator.UI.SellingPanel:CalculateDeposit()
  local itemData = Auctionator.Selling.currentItem
  
  if not itemData then
    self.form.deposit:SetText("--")
    return
  end
  
  -- Get the selected duration
  local duration = 3 -- Default to long (48h)
  
  for _, radio in ipairs(self.form.duration) do
    if radio:GetChecked() then
      duration = radio.duration
      break
    end
  end
  
  local quantity = tonumber(self.form.quantity:GetText()) or 0
  
  -- This is a simplified calculation; the actual deposit depends on vendor price,
  -- item quality, and other factors that vary by expansion
  local vendorPrice = Auctionator.API.GetVendorPrice(itemData.itemLink) or 0
  local deposit = math.floor(vendorPrice * 0.15 * quantity * duration)
  
  -- Display the deposit
  self.form.deposit:SetText(Auctionator.Utilities.FormatMoney(deposit))
end

-- Calculate total price
function Auctionator.UI.SellingPanel:CalculateTotal()
  local priceText = self.form.price:GetText()
  local quantityText = self.form.quantity:GetText()
  
  local price = Auctionator.Utilities.ParseMoney(priceText) or 0
  local quantity = tonumber(quantityText) or 0
  
  local total = price * quantity
  
  -- Display the total
  self.form.total:SetText(Auctionator.Utilities.FormatMoney(total))
end

-- Update price history display
function Auctionator.UI.SellingPanel:UpdatePriceHistory(itemLink)
  if not self.priceHistoryContent or not itemLink then
    return
  end
  
  local marketValue = Auctionator.Database.GetMarketValue(itemLink)
  local historicalValue = Auctionator.Database.GetHistoricalValue(itemLink)
  local minSeen = Auctionator.Database.GetMinPrice(itemLink)
  
  local text = ""
  
  if marketValue then
    text = text .. Auctionator.L.CURRENT_PRICE .. ": " .. 
      Auctionator.Utilities.FormatMoney(marketValue) .. "\n"
  end
  
  if historicalValue then
    text = text .. Auctionator.L.HISTORICAL_PRICE .. ": " .. 
      Auctionator.Utilities.FormatMoney(historicalValue) .. "\n"
  end
  
  if minSeen then
    text = text .. "Min Seen: " .. 
      Auctionator.Utilities.FormatMoney(minSeen) .. "\n"
  end
  
  if text == "" then
    text = Auctionator.L.ERR_NO_PRICE_DATA
  end
  
  self.priceHistoryContent:SetText(text)
end

-- Post an auction
function Auctionator.UI.SellingPanel:PostAuction()
  local itemData = Auctionator.Selling.currentItem
  
  if not itemData then
    return
  end
  
  -- Get form values
  local priceText = self.form.price:GetText()
  local quantityText = self.form.quantity:GetText()
  
  local price = Auctionator.Utilities.ParseMoney(priceText)
  local quantity = tonumber(quantityText)
  
  -- Get duration
  local duration = 3 -- Default to long (48h)
  
  for _, radio in ipairs(self.form.duration) do
    if radio:GetChecked() then
      duration = radio.duration
      break
    end
  end
  
  -- Validate
  if not price or price <= 0 then
    Auctionator.Utilities.Message.Error(Auctionator.L.ERR_INVALID_PRICE)
    return
  end
  
  if not quantity or quantity <= 0 then
    Auctionator.Utilities.Message.Error(Auctionator.L.ERR_INVALID_QUANTITY)
    return
  end
  
  -- Disable button while posting
  self.form.post:Disable()
  
  -- Create post data
  local postData = {
    price = price,
    quantity = quantity,
    duration = duration
  }
  
  -- Attempt to post
  Auctionator.EventBus:Fire({}, Auctionator.Selling.Events.POST_ATTEMPT, postData)
end

-- Clear the posting form
function Auctionator.UI.SellingPanel:ClearForm()
  self.form.price:SetText("")
  self.form.quantity:SetText("")
  self.form.deposit:SetText("--")
  self.form.total:SetText("--")
end

-- Show the selling panel
function Auctionator.UI.SellingPanel:Show()
  self.frame:Show()
  
  -- Update the display
  self:UpdateBagDisplay()
end

-- Hide the selling panel
function Auctionator.UI.SellingPanel:Hide()
  self.frame:Hide()
end