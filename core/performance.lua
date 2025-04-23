local _, VUI = ...

-- Performance optimization tools
VUI.Performance = {}

-- Throttle a function call to prevent excessive updates
-- Example: VUI.Performance:Throttle(myUpdateFunction, 0.1, true)
function VUI.Performance:Throttle(callback, interval, leading)
    interval = interval or 0.1 -- Default to 100ms
    
    local lastCall = 0
    local throttled = false
    local args
    
    -- Create and return a throttled function
    return function(...)
        local now = GetTime()
        local elapsed = now - lastCall
        
        args = {...}
        
        if elapsed >= interval then
            -- Execute immediately if enough time has passed
            lastCall = now
            return callback(unpack(args))
        elseif leading and not throttled then
            -- Execute first call immediately if leading is true
            lastCall = now
            throttled = true
            return callback(unpack(args))
        else
            -- Schedule with C_Timer if throttled
            if not throttled then
                throttled = true
                C_Timer.After(interval - elapsed, function()
                    throttled = false
                    lastCall = GetTime()
                    callback(unpack(args))
                end)
            end
        end
    end
end

-- Debounce a function call to only execute after calls have stopped
-- Example: VUI.Performance:Debounce(myExpensiveFunction, 0.3)
function VUI.Performance:Debounce(callback, wait, immediate)
    wait = wait or 0.3 -- Default to 300ms
    
    local timeout
    local args
    
    -- Create and return a debounced function
    return function(...)
        args = {...}
        
        if timeout then
            timeout:Cancel()
            timeout = nil
        end
        
        if immediate and not timeout then
            callback(unpack(args))
        end
        
        timeout = C_Timer.NewTimer(wait, function()
            timeout = nil
            if not immediate then
                callback(unpack(args))
            end
        end)
    end
end

-- Frame rate optimization for expensive UI operations
-- Only executes when FPS is above threshold or force=true
function VUI.Performance:OptimizeUIUpdate(callback, minFps, force)
    minFps = minFps or 30 -- Default to 30 FPS minimum
    
    -- Check current frame rate
    local currentFps = GetFramerate()
    
    if force or currentFps >= minFps then
        -- Safe to run expensive operation
        return callback()
    else
        -- Skip update to maintain performance
        return nil
    end
end

-- Apply optimizations to a module's update functions
function VUI.Performance:OptimizeModule(module)
    if not module then return end
    
    -- Optimize any OnUpdate handlers
    if module.OnUpdate then
        local originalOnUpdate = module.OnUpdate
        module.OnUpdate = function(self, elapsed, ...)
            -- Skip some updates in combat if frame rate is low
            if InCombatLockdown() and GetFramerate() < 30 then
                self.updateCounter = (self.updateCounter or 0) + elapsed
                if self.updateCounter < 0.1 then -- Skip updates for 100ms during combat
                    return
                end
                self.updateCounter = 0
            end
            
            return originalOnUpdate(self, elapsed, ...)
        end
    end
    
    -- Optimize any bag update functions
    if module.UpdateAllBags then
        module.UpdateAllBags = VUI.Performance:Throttle(module.UpdateAllBags, 0.2, true)
    end
    
    -- Optimize any frame update functions
    if module.UpdateCharacterFrame then
        module.UpdateCharacterFrame = VUI.Performance:Throttle(module.UpdateCharacterFrame, 0.1, true)
    end
    
    -- Apply optimizations to action bar updates
    if module.UpdateActionBars then
        module.UpdateActionBars = VUI.Performance:Throttle(module.UpdateActionBars, 0.1, true)
    end
    
    -- Throttle cooldown updates as they can be very frequent
    if module.UpdateCooldownText then
        module.UpdateCooldownText = VUI.Performance:Throttle(module.UpdateCooldownText, 0.05, false)
    end
    
    return module
end