local addonName, VUI = ...
local Auctionator = VUI.Auctionator

-- Throttle utility for preventing API spam
Auctionator.Utilities.Throttle = {}

-- Create a new throttle instance
-- interval: minimum time between executions (in seconds)
-- leading: if true, execute on the first call
-- trailing: if true, execute after the cooldown
function Auctionator.Utilities.Throttle.Create(interval, leading, trailing)
  -- Default parameters
  interval = interval or 0.5 -- Default to 500ms
  
  if leading == nil then
    leading = true
  end
  
  if trailing == nil then
    trailing = true
  end
  
  local throttle = {
    interval = interval,
    leading = leading,
    trailing = trailing,
    lastCall = 0,
    timeout = nil,
    pendingArgs = nil,
    pendingFunc = nil
  }
  
  -- The main throttling function
  -- Returns a function that will throttle calls to the provided function
  function throttle:Wrap(func)
    return function(...)
      local now = GetTime()
      local elapsed = now - self.lastCall
      local args = {...}
      
      -- Clear any existing timeout
      if self.timeout then
        self.timeout:Cancel()
        self.timeout = nil
      end
      
      if elapsed >= self.interval then
        -- Enough time has elapsed, execute now if leading
        self.lastCall = now
        
        if self.leading then
          return func(unpack(args))
        end
      end
      
      -- Store for potential trailing execution
      if self.trailing then
        self.pendingFunc = func
        self.pendingArgs = args
        
        -- Set timeout for trailing execution
        local remainingTime = self.interval - elapsed
        
        if remainingTime <= 0 then
          remainingTime = self.interval
        end
        
        self.timeout = C_Timer.NewTimer(remainingTime, function()
          if self.pendingFunc and self.pendingArgs then
            self.lastCall = GetTime()
            self.pendingFunc(unpack(self.pendingArgs))
            self.pendingFunc = nil
            self.pendingArgs = nil
            self.timeout = nil
          end
        end)
      end
    end
  end
  
  -- Cancel any pending execution
  function throttle:Cancel()
    if self.timeout then
      self.timeout:Cancel()
      self.timeout = nil
    end
    
    self.pendingFunc = nil
    self.pendingArgs = nil
  end
  
  return throttle
end

-- Create a debounce function
-- Ensures that a function is not executed until after a specified delay
-- If the debounced function is called again before the delay has finished, the timer resets
function Auctionator.Utilities.Debounce(func, delay)
  delay = delay or 0.3 -- Default to 300ms
  
  local timeout
  
  return function(...)
    local args = {...}
    
    -- Cancel previous timeout if it exists
    if timeout then
      timeout:Cancel()
    end
    
    -- Create new timeout
    timeout = C_Timer.NewTimer(delay, function()
      func(unpack(args))
      timeout = nil
    end)
  end
end