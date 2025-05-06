local _, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end

-- Theme Switching Optimization
-- This module improves performance when switching between themes
-- by using the atlas system and implementing efficient theme application techniques

-- Create namespace
VUI.ThemeSwitchingOptimization = {}
local ThemeOpt = VUI.ThemeSwitchingOptimization

-- Configuration
ThemeOpt.config = {
    enabled = true,                      -- Master switch for optimization
    preloadThemes = true,                -- Preload theme atlases
    batchedUpdates = true,               -- Use batched updating when switching themes
    priorityUpdates = true,              -- Update UI elements by priority
    updateBatchSize = 20,                -- Number of elements to update per frame
    delayNonVisibleUpdates = true,       -- Delay updating hidden frames
    throttleThemeSwitching = true,       -- Prevent rapid theme switching
    minimumThemeSwitchInterval = 1.0,    -- Minimum seconds between theme switches
    useAtlasForThemeElements = true,     -- Use texture atlas for theme elements
    transitionEffectsEnabled = true,     -- Use transition effects when switching themes
    transitionDuration = 0.3,            -- Duration of transition effects in seconds
    optimizeColorApplication = true,     -- Use optimized color application methods
    cacheTextureResults = true,          -- Cache texture results for quicker access
    priorityLevels = {                   -- Priority levels for different UI elements
        critical = 1,                    -- Must update immediately (player frame, etc.)
        high = 2,                        -- Update quickly (target frame, action bars)
        medium = 3,                      -- Update normally (party frames, buffs)
        low = 4                          -- Update when possible (non-essential elements)
    }
}

-- State tracking
ThemeOpt.state = {
    lastThemeSwitch = 0,                 -- Time of last theme switch
    currentBatch = {},                   -- Current batch of elements to update
    currentTheme = nil,                  -- Current theme name
    frameUpdateQueue = {},               -- Queue of frames to update
    currentBatchIndex = 1,               -- Current index in the batch
    themeSwitchInProgress = false,       -- Whether a theme switch is in progress
    updateStartTime = 0,                 -- When the theme update started
    preloadedThemes = {},                -- Themes that have been preloaded
    framePriorities = {},                -- Priority of each frame
    textureCache = {},                   -- Cache of texture lookups
    colorCache = {},                     -- Cache of color values
    themeElementCount = 0,               -- Count of theme elements registered
    updatedFrameCount = 0,               -- Number of frames updated in current switch
    skippedFrameCount = 0,               -- Number of frames skipped in current switch
    performanceStats = {                 -- Performance statistics
        switchCount = 0,                 -- Number of theme switches
        averageSwitchTime = 0,           -- Average time to switch themes (ms)
        lastSwitchTime = 0,              -- Time taken for last switch (ms)
        totalElementsUpdated = 0,        -- Total elements updated across all switches
        cachedTexturesUsed = 0,          -- Number of cached textures used
        atlasTexturesUsed = 0            -- Number of atlas textures used
    }
}

-- Initialize the theme switching optimization system
function ThemeOpt:Initialize()
    -- Create a frame for updates
    self.frame = CreateFrame("Frame")
    
    -- Set up update handler
    self.frame:SetScript("OnUpdate", function(_, elapsed)
        if self.state.themeSwitchInProgress then
            self:ProcessThemeUpdateBatch()
        end
    end)
    
    -- Hook original theme switching function
    if VUI.SwitchTheme then
        self.originalSwitchTheme = VUI.SwitchTheme
        VUI.SwitchTheme = function(self, themeName, noTransition)
            return ThemeOpt:OptimizedSwitchTheme(themeName, noTransition)
        end
    end
    
    -- Hook frame registration
    if VUI.RegisterThemeElement then
        self.originalRegisterThemeElement = VUI.RegisterThemeElement
        VUI.RegisterThemeElement = function(self, frame, updateFunc, priority)
            return ThemeOpt:RegisterThemeElement(frame, updateFunc, priority)
        end
    end
    
    -- Check for Atlas module
    if VUI.Atlas then
        -- Ensure the common theme textures are preloaded
        self:PreloadCommonThemeTextures()
    end
    
    -- Initialize with current theme
    self.state.currentTheme = VUI.db and VUI.db.profile and VUI.db.profile.theme or "thunderstorm"
    
    -- Register with VUI
    VUI:RegisterModule("ThemeSwitchingOptimization", self)
    

end

-- Register a frame as a theme element with priority
function ThemeOpt:RegisterThemeElement(frame, updateFunc, priority)
    -- Call original function first
    if self.originalRegisterThemeElement then
        self.originalRegisterThemeElement(VUI, frame, updateFunc, priority)
    end
    
    -- Store priority information
    priority = priority or self.config.priorityLevels.medium
    self.state.framePriorities[frame] = priority
    
    -- Update counter
    self.state.themeElementCount = self.state.themeElementCount + 1
    
    return frame
end

