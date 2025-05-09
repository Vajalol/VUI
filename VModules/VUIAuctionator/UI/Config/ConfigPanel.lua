local addonName, VUI = ...
local Auctionator = VUI.Auctionator

-- Create the Config UI object
Auctionator.Config.UI = {}

-- Initialize the configuration panel
function Auctionator.Config.UI:Initialize()
  -- Create the main configuration panel
  self:CreateConfigPanel()
  
  -- Register with VUI's configuration system
  if VUI.Config and VUI.Config.RegisterConfigPanel then
    VUI.Config:RegisterConfigPanel("VUIAuctionator", self.configPanel)
  end
end

-- Create the main configuration panel
function Auctionator.Config.UI:CreateConfigPanel()
  -- Create the main frame using the VUI panel template
  local frame = CreateFrame("Frame", "VUIAuctionatorConfigPanel")
  frame:Hide()
  
  -- Set title
  frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  frame.title:SetPoint("TOPLEFT", 16, -16)
  frame.title:SetText(Auctionator.L.CONFIG_HEADER)
  
  -- Create tabs for different config sections
  self:CreateConfigTabs(frame)
  
  -- Create scrollframe for content
  frame.scrollFrame = CreateFrame("ScrollFrame", frame:GetName() .. "ScrollFrame", frame, "UIPanelScrollFrameTemplate")
  frame.scrollFrame:SetPoint("TOPLEFT", 16, -50)
  frame.scrollFrame:SetPoint("BOTTOMRIGHT", -36, 16)
  
  -- Create content frame for the scroll frame
  frame.contentFrame = CreateFrame("Frame", frame.scrollFrame:GetName() .. "Content", frame.scrollFrame)
  frame.contentFrame:SetSize(frame.scrollFrame:GetWidth(), 1000) -- Height will be adjusted as content is added
  frame.scrollFrame:SetScrollChild(frame.contentFrame)
  
  -- Store tab content frames
  frame.tabContents = {}
  
  -- Create content for each tab
  self:CreateGeneralTabContent(frame)
  self:CreateSellingTabContent(frame)
  self:CreateBuyingTabContent(frame)
  self:CreateTooltipsTabContent(frame)
  self:CreateCancellingTabContent(frame)
  self:CreateAdvancedTabContent(frame)
  
  -- Initially show the first tab
  self:SelectTab(frame, 1)
  
  -- Store reference to the config panel
  self.configPanel = frame
end

-- Create tabs for the config panel
function Auctionator.Config.UI:CreateConfigTabs(frame)
  -- Tab data
  local tabs = {
    { text = Auctionator.L.CONFIG_GENERAL_TAB },
    { text = Auctionator.L.CONFIG_SELLING_TAB },
    { text = Auctionator.L.CONFIG_BUYING_TAB },
    { text = Auctionator.L.CONFIG_TOOLTIPS_TAB },
    { text = Auctionator.L.CONFIG_CANCELLING_TAB },
    { text = Auctionator.L.CONFIG_ADVANCED_TAB }
  }
  
  -- Create tab frames
  frame.tabs = {}
  
  for i, tabData in ipairs(tabs) do
    local tab = CreateFrame("Button", "$parent_Tab" .. i, frame, "VUIAuctionatorTabButtonTemplate")
    tab:SetID(i)
    tab:SetText(tabData.text)
    
    -- Position the tabs
    if i == 1 then
      tab:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 16, 2)
    else
      tab:SetPoint("LEFT", frame.tabs[i-1], "RIGHT", -4, 0)
    end
    
    -- Tab selection handler
    tab:SetScript("OnClick", function()
      self:SelectTab(frame, i)
    end)
    
    -- Store tab
    frame.tabs[i] = tab
  end
end

