local addonName, VUI = ...
local Auctionator = VUI.Auctionator

AuctionatorSaleItemMixin = {}

function AuctionatorSaleItemMixin:OnLoad()
  -- Set up controls
  self:SetupDurationDropDown()
  self:Reset()
  
  -- Apply VUI theme if available
  if VUI.ApplyThemeColor then
    VUI:ApplyThemeColor(self.PostButton)
    VUI:ApplyThemeColor(self.QuantityInput.MaxButton)
    VUI:ApplyThemeColor(self.PriceInput.UndercutButton)
  end
  
  -- Register events
  self:RegisterForDrag("LeftButton")
end

function AuctionatorSaleItemMixin:OnShow()
  self:Reset()
end

function AuctionatorSaleItemMixin:Reset()
  self.itemLink = nil
  self.itemInfo = nil
  self.stackSize = 0
  self.maxStackSize = 0
  
  -- Clear UI components
  self.Icon.IconTexture:SetTexture(nil)
  self.Icon.Count:SetText("")
  self.ItemInfo.Name:SetText("")
  self.ItemInfo.Quality:SetText("")
  self.ItemInfo.Level:SetText("")
  self.QuantityInput.InputBox:SetText("0")
  
  -- Clear money input
  self:SetPrice(0)
  
  -- Disable posting controls
  self:DisablePost()
  self.PostButton:Disable()
  
  -- Reset duration dropdown
  if self.Duration and self.Duration.DropDown then
    UIDropDownMenu_SetSelectedValue(self.Duration.DropDown, Auctionator.Config.Get(Auctionator.Config.Options.SELLING_DEFAULT_DURATION))
  end
end

function AuctionatorSaleItemMixin:DisablePost()
  self.QuantityInput.InputBox:Disable()
  self.QuantityInput.MaxButton:Disable()
  self.PriceInput.GoldBox:Disable()
  self.PriceInput.SilverBox:Disable()
  self.PriceInput.CopperBox:Disable()
  self.PriceInput.UndercutButton:Disable()
  self.PostButton:Disable()
end

function AuctionatorSaleItemMixin:EnablePost()
  self.QuantityInput.InputBox:Enable()
  self.QuantityInput.MaxButton:Enable()
  self.PriceInput.GoldBox:Enable()
  self.PriceInput.SilverBox:Enable()
  self.PriceInput.CopperBox:Enable()
  self.PriceInput.UndercutButton:Enable()
  self.PostButton:Enable()
end

function AuctionatorSaleItemMixin:SetupDurationDropDown()
  if not self.Duration or not self.Duration.DropDown then
    return
  end
  
  UIDropDownMenu_Initialize(self.Duration.DropDown, function(_, level, menuList)
    local durations = {
      {
        text = AUCTION_DURATION_ONE,
        value = 1,
      },
      {
        text = AUCTION_DURATION_TWO,
        value = 2,
      },
      {
        text = AUCTION_DURATION_THREE,
        value = 3,
      },
    }
    
    for _, duration in ipairs(durations) do
      local info = UIDropDownMenu_CreateInfo()
      info.text = duration.text
      info.value = duration.value
      info.func = function(self)
        UIDropDownMenu_SetSelectedValue(self:GetParent().DropDown, self.value)
      end
      UIDropDownMenu_AddButton(info)
    end
  end)
  
  -- Set the default duration
  UIDropDownMenu_SetWidth(self.Duration.DropDown, 120)
  UIDropDownMenu_SetSelectedValue(self.Duration.DropDown, Auctionator.Config.Get(Auctionator.Config.Options.SELLING_DEFAULT_DURATION) or 2)
  UIDropDownMenu_JustifyText(self.Duration.DropDown, "LEFT")
end

function AuctionatorSaleItemMixin:SetItem(itemLink, stackSize, maxStackSize)
  self:Reset()
  
  -- Check if we have a valid item
  if not itemLink then
    return
  end
  
  self.itemLink = itemLink
  self.stackSize = stackSize or 1
  self.maxStackSize = maxStackSize or self.stackSize
  
  -- Get itemInfo
  local name, _, quality, _, _, typeString, _, _, _, iconTexture = GetItemInfo(itemLink)
  if not name or not iconTexture then
    -- Item info not yet available, will try again
    C_Timer.After(0.1, function()
      if self.itemLink == itemLink then
        self:SetItem(itemLink, stackSize, maxStackSize)
      end
    end)
    return
  end
  
  self.itemInfo = {
    name = name,
    quality = quality,
    iconTexture = iconTexture,
    typeString = typeString,
  }
  
  -- Update UI components
  self.Icon.IconTexture:SetTexture(iconTexture)
  self.Icon.Count:SetText(stackSize > 1 and stackSize or "")
  self.ItemInfo.Name:SetText(name)
  
  -- Set item color based on quality
  local qualityColor = ITEM_QUALITY_COLORS[quality]
  if qualityColor then
    self.ItemInfo.Name:SetTextColor(qualityColor.r, qualityColor.g, qualityColor.b)
  end
  
  -- Set quality and type text
  local qualityName = _G["ITEM_QUALITY"..quality.."_DESC"]
  self.ItemInfo.Quality:SetText(qualityName)
  self.ItemInfo.Level:SetText(typeString or "")
  
  -- Set up quantity
  self.QuantityInput.InputBox:SetText("1")
  self.QuantityInput.InputBox:SetNumeric(true)
  self.QuantityInput.InputBox:SetMaxLetters(3)
  
  -- Try to autofill last price if enabled
  local lastPrice = 0
  if Auctionator.Config.Get(Auctionator.Config.Options.SELLING_AUTO_FILL_LAST_PRICE) then
    if Auctionator.Database and Auctionator.Database.GetLastSalePrice then
      lastPrice = Auctionator.Database.GetLastSalePrice(itemLink) or 0
    end
  end
  self:SetPrice(lastPrice)
  
  -- Enable posting controls
  self:EnablePost()
