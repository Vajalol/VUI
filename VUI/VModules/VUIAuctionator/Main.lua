local addonName, VUI = ...

-- Create the main Auctionator table in the VUI namespace
VUI.Auctionator = {
  -- Basic information
  Name = "VUIAuctionator",
  Version = "1.0.0",
  
  -- Flag to track initialization state
  Initialized = false,
  
  -- Module info for VUI integration
  ModuleInfo = {
    title = "VUIAuctionator",
    desc = "Advanced Auction House Tools",
    icon = [[Interface\AddOns\VUI\Media\auctionator.tga]],
    author = "Vortex-WoW"
  }
}

-- Module reference for shorter access
local Auctionator = VUI.Auctionator

function Auctionator:Initialize()
  if self.Initialized then
    return
  end

  -- Initialize EventBus for inter-module communication
  if self.EventBus and self.EventBus.Initialize then
    self.EventBus:Initialize()
  end
  
  -- Initialize Config
  if self.Config and self.Config.Initialize then
    self.Config:Initialize()
  end
  
  -- Initialize Database
  if self.Database and self.Database.Initialize then
    self.Database:Initialize()
  end
  
  -- Initialize subsystems
  if self.Selling and self.Selling.Initialize then
    self.Selling:Initialize()
  end
  
  if self.Lists and self.Lists.Initialize then
    self.Lists:Initialize()
  end
  
  if self.History and self.History.Initialize then
    self.History:Initialize()
  end
  
  if self.Cancel and self.Cancel.Initialize then
    self.Cancel:Initialize()
  end
  
  -- Initialize the Config UI
  if self.Config.UI and self.Config.UI.Initialize then
    self.Config.UI:Initialize()
  end
  
  -- Initialize the main UI
  if self.UI and self.UI.MainFrame and self.UI.MainFrame.Initialize then
    self.UI.MainFrame:Initialize()
  end
  
  -- Set up tooltips
  self:SetupTooltips()
  
  -- Register with VUI Config
  if VUI.Config and VUI.Config.RegisterModule then
    VUI.Config:RegisterModule("VUIAuctionator", self.ModuleInfo.title, self.ModuleInfo.desc, self.ModuleInfo.icon)
  end
  
  -- Setup slash commands
  self:SetupSlashCommands()
  
  -- Register for WoW events
  self:RegisterEvents()
  
  -- Mark as initialized
  self.Initialized = true
  
  -- Print initialization message
  if self.Utilities and self.Utilities.Message then
    self.Utilities.Message.Info("VUIAuctionator loaded (v" .. self.Version .. ")")
  else
    print("|cff00BBBB" .. "VUIAuctionator loaded (v" .. self.Version .. ")" .. "|r")
  end
end

function Auctionator:SetupSlashCommands()
  -- Register slash commands
  SLASH_VUIAUCTIONATOR1 = "/vuia"
  SLASH_VUIAUCTIONATOR2 = "/vuiauctionator"
  
  SlashCmdList["VUIAUCTIONATOR"] = function(msg)
    msg = msg:lower():trim()
    
    if msg == "debug" or msg == "debug toggle" then
      -- Toggle debug mode
      if Auctionator.Debug and Auctionator.Debug.Toggle then
        Auctionator.Debug.Toggle()
      end
    elseif msg == "config" or msg == "" then
      -- Open config panel
      if VUI.Config and VUI.Config.OpenConfigPanel then
        VUI.Config:OpenConfigPanel("VUIAuctionator")
      end
    elseif msg == "version" or msg == "ver" then
      -- Show version
      print("|cff00BBBB" .. "VUIAuctionator version: " .. self.Version .. "|r")
    elseif msg == "help" then
      -- Show help
      print("|cff00BBBBVUIAuctionator commands:|r")
      print("|cff88BBBB/vuia|r - Open configuration")
      print("|cff88BBBB/vuia debug|r - Toggle debug mode")
      print("|cff88BBBB/vuia version|r - Show version")
      print("|cff88BBBB/vuia help|r - Show this help text")
    else
      -- Unknown command
      print("|cff00BBBBVUIAuctionator:|r Unknown command. Type |cff88BBBB/vuia help|r for a list of commands.")
    end
  end
end

