local addonName, VUI = ...
local Auctionator = VUI.Auctionator

-- Initialize the Auction House interface
Auctionator.AH.Initialize = function()
  -- Setup the main AH frame
  if Auctionator.Constants.Features.IsModernAH() then
    -- For retail WoW
    Auctionator.AH.SetupModernAH()
  else
    -- For Classic WoW
    Auctionator.AH.SetupClassicAH()
  end
end

-- Setup the modern Auction House interface (Retail)
Auctionator.AH.SetupModernAH = function()
  -- Create event frame
  local eventFrame = CreateFrame("Frame")
  
  -- Register for AH related events
  eventFrame:RegisterEvent("AUCTION_HOUSE_SHOW")
  eventFrame:RegisterEvent("AUCTION_HOUSE_CLOSED")
  
  -- Event handler
  eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "AUCTION_HOUSE_SHOW" then
      Auctionator.AH.AuctionHouseOpened()
    elseif event == "AUCTION_HOUSE_CLOSED" then
      Auctionator.AH.AuctionHouseClosed()
    end
  end)
  
  -- Store frame reference
  Auctionator.AH.EventFrame = eventFrame
  
  -- Register for Auction House OnShow
  hooksecurefunc(AuctionHouseFrame, "OnShow", function()
    -- Notify when the AH is fully loaded
    C_Timer.After(0.5, function()
      Auctionator.AH.OnAHFrameLoaded()
    end)
  end)
end

-- Setup the classic Auction House interface (Classic)
Auctionator.AH.SetupClassicAH = function()
  -- Create event frame
  local eventFrame = CreateFrame("Frame")
  
  -- Register for AH related events
  eventFrame:RegisterEvent("AUCTION_HOUSE_SHOW")
  eventFrame:RegisterEvent("AUCTION_HOUSE_CLOSED")
  
  -- Event handler
  eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "AUCTION_HOUSE_SHOW" then
      Auctionator.AH.AuctionHouseOpened()
    elseif event == "AUCTION_HOUSE_CLOSED" then
      Auctionator.AH.AuctionHouseClosed()
    end
  end)
  
  -- Store frame reference
  Auctionator.AH.EventFrame = eventFrame
  
  -- Hook AuctionFrame OnShow
  if AuctionFrame then
    hooksecurefunc(AuctionFrame, "OnShow", function()
      -- Notify when the AH is fully loaded
      C_Timer.After(0.5, function()
        Auctionator.AH.OnAHFrameLoaded()
      end)
    end)
  end
end

-- Handler for when Auction House opens
Auctionator.AH.AuctionHouseOpened = function()
  Auctionator.Debug.Message("AH.AuctionHouseOpened")
  
  -- Trigger event
  Auctionator.Events.Fire(Auctionator.Constants.EVENTS.AH_READY)
end

-- Handler for when Auction House closes
Auctionator.AH.AuctionHouseClosed = function()
  Auctionator.Debug.Message("AH.AuctionHouseClosed")
end

-- Handler for when AH frame is fully loaded
Auctionator.AH.OnAHFrameLoaded = function()
  Auctionator.Debug.Message("AH.OnAHFrameLoaded")
  
  -- Setup tabs
  if Auctionator.Tabs and Auctionator.Tabs.OnAHOpened then
    Auctionator.Tabs.OnAHOpened()
  end
  
  -- Setup selling tab
  if Auctionator.Selling and Auctionator.Selling.OnAHOpened then
    Auctionator.Selling.OnAHOpened()
  end
  
  -- Setup shopping tab
  if Auctionator.Shopping and Auctionator.Shopping.OnAHOpened then
    Auctionator.Shopping.OnAHOpened()
  end
  
  -- Setup cancelling tab
  if Auctionator.Cancelling and Auctionator.Cancelling.OnAHOpened then
    Auctionator.Cancelling.OnAHOpened()
  end
  
  -- Setup any utility event handlers
  if Auctionator.Utilities and Auctionator.Utilities.OnAHOpened then
    Auctionator.Utilities.OnAHOpened()
  end
end