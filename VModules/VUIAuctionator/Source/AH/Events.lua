local addonName, VUI = ...
local Auctionator = VUI.Auctionator

-- Event handling related to the Auction House
Auctionator.AH.Events = {
  -- Track whether AH is ready
  IsReady = false,
  
  -- Callbacks waiting for AH ready
  Callbacks = {},
}

-- Register a callback to run when the AH is ready
function Auctionator.AH.Events.RegisterCallback(callback)
  if Auctionator.AH.Events.IsReady then
    -- AH is already ready, run callback immediately
    callback()
  else
    -- AH not yet ready, store callback for later
    table.insert(Auctionator.AH.Events.Callbacks, callback)
  end
end

-- Mark AH as ready and run pending callbacks
function Auctionator.AH.Events.SetReady()
  Auctionator.AH.Events.IsReady = true
  
  -- Run all pending callbacks
  for _, callback in ipairs(Auctionator.AH.Events.Callbacks) do
    callback()
  end
  
  -- Clear callbacks
  Auctionator.AH.Events.Callbacks = {}
end

-- Mark AH as not ready
function Auctionator.AH.Events.SetNotReady()
  Auctionator.AH.Events.IsReady = false
end

-- Register event handlers
Auctionator.Events.Register(Auctionator.Constants.EVENTS.AH_READY, function()
  Auctionator.AH.Events.SetReady()
end)

-- Setup event management for Auction House
if Auctionator.Constants.Features.IsModernAH() then
  -- For Retail WoW
  local frame = CreateFrame("Frame")
  
  -- Register for AH events
  frame:RegisterEvent("AUCTION_HOUSE_SHOW")
  frame:RegisterEvent("AUCTION_HOUSE_CLOSED")
  
  -- Handle events
  frame:SetScript("OnEvent", function(self, event, ...)
    if event == "AUCTION_HOUSE_SHOW" then
      -- AH is not immediately ready when shown
      -- Signal will come from AH.Main once UI is fully loaded
      Auctionator.AH.Events.SetNotReady()
    elseif event == "AUCTION_HOUSE_CLOSED" then
      Auctionator.AH.Events.SetNotReady()
    end
  end)
else
  -- For Classic WoW
  local frame = CreateFrame("Frame")
  
  -- Register for AH events
  frame:RegisterEvent("AUCTION_HOUSE_SHOW")
  frame:RegisterEvent("AUCTION_HOUSE_CLOSED")
  
  -- Handle events
  frame:SetScript("OnEvent", function(self, event, ...)
    if event == "AUCTION_HOUSE_SHOW" then
      -- AH is not immediately ready when shown
      -- Signal will come from AH.Main once UI is fully loaded
      Auctionator.AH.Events.SetNotReady()
    elseif event == "AUCTION_HOUSE_CLOSED" then
      Auctionator.AH.Events.SetNotReady()
    end
  end)
end