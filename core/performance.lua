local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end

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

-- Memory optimization tools
VUI.Performance.Memory = {}

-- Create a frame pool for reusing frames instead of creating new ones
function VUI.Performance.Memory:CreateFramePool(frameType, parent, template, resetterFunc)
    local pool = {}
    pool.frameType = frameType or "Frame"
    pool.parent = parent
    pool.template = template
    pool.resetterFunc = resetterFunc
    pool.activeFrames = {}
    pool.inactiveFrames = {}
    
    -- Acquire a frame from the pool or create a new one
    function pool:Acquire()
        local frame
        
        if #self.inactiveFrames > 0 then
            -- Reuse an inactive frame
            frame = table.remove(self.inactiveFrames)
        else
            -- Create a new frame
            frame = CreateFrame(self.frameType, nil, self.parent, self.template)
            -- Add a reference to the pool
            frame.poolReference = self
        end
        
        -- Mark as active and show
        frame:Show()
        self.activeFrames[frame] = true
        
        return frame
    end
    
    -- Release a frame back to the pool
    function pool:Release(frame)
        if not frame or not self.activeFrames[frame] then
            return
        end
        
        -- Apply the resetter function if provided
        if self.resetterFunc then
            self.resetterFunc(frame)
        end
        
        -- Hide and mark as inactive
        frame:Hide()
        frame:ClearAllPoints()
        
        -- Move from active to inactive
        self.activeFrames[frame] = nil
        table.insert(self.inactiveFrames, frame)
    end
    
    -- Release all active frames
    function pool:ReleaseAll()
        for frame in pairs(self.activeFrames) do
            self:Release(frame)
        end
    end
    
    -- Get the number of active frames
    function pool:GetNumActive()
        local count = 0
        for _ in pairs(self.activeFrames) do
            count = count + 1
        end
        return count
    end
    
    -- Get total number of frames (active + inactive)
    function pool:GetTotalCount()
        return self:GetNumActive() + #self.inactiveFrames
    end
    
    return pool
end

-- Texture atlas system
VUI.Performance.TextureAtlas = {}

-- Register a texture atlas
function VUI.Performance.TextureAtlas:Register(atlasName, texturePath, entries)
    if not VUI.TextureAtlases then
        VUI.TextureAtlases = {}
    end
    
    -- Store the atlas info
    VUI.TextureAtlases[atlasName] = {
        path = texturePath,
        entries = entries or {}
    }
end

-- Get a texture from an atlas
function VUI.Performance.TextureAtlas:GetTexture(atlasName, entryName)
    if not VUI.TextureAtlases or not VUI.TextureAtlases[atlasName] then
        return nil, nil, nil, nil
    end
    
    local atlas = VUI.TextureAtlases[atlasName]
    local entry = atlas.entries[entryName]
    
    if not entry then
        return nil, nil, nil, nil
    end
    
    return atlas.path, entry[1], entry[2], entry[3], entry[4]
end

-- Apply a texture from an atlas to a frame
function VUI.Performance.TextureAtlas:ApplyToTexture(texture, atlasName, entryName)
    if not texture then return end
    
    local path, left, right, top, bottom = self:GetTexture(atlasName, entryName)
    
    if path then
        texture:SetTexture(path)
        if left and right and top and bottom then
            texture:SetTexCoord(left, right, top, bottom)
        end
        return true
    end
    
    return false
end

-- Combat optimizations
VUI.Performance.Combat = {}

-- Settings
VUI.Performance.Combat.config = {
    enabled = true,
    throttleUIUpdates = true,
    disableAnimations = false,
    reduceParticles = false,
    optimizationLevel = 2  -- 1=low, 2=medium, 3=high
}

