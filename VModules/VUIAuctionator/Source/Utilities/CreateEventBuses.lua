local addonName, VUI = ...
<<<<<<< HEAD
local Auctionator = VUI.Auctionator or {}
VUI.Auctionator = Auctionator

-- Ensure required namespaces exist
Auctionator.Utilities = Auctionator.Utilities or {}

-- Safety check for CreateEventBus function
if not Auctionator.Utilities.CreateEventBus then
    -- Fallback implementation if the original is missing
    Auctionator.Utilities.CreateEventBus = function()
        local eventBus = {
            handlers = {},
            RegisterHandler = function(self, eventName, handler)
                if not self.handlers[eventName] then
                    self.handlers[eventName] = {}
                end
                table.insert(self.handlers[eventName], handler)
            end,
            Fire = function(self, eventName, ...)
                if self.handlers[eventName] then
                    for _, handler in ipairs(self.handlers[eventName]) do
                        pcall(handler, ...)
                    end
                end
            end,
            RegisterHandlerOnce = function(self, eventName, handler)
                local function oneTimeHandler(...)
                    handler(...)
                    self:UnregisterHandler(eventName, oneTimeHandler)
                end
                self:RegisterHandler(eventName, oneTimeHandler)
            end,
            UnregisterHandler = function(self, eventName, handler)
                if not self.handlers[eventName] then return end
                for i, h in ipairs(self.handlers[eventName]) do
                    if h == handler then
                        table.remove(self.handlers[eventName], i)
                        break
                    end
                end
            end,
            UnregisterAllHandlers = function(self, eventName)
                self.handlers[eventName] = nil
            end
        }
        return eventBus
    end
end
=======
local M = VUI:GetModule("VUIAuctionator")
local Auctionator = VUI.Auctionator
>>>>>>> f2841d4c299e00869d4563d9e99c5e582069affc

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