-- Select a tab
function Auctionator.Config.UI:SelectTab(frame, tabIndex)
  -- Hide all tab contents
  for i, content in ipairs(frame.tabContents) do
    content:Hide()
    
    -- Update tab appearance
    frame.tabs[i]:SetNormalFontObject("GameFontNormalSmall")
    
    -- Show the tab as unselected
    for _, region in ipairs({frame.tabs[i]:GetRegions()}) do
      if region:GetName() and region:GetName():find("Disabled") then
        region:Hide()
      end
    end
  end
  
  -- Show selected tab content
  frame.tabContents[tabIndex]:Show()
  
  -- Update selected tab appearance
  frame.tabs[tabIndex]:SetNormalFontObject("GameFontHighlightSmall")
  
  -- Show the tab as selected
  for _, region in ipairs({frame.tabs[tabIndex]:GetRegions()}) do
    if region:GetName() and region:GetName():find("Disabled") then
      region:Show()
    end
  end
end

-- Create the general tab content
function Auctionator.Config.UI:CreateGeneralTabContent(frame)
  -- Create content frame
  local content = CreateFrame("Frame", frame:GetName() .. "GeneralTabContent", frame.contentFrame)
  content:SetSize(frame.contentFrame:GetWidth(), 300)
  content:SetPoint("TOPLEFT")
  content:Hide()
  
  -- Auto-scan option
  content.autoScan = self:CreateCheckbox(
    content, 
    Auctionator.L.CONFIG_AUTOSCAN_ON_OPEN, 
    Auctionator.L.CONFIG_AUTOSCAN_ON_OPEN_TOOLTIP
  )
  content.autoScan:SetPoint("TOPLEFT", 0, 0)
  content.autoScan:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.AUTOSCAN_ON_OPEN))
  content.autoScan:SetScript("OnClick", function(self)
    Auctionator.Config.Set(Auctionator.Config.Options.AUTOSCAN_ON_OPEN, self:GetChecked())
  end)
  
  -- Open first auction option
  content.openFirst = self:CreateCheckbox(
    content, 
    Auctionator.L.CONFIG_OPEN_FIRST_AUCTION, 
    Auctionator.L.CONFIG_OPEN_FIRST_AUCTION_TOOLTIP
  )
  content.openFirst:SetPoint("TOPLEFT", content.autoScan, "BOTTOMLEFT", 0, -8)
  content.openFirst:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.OPEN_FIRST_AUCTION_WHEN_SEARCHING))
  content.openFirst:SetScript("OnClick", function(self)
    Auctionator.Config.Set(Auctionator.Config.Options.OPEN_FIRST_AUCTION_WHEN_SEARCHING, self:GetChecked())
  end)
  
  -- Auction chat log option
  content.auctionChat = self:CreateCheckbox(
    content, 
    Auctionator.L.CONFIG_AUCTION_CHAT_LOG, 
    Auctionator.L.CONFIG_AUCTION_CHAT_LOG_TOOLTIP
  )
  content.auctionChat:SetPoint("TOPLEFT", content.openFirst, "BOTTOMLEFT", 0, -8)
  content.auctionChat:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.AUCTION_CHAT_LOG))
  content.auctionChat:SetScript("OnClick", function(self)
    Auctionator.Config.Set(Auctionator.Config.Options.AUCTION_CHAT_LOG, self:GetChecked())
  end)
  
  -- LIFO auction sort option
  content.lifoSort = self:CreateCheckbox(
    content, 
    Auctionator.L.CONFIG_LIFO_AUCTION_SORT, 
    Auctionator.L.CONFIG_LIFO_AUCTION_SORT_TOOLTIP
  )
  content.lifoSort:SetPoint("TOPLEFT", content.auctionChat, "BOTTOMLEFT", 0, -8)
  content.lifoSort:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.LIFO_AUCTION_SORT))
  content.lifoSort:SetScript("OnClick", function(self)
    Auctionator.Config.Set(Auctionator.Config.Options.LIFO_AUCTION_SORT, self:GetChecked())
  end)
  
  -- Default tab dropdown (placeholder - would need more complex UI elements)
  content.defaultTabLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  content.defaultTabLabel:SetPoint("TOPLEFT", content.lifoSort, "BOTTOMLEFT", 0, -16)
  content.defaultTabLabel:SetText(Auctionator.L.CONFIG_DEFAULT_TAB)
  
  -- Store content frame
  table.insert(frame.tabContents, content)
