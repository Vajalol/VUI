--[[
    VUI - SpellNotifications FramePool
    Version: 0.2.0
    Author: VortexQ8
    
    Frame pooling system for improved performance in spell notifications
]]

local addonName, VUI = ...

if not VUI.modules.spellnotifications then return end

-- Namespaces
local module = VUI:GetModule("SpellNotifications")
module.FramePool = {}
local FramePool = module.FramePool

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

-- Statistics for performance monitoring
FramePool.stats = {
    framesCreated = 0,
    framesRecycled = 0,
    currentActiveFrames = 0,
    peakActiveFrames = 0,
    lastResetTime = 0
}

-- Initialize the frame pool system
function FramePool:Initialize()
    -- Preallocate a reasonable number of frames for efficiency
    local maxNotifications = module.db.profile.maxNotifications or 3
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
    if VUI.debug then
        VUI:Print("SpellNotifications FramePool initialized with " .. (maxNotifications * 2) .. " preallocated frames")
    end
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
    local frame = CreateFrame("Frame", "VUISpellNotification" .. index, UIParent)
    frame:SetSize(module.db.profile.size, module.db.profile.size)
    frame:SetPoint(
        module.db.profile.position.point,
        UIParent,
        module.db.profile.position.point,
        module.db.profile.position.x,
        module.db.profile.position.y
    )
    frame:SetAlpha(0)
    frame:Hide()
    
    -- Background texture
    frame.texture = frame:CreateTexture(nil, "BACKGROUND")
    frame.texture:SetAllPoints(frame)
    frame.texture:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\notification")
    
    -- Glow effect
    frame.glow = frame:CreateTexture(nil, "BACKGROUND", nil, -1)
    frame.glow:SetPoint("CENTER", frame, "CENTER", 0, 0)
    frame.glow:SetSize(frame:GetSize())
    frame.glow:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\glow")
    frame.glow:SetBlendMode("ADD")
    frame.glow:SetAlpha(0.7)
    
    -- Spell icon texture
    frame.spellIcon = frame:CreateTexture(nil, "ARTWORK")
    frame.spellIcon:SetPoint("CENTER", frame, "CENTER", 0, 0)
    frame.spellIcon:SetSize(frame:GetWidth() * 0.6, frame:GetHeight() * 0.6)
    frame.spellIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Crop default icon border
    
    -- Border overlay
    frame.border = frame:CreateTexture(nil, "BORDER")
    frame.border:SetAllPoints(frame)
    frame.border:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\border")
    frame.border:SetBlendMode("BLEND")
    
    -- Text label
    frame.text = frame:CreateFontString(nil, "OVERLAY")
    frame.text:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    frame.text:SetPoint("BOTTOM", frame, "BOTTOM", 0, -15)
    frame.text:SetTextColor(1, 1, 1)
    
    -- Fade in animation
    frame.fadeGroup = frame:CreateAnimationGroup()
    local fadeIn = frame.fadeGroup:CreateAnimation("Alpha")
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(1)
    fadeIn:SetDuration(0.3)
    fadeIn:SetOrder(1)
    frame.fadeGroup:SetScript("OnFinished", function()
        frame:SetAlpha(1)
    end)
    
    -- Fade out animation
    frame.animGroup = frame:CreateAnimationGroup()
    local fadeOut = frame.animGroup:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(0.5)
    fadeOut:SetStartDelay(2.5)
    fadeOut:SetOrder(1)
    frame.animGroup:SetScript("OnFinished", function()
        frame:SetAlpha(0)
        frame:Hide()
        
        -- Notify the pool that this frame is now available again
        if frame.poolInfo and frame.poolInfo.onHide and type(frame.poolInfo.onHide) == "function" then
            frame.poolInfo.onHide(frame)
        end
    end)
    
    -- Pulse animation for special notifications
    frame.pulseAnimGroup = frame:CreateAnimationGroup()
    local pulseAlpha1 = frame.pulseAnimGroup:CreateAnimation("Alpha")
    pulseAlpha1:SetFromAlpha(0.7)
    pulseAlpha1:SetToAlpha(1)
    pulseAlpha1:SetDuration(0.5)
    pulseAlpha1:SetOrder(1)
    local pulseAlpha2 = frame.pulseAnimGroup:CreateAnimation("Alpha")
    pulseAlpha2:SetFromAlpha(1)
    pulseAlpha2:SetToAlpha(0.7)
    pulseAlpha2:SetDuration(0.5)
    pulseAlpha2:SetOrder(2)
    frame.pulseAnimGroup:SetLooping("REPEAT")
    
    -- Setup target animation
    frame.pulseSizeAnimGroup = frame:CreateAnimationGroup()
    local pulseSize1 = frame.pulseSizeAnimGroup:CreateAnimation("Scale")
    pulseSize1:SetScale(1.2, 1.2)
    pulseSize1:SetDuration(0.3)
    pulseSize1:SetOrder(1)
    local pulseSize2 = frame.pulseSizeAnimGroup:CreateAnimation("Scale")
    pulseSize2:SetScale(1/1.2, 1/1.2)
    pulseSize2:SetDuration(0.3)
    pulseSize2:SetOrder(2)
    frame.pulseSizeAnimGroup:SetLooping("REPEAT")
    
    -- Setup spotlight animation
    frame.spotlightAnimGroup = frame:CreateAnimationGroup()
    local spotlightRotate = frame.spotlightAnimGroup:CreateAnimation("Rotation")
    spotlightRotate:SetDegrees(360)
    spotlightRotate:SetDuration(8)
    frame.spotlightAnimGroup:SetLooping("REPEAT")
    
    -- Store pool metadata on the frame
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
        self.spellIcon:SetTexture(nil)
        self.text:SetText("")
        
        -- Stop any playing animations
        if self.fadeGroup:IsPlaying() then 
            self.fadeGroup:Stop() 
        end
        if self.animGroup:IsPlaying() then 
            self.animGroup:Stop() 
        end
        if self.pulseAnimGroup:IsPlaying() then 
            self.pulseAnimGroup:Stop() 
        end
        if self.pulseSizeAnimGroup:IsPlaying() then 
            self.pulseSizeAnimGroup:Stop() 
        end
        if self.spotlightAnimGroup:IsPlaying() then 
            self.spotlightAnimGroup:Stop() 
        end
        
        -- Reset position
        self:ClearAllPoints()
        
        -- Return to default size and alpha
        self:SetSize(module.db.profile.size, module.db.profile.size)
        self:SetAlpha(0)
        
        -- Reset glow size
        self.glow:SetSize(self:GetSize())
        self.spellIcon:SetSize(self:GetWidth() * 0.6, self:GetHeight() * 0.6)
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
            module:ApplyTheme(frame)
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
    
    -- Log stats if debugging is enabled
    if VUI.debug then
        VUI:Print(string.format(
            "SpellNotifications FramePool stats: Created: %d, Recycled: %d, Active: %d, Peak: %d",
            self.stats.framesCreated,
            self.stats.framesRecycled,
            self.stats.currentActiveFrames,
            self.stats.peakActiveFrames
        ))
    end
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
    local estimatedSavingsPerFrame = 4 -- KB (notification frames are more complex)
    return (self.stats.framesRecycled * estimatedSavingsPerFrame) / 1024 -- Convert to MB
end