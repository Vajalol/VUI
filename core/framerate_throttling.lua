--[[
    VUI - Frame Rate Based Throttling System
    Author: VortexQ8
    
    This file implements the frame rate based throttling functionality for VUI,
    allowing the addon to dynamically adjust update frequencies and visual complexity
    based on the player's current frame rate to maintain smooth gameplay.
    
    Key features:
    1. Dynamic update frequency adjustment based on FPS
    2. Automatic detection of frame rate drops
    3. Progressive throttling of non-essential updates
    4. Frame rate brackets with specific optimization strategies
    5. Frame-intensive features auto-disabling at low FPS
]]

local _, VUI = ...
local L = VUI.L

-- Create the FrameRateThrottling system
local FrameRateThrottling = {}
VUI.FrameRateThrottling = FrameRateThrottling

-- Settings with defaults
local settings = {
    enabled = true,                    -- Master toggle
    
    -- FPS thresholds for different performance levels
    highPerformanceThreshold = 60,     -- Above this FPS, use high detail mode
    mediumPerformanceThreshold = 30,   -- Above this FPS, use medium detail mode
    lowPerformanceThreshold = 15,      -- Above this FPS, use low detail mode
    criticalPerformanceThreshold = 10, -- Below this FPS, use minimum detail mode
    
    -- Update frequencies for different performance levels (in seconds)
    highPerformanceUpdateRate = 0.03,  -- ~33 updates per second
    mediumPerformanceUpdateRate = 0.06, -- ~16 updates per second
    lowPerformanceUpdateRate = 0.1,    -- 10 updates per second
    criticalPerformanceUpdateRate = 0.2, -- 5 updates per second
    
    -- Feature control by performance level
    disableAnimationsAtLowFPS = true,  -- Disable animations below lowPerformanceThreshold
    disableShadowsAtLowFPS = true,     -- Disable shadows below lowPerformanceThreshold
    reduceParticlesAtMediumFPS = true, -- Reduce particles below mediumPerformanceThreshold
    disableBlursAtMediumFPS = true,    -- Disable blur effects below mediumPerformanceThreshold
    
    -- Advanced settings
    measurementSampleSize = 10,        -- Number of frames to sample for FPS calculation
    adjustmentFrequency = 1.0,         -- How often to recalculate throttling (seconds)
    combatBoost = true,                -- Prioritize combat features during combat
    adaptiveThrottling = true,         -- Progressively adjust throttling based on FPS trends
    showPerformanceIndicator = false,  -- Show FPS and throttling level indicator
    useHibernation = true,             -- Allow modules to hibernate when not visible
    
    -- Debug settings
    debugMode = false,                 -- Show detailed performance information
    logPerformanceIssues = true        -- Log when performance drops below thresholds
}

-- Performance levels
local PERFORMANCE_LEVEL = {
    HIGH = 4,       -- Full features, highest update frequency
    MEDIUM = 3,     -- Most features, medium update frequency
    LOW = 2,        -- Reduced features, low update frequency
    CRITICAL = 1,   -- Minimum essential features only, lowest update frequency
    HIBERNATION = 0 -- Only absolutely necessary updates (used for hidden UI)
}

-- Internal state
local currentPerformanceLevel = PERFORMANCE_LEVEL.HIGH
local currentFPS = 0
local frameTimeHistory = {}
local lastAdjustmentTime = 0
local hibernatingModules = {}
local throttledFunctions = {}
local frameThrottleManager = {}
local isInCombat = false
local perfTrackerFrame = nil
local measurementInProgress = false
local previousPerformanceLevels = {}
local fpsIndicatorFrame = nil
local statusText = ""
local scheduledUpdates = {}

-- Initialize the frame rate throttling system
function FrameRateThrottling:Initialize()
    -- Register with the database
    self:RegisterSettings()
    
    -- Create frame for measurements and updates
    if not self.frame then
        self.frame = CreateFrame("Frame")
        self.frame:SetScript("OnUpdate", function(_, elapsed)
            self:OnUpdate(elapsed)
        end)
    end
    
    -- Register events
    self:RegisterEvents()
    
    -- Initialize FPS history
    for i = 1, settings.measurementSampleSize do
        frameTimeHistory[i] = 0
    end
    
    -- Set initial performance level
    self:MeasureInitialPerformance()
    
    -- Create performance indicator if enabled
    if settings.showPerformanceIndicator then
        self:CreatePerformanceIndicator()
    end
    
    -- Register with central performance monitoring if available
    if VUI.PerformanceMonitoring then
        VUI.PerformanceMonitoring:RegisterSystem("FrameRateThrottling", function()
            return self:GetPerformanceMetrics()
        end)
    end
    
    VUI:Print("Frame Rate Throttling system initialized")
end