end

-- Create the selling tab content
function Auctionator.Config.UI:CreateSellingTabContent(frame)
  -- Create content frame
  local content = CreateFrame("Frame", frame:GetName() .. "SellingTabContent", frame.contentFrame)
  content:SetSize(frame.contentFrame:GetWidth(), 300)
  content:SetPoint("TOPLEFT")
  content:Hide()
  
  -- Show price history option
  content.priceHistory = self:CreateCheckbox(
    content, 
    Auctionator.L.CONFIG_SHOW_SELLING_PRICE_HISTORY, 
    Auctionator.L.CONFIG_SHOW_SELLING_PRICE_HISTORY_TOOLTIP
  )
  content.priceHistory:SetPoint("TOPLEFT", 0, 0)
  content.priceHistory:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SHOW_SELLING_PRICE_HISTORY))
  content.priceHistory:SetScript("OnClick", function(self)
    Auctionator.Config.Set(Auctionator.Config.Options.SHOW_SELLING_PRICE_HISTORY, self:GetChecked())
  end)
  
  -- Bag collapsed option
  content.bagCollapsed = self:CreateCheckbox(
    content, 
    Auctionator.L.CONFIG_SELLING_BAG_COLLAPSED, 
    Auctionator.L.CONFIG_SELLING_BAG_COLLAPSED_TOOLTIP
  )
  content.bagCollapsed:SetPoint("TOPLEFT", content.priceHistory, "BOTTOMLEFT", 0, -8)
  content.bagCollapsed:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_BAG_COLLAPSED))
  content.bagCollapsed:SetScript("OnClick", function(self)
    Auctionator.Config.Set(Auctionator.Config.Options.SELLING_BAG_COLLAPSED, self:GetChecked())
  end)
  
  -- Auto select next item option
  content.autoSelectNext = self:CreateCheckbox(
    content, 
    Auctionator.L.CONFIG_SELLING_AUTO_SELECT_NEXT, 
    Auctionator.L.CONFIG_SELLING_AUTO_SELECT_NEXT_TOOLTIP
  )
  content.autoSelectNext:SetPoint("TOPLEFT", content.bagCollapsed, "BOTTOMLEFT", 0, -8)
  content.autoSelectNext:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_AUTO_SELECT_NEXT))
  content.autoSelectNext:SetScript("OnClick", function(self)
    Auctionator.Config.Set(Auctionator.Config.Options.SELLING_AUTO_SELECT_NEXT, self:GetChecked())
  end)
  
  -- Show missing favorites option
  content.missingFavorites = self:CreateCheckbox(
    content, 
    Auctionator.L.CONFIG_SELLING_MISSING_FAVOURITES, 
    Auctionator.L.CONFIG_SELLING_MISSING_FAVOURITES_TOOLTIP
  )
  content.missingFavorites:SetPoint("TOPLEFT", content.autoSelectNext, "BOTTOMLEFT", 0, -8)
  content.missingFavorites:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_MISSING_FAVOURITES))
  content.missingFavorites:SetScript("OnClick", function(self)
    Auctionator.Config.Set(Auctionator.Config.Options.SELLING_MISSING_FAVOURITES, self:GetChecked())
  end)
  
  -- Store content frame
  table.insert(frame.tabContents, content)
end

-- Create the buying tab content
function Auctionator.Config.UI:CreateBuyingTabContent(frame)
  -- Create content frame
  local content = CreateFrame("Frame", frame:GetName() .. "BuyingTabContent", frame.contentFrame)
  content:SetSize(frame.contentFrame:GetWidth(), 300)
  content:SetPoint("TOPLEFT")
  content:Hide()
  
  -- Placeholder text
  content.placeholder = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  content.placeholder:SetPoint("TOPLEFT", 0, 0)
  content.placeholder:SetText("Buying options will be added in a future update.")
  
  -- Store content frame
  table.insert(frame.tabContents, content)
