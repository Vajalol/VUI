local addonName, VUI = ...
local Auctionator = VUI.Auctionator

AuctionatorConfigTabMixin = CreateFromMixins(AuctionatorTabMixin)

function AuctionatorConfigTabMixin:OnLoad()
  -- Apply VUI theme if available
  if VUI.ApplyThemeColor then
    if self.Background then
      VUI:ApplyThemeColor(self.Background, 0.2)
    end
    
    if self.Border then
      VUI:ApplyThemeColor(self.Border)
    end
    
    -- Apply theme to buttons
    VUI:ApplyThemeColor(self.SaveButton)
    VUI:ApplyThemeColor(self.CancelButton)
    VUI:ApplyThemeColor(self.ResetButton)
  end
  
  -- Initialize Tab
  self:InitializeCategories()
  self:RegisterEvents()
  self:SetupButtonHandlers()
  
  -- Initial display
  self:ShowCategory("General")
end

function AuctionatorConfigTabMixin:RegisterEvents()
  -- No specific events needed for this tab
end

function AuctionatorConfigTabMixin:SetupButtonHandlers()
  -- Save button
  self.SaveButton:SetScript("OnClick", function()
    self:SaveSettings()
  end)
  
  -- Cancel button
  self.CancelButton:SetScript("OnClick", function()
    self:CancelChanges()
  end)
  
  -- Reset button
  self.ResetButton:SetScript("OnClick", function()
    self:ResetToDefaults()
  end)
end

function AuctionatorConfigTabMixin:InitializeCategories()
  -- Initialize configuration categories
  self.categories = {
    "General",
    "Selling", 
    "Shopping",
    "Cancelling", 
    "Tooltips",
    "Advanced"
  }
  
  -- Initialize temporary settings table
  self.tempSettings = {}
  
  -- Setup category buttons
  for index, categoryName in ipairs(self.categories) do
    local button = self.CategoryList["Category"..index]
    if button then
      button.Text:SetText(categoryName)
      button:SetScript("OnClick", function()
        self:ShowCategory(categoryName)
      end)
    end
  end
  
  -- Setup configuration sections
  self.configSections = {
    General = self.GeneralOptions,
    Selling = self.SellingOptions,
    Shopping = self.ShoppingOptions,
    Cancelling = self.CancellingOptions,
    Tooltips = self.TooltipOptions,
    Advanced = self.AdvancedOptions
  }
  
  -- Initial settings
  self:PopulateSettings()
end

function AuctionatorConfigTabMixin:ShowCategory(categoryName)
  -- Hide all sections first
  for _, section in pairs(self.configSections) do
    section:Hide()
  end
  
  -- Show the selected section
  if self.configSections[categoryName] then
    self.configSections[categoryName]:Show()
    
    -- Highlight selected category
    for index, name in ipairs(self.categories) do
      local button = self.CategoryList["Category"..index]
      if button then
        if name == categoryName then
          button:LockHighlight()
        else
          button:UnlockHighlight()
        end
      end
    end
    
    -- Update title
    self.Title:SetText("Auctionator - " .. categoryName .. " Settings")
  end
end

function AuctionatorConfigTabMixin:PopulateSettings()
  -- Initialize settings from the VUI database
  local db = VUI.db.global.VUIAuctionator or {}
  
  -- Create a deep copy for temporary editing
  self.tempSettings = self:DeepCopy(db)
  
  -- Set initial values in the UI
  self:UpdateSettingsUI()
end

function AuctionatorConfigTabMixin:DeepCopy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
    copy = {}
    for orig_key, orig_value in next, orig, nil do
      copy[self:DeepCopy(orig_key)] = self:DeepCopy(orig_value)
    end
    setmetatable(copy, self:DeepCopy(getmetatable(orig)))
  else
    copy = orig
  end
  return copy
end