-- Optimized theme switching function
function ThemeOpt:OptimizedSwitchTheme(themeName, noTransition)
    if not self.config.enabled then
        -- Fall back to original function if optimization is disabled
        return self.originalSwitchTheme(VUI, themeName, noTransition)
    end
    
    local currentTime = GetTime()
    
    -- Prevent rapid theme switching
    if self.config.throttleThemeSwitching and 
       (currentTime - self.state.lastThemeSwitch) < self.config.minimumThemeSwitchInterval then

        return false
    end
    
    -- Update state
    self.state.lastThemeSwitch = currentTime
    self.state.updateStartTime = debugprofilestop()
    self.state.themeSwitchInProgress = true
    self.state.updatedFrameCount = 0
    self.state.skippedFrameCount = 0
    
    local oldTheme = self.state.currentTheme
    self.state.currentTheme = themeName
    
    -- Update theme in VUI database
    if VUI.db and VUI.db.profile then
        VUI.db.profile.theme = themeName
    end
    
    -- Clear caches
    if self.config.cacheTextureResults then
        self.state.textureCache = {}
        self.state.colorCache = {}
    end
    
    -- Preload the new theme's atlas if needed
    if self.config.preloadThemes and VUI.Atlas and not self.state.preloadedThemes[themeName] then
        self:PreloadThemeAtlas(themeName)
    end
    
    -- Apply transition effect if enabled
    if self.config.transitionEffectsEnabled and not noTransition then
        self:ApplyTransitionEffect(oldTheme, themeName)
    end
    
    -- Build the update queue
    self:BuildUpdateQueue()
    
    -- Start processing the queue

    
    -- Increment statistics
    self.state.performanceStats.switchCount = self.state.performanceStats.switchCount + 1
    
    return true
end

-- Build a priority-based queue of frames to update
function ThemeOpt:BuildUpdateQueue()
    -- Clear existing queue
    self.state.frameUpdateQueue = {}
    
    -- Create separate queues for each priority
    local priorityQueues = {{}, {}, {}, {}}
    
    -- Get all registered theme elements
    local themeElements = VUI.themeElements or {}
    
    -- Sort elements into priority queues
    for frame, updateInfo in pairs(themeElements) do
        local priority = self.state.framePriorities[frame] or self.config.priorityLevels.medium
        
        -- Skip hidden frames if configured to delay them
        if self.config.delayNonVisibleUpdates and type(frame.IsShown) == "function" and not frame:IsShown() then
            table.insert(priorityQueues[4], {frame = frame, updateFunc = updateInfo.updateFunc})
            self.state.skippedFrameCount = self.state.skippedFrameCount + 1
        else
            table.insert(priorityQueues[priority], {frame = frame, updateFunc = updateInfo.updateFunc})
        end
    end
    
    -- Combine queues in priority order
    for priority = 1, 4 do
        for _, info in ipairs(priorityQueues[priority]) do
            table.insert(self.state.frameUpdateQueue, info)
        end
    end
    
    -- Reset batch index
    self.state.currentBatchIndex = 1
    

end

