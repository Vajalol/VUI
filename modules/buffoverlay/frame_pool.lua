--[[
    VUI - BuffOverlay FramePool
    Version: 1.0.0
    Author: VortexQ8
    
    Frame pooling system for improved performance
]]

local addonName, VUI = ...

if not VUI.modules.buffoverlay then return end

-- Namespaces
local BuffOverlay = VUI.modules.buffoverlay
BuffOverlay.FramePool = {}
local FramePool = BuffOverlay.FramePool

-- Frame pools organized by type
FramePool.pools = {
    buff = {
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
    self:PreallocateFrames("buff", 20)
    
    -- Register callback for theme changes to update all frames
    if VUI.callbacks and VUI.callbacks.RegisterCallback then
        VUI.callbacks:RegisterCallback("OnThemeChanged", function(theme)
            self:UpdateAllActiveFrames(theme)
        end)
    end
    
    -- Update stats periodically (once every minute)
    self:CreateStatsMonitor()
    
    -- Frame pool preallocated and ready
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
    if poolType == "buff" then
        return self:CreateBuffFrame(index)
    end
    
    return nil
end

-- Create a buff frame (similar to the original function but designed for pooling)
function FramePool:CreateBuffFrame(index)
    local size = VUI.db.profile.modules.buffoverlay.size or 40
    local frame = CreateFrame("Frame", "VUIBuffOverlayFrame" .. index, BuffOverlay.container)
    frame:SetSize(size, size)
    
    -- Icon texture
    frame.icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon:SetAllPoints()
    frame.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Trim the icon borders
    
    -- Border
    frame.border = frame:CreateTexture(nil, "BORDER")
    frame.border:SetPoint("TOPLEFT", frame, "TOPLEFT", -1, 1)
    frame.border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 1, -1)
    frame.border:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
    frame.border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
    frame.border:SetVertexColor(1, 0, 0, 1) -- Default red border
    
    -- Glow overlay for theme effects using the atlas system
    frame.glow = frame:CreateTexture(nil, "OVERLAY")
    frame.glow:SetPoint("TOPLEFT", frame, "TOPLEFT", -3, 3)
    frame.glow:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 3, -3)
    
    -- Get texture from the module's atlas
    local glowTexture = "Interface\\AddOns\\VUI\\media\\textures\\buffoverlay\\glow.tga"
    local atlasTextureInfo = VUI:GetTextureCached(glowTexture)
    
    if atlasTextureInfo and atlasTextureInfo.isAtlas then
        -- Apply texture from atlas
        frame.glow:SetTexture(atlasTextureInfo.path)
        frame.glow:SetTexCoord(
            atlasTextureInfo.coords.left,
            atlasTextureInfo.coords.right,
            atlasTextureInfo.coords.top,
            atlasTextureInfo.coords.bottom
        )
        
        -- Using optimized atlas texture
    else
        -- Fallback to original texture
        frame.glow:SetTexture("Interface\\Buttons\\UI-Panel-Button-Glow")
        frame.glow:SetTexCoord(0, 1, 0, 1)
        
        -- Using standard texture
    end
    
    frame.glow:SetBlendMode("ADD")
    frame.glow:SetAlpha(0)
    
    -- Theme-specific overlay texture using the atlas system
    frame.themeOverlay = frame:CreateTexture(nil, "OVERLAY")
    frame.themeOverlay:SetAllPoints(frame.icon)
    frame.themeOverlay:SetBlendMode("ADD")
    frame.themeOverlay:SetAlpha(0)
    
    -- Pre-load the theme-specific overlays from the theme's atlas
    local theme = VUI.db.profile.appearance.theme or "thunderstorm"
    local sparkTexture = "Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. theme .. "\\spark.tga"
    local sparkTextureInfo = VUI:GetTextureCached(sparkTexture)
    
    if sparkTextureInfo and sparkTextureInfo.isAtlas then
        -- Theme texture preloaded for performance optimization
    end
    
    -- Cooldown swipe
    frame.cooldown = CreateFrame("Cooldown", frame:GetName() .. "Cooldown", frame, "CooldownFrameTemplate")
    frame.cooldown:SetAllPoints()
    frame.cooldown:SetDrawEdge(true)
    
    -- Duration text
    frame.duration = frame:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
    frame.duration:SetPoint("CENTER", frame, "BOTTOM", 0, 2)
    
    -- Stack count
    frame.count = frame:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
    frame.count:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1)
    
    -- Store pool metadata on the frame
    frame.poolInfo = {
        type = "buff",
        index = index,
        inUse = false,
        recycleCount = 0,
        creationTime = GetTime()
    }
    
    -- Add functions to easily manage the frame
    frame.Reset = function(self)
        -- Reset all display properties to default state
        self.icon:SetTexture(nil)
        self.border:SetVertexColor(1, 0, 0, 1)
        self.glow:SetAlpha(0)
        self.themeOverlay:SetAlpha(0)
        self.cooldown:Clear()
        self.duration:SetText("")
        self.count:SetText("")
        
        -- Reset metadata
        self.auraInfo = nil
        self.priority = nil
        self.isPurge = nil
        self.isOffensive = nil
        
        -- Reset position
        self:ClearAllPoints()
        
        -- Return to default size
        local size = VUI.db.profile.modules.buffoverlay.size or 40
        self:SetSize(size, size)
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
            if BuffOverlay.ThemeIntegration then
                BuffOverlay.ThemeIntegration:ApplyThemeToBuffFrame(frame)
            end
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
    
    -- Performance stats updated (visible in configuration panel)
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
    local estimatedSavingsPerFrame = 3 -- KB
    return (self.stats.framesRecycled * estimatedSavingsPerFrame) / 1024 -- Convert to MB
end