function AuctionatorConfigTabMixin:UpdateSettingsUI()
  -- General Settings
  if self.GeneralOptions then
    local general = self.tempSettings.general or {}
    
    self.GeneralOptions.AuctionChatMessages:SetChecked(general.auctionChatMessages ~= false)
    self.GeneralOptions.AutoOpenBrowse:SetChecked(general.autoOpenBrowse ~= false)
    self.GeneralOptions.AutoOpenSell:SetChecked(general.autoOpenSell ~= false)
    self.GeneralOptions.ShowBidPrice:SetChecked(general.showBidPrice ~= false)
    
    -- Default duration dropdown
    local durationValue = general.defaultDuration or 1
    UIDropDownMenu_SetSelectedValue(self.GeneralOptions.DefaultDuration, durationValue)
    UIDropDownMenu_SetText(self.GeneralOptions.DefaultDuration, self:GetDurationText(durationValue))
  end
  
  -- Selling Settings
  if self.SellingOptions then
    local selling = self.tempSettings.selling or {}
    
    self.SellingOptions.UndercutPercentage:SetText(tostring(selling.undercutPercentage or 5))
    self.SellingOptions.AutomaticUndercut:SetChecked(selling.automaticUndercut ~= false)
    self.SellingOptions.SaveLastPriceAsDefault:SetChecked(selling.saveLastPriceAsDefault ~= false)
    self.SellingOptions.ShowStackSize:SetChecked(selling.showStackSize ~= false)
    self.SellingOptions.AutoSelectNext:SetChecked(selling.autoSelectNext ~= false)
  end
  
  -- Shopping Settings
  if self.ShoppingOptions then
    local shopping = self.tempSettings.shopping or {}
    
    self.ShoppingOptions.ShowHistoryInTooltip:SetChecked(shopping.showHistoryInTooltip ~= false)
    self.ShoppingOptions.AutoFocusSearchBox:SetChecked(shopping.autoFocusSearchBox ~= false)
    self.ShoppingOptions.ConfirmBidPurchase:SetChecked(shopping.confirmBidPurchase ~= false)
  end
  
  -- Cancelling Settings
  if self.CancellingOptions then
    local cancelling = self.tempSettings.cancelling or {}
    
    self.CancellingOptions.AutoRefreshUndercutScan:SetChecked(cancelling.autoRefreshUndercutScan ~= false)
    self.CancellingOptions.ConfirmCancelAll:SetChecked(cancelling.confirmCancelAll ~= false)
  end
  
  -- Tooltip Settings
  if self.TooltipOptions then
    local tooltip = self.tempSettings.tooltip or {}
    
    self.TooltipOptions.ShowVendorPrice:SetChecked(tooltip.showVendorPrice ~= false)
    self.TooltipOptions.ShowAuctionPrice:SetChecked(tooltip.showAuctionPrice ~= false)
    self.TooltipOptions.ShowDisenchantPrice:SetChecked(tooltip.showDisenchantPrice ~= false)
    self.TooltipOptions.ShowHistoricalPrice:SetChecked(tooltip.showHistoricalPrice ~= false)
  end
  
  -- Advanced Settings
  if self.AdvancedOptions then
    local advanced = self.tempSettings.advanced or {}
    
    self.AdvancedOptions.Debug:SetChecked(advanced.debug == true)
    self.AdvancedOptions.FullScanInterval:SetText(tostring(advanced.fullScanInterval or 60))
  end
end

function AuctionatorConfigTabMixin:GetDurationText(value)
  if value == 1 then
    return "12 Hours"
  elseif value == 2 then
    return "24 Hours"
  elseif value == 3 then
    return "48 Hours"
  else
    return "12 Hours"
  end
end