-- Register settings with the database
function FrameRateThrottling:RegisterSettings()
    -- Register with VUI database
    local dbSettings = VUI.db.profile.frameRateThrottling
    if not dbSettings then
        VUI.db.profile.frameRateThrottling = CopyTable(settings)
    else
        -- Update settings from database, keeping defaults for missing values
        for k, v in pairs(settings) do
            if dbSettings[k] == nil then
                dbSettings[k] = v
            else
                settings[k] = dbSettings[k]
            end
        end
    end
end

-- Register for events
function FrameRateThrottling:RegisterEvents()
    -- Register combat events for combat boost feature
    if settings.combatBoost then
        self.frame:RegisterEvent("PLAYER_REGEN_DISABLED")
        self.frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    end
    
    -- Set up event handler
    self.frame:SetScript("OnEvent", function(_, event, ...)
        if event == "PLAYER_REGEN_DISABLED" then
            isInCombat = true
            self:AdjustForCombat(true)
        elseif event == "PLAYER_REGEN_ENABLED" then
            isInCombat = false
            self:AdjustForCombat(false)
        end
    end)
end

-- Main update function
function FrameRateThrottling:OnUpdate(elapsed)
    -- Only process every adjustmentFrequency seconds
    local currentTime = GetTime()
    if currentTime - lastAdjustmentTime < settings.adjustmentFrequency then
        return
    end
    
    -- Update last adjustment time
    lastAdjustmentTime = currentTime
    
    -- Measure current performance
    if not measurementInProgress then
        self:MeasurePerformance()
    end
    
    -- Process any scheduled updates
    self:ProcessScheduledUpdates()
    
    -- Update performance indicator if enabled
    if settings.showPerformanceIndicator and fpsIndicatorFrame then
        self:UpdatePerformanceIndicator()
    end
end

-- Measure current frame rate
function FrameRateThrottling:MeasurePerformance()
    measurementInProgress = true
    
    -- Use GetFramerate() which gives a proper FPS value in WoW
    local fps = GetFramerate()
    
    -- Store in history
    table.insert(frameTimeHistory, fps)
    if #frameTimeHistory > settings.measurementSampleSize then
        table.remove(frameTimeHistory, 1)
    end
    
    -- Calculate average FPS
    local totalFPS = 0
    for _, frameFPS in ipairs(frameTimeHistory) do
        totalFPS = totalFPS + frameFPS
    end
    currentFPS = totalFPS / #frameTimeHistory
    
    -- Determine performance level
    local newPerformanceLevel
    
    if currentFPS >= settings.highPerformanceThreshold then
        newPerformanceLevel = PERFORMANCE_LEVEL.HIGH
    elseif currentFPS >= settings.mediumPerformanceThreshold then
        newPerformanceLevel = PERFORMANCE_LEVEL.MEDIUM
    elseif currentFPS >= settings.lowPerformanceThreshold then
        newPerformanceLevel = PERFORMANCE_LEVEL.LOW
    else
        newPerformanceLevel = PERFORMANCE_LEVEL.CRITICAL
    end
    
    -- Apply adaptive throttling if enabled
    if settings.adaptiveThrottling then
        -- Track performance level history
        table.insert(previousPerformanceLevels, newPerformanceLevel)
        if #previousPerformanceLevels > 5 then
            table.remove(previousPerformanceLevels, 1)
        end
        
        -- If we've been at a lower performance level consistently, make it more aggressive
        local consistentLowPerf = true
        for _, level in ipairs(previousPerformanceLevels) do
            if level >= currentPerformanceLevel then
                consistentLowPerf = false
                break
            end
        end
        
        if consistentLowPerf and #previousPerformanceLevels >= 3 then
            -- Make throttling more aggressive
            newPerformanceLevel = math.max(newPerformanceLevel - 1, PERFORMANCE_LEVEL.CRITICAL)
        end
    end
    
    -- If performance level changed, update throttling
    if newPerformanceLevel ~= currentPerformanceLevel then
        statusText = string.format("Performance level changed from %d to %d (%.1f FPS)", 
            currentPerformanceLevel, newPerformanceLevel, currentFPS)
        
        if settings.debugMode then
            VUI:Print(statusText)
        end
        
        if settings.logPerformanceIssues and newPerformanceLevel < currentPerformanceLevel then
            VUI:Print(string.format("Performance warning: FPS dropped to %.1f. Reducing addon complexity.", currentFPS))
        end
        
        currentPerformanceLevel = newPerformanceLevel
        self:ApplyThrottling()
    end
    
    measurementInProgress = false
end

-- Get initial performance baseline
function FrameRateThrottling:MeasureInitialPerformance()
    -- Use current FPS for initial setting
    currentFPS = GetFramerate()
    
    -- Set initial performance level
    if currentFPS >= settings.highPerformanceThreshold then
        currentPerformanceLevel = PERFORMANCE_LEVEL.HIGH
    elseif currentFPS >= settings.mediumPerformanceThreshold then
        currentPerformanceLevel = PERFORMANCE_LEVEL.MEDIUM
    elseif currentFPS >= settings.lowPerformanceThreshold then
        currentPerformanceLevel = PERFORMANCE_LEVEL.LOW
    else
        currentPerformanceLevel = PERFORMANCE_LEVEL.CRITICAL
    end
    
    -- Apply initial throttling
    self:ApplyThrottling()
    
    if settings.debugMode then
        VUI:Print(string.format("Initial performance level: %d (%.1f FPS)", 
            currentPerformanceLevel, currentFPS))
    end
