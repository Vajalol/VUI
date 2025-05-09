local addonName, VUI = ...
local Auctionator = VUI.Auctionator

-- Simple event bus implementation
Auctionator.Utilities.CreateEventBus = function()
  local eventBus = {
    -- Event handlers storage
    handlers = {},
    -- Event firing queue to avoid recursive event firing causing issues
    queue = {},
    -- Flag indicating we're processing events
    isProcessing = false
  }

  -- Register a handler function for an event
  function eventBus:RegisterHandler(eventName, handler)
    if self.handlers[eventName] == nil then
      self.handlers[eventName] = {}
    end

    table.insert(self.handlers[eventName], handler)
  end

  -- Fire an event with optional arguments
  function eventBus:Fire(eventName, ...)
    -- Queue the event for processing
    table.insert(self.queue, {eventName = eventName, args = {...}})
    
    -- If we're already processing events, the event will be processed by the existing loop
    if self.isProcessing then
      return
    end
    
    -- Set flag and start processing
    self.isProcessing = true
    
    -- Process all events in the queue
    while #self.queue > 0 do
      local event = table.remove(self.queue, 1)
      
      if self.handlers[event.eventName] ~= nil then
        for _, handler in ipairs(self.handlers[event.eventName]) do
          -- Call handler with arguments
          handler(unpack(event.args))
        end
      end
    end
    
    -- Clear flag when done
    self.isProcessing = false
  end

  -- Convenience method for registering a one-time handler that removes itself after firing
  function eventBus:RegisterHandlerOnce(eventName, handler)
    local function oneTimeHandler(...)
      -- Call original handler
      handler(...)
      
      -- Find and remove this handler
      if self.handlers[eventName] ~= nil then
        for index, registeredHandler in ipairs(self.handlers[eventName]) do
          if registeredHandler == oneTimeHandler then
            table.remove(self.handlers[eventName], index)
            break
          end
        end
      end
    end
    
    -- Register the one-time handler
    self:RegisterHandler(eventName, oneTimeHandler)
  end

  -- Unregister a specific handler for an event
  function eventBus:UnregisterHandler(eventName, handler)
    if self.handlers[eventName] == nil then
      return
    end
    
    for index, registeredHandler in ipairs(self.handlers[eventName]) do
      if registeredHandler == handler then
        table.remove(self.handlers[eventName], index)
        break
      end
    end
  end

  -- Clear all handlers for an event
  function eventBus:UnregisterAllHandlers(eventName)
    self.handlers[eventName] = nil
  end

  return eventBus
end