function AuctionatorConfigTabMixin:InitializeDurationDropdown()
  local function OnDurationSelected(self, durationValue)
    AuctionatorConfigTabMixin.tempSettings.general.defaultDuration = durationValue
    UIDropDownMenu_SetSelectedValue(AuctionatorConfigTabMixin.GeneralOptions.DefaultDuration, durationValue)
    UIDropDownMenu_SetText(AuctionatorConfigTabMixin.GeneralOptions.DefaultDuration, AuctionatorConfigTabMixin:GetDurationText(durationValue))
  end
  
  local function InitializeDurationMenu(frame, level)
    local info = UIDropDownMenu_CreateInfo()
    
    info.func = OnDurationSelected
    
    info.text = "12 Hours"
    info.value = 1
    info.checked = AuctionatorConfigTabMixin.tempSettings.general.defaultDuration == 1
    UIDropDownMenu_AddButton(info, level)
    
    info.text = "24 Hours"
    info.value = 2
    info.checked = AuctionatorConfigTabMixin.tempSettings.general.defaultDuration == 2
    UIDropDownMenu_AddButton(info, level)
    
    info.text = "48 Hours"
    info.value = 3
    info.checked = AuctionatorConfigTabMixin.tempSettings.general.defaultDuration == 3
    UIDropDownMenu_AddButton(info, level)
  end
  
  UIDropDownMenu_Initialize(self.GeneralOptions.DefaultDuration, InitializeDurationMenu)
end

function AuctionatorConfigTabMixin:SaveSettings()
  -- Get values from UI controls
  
  -- General Settings
  local general = self.tempSettings.general or {}
  
  general.auctionChatMessages = self.GeneralOptions.AuctionChatMessages:GetChecked()
  general.autoOpenBrowse = self.GeneralOptions.AutoOpenBrowse:GetChecked()
  general.autoOpenSell = self.GeneralOptions.AutoOpenSell:GetChecked()
  general.showBidPrice = self.GeneralOptions.ShowBidPrice:GetChecked()
  general.defaultDuration = UIDropDownMenu_GetSelectedValue(self.GeneralOptions.DefaultDuration) or 1
  
  -- Selling Settings
  local selling = self.tempSettings.selling or {}
  
  selling.undercutPercentage = tonumber(self.SellingOptions.UndercutPercentage:GetText()) or 5
  selling.automaticUndercut = self.SellingOptions.AutomaticUndercut:GetChecked()
  selling.saveLastPriceAsDefault = self.SellingOptions.SaveLastPriceAsDefault:GetChecked()
  selling.showStackSize = self.SellingOptions.ShowStackSize:GetChecked()
  selling.autoSelectNext = self.SellingOptions.AutoSelectNext:GetChecked()
  
  -- Shopping Settings
  local shopping = self.tempSettings.shopping or {}
  
  shopping.showHistoryInTooltip = self.ShoppingOptions.ShowHistoryInTooltip:GetChecked()
  shopping.autoFocusSearchBox = self.ShoppingOptions.AutoFocusSearchBox:GetChecked()
  shopping.confirmBidPurchase = self.ShoppingOptions.ConfirmBidPurchase:GetChecked()
  
  -- Cancelling Settings
  local cancelling = self.tempSettings.cancelling or {}
  
  cancelling.autoRefreshUndercutScan = self.CancellingOptions.AutoRefreshUndercutScan:GetChecked()
  cancelling.confirmCancelAll = self.CancellingOptions.ConfirmCancelAll:GetChecked()
  
  -- Tooltip Settings
  local tooltip = self.tempSettings.tooltip or {}
  
  tooltip.showVendorPrice = self.TooltipOptions.ShowVendorPrice:GetChecked()
  tooltip.showAuctionPrice = self.TooltipOptions.ShowAuctionPrice:GetChecked()
  tooltip.showDisenchantPrice = self.TooltipOptions.ShowDisenchantPrice:GetChecked()
  tooltip.showHistoricalPrice = self.TooltipOptions.ShowHistoricalPrice:GetChecked()
  
  -- Advanced Settings
  local advanced = self.tempSettings.advanced or {}
  
  advanced.debug = self.AdvancedOptions.Debug:GetChecked()
  advanced.fullScanInterval = tonumber(self.AdvancedOptions.FullScanInterval:GetText()) or 60
  
  -- Save to VUI database
  self.tempSettings.general = general
  self.tempSettings.selling = selling
  self.tempSettings.shopping = shopping
  self.tempSettings.cancelling = cancelling
  self.tempSettings.tooltip = tooltip
  self.tempSettings.advanced = advanced
  
  -- Commit changes to the main database
  VUI.db.global.VUIAuctionator = self:DeepCopy(self.tempSettings)
  
  -- Notify user
  print("|cFF" .. VUI:GetThemeColorHex() .. "VUIAuctionator|r Settings saved.")
