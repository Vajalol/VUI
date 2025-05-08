local addonName, VUI = ...
local Auctionator = VUI.Auctionator

-- Initialize the event system
Auctionator.Events = Auctionator.Utilities.CreateEventBus()

-- Initialize module-specific event buses
local moduleEventBuses = {
  -- Shopping events
  Shopping = {},
  -- Selling events
  Selling = {},
  -- Cancelling events
  Cancelling = {},
  -- Config events
  Config = {},
  -- Database events
  Database = {},
  -- Tab events
  Tabs = {},
  -- Full scan events
  FullScan = {},
  -- Crafting info events
  CraftingInfo = {},
}

-- Create event buses for modules
for moduleName, _ in pairs(moduleEventBuses) do
  Auctionator[moduleName] = Auctionator[moduleName] or {}
  Auctionator[moduleName].Events = Auctionator.Utilities.CreateEventBus()
end

-- Register on Event - general purpose event registration
Auctionator.Events.Register = function(eventName, handler)
  Auctionator.Events:RegisterHandler(eventName, handler)
end

-- Fire an Event - general purpose event firing
Auctionator.Events.Fire = function(eventName, ...)
  Auctionator.Events:Fire(eventName, ...)
end

-- Register Once - general purpose one-time event registration
Auctionator.Events.RegisterOnce = function(eventName, handler)
  Auctionator.Events:RegisterHandlerOnce(eventName, handler)
end