-- Function to apply combat optimization modes
function VUI.Performance.Combat:ApplyOptimizations()
    -- Only apply if enabled and in combat
    if not self.config.enabled or not InCombatLockdown() then
        if self.optimizationsActive then
            self:RemoveOptimizations()
        end
        return
    end
    
    -- Mark as active
    self.optimizationsActive = true
    
    -- Apply throttling to UI updates
    if self.config.throttleUIUpdates then
        -- Throttle all registered frames with OnUpdate handlers
        for _, frame in pairs(VUI.frames or {}) do
            if frame.OnUpdate and not frame.throttled then
                local originalOnUpdate = frame.OnUpdate
                frame.originalOnUpdate = originalOnUpdate
                frame.throttled = true
                
                frame.OnUpdate = function(self, elapsed)
                    self.updateThrottle = (self.updateThrottle or 0) + elapsed
                    if self.updateThrottle >= 0.1 then  -- 100ms throttle
                        self.updateThrottle = 0
                        return originalOnUpdate(self, elapsed)
                    end
                end
            end
        end
    end
    
    -- Disable animations temporarily
    if self.config.disableAnimations then
        -- Store and disable animations
        if not self.originalAnimationSettings then
            self.originalAnimationSettings = GetCVar("ffxGlow")
            SetCVar("ffxGlow", "0")
        end
    end
    
    -- Reduce particle effects
    if self.config.reduceParticles and self.config.optimizationLevel >= 3 then
        if not self.originalParticleSettings then
            self.originalParticleSettings = {
                spellDensity = GetCVar("SpellDensity"),
                ffxDeath = GetCVar("ffxDeath")
            }
            SetCVar("SpellDensity", "4") -- Reduced density
            SetCVar("ffxDeath", "0")    -- Disable death effects
        end
    end
end

-- Function to remove combat optimizations
function VUI.Performance.Combat:RemoveOptimizations()
    -- Restore throttled frames
    for _, frame in pairs(VUI.frames or {}) do
        if frame.throttled and frame.originalOnUpdate then
            frame.OnUpdate = frame.originalOnUpdate
            frame.originalOnUpdate = nil
            frame.throttled = nil
            frame.updateThrottle = nil
        end
    end
    
    -- Restore animation settings
    if self.originalAnimationSettings then
        SetCVar("ffxGlow", self.originalAnimationSettings)
        self.originalAnimationSettings = nil
    end
    
    -- Restore particle settings
    if self.originalParticleSettings then
        SetCVar("SpellDensity", self.originalParticleSettings.spellDensity)
        SetCVar("ffxDeath", self.originalParticleSettings.ffxDeath)
        self.originalParticleSettings = nil
    end
    
    -- Mark as inactive
    self.optimizationsActive = false
end

-- Initialize performance monitoring
VUI.Performance.Monitoring = {}

-- Initialize monitoring
function VUI.Performance.Monitoring:Initialize()
    self.frame = CreateFrame("Frame")
    self.stats = {
        fps = {},
        memoryUsage = {},
        cpuUsage = {},
        timings = {}
    }
    
    -- Setup monitoring
    self.frame:SetScript("OnUpdate", function(_, elapsed)
        self:OnUpdate(elapsed)
    end)
    
    -- Create timing function
    self.StartTimer = function(name)
        self.stats.timings[name] = {
            start = debugprofilestop(),
            calls = (self.stats.timings[name] and self.stats.timings[name].calls or 0) + 1
        }
    end
    
    self.StopTimer = function(name)
        if self.stats.timings[name] and self.stats.timings[name].start then
            local elapsed = debugprofilestop() - self.stats.timings[name].start
            self.stats.timings[name].total = (self.stats.timings[name].total or 0) + elapsed
            self.stats.timings[name].average = self.stats.timings[name].total / self.stats.timings[name].calls
            self.stats.timings[name].start = nil
        end
    end
end

-- Update function for monitoring
function VUI.Performance.Monitoring:OnUpdate(elapsed)
    self.updateTimer = (self.updateTimer or 0) + elapsed
    
    -- Update stats every second
    if self.updateTimer >= 1.0 then
        -- Track FPS
        table.insert(self.stats.fps, GetFramerate())
        if #self.stats.fps > 60 then table.remove(self.stats.fps, 1) end
        
        -- Track memory usage
        local memory = collectgarbage("count")
        table.insert(self.stats.memoryUsage, memory)
        if #self.stats.memoryUsage > 60 then table.remove(self.stats.memoryUsage, 1) end
        
        self.updateTimer = 0
    end
end