end

function AuctionatorConfigTabMixin:CancelChanges()
  -- Discard changes and reload from database
  self:PopulateSettings()
  
  -- Notify user
  print("|cFF" .. VUI:GetThemeColorHex() .. "VUIAuctionator|r Changes discarded.")
end

function AuctionatorConfigTabMixin:ResetToDefaults()
  -- Create default settings
  local defaults = {
    general = {
      auctionChatMessages = true,
      autoOpenBrowse = true,
      autoOpenSell = true,
      showBidPrice = true,
      defaultDuration = 1,
    },
    selling = {
      undercutPercentage = 5,
      automaticUndercut = true,
      saveLastPriceAsDefault = true,
      showStackSize = true,
      autoSelectNext = true,
    },
    shopping = {
      showHistoryInTooltip = true,
      autoFocusSearchBox = true,
      confirmBidPurchase = true,
    },
    cancelling = {
      autoRefreshUndercutScan = true,
      confirmCancelAll = true,
    },
    tooltip = {
      showVendorPrice = true,
      showAuctionPrice = true,
      showDisenchantPrice = true,
      showHistoricalPrice = true,
    },
    advanced = {
      debug = false,
      fullScanInterval = 60,
    }
  }
  
  -- Confirm reset
  StaticPopupDialogs["VUIAUCTIONATOR_RESET_CONFIRM"] = StaticPopupDialogs["VUIAUCTIONATOR_RESET_CONFIRM"] or {
    text = "Are you sure you want to reset all VUIAuctionator settings to defaults?",
    button1 = ACCEPT,
    button2 = CANCEL,
    OnAccept = function()
      -- Apply defaults
      self.tempSettings = self:DeepCopy(defaults)
      VUI.db.global.VUIAuctionator = self:DeepCopy(defaults)
      
      -- Update UI
      self:UpdateSettingsUI()
      
      -- Notify user
      print("|cFF" .. VUI:GetThemeColorHex() .. "VUIAuctionator|r Settings reset to defaults.")
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
  }
  
  StaticPopup_Show("VUIAUCTIONATOR_RESET_CONFIRM")
end

function AuctionatorConfigTabMixin:OnShow()
  -- Initialize dropdown menu
  self:InitializeDurationDropdown()
  
  -- Refresh settings from database
  self:PopulateSettings()
end

-- Display current auction statistics
function AuctionatorConfigTabMixin:UpdateStatistics()
  local stats = VUI.db.global.VUIAuctionator and VUI.db.global.VUIAuctionator.stats or {}
  
  -- Selling stats
  if self.Statistics.SellingStats then
    self.Statistics.SellingStats.TotalSold:SetText(stats.totalItemsSold or 0)
    self.Statistics.SellingStats.GoldEarned:SetText(Auctionator.Utilities.FormatMoney(stats.totalGoldEarned or 0))
    self.Statistics.SellingStats.AvgSellTime:SetText(stats.avgSellTime and string.format("%.1f hours", stats.avgSellTime / 3600) or "N/A")
  end
  
  -- Buying stats
  if self.Statistics.BuyingStats then
    self.Statistics.BuyingStats.TotalBought:SetText(stats.totalItemsBought or 0)
    self.Statistics.BuyingStats.GoldSpent:SetText(Auctionator.Utilities.FormatMoney(stats.totalGoldSpent or 0))
    self.Statistics.BuyingStats.SearchesMade:SetText(stats.totalSearches or 0)
  end
  
  -- Cancelling stats
  if self.Statistics.CancellingStats then
    self.Statistics.CancellingStats.TotalCancelled:SetText(stats.totalItemsCancelled or 0)
    self.Statistics.CancellingStats.UndercutRate:SetText(stats.undercutRate and string.format("%.1f%%", stats.undercutRate * 100) or "N/A")
  end
end

-- Register the tab template for the Auctionator tab
Auctionator.Tabs.Auctionator = {
  Mixin = AuctionatorConfigTabMixin,
  Template = "AuctionatorConfigTabFrameTemplate",
} 