end

-- Apply throttling based on current performance level
function FrameRateThrottling:ApplyThrottling()
    -- Set update rate based on performance level
    local updateRate
    
    if currentPerformanceLevel == PERFORMANCE_LEVEL.HIGH then
        updateRate = settings.highPerformanceUpdateRate
    elseif currentPerformanceLevel == PERFORMANCE_LEVEL.MEDIUM then
        updateRate = settings.mediumPerformanceUpdateRate
    elseif currentPerformanceLevel == PERFORMANCE_LEVEL.LOW then
        updateRate = settings.lowPerformanceUpdateRate
    else -- CRITICAL or lower
        updateRate = settings.criticalPerformanceUpdateRate
    end
    
    -- Apply update rate to all throttled functions
    for func, info in pairs(throttledFunctions) do
        if type(info.throttle) == "function" then
            -- Update throttle settings
            info.throttle:SetThreshhold(updateRate * (info.multiplier or 1))
        end
    end
    
    -- Handle feature toggling based on performance level
    self:UpdateFeatures()
    
    -- Notify modules about performance level change
    self:NotifyModules()
    
    -- Send message for other systems
    VUI:SendMessage("PERFORMANCE_LEVEL_CHANGED", currentPerformanceLevel, currentFPS)
end

-- Update features based on performance level
function FrameRateThrottling:UpdateFeatures()
    -- Disable animations at low FPS if enabled
    if settings.disableAnimationsAtLowFPS then
        local disableAnimations = currentPerformanceLevel <= PERFORMANCE_LEVEL.LOW
        if VUI.db.profile.animations then
            VUI.db.profile.animations.enabled = not disableAnimations
        end
    end
    
    -- Disable shadows at low FPS if enabled
    if settings.disableShadowsAtLowFPS then
        local disableShadows = currentPerformanceLevel <= PERFORMANCE_LEVEL.LOW
        if VUI.db.profile.appearance then
            VUI.db.profile.appearance.enableShadows = not disableShadows
        end
    end
    
    -- Reduce particles at medium FPS if enabled
    if settings.reduceParticlesAtMediumFPS then
        local reduceParticles = currentPerformanceLevel <= PERFORMANCE_LEVEL.MEDIUM
        if VUI.db.profile.appearance then
            VUI.db.profile.appearance.reducedParticles = reduceParticles
        end
    end
    
    -- Disable blurs at medium FPS if enabled
    if settings.disableBlursAtMediumFPS then
        local disableBlurs = currentPerformanceLevel <= PERFORMANCE_LEVEL.MEDIUM
        if VUI.db.profile.appearance then
            VUI.db.profile.appearance.enableBlur = not disableBlurs
        end
    end
    
    -- Apply hibernation if needed
    if settings.useHibernation and currentPerformanceLevel <= PERFORMANCE_LEVEL.LOW then
        self:HibernateInactiveModules()
    else
        self:WakeHibernatingModules()
    end
end

-- Get current performance level
function FrameRateThrottling:GetPerformanceLevel()
    return currentPerformanceLevel
end

-- Get current FPS
function FrameRateThrottling:GetCurrentFPS()
    return currentFPS
end

-- Register a function to be throttled
function FrameRateThrottling:RegisterThrottledFunction(func, name, multiplier, priority)
    if not func or not name then return end
    
    -- Create throttled version of the function
    local throttle = VUI.Performance:CreateThrottle()
    
    -- Set initial threshold based on current performance level
    local updateRate
    if currentPerformanceLevel == PERFORMANCE_LEVEL.HIGH then
        updateRate = settings.highPerformanceUpdateRate
    elseif currentPerformanceLevel == PERFORMANCE_LEVEL.MEDIUM then
        updateRate = settings.mediumPerformanceUpdateRate
    elseif currentPerformanceLevel == PERFORMANCE_LEVEL.LOW then
        updateRate = settings.lowPerformanceUpdateRate
    else
        updateRate = settings.criticalPerformanceUpdateRate
    end
    
    -- Apply multiplier
    multiplier = multiplier or 1
    updateRate = updateRate * multiplier
    
    -- Set threshold
    throttle:SetThreshhold(updateRate)
    
    -- Set the function
    throttle:SetFunction(func)
    
    -- Store in registered functions
    throttledFunctions[func] = {
        name = name,
        throttle = throttle,
        multiplier = multiplier,
        priority = priority or 5 -- Default medium priority
    }
    
    -- Return the throttled function
    return function(...)
        return throttle:Call(...)
    end
end

-- Unregister a throttled function
function FrameRateThrottling:UnregisterThrottledFunction(func)
    if not func then return end
    throttledFunctions[func] = nil
