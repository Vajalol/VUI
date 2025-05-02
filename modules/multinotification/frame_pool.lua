--[[
    VUI - MultiNotification FramePool
    Version: 1.0.0
    Author: VortexQ8
    
    Frame pooling system for improved performance in the unified notification system
]]

local addonName, VUI = ...

if not VUI.modules.multinotification then return end

-- Namespaces
local MultiNotification = VUI.modules.multinotification
MultiNotification.FramePool = {}
local FramePool = MultiNotification.FramePool

-- Frame pools organized by type
FramePool.pools = {
    notification = {
        active = {},
        inactive = {},
        count = {
            created = 0,
            active = 0,
            recycled = 0
        }
    }
}

-- Statistics for performance monitoring - disabled in production
FramePool.stats = {
    framesCreated = 0,
    framesRecycled = 0,
    currentActiveFrames = 0,
    peakActiveFrames = 0,
    lastResetTime = 0,
    enabled = false -- Statistics tracking disabled in production
}

-- Initialize the frame pool system
function FramePool:Initialize()
    -- Preallocate a reasonable number of frames for efficiency
    local maxNotifications = MultiNotification.db.profile.globalSettings.maxNotifications or 5
    self:PreallocateFrames("notification", maxNotifications * 2) -- Preallocate twice the max for performance
    
    -- Register callback for theme changes to update all frames
    if VUI.callbacks and VUI.callbacks.RegisterCallback then
        VUI.callbacks:RegisterCallback("OnThemeChanged", function(theme)
            self:UpdateAllActiveFrames(theme)
        end)
    end
    
    -- Update stats periodically (once every minute)
    self:CreateStatsMonitor()
    
    -- Log initialization
    -- Initialization message disabled in production release
end

-- Preallocate frames for efficiency
function FramePool:PreallocateFrames(poolType, count)
    if not self.pools[poolType] then return end
    
    for i = 1, count do
        local frame = self:CreateFrame(poolType, i)
        if frame then
            frame:Hide()
            table.insert(self.pools[poolType].inactive, frame)
            self.pools[poolType].count.created = self.pools[poolType].count.created + 1
            self.stats.framesCreated = self.stats.framesCreated + 1
        end
    end
end

-- Create a new frame based on pool type
function FramePool:CreateFrame(poolType, index)
    if poolType == "notification" then
        return self:CreateNotificationFrame(index)
    end
    
    return nil
end

-- Create a notification frame (similar to the original function but designed for pooling)
function FramePool:CreateNotificationFrame(index)
    local frame = CreateFrame("Frame", "VUIMultiNotificationPooled"..index, UIParent)
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
    frame.fadeOut:SetStartDelay(2.5) -- Default display time
    frame.fadeOut:SetOrder(2)
    
    -- Handle animation completion
    frame.animGroup:SetScript("OnFinished", function()
        frame:Hide()
        
        -- Notify the pool that this frame is now available again
        if frame.poolInfo and frame.poolInfo.onHide and type(frame.poolInfo.onHide) == "function" then
            frame.poolInfo.onHide(frame)
        end
        
        -- Run any registered callbacks when notification completes
        if frame.onCompleteCallback and type(frame.onCompleteCallback) == "function" then
            frame.onCompleteCallback(frame)
        end
        
        -- Remove from active notifications if tracking is enabled
        if MultiNotification.activeNotifications then
            for i, activeFrame in ipairs(MultiNotification.activeNotifications) do
                if activeFrame == frame then
                    table.remove(MultiNotification.activeNotifications, i)
                    break
                end
            end
        end
        
        -- Process the notification queue in case there are pending notifications
        if MultiNotification.ProcessNotificationQueue then
            MultiNotification:ProcessNotificationQueue()
        end
    end)
    
    -- Add custom animation methods
    frame.StartFadeIn = function(self, duration)
        duration = duration or MultiNotification.db.profile.globalSettings.fadeInTime
        self.fadeIn:SetDuration(duration)
        
        -- Stop any running animations
        if self.animGroup:IsPlaying() then
            self.animGroup:Stop()
        end
        
        -- Show the frame and start fade-in
        self:Show()
        self:SetAlpha(0)
        
        -- Only play the fade-in part
        self.fadeIn:Play()
    end
    
    frame.StartFadeOut = function(self, delay, duration)
        delay = delay or MultiNotification.db.profile.globalSettings.timeVisible
        duration = duration or MultiNotification.db.profile.globalSettings.fadeOutTime
        
        self.fadeOut:SetStartDelay(delay)
        self.fadeOut:SetDuration(duration)
        
        -- Play the complete animation sequence
        if not self.animGroup:IsPlaying() then
            self.animGroup:Play()
        end
    end
    
    -- Data tracking for frame pooling
    frame.poolInfo = {
        type = "notification",
        index = index,
        inUse = false,
        recycleCount = 0,
        creationTime = GetTime()
    }
    
    -- Add functions to easily manage the frame
    frame.Reset = function(self)
        -- Reset all display properties to default state
        self.icon:SetTexture(nil)
        self.text:SetText("")
        self.background:SetTexture(nil)
        self.border:SetTexture(nil)
        self.glow:SetTexture(nil)
        self.cooldown:Clear()
        
        -- Stop any playing animations
        if self.animGroup:IsPlaying() then 
            self.animGroup:Stop() 
        end
        
        -- Reset position
        self:ClearAllPoints()
        
        -- Return to default size and alpha
        self:SetSize(40, 40)
        self:SetAlpha(0)
        
        -- Reset scale
        self:SetScale(MultiNotification.db.profile.globalSettings.scale)
        
        -- Reset callback
        self.onCompleteCallback = nil
        
        -- Reset notification data
        self.notificationType = nil
        self.duration = nil
        self.priority = nil
    end
    
    return frame
