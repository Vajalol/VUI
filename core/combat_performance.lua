local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end

-- Combat Performance Optimization System
-- This system improves addon performance during combat by throttling non-essential updates
-- and using efficient rendering techniques for high-frequency elements

-- Create namespace
VUI.CombatPerformance = {}
local CombatPerf = VUI.CombatPerformance

-- Configuration
CombatPerf.config = {
    enabled = true,                  -- Master switch
    throttleUpdateRate = 0.1,        -- Update rate for throttled frames during combat (seconds)
    normalUpdateRate = 0.03,         -- Update rate for normal operation (seconds)
    poolSize = 50,                   -- Default frame pool size for frequent updates
    dynamicPoolSizing = true,        -- Adjust pool size based on usage patterns
    priorityLevels = {               -- Priority levels for different update types
        critical = 1,                -- Must update every frame (buffs/debuffs on player/target)
        high = 2,                    -- Update frequently (cooldowns, etc.)
        medium = 3,                  -- Update regularly (party frames, etc.)
        low = 4                      -- Update infrequently during combat (non-essential UI elements)
    },
    reduceLODInCombat = true,        -- Reduce level of detail during combat
    disableAnimationsInCombat = false, -- Whether to disable animations in combat
    throttleTooltipsInCombat = true   -- Whether to reduce tooltip update frequency
}

-- State tracking
CombatPerf.state = {
    inCombat = false,
    lastCombatState = false,
    throttledFrames = {},          -- Frames that are currently throttled
    framePools = {},               -- Frame pools for different UI elements
    updateQueue = {},              -- Queue of frames to update with priority
    updateSchedule = {},           -- Schedule of when frames should update next
    frameUpdateTimes = {},         -- Tracking the time it takes to update frames
    lastUpdate = 0,                -- Last global update time
    throttleEnabled = false,       -- Whether throttling is currently active
    poolUsage = {},                -- Usage statistics for frame pools
    frameTypeCounts = {}           -- Count of different frame types
}

-- Initialize the frame pools
function CombatPerf:InitializePool(poolName, frameCreationFunc, initialSize)
    if self.state.framePools[poolName] then
        return -- Already initialized
    end
    
    initialSize = initialSize or self.config.poolSize
    
    self.state.framePools[poolName] = {
        active = {},         -- Currently active frames
        inactive = {},       -- Available frames for use
        createFunc = frameCreationFunc, -- Function to create new frames
        totalCreated = 0,    -- Total frames created for this pool
        maxUsed = 0,         -- Maximum frames used simultaneously
        lastResize = GetTime() -- Time of last pool resize
    }
    
    -- Pre-create frames for the pool
    for i = 1, initialSize do
        local frame = frameCreationFunc()
        frame:Hide()
        table.insert(self.state.framePools[poolName].inactive, frame)
    end
    
    self.state.framePools[poolName].totalCreated = initialSize

end