end

-- Adjust throttling for combat
function FrameRateThrottling:AdjustForCombat(inCombat)
    if not settings.combatBoost then return end
    
    if inCombat then
        -- Prioritize combat-related functions
        for func, info in pairs(throttledFunctions) do
            if info.priority and info.priority >= 8 then -- High priority (combat related)
                -- Reduce throttling for high priority functions
                local updateRate = settings.highPerformanceUpdateRate * 0.8 -- 20% faster
                info.throttle:SetThreshhold(updateRate)
            elseif info.priority and info.priority <= 3 then -- Low priority (non-essential)
                -- Increase throttling for low priority functions
                local updateRate
                if currentPerformanceLevel <= PERFORMANCE_LEVEL.MEDIUM then
                    updateRate = settings.lowPerformanceUpdateRate * 1.5 -- 50% slower
                else
                    updateRate = settings.mediumPerformanceUpdateRate * 1.5
                end
                info.throttle:SetThreshhold(updateRate)
            end
        end
        
        -- Wake hibernating combat-essential modules
        for moduleName, _ in pairs(hibernatingModules) do
            local moduleCategory = self:GetModuleCategory(moduleName)
            if moduleCategory == "combat" then
                self:WakeModule(moduleName)
            end
        end
    else
        -- Restore normal throttling
        self:ApplyThrottling()
    end
end

-- Get module category (requires VUI.DynamicModuleLoading)
function FrameRateThrottling:GetModuleCategory(moduleName)
    if VUI.DynamicModuleLoading and VUI.DynamicModuleLoading.GetModuleList then
        local moduleList = VUI.DynamicModuleLoading:GetModuleList()
        for _, moduleInfo in ipairs(moduleList) do
            if moduleInfo.name == moduleName then
                return moduleInfo.category
            end
        end
    end
    
    return "unknown"
end

-- Hibernate inactive modules to save resources
function FrameRateThrottling:HibernateInactiveModules()
    if not settings.useHibernation then return end
    
    -- Skip if in combat
    if isInCombat then return end
    
    -- Find modules that can be hibernated
    if VUI.DynamicModuleLoading and VUI.DynamicModuleLoading.GetModuleList then
        local moduleList = VUI.DynamicModuleLoading:GetModuleList()
        for _, moduleInfo in ipairs(moduleList) do
            -- Skip core modules and already hibernating modules
            if moduleInfo.state >= 2 and not moduleInfo.isCore and not hibernatingModules[moduleInfo.name] then
                local module = VUI:GetModule(moduleInfo.name)
                if module then
                    -- Check if module can hibernate (has frames that are not visible)
                    local canHibernate = false
                    
                    if module.mainFrame and not module.mainFrame:IsVisible() then
                        canHibernate = true
                    elseif module.frame and not module.frame:IsVisible() then
                        canHibernate = true
                    elseif module.GetAllFrames and type(module.GetAllFrames) == "function" then
                        local frames = module:GetAllFrames()
                        if frames and #frames > 0 then
                            canHibernate = true
                            for _, frame in ipairs(frames) do
                                if frame:IsVisible() then
                                    canHibernate = false
                                    break
                                end
                            end
                        end
                    end
                    
                    -- If module is a good candidate for hibernation
                    if canHibernate then
                        self:HibernateModule(moduleInfo.name)
                    end
                end
            end
        end
    end
end

-- Hibernate a specific module
function FrameRateThrottling:HibernateModule(moduleName)
    if hibernatingModules[moduleName] then
        return -- Already hibernating
    end
    
    local module = VUI:GetModule(moduleName)
    if not module then
        return -- Module not found
    end
    
    if settings.debugMode then
        VUI:Print("Hibernating module: " .. moduleName)
    end
    
    -- Store original update methods
    local originalMethods = {}
    
    -- Look for OnUpdate scripts on module frames
    if module.mainFrame then
        originalMethods.mainFrameOnUpdate = module.mainFrame:GetScript("OnUpdate")
        module.mainFrame:SetScript("OnUpdate", nil)
    end
    
    if module.frame then
        originalMethods.frameOnUpdate = module.frame:GetScript("OnUpdate")
        module.frame:SetScript("OnUpdate", nil)
    end
    
    -- Save the update methods
    hibernatingModules[moduleName] = originalMethods
    
    -- Call hibernate method if available
    if module.OnHibernate and type(module.OnHibernate) == "function" then
        module:OnHibernate()
    end
    
    -- Send message for other systems
    VUI:SendMessage("MODULE_HIBERNATED", moduleName)
end

-- Wake up hibernating modules
function FrameRateThrottling:WakeHibernatingModules()
    for moduleName, _ in pairs(hibernatingModules) do
        self:WakeModule(moduleName)
    end
end

