local addonName, VUI = ...
local Auctionator = VUI.Auctionator

-- Create EventBus alias to point to the Events system
-- This fixes inconsistencies in the codebase where both names are used
Auctionator.EventBus = Auctionator.Events

-- Add convenience methods using the same API as referenced in the codebase
function Auctionator.EventBus:Initialize()
  -- EventBus is already initialized by CreateEventBuses.lua, so this is a no-op
  -- But this method is called in Main.lua, so we need to provide it
  return
end

function Auctionator.EventBus:Fire(source, eventName, ...)
  -- Source parameter is unused in our implementation but provided for compatibility
  Auctionator.Events:Fire(eventName, ...)
end

function Auctionator.EventBus:Register(source, eventName, handler)
  -- Source parameter is unused in our implementation but provided for compatibility
  Auctionator.Events:RegisterHandler(eventName, handler)
end

function Auctionator.EventBus:RegisterOnce(source, eventName, handler)
  -- Source parameter is unused in our implementation but provided for compatibility
  Auctionator.Events:RegisterHandlerOnce(eventName, handler)
end

function Auctionator.EventBus:Unregister(source, eventName, handler)
  -- Source parameter is unused in our implementation but provided for compatibility
  Auctionator.Events:UnregisterHandler(eventName, handler)
end