end

-- Acquire a frame from the pool
function FramePool:AcquireFrame(poolType)
    if not self.pools[poolType] then return nil end
    
    local pool = self.pools[poolType]
    local frame
    
    -- Try to get an inactive frame
    if #pool.inactive > 0 then
        frame = table.remove(pool.inactive)
        frame:Reset()
        frame.poolInfo.recycleCount = frame.poolInfo.recycleCount + 1
        frame.poolInfo.inUse = true
        pool.count.recycled = pool.count.recycled + 1
        self.stats.framesRecycled = self.stats.framesRecycled + 1
    else
        -- Create a new frame if none are available
        local newIndex = pool.count.created + 1
        frame = self:CreateFrame(poolType, newIndex)
        
        if frame then
            frame.poolInfo.inUse = true
            pool.count.created = newIndex
            self.stats.framesCreated = self.stats.framesCreated + 1
        end
    end
    
    -- Add to active list
    if frame then
        table.insert(pool.active, frame)
        pool.count.active = pool.count.active + 1
        self.stats.currentActiveFrames = self.stats.currentActiveFrames + 1
        
        -- Update peak count
        if self.stats.currentActiveFrames > self.stats.peakActiveFrames then
            self.stats.peakActiveFrames = self.stats.currentActiveFrames
        end
        
        -- Set onHide callback
        frame.poolInfo.onHide = function(hiddenFrame)
            self:ReleaseFrame(hiddenFrame)
        end
    end
    
    return frame
end

-- Release a frame back to the pool
function FramePool:ReleaseFrame(frame)
    if not frame or not frame.poolInfo then return end
    
    local poolType = frame.poolInfo.type
    local pool = self.pools[poolType]
    
    if not pool then return end
    
    -- Remove from active list
    for i, activeFrame in ipairs(pool.active) do
        if activeFrame == frame then
            table.remove(pool.active, i)
            break
        end
    end
    
    -- Reset and hide the frame
    frame:Reset()
    frame:Hide()
    frame.poolInfo.inUse = false
    
    -- Add to inactive list
    table.insert(pool.inactive, frame)
    pool.count.active = pool.count.active - 1
    self.stats.currentActiveFrames = self.stats.currentActiveFrames - 1
end

-- Release all frames of a specific type
function FramePool:ReleaseAllFrames(poolType)
    if not poolType or not self.pools[poolType] then return end
    
    local pool = self.pools[poolType]
    
    -- Copy active frames to a temporary table to avoid modifying while iterating
    local activeFrames = {}
    for i, frame in ipairs(pool.active) do
        table.insert(activeFrames, frame)
    end
    
    -- Release each frame
    for _, frame in ipairs(activeFrames) do
        self:ReleaseFrame(frame)
    end
end

-- Update all active frames for a theme change
function FramePool:UpdateAllActiveFrames(theme)
    for poolType, pool in pairs(self.pools) do
        for _, frame in ipairs(pool.active) do
            MultiNotification:ApplyThemeToFrame(frame, frame.notificationType)
        end
    end
end

-- Create stats monitor for performance tracking
function FramePool:CreateStatsMonitor()
    self.statsTimer = C_Timer.NewTicker(60, function()
        self:UpdateStats()
    end)
end

-- Update pool statistics
function FramePool:UpdateStats()
    self.stats.lastResetTime = GetTime()
    
    -- Stats logging disabled in production release
end

-- Get current statistics
function FramePool:GetStats()
    return {
        framesCreated = self.stats.framesCreated,
        framesRecycled = self.stats.framesRecycled,
        activeFrames = self.stats.currentActiveFrames,
        peakActiveFrames = self.stats.peakActiveFrames,
        memoryReduction = self:EstimateMemoryReduction()
    }
end

-- Estimate memory reduction from pooling
function FramePool:EstimateMemoryReduction()
    -- Simple estimate based on typical frame recycling benefit
    -- Each recycled frame saves approximately 2-5KB depending on complexity
    local estimatedSavingsPerFrame = 5 -- KB (notification frames with animations are complex)
    return (self.stats.framesRecycled * estimatedSavingsPerFrame) / 1024 -- Convert to MB
end