-- Wake up a specific hibernating module
function FrameRateThrottling:WakeModule(moduleName)
    local originalMethods = hibernatingModules[moduleName]
    if not originalMethods then
        return -- Not hibernating
    end
    
    local module = VUI:GetModule(moduleName)
    if not module then
        return -- Module not found
    end
    
    if settings.debugMode then
        VUI:Print("Waking module: " .. moduleName)
    end
    
    -- Restore original update methods
    if module.mainFrame and originalMethods.mainFrameOnUpdate then
        module.mainFrame:SetScript("OnUpdate", originalMethods.mainFrameOnUpdate)
    end
    
    if module.frame and originalMethods.frameOnUpdate then
        module.frame:SetScript("OnUpdate", originalMethods.frameOnUpdate)
    end
    
    -- Remove from hibernating list
    hibernatingModules[moduleName] = nil
    
    -- Call wake method if available
    if module.OnWake and type(module.OnWake) == "function" then
        module:OnWake()
    end
    
    -- Send message for other systems
    VUI:SendMessage("MODULE_AWAKENED", moduleName)
end

-- Notify modules about performance level change
function FrameRateThrottling:NotifyModules()
    if not VUI.modules then return end
    
    for moduleName, _ in pairs(VUI.modules) do
        local module = VUI:GetModule(moduleName)
        if module and module.OnPerformanceLevelChanged and type(module.OnPerformanceLevelChanged) == "function" then
            module:OnPerformanceLevelChanged(currentPerformanceLevel, currentFPS)
        end
    end
end

-- Create a frame rate throttled update function
function FrameRateThrottling:CreateThrottledUpdate(func, frequency, frameThrottle)
    if not func then return nil end
    
    local updateFunc
    
    if frameThrottle then
        -- Create frame-based throttling
        local frameCount = 0
        local frameThreshold = frameThrottle
        
        updateFunc = function(...)
            frameCount = frameCount + 1
            if frameCount >= frameThreshold then
                frameCount = 0
                return func(...)
            end
        end
    else
        -- Create time-based throttling
        local threshold = frequency or 0.1
        local lastUpdate = 0
        
        updateFunc = function(...)
            local currentTime = GetTime()
            if currentTime - lastUpdate >= threshold then
                lastUpdate = currentTime
                return func(...)
            end
        end
    end
    
    -- Register for automatic threshold adjustment
    local updateId = tostring(func)
    frameThrottleManager[updateId] = {
        func = updateFunc,
        frameThrottle = frameThrottle ~= nil,
        baseThreshold = frameThrottle or frequency or 0.1
    }
    
    -- Return the throttled function
    return updateFunc
end

-- Create performance indicator
function FrameRateThrottling:CreatePerformanceIndicator()
    if fpsIndicatorFrame then
        return
    end
    
    fpsIndicatorFrame = CreateFrame("Frame", "VUIPerformanceIndicator", UIParent)
    fpsIndicatorFrame:SetSize(80, 20)
    fpsIndicatorFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -10, -10)
    fpsIndicatorFrame:SetFrameStrata("HIGH")
    
    -- Add background
    local bg = fpsIndicatorFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0, 0, 0, 0.5)
    
    -- Add text
    local text = fpsIndicatorFrame:CreateFontString(nil, "OVERLAY")
    text:SetFontObject(GameFontNormalSmall)
    text:SetPoint("CENTER")
    text:SetText("FPS: --")
    fpsIndicatorFrame.text = text
    
    -- Initialize indicator color
    self:UpdatePerformanceIndicatorColor()
    
    -- Make draggable
    fpsIndicatorFrame:SetMovable(true)
    fpsIndicatorFrame:EnableMouse(true)
    fpsIndicatorFrame:RegisterForDrag("LeftButton")
    fpsIndicatorFrame:SetScript("OnDragStart", function(frame) frame:StartMoving() end)
    fpsIndicatorFrame:SetScript("OnDragStop", function(frame) frame:StopMovingOrSizing() end)
    
    -- Add context menu
    fpsIndicatorFrame:SetScript("OnMouseUp", function(frame, button)
        if button == "RightButton" then
            self:ShowIndicatorMenu()
        end
    end)
end

-- Update performance indicator
function FrameRateThrottling:UpdatePerformanceIndicator()
    if not fpsIndicatorFrame then
        return
    end
    
    fpsIndicatorFrame.text:SetText(string.format("FPS: %.1f", currentFPS))
    self:UpdatePerformanceIndicatorColor()
end

-- Update indicator color based on performance level
function FrameRateThrottling:UpdatePerformanceIndicatorColor()
    if not fpsIndicatorFrame then
        return
    end
    
    local r, g, b = 1, 1, 1
    
    if currentPerformanceLevel == PERFORMANCE_LEVEL.HIGH then
        r, g, b = 0, 1, 0     -- Green
    elseif currentPerformanceLevel == PERFORMANCE_LEVEL.MEDIUM then
        r, g, b = 1, 1, 0     -- Yellow
    elseif currentPerformanceLevel == PERFORMANCE_LEVEL.LOW then
        r, g, b = 1, 0.5, 0   -- Orange
    else
        r, g, b = 1, 0, 0     -- Red
    end
    
    fpsIndicatorFrame.text:SetTextColor(r, g, b)