-- Get performance statistics
function VUI.Performance.Monitoring:GetStats()
    local stats = {
        fps = {
            current = GetFramerate(),
            average = 0,
            min = 999,
            max = 0
        },
        memory = {
            current = collectgarbage("count"),
            change = 0,
            peak = 0
        },
        timers = {}
    }
    
    -- Calculate FPS stats
    if #self.stats.fps > 0 then
        local sum = 0
        for _, fps in ipairs(self.stats.fps) do
            sum = sum + fps
            stats.fps.min = math.min(stats.fps.min, fps)
            stats.fps.max = math.max(stats.fps.max, fps)
        end
        stats.fps.average = sum / #self.stats.fps
    end
    
    -- Calculate memory stats
    if #self.stats.memoryUsage > 1 then
        stats.memory.change = stats.memory.current - self.stats.memoryUsage[1]
        stats.memory.peak = math.max(unpack(self.stats.memoryUsage))
    end
    
    -- Copy timing stats
    for name, timing in pairs(self.stats.timings) do
        stats.timers[name] = {
            calls = timing.calls or 0,
            total = timing.total or 0,
            average = timing.average or 0
        }
    end
    
    return stats
end

-- Reset performance monitoring
function VUI.Performance.Monitoring:Reset()
    self.stats = {
        fps = {},
        memoryUsage = {},
        cpuUsage = {},
        timings = {}
    }
    collectgarbage("collect")
end

-- Initialize monitoring on load
VUI.Performance.Monitoring:Initialize()

-- Lite Mode Support
VUI.Performance.LiteMode = {}

-- Lite Mode Configuration
VUI.Performance.LiteMode.config = {
    enabled = false,
    reducedVisualEffects = true,
    disableNonEssentialAnimations = true,
    minimalTextures = true,
    reduceParticleEffects = true,
    disableModuleFeatures = {
        -- List of module features to disable in lite mode
        buffoverlay = { "animations", "glow" },
        unitframes = { "portraits", "auras", "castbars" },
        actionbars = { "buttonGlow", "macroText" },
        nameplates = { "castBars", "auras" }
    },
    moduleDisableList = {
        -- Non-essential modules to disable in lite mode
        "msbt",           -- Disable scrolling battle text
        "detailsskin",    -- Disable Details skin
        "trufigcd",       -- Disable spell activation display
        "omnicd"          -- Disable cooldown tracking
    }
}

-- Function to enable/disable lite mode
function VUI.Performance.LiteMode:Toggle(enable)
    self.config.enabled = enable
    
    if enable then
        self:Enable()
    else
        self:Disable()
    end
end

-- Enable Lite Mode
function VUI.Performance.LiteMode:Enable()
    if not self.config.enabled then return end
    
    -- Store original settings for restoration later
    self:StoreOriginalSettings()
    
    -- Apply visual reductions
    if self.config.reducedVisualEffects then
        self:ApplyReducedVisuals()
    end
    
    -- Disable non-essential animations
    if self.config.disableNonEssentialAnimations then
        self:DisableNonEssentialAnimations()
    end
    
    -- Apply minimal textures
    if self.config.minimalTextures then
        self:ApplyMinimalTextures()
    end
    
    -- Disable certain module features
    self:DisableModuleFeatures()
    
    -- Disable non-essential modules
    self:DisableNonEssentialModules()
    
    -- Apply performance optimizations
    VUI.Performance.Combat.config.throttleUIUpdates = true
    VUI.Performance.Combat.config.disableAnimations = true
    VUI.Performance.Combat.config.reduceParticles = true
    VUI.Performance.Combat.config.optimizationLevel = 3 -- High optimization
    
    -- Apply combat optimizations even outside of combat
    VUI.Performance.Combat:ApplyOptimizations()
    
    -- Print info message
    VUI:Print("Lite Mode enabled - performance optimizations active.")
end

-- Disable Lite Mode
function VUI.Performance.LiteMode:Disable()
    -- Restore original settings
    self:RestoreOriginalSettings()
    
    -- Restore animations
    self:RestoreAnimations()
    
    -- Restore textures
    self:RestoreTextures()
    
    -- Re-enable module features
    self:RestoreModuleFeatures()
    
    -- Re-enable modules
    self:RestoreModules()
    
    -- Reset performance optimizations
    VUI.Performance.Combat.config.throttleUIUpdates = false
    VUI.Performance.Combat.config.disableAnimations = false
    VUI.Performance.Combat.config.reduceParticles = false
    VUI.Performance.Combat.config.optimizationLevel = 2 -- Medium optimization
    
    -- Remove combat optimizations if not in combat
    if not InCombatLockdown() then
        VUI.Performance.Combat:RemoveOptimizations()
    end
    
    -- Print info message
    VUI:Print("Lite Mode disabled - visual effects restored.")
end