-- Acquire a frame from the pool
function CombatPerf:AcquireFrame(poolName)
    if not self.state.framePools[poolName] then

        return nil
    end
    
    local pool = self.state.framePools[poolName]
    
    -- Get frame from inactive pool or create new if needed
    local frame
    if #pool.inactive > 0 then
        frame = table.remove(pool.inactive)
    else
        -- Create new frame
        frame = pool.createFunc()
        pool.totalCreated = pool.totalCreated + 1
        
        -- Log when pools grow significantly
        if pool.totalCreated % 10 == 0 then

        end
    end
    
    -- Reset frame to default state
    frame:Show()
    
    -- Add to active frames
    table.insert(pool.active, frame)
    
    -- Update max usage statistic
    if #pool.active > pool.maxUsed then
        pool.maxUsed = #pool.active
    end
    
    -- Resize pool if we're consistently using most frames
    if self.config.dynamicPoolSizing and (#pool.active > (pool.totalCreated * 0.8)) then
        self:ResizePool(poolName)
    end
    
    return frame
end

-- Release a frame back to the pool
function CombatPerf:ReleaseFrame(poolName, frame)
    if not self.state.framePools[poolName] then

        return
    end
    
    local pool = self.state.framePools[poolName]
    
    -- Find and remove from active frames
    for i, activeFrame in ipairs(pool.active) do
        if activeFrame == frame then
            table.remove(pool.active, i)
            break
        end
    end
    
    -- Reset frame state
    frame:Hide()
    frame:ClearAllPoints()
    
    -- Make available for reuse
    table.insert(pool.inactive, frame)
end

-- Resize a frame pool based on usage patterns
function CombatPerf:ResizePool(poolName)
    local pool = self.state.framePools[poolName]
    if not pool then return end
    
    -- Only resize if it's been at least 60 seconds since last resize
    if (GetTime() - pool.lastResize) < 60 then return end
    
    local currentSize = pool.totalCreated
    local targetSize = math.ceil(pool.maxUsed * 1.5) -- 50% buffer
    
    -- Create additional frames if needed
    if targetSize > currentSize then
        local framesToAdd = targetSize - currentSize
        for i = 1, framesToAdd do
            local frame = pool.createFunc()
            frame:Hide()
            table.insert(pool.inactive, frame)
        end
        
        pool.totalCreated = targetSize

    end
    
    pool.lastResize = GetTime()
end

-- Register a frame for throttling during combat
function CombatPerf:RegisterThrottledFrame(frame, updateFunc, priority, minUpdateRate)
    if not frame or not updateFunc then return end
    
    priority = priority or self.config.priorityLevels.medium
    minUpdateRate = minUpdateRate or self.config.throttleUpdateRate
    
    self.state.throttledFrames[frame] = {
        updateFunc = updateFunc,     -- Function to call for updates
        priority = priority,         -- Update priority
        minUpdateRate = minUpdateRate, -- Minimum update rate in seconds
        lastUpdate = 0,              -- When frame was last updated
        updateTime = 0,              -- Average time to update this frame
        updateCount = 0              -- How many times this frame has been updated
    }
    
    -- Count frame types for statistics
    local frameType = frame:GetObjectType()
    self.state.frameTypeCounts[frameType] = (self.state.frameTypeCounts[frameType] or 0) + 1
end

-- Unregister a frame from throttling
function CombatPerf:UnregisterThrottledFrame(frame)
    if self.state.throttledFrames[frame] then
        self.state.throttledFrames[frame] = nil
        
        -- Update frame type statistics
        local frameType = frame:GetObjectType()
        if self.state.frameTypeCounts[frameType] and self.state.frameTypeCounts[frameType] > 0 then
            self.state.frameTypeCounts[frameType] = self.state.frameTypeCounts[frameType] - 1
        end
    end
end

-- Update a throttled frame
function CombatPerf:UpdateThrottledFrame(frame, force)
    local frameInfo = self.state.throttledFrames[frame]
    if not frameInfo then return end
    
    local currentTime = GetTime()
    
    -- Skip update if throttling is active and not yet time to update
    if self.state.throttleEnabled and not force and 
       (currentTime - frameInfo.lastUpdate) < frameInfo.minUpdateRate then
        return
    end
    
    -- Measure update time for performance tracking
    local startTime = debugprofilestop()
    
    -- Call update function
    frameInfo.updateFunc(frame)
    
    -- Update timing statistics
    local updateTime = debugprofilestop() - startTime
    frameInfo.lastUpdate = currentTime
    
    -- Update rolling average of update time
    frameInfo.updateCount = frameInfo.updateCount + 1
    frameInfo.updateTime = frameInfo.updateTime + 
        ((updateTime - frameInfo.updateTime) / frameInfo.updateCount)
end

-- Process the update queue based on priorities
function CombatPerf:ProcessUpdateQueue(maxTimeMS)
    local startTime = debugprofilestop()
    local currentTime = GetTime()
    local processed = 0
    
    -- Process frames by priority
    for priority = 1, 4 do -- From highest to lowest priority
        for frame, info in pairs(self.state.throttledFrames) do
            -- Only process if this is the right priority
            if info.priority == priority then
                -- Check if we've spent too much time updating frames
                if maxTimeMS and (debugprofilestop() - startTime) > maxTimeMS then
                    return processed
                end
                
                -- Update if needed based on time since last update
                local timeSinceUpdate = currentTime - info.lastUpdate
                local updateNeeded = timeSinceUpdate >= info.minUpdateRate
                
                if updateNeeded then
                    self:UpdateThrottledFrame(frame)
                    processed = processed + 1
                end
            end
            -- No need for continue in Lua 5.1, just let the loop continue naturally
        end
    end
    
    return processed
end

-- Handle combat state changes
function CombatPerf:OnCombatStateChanged(inCombat)
    self.state.inCombat = inCombat
    
    if inCombat then
        self:EnableThrottling()

    else
        self:DisableThrottling()

        
        -- Force update all frames to restore visual state
        for frame, _ in pairs(self.state.throttledFrames) do
            self:UpdateThrottledFrame(frame, true)
        end
    end
    
    -- Notify modules of combat state change
    VUI:SendMessage("VUI_COMBAT_STATE_CHANGED", inCombat)
end

-- Enable throttling
function CombatPerf:EnableThrottling()
    if not self.config.enabled then return end
    
    self.state.throttleEnabled = true
    
    -- Apply combat-specific settings
    if self.config.reduceLODInCombat then
        self:ReduceLOD()
    end
    
    if self.config.disableAnimationsInCombat then
        self:DisableAnimations()
    end
    
    if self.config.throttleTooltipsInCombat then
        self:ThrottleTooltips()
    end
end

-- Disable throttling
function CombatPerf:DisableThrottling()
    self.state.throttleEnabled = false
    
    -- Restore normal settings
    if self.config.reduceLODInCombat then
        self:RestoreLOD()
    end
    
    if self.config.disableAnimationsInCombat then
        self:EnableAnimations()
    end
    
    if self.config.throttleTooltipsInCombat then
        self:RestoreTooltips()
    end
end

-- Reduce level of detail during combat
function CombatPerf:ReduceLOD()
    -- Track original settings to restore later
    if not self.state.originalLODSettings then
        self.state.originalLODSettings = {
            textureFiltering = VUI.db.profile.appearance and VUI.db.profile.appearance.textureFiltering or "TRILINEAR",
            shadowDetail = VUI.db.profile.appearance and VUI.db.profile.appearance.shadowDetail or "HIGH",
            particleDensity = VUI.db.profile.appearance and VUI.db.profile.appearance.particleDensity or 1.0,
            frameTextureLevels = VUI.db.profile.appearance and VUI.db.profile.appearance.frameTextureLevels or "HIGH"
        }
    end
    
    -- Reduce visual quality settings to improve performance
    if VUI.db.profile.appearance then
        -- Reduce texture filtering quality
        VUI.db.profile.appearance.textureFiltering = "BILINEAR"
        
        -- Reduce shadow detail
        VUI.db.profile.appearance.shadowDetail = "LOW"
        
        -- Reduce particle density (effects like spell animations)
        VUI.db.profile.appearance.particleDensity = 0.5
        
        -- Use lower resolution textures for frames
        VUI.db.profile.appearance.frameTextureLevels = "LOW"
    end
    
    -- Apply LOD settings to all UI elements
    self:ApplyLODToFrames(true)
    
    -- Notify modules about LOD change
    VUI:SendMessage("VUI_LOD_CHANGED", "LOW")
    
    -- Update appearance if theme system is available
    if VUI.ThemeIntegration and VUI.ThemeIntegration.ApplyTheme then
        local currentTheme = VUI.db.profile.appearance.theme or "thunderstorm"
        VUI.ThemeIntegration:ApplyTheme(currentTheme, true) -- true = minimal update
    end
end

-- Restore normal level of detail
function CombatPerf:RestoreLOD()
    -- Restore original settings if we have them
    if self.state.originalLODSettings and VUI.db.profile.appearance then
        VUI.db.profile.appearance.textureFiltering = self.state.originalLODSettings.textureFiltering
        VUI.db.profile.appearance.shadowDetail = self.state.originalLODSettings.shadowDetail
        VUI.db.profile.appearance.particleDensity = self.state.originalLODSettings.particleDensity
        VUI.db.profile.appearance.frameTextureLevels = self.state.originalLODSettings.frameTextureLevels
    end
    
    -- Reset LOD on frames
    self:ApplyLODToFrames(false)
    
    -- Notify modules about LOD change
    VUI:SendMessage("VUI_LOD_CHANGED", "NORMAL")
    
    -- Update appearance if theme system is available
    if VUI.ThemeIntegration and VUI.ThemeIntegration.ApplyTheme then
        local currentTheme = VUI.db.profile.appearance.theme or "thunderstorm"
        VUI.ThemeIntegration:ApplyTheme(currentTheme) -- normal update
    end
end

-- Apply LOD settings to frames
function CombatPerf:ApplyLODToFrames(reduceLOD)
    -- Process all throttled frames to apply appropriate LOD settings
    for frame, info in pairs(self.state.throttledFrames) do
        if frame.SetLOD then
            frame:SetLOD(reduceLOD and "LOW" or "HIGH")
        end
        
        -- Apply special handling for common frame types
        local frameType = frame:GetObjectType()
        
        if frameType == "StatusBar" then
            -- Reduce status bar resolution during combat
            if reduceLOD then
                frame:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
            elseif info.originalTexture then
                frame:SetStatusBarTexture(info.originalTexture)
            end
        elseif frameType == "Frame" or frameType == "Button" then
            -- Reduce shadow complexity on general frames
            local hasShadow = frame.shadow or frame.Shadow
            if hasShadow then
                if reduceLOD then
                    -- Store original alpha to restore later
                    if not info.originalShadowAlpha and hasShadow:GetAlpha() then
                        info.originalShadowAlpha = hasShadow:GetAlpha()
                    end
                    hasShadow:SetAlpha(0.3) -- Reduce shadow intensity
                elseif info.originalShadowAlpha then
                    hasShadow:SetAlpha(info.originalShadowAlpha)
                end
            end
        end
    end
    
    -- Also apply to unit frames if they exist
    if VUI.unitframes and VUI.unitframes.frames then
        for _, unitFrame in pairs(VUI.unitframes.frames) do
            if unitFrame.SetLOD then
                unitFrame:SetLOD(reduceLOD and "LOW" or "HIGH")
            end
        end
    end
    
    -- Apply to nameplates if they exist
    if VUI.nameplates and VUI.nameplates.SetLOD then
        VUI.nameplates:SetLOD(reduceLOD and "LOW" or "HIGH")
    end
end

-- Disable animations during combat
function CombatPerf:DisableAnimations()
    -- Store original animation settings
    if not self.state.originalAnimSettings then
        self.state.originalAnimSettings = {
            enabled = VUI.db.profile.animations and VUI.db.profile.animations.enabled or true,
            frameAnimsEnabled = VUI.db.profile.animations and VUI.db.profile.animations.frameAnimsEnabled or true,
            combatAnimsEnabled = VUI.db.profile.animations and VUI.db.profile.animations.combatAnimsEnabled or true,
            uiAnimsEnabled = VUI.db.profile.animations and VUI.db.profile.animations.uiAnimsEnabled or true
        }
    end
    
    -- Disable most animations, but keep essential combat animations
    if VUI.db.profile.animations then
        -- Keep essential animations enabled
        VUI.db.profile.animations.enabled = true
        
        -- Disable non-essential frame animations
        VUI.db.profile.animations.frameAnimsEnabled = false
        
        -- Keep combat animations (they're important)
        VUI.db.profile.animations.combatAnimsEnabled = true
        
        -- Disable UI animations (fades, etc)
        VUI.db.profile.animations.uiAnimsEnabled = false
    end
    
    -- Apply animation settings to all registered animation groups
    if VUI.AnimationManager then
        VUI.AnimationManager:PauseNonEssentialAnimations()
    end
    
    -- Notify modules about animation state change
    VUI:SendMessage("VUI_ANIMATIONS_STATE_CHANGED", false)
end

-- Enable animations when out of combat
function CombatPerf:EnableAnimations()
    -- Restore original animation settings
    if self.state.originalAnimSettings and VUI.db.profile.animations then
        VUI.db.profile.animations.enabled = self.state.originalAnimSettings.enabled
        VUI.db.profile.animations.frameAnimsEnabled = self.state.originalAnimSettings.frameAnimsEnabled
        VUI.db.profile.animations.combatAnimsEnabled = self.state.originalAnimSettings.combatAnimsEnabled
        VUI.db.profile.animations.uiAnimsEnabled = self.state.originalAnimSettings.uiAnimsEnabled
    end
    
    -- Resume animations
    if VUI.AnimationManager then
        VUI.AnimationManager:ResumeAllAnimations()
    end
    
    -- Notify modules about animation state change
    VUI:SendMessage("VUI_ANIMATIONS_STATE_CHANGED", true)
end

-- Throttle tooltip updates during combat
function CombatPerf:ThrottleTooltips()
    -- Store original tooltip settings
    if not self.state.originalTooltipSettings then
        self.state.originalTooltipSettings = {
            updateFrequency = VUI.db.profile.tooltip and VUI.db.profile.tooltip.updateFrequency or 0.1,
            detailLevel = VUI.db.profile.tooltip and VUI.db.profile.tooltip.detailLevel or "HIGH",
            enableEnhancedInfo = VUI.db.profile.tooltip and VUI.db.profile.tooltip.enableEnhancedInfo or true
        }
    end
    
    -- Reduce tooltip update frequency and detail during combat
    if VUI.db.profile.tooltip then
        -- Set slower update frequency for tooltips
        VUI.db.profile.tooltip.updateFrequency = 0.5 -- Once per half second
        
        -- Reduce level of information shown
        VUI.db.profile.tooltip.detailLevel = "LOW"
        
        -- Disable enhanced info that requires additional processing
        VUI.db.profile.tooltip.enableEnhancedInfo = false
    end
    
    -- Apply to GameTooltip
    if GameTooltip and GameTooltip.VUISetUpdateFrequency then
        GameTooltip:VUISetUpdateFrequency(0.5)
    end
    
    -- Notify tooltip module if available
    if VUI.tooltip and VUI.tooltip.SetCombatMode then
        VUI.tooltip:SetCombatMode(true)
    end
end

-- Restore normal tooltip behavior
function CombatPerf:RestoreTooltips()
    -- Restore original tooltip settings
    if self.state.originalTooltipSettings and VUI.db.profile.tooltip then
        VUI.db.profile.tooltip.updateFrequency = self.state.originalTooltipSettings.updateFrequency
        VUI.db.profile.tooltip.detailLevel = self.state.originalTooltipSettings.detailLevel
        VUI.db.profile.tooltip.enableEnhancedInfo = self.state.originalTooltipSettings.enableEnhancedInfo
    end
    
    -- Apply to GameTooltip
    if GameTooltip and GameTooltip.VUISetUpdateFrequency and self.state.originalTooltipSettings then
        GameTooltip:VUISetUpdateFrequency(self.state.originalTooltipSettings.updateFrequency)
    end
    
    -- Notify tooltip module if available
    if VUI.tooltip and VUI.tooltip.SetCombatMode then
        VUI.tooltip:SetCombatMode(false)
    end
end

-- Get performance statistics
function CombatPerf:GetStats()
    local stats = {}
    
    -- Count frames by priority
    stats.framesByPriority = {0, 0, 0, 0}
    for _, info in pairs(self.state.throttledFrames) do
        local priority = info.priority
        stats.framesByPriority[priority] = stats.framesByPriority[priority] + 1
    end
    
    -- Summarize frame pools
    stats.poolStats = {}
    for name, pool in pairs(self.state.framePools) do
        stats.poolStats[name] = {
            total = pool.totalCreated,
            active = #pool.active,
            inactive = #pool.inactive,
            maxUsed = pool.maxUsed
        }
    end
    
    -- Frame type counts
    stats.frameTypes = {}
    for frameType, count in pairs(self.state.frameTypeCounts) do
        stats.frameTypes[frameType] = count
    end
    
    -- Timing information
    stats.averageUpdateTime = 0
    local totalFrames = 0
    for _, info in pairs(self.state.throttledFrames) do
        if info.updateCount > 0 then
            stats.averageUpdateTime = stats.averageUpdateTime + info.updateTime
            totalFrames = totalFrames + 1
        end
    end
    
    if totalFrames > 0 then
        stats.averageUpdateTime = stats.averageUpdateTime / totalFrames
    end
    
    stats.throttlingEnabled = self.state.throttleEnabled
    stats.inCombat = self.state.inCombat
    
    return stats
end

-- Main update function - called from a frame's OnUpdate script
function CombatPerf:OnUpdate(elapsed)
    -- Update combat state from WoW API
    local inCombat = UnitAffectingCombat("player")
    if inCombat ~= self.state.lastCombatState then
        self.state.lastCombatState = inCombat
        self:OnCombatStateChanged(inCombat)
    end
    
    -- Process the update queue
    self.state.lastUpdate = self.state.lastUpdate + elapsed
    
    -- When throttling is active, process only a limited number of frames per update
    if self.state.throttleEnabled then
        -- Process updates with a time budget of 5ms
        self:ProcessUpdateQueue(5)
    else
        -- When out of combat, we can process more frames
        self:ProcessUpdateQueue(10)
    end
end

-- Create update frame
local updateFrame = CreateFrame("Frame")
updateFrame:SetScript("OnUpdate", function(self, elapsed)
    CombatPerf:OnUpdate(elapsed)
end)

-- Handle PLAYER_REGEN_DISABLED event (entering combat)
updateFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
updateFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
updateFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_REGEN_DISABLED" then
        CombatPerf:OnCombatStateChanged(true)
    elseif event == "PLAYER_REGEN_ENABLED" then
        CombatPerf:OnCombatStateChanged(false)
    end
end)

-- Register with VUI
VUI:RegisterModule("CombatPerformance", CombatPerf)

-- Return the module
return CombatPerf