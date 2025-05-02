--[[
    VUI - MultiNotification Frame Pool System
    Author: VortexQ8
    
    Implements a frame pooling system for notification frames to improve performance
    by reducing garbage collection and frame creation overhead.
]]

local _, VUI = ...
local MultiNotification = VUI:GetModule("MultiNotification")

-- Create the frame pool system
MultiNotification.FramePool = {
    pools = {},
    stats = {
        framesCreated = 0,
        framesRecycled = 0,
        memoryReduction = 0,  -- Estimated in KB
    },
    initialized = false
}

local FramePool = MultiNotification.FramePool

-- Initialize the frame pool system
function FramePool:Initialize()
    -- Create pool for notification frames
    self.pools.notification = {
        frames = {},     -- Available frames
        active = {},     -- Currently in use
        prototype = nil, -- Function to create new frames
        reset = nil,     -- Function to reset a frame
    }
    
    -- Set up the prototype function for creating new notification frames
    self.pools.notification.prototype = function(poolID)
        local frame = CreateFrame("Frame", "VUIMultiNotification_Pooled_"..poolID, UIParent)
        frame:SetSize(40, 40)
        frame:SetScale(MultiNotification.db.profile.globalSettings.scale)
        frame:SetFrameStrata("HIGH")
        frame:Hide()
        
        -- Background texture
        frame.background = frame:CreateTexture(nil, "BACKGROUND")
        frame.background:SetAllPoints()
        
        -- Border texture
        frame.border = frame:CreateTexture(nil, "BORDER")
        frame.border:SetAllPoints()
        
        -- Icon
        frame.icon = frame:CreateTexture(nil, "ARTWORK")
        frame.icon:SetPoint("CENTER")
        frame.icon:SetSize(32, 32)
        frame.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9) -- Trim icon borders
        
        -- Glow
        frame.glow = frame:CreateTexture(nil, "OVERLAY")
        frame.glow:SetPoint("CENTER")
        frame.glow:SetSize(60, 60)
        frame.glow:SetBlendMode("ADD")
        frame.glow:SetAlpha(0.8)
        
        -- Text
        frame.text = frame:CreateFontString(nil, "OVERLAY")
        frame.text:SetPoint("BOTTOM", 0, -15)
        frame.text:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE")
        
        -- Cooldown
        frame.cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
        frame.cooldown:SetPoint("CENTER")
        frame.cooldown:SetSize(36, 36)
        frame.cooldown:SetHideCountdownNumbers(true)
        
        -- Animation group for fade in/out
        frame.animGroup = frame:CreateAnimationGroup()
        
        -- Fade in animation
        frame.fadeIn = frame.animGroup:CreateAnimation("Alpha")
        frame.fadeIn:SetFromAlpha(0)
        frame.fadeIn:SetToAlpha(1)
        frame.fadeIn:SetDuration(0.3)
        frame.fadeIn:SetOrder(1)
        
        -- Fade out animation
        frame.fadeOut = frame.animGroup:CreateAnimation("Alpha")
        frame.fadeOut:SetFromAlpha(1)
        frame.fadeOut:SetToAlpha(0)
        frame.fadeOut:SetDuration(0.5)
        frame.fadeOut:SetStartDelay(3) -- Default delay
        frame.fadeOut:SetOrder(2)
        
        -- Update stats
        self.stats.framesCreated = self.stats.framesCreated + 1
        
        -- Use atlas for textures if available
        if VUI.Atlas then
            VUI.Atlas:ApplyAtlasTextures(frame)
        end
        
        return frame
    end
    
    -- Set up the reset function
    self.pools.notification.reset = function(frame)
        -- Hide the frame
        frame:Hide()
        
        -- Stop any running animations
        if frame.animGroup:IsPlaying() then
            frame.animGroup:Stop()
        end
        
        -- Reset cooldown
        if frame.cooldown:IsShown() then
            frame.cooldown:Hide()
        end
        
        -- Clear any click handlers
        frame:SetScript("OnMouseDown", nil)
        frame:SetScript("OnMouseUp", nil)
        frame:SetScript("OnHide", nil)
        
        -- Clear text
        frame.text:SetText("")
        
        -- Reset alpha
        frame:SetAlpha(1)
        
        -- Remove references
        frame.notificationData = nil
        
        return frame
    end
    
    -- Pre-create some notification frames (configurable)
    local preCacheCount = 5  -- Create a few frames initially for immediate use
    for i = 1, preCacheCount do
        local frame = self.pools.notification.prototype(i)
        table.insert(self.pools.notification.frames, frame)
    end
    
    self.initialized = true
    
    if VUI.debug then
        VUI:Print(string.format("MultiNotification frame pool initialized with %d precached frames", preCacheCount))
    end
end

-- Acquire a frame from the pool
function FramePool:AcquireFrame(poolType)
    -- Check if pool exists
    if not self.pools[poolType] then
        error("Frame pool type '" .. poolType .. "' does not exist")
        return nil
    end
    
    local pool = self.pools[poolType]
    local frame
    
    -- Get a frame from the pool or create a new one
    if #pool.frames > 0 then
        frame = table.remove(pool.frames, 1)
        self.stats.framesRecycled = self.stats.framesRecycled + 1
        
        -- Each recycled frame saves approximately 10KB memory 
        -- (rough estimate based on frame complexity)
        self.stats.memoryReduction = self.stats.memoryReduction + 10
    else
        local id = self.stats.framesCreated + 1
        frame = pool.prototype(id)
    end
    
    -- Add to active frames
    table.insert(pool.active, frame)
    
    -- Return the frame
    return frame
end

-- Release a frame back to the pool
function FramePool:ReleaseFrame(frame, poolType)
    -- Check if pool exists
    if not self.pools[poolType] then
        error("Frame pool type '" .. poolType .. "' does not exist")
        return
    end
    
    local pool = self.pools[poolType]
    
    -- Find the frame in active frames
    for i, activeFrame in ipairs(pool.active) do
        if activeFrame == frame then
            table.remove(pool.active, i)
            
            -- Reset the frame
            frame = pool.reset(frame)
            
            -- Add back to pool
            table.insert(pool.frames, frame)
            
            break
        end
    end
end

-- Release all frames from a specific pool
function FramePool:ReleaseAllFrames(poolType)
    -- Check if pool exists
    if not self.pools[poolType] then
        error("Frame pool type '" .. poolType .. "' does not exist")
        return
    end
    
    local pool = self.pools[poolType]
    
    -- Process all active frames
    while #pool.active > 0 do
        local frame = table.remove(pool.active)
        frame = pool.reset(frame)
        table.insert(pool.frames, frame)
    end
end

-- Get pool statistics
function FramePool:GetStats()
    -- Calculate memory reduction in MB
    local memoryInMB = self.stats.memoryReduction / 1024
    
    return {
        framesCreated = self.stats.framesCreated,
        framesRecycled = self.stats.framesRecycled,
        memoryReduction = memoryInMB
    }
end

-- Register this file with the module
VUI:RegisterModuleScript("MultiNotification", "FramePool")