end

-- Show context menu for performance indicator
function FrameRateThrottling:ShowIndicatorMenu()
    if not LibStub or not LibStub("AceGUI-3.0") then
        return
    end
    
    local AceGUI = LibStub("AceGUI-3.0")
    
    -- Create dropdown menu
    local dropdown = AceGUI:Create("Dropdown")
    dropdown:SetWidth(150)
    dropdown:SetHeight(20)
    dropdown:SetPoint("TOPRIGHT", fpsIndicatorFrame, "BOTTOMRIGHT")
    
    -- Add options
    dropdown:SetList({
        ["hide"] = "Hide Indicator",
        ["reset"] = "Reset Position",
        ["options"] = "Frame Rate Throttling Options"
    })
    
    -- Set handler
    dropdown:SetCallback("OnValueChanged", function(_, _, value)
        if value == "hide" then
            settings.showPerformanceIndicator = false
            VUI.db.profile.frameRateThrottling.showPerformanceIndicator = false
            fpsIndicatorFrame:Hide()
        elseif value == "reset" then
            fpsIndicatorFrame:ClearAllPoints()
            fpsIndicatorFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -10, -10)
        elseif value == "options" then
            VUI:OpenConfigPanel("Performance")
        end
        
        -- Hide dropdown
        dropdown:SetValue(nil)
        dropdown.frame:Hide()
    end)
    
    -- Show dropdown
    dropdown:SetValue(nil)
    dropdown.frame:Show()
end

-- Schedule an update based on performance level
function FrameRateThrottling:ScheduleUpdate(name, func, priority)
    if not name or not func then
        return
    end
    
    -- Default to medium priority
    priority = priority or 5
    
    -- Calculate delay based on performance level
    local delay
    if currentPerformanceLevel == PERFORMANCE_LEVEL.HIGH then
        delay = 0.03 + (0.1 * (10 - priority) / 10)   -- 0.03 to 0.13
    elseif currentPerformanceLevel == PERFORMANCE_LEVEL.MEDIUM then
        delay = 0.1 + (0.2 * (10 - priority) / 10)    -- 0.1 to 0.3
    elseif currentPerformanceLevel == PERFORMANCE_LEVEL.LOW then
        delay = 0.2 + (0.5 * (10 - priority) / 10)    -- 0.2 to 0.7
    else
        delay = 0.5 + (1.0 * (10 - priority) / 10)    -- 0.5 to 1.5
    end
    
    -- Schedule update
    scheduledUpdates[name] = {
        func = func,
        priority = priority,
        executeAt = GetTime() + delay
    }
end

-- Process scheduled updates
function FrameRateThrottling:ProcessScheduledUpdates()
    local currentTime = GetTime()
    local processed = {}
    
    for name, info in pairs(scheduledUpdates) do
        if info.executeAt <= currentTime then
            -- Execute update
            if type(info.func) == "function" then
                info.func()
            end
            
            -- Mark for removal
            table.insert(processed, name)
        end
    end
    
    -- Remove processed updates
    for _, name in ipairs(processed) do
        scheduledUpdates[name] = nil
    end
end

-- Get module specific throttling multiplier based on module importance
function FrameRateThrottling:GetModuleThrottleMultiplier(moduleName)
    -- Base multiplier on module category if using dynamic loading
    if VUI.DynamicModuleLoading then
        local category = self:GetModuleCategory(moduleName)
        
        if category == "core" then
            return 0.7   -- Faster updates for core modules
        elseif category == "combat" then
            -- For combat modules, base on combat state
            if isInCombat then
                return 0.5  -- Much faster updates during combat
            else
                return 1.2  -- Slower updates out of combat
            end
        elseif category == "social" then
            return 1.5   -- Slower updates for social features
        elseif category == "utility" then
            return 2.0   -- Much slower updates for utility features
        end
    end
    
    -- Default multiplier if not using dynamic loading
    return 1.0
end

-- Get performance metrics for monitoring
function FrameRateThrottling:GetPerformanceMetrics()
    local metrics = {
        currentFPS = currentFPS,
        performanceLevel = currentPerformanceLevel,
        inCombat = isInCombat,
        hibernatingModules = {},
        throttledFunctions = 0,
        scheduledUpdates = 0,
        enabled = settings.enabled,
        highPerformanceThreshold = settings.highPerformanceThreshold,
        mediumPerformanceThreshold = settings.mediumPerformanceThreshold,
        lowPerformanceThreshold = settings.lowPerformanceThreshold
    }
    
    -- Count hibernating modules
    for moduleName, _ in pairs(hibernatingModules) do
        table.insert(metrics.hibernatingModules, moduleName)
    end
    
    -- Count throttled functions
    for _, _ in pairs(throttledFunctions) do
        metrics.throttledFunctions = metrics.throttledFunctions + 1
    end
    
    -- Count scheduled updates
    for _, _ in pairs(scheduledUpdates) do
        metrics.scheduledUpdates = metrics.scheduledUpdates + 1
    end
    
    return metrics