function Auctionator:RegisterEvents()
  -- Create a frame for event handling
  self.EventFrame = self.EventFrame or CreateFrame("Frame")
  
  -- Register events
  self.EventFrame:RegisterEvent("ADDON_LOADED")
  self.EventFrame:RegisterEvent("PLAYER_LOGIN")
  self.EventFrame:RegisterEvent("AUCTION_HOUSE_SHOW")
  self.EventFrame:RegisterEvent("AUCTION_HOUSE_CLOSED")
  
  -- Set up event handler
  self.EventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" and ... == addonName then
      -- Initialize once VUI is fully loaded
      C_Timer.After(0.5, function() Auctionator:Initialize() end)
    elseif event == "PLAYER_LOGIN" then
      -- Do any player login initialization
      if Auctionator.Initialized then
        -- Already initialized, do any post-login tasks
      else
        -- Not initialized yet, wait for ADDON_LOADED
      end
    elseif event == "AUCTION_HOUSE_SHOW" then
      -- Handle auction house opened
      if Auctionator.Initialized and Auctionator.AuctionHouse and Auctionator.AuctionHouse.OnShow then
        Auctionator.AuctionHouse:OnShow()
      end
    elseif event == "AUCTION_HOUSE_CLOSED" then
      -- Handle auction house closed
      if Auctionator.Initialized and Auctionator.AuctionHouse and Auctionator.AuctionHouse.OnClose then
        Auctionator.AuctionHouse:OnClose()
      end
    end
  end)
end

-- Function to handle tooltip modifications
function Auctionator:SetupTooltips()
  -- Hook to item tooltips to add auction price information
  local function AddPricesToTooltip(tooltip, itemLink)
    -- Check if tooltip features are enabled
    if not Auctionator.Config.Get(Auctionator.Config.Options.TOOLTIP_MARKET_VALUE) and
       not Auctionator.Config.Get(Auctionator.Config.Options.TOOLTIP_HISTORICAL_PRICE) and
       not Auctionator.Config.Get(Auctionator.Config.Options.TOOLTIP_VENDOR_PRICE) then
      return
    end
    
    -- Check for valid link
    if not itemLink then return end
    
    -- Get market value
    local marketValue = nil
    if Auctionator.Config.Get(Auctionator.Config.Options.TOOLTIP_MARKET_VALUE) then
      marketValue = Auctionator.API.GetMarketValue(itemLink)
    end
    
    -- Get historical price
    local historicalPrice = nil
    if Auctionator.Config.Get(Auctionator.Config.Options.TOOLTIP_HISTORICAL_PRICE) then
      historicalPrice = Auctionator.API.GetHistoricalValue(itemLink)
    end
    
    -- Get vendor price
    local vendorPrice = nil
    if Auctionator.Config.Get(Auctionator.Config.Options.TOOLTIP_VENDOR_PRICE) then
      vendorPrice = Auctionator.API.GetVendorPrice(itemLink)
    end
    
    -- Add market value line
    if marketValue then
      local formattedPrice = Auctionator.Utilities.FormatMoney(marketValue, "GSC", true)
      tooltip:AddDoubleLine(Auctionator.Constants.TOOLTIP.LEFT_TEXT, 
                            Auctionator.Constants.TOOLTIP.RIGHT_TEXT_MARKET .. " " .. formattedPrice,
                            1, 0.82, 0, 1, 0.82, 0)
    end
    
    -- Add historical price line
    if historicalPrice then
      local formattedPrice = Auctionator.Utilities.FormatMoney(historicalPrice, "GSC", true)
      tooltip:AddDoubleLine(Auctionator.Constants.TOOLTIP.LEFT_TEXT,
                            Auctionator.Constants.TOOLTIP.RIGHT_TEXT_HISTORICAL .. " " .. formattedPrice,
                            1, 0.82, 0, 0.8, 0.8, 1)
    end
    
    -- Add vendor price line
    if vendorPrice and vendorPrice > 0 and not Auctionator.Config.Get(Auctionator.Config.Options.HIDE_VENDOR_TIPS) then
      local formattedPrice = Auctionator.Utilities.FormatMoney(vendorPrice, "GSC", true)
      tooltip:AddDoubleLine(Auctionator.Constants.TOOLTIP.LEFT_TEXT,
                            Auctionator.Constants.TOOLTIP.RIGHT_TEXT_VENDOR .. " " .. formattedPrice,
                            1, 0.82, 0, 0.7, 0.7, 0.7)
    end
  end
  
  -- Hook item tooltips
  local function HookTooltip(tooltip)
    tooltip:HookScript("OnTooltipSetItem", function(self)
      local _, itemLink = self:GetItem()
      if itemLink then
        AddPricesToTooltip(self, itemLink)
      end
    end)
  end
  
  -- Hook all game tooltips
  HookTooltip(GameTooltip)
  HookTooltip(ItemRefTooltip)
end