end

-- Create the tooltips tab content
function Auctionator.Config.UI:CreateTooltipsTabContent(frame)
  -- Create content frame
  local content = CreateFrame("Frame", frame:GetName() .. "TooltipsTabContent", frame.contentFrame)
  content:SetSize(frame.contentFrame:GetWidth(), 300)
  content:SetPoint("TOPLEFT")
  content:Hide()
  
  -- Show market value option
  content.marketValue = self:CreateCheckbox(
    content, 
    Auctionator.L.CONFIG_TOOLTIP_MARKET_VALUE, 
    Auctionator.L.CONFIG_TOOLTIP_MARKET_VALUE_TOOLTIP
  )
  content.marketValue:SetPoint("TOPLEFT", 0, 0)
  content.marketValue:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.TOOLTIP_MARKET_VALUE))
  content.marketValue:SetScript("OnClick", function(self)
    Auctionator.Config.Set(Auctionator.Config.Options.TOOLTIP_MARKET_VALUE, self:GetChecked())
  end)
  
  -- Show historical price option
  content.historicalPrice = self:CreateCheckbox(
    content, 
    Auctionator.L.CONFIG_TOOLTIP_HISTORICAL_PRICE, 
    Auctionator.L.CONFIG_TOOLTIP_HISTORICAL_PRICE_TOOLTIP
  )
  content.historicalPrice:SetPoint("TOPLEFT", content.marketValue, "BOTTOMLEFT", 0, -8)
  content.historicalPrice:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.TOOLTIP_HISTORICAL_PRICE))
  content.historicalPrice:SetScript("OnClick", function(self)
    Auctionator.Config.Set(Auctionator.Config.Options.TOOLTIP_HISTORICAL_PRICE, self:GetChecked())
  end)
  
  -- Show vendor price option
  content.vendorPrice = self:CreateCheckbox(
    content, 
    Auctionator.L.CONFIG_TOOLTIP_VENDOR_PRICE, 
    Auctionator.L.CONFIG_TOOLTIP_VENDOR_PRICE_TOOLTIP
  )
  content.vendorPrice:SetPoint("TOPLEFT", content.historicalPrice, "BOTTOMLEFT", 0, -8)
  content.vendorPrice:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.TOOLTIP_VENDOR_PRICE))
  content.vendorPrice:SetScript("OnClick", function(self)
    Auctionator.Config.Set(Auctionator.Config.Options.TOOLTIP_VENDOR_PRICE, self:GetChecked())
  end)
  
  -- Hide vendor tips option
  content.hideVendorTips = self:CreateCheckbox(
    content, 
    Auctionator.L.CONFIG_HIDE_VENDOR_TIPS, 
    Auctionator.L.CONFIG_HIDE_VENDOR_TIPS_TOOLTIP
  )
  content.hideVendorTips:SetPoint("TOPLEFT", content.vendorPrice, "BOTTOMLEFT", 0, -8)
  content.hideVendorTips:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.HIDE_VENDOR_TIPS))
  content.hideVendorTips:SetScript("OnClick", function(self)
    Auctionator.Config.Set(Auctionator.Config.Options.HIDE_VENDOR_TIPS, self:GetChecked())
  end)
  
  -- Store content frame
  table.insert(frame.tabContents, content)
end

-- Create the cancelling tab content
function Auctionator.Config.UI:CreateCancellingTabContent(frame)
  -- Create content frame
  local content = CreateFrame("Frame", frame:GetName() .. "CancellingTabContent", frame.contentFrame)
  content:SetSize(frame.contentFrame:GetWidth(), 300)
  content:SetPoint("TOPLEFT")
  content:Hide()
  
  -- Cancel shortcut label
  content.cancelShortcutLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  content.cancelShortcutLabel:SetPoint("TOPLEFT", 0, 0)
  content.cancelShortcutLabel:SetText(Auctionator.L.CONFIG_CANCEL_UNDERCUT_SHORTCUT)
  
  -- Cancel shortcut dropdown (placeholder - would need more complex UI elements)
  
  -- Store content frame
  table.insert(frame.tabContents, content)