-- Store original settings before enabling lite mode
function VUI.Performance.LiteMode:StoreOriginalSettings()
    if self.originalSettings then return end
    
    self.originalSettings = {
        modules = {},
        features = {},
        appearance = {}
    }
    
    -- Store module enabled states
    for _, moduleName in ipairs(self.config.moduleDisableList) do
        if VUI.enabledModules and VUI.enabledModules[moduleName] ~= nil then
            self.originalSettings.modules[moduleName] = VUI.enabledModules[moduleName]
        end
    end
    
    -- Store appearance settings
    if VUI.db and VUI.db.profile and VUI.db.profile.appearance then
        self.originalSettings.appearance = {
            textureDensity = VUI.db.profile.appearance.textureDensity,
            particleEffects = VUI.db.profile.appearance.particleEffects,
            animationLevel = VUI.db.profile.appearance.animationLevel
        }
    end
    
    -- Store module feature states
    for moduleName, features in pairs(self.config.disableModuleFeatures) do
        self.originalSettings.features[moduleName] = {}
        
        if VUI.db and VUI.db.profile and VUI.db.profile[moduleName] then
            for _, feature in ipairs(features) do
                if VUI.db.profile[moduleName][feature] ~= nil then
                    self.originalSettings.features[moduleName][feature] = 
                        VUI.db.profile[moduleName][feature]
                end
            end
        end
    end
end

-- Apply reduced visual settings
function VUI.Performance.LiteMode:ApplyReducedVisuals()
    if VUI.db and VUI.db.profile and VUI.db.profile.appearance then
        -- Reduce particle effects
        VUI.db.profile.appearance.particleEffects = 0
        
        -- Reduce visual effects level
        VUI.db.profile.appearance.visualEffects = 1 -- Low
        
        -- Reduce texture quality
        VUI.db.profile.appearance.textureDensity = 1 -- Low
    end
    
    -- Apply changes to Blizzard settings if possible
    if GetCVar then
        -- Store original values
        self.originalCVars = self.originalCVars or {
            spellDensity = GetCVar("SpellDensity"),
            ffxGlow = GetCVar("ffxGlow"),
            ffxDeath = GetCVar("ffxDeath"),
            ffxNetherWorld = GetCVar("ffxNetherWorld")
        }
        
        -- Reduce spell effects density
        SetCVar("SpellDensity", "4") -- Reduced density
        
        -- Disable other effects
        SetCVar("ffxGlow", "0")
        SetCVar("ffxDeath", "0")
        SetCVar("ffxNetherWorld", "0")
    end
end

-- Disable non-essential animations
function VUI.Performance.LiteMode:DisableNonEssentialAnimations()
    if VUI.db and VUI.db.profile then
        -- Disable animations globally
        VUI.db.profile.animations = VUI.db.profile.animations or {}
        VUI.db.profile.animations.enabled = false
        
        -- Disable specific animation types
        VUI.db.profile.animations = {
            enabled = false,
            frameAnimsEnabled = false,
            combatAnimsEnabled = false,
            unitframeAnimsEnabled = false
        }
    end
    
    -- Disable animation systems if they exist
    if VUI.Animations then
        VUI.Animations.enabled = false
    end
    
    -- Call animation systems to update
    if VUI.ThemeHelpers and VUI.ThemeHelpers.UpdateAnimationSettings then
        VUI.ThemeHelpers:UpdateAnimationSettings()
    end
end

-- Apply minimal textures
function VUI.Performance.LiteMode:ApplyMinimalTextures()
    if VUI.db and VUI.db.profile and VUI.db.profile.appearance then
        -- Use lower resolution textures
        VUI.db.profile.appearance.frameTextureLevels = "LOW"
        
        -- Reduce texture filtering quality
        VUI.db.profile.appearance.textureFiltering = "BILINEAR"
    end
    
    -- Apply to modules that have texture controls
    if VUI.unitframes and VUI.unitframes.SetTextureQuality then
        VUI.unitframes:SetTextureQuality("LOW")
    end
    
    if VUI.actionbars and VUI.actionbars.SetTextureQuality then
        VUI.actionbars:SetTextureQuality("LOW")
    end
    
    -- Apply theme changes if possible
    if VUI.ThemeIntegration and VUI.ThemeIntegration.ApplyTheme then
        local currentTheme = VUI.db.profile.appearance.theme or "thunderstorm"
        VUI.ThemeIntegration:ApplyTheme(currentTheme, true) -- true = minimal update
    end