end

-- Get config options for the settings panel
function FrameRateThrottling:GetConfigOptions()
    local options = {
        name = "Frame Rate Throttling",
        type = "group",
        args = {
            enabled = {
                order = 1,
                type = "toggle",
                name = "Enable Frame Rate Throttling",
                desc = "Dynamically adjust update frequencies based on FPS",
                get = function() return settings.enabled end,
                set = function(_, value) 
                    settings.enabled = value
                    VUI.db.profile.frameRateThrottling.enabled = value
                end,
                width = "full",
            },
            thresholdsHeader = {
                order = 2,
                type = "header",
                name = "Performance Thresholds",
            },
            highPerformanceThreshold = {
                order = 3,
                type = "range",
                name = "High Performance Threshold",
                desc = "FPS threshold for high performance mode",
                min = 30,
                max = 144,
                step = 1,
                get = function() return settings.highPerformanceThreshold end,
                set = function(_, value) 
                    settings.highPerformanceThreshold = value
                    VUI.db.profile.frameRateThrottling.highPerformanceThreshold = value
                end,
                width = "full",
                disabled = function() return not settings.enabled end,
            },
            mediumPerformanceThreshold = {
                order = 4,
                type = "range",
                name = "Medium Performance Threshold",
                desc = "FPS threshold for medium performance mode",
                min = 15,
                max = 60,
                step = 1,
                get = function() return settings.mediumPerformanceThreshold end,
                set = function(_, value) 
                    settings.mediumPerformanceThreshold = value
                    VUI.db.profile.frameRateThrottling.mediumPerformanceThreshold = value
                end,
                width = "full",
                disabled = function() return not settings.enabled end,
            },
            lowPerformanceThreshold = {
                order = 5,
                type = "range",
                name = "Low Performance Threshold",
                desc = "FPS threshold for low performance mode",
                min = 5,
                max = 30,
                step = 1,
                get = function() return settings.lowPerformanceThreshold end,
                set = function(_, value) 
                    settings.lowPerformanceThreshold = value
                    VUI.db.profile.frameRateThrottling.lowPerformanceThreshold = value
                end,
                width = "full",
                disabled = function() return not settings.enabled end,
            },
            featuresHeader = {
                order = 6,
                type = "header",
                name = "Feature Control",
            },
            disableAnimationsAtLowFPS = {
                order = 7,
                type = "toggle",
                name = "Disable Animations at Low FPS",
                desc = "Automatically disable animations when FPS is low",
                get = function() return settings.disableAnimationsAtLowFPS end,
                set = function(_, value) 
                    settings.disableAnimationsAtLowFPS = value
                    VUI.db.profile.frameRateThrottling.disableAnimationsAtLowFPS = value
                end,
                width = "full",
                disabled = function() return not settings.enabled end,
            },
            disableShadowsAtLowFPS = {
                order = 8,
                type = "toggle",
                name = "Disable Shadows at Low FPS",
                desc = "Automatically disable shadows when FPS is low",
                get = function() return settings.disableShadowsAtLowFPS end,
                set = function(_, value) 
                    settings.disableShadowsAtLowFPS = value
                    VUI.db.profile.frameRateThrottling.disableShadowsAtLowFPS = value
                end,
                width = "full",
                disabled = function() return not settings.enabled end,
            },
            reduceParticlesAtMediumFPS = {
                order = 9,
                type = "toggle",
                name = "Reduce Particles at Medium FPS",
                desc = "Automatically reduce particle effects when FPS drops to medium",
                get = function() return settings.reduceParticlesAtMediumFPS end,
                set = function(_, value) 
                    settings.reduceParticlesAtMediumFPS = value
                    VUI.db.profile.frameRateThrottling.reduceParticlesAtMediumFPS = value
                end,
                width = "full",
                disabled = function() return not settings.enabled end,
            },
            disableBlursAtMediumFPS = {
                order = 10,
                type = "toggle",
                name = "Disable Blur Effects at Medium FPS",
                desc = "Automatically disable blur effects when FPS drops to medium",
                get = function() return settings.disableBlursAtMediumFPS end,
                set = function(_, value) 
                    settings.disableBlursAtMediumFPS = value
                    VUI.db.profile.frameRateThrottling.disableBlursAtMediumFPS = value
                end,
                width = "full",
                disabled = function() return not settings.enabled end,
            },
            advancedHeader = {
                order = 11,
                type = "header",
                name = "Advanced Settings",
            },
            combatBoost = {
                order = 12,
                type = "toggle",
                name = "Combat Performance Boost",
                desc = "Prioritize combat-related features during combat",
                get = function() return settings.combatBoost end,
                set = function(_, value) 
                    settings.combatBoost = value
                    VUI.db.profile.frameRateThrottling.combatBoost = value
                    
                    -- Register/unregister events based on setting
                    if value then
                        self.frame:RegisterEvent("PLAYER_REGEN_DISABLED")
                        self.frame:RegisterEvent("PLAYER_REGEN_ENABLED")
                    else
                        self.frame:UnregisterEvent("PLAYER_REGEN_DISABLED")
                        self.frame:UnregisterEvent("PLAYER_REGEN_ENABLED")
                    end
                end,
                width = "full",
                disabled = function() return not settings.enabled end,
            },
            adaptiveThrottling = {
                order = 13,
                type = "toggle",
                name = "Adaptive Throttling",
                desc = "Progressively adjust throttling based on FPS trends",
                get = function() return settings.adaptiveThrottling end,
                set = function(_, value) 
                    settings.adaptiveThrottling = value
                    VUI.db.profile.frameRateThrottling.adaptiveThrottling = value
                end,
                width = "full",
                disabled = function() return not settings.enabled end,
            },
            useHibernation = {
                order = 14,
                type = "toggle",
                name = "Module Hibernation",
                desc = "Allow modules to hibernate when not visible",
                get = function() return settings.useHibernation end,
                set = function(_, value) 
                    settings.useHibernation = value
                    VUI.db.profile.frameRateThrottling.useHibernation = value
                    
                    -- Wake hibernating modules if disabled
                    if not value then
                        self:WakeHibernatingModules()
                    end
                end,
                width = "full",
                disabled = function() return not settings.enabled end,
            },
            showPerformanceIndicator = {
                order = 15,
                type = "toggle",
                name = "Show Performance Indicator",
                desc = "Display FPS and throttling level indicator",
                get = function() return settings.showPerformanceIndicator end,
                set = function(_, value) 
                    settings.showPerformanceIndicator = value
                    VUI.db.profile.frameRateThrottling.showPerformanceIndicator = value
                    
                    if value and not fpsIndicatorFrame then
                        self:CreatePerformanceIndicator()
                    elseif not value and fpsIndicatorFrame then
                        fpsIndicatorFrame:Hide()
                    elseif value and fpsIndicatorFrame then
                        fpsIndicatorFrame:Show()
                    end
                end,
                width = "full",
                disabled = function() return not settings.enabled end,
            },
            debugMode = {
                order = 16,
                type = "toggle",
                name = "Debug Mode",
                desc = "Show detailed performance information",
                get = function() return settings.debugMode end,
                set = function(_, value) 
                    settings.debugMode = value
                    VUI.db.profile.frameRateThrottling.debugMode = value
                end,
                width = "full",
                disabled = function() return not settings.enabled end,
            },
            logPerformanceIssues = {
                order = 17,
                type = "toggle",
                name = "Log Performance Issues",
                desc = "Log when performance drops below thresholds",
                get = function() return settings.logPerformanceIssues end,
                set = function(_, value) 
                    settings.logPerformanceIssues = value
                    VUI.db.profile.frameRateThrottling.logPerformanceIssues = value
                end,
                width = "full",
                disabled = function() return not settings.enabled end,
            },
            resetToDefaults = {
                order = 18,
                type = "execute",
                name = "Reset to Defaults",
                desc = "Reset all Frame Rate Throttling settings to defaults",
                func = function()
                    -- Reset settings to defaults
                    for k, v in pairs({
                        enabled = true,
                        highPerformanceThreshold = 60,
                        mediumPerformanceThreshold = 30,
                        lowPerformanceThreshold = 15,
                        criticalPerformanceThreshold = 10,
                        highPerformanceUpdateRate = 0.03,
                        mediumPerformanceUpdateRate = 0.06,
                        lowPerformanceUpdateRate = 0.1,
                        criticalPerformanceUpdateRate = 0.2,
                        disableAnimationsAtLowFPS = true,
                        disableShadowsAtLowFPS = true,
                        reduceParticlesAtMediumFPS = true,
                        disableBlursAtMediumFPS = true,
                        measurementSampleSize = 10,
                        adjustmentFrequency = 1.0,
                        combatBoost = true,
                        adaptiveThrottling = true,
                        showPerformanceIndicator = false,
                        useHibernation = true,
                        debugMode = false,
                        logPerformanceIssues = true
                    }) do
                        settings[k] = v
                        VUI.db.profile.frameRateThrottling[k] = v
                    end
                    
                    -- Apply updated settings
                    self:ApplyThrottling()
                    
                    -- Update indicator visibility
                    if settings.showPerformanceIndicator and not fpsIndicatorFrame then
                        self:CreatePerformanceIndicator()
                    elseif not settings.showPerformanceIndicator and fpsIndicatorFrame then
                        fpsIndicatorFrame:Hide()
                    end
                    
                    VUI:Print("Frame Rate Throttling settings reset to defaults")
                end,
                width = "full",
            },
        }
    }
    
    return options
end

-- Register with VUI core
VUI:RegisterScript("core/framerate_throttling.lua")