end

function AuctionatorSaleItemMixin:GetPrice()
  local gold = tonumber(self.PriceInput.GoldBox:GetText()) or 0
  local silver = tonumber(self.PriceInput.SilverBox:GetText()) or 0
  local copper = tonumber(self.PriceInput.CopperBox:GetText()) or 0
  
  return gold * 10000 + silver * 100 + copper
end

function AuctionatorSaleItemMixin:SetPrice(price)
  local gold = math.floor(price / 10000)
  local silver = math.floor((price % 10000) / 100)
  local copper = price % 100
  
  self.PriceInput.GoldBox:SetText(gold > 0 and gold or "")
  self.PriceInput.SilverBox:SetText(silver > 0 and silver or "")
  self.PriceInput.CopperBox:SetText(copper > 0 and copper or "")
end

-- Event Handlers
function AuctionatorSaleItemMixin:OnItemIconClicked()
  -- Clear the current item
  self:Reset()
end

function AuctionatorSaleItemMixin:OnMaxQuantityClicked()
  if not self.itemLink or self.stackSize <= 0 then
    return
  end
  
  self.QuantityInput.InputBox:SetText(tostring(self.stackSize))
end

function AuctionatorSaleItemMixin:OnQuantityChanged()
  local quantity = tonumber(self.QuantityInput.InputBox:GetText()) or 0
  
  -- Validate quantity
  if quantity <= 0 or quantity > self.stackSize then
    self.PostButton:Disable()
  else
    self.PostButton:Enable()
  end
end

function AuctionatorSaleItemMixin:OnUndercutButtonClicked()
  if not self.itemLink then
    return
  end
  
  -- Get current auction prices
  local results = {}
  if Auctionator.API and Auctionator.API.GetAuctionPrices then
    results = Auctionator.API.GetAuctionPrices(self.itemLink) or {}
  end
  
  if #results == 0 then
    -- No auctions found, can't undercut
    return
  end
  
  -- Sort by price
  table.sort(results, function(a, b) return a.unitPrice < b.unitPrice end)
  
  -- Calculate undercut price
  local lowestPrice = results[1].unitPrice
  local undercutPercent = 5
  if Auctionator.Config and Auctionator.Config.Get then
    undercutPercent = Auctionator.Config.Get(Auctionator.Config.Options.SELLING_UNDERCUT_PERCENTAGE) or 5
  end
  
  local undercutPrice = math.floor(lowestPrice * (100 - undercutPercent) / 100)
  
  -- Ensure minimum price of 1 copper
  undercutPrice = math.max(undercutPrice, 1)
  
  -- Set the price
  self:SetPrice(undercutPrice)
end

function AuctionatorSaleItemMixin:OnPostButtonClicked()
  if not self.itemLink then
    return
  end
  
  local quantity = tonumber(self.QuantityInput.InputBox:GetText()) or 0
  local price = self:GetPrice()
  local duration = 2 -- Default to medium duration
  
  if self.Duration and self.Duration.DropDown then
    duration = UIDropDownMenu_GetSelectedValue(self.Duration.DropDown) or 2
  end
  
  -- Validate inputs
  if quantity <= 0 or quantity > self.stackSize then
    -- Invalid quantity
    self.QuantityInput.InputBox:SetFocus()
    return
  end
  
  if price <= 0 then
    -- Invalid price
    self.PriceInput.GoldBox:SetFocus()
    return
  end
  
  -- Post the auction
  C_AuctionHouse.PostItem(self.itemLink, duration, quantity, nil, price)
  
  -- Save price for future reference
  if Auctionator.Database and Auctionator.Database.SaveLastSalePrice then
    Auctionator.Database.SaveLastSalePrice(self.itemLink, price)
  end
  
  -- Reset after posting
  self:Reset()
end 