end

-- Disable certain module features
function VUI.Performance.LiteMode:DisableModuleFeatures()
    if not VUI.db or not VUI.db.profile then return end
    
    for moduleName, features in pairs(self.config.disableModuleFeatures) do
        if VUI.db.profile[moduleName] then
            for _, feature in ipairs(features) do
                VUI.db.profile[moduleName][feature] = false
            end
        end
    end
    
    -- Special cases for unitframes
    if VUI.db.profile.unitframes then
        -- Disable portraits
        VUI.db.profile.unitframes.showPortraits = false
        
        -- Simplify power bars
        VUI.db.profile.unitframes.simplePowerBars = true
        
        -- Disable 3D models
        VUI.db.profile.unitframes.use3DPortraits = false
    end
    
    -- Apply changes to module systems
    if VUI.unitframes and VUI.unitframes.UpdateAll then
        VUI.unitframes:UpdateAll()
    end
    
    if VUI.actionbars and VUI.actionbars.UpdateAllButtons then
        VUI.actionbars:UpdateAllButtons()
    end
    
    if VUI.nameplates and VUI.nameplates.UpdateAll then
        VUI.nameplates:UpdateAll()
    end
end

-- Disable non-essential modules
function VUI.Performance.LiteMode:DisableNonEssentialModules()
    for _, moduleName in ipairs(self.config.moduleDisableList) do
        -- Only disable if it was enabled
        if VUI.enabledModules and VUI.enabledModules[moduleName] then
            VUI.enabledModules[moduleName] = false
            
            -- Call disable method if it exists
            if VUI[moduleName] and VUI[moduleName].Disable then
                VUI[moduleName]:Disable()
            end
        end
    end
end

-- Restore original settings
function VUI.Performance.LiteMode:RestoreOriginalSettings()
    if not self.originalSettings then return end
    
    -- Restore module enabled states
    for moduleName, enabled in pairs(self.originalSettings.modules) do
        if VUI.enabledModules then
            VUI.enabledModules[moduleName] = enabled
        end
    end
    
    -- Restore appearance settings
    if VUI.db and VUI.db.profile and VUI.db.profile.appearance and self.originalSettings.appearance then
        VUI.db.profile.appearance.textureDensity = self.originalSettings.appearance.textureDensity
        VUI.db.profile.appearance.particleEffects = self.originalSettings.appearance.particleEffects
        VUI.db.profile.appearance.animationLevel = self.originalSettings.appearance.animationLevel
    end
    
    -- Restore CVars
    if self.originalCVars and GetCVar then
        SetCVar("SpellDensity", self.originalCVars.spellDensity)
        SetCVar("ffxGlow", self.originalCVars.ffxGlow)
        SetCVar("ffxDeath", self.originalCVars.ffxDeath)
        SetCVar("ffxNetherWorld", self.originalCVars.ffxNetherWorld)
    end
    
    -- Clear original settings
    self.originalSettings = nil
    self.originalCVars = nil
end

-- Restore animations
function VUI.Performance.LiteMode:RestoreAnimations()
    if VUI.db and VUI.db.profile then
        -- Enable animations globally
        VUI.db.profile.animations = VUI.db.profile.animations or {}
        VUI.db.profile.animations.enabled = true
        
        -- Enable specific animation types
        VUI.db.profile.animations = {
            enabled = true,
            frameAnimsEnabled = true,
            combatAnimsEnabled = true,
            unitframeAnimsEnabled = true
        }
    end
    
    -- Enable animation systems if they exist
    if VUI.Animations then
        VUI.Animations.enabled = true
    end
    
    -- Call animation systems to update
    if VUI.ThemeHelpers and VUI.ThemeHelpers.UpdateAnimationSettings then
        VUI.ThemeHelpers:UpdateAnimationSettings()
    end
end