end

-- Create the advanced tab content
function Auctionator.Config.UI:CreateAdvancedTabContent(frame)
  -- Create content frame
  local content = CreateFrame("Frame", frame:GetName() .. "AdvancedTabContent", frame.contentFrame)
  content:SetSize(frame.contentFrame:GetWidth(), 300)
  content:SetPoint("TOPLEFT")
  content:Hide()
  
  -- No price database option
  content.noPriceDB = self:CreateCheckbox(
    content, 
    Auctionator.L.CONFIG_NO_PRICE_DATABASE, 
    Auctionator.L.CONFIG_NO_PRICE_DATABASE_TOOLTIP
  )
  content.noPriceDB:SetPoint("TOPLEFT", 0, 0)
  content.noPriceDB:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.NO_PRICE_DATABASE))
  content.noPriceDB:SetScript("OnClick", function(self)
    Auctionator.Config.Set(Auctionator.Config.Options.NO_PRICE_DATABASE, self:GetChecked())
  end)
  
  -- Auto purge old prices option
  content.autoPurge = self:CreateCheckbox(
    content, 
    Auctionator.L.CONFIG_AUTO_PURGE_OLD_PRICES, 
    Auctionator.L.CONFIG_AUTO_PURGE_OLD_PRICES_TOOLTIP
  )
  content.autoPurge:SetPoint("TOPLEFT", content.noPriceDB, "BOTTOMLEFT", 0, -8)
  content.autoPurge:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.AUTO_PURGE_OLD_PRICES))
  content.autoPurge:SetScript("OnClick", function(self)
    Auctionator.Config.Set(Auctionator.Config.Options.AUTO_PURGE_OLD_PRICES, self:GetChecked())
  end)
  
  -- Price history days label
  content.historyDaysLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  content.historyDaysLabel:SetPoint("TOPLEFT", content.autoPurge, "BOTTOMLEFT", 0, -16)
  content.historyDaysLabel:SetText(Auctionator.L.CONFIG_PRICE_HISTORY_DAYS)
  
  -- Price history days slider (placeholder - would need more complex UI elements)
  
  -- Reset configuration button
  content.resetButton = CreateFrame("Button", "$parentResetButton", content, "VUIAuctionatorButtonTemplate")
  content.resetButton:SetPoint("TOPLEFT", content.historyDaysLabel, "BOTTOMLEFT", 0, -24)
  content.resetButton:SetText(Auctionator.L.RESET)
  content.resetButton:SetScript("OnClick", function()
    -- Ask for confirmation
    StaticPopupDialogs["VUIAUCTIONATOR_RESET_CONFIG"] = {
      text = "Are you sure you want to reset all VUIAuctionator settings to defaults?",
      button1 = YES,
      button2 = NO,
      OnAccept = function()
        Auctionator.Config.ResetAll()
        ReloadUI()
      end,
      timeout = 0,
      whileDead = true,
      hideOnEscape = true,
    }
    StaticPopup_Show("VUIAUCTIONATOR_RESET_CONFIG")
  end)
  
  -- Store content frame
  table.insert(frame.tabContents, content)
end

-- Create a checkbox with label and tooltip
function Auctionator.Config.UI:CreateCheckbox(parent, label, tooltip)
  local checkbox = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
  checkbox.Text:SetText(label)
  
  -- Set up tooltip
  checkbox:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(label, 1, 1, 1)
    GameTooltip:AddLine(tooltip, nil, nil, nil, true)
    GameTooltip:Show()
  end)
  
  checkbox:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end)
  
  return checkbox
end