-- Process a batch of theme updates
function ThemeOpt:ProcessThemeUpdateBatch()
    if not self.state.themeSwitchInProgress then
        return
    end
    
    local batchSize = self.config.updateBatchSize
    local queue = self.state.frameUpdateQueue
    local startIndex = self.state.currentBatchIndex
    local endIndex = math.min(startIndex + batchSize - 1, #queue)
    local updatedThisFrame = 0
    
    -- Process batch
    for i = startIndex, endIndex do
        local info = queue[i]
        if info and info.frame and info.updateFunc then
            -- Measure update time
            local startTime = debugprofilestop()
            
            -- Update the frame
            local success = pcall(info.updateFunc, info.frame)
            
            local updateTime = debugprofilestop() - startTime
            
            -- Update statistics
            if success then
                self.state.updatedFrameCount = self.state.updatedFrameCount + 1
                self.state.performanceStats.totalElementsUpdated = 
                    self.state.performanceStats.totalElementsUpdated + 1
            end
            
            updatedThisFrame = updatedThisFrame + 1
        end
    end
    
    -- Update batch index
    self.state.currentBatchIndex = endIndex + 1
    
    -- Check if we're done
    if self.state.currentBatchIndex > #queue then
        self:CompleteThemeSwitch()
    end
end

-- Complete the theme switching process
function ThemeOpt:CompleteThemeSwitch()
    -- Calculate time taken
    local endTime = debugprofilestop()
    local timeTaken = endTime - self.state.updateStartTime
    
    -- Update statistics
    self.state.performanceStats.lastSwitchTime = timeTaken
    
    -- Update rolling average
    if self.state.performanceStats.switchCount > 1 then
        self.state.performanceStats.averageSwitchTime = 
            self.state.performanceStats.averageSwitchTime + 
            ((timeTaken - self.state.performanceStats.averageSwitchTime) / 
            self.state.performanceStats.switchCount)
    else
        self.state.performanceStats.averageSwitchTime = timeTaken
    end
    
    -- Reset state
    self.state.themeSwitchInProgress = false
    
    -- Notify system of completion
    VUI:SendMessage("VUI_THEME_SWITCH_COMPLETE", self.state.currentTheme)
end

-- Apply transition effect between themes
function ThemeOpt:ApplyTransitionEffect(oldTheme, newTheme)
    -- This is a placeholder for theme transition effects
    -- Could implement fading, sliding, or other transition effects
    
    -- For now, we'll just do a basic fade-out/fade-in using the UIFrameFadeOut/In functions if available
    if UIFrameFadeOut and UIFrameFadeIn and VUI.UIParent then
        local duration = self.config.transitionDuration / 2
        
        -- Fade out
        UIFrameFadeOut(VUI.UIParent, duration, 1, 0.7)
        
        -- Schedule fade in after update queue starts processing
        C_Timer.After(duration, function()
            UIFrameFadeIn(VUI.UIParent, duration, 0.7, 1)
        end)
    end
end

-- Preload a theme's texture atlas
function ThemeOpt:PreloadThemeAtlas(themeName)
    if not VUI.Atlas then return end
    
    VUI.Atlas:PreloadAtlas("themes." .. themeName)
    self.state.preloadedThemes[themeName] = true
end

-- Preload common theme textures
function ThemeOpt:PreloadCommonThemeTextures()
    if not VUI.Atlas then return end
    
    -- Preload common atlas
    VUI.Atlas:PreloadAtlas("common")
    
    -- Also preload the default theme
    local defaultTheme = "thunderstorm"
    self:PreloadThemeAtlas(defaultTheme)

end

-- Get optimized texture for theme
function ThemeOpt:GetOptimizedTexture(texturePath, theme)
    if not self.config.cacheTextureResults or not texturePath then
        return VUI:GetTexture(texturePath)
    end
    
    -- Use cached result if available
    local cacheKey = texturePath .. (theme or "")
    if self.state.textureCache[cacheKey] then
        self.state.performanceStats.cachedTexturesUsed = 
            self.state.performanceStats.cachedTexturesUsed + 1
        return self.state.textureCache[cacheKey]
    end
    
    -- Get texture using VUI's function
    local texture = VUI:GetTexture(texturePath)
    
    -- Check if it's an atlas texture
    if texture and texture.isAtlas then
        self.state.performanceStats.atlasTexturesUsed = 
            self.state.performanceStats.atlasTexturesUsed + 1
    end
    
    -- Cache the result
    self.state.textureCache[cacheKey] = texture
    
    return texture
end

-- Get optimized color for theme
function ThemeOpt:GetOptimizedColor(colorName, theme)
    if not self.config.cacheTextureResults or not colorName then
        return VUI:GetThemeColor(colorName)
    end
    
    -- Use cached result if available
    local cacheKey = colorName .. (theme or "")
    if self.state.colorCache[cacheKey] then
        return self.state.colorCache[cacheKey]
    end
    
    -- Get color using VUI's function
    local r, g, b, a = VUI:GetThemeColor(colorName)
    local color = {r = r, g = g, b = b, a = a}
    
    -- Cache the result
    self.state.colorCache[cacheKey] = color
    
    return color.r, color.g, color.b, color.a
end

-- Get performance statistics
function ThemeOpt:GetStats()
    local stats = {
        elementsRegistered = self.state.themeElementCount,
        switchCount = self.state.performanceStats.switchCount,
        averageSwitchTime = string.format("%.2fms", self.state.performanceStats.averageSwitchTime),
        lastSwitchTime = string.format("%.2fms", self.state.performanceStats.lastSwitchTime),
        totalElementsUpdated = self.state.performanceStats.totalElementsUpdated,
        cachedTexturesUsed = self.state.performanceStats.cachedTexturesUsed,
        atlasTexturesUsed = self.state.performanceStats.atlasTexturesUsed
    }
    
    return stats
end

-- Register a frame for the optimization system
function ThemeOpt:RegisterFrame(frame, updateFunc, priority)
    priority = priority or self.config.priorityLevels.medium
    self.state.framePriorities[frame] = priority
    return frame
end

-- Hook into the theme element registration if we're initializing after VUI
if not VUI.SwitchTheme then
    -- Wait for VUI to be initialized by hooking into OnInitialize
    local originalOnInitialize = VUI.OnInitialize
    VUI.OnInitialize = function(self, ...)
        -- Call the original OnInitialize first
        if originalOnInitialize then
            originalOnInitialize(self, ...)
        end
        
        -- Initialize our theme optimization
        if ThemeOpt and ThemeOpt.Initialize then
            ThemeOpt:Initialize()
        end
    end
else
    -- Initialize now
    ThemeOpt:Initialize()
end

-- Return the module
return ThemeOpt