-- Restore textures
function VUI.Performance.LiteMode:RestoreTextures()
    if VUI.db and VUI.db.profile and VUI.db.profile.appearance then
        -- Use normal resolution textures
        VUI.db.profile.appearance.frameTextureLevels = "HIGH"
        
        -- Restore texture filtering quality
        VUI.db.profile.appearance.textureFiltering = "TRILINEAR"
    end
    
    -- Apply to modules that have texture controls
    if VUI.unitframes and VUI.unitframes.SetTextureQuality then
        VUI.unitframes:SetTextureQuality("HIGH")
    end
    
    if VUI.actionbars and VUI.actionbars.SetTextureQuality then
        VUI.actionbars:SetTextureQuality("HIGH")
    end
    
    -- Apply theme changes
    if VUI.ThemeIntegration and VUI.ThemeIntegration.ApplyTheme then
        local currentTheme = VUI.db.profile.appearance.theme or "thunderstorm"
        VUI.ThemeIntegration:ApplyTheme(currentTheme)
    end
end

-- Restore module features
function VUI.Performance.LiteMode:RestoreModuleFeatures()
    if not VUI.db or not VUI.db.profile or not self.originalSettings or not self.originalSettings.features then 
        return 
    end
    
    for moduleName, features in pairs(self.originalSettings.features) do
        if VUI.db.profile[moduleName] then
            for feature, value in pairs(features) do
                VUI.db.profile[moduleName][feature] = value
            end
        end
    end
    
    -- Apply changes to module systems
    if VUI.unitframes and VUI.unitframes.UpdateAll then
        VUI.unitframes:UpdateAll()
    end
    
    if VUI.actionbars and VUI.actionbars.UpdateAllButtons then
        VUI.actionbars:UpdateAllButtons()
    end
    
    if VUI.nameplates and VUI.nameplates.UpdateAll then
        VUI.nameplates:UpdateAll()
    end
end

-- Restore disabled modules
function VUI.Performance.LiteMode:RestoreModules()
    if not self.originalSettings or not self.originalSettings.modules then return end
    
    for moduleName, enabled in pairs(self.originalSettings.modules) do
        if enabled and VUI.enabledModules then
            VUI.enabledModules[moduleName] = true
            
            -- Call enable method if it exists
            if VUI[moduleName] and VUI[moduleName].Enable then
                VUI[moduleName]:Enable()
            end
        end
    end
end

-- Apply Lite Mode from main VUI object
function VUI:ApplyLiteMode(enable)
    VUI.Performance.LiteMode:Toggle(enable)
end

-- Apply Performance Profile 
function VUI:ApplyPerformanceProfile(profileName)
    if not profileName then return end
    
    -- Create performance profiles
    local profiles = {
        raid = {
            liteMode = true,
            frameLimiter = true,
            throttleUIUpdates = true,
            disableNonEssentialAnimations = true,
            reducedVisualEffects = true,
            minimalTextures = true
        },
        solo = {
            liteMode = false,
            frameLimiter = false,
            throttleUIUpdates = false,
            disableNonEssentialAnimations = false,
            reducedVisualEffects = false,
            minimalTextures = false
        },
        battleground = {
            liteMode = true,
            frameLimiter = true,
            throttleUIUpdates = true,
            disableNonEssentialAnimations = true,
            reducedVisualEffects = true,
            minimalTextures = true
        }
    }
    
    -- Get the selected profile
    local profile = profiles[profileName]
    if not profile then return end
    
    -- Apply profile settings
    self.db.profile.performance = self.db.profile.performance or {}
    self.db.profile.performance.liteMode = profile.liteMode
    self.db.profile.performance.frameLimiter = profile.frameLimiter
    
    -- Update Combat Performance settings
    VUI.Performance.Combat.config.throttleUIUpdates = profile.throttleUIUpdates
    VUI.Performance.Combat.config.disableAnimations = profile.disableNonEssentialAnimations
    VUI.Performance.Combat.config.reduceParticles = profile.reducedVisualEffects
    
    -- Update Lite Mode settings
    VUI.Performance.LiteMode.config.reducedVisualEffects = profile.reducedVisualEffects
    VUI.Performance.LiteMode.config.disableNonEssentialAnimations = profile.disableNonEssentialAnimations
    VUI.Performance.LiteMode.config.minimalTextures = profile.minimalTextures
    
    -- Apply Lite Mode if needed
    self:ApplyLiteMode(profile.liteMode)
    
    -- Apply frame limiter if needed
    if VUI.FrameRateThrottling then
        if profile.frameLimiter then
            VUI.FrameRateThrottling:Enable()
        else
            VUI.FrameRateThrottling:Disable()
        end
    end
    
    -- Print info message
    VUI:Print(profileName:gsub("^%l", string.upper) .. " performance profile applied.")
end

-- Return the module
return VUI.Performance